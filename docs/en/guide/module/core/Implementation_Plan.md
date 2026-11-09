# Implementation Plan — CMake Architecture

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Concept  
> **Status:** Phases 1-7 completed, phase 8 in progress  
> **Based on:** master_concept v0.5, Solution_Schema v0.1, ErrorCodes v0.1  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [Implementation_Plan.md](../../../../de/guide/module/core/Implementation_Plan.md)

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
9. [Phase 8: AppContainer (in progress)](#9-phase-8-appcontainer-in-progress)
10. [Phase 9: System Externals (planned)](#10-phase-9-system-externals-planned)
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
| 8 | AppContainer | 🔄 In progress |
| 9 | System Externals | 🔄 Planned |

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
Phase 8: AppContainer (planned)
    ↓
Phase 9: System Externals (planned)
```

---

## 2. Phase 1: Foundation

**Status:** ✅ Completed

**Goal:** Basic infrastructure for all further modules.

### Modules

| Module | Description |
|--------|-------------|
| `Errors.cmake` | `cmake_fatal()`, `cmake_warn()`, `cmake_assert()` |
| `Debug.cmake` | Debug system with levels |
| `Context.cmake` | Context object pattern |
| `Json.cmake` | JSON helper functions |
| `Validation.cmake` | Schema validation |
| `SourceCollect.cmake` | Source file management |
| `OutputDirs.cmake` | Output directories |
| `Warnings.cmake` | Warning levels |
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
|--------|-------------|
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
|--------|-------------|
| `Executables.cmake` | Main loop over executables |
| `ExecutableCollect.cmake` | JSON → context |
| `ExecutableCreate.cmake` | Create the target |

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
10. Set Warnings
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
|--------|-------------|
| `Libraries.cmake` | Main loop |
| `LibraryCollect.cmake` | JSON → context |
| `LibraryCreate.cmake` | Create the target |
| `Dependencies.cmake` | Internal dependencies |

### Library Types

| Type | CMake |
|------|-------|
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
|--------|-------------|
| `Orchestrator.cmake` | Dispatch by external type |
| `Local/Attach.cmake` | Call Include.cmake |

### Flow

```
1. Detect the external type (path → local)
2. Determine the Include.cmake path
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
|--------|-------------|
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
1. Check the convention path
2. Check the explicit path (E216 if missing)
3. Load the PreFetch hook (if present)
4. FetchContent_Declare/MakeAvailable
5. Load the PostFetch hook (if present)
6. Enter the target in the registry
```

### New Error/Warning Codes

| Code | Type | Description |
|------|------|-------------|
| E218 | Error | External not cached and offline mode active |
| W302 | Warning | Version mismatch but offline mode - using cache |

### Success Criterion

```cmake
# spdlog is fetched to .externals/spdlog/
# ImGui PostFetch hook creates the target
# E216 for a missing explicit hook
# Switching presets uses the cache
```

---

## 8. Phase 7: Test Pipeline

**Status:** ✅ Completed

**Goal:** Test targets with framework integration and CTest.

### Modules

| Module | Description |
|--------|-------------|
| `Tests.cmake` | Main loop over the tests array |
| `TestCollect.cmake` | JSON → context |
| `TestCreate.cmake` | Create the test target |
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
            "timeout": 30
        }
    ]
}
```

### Supported Frameworks

| Framework | Description | Recommended for |
|-----------|-------------|-----------------|
| `doctest` | Fast, header-only | Unit tests, CI |
| `googletest` | Feature-rich, mocking | Large projects |
| `catch2` | BDD style, sections | Readable tests |

### Test Types

| Type | Description | Typical labels |
|------|-------------|----------------|
| `unit` | Individual functions/classes | `fast`, `isolated` |
| `integration` | Interplay of components | `slow`, `database` |
| `system` | Entire system | `e2e`, `slow` |
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

# Verbose on failure
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

## 9. Phase 8: AppContainer (in progress)

**Status:** 🔄 In progress

**Goal:** Testable app architecture with Core/Runner separation.

→ **Detailed concept:** [AppContainer_Concept.md](../../../konzepte/abgeschlossen/AppContainer_Concept.md)

### Modules

| Module | Status | Description |
|--------|--------|-------------|
| `Apps.cmake` | ✅ Implemented | Pipeline orchestrator, filters (skip, platform, BUILD_ONLY) |
| `AppCollect.cmake` | ✅ Implemented | JSON → context transformation |
| `AppCreate.cmake` | ✅ Implemented | Target creation (Core, Runner, Tests) |
| `Phase8.cmake` | ✅ Implemented | Build system test |

### Generated Targets

The following targets are created per app:

| Target | Type | Description |
|--------|------|-------------|
| `{AppName}.Core` | STATIC library | Business logic (testable) |
| `{AppName}` | Executable | Entry point (main()) |
| `{AppName}.UnitTests` | Executable | Unit tests (optional) |
| `{AppName}.IntegrationTests` | Executable | Integration tests (optional) |

### Directory Structure

```
projects/apps/{AppName}/
├── include/    → PUBLIC headers (Core)
├── src/        → Implementation (Core)
├── main/       → Entry point (Runner)
├── pch/        → Precompiled headers (optional)
└── tests/
    ├── unit/        → Unit tests
    └── integration/ → Integration tests
```

### Error Code Range

| Range | Codes | Category |
|-------|-------|----------|
| E4xx | E401-E407 | AppContainer errors |
| W4xx | W401-W403 | AppContainer warnings |

### Open Points

- [ ] SourceCollect.cmake integration (currently GLOB)
- [ ] UserGuide for the app container
- [ ] English documentation

---

## 10. Phase 9: System Externals (planned)

**Status:** 🔄 Planned

**Goal:** Integrate system libraries via `find_package()`.

→ **Detailed concept:** [System_Externals_Concept.md](../../../konzepte/abgeschlossen/System_Externals_Concept.md)

### Key Points

- Integrate Qt, Boost, OpenCV via `find_package()`
- New `find_package` field in the Solution.json externals
- Hybrid externals (system with fallback to fetched)

### Error Code Range

| Range | Category |
|-------|----------|
| E5xx | System-external-specific errors |

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

### Phase 8 🔄

- ✅ Apps.cmake
- ✅ AppCollect.cmake
- ✅ AppCreate.cmake
- ✅ Phase8.cmake (build system test)
- ✅ DemoPlayer test app
- ✅ Core/Runner/Tests separation
- ✅ Platform filter
- ✅ Unit tests with doctest
- [ ] SourceCollect.cmake integration
- [ ] UserGuide for the app container

### Phase 9 (planned)

- [ ] System/FindExternal.cmake
- [ ] Hybrid external support
- [ ] Qt/Boost/OpenCV tests

---

## 12. See Also

- [master_concept.md](../../../konzepte/abgeschlossen/Master_Concept.md) — architecture
- [guidelines.md](../../../konzepte/Guidelines.md) — conventions
- [AppContainer_Concept.md](../../../konzepte/abgeschlossen/AppContainer_Concept.md) — phase 8 detail
- [System_Externals_Concept.md](../../../konzepte/abgeschlossen/System_Externals_Concept.md) — phase 9 detail
- [Solution_Schema](../../references/Solution_Schema.md) — JSON schema
- [ErrorCodes](../../references/ErrorCodes.md) — error codes

---

## 13. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.1 | 2025-12-17 | Phase 8 in progress: Apps.cmake, AppCollect.cmake, AppCreate.cmake implemented, DemoPlayer test app, Core/Runner/Tests separation |
| 0.5.0 | 2025-12-14 | Phases 1-7 completed, Fetch v0.2 details integrated, test pipeline details integrated, phases 8/9 referenced as planned, Blueprint v0.5.0 format |
| 0.1.0 | 2025-12-03 | Initial (clean start): phases taken over from v1.5 |
