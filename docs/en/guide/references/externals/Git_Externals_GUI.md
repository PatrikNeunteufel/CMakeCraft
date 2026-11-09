# Git Externals: GUI & Graphics — Reference

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Git_Externals_GUI.md](../../../../de/guide/references/externals/Git_Externals_GUI.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Window & Input](#2-window--input)
3. [Immediate Mode GUI](#3-immediate-mode-gui)
4. [Game Development](#4-game-development)
5. [Vulkan / Low-Level Graphics](#5-vulkan--low-level-graphics)
6. [Quick Reference](#6-quick-reference)
7. [See Also](#7-see-also)
8. [Changelog](#8-changelog)

---

## 1. Overview

This document describes libraries for graphical user interfaces, window management and rendering.

### Categories

| Category | Libraries |
|----------|-----------|
| Window & Input | glfw, SDL2, SDL3 |
| Immediate Mode GUI | imgui, imgui_docking |
| Game Development | raylib, sokol |
| Vulkan | vulkan-headers, volk, VMA |

---

## 2. Window & Input

### 2.1 glfw

> **Purpose:** Cross-platform window/input handling for OpenGL, Vulkan and OpenGL ES.

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/glfw/glfw.git` |
| **Current Tag** | `3.4` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch required |
| **Target** | `glfw` |

```json
"glfw": {
    "git": "https://github.com/glfw/glfw.git",
    "tag": "3.4"
}
```

**PreFetch Hook (glfw.cmake):**
```cmake
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_INSTALL OFF CACHE BOOL "" FORCE)
```

**Usage:**
```cpp
#include <GLFW/glfw3.h>

glfwInit();
GLFWwindow* window = glfwCreateWindow(800, 600, "Hello", NULL, NULL);
while (!glfwWindowShouldClose(window)) {
    glfwPollEvents();
}
glfwTerminate();
```

---

### 2.2 SDL2

> **Purpose:** Cross-platform multimedia (video, audio, input, threading).

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/libsdl-org/SDL.git` |
| **Current Tag** | `release-2.30.0` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch recommended |

```json
"sdl2": {
    "git": "https://github.com/libsdl-org/SDL.git",
    "tag": "release-2.30.0"
}
```

**PreFetch Hook (sdl2.cmake):**
```cmake
set(SDL_TEST OFF CACHE BOOL "" FORCE)
set(SDL_TESTS OFF CACHE BOOL "" FORCE)
set(SDL2_DISABLE_INSTALL ON CACHE BOOL "" FORCE)
```

---

### 2.3 SDL3

> **Purpose:** Next generation of SDL with an improved API.

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/libsdl-org/SDL.git` |
| **Current Tag** | `release-3.2.0` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch recommended |

```json
"sdl3": {
    "git": "https://github.com/libsdl-org/SDL.git",
    "tag": "release-3.2.0"
}
```

---

## 3. Immediate Mode GUI

### 3.1 imgui

> **Purpose:** Bloat-free immediate mode GUI for tools and debug UIs.

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/ocornut/imgui.git` |
| **Current Tag** | `v1.91.6` (stable), `v1.91.6-docking` (docking) |
| **CMake Support** | ❌ |
| **Hook** | PostFetch required 🔧 |
| **Dependencies** | Backend (GLFW, SDL, etc.) + Renderer (OpenGL, Vulkan, etc.) |

```json
"imgui": {
    "git": "https://github.com/ocornut/imgui.git",
    "tag": "v1.91.6",
    "cmakeSupport": false
}
```

**Docking variant (same hook):**
```json
"imgui_docking": {
    "git": "https://github.com/ocornut/imgui.git",
    "tag": "v1.91.6-docking",
    "cmakeSupport": false,
    "hook": "imgui"
}
```

**PostFetch Hook:** See `cmake/externals/hooks/postfetch/imgui.cmake`

The hook creates an `imgui` target with:
- Core ImGui files
- OpenGL3 backend
- GLFW backend
- Win32 backend (on Windows)

**Automatic linking:**
- `glad` (if present) + `IMGUI_IMPL_OPENGL_LOADER_GLAD`
- `glfw` (if present)

**Important - order in Solution.json:**
```json
"externals": {
    "glad": { ... },   // 1. first
    "glfw": { ... },   // 2. then
    "imgui": { ... }   // 3. last
}
```

**Usage:**
```cpp
#include "imgui.h"
#include "imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"

ImGui::CreateContext();
ImGui_ImplGlfw_InitForOpenGL(window, true);
ImGui_ImplOpenGL3_Init("#version 330");

// In render loop:
ImGui_ImplOpenGL3_NewFrame();
ImGui_ImplGlfw_NewFrame();
ImGui::NewFrame();

ImGui::Begin("Hello");
ImGui::Text("Hello, ImGui!");
ImGui::End();

ImGui::Render();
ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
```

---

## 4. Game Development

### 4.1 raylib

> **Purpose:** Simple library for game development and rapid prototyping.

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/raysan5/raylib.git` |
| **Current Tag** | `5.0` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch recommended |

```json
"raylib": {
    "git": "https://github.com/raysan5/raylib.git",
    "tag": "5.0"
}
```

**PreFetch Hook (raylib.cmake):**
```cmake
set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(BUILD_GAMES OFF CACHE BOOL "" FORCE)
```

**Usage:**
```cpp
#include "raylib.h"

InitWindow(800, 450, "raylib example");
while (!WindowShouldClose()) {
    BeginDrawing();
    ClearBackground(RAYWHITE);
    DrawText("Hello, raylib!", 10, 10, 20, DARKGRAY);
    EndDrawing();
}
CloseWindow();
```

---

### 4.2 sokol

> **Purpose:** Minimal cross-platform libraries (app, gfx, audio, etc.).

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/floooh/sokol.git` |
| **Current Tag** | – (branch: master) |
| **CMake Support** | ❌ (header-only) |
| **Hook** | PostFetch required 🔧 |

```json
"sokol": {
    "git": "https://github.com/floooh/sokol.git",
    "branch": "master",
    "cmakeSupport": false
}
```

**PostFetch Hook (sokol.cmake):**
```cmake
add_library(${HOOK_EXTERNAL_NAME} INTERFACE)
target_include_directories(${HOOK_EXTERNAL_NAME} INTERFACE "${HOOK_SOURCE_DIR}")
_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)
```

---

## 5. Vulkan / Low-Level Graphics

### 5.1 Vulkan-Headers

> **Purpose:** Official Vulkan API headers.

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/KhronosGroup/Vulkan-Headers.git` |
| **Current Tag** | `v1.3.280` |
| **CMake Support** | ✅ |
| **Hook** | – |

```json
"vulkan-headers": {
    "git": "https://github.com/KhronosGroup/Vulkan-Headers.git",
    "tag": "v1.3.280"
}
```

---

### 5.2 volk (Vulkan Loader)

> **Purpose:** Meta-loader for Vulkan (loads function pointers dynamically).

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/zeux/volk.git` |
| **Current Tag** | `1.3.280` |
| **CMake Support** | ✅ |
| **Hook** | – |

```json
"volk": {
    "git": "https://github.com/zeux/volk.git",
    "tag": "1.3.280"
}
```

---

### 5.3 VulkanMemoryAllocator

> **Purpose:** Simple Vulkan memory allocation.

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator.git` |
| **Current Tag** | `v3.0.1` |
| **CMake Support** | ✅ |
| **Hook** | – |

```json
"vma": {
    "git": "https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator.git",
    "tag": "v3.0.1"
}
```

---

## 6. Quick Reference

| Library | Tag | CMake | Hook | Main Use |
|---------|-----|-------|------|----------|
| glfw | 3.4 | ✅ | PreFetch | Window/Input |
| sdl2 | release-2.30.0 | ✅ | PreFetch | Multimedia |
| sdl3 | release-3.2.0 | ✅ | PreFetch | Multimedia (next-gen) |
| imgui | v1.91.6 | ❌ | PostFetch 🔧 | Immediate Mode GUI |
| raylib | 5.0 | ✅ | PreFetch | Simple game dev |
| sokol | master | ❌ | PostFetch 🔧 | Minimal cross-platform |
| vulkan-headers | v1.3.280 | ✅ | – | Vulkan API |
| volk | 1.3.280 | ✅ | – | Vulkan loader |
| vma | v3.0.1 | ✅ | – | Vulkan memory |

---

## 7. See Also

- [Git_Externals_Reference.md](Git_Externals.md) — Main overview
- [Git_Externals_Core.md](Git_Externals_Core.md) — Logging & Testing
- [Git_Externals_Media.md](Git_Externals_Media.md) — Audio & Math
- [Externals.md](../Externals.md) — Local Externals (glad)

---

## 8. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: hook path in lower case (`cmake/externals/hooks/postfetch/`, `cmake/externals/hooks/HookLoader.cmake:40`)** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.0 | 2025-12-14 | Initial: extracted from Git_Externals_Reference |
