# cmake/externals/archive/Handler.cmake
# =====================================
# Archive externals - prebuilt packages fetched in a pinned version
#
# Version: 1.1.0
# Date:    2026-10-09
# Status:  Release
# Author:  CMake Architecture Team
#
# Dependencies:
#   - cmake/core/Errors.cmake
#   - cmake/core/Debug.cmake
#   - cmake/core/Json.cmake
#   - CMakeCraftPackage.cmake (repo root; standalone fetch and deploy logic)
#
# Provides:
#   - _handle_archive_external(EXT_NAME EXT_JSON)
#   - _apply_archive_external_to_target(TARGET_NAME EXT_NAME EXT_JSON EXT_OPTIONS)
#
# JSON fields of an archive external:
#   archive      - Mandatory: true
#   pin          - Mandatory: pin file, relative to the project root
#                  (variables: see CMakeCraftPackage.cmake)
#   platforms    - Optional: array of windows|linux|macos|unix; on any other
#                  platform the external is absent
#   include_dirs - Optional: include directories inside the package
#   define       - Optional: compile definition <define>=1 on each target
#   runtime      - Optional: { "files": [...], "dirs": [...] } copied next to
#                  each executable that names the external, by the target
#                  <executable>_deploy_<external> on every build
#
# Per target (external_options): { "runtime": false } - no copies
#
# An archive external that cannot be obtained is absent: W304 at configure,
# targets get neither include path nor define nor copies.
#
# Used by:
#   - Orchestrator.cmake

include_guard(GLOBAL)

include("${CMAKECRAFT_ROOT}/CMakeCraftPackage.cmake")

# ============================================================================
# _handle_archive_external - Fetches the package, remembers its root
# ============================================================================
#[[
    _handle_archive_external(EXT_NAME EXT_JSON)

    Parameters:
        EXT_NAME - Mandatory: Name of the external (prefix of the pin variables
                   and of -D<NAME>_LOCAL_DIR, upper-case)
        EXT_JSON - Mandatory: JSON definition of the external

    Sets:
        GLOBAL PROPERTY ARCHIVE_EXTERNAL_<name>_ROOT - package root, or ""

    Errors:
        E220 - 'pin' field missing
]]
function(_handle_archive_external EXT_NAME EXT_JSON)

    set_property(GLOBAL PROPERTY ARCHIVE_EXTERNAL_${EXT_NAME}_ROOT "")

    _json_get_string("${EXT_JSON}" "pin" _pin)
    if("${_pin}" STREQUAL "")
        cmake_fatal("E220"
            "Archive external '${EXT_NAME}': 'pin' field is required.\n"
            "  Example: { \"archive\": true, \"pin\": \"${EXT_NAME}.pin\" }")
    endif()

    # --------------------------------------------------------------------------
    # Platform filter
    # --------------------------------------------------------------------------

    _json_get_array_as_list("${EXT_JSON}" "platforms" _platforms)
    if(_platforms)
        set(_platform_match FALSE)
        foreach(_platform IN LISTS _platforms)
            string(TOLOWER "${_platform}" _platform)
            if((_platform STREQUAL "windows" AND WIN32) OR
               (_platform STREQUAL "linux" AND CMAKE_SYSTEM_NAME STREQUAL "Linux") OR
               (_platform STREQUAL "macos" AND APPLE) OR
               (_platform STREQUAL "unix" AND UNIX))
                set(_platform_match TRUE)
            endif()
        endforeach()
        if(NOT _platform_match)
            dbg(${DBG_COMMON} "  Archive external '${EXT_NAME}': not for this platform (${_platforms})" ID EXTERNALS)
            return()
        endif()
    endif()

    # --------------------------------------------------------------------------
    # Fetch (override -> cache -> download -> fallback paths)
    # --------------------------------------------------------------------------

    craft_package_fetch(
        NAME     "${EXT_NAME}"
        PIN_FILE "${CMAKE_SOURCE_DIR}/${_pin}"
        OUT_ROOT _root
    )

    set_property(GLOBAL PROPERTY ARCHIVE_EXTERNAL_${EXT_NAME}_ROOT "${_root}")

    if("${_root}" STREQUAL "")
        cmake_warn("W304" "Archive external '${EXT_NAME}' is not available - targets build without it")
    else()
        dbg(${DBG_COMMON} "  Archive external '${EXT_NAME}': ${_root}" ID EXTERNALS)
    endif()

endfunction()

# ============================================================================
# _apply_archive_external_to_target - Include path, define, runtime copies
# ============================================================================
#[[
    _apply_archive_external_to_target(TARGET_NAME EXT_NAME EXT_JSON EXT_OPTIONS)

    Parameters:
        TARGET_NAME - Mandatory: CMake target
        EXT_NAME    - Mandatory: Name of the external
        EXT_JSON    - Mandatory: JSON definition of the external
        EXT_OPTIONS - Mandatory: JSON options of this target for the external
]]
function(_apply_archive_external_to_target TARGET_NAME EXT_NAME EXT_JSON EXT_OPTIONS)

    get_property(_root GLOBAL PROPERTY ARCHIVE_EXTERNAL_${EXT_NAME}_ROOT)

    _json_get_array_as_list("${EXT_JSON}" "include_dirs" _include_dirs)
    _json_get_string_or_default("${EXT_JSON}" "define" "" _define)

    _json_get_object_or_empty("${EXT_JSON}" "runtime" _runtime)
    _json_get_array_as_list("${_runtime}" "files" _runtime_files)
    _json_get_array_as_list("${_runtime}" "dirs" _runtime_dirs)

    set(_no_runtime "")
    _json_get_bool_or_default("${EXT_OPTIONS}" "runtime" TRUE _want_runtime)
    if(NOT _want_runtime)
        set(_no_runtime NO_RUNTIME)
    endif()

    craft_package_deploy(
        TARGET        "${TARGET_NAME}"
        NAME          "${EXT_NAME}"
        ROOT         "${_root}"
        INCLUDE_DIRS  ${_include_dirs}
        DEFINE        "${_define}"
        RUNTIME_FILES ${_runtime_files}
        RUNTIME_DIRS  ${_runtime_dirs}
        ${_no_runtime}
    )

endfunction()
