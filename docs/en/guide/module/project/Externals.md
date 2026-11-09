# Externals.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** In Development (Pre-Release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [Externals.md](../../../../de/guide/module/project/Externals.md)  
> **Module:** [`cmake/project/Externals.cmake`](../../../../../cmake/project/Externals.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Processing](#3-processing)
4. [Load Order](#4-load-order)
5. [Debug Output](#5-debug-output)
6. [See Also](#6-see-also)
7. [Changelog](#7-changelog)

---

## 1. Overview

The `Externals.cmake` module is the **entry point for external dependencies**. It processes all externals from Solution.json and dispatches them to the orchestrator.

### Core Idea

Central processing of all externals BEFORE libraries and executables, so that all targets are available.

### Responsibilities

| Area | Description |
|------|-------------|
| Iteration | Over the externals object (key-value) |
| Dispatch | To the orchestrator for type-specific processing |
| Timing | Runs BEFORE libraries/executables |

### Loads Automatically

- cmake/externals/Orchestrator.cmake

---

## 2. Dependencies

| Module | Version | Usage |
|--------|---------|-------|
| Errors.cmake | 0.5.0 | (indirectly via the orchestrator) |
| Debug.cmake | 0.5.0 | `dbg`, `dbg_init`, `dbgspace`, `enddbgblock` |
| Json.cmake | 0.5.0 | `_json_has_key`, `_json_get_object` |
| Solution.cmake | 0.5.0 | `SOLUTION_JSON` property |

---

## 3. Processing

### 3.1 Pipeline Flow

```
Externals.cmake
    │
    ├── 1. Load Orchestrator.cmake
    │
    ├── 2. Get externals block from SOLUTION_JSON
    │   └── Return early if empty
    │
    ├── 3. Store as SOLUTION_EXTERNALS_JSON
    │
    └── 4. For each external (key-value):
        │
        ├── 4.1 Get name (key)
        │
        ├── 4.2 Get definition (value)
        │
        ├── 4.3 Check skip flag
        │   ├── skip: true  → Mark as SKIPPED, continue to next
        │   └── skip: false → Proceed with orchestration
        │
        └── 4.4 _orchestrate_external(name, definition)
```

### 3.2 Skip Feature

With `skip: true`, externals can be prepared but not yet loaded:

```json
{
    "externals": {
        "bass": { "path": "externals/bass" },
        "future_lib": { 
            "git": "https://...", 
            "tag": "v1.0.0",
            "skip": true
        }
    }
}
```

**Behavior:**
- Skipped externals are stored in the `SKIPPED_EXTERNALS` property
- `apply_external_to_target()` checks this list → **E013 FATAL** when used
- Works for local, fetched and system externals

### 3.3 Externals Structure

```json
{
    "externals": {
        "bass": { "path": "externals/bass" },
        "imgui": { "git": "https://...", "tag": "v1.90" },
        "glfw": { "git": "https://...", "tag": "3.3.8" }
    }
}
```

Each key is passed to the orchestrator individually.

---

## 4. Load Order

```
CMakeLists.txt
    │
    ├── Load core modules
    │
    ├── Solution.cmake           ← Load JSON
    │
    ├── Externals.cmake          ← HERE (before Libraries!)
    │   └── _orchestrate_external() for each external
    │
    ├── Libraries.cmake          ← Can use externals
    │
    └── Executables.cmake        ← Can use externals
```

**Important:** Externals must be loaded BEFORE Libraries and Executables!

---

## 5. Debug Output

```
-- [Externals] === Externals Pipeline Start ===
-- [Externals] Processing 3 external(s)...
-- [Externals] --- Processing: bass ---
-- [Externals] --- Processing: imgui ---
-- [Externals] --- Processing: glfw ---
-- [Externals] 
-- [Externals] === Externals Pipeline Complete ===
-- -------------------------------------------
```

---

## 6. See Also

- [Orchestrator.cmake](../externals/Orchestrator_cmake.md) — Type-specific handling
- [Solution.cmake](Solution.md) — Provides SOLUTION_JSON
- [Fetch.cmake](../externals/core/Fetch_cmake.md) — Git fetching
- [Local_Attach.cmake](../externals/locals/Attach_cmake.md) — Local externals

---

## 7. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.6.0 | 2025-12-20 | Skip feature: externals with `skip: true` are not loaded, SKIPPED_EXTERNALS property |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0 |
| 0.1.0 | 2025-12-08 | Initial (clean start): externals pipeline |
