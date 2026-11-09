# Libraries.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** In Development (Pre-Release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [Libraries.md](../../../../de/guide/module/project/Libraries.md)  
> **Module:** [`cmake/project/Libraries.cmake`](../../../../../cmake/project/Libraries.cmake)  
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

The `Libraries.cmake` module is the **orchestrator of the library pipeline**. It iterates over all libraries in Solution.json and delegates to LibraryCollect and LibraryCreate.

### Core Idea

Analogous to Executables.cmake — one module coordinates the entire library process.

### Responsibilities

| Area | Description |
|------|-------------|
| Iteration | Over the libraries array |
| Filters | skip, BUILD_ONLY, platform |
| Delegation | To the Collect and Create modules |
| Duplicate check | Does the target already exist? |

### Loads Automatically

- LibraryCollect.cmake
- LibraryCreate.cmake

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
Libraries.cmake
    │
    ├── 1. Load Sub-Modules
    │   ├── LibraryCollect.cmake
    │   └── LibraryCreate.cmake
    │
    ├── 2. Get libraries array from SOLUTION_JSON
    │   └── Return early if empty
    │
    └── 3. For each library:
        │
        ├── 3.1 Extract JSON
        │   └── E001 if no name
        │
        ├── 3.2 Create Context (LIB_0, LIB_1, ...)
        │
        ├── 3.3 _collect_library() → Fills Context
        │
        ├── 3.4 Check Filters:
        │   ├── skip=true → Continue
        │   ├── BUILD_ONLY → Not in list → Continue
        │   └── platform → Not matching → Continue
        │
        ├── 3.5 Duplicate Check
        │   └── E102 if target exists
        │
        └── 3.6 _create_library_target() → CMake Target
```

### 3.2 Context Naming

| Index | Context prefix |
|-------|----------------|
| 0 | `LIB_0` |
| 1 | `LIB_1` |
| n | `LIB_n` |

---

## 4. Filter Mechanisms

### 4.1 skip Flag

```json
{
    "name": "LegacyLib",
    "skip": true
}
```

### 4.2 BUILD_ONLY

```bash
cmake -B build -DBUILD_ONLY="CoreLib;UtilLib"
```

### 4.3 platform

```json
{
    "name": "WinHelper",
    "platform": "windows"
}
```

**Note:** Libraries use `platform` (singular), executables use `platforms` (plural/array).

---

## 5. Error Handling

### 5.1 Fatal Errors

| Code | Condition | Solution |
|------|-----------|----------|
| E001 | Library has no `name` field | Add a name |
| E102 | Target already exists | Make the name unique |

---

## 6. Debug Output

```
-- [Libraries] === Library Pipeline Start ===
-- [Libraries] Processing 2 library(ies)...
-- [Libraries] --- Processing: CoreLib ---
-- [Libraries]   Created: CoreLib
-- [Libraries] --- Processing: UtilLib ---
-- [Libraries]   Created: UtilLib
-- [Libraries] 
-- [Libraries] === Library Pipeline Complete ===
-- -------------------------------------------
```

---

## 7. See Also

- [LibraryCollect.cmake](LibraryCollect.md) — JSON to context
- [LibraryCreate.cmake](LibraryCreate.md) — Context to target
- [Executables.cmake](Executables.md) — Analogous module for executables
- [ErrorCodes.md](../../references/ErrorCodes.md) — E001, E102

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0: new header with target audience/language/English link/module link, numbered table of contents with anchors, chapter numbering |
| 0.1.0 | 2025-12-07 | Initial (clean start): pipeline orchestration |
