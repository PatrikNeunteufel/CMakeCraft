# Solution.cmake — Module Documentation

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** ModuleDoc  
> **Status:** In Development (Pre-Release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5, Solution_Schema v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [Solution.md](../../../../de/guide/module/project/Solution.md)  
> **Module:** [`cmake/project/Solution.cmake`](../../../../../cmake/project/Solution.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Properties Set](#3-properties-set)
4. [Processing](#4-processing)
5. [Debug Output](#5-debug-output)
6. [Error Handling](#6-error-handling)
7. [Usage Examples](#7-usage-examples)
8. [See Also](#8-see-also)
9. [Changelog](#changelog)

---

## 1. Overview

The `Solution.cmake` module is the **central configuration loader** of the build system. It reads `Solution.json` and sets global properties for all subsequent modules.

### Core Idea

One JSON file defines the entire project configuration — Solution.cmake makes it available to CMake.

### Responsibilities

| Area | Description |
|------|-------------|
| JSON loading | Reads and validates Solution.json |
| Metadata | Name, version, description, authors |
| Standards | C/C++ standard, extensions |
| Defaults | Library/executable types |
| Externals | Cache paths, update policy |

### Used By

- All subsequent modules (Executables, Libraries, Externals, Tests)

---

## 2. Dependencies

| Module | Version | Usage |
|--------|---------|-------|
| Errors.cmake | 0.5.0 | `cmake_fatal`, `cmake_warn` |
| Debug.cmake | 0.5.0 | `dbg`, `dbg_init`, `enddbgblock` |
| Json.cmake | 0.5.0 | All `_json_*` functions |
| Validation.cmake | 0.5.0 | Schema validation (indirect) |

**Load order:** Solution.cmake must be loaded after the core modules.

---

## 3. Properties Set

### 3.1 Global Properties

| Property | Type | Description |
|----------|------|-------------|
| `SOLUTION_JSON` | String | Complete JSON string |
| `SOLUTION_NAME` | String | Project name |
| `SOLUTION_VERSION` | String | Project version (e.g. "1.0.0") |
| `SOLUTION_DESCRIPTION` | String | Project description |
| `SOLUTION_AUTHORS` | List | Authors (semicolon-separated) |
| `SOLUTION_SCHEMA_VERSION` | String | Schema version (e.g. "0.1") |
| `SOLUTION_SETTINGS_JSON` | String | settings block as JSON |
| `SOLUTION_EXTERNALS_JSON` | String | externals block as JSON |
| `SOLUTION_LIBRARIES_JSON` | String | libraries array as JSON |
| `SOLUTION_EXECUTABLES_JSON` | String | executables array as JSON |
| `SOLUTION_CXX_STANDARD` | Int | C++ standard (e.g. 20) |
| `SOLUTION_C_STANDARD` | Int | C standard (e.g. 17) |
| `SOLUTION_DEFAULT_LIBRARY_TYPE` | String | Default: "STATIC" |
| `SOLUTION_DEFAULT_EXECUTABLE_TYPE` | String | Default: "CONSOLE" |
| `SOLUTION_SOURCE_MODE` | String | "explicit", "glob", or "auto" |
| `SOLUTION_EXTERNALS_CACHE_ROOT` | Path | Default: "externals/_cache" |
| `SOLUTION_EXTERNALS_SOURCE_ROOT` | Path | Default: "externals/_src" |
| `SOLUTION_EXTERNALS_UPDATE_POLICY` | String | Default: "checkout" |
| `SOLUTION_EXTERNALS_POLICY_JSON` | String | externalsPolicy block as JSON |

### 3.2 CMake Cache Variables

| Variable | Value | Description |
|----------|-------|-------------|
| `CMAKE_CXX_STANDARD` | From settings.standards | C++ standard |
| `CMAKE_CXX_STANDARD_REQUIRED` | ON/OFF | Standard required |
| `CMAKE_CXX_EXTENSIONS` | ON/OFF | Compiler extensions |
| `CMAKE_C_STANDARD` | From settings.standards | C standard |
| `CMAKE_C_STANDARD_REQUIRED` | ON/OFF | Standard required |
| `CMAKE_C_EXTENSIONS` | ON/OFF | Compiler extensions |

---

## 4. Processing

### 4.1 Flow

```
Solution.json
    │
    ├── 1. Read file
    │   └── E002 if not found
    │
    ├── 2. Check schema version
    │   ├── E002 if missing or not MAJOR.MINOR
    │   ├── E003 if MAJOR ≠ 1
    │   └── W101 / W102 if MINOR lower / higher than current
    │
    ├── 3. Extract solution block
    │   ├── E001 if missing
    │   ├── name (required) → SOLUTION_NAME
    │   ├── version → SOLUTION_VERSION
    │   ├── description → SOLUTION_DESCRIPTION
    │   └── authors[] → SOLUTION_AUTHORS
    │
    ├── 4. Extract settings block
    │   ├── standards → CMAKE_*_STANDARD
    │   ├── defaults → SOLUTION_DEFAULT_*
    │   └── sources.mode → SOLUTION_SOURCE_MODE
    │
    ├── 5. Extract externalsPolicy
    │   ├── cacheRoot → SOLUTION_EXTERNALS_CACHE_ROOT
    │   ├── sourceRoot → SOLUTION_EXTERNALS_SOURCE_ROOT
    │   └── updatePolicy → SOLUTION_EXTERNALS_UPDATE_POLICY
    │
    └── 6. Extract arrays
        ├── externals → SOLUTION_EXTERNALS_JSON
        ├── libraries → SOLUTION_LIBRARIES_JSON
        └── executables → SOLUTION_EXECUTABLES_JSON
```

### 4.2 Version Parsing

The version can be given as a string or as an object:

```json
// String format
"version": "1.2.3"

// Object format
"version": {
    "major": 1,
    "minor": 2,
    "patch": 3
}
```

---

## 5. Debug Output

### 5.1 Standard Output (SHOW_LEVEL = 2)

```
-- [Solution] Solution.json loaded
-- [Solution] MySolution v1.0.0
-- [Solution] C++ Standard: 20
-- [Solution] Source mode: explicit
-- [Solution] Externals defined: 8
-- [Solution] Executables: 3, Libraries: 1, Tests: 2
-- -------------------------------------------
```

### 5.2 Verbose Output (SHOW_LEVEL = 5)

```bash
cmake -B build -DDEBUG_DEFAULT_LEVEL=5
```

```
-- [Solution] Solution.json loaded
-- [Solution] Schema version: 0.1
-- [Solution] MySolution v1.0.0
-- [Solution] Description: Multi-Project Solution
-- [Solution] Authors: Author Name
-- [Solution] C++ Standard: 20
-- [Solution] C Standard: 17
-- [Solution] Default library type: STATIC
-- [Solution] Default executable type: CONSOLE
-- [Solution] Source mode: explicit
-- [Solution] Externals cache: externals/_cache
-- [Solution] Externals source: externals/_src
-- [Solution] Update policy: checkout
-- [Solution] Externals defined: 8
-- [Solution] Executables: 3, Libraries: 1, Tests: 2
-- -------------------------------------------
```

---

## 6. Error Handling

### 6.1 Fatal Errors

| Code | Condition | Solution |
|------|-----------|----------|
| E001 | `solution` block missing | Add the block to the JSON |
| E001 | `solution.name` missing | Add the name field |
| E002 | Solution.json not found | Create the file in the project root |
| E002 | `schemaVersion` missing or not in the format `MAJOR.MINOR` (`cmake/project/Solution.cmake:82`, `:94`) | Add or correct the field |
| E003 | `schemaVersion` with a different major version (`Solution.cmake:102`) | Use schema `1.x` |

### 6.2 Warnings

| Code | Condition | Recommendation |
|------|-----------|----------------|
| W101 | schemaVersion lower than the current one (`Solution.cmake:107`) | Raise the schema to the current version |
| W102 | schemaVersion higher than the current one (`Solution.cmake:109`) | Update CMakeCraft |

Solution.cmake does not raise W001 (schema < 0.1); it only appears in `validate_solution_schema()`,
which nothing calls (as of 2026-11-09, see [Validation.md §3.5](../core/Validation.md#35-validate_solution_schema)).

---

## 7. Usage Examples

### 7.1 Minimal Solution.json

```json
{
    "schemaVersion": "0.1",
    "solution": {
        "name": "MyProject"
    }
}
```

### 7.2 Complete Solution.json

```json
{
    "schemaVersion": "0.1",
    "solution": {
        "name": "MyProject",
        "version": "1.0.0",
        "description": "My awesome project",
        "authors": ["Developer Name"]
    },
    "settings": {
        "standards": {
            "cxx_standard": "20",
            "cxx_standard_required": true,
            "cxx_extensions": false,
            "c_standard": "17"
        },
        "defaults": {
            "library_type": "STATIC",
            "executable_type": "CONSOLE"
        },
        "sources": {
            "mode": "explicit"
        }
    },
    "externalsPolicy": {
        "cacheRoot": "externals/_cache",
        "sourceRoot": "externals/_src",
        "updatePolicy": "checkout"
    },
    "externals": { },
    "libraries": [ ],
    "executables": [ ],
    "tests": [ ]
}
```

### 7.3 Querying Properties

```cmake
# In other modules
get_property(_name GLOBAL PROPERTY SOLUTION_NAME)
get_property(_version GLOBAL PROPERTY SOLUTION_VERSION)
get_property(_cxx GLOBAL PROPERTY SOLUTION_CXX_STANDARD)

message(STATUS "Building ${_name} v${_version} with C++${_cxx}")
```

---

## 8. See Also

- [Solution_Schema.md](../../references/Solution_Schema.md) — JSON schema reference
- [Executables.cmake](Executables.md) — Uses SOLUTION_EXECUTABLES_JSON
- [Libraries.cmake](Libraries.md) — Uses SOLUTION_LIBRARIES_JSON
- [Externals.cmake](Externals.md) — Uses SOLUTION_EXTERNALS_JSON
- [ErrorCodes.md](../../references/ErrorCodes.md) — E001, E002, E003, W101, W102

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: schema version check with E002, E003, W101, W102 instead of W001 (§4.1, §6; W001 is never raised)** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| **0.5.0** | **2025-12-15** | **Migration to Blueprint v0.5.0: new header with target audience/language/English link/module link, numbered table of contents with anchors, chapter numbering** |
| 0.1.1 | 2025-12-07 | SOLUTION_LIBRARIES_JSON, SOLUTION_EXECUTABLES_JSON added |
| 0.1.0 | 2025-12-03 | Initial (clean start): JSON parsing, global properties, debug output |
