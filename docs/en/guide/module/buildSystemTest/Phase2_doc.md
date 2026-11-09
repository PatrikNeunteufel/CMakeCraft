# phase2.cmake — Module Documentation

> **Version:** 1.2.0  
> **Date:** 2026-10-24  
> **Type:** ModuleDoc  
> **Path:** `cmake/buildSystemTest/phase2.cmake`  
> **Status:** Stable  
> **Language:** English  
> **German:** [Phase2_doc.md](../../../../de/guide/module/buildSystemTest/Phase2_doc.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Tests](#2-tests)
3. [Success Flag](#3-success-flag)
4. [See Also](#4-see-also)
5. [Changelog](#changelog)

---

## 1. Overview

**Phase 2** tests the **Solution.json processing** — loading and validating the project configuration.

| Aspect | Description |
|--------|-------------|
| **Purpose** | Solution.json validation |
| **Debug ID** | `PHASE2_TEST` |
| **Dependencies** | Phase 1, Solution.cmake |

---

## 2. Tests

### 2.1 Solution Properties

| Property | Required |
|----------|----------|
| `SOLUTION_NAME` | ✅ |
| `SOLUTION_VERSION` | ✅ |
| `SOLUTION_SCHEMA_VERSION` | ✅ |
| `SOLUTION_DESCRIPTION` | ❌ |
| `SOLUTION_AUTHORS` | ❌ |

### 2.2 Settings Properties

| Property | Required | Default |
|----------|----------|---------|
| `SOLUTION_CXX_STANDARD` | ✅ | 17 |
| `SOLUTION_C_STANDARD` | ❌ | 11 |
| `SOLUTION_DEFAULT_LIBRARY_TYPE` | ✅ | STATIC |
| `SOLUTION_DEFAULT_EXECUTABLE_TYPE` | ✅ | CONSOLE |
| `SOLUTION_SOURCE_MODE` | ✅ | auto |
| `SOLUTION_MSVC_PARALLEL_COMPILE` | ✅ | 8 (value of `settings.msvc.parallel_compile`) |

### 2.3 CMake Cache Variables

| Variable | Checks |
|----------|--------|
| `CMAKE_CXX_STANDARD` | Set from Solution |
| `CMAKE_C_STANDARD` | Set from Solution |
| `CMAKE_CXX_STANDARD_REQUIRED` | TRUE |
| `CMAKE_CXX_EXTENSIONS` | OFF |
| `CMAKE_C_FLAGS_TESTING`, `CMAKE_CXX_FLAGS_TESTING` | not empty (Configurations.cmake) |

### 2.4 Externals Policy

| Property | Required |
|----------|----------|
| `SOLUTION_EXTERNALS_CACHE_ROOT` | ✅ |
| `SOLUTION_EXTERNALS_SOURCE_ROOT` | ❌ |
| `SOLUTION_EXTERNALS_UPDATE_POLICY` | ✅ |

### 2.5 Externals JSON

Checks that `SOLUTION_EXTERNALS_JSON` is present and not empty.

### 2.6 project() Compatibility

| Check | Expected |
|-------|----------|
| `PROJECT_NAME` | = `SOLUTION_NAME` |
| `PROJECT_VERSION` | = `SOLUTION_VERSION` |

---

## 3. Success Flag

```cmake
set(PHASE2_TEST_PASSED TRUE CACHE BOOL "Phase 2 Test passed" FORCE)
```

---

## 4. See Also

- [Solution.md](../project/Solution.md)
- [Solution_Schema.md](../../references/Solution_Schema.md)

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.2.0** | **2026-10-24** | **Checks the flags of the `Testing` configuration (CMakeCraft v0.13.0)** |
| 1.1.0 | 2026-10-23 | Checks `SOLUTION_MSVC_PARALLEL_COMPILE` (CMakeCraft v0.12.0) |
| 0.5.0 | 2025-12-15 | Blueprint v0.5.0 format |
| 0.1.0 | 2025-12-05 | Initial |
