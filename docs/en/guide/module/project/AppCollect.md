# AppCollect.cmake — Documentation

> **Version:** 1.0.3  
> **Date:** 2026-10-09  
> **Type:** ModuleDoc  
> **Status:** In Development  
> **Target Audience:** Build system developers  
> **Module:** [cmake/project/AppCollect.cmake](../../../../../cmake/project/AppCollect.cmake)  
> **Module Version:** 1.0.0  
> **Based on:** ModuleDoc v0.5  
> **Language:** English  
> **German:** [AppCollect.md](../../../../de/guide/module/project/AppCollect.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Concept](#3-concept)
4. [API Reference](#4-api-reference)
5. [Context Keys](#5-context-keys)
6. [Usage Examples](#6-usage-examples)
7. [Error Handling](#7-error-handling)
8. [Best Practices](#8-best-practices)
9. [See Also](#9-see-also)
10. [Changelog](#10-changelog)

---

## 1. Overview

The `AppCollect` module is responsible for **parsing app container definitions** from Solution.json and storing the extracted data in a context object.

### Purpose

- Extraction of all app container fields from JSON
- Transformation into typed context keys
- Application of default values
- Validation of required fields

### Features

- Complete parsing of the `apps[]` JSON structure
- Separate handling of core, runner and test configuration
- Sensible defaults (convention over configuration)
- Debug output for diagnostics

---

## 2. Dependencies

| Dependency | Type | Description |
|------------|------|-------------|
| CMake 3.19+ | System | JSON functions, `include_guard(GLOBAL)` |
| `Json.cmake` | Module | JSON parsing functions |
| `Context.cmake` | Module | Context object pattern |
| `Debug.cmake` | Module | Debug output |
| `Errors.cmake` | Module | Error handling |

---

## 3. Concept

### 3.1 App Container Architecture

An app container separates business logic (Core) from the entry point (Runner):

```
┌─────────────────────────────────────────┐
│           App-Container                  │
│  ┌─────────────────────────────────┐    │
│  │      AppName.Core (STATIC)      │    │
│  │  ┌─────────┐ ┌─────────┐        │    │
│  │  │ Module A│ │ Module B│        │    │
│  │  └─────────┘ └─────────┘        │    │
│  └─────────────────────────────────┘    │
│                  │                       │
│         ┌───────┼───────┐               │
│         ▼       ▼       ▼               │
│  ┌──────────┐ ┌─────┐ ┌─────┐           │
│  │  Runner  │ │Unit │ │Int. │           │
│  │  (main)  │ │Tests│ │Tests│           │
│  └──────────┘ └─────┘ └─────┘           │
└─────────────────────────────────────────┘
```

### 3.2 JSON → Context Transformation

AppCollect transforms the hierarchical JSON structure into flat context keys:

```
JSON:                          Context:
{                              
  "name": "AudioPlayer",   →   NAME = "AudioPlayer"
  "core": {                    
    "externals": ["bass"]  →   CORE_EXTERNALS = "bass"
  },                           
  "runner": {                  
    "type": "WINDOW"       →   RUNNER_TYPE = "WINDOW"
  }                            
}                              
```

### 3.3 Default Values

The module applies the following defaults:

| Field | Default | Rationale |
|-------|---------|-----------|
| `path` | `projects/apps/{name}` | Convention over configuration |
| `runner.type` | `CONSOLE` | Most common case |
| `pch.header` | `pch.h` | Standard name, path via search priority |
| `tests.framework` | `""` (empty) | Resolved only in AppCreate: per-target > global > E301 |
| `targets[].path` | `tests/{type}/{name}` | Convention over configuration |
| `targets[].timeout` | Type-dependent | e.g. unit=30s, integration=120s (see [Solution_Schema § 9.9](../../references/Solution_Schema.md#99-test-types-and-defaults)) |
| `targets[].labels` | Type-dependent | e.g. unit → `["unit", "fast"]` |
| `targets[].parallel` | Type-dependent | `FALSE` for performance, system, fuzz, security, ui |

---

## 4. API Reference

### 4.1 _collect_app()

```cmake
_collect_app(APP_JSON CTX)
```

**Description:**  
Parses an app container definition from JSON and stores all fields in the given context.

**Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `APP_JSON` | ✓ | JSON string of the app definition |
| `CTX` | ✓ | Context prefix (e.g. `APP_0`, `APP_1`) |

**Return value:**  
No direct return value. All values are stored as context keys.

**Example:**

```cmake
ctx_create(APP_0)
_collect_app("${_app_json}" APP_0)

ctx_get(APP_0 NAME _name)
ctx_get(APP_0 CORE_EXTERNALS _core_ext)
ctx_get(APP_0 RUNNER_TYPE _type)
```

**Errors:**
- `E400` if the `name` field is missing
- `E303`/`E304` if a test target is missing `name` or `type`

---

## 5. Context Keys

### 5.1 Base Keys

| Key | Type | JSON Path | Default |
|-----|------|-----------|---------|
| `NAME` | String | `name` | ⛔ Required |
| `DISPLAY_NAME` | String | `displayName` | = NAME |
| `DESCRIPTION` | String | `description` | `""` |
| `VERSION` | String | `version` | Solution version |
| `PATH` | String | `path` | `projects/apps/{name}` |
| `SKIP` | Bool | `skip` | `FALSE` |
| `PLATFORMS` | List | `platforms[]` | `[]` (all) |

### 5.2 Core Keys

| Key | Type | JSON Path | Default |
|-----|------|-----------|---------|
| `CORE_DEPENDENCIES` | List | `core.dependencies[]` | `[]` |
| `CORE_EXTERNALS` | List | `core.externals[]` | `[]` |
| `CORE_EXTERNAL_OPTIONS` | JSON | `core.external_options` | `{}` |

### 5.3 Runner Keys

| Key | Type | JSON Path | Default |
|-----|------|-----------|---------|
| `RUNNER_TYPE` | String | `runner.type` | `CONSOLE` |
| `RUNNER_EXTERNALS` | List | `runner.externals[]` | `[]` |
| `RUNNER_EXTERNAL_OPTIONS` | JSON | `runner.external_options` | `{}` |

### 5.4 PCH Keys

| Key | Type | JSON Path | Default |
|-----|------|-----------|---------|
| `PCH_ENABLED` | Bool | `pch.enabled` | `FALSE` |
| `PCH_HEADER` | String | `pch.header` | `pch.h` |
| `PCH_PATH` | String | `pch.path` | `""` (empty) |

**Note:** PCH is enabled implicitly if `pch.header` or `pch.path` is specified and `pch.enabled` is not explicitly `false`.

### 5.5 Test Keys (global)

| Key | Type | JSON Path | Default |
|-----|------|-----------|---------|
| `TESTS_FRAMEWORK` | String | `tests.framework` | `""` (empty, resolved in AppCreate) |
| `TESTS_SKIP` | Bool | `tests.skip` | `FALSE` |
| `TESTS_TARGETS_COUNT` | Number | (length of `tests.targets[]`) | `0` |

### 5.6 Test Target Keys (per entry in tests.targets[])

`{n}` is the 0-based index in the `targets[]` array.

| Key | Type | JSON Path | Default |
|-----|------|-----------|---------|
| `TESTS_TARGET_{n}_NAME` | String | `targets[].name` | ⛔ Required (E303) |
| `TESTS_TARGET_{n}_TYPE` | String | `targets[].type` | ⛔ Required (E304) |
| `TESTS_TARGET_{n}_SKIP` | Bool | `targets[].skip` | `FALSE` |
| `TESTS_TARGET_{n}_PATH` | String | `targets[].path` | `tests/{type}/{name}` |
| `TESTS_TARGET_{n}_FRAMEWORK` | String | `targets[].framework` | `""` (→ `TESTS_FRAMEWORK`) |
| `TESTS_TARGET_{n}_TIMEOUT` | Number | `targets[].timeout` | Type-dependent |
| `TESTS_TARGET_{n}_LABELS` | List | `targets[].labels[]` | Type-dependent |
| `TESTS_TARGET_{n}_DEPENDENCIES` | List | `targets[].dependencies[]` | `[]` |
| `TESTS_TARGET_{n}_EXTERNALS` | List | `targets[].externals[]` | `[]` |
| `TESTS_TARGET_{n}_EXTERNAL_OPTIONS` | JSON | `targets[].external_options` | `{}` |
| `TESTS_TARGET_{n}_COMPILE_OPTIONS` | List | `targets[].compile_options` | `""` |
| `TESTS_TARGET_{n}_PARALLEL` | Bool | `targets[].parallel` | Type-dependent |

The type-dependent defaults (timeout, labels, parallel) are provided by `_get_test_type_defaults()`; the table is in [Solution_Schema § 9.9](../../references/Solution_Schema.md#99-test-types-and-defaults).

---

## 6. Usage Examples

### 6.1 Minimal App Definition

**JSON:**
```json
{
    "apps": [
        {
            "name": "SimpleApp"
        }
    ]
}
```

**Resulting context keys:**
```cmake
NAME = "SimpleApp"
DISPLAY_NAME = "SimpleApp"
PATH = "projects/apps/SimpleApp"
RUNNER_TYPE = "CONSOLE"
TESTS_FRAMEWORK = ""
TESTS_TARGETS_COUNT = 0
# ... (all others with defaults)
```

### 6.2 Complete App Definition

**JSON:**
```json
{
    "apps": [
        {
            "name": "AudioPlayer",
            "displayName": "Audio Player Application",
            "version": "2.0.0",
            
            "core": {
                "dependencies": ["BasicLogger"],
                "externals": ["bass", "spdlog"]
            },
            
            "runner": {
                "type": "WINDOW",
                "externals": ["imgui_docking", "glad", "glfw"]
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
                        "timeout": 30,
                        "labels": ["unit", "audio"]
                    },
                    {
                        "name": "IntegrationTests",
                        "type": "integration",
                        "timeout": 120,
                        "labels": ["integration", "audio"],
                        "dependencies": ["BasicLogger"],
                        "externals": ["bass"]
                    }
                ]
            },
            
            "platforms": ["windows", "linux", "macos"]
        }
    ]
}
```

### 6.3 Usage in Apps.cmake

```cmake
# Iterate over the apps array
foreach(_idx RANGE 0 ${_last_idx})
    _json_array_get("${_solution_json}" "apps" ${_idx} _app_json)
    
    # Create and fill the context
    ctx_create(APP_${_idx})
    _collect_app("${_app_json}" APP_${_idx})
    
    # Use the values
    ctx_get(APP_${_idx} NAME _name)
    ctx_get(APP_${_idx} SKIP _skip)
    
    if(_skip)
        continue()
    endif()
    
    # Continue with AppCreate...
endforeach()
```

---

## 7. Error Handling

### 7.1 Errors Raised

| Code | Condition | Message |
|------|-----------|---------|
| `E400` | `name` field missing | `App definition missing required 'name' field` |
| `E303` | Test target without `name` | `Test target [{n}] missing required 'name' field` |
| `E304` | Test target without `type` | `Test target '{name}' missing required 'type' field` |

### 7.2 Warnings Raised

| Code | Condition |
|------|-----------|
| `W401` | `tests.targets` is present but empty |
| `W402` | `parallel: true` on a serial test type (performance, system, fuzz, security, ui) |

### 7.3 Error Context

AppCollect raises only parsing errors. Validation errors (path does not exist, unknown framework, unknown dependency, etc.) are handled by `AppCreate` (E301/E302/E305, E101).

---

## 8. Best Practices

### 8.1 Do's

| Recommendation | Rationale |
|----------------|-----------|
| Check the context right after Collect | Early error detection |
| Use debug level ULTRA_RARE for details | Complete diagnostics |
| Document defaults | Transparency for users |

### 8.2 Don'ts

| Avoid | Reason |
|-------|--------|
| Validation in Collect | Separation of concerns |
| Direct JSON access after Collect | The context is the single source of truth |
| Changing hardcoded defaults | Breaks existing apps |

---

## 9. See Also

- [Apps.cmake](Apps.md) — Orchestrator for the app pipeline
- [AppCreate.cmake](AppCreate.md) — Target creation
- [Context.cmake](../core/Context.md) — Context object pattern
- [Json.cmake](../core/Json.md) — JSON parsing
- [AppContainer_Concept.md](../../../konzepte/abgeschlossen/AppContainer_Concept.md) — Concept document
- [ErrorCodes.md](../../references/ErrorCodes.md) — Error code reference (E4xx)

---

## 10. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.3** | **2026-10-09** | **New key TESTS_TARGET_{n}_COMPILE_OPTIONS (§ 5.6): `targets[].compile_options` is collected (CMakeCraft v0.11.0)** |
| **1.0.2** | **2026-10-05** | **New key TESTS_TARGET_{n}_EXTERNAL_OPTIONS (§ 5.6): `targets[].external_options` is collected — until now the key was ignored on app tests** |
| **1.0.1** | **2026-07-20** | **Test keys brought up to the tests.targets[] structure (§ 5.5/5.6): TESTS_TARGET_{n}_* keys documented incl. new DEPENDENCIES key, old tests.unit/tests.integration schema removed; example 6.2 and error list (§ 7) corrected (E400 instead of E401, E303/E304, W401/W402)** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.7.0 | 2025-12-20 | CORE_EXTERNAL_OPTIONS and RUNNER_EXTERNAL_OPTIONS added |
| 0.5.1 | 2025-12-18 | PCH defaults corrected: header set to pch.h, PCH_SOURCE removed, PCH_PATH added, implicit activation documented |
| 0.5.0 | 2025-12-17 | Initial: Phase 8 app container JSON parsing, core/runner/tests separation, complete context keys |
