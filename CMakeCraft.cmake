# ==============================================================================
# CMakeCraft.cmake – Entry Point (relocatable)
# ==============================================================================
#
# Project:      CMakeCraft (CMake Architecture V2)
# Version:      0.7.0
# Date:         2026-07-18
#
# Description:
#   Single entry point of the CMakeCraft build system. Self-locating: all
#   build-system modules are loaded relative to this file (CMAKECRAFT_DIR),
#   so CMakeCraft can live anywhere (project snapshot, .externals/ checkout,
#   submodule, sibling directory).
#
#   Project-owned inputs stay relative to the CONSUMING project
#   (CMAKE_SOURCE_DIR): Solution.json, projects/, externals/, .externals/.
#
# Consumer usage (thin CMakeLists.txt):
#   cmake_minimum_required(VERSION 3.25)
#   include("<path-to-cmakecraft>/CMakeCraft.cmake")
#
# Options:
#   -DBUILD_TESTS=ON|OFF          Build project tests (default: OFF)
#   -DRUN_BUILD_SYSTEM_TESTS=ON   Run phase tests (default: OFF; CMakeCraft
#                                 repo itself: use preset "craft-selftest")
#   -DTEST_PHASE=1..9             Specific phase(s) to test (default: all)
#   -DDEBUG_MESSAGES=ON|OFF       Debug output on/off (default: ON)
#   -DDEBUG_DEFAULT_LEVEL=1-5     Debug verbosity (default: 2)
#
# Changelog:
#   v0.7.0 (2026-07-18): relocatable entry point (CMAKECRAFT_DIR), phase-test
#                        block reactivated (was commented out)
#   v0.6.x (2026-07-17): case fixes (lowercase), packages/ tracked, selftest preset
#   v0.5.0 (2025-12-17): Phase 8 (App-Container)
#
# ==============================================================================

# Include guard (a consumer must not load the build system twice)
if(DEFINED CMAKECRAFT_INCLUDED)
    return()
endif()
set(CMAKECRAFT_INCLUDED TRUE)

# ==============================================================================
# Self-location: CMAKECRAFT_DIR points to the module tree of THIS checkout
# ==============================================================================

set(CMAKECRAFT_ROOT "${CMAKE_CURRENT_LIST_DIR}")
set(CMAKECRAFT_DIR  "${CMAKE_CURRENT_LIST_DIR}/cmake")

# ==============================================================================
# Options
# ==============================================================================

option(BUILD_TESTS "Build project tests" OFF)
# Default OFF: consumer projects do not need the build-system self-tests.
# In the CMakeCraft repo itself: use preset "craft-selftest" (or -DRUN_BUILD_SYSTEM_TESTS=ON).
option(RUN_BUILD_SYSTEM_TESTS "Run build system phase tests" OFF)
set(TEST_PHASE "" CACHE STRING "Specific phase to test (empty = all completed phases)")

# ==============================================================================
# Phase 1: Core Modules (Order Matters!)
# ==============================================================================

include("${CMAKECRAFT_DIR}/core/Errors.cmake")
include("${CMAKECRAFT_DIR}/core/Debug.cmake")
include("${CMAKECRAFT_DIR}/core/Json.cmake")
include("${CMAKECRAFT_DIR}/core/Validation.cmake")
include("${CMAKECRAFT_DIR}/core/Context.cmake")
include("${CMAKECRAFT_DIR}/core/SourceCollect.cmake")
include("${CMAKECRAFT_DIR}/core/OutputDirs.cmake")
include("${CMAKECRAFT_DIR}/core/Warnings.cmake")
include("${CMAKECRAFT_DIR}/core/CompilerOptions.cmake")

# ==============================================================================
# Build System Info (via Debug Module)
# ==============================================================================

dbg_init(ID CMAKE_MAIN LEVEL ${DBG_SHOW_MUCH} SWITCH ON TAG "CMake")

dbg(${DBG_OFTEN} "=== CMakeCraft (CMake Architecture V2) ===" ID CMAKE_MAIN)
dbg(${DBG_COMMON} "CMakeCraft Dir: ${CMAKECRAFT_DIR}" ID CMAKE_MAIN)
dbg(${DBG_COMMON} "CMake Version: ${CMAKE_VERSION}" ID CMAKE_MAIN)
dbg(${DBG_COMMON} "Generator: ${CMAKE_GENERATOR}" ID CMAKE_MAIN)
dbg(${DBG_COMMON} "Build Tests: ${BUILD_TESTS}" ID CMAKE_MAIN)
dbg(${DBG_COMMON} "Build System Tests: ${RUN_BUILD_SYSTEM_TESTS}" ID CMAKE_MAIN)

# ==============================================================================
# Phase 2: Solution Configuration (reads <project>/Solution.json)
# ==============================================================================

include("${CMAKECRAFT_DIR}/project/Solution.cmake")

# ==============================================================================
# Project Definition (with values from Solution.json)
# ==============================================================================

get_property(_sol_name GLOBAL PROPERTY SOLUTION_NAME)
get_property(_sol_version GLOBAL PROPERTY SOLUTION_VERSION)

project(
    "${_sol_name}"
    VERSION "${_sol_version}"
    LANGUAGES C CXX
)

dbg(${DBG_COMMON} "Project: ${PROJECT_NAME} v${PROJECT_VERSION}" ID CMAKE_MAIN)

# ==============================================================================
# Phase 5 & 6: Externals (Local + Fetched) — BEFORE Libraries and Executables!
# ==============================================================================

include("${CMAKECRAFT_DIR}/project/Externals.cmake")

# ==============================================================================
# Phase 4: Libraries — BEFORE Executables!
# ==============================================================================

include("${CMAKECRAFT_DIR}/project/Libraries.cmake")

# ==============================================================================
# Phase 3: Executables
# ==============================================================================

include("${CMAKECRAFT_DIR}/project/Executables.cmake")

# ==============================================================================
# Phase 8: App-Container
# ==============================================================================

include("${CMAKECRAFT_DIR}/project/Apps.cmake")

# ==============================================================================
# Phase 7: Tests (only when BUILD_TESTS is enabled)
# ==============================================================================

if(BUILD_TESTS)
    include("${CMAKECRAFT_DIR}/project/Tests.cmake")
endif()

# ==============================================================================
# Close Main Debug Block
# ==============================================================================

dbgspace(ID CMAKE_MAIN)
dbg(${DBG_OFTEN} "=== Configuration Complete ===" ID CMAKE_MAIN)
enddbgblock(ID CMAKE_MAIN)

# ==============================================================================
# Build System Tests (optional, after pipeline)
# ==============================================================================

if(RUN_BUILD_SYSTEM_TESTS)

    dbg_init(ID BUILD_TEST LEVEL ${DBG_SHOW_ALL} SWITCH ON TAG "BuildTest")
    dbg(${DBG_OFTEN} "Running Build System Tests..." ID BUILD_TEST)

    if(NOT "${TEST_PHASE}" STREQUAL "")
        dbg(${DBG_COMMON} "Testing phase(s): ${TEST_PHASE}" ID BUILD_TEST)
    else()
        dbg(${DBG_COMMON} "Testing all completed phases" ID BUILD_TEST)
    endif()

    foreach(_craft_phase RANGE 1 9)
        if("${TEST_PHASE}" STREQUAL "" OR "${_craft_phase}" IN_LIST TEST_PHASE)
            dbgspace(ID BUILD_TEST)
            include("${CMAKECRAFT_DIR}/buildSystemTest/phase${_craft_phase}.cmake")
        endif()
    endforeach()
    unset(_craft_phase)

    dbgspace(ID BUILD_TEST)
    dbg(${DBG_OFTEN} "Build System Tests completed" ID BUILD_TEST)
    enddbgblock(ID BUILD_TEST)

endif()

# ==============================================================================
# Cleanup
# ==============================================================================

unset(_sol_name)
unset(_sol_version)
