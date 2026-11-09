# Externals — External Management System

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Language:** English  
> **German:** [README.md](../../../../de/guide/module/externals/README.md)

---

## Quick Start

**Integrating external libraries?**
1. [Orchestrator_cmake.md](Orchestrator_cmake.md) — Understand the main entry point
2. [../../userguides/Externals.md](../../userguides/Externals.md) — Practical guide
3. [../../userguides/Adding_Externals.md](../../userguides/Adding_Externals.md) — Add a new external

**Fetching a Git-based library?**
1. [core/Fetch_cmake.md](core/Fetch_cmake.md) — FetchContent wrapper
2. [hooks/HookLoader_cmake.md](hooks/HookLoader_cmake.md) — Pre/post-fetch hooks
3. [fetched/Handler_cmake.md](fetched/Handler_cmake.md) — Post-fetch processing

**Integrating a local library?**
1. [locals/Attach_cmake.md](locals/Attach_cmake.md) — Local attach system
2. [includes/](includes/bass/Bass_Include.md) — Include definitions per library

**Fetching a prebuilt package?**
1. [archive/Handler_cmake.md](archive/Handler_cmake.md) — External kind `archive`
2. [../CMakeCraftPackage.md](../CMakeCraftPackage.md) — Pin file, fetching, deployment

**Writing a hook for a library?**
1. [hooks/HookLoader_cmake.md](hooks/HookLoader_cmake.md) — Understand the hook system
2. [hooks/prefetch/Glfw.md](hooks/prefetch/Glfw.md) — Example: pre-fetch hook
3. [hooks/postfetch/Imgui.md](hooks/postfetch/Imgui.md) — Example: post-fetch hook

**Understanding the target registry?**
1. [registry/Targets_cmake.md](registry/Targets_cmake.md) — Central target management

---

## Overview

The external management system handles all external dependencies: local (`path`), Git-based (`git`, fetched), system (`system`, find_package) and archive externals (`archive`, prebuilt packages). It uses a centralized registry system and hook mechanisms.

### Architecture

```
cmake/externals/
├── Orchestrator.cmake           ← Main entry, detects the type and dispatches
│
├── local/
│   └── Attach.cmake             ← Integrates local libs ("path")
├── includes/                    ← Include.cmake per local external
│   ├── bass/Include.cmake
│   ├── doctest/Include.cmake
│   ├── glad/Include.cmake
│   └── lua54/Include.cmake
│
├── fetched/
│   └── Handler.cmake            ← Processes fetched libs ("git")
├── core/
│   └── Fetch.cmake              ← Git FetchContent
├── hooks/                       ← Pre/post-fetch hooks
│   ├── HookLoader.cmake
│   ├── prefetch/                ← catch2, glfw, googletest, qt-ads, qt-ads110 (.cmake)
│   └── postfetch/               ← imgui, qt-ads, qt-ads110, stb (.cmake)
├── registry/
│   └── Targets.cmake            ← Central target registry
│
├── system/                      ← System externals via find_package ("system": true)
│   ├── Handler.cmake
│   ├── PathResolver.cmake
│   └── packages/                ← Qt6.cmake, Boost.cmake
│
└── archive/
    └── Handler.cmake            ← Fetches prebuilt packages ("archive": true; CMakeCraftPackage.cmake)
```

---

## Files

| File | Description |
|------|-------------|
| [Orchestrator_cmake.md](Orchestrator_cmake.md) | Main orchestration — coordinates all external operations |

---

## Subfolders

| Folder | Files | Description |
|--------|-------|-------------|
| [archive/](archive/Handler_cmake.md) | 1 | Handler for archive externals |
| [core/](core/Fetch_cmake.md) | 1 | Core functions |
| [fetched/](fetched/Handler_cmake.md) | 1 | Handler for fetched libraries |
| [hooks/](hooks/HookLoader_cmake.md) | 8 | Pre/post-fetch hook system |
| [includes/](includes/bass/Bass_Include.md) | 4 | Library-specific includes |
| [locals/](locals/Attach_cmake.md) | 1 | Local library integration (code: `local/`) |
| [registry/](registry/Targets_cmake.md) | 1 | Target registry |
| [system/](system/README.md) | 5 | System externals (find_package) |

---

## Subfolder Files (Direct Access)

### core/ — Core Functions

| File | Description |
|------|-------------|
| [core/Fetch_cmake.md](core/Fetch_cmake.md) | Git FetchContent wrapper with hook integration |

### fetched/ — Post-Fetch Handler

| File | Description |
|------|-------------|
| [fetched/Handler_cmake.md](fetched/Handler_cmake.md) | Processes libraries after the Git fetch |

### archive/ — Archive Externals

| File | Description |
|------|-------------|
| [archive/Handler_cmake.md](archive/Handler_cmake.md) | Fetches prebuilt packages in a pinned version and applies them to targets |

### locals/ — Local Libraries

| File | Description |
|------|-------------|
| [locals/Attach_cmake.md](locals/Attach_cmake.md) | Attaches preinstalled libraries to targets |

### registry/ — Target Registry

| File | Description |
|------|-------------|
| [registry/Targets_cmake.md](registry/Targets_cmake.md) | Central management of all external targets |

### hooks/ — Hook System

| File | Description |
|------|-------------|
| [hooks/HookLoader_cmake.md](hooks/HookLoader_cmake.md) | Hook loader and discovery |
| [hooks/prefetch/Catch2.md](hooks/prefetch/Catch2.md) | Catch2 pre-fetch hook |
| [hooks/prefetch/Glfw.md](hooks/prefetch/Glfw.md) | GLFW pre-fetch hook |
| [hooks/prefetch/Googletest.md](hooks/prefetch/Googletest.md) | GoogleTest pre-fetch hook |
| [hooks/prefetch/Qt-Ads_PreFetch.md](hooks/prefetch/Qt-Ads_PreFetch.md) | Qt-ADS pre-fetch hook |
| [hooks/postfetch/Imgui.md](hooks/postfetch/Imgui.md) | ImGui post-fetch hook |
| [hooks/postfetch/Qt-Ads_PostFetch.md](hooks/postfetch/Qt-Ads_PostFetch.md) | Qt-ADS post-fetch hook |
| [hooks/postfetch/Stb.md](hooks/postfetch/Stb.md) | stb post-fetch hook |

### includes/ — Library Includes

| File | Description |
|------|-------------|
| [includes/bass/Bass_Include.md](includes/bass/Bass_Include.md) | BASS audio library + plugins |
| [includes/doctest/Doctest_Include.md](includes/doctest/Doctest_Include.md) | doctest testing framework |
| [includes/glad/Glad_Include.md](includes/glad/Glad_Include.md) | GLAD OpenGL loader |
| [includes/lua54/Lua54_Include.md](includes/lua54/Lua54_Include.md) | Lua 5.4 scripting engine |

### system/ — System Externals

| File | Description |
|------|-------------|
| [system/README.md](system/README.md) | Overview of system externals |
| [system/Handler_cmake.md](system/Handler_cmake.md) | find_package handler |
| [system/PathResolver_cmake.md](system/PathResolver_cmake.md) | Search paths |
| [system/packages/Qt6_cmake.md](system/packages/Qt6_cmake.md) | Package hook Qt6 |
| [system/packages/Boost_cmake.md](system/packages/Boost_cmake.md) | Package hook Boost |

---

## External Types

| Type | Source | Examples | Reference |
|------|--------|----------|-----------|
| **Git (fetched)** | Git repository | GLFW, ImGui, doctest | [Git_Externals.md](../../references/externals/Git_Externals.md) |
| **Local** | Folder in the project (`path`) | BASS, Lua, glad, doctest | [Local_Externals.md](../../references/externals/Local_Externals.md) |
| **System** | Installed package via find_package (`"system": true`) | Qt6, Boost | [system/Handler_cmake.md](system/Handler_cmake.md) |
| **Archive** | Prebuilt package (pin file with version, URL, SHA256) | — | [archive/Handler_cmake.md](archive/Handler_cmake.md) |

---

## See Also

- [../README.md](../README.md) — Module overview
- [../../references/Externals.md](../../references/Externals.md) — Externals reference
- [../../references/README.md](../../references/README.md) — External definitions
- [../../userguides/Externals.md](../../userguides/Externals.md) — Externals user guide

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: architecture tree following `cmake/externals/` (`local/`, `system/`, `archive/`, hook files in lowercase, `includes/<name>/Include.cmake`); folder table with `archive/` and `system/`, 8 hook documents; system externals as a type of their own** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
