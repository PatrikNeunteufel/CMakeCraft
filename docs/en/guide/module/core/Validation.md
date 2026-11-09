# Validation.cmake — Module Documentation

> **Version:** 1.0.2  
> **Date:** 2026-11-09  
> **Type:** ModuleDoc  
> **Status:** In development (pre-release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [Validation.md](../../../../de/guide/module/core/Validation.md)  
> **Module:** [`cmake/core/Validation.cmake`](../../../../../cmake/core/Validation.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [API Reference](#3-api-reference)
4. [Error Handling](#4-error-handling)
5. [Usage Examples](#5-usage-examples)
6. [See Also](#6-see-also)
7. [Changelog](#changelog)

---

## 1. Overview

The `Validation.cmake` module provides **JSON schema validation** for Solution.json and externals. It ensures that all configurations are correct and complete.

### Core Idea

Early validation following the fail-fast principle — errors are detected before they lead to cryptic CMake errors.

### Responsibilities

| Area | Description |
|------|-------------|
| Required fields | Check for existence |
| Source fields | Exactly one source type per external |
| Schema version | Compatibility check |
| Best practices | Include.cmake quality checks |

### Used By

- Solution.cmake
- Orchestrator.cmake

---

## 2. Dependencies

| Module | Version | Usage |
|--------|---------|-------|
| Errors.cmake | 0.1.2 | `cmake_fatal`, `cmake_warn` |
| Json.cmake | 0.1.1 | `_json_has_key`, `_json_get_string`, `_json_get_string_or_default` |

---

## 3. API Reference

### 3.1 validate_external_source()

Checks that an external has exactly one source field.

```cmake
validate_external_source(<EXT_NAME> <EXT_JSON>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `EXT_NAME` | String | ✓ | Name of the external |
| `EXT_JSON` | String | ✓ | JSON string of the external object |

**Allowed source fields** (`Validation.cmake:58`):

- `system` — system external (`"system": true`, phase 9; also requires `package`)
- `path` — local external
- `git` — fetched via Git
- `archive` — archive external (prebuilt package, pinned version)
- `vcpkg`, `conan`, `find_package` — reserved: the check lets them pass, but the orchestrator does not know
  them and aborts with E012 (`No valid source field (system/git/path/archive)`, `Orchestrator.cmake:115`)

**Errors:**

| Code | Condition |
|------|-----------|
| E012 | No source field present |
| E012 | Several source fields present |
| E502 | `system: true`, but field `package` missing |

**Example:**

```cmake
validate_external_source("bass" "${_ext_json}")
```

---

### 3.2 validate_required_fields()

Checks that all given required fields exist.

```cmake
validate_required_fields(<JSON_STRING> <ENTITY_TYPE> <ENTITY_NAME> FIELDS <field1> [field2...])
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `JSON_STRING` | String | ✓ | JSON object as string |
| `ENTITY_TYPE` | String | ✓ | Type for the error message |
| `ENTITY_NAME` | String | ✓ | Name for the error message |
| `FIELDS` | List | ✓ | List of required fields |

**Errors:**

| Code | Condition |
|------|-----------|
| E001 | A required field is missing |

**Example:**

```cmake
validate_required_fields("${_json}" "Executable" "MyApp" FIELDS name path)
```

---

### 3.3 validate_fetched_external()

Checks that a fetched external has a version specifier.

```cmake
validate_fetched_external(<EXT_NAME> <EXT_JSON>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `EXT_NAME` | String | ✓ | Name of the external |
| `EXT_JSON` | String | ✓ | JSON string of the external object |

**Required (at least one):**

- `tag` — Git tag (e.g. "v1.0.0")
- `branch` — Git branch (e.g. "main")
- `commit` — Git commit SHA

**Errors:**

| Code | Condition |
|------|-----------|
| E215 | Neither tag, branch nor commit given |

**Example:**

```cmake
validate_fetched_external("glfw" "${_ext_json}")
```

---

### 3.4 validate_local_external()

Checks that Include.cmake exists for a local external.

```cmake
validate_local_external(<EXT_NAME> <EXT_JSON>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `EXT_NAME` | String | ✓ | Name of the external |
| `EXT_JSON` | String | ✓ | JSON string of the external object |

**Checks:**

1. Custom "include" field, or
2. Convention: `${path}/Include.cmake`

**Errors:**

| Code | Condition |
|------|-----------|
| E213 | Include.cmake not found |

**Example:**

```cmake
validate_local_external("bass" "${_ext_json}")
```

---

### 3.5 validate_solution_schema()

Checks the schema version of Solution.json.

> Currently not called (as of 2026-11-09): no module calls `validate_solution_schema()`, so
> W001 is never raised. `cmake/project/Solution.cmake` checks the schema version itself
> (E002 `:82`, `:94`; E003 `:102`; W101 `:107`; W102 `:109`).

```cmake
validate_solution_schema(<SOLUTION_JSON>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `SOLUTION_JSON` | String | ✓ | Complete JSON string of Solution.json |

**Warnings:**

| Code | Condition |
|------|-----------|
| W001 | schemaVersion missing |
| W001 | schemaVersion < 0.1 |

**Example:**

```cmake
file(READ "${CMAKE_SOURCE_DIR}/Solution.json" _json)
validate_solution_schema("${_json}")
```

---

### 3.6 validate_local_external_include()

Best-practice checks for Include.cmake.

```cmake
validate_local_external_include(<INCLUDE_FILE> <EXT_NAME>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `INCLUDE_FILE` | Path | ✓ | Full path to Include.cmake |
| `EXT_NAME` | String | ✓ | Name of the external |

**Warnings:**

| Code | Condition |
|------|-----------|
| W103 | `add_executable()` found (IDE clutter) |
| W104 | `add_subdirectory(examples|tests|...)` found |

**Example:**

```cmake
validate_local_external_include("${_include_path}" "imgui")
```

---

## 4. Error Handling

### 4.1 Fatal Errors

| Code | Function | Description |
|------|----------|-------------|
| E001 | validate_required_fields | Required field missing |
| E012 | validate_external_source | No / several source fields |
| E502 | validate_external_source | `system: true` without `package` |
| E213 | validate_local_external | Include.cmake not found |
| E215 | validate_fetched_external | No tag/branch/commit |

### 4.2 Warnings

| Code | Function | Description |
|------|----------|-------------|
| W001 | validate_solution_schema | Schema version missing/outdated (currently not raised, §3.5) |
| W103 | validate_local_external_include | add_executable() found |
| W104 | validate_local_external_include | Example directories included |

---

## 5. Usage Examples

### 5.1 In Solution.cmake

> Template, not today's code: `cmake/project/Solution.cmake` calls neither
> `validate_solution_schema()` nor `validate_required_fields()` (as of 2026-11-09); it checks
> the schema version itself (§3.5).

```cmake
file(READ "${CMAKE_SOURCE_DIR}/Solution.json" _json)

# Check the schema
validate_solution_schema("${_json}")

# solution.name is required
_json_get_object("${_json}" "solution" _solution)
validate_required_fields("${_solution}" "Solution" "" FIELDS name)
```

### 5.2 In Orchestrator.cmake

```cmake
function(_orchestrate_external EXT_NAME EXT_JSON)
    # Check the source field
    validate_external_source("${EXT_NAME}" "${EXT_JSON}")
    
    _json_has_key("${EXT_JSON}" "path" _is_local)
    _json_has_key("${EXT_JSON}" "git" _is_git)
    
    if(_is_local)
        validate_local_external("${EXT_NAME}" "${EXT_JSON}")
        # ...
    elseif(_is_git)
        validate_fetched_external("${EXT_NAME}" "${EXT_JSON}")
        # ...
    endif()
endfunction()
```

### 5.3 Executable Validation

```cmake
function(_collect_executable EXE_JSON CTX)
    _json_get_string("${EXE_JSON}" "name" _name)
    
    # Validate required fields
    validate_required_fields("${EXE_JSON}" "Executable" "${_name}" 
        FIELDS name path)
    
    # ...
endfunction()
```

---

## 6. See Also

- [Errors.cmake](Errors.md) — cmake_fatal, cmake_warn
- [Json.cmake](Json.md) — JSON helper functions
- [Solution.cmake](../project/Solution.md) — uses Validation
- [Orchestrator.cmake](../externals/Orchestrator_cmake.md) — uses Validation
- [ErrorCodes.md](../../references/ErrorCodes.md) — E001, E012, E213, E215, E502, W001, W103, W104

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.2** | **2026-11-09** | **Aligned with the code: allowed source fields in §3.1 include `system`; `vcpkg`/`conan`/`find_package` as reserved (orchestrator: E012); E502 in the error tables §3.1 and §4.1 (`Validation.cmake:58`, `:94`); `validate_solution_schema()` noted as not called (§3.5, §4.2, §5.1), so W001 is never raised** |
| 1.0.1 | 2026-10-09 | CMakeCraft v0.10.0: validate_external_source: `archive` as source field; the E012 message names `archive` |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0: new header with target audience/language/English link/module link, numbered table of contents with anchors, chapter numbering |
| 0.1.1 | 2025-12-05 | English translation (Language Standards v0.1.1) |
| 0.1.0 | 2025-12-03 | Initial (clean start): validate_external_source, validate_required_fields, validate_fetched_external, validate_local_external, validate_solution_schema, validate_local_external_include |
