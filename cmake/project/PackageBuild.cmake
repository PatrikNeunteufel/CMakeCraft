# cmake/project/PackageBuild.cmake
# =================================
# Build-time script of the target package_<name> (run via cmake -P)
#
# Version: 1.0.0
# Date:    2026-10-09
# Status:  Release
# Author:  CMake Architecture Team
#
# Dependencies:
#   - None (script mode; reads the manifest written by Packages.cmake)
#
# Usage:
#   cmake -DCRAFT_PKG_MANIFEST=<manifest.cmake> -P PackageBuild.cmake
#
# Stages the package folder, writes the archive and its checksum.
# The folder is rebuilt from scratch on every run.

if(NOT DEFINED CRAFT_PKG_MANIFEST OR NOT EXISTS "${CRAFT_PKG_MANIFEST}")
    message(FATAL_ERROR "[Package] manifest not found: ${CRAFT_PKG_MANIFEST}")
endif()
include("${CRAFT_PKG_MANIFEST}")

if("${CRAFT_PKG_ARCHIVE}" STREQUAL "" OR "${CRAFT_PKG_OUT_DIR}" STREQUAL "")
    message(FATAL_ERROR "[Package] manifest is incomplete: ${CRAFT_PKG_MANIFEST}")
endif()

if(NOT "${CRAFT_PKG_REQUIRED_CONFIG}" STREQUAL "" AND
   NOT "${CRAFT_PKG_CONFIG}" STREQUAL "${CRAFT_PKG_REQUIRED_CONFIG}")
    message(FATAL_ERROR
        "[Package] '${CRAFT_PKG_NAME}' is built from configuration "
        "'${CRAFT_PKG_REQUIRED_CONFIG}' only - this build is '${CRAFT_PKG_CONFIG}'.")
endif()

set(_stage "${CRAFT_PKG_OUT_DIR}/${CRAFT_PKG_ARCHIVE}")
set(_zip   "${CRAFT_PKG_OUT_DIR}/${CRAFT_PKG_ARCHIVE}.zip")

file(REMOVE_RECURSE "${_stage}")
file(REMOVE "${_zip}" "${_zip}.sha256")
file(MAKE_DIRECTORY "${_stage}")

# ------------------------------------------------------------------------------
# Contents
# ------------------------------------------------------------------------------

foreach(_i IN LISTS CRAFT_PKG_ITEMS)
    set(_kind    "${CRAFT_PKG_ITEM_${_i}_KIND}")
    set(_src     "${CRAFT_PKG_ITEM_${_i}_SRC}")
    set(_dst     "${_stage}/${CRAFT_PKG_ITEM_${_i}_TO}")

    if(_kind STREQUAL "files")
        foreach(_file IN LISTS CRAFT_PKG_ITEM_${_i}_FILES)
            if(NOT EXISTS "${_src}/${_file}")
                message(FATAL_ERROR "[Package] '${CRAFT_PKG_NAME}': file not found: ${_src}/${_file}")
            endif()
            get_filename_component(_sub "${_file}" DIRECTORY)
            file(COPY "${_src}/${_file}" DESTINATION "${_dst}/${_sub}")
        endforeach()
    elseif(_kind STREQUAL "file")
        if(NOT EXISTS "${_src}")
            message(FATAL_ERROR "[Package] '${CRAFT_PKG_NAME}': file not found: ${_src}")
        endif()
        file(COPY "${_src}" DESTINATION "${_dst}")
    else()
        if(NOT IS_DIRECTORY "${_src}")
            message(FATAL_ERROR "[Package] '${CRAFT_PKG_NAME}': folder not found: ${_src}")
        endif()
        set(_patterns "")
        foreach(_pattern IN LISTS CRAFT_PKG_ITEM_${_i}_EXCLUDE)
            list(APPEND _patterns PATTERN "${_pattern}" EXCLUDE)
        endforeach()
        file(COPY "${_src}/" DESTINATION "${_dst}" ${_patterns})
    endif()
endforeach()

if(NOT "${CRAFT_PKG_VERSION_FILE}" STREQUAL "")
    file(COPY_FILE "${CRAFT_PKG_VERSION_FILE}" "${_stage}/VERSION")
endif()

# ------------------------------------------------------------------------------
# Archive (one top-level folder) and checksum
# ------------------------------------------------------------------------------

execute_process(
    COMMAND "${CMAKE_COMMAND}" -E tar cf "${_zip}" --format=zip -- "${CRAFT_PKG_ARCHIVE}"
    WORKING_DIRECTORY "${CRAFT_PKG_OUT_DIR}"
    RESULT_VARIABLE _result)
if(NOT _result EQUAL 0)
    message(FATAL_ERROR "[Package] '${CRAFT_PKG_NAME}': writing the archive failed (${_result}): ${_zip}")
endif()

file(SHA256 "${_zip}" _hash)
file(WRITE "${_zip}.sha256" "${_hash}  ${CRAFT_PKG_ARCHIVE}.zip\n")

message(STATUS "[Package] ${CRAFT_PKG_NAME}: ${_zip}")
message(STATUS "[Package] SHA256: ${_hash}")
