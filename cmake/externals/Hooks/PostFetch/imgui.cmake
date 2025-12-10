# ==============================================================================
# PostFetch/imgui.cmake – ImGui PostFetch Hook
# ==============================================================================
#
# Hook:         imgui.cmake
# Version:      0.3.0
# Date:         2025-12-10
# Part of:      CMake Architecture V2
#
# Description:
#   PostFetch hook for Dear ImGui.
#   ImGui has no CMakeLists.txt, so we create the target manually.
#
#   Creates a combined target that includes:
#   - Core ImGui
#   - OpenGL3 backend
#   - GLFW backend
#   - Win32 backend (Windows only)
#
# Hook Reuse:
#   This hook can be reused for ImGui variants via "hook" field:
#   
#   "imgui": { "git": "...", "tag": "v1.91.6", "cmakeSupport": false }
#   "imgui_docking": { "git": "...", "tag": "v1.91.6-docking", "cmakeSupport": false, "hook": "imgui" }
#
#   Each variant gets its own target (imgui, imgui_docking) using HOOK_EXTERNAL_NAME.
#
# Provided Variables (from HookLoader):
#   HOOK_EXTERNAL_NAME - Name of the external (e.g. "imgui" or "imgui_docking")
#   HOOK_SOURCE_DIR    - Path to imgui source
#   HOOK_EXTERNAL_JSON - JSON definition
#
# IMPORTANT:
#   Always use ${HOOK_EXTERNAL_NAME} for target names!
#   This allows hook reuse for variants.
#
# Changes v0.3.0:
#   - Dynamic target name via ${HOOK_EXTERNAL_NAME}
#   - Supports hook reuse for imgui variants (imgui_docking, etc.)
#   - Lock handled by HookLoader (no manual lock needed)
#
# Changes v0.2.0:
#   - Combined target with backends
#   - Auto-link glad and glfw
#
# Based on:
#   - guidelines v0.1
#
# ==============================================================================

message(STATUS "[${HOOK_EXTERNAL_NAME}] Creating target from: ${HOOK_SOURCE_DIR}")

# ==============================================================================
# Collect Source Files
# ==============================================================================

set(_imgui_sources
    "${HOOK_SOURCE_DIR}/imgui.cpp"
    "${HOOK_SOURCE_DIR}/imgui_demo.cpp"
    "${HOOK_SOURCE_DIR}/imgui_draw.cpp"
    "${HOOK_SOURCE_DIR}/imgui_tables.cpp"
    "${HOOK_SOURCE_DIR}/imgui_widgets.cpp"
)

set(_imgui_includes
    "${HOOK_SOURCE_DIR}"
    "${HOOK_SOURCE_DIR}/backends"
)

# ==============================================================================
# Add OpenGL3 Backend
# ==============================================================================

if(EXISTS "${HOOK_SOURCE_DIR}/backends/imgui_impl_opengl3.cpp")
    list(APPEND _imgui_sources "${HOOK_SOURCE_DIR}/backends/imgui_impl_opengl3.cpp")
    message(STATUS "[${HOOK_EXTERNAL_NAME}]   + OpenGL3 backend")
endif()

# ==============================================================================
# Add GLFW Backend
# ==============================================================================

if(EXISTS "${HOOK_SOURCE_DIR}/backends/imgui_impl_glfw.cpp")
    list(APPEND _imgui_sources "${HOOK_SOURCE_DIR}/backends/imgui_impl_glfw.cpp")
    message(STATUS "[${HOOK_EXTERNAL_NAME}]   + GLFW backend")
endif()

# ==============================================================================
# Add Win32 Backend (Windows only)
# ==============================================================================

if(WIN32 AND EXISTS "${HOOK_SOURCE_DIR}/backends/imgui_impl_win32.cpp")
    list(APPEND _imgui_sources "${HOOK_SOURCE_DIR}/backends/imgui_impl_win32.cpp")
    message(STATUS "[${HOOK_EXTERNAL_NAME}]   + Win32 backend")
endif()

# ==============================================================================
# Create Combined ImGui Library (Dynamic Target Name!)
# ==============================================================================

add_library(${HOOK_EXTERNAL_NAME} STATIC ${_imgui_sources})

target_include_directories(${HOOK_EXTERNAL_NAME} PUBLIC ${_imgui_includes})

# C++ Standard
target_compile_features(${HOOK_EXTERNAL_NAME} PUBLIC cxx_std_11)

# Suppress warnings in external code
if(MSVC)
    target_compile_options(${HOOK_EXTERNAL_NAME} PRIVATE /W0)
else()
    target_compile_options(${HOOK_EXTERNAL_NAME} PRIVATE -w)
endif()

# ==============================================================================
# Link Dependencies
# ==============================================================================

# Link GLAD if available (for OpenGL3 backend)
if(TARGET glad)
    target_link_libraries(${HOOK_EXTERNAL_NAME} PUBLIC glad)
    target_compile_definitions(${HOOK_EXTERNAL_NAME} PRIVATE IMGUI_IMPL_OPENGL_LOADER_GLAD)
    message(STATUS "[${HOOK_EXTERNAL_NAME}]   Linked: glad")
endif()

# Link GLFW if available (for GLFW backend)
if(TARGET glfw)
    target_link_libraries(${HOOK_EXTERNAL_NAME} PUBLIC glfw)
    message(STATUS "[${HOOK_EXTERNAL_NAME}]   Linked: glfw")
endif()

# ==============================================================================
# Register Target (Dynamic Name!)
# ==============================================================================

_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)

message(STATUS "[${HOOK_EXTERNAL_NAME}] Target '${HOOK_EXTERNAL_NAME}' created (combined with backends)")
message(STATUS "[${HOOK_EXTERNAL_NAME}] PostFetch hook complete")
