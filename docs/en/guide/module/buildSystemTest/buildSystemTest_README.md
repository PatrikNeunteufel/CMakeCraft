# Build System Tests — Phase Test Documentation

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Language:** English  
> **German:** [buildSystemTest_README.md](../../../../de/guide/module/buildSystemTest/buildSystemTest_README.md)

---

## Quick Start

**Test the build system?**
```bash
cmake --preset craft-selftest                             # in the CMakeCraft repo
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=ON                # in general
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=ON -DTEST_PHASE=8  # Phase 8 only
```

**Understand a single phase?**
- [Phase1_doc.md](Phase1_doc.md) — core modules
- [Phase8_doc.md](Phase8_doc.md) — app container (new)

---

## Overview

The build system tests validate the correct functioning of all CMake modules. Each phase tests a specific part of the pipeline.

### Test Architecture

```
CMakeCraft.cmake  (after the pipeline)
     │
     └── if(RUN_BUILD_SYSTEM_TESTS)          ← Default OFF
             │   foreach 1..11, filtered by TEST_PHASE
             │
             ├── phase1.cmake  → Core modules
             ├── phase2.cmake  → Solution
             ├── phase3.cmake  → Executables
             ├── phase4.cmake  → Libraries
             ├── phase5.cmake  → Local Externals
             ├── phase6.cmake  → Git Externals
             ├── phase7.cmake  → Tests
             ├── phase8.cmake  → App container (new)
             ├── phase9.cmake  → System Externals
             ├── phase10.cmake → Packages, archive externals
             └── phase11.cmake → compile_options per library, source packages

Files: cmake/buildSystemTest/phase<n>.cmake
```

---

## Files

| File | Phase | Description |
|------|-------|-------------|
| [Phase1_doc.md](Phase1_doc.md) | 1 | Core modules (Errors, Debug, Context, Json, etc.) |
| [Phase2_doc.md](Phase2_doc.md) | 2 | Solution.cmake, JSON loading |
| [Phase3_doc.md](Phase3_doc.md) | 3 | Executable pipeline |
| [Phase4_doc.md](Phase4_doc.md) | 4 | Library pipeline |
| [Phase5_doc.md](Phase5_doc.md) | 5 | Local Externals |
| [Phase6_doc.md](Phase6_doc.md) | 6 | Git Externals + hooks |
| [Phase7_doc.md](Phase7_doc.md) | 7 | Test pipeline |
| [Phase8_doc.md](Phase8_doc.md) | 8 | App container pipeline |
| [Phase9_doc.md](Phase9_doc.md) | 9 | System Externals, entry point of Qt GUI programs |
| [Phase10_doc.md](Phase10_doc.md) | 10 | Packages, CMakeCraftPackage, archive externals |
| [Phase11_doc.md](Phase11_doc.md) | 11 | compile_options per library, source package, E105, E106 |

---

## Phase Overview

| Phase | Status | Modules | Tests |
|-------|--------|---------|-------|
| **1** | ✅ Stable | Errors, Debug, Context, Json, Validation, OutputDirs, Warnings, CompilerOptions, SourceCollect | Module availability, function tests |
| **2** | ✅ Stable | Solution | JSON loading, properties |
| **3** | ✅ Stable | Executables, ExecutableCollect, ExecutableCreate | Target creation, linking |
| **4** | ✅ Stable | Libraries, LibraryCollect, LibraryCreate | STATIC/SHARED, dependencies |
| **5** | ✅ Stable | Externals (Local) | Local attach, include files |
| **6** | ✅ Stable | Externals (Git) | FetchContent, hooks, caching |
| **7** | ✅ Stable | Tests, TestCollect, TestCreate | Framework integration, CTest |
| **8** | ✅ In development | Apps, AppCollect, AppCreate | Core/Runner/Tests targets |
| **9** | ✅ Stable | Externals (System), system/Handler, system/PathResolver, system/packages/Qt6 | Type detection, fields, type priority, package hooks, entry point of Qt GUI programs |
| **10** | ✅ Stable | Packages, CMakeCraftPackage, archive/Handler | Package target, output_name/defines, fetch via URL/cache/fallback path, apply to target |
| **11** | ✅ Stable | LibraryCreate, SourcePackage, PackageBuild, CompilerOptions | compile_options on the target, generated CMakeLists.txt, build the package, build and run a consumer without CMakeCraft, E105, E106 |

---

## Test Flags

| Flag | Default | Description |
|------|---------|-------------|
| `RUN_BUILD_SYSTEM_TESTS` | OFF | Enable build system tests (in the CMakeCraft repo: preset `craft-selftest`) |
| `TEST_PHASE` | "" (all) | Test specific phase(s) (`1`–`11`, list separated by `;`); only takes effect with `RUN_BUILD_SYSTEM_TESTS=ON` |
| `BUILD_TESTS` | OFF | Enable project tests (for phase 7/8) |

### Examples

```bash
# Test all phases (in the CMakeCraft repo)
cmake --preset craft-selftest

# Test all phases (in general)
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=ON

# Test phase 8 only
cmake --preset craft-selftest -DTEST_PHASE=8

# Phase 7+8 with project tests
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=ON -DBUILD_TESTS=ON -DTEST_PHASE="7;8"

# Afterwards without phase tests again (reset the cache value)
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=OFF
```

---

## Test Output

Each phase emits debug output with its own tag:

```
-- [Phase8] === Phase 8 Test Start ===
-- [Phase8] Test 1: Apps array parsing...
-- [Phase8]   Found 1 app(s) in Solution.json
-- [Phase8] Test 3: App-Container targets...
-- [Phase8]   Core Library: DemoPlayer.Core
-- [Phase8]   Runner Executable: DemoPlayer
-- [Phase8] === Phase 8 Test PASSED ===
```

---

## Success Flags

Each phase sets a cache flag on success:

| Phase | Flag |
|-------|------|
| 1 | `PHASE1_TEST_PASSED` |
| 2 | `PHASE2_TEST_PASSED` |
| 3 | `PHASE3_TEST_PASSED` |
| 4 | `PHASE4_TEST_PASSED` |
| 5 | `PHASE5_TEST_PASSED` |
| 6 | `PHASE6_TEST_PASSED` |
| 7 | `PHASE7_TEST_PASSED` |
| 8 | `PHASE8_TEST_PASSED` |
| 9 | `PHASE9_TEST_PASSED` |
| 10 | `PHASE10_TEST_PASSED` |
| 11 | `PHASE11_TEST_PASSED` |

---

## See Also

- [../README.md](../README.md) — module overview
- [Implementation_Plan.md](../../../konzepte/abgeschlossen/Implementation_Plan.md) — phase planning
- [../../references/ErrorCodes.md](../../references/ErrorCodes.md) — error codes

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: `RUN_BUILD_SYSTEM_TESTS` default `OFF`, preset `craft-selftest`; phase tests run from `CMakeCraft.cmake`, file names `phase<n>.cmake` in lowercase; `TEST_PHASE` only takes effect together with `RUN_BUILD_SYSTEM_TESTS=ON`** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
