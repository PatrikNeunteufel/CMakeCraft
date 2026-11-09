# Master Concept — CMake Architecture

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Concept  
> **Status:** Stable (Phases 1-9 completed)  
> **Target Audience:** Build System Developers, Architects  
> **Language:** English  
> **German:** [Master_Concept.md](../../../de/konzepte/abgeschlossen/Master_Concept.md)

This document serves as the **central reference** for the CMake build system. It defines the structure, principles and technical foundation.

---

## Table of Contents

1. [Vision](#1-vision)
2. [Project Structure](#2-project-structure)
3. [Solution.json Schema](#3-solutionjson-schema)
4. [External Types](#4-external-types)
5. [Hook System](#5-hook-system)
6. [External Caching (.externals/)](#6-external-caching-externals)
7. [Context Object Pattern](#7-context-object-pattern)
8. [Source Management](#8-source-management)
9. [Error Handling](#9-error-handling)
10. [Pipelines](#10-pipelines)
11. [Test Pipeline](#11-test-pipeline)
12. [App Container](#12-app-container)
13. [Cache Variables](#13-cache-variables)
14. [Build System Tests](#14-build-system-tests)
15. [Documentation](#15-documentation)
16. [Planned Extensions](#16-planned-extensions)
17. [See Also](#17-see-also)
18. [Changelog](#18-changelog)

---

## 1. Vision

A modular, stable and cross-platform CMake system that can manage large multi-executable projects, is JSON-driven and has minimal global state.

### Core Principles

- **Declarative via JSON** — imperative only where necessary
- **No global state** — everything via context objects
- **Testable at every level** — unit, integration, end-to-end
- **Fail-fast** — clear error messages
- **Single Source of Truth** — for external versions
- **Convention over Configuration** — for optional features

---

## 2. Project Structure

The CMake infrastructure is divided into clearly separated areas of responsibility.

```
CMakeLists.txt                         # Top level: load modules
Solution.json                          # JSON definition of all targets
CMakePresets.json                      # Build presets

cmake/
  core/                                # Basic building blocks
    Errors.cmake                       # Error handling
    Debug.cmake                        # Debug system
    Context.cmake                      # Context object pattern
    Json.cmake                         # JSON helper functions
    Validation.cmake                   # Schema validation
    SourceCollect.cmake                # Source file management
    OutputDirs.cmake                   # Target folders
    Warnings.cmake                     # Warning level
    CompilerOptions.cmake              # Compiler options

  externals/                           # External system
    Orchestrator.cmake                 # High-level workflow
    Core/                              # For fetched externals
      Fetch.cmake                      # FetchContent with .externals/ caching
      Hash.cmake
      Policies.cmake
    Hooks/                             # Hook system
      HookLoader.cmake
      PreFetch/
      PostFetch/
    Local/                             # For local externals
      Attach.cmake
    Registry/                          # Target management
      Targets.cmake
      Linking.cmake

  project/                             # Pipelines
    Solution.cmake                     # Load Solution.json
    Executables.cmake                  # Executable pipeline
    ExecutableCollect.cmake
    ExecutableCreate.cmake
    Libraries.cmake                    # Library pipeline
    LibraryCollect.cmake
    LibraryCreate.cmake
    Tests.cmake                        # Test pipeline (standalone)
    TestCollect.cmake
    TestCreate.cmake
    TestFrameworks.cmake               # Framework-specific configuration
    Apps.cmake                         # App container pipeline
    AppCollect.cmake
    AppCreate.cmake
    Dependencies.cmake                 # Internal dependencies

.externals/                            # Fetched externals (gitignored)
  glfw/
  imgui/
  .lockfile.json

externals/                             # Local externals in the repo
  bass/
    Include.cmake
  lua/
    Include.cmake
  doctest/
    Include.cmake

projects/
  apps/                                # App containers (Phase 8)
    MyVisualizer/
    DemoPlayer/
  exec/                                # Legacy executables
    MinimalConsole/
  libs/                                # Libraries
    CoreLib/
  tests/                               # Standalone tests
    CoreLib_UnitTests/
```

---

## 3. Solution.json Schema

Solution.json is the heart of the declarative configuration.

**Current schema version:** `0.1`

### Root-Level Structure

```json
{
    "schemaVersion": "0.1",
    "solution": { },
    "settings": { },
    "externalsPolicy": { },
    "externals": { },
    "libraries": [ ],
    "executables": [ ],
    "tests": [ ],
    "apps": [ ]
}
```

| Block | Required | Description |
|-------|---------|--------------|
| `schemaVersion` | ✅ | Version of the JSON schema |
| `solution` | ✅ | Metadata (name, version, authors) |
| `settings` | ❌ | Global build settings |
| `externalsPolicy` | ❌ | Cache directory, update strategy |
| `externals` | ❌ | Central external definitions |
| `libraries` | ❌ | Internal libraries |
| `executables` | ❌ | Executable programs (monolithic) |
| `tests` | ❌ | Standalone test targets |
| `apps` | ❌ | **App containers (Core/Runner/Tests)** |

### Central Externals Block

**All external definitions are defined centrally.** Executables/apps reference them only by name.

| Problem (decentralized) | Solution (centralized) |
|---------------------|------------------|
| Version drift | One version for all |
| Update effort | Change one place |
| Inconsistent flags | Uniform configuration |

---

## 4. External Types

The type is detected automatically from the field that is present:

| Detection field | Type | Status |
|----------------|-----|--------|
| `system` | **system** | ✅ Implemented |
| `path` | **local** | ✅ Implemented |
| `git` | **fetched** | ✅ Implemented |
| `vcpkg` | **vcpkg** | ⬜ Planned |
| `conan` | **conan** | ⬜ Planned |

**Validation:** Exactly one of these fields must be present (error E012).

### Local Externals

Already reside in the repository.

```json
"externals": {
    "bass": { "path": "externals/bass" },
    "lua": { "path": "externals/lua" }
}
```

**Convention:** Every local external must have an `Include.cmake`.

### Fetched Externals

Are cloned from Git into `.externals/`.

```json
"externals": {
    "spdlog": {
        "git": "https://github.com/gabime/spdlog.git",
        "tag": "v1.12.0"
    }
}
```

| Field | Required | Description |
|------|---------|--------------|
| `git` | ✅ | Repository URL |
| `tag` | ❌* | Git tag |
| `branch` | ❌* | Git branch |
| `commit` | ❌* | Commit hash |
| `hooks` | ❌ | Pre/PostFetch hooks |
| `shallow` | ❌ | Shallow clone (default: true) |

*Exactly one of `tag`, `branch`, `commit` is required (error E215).

### System Externals

Libraries already installed on the system, via `find_package()`.

```json
"externals": {
    "qt6": {
        "system": true,
        "package": "Qt6",
        "version": ">=6.5.0",
        "components": ["Core", "Widgets", "Gui"],
        "hints": ["${QT_ROOT}"],
        "backup": "E:/Backup/Qt/6.7.0"
    }
}
```

| Field | Required | Default | Description |
|------|---------|---------|--------------|
| `system` | ✅ | — | Must be `true` |
| `package` | ✅ | — | Name for `find_package()` |
| `version` | ❌ | — | Version constraint |
| `components` | ❌ | `[]` | Package components |
| `hints` | ❌ | `[]` | Additional search paths |
| `backup` | ❌ | — | Emergency path (W501) |
| `required` | ❌ | `true` | Error if not found |

**Path resolution (stages):**
1. Environment variables ($QT_ROOT, $BOOST_ROOT)
2. CMAKE_PREFIX_PATH
3. hints[] from Solution.json
4. Standard paths (C:/Qt/, /opt/Qt/, etc.)
5. backup path (with W501 warning)
6. Error E501/E503

> **Code today (2026-11-09, CMakeCraft v0.14.1):** E501 is dropped. `find_package()` runs without `REQUIRED` (`cmake/externals/system/Handler.cmake:270`, `:273`); if a package with `required` (default) is not found, `_system_external_not_found()` names the cause (`Handler.cmake:290`): E503 (`:101`, `:120`, `:128`), E504 (`:91`) or E505 (`:109`).

→ Detail: [System_Externals_Concept.md](System_Externals_Concept.md)

---

## 5. Hook System

For externals that need special handling.

### Convention over Configuration

| Situation | Behavior |
|-----------|-----------|
| No hooks specified, no convention path | No hook |
| No hooks specified, convention path exists | Auto-load |
| Hooks specified explicitly, file exists | Load |
| Hooks specified explicitly, file missing | **Error E216** |

**Convention paths:**
- PreFetch: `cmake/externals/Hooks/PreFetch/${name}.cmake`
- PostFetch: `cmake/externals/Hooks/PostFetch/${name}.cmake`

---

## 6. External Caching (.externals/)

**Implemented in Phase 6 (Fetch.cmake v0.2.0)**

### Directory Structure

```
project_root/
├── .externals/                 ← Fetched externals (gitignored, hidden)
│   ├── glfw/
│   ├── imgui/
│   └── .lockfile.json          ← Version tracking
│
├── externals/                  ← Local externals (in the repository)
│   ├── bass/
│   └── lua/
│
└── build/                      ← Build directories (all share .externals/)
    ├── msvc-debug/
    ├── msvc-release/
    └── clang-release/
```

### Clear Separation

| Directory | Content | Git status | Source |
|-------------|--------|------------|--------|
| `externals/` | Local externals | ✅ Committed | `path` in Solution.json |
| `.externals/` | Fetched externals | ❌ Gitignored | `git` in Solution.json |

### CMake Options

| Option | Default | Description |
|--------|---------|--------------|
| `EXTERNALS_OFFLINE` | OFF | No network, cache only |
| `EXTERNALS_FORCE_FETCH` | OFF | Ignore cache, reload |

### Advantages

| Aspect | Before (v0.1.0) | After (v0.2.0) |
|--------|-----------------|------------------|
| **Download** | On every configure | Only once |
| **Preset switch** | New download | Immediate (cache) |
| **Offline** | Error | Works |
| **Storage** | N × copies | 1 × copy |

---

## 7. Context Object Pattern

Instead of global variables, each target uses its own namespace.

```cmake
ctx_create(EXE_MyApp)
ctx_set(EXE_MyApp NAME "MyApp")
ctx_set(EXE_MyApp PATH "src/app")
ctx_get(EXE_MyApp NAME _name)
```

**Advantages:**
- Isolated namespaces
- Parallel processing possible
- No state leaking

---

## 8. Source Management

Three modes for source files:

| Mode | Description |
|------|--------------|
| `explicit` | Source.cmake required (default) |
| `glob` | Automatic collection |
| `auto` | Source.cmake if present, otherwise GLOB |

**Recommendation:** `explicit` for maximum control.

---

## 9. Error Handling

Uniform system via `Errors.cmake`:

```cmake
cmake_fatal("E001" "Description")    # Aborts
cmake_warn("W001" "Description")     # Continues
cmake_assert(CONDITION "Message")    # Internal check
```

### Error Code Ranges

| Range | Category |
|---------|-----------|
| E0xx | JSON/parsing |
| E1xx | Target creation |
| E2xx | Externals |
| E3xx | Tests |
| E4xx | App container |
| E5xx | System externals (Phase 9) |
| W0xx | Deprecation |
| W1xx | Configuration |
| W2xx | Tools/setup |
| W3xx | External caching |
| W4xx | App container warnings |

> **Code today (2026-11-09):** E0xx–E5xx and W0xx–W5xx are in use; W5xx (system externals: W501, `cmake/externals/system/Handler.cmake:245`) is missing from this table. W6xx–W9xx occur only in the self-test (`cmake/buildSystemTest/`). Since module 1.1.0 (CMakeCraft v0.14.1) the header comment of `cmake/core/Errors.cmake:22–37` names all ranges E0xx–E5xx and W0xx–W9xx. The codes raised per range: [Guidelines.md §3.3](../Guidelines.md#33-error-codes).

---

## 10. Pipelines

### Executable Pipeline

1. **Collect:** JSON → context
2. **Validate:** required fields, dependencies
3. **Create:** create the CMake target
4. **Configure:** PCH, sources, externals, options

### Library Pipeline

Analogous to executables, additionally:
- PUBLIC/PRIVATE headers
- STATIC/SHARED/INTERFACE types

### App Pipeline

Extended pipeline for testable apps:
1. **Collect:** JSON → context (incl. tests.targets[])
2. **Filter:** skip, platforms, BUILD_ONLY
3. **Create Core:** STATIC library
4. **Create Runner:** executable (links against core)
5. **Create Tests:** for each target in tests.targets[]

---

## 11. Test Pipeline

**Implemented in Phase 7**

### Delimitation

| Test kind | Purpose | Location | Activation |
|----------|-------|-----|-------------|
| **Build system tests** | Test CMake modules | `cmake/buildSystemTest/` | `RUN_BUILD_SYSTEM_TESTS=ON` |
| **Standalone tests** | Test library code | `projects/tests/` | `BUILD_TESTS=ON` |
| **App tests** | Test app code | `projects/apps/{App}/tests/` | `BUILD_TESTS=ON` |

### Test Definition in Solution.json

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

| Framework | Recommended for |
|-----------|---------------|
| `doctest` | Fast unit tests, CI |
| `googletest` | Mocking, parameterized tests |
| `catch2` | BDD style, integrated benchmarks |

### Test Types

| Type | Description |
|-----|--------------|
| `unit` | Individual functions/classes |
| `integration` | Component interplay |
| `system` | Overall system |
| `performance` | Benchmarks |
| `smoke` | Quick basic tests |

---

## 12. App Container

**Implemented in Phase 8**

App containers enable a testable application architecture by separating business logic from the entry point.

→ **Detailed concept:** [AppContainer_Concept.md](AppContainer_Concept.md)  
→ **Test concept:** [App_Tests_Targets_Concept.md](App_Tests_Targets_Concept.md)

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      App-Container                              │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              AppName.Core (STATIC Library)                │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐                    │  │
│  │  │ Module A│  │ Module B│  │ Module C│   ...              │  │
│  │  └─────────┘  └─────────┘  └─────────┘                    │  │
│  └───────────────────────────────────────────────────────────┘  │
│                           │                                     │
│            ┌──────────────┼──────────────┐                      │
│            ▼              ▼              ▼                      │
│     ┌───────────┐  ┌────────────┐  ┌────────────┐               │
│     │   main/   │  │ UnitTests  │  │ Int.Tests  │               │
│     │ (Runner)  │  │            │  │            │               │
│     └───────────┘  └────────────┘  └────────────┘               │
└─────────────────────────────────────────────────────────────────┘
```

### Directory Structure

```
projects/apps/{AppName}/
├── include/    → PUBLIC headers (core)
├── src/        → Implementation (core)
├── main/       → Entry point (runner)
├── pch/        → Precompiled headers (optional)
└── tests/
    └── {type}/
        └── {TestName}/
            ├── Source.cmake
            ├── test_main.cpp
            └── test_*.cpp
```

### App Definition in Solution.json

```json
{
    "apps": [
        {
            "name": "MyVisualizer",
            "displayName": "My Visualizer",
            "version": "1.0.0",
            "skip": false,
            
            "core": {
                "dependencies": ["CoreLib"],
                "externals": ["bass"]
            },
            
            "runner": {
                "type": "GUI",
                "externals": ["glad", "glfw"]
            },
            
            "pch": {
                "enabled": true
            },
            
            "tests": {
                "skip": false,
                "framework": "doctest",
                "targets": [
                    {
                        "name": "UnitTests",
                        "type": "unit",
                        "skip": false
                    }
                ]
            }
        }
    ]
}
```

### Generated Targets

| Target | Type | Description |
|--------|-----|--------------|
| `{AppName}.Core` | STATIC Library | Business logic |
| `{AppName}` | Executable | Entry point |
| `{AppName}.{TestName}` | Executable | Tests |

### Flexible Test Configuration

- Any number of tests per app via `tests.targets[]`
- Arbitrary test types (not only unit/integration/performance)
- Type-based defaults for timeout, parallel, labels
- Framework override per test
- Skip feature (global + per target)

---

## 13. Cache Variables

| Variable | Default | Description |
|----------|---------|--------------|
| `BUILD_TESTS` | ON | Enable project tests |
| `BUILD_ONLY` | "" | Only specific targets |
| `RUN_BUILD_SYSTEM_TESTS` | OFF | CMake module tests |
| `ENABLE_CLANG_TIDY` | OFF | Code quality checks |
| `ENABLE_STRICT_CONFORMANCE` | ON | MSVC strict mode |
| `NO_EXCEPTIONS` | OFF | Disable exceptions |
| `NO_RTTI` | OFF | Disable RTTI |
| `EXTERNALS_OFFLINE` | OFF | Offline mode |
| `EXTERNALS_FORCE_FETCH` | OFF | Force re-fetch |

---

## 14. Build System Tests

| Test | Description |
|------|--------------|
| `test_context.cmake` | Context API |
| `test_json_helpers.cmake` | JSON parsing |
| `test_errors.cmake` | Error handling |
| `test_validation.cmake` | Schema validation |
| `test_simple_executable.cmake` | Minimal project |
| `test_externals_pipeline.cmake` | Fetch + registry |
| `test_local_externals.cmake` | Local externals |
| `test_hooks.cmake` | Hook system |

---

## 15. Documentation

| Document | Description |
|----------|--------------|
| **Solution_Schema** | JSON schema documentation (incl. apps[], system externals) |
| **ErrorCodes** | All error codes (E0xx-E5xx, W0xx-W5xx) |
| **guidelines** | Coding conventions |
| **implementation_plan** | Phase-based plan |
| **AppContainer_Concept** | App container architecture |
| **App_Tests_Targets_Concept** | Flexible app tests |
| **System_Externals_Concept** | System externals (find_package) |

---

## 16. Planned Extensions

### Post-Release

- vcpkg/Conan integration
- Parallelization of external fetching
- IDE integration (VSCode, CLion)
- Export mechanism for libraries
- Lockfile system for reproducible builds

---

## 17. See Also

- [Implementation_Plan.md](Implementation_Plan.md) — Phase-based plan
- [Guidelines.md](../Guidelines.md) — Conventions
- [AppContainer_Concept.md](AppContainer_Concept.md) — App container detail
- [App_Tests_Targets_Concept.md](App_Tests_Targets_Concept.md) — Flexible app tests
- [System_Externals_Concept.md](System_Externals_Concept.md) — Phase 9 detail
- [Future_Enhancements.md](../Future_Enhancements.md) — Post-release features

---

## 18. Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: `EXTERNALS_FORCE_FETCH` in §6 set to OFF (as in §13 and `cmake/externals/core/Fetch.cmake:50`); "Code today" note on the error code ranges (§9), updated to CMakeCraft v0.14.1; "Code today" note on E501/E503 (§4: E502–E505 raised, E501 dropped, `find_package` without `REQUIRED`)** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.7.0 | 2025-12-19 | Phase 9 completed: system externals (§4), system type before path/git, planned extensions updated (§16) |
| 0.6.0 | 2025-12-18 | Phase 8 completed: app container section (§12) added, apps[] in schema (§3), app pipeline in pipelines (§10), error code ranges extended (E4xx, W4xx) |
| 0.5.0 | 2025-12-14 | Phases 1-7 completed, Fetch v0.2 (.externals/ caching) integrated, test pipeline integrated, Blueprint v0.5.0 format, references to Phase 8/9 |
| 0.1.0 | 2025-12-03 | Initial (clean start): structure taken over from v1.7 |
