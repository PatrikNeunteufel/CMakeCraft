# cmake/project/AppCreate.cmake
# ==============================
# Creates App-Container targets from prepared Context
#
# Version: 0.5.0
# Date:    2025-12-17
# Status:  Development
# Author:  CMake Architecture V2 Team
#
# Dependencies:
#   - cmake/core/Context.cmake
#   - cmake/core/Errors.cmake
#   - cmake/core/Debug.cmake
#   - cmake/core/OutputDirs.cmake
#   - cmake/core/Warnings.cmake
#   - cmake/core/CompilerOptions.cmake
#   - cmake/externals/Orchestrator.cmake
#
# Provides:
#   - _create_app_core(CTX)    - Creates {AppName}.Core STATIC library
#   - _create_app_runner(CTX)  - Creates {AppName} executable
#   - _create_app_tests(CTX)   - Creates {AppName}.*Tests executables
#
# Used by:
#   - Apps.cmake

include_guard(GLOBAL)

# ==============================================================================
# _create_app_core - Creates the Core STATIC library
# ==============================================================================
#[[
    _create_app_core(CTX)
    
    Creates the {AppName}.Core STATIC library containing all business logic.
    This library is linked by both the Runner and the Tests.
    
    Parameters:
        CTX - Mandatory: Context prefix (e.g. APP_0, APP_1)
    
    Expected Context Keys:
        NAME, PATH, VERSION, PCH_ENABLED, PCH_HEADER, PCH_SOURCE,
        CORE_DEPENDENCIES, CORE_EXTERNALS
    
    Directory Structure Expected:
        {PATH}/
        ├── include/    - PUBLIC headers
        └── src/        - Implementation files
    
    Generated Target:
        {AppName}.Core - STATIC library
    
    Example:
        ctx_create(APP_0)
        _collect_app("${_app_json}" APP_0)
        _create_app_core(APP_0)
        # Creates: AudioPlayer.Core
]]
function(_create_app_core CTX)
    
    # --------------------------------------------------------------------------
    # Read Context Data
    # --------------------------------------------------------------------------
    
    ctx_get(${CTX} NAME _name)
    ctx_get(${CTX} PATH _path)
    ctx_get(${CTX} VERSION _version)
    ctx_get(${CTX} PCH_ENABLED _pch_enabled)
    ctx_get(${CTX} PCH_HEADER _pch_header)
    ctx_get(${CTX} PCH_SOURCE _pch_source)
    ctx_get(${CTX} CORE_DEPENDENCIES _dependencies)
    ctx_get(${CTX} CORE_EXTERNALS _externals)
    
    set(_target_name "${_name}.Core")
    set(_base_dir "${CMAKE_SOURCE_DIR}/${_path}")
    set(_src_dir "${_base_dir}/src")
    set(_include_dir "${_base_dir}/include")
    
    # --------------------------------------------------------------------------
    # Validate Directories
    # --------------------------------------------------------------------------
    
    # Base path must exist
    if(NOT EXISTS "${_base_dir}")
        cmake_fatal("E402" "App '${_name}': Path does not exist: ${_path}")
    endif()
    
    # src/ directory must exist
    if(NOT EXISTS "${_src_dir}")
        cmake_fatal("E403" "App '${_name}': No src/ directory in ${_path}")
    endif()
    
    # include/ directory is optional but recommended
    if(NOT EXISTS "${_include_dir}")
        cmake_warn("W401" "App '${_name}': No include/ directory (headers will be private)")
        set(_has_include_dir FALSE)
    else()
        set(_has_include_dir TRUE)
    endif()
    
    # --------------------------------------------------------------------------
    # Collect Sources
    # --------------------------------------------------------------------------
    
    file(GLOB_RECURSE _sources
        "${_src_dir}/*.cpp"
        "${_src_dir}/*.cxx"
        "${_src_dir}/*.cc"
        "${_src_dir}/*.c"
    )
    
    file(GLOB_RECURSE _private_headers
        "${_src_dir}/*.h"
        "${_src_dir}/*.hpp"
        "${_src_dir}/*.hxx"
    )
    
    if(NOT _sources)
        cmake_fatal("E404" "App '${_name}': No source files found in src/")
    endif()
    
    # Collect public headers if include/ exists
    set(_public_headers "")
    if(_has_include_dir)
        file(GLOB_RECURSE _public_headers
            "${_include_dir}/*.h"
            "${_include_dir}/*.hpp"
            "${_include_dir}/*.hxx"
        )
    endif()
    
    dbg(${DBG_RARE} "    Core sources: ${_sources}" ID APPS)
    dbg(${DBG_ULTRA_RARE} "    Public headers: ${_public_headers}" ID APPS)
    
    # --------------------------------------------------------------------------
    # Create STATIC Library
    # --------------------------------------------------------------------------
    
    add_library(${_target_name} STATIC)
    
    target_sources(${_target_name}
        PRIVATE
            ${_sources}
            ${_private_headers}
    )
    
    if(_public_headers)
        target_sources(${_target_name}
            PUBLIC
                FILE_SET HEADERS
                BASE_DIRS "${_include_dir}"
                FILES ${_public_headers}
        )
    endif()
    
    # --------------------------------------------------------------------------
    # Include Directories
    # --------------------------------------------------------------------------
    
    # Private: src/ for implementation details
    target_include_directories(${_target_name} PRIVATE "${_src_dir}")
    
    # Public: include/ for consumers (Runner, Tests, other targets)
    if(_has_include_dir)
        target_include_directories(${_target_name} PUBLIC "${_include_dir}")
    endif()
    
    # --------------------------------------------------------------------------
    # Precompiled Headers
    # --------------------------------------------------------------------------
    
    if(_pch_enabled)
        set(_pch_path "${_base_dir}/${_pch_header}")
        
        if(EXISTS "${_pch_path}")
            target_precompile_headers(${_target_name} PRIVATE "${_pch_path}")
            dbg(${DBG_RARE} "    PCH: ${_pch_path}" ID APPS)
        else()
            cmake_warn("W402" "App '${_name}': PCH enabled but '${_pch_header}' not found")
        endif()
    endif()
    
    # --------------------------------------------------------------------------
    # Internal Dependencies (Libraries)
    # --------------------------------------------------------------------------
    
    foreach(_dep IN LISTS _dependencies)
        if(TARGET ${_dep})
            target_link_libraries(${_target_name} PUBLIC ${_dep})
            dbg(${DBG_RARE} "    Link: ${_dep} (internal, PUBLIC)" ID APPS)
        else()
            cmake_fatal("E405" "App '${_name}': Dependency '${_dep}' does not exist")
        endif()
    endforeach()
    
    # --------------------------------------------------------------------------
    # External Dependencies (via Orchestrator)
    # --------------------------------------------------------------------------
    
    foreach(_ext IN LISTS _externals)
        # Check if external is defined in central block
        get_property(_externals_json GLOBAL PROPERTY SOLUTION_EXTERNALS_JSON)
        _json_has_key("${_externals_json}" "${_ext}" _ext_defined)
        
        if(NOT _ext_defined)
            cmake_fatal("E010" "External '${_ext}' not defined in externals block")
        endif()
        
        # Apply external via Orchestrator (no per-target options for Core)
        apply_external_to_target("${_target_name}" "${_ext}" "{}")
        
        dbg(${DBG_RARE} "    External: ${_ext} applied" ID APPS)
    endforeach()
    
    # --------------------------------------------------------------------------
    # Apply Standard Modules
    # --------------------------------------------------------------------------
    
    # Warnings (from Warnings.cmake)
    apply_warnings(${_target_name})
    
    # Compiler options (from CompilerOptions.cmake)
    apply_compiler_options(${_target_name})
    
    # Output directories (from OutputDirs.cmake)
    setup_output_dirs(${_target_name})
    
    # --------------------------------------------------------------------------
    # Version as Target Property
    # --------------------------------------------------------------------------
    
    if(NOT "${_version}" STREQUAL "")
        set_target_properties(${_target_name} PROPERTIES
            VERSION "${_version}"
        )
    endif()
    
    # --------------------------------------------------------------------------
    # IDE Organization
    # --------------------------------------------------------------------------
    
    set_target_properties(${_target_name} PROPERTIES
        FOLDER "Apps/${_name}"
    )
    
endfunction()

# ==============================================================================
# _create_app_runner - Creates the Runner executable
# ==============================================================================
#[[
    _create_app_runner(CTX)
    
    Creates the {AppName} executable (the runner with main()).
    Links against {AppName}.Core and applies runner-specific externals.
    
    Parameters:
        CTX - Mandatory: Context prefix (e.g. APP_0, APP_1)
    
    Expected Context Keys:
        NAME, PATH, VERSION, RUNNER_TYPE, RUNNER_EXTERNALS
    
    Directory Structure Expected:
        {PATH}/
        └── main/    - Entry point (main.cpp)
    
    Generated Target:
        {AppName} - Executable (CONSOLE or GUI)
]]
function(_create_app_runner CTX)
    
    # --------------------------------------------------------------------------
    # Read Context Data
    # --------------------------------------------------------------------------
    
    ctx_get(${CTX} NAME _name)
    ctx_get(${CTX} PATH _path)
    ctx_get(${CTX} VERSION _version)
    ctx_get(${CTX} DISPLAY_NAME _display_name)
    ctx_get(${CTX} RUNNER_TYPE _runner_type)
    ctx_get(${CTX} RUNNER_EXTERNALS _externals)
    
    set(_target_name "${_name}")
    set(_core_target "${_name}.Core")
    set(_base_dir "${CMAKE_SOURCE_DIR}/${_path}")
    set(_main_dir "${_base_dir}/main")
    
    # --------------------------------------------------------------------------
    # Validate main/ Directory
    # --------------------------------------------------------------------------
    
    if(NOT EXISTS "${_main_dir}")
        cmake_fatal("E406" "App '${_name}': No main/ directory in ${_path}")
    endif()
    
    # --------------------------------------------------------------------------
    # Collect Sources from main/
    # --------------------------------------------------------------------------
    
    file(GLOB_RECURSE _sources
        "${_main_dir}/*.cpp"
        "${_main_dir}/*.cxx"
        "${_main_dir}/*.cc"
        "${_main_dir}/*.c"
    )
    
    file(GLOB_RECURSE _headers
        "${_main_dir}/*.h"
        "${_main_dir}/*.hpp"
        "${_main_dir}/*.hxx"
    )
    
    if(NOT _sources)
        cmake_fatal("E407" "App '${_name}': No source files found in main/")
    endif()
    
    dbg(${DBG_RARE} "    Runner sources: ${_sources}" ID APPS)
    
    # --------------------------------------------------------------------------
    # Create Executable (GUI vs. CONSOLE)
    # --------------------------------------------------------------------------
    
    if(_runner_type STREQUAL "WINDOW" OR _runner_type STREQUAL "GUI")
        if(WIN32)
            add_executable(${_target_name} WIN32 ${_sources} ${_headers})
        elseif(APPLE)
            add_executable(${_target_name} MACOSX_BUNDLE ${_sources} ${_headers})
        else()
            add_executable(${_target_name} ${_sources} ${_headers})
        endif()
    else()
        # CONSOLE or other
        add_executable(${_target_name} ${_sources} ${_headers})
    endif()
    
    dbg(${DBG_RARE} "    add_executable(${_target_name}) [${_runner_type}]" ID APPS)
    
    # --------------------------------------------------------------------------
    # Include Directory for main/
    # --------------------------------------------------------------------------
    
    target_include_directories(${_target_name} PRIVATE "${_main_dir}")
    
    # --------------------------------------------------------------------------
    # Link Against Core Library
    # --------------------------------------------------------------------------
    
    target_link_libraries(${_target_name} PRIVATE ${_core_target})
    dbg(${DBG_RARE} "    Link: ${_core_target} (Core Library)" ID APPS)
    
    # --------------------------------------------------------------------------
    # Runner-Specific External Dependencies
    # --------------------------------------------------------------------------
    
    foreach(_ext IN LISTS _externals)
        # Check if external is defined in central block
        get_property(_externals_json GLOBAL PROPERTY SOLUTION_EXTERNALS_JSON)
        _json_has_key("${_externals_json}" "${_ext}" _ext_defined)
        
        if(NOT _ext_defined)
            cmake_fatal("E010" "External '${_ext}' not defined in externals block")
        endif()
        
        # Apply external via Orchestrator
        apply_external_to_target("${_target_name}" "${_ext}" "{}")
        
        dbg(${DBG_RARE} "    External: ${_ext} applied (Runner)" ID APPS)
    endforeach()
    
    # --------------------------------------------------------------------------
    # Apply Standard Modules
    # --------------------------------------------------------------------------
    
    apply_warnings(${_target_name})
    apply_compiler_options(${_target_name})
    setup_output_dirs(${_target_name})
    
    # --------------------------------------------------------------------------
    # Version as Target Property
    # --------------------------------------------------------------------------
    
    if(NOT "${_version}" STREQUAL "")
        set_target_properties(${_target_name} PROPERTIES
            VERSION "${_version}"
        )
    endif()
    
    # --------------------------------------------------------------------------
    # Windows-specific: Subsystem for GUI
    # --------------------------------------------------------------------------
    
    if(WIN32 AND (_runner_type STREQUAL "WINDOW" OR _runner_type STREQUAL "GUI"))
        set_target_properties(${_target_name} PROPERTIES
            WIN32_EXECUTABLE TRUE
        )
        target_compile_definitions(${_target_name} PRIVATE APP_WINDOWS_GUI)
        dbg(${DBG_RARE} "    Windows GUI: APP_WINDOWS_GUI defined" ID APPS)
    endif()
    
    # --------------------------------------------------------------------------
    # macOS-specific: Bundle Properties
    # --------------------------------------------------------------------------
    
    if(APPLE AND (_runner_type STREQUAL "WINDOW" OR _runner_type STREQUAL "GUI"))
        set_target_properties(${_target_name} PROPERTIES
            MACOSX_BUNDLE TRUE
            MACOSX_BUNDLE_GUI_IDENTIFIER "com.project.${_name}"
            MACOSX_BUNDLE_BUNDLE_NAME "${_display_name}"
            MACOSX_BUNDLE_BUNDLE_VERSION "${_version}"
            MACOSX_BUNDLE_SHORT_VERSION_STRING "${_version}"
        )
    endif()
    
    # --------------------------------------------------------------------------
    # IDE Organization
    # --------------------------------------------------------------------------
    
    set_target_properties(${_target_name} PROPERTIES
        FOLDER "Apps/${_name}"
    )
    
    if(NOT "${_display_name}" STREQUAL "${_name}")
        set_target_properties(${_target_name} PROPERTIES
            PROJECT_LABEL "${_display_name}"
        )
    endif()
    
endfunction()

# ==============================================================================
# _create_app_tests - Creates Unit and Integration Test executables
# ==============================================================================
#[[
    _create_app_tests(CTX)
    
    Creates test executables for the App-Container.
    Tests link against {AppName}.Core and use the configured test framework.
    
    Parameters:
        CTX - Mandatory: Context prefix (e.g. APP_0, APP_1)
    
    Expected Context Keys:
        NAME, PATH, TESTS_FRAMEWORK,
        TESTS_UNIT_ENABLED, TESTS_UNIT_TIMEOUT, TESTS_UNIT_LABELS,
        TESTS_INTEGRATION_ENABLED, TESTS_INTEGRATION_TIMEOUT,
        TESTS_INTEGRATION_LABELS, TESTS_INTEGRATION_EXTERNALS
    
    Directory Structure Expected:
        {PATH}/
        └── tests/
            ├── unit/        - Unit test sources
            └── integration/ - Integration test sources
    
    Generated Targets:
        {AppName}.UnitTests        - Unit test executable
        {AppName}.IntegrationTests - Integration test executable
]]
function(_create_app_tests CTX)
    
    # --------------------------------------------------------------------------
    # Read Context Data
    # --------------------------------------------------------------------------
    
    ctx_get(${CTX} NAME _name)
    ctx_get(${CTX} PATH _path)
    ctx_get(${CTX} TESTS_FRAMEWORK _framework)
    ctx_get(${CTX} TESTS_UNIT_ENABLED _unit_enabled)
    ctx_get(${CTX} TESTS_UNIT_TIMEOUT _unit_timeout)
    ctx_get(${CTX} TESTS_UNIT_LABELS _unit_labels)
    ctx_get(${CTX} TESTS_INTEGRATION_ENABLED _integration_enabled)
    ctx_get(${CTX} TESTS_INTEGRATION_TIMEOUT _integration_timeout)
    ctx_get(${CTX} TESTS_INTEGRATION_LABELS _integration_labels)
    ctx_get(${CTX} TESTS_INTEGRATION_EXTERNALS _integration_externals)
    ctx_get(${CTX} CORE_EXTERNALS _core_externals)
    
    set(_core_target "${_name}.Core")
    set(_base_dir "${CMAKE_SOURCE_DIR}/${_path}")
    set(_tests_dir "${_base_dir}/tests")
    
    # --------------------------------------------------------------------------
    # Check if tests directory exists
    # --------------------------------------------------------------------------
    
    if(NOT EXISTS "${_tests_dir}")
        # No tests directory - nothing to do
        dbg(${DBG_RARE} "    No tests/ directory for ${_name}" ID APPS)
        return()
    endif()
    
    # --------------------------------------------------------------------------
    # Validate Framework
    # --------------------------------------------------------------------------
    
    set(_valid_frameworks "doctest" "googletest" "catch2")
    if(NOT "${_framework}" IN_LIST _valid_frameworks)
        cmake_fatal("E301" "App '${_name}': Unknown test framework '${_framework}'. Valid: ${_valid_frameworks}")
    endif()
    
    # --------------------------------------------------------------------------
    # Unit Tests
    # --------------------------------------------------------------------------
    
    if(_unit_enabled)
        set(_unit_dir "${_tests_dir}/unit")
        
        if(EXISTS "${_unit_dir}")
            _create_app_test_target(
                "${_name}.UnitTests"
                "${_unit_dir}"
                "${_core_target}"
                "${_framework}"
                "${_unit_timeout}"
                "${_unit_labels}"
                ""  # No additional externals for unit tests
                "${_name}"
            )
            dbg(${DBG_COMMON} "  Created: ${_name}.UnitTests" ID APPS)
        else()
            cmake_warn("W403" "App '${_name}': tests.unit enabled but no tests/unit/ directory")
        endif()
    endif()
    
    # --------------------------------------------------------------------------
    # Integration Tests
    # --------------------------------------------------------------------------
    
    if(_integration_enabled)
        set(_integration_dir "${_tests_dir}/integration")
        
        if(EXISTS "${_integration_dir}")
            _create_app_test_target(
                "${_name}.IntegrationTests"
                "${_integration_dir}"
                "${_core_target}"
                "${_framework}"
                "${_integration_timeout}"
                "${_integration_labels}"
                "${_integration_externals}"
                "${_name}"
            )
            dbg(${DBG_COMMON} "  Created: ${_name}.IntegrationTests" ID APPS)
        else()
            cmake_warn("W403" "App '${_name}': tests.integration enabled but no tests/integration/ directory")
        endif()
    endif()
    
endfunction()

# ==============================================================================
# _create_app_test_target - Helper to create a single test target
# ==============================================================================
#[[
    _create_app_test_target(TARGET_NAME SRC_DIR CORE_TARGET FRAMEWORK TIMEOUT LABELS EXTRA_EXTERNALS APP_NAME)
    
    Internal helper function to create a test executable.
    
    Parameters:
        TARGET_NAME     - Name for the test target
        SRC_DIR         - Directory containing test sources
        CORE_TARGET     - Core library to link against
        FRAMEWORK       - Test framework (doctest, googletest, catch2)
        TIMEOUT         - CTest timeout in seconds
        LABELS          - CTest labels (semicolon-separated)
        EXTRA_EXTERNALS - Additional externals for this test
        APP_NAME        - Parent app name (for folder organization)
]]
function(_create_app_test_target TARGET_NAME SRC_DIR CORE_TARGET FRAMEWORK TIMEOUT LABELS EXTRA_EXTERNALS APP_NAME)
    
    # --------------------------------------------------------------------------
    # Collect Sources
    # --------------------------------------------------------------------------
    
    file(GLOB_RECURSE _sources
        "${SRC_DIR}/*.cpp"
        "${SRC_DIR}/*.cxx"
        "${SRC_DIR}/*.cc"
        "${SRC_DIR}/*.c"
    )
    
    file(GLOB_RECURSE _headers
        "${SRC_DIR}/*.h"
        "${SRC_DIR}/*.hpp"
        "${SRC_DIR}/*.hxx"
    )
    
    if(NOT _sources)
        cmake_warn("W403" "Test '${TARGET_NAME}': No source files found")
        return()
    endif()
    
    # --------------------------------------------------------------------------
    # Create Test Executable
    # --------------------------------------------------------------------------
    
    add_executable(${TARGET_NAME} ${_sources} ${_headers})
    
    target_include_directories(${TARGET_NAME} PRIVATE "${SRC_DIR}")
    
    # --------------------------------------------------------------------------
    # Link Against Core Library
    # --------------------------------------------------------------------------
    
    target_link_libraries(${TARGET_NAME} PRIVATE ${CORE_TARGET})
    
    # --------------------------------------------------------------------------
    # Link Test Framework
    # --------------------------------------------------------------------------
    
    # Check if framework external is defined
    get_property(_externals_json GLOBAL PROPERTY SOLUTION_EXTERNALS_JSON)
    _json_has_key("${_externals_json}" "${FRAMEWORK}" _framework_defined)
    
    if(NOT _framework_defined)
        cmake_fatal("E010" "Test framework '${FRAMEWORK}' not defined in externals block")
    endif()
    
    apply_external_to_target("${TARGET_NAME}" "${FRAMEWORK}" "{}")
    
    # --------------------------------------------------------------------------
    # Additional Externals (for integration tests)
    # --------------------------------------------------------------------------
    
    foreach(_ext IN LISTS EXTRA_EXTERNALS)
        _json_has_key("${_externals_json}" "${_ext}" _ext_defined)
        
        if(NOT _ext_defined)
            cmake_fatal("E010" "External '${_ext}' not defined in externals block")
        endif()
        
        apply_external_to_target("${TARGET_NAME}" "${_ext}" "{}")
    endforeach()
    
    # --------------------------------------------------------------------------
    # Apply Standard Modules
    # --------------------------------------------------------------------------
    
    apply_warnings(${TARGET_NAME})
    apply_compiler_options(${TARGET_NAME})
    setup_output_dirs(${TARGET_NAME})
    
    # --------------------------------------------------------------------------
    # CTest Registration
    # --------------------------------------------------------------------------
    
    add_test(
        NAME ${TARGET_NAME}
        COMMAND ${TARGET_NAME}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
    
    # Timeout
    set_tests_properties(${TARGET_NAME} PROPERTIES
        TIMEOUT ${TIMEOUT}
    )
    
    # Labels (add app name as label automatically)
    set(_all_labels "${APP_NAME}")
    if(LABELS)
        list(APPEND _all_labels ${LABELS})
    endif()
    set_tests_properties(${TARGET_NAME} PROPERTIES
        LABELS "${_all_labels}"
    )
    
    # --------------------------------------------------------------------------
    # IDE Organization
    # --------------------------------------------------------------------------
    
    set_target_properties(${TARGET_NAME} PROPERTIES
        FOLDER "Apps/${APP_NAME}/Tests"
        VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
    )
    
endfunction()
