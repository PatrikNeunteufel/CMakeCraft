# phase12.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2026-11-26  
> **Type:** ModuleDoc  
> **Path:** `cmake/buildSystemTest/phase12.cmake`  
> **Status:** Stable  
> **Language:** English  
> **German:** [Phase12_doc.md](../../../../de/guide/module/buildSystemTest/Phase12_doc.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Tests](#2-tests)
3. [Success Flag](#3-success-flag)
4. [See Also](#4-see-also)
5. [Changelog](#5-changelog)

---

## 1. Overview

**Phase 12** tests the target for the API reference from the block `documentation.doxygen`
(CMakeCraft v0.15.0). Doxygen runs with the project's own Doxyfile in the project root.

| Aspect | Description |
|--------|-------------|
| **Purpose** | Validate target `docs`, `target`, Doxygen exit code, W202, E107, E001 |
| **Debug ID** | `PHASE12_TEST` |
| **Dependencies** | Documentation.cmake |
| **Demo** | none — the demo solution has no `documentation` block; everything runs in nested projects |
| **Condition** | Tests 2–3 run only if Doxygen is installed (otherwise a note in the output) |

Everything is written below `<build>/phase12/`. The nested projects use generator, platform,
toolset, `CMAKE_MAKE_PROGRAM` and compiler of this build. Each has a `Solution.json` with only
`documentation`, a header `src/phase12.h` (one documented and one undocumented function) and a
Doxyfile with `INPUT = src` and `OUTPUT_DIRECTORY = apidoc`, both relative to the project root.

---

## 2. Tests

### 2.1 Module Loaded, No Target Without the Block

`_create_doxygen_target` is defined. If the demo solution has no `documentation` block, there is
no target `docs`.

### 2.2 Project's Own Doxyfile, Not Part of ALL

`{ "doxygen": { "doxyfile": "Doxyfile" } }`: configuring without W202. The ordinary build does not
create `apidoc/`; `--target docs` writes `apidoc/html/index.html` **in the project root** — which
shows that Doxygen runs there.

### 2.3 Own Target Name, Exit Code Passed Through

Doxyfile `doc/Strict.doxyfile` (in a subfolder; `INPUT = src` still applies relative to the root)
with `EXTRACT_ALL = NO`, `WARN_IF_UNDOCUMENTED = YES`, `WARN_AS_ERROR = YES` and
`"target": "apidocs"`. The target `apidocs` must fail, and the output must name
`phase12_undocumented`.

### 2.4 Doxygen Not Found: W202

Configuring with `-DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=TRUE` succeeds and reports `[W202]`;
`--target docs` fails with "Doxygen not found".

### 2.5 E107

`"doxyfile": "Missing.doxyfile"` must abort with `[E107]` and name the file (both searched
separately, because CMake wraps long messages).

### 2.6 E001

`{ "doxygen": { "target": "docs" } }` without `doxyfile` must abort with `[E001]` and name the
field.

---

## 3. Success Flag

```cmake
set(PHASE12_TEST_PASSED TRUE CACHE BOOL "Phase 12 Test passed" FORCE)
```

---

## 4. See Also

- [Documentation.cmake](../project/Documentation.md)
- [Solution_Schema.md](../../references/Solution_Schema.md) §10

---

## 5. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2026-11-26** | **Initial (CMakeCraft v0.15.0)** |
