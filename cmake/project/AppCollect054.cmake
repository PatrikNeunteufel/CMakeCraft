# cmake/project/AppCollect.cmake
# ================================
# Collects App-Container data from JSON into a Context
#
# Version: 0.5.4
# Date:    2025-12-18
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
#     - PCH_ENABLED, PCH_HEADER, PCH_PATH
#   Tests:
#     - TESTS_FRAMEWORK (global default)
#     - TESTS_UNIT_ENABLED, TESTS_UNIT_TIMEOUT, TESTS_UNIT_LABELS, TESTS_UNIT_FRAMEWORK
#     - TESTS_INTEGRATION_ENABLED, TESTS_INTEGRATION_TIMEOUT, 
#       TESTS_INTEGRATION_LABELS, TESTS_INTEGRATION_EXTERNALS, TESTS_INTEGRATION_FRAMEWORK
#     - TESTS_PERFORMANCE_ENABLED, TESTS_PERFORMANCE_TIMEOUT,
#       TESTS_PERFORMANCE_LABELS, TESTS_PERFORMANCE_EXTERNALS, TESTS_PERFORMANCE_FRAMEWORK
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
        APP_JSON - Mandatory: JSON object string containing app definition
        CTX      - Mandatory: Context prefix (e.g. APP_0, APP_1)
    
    JSON Schema:
        {
            "name": "AppName",              // Required
            "displayName": "Display Name",  // Optional, defaults to name
            "version": "1.0.0",             // Optional
            "description": "...",           // Optional
            "path": "projects/apps/...",    // Optional, defaults to projects/apps/{name}
            "skip": false,                  // Optional
            
            "core": {
                "dependencies": [],
                "externals": []
            },
            
            "runner": {
                "type": "CONSOLE|GUI",
                "externals": []
            },
            
            "pch": {
                "enabled": true,
                "header": "pch.h",
                "path": ""
            },
            
            "tests": {
                "framework": "doctest",     // Global default
                "unit": {
                    "framework": "doctest", // Optional override
                    "timeout": 30,
                    "labels": ["unit", "fast"]
                },
                "integration": {
                    "framework": "doctest", // Optional override
                    "timeout": 120,
                    "labels": ["integration"],
                    "externals": ["bass"]
                },
                "performance": {
                    "framework": "doctest", // Optional override
                    "timeout": 300,
                    "labels": ["performance", "benchmark"],
                    "externals": []
                }
            },
            
            "platforms": ["windows", "linux", "macos"]
        }
    
    Example:
        _collect_app("${_app_json}" APP_0)
        ctx_get(APP_0 NAME _name)
]]
function(_collect_app APP_JSON CTX)
    
    # ==========================================================================
    # Base Fields
    # ==========================================================================
    
    # Name (required)
    _json_has_key("${APP_JSON}" "name" _has_name)
    if(NOT _has_name)
        cmake_fatal("E400" "App definition missing required 'name' field")
    endif()
    string(JSON _name GET "${APP_JSON}" "name")
    
    # Display Name (optional, defaults to name)
    _json_get_string_or_default("${APP_JSON}" "displayName" "${_name}" _display_name)
    
    # Description (optional)
    _json_get_string_or_default("${APP_JSON}" "description" "" _description)
    
    # Version (optional)
    _json_get_string_or_default("${APP_JSON}" "version" "" _version)
    
    # Path (optional, defaults to projects/apps/{name})
    _json_get_string_or_default("${APP_JSON}" "path" "projects/apps/${_name}" _path)
    
    # Skip (optional)
    set(_skip FALSE)
    _json_has_key("${APP_JSON}" "skip" _has_skip)
    if(_has_skip)
        _json_get_bool_from_key("${APP_JSON}" "skip" _skip)
    endif()
    
    ctx_set(${CTX} NAME "${_name}")
    ctx_set(${CTX} DISPLAY_NAME "${_display_name}")
    ctx_set(${CTX} DESCRIPTION "${_description}")
    ctx_set(${CTX} VERSION "${_version}")
    ctx_set(${CTX} PATH "${_path}")
    ctx_set(${CTX} SKIP "${_skip}")
    
    # ==========================================================================
    # Core Section
    # ==========================================================================
    
    set(_core_dependencies "")
    set(_core_externals "")
    
    _json_has_key("${APP_JSON}" "core" _has_core)
    if(_has_core)
        _json_get_object("${APP_JSON}" "core" _core_obj)
        
        # Dependencies
        _json_array_length("${_core_obj}" "dependencies" _dep_count)
        if(_dep_count GREATER 0)
            math(EXPR _dep_last "${_dep_count} - 1")
            foreach(_dep_idx RANGE 0 ${_dep_last})
                _json_array_get("${_core_obj}" "dependencies" ${_dep_idx} _dep)
                list(APPEND _core_dependencies "${_dep}")
            endforeach()
        endif()
        
        # Externals
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
    # Runner Section
    # ==========================================================================
    
    set(_runner_type "CONSOLE")
    set(_runner_externals "")
    
    _json_has_key("${APP_JSON}" "runner" _has_runner)
    if(_has_runner)
        _json_get_object("${APP_JSON}" "runner" _runner_obj)
        
        # Type
        _json_get_string_or_default("${_runner_obj}" "type" "CONSOLE" _runner_type)
        string(TOUPPER "${_runner_type}" _runner_type)
        
        # Externals
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
    # PCH Section
    # ==========================================================================
    
    set(_pch_enabled FALSE)
    set(_pch_header "pch.h")
    set(_pch_path "")
    
    _json_has_key("${APP_JSON}" "pch" _has_pch)
    if(_has_pch)
        _json_get_object("${APP_JSON}" "pch" _pch_obj)
        
        _json_has_key("${_pch_obj}" "enabled" _has_pch_enabled)
        if(_has_pch_enabled)
            _json_get_bool_from_key("${_pch_obj}" "enabled" _pch_enabled)
        endif()
        _json_get_string_or_default("${_pch_obj}" "header" "pch.h" _pch_header)
        _json_get_string_or_default("${_pch_obj}" "path" "" _pch_path)
    endif()
    
    ctx_set(${CTX} PCH_ENABLED "${_pch_enabled}")
    ctx_set(${CTX} PCH_HEADER "${_pch_header}")
    ctx_set(${CTX} PCH_PATH "${_pch_path}")
    
    # ==========================================================================
    # Tests Section
    # ==========================================================================
    
    set(_tests_framework "")  # Empty = must be specified somewhere
    set(_tests_unit_enabled FALSE)
    set(_tests_unit_timeout 30)
    set(_tests_unit_labels "")
    set(_tests_unit_framework "")
    set(_tests_integration_enabled FALSE)
    set(_tests_integration_timeout 120)
    set(_tests_integration_labels "")
    set(_tests_integration_externals "")
    set(_tests_integration_framework "")
    set(_tests_performance_enabled FALSE)
    set(_tests_performance_timeout 300)
    set(_tests_performance_labels "")
    set(_tests_performance_externals "")
    set(_tests_performance_framework "")
    
    _json_has_key("${APP_JSON}" "tests" _has_tests)
    if(_has_tests)
        _json_get_object("${APP_JSON}" "tests" _tests_obj)
        
        # Global Framework (default for all test types)
        _json_get_string_or_default("${_tests_obj}" "framework" "" _tests_framework)
        
        # -----------------------------------------------------------------------
        # Unit Tests
        # -----------------------------------------------------------------------
        _json_has_key("${_tests_obj}" "unit" _has_unit)
        if(_has_unit)
            set(_tests_unit_enabled TRUE)
            _json_get_object("${_tests_obj}" "unit" _unit_obj)
            
            # Framework override
            _json_get_string_or_default("${_unit_obj}" "framework" "" _tests_unit_framework)
            
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
            
            # Framework override
            _json_get_string_or_default("${_integration_obj}" "framework" "" _tests_integration_framework)
            
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
        
        # -----------------------------------------------------------------------
        # Performance Tests
        # -----------------------------------------------------------------------
        _json_has_key("${_tests_obj}" "performance" _has_performance)
        if(_has_performance)
            set(_tests_performance_enabled TRUE)
            _json_get_object("${_tests_obj}" "performance" _performance_obj)
            
            # Framework override
            _json_get_string_or_default("${_performance_obj}" "framework" "" _tests_performance_framework)
            
            # Timeout
            _json_has_key("${_performance_obj}" "timeout" _has_timeout)
            if(_has_timeout)
                _json_get_number("${_performance_obj}" "timeout" _tests_performance_timeout)
            endif()
            
            # Labels
            _json_array_length("${_performance_obj}" "labels" _label_count)
            if(_label_count GREATER 0)
                math(EXPR _label_last "${_label_count} - 1")
                foreach(_label_idx RANGE 0 ${_label_last})
                    _json_array_get("${_performance_obj}" "labels" ${_label_idx} _label)
                    list(APPEND _tests_performance_labels "${_label}")
                endforeach()
            endif()
            
            # Additional externals for performance tests
            _json_array_length("${_performance_obj}" "externals" _ext_count)
            if(_ext_count GREATER 0)
                math(EXPR _ext_last "${_ext_count} - 1")
                foreach(_ext_idx RANGE 0 ${_ext_last})
                    _json_array_get("${_performance_obj}" "externals" ${_ext_idx} _ext)
                    list(APPEND _tests_performance_externals "${_ext}")
                endforeach()
            endif()
        endif()
    endif()
    
    ctx_set(${CTX} TESTS_FRAMEWORK "${_tests_framework}")
    ctx_set(${CTX} TESTS_UNIT_ENABLED "${_tests_unit_enabled}")
    ctx_set(${CTX} TESTS_UNIT_TIMEOUT "${_tests_unit_timeout}")
    ctx_set(${CTX} TESTS_UNIT_LABELS "${_tests_unit_labels}")
    ctx_set(${CTX} TESTS_UNIT_FRAMEWORK "${_tests_unit_framework}")
    ctx_set(${CTX} TESTS_INTEGRATION_ENABLED "${_tests_integration_enabled}")
    ctx_set(${CTX} TESTS_INTEGRATION_TIMEOUT "${_tests_integration_timeout}")
    ctx_set(${CTX} TESTS_INTEGRATION_LABELS "${_tests_integration_labels}")
    ctx_set(${CTX} TESTS_INTEGRATION_EXTERNALS "${_tests_integration_externals}")
    ctx_set(${CTX} TESTS_INTEGRATION_FRAMEWORK "${_tests_integration_framework}")
    ctx_set(${CTX} TESTS_PERFORMANCE_ENABLED "${_tests_performance_enabled}")
    ctx_set(${CTX} TESTS_PERFORMANCE_TIMEOUT "${_tests_performance_timeout}")
    ctx_set(${CTX} TESTS_PERFORMANCE_LABELS "${_tests_performance_labels}")
    ctx_set(${CTX} TESTS_PERFORMANCE_EXTERNALS "${_tests_performance_externals}")
    ctx_set(${CTX} TESTS_PERFORMANCE_FRAMEWORK "${_tests_performance_framework}")
    
    # ==========================================================================
    # Platforms Filter
    # ==========================================================================
    
    set(_platforms "")
    
    _json_array_length("${APP_JSON}" "platforms" _platform_count)
    if(_platform_count GREATER 0)
        math(EXPR _platform_last "${_platform_count} - 1")
        foreach(_plat_idx RANGE 0 ${_platform_last})
            _json_array_get("${APP_JSON}" "platforms" ${_plat_idx} _plat)
            list(APPEND _platforms "${_plat}")
        endforeach()
    endif()
    
    ctx_set(${CTX} PLATFORMS "${_platforms}")
    
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
    dbg(${DBG_ULTRA_RARE} "    PCH: ${_pch_enabled} (header=${_pch_header}, path=${_pch_path})" ID APPS)
    dbg(${DBG_ULTRA_RARE} "    TESTS_FRAMEWORK: ${_tests_framework}" ID APPS)
    dbg(${DBG_ULTRA_RARE} "    TESTS_UNIT_ENABLED: ${_tests_unit_enabled}" ID APPS)
    dbg(${DBG_ULTRA_RARE} "    TESTS_INTEGRATION_ENABLED: ${_tests_integration_enabled}" ID APPS)
    dbg(${DBG_ULTRA_RARE} "    TESTS_PERFORMANCE_ENABLED: ${_tests_performance_enabled}" ID APPS)
    dbg(${DBG_ULTRA_RARE} "    PLATFORMS: ${_platforms}" ID APPS)
    
endfunction()
