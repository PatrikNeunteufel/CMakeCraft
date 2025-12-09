# ==============================================================================
# Hooks/HookLoader.cmake – Hook System for Externals
# ==============================================================================
#
# Module:       HookLoader.cmake
# Version:      0.1.0
# Date:         2025-12-09
# Part of:      CMake Architecture V2
#
# Description:
#   Loads PreFetch and PostFetch hooks for externals.
#   Implements Convention over Configuration pattern.
#
# Dependencies (must be loaded before):
#   - cmake/core/Errors.cmake
#   - cmake/core/Debug.cmake
#   - cmake/core/Json.cmake
#
# Convention Paths:
#   - PreFetch:  cmake/externals/Hooks/PreFetch/${name}.cmake
#   - PostFetch: cmake/externals/Hooks/PostFetch/${name}.cmake
#
# Hook Behavior:
#   - No hooks in JSON, no convention file → No hook loaded
#   - No hooks in JSON, convention file exists → Auto-load
#   - Hooks explicitly defined, file exists → Load
#   - Hooks explicitly defined, file missing → Error E216
#
# Based on:
#   - master_concept v0.1
#   - guidelines v0.1
#
# ==============================================================================

include_guard(GLOBAL)

# ==============================================================================
# Convention Paths
# ==============================================================================

set(HOOKS_PREFETCH_DIR "${CMAKE_SOURCE_DIR}/cmake/externals/Hooks/PreFetch")
set(HOOKS_POSTFETCH_DIR "${CMAKE_SOURCE_DIR}/cmake/externals/Hooks/PostFetch")

# ==============================================================================
# _load_prefetch_hook - Load PreFetch hook if applicable
# ==============================================================================
#[[
    _load_prefetch_hook(EXT_NAME EXT_JSON)
    
    Loads a PreFetch hook based on convention or explicit configuration.
    PreFetch hooks run BEFORE FetchContent_MakeAvailable.
    
    Parameters:
        EXT_NAME - Name of the external
        EXT_JSON - JSON definition of the external
    
    Use Cases:
        - Set CMake options before external is configured
        - Disable examples/tests in the external
        - Set up cache variables
    
    Example Hook (cmake/externals/Hooks/PreFetch/spdlog.cmake):
        set(SPDLOG_BUILD_EXAMPLE OFF CACHE BOOL "" FORCE)
        set(SPDLOG_BUILD_TESTS OFF CACHE BOOL "" FORCE)
]]
function(_load_prefetch_hook EXT_NAME EXT_JSON)
    
    # ==========================================================================
    # Check for explicit hook path
    # ==========================================================================
    
    _json_has_key("${EXT_JSON}" "hooks" _has_hooks)
    
    set(_explicit_path "")
    set(_is_explicit FALSE)
    
    if(_has_hooks)
        _json_get_object("${EXT_JSON}" "hooks" _hooks_json)
        _json_has_key("${_hooks_json}" "preFetch" _has_prefetch)
        
        if(_has_prefetch)
            _json_get_string("${_hooks_json}" "preFetch" _explicit_path)
            set(_is_explicit TRUE)
        endif()
    endif()
    
    # ==========================================================================
    # Determine hook file path
    # ==========================================================================
    
    if(_is_explicit)
        # Explicit path specified
        set(_hook_file "${CMAKE_SOURCE_DIR}/${_explicit_path}")
        
        if(NOT EXISTS "${_hook_file}")
            cmake_fatal("E216" "External '${EXT_NAME}': preFetch hook not found: ${_explicit_path}")
        endif()
        
        dbg(${DBG_COMMON} "    PreFetch hook (explicit): ${_explicit_path}" ID EXTERNALS)
        
    else()
        # Convention path
        set(_hook_file "${HOOKS_PREFETCH_DIR}/${EXT_NAME}.cmake")
        
        if(NOT EXISTS "${_hook_file}")
            # No convention hook - this is fine
            dbg(${DBG_ULTRA_RARE} "    No PreFetch hook for ${EXT_NAME}" ID EXTERNALS)
            return()
        endif()
        
        dbg(${DBG_COMMON} "    PreFetch hook (convention): ${EXT_NAME}.cmake" ID EXTERNALS)
    endif()
    
    # ==========================================================================
    # Set variables for hook
    # ==========================================================================
    
    set(HOOK_EXTERNAL_NAME "${EXT_NAME}")
    set(HOOK_EXTERNAL_JSON "${EXT_JSON}")
    
    # ==========================================================================
    # Load hook
    # ==========================================================================
    
    include("${_hook_file}")
    
endfunction()

# ==============================================================================
# _load_postfetch_hook - Load PostFetch hook if applicable
# ==============================================================================
#[[
    _load_postfetch_hook(EXT_NAME EXT_JSON)
    
    Loads a PostFetch hook based on convention or explicit configuration.
    PostFetch hooks run AFTER FetchContent_MakeAvailable.
    
    Parameters:
        EXT_NAME - Name of the external
        EXT_JSON - JSON definition of the external
    
    Use Cases:
        - Create targets for externals without CMakeLists.txt (e.g. ImGui)
        - Register targets in the registry
        - Apply additional configuration to targets
    
    Example Hook (cmake/externals/Hooks/PostFetch/imgui.cmake):
        FetchContent_GetProperties(imgui)
        add_library(imgui STATIC
            ${imgui_SOURCE_DIR}/imgui.cpp
            ${imgui_SOURCE_DIR}/imgui_draw.cpp
            ...
        )
        target_include_directories(imgui PUBLIC ${imgui_SOURCE_DIR})
]]
function(_load_postfetch_hook EXT_NAME EXT_JSON)
    
    # ==========================================================================
    # Check for explicit hook path
    # ==========================================================================
    
    _json_has_key("${EXT_JSON}" "hooks" _has_hooks)
    
    set(_explicit_path "")
    set(_is_explicit FALSE)
    
    if(_has_hooks)
        _json_get_object("${EXT_JSON}" "hooks" _hooks_json)
        _json_has_key("${_hooks_json}" "postFetch" _has_postfetch)
        
        if(_has_postfetch)
            _json_get_string("${_hooks_json}" "postFetch" _explicit_path)
            set(_is_explicit TRUE)
        endif()
    endif()
    
    # ==========================================================================
    # Determine hook file path
    # ==========================================================================
    
    if(_is_explicit)
        # Explicit path specified
        set(_hook_file "${CMAKE_SOURCE_DIR}/${_explicit_path}")
        
        if(NOT EXISTS "${_hook_file}")
            cmake_fatal("E216" "External '${EXT_NAME}': postFetch hook not found: ${_explicit_path}")
        endif()
        
        dbg(${DBG_COMMON} "    PostFetch hook (explicit): ${_explicit_path}" ID EXTERNALS)
        
    else()
        # Convention path
        set(_hook_file "${HOOKS_POSTFETCH_DIR}/${EXT_NAME}.cmake")
        
        if(NOT EXISTS "${_hook_file}")
            # No convention hook - this is fine for externals with CMakeLists.txt
            dbg(${DBG_ULTRA_RARE} "    No PostFetch hook for ${EXT_NAME}" ID EXTERNALS)
            return()
        endif()
        
        dbg(${DBG_COMMON} "    PostFetch hook (convention): ${EXT_NAME}.cmake" ID EXTERNALS)
    endif()
    
    # ==========================================================================
    # Set variables for hook
    # ==========================================================================
    
    set(HOOK_EXTERNAL_NAME "${EXT_NAME}")
    set(HOOK_EXTERNAL_JSON "${EXT_JSON}")
    
    # Get source directory
    _get_external_source_dir("${EXT_NAME}" HOOK_SOURCE_DIR)
    
    # ==========================================================================
    # Load hook
    # ==========================================================================
    
    include("${_hook_file}")
    
endfunction()

# ==============================================================================
# _check_hook_requirements - Validate hook setup
# ==============================================================================
#[[
    _check_hook_requirements(EXT_NAME EXT_JSON OUT_NEEDS_POSTFETCH)
    
    Checks if an external requires a PostFetch hook (no CMakeLists.txt).
    
    Parameters:
        EXT_NAME          - Name of the external
        EXT_JSON          - JSON definition of the external
        OUT_NEEDS_POSTFETCH - Output: TRUE if PostFetch hook is required
]]
function(_check_hook_requirements EXT_NAME EXT_JSON OUT_NEEDS_POSTFETCH)
    
    # Check if external has cmakeSupport flag
    _json_has_key("${EXT_JSON}" "cmakeSupport" _has_cmake_flag)
    
    if(_has_cmake_flag)
        _json_get_bool_from_key("${EXT_JSON}" "cmakeSupport" _has_cmake)
        if(NOT _has_cmake)
            set(${OUT_NEEDS_POSTFETCH} TRUE PARENT_SCOPE)
            return()
        endif()
    endif()
    
    # Default: assume external has CMake support
    set(${OUT_NEEDS_POSTFETCH} FALSE PARENT_SCOPE)
    
endfunction()
