# SourceCollect.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** In development (pre-release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [SourceCollect.md](../../../../de/guide/module/core/SourceCollect.md)  
> **Module:** [`cmake/core/SourceCollect.cmake`](../../../../../cmake/core/SourceCollect.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Concept](#3-concept)
4. [API Reference](#4-api-reference)
5. [Source.cmake Format](#5-sourcecmake-format)
6. [Usage Examples](#6-usage-examples)
7. [Error Handling](#7-error-handling)
8. [Best Practices](#8-best-practices)
9. [See Also](#9-see-also)
10. [Changelog](#changelog)

---

## 1. Overview

The `SourceCollect.cmake` module manages **source files** for executables, libraries and tests. It supports explicit declaration via Source.cmake as well as GLOB as a fallback.

### Core Idea

Explicit source control as the default, with flexible modes for different use cases.

### Responsibilities

| Area | Description |
|------|-------------|
| Collection | Sources, headers, templates, modules |
| Modes | explicit, glob, auto |
| Categories | Compilable, headers, extras, C++20 modules |
| Include paths | Automatic + from Source.cmake |

### Used By

- ExecutableCreate.cmake
- LibraryCreate.cmake
- TestCreate.cmake

---

## 2. Dependencies

| Module | Version | Usage |
|--------|---------|-------|
| Errors.cmake | 0.1.2 | `cmake_fatal`, `cmake_warn` |
| Debug.cmake | 0.1.1 | `dbg` |

---

## 3. Concept

### 3.1 Source Modes

| Mode | Description | Recommended |
|------|-------------|-------------|
| `explicit` | Source.cmake required (default) | ✅ Yes |
| `glob` | Automatic collection via wildcard | ⚠️ Only for prototypes |
| `auto` | Source.cmake if present, otherwise GLOB | ⚪ Transition |

> With `auto`: Source.cmake is used if present **and non-empty**. With an empty Source.cmake → fallback to GLOB with W111 + W110.

### 3.2 File Categories

| Category | Variable suffix | Extensions | Description |
|----------|-----------------|------------|-------------|
| Sources | `_SOURCES` | .cpp, .cxx, .cc, .c | Compilable files |
| Headers | `_HEADERS` | .h, .hpp, .hxx, .hh | Declarations |
| Templates | `_TEMPLATES` | .tpp, .txx, .ipp | Template implementations |
| Inlines | `_INLINES` | .inl | Inline implementations |
| Impl | `_IMPL` | .impl | PIMPL details |
| Modules | `_MODULES` | .ixx, .cppm, .mpp | C++20 modules (experimental) |

### 3.3 Processing Flow

```
collect_sources()
    │
    ├── Mode = explicit?
    │   └── _collect_sources_from_cmake()
    │       └── include(Source.cmake)
    │
    ├── Mode = glob?
    │   └── _collect_sources_glob()
    │       └── file(GLOB_RECURSE ...)
    │
    └── Mode = auto?
        ├── Source.cmake present? → _collect_sources_from_cmake()
        └── Not present? → _collect_sources_glob()
```

---

## 4. API Reference

### 4.1 collect_sources()

Main entry point for source collection.

```cmake
collect_sources(<TARGET_NAME> <SOURCE_DIR> 
                <OUT_SOURCES> <OUT_HEADERS> <OUT_EXTRAS> <OUT_MODULES> <OUT_INCLUDES>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `TARGET_NAME` | String | ✓ | Name of the target |
| `SOURCE_DIR` | Path | ✓ | Source directory |
| `OUT_SOURCES` | Variable | ✓ | Output: compilable files |
| `OUT_HEADERS` | Variable | ✓ | Output: header files |
| `OUT_EXTRAS` | Variable | ✓ | Output: templates + inlines + impl |
| `OUT_MODULES` | Variable | ✓ | Output: C++20 module units |
| `OUT_INCLUDES` | Variable | ✓ | Output: include paths |

**Example:**

```cmake
collect_sources(MyApp "${_source_dir}" 
    _sources _headers _extras _modules _includes)
```

---

### 4.2 _collect_sources_from_cmake()

Loads Source.cmake and collects all defined files.

```cmake
_collect_sources_from_cmake(<TARGET_NAME> <SOURCE_DIR>
                            <OUT_SOURCES> <OUT_HEADERS> <OUT_EXTRAS> <OUT_MODULES> <OUT_INCLUDES>)
```

**Errors:**

| Code | Condition |
|------|-----------|
| E104 | Source.cmake not found |

**Warnings:**

| Code | Condition |
|------|-----------|
| W101 | No compilable files defined |
| W109 | C++20 modules used |

---

### 4.3 _collect_sources_glob()

GLOB-based collection (fallback).

```cmake
_collect_sources_glob(<SOURCE_DIR>
                      <OUT_SOURCES> <OUT_HEADERS> <OUT_EXTRAS> <OUT_MODULES>)
```

**Warnings:**

| Code | Condition |
|------|-----------|
| W101 | Source.cmake defines no files | explicit mode |
| W110 | GLOB fallback active | Always with GLOB |
| W111 | Source.cmake exists but is empty | auto mode with path |

---

### 4.4 _apply_sources_to_target()

Applies collected files to a target.

```cmake
_apply_sources_to_target(<TARGET_NAME>
                         <SOURCES> <HEADERS> <EXTRAS> <MODULES> <INCLUDES> <SOURCE_DIR>)
```

**Automatically added include paths:**

1. `SOURCE_DIR` — always
2. `SOURCE_DIR/pch/` — if present

---

### 4.5 collect_files()

Helper for controlled wildcards in Source.cmake.

```cmake
collect_files(<OUT_VAR>
    DIRECTORY <path>
    EXTENSIONS <ext1> [ext2...]
    [EXCLUDE <pattern1> [pattern2...]]
)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `OUT_VAR` | Variable | ✓ | Output for the file list |
| `DIRECTORY` | Path | ✓ | Directory to search |
| `EXTENSIONS` | List | ✓ | Extensions without dot |
| `EXCLUDE` | List | — | Regex patterns to exclude |

**Errors:**

| Code | Condition |
|------|-----------|
| E001 | DIRECTORY missing |
| E001 | EXTENSIONS missing |

**Example:**

```cmake
collect_files(_generated
    DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/generated"
    EXTENSIONS cpp c
    EXCLUDE "*_test.cpp" "test_*.cpp"
)
list(APPEND ${TARGET}_SOURCES ${_generated})
```

---

### 4.6 _get_source_mode()

Determines the source mode from the solution settings.

```cmake
_get_source_mode(<OUT_VAR>)
```

**Returns:** "explicit" (default), "glob", or "auto"

**Warnings:**

| Code | Condition |
|------|-----------|
| W101 | Invalid mode |

---

## 5. Source.cmake Format

### 5.1 Minimal Source.cmake

```cmake
set(${TARGET}_SOURCES
    main.cpp
)
```

### 5.2 Complete Source.cmake

```cmake
# Compilable sources
set(${TARGET}_SOURCES
    main.cpp
    app/Application.cpp
    app/Window.cpp
    utils/FileIO.cpp
)

# Header files
set(${TARGET}_HEADERS
    app/Application.h
    app/Window.h
    utils/FileIO.h
)

# Template implementations
set(${TARGET}_TEMPLATES
    utils/Container.tpp
)

# Inline implementations
set(${TARGET}_INLINES
    utils/FastMath.inl
)

# PIMPL details
set(${TARGET}_IMPL
    app/ApplicationImpl.impl
)

# C++20 modules (experimental)
set(${TARGET}_MODULES
    math.ixx
)

# Additional include paths
set(${TARGET}_INCLUDES
    include
    ../shared/include
)
```

### 5.3 With collect_files() for Generated Files

```cmake
set(${TARGET}_SOURCES
    main.cpp
    core/Engine.cpp
)

# Generated files
collect_files(_generated
    DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/generated"
    EXTENSIONS cpp
    EXCLUDE "*_test.cpp"
)
list(APPEND ${TARGET}_SOURCES ${_generated})
```

---

## 6. Usage Examples

### 6.1 In ExecutableCreate.cmake

```cmake
function(_create_executable_target CTX)
    ctx_get(${CTX} NAME _name)
    ctx_get(${CTX} PATH _path)
    
    set(_source_dir "${CMAKE_SOURCE_DIR}/${_path}")
    
    # Collect sources
    collect_sources(${_name} "${_source_dir}"
        _sources _headers _extras _modules _includes)
    
    # Create the target
    add_executable(${_name} ${_sources})
    
    # Apply sources
    _apply_sources_to_target(${_name}
        "${_sources}" "${_headers}" "${_extras}" "${_modules}" "${_includes}"
        "${_source_dir}")
endfunction()
```

---

## 7. Error Handling

### 7.1 Fatal Errors

| Code | Description | Solution |
|------|-------------|----------|
| E104 | Source.cmake not found | Create Source.cmake or change the mode to `auto` |
| E001 | Required field missing (collect_files) | Specify DIRECTORY and EXTENSIONS |

### 7.2 Warnings

| Code | Description | Recommendation |
|------|-------------|----------------|
| W101 | No sources defined | Check Source.cmake |
| W109 | C++20 modules used | Experimental — only with CMake 3.28+ |
| W110 | GLOB fallback active | Migrate to an explicit Source.cmake |

---

## 8. Best Practices

### 8.1 Prefer the "explicit" Mode

```cmake
# ✅ Good - explicit control
# In Solution.json:
"settings": {
    "source": {
        "mode": "explicit"
    }
}
```

### 8.2 Source.cmake for Every Target

```
projects/exec/MyApp/
├── src/
│   ├── Source.cmake    # ← required with mode=explicit
│   ├── main.cpp
│   └── ...
```

### 8.3 collect_files() Only for Generated Files

```cmake
# ✅ Good - only for generated files
collect_files(_gen DIRECTORY "${_dir}/generated" ...)

# ❌ Bad - for normal sources
collect_files(_all DIRECTORY "${_dir}" ...)  # Better: list explicitly!
```

---

## 9. See Also

- [ExecutableCreate.cmake](../project/ExecutableCreate.md) — uses SourceCollect
- [LibraryCreate.cmake](../project/LibraryCreate.md) — uses SourceCollect
- [Solution.cmake](../project/Solution.md) — sets SOLUTION_SOURCE_MODE
- [ErrorCodes.md](../../references/ErrorCodes.md) — E104, W101, W109, W110

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.1 | 2025-12-17 | collect_sources() integration, SourceCollect.cmake dependency |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0: new header with target audience/language/English link/module link, numbered table of contents with anchors, chapter numbering |
| 0.1.1 | 2025-12-05 | English translation (Language Standards v0.1.1) |
| 0.1.0 | 2025-12-03 | Initial (clean start): collect_sources, _collect_sources_from_cmake, _collect_sources_glob, _apply_sources_to_target, collect_files, _get_source_mode |
