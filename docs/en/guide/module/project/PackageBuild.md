# PackageBuild.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2026-10-09  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [PackageBuild.md](../../../../de/guide/module/project/PackageBuild.md)  
> **Module:** [`cmake/project/PackageBuild.cmake`](../../../../../cmake/project/PackageBuild.cmake)  
> **Module Version:** 1.0.0  
> **Phase:** 10 (Packages)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Invocation](#3-invocation)
4. [Processing](#4-processing)
5. [Error Handling](#5-error-handling)
6. [See Also](#6-see-also)
7. [Changelog](#7-changelog)

---

## 1. Overview

`PackageBuild.cmake` is the **build-time script** of the target `package_<name>`. It is not included but run via `cmake -P`. It stages the package folder, writes the archive and its checksum.

### Core Idea

Configure time and build time are kept apart: [Packages.cmake](Packages.md) describes the package in a manifest, this script executes the manifest. The package folder is rebuilt from scratch on every run.

### Result in `CRAFT_PKG_OUT_DIR`

| Path | Content |
|------|---------|
| `<archive>/` | The staged folder |
| `<archive>.zip` | The folder as zip archive (one top-level folder) |
| `<archive>.zip.sha256` | One line `<hash>  <archive>.zip` (format of `sha256sum`) |

---

## 2. Dependencies

| Module | Usage |
|--------|-------|
| — | None (script mode; reads the manifest written by Packages.cmake) |

The script defines no functions and uses neither `cmake_fatal` nor `dbg`. Messages carry the prefix `[Package]`.

---

## 3. Invocation

```bash
cmake -DCRAFT_PKG_MANIFEST=<manifest.cmake> -P PackageBuild.cmake
```

| Variable | Required | Description |
|----------|----------|-------------|
| `CRAFT_PKG_MANIFEST` | ✓ | Path of the manifest (`manifest-<CONFIG>.cmake`) |

`Packages.cmake` issues this call as the command of the target `package_<name>`; there is no need to run it by hand.

### Manifest Variables Read

| Variable | Usage |
|----------|-------|
| `CRAFT_PKG_NAME` | Package name for messages |
| `CRAFT_PKG_ARCHIVE` | Folder and archive name (mandatory) |
| `CRAFT_PKG_OUT_DIR` | Destination directory (mandatory) |
| `CRAFT_PKG_REQUIRED_CONFIG` | The only configuration allowed, or empty |
| `CRAFT_PKG_CONFIG` | Configuration of this build |
| `CRAFT_PKG_VERSION_FILE` | Configured version file, or empty |
| `CRAFT_PKG_ITEMS` | List of content indices |
| `CRAFT_PKG_ITEM_<i>_KIND` | `files`, `file` or `dir` |
| `CRAFT_PKG_ITEM_<i>_SRC` | Source (folder or file) |
| `CRAFT_PKG_ITEM_<i>_TO` | Destination folder inside the package |
| `CRAFT_PKG_ITEM_<i>_FILES` | Files relative to the source (kind `files`) |
| `CRAFT_PKG_ITEM_<i>_EXCLUDE` | Exclude patterns (kind `dir`) |

---

## 4. Processing

```
PackageBuild.cmake
    │
    ├── 1. Include the manifest
    │   ├── not found → FATAL_ERROR
    │   └── CRAFT_PKG_ARCHIVE or CRAFT_PKG_OUT_DIR empty → FATAL_ERROR
    │
    ├── 2. Check the configuration
    │   └── CRAFT_PKG_REQUIRED_CONFIG set and ≠ CRAFT_PKG_CONFIG → FATAL_ERROR
    │
    ├── 3. Clean up
    │   ├── remove and recreate <out>/<archive>/
    │   └── remove <archive>.zip and <archive>.zip.sha256
    │
    ├── 4. Copy the contents (each entry to <out>/<archive>/<TO>)
    │   ├── files → every named file, subfolders are kept
    │   ├── file  → one file
    │   └── dir   → the whole folder, EXCLUDE as PATTERN ... EXCLUDE
    │
    ├── 5. Version file (if set) → <out>/<archive>/VERSION
    │
    ├── 6. Write the archive
    │   └── cmake -E tar cf <archive>.zip --format=zip -- <archive>
    │       (working directory: CRAFT_PKG_OUT_DIR)
    │
    └── 7. Compute SHA256 → <archive>.zip.sha256
```

At the end the script prints the archive path and the checksum as `STATUS` messages.

---

## 5. Error Handling

All errors are `message(FATAL_ERROR ...)` without an error code; they abort the build of the target.

| Condition | Message |
|-----------|---------|
| Manifest not given or not present | `[Package] manifest not found` |
| `CRAFT_PKG_ARCHIVE` or `CRAFT_PKG_OUT_DIR` empty | `[Package] manifest is incomplete` |
| Build configuration differs from `config` | `'<name>' is built from configuration '<config>' only` |
| Kind `files`: a named file is missing | `file not found: <src>/<file>` |
| Kind `file`: file is missing | `file not found: <src>` |
| Kind `dir`: folder is missing | `folder not found: <src>` |
| Archive could not be written | `writing the archive failed (<result>)` |

---

## 6. See Also

- [Packages.cmake](Packages.md) — writes the manifest, creates the target
- [CMakeCraftPackage.cmake](../CMakeCraftPackage.md) — fetches the archive produced here and checks its SHA256

---

## 7. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2026-10-09** | **Initial (CMakeCraft v0.10.0): package folder, zip archive, checksum** |
