# cmake/project/AppCollect.cmake
# ================================
# Collects App-Container data from JSON into a Context
#
# Version: 0.5.0
# Date:    2025-12-17
# Status:  Development
# Author:  CMake Architecture V2 Team
#
# Dependencies:
#   - cmake/core/Json.cmake
#   - cmake/core/Context.cmake
#   - cmake/core/Debug.cmake
#   - cmake/core/Errors.cmake
#
# Provides:
#   - _collect_app(APP_JSON CTX)
#
# Context Keys Set:
#   Base:
#     - NAME, DISPLAY_NAME, DESCRIPTION, VERSION, PATH
#   Core:
#     - CORE_DEPENDENCIES, CORE_EXTERNALS
#   Runner:
#     - RUNNER_TYPE, RUNNER_EXTERNALS
#   PCH:
#     - PCH_ENABLED, PCH_HEADER, PCH_SOURCE
#   Tests:
#     - TESTS_FRAMEWORK
#     - TESTS_UNIT_ENABLED, TESTS_UNIT_TIMEOUT, TESTS_UNIT_LABELS
#     - TESTS_INTEGRATION_ENABLED, TESTS_INTEGRATION_TIMEOUT, 
#       TESTS_INTEGRATION_LABELS, TESTS_INTEGRATION_EXTERNALS
#   Filter:
#     - PLATFORMS, SKIP
#
# Used by:
#   - Apps.cmake

include_guard(GLOBAL)

# ============================================================================
# _collect_app - Collects App-Container data from JSON into Context
# ============================================================================
#[[
    _collect_app(APP_JSON CTX)
    
    Parses an App-Container definition from JSON and stores all fields
    in a Context for later processing by AppCreate.
    
    Parameters:
        APP_JSON - Mandatory: JSON string of the app definition
        CTX      - Mandatory: Context prefix (e.g. APP_0, APP_1)
    
    Context Keys Set:
        See header comment for complete list.
    
    Example:
        ctx_create(APP_0)
        _collect_app("${_app_json}" APP_0)
        ctx_get(APP_0 NAME _name)
        ctx_get(APP_0 CORE_EXTERNALS _core_ext)
]]
function(_collect_app APP_JSON CTX)
    
    # ==========================================================================
    # Required Field: name
    # ==========================================================================
    
    _json_get_string("${APP_JSON}" "name" _name)
    if("${_name}" STREQUAL "")
        cmake_fatal("E401" "App definition: 'name' is required")
    endif()
    ctx_set(${CTX} NAME "${_name}")
    
    # ==========================================================================
    # Optional Metadata
    # ==========================================================================
    
    _json_get_string_or_default("${APP_JSON}" "displayName" "${_name}" _display_name)
    ctx_set(${CTX} DISPLAY_NAME "${_display_name}")
    
    _json_get_string_or_default("${APP_JSON}" "description" "" _description)
    ctx_set(${CTX} DESCRIPTION "${_description}")
    
    # Version: from app or solution
    _json_has_key("${APP_JSON}" "version" _has_version)
    if(_has_version)
        _json_get_string("${APP_JSON}" "version" _version)
    else()
        get_property(_version GLOBAL PROPERTY SOLUTION_VERSION)
    endif()
    ctx_set(${CTX} VERSION "${_version}")
    
    # ==========================================================================
    # Path (with intelligent default)
    # ==========================================================================
    
    _json_has_key("${APP_JSON}" "path" _has_path)
    if(_has_path)
        _json_get_string("${APP_JSON}" "path" _path)
    else()
        # Convention: projects/apps/{name}
        set(_path "projects/apps/${_name}")
    endif()
    ctx_set(${CTX} PATH "${_path}")
    
    # ==========================================================================
    # Skip Flag
    # ==========================================================================
    
    _json_get_bool_from_key("${APP_JSON}" "skip" _skip)
    ctx_set(${CTX} SKIP "${_skip}")
    
    # ==========================================================================
    # Platforms Filter
    # ==========================================================================
    
    set(_platforms "")
    _json_array_length("${APP_JSON}" "platforms" _plat_count)
    if(_plat_count GREATER 0)
        math(EXPR _plat_last "${_plat_count} - 1")
        foreach(_plat_idx RANGE 0 ${_plat_last})
            _json_array_get("${APP_JSON}" "platforms" ${_plat_idx} _plat)
            list(APPEND _platforms "${_plat}")
        endforeach()
    endif()
    ctx_set(${CTX} PLATFORMS "${_platforms}")
    
    # ==========================================================================
    # Core Section (dependencies, externals for the static library)
    # ==========================================================================
    
    set(_core_dependencies "")
    set(_core_externals "")
    
    _json_has_key("${APP_JSON}" "core" _has_core)
    if(_has_core)
        _json_get_object("${APP_JSON}" "core" _core_obj)
        
        # Core dependencies (internal libraries)
        _json_array_length("${_core_obj}" "dependencies" _dep_count)
        if(_dep_count GREATER 0)
            math(EXPR _dep_last "${_dep_count} - 1")
            foreach(_dep_idx RANGE 0 ${_dep_last})
                _json_array_get("${_core_obj}" "dependencies" ${_dep_idx} _dep)
                list(APPEND _core_dependencies "${_dep}")
            endforeach()
        endif()
        
        # Core externals
        _json_array_length("${_core_obj}" "externals" _ext_count)
        if(_ext_count GREATER 0)
            math(EXPR _ext_last "${_ext_count} - 1")
            foreach(_ext_idx RANGE 0 ${_ext_last})
                _json_array_get("${_core_obj}" "externals" ${_ext_idx} _ext)
                list(APPEND _core_externals "${_ext}")
            endforeach()
        endif()
    endif()
    
    ctx_set(${CTX} CORE_DEPENDENCIES "${_core_dependencies}")
    ctx_set(${CTX} CORE_EXTERNALS "${_core_externals}")
    
    # ==========================================================================
    # Runner Section (type, externals for the executable)
    # ==========================================================================
    
    set(_runner_type "CONSOLE")
    set(_runner_externals "")
    
    _json_has_key("${APP_JSON}" "runner" _has_runner)
    if(_has_runner)
        _json_get_object("${APP_JSON}" "runner" _runner_obj)
        
        # Runner type
        _json_get_string_or_default("${_runner_obj}" "type" "CONSOLE" _runner_type)
        string(TOUPPER "${_runner_type}" _runner_type)
        
        # Runner externals (GUI frameworks etc.)
        _json_array_length("${_runner_obj}" "externals" _ext_count)
        if(_ext_count GREATER 0)
            math(EXPR _ext_last "${_ext_count} - 1")
            foreach(_ext_idx RANGE 0 ${_ext_last})
                _json_array_get("${_runner_obj}" "externals" ${_ext_idx} _ext)
                list(APPEND _runner_externals "${_ext}")
            endforeach()
        endif()
    endif()
    
    ctx_set(${CTX} RUNNER_TYPE "${_runner_type}")
    ctx_set(${CTX} RUNNER_EXTERNALS "${_runner_externals}")
    
    # ==========================================================================
    # PCH Section (Precompiled Headers)
    # ==========================================================================
    
    set(_pch_enabled FALSE)
    set(_pch_header "pch/pch.hpp")
    set(_pch_source "pch/pch.cpp")
    
    _json_has_key("${APP_JSON}" "pch" _has_pch)
    if(_has_pch)
        _json_get_object("${APP_JSON}" "pch" _pch_obj)
        
        _json_get_bool_from_key("${_pch_obj}" "enabled" _pch_enabled)
        _json_get_string_or_default("${_pch_obj}" "header" "pch/pch.hpp" _pch_header)
        _json_get_string_or_default("${_pch_obj}" "source" "pch/pch.cpp" _pch_source)
    endif()
    
    ctx_set(${CTX} PCH_ENABLED "${_pch_enabled}")
    ctx_set(${CTX} PCH_HEADER "${_pch_header}")
    ctx_set(${CTX} PCH_SOURCE "${_pch_source}")
    
    # ==========================================================================
    # Tests Section
    # ==========================================================================
    
    set(_tests_framework "doctest")
    set(_tests_unit_enabled FALSE)
    set(_tests_unit_timeout 30)
    set(_tests_unit_labels "")
    set(_tests_integration_enabled FALSE)
    set(_tests_integration_timeout 120)
    set(_tests_integration_labels "")
    set(_tests_integration_externals "")
    
    _json_has_key("${APP_JSON}" "tests" _has_tests)
    if(_has_tests)
        _json_get_object("${APP_JSON}" "tests" _tests_obj)
        
        # Framework
        _json_get_string_or_default("${_tests_obj}" "framework" "doctest" _tests_framework)
        
        # -----------------------------------------------------------------------
        # Unit Tests
        # -----------------------------------------------------------------------
        _json_has_key("${_tests_obj}" "unit" _has_unit)
        if(_has_unit)
            set(_tests_unit_enabled TRUE)
            _json_get_object("${_tests_obj}" "unit" _unit_obj)
            
            # Timeout
            _json_has_key("${_unit_obj}" "timeout" _has_timeout)
            if(_has_timeout)
                _json_get_number("${_unit_obj}" "timeout" _tests_unit_timeout)
            endif()
            
            # Labels
            _json_array_length("${_unit_obj}" "labels" _label_count)
            if(_label_count GREATER 0)
                math(EXPR _label_last "${_label_count} - 1")
                foreach(_label_idx RANGE 0 ${_label_last})
                    _json_array_get("${_unit_obj}" "labels" ${_label_idx} _label)
                    list(APPEND _tests_unit_labels "${_label}")
                endforeach()
            endif()
        endif()
        
        # -----------------------------------------------------------------------
        # Integration Tests
        # -----------------------------------------------------------------------
        _json_has_key("${_tests_obj}" "integration" _has_integration)
        if(_has_integration)
            set(_tests_integration_enabled TRUE)
            _json_get_object("${_tests_obj}" "integration" _integration_obj)
            
            # Timeout
            _json_has_key("${_integration_obj}" "timeout" _has_timeout)
            if(_has_timeout)
                _json_get_number("${_integration_obj}" "timeout" _tests_integration_timeout)
            endif()
            
            # Labels
            _json_array_length("${_integration_obj}" "labels" _label_count)
            if(_label_count GREATER 0)
                math(EXPR _label_last "${_label_count} - 1")
                foreach(_label_idx RANGE 0 ${_label_last})
                    _json_array_get("${_integration_obj}" "labels" ${_label_idx} _label)
                    list(APPEND _tests_integration_labels "${_label}")
                endforeach()
            endif()
            
            # Additional externals for integration tests
            _json_array_length("${_integration_obj}" "externals" _ext_count)
            if(_ext_count GREATER 0)
                math(EXPR _ext_last "${_ext_count} - 1")
                foreach(_ext_idx RANGE 0 ${_ext_last})
                    _json_array_get("${_integration_obj}" "externals" ${_ext_idx} _ext)
                    list(APPEND _tests_integration_externals "${_ext}")
                endforeach()
            endif()
        endif()
    endif()
    
    ctx_set(${CTX} TESTS_FRAMEWORK "${_tests_framework}")
    ctx_set(${CTX} TESTS_UNIT_ENABLED "${_tests_unit_enabled}")
    ctx_set(${CTX} TESTS_UNIT_TIMEOUT "${_tests_unit_timeout}")
    ctx_set(${CTX} TESTS_UNIT_LABELS "${_tests_unit_labels}")
    ctx_set(${CTX} TESTS_INTEGRATION_ENABLED "${_tests_integration_enabled}")
    ctx_set(${CTX} TESTS_INTEGRATION_TIMEOUT "${_tests_integration_timeout}")
    ctx_set(${CTX} TESTS_INTEGRATION_LABELS "${_tests_integration_labels}")
    ctx_set(${CTX} TESTS_INTEGRATION_EXTERNALS "${_tests_integration_externals}")
    
    # ==========================================================================
    # Debug Output
    # ==========================================================================
    
    dbg(${DBG_RARE} "  Collected App '${_name}':" ID APPS)
    dbg(${DBG_RARE} "    PATH: ${_path}" ID APPS)
    dbg(${DBG_RARE} "    SKIP: ${_skip}" ID APPS)
    dbg(${DBG_RARE} "    RUNNER_TYPE: ${_runner_type}" ID APPS)
    dbg(${DBG_ULTRA_RARE} "    CORE_DEPENDENCIES: ${_core_dependencies}" ID APPS)
    dbg(${DBG_ULTRA_RARE} "    CORE_EXTERNALS: ${_core_externals}" ID APPS)
    dbg(${DBG_ULTRA_RARE} "    RUNNER_EXTERNALS: ${_runner_externals}" ID APPS)
    dbg(${DBG_ULTRA_RARE} "    PCH: ${_pch_enabled} (${_pch_header})" ID APPS)
    dbg(${DBG_ULTRA_RARE} "    TESTS_FRAMEWORK: ${_tests_framework}" ID APPS)
    dbg(${DBG_ULTRA_RARE} "    TESTS_UNIT_ENABLED: ${_tests_unit_enabled}" ID APPS)
    dbg(${DBG_ULTRA_RARE} "    TESTS_INTEGRATION_ENABLED: ${_tests_integration_enabled}" ID APPS)
    dbg(${DBG_ULTRA_RARE} "    PLATFORMS: ${_platforms}" ID APPS)
    
endfunction()
