# hooks/HookLoader.cmake — Pre/PostFetch Hook System

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5, Doc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [HookLoader_cmake.md](../../../../../de/guide/module/externals/hooks/HookLoader_cmake.md)  
> **Module:** [cmake/externals/hooks/HookLoader.cmake](../../../../../../cmake/externals/hooks/HookLoader.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Convention Paths](#3-convention-paths)
4. [API Reference](#4-api-reference)
5. [Hook Variables](#5-hook-variables)
6. [Hook Types](#6-hook-types)
7. [Hook Reuse](#7-hook-reuse)
8. [Usage Examples](#8-usage-examples)
9. [Error Handling](#9-error-handling)
10. [See Also](#10-see-also)
11. [Changelog](#11-changelog)

---

## 1. Overview

`hooks/HookLoader.cmake` implements the hook system for fetched externals.

### Core Functions

- **PreFetch** — Set CMake options before the external is configured
- **PostFetch** — Create targets for externals without a CMakeLists.txt
- **Hook Reuse** — Same hooks for variants (e.g. imgui/imgui_docking)

### Convention over Configuration

```
cmake/externals/hooks/
├── HookLoader.cmake
├── prefetch/
│   ├── catch2.cmake
│   ├── glfw.cmake
│   ├── googletest.cmake
│   ├── qt-ads.cmake
│   └── qt-ads110.cmake
└── postfetch/
    ├── imgui.cmake
    ├── qt-ads.cmake
    ├── qt-ads110.cmake
    └── stb.cmake
```

---

## 2. Dependencies

| Module | Purpose |
|--------|---------|
| `Errors.cmake` | Error handling |
| `Debug.cmake` | Debug output |
| `Json.cmake` | JSON parsing |
| `core/Fetch.cmake` | `_get_external_source_dir()` |

---

## 3. Convention Paths

| Type | Path |
|------|------|
| PreFetch | `cmake/externals/hooks/prefetch/{name}.cmake` |
| PostFetch | `cmake/externals/hooks/postfetch/{name}.cmake` |

---

## 4. API Reference

### 4.1 _load_prefetch_hook()

```cmake
_load_prefetch_hook(EXT_NAME EXT_JSON)
```

Loads a PreFetch hook (before FetchContent_MakeAvailable).

---

### 4.2 _load_postfetch_hook()

```cmake
_load_postfetch_hook(EXT_NAME EXT_JSON)
```

Loads a PostFetch hook (after FetchContent_MakeAvailable).

---

### 4.3 _get_hook_name()

```cmake
_get_hook_name(EXT_NAME EXT_JSON OUT_HOOK_NAME)
```

Determines which hook is to be used (own name or `hook` override).

---

## 5. Hook Variables

### Available in All Hooks

| Variable | Description |
|----------|-------------|
| `HOOK_EXTERNAL_NAME` | Name of the external (use it for target names!) |
| `HOOK_EXTERNAL_JSON` | JSON definition of the external |

### Only in PostFetch Hooks

| Variable | Description |
|----------|-------------|
| `HOOK_SOURCE_DIR` | Path to the source directory |

---

## 6. Hook Types

### PreFetch Hooks

Run **before** `FetchContent_MakeAvailable()`.

```cmake
# cmake/externals/hooks/prefetch/glfw.cmake
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
```

### PostFetch Hooks

Run **after** `FetchContent_MakeAvailable()`.

```cmake
# cmake/externals/hooks/postfetch/imgui.cmake
add_library(${HOOK_EXTERNAL_NAME} STATIC
    ${HOOK_SOURCE_DIR}/imgui.cpp
    ...
)
_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)
```

---

## 7. Hook Reuse

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

→ Both use the `imgui.cmake` hooks, but create different targets.

---

## 8. Usage Examples

### Minimal PreFetch

```cmake
# cmake/externals/hooks/prefetch/catch2.cmake
set(CATCH_BUILD_TESTING OFF CACHE BOOL "" FORCE)
```

### PostFetch with Target

```cmake
# cmake/externals/hooks/postfetch/stb.cmake
add_library(${HOOK_EXTERNAL_NAME} INTERFACE)
target_include_directories(${HOOK_EXTERNAL_NAME} INTERFACE ${HOOK_SOURCE_DIR})
_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)
```

---

## 9. Error Handling

| Code | Error | Description |
|------|-------|-------------|
| E216 | Hook not found | Explicitly specified hook does not exist |

---

## 10. See Also

- [Handler_cmake.md](../fetched/Handler_cmake.md) — Hook caller
- [Targets_cmake.md](../registry/Targets_cmake.md) — Target registration
- [Glfw.md](prefetch/Glfw.md) — GLFW PreFetch hook
- [Imgui.md](postfetch/Imgui.md) — ImGui PostFetch hook

---

## 11. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: example tree with the existing hooks (instead of the non-existent `prefetch/spdlog.cmake`); `core/Fetch.cmake` in lowercase** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.0 | 2025-12-15 | Documentation migrated to Blueprint v0.5.0 |
