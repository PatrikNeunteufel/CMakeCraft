# cmake/externals/system/PathResolver.cmake
# ==========================================
# Generic path resolution for system externals
#
# Version: 0.6.0
# Date:    2025-12-18
# Status:  Development
# Author:  CMake Architecture V2 Team
# Phase:   9
#
# Dependencies:
#   - cmake/core/Debug.cmake
#
# Provides:
#   - _resolve_system_path(EXT_NAME PACKAGE HINTS ADDITIONAL_PATHS BACKUP OUT_PATH OUT_IS_BACKUP)
#
# Search Order:
#   1. Environment variables: ${PACKAGE}_ROOT, ${PACKAGE}_DIR, ${PACKAGE}_HOME
#   2. hints[] from Solution.json
#   3. Package-specific standard paths (from package hook)
#   4. backup path (with warning)
#   5. Let find_package() handle it
#
# Used by:
#   - system/Handler.cmake

include_guard(GLOBAL)

# ==============================================================================
# _resolve_system_path - Multi-stage path resolution
# ==============================================================================
#[[
    _resolve_system_path(EXT_NAME PACKAGE HINTS ADDITIONAL_PATHS BACKUP OUT_PATH OUT_IS_BACKUP)
    
    Resolves the installation path for a system package.
    
    Parameters:
        EXT_NAME         - Name of the external (for debug output)
        PACKAGE          - Package name (e.g. "Qt6", "Boost")
        HINTS            - CMake list of hint paths from Solution.json
        ADDITIONAL_PATHS - CMake list of paths from package hook
        BACKUP           - Backup path (string, may be empty)
        OUT_PATH         - Output: resolved path or empty
        OUT_IS_BACKUP    - Output: TRUE if backup was used
    
    Search Priority:
        1. Environment variables (${PACKAGE}_ROOT, ${PACKAGE}_DIR, ${PACKAGE}_HOME)
        2. hints[] from Solution.json
        3. Package-specific standard paths
        4. backup path (triggers warning in caller)
    
    If nothing found, returns empty path and lets find_package() try its defaults.
    
    Example:
        _resolve_system_path("qt6" "Qt6" "${_hints}" "${_std_paths}" "${_backup}" 
                             _path _is_backup)
]]
function(_resolve_system_path EXT_NAME PACKAGE HINTS ADDITIONAL_PATHS BACKUP OUT_PATH OUT_IS_BACKUP)
    set(_found FALSE)
    set(_result_path "")
    set(_is_backup FALSE)
    
    # =========================================================================
    # Stage 1: Environment Variables
    # =========================================================================
    
    foreach(_var_suffix ROOT DIR HOME)
        set(_var_name "${PACKAGE}_${_var_suffix}")
        if(DEFINED ENV{${_var_name}})
            set(_candidate "$ENV{${_var_name}}")
            if(EXISTS "${_candidate}")
                set(_found TRUE)
                set(_result_path "${_candidate}")
                dbg(${DBG_RARE} "  [${EXT_NAME}] Found via ENV ${_var_name}: ${_candidate}" ID EXTERNALS)
                break()
            else()
                dbg(${DBG_ULTRA_RARE} "  [${EXT_NAME}] ENV ${_var_name} set but path doesn't exist: ${_candidate}" ID EXTERNALS)
            endif()
        endif()
    endforeach()
    
    # =========================================================================
    # Stage 2: hints[] from Solution.json
    # =========================================================================
    
    if(NOT _found AND HINTS)
        foreach(_hint IN LISTS HINTS)
            # Expand environment variables in hint
            # Supports both ${VAR} and $ENV{VAR} syntax
            string(CONFIGURE "${_hint}" _hint_expanded @ONLY)
            
            # Also try direct env var replacement
            if(_hint_expanded MATCHES "^\\\$\\{([^}]+)\\}$")
                set(_env_var "${CMAKE_MATCH_1}")
                if(DEFINED ENV{${_env_var}})
                    set(_hint_expanded "$ENV{${_env_var}}")
                endif()
            endif()
            
            if(EXISTS "${_hint_expanded}")
                set(_found TRUE)
                set(_result_path "${_hint_expanded}")
                dbg(${DBG_RARE} "  [${EXT_NAME}] Found via hint: ${_hint_expanded}" ID EXTERNALS)
                break()
            else()
                dbg(${DBG_ULTRA_RARE} "  [${EXT_NAME}] Hint path doesn't exist: ${_hint_expanded}" ID EXTERNALS)
            endif()
        endforeach()
    endif()
    
    # =========================================================================
    # Stage 3: Package-specific standard paths (from hook)
    # =========================================================================
    
    if(NOT _found AND ADDITIONAL_PATHS)
        foreach(_path IN LISTS ADDITIONAL_PATHS)
            # Expand environment variables
            string(CONFIGURE "${_path}" _path_expanded @ONLY)
            
            if(EXISTS "${_path_expanded}")
                set(_found TRUE)
                set(_result_path "${_path_expanded}")
                dbg(${DBG_RARE} "  [${EXT_NAME}] Found at standard path: ${_path_expanded}" ID EXTERNALS)
                break()
            else()
                dbg(${DBG_ULTRA_RARE} "  [${EXT_NAME}] Standard path doesn't exist: ${_path_expanded}" ID EXTERNALS)
            endif()
        endforeach()
    endif()
    
    # =========================================================================
    # Stage 4: Backup path (with warning in caller)
    # =========================================================================
    
    if(NOT _found AND NOT "${BACKUP}" STREQUAL "")
        # Expand environment variables
        string(CONFIGURE "${BACKUP}" _backup_expanded @ONLY)
        
        if(EXISTS "${_backup_expanded}")
            set(_found TRUE)
            set(_result_path "${_backup_expanded}")
            set(_is_backup TRUE)
            dbg(${DBG_RARE} "  [${EXT_NAME}] Found at BACKUP: ${_backup_expanded}" ID EXTERNALS)
        else()
            dbg(${DBG_ULTRA_RARE} "  [${EXT_NAME}] Backup path doesn't exist: ${_backup_expanded}" ID EXTERNALS)
        endif()
    endif()
    
    # =========================================================================
    # Result
    # =========================================================================
    
    if(_found)
        set(${OUT_PATH} "${_result_path}" PARENT_SCOPE)
        set(${OUT_IS_BACKUP} ${_is_backup} PARENT_SCOPE)
    else()
        # No path found - let find_package() try its default locations
        set(${OUT_PATH} "" PARENT_SCOPE)
        set(${OUT_IS_BACKUP} FALSE PARENT_SCOPE)
        dbg(${DBG_RARE} "  [${EXT_NAME}] No explicit path found, relying on find_package() defaults" ID EXTERNALS)
    endif()
    
endfunction()
