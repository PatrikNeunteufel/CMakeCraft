# ==============================================================================
# Phase10.cmake – Build System Test for Packages and Archive Externals
# ==============================================================================
#
# Test:         Phase 10
# Version:      1.0.0
# Date:         2026-10-09
# Part of:      CMake Architecture
#
# Description:
#   Tests building and consuming prebuilt packages:
#   - "packages" block → target package_<name> (demo: package_packdemo)
#   - Library fields "output_name" and "defines" with {version}
#   - CMakeCraftPackage.cmake: fetch from a file:// URL, from a fallback path,
#     from the cache; rejection of a wrong checksum is NOT exercised here
#     (it is a warning by design and would clutter the selftest output)
#   - External kind "archive": handler and application to a target
#
#   The test writes a miniature package below <build>/phase10/ and fetches it
#   from there. No network access, nothing is written into the source tree.
#
# ==============================================================================

include_guard(GLOBAL)

dbg_init(ID PHASE10_TEST LEVEL ${DBG_SHOW_ALL} SWITCH ON TAG "Phase10")
dbg(${DBG_OFTEN} "=== Phase 10 Test Start ===" ID PHASE10_TEST)

# ==============================================================================
# Test 1: Modules Available
# ==============================================================================

dbg(${DBG_COMMON} "Test 1: Package modules..." ID PHASE10_TEST)

foreach(_p10_command IN ITEMS
        craft_package_fetch
        craft_package_deploy
        _create_package_target
        _handle_archive_external
        _apply_archive_external_to_target)
    if(NOT COMMAND ${_p10_command})
        cmake_fatal("ASSERT" "${_p10_command}() is not defined")
    endif()
endforeach()

dbg(${DBG_COMMON} "  CMakeCraftPackage.cmake v${CMAKECRAFT_PACKAGE_VERSION}" ID PHASE10_TEST)

# ==============================================================================
# Test 2: Library output_name and defines (demo library PackDemo)
# ==============================================================================

dbg(${DBG_COMMON} "Test 2: output_name and defines..." ID PHASE10_TEST)

if(TARGET PackDemo)
    get_target_property(_p10_output_name PackDemo OUTPUT_NAME)
    if(NOT "${_p10_output_name}" STREQUAL "PackDemo1")
        cmake_fatal("ASSERT" "PackDemo: OUTPUT_NAME should be 'PackDemo1', got: ${_p10_output_name}")
    endif()

    get_target_property(_p10_defines PackDemo COMPILE_DEFINITIONS)
    if(NOT "${_p10_defines}" MATCHES "PACK_DEMO_VERSION=\"1\\.2\\.0\"")
        cmake_fatal("ASSERT" "PackDemo: {version} not replaced in defines, got: ${_p10_defines}")
    endif()

    dbg(${DBG_COMMON} "  PackDemo: OUTPUT_NAME=${_p10_output_name}, defines=${_p10_defines}" ID PHASE10_TEST)
else()
    dbg(${DBG_COMMON} "  Demo library PackDemo not present (skipped)" ID PHASE10_TEST)
endif()

# ==============================================================================
# Test 3: Package Target (demo package packdemo)
# ==============================================================================

dbg(${DBG_COMMON} "Test 3: Package target..." ID PHASE10_TEST)

get_property(_p10_solution_json GLOBAL PROPERTY SOLUTION_JSON)
_json_array_length("${_p10_solution_json}" "packages" _p10_pkg_count)

if(_p10_pkg_count GREATER 0 AND TARGET PackDemo)
    if(NOT TARGET package_packdemo)
        cmake_fatal("ASSERT" "Target 'package_packdemo' was not created")
    endif()

    get_target_property(_p10_pkg_deps package_packdemo MANUALLY_ADDED_DEPENDENCIES)
    if(NOT "PackDemo" IN_LIST _p10_pkg_deps)
        cmake_fatal("ASSERT" "package_packdemo should depend on PackDemo, got: ${_p10_pkg_deps}")
    endif()

    get_property(_p10_solution_version GLOBAL PROPERTY SOLUTION_VERSION)
    file(STRINGS "${CMAKE_BINARY_DIR}/package/packdemo/VERSION" _p10_version_line REGEX "^produkt=")
    if(NOT "${_p10_version_line}" STREQUAL "produkt=${_p10_solution_version}")
        cmake_fatal("ASSERT" "packdemo: version_file not configured, got: ${_p10_version_line}")
    endif()

    dbg(${DBG_COMMON} "  package_packdemo exists, depends on PackDemo, ${_p10_version_line}" ID PHASE10_TEST)
else()
    dbg(${DBG_COMMON} "  No demo package defined (skipped)" ID PHASE10_TEST)
endif()

# ==============================================================================
# Test 4: Fetch a miniature package (file:// URL, then cache)
# ==============================================================================

dbg(${DBG_COMMON} "Test 4: Fetch from URL and cache..." ID PHASE10_TEST)

set(_p10_dir "${CMAKE_BINARY_DIR}/phase10")
file(REMOVE_RECURSE "${_p10_dir}")

# Miniature package: one header and the file VERSION
set(_p10_archive "phase10demo-v1.2.3")
file(WRITE "${_p10_dir}/source/${_p10_archive}/include/phase10_demo.h" "#define PHASE10_DEMO 1\n")
file(WRITE "${_p10_dir}/source/${_p10_archive}/tools/readme.txt" "phase 10\n")
file(WRITE "${_p10_dir}/source/${_p10_archive}/VERSION" "produkt=1.2.3\n")

execute_process(
    COMMAND "${CMAKE_COMMAND}" -E tar cf "${_p10_dir}/source/${_p10_archive}.zip" --format=zip -- "${_p10_archive}"
    WORKING_DIRECTORY "${_p10_dir}/source"
    RESULT_VARIABLE _p10_result)
if(NOT _p10_result EQUAL 0)
    cmake_fatal("ASSERT" "Could not write the miniature package (${_p10_result})")
endif()
file(SHA256 "${_p10_dir}/source/${_p10_archive}.zip" _p10_hash)

file(WRITE "${_p10_dir}/url/phase10demo.pin"
    "set(PHASE10DEMO_VERSION \"v1.2.3\")\n"
    "set(PHASE10DEMO_URL \"file:///${_p10_dir}/source/${_p10_archive}.zip\")\n"
    "set(PHASE10DEMO_SHA256 \"${_p10_hash}\")\n")

craft_package_fetch(NAME phase10demo PIN_FILE "${_p10_dir}/url/phase10demo.pin" OUT_ROOT _p10_root)

if("${_p10_root}" STREQUAL "")
    cmake_fatal("ASSERT" "Fetch from file:// URL failed")
endif()
if(NOT "${_p10_root}" STREQUAL "${_p10_dir}/url/.externals/phase10demo/v1.2.3")
    cmake_fatal("ASSERT" "Unexpected cache location: ${_p10_root}")
endif()
if(NOT EXISTS "${_p10_root}/include/phase10_demo.h" OR NOT EXISTS "${_p10_root}/VERSION")
    cmake_fatal("ASSERT" "Fetched package is incomplete: ${_p10_root}")
endif()

# Second fetch must come from the cache: the source archive is gone
file(RENAME "${_p10_dir}/source/${_p10_archive}.zip" "${_p10_dir}/source/moved.zip")
craft_package_fetch(NAME phase10demo PIN_FILE "${_p10_dir}/url/phase10demo.pin" OUT_ROOT _p10_root_cached)
file(RENAME "${_p10_dir}/source/moved.zip" "${_p10_dir}/source/${_p10_archive}.zip")

if(NOT "${_p10_root_cached}" STREQUAL "${_p10_root}")
    cmake_fatal("ASSERT" "Second fetch did not use the cache: '${_p10_root_cached}'")
endif()

dbg(${DBG_COMMON} "  Fetched and cached: ${_p10_root}" ID PHASE10_TEST)

# ==============================================================================
# Test 5: Archive External (handler with fallback path, CACHE in <build>)
# ==============================================================================

dbg(${DBG_COMMON} "Test 5: Archive external via fallback path..." ID PHASE10_TEST)

# No URL host to reach: the archive name comes from the URL, the file from
# the fallback path.
file(WRITE "${_p10_dir}/fallback/phase10demo.pin"
    "set(PHASE10DEMO_VERSION \"v1.2.3\")\n"
    "set(PHASE10DEMO_URL \"file:///${_p10_dir}/nowhere/${_p10_archive}.zip\")\n"
    "set(PHASE10DEMO_SHA256 \"${_p10_hash}\")\n"
    "set(PHASE10DEMO_FALLBACK_PATHS \"../source\")\n")

file(RELATIVE_PATH _p10_pin_rel "${CMAKE_SOURCE_DIR}" "${_p10_dir}/fallback/phase10demo.pin")

set(_p10_ext_json "{
    \"archive\": true,
    \"pin\": \"${_p10_pin_rel}\",
    \"include_dirs\": [\"include\"],
    \"define\": \"PHASE10_DEMO_VORHANDEN\",
    \"runtime\": { \"files\": [\"VERSION\"], \"dirs\": [\"tools\"] }
}")

validate_external_source("phase10demo" "${_p10_ext_json}")
_handle_archive_external("phase10demo" "${_p10_ext_json}")

get_property(_p10_ext_root GLOBAL PROPERTY ARCHIVE_EXTERNAL_phase10demo_ROOT)
if(NOT "${_p10_ext_root}" STREQUAL "${_p10_dir}/fallback/.externals/phase10demo/v1.2.3")
    cmake_fatal("ASSERT" "Archive external not fetched via fallback path, root: '${_p10_ext_root}'")
endif()

dbg(${DBG_COMMON} "  Root: ${_p10_ext_root}" ID PHASE10_TEST)

# ==============================================================================
# Test 6: Apply to a Target (include path and define; absent package)
# ==============================================================================

dbg(${DBG_COMMON} "Test 6: Apply archive external to a target..." ID PHASE10_TEST)

if(NOT TARGET _craft_phase10_probe)
    add_library(_craft_phase10_probe INTERFACE)
    add_library(_craft_phase10_absent INTERFACE)
endif()

_apply_archive_external_to_target(_craft_phase10_probe "phase10demo" "${_p10_ext_json}" "{}")

get_target_property(_p10_includes _craft_phase10_probe INTERFACE_INCLUDE_DIRECTORIES)
get_target_property(_p10_probe_defines _craft_phase10_probe INTERFACE_COMPILE_DEFINITIONS)

if(NOT "${_p10_ext_root}/include" IN_LIST _p10_includes)
    cmake_fatal("ASSERT" "Include path of the archive external missing, got: ${_p10_includes}")
endif()
if(NOT "PHASE10_DEMO_VORHANDEN=1" IN_LIST _p10_probe_defines)
    cmake_fatal("ASSERT" "Define of the archive external missing, got: ${_p10_probe_defines}")
endif()

# Absent package: neither include path nor define
craft_package_deploy(TARGET _craft_phase10_absent ROOT ""
    INCLUDE_DIRS include DEFINE PHASE10_DEMO_VORHANDEN)

get_target_property(_p10_absent_includes _craft_phase10_absent INTERFACE_INCLUDE_DIRECTORIES)
get_target_property(_p10_absent_defines _craft_phase10_absent INTERFACE_COMPILE_DEFINITIONS)
if(_p10_absent_includes OR _p10_absent_defines)
    cmake_fatal("ASSERT" "Absent package must not touch the target, got: ${_p10_absent_includes} / ${_p10_absent_defines}")
endif()

dbg(${DBG_COMMON} "  Include path and define set; absent package leaves the target untouched" ID PHASE10_TEST)

# ==============================================================================
# Summary
# ==============================================================================

dbgspace(ID PHASE10_TEST)
dbg(${DBG_OFTEN} "=== Phase 10 Test PASSED ===" ID PHASE10_TEST)
enddbgblock(ID PHASE10_TEST)

set(PHASE10_TEST_PASSED TRUE CACHE BOOL "Phase 10 Test passed" FORCE)

# ==============================================================================
# Cleanup
# ==============================================================================

unset(_p10_command)
unset(_p10_output_name)
unset(_p10_defines)
unset(_p10_solution_json)
unset(_p10_pkg_count)
unset(_p10_pkg_deps)
unset(_p10_solution_version)
unset(_p10_version_line)
unset(_p10_dir)
unset(_p10_archive)
unset(_p10_result)
unset(_p10_hash)
unset(_p10_root)
unset(_p10_root_cached)
unset(_p10_pin_rel)
unset(_p10_ext_json)
unset(_p10_ext_root)
unset(_p10_includes)
unset(_p10_probe_defines)
unset(_p10_absent_includes)
unset(_p10_absent_defines)
