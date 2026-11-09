# Executables.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** In Development (Pre-Release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [Executables.md](../../../../de/guide/module/project/Executables.md)  
> **Module:** [`cmake/project/Executables.cmake`](../../../../../cmake/project/Executables.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Processing](#3-processing)
4. [Filter Mechanisms](#4-filter-mechanisms)
5. [Error Handling](#5-error-handling)
6. [Debug Output](#6-debug-output)
7. [See Also](#7-see-also)
8. [Changelog](#changelog)

---

## 1. Overview

The `Executables.cmake` module is the **orchestrator of the executable pipeline**. It iterates over all executables in Solution.json and delegates to ExecutableCollect and ExecutableCreate.

### Core Idea

One module coordinates the entire process — from JSON parsing to target creation.

### Responsibilities

| Area | Description |
|------|-------------|
| Iteration | Over the executables array |
| Filters | skip, BUILD_ONLY, platforms |
| Delegation | To the Collect and Create modules |
| Duplicate check | Does the target already exist? |

### Loads Automatically

- ExecutableCollect.cmake
- ExecutableCreate.cmake

---

## 2. Dependencies

| Module | Version | Usage |
|--------|---------|-------|
| Errors.cmake | 0.5.0 | `cmake_fatal` |
| Debug.cmake | 0.5.0 | `dbg`, `dbg_init`, `dbgspace`, `enddbgblock` |
| Json.cmake | 0.5.0 | `_json_has_key`, `_json_array_length`, `_json_array_get`, `_json_get_string` |
| Context.cmake | 0.5.0 | `ctx_create`, `ctx_get` |
| Solution.cmake | 0.5.0 | `SOLUTION_JSON` property |

---

## 3. Processing

### 3.1 Pipeline Flow

```
Executables.cmake
    │
    ├── 1. Load Sub-Modules
    │   ├── ExecutableCollect.cmake
    │   └── ExecutableCreate.cmake
    │
    ├── 2. Get executables array from SOLUTION_JSON
    │   └── Return early if empty
    │
    └── 3. For each executable:
        │
        ├── 3.1 Extract JSON
        │   └── E001 if no name
        │
        ├── 3.2 Create Context (EXE_0, EXE_1, ...)
        │
        ├── 3.3 _collect_executable() → Fills Context
        │
        ├── 3.4 Check Filters:
        │   ├── skip=true → Continue
        │   ├── BUILD_ONLY → Not in list → Continue
        │   └── platforms → Not matching → Continue
        │
        ├── 3.5 Duplicate Check
        │   └── E102 if target exists
        │
        └── 3.6 _create_executable_target() → CMake Target
```

### 3.2 Context Naming

Each executable gets a numbered context:

| Index | Context prefix |
|-------|----------------|
| 0 | `EXE_0` |
| 1 | `EXE_1` |
| n | `EXE_n` |

---

## 4. Filter Mechanisms

### 4.1 skip Flag

In Solution.json:
```json
{
    "name": "OldTool",
    "skip": true
}
```

The executable is skipped entirely.

### 4.2 BUILD_ONLY

CMake call:
```bash
cmake -B build -DBUILD_ONLY="MyApp;OtherApp"
```

Only the specified executables are built. All others are skipped.

### 4.3 platforms

In Solution.json:
```json
{
    "name": "WinTool",
    "platforms": ["windows"]
}
```

Supported values:

| Value | Condition |
|-------|-----------|
| `windows` | WIN32 |
| `linux` | CMAKE_SYSTEM_NAME == "Linux" |
| `macos` | APPLE |
| `unix` | UNIX |

Multiple platforms are possible:
```json
"platforms": ["windows", "linux"]
```

---

## 5. Error Handling

### 5.1 Fatal Errors

| Code | Condition | Solution |
|------|-----------|----------|
| E001 | Executable has no `name` field | Add a name |
| E102 | Target already exists | Make the name unique |

---

## 6. Debug Output

### 6.1 Standard Output

```
-- [Executables] === Executable Pipeline Start ===
-- [Executables] Processing 3 executable(s)...
-- [Executables] --- Processing: MyApp ---
-- [Executables]   Created: MyApp
-- [Executables] --- Processing: OldTool ---
-- [Executables]   SKIP: OldTool (skip=true in Solution.json)
-- [Executables] --- Processing: WinOnly ---
-- [Executables]   SKIP: WinOnly (platform not supported: windows)
-- [Executables] 
-- [Executables] === Executable Pipeline Complete ===
-- -------------------------------------------
```

---

## 7. See Also

- [ExecutableCollect.cmake](ExecutableCollect.md) — JSON to context
- [ExecutableCreate.cmake](ExecutableCreate.md) — Context to target
- [Solution.cmake](Solution.md) — Provides SOLUTION_JSON
- [Context.cmake](../core/Context.md) — Context system
- [ErrorCodes.md](../../references/ErrorCodes.md) — E001, E102

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0: new header with target audience/language/English link/module link, numbered table of contents with anchors, chapter numbering |
| 0.1.0 | 2025-12-05 | Initial (clean start): pipeline orchestration, filters (skip, BUILD_ONLY, platforms) |
