# ==============================================================================
# CMakeCraftPackage.cmake – fetch and deploy a prebuilt package (standalone)
# ==============================================================================
#
# Project:      CMakeCraft (CMake Architecture V2)
# Version:      1.1.0   (version of THIS file, independent of CMakeCraft's own)
# Date:         2026-10-09
#
# Description:
#   Fetches a prebuilt package (headers, runtime files, tools) in a pinned
#   version and deploys it to targets. The file is STANDALONE: it uses nothing
#   from the CMakeCraft core, so a project that does not build with CMakeCraft
#   can carry an unchanged copy and include it directly.
#
#   CMakeCraft itself calls it from the external kind "archive".
#
# Requires:     CMake 3.26 (copy_directory_if_different)
#
# Provides:
#   craft_package_fetch(NAME <name> PIN_FILE <file> [CACHE_DIR <dir>]
#                       OUT_ROOT <var>)
#   craft_package_deploy(TARGET <target> ROOT <dir>
#                        [INCLUDE_DIRS <dir>...] [DEFINE <name>]
#                        [RUNTIME_FILES <file>...] [RUNTIME_DIRS <dir>...]
#                        [NAME <name>] [NO_RUNTIME])
#
# Changelog:
#   1.1.0 (2026-10-09): runtime files are copied by a target of their own
#                       (<target>_deploy_<name>) that the executable depends
#                       on, no longer by a POST_BUILD step of the executable.
#                       The copy runs on every build, also when the executable
#                       is not linked again - after a change of the pinned
#                       version the new files arrive with the next build.
#                       New optional argument NAME.
#   1.0.0 (2026-10-09): first version
#
# Pin file (CMake script, <NAME> = upper-case package name):
#   set(<NAME>_VERSION "v0.2.0")
#   set(<NAME>_URL     "https://.../<archive>.zip")
#   set(<NAME>_SHA256  "<64 hex digits>")
#   set(<NAME>_FALLBACK_PATHS "../Other/out/package")   # optional, directories
#
# Package layout: the archive holds one top-level folder (or the content
# directly) with a file VERSION whose line "produkt=<x.y.z>" must match the
# pinned version (a leading "v" of the pin is ignored).
#
# Order of sources:
#   1. -D<NAME>_LOCAL_DIR=<dir>   developer override, used as is (unchecked)
#   2. cache                      default: <pin dir>/.externals/<name>/<version>/
#   3. download of <NAME>_URL     checked against <NAME>_SHA256
#   4. <NAME>_FALLBACK_PATHS      directories holding the same archive file,
#                                 same checksum
#
# A package that cannot be obtained is a WARNING, never an error: OUT_ROOT is
# empty and craft_package_deploy() then does nothing.
#
# ==============================================================================

include_guard(GLOBAL)

set(CMAKECRAFT_PACKAGE_VERSION "1.1.0")

if(CMAKE_VERSION VERSION_LESS 3.26)
    message(FATAL_ERROR
        "[CraftPackage] CMake 3.26 or newer is required (found ${CMAKE_VERSION}).")
endif()

# An empty ROOT ("package absent") is a regular argument of craft_package_deploy
if(POLICY CMP0174)
    cmake_policy(SET CMP0174 NEW)
endif()

# $<TARGET_FILE_DIR:...> in the deploy target must not make it depend on the
# executable: the dependency runs the other way (see craft_package_deploy)
cmake_policy(SET CMP0112 NEW)

# ------------------------------------------------------------------------------
# _craft_package_read_version – reads "produkt=" from <root>/VERSION
# ------------------------------------------------------------------------------
function(_craft_package_read_version ROOT OUT_VAR)
    set(${OUT_VAR} "" PARENT_SCOPE)
    if(NOT EXISTS "${ROOT}/VERSION")
        return()
    endif()
    file(STRINGS "${ROOT}/VERSION" _lines REGEX "^produkt=")
    if(_lines)
        list(GET _lines 0 _line)
        string(REGEX REPLACE "^produkt=[ \t]*" "" _value "${_line}")
        string(STRIP "${_value}" _value)
        set(${OUT_VAR} "${_value}" PARENT_SCOPE)
    endif()
endfunction()

# ------------------------------------------------------------------------------
# _craft_package_unpack – checks an archive and moves its content into the cache
#
# The archive is unpacked next to the cache directory and renamed into place
# only after checksum and version are right, so an aborted run never leaves
# something that looks like a cached package.
# ------------------------------------------------------------------------------
function(_craft_package_unpack ZIP SHA256 WANT CACHE OUT_OK OUT_REASON)
    set(${OUT_OK} FALSE PARENT_SCOPE)
    set(${OUT_REASON} "" PARENT_SCOPE)

    file(SHA256 "${ZIP}" _have)
    string(TOLOWER "${SHA256}" _want_hash)
    if(NOT _have STREQUAL _want_hash)
        set(${OUT_REASON} "checksum differs (have ${_have})" PARENT_SCOPE)
        return()
    endif()

    set(_work "${CACHE}.unpack")
    file(REMOVE_RECURSE "${_work}")
    file(ARCHIVE_EXTRACT INPUT "${ZIP}" DESTINATION "${_work}")

    # Content directly, or one top-level folder
    set(_root "${_work}")
    if(NOT EXISTS "${_root}/VERSION")
        file(GLOB _children LIST_DIRECTORIES TRUE "${_work}/*")
        list(LENGTH _children _count)
        if(_count EQUAL 1 AND IS_DIRECTORY "${_children}")
            set(_root "${_children}")
        endif()
    endif()

    _craft_package_read_version("${_root}" _produkt)
    if(NOT _produkt STREQUAL WANT)
        file(REMOVE_RECURSE "${_work}")
        set(${OUT_REASON}
            "file VERSION says produkt='${_produkt}', the pin wants '${WANT}'" PARENT_SCOPE)
        return()
    endif()

    file(REMOVE_RECURSE "${CACHE}")
    if(EXISTS "${CACHE}")
        file(REMOVE_RECURSE "${_work}")
        set(${OUT_REASON} "cache directory could not be removed: ${CACHE}" PARENT_SCOPE)
        return()
    endif()
    get_filename_component(_cache_parent "${CACHE}" DIRECTORY)
    file(MAKE_DIRECTORY "${_cache_parent}")
    file(RENAME "${_root}" "${CACHE}" RESULT _rename_result)
    file(REMOVE_RECURSE "${_work}")
    if(NOT _rename_result EQUAL 0)
        set(${OUT_REASON} "could not move into the cache: ${_rename_result}" PARENT_SCOPE)
        return()
    endif()

    set(${OUT_OK} TRUE PARENT_SCOPE)
endfunction()

# ==============================================================================
# craft_package_fetch
# ==============================================================================
#[[
    craft_package_fetch(NAME <name> PIN_FILE <file> [CACHE_DIR <dir>] OUT_ROOT <var>)

    Parameters:
        NAME      - Mandatory: package name; its upper-case form is the prefix
                    of the pin variables and of <NAME>_LOCAL_DIR
        PIN_FILE  - Mandatory: pin file (relative: to CMAKE_CURRENT_SOURCE_DIR)
        CACHE_DIR - Optional: directory of the unpacked package
                    (default: <pin dir>/.externals/<name>/<version>)
        OUT_ROOT  - Mandatory: receives the package root, or "" if unavailable

    Relative paths inside the pin file and in <NAME>_LOCAL_DIR are relative to
    the directory of the pin file.
]]
function(craft_package_fetch)
    cmake_parse_arguments(PARSE_ARGV 0 _cpf "" "NAME;PIN_FILE;CACHE_DIR;OUT_ROOT" "")

    if("${_cpf_NAME}" STREQUAL "" OR "${_cpf_PIN_FILE}" STREQUAL "" OR "${_cpf_OUT_ROOT}" STREQUAL "")
        message(FATAL_ERROR "[CraftPackage] craft_package_fetch: NAME, PIN_FILE and OUT_ROOT are mandatory.")
    endif()

    set(${_cpf_OUT_ROOT} "" PARENT_SCOPE)
    set(_tag "[CraftPackage] ${_cpf_NAME}")

    string(TOUPPER "${_cpf_NAME}" _prefix)
    string(MAKE_C_IDENTIFIER "${_prefix}" _prefix)

    get_filename_component(_pin "${_cpf_PIN_FILE}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
    if(NOT EXISTS "${_pin}")
        message(WARNING "${_tag}: pin file not found: ${_pin} - building without the package.")
        return()
    endif()
    get_filename_component(_base "${_pin}" DIRECTORY)

    # --------------------------------------------------------------------------
    # 1) Developer override
    # --------------------------------------------------------------------------
    set(${_prefix}_LOCAL_DIR "" CACHE PATH
        "Unpacked package '${_cpf_NAME}' used as is (developer override; empty = use the pin)")

    if(${_prefix}_LOCAL_DIR)
        get_filename_component(_local "${${_prefix}_LOCAL_DIR}" ABSOLUTE BASE_DIR "${_base}")
        if(NOT IS_DIRECTORY "${_local}")
            message(WARNING
                "${_tag}: ${_prefix}_LOCAL_DIR is set, but is no directory: ${_local} - building without the package.")
            return()
        endif()
        message(STATUS "${_tag} (LOCAL OVERRIDE): ${_local}")
        set(${_cpf_OUT_ROOT} "${_local}" PARENT_SCOPE)
        return()
    endif()

    # --------------------------------------------------------------------------
    # Pin
    # --------------------------------------------------------------------------
    include("${_pin}")
    set(_version "${${_prefix}_VERSION}")
    set(_url     "${${_prefix}_URL}")
    set(_sha256  "${${_prefix}_SHA256}")

    if("${_version}" STREQUAL "")
        message(WARNING "${_tag}: ${_prefix}_VERSION is not set in ${_pin} - building without the package.")
        return()
    endif()
    string(REGEX REPLACE "^[vV]" "" _want "${_version}")

    # --------------------------------------------------------------------------
    # 2) Cache
    # --------------------------------------------------------------------------
    if(NOT "${_cpf_CACHE_DIR}" STREQUAL "")
        get_filename_component(_cache "${_cpf_CACHE_DIR}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
    else()
        set(_cache "${_base}/.externals/${_cpf_NAME}/${_version}")
    endif()

    _craft_package_read_version("${_cache}" _cached)
    if(_cached STREQUAL _want)
        message(STATUS "${_tag} ${_version} from cache: ${_cache}")
        set(${_cpf_OUT_ROOT} "${_cache}" PARENT_SCOPE)
        return()
    endif()

    if(NOT _sha256 MATCHES "^[0-9a-fA-F]+$")
        message(WARNING
            "${_tag}: ${_prefix}_SHA256 is missing or not hexadecimal in ${_pin} - "
            "nothing is fetched without a checksum. Building without the package.")
        return()
    endif()

    get_filename_component(_zip_name "${_url}" NAME)
    set(_reasons "")

    # --------------------------------------------------------------------------
    # 3) Download
    #    Without EXPECTED_HASH: file(DOWNLOAD) would turn a failed download into
    #    a fatal error. The checksum is compared in _craft_package_unpack.
    # --------------------------------------------------------------------------
    if(NOT "${_url}" STREQUAL "")
        set(_download "${_cache}.download/${_zip_name}")
        message(STATUS "${_tag} ${_version}: downloading ${_url}")
        file(DOWNLOAD "${_url}" "${_download}"
            STATUS _status
            INACTIVITY_TIMEOUT 30
            TLS_VERIFY ON)
        list(GET _status 0 _status_code)
        if(_status_code EQUAL 0)
            _craft_package_unpack("${_download}" "${_sha256}" "${_want}" "${_cache}" _ok _reason)
        else()
            set(_ok FALSE)
            list(GET _status 1 _reason)
        endif()
        file(REMOVE_RECURSE "${_cache}.download")
        if(_ok)
            message(STATUS "${_tag} ${_version} ready: ${_cache}")
            set(${_cpf_OUT_ROOT} "${_cache}" PARENT_SCOPE)
            return()
        endif()
        string(APPEND _reasons "\n   - ${_url}: ${_reason}")
    endif()

    # --------------------------------------------------------------------------
    # 4) Fallback paths (directories holding the archive file)
    # --------------------------------------------------------------------------
    foreach(_dir IN LISTS ${_prefix}_FALLBACK_PATHS)
        get_filename_component(_dir "${_dir}" ABSOLUTE BASE_DIR "${_base}")
        set(_candidate "${_dir}/${_zip_name}")
        if("${_zip_name}" STREQUAL "" OR NOT EXISTS "${_candidate}")
            string(APPEND _reasons "\n   - ${_candidate}: not found")
            continue()
        endif()
        _craft_package_unpack("${_candidate}" "${_sha256}" "${_want}" "${_cache}" _ok _reason)
        if(_ok)
            message(STATUS "${_tag} ${_version} ready (from ${_candidate}): ${_cache}")
            set(${_cpf_OUT_ROOT} "${_cache}" PARENT_SCOPE)
            return()
        endif()
        string(APPEND _reasons "\n   - ${_candidate}: ${_reason}")
    endforeach()

    message(WARNING
        "${_tag} ${_version} could not be obtained - building without the package.\n"
        "  Tried:${_reasons}\n"
        "  Remedy: connect to the network, provide the archive in a fallback path "
        "(${_prefix}_FALLBACK_PATHS in ${_pin}), or set -D${_prefix}_LOCAL_DIR=<unpacked package>.")
endfunction()

# ==============================================================================
# craft_package_deploy
# ==============================================================================
#[[
    craft_package_deploy(TARGET <target> ROOT <dir>
                         [INCLUDE_DIRS <dir>...] [DEFINE <name>]
                         [RUNTIME_FILES <file>...] [RUNTIME_DIRS <dir>...]
                         [NAME <name>] [NO_RUNTIME])

    Parameters:
        TARGET        - Mandatory: existing target
        ROOT          - Mandatory: package root from craft_package_fetch; empty
                        or missing = the package is absent, nothing happens
        INCLUDE_DIRS  - Optional: include directories, relative to ROOT
                        (include path only - nothing is linked)
        DEFINE        - Optional: compile definition <name>=1 on the target
        RUNTIME_FILES - Optional: files, relative to ROOT, copied next to the
                        executable on each build
        RUNTIME_DIRS  - Optional: directories, relative to ROOT, copied as a
                        subfolder of the same name next to the executable
        NAME          - Optional: package name, part of the name of the deploy
                        target (<target>_deploy_<name>; default: "package")
        NO_RUNTIME    - Optional: include path and define only, no copies

    Runtime files and directories are only copied for executable targets, per
    configuration, and only when they differ.

    The copies are made by a target of their own that the executable depends
    on. It runs on every build of the executable, whether or not the
    executable itself is compiled or linked - so the files of a newly pinned
    package version arrive without touching the executable.
]]
function(craft_package_deploy)
    cmake_parse_arguments(PARSE_ARGV 0 _cpd
        "NO_RUNTIME" "TARGET;ROOT;DEFINE;NAME" "INCLUDE_DIRS;RUNTIME_FILES;RUNTIME_DIRS")

    if("${_cpd_TARGET}" STREQUAL "" OR NOT TARGET "${_cpd_TARGET}")
        message(FATAL_ERROR "[CraftPackage] craft_package_deploy: TARGET '${_cpd_TARGET}' does not exist.")
    endif()

    # Package absent: no include path, no define, no copy
    if("${_cpd_ROOT}" STREQUAL "" OR NOT IS_DIRECTORY "${_cpd_ROOT}")
        return()
    endif()

    get_target_property(_type "${_cpd_TARGET}" TYPE)
    if(_type STREQUAL "INTERFACE_LIBRARY")
        set(_scope INTERFACE)
    else()
        set(_scope PRIVATE)
    endif()

    foreach(_inc IN LISTS _cpd_INCLUDE_DIRS)
        target_include_directories("${_cpd_TARGET}" ${_scope} "${_cpd_ROOT}/${_inc}")
    endforeach()

    if(NOT "${_cpd_DEFINE}" STREQUAL "")
        target_compile_definitions("${_cpd_TARGET}" ${_scope} "${_cpd_DEFINE}=1")
    endif()

    if(_cpd_NO_RUNTIME OR NOT _type STREQUAL "EXECUTABLE")
        return()
    endif()

    set(_commands "")
    foreach(_file IN LISTS _cpd_RUNTIME_FILES)
        list(APPEND _commands
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different
                    "${_cpd_ROOT}/${_file}" "$<TARGET_FILE_DIR:${_cpd_TARGET}>")
    endforeach()
    foreach(_dir IN LISTS _cpd_RUNTIME_DIRS)
        get_filename_component(_dir_name "${_dir}" NAME)
        list(APPEND _commands
            COMMAND "${CMAKE_COMMAND}" -E copy_directory_if_different
                    "${_cpd_ROOT}/${_dir}" "$<TARGET_FILE_DIR:${_cpd_TARGET}>/${_dir_name}")
    endforeach()

    if(NOT _commands)
        return()
    endif()

    # A target of its own, not POST_BUILD: POST_BUILD only runs when the
    # executable is linked, and a new package version does not relink it.
    if("${_cpd_NAME}" STREQUAL "")
        set(_cpd_NAME "package")
    endif()
    string(MAKE_C_IDENTIFIER "${_cpd_NAME}" _deploy_suffix)
    set(_deploy_base "${_cpd_TARGET}_deploy_${_deploy_suffix}")
    set(_deploy "${_deploy_base}")
    set(_deploy_index 1)
    while(TARGET "${_deploy}")
        math(EXPR _deploy_index "${_deploy_index} + 1")
        set(_deploy "${_deploy_base}_${_deploy_index}")
    endwhile()

    # The directory may not exist yet: the copy runs before the first link
    add_custom_target("${_deploy}"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "$<TARGET_FILE_DIR:${_cpd_TARGET}>"
        ${_commands}
        COMMENT "Deploying package files next to ${_cpd_TARGET}"
        VERBATIM)
    add_dependencies("${_cpd_TARGET}" "${_deploy}")

    # IDE folder of the executable - read at the end of the directory, because
    # the caller may set it after this call. EVAL: a deferred call evaluates
    # its variables only when it runs, the names must be fixed here.
    cmake_language(EVAL CODE
        "cmake_language(DEFER CALL _craft_package_deploy_folder [[${_cpd_TARGET}]] [[${_deploy}]])")
endfunction()

# ------------------------------------------------------------------------------
# _craft_package_deploy_folder – puts the deploy target next to its executable
# ------------------------------------------------------------------------------
function(_craft_package_deploy_folder TARGET DEPLOY_TARGET)
    get_target_property(_folder "${TARGET}" FOLDER)
    if(_folder)
        set_target_properties("${DEPLOY_TARGET}" PROPERTIES FOLDER "${_folder}")
    endif()
endfunction()
