# Context.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** In development (pre-release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [Context.md](../../../../de/guide/module/core/Context.md)  
> **Module:** [`cmake/core/Context.cmake`](../../../../../cmake/core/Context.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Concept](#3-concept)
4. [API Reference](#4-api-reference)
5. [Usage Examples](#5-usage-examples)
6. [Standard Context Keys](#6-standard-context-keys)
7. [Error Handling](#7-error-handling)
8. [Best Practices](#8-best-practices)
9. [Debugging](#9-debugging)
10. [Known Limitations](#10-known-limitations)
11. [See Also](#11-see-also)
12. [Changelog](#changelog)

---

## 1. Overview

The `Context.cmake` module implements a **context object pattern** for isolated namespaces. It allows clean management of target data during the CMake configuration without global variables.

### Core Idea

Instead of global variables, each executable/library uses its own namespace with a unique prefix.

### Responsibilities

| Area | Description |
|------|-------------|
| Namespaces | Isolated data per target |
| Propagation | Values available across all function levels |
| Debugging | `ctx_dump()` for diagnosis |

### Used By

- ExecutableCollect.cmake
- LibraryCollect.cmake
- TestCollect.cmake

---

## 2. Dependencies

| Module | Version | Usage |
|--------|---------|-------|
| — | — | None (base module) |

**Design decision:** Context.cmake is deliberately implemented without dependencies on Debug.cmake or Errors.cmake. As a fundamental base module used by other modules (incl. Debug.cmake indirectly), this avoids circular dependencies. Incorrect use leads to empty return values instead of exceptions.

→ See [Open clarifications](../../../konzepte/abgeschlossen/Offene_Abklaerungen_Core_Module.md) for details on this decision.

---

## 3. Concept

### 3.1 Why Context Objects?

**Problem with global variables:**
```cmake
# Bad: global variables
set(EXE_NAME "App1")
set(EXE_PATH "src/app1")
# ... overwritten later ...
set(EXE_NAME "App2")  # App1 data lost!
```

**Solution with context:**
```cmake
# Good: isolated namespaces
ctx_create(EXE_0)
ctx_set(EXE_0 NAME "App1")
ctx_set(EXE_0 PATH "src/app1")

ctx_create(EXE_1)
ctx_set(EXE_1 NAME "App2")
ctx_set(EXE_1 PATH "src/app2")

# Both exist in parallel
ctx_get(EXE_0 NAME _name)  # "App1"
ctx_get(EXE_1 NAME _name)  # "App2"
```

### 3.2 GLOBAL PROPERTY Implementation

The context uses **GLOBAL PROPERTY** for storage, not `PARENT_SCOPE`. This has important advantages:

| Method | Scope propagation | Problem |
|--------|-------------------|---------|
| `PARENT_SCOPE` | One level up | Nested functions lose values |
| `GLOBAL PROPERTY` | Available everywhere | ✅ Works across all scopes |

**Example of the problem with PARENT_SCOPE:**
```cmake
function(outer)
    function(inner)
        set(VAR "value" PARENT_SCOPE)  # Only reaches outer()
    endfunction()
    inner()
    # VAR is set here
endfunction()
outer()
# VAR is NOT set here!
```

**With GLOBAL PROPERTY:**
```cmake
function(outer)
    function(inner)
        set_property(GLOBAL PROPERTY MY_VAR "value")
    endfunction()
    inner()
endfunction()
outer()
get_property(_val GLOBAL PROPERTY MY_VAR)  # "value" ✅
```

### 3.3 Context Prefix Convention

| Prefix | Usage |
|--------|-------|
| `EXE_` | Executables (`EXE_0`, `EXE_1`, `EXE_MyApp`) |
| `LIB_` | Libraries (`LIB_0`, `LIB_CoreLib`) |
| `TEST_` | Tests (`TEST_0`, `TEST_UnitTests`) |

---

## 4. API Reference

### 4.1 ctx_create()

Creates a new context with the given prefix.

```cmake
ctx_create(<PREFIX>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `PREFIX` | String | ✓ | Unique namespace identifier |

**Returns:** Nothing (initializes the GLOBAL PROPERTY `${PREFIX}_KEYS`)

**Example:**

```cmake
ctx_create(EXE_MyApp)
ctx_create(LIB_CoreLib)
ctx_create(TEST_UnitTests)
```

---

### 4.2 ctx_set()

Sets a value in the context.

```cmake
ctx_set(<PREFIX> <KEY> <VALUE>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `PREFIX` | String | ✓ | Context prefix |
| `KEY` | String | ✓ | Key (UPPER_SNAKE_CASE recommended) |
| `VALUE` | String/List | ✓ | Value to store |

**Returns:** Nothing (stores as GLOBAL PROPERTY `${PREFIX}_${KEY}`)

**Example:**

```cmake
ctx_set(EXE_MyApp NAME "MyApp")
ctx_set(EXE_MyApp VERSION "1.0.0")
ctx_set(EXE_MyApp EXTERNALS "bass;imgui;glfw")
```

---

### 4.3 ctx_get()

Reads a value from the context.

```cmake
ctx_get(<PREFIX> <KEY> <OUT_VAR>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `PREFIX` | String | ✓ | Context prefix |
| `KEY` | String | ✓ | Key |
| `OUT_VAR` | Variable | ✓ | Variable for the return value |

**Returns:** Value in `OUT_VAR` (empty string if the key does not exist)

**Example:**

```cmake
ctx_get(EXE_MyApp NAME _name)
ctx_get(EXE_MyApp VERSION _version)
ctx_get(EXE_MyApp EXTERNALS _externals)

message(STATUS "Name: ${_name}")        # MyApp
message(STATUS "Version: ${_version}")  # 1.0.0

foreach(_ext IN LISTS _externals)
    message(STATUS "External: ${_ext}")
endforeach()
```

---

### 4.4 ctx_dump()

Debug output of all keys in the context. Only active if `DEBUG_CONTEXT=ON`.

```cmake
ctx_dump(<PREFIX>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `PREFIX` | String | ✓ | Context prefix |

**Returns:** Nothing (prints to stdout if `DEBUG_CONTEXT=ON`)

**Activation:**

```bash
cmake -B build -DDEBUG_CONTEXT=ON
```

**Example:**

```cmake
ctx_dump(EXE_MyApp)
```

**Output:**

```
-- === Context Dump: EXE_MyApp ===
--   NAME = MyApp
--   VERSION = 1.0.0
--   TYPE = GUI
--   EXTERNALS = bass;imgui;glfw
-- === End Context: EXE_MyApp ===
```

---

## 5. Usage Examples

### 5.1 Executable Pipeline

```cmake
# In ExecutableCollect.cmake
function(_collect_executable EXE_JSON CTX)
    # Extract JSON data
    _json_get_string("${EXE_JSON}" "name" _name)
    _json_get_string("${EXE_JSON}" "path" _path)
    _json_get_bool_from_key("${EXE_JSON}" "skip" _skip)
    
    # Store in the context
    ctx_set(${CTX} NAME "${_name}")
    ctx_set(${CTX} PATH "${_path}")
    ctx_set(${CTX} SKIP "${_skip}")
endfunction()

# In Executables.cmake
foreach(_idx RANGE 0 ${_exe_count})
    ctx_create(EXE_${_idx})
    _collect_executable("${_exe_json}" EXE_${_idx})
    
    # Values are available immediately (thanks to GLOBAL PROPERTY)
    ctx_get(EXE_${_idx} NAME _name)
    ctx_get(EXE_${_idx} SKIP _skip)
    
    if(_skip)
        continue()
    endif()
    
    _create_executable_target(EXE_${_idx})
endforeach()
```

### 5.2 Several Contexts in Parallel

```cmake
# Both contexts exist independently
ctx_create(EXE_Editor)
ctx_set(EXE_Editor NAME "Editor")
ctx_set(EXE_Editor TYPE "GUI")

ctx_create(EXE_CLI)
ctx_set(EXE_CLI NAME "CLI")
ctx_set(EXE_CLI TYPE "CONSOLE")

# Values do not overwrite each other
ctx_get(EXE_Editor TYPE _type1)  # "GUI"
ctx_get(EXE_CLI TYPE _type2)     # "CONSOLE"
```

---

## 6. Standard Context Keys

### 6.1 For Executables

| Key | Type | Description |
|-----|------|-------------|
| `NAME` | String | Target name |
| `DISPLAY_NAME` | String | Display name |
| `DESCRIPTION` | String | Description |
| `VERSION` | String | Version (SemVer) |
| `PATH` | String | Source directory (relative) |
| `TYPE` | String | GUI, CONSOLE, CLI, HEADLESS, WORKER |
| `SKIP` | Boolean | true = skip |
| `PCH_ENABLED` | Boolean | Precompiled header enabled |
| `PCH_HEADER` | String | PCH header file |
| `DEPENDENCIES` | List | Internal dependencies |
| `EXTERNALS` | List | External dependencies |
| `DEFINES` | List | Preprocessor definitions |
| `COMPILE_OPTIONS` | List | Compiler options |
| `LINK_OPTIONS` | List | Linker options |
| `PLATFORMS` | List | Target platforms |

### 6.2 For Libraries

| Key | Type | Description |
|-----|------|-------------|
| `NAME` | String | Target name |
| `TYPE` | String | STATIC, SHARED, INTERFACE, OBJECT |
| `PUBLIC_HEADERS` | List | Public headers |
| `PRIVATE_HEADERS` | List | Private headers |
| `ALIAS` | String | Namespace alias (e.g. `MyProject::Core`) |
| ... | ... | (as for executables) |

---

## 7. Error Handling

The context module itself raises no specific error codes. Incorrect use leads to:

| Situation | Behavior |
|-----------|----------|
| `ctx_get` without `ctx_create` | Empty string |
| Key does not exist | Empty string |
| Wrong PREFIX | Empty string (silent errors) |

**Recommendation:** Check critical keys explicitly:

```cmake
ctx_get(${CTX} NAME _name)
if("${_name}" STREQUAL "")
    cmake_fatal("E001" "Context ${CTX}: NAME missing")
endif()
```

---

## 8. Best Practices

| Do | Don't |
|----|-------|
| `ctx_create()` before the first `ctx_set()` | Set directly without create |
| UPPER_SNAKE_CASE for keys | lowercase-keys |
| Unique prefixes (EXE_, LIB_, TEST_) | Generic prefixes |
| Lists separated by semicolons | Space-separated lists |
| `DEBUG_CONTEXT` for troubleshooting | Manual property queries |

### Design Decision: Minimal API

| Function | Status | Reason |
|----------|--------|--------|
| `ctx_create` | ✅ | Basic function |
| `ctx_set` | ✅ | Basic function |
| `ctx_get` | ✅ | Basic function |
| `ctx_dump` | ✅ | Debug only, very useful |
| `ctx_has` | ❌ | `ctx_get` + `if(DEFINED)` is enough |
| `ctx_append` | ❌ | `ctx_get` + `list(APPEND)` + `ctx_set` explicitly |

---

## 9. Debugging

### 9.1 Value Is Empty

**Problem:** `ctx_get()` returns an empty string.

**Possible causes:**

1. `ctx_set()` was never called
2. Wrong PREFIX or KEY
3. Typo in the key name

**Solution:**

```bash
cmake -B build -DDEBUG_CONTEXT=ON
```

```cmake
ctx_dump(EXE_MyApp)
```

### 9.2 Values Are Not Propagated

**Problem:** Values are not available in the calling function.

**Cause:** Old module with PARENT_SCOPE instead of GLOBAL PROPERTY.

**Solution:** Update the module to v0.1.0+.

---

## 10. Known Limitations

| Limitation | Description |
|------------|-------------|
| No typing | All values are strings |
| No deletion | Keys cannot be removed (not needed) |
| Global namespace | Prefixes must be unique |

---

## 11. See Also

- [Errors.cmake](Errors.md) — error handling
- [Debug.cmake](Debug.md) — debug system
- [ExecutableCollect.cmake](../project/ExecutableCollect.md) — uses Context
- [LibraryCollect.cmake](../project/LibraryCollect.md) — uses Context
- [guidelines](../../../konzepte/Guidelines.md) — coding conventions

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0: new header with target audience/language/English link/module link, numbered table of contents with anchors, chapter numbering, section Standard Context Keys |
| 0.1.1 | 2025-12-05 | English translation (Language Standards v0.1.1) |
| 0.1.0 | 2025-12-03 | Initial (clean start): GLOBAL PROPERTY instead of PARENT_SCOPE, ctx_create/set/get/dump API |
