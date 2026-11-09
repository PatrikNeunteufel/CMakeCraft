# Apps.cmake — Documentation

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** ModuleDoc  
> **Status:** In Development  
> **Target Audience:** Build system developers  
> **Module:** [cmake/project/Apps.cmake](../../../../../cmake/project/Apps.cmake)  
> **Module Version:** 1.0.0  
> **Based on:** ModuleDoc v0.5  
> **Language:** English  
> **German:** [Apps.md](../../../../de/guide/module/project/Apps.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Concept](#3-concept)
4. [Pipeline Flow](#4-pipeline-flow)
5. [Generated Targets](#5-generated-targets)
6. [Filter Mechanisms](#6-filter-mechanisms)
7. [Usage Examples](#7-usage-examples)
8. [Error Handling](#8-error-handling)
9. [Best Practices](#9-best-practices)
10. [See Also](#10-see-also)
11. [Changelog](#11-changelog)

---

## 1. Overview

The `Apps` module is the **orchestrator for the app container pipeline**. It iterates over all `apps[]` entries in Solution.json and coordinates the creation of all associated targets.

### Purpose

- Iteration over the `apps[]` array in Solution.json
- Application of skip and platform filters
- Coordination of target creation (Core, Runner, Tests)
- Debug output for tracing the pipeline

### Generated Targets per App

| Target | Type | Description |
|--------|------|-------------|
| `{AppName}.Core` | STATIC library | Business logic, testable |
| `{AppName}` | Executable | Entry point (main()) |
| `{AppName}.{TestName}` | Test executable | one per entry in `tests.targets[]` (optional, only with `BUILD_TESTS`), e.g. `{AppName}.UnitTests` |

---

## 2. Dependencies

| Dependency | Type | Description |
|------------|------|-------------|
| CMake 3.19+ | System | JSON functions |
| `Errors.cmake` | Module | Error handling |
| `Debug.cmake` | Module | Debug output |
| `Json.cmake` | Module | JSON parsing |
| `Context.cmake` | Module | Context object pattern |
| `Solution.cmake` | Module | Solution properties |

### Auto-Loaded

| Module | Description |
|--------|-------------|
| `AppCollect.cmake` | JSON → context transformation |
| `AppCreate.cmake` | Target creation |

---

## 3. Concept

### 3.1 Pipeline Architecture

```
Solution.json
     │
     ▼
┌─────────────────────────────────────────────────────────┐
│                    Apps.cmake                            │
│  ┌─────────────────────────────────────────────────┐    │
│  │              For each app:                       │    │
│  │                                                  │    │
│  │  1. Extract JSON                                │    │
│  │  2. AppCollect → Context                        │    │
│  │  3. Check skip filter                           │    │
│  │  4. Check BUILD_ONLY filter                     │    │
│  │  5. Check platform filter                       │    │
│  │  6. Duplicate check                             │    │
│  │  7. Call AppCreate:                             │    │
│  │     a. _create_app_core()                       │    │
│  │     b. _create_app_runner()                     │    │
│  │     c. _create_app_tests() (if BUILD_TESTS)     │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

### 3.2 Separation of Concerns

| Module | Responsibility |
|--------|----------------|
| `Apps.cmake` | Orchestration, filters, iteration |
| `AppCollect.cmake` | JSON parsing, filling the context |
| `AppCreate.cmake` | CMake target creation |

---

## 4. Pipeline Flow

### 4.1 Step by Step

```
1. Load Solution.json (GLOBAL PROPERTY)
2. Check whether the 'apps' array exists
3. For each entry in the array:
   │
   ├─ Extract JSON
   ├─ Validate name (E401 if missing)
   ├─ Create & fill context
   │
   ├─ Skip check (skip=true → skip)
   ├─ BUILD_ONLY check (not in list → skip)
   ├─ Platform check (not supported → skip)
   │
   ├─ Duplicate check (E102 if target exists)
   │
   └─ Create targets:
      ├─ _create_app_core()    → {AppName}.Core
      ├─ _create_app_runner()  → {AppName}
      └─ _create_app_tests()   → {AppName}.{targets[].name} (if BUILD_TESTS)
```

### 4.2 Early Exit Conditions

| Condition | Action |
|-----------|--------|
| No `apps` array | Return (no error) |
| Empty `apps` array | Return (no error) |
| `skip=true` | Continue with the next app |
| Not in `BUILD_ONLY` | Continue with the next app |
| Platform not supported | Continue with the next app |

---

## 5. Generated Targets

### 5.1 Target Naming Convention

```
AudioPlayer.Core            ← STATIC library
AudioPlayer                 ← Executable
AudioPlayer.UnitTests       ← Test (entry "UnitTests" in tests.targets[])
AudioPlayer.IntegrationTests ← Test (entry "IntegrationTests" in tests.targets[])
```

The name of a test target is `{AppName}.{name}`, with `name` from `tests.targets[]` (`AppCreate.cmake`, `_create_app_tests`).

```
```

### 5.2 Target Dependencies

```
AudioPlayer.Core
     │
     ├──────────────────┬────────────────────────────┐
     ▼                  ▼                            ▼
AudioPlayer      AudioPlayer.UnitTests     AudioPlayer.IntegrationTests
```

---

## 6. Filter Mechanisms

### 6.1 Skip Flag

```json
{
    "apps": [
        {
            "name": "DisabledApp",
            "skip": true
        }
    ]
}
```

### 6.2 BUILD_ONLY

```bash
cmake -B build -DBUILD_ONLY="AudioPlayer;VideoPlayer"
```

The module checks both `{AppName}` and `{AppName}.Core` against the BUILD_ONLY list.

### 6.3 Platform Filter

```json
{
    "apps": [
        {
            "name": "WindowsOnlyApp",
            "platforms": ["windows"]
        }
    ]
}
```

**Supported platforms:**
- `windows` → WIN32
- `linux` → CMAKE_SYSTEM_NAME = "Linux"
- `macos` → APPLE
- `unix` → UNIX

---

## 7. Usage Examples

### 7.1 Inclusion in CMakeCraft.cmake

`CMakeCraft.cmake` loads the module itself; a project does not include it.

```cmake
# After externals, libraries and executables
include("${CMAKECRAFT_DIR}/project/Apps.cmake")
```

### 7.2 Solution.json with Apps

```json
{
    "solution": {
        "name": "MyProject",
        "version": "1.0.0"
    },
    
    "externals": {
        "bass": { "path": "externals/bass" },
        "doctest": { "path": "externals/doctest" }
    },
    
    "apps": [
        {
            "name": "AudioPlayer",
            "core": {
                "externals": ["bass"]
            },
            "runner": {
                "type": "CONSOLE"
            },
            "tests": {
                "framework": "doctest",
                "targets": [
                    {
                        "name": "UnitTests",
                        "type": "unit",
                        "path": "tests/unit/UnitTests",
                        "labels": ["unit", "audio"]
                    },
                    {
                        "name": "IntegrationTests",
                        "type": "integration"
                    }
                ]
            }
        }
    ]
}
```

### 7.3 Build Commands

```bash
# Build all apps
cmake -B build
cmake --build build

# Only a specific app
cmake -B build -DBUILD_ONLY="AudioPlayer"

# With tests
cmake -B build -DBUILD_TESTS=ON
ctest --test-dir build -L AudioPlayer
```

---

## 8. Error Handling

### 8.1 Errors Raised

| Code | Condition | Message |
|------|-----------|---------|
| `E401` | `name` missing | `App #N has no 'name' field` |
| `E102` | Target exists | `Target '{AppName}.Core' already exists` |
| `E102` | Target exists | `Target '{AppName}' already exists` |

### 8.2 Errors from Submodules

Additional errors can be raised by `AppCollect` and `AppCreate` (E402-E407, W401-W403).

---

## 9. Best Practices

### 9.1 Do's

| Recommendation | Rationale |
|----------------|-----------|
| Load apps after libraries/executables | Dependencies must exist |
| Use unique app names | Avoids E102 |
| Platform filter for OS-specific apps | Clean cross-platform build |

### 9.2 Don'ts

| Avoid | Reason |
|-------|--------|
| App name = library name | Target collision |
| Including Apps.cmake multiple times | `include_guard(GLOBAL)` prevents this |
| Expecting tests without BUILD_TESTS | Tests are only created when the flag is set |

---

## 10. See Also

- [AppCollect.cmake](AppCollect.md) — JSON parsing
- [AppCreate.cmake](AppCreate.md) — Target creation
- [Executables.cmake](Executables.md) — Similar pattern for executables
- [AppContainer_Concept.md](../../../konzepte/abgeschlossen/AppContainer_Concept.md) — Architecture concept
- [ErrorCodes.md](../../references/ErrorCodes.md) — Error code reference

---

## 11. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: test targets from `tests.targets[]` (name `{AppName}.{name}`) instead of `tests.unit`/`tests.integration`; inclusion via `${CMAKECRAFT_DIR}` in `CMakeCraft.cmake`** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.0 | 2025-12-17 | Initial: Phase 8 app container orchestrator, skip/platform/BUILD_ONLY filters, target creation via AppCreate |
