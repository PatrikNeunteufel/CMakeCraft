# cmake/externals/includes/qt6/Include.cmake
# ============================================
# Qt6 integration - finds system Qt6 and configures deployment
#
# Version: 0.6.0
# Date:    2025-12-16
# Status:  Development
# Author:  CMake Architecture V2 Team
# Type:    Local External Include (System Library)
#
# Dependencies:
#   - Qt6 installation (Online Installer, system packages, Homebrew)
#   - cmake/externals/Registry/Targets.cmake (_register_external_target)
#
# Expected Variables (set by Orchestrator):
#   - EXTERNAL_NAME    - "qt6"
#   - EXTERNAL_OPTIONS - JSON string with components/hint/backup
#   - EXECUTABLE_NAME  - Target to attach to
#
# Note: EXTERNAL_ROOT is not used - Qt6 is found via find_package
#
# Path Resolution (priority order):
#   1. QT_ROOT environment variable
#   2. QT6_DIR environment variable
#   3. CMAKE_PREFIX_PATH
#   4. Solution.json "hint" field
#   5. Common installation paths (auto-detection)
#   6. Solution.json "backup" field (with WARNING)
#
# Available Options (via external_options in Solution.json):
#   - components - Array of Qt modules ["Core", "Widgets", "Gui", ...]
#   - hint       - Primary Qt installation path
#   - backup     - Fallback path (USB stick, network drive)
#
# Provides:
#   - qt6 (INTERFACE target linking all requested components)
#   - AUTOMOC/AUTOUIC/AUTORCC enabled per-target
#   - Platform-specific deployment (windeployqt, macdeployqt, RPATH)
#
# Used by:
#   - Orchestrator.cmake (via apply_external_to_target)

include_guard(GLOBAL)

message(STATUS "[qt6] Configuring Qt6 integration")

# ==============================================================================
# Configuration
# ==============================================================================

# Default components if not specified
set(_QT6_DEFAULT_COMPONENTS
    Core
    Gui
    Widgets
)

# Get components from options or use defaults
if(DEFINED _EXTERNAL_OPTIONS)
    string(JSON _components_json ERROR_VARIABLE _err GET "${_EXTERNAL_OPTIONS}" "components")
    if(NOT _err)
        # Parse JSON array
        set(_QT6_COMPONENTS "")
        string(JSON _comp_count LENGTH "${_components_json}")
        if(_comp_count GREATER 0)
            math(EXPR _last_idx "${_comp_count} - 1")
            foreach(_idx RANGE 0 ${_last_idx})
                string(JSON _comp GET "${_components_json}" ${_idx})
                list(APPEND _QT6_COMPONENTS "${_comp}")
            endforeach()
        endif()
    else()
        set(_QT6_COMPONENTS ${_QT6_DEFAULT_COMPONENTS})
    endif()
    
    # Get hint path from options
    string(JSON _hint_path ERROR_VARIABLE _err GET "${_EXTERNAL_OPTIONS}" "hint")
    if(_err)
        set(_hint_path "")
    endif()
    
    # Get backup path from options
    string(JSON _backup_path ERROR_VARIABLE _err GET "${_EXTERNAL_OPTIONS}" "backup")
    if(_err)
        set(_backup_path "")
    endif()
else()
    set(_QT6_COMPONENTS ${_QT6_DEFAULT_COMPONENTS})
    set(_hint_path "")
    set(_backup_path "")
endif()

message(STATUS "[qt6]   Requested components: ${_QT6_COMPONENTS}")

# ==============================================================================
# Qt6 Path Detection
# ==============================================================================

set(_QT6_SEARCH_PATHS "")

# Priority 1: Environment variable QT_ROOT
if(DEFINED ENV{QT_ROOT})
    list(APPEND _QT6_SEARCH_PATHS "$ENV{QT_ROOT}")
    message(STATUS "[qt6]   Found QT_ROOT: $ENV{QT_ROOT}")
endif()

# Priority 2: Environment variable QT6_DIR
if(DEFINED ENV{QT6_DIR})
    list(APPEND _QT6_SEARCH_PATHS "$ENV{QT6_DIR}")
    message(STATUS "[qt6]   Found QT6_DIR: $ENV{QT6_DIR}")
endif()

# Priority 3: Hint from Solution.json
if(_hint_path)
    # Expand environment variables in hint
    string(REPLACE "\${" "$ENV{" _hint_expanded "${_hint_path}")
    string(CONFIGURE "${_hint_expanded}" _hint_expanded)
    list(APPEND _QT6_SEARCH_PATHS "${_hint_expanded}")
    message(STATUS "[qt6]   Hint path: ${_hint_expanded}")
endif()

# Priority 4: Common installation paths
if(WIN32)
    # Qt Installer default locations (newest first)
    list(APPEND _QT6_SEARCH_PATHS
        "C:/Qt/6.10.1/msvc2022_64"
        "C:/Qt/6.10.0/msvc2022_64"
        "C:/Qt/6.9.0/msvc2022_64"
        "C:/Qt/6.8.0/msvc2022_64"
        "C:/Qt/6.7.0/msvc2022_64"
        "C:/Qt/6.6.0/msvc2022_64"
        "C:/Qt/6.5.0/msvc2022_64"
        "D:/Qt/6.10.1/msvc2022_64"
        "D:/Qt/6.10.0/msvc2022_64"
        "D:/Qt/6.8.0/msvc2022_64"
        "D:/Qt/6.7.0/msvc2022_64"
        "I:/Qt/6.10.1/msvc2022_64"
        "E:/Qt/6.10.1/msvc2022_64"
    )
elseif(APPLE)
    list(APPEND _QT6_SEARCH_PATHS
        "$ENV{HOME}/Qt/6.10.1/macos"
        "$ENV{HOME}/Qt/6.10.0/macos"
        "$ENV{HOME}/Qt/6.8.0/macos"
        "$ENV{HOME}/Qt/6.7.0/macos"
        "/opt/homebrew/opt/qt@6"
        "/usr/local/opt/qt@6"
    )
else()
    # Linux
    list(APPEND _QT6_SEARCH_PATHS
        "$ENV{HOME}/Qt/6.10.1/gcc_64"
        "$ENV{HOME}/Qt/6.10.0/gcc_64"
        "$ENV{HOME}/Qt/6.8.0/gcc_64"
        "$ENV{HOME}/Qt/6.7.0/gcc_64"
        "/opt/Qt/6.10.1/gcc_64"
        "/opt/Qt/6.8.0/gcc_64"
        "/opt/Qt/6.7.0/gcc_64"
        "/usr/lib/qt6"
        "/usr/lib/x86_64-linux-gnu/qt6"
    )
endif()

# ==============================================================================
# Find Qt6
# ==============================================================================

set(_QT6_FOUND FALSE)
set(_QT6_PREFIX "")
set(_QT6_IS_BACKUP FALSE)

# Search in priority order
foreach(_path IN LISTS _QT6_SEARCH_PATHS)
    if(EXISTS "${_path}")
        # Check if this is a valid Qt installation
        if(EXISTS "${_path}/lib/cmake/Qt6" OR EXISTS "${_path}/lib/cmake/Qt6Core")
            set(_QT6_FOUND TRUE)
            set(_QT6_PREFIX "${_path}")
            message(STATUS "[qt6]   Found Qt6 at: ${_path}")
            break()
        endif()
    endif()
endforeach()

# ==============================================================================
# Backup Path (Priority 6 - with WARNING)
# ==============================================================================

if(NOT _QT6_FOUND AND _backup_path)
    # Expand environment variables in backup path
    string(REPLACE "\${" "$ENV{" _backup_expanded "${_backup_path}")
    string(CONFIGURE "${_backup_expanded}" _backup_expanded)
    
    if(EXISTS "${_backup_expanded}")
        if(EXISTS "${_backup_expanded}/lib/cmake/Qt6" OR EXISTS "${_backup_expanded}/lib/cmake/Qt6Core")
            set(_QT6_FOUND TRUE)
            set(_QT6_PREFIX "${_backup_expanded}")
            set(_QT6_IS_BACKUP TRUE)
            
            message(WARNING 
                "[qt6] Primary Qt6 installation not found!\n"
                "  Using BACKUP location: ${_backup_expanded}\n"
                "  \n"
                "  This may be slower (USB/network drive) and is not recommended for production.\n"
                "  \n"
                "  To fix, set one of:\n"
                "    - Environment variable QT_ROOT\n"
                "    - Environment variable QT6_DIR\n"
                "    - Install Qt6 to a standard location\n"
            )
        endif()
    endif()
endif()

# ==============================================================================
# Error if not found
# ==============================================================================
message("QtQtQtQtQtQtQtQtQtQtQtQtQtQtQtQtQtQtQtQt")
if(NOT _QT6_FOUND)
    # Build helpful error message with searched paths
    set(_searched_paths_msg "")
    foreach(_path IN LISTS _QT6_SEARCH_PATHS)
        string(APPEND _searched_paths_msg "    - ${_path}\n")
    endforeach()
    if(_backup_path)
        string(APPEND _searched_paths_msg "    - ${_backup_path} (backup)\n")
        message("looking BACKUP path: ${_backup_path}")
    endif()
    
    message(FATAL_ERROR 
        "[qt6] Qt6 not found!\n"
        "  \n"
        "  Searched paths:\n"
        "${_searched_paths_msg}"
        "  \n"
        "  Please set one of:\n"
        "    - Environment variable QT_ROOT (recommended)\n"
        "    - Environment variable QT6_DIR\n"
        "    - 'hint' in Solution.json options\n"
        "    - 'backup' in Solution.json options\n"
        "  \n"
        "  Example (Windows CMD):\n"
        "    set QT_ROOT=C:/Qt/6.7.0/msvc2022_64\n"
        "  \n"
        "  Example (Solution.json):\n"
        "    \"options\": { \"hint\": \"C:/Qt/6.7.0/msvc2022_64\" }\n"
    )
endif()

# ==============================================================================
# Configure CMake to find Qt6
# ==============================================================================

# Add to CMAKE_PREFIX_PATH
list(PREPEND CMAKE_PREFIX_PATH "${_QT6_PREFIX}")

# Find Qt6 package with requested components
find_package(Qt6 REQUIRED COMPONENTS ${_QT6_COMPONENTS})

message(STATUS "[qt6]   Qt6 Version: ${Qt6_VERSION}")
message(STATUS "[qt6]   Qt6 Prefix: ${_QT6_PREFIX}")

# ==============================================================================
# Create Convenience Target
# ==============================================================================

# Create a non-imported interface target that links all requested components
# Using a regular INTERFACE library instead of IMPORTED for better propagation
if(NOT TARGET qt6)
    add_library(qt6 INTERFACE)
    
    foreach(_comp IN LISTS _QT6_COMPONENTS)
        if(TARGET Qt6::${_comp})
            target_link_libraries(qt6 INTERFACE Qt6::${_comp})
            message(STATUS "[qt6]   Added component: Qt6::${_comp}")
        endif()
    endforeach()
endif()

# ==============================================================================
# Link to Executable (like BASS Include.cmake pattern)
# ==============================================================================

# EXECUTABLE_NAME is set by Orchestrator before including this file
if(DEFINED EXECUTABLE_NAME AND TARGET ${EXECUTABLE_NAME})
    target_link_libraries(${EXECUTABLE_NAME} PRIVATE qt6)
    message(STATUS "[qt6]   Linked qt6 to ${EXECUTABLE_NAME}")
    
    # Enable AUTOMOC/AUTOUIC/AUTORCC for this target specifically
    set_target_properties(${EXECUTABLE_NAME} PROPERTIES
        AUTOMOC ON
        AUTOUIC ON
        AUTORCC ON
    )
    message(STATUS "[qt6]   AUTOMOC/AUTOUIC/AUTORCC enabled for ${EXECUTABLE_NAME}")
    
    # ==========================================================================
    # Platform-specific Deployment
    # ==========================================================================
    
    if(WIN32)
        # ======================================================================
        # Windows: DLL Deployment
        # ======================================================================
        
        # Use windeployqt to copy all required Qt DLLs
        find_program(_WINDEPLOYQT windeployqt HINTS "${_QT6_PREFIX}/bin")
        
        if(_WINDEPLOYQT)
            # Run windeployqt after build to copy all required DLLs
            add_custom_command(TARGET ${EXECUTABLE_NAME} POST_BUILD
                COMMAND "${_WINDEPLOYQT}"
                    --no-translations
                    --no-system-d3d-compiler
                    --no-opengl-sw
                    "$<TARGET_FILE:${EXECUTABLE_NAME}>"
                COMMENT "[qt6] Running windeployqt for ${EXECUTABLE_NAME}..."
                VERBATIM
            )
            message(STATUS "[qt6]   windeployqt will copy DLLs after build")
        else()
            # Fallback: Manual DLL copy for core components
            message(STATUS "[qt6]   windeployqt not found, using manual DLL copy")
            
            set(_qt6_bin_dir "${_QT6_PREFIX}/bin")
            
            foreach(_comp IN LISTS _QT6_COMPONENTS)
                # Use generator expression for Debug/Release DLL selection
                # This works for both single-config (Ninja) and multi-config (VS) generators
                set(_dll_debug "${_qt6_bin_dir}/Qt6${_comp}d.dll")
                set(_dll_release "${_qt6_bin_dir}/Qt6${_comp}.dll")
                
                # Copy Debug DLL if it exists
                if(EXISTS "${_dll_debug}")
                    add_custom_command(TARGET ${EXECUTABLE_NAME} POST_BUILD
                        COMMAND ${CMAKE_COMMAND} -E 
                            $<IF:$<CONFIG:Debug>,copy_if_different,true>
                            "${_dll_debug}"
                            "$<TARGET_FILE_DIR:${EXECUTABLE_NAME}>"
                        COMMENT "[qt6] Copying Qt6${_comp}d.dll (Debug)"
                    )
                endif()
                
                # Copy Release DLL if it exists
                if(EXISTS "${_dll_release}")
                    add_custom_command(TARGET ${EXECUTABLE_NAME} POST_BUILD
                        COMMAND ${CMAKE_COMMAND} -E 
                            $<IF:$<NOT:$<CONFIG:Debug>>,copy_if_different,true>
                            "${_dll_release}"
                            "$<TARGET_FILE_DIR:${EXECUTABLE_NAME}>"
                        COMMENT "[qt6] Copying Qt6${_comp}.dll (Release)"
                    )
                endif()
            endforeach()
        endif()
        
    elseif(APPLE)
        # ======================================================================
        # macOS: Bundle Deployment
        # ======================================================================
        
        find_program(_MACDEPLOYQT macdeployqt HINTS "${_QT6_PREFIX}/bin")
        
        if(_MACDEPLOYQT)
            # Only run macdeployqt for bundle targets
            get_target_property(_is_bundle ${EXECUTABLE_NAME} MACOSX_BUNDLE)
            if(_is_bundle)
                add_custom_command(TARGET ${EXECUTABLE_NAME} POST_BUILD
                    COMMAND "${_MACDEPLOYQT}"
                        "$<TARGET_BUNDLE_DIR:${EXECUTABLE_NAME}>"
                        -always-overwrite
                    COMMENT "[qt6] Running macdeployqt for ${EXECUTABLE_NAME}..."
                    VERBATIM
                )
                message(STATUS "[qt6]   macdeployqt will deploy bundle after build")
            else()
                message(STATUS "[qt6]   Not a bundle target, skipping macdeployqt")
            endif()
        else()
            message(STATUS "[qt6]   macdeployqt not found")
        endif()
        
        # Set RPATH for non-bundle executables
        set_target_properties(${EXECUTABLE_NAME} PROPERTIES
            INSTALL_RPATH "@executable_path/../lib;${_QT6_PREFIX}/lib"
            BUILD_RPATH "${_QT6_PREFIX}/lib"
        )
        
    else()
        # ======================================================================
        # Linux: RPATH Configuration
        # ======================================================================
        
        # Set RPATH so the executable finds Qt libraries at runtime
        # This avoids the need to set LD_LIBRARY_PATH
        set_target_properties(${EXECUTABLE_NAME} PROPERTIES
            # For installed binaries: look in ../lib relative to executable
            INSTALL_RPATH "$ORIGIN/../lib;${_QT6_PREFIX}/lib"
            # For build directory: use Qt's lib path directly
            BUILD_RPATH "${_QT6_PREFIX}/lib"
            # Don't remove RPATH during install
            INSTALL_RPATH_USE_LINK_PATH TRUE
        )
        message(STATUS "[qt6]   RPATH configured for Linux")
        
        # Optional: linuxdeployqt (not standard, but useful for AppImage)
        find_program(_LINUXDEPLOYQT linuxdeployqt)
        if(_LINUXDEPLOYQT)
            message(STATUS "[qt6]   linuxdeployqt found (can be used for AppImage)")
        endif()
    endif()
else()
    message(STATUS "[qt6]   No EXECUTABLE_NAME defined (first-time setup)")
endif()

# ==============================================================================
# Register Target (for reference)
# ==============================================================================

# Register main target
_register_external_target("qt6" "qt6" PRIMARY)

# ==============================================================================
# Export Variables
# ==============================================================================

set(QT6_FOUND TRUE PARENT_SCOPE)
set(QT6_PREFIX "${_QT6_PREFIX}" PARENT_SCOPE)
set(QT6_VERSION "${Qt6_VERSION}" PARENT_SCOPE)
set(QT6_IS_BACKUP ${_QT6_IS_BACKUP} PARENT_SCOPE)

if(_QT6_IS_BACKUP)
    message(STATUS "[qt6] Configuration complete (using BACKUP location)")
else()
    message(STATUS "[qt6] Configuration complete")
endif()
