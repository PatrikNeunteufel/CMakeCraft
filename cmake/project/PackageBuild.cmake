# cmake/project/PackageBuild.cmake
# =================================
# Build-time script of the target package_<name> (run via cmake -P)
#
# Version: 1.1.0
# Date:    2026-11-07
# Status:  Release
# Author:  CMake Architecture Team
#
# Dependencies:
#   - None (script mode; reads the manifest written by Packages.cmake or
#     SourcePackage.cmake)
#
# Usage:
#   cmake -DCRAFT_PKG_MANIFEST=<manifest.cmake> -P PackageBuild.cmake
#
# Stages the package folder, writes the archive and its checksum.
# The folder is rebuilt from scratch on every run.
# A source package (CRAFT_PKG_KIND "source") additionally gets its
# CMakeLists.txt, VERSION and SHA256SUMS over every file of the folder.

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
# Source package of a library (SourcePackage.cmake)
# ------------------------------------------------------------------------------

# Writes CONTENT to FILE with LF line ends on every platform. file(WRITE)
# writes CRLF on Windows, which would make a package differ from the same
# package built under Linux and break "sha256sum -c". file(CONFIGURE) knows
# NEWLINE_STYLE; every "@" is masked so @ONLY replaces nothing of CONTENT.
function(_craft_pkg_write_lf FILE CONTENT)
    string(REPLACE "@" "@_CRAFT_PKG_AT@" _content "${CONTENT}")
    set(_CRAFT_PKG_AT "@")
    file(CONFIGURE OUTPUT "${FILE}" CONTENT "${_content}" @ONLY NEWLINE_STYLE LF)
endfunction()

# SHA256 over every file below DIR, sorted, one line "<hash>  <path>" (LF);
# OUT_LINES gets the lines, OUT_HASH the hash of the lines
function(_craft_pkg_sums DIR OUT_LINES OUT_HASH)
    file(GLOB_RECURSE _all RELATIVE "${DIR}" LIST_DIRECTORIES false "${DIR}/*")
    list(REMOVE_ITEM _all "SHA256SUMS")
    list(SORT _all)
    set(_lines "")
    foreach(_rel IN LISTS _all)
        file(SHA256 "${DIR}/${_rel}" _hash)
        string(APPEND _lines "${_hash}  ${_rel}\n")
    endforeach()
    string(SHA256 _sum "${_lines}")
    set(${OUT_LINES} "${_lines}" PARENT_SCOPE)
    set(${OUT_HASH} "${_sum}" PARENT_SCOPE)
endfunction()

if("${CRAFT_PKG_KIND}" STREQUAL "source")
    # Files of the library, one by one
    list(LENGTH CRAFT_PKG_COPY_SRC _count)
    if(_count GREATER 0)
        math(EXPR _last "${_count} - 1")
        foreach(_i RANGE 0 ${_last})
            list(GET CRAFT_PKG_COPY_SRC ${_i} _src)
            list(GET CRAFT_PKG_COPY_DST ${_i} _dst)
            if(NOT EXISTS "${_src}")
                message(FATAL_ERROR "[Package] '${CRAFT_PKG_NAME}': file not found: ${_src}")
            endif()
            get_filename_component(_dst_dir "${_stage}/${_dst}" DIRECTORY)
            file(MAKE_DIRECTORY "${_dst_dir}")
            file(COPY_FILE "${_src}" "${_stage}/${_dst}")
        endforeach()
    endif()

    # Folders: public headers, externals (minus their Include.cmake)
    list(LENGTH CRAFT_PKG_DIR_SRC _count)
    if(_count GREATER 0)
        math(EXPR _last "${_count} - 1")
        foreach(_i RANGE 0 ${_last})
            list(GET CRAFT_PKG_DIR_SRC ${_i} _src)
            list(GET CRAFT_PKG_DIR_DST ${_i} _dst)
            list(GET CRAFT_PKG_DIR_DROP ${_i} _drop)
            if(NOT IS_DIRECTORY "${_src}")
                message(FATAL_ERROR "[Package] '${CRAFT_PKG_NAME}': folder not found: ${_src}")
            endif()
            file(MAKE_DIRECTORY "${_stage}/${_dst}")
            file(COPY "${_src}/" DESTINATION "${_stage}/${_dst}")
            if(NOT "${_drop}" STREQUAL "-")
                file(REMOVE "${_stage}/${_dst}/${_drop}")
            endif()
        endforeach()
    endif()

    # CMakeLists.txt with the checksum of each external's folder
    file(READ "${CRAFT_PKG_CMAKELISTS}" _cmakelists)
    foreach(_ext IN LISTS CRAFT_PKG_HASH_NAMES)
        _craft_pkg_sums("${_stage}/externals/${_ext}" _unused _ext_hash)
        string(REPLACE "@CRAFT_EXT_SHA256_${_ext}@" "${_ext_hash}" _cmakelists "${_cmakelists}")
    endforeach()
    _craft_pkg_write_lf("${_stage}/CMakeLists.txt" "${_cmakelists}")

    _craft_pkg_write_lf("${_stage}/VERSION" "${CRAFT_PKG_LIB_VERSION}\n")

    # Checksums of every file of the folder (the receiver keeps it unpacked)
    _craft_pkg_sums("${_stage}" _sums _unused)
    _craft_pkg_write_lf("${_stage}/SHA256SUMS" "${_sums}")
    set(CRAFT_PKG_ITEMS "")
endif()

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
_craft_pkg_write_lf("${_zip}.sha256" "${_hash}  ${CRAFT_PKG_ARCHIVE}.zip\n")

message(STATUS "[Package] ${CRAFT_PKG_NAME}: ${_zip}")
message(STATUS "[Package] SHA256: ${_hash}")
