# phase7.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Path:** `cmake/buildSystemTest/phase7.cmake`  
> **Status:** Stable  
> **Language:** English  
> **German:** [Phase7_doc.md](../../../../de/guide/module/buildSystemTest/Phase7_doc.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Tests](#2-tests)
3. [Success Flag](#3-success-flag)
4. [See Also](#4-see-also)
5. [Changelog](#changelog)

---

## 1. Overview

**Phase 7** tests the **test pipeline** — the creation of test targets and the CTest integration.

| Aspect | Description |
|--------|-------------|
| **Purpose** | Test pipeline validation |
| **Debug ID** | `PHASE7_TEST` |
| **Dependencies** | Phase 1-6, Tests.cmake |
| **Condition** | Runs completely only if `BUILD_TESTS=ON` |

---

## 2. Tests

### 2.1 BUILD_TESTS Option

```cmake
if(BUILD_TESTS)
    # Full tests
else()
    # JSON parsing tests only
endif()
```

### 2.2 Tests Array Parsing

Checks the `tests` array in Solution.json:

```cmake
string(JSON _tests_json GET "${_solution_json}" "tests")
string(JSON _tests_count LENGTH "${_tests_json}")
```

| Field | Description |
|-------|-------------|
| `name` | Test name |
| `type` | unit, integration, system, etc. |
| `framework` | doctest, googletest, catch2 |

### 2.3 Framework Externals

Checks that the test framework externals are defined:

| Framework | Type |
|-----------|------|
| `doctest` | Local |
| `googletest` | Git (Fetched) |
| `catch2` | Git (Fetched) |

### 2.4 Test Targets

Checks target creation (only if `BUILD_TESTS=ON`):

| Target | Framework |
|--------|-----------|
| `BasicLogger_UnitTests` | doctest |
| `AudioEngine_UnitTests` | googletest |
| `Integration_Tests` | catch2 |

### 2.5 CTest Integration

```cmake
if(CMAKE_TESTING_ENABLED)
    # CTest is enabled
endif()
```

Checks test properties:

| Property | Description |
|----------|-------------|
| `TIMEOUT` | Test timeout in seconds |
| `LABELS` | Test labels for filtering |

### 2.6 Test Types

Supported test types:

| Type | Description |
|------|-------------|
| `unit` | Unit tests |
| `integration` | Integration tests |
| `system` | System tests |
| `performance` | Performance tests |
| `smoke` | Smoke tests |

### 2.7 Framework Targets

Checks framework library targets (if `BUILD_TESTS=ON`):

| Target | Framework |
|--------|-----------|
| `doctest` | doctest |
| `gtest_main` | GoogleTest |
| `gmock_main` | GoogleMock |
| `Catch2WithMain` | Catch2 |

---

## 3. Success Flag

```cmake
set(PHASE7_TEST_PASSED TRUE CACHE BOOL "Phase 7 Test passed" FORCE)
```

---

## 4. See Also

- [Tests.md](../project/Tests.md)
- [TestCollect.md](../project/TestCollect.md)
- [TestCreate.md](../project/TestCreate.md)
- [Git_Externals_Testing.md](../../references/externals/Git_Externals_Testing.md)
- [Local_Externals_Testing.md](../../references/externals/Local_Externals_Testing.md)

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-15 | Blueprint v0.5.0 format |
| 0.1.0 | 2025-12-12 | Initial |
