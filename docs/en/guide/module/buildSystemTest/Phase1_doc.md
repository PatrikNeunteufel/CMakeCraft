# phase1.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Path:** `cmake/buildSystemTest/phase1.cmake`  
> **Status:** Stable  
> **Language:** English  
> **German:** [Phase1_doc.md](../../../../de/guide/module/buildSystemTest/Phase1_doc.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Tests](#2-tests)
3. [Success Flag](#3-success-flag)
4. [See Also](#4-see-also)
5. [Changelog](#changelog)

---

## 1. Overview

**Phase 1** tests the **core modules** — the fundamental building blocks of the build system.

| Aspect | Description |
|--------|-------------|
| **Purpose** | Core module validation |
| **Debug ID** | `PHASE1_TEST` |
| **Dependencies** | All core modules must be loaded |

---

## 2. Tests

### 2.1 Context API

```cmake
ctx_create(TEST_CTX)
ctx_set(TEST_CTX NAME "TestTarget")
ctx_get(TEST_CTX NAME _test_name)
```

| Test | Checks |
|------|--------|
| `ctx_create` | Create a context |
| `ctx_set` | Set values |
| `ctx_get` | Read values |

### 2.2 JSON Helpers

| Function | Checks |
|----------|--------|
| `_json_has_key` | Key existence |
| `_json_get_string` | String values |
| `_json_get_string_or_default` | Default values |
| `_json_get_bool_from_key` | Boolean values |
| `_json_get_type` | Type detection |

### 2.3 Debug System

| Function | Checks |
|----------|--------|
| `dbg_init` | Debug initialization |
| `dbg` | Debug output (all levels) |
| `dbgspace` | Blank lines |
| `enddbgblock` | Block end |

### 2.4 Warning System

| Function | Checks |
|----------|--------|
| `cmake_warn` | Non-fatal warnings |

---

## 3. Success Flag

```cmake
set(PHASE1_TEST_PASSED TRUE CACHE BOOL "Phase 1 Test passed" FORCE)
```

---

## 4. See Also

- [Errors.md](../core/Errors.md)
- [Debug.md](../core/Debug.md)
- [Json.md](../core/Json.md)
- [Context.md](../core/Context.md)
- [Validation.md](../core/Validation.md)

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-15 | Blueprint v0.5.0 format |
| 0.1.0 | 2025-12-05 | Initial |
