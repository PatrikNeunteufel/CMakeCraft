# Errors.cmake — Module Documentation

> **Version:** 1.0.2  
> **Date:** 2026-11-09  
> **Type:** ModuleDoc  
> **Status:** In development (pre-release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5, ErrorCodes v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [Errors.md](../../../../de/guide/module/core/Errors.md)  
> **Module:** [`cmake/core/Errors.cmake`](../../../../../cmake/core/Errors.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Concept](#3-concept)
4. [API Reference](#4-api-reference)
5. [Usage Examples](#5-usage-examples)
6. [Error Code Categories](#6-error-code-categories)
7. [Best Practices](#7-best-practices)
8. [See Also](#8-see-also)
9. [Changelog](#changelog)

---

## 1. Overview

The `Errors.cmake` module provides **uniform error handling** for the entire build system. It defines standardized functions for fatal errors, warnings and assertions.

### Core Idea

All errors use standardized codes (E0xx, W0xx, etc.) for consistent, traceable error messages.

### Responsibilities

| Area | Description |
|------|-------------|
| Fatal errors | Abort the build with a code |
| Warnings | Notes without abort |
| Assertions | Internal consistency checks |
| Field validation | Check required context fields |

### Used By

- All modules for error handling
- CompilerOptions.cmake (W201)
- SourceCollect.cmake (E104, W110)
- Validation.cmake (E001, E002)
- And many more...

---

## 2. Dependencies

| Module | Version | Usage |
|--------|---------|-------|
| — | — | None (base module, must be loaded first) |

**Note:** `cmake_require_field()` needs `Context.cmake` (ctx_get), but Context.cmake must be loaded after Errors.cmake.

---

## 3. Concept

### 3.1 Error vs. Warning vs. Assertion

| Function | Behavior | Usage |
|----------|----------|-------|
| `cmake_fatal()` | Aborts the build | User errors, missing required fields |
| `cmake_warn()` | Build continues | Deprecated, suboptimal config |
| `cmake_assert()` | Aborts if false | Internal consistency checks |

### 3.2 Error Code Format

```
[E|W][K][NN]

E = Error (build aborts)
W = Warning (build continues)
K = Category (1 digit)
NN = Number (2 digits)
```

---

## 4. API Reference

### 4.1 cmake_fatal()

Aborts the build with an error code.

```cmake
cmake_fatal(<CODE> <MESSAGE>...)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `CODE` | String | ✓ | Error code (e.g. `E001`, `E012`) |
| `MESSAGE...` | String(s) | ✓ | Error description; several parts are joined without separator |

**Multi-part messages** (since module 1.1.0, CMakeCraft v0.14.1): all arguments after `CODE`
are joined without separator, so a long message can be written as several quoted lines. The
function reads `ARGV1` … `ARGV<n-1>` instead of `ARGN`, so that a part containing a semicolon
(e.g. `path;git`) stays intact (`cmake/core/Errors.cmake:65–69`, `:145–152`). Up to module
0.1.5 only the first part arrived; E012, E502, E220, E503 and W501 were affected.

**Returns:** Nothing (aborts the build)

**Output:**
```
CMake Error at cmake/core/Errors.cmake:XX (message):
  [E001] Executable 'MyApp': required field 'name' missing
```

**Example:**

```cmake
cmake_fatal("E001" "Executable 'MyApp': required field 'name' missing")
cmake_fatal("E002" "Solution.json not found: ${CMAKE_SOURCE_DIR}/Solution.json")
cmake_fatal("E012" "External 'imgui': no source field (path/git) given")

# Multi-part: yields one message over two lines
cmake_fatal("E012" "External 'mylib': Multiple source fields specified: path;git\n"
                   "  Only one source field is allowed.")
```

---

### 4.2 cmake_warn()

Outputs a warning; the build continues.

```cmake
cmake_warn(<CODE> <MESSAGE>...)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `CODE` | String | ✓ | Warning code (e.g. `W001`, `W201`) |
| `MESSAGE...` | String(s) | ✓ | Warning description; parts joined as with `cmake_fatal()` (`cmake/core/Errors.cmake:212–219`) |

**Returns:** Nothing (outputs a warning)

**Output:**
```
CMake Warning at cmake/core/Errors.cmake:XX (message):
  [W001] Schema version < 0.1, features limited
```

**Example:**

```cmake
cmake_warn("W001" "Schema version < 0.1, features limited")
cmake_warn("W201" "ENABLE_CLANG_TIDY=ON but clang-tidy not found")
cmake_warn("W302" "External 'glfw': Version mismatch but offline mode - using cached")
```

---

### 4.3 cmake_assert()

Checks a condition and aborts if it is false.

```cmake
cmake_assert(<CONDITION> <MESSAGE>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `CONDITION` | CMake condition | ✓ | Checked with `if(NOT ...)` |
| `MESSAGE` | String | ✓ | Error description on failure |

**Returns:** Nothing (aborts if the condition is false)

**Note:** This is a `macro()`, not a `function()`, so that CONDITION is evaluated correctly.

**Example:**

```cmake
cmake_assert(DEFINED _var "Variable must be defined")
cmake_assert(_count GREATER 0 "Count must be > 0")
cmake_assert("${_type}" STREQUAL "GUI" "Unexpected type")
```

---

### 4.4 cmake_require_field()

Validates that a field is set in a context.

```cmake
cmake_require_field(<CTX> <FIELD_NAME> <ENTITY_TYPE>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `CTX` | String | ✓ | Context prefix (e.g. `EXE_0`) |
| `FIELD_NAME` | String | ✓ | Name of the field to check |
| `ENTITY_TYPE` | String | ✓ | Type for the error message (e.g. "Executable") |

**Returns:** Nothing (aborts if the field is missing)

**Dependency:** Needs `Context.cmake` (ctx_get).

**Errors:**

| Code | Condition |
|------|-----------|
| E001 | Field missing or empty |

**Example:**

```cmake
ctx_create(EXE_0)
ctx_set(EXE_0 NAME "MyApp")
# ctx_set(EXE_0 PATH "...")  # missing!

cmake_require_field(EXE_0 PATH "Executable")
# → [E001] Executable 'MyApp' has no 'PATH' field
```

---

## 5. Usage Examples

### 5.1 Required Field Validation

```cmake
function(_collect_executable EXE_JSON CTX)
    _json_get_string("${EXE_JSON}" "name" _name)
    
    if("${_name}" STREQUAL "")
        cmake_fatal("E001" "Executable: required field 'name' missing")
    endif()
    
    ctx_set(${CTX} NAME "${_name}")
endfunction()
```

### 5.2 External Validation

```cmake
function(validate_external EXT_NAME EXT_JSON)
    _json_has_key("${EXT_JSON}" "path" _has_path)
    _json_has_key("${EXT_JSON}" "git" _has_git)
    
    if(NOT _has_path AND NOT _has_git)
        cmake_fatal("E012" "External '${EXT_NAME}': no source field")
    endif()
endfunction()
```

### 5.3 Checking the Schema Version

```cmake
_json_get_string("${_json}" "schemaVersion" _version)

if(NOT "${_version}" VERSION_GREATER_EQUAL "0.1")
    cmake_warn("W001" "Schema version ${_version} < 0.1")
endif()
```

### 5.4 Internal Assertions

```cmake
function(_internal_process DATA)
    # Check internal consistency
    cmake_assert(DEFINED DATA "DATA must be passed")
    cmake_assert(NOT "${DATA}" STREQUAL "" "DATA must not be empty")
    
    # ... processing ...
endfunction()
```

---

## 6. Error Code Categories

### 6.1 Fatal Errors (E)

| Range | Codes | Description |
|-------|-------|-------------|
| JSON/parsing | `E0xx` | Missing required fields, invalid JSON |
| Target creation | `E1xx` | Target exists, dependency missing |
| Externals | `E2xx` | Fetch failed, Include.cmake missing |
| Tests | `E3xx` | Framework, source errors |
| AppContainer | `E4xx` | App structure, directories |
| System Externals | `E5xx` | find_package, components |

### 6.2 Warnings (W)

| Range | Codes | Description |
|-------|-------|-------------|
| Deprecation | `W0xx` | Outdated features/syntax |
| Config/validation | `W1xx` | Suboptimal settings |
| Tools/setup | `W2xx` | Missing tools |
| External caching | `W3xx` | Offline mode, hook reuse |
| AppContainer | `W4xx` | Optional directories |
| System Externals | `W5xx` | Backup usage |

→ Complete reference: [ErrorCodes.md](../../references/ErrorCodes.md)

### 6.3 Codes Documented Since Module v0.1.4

| Code | Description | Raised in |
|------|-------------|-----------|
| `E220` | Archive external: field `pin` missing | `externals/archive/Handler.cmake` |
| `W112` | Package names a target that does not exist | `project/Packages.cmake` |
| `W304` | Archive external not available — targets build without it | `externals/archive/Handler.cmake` |

### 6.4 Catalog Since Module 1.1.0

The header comment of the functions additionally names the ranges E3xx (tests), E4xx (apps),
E5xx (system externals), W4xx (apps) and W5xx (system externals) (`cmake/core/Errors.cmake:117–138`,
`:199–205`). The system handler raises E504 and E505 since CMakeCraft v0.14.1; E501 and W502
are dropped. Codes that nothing raises are marked there as "currently not raised": E103,
E217, W001, W002, W105–W108, W301 (`Errors.cmake:97`, `:110`, `:168–171`, `:179–183`, `:193`).

---

## 7. Best Practices

### 7.1 Always Use an Error Code

```cmake
# ✅ Good
cmake_fatal("E012" "External 'foo': no source field")

# ❌ Bad
message(FATAL_ERROR "External 'foo': no source field")
```

### 7.2 Meaningful Error Messages

```cmake
# ✅ Good - contains context
cmake_fatal("E001" "Executable 'MyApp': required field 'path' missing")

# ❌ Bad - no context
cmake_fatal("E001" "Required field missing")
```

### 7.3 Assertions Only for Internal Checks

```cmake
# ✅ For internal consistency
cmake_assert(DEFINED _internal "Internal error")

# ❌ Not for user errors
cmake_assert(_user_input "...")  # → use cmake_fatal!
```

### 7.4 Validate Early

```cmake
function(process_target NAME PATH)
    # ✅ Validation at the start
    if("${NAME}" STREQUAL "")
        cmake_fatal("E001" "NAME is required")
    endif()
    
    # Only then processing...
endfunction()
```

---

## 8. See Also

- [ErrorCodes.md](../../references/ErrorCodes.md) — complete error code reference
- [Debug.cmake](Debug.md) — for debug output (not errors)
- [Context.cmake](Context.md) — for cmake_require_field()
- [guidelines](../../../konzepte/Guidelines.md) — error handling conventions

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.2** | **2026-11-09** | **`cmake_fatal`/`cmake_warn` with several message parts (`<MESSAGE>...`, module 1.1.0, CMakeCraft v0.14.1); §6.4 catalog: E3xx–E5xx, W4xx, W5xx, E504/E505 raised, E501/W502 dropped, never-raised codes marked** |
| **1.0.1** | **2026-10-09** | **CMakeCraft v0.10.0: E220, W112, W304 documented (module v0.1.4)** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0: new header with target audience/language/English link/module link, numbered table of contents with anchors, chapter numbering |
| 0.1.2 | 2025-12-09 | W3xx range for externals, E218, W302 documented |
| 0.1.1 | 2025-12-05 | English translation (Language Standards v0.1.1) |
| 0.1.0 | 2025-12-03 | Initial (clean start): cmake_fatal/cmake_warn/cmake_assert/cmake_require_field API |
