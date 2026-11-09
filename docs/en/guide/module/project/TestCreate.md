# TestCreate.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** In Development (Pre-Release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [TestCreate.md](../../../../de/guide/module/project/TestCreate.md)  
> **Module:** [`cmake/project/TestCreate.cmake`](../../../../../cmake/project/TestCreate.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [API Reference](#3-api-reference)
4. [Processing](#4-processing)
5. [Framework Integration](#5-framework-integration)
6. [CTest Registration](#6-ctest-registration)
7. [Error Handling](#7-error-handling)
8. [See Also](#8-see-also)
9. [Changelog](#changelog)

---

## 1. Overview

The `TestCreate.cmake` module **creates test targets** from a prepared context. It handles framework integration, CTest registration and dependencies.

### Core Idea

Analogous to ExecutableCreate — but with test-specific logic (framework, CTest).

### Responsibilities

| Area | Description |
|------|-------------|
| Target creation | add_executable() for the test |
| Framework | doctest, catch2, gtest integration |
| CTest | add_test(), labels, timeout |
| Dependencies | Target, libraries, externals |

---

## 2. Dependencies

| Module | Version | Usage |
|--------|---------|-------|
| Context.cmake | 0.5.0 | `ctx_get` |
| Errors.cmake | 0.5.0 | `cmake_fatal`, `cmake_warn` |
| Debug.cmake | 0.5.0 | `dbg` |
| Warnings.cmake | 0.5.0 | `apply_warnings` |
| CompilerOptions.cmake | 0.5.0 | `apply_compiler_options` |
| OutputDirs.cmake | 0.5.0 | `setup_output_dirs` |
| Orchestrator.cmake | 0.5.0 | `apply_external_to_target` |

---

## 3. API Reference

### 3.1 _create_test_target()

Creates a CMake test target from the context.

```cmake
_create_test_target(<CTX>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `CTX` | String | ✓ | Context prefix (e.g. `TEST_0`) |

**Expected context keys:**

| Key | Usage |
|-----|-------|
| NAME | Test name |
| PATH | Source directory |
| FRAMEWORK | doctest, catch2, gtest |
| TARGET | Target under test |
| DEPENDENCIES | Internal libraries |
| EXTERNALS | External dependencies |
| TIMEOUT | CTest timeout |
| LABELS | CTest labels |
| PARALLEL | Parallel flag |

---

## 4. Processing

### 4.1 Flow

```
_create_test_target(CTX)
    │
    ├── 1. Read context data
    │
    ├── 2. Validate source directory
    │
    ├── 3. Create test executable
    │   └── add_executable(${name} ${sources})
    │
    ├── 4. Link framework external
    │   └── apply_external_to_target(name, framework)
    │
    ├── 5. Link target under test
    │   └── target_link_libraries(name PRIVATE target)
    │
    ├── 6. Link dependencies
    │
    ├── 7. Link other externals
    │
    ├── 8. Apply standard modules
    │   ├── apply_warnings()
    │   ├── apply_compiler_options()
    │   └── setup_output_dirs()
    │
    └── 9. Register with CTest
        ├── add_test(NAME name COMMAND name)
        ├── set_tests_properties(TIMEOUT)
        ├── set_tests_properties(LABELS)
        └── set_tests_properties(RUN_SERIAL) if !parallel
```

---

## 5. Framework Integration

### 5.1 doctest (Default)

```json
{
    "name": "MyTests",
    "framework": "doctest"
}
```

doctest must be defined as an external.

### 5.2 Catch2

```json
{
    "framework": "catch2"
}
```

### 5.3 Google Test

```json
{
    "framework": "gtest"
}
```

---

## 6. CTest Registration

### 6.1 Basic Registration

```cmake
add_test(
    NAME ${_name}
    COMMAND ${_name}
)
```

### 6.2 Properties

```cmake
set_tests_properties(${_name} PROPERTIES
    TIMEOUT ${_timeout}
    LABELS "${_labels}"
)

# If not parallel
if(NOT _parallel)
    set_tests_properties(${_name} PROPERTIES
        RUN_SERIAL TRUE
    )
endif()
```

### 6.3 Running Tests

```bash
ctest --test-dir build              # All tests
ctest -L unit                        # Unit tests only
ctest -R "Core"                      # Filter by name
ctest --output-on-failure           # Output on failure
```

---

## 7. Error Handling

### 7.1 Fatal Errors

| Code | Condition | Solution |
|------|-----------|----------|
| E001 | Source path does not exist | Check/create the path |
| E010 | Framework external not defined | Add the external |
| E101 | Dependency does not exist | Check the target order |

### 7.2 Warnings

| Code | Condition | Recommendation |
|------|-----------|----------------|
| W101 | No sources found | Add test files |

---

## 8. See Also

- [Tests.cmake](Tests.md) — Calls _create_test_target
- [TestCollect.cmake](TestCollect.md) — Fills the context
- [ExecutableCreate.cmake](ExecutableCreate.md) — Analogous module
- [Testing_UserGuide.md](../../userguides/Testing.md) — User guide

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.1 | 2025-12-17 | collect_sources() integration, SourceCollect.cmake dependency |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0 |
| 0.1.0 | 2025-12-11 | Initial (clean start): test target creation with CTest |
