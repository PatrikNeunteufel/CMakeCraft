# CMakeCraftPackage.cmake — Fetch and Deploy Prebuilt Packages

> **Version:** 1.0.0  
> **Date:** 2026-10-09  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [CMakeCraftPackage.md](../../../de/guide/module/CMakeCraftPackage.md)  
> **Module:** [CMakeCraftPackage.cmake](../../../../CMakeCraftPackage.cmake)  
> **Module Version:** 1.0.0 (version of the file itself, independent of the CMakeCraft version)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Concept](#3-concept)
4. [API Reference](#4-api-reference)
5. [Processing Flow](#5-processing-flow)
6. [Usage Examples](#6-usage-examples)
7. [Error Handling](#7-error-handling)
8. [See Also](#8-see-also)
9. [Changelog](#9-changelog)

---

## 1. Overview

`CMakeCraftPackage.cmake` fetches a **prebuilt package** (headers, runtime files, tools) in a pinned version and applies it to targets. The file lives in the repo root and is **standalone**: it uses nothing from the CMakeCraft core. A project that does not build with CMakeCraft can carry an unchanged copy and include it directly.

CMakeCraft itself calls the file from the external kind `archive` (see [archive/Handler_cmake.md](externals/archive/Handler_cmake.md)).

### Core Functions

- **Fetch** — `craft_package_fetch()`: developer override, cache, download, fallback paths
- **Check** — SHA256 of the archive and the version from the file `VERSION` inside the package
- **Deploy** — `craft_package_deploy()`: include path, define, copies next to the executable
- **A missing package is not an error** — warning, empty root, `craft_package_deploy()` then does nothing

---

## 2. Dependencies

| Dependency | Type | Description |
|------------|------|-------------|
| CMake 3.26+ | System | Because of `copy_directory_if_different`; older versions abort with `FATAL_ERROR` on include |

**No** other modules are required. Errors and warnings go through `message()` with the prefix `[CraftPackage]`, not through `cmake_fatal`/`cmake_warn`.

On include the file sets:

| Effect | Description |
|--------|-------------|
| `include_guard(GLOBAL)` | Including it more than once is harmless |
| `CMAKECRAFT_PACKAGE_VERSION` | Variable holding the version of this file (`1.0.0`) |
| Policy `CMP0174` → `NEW` | Only if the policy exists; an empty `ROOT` is then a regular argument of `craft_package_deploy()` |

---

## 3. Concept

### 3.1 Pin File

The pin file is a CMake script. `<NAME>` is the upper-case package name, turned into a C identifier (`string(MAKE_C_IDENTIFIER)`).

```cmake
set(<NAME>_VERSION "v0.2.0")
set(<NAME>_URL     "https://.../<archive>.zip")
set(<NAME>_SHA256  "<64 hex digits>")
set(<NAME>_FALLBACK_PATHS "../Other/out/package")   # optional, directories
```

| Variable | Required | Description |
|----------|----------|-------------|
| `<NAME>_VERSION` | ✓ | Pinned version; if missing, a warning is issued and the build goes on without the package |
| `<NAME>_URL` | — | Address of the archive; its last path component is also the file name looked up in the fallback paths |
| `<NAME>_SHA256` | ✓ (except on a cache hit or override) | Checksum of the archive; the check is that the value consists of hex digits only — nothing is fetched without a checksum |
| `<NAME>_FALLBACK_PATHS` | — | Directories holding the same archive file (same checksum) |

Relative paths inside the pin file and in `<NAME>_LOCAL_DIR` are relative to the directory of the pin file.

### 3.2 Package Layout

The archive holds one top-level folder, or the content directly. The package root contains a file `VERSION` whose line `produkt=<x.y.z>` must match the pinned version. A leading `v` or `V` of the pin version is ignored in the comparison.

### 3.3 Order of Sources

| # | Source | Description |
|---|--------|-------------|
| 1 | `-D<NAME>_LOCAL_DIR=<dir>` | Developer override, used as is and **unchecked** |
| 2 | Cache | Default: `<pin dir>/.externals/<name>/<version>/` |
| 3 | Download of `<NAME>_URL` | Checked against `<NAME>_SHA256` |
| 4 | `<NAME>_FALLBACK_PATHS` | Directories holding the same archive file, same checksum |

### 3.4 Aborted Runs

The archive is unpacked next to the cache directory (`<cache>.unpack`) and renamed into place only after checksum and version are right. An aborted run therefore never leaves something that looks like a cached package. The download goes to `<cache>.download/` and is removed again after the attempt.

---

## 4. API Reference

### 4.1 craft_package_fetch()

```cmake
craft_package_fetch(NAME <name> PIN_FILE <file> [CACHE_DIR <dir>] OUT_ROOT <var>)
```

**Description:**  
Fetches the package in the pinned version and returns its root.

**Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `NAME` | ✓ | Package name; its upper-case form is the prefix of the pin variables and of `<NAME>_LOCAL_DIR` |
| `PIN_FILE` | ✓ | Pin file (relative: to `CMAKE_CURRENT_SOURCE_DIR`) |
| `CACHE_DIR` | — | Directory of the unpacked package, relative to `CMAKE_CURRENT_SOURCE_DIR` (default: `<pin dir>/.externals/<name>/<version>`) |
| `OUT_ROOT` | ✓ | Receives the package root, or `""` if the package is unavailable |

**Returns:**  
`OUT_ROOT` in the calling scope (`PARENT_SCOPE`). The function also creates the cache variable `<NAME>_LOCAL_DIR` (type `PATH`, default empty).

**Errors:**  
- `FATAL_ERROR` if `NAME`, `PIN_FILE` or `OUT_ROOT` is missing
- Everything else is a `WARNING` with an empty `OUT_ROOT` (see [Error Handling](#7-error-handling))

---

### 4.2 craft_package_deploy()

```cmake
craft_package_deploy(TARGET <target> ROOT <dir>
                     [INCLUDE_DIRS <dir>...] [DEFINE <name>]
                     [RUNTIME_FILES <file>...] [RUNTIME_DIRS <dir>...]
                     [NO_RUNTIME])
```

**Description:**  
Applies a fetched package to a target.

**Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `TARGET` | ✓ | Existing target |
| `ROOT` | ✓ | Package root from `craft_package_fetch()`; empty or not a directory = the package is absent, nothing happens |
| `INCLUDE_DIRS` | — | Include directories, relative to `ROOT` (include path only — nothing is linked) |
| `DEFINE` | — | Compile definition `<name>=1` on the target |
| `RUNTIME_FILES` | — | Files, relative to `ROOT`, copied next to the executable after each build |
| `RUNTIME_DIRS` | — | Directories, relative to `ROOT`, copied as a subfolder of the same name next to the executable |
| `NO_RUNTIME` | — | Include path and define only, no copies |

**Behavior:**

| Target type | Include path and define | Runtime copies |
|-------------|-------------------------|----------------|
| `INTERFACE_LIBRARY` | `INTERFACE` | none |
| `EXECUTABLE` | `PRIVATE` | yes (`POST_BUILD`), unless `NO_RUNTIME` |
| other | `PRIVATE` | none |

Copies go to `$<TARGET_FILE_DIR:target>`, i.e. per configuration, and only when they differ (`copy_if_different`, `copy_directory_if_different`).

**Returns:**  
Nothing.

**Errors:**  
- `FATAL_ERROR` if `TARGET` is empty or does not exist

---

## 5. Processing Flow

```
craft_package_fetch(NAME, PIN_FILE, [CACHE_DIR], OUT_ROOT)
    │
    ├── 0. OUT_ROOT = ""; does the pin file exist?
    │   └── No → WARNING, done
    │
    ├── 1. <NAME>_LOCAL_DIR set?
    │   ├── directory → OUT_ROOT = that directory, done (unchecked)
    │   └── no directory → WARNING, done
    │
    ├── 2. Include the pin file
    │   └── <NAME>_VERSION empty → WARNING, done
    │
    ├── 3. Cache: does <cache>/VERSION carry the wanted version?
    │   └── Yes → OUT_ROOT = <cache>, done
    │
    ├── 4. <NAME>_SHA256 not hexadecimal → WARNING, done
    │
    ├── 5. Download (if <NAME>_URL is set)
    │   ├── INACTIVITY_TIMEOUT 30, TLS_VERIFY ON
    │   └── success → check and unpack → OUT_ROOT = <cache>, done
    │
    ├── 6. Fallback paths, in order
    │   └── <dir>/<archive name> exists → check and unpack
    │       → OUT_ROOT = <cache>, done
    │
    └── 7. WARNING listing every attempt and its reason
```

**Check and unpack** (`_craft_package_unpack`):

1. Compare the SHA256 of the archive file (case of the expected sum does not matter)
2. Unpack to `<cache>.unpack`
3. Determine the package root: the content directly, or — if there is no `VERSION` there and exactly one folder is contained — that folder
4. Compare `produkt=` from `VERSION` with the wanted version
5. Remove the old cache directory, rename the package root into its place

The download deliberately runs without `EXPECTED_HASH`: `file(DOWNLOAD)` would otherwise turn a failed download into a fatal error. The checksum is compared while unpacking.

---

## 6. Usage Examples

### 6.1 Standalone (without CMakeCraft)

```cmake
include("${CMAKE_CURRENT_LIST_DIR}/cmake/CMakeCraftPackage.cmake")

craft_package_fetch(
    NAME     toolkit
    PIN_FILE "toolkit.pin"
    OUT_ROOT _toolkit_root
)

craft_package_deploy(
    TARGET        MyApp
    ROOT          "${_toolkit_root}"
    INCLUDE_DIRS  include
    DEFINE        TOOLKIT_AVAILABLE
    RUNTIME_FILES bin/toolkit.dll
    RUNTIME_DIRS  tools
)
```

The pin file `toolkit.pin` for it:

```cmake
set(TOOLKIT_VERSION "v0.2.0")
set(TOOLKIT_URL     "https://example.org/toolkit-v0.2.0.zip")
set(TOOLKIT_SHA256  "<64 hex digits>")
```

### 6.2 Developing Against a Locally Unpacked Package

```bash
cmake -B build -DTOOLKIT_LOCAL_DIR=../Toolkit/out/package/toolkit-v0.2.0
```

### 6.3 Package Absent

```cmake
craft_package_deploy(TARGET MyApp ROOT "" INCLUDE_DIRS include DEFINE TOOLKIT_AVAILABLE)
# Neither include path nor define nor copies - the code checks the define itself.
```

---

## 7. Error Handling

The file uses no error codes of the CMakeCraft core.

### Fatal Errors

| Condition | Message |
|-----------|---------|
| CMake older than 3.26 | `[CraftPackage] CMake 3.26 or newer is required` |
| `craft_package_fetch` without `NAME`, `PIN_FILE` or `OUT_ROOT` | `NAME, PIN_FILE and OUT_ROOT are mandatory` |
| `craft_package_deploy` with an empty or unknown `TARGET` | `TARGET '<name>' does not exist` |

### Warnings (the build goes on without the package)

| Condition |
|-----------|
| Pin file not found |
| `<NAME>_LOCAL_DIR` set, but not a directory |
| `<NAME>_VERSION` not set in the pin file |
| `<NAME>_SHA256` missing or not hexadecimal |
| Package not obtainable from any source — the message gives the reason per attempt (download status, checksum differs, version in `VERSION` does not match, file not found, cache directory not removable, move into the cache failed) and the remedies |

---

## 8. See Also

- [externals/archive/Handler_cmake.md](externals/archive/Handler_cmake.md) — external kind `archive`, calls this file
- [project/Packages.md](project/Packages.md) — produces packages in the layout expected here
- [buildSystemTest/Phase10_doc.md](buildSystemTest/Phase10_doc.md) — phase test

---

## 9. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2026-10-09** | **Initial (CMakeCraft v0.10.0): craft_package_fetch, craft_package_deploy** |
