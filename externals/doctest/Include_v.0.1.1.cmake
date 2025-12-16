# ==============================================================================
# externals/doctest/Include.cmake – doctest Testing Framework Integration
# ==============================================================================
#
# Module:       Include.cmake
# Version:      0.1.0
# Date:         2025-12-08
# Part of:      CMake Architecture V2
# Type:         Local External Include
#
# Description:
#   Integrates the doctest testing framework into a target.
#   doctest is header-only, so only include directories are needed.
#
# Expected Variables (set by Orchestrator):
#   EXTERNAL_NAME    - "doctest"
#   EXTERNAL_ROOT    - Path to externals/doctest
#   EXTERNAL_OPTIONS - JSON string with options
#   EXECUTABLE_NAME  - Target to attach to
#
# Available Options (via external_options in Solution.json):
#   DOCTEST_NO_SHORT_MACRO_NAMES      - Use long macro names (TEST_CASE → DOCTEST_TEST_CASE)
#   DOCTEST_CONFIG_SUPER_FAST_ASSERTS - Faster asserts with less debug info
#   DOCTEST_CONFIG_DISABLE            - Disable doctest completely (for release builds)
#
# Creates: Header-only, no libraries to link
#
# Based on:
#   - CMake_Blueprint v0.1
#   - guidelines v0.1
#
# ==============================================================================

# Note: No include_guard() - this file is included per-target intentionally

# ==============================================================================
# Variable Compatibility
# ==============================================================================

# Support both new and legacy variable names
if(NOT DEFINED EXTERNAL_OPTIONS AND DEFINED EXTERNAL_ELEMENT_OPTIONS)
    set(EXTERNAL_OPTIONS "${EXTERNAL_ELEMENT_OPTIONS}")
endif()
if(NOT DEFINED EXTERNAL_NAME AND DEFINED EXTERNAL_ELEMENT_NAME)
    set(EXTERNAL_NAME "${EXTERNAL_ELEMENT_NAME}")
endif()
if(NOT DEFINED EXTERNAL_ROOT)
    set(EXTERNAL_ROOT "${CMAKE_SOURCE_DIR}/externals/doctest")
endif()

# ==============================================================================
# Debug Output
# ==============================================================================

message(STATUS "[${EXTERNAL_NAME}] Attaching to ${EXECUTABLE_NAME}")

# ==============================================================================
# Path Configuration
# ==============================================================================

set(_doctest_root "${EXTERNAL_ROOT}")

# ==============================================================================
# Include Directory (Header-Only Library)
# ==============================================================================

# doctest.h is in the root directory
target_include_directories(${EXECUTABLE_NAME} PRIVATE "${_doctest_root}")

message(STATUS "[${EXTERNAL_NAME}]   Header: ${_doctest_root}/doctest.h")

# ==============================================================================
# Process Options
# ==============================================================================

_json_get_bool_from_key("${EXTERNAL_OPTIONS}" "DOCTEST_NO_SHORT_MACRO_NAMES" _no_short_macros)
if(_no_short_macros)
    target_compile_definitions(${EXECUTABLE_NAME} PRIVATE 
        DOCTEST_CONFIG_NO_SHORT_MACRO_NAMES
    )
    message(STATUS "[${EXTERNAL_NAME}]   No Short Macros: ENABLED")
endif()

_json_get_bool_from_key("${EXTERNAL_OPTIONS}" "DOCTEST_CONFIG_SUPER_FAST_ASSERTS" _fast_asserts)
if(_fast_asserts)
    target_compile_definitions(${EXECUTABLE_NAME} PRIVATE 
        DOCTEST_CONFIG_SUPER_FAST_ASSERTS
    )
    message(STATUS "[${EXTERNAL_NAME}]   Super Fast Asserts: ENABLED")
endif()

_json_get_bool_from_key("${EXTERNAL_OPTIONS}" "DOCTEST_CONFIG_DISABLE" _disable)
if(_disable)
    target_compile_definitions(${EXECUTABLE_NAME} PRIVATE 
        DOCTEST_CONFIG_DISABLE
    )
    message(STATUS "[${EXTERNAL_NAME}]   doctest: DISABLED")
endif()

# ==============================================================================
# Platform-Specific Configuration
# ==============================================================================

# MSVC: Suppress specific warnings
if(MSVC)
    target_compile_options(${EXECUTABLE_NAME} PRIVATE
        /wd4251  # 'identifier' : class 'type' needs to have dll-interface
        /wd4275  # non dll-interface class 'type' used as base
    )
endif()

# GCC/Clang: Suppress specific warnings
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(${EXECUTABLE_NAME} PRIVATE
        -Wno-unknown-pragmas
    )
endif()

# ==============================================================================
# Complete
# ==============================================================================

message(STATUS "[${EXTERNAL_NAME}] Integration complete (header-only)")
