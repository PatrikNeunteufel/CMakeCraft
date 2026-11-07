# ==============================================================================
# Phase11.cmake – Build System Test for Library Compile Options and Source Packages
# ==============================================================================
#
# Test:         Phase 11
# Version:      1.0.0
# Date:         2026-11-07
# Part of:      CMake Architecture
#
# Description:
#   Tests (CMakeCraft v0.14.0):
#   - "compile_options" on a STATIC library (demo: CalcDemo): on the target,
#     after the defaults of apply_compiler_options
#   - INTERFACE library with "compile_options" -> E105
#   - Source package { "name", "library" } (demo: package_calcdemo): the
#     generated CMakeLists.txt keeps generator expressions verbatim and
#     carries the define of the local header external calcext
#   - Building the package: sources, headers, CMakeLists.txt, VERSION of the
#     library, SHA256SUMS that match the files, the external without its
#     Include.cmake
#   - A plain CMake project without CMakeCraft adds the unpacked package with
#     add_subdirectory, links an executable against it and runs it
#   - Source package of a library with a non-local external -> E106
#
#   Everything is written below <build>/phase11/. The nested projects use the
#   generator and compilers of this build; no network access.
#
# ==============================================================================

include_guard(GLOBAL)

dbg_init(ID PHASE11_TEST LEVEL ${DBG_SHOW_ALL} SWITCH ON TAG "Phase11")
dbg(${DBG_OFTEN} "=== Phase 11 Test Start ===" ID PHASE11_TEST)

set(_p11_dir "${CMAKE_BINARY_DIR}/phase11")
file(REMOVE_RECURSE "${_p11_dir}")
file(MAKE_DIRECTORY "${_p11_dir}")

# Generator, platform and compilers of this build for the nested projects
set(_p11_gen_args -G "${CMAKE_GENERATOR}")
if(CMAKE_GENERATOR_PLATFORM)
    list(APPEND _p11_gen_args -A "${CMAKE_GENERATOR_PLATFORM}")
endif()
if(CMAKE_GENERATOR_TOOLSET)
    list(APPEND _p11_gen_args -T "${CMAKE_GENERATOR_TOOLSET}")
endif()
if(CMAKE_MAKE_PROGRAM)
    list(APPEND _p11_gen_args "-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}")
endif()
list(APPEND _p11_gen_args
    "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}"
    "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}")
get_property(_p11_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(NOT _p11_multi_config)
    list(APPEND _p11_gen_args "-DCMAKE_BUILD_TYPE=Debug")
endif()

# Writes a minimal CMakeCraft consumer into DIR and configures it;
# OUT_RESULT / OUT_OUTPUT get exit code and combined output
function(_p11_configure_craft_project DIR SOLUTION_JSON OUT_RESULT OUT_OUTPUT)
    file(WRITE "${DIR}/CMakeLists.txt"
        "cmake_minimum_required(VERSION 3.26)\n"
        "project(Phase11Nested LANGUAGES NONE)\n"
        "include(\"${CMAKECRAFT_ROOT}/CMakeCraft.cmake\")\n")
    file(WRITE "${DIR}/Solution.json" "${SOLUTION_JSON}")
    execute_process(
        COMMAND "${CMAKE_COMMAND}" -S "${DIR}" -B "${DIR}/build" ${_p11_gen_args}
        RESULT_VARIABLE _result
        OUTPUT_VARIABLE _output
        ERROR_VARIABLE _output)
    set(${OUT_RESULT} "${_result}" PARENT_SCOPE)
    set(${OUT_OUTPUT} "${_output}" PARENT_SCOPE)
endfunction()

# ==============================================================================
# Test 1: Modules Available
# ==============================================================================

dbg(${DBG_COMMON} "Test 1: Functions..." ID PHASE11_TEST)

foreach(_p11_command IN ITEMS
        craft_language_rules
        _create_source_package_target
        _craft_target_snapshot
        _craft_record_external_effect)
    if(NOT COMMAND ${_p11_command})
        cmake_fatal("ASSERT" "${_p11_command}() is not defined")
    endif()
endforeach()

dbg(${DBG_COMMON} "  All functions defined" ID PHASE11_TEST)

if(NOT TARGET CalcDemo OR NOT TARGET package_calcdemo)
    dbg(${DBG_COMMON} "  Demo library CalcDemo or package_calcdemo not present (tests 2-5 skipped)" ID PHASE11_TEST)
    set(_p11_demo FALSE)
else()
    set(_p11_demo TRUE)
endif()

# ==============================================================================
# Test 2: compile_options on the library, after apply_compiler_options
# ==============================================================================

if(_p11_demo)
    dbg(${DBG_COMMON} "Test 2: compile_options of CalcDemo..." ID PHASE11_TEST)

    get_property(_p11_solution_json GLOBAL PROPERTY SOLUTION_JSON)
    string(JSON _p11_lib_count LENGTH "${_p11_solution_json}" "libraries")
    set(_p11_expected "")
    math(EXPR _p11_lib_last "${_p11_lib_count} - 1")
    foreach(_p11_i RANGE 0 ${_p11_lib_last})
        string(JSON _p11_lib_name GET "${_p11_solution_json}" "libraries" ${_p11_i} "name")
        if(_p11_lib_name STREQUAL "CalcDemo")
            string(JSON _p11_lib_json GET "${_p11_solution_json}" "libraries" ${_p11_i})
            _json_get_array_as_list("${_p11_lib_json}" "compile_options" _p11_expected)
        endif()
    endforeach()
    list(LENGTH _p11_expected _p11_expected_count)
    if(_p11_expected_count EQUAL 0)
        cmake_fatal("ASSERT" "CalcDemo in Solution.json has no compile_options")
    endif()

    get_target_property(_p11_options CalcDemo COMPILE_OPTIONS)
    list(LENGTH _p11_options _p11_count)
    math(EXPR _p11_tail_start "${_p11_count} - ${_p11_expected_count}")
    if(_p11_tail_start LESS 0)
        cmake_fatal("ASSERT" "CalcDemo: COMPILE_OPTIONS too short: ${_p11_options}")
    endif()
    list(SUBLIST _p11_options ${_p11_tail_start} ${_p11_expected_count} _p11_tail)
    if(NOT "${_p11_tail}" STREQUAL "${_p11_expected}")
        cmake_fatal("ASSERT" "CalcDemo: compile_options must come last (after apply_compiler_options).\n  expected tail: ${_p11_expected}\n  got: ${_p11_options}")
    endif()

    # The language rules of this compiler stand before them
    craft_language_rules(_p11_rules)
    if(MSVC)
        set(_p11_rule_options "${_p11_rules_MSVC_OPTIONS}")
    else()
        set(_p11_rule_options "${_p11_rules_GNU_OPTIONS}")
    endif()
    foreach(_p11_rule IN LISTS _p11_rule_options)
        list(FIND _p11_options "${_p11_rule}" _p11_rule_index)
        if(_p11_rule_index LESS 0 OR NOT _p11_rule_index LESS _p11_tail_start)
            cmake_fatal("ASSERT" "CalcDemo: language rule '${_p11_rule}' missing or after the library's options: ${_p11_options}")
        endif()
    endforeach()

    dbg(${DBG_COMMON} "  CalcDemo: ${_p11_expected_count} option(s) last, after ${_p11_tail_start} default(s)" ID PHASE11_TEST)
endif()

# ==============================================================================
# Test 3: Generated CMakeLists.txt of package_calcdemo
# ==============================================================================

if(_p11_demo)
    dbg(${DBG_COMMON} "Test 3: Generated CMakeLists.txt..." ID PHASE11_TEST)

    get_target_property(_p11_template package_calcdemo CRAFT_PACKAGE_CMAKELISTS)
    get_target_property(_p11_manifest package_calcdemo CRAFT_PACKAGE_MANIFEST)
    if(NOT EXISTS "${_p11_template}" OR NOT EXISTS "${_p11_manifest}")
        cmake_fatal("ASSERT" "package_calcdemo: template or manifest missing (${_p11_template}, ${_p11_manifest})")
    endif()
    file(READ "${_p11_template}" _p11_text)

    foreach(_p11_needle IN LISTS _p11_expected ITEMS
            "add_library(CalcDemo STATIC"
            "add_library(CalcDemo::CalcDemo ALIAS CalcDemo)"
            "add_library(calcext INTERFACE)"
            "CALCEXT_NO_THREADS"
            "CALC_DEMO_VERSION=\"0.3.0\""
            "target_link_libraries(CalcDemo PRIVATE calcext)"
            "@CRAFT_EXT_SHA256_calcext@")
        string(FIND "${_p11_text}" "${_p11_needle}" _p11_pos)
        if(_p11_pos LESS 0)
            cmake_fatal("ASSERT" "Generated CMakeLists.txt lacks: ${_p11_needle}")
        endif()
    endforeach()

    get_target_property(_p11_ext CalcDemo CXX_EXTENSIONS)
    if(_p11_ext MATCHES "NOTFOUND$" OR _p11_ext)
        set(_p11_ext_text "CXX_EXTENSIONS ON")
    else()
        set(_p11_ext_text "CXX_EXTENSIONS OFF")
    endif()
    string(FIND "${_p11_text}" "${_p11_ext_text}" _p11_pos)
    if(_p11_pos LESS 0)
        cmake_fatal("ASSERT" "Generated CMakeLists.txt: expected '${_p11_ext_text}' as in the solution")
    endif()

    foreach(_p11_needle IN ITEMS "CMakeCraft.cmake" "CMAKECRAFT_" "include(" "craft_language" "/W4" "/MP" "/bigobj")
        string(FIND "${_p11_text}" "${_p11_needle}" _p11_pos)
        if(NOT _p11_pos LESS 0)
            cmake_fatal("ASSERT" "Generated CMakeLists.txt must be plain CMake without '${_p11_needle}'")
        endif()
    endforeach()

    dbg(${DBG_COMMON} "  Generator expressions verbatim, external define present, ${_p11_ext_text}" ID PHASE11_TEST)
endif()

# ==============================================================================
# Test 4: Build the package (PackageBuild.cmake, output below phase11/)
# ==============================================================================

if(_p11_demo)
    dbg(${DBG_COMMON} "Test 4: Build the source package..." ID PHASE11_TEST)

    file(READ "${_p11_manifest}" _p11_manifest_text)
    string(REGEX REPLACE "set\\(CRAFT_PKG_OUT_DIR [^\n]*\\)"
        "set(CRAFT_PKG_OUT_DIR [==[${_p11_dir}/out]==])"
        _p11_manifest_text "${_p11_manifest_text}")
    file(WRITE "${_p11_dir}/manifest-source.cmake" "${_p11_manifest_text}")

    execute_process(
        COMMAND "${CMAKE_COMMAND}" "-DCRAFT_PKG_MANIFEST=${_p11_dir}/manifest-source.cmake"
                -P "${CMAKECRAFT_DIR}/project/PackageBuild.cmake"
        RESULT_VARIABLE _p11_result
        OUTPUT_VARIABLE _p11_output
        ERROR_VARIABLE _p11_output)
    if(NOT _p11_result EQUAL 0)
        cmake_fatal("ASSERT" "Building the source package failed (${_p11_result}):\n${_p11_output}")
    endif()

    set(_p11_pkg "${_p11_dir}/out/calcdemo-v0.3.0")
    foreach(_p11_file IN ITEMS
            CMakeLists.txt VERSION SHA256SUMS
            include/calc_demo.h src/calc_demo.cpp src/calc_detail.h
            externals/calcext/calcext.h externals/calcext/LICENSE.md)
        if(NOT EXISTS "${_p11_pkg}/${_p11_file}")
            cmake_fatal("ASSERT" "Source package lacks ${_p11_file}: ${_p11_pkg}")
        endif()
    endforeach()
    foreach(_p11_file IN ITEMS externals/calcext/Include.cmake src/Source.cmake)
        if(EXISTS "${_p11_pkg}/${_p11_file}")
            cmake_fatal("ASSERT" "Source package must not contain ${_p11_file}")
        endif()
    endforeach()
    if(NOT EXISTS "${_p11_dir}/out/calcdemo-v0.3.0.zip" OR NOT EXISTS "${_p11_dir}/out/calcdemo-v0.3.0.zip.sha256")
        cmake_fatal("ASSERT" "Source package: archive or its checksum missing")
    endif()

    file(READ "${_p11_pkg}/VERSION" _p11_version)
    if(NOT "${_p11_version}" STREQUAL "0.3.0\n")
        cmake_fatal("ASSERT" "VERSION should be the library version 0.3.0, got: '${_p11_version}'")
    endif()

    file(READ "${_p11_pkg}/CMakeLists.txt" _p11_text)
    if(_p11_text MATCHES "@CRAFT_EXT_SHA256_")
        cmake_fatal("ASSERT" "CMakeLists.txt in the package still has a checksum placeholder")
    endif()

    # Generated files: LF only, on every platform. Read as hex - a text read
    # would hide a CR (file(READ) on Windows) and pass a CRLF file.
    foreach(_p11_file IN ITEMS
            "${_p11_pkg}/CMakeLists.txt" "${_p11_pkg}/VERSION" "${_p11_pkg}/SHA256SUMS"
            "${_p11_dir}/out/calcdemo-v0.3.0.zip.sha256")
        file(READ "${_p11_file}" _p11_hex HEX)
        if(_p11_hex MATCHES "^(..)*0d")
            cmake_fatal("ASSERT" "Generated file has CR (must be LF only): ${_p11_file}")
        endif()
    endforeach()

    # SHA256SUMS: every file once, hashes match, sorted
    file(STRINGS "${_p11_pkg}/SHA256SUMS" _p11_lines)
    file(GLOB_RECURSE _p11_all RELATIVE "${_p11_pkg}" LIST_DIRECTORIES false "${_p11_pkg}/*")
    list(REMOVE_ITEM _p11_all "SHA256SUMS")
    list(SORT _p11_all)
    set(_p11_listed "")
    foreach(_p11_line IN LISTS _p11_lines)
        if(NOT _p11_line MATCHES "^([0-9a-f]+)  (.+)$")
            cmake_fatal("ASSERT" "SHA256SUMS: line not in sha256sum format: ${_p11_line}")
        endif()
        set(_p11_hash "${CMAKE_MATCH_1}")
        set(_p11_rel "${CMAKE_MATCH_2}")
        file(SHA256 "${_p11_pkg}/${_p11_rel}" _p11_actual)
        if(NOT _p11_actual STREQUAL _p11_hash)
            cmake_fatal("ASSERT" "SHA256SUMS: wrong checksum for ${_p11_rel}")
        endif()
        list(APPEND _p11_listed "${_p11_rel}")
    endforeach()
    if(NOT "${_p11_listed}" STREQUAL "${_p11_all}")
        cmake_fatal("ASSERT" "SHA256SUMS must list every file once, sorted.\n  listed: ${_p11_listed}\n  files:  ${_p11_all}")
    endif()

    list(LENGTH _p11_listed _p11_file_count)
    dbg(${DBG_COMMON} "  ${_p11_file_count} files, VERSION 0.3.0, SHA256SUMS match" ID PHASE11_TEST)
endif()

# ==============================================================================
# Test 5: Plain CMake project without CMakeCraft consumes the package
# ==============================================================================

if(_p11_demo)
    dbg(${DBG_COMMON} "Test 5: Plain CMake consumer..." ID PHASE11_TEST)

    set(_p11_consumer "${_p11_dir}/consumer")
    list(GET _p11_expected 0 _p11_first_option)
    file(WRITE "${_p11_consumer}/CMakeLists.txt"
        "cmake_minimum_required(VERSION 3.26)\n"
        "project(Phase11Consumer LANGUAGES CXX)\n"
        "add_subdirectory([==[${_p11_pkg}]==] calcdemo)\n"
        "add_executable(p11_consumer main.cpp)\n"
        "target_link_libraries(p11_consumer PRIVATE CalcDemo::CalcDemo)\n"
        "set_target_properties(p11_consumer PROPERTIES\n"
        "    RUNTIME_OUTPUT_DIRECTORY \"\${CMAKE_BINARY_DIR}/bin\"\n"
        "    RUNTIME_OUTPUT_DIRECTORY_DEBUG \"\${CMAKE_BINARY_DIR}/bin\")\n"
        "get_target_property(_options CalcDemo COMPILE_OPTIONS)\n"
        "list(FIND _options [==[${_p11_first_option}]==] _index)\n"
        "if(_index LESS 0)\n"
        "    message(FATAL_ERROR \"option of the library missing on target CalcDemo: \${_options}\")\n"
        "endif()\n")
    file(WRITE "${_p11_consumer}/main.cpp"
        "#include <calc_demo.h>\n"
        "#include <cstdio>\n"
        "int main()\n"
        "{\n"
        "    if (calc_demo::external_marker() != 42) return 1;\n"
        "    // 0.1 * 10 rounds to exactly 1.0; fused it would leave 5.55e-17\n"
        "    const double r = calc_demo::mul_add(0.1, 10.0, -1.0);\n"
        "    std::printf(\"calc_demo %g\\n\", r);\n"
        "    return r == 0.0 ? 0 : 2;\n"
        "}\n")

    execute_process(
        COMMAND "${CMAKE_COMMAND}" -S "${_p11_consumer}" -B "${_p11_consumer}/build" ${_p11_gen_args}
        RESULT_VARIABLE _p11_result
        OUTPUT_VARIABLE _p11_output
        ERROR_VARIABLE _p11_output)
    if(NOT _p11_result EQUAL 0)
        cmake_fatal("ASSERT" "Plain consumer: configure failed (${_p11_result}):\n${_p11_output}")
    endif()

    execute_process(
        COMMAND "${CMAKE_COMMAND}" --build "${_p11_consumer}/build" --config Debug
        RESULT_VARIABLE _p11_result
        OUTPUT_VARIABLE _p11_output
        ERROR_VARIABLE _p11_output)
    if(NOT _p11_result EQUAL 0)
        cmake_fatal("ASSERT" "Plain consumer: build failed (${_p11_result}):\n${_p11_output}")
    endif()

    execute_process(
        COMMAND "${_p11_consumer}/build/bin/p11_consumer${CMAKE_EXECUTABLE_SUFFIX}"
        RESULT_VARIABLE _p11_result
        OUTPUT_VARIABLE _p11_output
        ERROR_VARIABLE _p11_output)
    if(NOT _p11_result EQUAL 0 OR NOT _p11_output MATCHES "calc_demo 0")
        cmake_fatal("ASSERT" "Plain consumer: run failed (${_p11_result}): ${_p11_output}")
    endif()

    string(STRIP "${_p11_output}" _p11_output)
    dbg(${DBG_COMMON} "  Configured, built and ran without CMakeCraft: ${_p11_output}" ID PHASE11_TEST)
endif()

# ==============================================================================
# Test 6: INTERFACE library with compile_options -> E105
# ==============================================================================

dbg(${DBG_COMMON} "Test 6: E105..." ID PHASE11_TEST)

_p11_configure_craft_project("${_p11_dir}/e105" [==[
{
    "schemaVersion": "1.0",
    "solution": { "name": "Phase11E105", "version": "0.1.0" },
    "settings": { "standards": { "cxx_standard": 20 }, "sources": { "mode": "explicit" } },
    "externals": {},
    "libraries": [
        { "name": "HeaderOnly", "type": "INTERFACE", "path": "lib",
          "compile_options": [ "-ffp-contract=off" ] }
    ]
}
]==] _p11_result _p11_output)
if(_p11_result EQUAL 0 OR NOT _p11_output MATCHES "\\[E105\\]")
    cmake_fatal("ASSERT" "INTERFACE library with compile_options should fail with E105 (exit ${_p11_result}):\n${_p11_output}")
endif()

dbg(${DBG_COMMON} "  E105 raised" ID PHASE11_TEST)

# ==============================================================================
# Test 7: Source package with a non-local external -> E106
# ==============================================================================

dbg(${DBG_COMMON} "Test 7: E106..." ID PHASE11_TEST)

file(WRITE "${_p11_dir}/e106/lib/src/Source.cmake"
    "set(\${TARGET_NAME}_SOURCES \"\${CMAKE_CURRENT_LIST_DIR}/calc.cpp\")\n")
file(WRITE "${_p11_dir}/e106/lib/src/calc.cpp" "int phase11_calc() { return 1; }\n")
_p11_configure_craft_project("${_p11_dir}/e106" [==[
{
    "schemaVersion": "1.0",
    "solution": { "name": "Phase11E106", "version": "0.1.0" },
    "settings": { "standards": { "cxx_standard": 20 }, "sources": { "mode": "explicit" } },
    "externals": {
        "threads": { "system": true, "package": "Threads" }
    },
    "libraries": [
        { "name": "Calc", "type": "STATIC", "path": "lib/src", "externals": [ "threads" ] }
    ],
    "packages": [
        { "name": "calc", "library": "Calc" }
    ]
}
]==] _p11_result _p11_output)
if(_p11_result EQUAL 0 OR NOT _p11_output MATCHES "\\[E106\\][^\n]*threads")
    cmake_fatal("ASSERT" "Source package with a system external should fail with E106 naming it (exit ${_p11_result}):\n${_p11_output}")
endif()

dbg(${DBG_COMMON} "  E106 raised, names the external" ID PHASE11_TEST)

# ==============================================================================
# Summary
# ==============================================================================

dbg(${DBG_OFTEN} "=== Phase 11 Test PASSED ===" ID PHASE11_TEST)
enddbgblock(ID PHASE11_TEST)

set(PHASE11_TEST_PASSED TRUE CACHE BOOL "Phase 11 Test passed" FORCE)
