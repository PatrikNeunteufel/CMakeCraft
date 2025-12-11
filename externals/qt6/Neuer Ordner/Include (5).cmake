# ==============================================================================
# externals/qt6/Include.cmake – Qt6 Integration
# ==============================================================================
#
# Module:       Include.cmake (Qt6)
# Version:      0.2.0
# Date:         2025-12-10
# Part of:      CMake Architecture V2
#
# Description:
#   Flexible Qt6 integration supporting multiple installation methods:
#   - Qt Installer (Windows/macOS)
#   - System packages (Linux)
#   - Manual extraction (Zip/tar.xz)
#   - Environment variable configuration
#   - Backup location (USB stick, network drive)
#
# Configuration (in order of priority):
#   1. QT_ROOT environment variable
#   2. QT6_DIR environment variable  
#   3. CMAKE_PREFIX_PATH
#   4. Solution.json "hint" field
#   5. Common installation paths (auto-detection)
#   6. Solution.json "backup" field (with WARNING)
#
# Usage in Solution.json:
#   "qt6": {
#       "path": "externals/qt6",
#       "options": {
#           "components": ["Core", "Widgets", "Gui"],
#           "hint": "D:/Libs/Qt/6.7.0/msvc2022_64",
#           "backup": "E:/Backup/Qt/6.7.0/msvc2022_64"
#       }
#   }
#
# Environment Variables:
#   QT_ROOT  - Root of Qt installation (e.g., C:/Qt/6.7.0/msvc2022_64)
#   QT6_DIR  - Alternative to QT_ROOT
#
# Changes v0.2.0:
#   - Added backup path support with WARNING
#   - Improved path resolution logging
#   - Better error messages
#
# ==============================================================================

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

if(NOT _QT6_FOUND)
    # Build helpful error message with searched paths
    set(_searched_paths_msg "")
    foreach(_path IN LISTS _QT6_SEARCH_PATHS)
        string(APPEND _searched_paths_msg "    - ${_path}\n")
    endforeach()
    if(_backup_path)
        string(APPEND _searched_paths_msg "    - ${_backup_path} (backup)\n")
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
else()
    message(STATUS "[qt6]   No EXECUTABLE_NAME defined (first-time setup)")
endif()

# ==============================================================================
# Register Target (for reference)
# ==============================================================================

# Register main target
_register_external_target("qt6" "qt6" PRIMARY)

# ==============================================================================
# Qt-specific Configuration
# ==============================================================================

# Enable automatic MOC, UIC, RCC
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

message(STATUS "[qt6]   AUTOMOC/AUTOUIC/AUTORCC enabled")

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
