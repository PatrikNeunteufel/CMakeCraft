# Json.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** In development (pre-release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [Json.md](../../../../de/guide/module/core/Json.md)  
> **Module:** [`cmake/core/Json.cmake`](../../../../../cmake/core/Json.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [API Reference](#3-api-reference)
4. [Usage Examples](#4-usage-examples)
5. [Return Values and Error Handling](#5-return-values-and-error-handling)
6. [Best Practices](#6-best-practices)
7. [See Also](#7-see-also)
8. [Changelog](#changelog)

---

## 1. Overview

The `Json.cmake` module provides **JSON helper functions** for the CMake build system. It wraps the CMake 3.19+ `string(JSON ...)` commands in user-friendly functions.

### Core Idea

Uniform, fault-tolerant JSON operations for the entire build system.

### Responsibilities

| Area | Description |
|------|-------------|
| Reading | Strings, numbers, booleans, objects, arrays |
| Checking | Key existence, type detection |
| Fallbacks | Default values for missing keys |
| Conversion | Arrays to CMake lists |

### Used By

- Solution.cmake
- ExecutableCollect.cmake
- LibraryCollect.cmake
- TestCollect.cmake
- AppCollect.cmake
- Validation.cmake

### Note

All functions are marked with the `_` prefix (private), since they are intended only for internal build system use.

---

## 2. Dependencies

| Module | Version | Usage |
|--------|---------|-------|
| CMake | 3.19+ | `string(JSON ...)` command |

**Design decision:** Json.cmake is a base module without dependencies on other CMake modules. It uses no debug or error functions — errors are signaled by empty return values and handled by the calling modules.

→ See [Open clarifications](../../../konzepte/abgeschlossen/Offene_Abklaerungen_Core_Module.md) for details on this decision.

---

## 3. API Reference

### Function Overview

| # | Function | Description |
|---|----------|-------------|
| 3.1 | `_json_has_key` | Checks key existence |
| 3.2 | `_json_get_string` | Reads a string |
| 3.3 | `_json_get_string_or_default` | String with default |
| 3.4 | `_json_get_bool_from_key` | Reads a boolean |
| 3.5 | `_json_get_bool_or_default` | Boolean with default |
| 3.6 | `_json_array_length` | Array length |
| 3.7 | `_json_array_get` | Array element |
| 3.8 | `_json_get_array_as_list` | Array as CMake list |
| 3.9 | `_json_get_object` | Extracts an object |
| 3.10 | `_json_get_object_or_empty` | Object with fallback |
| 3.11 | `_json_get_type` | Type of a key |
| 3.12 | `_json_get_number` | Reads a number |
| 3.13 | `_json_get_number_or_default` | Number with default |

---

### 3.1 _json_has_key()

Checks whether a key exists in the JSON object.

```cmake
_json_has_key(<JSON_STRING> <KEY> <OUT_VAR>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `JSON_STRING` | String | ✓ | JSON object as string |
| `KEY` | String | ✓ | Key to check |
| `OUT_VAR` | Variable | ✓ | Output: TRUE or FALSE |

**Returns:** TRUE if the key exists, FALSE otherwise

**Example:**

```cmake
_json_has_key("${_json}" "name" _has_name)
if(_has_name)
    # Key exists
endif()
```

---

### 3.2 _json_get_string()

Reads a string value from JSON.

```cmake
_json_get_string(<JSON_STRING> <KEY> <OUT_VAR>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `JSON_STRING` | String | ✓ | JSON object as string |
| `KEY` | String | ✓ | Key |
| `OUT_VAR` | Variable | ✓ | Output: string value or "" |

**Returns:** String value on success, empty string if the key is missing

**Example:**

```cmake
_json_get_string("${_json}" "name" _name)
```

---

### 3.3 _json_get_string_or_default()

Reads a string value with fallback to a default.

```cmake
_json_get_string_or_default(<JSON_STRING> <KEY> <DEFAULT> <OUT_VAR>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `JSON_STRING` | String | ✓ | JSON object as string |
| `KEY` | String | ✓ | Key |
| `DEFAULT` | String | ✓ | Fallback value |
| `OUT_VAR` | Variable | ✓ | Output: string value or DEFAULT |

**Returns:** String value, or DEFAULT if the key is missing/empty

**Example:**

```cmake
_json_get_string_or_default("${_json}" "type" "CONSOLE" _type)
# _type is "CONSOLE" if "type" is missing
```

---

### 3.4 _json_get_bool_from_key()

Reads a boolean value with robust detection.

```cmake
_json_get_bool_from_key(<JSON_STRING> <KEY> <OUT_VAR>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `JSON_STRING` | String | ✓ | JSON object as string |
| `KEY` | String | ✓ | Key |
| `OUT_VAR` | Variable | ✓ | Output: TRUE or FALSE |

**Recognized values:**

| TRUE | FALSE |
|------|-------|
| true, TRUE, 1, ON, YES | false, FALSE, 0, OFF, NO, empty, key missing |

**Note:** CMake's `string(JSON GET)` returns the strings "true"/"false" (lowercase) for JSON `true`/`false`. This function recognizes all common variants.

**Example:**

```cmake
_json_get_bool_from_key("${_json}" "skip" _skip)
if(_skip)
    return()  # Skip
endif()
```

---

### 3.5 _json_get_bool_or_default()

Reads a boolean value with a fallback default if the key is missing.

```cmake
_json_get_bool_or_default(<JSON_STRING> <KEY> <DEFAULT> <OUT_VAR>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `JSON_STRING` | String | ✓ | JSON object as string |
| `KEY` | String | ✓ | Key |
| `DEFAULT` | Bool | ✓ | Fallback value if the key is missing (TRUE/FALSE) |
| `OUT_VAR` | Variable | ✓ | Output: TRUE or FALSE |

**Recognized values:**

| TRUE | FALSE |
|------|-------|
| true, TRUE, 1, ON, YES | false, FALSE, 0, OFF, NO |

**Difference to `_json_get_bool_from_key`:**

| Function | If the key is missing |
|----------|-----------------------|
| `_json_get_bool_from_key` | Returns FALSE |
| `_json_get_bool_or_default` | Returns the given DEFAULT |

**Example:**

```cmake
# With default TRUE if "enabled" is missing
_json_get_bool_or_default("${_json}" "enabled" TRUE _enabled)

# With default FALSE if "skip" is missing  
_json_get_bool_or_default("${_json}" "skip" FALSE _skip)
if(_skip)
    message(STATUS "Skipped")
endif()

# Parallel execution: default TRUE for unit tests
_json_get_bool_or_default("${_test_json}" "parallel" TRUE _parallel)
```

---

### 3.6 _json_array_length()

Determines the length of a JSON array.

```cmake
_json_array_length(<JSON_STRING> <KEY> <OUT_VAR>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `JSON_STRING` | String | ✓ | JSON object as string |
| `KEY` | String | ✓ | Key of the array |
| `OUT_VAR` | Variable | ✓ | Output: array length (0 if missing) |

**Returns:** Array length, or 0 if the key is missing / not an array

**Example:**

```cmake
_json_array_length("${_json}" "externals" _count)
if(_count GREATER 0)
    # Process the array
endif()
```

---

### 3.7 _json_array_get()

Reads an element from a JSON array.

```cmake
_json_array_get(<JSON_STRING> <KEY> <INDEX> <OUT_VAR>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `JSON_STRING` | String | ✓ | JSON object as string |
| `KEY` | String | ✓ | Key of the array |
| `INDEX` | Int | ✓ | 0-based index |
| `OUT_VAR` | Variable | ✓ | Output: element value or "" |

**Returns:** Element value, or empty string on error

**Example:**

```cmake
_json_array_length("${_json}" "items" _count)
math(EXPR _last "${_count} - 1")
foreach(_idx RANGE 0 ${_last})
    _json_array_get("${_json}" "items" ${_idx} _item)
    message(STATUS "Item: ${_item}")
endforeach()
```

---

### 3.8 _json_get_array_as_list()

Reads a JSON array and returns it as a CMake list.

```cmake
_json_get_array_as_list(<JSON_STRING> <KEY> <OUT_VAR>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `JSON_STRING` | String | ✓ | JSON object as string |
| `KEY` | String | ✓ | Key of the array |
| `OUT_VAR` | Variable | ✓ | Output: CMake list (semicolon-separated) or "" |

**Returns:** CMake list, or empty string if the key is missing or the array is empty

**Example:**

```cmake
# JSON: { "dependencies": ["LibA", "LibB", "LibC"] }
_json_get_array_as_list("${_json}" "dependencies" _deps)
# _deps = "LibA;LibB;LibC"

foreach(_dep IN LISTS _deps)
    message(STATUS "Dependency: ${_dep}")
endforeach()
```

**Comparison with manual iteration:**

```cmake
# Old (manual):
_json_array_length("${_json}" "items" _count)
set(_items "")
if(_count GREATER 0)
    math(EXPR _last "${_count} - 1")
    foreach(_i RANGE 0 ${_last})
        _json_array_get("${_json}" "items" ${_i} _item)
        list(APPEND _items "${_item}")
    endforeach()
endif()

# New (with _json_get_array_as_list):
_json_get_array_as_list("${_json}" "items" _items)
```

---

### 3.9 _json_get_object()

Extracts a nested JSON object as a string.

```cmake
_json_get_object(<JSON_STRING> <KEY> <OUT_VAR>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `JSON_STRING` | String | ✓ | JSON object as string |
| `KEY` | String | ✓ | Key of the object |
| `OUT_VAR` | Variable | ✓ | Output: JSON string of the object or "" |

**Returns:** JSON string of the nested object, or empty string

**Example:**

```cmake
_json_get_object("${_json}" "settings" _settings)
_json_get_string("${_settings}" "cxx_standard" _std)
```

---

### 3.10 _json_get_object_or_empty()

Like `_json_get_object`, but returns "{}" if the key is missing.

```cmake
_json_get_object_or_empty(<JSON_STRING> <KEY> <OUT_VAR>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `JSON_STRING` | String | ✓ | JSON object as string |
| `KEY` | String | ✓ | Key of the object |
| `OUT_VAR` | Variable | ✓ | Output: JSON string or "{}" |

**Returns:** JSON string or "{}" — allows safe further processing

**Example:**

```cmake
_json_get_object_or_empty("${_json}" "options" _options)
# _options is at least "{}", never empty
_json_get_string_or_default("${_options}" "key" "default" _val)
```

---

### 3.11 _json_get_type()

Determines the JSON type of a value.

```cmake
_json_get_type(<JSON_STRING> <KEY> <OUT_VAR>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `JSON_STRING` | String | ✓ | JSON object as string |
| `KEY` | String | ✓ | Key |
| `OUT_VAR` | Variable | ✓ | Output: type string |

**Possible return values:**

| Value | Meaning |
|-------|---------|
| `NULL` | null |
| `BOOLEAN` | true/false |
| `NUMBER` | Numeric |
| `STRING` | String |
| `ARRAY` | Array [...] |
| `OBJECT` | Object {...} |
| `""` | Key does not exist |

**Example:**

```cmake
_json_get_type("${_json}" "version" _vtype)
if("${_vtype}" STREQUAL "STRING")
    _json_get_string("${_json}" "version" _ver)
elseif("${_vtype}" STREQUAL "OBJECT")
    _json_get_object("${_json}" "version" _vobj)
endif()
```

---

### 3.12 _json_get_number()

Reads a numeric value.

```cmake
_json_get_number(<JSON_STRING> <KEY> <OUT_VAR>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `JSON_STRING` | String | ✓ | JSON object as string |
| `KEY` | String | ✓ | Key |
| `OUT_VAR` | Variable | ✓ | Output: numeric value or "" |

**Example:**

```cmake
_json_get_number("${_json}" "timeout" _timeout)
if(NOT "${_timeout}" STREQUAL "")
    message("Timeout: ${_timeout}s")
endif()
```

---

### 3.13 _json_get_number_or_default()

Reads a numeric value with fallback.

```cmake
_json_get_number_or_default(<JSON_STRING> <KEY> <DEFAULT> <OUT_VAR>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `JSON_STRING` | String | ✓ | JSON object as string |
| `KEY` | String | ✓ | Key |
| `DEFAULT` | Number | ✓ | Fallback value |
| `OUT_VAR` | Variable | ✓ | Output: numeric value or default |

**Example:**

```cmake
# Test timeout with default 30 seconds
_json_get_number_or_default("${_json}" "timeout" 30 _timeout)
message("Timeout: ${_timeout}s")
```

---

## 4. Usage Examples

### 4.1 Parsing Solution.json

```cmake
# Load the JSON
file(READ "${CMAKE_SOURCE_DIR}/Solution.json" _json)

# Read required fields
_json_get_string("${_json}" "schemaVersion" _schema)
_json_get_object("${_json}" "solution" _solution)
_json_get_string("${_solution}" "name" _name)

# Optional fields with defaults
_json_get_string_or_default("${_solution}" "version" "0.0.0" _version)
```

### 4.2 Iterating the Executables Array

```cmake
_json_get_object("${_json}" "solution" _solution)
_json_array_length("${_solution}" "executables" _exe_count)

if(_exe_count GREATER 0)
    math(EXPR _last "${_exe_count} - 1")
    foreach(_idx RANGE 0 ${_last})
        _json_array_get("${_solution}" "executables" ${_idx} _exe_json)
        _json_get_string("${_exe_json}" "name" _name)
        _json_get_bool_from_key("${_exe_json}" "skip" _skip)
        
        if(NOT _skip)
            # Process the executable
        endif()
    endforeach()
endif()
```

### 4.3 Test Configuration with Defaults

```cmake
# Test JSON: { "name": "UnitTests", "type": "unit", "timeout": 60 }
_json_get_string("${_test_json}" "name" _name)
_json_get_string("${_test_json}" "type" _type)

# Optional with default
_json_get_number_or_default("${_test_json}" "timeout" 30 _timeout)
_json_get_bool_or_default("${_test_json}" "skip" FALSE _skip)
_json_get_bool_or_default("${_test_json}" "parallel" TRUE _parallel)

# Labels as a list
_json_get_array_as_list("${_test_json}" "labels" _labels)
if("${_labels}" STREQUAL "")
    set(_labels "${_type}")  # Default: type as label
endif()
```

---

## 5. Return Values and Error Handling

### 5.1 Fault-Tolerant Design

All functions return sensible defaults on errors:

| Function | On error |
|----------|----------|
| `_json_has_key` | FALSE |
| `_json_get_string` | "" |
| `_json_get_string_or_default` | DEFAULT |
| `_json_get_bool_from_key` | FALSE |
| `_json_get_bool_or_default` | DEFAULT |
| `_json_get_number` | "" |
| `_json_get_number_or_default` | DEFAULT |
| `_json_array_length` | 0 |
| `_json_array_get` | "" |
| `_json_get_array_as_list` | "" |
| `_json_get_object` | "" |
| `_json_get_object_or_empty` | "{}" |
| `_json_get_type` | "" |

### 5.2 No Exceptions

The module raises no errors. Required fields are validated by the calling modules (e.g. Validation.cmake with cmake_fatal).

---

## 6. Best Practices

### 6.1 Always Check Key Existence for Critical Fields

```cmake
# ✅ Good - explicit check
_json_has_key("${_json}" "name" _has_name)
if(NOT _has_name)
    cmake_fatal("E001" "Required field 'name' missing")
endif()
_json_get_string("${_json}" "name" _name)

# ❌ Bad - no check
_json_get_string("${_json}" "name" _name)
# _name could be empty!
```

### 6.2 _or_default for Optional Fields

```cmake
# ✅ Good - default value
_json_get_string_or_default("${_json}" "type" "CONSOLE" _type)
_json_get_bool_or_default("${_json}" "skip" FALSE _skip)

# ❌ Bad - manual check
_json_get_string("${_json}" "type" _type)
if("${_type}" STREQUAL "")
    set(_type "CONSOLE")
endif()
```

### 6.3 Check the Type for Polymorphic Fields

```cmake
_json_get_type("${_json}" "version" _type)
if("${_type}" STREQUAL "STRING")
    # Simple version: "1.0.0"
elseif("${_type}" STREQUAL "OBJECT")
    # Complex version: { "major": 1, "minor": 0 }
endif()
```

### 6.4 _json_get_array_as_list for Lists

```cmake
# ✅ Good - compact with _json_get_array_as_list
_json_get_array_as_list("${_json}" "dependencies" _deps)
foreach(_dep IN LISTS _deps)
    target_link_libraries(${_target} PRIVATE ${_dep})
endforeach()

# ❌ Cumbersome - manual iteration
_json_array_length("${_json}" "dependencies" _count)
if(_count GREATER 0)
    math(EXPR _last "${_count} - 1")
    foreach(_i RANGE 0 ${_last})
        _json_array_get("${_json}" "dependencies" ${_i} _dep)
        target_link_libraries(${_target} PRIVATE ${_dep})
    endforeach()
endif()
```

---

## 7. See Also

- [Validation.cmake](Validation.md) — schema validation with Json.cmake
- [Solution.cmake](../project/Solution.md) — main user of Json.cmake
- [TestCollect.cmake](../project/TestCollect.md) — uses _json_get_bool_or_default, _json_get_array_as_list
- [CMake string(JSON)](https://cmake.org/cmake/help/latest/command/string.html#json) — CMake documentation

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.6.0 | 2025-12-18 | New: _json_get_bool_or_default() for booleans with default, _json_get_array_as_list() for array→list conversion. Centralization of all JSON helpers (previously partly duplicated in TestCollect.cmake) |
| 0.5.1 | 2025-12-17 | New: _json_get_number(), _json_get_number_or_default() for numeric values |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0: new header with target audience/language/English link/module link, numbered table of contents with anchors, chapter numbering |
| 0.1.1 | 2025-12-05 | English translation (Language Standards v0.1.1) |
| 0.1.0 | 2025-12-03 | Initial (clean start): _json_has_key, _json_get_string, _json_get_string_or_default, _json_get_bool_from_key, _json_array_length, _json_array_get, _json_get_object, _json_get_object_or_empty, _json_get_type |
