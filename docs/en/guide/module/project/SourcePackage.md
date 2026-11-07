# SourcePackage.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2026-11-07  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [SourcePackage.md](../../../../de/guide/module/project/SourcePackage.md)  
> **Module:** [`cmake/project/SourcePackage.cmake`](../../../../../cmake/project/SourcePackage.cmake)  
> **Module Version:** 1.0.0  
> **Phase:** 11 (Source Packages)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [API Reference](#3-api-reference)
4. [Processing](#4-processing)
5. [Error Handling](#5-error-handling)
6. [See Also](#6-see-also)
7. [Changelog](#7-changelog)

---

## 1. Overview

`SourcePackage.cmake` creates the target `package_<name>` for an entry `{ "name": …, "library": … }` in the `packages` block. The package contains the sources of a **STATIC library** and a generated `CMakeLists.txt` in plain CMake: a consumer without CMakeCraft includes it with `add_subdirectory()` and compiles the library with the same switches.

### Core Idea

Everything the `CMakeLists.txt` needs is known at configure time — CMakeCraft has just created the library. The module reads the description that [LibraryCreate.cmake](LibraryCreate.md) leaves on the target (`CRAFT_LIB_*`, `CRAFT_EXT_*`) and writes the `CMakeLists.txt` with `file(WRITE)`. This way generator expressions in `compile_options` stay **verbatim**; `file(GENERATE)` would resolve them for the own compiler. Only the checksums of the external folders depend on the content at build time; for these the text holds a placeholder that [PackageBuild.cmake](PackageBuild.md) replaces.

### Result of a Build of `package_<name>`

See [Packages.md](../../references/Packages.md) §2.5: `src/`, `include/`, `externals/<ext>/`, `CMakeLists.txt`, `VERSION`, `SHA256SUMS`, plus `.zip` and `.zip.sha256`.

---

## 2. Dependencies

| Module | Usage |
|--------|-------|
| Errors.cmake | `cmake_fatal`, `cmake_warn` |
| Debug.cmake | `dbg` |
| Json.cmake | `_json_get_string`, `_json_get_string_or_default`, `_json_has_key`, `_json_get_object`, `_json_get_bool_or_default` |
| CompilerOptions.cmake | `craft_language_rules` — the language rules of all compiler families |
| LibraryCreate.cmake | Target properties `CRAFT_LIB_*`, `CRAFT_EXT_*`, `CRAFT_PUBLIC_HEADERS_DIR` |
| Packages.cmake | calls `_create_source_package_target()` for entries with `library` |
| PackageBuild.cmake | is run at build time via `cmake -P` |

---

## 3. API Reference

### 3.1 _create_source_package_target()

```cmake
_create_source_package_target(<PKG_JSON> <NAME>)
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `PKG_JSON` | String | ✓ | JSON string of the entry |
| `NAME` | String | ✓ | its field `name` |

Creates the target `package_<name>` (not in `ALL`), plus `package/<name>/CMakeLists.txt.in` and `package/<name>/manifest-source.cmake` in the build folder. The target carries the properties `CRAFT_PACKAGE_MANIFEST` and `CRAFT_PACKAGE_CMAKELISTS` (read by the phase test).

### 3.2 Helper Functions (internal)

| Function | Purpose |
|----------|---------|
| `_craft_pkg_bracket(VALUE OUT)` | Value as CMake bracket argument `[=[…]=]`, so that quotes and `$<…>` stay unchanged |
| `_craft_pkg_place(PATH SRC_DIR PUB_DIR OUT)` | Location of a path in the package: `include/…` below the public headers, `src/…` below `path`, otherwise empty |
| `_craft_pkg_external(LIB EXT CODE ROOT DROP)` | Block of the `CMakeLists.txt` for a local external; folder and `Include.cmake` to leave out |

---

## 4. Processing

```
_create_source_package_target(PKG_JSON NAME)
    │
    ├── 1. contents / config / version_file present? → E001
    ├── 2. library missing → W112, no target
    ├── 3. not STATIC → E106;  C++20 modules → E106
    │
    ├── 4. Classify files (_craft_pkg_place)
    │   ├── below public_headers → include/… (comes with the folder)
    │   ├── below path           → src/…     (copied one by one)
    │   └── otherwise            → E106
    │   Likewise the private includes and the PCH header
    │
    ├── 5. Externals (_craft_pkg_external)
    │   ├── not local (system, git, archive) → E106
    │   ├── CRAFT_EXT_<ext>_OTHER set (target changed directly) → E106
    │   └── per linked target: INTERFACE, not imported, no link libraries,
    │       sources, link options, PCH; include folders inside the external folder → otherwise E106
    │       → block "if(NOT TARGET …) add_library(… INTERFACE) … else() compare checksum"
    │
    ├── 6. Write CMakeLists.txt.in (file(WRITE))
    │   ├── Check: target already exists / dependencies missing
    │   ├── Externals, add_library(STATIC) + alias <name>::<name>
    │   ├── Include folders, defines
    │   ├── if(MSVC) / elseif(GNU|Clang): craft_language_rules
    │   ├── compile_options (verbatim)
    │   ├── cxx_std_<n>, CXX_STANDARD, CXX_STANDARD_REQUIRED, CXX_EXTENSIONS
    │   ├── OUTPUT_NAME, VERSION, PCH
    │   └── target_link_libraries: dependencies (PUBLIC), externals (PUBLIC/PRIVATE as linked)
    │
    └── 7. Write the manifest, add_custom_target(package_<name> … PackageBuild.cmake)
```

`craft_language_rules` is called without flags — exactly as `apply_compiler_options(${name})` in LibraryCreate.cmake sets the language rules for a library. If `CXX_EXTENSIONS` is missing on the target (not set in the solution), the module writes `ON`, the CMake default for GNU and Clang.

---

## 5. Error Handling

| Code | Condition |
|------|-----------|
| E001 | `library` empty, or together with `contents`, `config` or `version_file` |
| E106 | Library not STATIC; C++20 modules; file, include folder or PCH outside `path` and `public_headers` |
| E106 | External not local; changes the target directly; brings a target that is not a header-only INTERFACE target; include folder outside its folder |
| W112 | Library does not exist (skipped, other platform) — `package_<name>` is not created |

---

## 6. See Also

- [Packages.md](../../references/Packages.md) §2.5 — reference for users
- [Packages.cmake](Packages.md) — the `packages` block
- [PackageBuild.cmake](PackageBuild.md) — build-time script
- [LibraryCreate.cmake](LibraryCreate.md) — description on the target
- [CompilerOptions.cmake](../core/CompilerOptions.md) — `craft_language_rules`
- [Phase11_doc.md](../buildSystemTest/Phase11_doc.md) — phase test

---

## 7. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2026-11-07** | **Initial (CMakeCraft v0.14.0): source package of a STATIC library with generated plain CMakeLists.txt, carried-over local externals, E106** |
