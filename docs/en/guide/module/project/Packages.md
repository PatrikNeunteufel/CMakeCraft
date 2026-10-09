# Packages.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2026-10-09  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [Packages.md](../../../../de/guide/module/project/Packages.md)  
> **Module:** [`cmake/project/Packages.cmake`](../../../../../cmake/project/Packages.cmake)  
> **Module Version:** 1.0.0  
> **Phase:** 10 (Packages)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [API Reference](#3-api-reference)
4. [JSON Mapping](#4-json-mapping)
5. [Processing](#5-processing)
6. [Error Handling](#6-error-handling)
7. [Debug Output](#7-debug-output)
8. [See Also](#8-see-also)
9. [Changelog](#9-changelog)

---

## 1. Overview

The `Packages.cmake` module creates **one target `package_<name>`** per entry of the `packages` block in Solution.json. The target is not part of `ALL`; it is built on purpose and then writes a package to `<project>/out/package/`.

### Result of Building `package_<name>`

| Path in `out/package/` | Content |
|------------------------|---------|
| `<archive>/` | The staged folder |
| `<archive>.zip` | The folder as archive (one top-level folder) |
| `<archive>.zip.sha256` | Checksum, format of `sha256sum` |

### Responsibilities

| Area | Description |
|------|-------------|
| JSON parsing | Read and check the fields of a package entry |
| Manifest | Generate one file `manifest-<CONFIG>.cmake` per configuration |
| Version file | Configure the template at configure time to `<build>/package/<name>/VERSION` |
| Target | Create `package_<name>`, add dependencies on the packaged targets |

The staging itself happens at build time in [PackageBuild.cmake](PackageBuild.md).

### Position in the Flow

`CMakeCraft.cmake` includes the module as phase 10 — after libraries, executables and apps (their targets must exist) and before the tests.

---

## 2. Dependencies

| Module | Usage |
|--------|-------|
| Errors.cmake | `cmake_fatal`, `cmake_warn` |
| Debug.cmake | `dbg`, `dbg_init`, `enddbgblock` |
| Json.cmake | `_json_get_string`, `_json_get_string_or_default`, `_json_array_length`, `_json_array_get`, `_json_get_array_as_list`, `_json_has_key` |
| Solution.cmake | Global properties `SOLUTION_JSON`, `SOLUTION_VERSION` |
| PackageBuild.cmake | Run at build time via `cmake -P` |
| LibraryCreate.cmake | Sets the target property `CRAFT_PUBLIC_HEADERS_DIR` read by `headers_of` |

---

## 3. API Reference

### 3.1 _create_package_target()

Creates the target `package_<name>` from one entry of `packages`.

```cmake
_create_package_target(<PKG_JSON>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `PKG_JSON` | String | ✓ | JSON string of one entry of `packages` |

**Returns:** Nothing (creates target, manifest and, if requested, the version file)

### 3.2 Pipeline on Include

On `include()` the module reads `packages` from the global property `SOLUTION_JSON` and calls `_create_package_target()` per entry. If the block is missing or empty, nothing happens.

---

## 4. JSON Mapping

### 4.1 Fields of a Package Entry

| Field | Required | Default | Description |
|-------|----------|---------|-------------|
| `name` | ✓ | — | Package name; the target becomes `package_<name>` |
| `archive` | — | `<name>-v{version}` | Folder and archive name; `{version}` is the solution version |
| `config` | — | "" | The only configuration the package may be built from (e.g. `Release`) |
| `version_file` | — | "" | Template relative to the project root; configured with `@VERSION@` (solution version) and written as file `VERSION` into the package root |
| `contents` | ✓ | — | Array of contents, at least one entry |

### 4.2 Fields of a `contents` Entry

Each entry has `to` and **exactly one** source.

| Field | Description |
|-------|-------------|
| `to` | Destination folder inside the package |
| `headers_of` | Public header folder of a library (property `CRAFT_PUBLIC_HEADERS_DIR`), optionally narrowed by `files` |
| `binary_of` | The built file of a target (`$<TARGET_FILE:...>`) |
| `output_dir_of` | The output folder of a target (`$<TARGET_FILE_DIR:...>`) with all subfolders, minus `exclude` |
| `from` | Folder relative to the project root, optionally narrowed by `files` |
| `files` | Array of files relative to the source; applies to `headers_of` and `from` |
| `exclude` | Array of patterns left out when a whole folder is copied |

This yields the copy kind in the manifest:

| Source | Kind | Meaning |
|--------|------|---------|
| `binary_of` | `file` | One file |
| `headers_of` / `from` with `files` | `files` | The named files, subfolders are kept |
| everything else | `dir` | The whole folder, minus `exclude` |

### 4.3 Example (Demo Solution)

```json
"packages": [
    {
        "name": "packdemo",
        "archive": "packdemo-v{version}",
        "contents": [
            { "to": "include", "headers_of": "PackDemo", "files": [ "pack_demo.h" ] },
            { "to": "bin", "binary_of": "PackDemo" }
        ],
        "version_file": "projects/demos/packaging/VERSION.in"
    }
]
```

The template `projects/demos/packaging/VERSION.in`:

```
produkt=@VERSION@
```

Build:

```bash
cmake --build <build> --target package_packdemo
```

---

## 5. Processing

```
_create_package_target(PKG_JSON)
    │
    ├── 1. read name                         → E001 if empty
    │      target package_<name> exists      → E102
    │
    ├── 2. read archive (replace {version}), config
    │
    ├── 3. walk contents                     → E001 if missing or empty
    │   ├── exactly one source?              → E001 otherwise
    │   ├── source names a target that does not exist
    │   │       → W112, the package is NOT created (return)
    │   ├── headers_of without public headers → E001
    │   ├── from: folder does not exist       → E001
    │   ├── binary_of / output_dir_of → remember dependency on the target
    │   └── manifest lines CRAFT_PKG_ITEM_<i>_{KIND,TO,SRC,FILES,EXCLUDE}
    │
    ├── 4. version_file (if given)           → E001 if not found
    │   └── configure_file(... @ONLY) → <build>/package/<name>/VERSION
    │
    ├── 5. write the manifest (file(GENERATE))
    │   └── <build>/package/<name>/manifest-$<CONFIG>.cmake
    │
    └── 6. add_custom_target(package_<name>)
        ├── cmake -DCRAFT_PKG_MANIFEST=<manifest> -P PackageBuild.cmake
        └── add_dependencies(package_<name> <targets from step 3>)
```

### Manifest Variables

| Variable | Content |
|----------|---------|
| `CRAFT_PKG_NAME` | Package name |
| `CRAFT_PKG_ARCHIVE` | Folder and archive name |
| `CRAFT_PKG_OUT_DIR` | `${CMAKE_SOURCE_DIR}/out/package` |
| `CRAFT_PKG_REQUIRED_CONFIG` | Value of `config` |
| `CRAFT_PKG_CONFIG` | `$<CONFIG>` of the build |
| `CRAFT_PKG_VERSION_FILE` | Path of the configured version file, or empty |
| `CRAFT_PKG_ITEMS` | List of content indices |
| `CRAFT_PKG_ITEM_<i>_*` | `KIND`, `TO`, `SRC`, `FILES`, `EXCLUDE` per content |

Generator expressions in the manifest are resolved at generate time.

---

## 6. Error Handling

### 6.1 Fatal Errors

| Code | Condition |
|------|-----------|
| E001 | `name` missing |
| E001 | `contents` missing or empty |
| E001 | A `contents` entry does not have exactly one of the sources `headers_of`, `binary_of`, `output_dir_of`, `from` |
| E001 | `headers_of`: the library has no public headers |
| E001 | `from`: folder does not exist |
| E001 | `version_file` not found |
| E102 | Target `package_<name>` already exists |

### 6.2 Warnings

| Code | Condition | Consequence |
|------|-----------|-------------|
| W112 | A source names a target that does not exist (skipped or other platform) | `package_<name>` is not created |

Build-time errors: see [PackageBuild.cmake](PackageBuild.md).

---

## 7. Debug Output

### Debug ID: `PACKAGES` (tag `Packages`)

| Level | Output |
|-------|--------|
| `DBG_OFTEN` | Package Pipeline Start / Complete, number of packages |
| `DBG_COMMON` | Created: package_{name} -> out/package/{archive} |

---

## 8. See Also

- [PackageBuild.cmake](PackageBuild.md) — build-time script of the target
- [LibraryCreate.cmake](LibraryCreate.md) — sets `CRAFT_PUBLIC_HEADERS_DIR`
- [CMakeCraftPackage.cmake](../CMakeCraftPackage.md) — fetches packages in this layout
- [Phase10_doc.md](../buildSystemTest/Phase10_doc.md) — phase test

---

## 9. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2026-10-09** | **Initial (CMakeCraft v0.10.0): block `packages`, target `package_<name>`** |
