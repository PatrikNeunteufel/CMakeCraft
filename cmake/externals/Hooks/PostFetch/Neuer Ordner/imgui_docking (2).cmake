# ==============================================================================
# PostFetch/imgui_d.cmake – imgui_d PostFetch Hook
# ==============================================================================
#
# Hook:         imgui_d.cmake
# Version:      0.2.0
# Date:         2025-12-09
# Part of:      CMake Architecture V2
#
# Description:
#   PostFetch hook for Dear imgui_d.
#   imgui_d has no CMakeLists.txt, so we create the target manually.
#
#   Creates a combined 'imgui_d' target that includes:
#   - Core imgui_d
#   - OpenGL3 backend
#   - GLFW backend
#   - Win32 backend (Windows only)
#
# Expected Variables:
#   HOOK_EXTERNAL_NAME - "imgui_d"
#   HOOK_SOURCE_DIR    - Path to imgui_d source
#
# Based on:
#   - guidelines v0.1
#
# ==============================================================================

# Get source directory from FetchContent
string(TOLOWER "${HOOK_EXTERNAL_NAME}" _ext_lower)
FetchContent_GetProperties(${_ext_lower})

set(_imgui_d_src "${${_ext_lower}_SOURCE_DIR}")

message(STATUS "[imgui_d] Creating target from: ${_imgui_d_src}")

# ==============================================================================
# Collect Source Files
# ==============================================================================

set(_imgui_d_sources
    "${_imgui_d_src}/imgui.cpp"
    "${_imgui_d_src}/imgui_demo.cpp"
    "${_imgui_d_src}/imgui_draw.cpp"
    "${_imgui_d_src}/imgui_tables.cpp"
    "${_imgui_d_src}/imgui_widgets.cpp"
)

set(_imgui_d_includes
    "${_imgui_d_src}"
    "${_imgui_d_src}/backends"
)

set(_imgui_d_links "")

# ==============================================================================
# Add OpenGL3 Backend
# ==============================================================================

if(EXISTS "${_imgui_d_src}/backends/imgui_impl_opengl3.cpp")
    list(APPEND _imgui_d_sources "${_imgui_d_src}/backends/imgui_impl_opengl3.cpp")
    message(STATUS "[imgui_d]   + OpenGL3 backend")
endif()

# ==============================================================================
# Add GLFW Backend
# ==============================================================================

if(EXISTS "${_imgui_d_src}/backends/imgui_impl_glfw.cpp")
    list(APPEND _imgui_d_sources "${_imgui_d_src}/backends/imgui_impl_glfw.cpp")
    message(STATUS "[imgui_d]   + GLFW backend")
endif()

# ==============================================================================
# Add Win32 Backend (Windows only)
# ==============================================================================

if(WIN32 AND EXISTS "${_imgui_d_src}/backends/imgui_impl_win32.cpp")
    list(APPEND _imgui_d_sources "${_imgui_d_src}/backends/imgui_impl_win32.cpp")
    message(STATUS "[imgui_d]   + Win32 backend")
endif()

# ==============================================================================
# Create Combined imgui_d Library
# ==============================================================================

add_library(imgui_d STATIC ${_imgui_d_sources})

target_include_directories(imgui_d PUBLIC ${_imgui_d_includes})

# C++ Standard
target_compile_features(imgui_d PUBLIC cxx_std_11)

# Suppress warnings in external code
if(MSVC)
    target_compile_options(imgui_d PRIVATE /W0)
else()
    target_compile_options(imgui_d PRIVATE -w)
endif()

# ==============================================================================
# Link Dependencies
# ==============================================================================

# Link GLAD if available (for OpenGL3 backend)
if(TARGET glad)
    target_link_libraries(imgui_d PUBLIC glad)
    target_compile_definitions(imgui_d PRIVATE IMGUI_IMPL_OPENGL_LOADER_GLAD)
    message(STATUS "[imgui_d]   Linked: glad")
endif()

# Link GLFW if available (for GLFW backend)
if(TARGET glfw)
    target_link_libraries(imgui_d PUBLIC glfw)
    message(STATUS "[imgui_d]   Linked: glfw")
endif()

# ==============================================================================
# Register Target
# ==============================================================================

_register_external_target("imgui_d" "imgui_d" PRIMARY)

message(STATUS "[imgui_d] Target 'imgui_d' created (combined with backends)")
message(STATUS "[imgui_d] PostFetch hook complete")
