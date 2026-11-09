# TestCollect.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** In Development (Pre-Release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [TestCollect.md](../../../../de/guide/module/project/TestCollect.md)  
> **Module:** [`cmake/project/TestCollect.cmake`](../../../../../cmake/project/TestCollect.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [API Reference](#3-api-reference)
4. [Context Keys](#4-context-keys)
5. [Default Values](#5-default-values)
6. [JSON Mapping](#6-json-mapping)
7. [See Also](#7-see-also)
8. [Changelog](#changelog)

---

## 1. Overview

The `TestCollect.cmake` module **collects test data** from JSON and stores it in a context. It handles default values and path conventions.

### Core Idea

Analogous to ExecutableCollect/LibraryCollect — separation of Collect and Create.

### Responsibilities

| Area | Description |
|------|-------------|
| JSON parsing | Extract all test fields |
| Defaults | Framework, timeout, labels |
| Conventions | Path defaults |

---

## 2. Dependencies

| Module | Version | Usage |
|--------|---------|-------|
| Context.cmake | 0.5.0 | `ctx_set` |
| Json.cmake | 0.5.0 | All `_json_*` functions |
| Debug.cmake | 0.5.0 | `dbg` |

---

## 3. API Reference

### 3.1 _collect_test()

Collects all fields of a test from JSON into a context.

```cmake
_collect_test(<TEST_JSON> <CTX>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `TEST_JSON` | String | ✓ | JSON string of the test |
| `CTX` | String | ✓ | Context prefix (e.g. `TEST_0`) |

---

## 4. Context Keys

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `NAME` | String | — | Test name (required) |
| `DISPLAY_NAME` | String | NAME | Display name |
| `VERSION` | String | Solution version | Version |
| `TYPE` | String | "unit" | unit, integration, e2e |
| `FRAMEWORK` | String | "doctest" | Test framework |
| `PATH` | Path | `projects/tests/{name}/src` | Source path |
| `TARGET` | String | "" | Target under test |
| `DEPENDENCIES` | List | "" | Internal dependencies |
| `EXTERNALS` | List | "" | External dependencies |
| `EXTERNAL_OPTIONS` | JSON | "{}" | External options |
| `TIMEOUT` | Int | 60 | Timeout in seconds |
| `LABELS` | List | [TYPE] | CTest labels |
| `PARALLEL` | Bool | TRUE | Can run in parallel |
| `SKIP` | Bool | FALSE | Skip |
| `PLATFORMS` | List | "" | Platform filter |
| `DEFINES` | List | "" | Preprocessor definitions |
| `COMPILE_OPTIONS` | List | "" | Compiler options |

---

## 5. Default Values

| Constant | Value | Description |
|----------|-------|-------------|
| `_TEST_DEFAULT_TYPE` | "unit" | Default test type |
| `_TEST_DEFAULT_FRAMEWORK` | "doctest" | Default framework |
| `_TEST_DEFAULT_TIMEOUT` | 60 | Seconds |
| `_TEST_DEFAULT_PARALLEL` | TRUE | Parallel allowed |

---

## 6. JSON Mapping

### 6.1 Minimal JSON

```json
{
    "name": "CoreLibTests"
}
```

### 6.2 Complete JSON

```json
{
    "name": "CoreLibTests",
    "displayName": "Core Library Tests",
    "type": "unit",
    "framework": "doctest",
    "path": "tests/core",
    "target": "CoreLib",
    "dependencies": ["UtilLib"],
    "externals": ["doctest"],
    "timeout": 120,
    "labels": ["unit", "core", "fast"],
    "parallel": true,
    "skip": false,
    "platforms": ["windows", "linux"],
    "defines": ["TESTING=1"],
    "compile_options": ["-O0"]
}
```

---

## 7. See Also

- [Tests.cmake](Tests.md) — Calls _collect_test
- [TestCreate.cmake](TestCreate.md) — Uses the context
- [ExecutableCollect.cmake](ExecutableCollect.md) — Analogous module

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0 |
| 0.1.0 | 2025-12-11 | Initial (clean start): test data collection |
