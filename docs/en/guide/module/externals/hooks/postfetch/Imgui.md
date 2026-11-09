# PostFetch/imgui.cmake — ImGui PostFetch Hook

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5, Doc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [Imgui.md](../../../../../../de/guide/module/externals/hooks/postfetch/Imgui.md)  
> **Hook:** [cmake/externals/hooks/postfetch/imgui.cmake](../../../../../../../cmake/externals/hooks/postfetch/imgui.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Why a PostFetch Hook?](#2-why-a-postfetch-hook)
3. [Created Targets](#3-created-targets)
4. [Backends](#4-backends)
5. [Hook Reuse](#5-hook-reuse)
6. [Solution.json Configuration](#6-solutionjson-configuration)
7. [Dependencies](#7-dependencies)
8. [See Also](#8-see-also)
9. [Changelog](#9-changelog)

---

## 1. Overview

The `imgui.cmake` PostFetch hook creates CMake targets for Dear ImGui, since ImGui itself contains no CMakeLists.txt.

---

## 2. Why a PostFetch Hook?

ImGui is a **header-centric** project without CMake support. The PostFetch hook:

1. Collects the required source files
2. Creates a STATIC library
3. Configures the include directories
4. Links the backend dependencies
5. Registers the target

---

## 3. Created Targets

| Target | Type | Description |
|--------|------|-------------|
| `${HOOK_EXTERNAL_NAME}` | STATIC | Combined ImGui library with backends |

The target name matches the external name:
- `"imgui"` → target `imgui`
- `"imgui_docking"` → target `imgui_docking`

---

## 4. Backends

| Backend | Condition |
|---------|-----------|
| OpenGL3 | Automatic if present |
| GLFW | Automatic if present |
| Win32 | Windows only |

---

## 5. Hook Reuse

```json
{
    "imgui": {
        "git": "https://github.com/ocornut/imgui.git",
        "tag": "v1.91.6",
        "cmakeSupport": false
    },
    "imgui_docking": {
        "git": "https://github.com/ocornut/imgui.git",
        "branch": "docking",
        "hook": "imgui",
        "cmakeSupport": false
    }
}
```

**Important:** The hook uses `${HOOK_EXTERNAL_NAME}` for target names.

---

## 6. Solution.json Configuration

### Standard ImGui

```json
{
    "imgui": {
        "git": "https://github.com/ocornut/imgui.git",
        "tag": "v1.91.6",
        "cmakeSupport": false
    }
}
```

### Using It in an Executable

```json
{
    "executables": [{
        "name": "MyGuiApp",
        "externals": ["glad", "glfw", "imgui"]
    }]
}
```

**Order matters:** glad and glfw before imgui.

---

## 7. Dependencies

| External | Usage |
|----------|-------|
| `glad` | OpenGL loader (linked PUBLIC) |
| `glfw` | Window/input backend (linked PUBLIC) |

---

## 8. See Also

- [HookLoader_cmake.md](../HookLoader_cmake.md) — Hook system
- [Targets_cmake.md](../../registry/Targets_cmake.md) — Target registration
- [Glfw.md](../prefetch/Glfw.md) — GLFW PreFetch hook

---

## 9. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-15 | Documentation migrated to Blueprint v0.5.0 |
