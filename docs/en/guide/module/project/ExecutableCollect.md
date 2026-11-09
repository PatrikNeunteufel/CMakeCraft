# ExecutableCollect.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** In Development (Pre-Release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [ExecutableCollect.md](../../../../de/guide/module/project/ExecutableCollect.md)  
> **Module:** [`cmake/project/ExecutableCollect.cmake`](../../../../../cmake/project/ExecutableCollect.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [API Reference](#3-api-reference)
4. [Context Keys](#4-context-keys)
5. [JSON Mapping](#5-json-mapping)
6. [Error Handling](#6-error-handling)
7. [See Also](#7-see-also)
8. [Changelog](#8-changelog)

---

## 1. Overview

The `ExecutableCollect.cmake` module **collects data** from the JSON of an executable and stores it in a context. It is responsible for parsing and normalizing the executable definitions.

### Core Idea

Separation of concerns: Collect gathers and normalizes data, Create uses it.

### Responsibilities

| Area | Description |
|------|-------------|
| JSON parsing | Extract all fields |
| Normalization | Set defaults, unify types |
| Filling the context | Store all values as context keys |

---

## 2. Dependencies

| Module | Version | Usage |
|--------|---------|-------|
| Json.cmake | 0.5.0 | All `_json_*` functions |
| Context.cmake | 0.5.0 | `ctx_set` |
| Debug.cmake | 0.5.0 | `dbg` |

---

## 3. API Reference

### 3.1 _collect_executable()

Collects all fields of an executable from JSON into a context.

```cmake
_collect_executable(<EXE_JSON> <CTX>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `EXE_JSON` | String | ✓ | JSON string of the executable |
| `CTX` | String | ✓ | Context prefix (e.g. `EXE_0`) |

**Return value:** None (fills the context)

**Example:**

```cmake
_json_array_get("${_solution_json}" "executables" 0 _exe_json)
ctx_create(EXE_0)
_collect_executable("${_exe_json}" EXE_0)

# Available afterwards:
ctx_get(EXE_0 NAME _name)
ctx_get(EXE_0 PATH _path)
```

---

## 4. Context Keys

### 4.1 Required Fields

| Key | Type | Description |
|-----|------|-------------|
| `NAME` | String | Target name (required in JSON) |

### 4.2 Optional Fields

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `DISPLAY_NAME` | String | NAME | Display name |
| `DESCRIPTION` | String | "" | Description |
| `VERSION` | String | Solution version | Version |
| `PATH` | Path | `projects/exec/{name}/src` | Source path |
| `TYPE` | Enum | From settings | CONSOLE, GUI, CLI, HEADLESS, WORKER |
| `SKIP` | Bool | FALSE | Skip |
| `PCH_ENABLED` | Bool | FALSE | PCH enabled |
| `PCH_HEADER` | String | `pch.h` | PCH header file |
| `PCH_PATH` | String | "" | Custom PCH path (relative to projects/) |
| `DEPENDENCIES` | List | "" | Internal dependencies |
| `EXTERNALS` | List | "" | External dependencies |
| `EXTERNAL_OPTIONS` | JSON | "{}" | External-specific options |
| `PLATFORMS` | List | "" (= all) | Supported platforms |
| `DEFINES` | List | "" | Preprocessor definitions |
| `COMPILE_OPTIONS` | List | "" | Additional compiler options |
| `LINK_OPTIONS` | List | "" | Additional linker options |

**Note:** PCH is enabled implicitly if `pch.header` or `pch.path` is specified and `pch.enabled` is not explicitly `false`.

---

## 5. JSON Mapping

### 5.1 Minimal JSON

```json
{
    "name": "MyApp"
}
```

Result:
- NAME = "MyApp"
- PATH = "projects/exec/MyApp/src" (convention)
- TYPE = SOLUTION_DEFAULT_EXECUTABLE_TYPE
- VERSION = SOLUTION_VERSION

### 5.2 Complete JSON

```json
{
    "name": "MyApp",
    "displayName": "My Application",
    "description": "A sample application",
    "version": "1.0.0",
    "path": "src/apps/myapp",
    "type": "GUI",
    "skip": false,
    "pch": {
        "enabled": true,
        "header": "stdafx.h"
    },
    "dependencies": ["CoreLib", "UtilLib"],
    "externals": ["imgui", "glfw"],
    "external_options": {
        "imgui": { "backend": "glfw" }
    },
    "platforms": ["windows", "linux"],
    "defines": ["MY_APP_VERSION=1"],
    "compile_options": ["-ffast-math"],
    "link_options": ["-static"]
}
```

### 5.3 Type Conversion

The `type` value is automatically converted to uppercase:

| JSON | Context |
|------|---------|
| "console" | "CONSOLE" |
| "Gui" | "GUI" |
| "CLI" | "CLI" |

---

## 6. Error Handling

### 6.1 Fatal Errors

| Code | Condition | Solution |
|------|-----------|----------|
| E001 | `name` field missing | Add a name |

### 6.2 Implicit Defaults

Missing optional fields do not cause errors; they are filled with sensible defaults.

---

## 7. See Also

- [Executables.cmake](Executables.md) — Calls _collect_executable
- [ExecutableCreate.cmake](ExecutableCreate.md) — Uses the filled context
- [Context.cmake](../core/Context.md) — Context system
- [Json.cmake](../core/Json.md) — JSON parsing

---

## 8. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.1 | 2025-12-18 | PCH_PATH added, implicit PCH activation documented |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0: new header with target audience/language/English link/module link, numbered table of contents with anchors, chapter numbering |
| 0.1.0 | 2025-12-05 | Initial (clean start): JSON to context mapping |
