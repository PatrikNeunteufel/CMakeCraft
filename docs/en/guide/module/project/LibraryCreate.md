# LibraryCreate.cmake — Module Documentation

> **Version:** 1.0.2  
> **Date:** 2026-11-07  
> **Type:** ModuleDoc  
> **Status:** In Development (Pre-Release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [LibraryCreate.md](../../../../de/guide/module/project/LibraryCreate.md)  
> **Module:** [`cmake/project/LibraryCreate.cmake`](../../../../../cmake/project/LibraryCreate.cmake)  
> **Module Version:** 1.1.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [API Reference](#3-api-reference)
4. [Library Types](#4-library-types)
5. [Processing](#5-processing)
6. [Error Handling](#6-error-handling)
7. [See Also](#7-see-also)
8. [Changelog](#8-changelog)

---

## 1. Overview

The `LibraryCreate.cmake` module **creates CMake library targets** from a prepared context. It supports STATIC, SHARED and INTERFACE libraries.

### Core Idea

Analogous to ExecutableCreate — the context contains all the data, Create creates the target.

### Responsibilities

| Area | Description |
|------|-------------|
| Target creation | add_library() with the correct type |
| Source collection | GLOB or Source.cmake |
| Public headers | Set include directories |
| Dependencies | Internal libraries, externals |

---

## 2. Dependencies

| Module | Version | Usage |
|--------|---------|-------|
| Context.cmake | 0.5.0 | `ctx_get` |
| Errors.cmake | 0.5.0 | `cmake_fatal`, `cmake_warn` |
| Debug.cmake | 0.5.0 | `dbg` |
| OutputDirs.cmake | 0.5.0 | `setup_output_dirs` |
| Warnings.cmake | 0.5.0 | `apply_warnings` |
| CompilerOptions.cmake | 0.5.0 | `apply_compiler_options` |
| Orchestrator.cmake | 0.7.0 | `apply_external_to_target` |

---

## 3. API Reference

### 3.1 _create_library_target()

Creates a CMake library target from the context.

```cmake
_create_library_target(<CTX>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `CTX` | String | ✓ | Context prefix (e.g. `LIB_0`) |

**Expected context keys:**

| Key | Usage |
|-----|-------|
| NAME | Target name |
| PATH | Source directory |
| TYPE | STATIC, SHARED, INTERFACE |
| VERSION | Target version |
| PUBLIC_HEADERS | Public include directory |
| DEPENDENCIES | Internal libraries |
| EXTERNALS | External dependencies |
| EXTERNAL_OPTIONS | Per-external options (JSON) |
| OUTPUT_NAME | File name without extension (empty = target name) |
| DEFINES | Preprocessor definitions; `{version}` stands for VERSION |
| COMPILE_OPTIONS | Compiler flags of the library (PRIVATE, after `apply_compiler_options`); E105 for INTERFACE |

---

## 4. Library Types

### 4.1 STATIC Library

```cmake
add_library(${name} STATIC ${sources})
```

Default for most libraries.

### 4.2 SHARED Library

```cmake
add_library(${name} SHARED ${sources})
```

Produces .dll/.so/.dylib.

### 4.3 INTERFACE Library

```cmake
add_library(${name} INTERFACE)
target_include_directories(${name} INTERFACE ${public_headers})
```

Header-only library — no sources, only include directories.

---

## 5. Processing

### 5.1 Flow

```
_create_library_target(CTX)
    │
    ├── 1. Read context data
    │
    ├── 2. TYPE == INTERFACE?
    │   ├── Yes → E105 if COMPILE_OPTIONS is set
    │   │       add_library(INTERFACE)
    │   │       └── Set public headers only
    │   │
    │   └── No → Continue with STATIC/SHARED
    │
    ├── 3. Validate source directory
    │   └── E001 if it does not exist
    │
    ├── 4. Create target (STATIC/SHARED)
    │
    ├── 5. Collect sources (GLOB)
    │
    ├── 6. Set public headers
    │   └── PUBLIC include directory
    │
    ├── 7. Link internal dependencies
    │
    ├── 8. Apply externals (with options)
    │   ├── _craft_target_snapshot()          state before
    │   ├── apply_external_to_target(name, ext, options)
    │   └── _craft_record_external_effect()   what the external added
    │
    ├── 9. Apply standard modules
    │   ├── apply_warnings()
    │   ├── apply_compiler_options()
    │   ├── target_compile_options(PRIVATE COMPILE_OPTIONS)   afterwards
    │   └── setup_output_dirs()
    │
    ├── 10. Set version as a property
    │
    └── 11. Description for a source package (CRAFT_LIB_*)
```

### 5.2 Public Headers

```cmake
target_include_directories(${name}
    PUBLIC "${CMAKE_SOURCE_DIR}/${public_headers}"
    PRIVATE "${src_dir}"
)
```

- **PUBLIC:** Visible to consumers of the library
- **PRIVATE:** Used internally only

If `PUBLIC_HEADERS` is set, the target also receives the property `CRAFT_PUBLIC_HEADERS_DIR` with the absolute path (`${CMAKE_SOURCE_DIR}/${public_headers}`) — for INTERFACE libraries as well. [Packages.cmake](Packages.md) reads it for `headers_of`.

### 5.3 Defines and Output Name

Right after the context is read, every `{version}` in `DEFINES` is replaced by the version of the target.

```cmake
# INTERFACE library
target_compile_definitions(${name} INTERFACE ${defines})

# STATIC / SHARED library (after the externals are applied)
target_compile_definitions(${name} PRIVATE ${defines})
set_target_properties(${name} PROPERTIES OUTPUT_NAME "${output_name}")  # only if not empty
```

- **DEFINES:** `INTERFACE` for INTERFACE libraries, `PRIVATE` otherwise
- **OUTPUT_NAME:** STATIC/SHARED only; the file name then differs from the target name, the target name stays

### 5.4 Compile Options (since v0.14.0)

```cmake
apply_warnings(${name})
apply_compiler_options(${name})
target_compile_options(${name} PRIVATE ${compile_options})   # only if not empty
```

The flags of the library come **after** the defaults, so that a flag of the library overrides
a default (with MSVC the later `/fp:` wins). Generator expressions stay unchanged.
An INTERFACE library with `compile_options` aborts with **E105**.

### 5.5 Description for a Source Package (since v0.14.0)

At the end, for STATIC/SHARED, the module sets the properties from which
[SourcePackage.cmake](SourcePackage.md) builds the generated `CMakeLists.txt`:

| Property | Content |
|----------|---------|
| `CRAFT_LIB_SOURCE_DIR` | absolute source folder (`path`) |
| `CRAFT_LIB_FILES` | sources, headers and extras from `collect_sources()` |
| `CRAFT_LIB_MODULES` | C++20 module units |
| `CRAFT_LIB_PRIVATE_INCLUDES` | source folder, includes from `Source.cmake`, `pch/` |
| `CRAFT_LIB_DEFINES`, `CRAFT_LIB_COMPILE_OPTIONS` | as set (`{version}` replaced) |
| `CRAFT_LIB_PCH` | PCH header found, or empty |
| `CRAFT_LIB_DEPENDENCIES`, `CRAFT_LIB_EXTERNALS` | as in the JSON |
| `CRAFT_LIB_VERSION`, `CRAFT_LIB_OUTPUT_NAME` | as in the JSON (version falling back to the solution) |
| `CRAFT_EXT_<ext>_LINKS` | entries the external added to `LINK_LIBRARIES` |
| `CRAFT_EXT_<ext>_PUBLIC` | those of them linked PUBLIC (without `$<LINK_ONLY:…>` in `INTERFACE_LINK_LIBRARIES`) |
| `CRAFT_EXT_<ext>_OTHER` | names of all other properties the external changed on the target |

For this, `_craft_target_snapshot` and `_craft_record_external_effect` compare the properties
in `_CRAFT_EXTERNAL_EFFECT_PROPERTIES` (link, include, define, options, feature,
link options, source and PCH properties, each also `INTERFACE_*`) before and after
`apply_external_to_target`.

---

## 6. Error Handling

### 6.1 Fatal Errors

| Code | Condition | Solution |
|------|-----------|----------|
| E001 | Source path does not exist | Check/create the path |
| E101 | Internal dependency does not exist | Check the library order |
| E105 | `compile_options` on an INTERFACE library | Move the flags to a STATIC library or remove them |

### 6.2 Warnings

| Code | Condition | Recommendation |
|------|-----------|----------------|
| W101 | No sources found | Add source files |

---

## 7. See Also

- [Libraries.cmake](Libraries.md) — Calls _create_library_target
- [LibraryCollect.cmake](LibraryCollect.md) — Fills the context
- [ExecutableCreate.cmake](ExecutableCreate.md) — Analogous module for executables

---

## 8. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.2** | **2026-11-07** | **CMakeCraft v0.14.0: COMPILE_OPTIONS (PRIVATE, after `apply_compiler_options`, E105 for INTERFACE); description for source packages (`CRAFT_LIB_*`, `CRAFT_EXT_*`); module version 1.1.0** |
| 1.0.1 | 2026-10-09 | CMakeCraft v0.10.0: OUTPUT_NAME and DEFINES (with `{version}`); target property `CRAFT_PUBLIC_HEADERS_DIR` |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.6.0 | 2025-12-20 | EXTERNAL_OPTIONS support: apply_external_to_target() instead of direct linking |
| 0.5.1 | 2025-12-17 | collect_sources() integration, SourceCollect.cmake dependency |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0 |
| 0.1.0 | 2025-12-07 | Initial (clean start): STATIC/SHARED/INTERFACE support |
