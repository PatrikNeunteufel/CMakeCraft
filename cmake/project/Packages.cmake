# cmake/project/Packages.cmake
# =============================
# Package pipeline - creates one target package_<name> per entry of "packages"
#
# Version: 1.0.0
# Date:    2026-10-09
# Status:  Release
# Author:  CMake Architecture Team
#
# Dependencies:
#   - cmake/core/Errors.cmake
#   - cmake/core/Debug.cmake
#   - cmake/core/Json.cmake
#   - cmake/project/Solution.cmake
#   - cmake/project/PackageBuild.cmake (run at build time via cmake -P)
#
# Provides:
#   - _create_package_target(PKG_JSON)
#   - Target package_<name> (not part of ALL)
#
# Result of building package_<name>, in <project>/out/package/:
#   <archive>/            the staged folder
#   <archive>.zip         the folder as archive (one top-level folder)
#   <archive>.zip.sha256  checksum, format of sha256sum
#
# Used by:
#   - CMakeCraft.cmake (after libraries, executables and apps exist)

include_guard(GLOBAL)

# ============================================================================
# _create_package_target - Creates the target package_<name>
# ============================================================================
#[[
    _create_package_target(PKG_JSON)

    Parameters:
        PKG_JSON - Mandatory: JSON string of one entry of "packages"

    JSON fields:
        name         - Mandatory: package name, target becomes package_<name>
        archive      - Optional: folder and archive name, {version} is the
                       solution version (default: "<name>-v{version}")
        config       - Optional: the only configuration the package may be
                       built from (e.g. "Release")
        version_file - Optional: template, configured with @VERSION@ and
                       written as file VERSION into the package root
        contents     - Mandatory: array, each entry has "to" (folder inside
                       the package) and exactly one source:
                         headers_of    - public header folder of a library,
                                         optionally narrowed by "files"
                         binary_of     - the built file of a target
                         output_dir_of - the output folder of a target with
                                         all subfolders, minus "exclude"
                         from          - folder relative to the project root,
                                         optionally narrowed by "files"

    A package naming a target that does not exist (skipped, other platform)
    is left out with W112.
]]
function(_create_package_target PKG_JSON)

    _json_get_string("${PKG_JSON}" "name" _name)
    if("${_name}" STREQUAL "")
        cmake_fatal("E001" "Package has no 'name' field")
    endif()

    if(TARGET package_${_name})
        cmake_fatal("E102" "Target 'package_${_name}' already exists")
    endif()

    get_property(_version GLOBAL PROPERTY SOLUTION_VERSION)

    _json_get_string_or_default("${PKG_JSON}" "archive" "${_name}-v{version}" _archive)
    string(REPLACE "{version}" "${_version}" _archive "${_archive}")
    _json_get_string_or_default("${PKG_JSON}" "config" "" _config)

    set(_out_dir "${CMAKE_SOURCE_DIR}/out/package")
    set(_work_dir "${CMAKE_BINARY_DIR}/package/${_name}")

    # --------------------------------------------------------------------------
    # Contents -> manifest lines (generator expressions resolved at generate time)
    # --------------------------------------------------------------------------

    _json_array_length("${PKG_JSON}" "contents" _item_count)
    if(_item_count EQUAL 0)
        cmake_fatal("E001" "Package '${_name}': required field 'contents' missing or empty")
    endif()

    set(_manifest "")
    set(_items "")
    set(_depends "")
    math(EXPR _item_last "${_item_count} - 1")

    foreach(_i RANGE 0 ${_item_last})
        _json_array_get("${PKG_JSON}" "contents" ${_i} _item)
        _json_get_string("${_item}" "to" _to)
        _json_get_array_as_list("${_item}" "files" _files)
        _json_get_array_as_list("${_item}" "exclude" _exclude)

        set(_source_keys "")
        foreach(_key IN ITEMS headers_of binary_of output_dir_of from)
            _json_has_key("${_item}" "${_key}" _has_key)
            if(_has_key)
                list(APPEND _source_keys "${_key}")
            endif()
        endforeach()
        list(LENGTH _source_keys _source_count)
        if(NOT _source_count EQUAL 1)
            cmake_fatal("E001" "Package '${_name}', contents[${_i}]: exactly one of 'headers_of', 'binary_of', 'output_dir_of', 'from' is required")
        endif()
        _json_get_string("${_item}" "${_source_keys}" _source)

        # Sources naming a target
        if(NOT _source_keys STREQUAL "from")
            if(NOT TARGET ${_source})
                cmake_warn("W112" "Package '${_name}': target '${_source}' does not exist (skipped or other platform) - package_${_name} is not created")
                return()
            endif()
        endif()

        if(_source_keys STREQUAL "headers_of")
            get_target_property(_src ${_source} CRAFT_PUBLIC_HEADERS_DIR)
            if(NOT _src)
                cmake_fatal("E001" "Package '${_name}': library '${_source}' has no public headers")
            endif()
        elseif(_source_keys STREQUAL "from")
            set(_src "${CMAKE_SOURCE_DIR}/${_source}")
            if(NOT IS_DIRECTORY "${_src}")
                cmake_fatal("E001" "Package '${_name}': folder does not exist: ${_source}")
            endif()
        elseif(_source_keys STREQUAL "binary_of")
            set(_src "$<TARGET_FILE:${_source}>")
            list(APPEND _depends ${_source})
        else()
            set(_src "$<TARGET_FILE_DIR:${_source}>")
            list(APPEND _depends ${_source})
        endif()

        if(_source_keys STREQUAL "binary_of")
            set(_kind "file")
        elseif(_files AND (_source_keys STREQUAL "headers_of" OR _source_keys STREQUAL "from"))
            set(_kind "files")
        else()
            set(_kind "dir")
        endif()

        list(APPEND _items ${_i})
        string(APPEND _manifest
            "set(CRAFT_PKG_ITEM_${_i}_KIND \"${_kind}\")\n"
            "set(CRAFT_PKG_ITEM_${_i}_TO \"${_to}\")\n"
            "set(CRAFT_PKG_ITEM_${_i}_SRC \"${_src}\")\n"
            "set(CRAFT_PKG_ITEM_${_i}_FILES \"${_files}\")\n"
            "set(CRAFT_PKG_ITEM_${_i}_EXCLUDE \"${_exclude}\")\n")
    endforeach()

    # --------------------------------------------------------------------------
    # Version file (template -> <build>/package/<name>/VERSION)
    # --------------------------------------------------------------------------

    set(_version_out "")
    _json_get_string_or_default("${PKG_JSON}" "version_file" "" _version_file)
    if(NOT "${_version_file}" STREQUAL "")
        if(NOT EXISTS "${CMAKE_SOURCE_DIR}/${_version_file}")
            cmake_fatal("E001" "Package '${_name}': version_file not found: ${_version_file}")
        endif()
        set(VERSION "${_version}")
        set(_version_out "${_work_dir}/VERSION")
        configure_file("${CMAKE_SOURCE_DIR}/${_version_file}" "${_version_out}" @ONLY)
    endif()

    # --------------------------------------------------------------------------
    # Manifest and target
    # --------------------------------------------------------------------------

    string(PREPEND _manifest
        "# Generated by CMakeCraft (Packages.cmake) - do not edit\n"
        "set(CRAFT_PKG_NAME \"${_name}\")\n"
        "set(CRAFT_PKG_ARCHIVE \"${_archive}\")\n"
        "set(CRAFT_PKG_OUT_DIR \"${_out_dir}\")\n"
        "set(CRAFT_PKG_REQUIRED_CONFIG \"${_config}\")\n"
        "set(CRAFT_PKG_CONFIG \"$<CONFIG>\")\n"
        "set(CRAFT_PKG_VERSION_FILE \"${_version_out}\")\n"
        "set(CRAFT_PKG_ITEMS \"${_items}\")\n")

    set(_manifest_file "${_work_dir}/manifest-$<CONFIG>.cmake")
    file(GENERATE OUTPUT "${_manifest_file}" CONTENT "${_manifest}")

    add_custom_target(package_${_name}
        COMMAND "${CMAKE_COMMAND}" "-DCRAFT_PKG_MANIFEST=${_manifest_file}"
                -P "${CMAKECRAFT_DIR}/project/PackageBuild.cmake"
        COMMENT "Packaging ${_archive}"
        VERBATIM
    )

    if(_depends)
        list(REMOVE_DUPLICATES _depends)
        add_dependencies(package_${_name} ${_depends})
    endif()

    dbg(${DBG_COMMON} "  Created: package_${_name} -> out/package/${_archive}" ID PACKAGES)

endfunction()

# ==============================================================================
# Iterate Over Packages
# ==============================================================================

get_property(_solution_json GLOBAL PROPERTY SOLUTION_JSON)
_json_array_length("${_solution_json}" "packages" _pkg_count)

if(_pkg_count GREATER 0)

    dbg_init(ID PACKAGES LEVEL ${DBG_SHOW_MUCH} SWITCH ON TAG "Packages")
    dbg(${DBG_OFTEN} "=== Package Pipeline Start ===" ID PACKAGES)
    dbg(${DBG_OFTEN} "Processing ${_pkg_count} package(s)..." ID PACKAGES)

    math(EXPR _pkg_last "${_pkg_count} - 1")
    foreach(_pkg_idx RANGE 0 ${_pkg_last})
        _json_array_get("${_solution_json}" "packages" ${_pkg_idx} _pkg_json)
        _create_package_target("${_pkg_json}")
    endforeach()

    dbg(${DBG_OFTEN} "=== Package Pipeline Complete ===" ID PACKAGES)
    enddbgblock(ID PACKAGES)

endif()

# ==============================================================================
# Cleanup
# ==============================================================================

unset(_solution_json)
unset(_pkg_count)
unset(_pkg_last)
unset(_pkg_idx)
unset(_pkg_json)
