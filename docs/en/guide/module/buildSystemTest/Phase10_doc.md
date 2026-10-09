# phase10.cmake — Module Documentation

> **Version:** 1.1.0  
> **Date:** 2026-10-09  
> **Type:** ModuleDoc  
> **Path:** `cmake/buildSystemTest/phase10.cmake`  
> **Status:** Stable  
> **Language:** English  

---

## Table of Contents

1. [Overview](#1-overview)
2. [Tests](#2-tests)
3. [Success Flag](#3-success-flag)
4. [See Also](#4-see-also)
5. [Changelog](#5-changelog)

---

## 1. Overview

**Phase 10** tests **building and consuming prebuilt packages** — the `packages` block, the library fields `output_name` and `defines`, `CMakeCraftPackage.cmake` and the external kind `archive`.

| Aspect | Description |
|--------|-------------|
| **Purpose** | Validate packages and archive externals |
| **Debug ID** | `PHASE10_TEST` |
| **Dependencies** | Packages.cmake, CMakeCraftPackage.cmake, archive/Handler.cmake, Validation.cmake |
| **Condition** | Tests 2 and 3 only run if the demo library `PackDemo` resp. the demo package `packdemo` is present; otherwise they are skipped |

The test writes a miniature package below `<build>/phase10/` and fetches it from there. No network access, nothing is written into the source tree.

**Not exercised:** rejection of a wrong checksum. It is a warning by design and would clutter the selftest output.

---

## 2. Tests

### 2.1 Modules Available

Checks that these commands are defined:

| Command | Module |
|---------|--------|
| `craft_package_fetch` | CMakeCraftPackage.cmake |
| `craft_package_deploy` | CMakeCraftPackage.cmake |
| `_create_package_target` | Packages.cmake |
| `_handle_archive_external` | archive/Handler.cmake |
| `_apply_archive_external_to_target` | archive/Handler.cmake |

### 2.2 output_name and defines

Checked on the demo library `PackDemo` (only if the target exists):

| Property | Expected |
|----------|----------|
| `OUTPUT_NAME` | `PackDemo1` |
| `COMPILE_DEFINITIONS` | contains `PACK_DEMO_VERSION="1.2.0"` — `{version}` was replaced |

### 2.3 Package Target

Checks the demo package `packdemo` (only if `packages` is not empty and `PackDemo` exists):

| Check | Expected |
|-------|----------|
| Target `package_packdemo` | exists |
| `MANUALLY_ADDED_DEPENDENCIES` | contains `PackDemo` |
| `<build>/package/packdemo/VERSION` | line `produkt=<solution version>` — `version_file` was configured |

### 2.4 Fetch from URL and Cache

Creates a miniature package `phase10demo-v1.2.3` below `<build>/phase10/source/` (one header, a folder `tools`, the file `VERSION`), zips it and writes a pin file with a `file://` URL and the computed SHA256.

| Check | Expected |
|-------|----------|
| `craft_package_fetch()` | returns a non-empty root |
| Cache location | `<build>/phase10/url/.externals/phase10demo/v1.2.3` |
| Content | `include/phase10_demo.h` and `VERSION` exist |
| Second fetch with the source archive moved away | the same root — it comes from the cache |

### 2.5 Archive External via Fallback Path

Writes a second pin file whose URL points nowhere and whose `PHASE10DEMO_FALLBACK_PATHS` refers to `../source`. The external definition:

```json
{
    "archive": true,
    "pin": "<relative path to the pin file>",
    "include_dirs": ["include"],
    "define": "PHASE10_DEMO_VORHANDEN",
    "runtime": { "files": ["VERSION"], "dirs": ["tools"] }
}
```

| Check | Expected |
|-------|----------|
| `validate_external_source()` | accepts `archive` as source field |
| `ARCHIVE_EXTERNAL_phase10demo_ROOT` | `<build>/phase10/fallback/.externals/phase10demo/v1.2.3` |

### 2.6 Apply to a Target

Uses two INTERFACE libraries as probes (`_craft_phase10_probe`, `_craft_phase10_absent`).

| Check | Expected |
|-------|----------|
| `_apply_archive_external_to_target()` on the probe | `INTERFACE_INCLUDE_DIRECTORIES` contains `<root>/include` |
| | `INTERFACE_COMPILE_DEFINITIONS` contains `PHASE10_DEMO_VORHANDEN=1` |
| `craft_package_deploy(... ROOT "")` on the second probe | neither include path nor define — an absent package leaves the target untouched |

### 2.7 Runtime Files of an Executable

Uses two executables outside `ALL` (`_craft_phase10_exe`, `_craft_phase10_exe_plain`), source `<build>/phase10/main.cpp`.

| Check | Expected |
|-------|----------|
| `_apply_archive_external_to_target()` on `_craft_phase10_exe` | target `_craft_phase10_exe_deploy_phase10demo` exists |
| | `_craft_phase10_exe` depends on it (`MANUALLY_ADDED_DEPENDENCIES`) |
| the same with `{ "runtime": false }` on `_craft_phase10_exe_plain` | no deploy target |

The copy itself only runs when building: `cmake --build <build> --target _craft_phase10_exe`.

---

## 3. Success Flag

```cmake
set(PHASE10_TEST_PASSED TRUE CACHE BOOL "Phase 10 Test passed" FORCE)
```

---

## 4. See Also

- [Packages.md](../project/Packages.md)
- [PackageBuild.md](../project/PackageBuild.md)
- [CMakeCraftPackage.md](../CMakeCraftPackage.md)
- [archive/Handler_cmake.md](../externals/archive/Handler_cmake.md)
- [LibraryCreate.md](../project/LibraryCreate.md)

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.1.0** | **2026-10-09** | **CMakeCraft v0.11.0: test 7 (§2.7) — deploy target for runtime files** |
| 1.0.0 | 2026-10-09 | Initial (CMakeCraft v0.10.0) |
