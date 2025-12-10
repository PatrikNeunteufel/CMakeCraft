# ==============================================================================
# PostFetch/imgui.cmake – ImGui PostFetch Hook
# ==============================================================================
#
# Hook:         imgui.cmake
# Version:      0.1.0
# Date:         2025-12-09
# Part of:      CMake Architecture V2
#
# Description:
#   PostFetch hook for Dear ImGui.
#   ImGui has no CMakeLists.txt, so we create the target manually.
#
# Creates:
#   - imgui (STATIC library)
#
# Expected Variables:
#   HOOK_EXTERNAL_NAME - "imgui"
#   HOOK_SOURCE_DIR    - Path to imgui source
#
# Based on:
#   - guidelines v0.1
#
# ==============================================================================

# Get source directory from FetchContent
string(TOLOWER "${HOOK_EXTERNAL_NAME}" _ext_lower)
FetchContent_GetProperties(${_ext_lower})

set(_imgui_src "${${_ext_lower}_SOURCE_DIR}")

message(STATUS "[imgui] Creating target from: ${_imgui_src}")

# ==============================================================================
# Core ImGui Library
# ==============================================================================

add_library(imgui STATIC
    "${_imgui_src}/imgui.cpp"
    "${_imgui_src}/imgui_demo.cpp"
    "${_imgui_src}/imgui_draw.cpp"
    "${_imgui_src}/imgui_tables.cpp"
    "${_imgui_src}/imgui_widgets.cpp"
)

target_include_directories(imgui PUBLIC
    "${_imgui_src}"
)

# C++ Standard
target_compile_features(imgui PUBLIC cxx_std_11)

# ==============================================================================
# Register Target
# ==============================================================================

_register_external_target("imgui" "imgui" PRIMARY)

message(STATUS "[imgui] Target 'imgui' created")

# ==============================================================================
# Optional: Backend Libraries
# ==============================================================================

# Check if we should create backend targets
# This could be controlled by external_options in the future

# OpenGL3 Backend (requires GLAD)
if(EXISTS "${_imgui_src}/backends/imgui_impl_opengl3.cpp")
    add_library(imgui_impl_opengl3 STATIC
        "${_imgui_src}/backends/imgui_impl_opengl3.cpp"
    )
    target_include_directories(imgui_impl_opengl3 PUBLIC
        "${_imgui_src}"
        "${_imgui_src}/backends"
    )
    target_link_libraries(imgui_impl_opengl3 PUBLIC imgui)
    
    # Link GLAD if available
    if(TARGET glad)
        target_link_libraries(imgui_impl_opengl3 PUBLIC glad)
    endif()
    
    _register_external_target("imgui" "imgui_impl_opengl3")
    message(STATUS "[imgui] Target 'imgui_impl_opengl3' created")
endif()

# Win32 Backend
if(WIN32 AND EXISTS "${_imgui_src}/backends/imgui_impl_win32.cpp")
    add_library(imgui_impl_win32 STATIC
        "${_imgui_src}/backends/imgui_impl_win32.cpp"
    )
    target_include_directories(imgui_impl_win32 PUBLIC
        "${_imgui_src}"
        "${_imgui_src}/backends"
    )
    target_link_libraries(imgui_impl_win32 PUBLIC imgui)
    
    _register_external_target("imgui" "imgui_impl_win32")
    message(STATUS "[imgui] Target 'imgui_impl_win32' created")
endif()

# GLFW Backend
if(EXISTS "${_imgui_src}/backends/imgui_impl_glfw.cpp")
    add_library(imgui_impl_glfw STATIC
        "${_imgui_src}/backends/imgui_impl_glfw.cpp"
    )
    target_include_directories(imgui_impl_glfw PUBLIC
        "${_imgui_src}"
        "${_imgui_src}/backends"
    )
    target_link_libraries(imgui_impl_glfw PUBLIC imgui)
    
    # Link GLFW if available
    if(TARGET glfw)
        target_link_libraries(imgui_impl_glfw PUBLIC glfw)
    endif()
    
    _register_external_target("imgui" "imgui_impl_glfw")
    message(STATUS "[imgui] Target 'imgui_impl_glfw' created")
endif()

message(STATUS "[imgui] PostFetch hook complete")
