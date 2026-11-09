# OutputDirs.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** In development (pre-release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [OutputDirs.md](../../../../de/guide/module/core/OutputDirs.md)  
> **Module:** [`cmake/core/OutputDirs.cmake`](../../../../../cmake/core/OutputDirs.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Concept](#3-concept)
4. [API Reference](#4-api-reference)
5. [Output Structure](#5-output-structure)
6. [Usage Examples](#6-usage-examples)
7. [See Also](#7-see-also)
8. [Changelog](#changelog)

---

## 1. Overview

The `OutputDirs.cmake` module configures **standardized output directories** for all targets. It ensures a uniform, isolated directory structure.

### Core Idea

Every target gets its own subdirectory for better isolation and simpler deployment preparation.

### Responsibilities

| Area | Description |
|------|-------------|
| Categorization | Automatic detection (EXECUTABLE vs. LIBRARY) |
| Isolation | Own directory per target |
| Configurations | Debug/Release/Testing subdirectories |

### Used By

- ExecutableCreate.cmake
- LibraryCreate.cmake

---

## 2. Dependencies

| Module | Version | Usage |
|--------|---------|-------|
| — | — | None (standalone module) |

**Design decision:** OutputDirs.cmake is a simple standalone module without debug or error integration. Errors (e.g. target does not exist) are reported directly by CMake.

→ See [Open clarifications](../../../konzepte/abgeschlossen/Offene_Abklaerungen_Core_Module.md) for details on a possible dbg() integration.

---

## 3. Concept

### 3.1 Target Categories

| Target type | Category | Path |
|-------------|----------|------|
| EXECUTABLE | exec | `exec/${TARGET}/bin/` |
| STATIC_LIBRARY | libs | `libs/${TARGET}/lib/` |
| SHARED_LIBRARY | libs | `libs/${TARGET}/lib/` |
| MODULE_LIBRARY | libs | `libs/${TARGET}/lib/` |
| OBJECT_LIBRARY | libs | `libs/${TARGET}/lib/` |
| INTERFACE_LIBRARY | libs | `libs/${TARGET}/lib/` |
| (Unknown) | other | `other/${TARGET}/` |

### 3.2 Properties Set

| Property | Directory | Description |
|----------|-----------|-------------|
| `RUNTIME_OUTPUT_DIRECTORY` | bin/ | Executables, DLLs |
| `LIBRARY_OUTPUT_DIRECTORY` | lib/ | Shared libraries (.so) |
| `ARCHIVE_OUTPUT_DIRECTORY` | lib/ | Static libraries (.a, .lib) |

For each property, configuration-specific variants are set in addition:
- `*_DEBUG`
- `*_RELEASE`
- `*_TESTING`

---

## 4. API Reference

### 4.1 setup_output_dirs()

Configures standardized output directories for a target.

```cmake
setup_output_dirs(<TARGET_NAME>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `TARGET_NAME` | String | ✓ | CMake target (must already exist) |

**Prerequisite:** The target must already have been created with `add_executable()` or `add_library()`.

**Returns:** Nothing (sets target properties)

**Example:**

```cmake
add_executable(MyApp main.cpp)
setup_output_dirs(MyApp)
# → build/exec/MyApp/bin/Debug/MyApp.exe

add_library(CoreLib STATIC core.cpp)
setup_output_dirs(CoreLib)
# → build/libs/CoreLib/lib/Debug/CoreLib.lib
```

---

## 5. Output Structure

### 5.1 Complete Example

```
out/build/preset-name/
├── exec/
│   ├── MyApp/
│   │   └── bin/
│   │       ├── Debug/
│   │       │   ├── MyApp.exe
│   │       │   └── required.dll
│   │       └── Release/
│   │           └── MyApp.exe
│   └── OtherApp/
│       └── bin/
│           └── Debug/
│               └── OtherApp.exe
└── libs/
    ├── CoreLib/
    │   └── lib/
    │       ├── Debug/
    │       │   └── CoreLib.lib
    │       └── Release/
    │           └── CoreLib.lib
    └── PluginLib/
        └── lib/
            └── Debug/
                ├── PluginLib.lib    (import library)
                └── PluginLib.dll    (via RUNTIME)
```

### 5.2 Platform-Specific Outputs

| Platform | Executable | Static lib | Shared lib |
|----------|------------|------------|------------|
| Windows | .exe → bin/ | .lib → lib/ | .dll → bin/, .lib → lib/ |
| Linux | (no ext.) → bin/ | .a → lib/ | .so → lib/ |
| macOS | (no ext.) → bin/ | .a → lib/ | .dylib → lib/ |

---

## 6. Usage Examples

### 6.1 In ExecutableCreate.cmake

```cmake
function(_create_executable_target CTX)
    ctx_get(${CTX} NAME _name)
    
    add_executable(${_name} ${_sources})
    setup_output_dirs(${_name})    # ← output directories
    apply_warnings(${_name})
    apply_compiler_options(${_name})
endfunction()
```

### 6.2 In LibraryCreate.cmake

```cmake
function(_create_library_target CTX)
    ctx_get(${CTX} NAME _name)
    ctx_get(${CTX} TYPE _type)
    
    add_library(${_name} ${_type} ${_sources})
    setup_output_dirs(${_name})    # ← output directories
endfunction()
```

### 6.3 Standalone Usage

```cmake
add_executable(MyTool tool.cpp)
setup_output_dirs(MyTool)

add_library(HelperLib STATIC helper.cpp)
setup_output_dirs(HelperLib)
```

---

## 7. See Also

- [ExecutableCreate.cmake](../project/ExecutableCreate.md) — uses setup_output_dirs
- [LibraryCreate.cmake](../project/LibraryCreate.md) — uses setup_output_dirs
- [CMake OUTPUT_DIRECTORY](https://cmake.org/cmake/help/latest/prop_tgt/RUNTIME_OUTPUT_DIRECTORY.html) — CMake documentation

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0: new header with target audience/language/English link/module link, numbered table of contents with anchors, chapter numbering |
| 0.1.3 | 2025-12-07 | Target-isolated directories, exec/libs separation, automatic type detection |
| 0.1.2 | 2025-12-05 | TESTING configuration added |
| 0.1.1 | 2025-12-04 | Debug/Release subdirectories |
| 0.1.0 | 2025-12-03 | Initial (clean start) |
