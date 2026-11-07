# cmake/project/SourcePackage.cmake
# ==================================
# Source package of one library - target package_<name> for an entry
# { "name": ..., "library": ... } of "packages"
#
# Version: 1.0.0
# Date:    2026-11-07
# Status:  Release
# Author:  CMake Architecture Team
#
# Dependencies:
#   - cmake/core/Errors.cmake
#   - cmake/core/Debug.cmake
#   - cmake/core/Json.cmake
#   - cmake/core/CompilerOptions.cmake (craft_language_rules)
#   - cmake/project/LibraryCreate.cmake (CRAFT_LIB_* / CRAFT_EXT_* properties)
#   - cmake/project/PackageBuild.cmake (run at build time via cmake -P)
#
# Provides:
#   - _create_source_package_target(PKG_JSON NAME)
#
# Result of building package_<name>, in <project>/out/package/:
#   <archive>/
#       CMakeLists.txt      plain CMake, no CMakeCraft: add_subdirectory()
#       VERSION             version of the library
#       SHA256SUMS          every file of the folder, format of sha256sum
#       include/            the public headers
#       src/                the files of the library (from Source.cmake)
#       externals/<ext>/    each local header external, with its licence
#   <archive>.zip, <archive>.zip.sha256
#
# The generated CMakeLists.txt is written with file(WRITE) at configure time,
# so generator expressions in compile_options stay verbatim; the checksums of
# the externals are filled in at build time (PackageBuild.cmake).
#
# Used by:
#   - Packages.cmake

include_guard(GLOBAL)

# ============================================================================
# _craft_pkg_bracket - Value as CMake bracket argument (kept verbatim)
# ============================================================================
function(_craft_pkg_bracket VALUE OUT_VAR)
    set(_eq "=")
    while("${VALUE}" MATCHES "]${_eq}]")
        string(APPEND _eq "=")
    endwhile()
    set(${OUT_VAR} "[${_eq}[${VALUE}]${_eq}]" PARENT_SCOPE)
endfunction()

# ============================================================================
# _craft_pkg_place - Where a path of the library lies inside the package
# ============================================================================
#[[
    _craft_pkg_place(PATH SRC_DIR PUB_DIR OUT_VAR)

    OUT_VAR: "include[/<rel>]" below the public headers, "src[/<rel>]" below
    the source folder of the library, "" anywhere else.
]]
function(_craft_pkg_place PATH SRC_DIR PUB_DIR OUT_VAR)
    cmake_path(SET _path NORMALIZE "${PATH}")
    set(_result "")
    foreach(_pair IN ITEMS "include|${PUB_DIR}" "src|${SRC_DIR}")
        string(FIND "${_pair}" "|" _bar)
        string(SUBSTRING "${_pair}" 0 ${_bar} _to)
        math(EXPR _start "${_bar} + 1")
        string(SUBSTRING "${_pair}" ${_start} -1 _base)
        if("${_base}" STREQUAL "")
            continue()
        endif()
        cmake_path(SET _base NORMALIZE "${_base}")
        cmake_path(IS_PREFIX _base "${_path}" NORMALIZE _inside)
        if(_inside)
            cmake_path(RELATIVE_PATH _path BASE_DIRECTORY "${_base}" OUTPUT_VARIABLE _rel)
            string(REGEX REPLACE "/$" "" _rel "${_rel}")
            if("${_rel}" STREQUAL "" OR "${_rel}" STREQUAL ".")
                set(_result "${_to}")
            else()
                set(_result "${_to}/${_rel}")
            endif()
            break()
        endif()
    endforeach()
    set(${OUT_VAR} "${_result}" PARENT_SCOPE)
endfunction()

# ============================================================================
# _craft_pkg_external - Block of the generated CMakeLists.txt for one external
# ============================================================================
#[[
    _craft_pkg_external(LIB EXT OUT_CODE OUT_ROOT OUT_DROP)

    Takes what applying the local external EXT added to the library LIB (see
    _craft_record_external_effect) and describes it in plain CMake. Allowed:
    INTERFACE targets with include folders inside the external's folder,
    defines, compile options and compile features. Anything else is E106.

    OUT_CODE - CMake code (empty if the external added nothing)
    OUT_ROOT - folder of the external (copied to externals/<EXT>)
    OUT_DROP - path of its Include.cmake relative to OUT_ROOT ("" if outside)
]]
function(_craft_pkg_external LIB EXT OUT_CODE OUT_ROOT OUT_DROP)
    get_property(_externals_json GLOBAL PROPERTY SOLUTION_EXTERNALS_JSON)
    _json_get_object("${_externals_json}" "${EXT}" _ext_json)

    _json_get_bool_or_default("${_ext_json}" "system" FALSE _is_system)
    _json_has_key("${_ext_json}" "git" _is_fetched)
    _json_get_bool_or_default("${_ext_json}" "archive" FALSE _is_archive)
    _json_has_key("${_ext_json}" "path" _is_local)
    if(_is_system OR _is_fetched OR _is_archive OR NOT _is_local)
        cmake_fatal("E106" "Source package of '${LIB}': external '${EXT}' is not a local external (system, fetched or archive) - only local header externals travel with the package")
    endif()

    _json_get_string("${_ext_json}" "path" _ext_path)
    cmake_path(SET _ext_root NORMALIZE "${CMAKE_SOURCE_DIR}/${_ext_path}")
    string(REGEX REPLACE "/$" "" _ext_root "${_ext_root}")

    # Include.cmake is CMakeCraft's, not the receiver's - left out of the copy
    _json_get_string_or_default("${_ext_json}" "include" "" _include_rel)
    set(_drop "")
    if(NOT "${_include_rel}" STREQUAL "")
        cmake_path(SET _include_file NORMALIZE "${CMAKE_SOURCE_DIR}/${_include_rel}")
        cmake_path(IS_PREFIX _ext_root "${_include_file}" NORMALIZE _inside)
        if(_inside)
            cmake_path(RELATIVE_PATH _include_file BASE_DIRECTORY "${_ext_root}" OUTPUT_VARIABLE _drop)
        endif()
    endif()

    get_target_property(_other ${LIB} CRAFT_EXT_${EXT}_OTHER)
    if(_other)
        cmake_fatal("E106" "Source package of '${LIB}': external '${EXT}' changes the library directly (${_other}) - only a linked INTERFACE target can be described")
    endif()

    get_target_property(_links ${LIB} CRAFT_EXT_${EXT}_LINKS)
    get_target_property(_public ${LIB} CRAFT_EXT_${EXT}_PUBLIC)
    if(NOT _links)
        set(_links "")
    endif()
    if(NOT _public)
        set(_public "")
    endif()

    set(_code "")
    set(_dir "\${CMAKE_CURRENT_SOURCE_DIR}/externals/${EXT}")

    foreach(_link IN LISTS _links)
        if(NOT TARGET ${_link})
            cmake_fatal("E106" "Source package of '${LIB}': external '${EXT}' links '${_link}', which is not a target")
        endif()

        set(_real "${_link}")
        get_target_property(_aliased ${_link} ALIASED_TARGET)
        if(_aliased)
            set(_real "${_aliased}")
        endif()

        get_target_property(_type ${_real} TYPE)
        get_target_property(_imported ${_real} IMPORTED)
        if(NOT _type STREQUAL "INTERFACE_LIBRARY" OR _imported)
            cmake_fatal("E106" "Source package of '${LIB}': external '${EXT}' brings target '${_real}' (${_type}) - only a header-only INTERFACE target can travel")
        endif()

        foreach(_prop IN ITEMS INTERFACE_LINK_LIBRARIES INTERFACE_SOURCES
                INTERFACE_LINK_OPTIONS INTERFACE_LINK_DIRECTORIES
                INTERFACE_PRECOMPILE_HEADERS)
            get_target_property(_value ${_real} ${_prop})
            if(_value)
                cmake_fatal("E106" "Source package of '${LIB}': target '${_real}' of external '${EXT}' sets ${_prop} (${_value}) - only include folders, defines, compile options and features can travel")
            endif()
        endforeach()

        get_target_property(_includes ${_real} INTERFACE_INCLUDE_DIRECTORIES)
        get_target_property(_system ${_real} INTERFACE_SYSTEM_INCLUDE_DIRECTORIES)
        get_target_property(_defines ${_real} INTERFACE_COMPILE_DEFINITIONS)
        get_target_property(_options ${_real} INTERFACE_COMPILE_OPTIONS)
        get_target_property(_features ${_real} INTERFACE_COMPILE_FEATURES)
        foreach(_var IN ITEMS _includes _system _defines _options _features)
            if(NOT ${_var})
                set(${_var} "")
            endif()
        endforeach()

        set(_inc_system "")
        set(_inc_plain "")
        foreach(_inc IN LISTS _includes)
            cmake_path(SET _inc_norm NORMALIZE "${_inc}")
            cmake_path(IS_PREFIX _ext_root "${_inc_norm}" NORMALIZE _inside)
            if(NOT _inside)
                cmake_fatal("E106" "Source package of '${LIB}': target '${_real}' of external '${EXT}' has an include folder outside ${_ext_path}: ${_inc}")
            endif()
            cmake_path(RELATIVE_PATH _inc_norm BASE_DIRECTORY "${_ext_root}" OUTPUT_VARIABLE _rel)
            string(REGEX REPLACE "/$" "" _rel "${_rel}")
            if("${_rel}" STREQUAL "" OR "${_rel}" STREQUAL ".")
                set(_target_dir "\"${_dir}\"")
            else()
                set(_target_dir "\"${_dir}/${_rel}\"")
            endif()
            if("${_inc}" IN_LIST _system)
                list(APPEND _inc_system "${_target_dir}")
            else()
                list(APPEND _inc_plain "${_target_dir}")
            endif()
        endforeach()

        set(_hash "@CRAFT_EXT_SHA256_${EXT}@")
        string(APPEND _code
            "# External '${EXT}' (local, header only): externals/${EXT}\n"
            "if(NOT TARGET ${_real})\n"
            "    add_library(${_real} INTERFACE)\n")
        if(_inc_system)
            list(JOIN _inc_system "\n        " _text)
            string(APPEND _code "    target_include_directories(${_real} SYSTEM INTERFACE\n        ${_text})\n")
        endif()
        if(_inc_plain)
            list(JOIN _inc_plain "\n        " _text)
            string(APPEND _code "    target_include_directories(${_real} INTERFACE\n        ${_text})\n")
        endif()
        foreach(_pair IN ITEMS "target_compile_definitions|_defines"
                               "target_compile_options|_options"
                               "target_compile_features|_features")
            string(REPLACE "|" ";" _pair "${_pair}")
            list(GET _pair 0 _command)
            list(GET _pair 1 _var)
            if(${_var})
                set(_items "")
                foreach(_item IN LISTS ${_var})
                    _craft_pkg_bracket("${_item}" _quoted)
                    list(APPEND _items "${_quoted}")
                endforeach()
                list(JOIN _items "\n        " _text)
                string(APPEND _code "    ${_command}(${_real} INTERFACE\n        ${_text})\n")
            endif()
        endforeach()
        string(APPEND _code
            "    set_property(GLOBAL PROPERTY CRAFT_PACKAGE_EXTERNAL_${_real}_SHA256 \"${_hash}\")\n"
            "else()\n"
            "    get_property(_craft_sha256 GLOBAL PROPERTY CRAFT_PACKAGE_EXTERNAL_${_real}_SHA256)\n"
            "    if(NOT \"\${_craft_sha256}\" STREQUAL \"${_hash}\")\n"
            "        message(FATAL_ERROR \"[${LIB}] target '${_real}' already exists with other content - another package brings a different '${EXT}', or the project defines '${_real}' itself\")\n"
            "    endif()\n"
            "endif()\n")
        if(_aliased)
            string(APPEND _code
                "if(NOT TARGET ${_link})\n"
                "    add_library(${_link} ALIAS ${_real})\n"
                "endif()\n")
        endif()

        if("${_link}" IN_LIST _public)
            set_property(DIRECTORY APPEND PROPERTY _CRAFT_PKG_LINKS_PUBLIC "${_link}")
        else()
            set_property(DIRECTORY APPEND PROPERTY _CRAFT_PKG_LINKS_PRIVATE "${_link}")
        endif()
    endforeach()

    if(NOT "${_code}" STREQUAL "")
        string(APPEND _code "\n")
    endif()
    set(${OUT_CODE} "${_code}" PARENT_SCOPE)
    set(${OUT_ROOT} "${_ext_root}" PARENT_SCOPE)
    set(${OUT_DROP} "${_drop}" PARENT_SCOPE)
endfunction()

# ============================================================================
# _create_source_package_target - Creates package_<name> for a library
# ============================================================================
#[[
    _create_source_package_target(PKG_JSON NAME)

    Parameters:
        PKG_JSON - Mandatory: JSON string of one entry of "packages"
        NAME     - Mandatory: its "name"

    JSON fields:
        name    - Mandatory: package name, target becomes package_<name>
        library - Mandatory: the library (STATIC) packed as sources
        archive - Optional: folder and archive name, {version} is the
                  version of the library (default: "<name>-v{version}")
    "contents", "config" and "version_file" are not allowed here (E001).

    Errors:
        E001 - field not allowed together with "library"
        E106 - the library cannot be described in plain CMake (type, C++20
               modules, a file or include folder outside the library, an
               external that is not local or not a header-only target)

    A library that does not exist (skipped, other platform) leaves the
    package out with W112.
]]
function(_create_source_package_target PKG_JSON NAME)

    foreach(_key IN ITEMS contents config version_file)
        _json_has_key("${PKG_JSON}" "${_key}" _has_key)
        if(_has_key)
            cmake_fatal("E001" "Package '${NAME}': field '${_key}' is not allowed together with 'library'")
        endif()
    endforeach()

    _json_get_string("${PKG_JSON}" "library" _lib)
    if("${_lib}" STREQUAL "")
        cmake_fatal("E001" "Package '${NAME}': field 'library' is empty")
    endif()
    if(NOT TARGET ${_lib})
        cmake_warn("W112" "Package '${NAME}': library '${_lib}' does not exist (skipped or other platform) - package_${NAME} is not created")
        return()
    endif()

    get_target_property(_type ${_lib} TYPE)
    if(NOT _type STREQUAL "STATIC_LIBRARY")
        cmake_fatal("E106" "Source package '${NAME}': library '${_lib}' is ${_type} - a source package needs a STATIC library")
    endif()

    get_target_property(_src_dir ${_lib} CRAFT_LIB_SOURCE_DIR)
    get_target_property(_files ${_lib} CRAFT_LIB_FILES)
    get_target_property(_modules ${_lib} CRAFT_LIB_MODULES)
    get_target_property(_includes ${_lib} CRAFT_LIB_PRIVATE_INCLUDES)
    get_target_property(_defines ${_lib} CRAFT_LIB_DEFINES)
    get_target_property(_options ${_lib} CRAFT_LIB_COMPILE_OPTIONS)
    get_target_property(_pch ${_lib} CRAFT_LIB_PCH)
    get_target_property(_deps ${_lib} CRAFT_LIB_DEPENDENCIES)
    get_target_property(_externals ${_lib} CRAFT_LIB_EXTERNALS)
    get_target_property(_version ${_lib} CRAFT_LIB_VERSION)
    get_target_property(_output_name ${_lib} CRAFT_LIB_OUTPUT_NAME)
    get_target_property(_pub_dir ${_lib} CRAFT_PUBLIC_HEADERS_DIR)
    foreach(_var IN ITEMS _files _modules _includes _defines _options _pch
            _deps _externals _version _output_name _pub_dir)
        if(NOT ${_var})
            set(${_var} "")
        endif()
    endforeach()
    list(REMOVE_ITEM _files "")
    list(REMOVE_DUPLICATES _files)

    if(_modules)
        cmake_fatal("E106" "Source package '${NAME}': library '${_lib}' has C++20 module units - not supported in a source package")
    endif()

    _json_get_string_or_default("${PKG_JSON}" "archive" "${NAME}-v{version}" _archive)
    string(REPLACE "{version}" "${_version}" _archive "${_archive}")

    set(_out_dir "${CMAKE_SOURCE_DIR}/out/package")
    set(_work_dir "${CMAKE_BINARY_DIR}/package/${NAME}")

    # --------------------------------------------------------------------------
    # Files of the library -> src/ (below the public headers: include/)
    # --------------------------------------------------------------------------

    set(_copy_src "")
    set(_copy_dst "")
    set(_sources_text "")
    foreach(_file IN LISTS _files)
        _craft_pkg_place("${_file}" "${_src_dir}" "${_pub_dir}" _place)
        if("${_place}" STREQUAL "")
            cmake_fatal("E106" "Source package '${NAME}': file outside the library and its public headers: ${_file}")
        endif()
        if(_place MATCHES "^src/")
            cmake_path(SET _file_norm NORMALIZE "${_file}")
            list(APPEND _copy_src "${_file_norm}")
            list(APPEND _copy_dst "${_place}")
        endif()
        string(APPEND _sources_text "    \"\${CMAKE_CURRENT_SOURCE_DIR}/${_place}\"\n")
    endforeach()

    set(_private_text "")
    foreach(_inc IN LISTS _includes)
        _craft_pkg_place("${_inc}" "${_src_dir}" "${_pub_dir}" _place)
        if("${_place}" STREQUAL "")
            cmake_fatal("E106" "Source package '${NAME}': include folder outside the library and its public headers: ${_inc}")
        endif()
        string(APPEND _private_text "        \"\${CMAKE_CURRENT_SOURCE_DIR}/${_place}\"\n")
    endforeach()

    set(_pch_text "")
    if(NOT "${_pch}" STREQUAL "")
        _craft_pkg_place("${_pch}" "${_src_dir}" "${_pub_dir}" _place)
        if("${_place}" STREQUAL "")
            cmake_fatal("E106" "Source package '${NAME}': precompiled header outside the library: ${_pch}")
        endif()
        if(_place MATCHES "^src/" AND NOT "${_place}" IN_LIST _copy_dst)
            cmake_path(SET _pch_norm NORMALIZE "${_pch}")
            list(APPEND _copy_src "${_pch_norm}")
            list(APPEND _copy_dst "${_place}")
        endif()
        set(_pch_text "target_precompile_headers(${_lib} PRIVATE \"\${CMAKE_CURRENT_SOURCE_DIR}/${_place}\")\n")
    endif()

    # --------------------------------------------------------------------------
    # Externals (local header externals only)
    # --------------------------------------------------------------------------

    set_property(DIRECTORY PROPERTY _CRAFT_PKG_LINKS_PUBLIC "")
    set_property(DIRECTORY PROPERTY _CRAFT_PKG_LINKS_PRIVATE "")
    set(_externals_text "")
    set(_dir_src "")
    set(_dir_dst "")
    set(_dir_drop "")
    set(_hash_names "")
    foreach(_ext IN LISTS _externals)
        _craft_pkg_external(${_lib} "${_ext}" _code _root _drop)
        if("${_code}" STREQUAL "")
            dbg(${DBG_RARE} "    External ${_ext} added nothing - left out" ID PACKAGES)
            continue()
        endif()
        string(APPEND _externals_text "${_code}")
        list(APPEND _dir_src "${_root}")
        list(APPEND _dir_dst "externals/${_ext}")
        if("${_drop}" STREQUAL "")
            list(APPEND _dir_drop "-")
        else()
            list(APPEND _dir_drop "${_drop}")
        endif()
        list(APPEND _hash_names "${_ext}")
    endforeach()
    get_property(_links_public DIRECTORY PROPERTY _CRAFT_PKG_LINKS_PUBLIC)
    get_property(_links_private DIRECTORY PROPERTY _CRAFT_PKG_LINKS_PRIVATE)

    if(NOT "${_pub_dir}" STREQUAL "")
        list(PREPEND _dir_src "${_pub_dir}")
        list(PREPEND _dir_dst "include")
        list(PREPEND _dir_drop "-")
    endif()

    # --------------------------------------------------------------------------
    # Generated CMakeLists.txt (plain CMake)
    # --------------------------------------------------------------------------

    set(_cm "")
    string(APPEND _cm
        "# Generated by CMakeCraft (SourcePackage.cmake) - do not edit.\n"
        "# Library '${_lib}' ${_version} as plain CMake, no CMakeCraft needed:\n"
        "#   add_subdirectory(<this folder>)\n"
        "#   target_link_libraries(<your target> PRIVATE ${_lib}::${_lib})\n"
        "# Checksums of every file: SHA256SUMS (sha256sum -c SHA256SUMS)\n"
        "\n"
        "cmake_minimum_required(VERSION 3.26)\n"
        "\n"
        "if(TARGET ${_lib})\n"
        "    message(FATAL_ERROR \"[${_lib}] target '${_lib}' already exists - is this package added twice?\")\n"
        "endif()\n"
        "\n")

    if(_deps)
        string(APPEND _cm "# Libraries this one needs - each is a package of its own, added before this one\n")
        foreach(_dep IN LISTS _deps)
            string(APPEND _cm
                "if(NOT TARGET ${_dep})\n"
                "    message(FATAL_ERROR \"[${_lib}] needs target '${_dep}' - add its package before this one\")\n"
                "endif()\n")
        endforeach()
        string(APPEND _cm "\n")
    endif()

    string(APPEND _cm "${_externals_text}")

    string(APPEND _cm
        "add_library(${_lib} STATIC\n"
        "${_sources_text}"
        ")\n"
        "add_library(${_lib}::${_lib} ALIAS ${_lib})\n"
        "\n")

    if(NOT "${_pub_dir}" STREQUAL "")
        string(APPEND _cm "target_include_directories(${_lib} PUBLIC\n        \"\${CMAKE_CURRENT_SOURCE_DIR}/include\")\n")
    endif()
    string(APPEND _cm "target_include_directories(${_lib} PRIVATE\n${_private_text})\n")

    if(_defines)
        set(_items "")
        foreach(_item IN LISTS _defines)
            _craft_pkg_bracket("${_item}" _quoted)
            list(APPEND _items "${_quoted}")
        endforeach()
        list(JOIN _items "\n        " _text)
        string(APPEND _cm "target_compile_definitions(${_lib} PRIVATE\n        ${_text})\n")
    endif()

    # Language rules exactly as apply_compiler_options sets them for a library
    craft_language_rules(_rules)
    set(_msvc_text "")
    if(_rules_MSVC_OPTIONS)
        list(JOIN _rules_MSVC_OPTIONS " " _text)
        string(APPEND _msvc_text "    target_compile_options(${_lib} PRIVATE ${_text})\n")
    endif()
    if(_rules_MSVC_DEFINES)
        list(JOIN _rules_MSVC_DEFINES " " _text)
        string(APPEND _msvc_text "    target_compile_definitions(${_lib} PRIVATE ${_text})\n")
    endif()
    set(_gnu_text "")
    if(_rules_GNU_OPTIONS)
        list(JOIN _rules_GNU_OPTIONS " " _text)
        string(APPEND _gnu_text "    target_compile_options(${_lib} PRIVATE ${_text})\n")
    endif()
    if(NOT "${_msvc_text}${_gnu_text}" STREQUAL "")
        string(APPEND _cm
            "\n# Language rules the library was built and checked with (as CMakeCraft sets them)\n"
            "if(MSVC)\n${_msvc_text}")
        if(NOT "${_gnu_text}" STREQUAL "")
            string(APPEND _cm "elseif(CMAKE_CXX_COMPILER_ID MATCHES \"GNU|Clang\")\n${_gnu_text}")
        endif()
        string(APPEND _cm "endif()\n")
    endif()

    if(_options)
        set(_items "")
        foreach(_item IN LISTS _options)
            _craft_pkg_bracket("${_item}" _quoted)
            list(APPEND _items "${_quoted}")
        endforeach()
        list(JOIN _items "\n        " _text)
        string(APPEND _cm
            "\n# compile_options of the library (Solution.json), after the language rules\n"
            "target_compile_options(${_lib} PRIVATE\n        ${_text})\n")
    endif()

    # C++ standard as the library had it
    get_target_property(_std ${_lib} CXX_STANDARD)
    get_target_property(_std_required ${_lib} CXX_STANDARD_REQUIRED)
    get_target_property(_std_extensions ${_lib} CXX_EXTENSIONS)
    if(NOT _std_required)
        set(_std_required OFF)
    endif()
    if("${_std_extensions}" MATCHES "NOTFOUND$")
        # unset in the solution: the CMake default (GNU/Clang: gnu++NN)
        set(_std_extensions ON)
    elseif(_std_extensions)
        set(_std_extensions ON)
    else()
        set(_std_extensions OFF)
    endif()
    string(APPEND _cm "\n")
    if(_std)
        string(APPEND _cm "target_compile_features(${_lib} PUBLIC cxx_std_${_std})\n")
        string(APPEND _cm "set_target_properties(${_lib} PROPERTIES\n"
                          "    CXX_STANDARD ${_std}\n"
                          "    CXX_STANDARD_REQUIRED ${_std_required}\n"
                          "    CXX_EXTENSIONS ${_std_extensions})\n")
    else()
        string(APPEND _cm "set_target_properties(${_lib} PROPERTIES CXX_EXTENSIONS ${_std_extensions})\n")
    endif()
    if(NOT "${_output_name}" STREQUAL "")
        string(APPEND _cm "set_target_properties(${_lib} PROPERTIES OUTPUT_NAME \"${_output_name}\")\n")
    endif()
    if(NOT "${_version}" STREQUAL "")
        string(APPEND _cm "set_target_properties(${_lib} PROPERTIES VERSION \"${_version}\")\n")
    endif()
    string(APPEND _cm "${_pch_text}")

    if(_deps OR _links_public OR _links_private)
        string(APPEND _cm "\n")
    endif()
    if(_deps)
        list(JOIN _deps " " _text)
        string(APPEND _cm "target_link_libraries(${_lib} PUBLIC ${_text})\n")
    endif()
    if(_links_public)
        list(JOIN _links_public " " _text)
        string(APPEND _cm "target_link_libraries(${_lib} PUBLIC ${_text})\n")
    endif()
    if(_links_private)
        list(JOIN _links_private " " _text)
        string(APPEND _cm "target_link_libraries(${_lib} PRIVATE ${_text})\n")
    endif()

    set(_template "${_work_dir}/CMakeLists.txt.in")
    file(WRITE "${_template}" "${_cm}")

    # --------------------------------------------------------------------------
    # Manifest (file(WRITE): nothing in it depends on the configuration)
    # --------------------------------------------------------------------------

    set(_manifest "")
    foreach(_pair IN ITEMS
            "CRAFT_PKG_KIND|source"
            "CRAFT_PKG_NAME|${NAME}"
            "CRAFT_PKG_ARCHIVE|${_archive}"
            "CRAFT_PKG_OUT_DIR|${_out_dir}"
            "CRAFT_PKG_REQUIRED_CONFIG|"
            "CRAFT_PKG_CONFIG|"
            "CRAFT_PKG_LIB_VERSION|${_version}"
            "CRAFT_PKG_CMAKELISTS|${_template}")
        string(FIND "${_pair}" "|" _bar)
        string(SUBSTRING "${_pair}" 0 ${_bar} _var)
        math(EXPR _start "${_bar} + 1")
        string(SUBSTRING "${_pair}" ${_start} -1 _value)
        _craft_pkg_bracket("${_value}" _quoted)
        string(APPEND _manifest "set(${_var} ${_quoted})\n")
    endforeach()
    foreach(_var IN ITEMS _copy_src _copy_dst _dir_src _dir_dst _dir_drop _hash_names)
        string(TOUPPER "CRAFT_PKG${_var}" _name_upper)
        _craft_pkg_bracket("${${_var}}" _quoted)
        string(APPEND _manifest "set(${_name_upper} ${_quoted})\n")
    endforeach()
    string(PREPEND _manifest "# Generated by CMakeCraft (SourcePackage.cmake) - do not edit\n")

    set(_manifest_file "${_work_dir}/manifest-source.cmake")
    file(WRITE "${_manifest_file}" "${_manifest}")

    add_custom_target(package_${NAME}
        COMMAND "${CMAKE_COMMAND}" "-DCRAFT_PKG_MANIFEST=${_manifest_file}"
                -P "${CMAKECRAFT_DIR}/project/PackageBuild.cmake"
        COMMENT "Packaging ${_archive} (sources of ${_lib})"
        VERBATIM
    )
    set_target_properties(package_${NAME} PROPERTIES
        CRAFT_PACKAGE_MANIFEST "${_manifest_file}"
        CRAFT_PACKAGE_CMAKELISTS "${_template}"
    )

    dbg(${DBG_COMMON} "  Created: package_${NAME} -> out/package/${_archive} (sources of ${_lib})" ID PACKAGES)

endfunction()
