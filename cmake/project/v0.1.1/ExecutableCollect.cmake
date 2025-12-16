# ==============================================================================
# ExecutableCollect.cmake – Executable Data Collection
# ==============================================================================
#
# Module:       ExecutableCollect.cmake
# Version:      0.1.0
# Date:         2025-12-05
# Part of:      CMake Architecture V2
#
# Description:
#   Collects all data for an executable from JSON into a Context.
#   This module is responsible for parsing and normalizing executable
#   definitions from Solution.json.
#
# Dependencies (must be loaded before):
#   - cmake/core/Json.cmake
#   - cmake/core/Context.cmake
#   - cmake/core/Debug.cmake
#
# Provides:
#   _collect_executable(EXE_JSON CTX)
#
# Context Keys Set:
#   Mandatory:
#     NAME              - Target name
#
#   Optional:
#     DISPLAY_NAME      - Display name (default: NAME)
#     DESCRIPTION       - Description
#     VERSION           - Version (default: Solution version)
#     PATH              - Source path (default: projects/exec/{name}/src)
#     TYPE              - CONSOLE, GUI, CLI, HEADLESS, WORKER (default: from settings)
#     SKIP              - Boolean whether to skip
#     PCH_ENABLED       - Precompiled header enabled
#     PCH_HEADER        - PCH header file (default: pch.h)
#     DEPENDENCIES      - List of internal dependencies (libraries)
#     EXTERNALS         - List of external dependencies
#     EXTERNAL_OPTIONS  - JSON block with external-specific options
#     PLATFORMS         - List of supported platforms (empty = all)
#     DEFINES           - Preprocessor definitions
#     COMPILE_OPTIONS   - Additional compiler options
#     LINK_OPTIONS      - Additional linker options
#
# Based on:
#   - master_concept v0.1
#   - Solution_Schema v0.1
#   - guidelines v0.1
#
# ==============================================================================

include_guard(GLOBAL)

# ==============================================================================
# Main Function: _collect_executable
# ==============================================================================
#
# Collects all fields of an executable from JSON into a Context.
#
# Parameters:
#   EXE_JSON  - JSON string of the executable
#   CTX       - Context prefix (e.g. EXE_0, EXE_1, ...)
#
function(_collect_executable EXE_JSON CTX)
    
    # --------------------------------------------------------------------------
    # Required Field: name
    # --------------------------------------------------------------------------
    
    _json_get_string("${EXE_JSON}" "name" _name)
    if("${_name}" STREQUAL "")
        cmake_fatal("E001" "Executable has no 'name' field")
    endif()
    ctx_set(${CTX} NAME "${_name}")
    
    # --------------------------------------------------------------------------
    # Optional Metadata
    # --------------------------------------------------------------------------
    
    _json_get_string_or_default("${EXE_JSON}" "displayName" "${_name}" _display_name)
    ctx_set(${CTX} DISPLAY_NAME "${_display_name}")
    
    _json_get_string_or_default("${EXE_JSON}" "description" "" _description)
    ctx_set(${CTX} DESCRIPTION "${_description}")
    
    # Version: from executable or solution
    _json_has_key("${EXE_JSON}" "version" _has_version)
    if(_has_version)
        _json_get_string("${EXE_JSON}" "version" _version)
    else()
        get_property(_version GLOBAL PROPERTY SOLUTION_VERSION)
    endif()
    ctx_set(${CTX} VERSION "${_version}")
    
    # --------------------------------------------------------------------------
    # Path (with intelligent default)
    # --------------------------------------------------------------------------
    
    _json_has_key("${EXE_JSON}" "path" _has_path)
    if(_has_path)
        _json_get_string("${EXE_JSON}" "path" _path)
    else()
        # Convention: projects/exec/{name}/src
        set(_path "projects/exec/${_name}/src")
    endif()
    ctx_set(${CTX} PATH "${_path}")
    
    # --------------------------------------------------------------------------
    # Type (CONSOLE, GUI, CLI, HEADLESS, WORKER)
    # --------------------------------------------------------------------------
    
    get_property(_default_type GLOBAL PROPERTY SOLUTION_DEFAULT_EXECUTABLE_TYPE)
    if("${_default_type}" STREQUAL "")
        set(_default_type "CONSOLE")
    endif()
    
    _json_get_string_or_default("${EXE_JSON}" "type" "${_default_type}" _type)
    string(TOUPPER "${_type}" _type)
    ctx_set(${CTX} TYPE "${_type}")
    
    # --------------------------------------------------------------------------
    # Skip Flag
    # --------------------------------------------------------------------------
    
    _json_get_bool_from_key("${EXE_JSON}" "skip" _skip)
    ctx_set(${CTX} SKIP "${_skip}")
    
    # --------------------------------------------------------------------------
    # PCH (Precompiled Headers)
    # --------------------------------------------------------------------------
    
    _json_has_key("${EXE_JSON}" "pch" _has_pch)
    if(_has_pch)
        _json_get_object("${EXE_JSON}" "pch" _pch_obj)
        _json_get_bool_from_key("${_pch_obj}" "enabled" _pch_enabled)
        _json_get_string_or_default("${_pch_obj}" "header" "pch.h" _pch_header)
    else()
        set(_pch_enabled FALSE)
        set(_pch_header "pch.h")
    endif()
    ctx_set(${CTX} PCH_ENABLED "${_pch_enabled}")
    ctx_set(${CTX} PCH_HEADER "${_pch_header}")
    
    # --------------------------------------------------------------------------
    # Dependencies (internal libraries)
    # --------------------------------------------------------------------------
    
    set(_dependencies "")
    _json_array_length("${EXE_JSON}" "dependencies" _dep_count)
    if(_dep_count GREATER 0)
        math(EXPR _dep_last "${_dep_count} - 1")
        foreach(_dep_idx RANGE 0 ${_dep_last})
            _json_array_get("${EXE_JSON}" "dependencies" ${_dep_idx} _dep)
            list(APPEND _dependencies "${_dep}")
        endforeach()
    endif()
    ctx_set(${CTX} DEPENDENCIES "${_dependencies}")
    
    # --------------------------------------------------------------------------
    # Externals (external dependencies)
    # --------------------------------------------------------------------------
    
    set(_externals "")
    _json_array_length("${EXE_JSON}" "externals" _ext_count)
    if(_ext_count GREATER 0)
        math(EXPR _ext_last "${_ext_count} - 1")
        foreach(_ext_idx RANGE 0 ${_ext_last})
            _json_array_get("${EXE_JSON}" "externals" ${_ext_idx} _ext)
            list(APPEND _externals "${_ext}")
        endforeach()
    endif()
    ctx_set(${CTX} EXTERNALS "${_externals}")
    
    # --------------------------------------------------------------------------
    # External Options (JSON block for later processing)
    # --------------------------------------------------------------------------
    
    _json_get_object_or_empty("${EXE_JSON}" "external_options" _ext_options)
    ctx_set(${CTX} EXTERNAL_OPTIONS "${_ext_options}")
    
    # --------------------------------------------------------------------------
    # Platforms (platform filter)
    # --------------------------------------------------------------------------
    
    set(_platforms "")
    _json_array_length("${EXE_JSON}" "platforms" _plat_count)
    if(_plat_count GREATER 0)
        math(EXPR _plat_last "${_plat_count} - 1")
        foreach(_plat_idx RANGE 0 ${_plat_last})
            _json_array_get("${EXE_JSON}" "platforms" ${_plat_idx} _plat)
            list(APPEND _platforms "${_plat}")
        endforeach()
    endif()
    ctx_set(${CTX} PLATFORMS "${_platforms}")
    
    # --------------------------------------------------------------------------
    # Defines (preprocessor definitions)
    # --------------------------------------------------------------------------
    
    set(_defines "")
    _json_array_length("${EXE_JSON}" "defines" _def_count)
    if(_def_count GREATER 0)
        math(EXPR _def_last "${_def_count} - 1")
        foreach(_def_idx RANGE 0 ${_def_last})
            _json_array_get("${EXE_JSON}" "defines" ${_def_idx} _def)
            list(APPEND _defines "${_def}")
        endforeach()
    endif()
    ctx_set(${CTX} DEFINES "${_defines}")
    
    # --------------------------------------------------------------------------
    # Compile Options
    # --------------------------------------------------------------------------
    
    set(_compile_options "")
    _json_array_length("${EXE_JSON}" "compile_options" _co_count)
    if(_co_count GREATER 0)
        math(EXPR _co_last "${_co_count} - 1")
        foreach(_co_idx RANGE 0 ${_co_last})
            _json_array_get("${EXE_JSON}" "compile_options" ${_co_idx} _co)
            list(APPEND _compile_options "${_co}")
        endforeach()
    endif()
    ctx_set(${CTX} COMPILE_OPTIONS "${_compile_options}")
    
    # --------------------------------------------------------------------------
    # Link Options
    # --------------------------------------------------------------------------
    
    set(_link_options "")
    _json_array_length("${EXE_JSON}" "link_options" _lo_count)
    if(_lo_count GREATER 0)
        math(EXPR _lo_last "${_lo_count} - 1")
        foreach(_lo_idx RANGE 0 ${_lo_last})
            _json_array_get("${EXE_JSON}" "link_options" ${_lo_idx} _lo)
            list(APPEND _link_options "${_lo}")
        endforeach()
    endif()
    ctx_set(${CTX} LINK_OPTIONS "${_link_options}")
    
    # --------------------------------------------------------------------------
    # Debug Output (at high level)
    # --------------------------------------------------------------------------
    
    dbg(${DBG_RARE} "  Collected ${_name}:" ID EXECUTABLES)
    dbg(${DBG_RARE} "    PATH: ${_path}" ID EXECUTABLES)
    dbg(${DBG_RARE} "    TYPE: ${_type}" ID EXECUTABLES)
    dbg(${DBG_RARE} "    SKIP: ${_skip}" ID EXECUTABLES)
    dbg(${DBG_RARE} "    PCH: ${_pch_enabled} (${_pch_header})" ID EXECUTABLES)
    dbg(${DBG_ULTRA_RARE} "    DEPENDENCIES: ${_dependencies}" ID EXECUTABLES)
    dbg(${DBG_ULTRA_RARE} "    EXTERNALS: ${_externals}" ID EXECUTABLES)
    dbg(${DBG_ULTRA_RARE} "    PLATFORMS: ${_platforms}" ID EXECUTABLES)
    
endfunction()
