# Tests.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** In Development (Pre-Release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [Tests.md](../../../../de/guide/module/project/Tests.md)  
> **Module:** [`cmake/project/Tests.cmake`](../../../../../cmake/project/Tests.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Activation](#3-activation)
4. [Processing](#4-processing)
5. [CTest Integration](#5-ctest-integration)
6. [Debug Output](#6-debug-output)
7. [See Also](#7-see-also)
8. [Changelog](#changelog)

---

## 1. Overview

The `Tests.cmake` module is the **orchestrator of the test pipeline**. It iterates over all tests in Solution.json and creates test targets with CTest integration.

### Core Idea

Tests are only built when needed (BUILD_TESTS=ON) and are fully integrated into CTest.

### Responsibilities

| Area | Description |
|------|-------------|
| Activation | Check the BUILD_TESTS flag |
| Iteration | Over the tests array |
| Filters | skip, platforms |
| CTest | enable_testing(), add_test() |

### Loads Automatically

- TestCollect.cmake
- TestCreate.cmake

---

## 2. Dependencies

| Module | Version | Usage |
|--------|---------|-------|
| Context.cmake | 0.5.0 | `ctx_create`, `ctx_get` |
| Errors.cmake | 0.5.0 | (indirect) |
| Debug.cmake | 0.5.0 | (indirect) |
| Json.cmake | 0.5.0 | `_json_has_key`, JSON parsing |
| Solution.cmake | 0.5.0 | `SOLUTION_JSON` property |

---

## 3. Activation

### 3.1 CMake Call

```bash
# Enable tests
cmake -B build -DBUILD_TESTS=ON

# Disable tests (default)
cmake -B build -DBUILD_TESTS=OFF
```

### 3.2 Preset Configuration

```json
{
    "configurePresets": [
        {
            "name": "dev",
            "cacheVariables": {
                "BUILD_TESTS": "ON"
            }
        }
    ]
}
```

---

## 4. Processing

### 4.1 Pipeline Flow

```
Tests.cmake
    │
    ├── 1. BUILD_TESTS == OFF?
    │   └── Return early
    │
    ├── 2. Load Sub-Modules
    │   ├── TestCollect.cmake
    │   └── TestCreate.cmake
    │
    ├── 3. Get tests array from SOLUTION_JSON
    │   └── Return early if empty
    │
    ├── 4. Enable CTest
    │   ├── include(CTest)
    │   └── enable_testing()
    │
    └── 5. For each test:
        │
        ├── 5.1 Create Context (TEST_0, TEST_1, ...)
        │
        ├── 5.2 _collect_test() → Fill Context
        │
        ├── 5.3 Check Filters:
        │   ├── skip=true → Continue
        │   └── platforms → Not matching → Continue
        │
        └── 5.4 _create_test_target()
```

---

## 5. CTest Integration

### 5.1 Running Tests

```bash
# All tests
ctest --test-dir build

# With output on failure
ctest --test-dir build --output-on-failure

# Verbose
ctest --test-dir build -V
```

### 5.2 Filtering Tests

```bash
# By label
ctest -L unit
ctest -L integration

# By name (regex)
ctest -R "MyTest"
ctest -R ".*Core.*"
```

---

## 6. Debug Output

```
-- [Tests] === Test Pipeline Start ===
-- [Tests] Processing 3 test(s)...
-- [Tests] --- Processing: CoreLibTests ---
-- [Tests]   Created: CoreLibTests
-- [Tests] --- Processing: UtilTests ---
-- [Tests]   Created: UtilTests
-- [Tests] --- Processing: WinOnlyTests ---
-- [Tests]   Skipped (platform filter)
-- 
-- [Tests] === Test Pipeline Complete ===
-- [Tests] Run tests with: ctest --test-dir <build-dir>
-- [Tests] Filter by label: ctest -L unit
-- [Tests] Filter by name:  ctest -R <pattern>
```

---

## 7. See Also

- [TestCollect.cmake](TestCollect.md) — JSON to context
- [TestCreate.cmake](TestCreate.md) — Context to target
- [Executables.cmake](Executables.md) — Analogous module
- [Testing_UserGuide.md](../../userguides/Testing.md) — User guide

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0 |
| 0.1.0 | 2025-12-11 | Initial (clean start): test pipeline with CTest |
