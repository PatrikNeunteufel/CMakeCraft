# ==============================================================================
# Targets.cmake – External Target Registry
# ==============================================================================
#
# Module:       Targets.cmake
# Version:      0.2.0
# Date:         2025-12-12
# Part of:      CMake Architecture V2
#
# Description:
#   Registry for external targets. Tracks which targets belong to which
#   externals and provides lookup functionality.
#
# v0.2.0 Changes:
#   - Added framework-specific target patterns (Catch2, GoogleTest)
#   - Enhanced auto-detection for common libraries
#
# Provides:
#   _register_external_target(EXT_NAME TARGET_NAME [PRIMARY])
#   _auto_register_external_targets(EXT_NAME)
#   _get_external_targets(EXT_NAME OUT_VAR)
#   _get_external_primary_target(EXT_NAME OUT_VAR)
#   _has_external_target(EXT_NAME OUT_VAR)
#   _validate_external_targets(EXT_NAME)
#   _link_external_to_target(CONSUMER_TARGET EXT_NAME [SCOPE])
#
# ==============================================================================

include_guard(GLOBAL)

# ==============================================================================
# Framework-Specific Target Mappings
# ==============================================================================
#
# Some libraries create targets with names different from the external name.
# This map defines known patterns for auto-detection.
#

# Catch2 v3 targets
set(_KNOWN_TARGETS_catch2 "Catch2;Catch2WithMain;Catch2::Catch2;Catch2::Catch2WithMain")
set(_PRIMARY_TARGET_catch2 "Catch2WithMain")

# GoogleTest targets
set(_KNOWN_TARGETS_googletest "gtest;gtest_main;gmock;gmock_main;GTest::gtest;GTest::gtest_main;GTest::gmock;GTest::gmock_main")
set(_PRIMARY_TARGET_googletest "gtest_main")

# GLFW targets
set(_KNOWN_TARGETS_glfw "glfw;glfw3;glfw::glfw")
set(_PRIMARY_TARGET_glfw "glfw")

# spdlog targets
set(_KNOWN_TARGETS_spdlog "spdlog;spdlog::spdlog;spdlog::spdlog_header_only")
set(_PRIMARY_TARGET_spdlog "spdlog::spdlog")

# fmt targets
set(_KNOWN_TARGETS_fmt "fmt;fmt::fmt;fmt::fmt-header-only")
set(_PRIMARY_TARGET_fmt "fmt::fmt")

# nlohmann_json targets
set(_KNOWN_TARGETS_nlohmann_json "nlohmann_json;nlohmann_json::nlohmann_json")
set(_PRIMARY_TARGET_nlohmann_json "nlohmann_json::nlohmann_json")

# ==============================================================================
# _register_external_target - Register a target for an external
# ==============================================================================
#[[
    _register_external_target(EXT_NAME TARGET_NAME [PRIMARY])
    
    Registers a target as belonging to an external.
    
    Parameters:
        EXT_NAME    - Name of the external
        TARGET_NAME - CMake target name
        PRIMARY     - (optional) Mark as primary target
    
    Example:
        _register_external_target("glfw" "glfw" PRIMARY)
        _register_external_target("glfw" "glfw::glfw")
]]
function(_register_external_target EXT_NAME TARGET_NAME)
    cmake_parse_arguments(_ARG "PRIMARY" "" "" ${ARGN})
    
    # Store target in external's target list
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
    Uses common naming conventions and framework-specific patterns.
    
    Parameters:
        EXT_NAME - Name of the external
    
    Detection order:
        1. Framework-specific known targets (Catch2, GoogleTest, etc.)
        2. Generic patterns: ${EXT_NAME}, ${EXT_NAME}::${EXT_NAME}, lowercase
]]
function(_auto_register_external_targets EXT_NAME)
    string(TOLOWER "${EXT_NAME}" _ext_lower)
    
    # ==========================================================================
    # Step 1: Check for framework-specific targets
    # ==========================================================================
    
    if(DEFINED _KNOWN_TARGETS_${_ext_lower})
        set(_known_targets "${_KNOWN_TARGETS_${_ext_lower}}")
        set(_primary_target "${_PRIMARY_TARGET_${_ext_lower}}")
        
        dbg(${DBG_RARE} "  Using known targets for ${EXT_NAME}: ${_known_targets}" ID EXTERNALS)
        
        # Try to find and register known targets
        set(_found_any FALSE)
        foreach(_candidate IN LISTS _known_targets)
            if(TARGET ${_candidate})
                if("${_candidate}" STREQUAL "${_primary_target}")
                    _register_external_target("${EXT_NAME}" "${_candidate}" PRIMARY)
                else()
                    _register_external_target("${EXT_NAME}" "${_candidate}")
                endif()
                set(_found_any TRUE)
            endif()
        endforeach()
        
        # If primary wasn't found but others were, set first as primary
        if(_found_any)
            get_property(_current_primary GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_PRIMARY_TARGET)
            if("${_current_primary}" STREQUAL "")
                get_property(_targets GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_TARGETS)
                list(GET _targets 0 _first)
                set_property(GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_PRIMARY_TARGET "${_first}")
            endif()
            return()
        endif()
    endif()
    
    # ==========================================================================
    # Step 2: Generic auto-detection patterns
    # ==========================================================================
    
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
        if(_targets)
            list(GET _targets 0 _primary)
        endif()
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
    _get_external_primary_target("${EXT_NAME}" _primary)
    dbg(${DBG_COMMON} "  Validated: ${EXT_NAME} (primary: ${_primary}, all: ${_targets})" ID EXTERNALS)
    
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
        _link_external_to_target(MyApp glfw PRIVATE)
]]
function(_link_external_to_target CONSUMER_TARGET EXT_NAME)
    # Parse optional scope
    set(_scope PRIVATE)
    if(ARGC GREATER 2)
        set(_scope ${ARGV2})
    endif()
    
    # Get primary target
    _get_external_primary_target("${EXT_NAME}" _primary)
    
    if(NOT _primary)
        cmake_fatal("E202" "External '${EXT_NAME}' has no registered targets")
    endif()
    
    # Link
    if(TARGET ${_primary})
        target_link_libraries(${CONSUMER_TARGET} ${_scope} ${_primary})
        dbg(${DBG_RARE} "  Linked: ${CONSUMER_TARGET} <- ${_primary} (${_scope})" ID EXTERNALS)
    else()
        cmake_fatal("E203" "Target '${_primary}' for external '${EXT_NAME}' not found")
    endif()
    
endfunction()

# ==============================================================================
# _get_all_external_targets - Get all targets for linking (for complex externals)
# ==============================================================================
#[[
    _get_all_external_targets(EXT_NAME OUT_VAR)
    
    Gets all linkable targets for an external. Useful for externals
    with multiple targets that should all be linked.
    
    Parameters:
        EXT_NAME - Name of the external
        OUT_VAR  - Output variable for target list
    
    Example:
        _get_all_external_targets("googletest" _gtest_targets)
        # Returns: gtest_main;gmock;... (all available)
]]
function(_get_all_external_targets EXT_NAME OUT_VAR)
    get_property(_targets GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_TARGETS)
    
    # Filter to only existing targets
    set(_existing "")
    foreach(_t IN LISTS _targets)
        if(TARGET ${_t})
            list(APPEND _existing "${_t}")
        endif()
    endforeach()
    
    set(${OUT_VAR} "${_existing}" PARENT_SCOPE)
endfunction()
