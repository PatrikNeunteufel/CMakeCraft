# LibraryCollect.cmake — Module Documentation

> **Version:** 1.0.2  
> **Date:** 2026-11-07  
> **Type:** ModuleDoc  
> **Status:** In Development (Pre-Release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [LibraryCollect.md](../../../../de/guide/module/project/LibraryCollect.md)  
> **Module:** [`cmake/project/LibraryCollect.cmake`](../../../../../cmake/project/LibraryCollect.cmake)  
> **Module Version:** 1.1.0

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

The `LibraryCollect.cmake` module **collects data** from the JSON of a library and stores it in a context. It is responsible for parsing and normalizing the library definitions.

### Core Idea

Analogous to ExecutableCollect — separation of concerns: Collect gathers, Create uses.

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

### 3.1 _collect_library()

Collects all fields of a library from JSON into a context.

```cmake
_collect_library(<LIB_JSON> <CTX>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `LIB_JSON` | String | ✓ | JSON string of the library |
| `CTX` | String | ✓ | Context prefix (e.g. `LIB_0`) |

**Return value:** None (fills the context)

---

## 4. Context Keys

### 4.1 Required Fields

| Key | Type | Description |
|-----|------|-------------|
| `NAME` | String | Target name (required in JSON) |

### 4.2 Optional Fields

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `VERSION` | String | Solution version | Version |
| `PATH` | Path | `projects/libs/{name}/src` | Source path |
| `TYPE` | Enum | From settings | STATIC, SHARED, INTERFACE |
| `PUBLIC_HEADERS` | Path | "" | Public header directory |
| `SKIP` | Bool | FALSE | Skip |
| `PCH_ENABLED` | Bool | FALSE | Enable PCH |
| `PCH_HEADER` | String | `pch.h` | PCH header name |
| `PCH_PATH` | String | "" | Custom PCH path (relative to projects/) |
| `DEPENDENCIES` | List | "" | Internal dependencies |
| `EXTERNALS` | List | "" | External dependencies |
| `EXTERNAL_OPTIONS` | JSON | "{}" | Per-external options |
| `PLATFORM` | String | "" (= all) | Target platform |
| `OUTPUT_NAME` | String | "" (= target name) | File name without extension (JSON: `output_name`) |
| `DEFINES` | List | "" | Preprocessor definitions (JSON: `defines`); `{version}` is only replaced in LibraryCreate |
| `COMPILE_OPTIONS` | List | "" | Compiler flags of the library (JSON: `compile_options`), generator expressions unchanged; LibraryCreate sets them PRIVATE, E105 for INTERFACE |

**Note:** PCH is enabled implicitly if `pch.header` or `pch.path` is specified and `pch.enabled` is not explicitly `false`.

---

## 5. JSON Mapping

### 5.1 Minimal JSON

```json
{
    "name": "CoreLib"
}
```

### 5.2 Complete JSON

```json
{
    "name": "CoreLib",
    "version": "1.0.0",
    "path": "src/libs/core",
    "type": "STATIC",
    "public_headers": "include/core",
    "skip": false,
    "pch": {
        "enabled": true,
        "header": "pch.h"
    },
    "dependencies": ["UtilLib"],
    "externals": ["bass"],
    "external_options": {
        "bass": { "BASS_FLAC": true }
    },
    "platform": "windows",
    "output_name": "CoreLib1",
    "defines": ["CORE_LIB_VERSION=\"{version}\""],
    "compile_options": ["$<$<CXX_COMPILER_ID:MSVC>:/fp:precise>"]
}
```

---

## 6. Error Handling

| Code | Condition | Solution |
|------|-----------|----------|
| E001 | `name` field missing | Add a name |

---

## 7. See Also

- [Libraries.cmake](Libraries.md) — Calls _collect_library
- [LibraryCreate.cmake](LibraryCreate.md) — Uses the filled context
- [ExecutableCollect.cmake](ExecutableCollect.md) — Analogous module for executables

---

## 8. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.2** | **2026-11-07** | **CMakeCraft v0.14.0: COMPILE_OPTIONS added (JSON: `compile_options`); module version 1.1.0** |
| 1.0.1 | 2026-10-09 | CMakeCraft v0.10.0: OUTPUT_NAME and DEFINES added (JSON: `output_name`, `defines`) |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.6.0 | 2025-12-20 | EXTERNAL_OPTIONS added: per-external options analogous to ExecutableCollect |
| 0.5.1 | 2025-12-18 | PCH support added: PCH_ENABLED, PCH_HEADER, PCH_PATH |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0 |
| 0.1.0 | 2025-12-07 | Initial (clean start): JSON to context mapping |
