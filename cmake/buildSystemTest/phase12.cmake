# ==============================================================================
# Phase12.cmake – Build System Test for the Documentation Target (Doxygen)
# ==============================================================================
#
# Test:         Phase 12
# Version:      1.0.0
# Date:         2026-11-26
# Part of:      CMake Architecture
#
# Description:
#   Tests (CMakeCraft v0.15.0):
#   - Without "documentation" no target docs exists (demo solution)
#   - "documentation.doxygen.doxyfile": the project's Doxyfile runs unchanged
#     in the project root (relative INPUT and OUTPUT_DIRECTORY resolve there),
#     the target is not part of ALL
#   - "target" renames the target; Doxygen's exit code is passed through
#     (WARN_AS_ERROR = YES in the Doxyfile makes the target fail)
#   - Doxygen not found -> W202, configure succeeds, the target fails
#   - Doxyfile missing -> E107; "doxyfile" missing -> E001
#
#   Everything is written below <build>/phase12/. The nested projects use the
#   generator and compilers of this build. Tests that run Doxygen are skipped
#   (with a note) when Doxygen is not installed.
#
# ==============================================================================

include_guard(GLOBAL)

dbg_init(ID PHASE12_TEST LEVEL ${DBG_SHOW_ALL} SWITCH ON TAG "Phase12")
dbg(${DBG_OFTEN} "=== Phase 12 Test Start ===" ID PHASE12_TEST)

set(_p12_dir "${CMAKE_BINARY_DIR}/phase12")
file(REMOVE_RECURSE "${_p12_dir}")
file(MAKE_DIRECTORY "${_p12_dir}")

# Generator, platform and compilers of this build for the nested projects
set(_p12_gen_args -G "${CMAKE_GENERATOR}")
if(CMAKE_GENERATOR_PLATFORM)
    list(APPEND _p12_gen_args -A "${CMAKE_GENERATOR_PLATFORM}")
endif()
if(CMAKE_GENERATOR_TOOLSET)
    list(APPEND _p12_gen_args -T "${CMAKE_GENERATOR_TOOLSET}")
endif()
if(CMAKE_MAKE_PROGRAM)
    list(APPEND _p12_gen_args "-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}")
endif()
list(APPEND _p12_gen_args
    "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}"
    "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}")
get_property(_p12_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(NOT _p12_multi_config)
    list(APPEND _p12_gen_args "-DCMAKE_BUILD_TYPE=Debug")
endif()

# Writes a minimal CMakeCraft consumer whose Solution.json has only the given
# "documentation" block, and configures it; further arguments go to cmake
function(_p12_configure DIR DOCUMENTATION_JSON OUT_RESULT OUT_OUTPUT)
    file(WRITE "${DIR}/CMakeLists.txt"
        "cmake_minimum_required(VERSION 3.26)\n"
        "project(Phase12Nested LANGUAGES NONE)\n"
        "include(\"${CMAKECRAFT_ROOT}/CMakeCraft.cmake\")\n")
    file(WRITE "${DIR}/Solution.json"
        "{\n"
        "    \"schemaVersion\": \"1.0\",\n"
        "    \"solution\": { \"name\": \"Phase12Nested\", \"version\": \"0.1.0\" },\n"
        "    \"settings\": { \"standards\": { \"cxx_standard\": 20 } },\n"
        "    \"documentation\": ${DOCUMENTATION_JSON}\n"
        "}\n")
    execute_process(
        COMMAND "${CMAKE_COMMAND}" -S "${DIR}" -B "${DIR}/build" ${_p12_gen_args} ${ARGN}
        RESULT_VARIABLE _result
        OUTPUT_VARIABLE _output
        ERROR_VARIABLE _output)
    set(${OUT_RESULT} "${_result}" PARENT_SCOPE)
    set(${OUT_OUTPUT} "${_output}" PARENT_SCOPE)
endfunction()

# Builds TARGET of the nested project in DIR (empty TARGET = default build)
function(_p12_build DIR TARGET OUT_RESULT OUT_OUTPUT)
    set(_target_args "")
    if(NOT "${TARGET}" STREQUAL "")
        set(_target_args --target "${TARGET}")
    endif()
    execute_process(
        COMMAND "${CMAKE_COMMAND}" --build "${DIR}/build" --config Debug ${_target_args}
        RESULT_VARIABLE _result
        OUTPUT_VARIABLE _output
        ERROR_VARIABLE _output)
    set(${OUT_RESULT} "${_result}" PARENT_SCOPE)
    set(${OUT_OUTPUT} "${_output}" PARENT_SCOPE)
endfunction()

# A documented header below src/ and a Doxyfile with paths relative to DIR
function(_p12_write_doxygen_project DIR DOXYFILE_NAME EXTRA_LINES)
    file(WRITE "${DIR}/src/phase12.h"
        "/// @file phase12.h\n"
        "/// @brief Header for the phase 12 test.\n"
        "\n"
        "/// @brief Documented function.\n"
        "int phase12_documented();\n"
        "\n"
        "int phase12_undocumented();\n")
    file(WRITE "${DIR}/${DOXYFILE_NAME}"
        "PROJECT_NAME     = Phase12\n"
        "INPUT            = src\n"
        "OUTPUT_DIRECTORY = apidoc\n"
        "GENERATE_HTML    = YES\n"
        "GENERATE_LATEX   = NO\n"
        "HAVE_DOT         = NO\n"
        "QUIET            = YES\n"
        "${EXTRA_LINES}")
endfunction()

# ==============================================================================
# Test 1: Module loaded, no target docs without the block
# ==============================================================================

dbg(${DBG_COMMON} "Test 1: Function, no block -> no target..." ID PHASE12_TEST)

if(NOT COMMAND _create_doxygen_target)
    cmake_fatal("ASSERT" "_create_doxygen_target() is not defined")
endif()

get_property(_p12_solution_json GLOBAL PROPERTY SOLUTION_JSON)
_json_has_key("${_p12_solution_json}" "documentation" _p12_demo_has_doc)
if(NOT _p12_demo_has_doc AND TARGET docs)
    cmake_fatal("ASSERT" "Solution.json has no 'documentation' block, but a target 'docs' exists")
endif()

dbg(${DBG_COMMON} "  Function defined, no target without the block" ID PHASE12_TEST)

find_package(Doxygen QUIET)
if(TARGET Doxygen::doxygen)
    set(_p12_have_doxygen TRUE)
    dbg(${DBG_COMMON} "  Doxygen ${DOXYGEN_VERSION} found: tests 2-3 run Doxygen" ID PHASE12_TEST)
else()
    set(_p12_have_doxygen FALSE)
    dbg(${DBG_COMMON} "  Doxygen not found: tests 2-3 skipped" ID PHASE12_TEST)
endif()

# ==============================================================================
# Test 2: Project Doxyfile in the root, not part of ALL
# ==============================================================================

if(_p12_have_doxygen)
    dbg(${DBG_COMMON} "Test 2: docs from the project Doxyfile..." ID PHASE12_TEST)

    set(_p12_proj "${_p12_dir}/doxyfile")
    _p12_write_doxygen_project("${_p12_proj}" "Doxyfile" "")
    _p12_configure("${_p12_proj}" [==[{ "doxygen": { "doxyfile": "Doxyfile" } }]==]
        _p12_result _p12_output)
    if(NOT _p12_result EQUAL 0)
        cmake_fatal("ASSERT" "Configure with documentation.doxygen failed (exit ${_p12_result}):\n${_p12_output}")
    endif()
    if(_p12_output MATCHES "W202")
        cmake_fatal("ASSERT" "W202 although Doxygen is installed:\n${_p12_output}")
    endif()

    _p12_build("${_p12_proj}" "" _p12_result _p12_output)
    if(NOT _p12_result EQUAL 0)
        cmake_fatal("ASSERT" "Default build of the nested project failed (exit ${_p12_result}):\n${_p12_output}")
    endif()
    if(EXISTS "${_p12_proj}/apidoc")
        cmake_fatal("ASSERT" "The default build (ALL) ran Doxygen: ${_p12_proj}/apidoc exists")
    endif()

    _p12_build("${_p12_proj}" "docs" _p12_result _p12_output)
    if(NOT _p12_result EQUAL 0)
        cmake_fatal("ASSERT" "Building target docs failed (exit ${_p12_result}):\n${_p12_output}")
    endif()
    if(NOT EXISTS "${_p12_proj}/apidoc/html/index.html")
        cmake_fatal("ASSERT" "Target docs did not write apidoc/html/index.html relative to the project root:\n${_p12_output}")
    endif()

    dbg(${DBG_COMMON} "  ALL without Doxygen, docs writes apidoc/html/index.html in the root" ID PHASE12_TEST)
endif()

# ==============================================================================
# Test 3: Own target name, exit code of Doxygen passed through
# ==============================================================================

if(_p12_have_doxygen)
    dbg(${DBG_COMMON} "Test 3: target, WARN_AS_ERROR..." ID PHASE12_TEST)

    set(_p12_proj "${_p12_dir}/warnaserror")
    _p12_write_doxygen_project("${_p12_proj}" "doc/Strict.doxyfile"
        "EXTRACT_ALL          = NO\nWARN_IF_UNDOCUMENTED = YES\nWARN_AS_ERROR        = YES\n")
    _p12_configure("${_p12_proj}"
        [==[{ "doxygen": { "doxyfile": "doc/Strict.doxyfile", "target": "apidocs" } }]==]
        _p12_result _p12_output)
    if(NOT _p12_result EQUAL 0)
        cmake_fatal("ASSERT" "Configure with target 'apidocs' failed (exit ${_p12_result}):\n${_p12_output}")
    endif()

    _p12_build("${_p12_proj}" "apidocs" _p12_result _p12_output)
    if(_p12_result EQUAL 0)
        cmake_fatal("ASSERT" "Target apidocs succeeded although the Doxyfile sets WARN_AS_ERROR and a function is undocumented:\n${_p12_output}")
    endif()
    if(NOT _p12_output MATCHES "phase12_undocumented")
        cmake_fatal("ASSERT" "Target apidocs failed, but not on Doxygen's warning (exit ${_p12_result}):\n${_p12_output}")
    endif()

    dbg(${DBG_COMMON} "  Target 'apidocs' fails on Doxygen's warning" ID PHASE12_TEST)
endif()

# ==============================================================================
# Test 4: Doxygen not found -> W202, configure succeeds, target fails
# ==============================================================================

dbg(${DBG_COMMON} "Test 4: W202..." ID PHASE12_TEST)

set(_p12_proj "${_p12_dir}/nodoxygen")
_p12_write_doxygen_project("${_p12_proj}" "Doxyfile" "")
_p12_configure("${_p12_proj}" [==[{ "doxygen": { "doxyfile": "Doxyfile" } }]==]
    _p12_result _p12_output -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=TRUE)
if(NOT _p12_result EQUAL 0 OR NOT _p12_output MATCHES "\\[W202\\]")
    cmake_fatal("ASSERT" "Without Doxygen configure should succeed with W202 (exit ${_p12_result}):\n${_p12_output}")
endif()

_p12_build("${_p12_proj}" "docs" _p12_result _p12_output)
if(_p12_result EQUAL 0 OR NOT _p12_output MATCHES "Doxygen not found")
    cmake_fatal("ASSERT" "Without Doxygen target docs should fail with a message (exit ${_p12_result}):\n${_p12_output}")
endif()

dbg(${DBG_COMMON} "  W202 at configure time, target docs fails with a message" ID PHASE12_TEST)

# ==============================================================================
# Test 5: Doxyfile missing -> E107
# ==============================================================================

dbg(${DBG_COMMON} "Test 5: E107..." ID PHASE12_TEST)

_p12_configure("${_p12_dir}/e107" [==[{ "doxygen": { "doxyfile": "Missing.doxyfile" } }]==]
    _p12_result _p12_output)
# CMake wraps long messages, so code and file name are matched separately
if(_p12_result EQUAL 0 OR NOT _p12_output MATCHES "\\[E107\\]" OR NOT _p12_output MATCHES "Missing\\.doxyfile")
    cmake_fatal("ASSERT" "A missing Doxyfile should fail with E107 naming it (exit ${_p12_result}):\n${_p12_output}")
endif()

dbg(${DBG_COMMON} "  E107 raised, names the file" ID PHASE12_TEST)

# ==============================================================================
# Test 6: "doxyfile" missing -> E001
# ==============================================================================

dbg(${DBG_COMMON} "Test 6: E001..." ID PHASE12_TEST)

_p12_configure("${_p12_dir}/e001" [==[{ "doxygen": { "target": "docs" } }]==]
    _p12_result _p12_output)
if(_p12_result EQUAL 0 OR NOT _p12_output MATCHES "\\[E001\\][ \t\r\n]*documentation\\.doxygen: required field 'doxyfile'")
    cmake_fatal("ASSERT" "documentation.doxygen without 'doxyfile' should fail with E001 (exit ${_p12_result}):\n${_p12_output}")
endif()

dbg(${DBG_COMMON} "  E001 raised, names the field" ID PHASE12_TEST)

# ==============================================================================
# Summary
# ==============================================================================

dbg(${DBG_OFTEN} "=== Phase 12 Test PASSED ===" ID PHASE12_TEST)
enddbgblock(ID PHASE12_TEST)

set(PHASE12_TEST_PASSED TRUE CACHE BOOL "Phase 12 Test passed" FORCE)
