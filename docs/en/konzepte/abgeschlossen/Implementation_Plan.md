# Implementation Plan — CMake Architecture

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Concept  
> **Status:** Phases 1-9 completed  
> **Based on:** master_concept v0.7, Solution_Schema v0.7, ErrorCodes v0.1  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [Implementation_Plan.md](../../../de/konzepte/abgeschlossen/Implementation_Plan.md)

This plan describes the step-by-step implementation of the CMake build system.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Phase 1: Foundation](#2-phase-1-foundation)
3. [Phase 2: Solution & Validation](#3-phase-2-solution--validation)
4. [Phase 3: Executable Pipeline](#4-phase-3-executable-pipeline)
5. [Phase 4: Library Pipeline](#5-phase-4-library-pipeline)
6. [Phase 5: Local Externals](#6-phase-5-local-externals)
7. [Phase 6: Fetched Externals + Hooks](#7-phase-6-fetched-externals--hooks)
8. [Phase 7: Test Pipeline](#8-phase-7-test-pipeline)
9. [Phase 8: App Container](#9-phase-8-app-container)
10. [Phase 9: System Externals](#10-phase-9-system-externals)
11. [Checklist](#11-checklist)
12. [See Also](#12-see-also)
13. [Changelog](#13-changelog)

---

## 1. Overview

### Phase Status

| Phase | Name | Status |
|-------|------|--------|
| 1 | Foundation | ✅ Completed |
| 2 | Solution & Validation | ✅ Completed |
| 3 | Executable Pipeline | ✅ Completed |
| 4 | Library Pipeline | ✅ Completed |
| 5 | Local Externals | ✅ Completed |
| 6 | Fetched Externals + Hooks | ✅ Completed |
| 7 | Test Pipeline | ✅ Completed |
| 8 | App Container | ✅ Completed |
| 9 | System Externals | ✅ Completed |

### Phase Flow

```
Phase 1: Foundation (core modules)
    ↓
Phase 2: Solution & Validation
    ↓
Phase 3: Executable Pipeline
    ↓
Phase 4: Library Pipeline
    ↓
Phase 5: Local Externals
    ↓
Phase 6: Fetched Externals + Hooks (.externals/ caching)
    ↓
Phase 7: Test Pipeline (doctest, googletest, catch2)
    ↓
Phase 8: App Container (Core/Runner/Tests)
    ↓
Phase 9: System Externals (find_package) ← CURRENTLY COMPLETED
```

---

## 2. Phase 1: Foundation

**Status:** ✅ Completed

**Goal:** Basic infrastructure for all further modules.

### Modules

| Module | Description |
|-------|--------------|
| `Errors.cmake` | `cmake_fatal()`, `cmake_warn()`, `cmake_assert()` |
| `Debug.cmake` | Debug system with levels |
| `Context.cmake` | Context object pattern |
| `Json.cmake` | JSON helper functions |
| `Validation.cmake` | Schema validation |
| `SourceCollect.cmake` | Source file management |
| `OutputDirs.cmake` | Target directories |
| `Warnings.cmake` | Warning level |
| `CompilerOptions.cmake` | Compiler configuration |

### Success Criterion

```bash
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=ON
# Phase 1 tests pass
```

---

## 3. Phase 2: Solution & Validation

**Status:** ✅ Completed

**Goal:** Read and validate Solution.json.

### Modules

| Module | Description |
|-------|--------------|
| `Solution.cmake` | Load JSON, set GLOBAL properties |

### Functions

```cmake
# Load Solution.json
_load_solution_json()

# Validate required fields
validate_solution_structure()

# Merge settings with defaults
_apply_settings_defaults()
```

### Success Criterion

```cmake
# After include(Solution.cmake):
# - SOLUTION_JSON is set
# - SOLUTION_NAME is available
# - SOLUTION_VERSION is available
# - SOLUTION_SETTINGS_JSON is available
```

---

## 4. Phase 3: Executable Pipeline

**Status:** ✅ Completed

**Goal:** Create executables from Solution.json.

### Modules

| Module | Description |
|-------|--------------|
| `Executables.cmake` | Main loop over executables |
| `ExecutableCollect.cmake` | JSON → context |
| `ExecutableCreate.cmake` | Create target |

### Pipeline

```
1. Parse JSON
2. Create context (ctx_create)
3. Extract fields (ctx_set)
4. Check BUILD_ONLY
5. Check skip
6. Load Source.cmake or GLOB
7. add_executable()
8. Configure PCH
9. Apply CompilerOptions
10. Set warnings
11. Set OutputDirs
```

### Success Criterion

```bash
cmake -B build
cmake --build build
./build/bin/MinimalConsole  # "Hello World"
```

---

## 5. Phase 4: Library Pipeline

**Status:** ✅ Completed

**Goal:** Create libraries from Solution.json.

### Modules

| Module | Description |
|-------|--------------|
| `Libraries.cmake` | Main loop |
| `LibraryCollect.cmake` | JSON → context |
| `LibraryCreate.cmake` | Create target |
| `Dependencies.cmake` | Internal dependencies |

### Library Types

| Type | CMake |
|-----|-------|
| STATIC | `add_library(X STATIC)` |
| SHARED | `add_library(X SHARED)` |
| INTERFACE | `add_library(X INTERFACE)` |

### Success Criterion

```cmake
# Library is created
# Executable can link against the library
target_link_libraries(MyApp PRIVATE CoreLib)
```

---

## 6. Phase 5: Local Externals

**Status:** ✅ Completed

**Goal:** Integrate local externals.

### Modules

| Module | Description |
|-------|--------------|
| `Orchestrator.cmake` | Dispatch by external type |
| `Local/Attach.cmake` | Call Include.cmake |

### Flow

```
1. Detect external type (path → local)
2. Determine Include.cmake path
3. Set variables (EXECUTABLE_NAME, EXTERNAL_ELEMENT_OPTIONS)
4. Load Include.cmake
5. Check warnings (W103, W104)
```

### Success Criterion

```cmake
# BASS loads correctly
# target_link_libraries works
# DLLs are copied
```

---

## 7. Phase 6: Fetched Externals + Hooks

**Status:** ✅ Completed

**Goal:** Fetch Git externals with .externals/ caching, hook system.

### Modules

| Module | Description |
|-------|--------------|
| `Core/Fetch.cmake` | FetchContent wrapper with caching |
| `Core/Hash.cmake` | Config hashing |
| `Core/Policies.cmake` | Update strategy |
| `Hooks/HookLoader.cmake` | Hook system |
| `Registry/Targets.cmake` | Target registry |

### .externals/ Caching (Fetch v0.2.0)

```
project_root/
├── .externals/                 ← Fetched externals (gitignored)
│   ├── glfw/
│   ├── imgui/
│   └── .lockfile.json
├── externals/                  ← Local externals (committed)
│   └── bass/
└── build/                      ← All presets share .externals/
```

**Advantages:**
- Download only once (not per preset)
- Offline mode possible (`EXTERNALS_OFFLINE=ON`)
- Force re-fetch (`EXTERNALS_FORCE_FETCH=ON`)

### Hook Flow

```
1. Check convention path
2. Check explicit path (E216 if missing)
3. Load PreFetch hook (if present)
4. FetchContent_Declare/MakeAvailable
5. Load PostFetch hook (if present)
6. Enter target in the registry
```

### New Error/Warning Codes

| Code | Type | Description |
|------|-----|--------------|
| E218 | Error | External not cached and offline mode active |
| W302 | Warning | Version mismatch but offline mode - use cache |

### Success Criterion

```cmake
# spdlog is fetched into .externals/spdlog/
# ImGui PostFetch hook creates the target
# E216 for a missing explicit hook
# Preset switch uses the cache
```

---

## 8. Phase 7: Test Pipeline

**Status:** ✅ Completed

**Goal:** Test targets with framework integration and CTest.

### Modules

| Module | Description |
|-------|--------------|
| `Tests.cmake` | Main loop over the tests array |
| `TestCollect.cmake` | JSON → context |
| `TestCreate.cmake` | Create test target |
| `TestFrameworks.cmake` | Framework-specific configuration |

### Solution.json Schema

```json
{
    "tests": [
        {
            "name": "CoreLib_Tests",
            "type": "unit",
            "framework": "doctest",
            "dependencies": ["CoreLib"],
            "externals": ["doctest"],
            "labels": ["unit", "fast"],
            "timeout": 30,
            "skip": false
        }
    ]
}
```

### Supported Frameworks

| Framework | Description | Recommended for |
|-----------|--------------|---------------|
| `doctest` | Fast, header-only | Unit tests, CI |
| `googletest` | Feature-rich, mocking | Large projects |
| `catch2` | BDD style, sections | Readable tests |

### Test Types

| Type | Description | Typical labels |
|-----|--------------|-----------------|
| `unit` | Individual functions/classes | `fast`, `isolated` |
| `integration` | Component interplay | `slow`, `database` |
| `system` | Overall system | `e2e`, `slow` |
| `performance` | Benchmarks | `benchmark`, `slow` |
| `smoke` | Quick basic tests | `fast`, `critical` |

### CTest Integration

```bash
# All tests
ctest --test-dir build

# Unit tests only
ctest -L unit

# Parallel
ctest -j8

# Verbose on failures
ctest --output-on-failure
```

### Success Criterion

```bash
cmake -B build -DBUILD_TESTS=ON
cmake --build build
ctest --test-dir build
# All tests pass
```

---

## 9. Phase 8: App Container

**Status:** ✅ Completed

**Goal:** Testable app architecture with core/runner separation and flexible test targets.

→ **Detailed concept:** [AppContainer_Concept.md](AppContainer_Concept.md)  
→ **Test concept:** [App_Tests_Targets_Concept.md](App_Tests_Targets_Concept.md)

### Modules

| Module | Version | Description |
|-------|---------|--------------|
| `Apps.cmake` | v0.5.x | Pipeline orchestrator, filter (skip, platform, BUILD_ONLY) |
| `AppCollect.cmake` | v0.6.1 | JSON → context, tests parsing with targets[] |
| `AppCreate.cmake` | v0.6.1 | Target creation (core, runner, tests), skip handling |
| `Json.cmake` | v0.6.0 | New helpers: `_json_get_bool_or_default`, `_json_get_array_as_list` |

### Generated Targets

The following targets are created per app:

| Target | Type | Description |
|--------|-----|--------------|
| `{AppName}.Core` | STATIC Library | Business logic (testable) |
| `{AppName}` | Executable | Entry point (main/) |
| `{AppName}.{TestName}` | Executable | Tests (for each target in tests.targets[]) |

### Directory Structure

```
projects/apps/{AppName}/
├── include/    → PUBLIC headers (core)
├── src/        → Implementation (core)
├── main/       → Entry point (runner)
├── pch/        → Precompiled headers (optional)
└── tests/
    └── {type}/
        └── {TestName}/   → Each test target
            ├── Source.cmake
            ├── test_main.cpp
            └── test_*.cpp
```

### Flexible Test Configuration

```json
"tests": {
    "skip": false,
    "framework": "doctest",
    "targets": [
        {
            "name": "Core_UnitTests",
            "type": "unit",
            "skip": false,
            "path": "tests/unit/core",
            "timeout": 30,
            "labels": ["unit", "core", "fast"],
            "parallel": true
        }
    ]
}
```

### Test Type Defaults

| Type | Timeout | Parallel | Labels |
|-----|---------|----------|--------|
| `unit` | 30s | true | `["unit", "fast"]` |
| `integration` | 120s | true | `["integration"]` |
| `performance` | 300s | false | `["performance", "benchmark"]` |
| `system` | 180s | false | `["system", "e2e", "slow"]` |
| `smoke` | 10s | true | `["smoke", "critical", "fast"]` |
| `fuzz` | 60s | false | `["fuzz", "security"]` |
| `security` | 120s | false | `["security"]` |
| `ui` | 180s | false | `["ui", "slow"]` |
| `api` | 60s | true | `["api", "integration"]` |

### Skip Feature

| Level | Field | Effect |
|-------|------|---------|
| App | `apps[].skip` | Skip the entire app |
| All tests | `apps[].tests.skip` | Skip all tests of the app |
| Individual test | `apps[].tests.targets[].skip` | Skip only this test |

**Skip logic:** Global skip takes precedence over per-target skip.

### Error Code Range

| Range | Codes | Category |
|---------|-------|-----------|
| E4xx | E401-E407 | App container errors |
| W4xx | W401-W403 | App container warnings |
| E3xx | E301-E306 | App tests errors |
| W402 | — | Parallel warning for serial test types |

### Success Criterion

```bash
cmake -B build -DBUILD_TESTS=ON
cmake --build build
# App targets created:
# - MyApp.Core (STATIC Library)
# - MyApp (Executable)
# - MyApp.UnitTests (Test)
# - MyApp.IntegrationTests (Test)
ctest --test-dir build -L MyApp
# Tests pass
```

---

## 10. Phase 9: System Externals

**Status:** ✅ Completed

**Goal:** Integrate system libraries via `find_package()`.

→ **Detailed concept:** [System_Externals_Concept.md](System_Externals_Concept.md)

### Modules

| Module | Version | Description |
|-------|---------|--------------|
| `System/Handler.cmake` | v0.1.0 | System external handler (find_package) |
| `System/PathResolver.cmake` | v0.1.0 | Multi-stage path resolution |
| `Orchestrator.cmake` | v0.3.0 | Dispatch: system → git → path |

### System External JSON Syntax

```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "version": ">=6.5.0",
    "components": ["Core", "Widgets", "Gui"],
    "hints": ["${QT_ROOT}"],
    "backup": "E:/Backup/Qt/6.7.0",
    "required": true
}
```

### Type Detection (Priority)

| Order | Field | Type |
|-------------|------|-----|
| 1 | `system: true` | System external |
| 2 | `git` | Fetched external |
| 3 | `path` | Local external |
| — | none | Error E012 |

### Path Resolution (Stages)

1. Environment variables ($QT_ROOT, $QT_DIR)
2. CMAKE_PREFIX_PATH
3. hints[] from Solution.json
4. Standard paths (C:/Qt/..., /opt/Qt/...)
5. backup path (with W501 warning)
6. Error E501/E503

> **Code today (2026-11-09, CMakeCraft v0.14.1):** E501 is dropped. `find_package()` runs without `REQUIRED` (`cmake/externals/system/Handler.cmake:270`, `:273`); if a package with `required` (default) is not found, `_system_external_not_found()` names the cause (`Handler.cmake:290`): E503 (`:101`, `:120`, `:128`), E504 (`:91`) or E505 (`:109`).

### Error Code Range

| Range | Category |
|---------|-----------|
| E5xx | System-external-specific errors |
| W5xx | System external warnings |

### Success Criterion

```bash
cmake -B build
# Qt6 is found via find_package()
# System external targets available (Qt6::Core, etc.)
# Phase 9 tests pass
```

---

## 11. Checklist

### Phase 1 ✅

- ✅ Errors.cmake
- ✅ Debug.cmake
- ✅ Context.cmake
- ✅ Json.cmake
- ✅ Validation.cmake
- ✅ SourceCollect.cmake
- ✅ OutputDirs.cmake
- ✅ Warnings.cmake
- ✅ CompilerOptions.cmake
- ✅ Phase 1 tests pass

### Phase 2 ✅

- ✅ Solution.cmake
- ✅ SOLUTION_* properties set
- ✅ Schema validation works

### Phase 3 ✅

- ✅ Executables.cmake
- ✅ ExecutableCollect.cmake
- ✅ ExecutableCreate.cmake
- ✅ MinimalConsole builds and runs

### Phase 4 ✅

- ✅ Libraries.cmake
- ✅ LibraryCollect.cmake
- ✅ LibraryCreate.cmake
- ✅ Dependencies.cmake
- ✅ Executable links against library

### Phase 5 ✅

- ✅ Orchestrator.cmake
- ✅ Local/Attach.cmake
- ✅ BASS loads correctly
- ✅ W103/W104 check

### Phase 6 ✅

- ✅ Core/Fetch.cmake (v0.2.0 with .externals/)
- ✅ Hooks/HookLoader.cmake
- ✅ Registry/Targets.cmake
- ✅ Git external is fetched
- ✅ Hook system works
- ✅ E216 for a missing hook
- ✅ Offline mode (E218, W302)

### Phase 7 ✅

- ✅ Tests.cmake
- ✅ TestCollect.cmake
- ✅ TestCreate.cmake
- ✅ TestFrameworks.cmake
- ✅ CTest integration
- ✅ doctest support
- ✅ googletest support
- ✅ catch2 support
- ✅ Labels and timeout
- ✅ Skip feature for standalone tests

### Phase 8 ✅

**Core modules:**
- ✅ Apps.cmake (pipeline orchestrator)
- ✅ AppCollect.cmake v0.6.1 (JSON → context)
- ✅ AppCreate.cmake v0.6.1 (create core/runner/tests)

**JSON helpers (Json.cmake v0.6.0):**
- ✅ `_json_get_bool_or_default()` - boolean with default
- ✅ `_json_get_array_as_list()` - array → CMake list

**Core/runner separation:**
- ✅ STATIC library for core (include/ + src/)
- ✅ Executable for runner (main/)
- ✅ Runner links against core
- ✅ PCH for core (optional)

**Flexible test targets:**
- ✅ tests.targets[] array structure
- ✅ Any number of tests per app
- ✅ Arbitrary test types (not only unit/integration/performance)
- ✅ Type-based defaults (timeout, parallel, labels)
- ✅ Framework override per test
- ✅ Path override per test
- ✅ Externals per test
- ✅ Labels per test
- ✅ Parallel control per test

**Skip feature:**
- ✅ Global tests.skip (all tests of an app)
- ✅ Per-target skip (individual test)
- ✅ Skip logic (global takes precedence)
- ✅ CMake output for skip

**Warnings:**
- ✅ W402 for parallel=true with serial test types

**Filters:**
- ✅ Platform filter
- ✅ BUILD_ONLY filter
- ✅ App-level skip

**Test apps:**
- ✅ MyVisualizer demo app
- ✅ DemoPlayer test app

**Documentation:**
- ✅ AppContainer_Concept.md v0.6.0
- ✅ App_Tests_Targets_Concept.md v0.1.1
- ✅ Solution_Schema.md v0.6.0 (apps[] section)
- ✅ Template README.md v0.2.1
- ✅ Template README_de.md v0.2.1
- ✅ Json.md v0.6.0

**Open (nice-to-have):**
- [ ] User guide for app containers (separate document)
- [ ] Synchronize English documentation

### Phase 9 ✅

**Core modules:**
- ✅ System/Handler.cmake (find_package integration)
- ✅ System/PathResolver.cmake (multi-stage search)
- ✅ Orchestrator.cmake v0.3.0 (system type dispatch)

**JSON schema:**
- ✅ system: true type detection
- ✅ package field (required for system)
- ✅ version field (optional)
- ✅ components[] array (optional)
- ✅ hints[] array (optional)
- ✅ backup field (optional)
- ✅ required field (optional, default: true)

**Type priority:**
- ✅ system → git → path → E012
- ✅ Mutual exclusion validated

**Path resolution:**
- ✅ Environment variables
- ✅ CMAKE_PREFIX_PATH
- ✅ hints[] from JSON
- ✅ Standard paths (platform-specific)
- ✅ backup with W501 warning

**Error/warning codes:**
- ✅ E501: System external not found
- ✅ E502: package field required
- ✅ E503: find_package() failed
- ✅ E504: Component not found
- ✅ E505: Version constraint failed
- ✅ W501: Using backup location
- ✅ W502: Version mismatch

> **Code today (2026-11-09, CMakeCraft v0.14.1):** Raised are E502 (`cmake/core/Validation.cmake:94`, `cmake/externals/system/Handler.cmake:180`), E503 (`Handler.cmake:101`, `:120`, `:128`, `:331`), E504 (`:91`), E505 (`:109`) and W501 (`:245`). `find_package()` runs without `REQUIRED` (`:270`, `:273`); the cause of a failure is named by `_system_external_not_found()`. E501 and W502 are dropped. The self-test checks E503–E505 (`cmake/buildSystemTest/phase9.cmake:498–609`).

**Tests:**
- ✅ Phase9.cmake build system test
- ✅ Qt6 system external tested

**Documentation:**
- ✅ System_Externals_Concept.md v0.7.0
- ✅ Solution_Schema.md v0.7.0 (system fields)
- ✅ Implementation_Plan.md v0.7.0
- ✅ Master_Concept.md v0.7.0

**Not in scope (deliberately removed):**
- ❌ Hybrid external support (system with fetched fallback)
- ❌ vcpkg/Conan integration (separate feature)

---

## 12. See Also

- [Master_Concept.md](Master_Concept.md) — Architecture
- [Guidelines.md](../Guidelines.md) — Conventions
- [AppContainer_Concept.md](AppContainer_Concept.md) — Phase 8 detail
- [App_Tests_Targets_Concept.md](App_Tests_Targets_Concept.md) — Flexible app tests
- [System_Externals_Concept.md](System_Externals_Concept.md) — Phase 9 detail
- [Solution_Schema](../../guide/references/Solution_Schema.md) — JSON schema
- [ErrorCodes](../../guide/references/ErrorCodes.md) — Error codes

---

## 13. Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: Phase 8 checklist "Runner links against core"; "Code today" notes on E501–E505/W502 (§10, §11), updated to CMakeCraft v0.14.1 (E502–E505 and W501 raised, E501/W502 dropped, `find_package` without `REQUIRED`)** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.7.0 | 2025-12-19 | Phase 9 completed: system externals (find_package), type priority system→git→path, PathResolver, error codes E5xx/W5xx, Phase9.cmake tests, hybrid support deliberately removed |
| 0.6.0 | 2025-12-18 | Phase 8 completed: complete checklist with all features (core/runner, flexible tests.targets[], skip feature, type defaults, Json.cmake v0.6.0), documentation complete |
| 0.5.1 | 2025-12-17 | Phase 8 in progress: Apps.cmake, AppCollect.cmake, AppCreate.cmake implemented, DemoPlayer test app, core/runner/tests separation |
| 0.5.0 | 2025-12-14 | Phases 1-7 completed, Fetch v0.2 details integrated, test pipeline details integrated, Phase 8/9 referenced as planned, Blueprint v0.5.0 format |
| 0.1.0 | 2025-12-03 | Initial (clean start): phases taken over from v1.5 |
