# App Tests Targets Concept

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Status:** Implemented  
> **Author:** CMake Architecture Team  
> **Language:** English  
> **German:** [App_Tests_Targets_Concept.md](../../../de/konzepte/abgeschlossen/App_Tests_Targets_Concept.md)

---

## 1. Overview

This concept describes the flexible test configuration for app containers by means of the `tests.targets[]` array. It allows any number of tests per app with individual configuration.

### 1.1 Goals

- Any number of tests per app
- Arbitrary test types (not restricted to unit/integration/performance)
- Individual framework per test
- Sensible defaults for known types
- Clear folder structure conventions
- **Flexible skipping of tests (global and per target)**

### 1.2 Non-Goals

- Backward compatibility with the old `tests.unit`/`tests.integration`/`tests.performance` structure
- Automatic migration of existing projects

---

## 2. JSON Schema

### 2.1 Complete Structure

```json
{
    "apps": [
        {
            "name": "MyApp",
            "tests": {
                "skip": false,
                "framework": "doctest",
                "targets": [
                    {
                        "name": "Core_UnitTests",
                        "type": "unit",
                        "skip": false,
                        "path": "tests/unit/core",
                        "framework": "doctest",
                        "timeout": 30,
                        "labels": ["unit", "core", "fast"],
                        "externals": [],
                        "parallel": true
                    }
                ]
            }
        }
    ]
}
```

### 2.2 Field Definitions

#### tests (Object)

| Field | Type | Required | Default | Description |
|------|-----|---------|---------|--------------|
| `skip` | bool | No | `false` | **Skip all tests of this app** |
| `framework` | string | No | — | Global default framework for all tests |
| `targets` | array | Yes | `[]` | List of test targets |

#### tests.targets[] (Object)

| Field | Type | Required | Default | Description |
|------|-----|---------|---------|--------------|
| `name` | string | Yes | — | Target name (becomes `{AppName}.{name}`) |
| `type` | string | Yes | — | Test type (unit, integration, etc.) |
| `skip` | bool | No | `false` | **Skip this test** |
| `path` | string | No | `tests/{type}/{name}` | Path relative to the app directory |
| `framework` | string | No | `tests.framework` | Test framework (doctest, googletest, catch2) |
| `timeout` | number | No | Type-dependent | CTest timeout in seconds |
| `labels` | array | No | Type-dependent | CTest labels |
| `externals` | array | No | `[]` | Additional externals for this test |
| `parallel` | bool | No | Type-dependent | Parallel execution allowed |

---

## 2.5 Skip Feature

The skip feature allows tests to be disabled temporarily without removing them from the configuration.

### 2.5.1 Global Skip

Skips **all** tests of an app:

```json
"tests": {
    "skip": true,
    "framework": "doctest",
    "targets": [
        { "name": "UnitTests", "type": "unit" },
        { "name": "IntegrationTests", "type": "integration" }
    ]
}
```

**CMake output:**
```
[Apps]   SKIP: All tests for MyApp (tests.skip=true)
```

### 2.5.2 Per-Target Skip

Skips individual tests:

```json
"tests": {
    "framework": "doctest",
    "targets": [
        { 
            "name": "UnitTests", 
            "type": "unit",
            "skip": false
        },
        { 
            "name": "IntegrationTests", 
            "type": "integration",
            "skip": true
        },
        { 
            "name": "PerformanceTests", 
            "type": "performance",
            "skip": true
        }
    ]
}
```

**CMake output:**
```
[Apps]   Created: MyApp.UnitTests (unit, doctest)
[Apps]   SKIP: MyApp.IntegrationTests (skip=true)
[Apps]   SKIP: MyApp.PerformanceTests (skip=true)
```

### 2.5.3 Skip Logic

| Global `tests.skip` | Target `skip` | Result |
|---------------------|---------------|----------|
| `true` | any | ⏭️ Skipped |
| `false` / missing | `true` | ⏭️ Skipped |
| `false` / missing | `false` / missing | ✅ Is built |

**Important:** Global skip takes precedence — if `tests.skip: true`, all tests are skipped, regardless of individual `skip` settings.

### 2.5.4 Use Cases

| Scenario | Configuration |
|----------|---------------|
| Make CI faster | `"tests": { "skip": true }` for apps with slow tests |
| Temporarily disable a broken test | `"skip": true` for an individual test |
| Performance tests only at night | `"skip": true`, the nightly pipeline sets it to `false` |
| Platform-specific tests | Combine with `platforms: []` |

### 2.5.5 Consistency with Other Targets

The skip feature behaves consistently with other target types:

| Target type | Skip property | Behavior |
|------------|---------------|-----------|
| `executables[]` | `skip: true` | Target is not created |
| `libraries[]` | `skip: true` | Target is not created |
| `tests[]` (standalone) | `skip: true` | Test is not created |
| `apps[].tests.skip` | `skip: true` | All app tests are skipped |
| `apps[].tests.targets[].skip` | `skip: true` | Individual app test is skipped |

---

## 3. Known Test Types

These types have predefined defaults. Unknown types are allowed and receive generic defaults.

### 3.1 Type Definitions

| Type | Description | Default Timeout | Default Labels | Parallel |
|-----|--------------|-----------------|----------------|----------|
| `unit` | Isolated function/class tests | 30s | `["unit", "fast"]` | true |
| `integration` | Component interactions | 120s | `["integration"]` | true |
| `performance` | Time measurement, benchmarks | 300s | `["performance", "benchmark"]` | false |
| `system` | End-to-end through the entire system | 180s | `["system", "e2e", "slow"]` | false |
| `smoke` | Quick basic check | 10s | `["smoke", "critical", "fast"]` | true |
| `fuzz` | Random/invalid inputs | 60s | `["fuzz", "security"]` | false |
| `security` | Security tests | 120s | `["security"]` | false |
| `ui` | User interface tests | 180s | `["ui", "slow"]` | false |
| `api` | API endpoint tests | 60s | `["api", "integration"]` | true |
| *(unknown)* | User-defined type | 60s | `["{type}"]` | true |

### 3.2 Intended Use

#### unit
- **When:** Test individual functions, classes, modules in isolation
- **Properties:** Fast, no external dependencies, on every build
- **Example:** `Application::init()` returns `true`

#### integration
- **When:** Test the interplay of several components
- **Properties:** May use external resources (files, database)
- **Example:** Application initializes and communicates with the logger

#### performance
- **When:** Measure runtime, memory, throughput
- **Properties:** Multiple runs, statistical evaluation, baselines
- **Example:** Init time below 100ms

#### system
- **When:** Test the entire system end-to-end
- **Properties:** Complete workflow, all components together
- **Example:** User starts the app, loads a file, exports the result

#### smoke
- **When:** Quick basic check after the build
- **Properties:** "Does it start at all?", critical paths
- **Example:** Application can be created without an exception

#### fuzz
- **When:** Test robustness against invalid inputs
- **Properties:** Random data, limits, special characters
- **Example:** Call the API with random strings

#### security
- **When:** Uncover security vulnerabilities
- **Properties:** Injection, buffer overflow, authentication
- **Example:** SQL injection in input fields

#### ui
- **When:** Test the user interface
- **Properties:** GUI interactions, events, rendering
- **Example:** A button click triggers the expected action

#### api
- **When:** Test API endpoints
- **Properties:** Request/response, status code, payload
- **Example:** GET /status returns 200 OK

---

## 4. Folder Structure

### 4.1 Convention

```
{AppPath}/
└── tests/
    └── {type}/
        └── {name}/           ← Or short: {name} if unambiguous
            ├── Source.cmake
            ├── test_main.cpp
            └── test_*.cpp
```

### 4.2 Path Resolution

| Configuration | Resulting path |
|---------------|---------------------|
| `path` not specified | `tests/{type}/{name}` |
| `path: "tests/unit/core"` | `tests/unit/core` (explicit) |
| `path: "tests/mytest"` | `tests/mytest` (flat) |

### 4.3 Example Structure

```
projects/apps/MyVisualizer/
├── include/
├── src/
├── main/
├── pch/
└── tests/
    ├── unit/
    │   ├── core/                    ← Core_UnitTests
    │   │   ├── Source.cmake
    │   │   ├── test_main.cpp
    │   │   └── test_Application.cpp
    │   └── utils/                   ← Utils_UnitTests
    │       ├── Source.cmake
    │       ├── test_main.cpp
    │       └── test_StringUtils.cpp
    ├── integration/
    │   └── api/                     ← API_IntegrationTests
    │       ├── Source.cmake
    │       ├── test_main.cpp
    │       └── test_ApiEndpoints.cpp
    ├── performance/
    │   └── benchmarks/              ← Benchmarks
    │       ├── Source.cmake
    │       ├── test_main.cpp
    │       └── bench_Algorithms.cpp
    └── smoke/
        └── startup/                 ← Startup_SmokeTests
            ├── Source.cmake
            ├── test_main.cpp
            └── test_Startup.cpp
```

---

## 5. Framework Resolution

### 5.1 Priority

```
1. Test-specific:    targets[].framework
         ↓ (if empty)
2. Global:           tests.framework
         ↓ (if empty)
3. ERROR:            E301 - No framework specified
```

### 5.2 Supported Frameworks

| Framework | Target name | Description |
|-----------|-------------|--------------|
| `doctest` | doctest | Header-only, fast, C++11 |
| `googletest` | gmock_main | Google Test + Mock, feature-rich |
| `catch2` | Catch2WithMain | BDD style, modern syntax |

### 5.3 Example

```json
"tests": {
    "framework": "doctest",
    "targets": [
        {
            "name": "Core_UnitTests",
            "type": "unit"
            // → Uses "doctest" (global)
        },
        {
            "name": "API_IntegrationTests",
            "type": "integration",
            "framework": "googletest"
            // → Uses "googletest" (override)
        }
    ]
}
```

---

## 6. Generated Targets

### 6.1 Naming Convention

```
{AppName}.{TestName}
```

| App | Test name | CMake target |
|-----|-----------|--------------|
| MyVisualizer | Core_UnitTests | `MyVisualizer.Core_UnitTests` |
| MyVisualizer | API_IntegrationTests | `MyVisualizer.API_IntegrationTests` |
| DemoPlayer | Smoke | `DemoPlayer.Smoke` |

### 6.2 CTest Registration

Every test is automatically registered with CTest with:
- Name: `{AppName}.{TestName}`
- Timeout: from the configuration or the type default
- Labels: app name + type + configured labels
- WORKING_DIRECTORY: `${CMAKE_BINARY_DIR}`

---

## 7. Complete Example

### 7.1 Solution.json

```json
{
    "apps": [
        {
            "name": "MyVisualizer",
            "displayName": "My Visualizer",
            "version": "0.1.0",
            
            "core": {
                "dependencies": [],
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
                        "name": "Core_UnitTests",
                        "type": "unit",
                        "timeout": 30,
                        "labels": ["unit", "core", "fast"]
                    },
                    {
                        "name": "Utils_UnitTests",
                        "type": "unit",
                        "path": "tests/unit/utils",
                        "timeout": 30,
                        "labels": ["unit", "utils", "fast"]
                    },
                    {
                        "name": "Audio_IntegrationTests",
                        "type": "integration",
                        "timeout": 120,
                        "labels": ["integration", "audio"],
                        "externals": ["bass"]
                    },
                    {
                        "name": "Benchmarks",
                        "type": "performance",
                        "path": "tests/performance/benchmarks",
                        "timeout": 300,
                        "labels": ["performance", "nightly"],
                        "skip": true
                    },
                    {
                        "name": "Startup_Smoke",
                        "type": "smoke",
                        "path": "tests/smoke/startup",
                        "timeout": 10,
                        "labels": ["smoke", "critical"]
                    },
                    {
                        "name": "InputFuzz",
                        "type": "fuzz",
                        "framework": "googletest",
                        "timeout": 180,
                        "labels": ["fuzz", "security", "nightly"],
                        "skip": true
                    }
                ]
            }
        }
    ]
}
```

### 7.2 Resulting Targets

| CMake target | Framework | Timeout | Status |
|--------------|-----------|---------|--------|
| `MyVisualizer.Core_UnitTests` | doctest | 30s | ✅ Built |
| `MyVisualizer.Utils_UnitTests` | doctest | 30s | ✅ Built |
| `MyVisualizer.Audio_IntegrationTests` | doctest | 120s | ✅ Built |
| `MyVisualizer.Benchmarks` | doctest | 300s | ⏭️ Skipped |
| `MyVisualizer.Startup_Smoke` | doctest | 10s | ✅ Built |
| `MyVisualizer.InputFuzz` | googletest | 180s | ⏭️ Skipped |

---

## 8. Migration from the Old Structure

### 8.1 Old Structure (No Longer Supported)

```json
"tests": {
    "framework": "doctest",
    "unit": {
        "timeout": 30,
        "labels": ["unit", "fast"]
    },
    "integration": {
        "timeout": 120
    },
    "performance": {
        "timeout": 300
    }
}
```

### 8.2 New Structure

```json
"tests": {
    "framework": "doctest",
    "targets": [
        {
            "name": "UnitTests",
            "type": "unit",
            "path": "tests/unit",
            "timeout": 30,
            "labels": ["unit", "fast"]
        },
        {
            "name": "IntegrationTests",
            "type": "integration",
            "path": "tests/integration",
            "timeout": 120
        },
        {
            "name": "PerformanceTests",
            "type": "performance",
            "path": "tests/performance",
            "timeout": 300
        }
    ]
}
```

### 8.3 Folder Adjustment

```bash
# Before:
tests/unit/Application_Tests.cpp

# After (subfolder with the test name):
tests/unit/UnitTests/Application_Tests.cpp

# Or with an explicit path: "tests/unit" stays as it is
```

---

## 9. Error Handling

| Code | Condition | Message |
|------|-----------|---------|
| E301 | No framework | No framework specified for test '{name}'. Set tests.framework or targets[].framework |
| E302 | Unknown framework | Unknown framework '{fw}' for test '{name}'. Valid: doctest, googletest, catch2 |
| E303 | Missing name | Test target [{idx}] missing required 'name' field |
| E304 | Missing type | Test target '{name}' missing required 'type' field |
| E305 | Path does not exist | Test '{name}' path does not exist: {path} |
| E306 | No sources | Test '{name}': No source files found in {path} |
| W401 | Empty targets array | App '{name}': tests.targets is empty |
| W402 | Parallel serial type | Test '{name}' (type '{type}') has parallel=true. This type typically runs serial for accurate results. |

> **Code today (2026-11-09):** E306 does not exist in the code. If a test path has no source files, the code warns with W403 `Test '${TARGET_NAME}': No source files found` and skips the test (`cmake/project/AppCreate.cmake:702`); W403 is also used for `App '${_name}': tests.targets configured but no tests/ directory` (`AppCreate.cmake:577`). W401 also reports `App '${_name}': No include/ directory (headers will be private)` (`AppCreate.cmake:96`). In the code, the messages of the table start with `App '${_name}': ` (`cmake/project/AppCollect.cmake:338–435`, `AppCreate.cmake:627–635`).

### 9.1 Parallel Warning W402

Certain test types should not be run in parallel, since this can distort the results:

| Type | Reason |
|-----|-------|
| `performance` | Time measurements become inaccurate due to competing tests |
| `system` | End-to-end tests can influence each other |
| `fuzz` | Resource-intensive, can destabilize the system |
| `security` | Isolation is important for valid results |
| `ui` | GUI tests can block each other |

If `parallel: true` is set explicitly for these types, warning W402 appears.
The system does not block, since the user may know what they are doing (e.g. a dedicated test server).

---

## 10. Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: "Code today" note on §9 (no E306, W401/W403 as used in the code)** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.1.1 | 2025-12-18 | New: skip feature (global tests.skip + per-target skip), status changed to "Implemented" |
| 0.1.0 | 2025-12-18 | Initial: concept for flexible test targets |
