# ==============================================================================
# LibraryCollect.cmake – Library Data Collection
# ==============================================================================
#
# Module:       LibraryCollect.cmake
# Version:      0.1.0
# Date:         2025-12-07
# Part of:      CMake Architecture V2
#
# Description:
#   Collects all data for a library from JSON into a Context.
#   This module is responsible for parsing and normalizing library
#   definitions from Solution.json.
#
# Dependencies (must be loaded before):
#   - cmake/core/Json.cmake
#   - cmake/core/Context.cmake
#   - cmake/core/Debug.cmake
#
# Provides:
#   _collect_library(LIB_JSON CTX)
#
# Context Keys Set:
#   Mandatory:
#     NAME              - Target name
#
#   Optional:
#     VERSION           - Version (default: Solution version)
#     PATH              - Source path (default: projects/libs/{name}/src)
#     TYPE              - STATIC, SHARED, INTERFACE (default: from settings)
#     PUBLIC_HEADERS    - Public header directory
#     SKIP              - Boolean whether to skip
#     DEPENDENCIES      - List of internal dependencies (other libraries)
#     EXTERNALS         - List of external dependencies
#     PLATFORM          - Target platform (single value, empty = all)
#
# Based on:
#   - master_concept v0.1
#   - Solution_Schema v0.1
#   - guidelines v0.1
#
# ==============================================================================

include_guard(GLOBAL)

# ==============================================================================
# Main Function: _collect_library
# ==============================================================================
#
# Collects all fields of a library from JSON into a Context.
#
# Parameters:
#   LIB_JSON  - JSON string of the library
#   CTX       - Context prefix (e.g. LIB_0, LIB_1, ...)
#
function(_collect_library LIB_JSON CTX)
    
    # --------------------------------------------------------------------------
    # Required Field: name
    # --------------------------------------------------------------------------
    
    _json_get_string("${LIB_JSON}" "name" _name)
    if("${_name}" STREQUAL "")
        cmake_fatal("E001" "Library has no 'name' field")
    endif()
    ctx_set(${CTX} NAME "${_name}")
    
    # --------------------------------------------------------------------------
    # Version (from library or solution)
    # --------------------------------------------------------------------------
    
    _json_has_key("${LIB_JSON}" "version" _has_version)
    if(_has_version)
        _json_get_string("${LIB_JSON}" "version" _version)
    else()
        get_property(_version GLOBAL PROPERTY SOLUTION_VERSION)
    endif()
    ctx_set(${CTX} VERSION "${_version}")
    
    # --------------------------------------------------------------------------
    # Path (with intelligent default)
    # --------------------------------------------------------------------------
    
    _json_has_key("${LIB_JSON}" "path" _has_path)
    if(_has_path)
        _json_get_string("${LIB_JSON}" "path" _path)
    else()
        # Convention: projects/libs/{name}/src
        set(_path "projects/libs/${_name}/src")
    endif()
    ctx_set(${CTX} PATH "${_path}")
    
    # --------------------------------------------------------------------------
    # Type (STATIC, SHARED, INTERFACE)
    # --------------------------------------------------------------------------
    
    get_property(_default_type GLOBAL PROPERTY SOLUTION_DEFAULT_LIBRARY_TYPE)
    if("${_default_type}" STREQUAL "")
        set(_default_type "STATIC")
    endif()
    
    _json_get_string_or_default("${LIB_JSON}" "type" "${_default_type}" _type)
    string(TOUPPER "${_type}" _type)
    
    # Validate type
    set(_valid_types "STATIC;SHARED;INTERFACE")
    if(NOT "${_type}" IN_LIST _valid_types)
        cmake_fatal("E003" "Invalid library type '${_type}' for '${_name}'. Valid: STATIC, SHARED, INTERFACE")
    endif()
    
    ctx_set(${CTX} TYPE "${_type}")
    
    # --------------------------------------------------------------------------
    # Public Headers (optional)
    # --------------------------------------------------------------------------
    
    _json_has_key("${LIB_JSON}" "public_headers" _has_public_headers)
    if(_has_public_headers)
        _json_get_string("${LIB_JSON}" "public_headers" _public_headers)
    else()
        # Convention: check if default include directory exists
        set(_default_include "projects/libs/${_name}/include")
        if(EXISTS "${CMAKE_SOURCE_DIR}/${_default_include}")
            set(_public_headers "${_default_include}")
        else()
            set(_public_headers "")
        endif()
    endif()
    ctx_set(${CTX} PUBLIC_HEADERS "${_public_headers}")
    
    # --------------------------------------------------------------------------
    # Skip Flag
    # --------------------------------------------------------------------------
    
    _json_get_bool_from_key("${LIB_JSON}" "skip" _skip)
    ctx_set(${CTX} SKIP "${_skip}")
    
    # --------------------------------------------------------------------------
    # Dependencies (internal libraries)
    # --------------------------------------------------------------------------
    
    set(_dependencies "")
    _json_array_length("${LIB_JSON}" "dependencies" _dep_count)
    if(_dep_count GREATER 0)
        math(EXPR _dep_last "${_dep_count} - 1")
        foreach(_dep_idx RANGE 0 ${_dep_last})
            _json_array_get("${LIB_JSON}" "dependencies" ${_dep_idx} _dep)
            list(APPEND _dependencies "${_dep}")
        endforeach()
    endif()
    ctx_set(${CTX} DEPENDENCIES "${_dependencies}")
    
    # --------------------------------------------------------------------------
    # Externals (external dependencies)
    # --------------------------------------------------------------------------
    
    set(_externals "")
    _json_array_length("${LIB_JSON}" "externals" _ext_count)
    if(_ext_count GREATER 0)
        math(EXPR _ext_last "${_ext_count} - 1")
        foreach(_ext_idx RANGE 0 ${_ext_last})
            _json_array_get("${LIB_JSON}" "externals" ${_ext_idx} _ext)
            list(APPEND _externals "${_ext}")
        endforeach()
    endif()
    ctx_set(${CTX} EXTERNALS "${_externals}")
    
    # --------------------------------------------------------------------------
    # Platform (single value platform filter)
    # --------------------------------------------------------------------------
    
    _json_get_string_or_default("${LIB_JSON}" "platform" "" _platform)
    ctx_set(${CTX} PLATFORM "${_platform}")
    
    # --------------------------------------------------------------------------
    # Debug Output (at high level)
    # --------------------------------------------------------------------------
    
    dbg(${DBG_RARE} "  Collected ${_name}:" ID LIBRARIES)
    dbg(${DBG_RARE} "    PATH: ${_path}" ID LIBRARIES)
    dbg(${DBG_RARE} "    TYPE: ${_type}" ID LIBRARIES)
    dbg(${DBG_RARE} "    PUBLIC_HEADERS: ${_public_headers}" ID LIBRARIES)
    dbg(${DBG_RARE} "    SKIP: ${_skip}" ID LIBRARIES)
    dbg(${DBG_ULTRA_RARE} "    DEPENDENCIES: ${_dependencies}" ID LIBRARIES)
    dbg(${DBG_ULTRA_RARE} "    EXTERNALS: ${_externals}" ID LIBRARIES)
    
endfunction()
