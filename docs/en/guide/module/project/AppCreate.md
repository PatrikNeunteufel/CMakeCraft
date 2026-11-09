# AppCreate.cmake — Documentation

> **Version:** 1.0.3  
> **Date:** 2026-11-09  
> **Type:** ModuleDoc  
> **Status:** In Development  
> **Target Audience:** Build system developers  
> **Module:** [cmake/project/AppCreate.cmake](../../../../../cmake/project/AppCreate.cmake)  
> **Module Version:** 1.0.0  
> **Based on:** ModuleDoc v0.5  
> **Language:** English  
> **German:** [AppCreate.md](../../../../de/guide/module/project/AppCreate.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Concept](#3-concept)
4. [API Reference](#4-api-reference)
   - 4.1 [_create_app_core()](#41-_create_app_core)
   - 4.2 [_create_app_runner()](#42-_create_app_runner)
   - 4.3 [_create_app_tests()](#43-_create_app_tests)
   - 4.4 [_create_app_test_target()](#44-_create_app_test_target)
5. [Directory Structure](#5-directory-structure)
6. [PCH Handling](#6-pch-handling)
7. [Usage Examples](#7-usage-examples)
8. [Error Handling](#8-error-handling)
9. [Best Practices](#9-best-practices)
10. [See Also](#10-see-also)
11. [Changelog](#11-changelog)

---

## 1. Overview

The `AppCreate` module is responsible for **creating all CMake targets** of an app container. It contains three main functions, each of which creates one part of the app container.

### Purpose

- Creation of the core library (`{AppName}.Core`)
- Creation of the runner executable (`{AppName}`)
- Creation of the test executables (`{AppName}.*Tests`)

### Generated Targets

| Function | Target | Type | Description |
|----------|--------|------|-------------|
| `_create_app_core()` | `{AppName}.Core` | STATIC library | Business logic |
| `_create_app_runner()` | `{AppName}` | Executable | Entry point with main() |
| `_create_app_tests()` | `{AppName}.UnitTests` | Executable | Unit tests |
| `_create_app_tests()` | `{AppName}.IntegrationTests` | Executable | Integration tests |

---

## 2. Dependencies

| Dependency | Type | Description |
|------------|------|-------------|
| CMake 3.19+ | System | JSON functions, FILE_SET |
| `Context.cmake` | Module | Reading context data |
| `Errors.cmake` | Module | Error handling |
| `Debug.cmake` | Module | Debug output |
| `OutputDirs.cmake` | Module | Output directories |
| `Warnings.cmake` | Module | Warning configuration |
| `CompilerOptions.cmake` | Module | Compiler settings |
| `Orchestrator.cmake` | Module | External integration |

---

## 3. Concept

### 3.1 Target Hierarchy

```
{AppName}.Core (STATIC Library)
       │
       │ PUBLIC link
       │
       ├──────────────────┬────────────────────┐
       │                  │                    │
       ▼                  ▼                    ▼
{AppName}          {AppName}.UnitTests  {AppName}.IntegrationTests
(Executable)       (Test Executable)    (Test Executable)
```

### 3.2 Dependency Propagation

| Link type | From → To | Meaning |
|-----------|-----------|---------|
| PUBLIC | Core.Dependencies → Core | Transitive to runner/tests |
| PUBLIC | Core.Externals → Core | Transitive to runner/tests |
| PUBLIC | Core.pch/ include → Core | Transitive to runner/tests |
| PRIVATE | Runner.Externals → Runner | Runner only |
| PRIVATE | Integration.Externals → Integration | Integration tests only |

### 3.3 Why a STATIC Library?

- **Testability:** Tests can link against Core without a main() conflict
- **Compilation:** Compiled once, used multiple times
- **Isolation:** Core contains no entry point logic
- **PCH sharing:** Runner and tests can reuse the PCH of Core

---

## 4. API Reference

### 4.1 _create_app_core()

```cmake
_create_app_core(CTX)
```

**Description:**  
Creates the `{AppName}.Core` STATIC library with all business logic sources.

**Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `CTX` | ✓ | Context prefix (e.g. `APP_0`) |

**Expected context keys:**

| Key | Usage |
|-----|-------|
| `NAME` | Target name base |
| `PATH` | Base directory |
| `VERSION` | Target version |
| `PCH_ENABLED` | Enable precompiled headers |
| `PCH_HEADER` | PCH header file name |
| `PCH_PATH` | Optional custom path for the PCH |
| `CORE_DEPENDENCIES` | Internal libraries |
| `CORE_EXTERNALS` | External dependencies |
| `CORE_EXTERNAL_OPTIONS` | Per-external options (JSON) |

**Expected directories:**

```
{PATH}/
├── include/    ← PUBLIC headers (optional, W401 if missing)
├── src/        ← Implementation (required, E403 if missing)
└── pch/        ← Precompiled header (optional)
```

**Generated target:**
- `{AppName}.Core` — STATIC library

**Target properties (set):**

| Property | Description |
|----------|-------------|
| `APP_PCH_ENABLED` | Boolean: PCH active |
| `APP_PCH_PATH` | Path to the PCH header |

**Errors:**
- `E402` — Path does not exist
- `E403` — No src/ directory
- `E404` — No sources in src/
- `E405` — Dependency not found
- `E010` — External not defined
- `W401` — No include/ directory
- `W402` — PCH header not found

---

### 4.2 _create_app_runner()

```cmake
_create_app_runner(CTX)
```

**Description:**  
Creates the `{AppName}` executable with the entry point (main()). Uses **no PCH** — main.cpp is typically minimal and hardly benefits from it.

**Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `CTX` | ✓ | Context prefix (e.g. `APP_0`) |

**Expected context keys:**

| Key | Usage |
|-----|-------|
| `NAME` | Target name |
| `PATH` | Base directory |
| `VERSION` | Target version |
| `DISPLAY_NAME` | Display name (macOS bundle) |
| `RUNNER_TYPE` | CONSOLE or WINDOW/GUI |
| `RUNNER_EXTERNALS` | Runner-specific externals |
| `RUNNER_EXTERNAL_OPTIONS` | Per-external options (JSON) |

**Expected directories:**

```
{PATH}/
└── main/    ← Entry point (required, E406 if missing)
```

**Generated target:**
- `{AppName}` — Executable (WIN32/MACOSX_BUNDLE for GUI)

**PCH behavior:**
- Inherits the `pch/` include directory from Core (PUBLIC)
- Uses **no** `target_precompile_headers()`
- `#include "pch.h"` is **not required** in main.cpp

**Errors:**
- `E406` — No main/ directory
- `E407` — No sources in main/
- `E010` — External not defined

---

### 4.3 _create_app_tests()

```cmake
_create_app_tests(CTX)
```

**Description:**  
Creates test executables based on the tests configuration in the context.

**Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `CTX` | ✓ | Context prefix (e.g. `APP_0`) |

**Expected context keys:**

| Key | Usage |
|-----|-------|
| `NAME` | App name for the target prefix |
| `PATH` | Base directory |
| `TESTS_FRAMEWORK` | Default framework for all test targets (doctest, googletest, catch2) |
| `TESTS_SKIP` | `TRUE` skips all tests of the app |
| `TESTS_TARGETS_COUNT` | Number of entries in `tests.targets[]` |
| `TESTS_TARGET_{n}_NAME` | Name → target `{AppName}.{name}` |
| `TESTS_TARGET_{n}_TYPE` | Test type (output only; defaults are set by AppCollect) |
| `TESTS_TARGET_{n}_SKIP` | `TRUE` skips this target |
| `TESTS_TARGET_{n}_PATH` | Source directory relative to the app directory |
| `TESTS_TARGET_{n}_FRAMEWORK` | Framework of this target; empty → `TESTS_FRAMEWORK` |
| `TESTS_TARGET_{n}_TIMEOUT` | CTest timeout |
| `TESTS_TARGET_{n}_LABELS` | CTest labels |
| `TESTS_TARGET_{n}_DEPENDENCIES` | Internal libraries, linked directly |
| `TESTS_TARGET_{n}_EXTERNALS` | Additional externals |
| `TESTS_TARGET_{n}_EXTERNAL_OPTIONS` | Options per external from `EXTERNALS` (JSON) |
| `TESTS_TARGET_{n}_PARALLEL` | Parallel execution allowed |
| `TESTS_TARGET_{n}_COMPILE_OPTIONS` | Compiler flags for this test target only |

All keys are set by [AppCollect § 5.5/5.6](AppCollect.md).

**Expected directories:**

```
{PATH}/
└── tests/
    └── {type}/
        └── {name}/   ← TESTS_TARGET_{n}_PATH (default: tests/{type}/{name})
```

**Generated targets:**
- `{AppName}.{name}` — one per entry in `tests.targets[]`, unless `TESTS_SKIP` or `TESTS_TARGET_{n}_SKIP` is set

**Errors:**
- `E301` — No framework specified (neither `tests.framework` nor `targets[].framework`)
- `E302` — Unknown framework
- `E305` — Path of the test target does not exist
- `E010` — Framework/external not defined
- `E101` — Dependency of the test target does not exist
- `W403` — Tests configured, but `tests/` is missing or the target has no sources

---

### 4.4 _create_app_test_target()

```cmake
_create_app_test_target(TARGET_NAME SRC_DIR CORE_TARGET DEPENDENCIES FRAMEWORK TIMEOUT LABELS EXTRA_EXTERNALS EXTERNAL_OPTIONS APP_NAME PARALLEL COMPILE_OPTIONS)
```

**Description:**  
Internal helper function for creating a single test target.

**Parameters:**

| Parameter | Description |
|-----------|-------------|
| `TARGET_NAME` | Name of the test target |
| `SRC_DIR` | Directory with test sources |
| `CORE_TARGET` | Core library to link |
| `DEPENDENCIES` | Internal libraries that are linked directly (list) |
| `FRAMEWORK` | Test framework |
| `TIMEOUT` | CTest timeout in seconds |
| `LABELS` | CTest labels (list) |
| `EXTRA_EXTERNALS` | Additional externals |
| `EXTERNAL_OPTIONS` | JSON object with options per external from `EXTRA_EXTERNALS`; the framework external always gets `{}` |
| `APP_NAME` | App name for the IDE folder |
| `PARALLEL` | `TRUE` allows parallel execution, `FALSE` forces serial execution |
| `COMPILE_OPTIONS` | Compiler flags for this test target only (list, PRIVATE; set after `apply_compiler_options()`) |

---

## 5. Directory Structure

### 5.1 Complete App Structure

```
projects/apps/{AppName}/
├── include/                 ← PUBLIC headers (Core)
│   └── Application.hpp
├── src/                     ← Implementation (Core)
│   └── Application.cpp
├── main/                    ← Entry point (Runner)
│   └── main.cpp
├── pch/                     ← Precompiled headers (optional)
│   └── pch.h
└── tests/                   ← Tests
    ├── unit/
    │   └── Application_Tests.cpp
    └── integration/
        └── Application_Integration_Tests.cpp
```

### 5.2 Include Directories

| Directory | Visibility | Purpose |
|-----------|------------|---------|
| `include/` | PUBLIC | Public headers for runner/tests |
| `pch/` | PUBLIC | PCH header for runner/tests |
| `src/` | PRIVATE | Only if private headers exist |

### 5.3 Minimal App Structure

```
projects/apps/{AppName}/
├── src/
│   └── Logic.cpp
└── main/
    └── main.cpp
```

---

## 6. PCH Handling

### 6.1 Activation

PCH is enabled in Solution.json:

```json
"apps": [{
    "name": "MyApp",
    "pch": {
        "enabled": true,
        "header": "pch.h"    // Optional, default: "pch.h"
    }
}]
```

### 6.2 Search Path Priority

| Priority | Path | Example |
|----------|------|---------|
| 1 | `{PATH}/pch/{header}` | `projects/apps/MyApp/pch/pch.h` |
| 2 | `{PATH}/src/{header}` | `projects/apps/MyApp/src/pch.h` |
| 3 | `{PATH}/{header}` | `projects/apps/MyApp/pch.h` |

### 6.3 PCH for Core Only

**Important simplification:** PCH is enabled **for Core only**, not for the runner or tests.

```
Core Target:
  ├── target_include_directories(PUBLIC ${pch_dir})   ← pch/ is visible
  └── target_precompile_headers(PRIVATE ${pch_path})  ← Compiles the PCH

Runner:
  ├── Inherits pch/ include dir via PUBLIC link       ← Could find pch.h
  └── NO target_precompile_headers()                  ← Does not use the PCH

Tests:
  ├── Inherits pch/ include dir via PUBLIC link       ← Could find pch.h
  └── NO target_precompile_headers()                  ← Does not use the PCH
```

### 6.4 Why No PCH for Runner/Tests?

| Aspect | Rationale |
|--------|-----------|
| **Core is not recompiled** | Runner/tests only link against the finished `.lib` |
| **main.cpp is minimal** | Typically 20-30 lines, PCH gain negligible |
| **Tests have framework includes** | doctest/googletest dominate the compile time |
| **Simpler templates** | No `#include "pch.h"` needed in main.cpp and tests |
| **Fewer sources of error** | No "PCH not found" when PCH is disabled |

### 6.5 Why Is pch/ PUBLIC Anyway?

The `pch/` directory is configured as a **PUBLIC include** so that:
- `src/*.cpp` works with `#include "pch.h"`
- Runner/tests could use `#include "pch.h"` manually if needed

### 6.6 Why Is a Manual #include Needed in Core?

MSVC requires `#include "pch.h"` as the first line in every `.cpp` that uses the PCH. GCC/Clang can inject the PCH via `-include`, but for **cross-platform compatibility** the explicit include is required.

**When PCH is disabled:** `#include "pch.h"` only has to be removed from `src/*.cpp` (not from main.cpp or tests, since they do not use it anyway).

---

## 7. Usage Examples

### 7.1 Using the Core Library

```cpp
// main/main.cpp (no PCH required)
#include "Application.hpp" // From include/ of the core library

int main(int argc, char* argv[]) {
    MyApp::Application app;
    return app.run(argc, argv);
}
```

### 7.2 Writing a Unit Test

```cpp
// tests/unit/Application_Tests.cpp (no PCH required)
#include <doctest/doctest.h>
#include "Application.hpp"        // From include/ of the core library

TEST_CASE("Application functionality") {
    MyApp::Application app;
    CHECK(app.initialize() == true);
}
```

### 7.3 Running CTest

```bash
# All app tests
ctest -L AudioPlayer

# Unit tests only
ctest -R "UnitTests"

# With timeout override
ctest --timeout 60
```

---

## 8. Error Handling

### 8.1 Core Errors (E4xx)

| Code | Function | Condition |
|------|----------|-----------|
| `E402` | `_create_app_core` | Path does not exist |
| `E403` | `_create_app_core` | No src/ directory |
| `E404` | `_create_app_core` | No sources in src/ |
| `E405` | `_create_app_core` | Dependency not found |
| `E406` | `_create_app_runner` | No main/ directory |
| `E407` | `_create_app_runner` | No sources in main/ |

### 8.2 General Errors

| Code | Condition |
|------|-----------|
| `E010` | External or test framework not defined in the externals block |
| `E101` | Dependency of a test target does not exist |
| `E301` | No test framework specified (neither `tests.framework` nor `targets[].framework`) |
| `E302` | Unknown test framework (valid: `doctest`, `googletest`, `catch2`) |
| `E305` | Path of the test target does not exist |

### 8.3 Warnings (W4xx)

| Code | Function | Condition |
|------|----------|-----------|
| `W401` | `_create_app_core` | No include/ directory |
| `W402` | `_create_app_core` | PCH header not found |
| `W403` | `_create_app_tests` | Tests enabled but no sources |

---

## 9. Best Practices

### 9.1 Do's

| Recommendation | Rationale |
|----------------|-----------|
| Headers in include/, implementation in src/ | Clear separation |
| Keep main.cpp minimal | Logic belongs in Core |
| PCH for standard includes | Reduces build time |
| Define the framework in externals | Central management |
| Set labels for tests | Easy filtering |

### 9.2 Don'ts

| Avoid | Reason |
|-------|--------|
| Business logic in main/ | Not testable |
| Tests without framework external | E010 error |
| Large main.cpp | Violates the app container principle |
| PCH in Core without #include | MSVC errors in src/*.cpp |

### 9.3 Example: Good vs. Bad Structure

**Good:**
```cpp
// main/main.cpp (minimal, no PCH needed)
#include "Application.hpp"
int main() { return MyApp::run(); }

// src/Application.cpp (testable, with PCH)
#include "pch.h"
#include "Application.hpp"
namespace MyApp {
    int run() { /* Business Logic */ }
}
```

**Bad:**
```cpp
// main/main.cpp (too much logic)
int main() {
    // 500 lines of business logic...
}
```

---

## 10. See Also

- [Apps.cmake](Apps.md) — Orchestrator
- [AppCollect.cmake](AppCollect.md) — JSON parsing
- [ExecutableCreate.cmake](ExecutableCreate.md) — Similar pattern
- [TestCreate.cmake](TestCreate.md) — Test pattern
- [AppContainer_Concept.md](../../../konzepte/abgeschlossen/AppContainer_Concept.md) — Concept
- [ErrorCodes.md](../../references/ErrorCodes.md) — E4xx, W4xx codes

---

## 11. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.3** | **2026-11-09** | **Aligned with the code: § 8.2 E301 = no framework, E302 = unknown framework (as in § 4.3); E101 and E305 added** |
| **1.0.2** | **2026-10-09** | **_create_app_test_target(): new parameter COMPILE_OPTIONS — `tests.targets[].compile_options` is set as PRIVATE compiler flags on the test target (CMakeCraft v0.11.0)** |
| **1.0.1** | **2026-10-05** | **_create_app_test_target(): new parameter EXTERNAL_OPTIONS — `tests.targets[].external_options` is applied per external instead of a fixed `{}`. Signature in § 4.4 corrected (DEPENDENCIES, PARALLEL were missing). § 4.3 brought up to the tests.targets[] structure (old tests.unit/tests.integration schema removed, error list completed)** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.7.0 | 2025-12-20 | CORE_EXTERNAL_OPTIONS and RUNNER_EXTERNAL_OPTIONS: apply_external_to_target() with options |
| 0.5.4 | 2025-12-18 | PCH simplified: Core only, not for runner/tests (no more REUSE_FROM) |
| 0.5.3 | 2025-12-18 | PCH include directory added as PUBLIC, APP_PCH_* target properties |
| 0.5.2 | 2025-12-18 | PCH 3-tier search, implicit activation |
| 0.5.1 | 2025-12-17 | collect_sources() integration, SourceCollect.cmake dependency |
| 0.5.0 | 2025-12-17 | Initial: Phase 8 app container target creation |
