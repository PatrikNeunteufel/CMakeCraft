# ==============================================================================
# Core/Fetch.cmake – FetchContent Wrapper for Git Externals
# ==============================================================================
#
# Module:       Fetch.cmake
# Version:      0.1.0
# Date:         2025-12-09
# Part of:      CMake Architecture V2
#
# Description:
#   Wrapper around CMake's FetchContent for fetching Git-based externals.
#   Handles tag/branch/commit specification and provides consistent interface.
#
# Dependencies (must be loaded before):
#   - cmake/core/Errors.cmake
#   - cmake/core/Debug.cmake
#   - cmake/core/Json.cmake
#
# Provides:
#   _fetch_git_external(EXT_NAME EXT_JSON)
#   _is_external_populated(EXT_NAME OUT_VAR)
#
# Based on:
#   - master_concept v0.1
#   - guidelines v0.1
#
# ==============================================================================

include_guard(GLOBAL)

include(FetchContent)

# ==============================================================================
# _fetch_git_external - Fetch a Git-based external
# ==============================================================================
#[[
    _fetch_git_external(EXT_NAME EXT_JSON)
    
    Fetches a Git repository using FetchContent.
    
    Parameters:
        EXT_NAME - Name of the external
        EXT_JSON - JSON definition containing git, tag/branch/commit
    
    JSON Fields:
        git     - Repository URL (required)
        tag     - Git tag to checkout
        branch  - Git branch to checkout
        commit  - Git commit hash to checkout
        shallow - Use shallow clone (default: true for tag/branch)
    
    Example:
        _fetch_git_external("spdlog" "{\"git\":\"https://...\",\"tag\":\"v1.12.0\"}")
]]
function(_fetch_git_external EXT_NAME EXT_JSON)
    
    # ==========================================================================
    # Extract Git URL
    # ==========================================================================
    
    _json_get_string("${EXT_JSON}" "git" _git_url)
    
    if("${_git_url}" STREQUAL "")
        cmake_fatal("E012" "External '${EXT_NAME}': No 'git' URL specified")
    endif()
    
    dbg(${DBG_COMMON} "  Fetching: ${_git_url}" ID EXTERNALS)
    
    # ==========================================================================
    # Extract Version Reference (tag/branch/commit)
    # ==========================================================================
    
    _json_has_key("${EXT_JSON}" "tag" _has_tag)
    _json_has_key("${EXT_JSON}" "branch" _has_branch)
    _json_has_key("${EXT_JSON}" "commit" _has_commit)
    
    # Validate: exactly one must be present
    set(_ref_count 0)
    if(_has_tag)
        math(EXPR _ref_count "${_ref_count} + 1")
    endif()
    if(_has_branch)
        math(EXPR _ref_count "${_ref_count} + 1")
    endif()
    if(_has_commit)
        math(EXPR _ref_count "${_ref_count} + 1")
    endif()
    
    if(_ref_count EQUAL 0)
        cmake_fatal("E215" "Fetched external '${EXT_NAME}': No tag/branch/commit specified")
    endif()
    
    if(_ref_count GREATER 1)
        cmake_fatal("E215" "Fetched external '${EXT_NAME}': Multiple version refs specified (use only one of tag/branch/commit)")
    endif()
    
    # ==========================================================================
    # Build FetchContent Arguments
    # ==========================================================================
    
    set(_fetch_args
        GIT_REPOSITORY "${_git_url}"
    )
    
    if(_has_tag)
        _json_get_string("${EXT_JSON}" "tag" _tag)
        list(APPEND _fetch_args GIT_TAG "${_tag}")
        dbg(${DBG_COMMON} "    Tag: ${_tag}" ID EXTERNALS)
        set(_use_shallow TRUE)
        
    elseif(_has_branch)
        _json_get_string("${EXT_JSON}" "branch" _branch)
        list(APPEND _fetch_args GIT_TAG "origin/${_branch}")
        dbg(${DBG_COMMON} "    Branch: ${_branch}" ID EXTERNALS)
        set(_use_shallow TRUE)
        
    elseif(_has_commit)
        _json_get_string("${EXT_JSON}" "commit" _commit)
        list(APPEND _fetch_args GIT_TAG "${_commit}")
        dbg(${DBG_COMMON} "    Commit: ${_commit}" ID EXTERNALS)
        # Cannot use shallow clone with specific commit
        set(_use_shallow FALSE)
    endif()
    
    # ==========================================================================
    # Shallow Clone Option
    # ==========================================================================
    
    _json_has_key("${EXT_JSON}" "shallow" _has_shallow)
    if(_has_shallow)
        _json_get_bool_from_key("${EXT_JSON}" "shallow" _use_shallow)
    endif()
    
    if(_use_shallow)
        list(APPEND _fetch_args GIT_SHALLOW TRUE)
        dbg(${DBG_RARE} "    Shallow clone: ON" ID EXTERNALS)
    endif()
    
    # ==========================================================================
    # Progress Output
    # ==========================================================================
    
    list(APPEND _fetch_args GIT_PROGRESS TRUE)
    
    # ==========================================================================
    # FetchContent Declare
    # ==========================================================================
    
    # Convert name to lowercase for FetchContent
    string(TOLOWER "${EXT_NAME}" _ext_lower)
    
    FetchContent_Declare(
        ${_ext_lower}
        ${_fetch_args}
    )
    
    # ==========================================================================
    # Store for later MakeAvailable
    # ==========================================================================
    
    # Mark as declared
    set_property(GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_DECLARED TRUE)
    set_property(GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_JSON "${EXT_JSON}")
    
    dbg(${DBG_COMMON} "  Declared: ${EXT_NAME}" ID EXTERNALS)
    
endfunction()

# ==============================================================================
# _make_external_available - Actually fetch and make available
# ==============================================================================
#[[
    _make_external_available(EXT_NAME)
    
    Makes a declared external available (downloads if needed).
    Should be called after PreFetch hook and before PostFetch hook.
    
    Parameters:
        EXT_NAME - Name of the external
    
    Example:
        _make_external_available("spdlog")
]]
function(_make_external_available EXT_NAME)
    string(TOLOWER "${EXT_NAME}" _ext_lower)
    
    dbg(${DBG_COMMON} "  Making available: ${EXT_NAME}" ID EXTERNALS)
    
    # Suppress CMake messages during fetch
    set(FETCHCONTENT_QUIET ON)
    
    FetchContent_MakeAvailable(${_ext_lower})
    
    # Check if populated
    FetchContent_GetProperties(${_ext_lower})
    
    if(${_ext_lower}_POPULATED)
        dbg(${DBG_COMMON} "  Populated: ${EXT_NAME}" ID EXTERNALS)
        dbg(${DBG_RARE} "    Source: ${${_ext_lower}_SOURCE_DIR}" ID EXTERNALS)
        
        # Store source directory
        set_property(GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_SOURCE_DIR "${${_ext_lower}_SOURCE_DIR}")
        set_property(GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_POPULATED TRUE)
    else()
        cmake_fatal("E202" "Fetch failed for '${EXT_NAME}': FetchContent did not populate")
    endif()
    
endfunction()

# ==============================================================================
# _is_external_populated - Check if external is populated
# ==============================================================================
#[[
    _is_external_populated(EXT_NAME OUT_VAR)
    
    Checks if an external has been successfully fetched.
    
    Parameters:
        EXT_NAME - Name of the external
        OUT_VAR  - Output variable (TRUE/FALSE)
]]
function(_is_external_populated EXT_NAME OUT_VAR)
    get_property(_populated GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_POPULATED)
    
    if(_populated)
        set(${OUT_VAR} TRUE PARENT_SCOPE)
    else()
        set(${OUT_VAR} FALSE PARENT_SCOPE)
    endif()
endfunction()

# ==============================================================================
# _get_external_source_dir - Get source directory of fetched external
# ==============================================================================
#[[
    _get_external_source_dir(EXT_NAME OUT_VAR)
    
    Gets the source directory of a fetched external.
    
    Parameters:
        EXT_NAME - Name of the external
        OUT_VAR  - Output variable for source directory path
]]
function(_get_external_source_dir EXT_NAME OUT_VAR)
    get_property(_source_dir GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_SOURCE_DIR)
    set(${OUT_VAR} "${_source_dir}" PARENT_SCOPE)
endfunction()
