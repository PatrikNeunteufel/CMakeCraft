# phase11.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2026-11-07  
> **Type:** ModuleDoc  
> **Path:** `cmake/buildSystemTest/phase11.cmake`  
> **Status:** Stable  
> **Language:** English  
> **German:** [Phase11_doc.md](../../../../de/guide/module/buildSystemTest/Phase11_doc.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Tests](#2-tests)
3. [Success Flag](#3-success-flag)
4. [See Also](#4-see-also)
5. [Changelog](#5-changelog)

---

## 1. Overview

**Phase 11** tests `compile_options` on libraries and the **source package of a library** (CMakeCraft v0.14.0) — up to a plain CMake project without CMakeCraft that includes, builds and runs the package.

| Aspect | Description |
|--------|-------------|
| **Purpose** | Validate `compile_options` per library, source package, E105, E106 |
| **Debug ID** | `PHASE11_TEST` |
| **Dependencies** | LibraryCreate.cmake, SourcePackage.cmake, PackageBuild.cmake, CompilerOptions.cmake |
| **Demo** | Library `CalcDemo` (STATIC, `compile_options` per compiler family, `defines`), local header external `calcext` with its own `Include.cmake` (INTERFACE target with `SYSTEM` include and define `CALCEXT_NO_THREADS`), package `calcdemo` |
| **Condition** | Tests 2–5 only run if `CalcDemo` and `package_calcdemo` are present |

Everything is written below `<build>/phase11/`. The nested projects (tests 5–7) use generator, platform, toolset, `CMAKE_MAKE_PROGRAM` and compiler of this build; no network access. The phase configures three projects and builds one — it takes considerably longer than the others (Ninja/Clang about 12 s, Visual Studio about 40 s).

`calcext.h` aborts with `#error` if `CALCEXT_NO_THREADS` is missing: a package that only carries over the include folder of the external is caught in test 5.

---

## 2. Tests

### 2.1 Functions Available

`craft_language_rules`, `_create_source_package_target`, `_craft_target_snapshot`, `_craft_record_external_effect` are defined.

### 2.2 compile_options on the Library

The `compile_options` of `CalcDemo` from `Solution.json` are the **last** entries in `COMPILE_OPTIONS` of the target; every language rule of the current compiler (`craft_language_rules`) comes before them.

### 2.3 Generated CMakeLists.txt

The template of `package_calcdemo` contains the generator expressions verbatim, `add_library(CalcDemo STATIC`, the alias, the INTERFACE target `calcext` with `CALCEXT_NO_THREADS`, the define of the library, the link and the checksum placeholder; `CXX_EXTENSIONS` is as on the target. It does **not** contain `CMakeCraft.cmake`, `CMAKECRAFT_`, `include(`, `craft_language`, `/W4`, `/MP`, `/bigobj`.

### 2.4 Build the Package

`PackageBuild.cmake` runs with a copy of the manifest whose output folder lies below `<build>/phase11/out`. Checked: `CMakeLists.txt`, `VERSION` (= `0.3.0\n`, version of the library), `SHA256SUMS`, `include/calc_demo.h`, `src/calc_demo.cpp`, `src/calc_detail.h`, `externals/calcext/calcext.h` and `LICENSE.md` present; `externals/calcext/Include.cmake` and `src/Source.cmake` **not**; `.zip` and `.zip.sha256` present; no placeholder left in the `CMakeLists.txt`. `CMakeLists.txt`, `VERSION`, `SHA256SUMS` and `.zip.sha256` contain no CR (read as hex — a text read hides the CR on Windows). `SHA256SUMS`: every line in the format of `sha256sum`, every checksum matches, every file exactly once, sorted.

### 2.5 Plain CMake Project as Consumer

A project without CMakeCraft (`add_subdirectory` of the unpacked package, `add_executable`, `target_link_libraries(… CalcDemo::CalcDemo)`) checks at configure time that the first option of the library is on its target, and is built and run. The exe computes `mul_add(0.1, 10.0, -1.0)` (two roundings yield exactly 0) and checks the value from `calcext`; expected: exit 0 and `calc_demo 0`.

### 2.6 E105

A nested CMakeCraft project with an INTERFACE library with `compile_options` must abort with `[E105]`.

### 2.7 E106

A nested CMakeCraft project with a STATIC library that names the system external `Threads`, and a source package of this library, must abort with `[E106]` and name the external.

---

## 3. Success Flag

```cmake
set(PHASE11_TEST_PASSED TRUE CACHE BOOL "Phase 11 Test passed" FORCE)
```

---

## 4. See Also

- [SourcePackage.cmake](../project/SourcePackage.md)
- [Packages.md](../../references/Packages.md) §2.5
- [Phase10_doc.md](Phase10_doc.md) — packages and archive externals

---

## 5. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2026-11-07** | **Initial (CMakeCraft v0.14.0)** |
