# ==============================================================================
# PostFetch/imgui.cmake – ImGui PostFetch Hook
# ==============================================================================
#
# Hook:         imgui.cmake
# Version:      0.2.0
# Date:         2025-12-09
# Part of:      CMake Architecture V2
#
# Description:
#   PostFetch hook for Dear ImGui.
#   ImGui has no CMakeLists.txt, so we create the target manually.
#
#   Creates a combined 'imgui' target that includes:
#   - Core ImGui
#   - OpenGL3 backend
#   - GLFW backend
#   - Win32 backend (Windows only)
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
# Collect Source Files
# ==============================================================================

set(_imgui_sources
    "${_imgui_src}/imgui.cpp"
    "${_imgui_src}/imgui_demo.cpp"
    "${_imgui_src}/imgui_draw.cpp"
    "${_imgui_src}/imgui_tables.cpp"
    "${_imgui_src}/imgui_widgets.cpp"
)

set(_imgui_includes
    "${_imgui_src}"
    "${_imgui_src}/backends"
)

set(_imgui_links "")

# ==============================================================================
# Add OpenGL3 Backend
# ==============================================================================

if(EXISTS "${_imgui_src}/backends/imgui_impl_opengl3.cpp")
    list(APPEND _imgui_sources "${_imgui_src}/backends/imgui_impl_opengl3.cpp")
    message(STATUS "[imgui]   + OpenGL3 backend")
endif()

# ==============================================================================
# Add GLFW Backend
# ==============================================================================

if(EXISTS "${_imgui_src}/backends/imgui_impl_glfw.cpp")
    list(APPEND _imgui_sources "${_imgui_src}/backends/imgui_impl_glfw.cpp")
    message(STATUS "[imgui]   + GLFW backend")
endif()

# ==============================================================================
# Add Win32 Backend (Windows only)
# ==============================================================================

if(WIN32 AND EXISTS "${_imgui_src}/backends/imgui_impl_win32.cpp")
    list(APPEND _imgui_sources "${_imgui_src}/backends/imgui_impl_win32.cpp")
    message(STATUS "[imgui]   + Win32 backend")
endif()

# ==============================================================================
# Create Combined ImGui Library
# ==============================================================================

add_library(imgui STATIC ${_imgui_sources})

target_include_directories(imgui PUBLIC ${_imgui_includes})

# C++ Standard
target_compile_features(imgui PUBLIC cxx_std_11)

# Suppress warnings in external code
if(MSVC)
    target_compile_options(imgui PRIVATE /W0)
else()
    target_compile_options(imgui PRIVATE -w)
endif()

# ==============================================================================
# Link Dependencies
# ==============================================================================

# Link GLAD if available (for OpenGL3 backend)
if(TARGET glad)
    target_link_libraries(imgui PUBLIC glad)
    target_compile_definitions(imgui PRIVATE IMGUI_IMPL_OPENGL_LOADER_GLAD)
    message(STATUS "[imgui]   Linked: glad")
endif()

# Link GLFW if available (for GLFW backend)
if(TARGET glfw)
    target_link_libraries(imgui PUBLIC glfw)
    message(STATUS "[imgui]   Linked: glfw")
endif()

# ==============================================================================
# Register Target
# ==============================================================================

_register_external_target("imgui" "imgui" PRIMARY)

message(STATUS "[imgui] Target 'imgui' created (combined with backends)")
message(STATUS "[imgui] PostFetch hook complete")
