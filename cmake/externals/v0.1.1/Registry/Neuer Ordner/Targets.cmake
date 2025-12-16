# ==============================================================================
# Registry/Targets.cmake – Target Registry for Externals
# ==============================================================================
#
# Module:       Targets.cmake
# Version:      0.1.0
# Date:         2025-12-09
# Part of:      CMake Architecture V2
#
# Description:
#   Maintains a registry of targets created by externals.
#   Provides lookup and validation functions.
#
# Dependencies (must be loaded before):
#   - cmake/core/Errors.cmake
#   - cmake/core/Debug.cmake
#
# Provides:
#   _register_external_target(EXT_NAME TARGET_NAME)
#   _get_external_targets(EXT_NAME OUT_VAR)
#   _has_external_target(EXT_NAME OUT_VAR)
#   _validate_external_targets(EXT_NAME)
#
# Based on:
#   - master_concept v0.1
#   - guidelines v0.1
#
# ==============================================================================

include_guard(GLOBAL)

# ==============================================================================
# Global Properties for Registry
# ==============================================================================

# EXTERNAL_REGISTRY_ALL - List of all registered externals
# EXTERNAL_${NAME}_TARGETS - List of targets for a specific external
# EXTERNAL_${NAME}_PRIMARY_TARGET - Primary target name (usually same as EXT_NAME)

# ==============================================================================
# _register_external_target - Register a target for an external
# ==============================================================================
#[[
    _register_external_target(EXT_NAME TARGET_NAME [PRIMARY])
    
    Registers a CMake target as belonging to an external.
    
    Parameters:
        EXT_NAME    - Name of the external
        TARGET_NAME - Name of the CMake target
        PRIMARY     - Optional: Mark as primary target
    
    Example:
        _register_external_target("imgui" "imgui" PRIMARY)
        _register_external_target("imgui" "imgui_backends")
]]
function(_register_external_target EXT_NAME TARGET_NAME)
    set(_options PRIMARY)
    cmake_parse_arguments(_ARG "${_options}" "" "" ${ARGN})
    
    # Add external to global list if not present
    get_property(_all_externals GLOBAL PROPERTY EXTERNAL_REGISTRY_ALL)
    if(NOT "${EXT_NAME}" IN_LIST _all_externals)
        set_property(GLOBAL APPEND PROPERTY EXTERNAL_REGISTRY_ALL "${EXT_NAME}")
    endif()
    
    # Add target to external's target list
    get_property(_targets GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_TARGETS)
    if(NOT "${TARGET_NAME}" IN_LIST _targets)
        set_property(GLOBAL APPEND PROPERTY EXTERNAL_${EXT_NAME}_TARGETS "${TARGET_NAME}")
    endif()
    
    # Set primary target if specified
    if(_ARG_PRIMARY)
        set_property(GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_PRIMARY_TARGET "${TARGET_NAME}")
    endif()
    
    dbg(${DBG_RARE} "  Registered target: ${TARGET_NAME} (external: ${EXT_NAME})" ID EXTERNALS)
    
endfunction()

# ==============================================================================
# _auto_register_external_targets - Auto-detect and register targets
# ==============================================================================
#[[
    _auto_register_external_targets(EXT_NAME)
    
    Attempts to auto-detect targets created by an external.
    Uses common naming conventions.
    
    Parameters:
        EXT_NAME - Name of the external
    
    Checks for targets:
        - ${EXT_NAME}
        - ${EXT_NAME}::${EXT_NAME}
        - ${ext_name} (lowercase)
]]
function(_auto_register_external_targets EXT_NAME)
    string(TOLOWER "${EXT_NAME}" _ext_lower)
    
    # Check common target naming patterns
    set(_candidates
        "${EXT_NAME}"
        "${EXT_NAME}::${EXT_NAME}"
        "${_ext_lower}"
        "${_ext_lower}::${_ext_lower}"
    )
    
    set(_found_primary FALSE)
    
    foreach(_candidate IN LISTS _candidates)
        if(TARGET ${_candidate})
            if(NOT _found_primary)
                _register_external_target("${EXT_NAME}" "${_candidate}" PRIMARY)
                set(_found_primary TRUE)
            else()
                _register_external_target("${EXT_NAME}" "${_candidate}")
            endif()
        endif()
    endforeach()
    
    if(NOT _found_primary)
        dbg(${DBG_COMMON} "  Warning: No targets found for ${EXT_NAME}" ID EXTERNALS)
    endif()
    
endfunction()

# ==============================================================================
# _get_external_targets - Get all targets for an external
# ==============================================================================
#[[
    _get_external_targets(EXT_NAME OUT_VAR)
    
    Gets list of all registered targets for an external.
    
    Parameters:
        EXT_NAME - Name of the external
        OUT_VAR  - Output variable for target list
]]
function(_get_external_targets EXT_NAME OUT_VAR)
    get_property(_targets GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_TARGETS)
    set(${OUT_VAR} "${_targets}" PARENT_SCOPE)
endfunction()

# ==============================================================================
# _get_external_primary_target - Get primary target for an external
# ==============================================================================
#[[
    _get_external_primary_target(EXT_NAME OUT_VAR)
    
    Gets the primary (main) target for an external.
    
    Parameters:
        EXT_NAME - Name of the external
        OUT_VAR  - Output variable for target name
]]
function(_get_external_primary_target EXT_NAME OUT_VAR)
    get_property(_primary GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_PRIMARY_TARGET)
    
    if("${_primary}" STREQUAL "")
        # Fall back to first registered target
        get_property(_targets GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_TARGETS)
        list(GET _targets 0 _primary)
    endif()
    
    set(${OUT_VAR} "${_primary}" PARENT_SCOPE)
endfunction()

# ==============================================================================
# _has_external_target - Check if external has registered targets
# ==============================================================================
#[[
    _has_external_target(EXT_NAME OUT_VAR)
    
    Checks if an external has at least one registered target.
    
    Parameters:
        EXT_NAME - Name of the external
        OUT_VAR  - Output variable (TRUE/FALSE)
]]
function(_has_external_target EXT_NAME OUT_VAR)
    get_property(_targets GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_TARGETS)
    
    if(_targets)
        set(${OUT_VAR} TRUE PARENT_SCOPE)
    else()
        set(${OUT_VAR} FALSE PARENT_SCOPE)
    endif()
endfunction()

# ==============================================================================
# _validate_external_targets - Validate external has usable targets
# ==============================================================================
#[[
    _validate_external_targets(EXT_NAME)
    
    Validates that an external has at least one usable target.
    Issues E201 if no targets found.
    
    Parameters:
        EXT_NAME - Name of the external
]]
function(_validate_external_targets EXT_NAME)
    _has_external_target("${EXT_NAME}" _has_targets)
    
    if(NOT _has_targets)
        cmake_fatal("E201" "Fetched external '${EXT_NAME}': No target in registry. PostFetch hook required?")
    endif()
    
    # Log registered targets
    _get_external_targets("${EXT_NAME}" _targets)
    dbg(${DBG_COMMON} "  Validated: ${EXT_NAME} has ${_targets}" ID EXTERNALS)
    
endfunction()

# ==============================================================================
# _link_external_to_target - Link external's targets to a consumer target
# ==============================================================================
#[[
    _link_external_to_target(CONSUMER_TARGET EXT_NAME [SCOPE])
    
    Links an external's primary target to a consumer target.
    
    Parameters:
        CONSUMER_TARGET - Target that will use the external
        EXT_NAME        - Name of the external
        SCOPE           - Link scope (PUBLIC/PRIVATE/INTERFACE), default PRIVATE
    
    Example:
        _link_external_to_target("MyApp" "spdlog" PRIVATE)
]]
function(_link_external_to_target CONSUMER_TARGET EXT_NAME)
    set(_options "")
    set(_one_value SCOPE)
    cmake_parse_arguments(_ARG "${_options}" "${_one_value}" "" ${ARGN})
    
    if(NOT _ARG_SCOPE)
        set(_ARG_SCOPE PRIVATE)
    endif()
    
    _get_external_primary_target("${EXT_NAME}" _primary)
    
    if("${_primary}" STREQUAL "")
        cmake_warn("W101" "External '${EXT_NAME}': No target to link")
        return()
    endif()
    
    target_link_libraries(${CONSUMER_TARGET} ${_ARG_SCOPE} ${_primary})
    
    dbg(${DBG_COMMON} "    Linked ${_primary} to ${CONSUMER_TARGET}" ID EXTERNALS)
    
endfunction()

# ==============================================================================
# _print_registry_summary - Debug output of registry state
# ==============================================================================
#[[
    _print_registry_summary()
    
    Prints a summary of all registered externals and their targets.
    Only outputs in debug mode.
]]
function(_print_registry_summary)
    get_property(_all_externals GLOBAL PROPERTY EXTERNAL_REGISTRY_ALL)
    
    if(NOT _all_externals)
        dbg(${DBG_COMMON} "Registry: Empty" ID EXTERNALS)
        return()
    endif()
    
    dbg(${DBG_COMMON} "=== External Registry Summary ===" ID EXTERNALS)
    
    foreach(_ext IN LISTS _all_externals)
        _get_external_targets("${_ext}" _targets)
        _get_external_primary_target("${_ext}" _primary)
        
        dbg(${DBG_COMMON} "  ${_ext}:" ID EXTERNALS)
        dbg(${DBG_COMMON} "    Primary: ${_primary}" ID EXTERNALS)
        dbg(${DBG_COMMON} "    Targets: ${_targets}" ID EXTERNALS)
    endforeach()
    
    dbg(${DBG_COMMON} "=================================" ID EXTERNALS)
    
endfunction()
