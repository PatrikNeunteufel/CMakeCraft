# App Container — Architecture Concept

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Concept  
> **Status:** Implemented  
> **Phase:** 8 (completed)  
> **Target Audience:** Build System Developers, Architects  
> **Language:** English  
> **German:** [AppContainer_Concept.md](../../../de/konzepte/abgeschlossen/AppContainer_Concept.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Directory Structure](#2-directory-structure)
3. [Solution.json Integration](#3-solutionjson-integration)
4. [Tests Configuration](#4-tests-configuration)
5. [CMake Modules](#5-cmake-modules)
6. [Error Codes](#6-error-codes)
7. [Build Output Structure](#7-build-output-structure)
8. [Example: Complete App Container](#8-example-complete-app-container)
9. [Migration: Executable → App Container](#9-migration-executable--app-container)
10. [See Also](#10-see-also)
11. [Changelog](#11-changelog)

---

## 1. Overview

### 1.1 Motivation

The current build system supports executables as monolithic units. This leads to problems with testability:

| Problem | Description |
|---------|--------------|
| **Not testable** | Business logic is mixed with `main()` |
| **Code duplication** | To test modules, sources have to be copied manually |
| **Circular dependencies** | Test targets cannot simply link against executable code |

### 1.2 Solution: App Container

An **app container** separates the application logic from the entry point logic:

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
│            │                                                    │
│            ▼                                                    │
│     ┌───────────┐                                               │
│     │ AppName   │                                               │
│     │(Executable)│                                              │
│     └───────────┘                                               │
└─────────────────────────────────────────────────────────────────┘
```

### 1.3 Compatibility

| Mode | JSON array | Description | Testability |
|-------|------------|--------------|-------------|
| **Executable** | `executables[]` | Monolithic executable | Limited |
| **App container** | `apps[]` | Separate core library + runner | Full testability |

**Both modes use the same default paths:**
- Executables: `projects/exec/{name}/`
- App containers: `projects/apps/{name}/`

**Existing projects continue to work** — the `executables[]` section remains fully supported.

### 1.4 Design Principles

| Principle | Implementation |
|---------|-----------|
| **Single Source of Truth** | Everything in `Solution.json`, no separate `app.json` |
| **Convention over Configuration** | Fixed directory structure, minimal configuration |
| **Central externals** | Externals only in the `externals{}` block, never in apps |
| **Consistency** | Same patterns as legacy (Source.cmake, PCH, etc.) |
| **Flexible tests** | Any number of tests per app via `tests.targets[]` |

---

## 2. Directory Structure

### 2.1 App Container Layout

```
projects/apps/{AppName}/
├── include/                    # PUBLIC headers → {AppName}.Core
│   ├── Source.cmake
│   └── *.hpp
├── src/                        # Implementation → {AppName}.Core
│   ├── Source.cmake
│   └── *.cpp
├── main/                       # Entry point → {AppName}
│   ├── Source.cmake
│   └── main.cpp
├── pch/                        # Precompiled header (optional)
│   └── pch.h
└── tests/
    ├── unit/
    │   └── {TestName}/         # → {AppName}.{TestName}
    │       ├── Source.cmake
    │       ├── test_main.cpp
    │       └── test_*.cpp
    ├── integration/
    │   └── {TestName}/
    │       └── ...
    └── performance/
        └── {TestName}/
            └── ...
```

### 2.2 Symmetry include/ ↔ src/

```
include/                    src/
├── Audio/                  ├── Audio/
│   ├── Player.hpp          │   ├── Player.cpp
│   └── Decoder.hpp         │   └── Decoder.cpp
├── UI/                     ├── UI/
│   └── Window.hpp          │   └── Window.cpp
└── Core/                   └── Core/
    └── Application.hpp         └── Application.cpp
```

### 2.3 Overall Structure in the Project

```
project_root/
├── Solution.json
├── projects/
│   ├── apps/                    # App containers
│   │   ├── MyVisualizer/
│   │   └── DemoPlayer/
│   ├── exec/                    # Legacy executables
│   │   └── MinimalConsole/
│   ├── libs/                    # Libraries
│   │   └── CoreLib/
│   └── tests/                   # Standalone tests
│       └── CoreLib_UnitTests/
└── externals/
    └── bass/
```

---

## 3. Solution.json Integration

### 3.1 Complete Example

```json
{
    "solution": {
        "name": "MySolution",
        "version": "1.0.0"
    },
    
    "externals": {
        "bass": { "path": "externals/bass" },
        "glad": { "path": "externals/glad" },
        "glfw": { "git": "https://github.com/glfw/glfw.git", "tag": "3.4" },
        "doctest": { "path": "externals/doctest" }
    },
    
    "apps": [
        {
            "name": "MyVisualizer",
            "displayName": "My Visualizer Application",
            "version": "1.0.0",
            
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
                "framework": "doctest",
                "targets": [
                    {
                        "name": "UnitTests",
                        "type": "unit",
                        "path": "tests/unit/UnitTests"
                    },
                    {
                        "name": "IntegrationTests",
                        "type": "integration",
                        "path": "tests/integration/IntegrationTests",
                        "externals": ["bass"]
                    }
                ]
            },
            
            "platforms": ["windows", "linux", "macos"]
        }
    ]
}
```

### 3.2 App Definition Schema

| Field | Type | Required | Default | Description |
|------|-----|---------|---------|--------------|
| `name` | string | ✅ | — | Unique app name |
| `displayName` | string | — | `name` | Display name |
| `version` | string | — | Solution version | App version |
| `description` | string | — | `""` | Description |
| `skip` | bool | — | `false` | Skip the entire app |
| `path` | string | — | `projects/apps/{name}` | Base path |
| `core` | object | — | `{}` | Core library configuration |
| `runner` | object | — | `{}` | Runner executable configuration |
| `pch` | object | — | `{}` | PCH configuration |
| `tests` | object | — | `{}` | Test configuration |
| `platforms` | array | — | all | Target platforms |

### 3.3 Core Definition Schema

| Field | Type | Default | Description |
|------|-----|---------|--------------|
| `dependencies` | array | `[]` | Internal library dependencies |
| `externals` | array | `[]` | External dependencies |

### 3.4 Runner Definition Schema

| Field | Type | Default | Description |
|------|-----|---------|--------------|
| `type` | string | `"CONSOLE"` | CONSOLE or GUI |
| `externals` | array | `[]` | Additional externals (GUI, etc.) |

### 3.5 PCH Definition Schema

| Field | Type | Default | Description |
|------|-----|---------|--------------|
| `enabled` | bool | `false` | Enable PCH |
| `header` | string | `"pch.h"` | Header file name in `pch/` |

---

## 4. Tests Configuration

### 4.1 Flexible Test Targets

The tests are configured via a `targets[]` array, which allows any number of tests with individual configuration.

→ **Detailed concept:** [App_Tests_Targets_Concept.md](App_Tests_Targets_Concept.md)

### 4.2 Tests Definition Schema

| Field | Type | Default | Description |
|------|-----|---------|--------------|
| `skip` | bool | `false` | **Skip all tests of this app** |
| `framework` | string | — | Default framework for all tests |
| `targets` | array | `[]` | Test target definitions |

### 4.3 Test Target Schema

| Field | Type | Required | Default | Description |
|------|-----|---------|---------|--------------|
| `name` | string | ✅ | — | Target name (→ `{AppName}.{name}`) |
| `type` | string | ✅ | — | Test type (unit, integration, etc.) |
| `skip` | bool | — | `false` | Skip this test |
| `path` | string | — | `tests/{type}/{name}` | Path relative to the app directory |
| `framework` | string | — | `tests.framework` | Framework override |
| `timeout` | number | — | Type-dependent | CTest timeout (seconds) |
| `labels` | array | — | Type-dependent | CTest labels |
| `externals` | array | — | `[]` | Additional externals |
| `parallel` | bool | — | Type-dependent | Parallel execution |

### 4.4 Known Test Types

| Type | Default Timeout | Default Parallel | Description |
|-----|-----------------|------------------|--------------|
| `unit` | 30s | true | Isolated function/class tests |
| `integration` | 120s | true | Component interactions |
| `performance` | 300s | false | Benchmarks, time measurements |
| `system` | 180s | false | End-to-end tests |
| `smoke` | 10s | true | Quick basic checks |
| `fuzz` | 60s | false | Random/invalid inputs |
| `security` | 120s | false | Security tests |
| `ui` | 180s | false | User interface tests |
| `api` | 60s | true | API endpoint tests |

### 4.5 Skip Feature

The skip feature allows tests to be disabled temporarily:

```json
"tests": {
    "skip": true,           // Global: skip all tests
    "framework": "doctest",
    "targets": [
        {
            "name": "UnitTests",
            "type": "unit",
            "skip": false    // Ignored if global skip=true
        },
        {
            "name": "SlowTests",
            "type": "performance",
            "skip": true     // Skipped individually
        }
    ]
}
```

**Skip logic:**

| Global `tests.skip` | Target `skip` | Result |
|---------------------|---------------|----------|
| `true` | any | ⏭️ Skipped |
| `false`/missing | `true` | ⏭️ Skipped |
| `false`/missing | `false`/missing | ✅ Is built |

### 4.6 Example: Multiple Tests

```json
"tests": {
    "framework": "doctest",
    "targets": [
        {
            "name": "Core_UnitTests",
            "type": "unit",
            "path": "tests/unit/core",
            "timeout": 30,
            "labels": ["unit", "core", "fast"]
        },
        {
            "name": "Utils_UnitTests",
            "type": "unit",
            "path": "tests/unit/utils"
        },
        {
            "name": "Audio_IntegrationTests",
            "type": "integration",
            "externals": ["bass"],
            "timeout": 120
        },
        {
            "name": "Benchmarks",
            "type": "performance",
            "skip": true,
            "labels": ["performance", "nightly"]
        }
    ]
}
```

---

## 5. CMake Modules

### 5.1 Module Overview

| Module | Version | Description |
|-------|---------|--------------|
| `Apps.cmake` | v0.5.x | Pipeline orchestrator, filter |
| `AppCollect.cmake` | v0.6.1 | JSON → context, tests parsing |
| `AppCreate.cmake` | v0.6.1 | Create core, runner, tests |
| `Json.cmake` | v0.6.0 | JSON helper (central) |

### 5.2 Pipeline

```
1. Apps.cmake: iterate the apps array
2. AppCollect: parse JSON, create context
   - App metadata
   - Core configuration
   - Runner configuration
   - Tests with targets[]
3. Check filters:
   - skip
   - platforms
   - BUILD_ONLY
4. AppCreate:
   a. Create core library (STATIC)
   b. Configure PCH (if enabled)
   c. Create runner executable
   d. Create tests (for each target in tests.targets[])
      - Check global skip
      - Check per-target skip
      - Apply type defaults
      - Resolve framework
      - Register with CTest
```

### 5.3 Generated Targets

For an app `MyVisualizer` with 3 test targets:

| Target | Type | Description |
|--------|-----|--------------|
| `MyVisualizer.Core` | STATIC Library | Business logic |
| `MyVisualizer` | Executable | Entry point + core |
| `MyVisualizer.UnitTests` | Executable | Unit tests |
| `MyVisualizer.IntegrationTests` | Executable | Integration tests |
| `MyVisualizer.Benchmarks` | Executable | Performance tests |

---

## 6. Error Codes

### 6.1 App Container Errors (E4xx)

| Code | Description |
|------|--------------|
| E401 | App definition: 'name' is required |
| E402 | App path does not exist |
| E403 | App has no src/ directory |
| E404 | App has no source files in src/ |
| E405 | App dependency not found |
| E406 | App has no main/ directory |
| E407 | App has no source files in main/ |

### 6.2 App Tests Errors

| Code | Description |
|------|--------------|
| E301 | No framework specified for test |
| E302 | Unknown test framework |
| E303 | Test target: 'name' missing |
| E304 | Test target: 'type' missing |
| E305 | Test path does not exist |
| E306 | No source files in test path |

### 6.3 App Container Warnings (W4xx)

| Code | Description |
|------|--------------|
| W401 | App has no include/ directory |
| W402 | PCH enabled but header not found |
| W402 | Test with serial type has parallel=true |
| W403 | Tests directory exists but no sources found |

> **Code today (2026-11-09):** E306 does not exist in the code. A test path without source files is reported by warning W403 `Test '${TARGET_NAME}': No source files found`, and the test is skipped (`cmake/project/AppCreate.cmake:702`); W403 is also used for `App '${_name}': tests.targets configured but no tests/ directory` (`AppCreate.cmake:577`). Besides the missing `include/` (`AppCreate.cmake:96`), W401 also reports `App '${_name}': tests.targets is empty` (`cmake/project/AppCollect.cmake:338`). An app entry without a name is reported by `cmake/project/Apps.cmake:86` with E401; `AppCollect.cmake:183` checks the same with E400.

---

## 7. Build Output Structure

```
out/build/{preset}/
├── apps/
│   └── MyVisualizer/
│       ├── bin/
│       │   └── Debug/
│       │       └── MyVisualizer.exe
│       ├── lib/
│       │   └── Debug/
│       │       └── MyVisualizer.Core.lib
│       └── tests/
│           └── Debug/
│               ├── MyVisualizer.UnitTests.exe
│               ├── MyVisualizer.IntegrationTests.exe
│               └── MyVisualizer.Benchmarks.exe
├── exec/
│   └── MinimalConsole/
└── lib/
    └── CoreLib/
```

---

## 8. Example: Complete App Container

### 8.1 Solution.json

```json
{
    "apps": [
        {
            "name": "AudioPlayer",
            "displayName": "Audio Player",
            "version": "2.0.0",
            
            "core": {
                "dependencies": ["BasicLogger"],
                "externals": ["bass", "spdlog"]
            },
            
            "runner": {
                "type": "GUI",
                "externals": ["imgui", "glad", "glfw"]
            },
            
            "pch": {
                "enabled": true
            },
            
            "tests": {
                "framework": "doctest",
                "targets": [
                    {
                        "name": "Core_UnitTests",
                        "type": "unit",
                        "path": "tests/unit/core",
                        "labels": ["unit", "audio", "fast"]
                    },
                    {
                        "name": "Playback_IntegrationTests",
                        "type": "integration",
                        "path": "tests/integration/playback",
                        "externals": ["bass"],
                        "labels": ["integration", "audio"]
                    },
                    {
                        "name": "Benchmarks",
                        "type": "performance",
                        "path": "tests/performance/benchmarks",
                        "skip": true
                    }
                ]
            }
        }
    ]
}
```

### 8.2 CMake Output

```
[Apps] --- Processing: AudioPlayer ---
[Apps]   Path: projects/apps/AudioPlayer
[Apps]   Core: AudioPlayer.Core
[Apps]     - Dependencies: BasicLogger
[Apps]     - Externals: bass, spdlog
[Apps]   Runner: AudioPlayer (GUI)
[Apps]     - Externals: imgui, glad, glfw
[Apps]   PCH: Enabled (pch/pch.h)
[Apps]   Tests:
[Apps]     - Created: AudioPlayer.Core_UnitTests (unit, doctest)
[Apps]     - Created: AudioPlayer.Playback_IntegrationTests (integration, doctest)
[Apps]     - SKIP: AudioPlayer.Benchmarks (skip=true)
```

---

## 9. Migration: Executable → App Container

### 9.1 Before (Executable)

```json
"executables": [
    {
        "name": "MyApp",
        "type": "CONSOLE",
        "path": "projects/exec/MyApp/src",
        "externals": ["bass"]
    }
]
```

```
projects/exec/MyApp/
└── src/
    ├── main.cpp
    ├── Application.cpp
    └── Application.hpp
```

### 9.2 After (App Container)

```json
"apps": [
    {
        "name": "MyApp",
        "core": {
            "externals": ["bass"]
        },
        "runner": {
            "type": "CONSOLE"
        },
        "tests": {
            "framework": "doctest",
            "targets": [
                { "name": "UnitTests", "type": "unit" }
            ]
        }
    }
]
```

```
projects/apps/MyApp/
├── include/
│   └── Application.hpp
├── src/
│   └── Application.cpp
├── main/
│   └── main.cpp
└── tests/
    └── unit/
        └── UnitTests/
            ├── Source.cmake
            ├── test_main.cpp
            └── test_Application.cpp
```

### 9.3 Migration Steps

1. **Create the directory:** `projects/apps/{name}/`
2. **Split the sources:**
   - Headers → `include/`
   - Implementation → `src/`
   - main.cpp → `main/`
3. **Adjust Solution.json:**
   - Move from `executables[]` to `apps[]`
   - Split externals into `core` or `runner`
4. **Add tests:**
   - Create `tests/unit/{TestName}/`
   - `test_main.cpp` with the framework main
   - Create test files

---

## 10. See Also

- [App_Tests_Targets_Concept.md](App_Tests_Targets_Concept.md) — Flexible test configuration
- [Solution_Schema.md](../../guide/references/Solution_Schema.md) — JSON schema reference
- [ErrorCodes.md](../../guide/references/ErrorCodes.md) — Error codes
- [App Template](../../../../templates/App/README.md) — Template for new apps

---

## 11. Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: "Code today" note on §6 (no E306, W401/W403 as used in the code, E400)** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.6.0 | 2025-12-18 | Phase 8 completed: new tests.targets[] structure (replaces tests.unit/integration), skip feature (global + per target), type-based defaults, framework override, W402 parallel warning, status set to "Implemented" |
| 0.5.0 | 2025-12-14 | Initial: concept for core/runner separation |
