# CMakeLists.txt — Reference

> **Version:** 1.0.2  
> **Date:** 2026-11-09  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [CMakeLists.md](../../../de/guide/module/CMakeLists.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Structure](#2-structure)
3. [Phases](#3-phases)
4. [Options](#4-options)
5. [Module Load Order](#5-module-load-order)
6. [Console Output](#6-console-output)
7. [Build System Tests](#7-build-system-tests)
8. [Directory Structure](#8-directory-structure)
9. [Best Practices](#9-best-practices)
10. [Troubleshooting](#10-troubleshooting)
11. [See Also](#11-see-also)
12. [Changelog](#changelog)

---

## 1. Overview

Since v0.7.0 the entry point of the build system is the file **`CMakeCraft.cmake`** in the repo root. It is
**self-locating**: it sets `CMAKECRAFT_DIR` to the `cmake/` folder next to it (and `CMAKECRAFT_ROOT` to its own
folder) and loads every module through `${CMAKECRAFT_DIR}`. CMakeCraft can therefore live anywhere (snapshot in the
project, checkout under `.externals/`, submodule, sibling directory).

The `CMakeLists.txt` of a project — including that of the CMakeCraft repo itself — is only a **thin wrapper**: it
calls `cmake_minimum_required()` and `project()` and includes `CMakeCraft.cmake`. The CMakeCraft repo thus uses its
entry point exactly like a consumer does ("dogfooding" against the demo `Solution.json`).

Project-owned inputs stay relative to the **consuming project** (`CMAKE_SOURCE_DIR`): `Solution.json`,
`projects/`, `externals/`, `.externals/`.

### Responsibilities

| File | Task |
|------|------|
| **`CMakeLists.txt`** (project) | Minimum version (3.26), `project(<Name> LANGUAGES NONE)`, `include(…/CMakeCraft.cmake)` |
| **`CMakeCraft.cmake`** | Include guard, self-location (`CMAKECRAFT_DIR`), options, load core modules, process `Solution.json`, `project()` with name/version from the solution, pipelines in fixed order, optional build system tests |

### Minimal CMakeLists.txt

This is the `CMakeLists.txt` of the CMakeCraft repo (consumers look the same, with their own path to `CMakeCraft.cmake`):

```cmake
cmake_minimum_required(VERSION 3.26)
project(CMakeCraft LANGUAGES NONE)   # name/version come from Solution.json

include("${CMAKE_CURRENT_LIST_DIR}/CMakeCraft.cmake")
```

The line `project(<Name> LANGUAGES NONE)` is **required** since v0.13.0 (otherwise E005, see
[10.2](#102-e005-no-project-line)). Name and version of the project still come from `Solution.json`:
`CMakeCraft.cmake` calls `project()` a second time with these values and `LANGUAGES C CXX`.

How a consumer obtains CMakeCraft (bootstrap fetch via `cmakecraft.pin`, development against a working copy with
`-DCMAKECRAFT_LOCAL_DIR=<checkout>`) is described in the [Neues_Projekt_Guide](../userguides/Neues_Projekt_Guide.md).

---

## 2. Structure

### 2.1 Sections of `CMakeCraft.cmake`

| Section | Description |
|---------|-------------|
| **Include guard** | `CMAKECRAFT_INCLUDED` — a project loads the build system only once |
| **Self-location** | `CMAKECRAFT_ROOT` = folder of `CMakeCraft.cmake`, `CMAKECRAFT_DIR` = `${CMAKECRAFT_ROOT}/cmake` |
| **Options** | `BUILD_TESTS`, `RUN_BUILD_SYSTEM_TESTS`, `TEST_PHASE` |
| **Phase 1** | Load core modules (10 modules) |
| **Info** | Debug output about the configuration (ID `CMAKE_MAIN`) |
| **Phase 2** | Load `project/Solution.cmake` |
| **Project** | Check for a `project()` line (E005), `project()` with name/version from the solution, `craft_setup_testing_configuration()` |
| **Testing** | `enable_testing()` when `BUILD_TESTS` is on — before any `add_test()` call |
| **Phase 5 & 6** | Externals (local, fetched, system, archive) — before libraries and executables |
| **Phase 4** | Libraries — before executables |
| **Phase 3** | Executables |
| **Phase 8** | App containers |
| **Phase 10** | Packages (needs the targets above) |
| **Phase 7** | Tests (only with `BUILD_TESTS`) |
| **Build system tests** | Phase tests 1–11 (only with `RUN_BUILD_SYSTEM_TESTS`) |
| **Cleanup** | Clean up temporary variables |

### 2.2 Phase Numbers

> **Note:** The phase numbers reflect the **development order**, not the execution order.
> Externals (phase 5/6) run before libraries (phase 4), libraries before executables (phase 3).

---

## 3. Phases

### Overview

| Phase | Name | Modules | Status |
|-------|------|---------|--------|
| **1** | Core | Errors, Debug, Json, Validation, Context, SourceCollect, OutputDirs, Warnings, CompilerOptions, Configurations | ✅ |
| **2** | Solution | Solution | ✅ |
| **3** | Executables | Executables, ExecutableCollect, ExecutableCreate | ✅ |
| **4** | Libraries | Libraries, LibraryCollect, LibraryCreate | ✅ |
| **5** | Local externals | Externals, externals/Orchestrator, local/Attach, includes/\<name\>/Include, registry/Targets | ✅ |
| **6** | Git externals & hooks | core/Fetch, fetched/Handler, hooks/HookLoader (+ prefetch/postfetch) | ✅ |
| **7** | Tests | Tests, TestCollect, TestCreate | ✅ |
| **8** | App container | Apps, AppCollect, AppCreate | ✅ |
| **9** | System externals | system/Handler, system/PathResolver, system/packages (Qt6, Boost) | ✅ |
| **10** | Packages & archive externals | Packages, PackageBuild (build-time script), archive/Handler, `CMakeCraftPackage.cmake` | ✅ |
| **11** | Library `compile_options` & source package | LibraryCreate, SourcePackage | ✅ |

### Execution Order

```
 1. Core modules     (Phase 1)
 2. Solution         (Phase 2)
 3. project()        ← name/version from Solution.json
 4. enable_testing() ← only with BUILD_TESTS
 5. Externals        (Phase 5, 6, 9, 10) ← BEFORE libraries and executables!
 6. Libraries        (Phase 4)  ← BEFORE executables!
 7. Executables      (Phase 3)
 8. Apps             (Phase 8)
 9. Packages         (Phase 10, 11) ← needs the targets above
10. Tests            (Phase 7)  ← only with BUILD_TESTS
11. Phase tests 1–11            ← only with RUN_BUILD_SYSTEM_TESTS
```

---

## 4. Options

### 4.1 Cache Variables

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `BUILD_TESTS` | BOOL | `OFF` | Build project tests (`enable_testing()`, phase 7, test targets of apps) |
| `RUN_BUILD_SYSTEM_TESTS` | BOOL | `OFF` | Run the build system phase tests; in the CMakeCraft repo via the preset `craft-selftest` |
| `TEST_PHASE` | STRING | `""` | Test only these phase(s), `1`–`11`; empty = all |
| `DEBUG_MESSAGES` | BOOL | `ON` | Master switch of the debug output (`Debug.cmake`) |
| `DEBUG_DEFAULT_LEVEL` | STRING | `2` | SHOW level for debug contexts without their own `LEVEL` (1–5) |
| `BUILD_ONLY` | STRING | `""` | Create only these libraries/executables/apps (list separated by `;`); not an `option()`, read by the pipelines and set in the presets |

`CMakeCraft.cmake` defines `BUILD_TESTS`, `RUN_BUILD_SYSTEM_TESTS` and `TEST_PHASE`; `core/Debug.cmake` sets
`DEBUG_MESSAGES` and `DEBUG_DEFAULT_LEVEL` unless they are already defined.

### 4.2 Usage

```bash
# Standard build (no project tests, no phase tests)
cmake -B build

# Build project tests
cmake -B build -DBUILD_TESTS=ON

# Self-test of the build system (in the CMakeCraft repo)
cmake --preset craft-selftest

# Test phase 4 only
cmake --preset craft-selftest -DTEST_PHASE=4

# Switch debug output off entirely
cmake -B build -DDEBUG_MESSAGES=OFF

# Specific target only
cmake -B build -DBUILD_ONLY="MyApp"

# Set Qt6 path
cmake -B build -DCMAKE_PREFIX_PATH=/path/to/Qt/6.6.0/gcc_64
```

### 4.3 Debug Levels

Each output `dbg(<freq> …)` appears when its frequency level is ≤ the SHOW level of the context.

| SHOW level | Constant | Description |
|------------|----------|-------------|
| 1 | `DBG_SHOW_LITTLE` | Only the essentials |
| 2 | `DBG_SHOW_SOME` | Standard (default of `DEBUG_DEFAULT_LEVEL`) |
| 3 | `DBG_SHOW_MUCH` | More details |
| 4 | `DBG_SHOW_LOTS` | Many details |
| 5 | `DBG_SHOW_ALL` | Everything |

`DEBUG_DEFAULT_LEVEL` only affects contexts without their own `LEVEL`. The pipelines set their level themselves
(`CMAKE_MAIN`, `SOLUTION`, `EXTERNALS`, `LIBRARIES`, `EXECUTABLES`, `APPS`, `PACKAGES`: `DBG_SHOW_MUCH`;
`BUILD_TEST`: `DBG_SHOW_ALL`).

---

## 5. Module Load Order

### 5.1 Phase 1: Core Modules

The order is **critical** — later modules depend on earlier ones:

```cmake
include("${CMAKECRAFT_DIR}/core/Errors.cmake")          # 1. Error handling
include("${CMAKECRAFT_DIR}/core/Debug.cmake")           # 2. Debug output
include("${CMAKECRAFT_DIR}/core/Json.cmake")            # 3. JSON parsing
include("${CMAKECRAFT_DIR}/core/Validation.cmake")      # 4. Validation
include("${CMAKECRAFT_DIR}/core/Context.cmake")         # 5. Context system
include("${CMAKECRAFT_DIR}/core/SourceCollect.cmake")   # 6. Source collection
include("${CMAKECRAFT_DIR}/core/OutputDirs.cmake")      # 7. Output directories
include("${CMAKECRAFT_DIR}/core/Warnings.cmake")        # 8. Compiler warnings
include("${CMAKECRAFT_DIR}/core/CompilerOptions.cmake") # 9. Compiler options
include("${CMAKECRAFT_DIR}/core/Configurations.cmake")  # 10. Testing configuration
```

### 5.2 Phase 2: Solution

```cmake
include("${CMAKECRAFT_DIR}/project/Solution.cmake")
```

Loads and validates `Solution.json` from `CMAKE_SOURCE_DIR` and stores name and version in the global properties
`SOLUTION_NAME` and `SOLUTION_VERSION`.

### 5.3 project() Call

```cmake
get_property(_sol_name GLOBAL PROPERTY SOLUTION_NAME)
get_property(_sol_version GLOBAL PROPERTY SOLUTION_VERSION)

project("${_sol_name}" VERSION "${_sol_version}" LANGUAGES C CXX)

craft_setup_testing_configuration()
```

Before that, `CMakeCraft.cmake` checks that the project's `CMakeLists.txt` has a `project()` line of its own (E005).

### 5.4 Phase 5/6: Externals

```cmake
include("${CMAKECRAFT_DIR}/project/Externals.cmake")
```

Loads the externals orchestrator (`externals/Orchestrator.cmake`) with the handlers for local, fetched, system and
archive externals. **Runs before libraries and executables**, so that their targets find the externals.

### 5.5 Phase 4: Libraries

```cmake
include("${CMAKECRAFT_DIR}/project/Libraries.cmake")
```

**Must be loaded before executables!** Executables can link against libraries.

### 5.6 Phase 3: Executables

```cmake
include("${CMAKECRAFT_DIR}/project/Executables.cmake")
```

### 5.7 Phase 8: App Container

```cmake
include("${CMAKECRAFT_DIR}/project/Apps.cmake")
```

### 5.8 Phase 10: Packages

```cmake
include("${CMAKECRAFT_DIR}/project/Packages.cmake")
```

Creates the targets `package_<name>` (loads `SourcePackage.cmake` for source packages, phase 11).

### 5.9 Phase 7: Tests

```cmake
if(BUILD_TESTS)
    include("${CMAKECRAFT_DIR}/project/Tests.cmake")
endif()
```

---

## 6. Console Output

### 6.1 Rule

> **Console output goes through the debug system (`dbg()`).**  
> No direct `message()` calls except for errors via `cmake_fatal()`.

### 6.2 Debug IDs

| ID | Module | Description |
|----|--------|-------------|
| `CMAKE_MAIN` | CMakeCraft.cmake | Main configuration (tag `CMake`) |
| `BUILD_TEST` | CMakeCraft.cmake | Build system tests (tag `BuildTest`) |
| `SOLUTION` | Solution.cmake | Solution processing |
| `EXTERNALS` | Externals.cmake | Externals pipeline |
| `LIBRARIES` | Libraries.cmake | Library pipeline |
| `EXECUTABLES` | Executables.cmake | Executable pipeline |
| `APPS` | Apps.cmake | App container pipeline |
| `PACKAGES` | Packages.cmake | Package pipeline |
| `TESTS` | TestCollect.cmake | Test collection; `Tests.cmake` itself writes with `message(STATUS "[Tests] …")` |

### 6.3 Example Output

The frame comes from `CMakeCraft.cmake` (ID `CMAKE_MAIN`); in between, the pipelines write with their own tag
(`[Solution]`, `[Externals]`, `[Libraries]`, `[Executables]`, `[Apps]`, `[Packages]`, `[Tests]`):

```
-- [CMake] === CMakeCraft (CMake Architecture V2) ===
-- [CMake] CMakeCraft Dir: <path>/CMakeCraft/cmake
-- [CMake] CMake Version: <version>
-- [CMake] Generator: Ninja
-- [CMake] Build Tests: OFF
-- [CMake] Build System Tests: OFF
-- [Solution] …
-- [CMake] Project: <Name> v<Version>
-- [Externals] …
-- [Libraries] …
-- [Executables] …
-- [Apps] …
-- [Packages] …
-- 
-- [CMake] === Configuration Complete ===
-- -------------------------------------------
```

---

## 7. Build System Tests

### 7.1 Phase Tests

The phase tests live under `cmake/buildSystemTest/` and run after the pipeline when `RUN_BUILD_SYSTEM_TESTS` is on
(default `OFF`). "Green" means: configure without errors.

| Phase | File | Tests |
|-------|------|-------|
| 1 | `phase1.cmake` | Core modules |
| 2 | `phase2.cmake` | Solution.cmake (properties, settings) |
| 3 | `phase3.cmake` | Executable pipeline |
| 4 | `phase4.cmake` | Library pipeline |
| 5 | `phase5.cmake` | Externals pipeline (local externals) |
| 6 | `phase6.cmake` | Git externals and hooks |
| 7 | `phase7.cmake` | Test pipeline |
| 8 | `phase8.cmake` | App container pipeline |
| 9 | `phase9.cmake` | System externals |
| 10 | `phase10.cmake` | Packages and archive externals |
| 11 | `phase11.cmake` | `compile_options` of libraries and source packages |

### 7.2 Test Flags

After a successful test each phase sets a cache flag, `PHASE1_TEST_PASSED` to `PHASE11_TEST_PASSED`:

```cmake
set(PHASE1_TEST_PASSED TRUE CACHE BOOL "Phase 1 Test passed" FORCE)
```

### 7.3 Enable

```bash
# In the CMakeCraft repo: preset (Ninja Clang Debug + RUN_BUILD_SYSTEM_TESTS=ON)
cmake --preset craft-selftest

# In general
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=ON
```

In consumer projects the phase tests are only needed as a smoke check after a snapshot sync.

### 7.4 Test a Single Phase

```bash
cmake --preset craft-selftest -DTEST_PHASE=4
```

---

## 8. Directory Structure

```
CMakeCraft/
├── CMakeLists.txt              ← thin wrapper (this file)
├── CMakeCraft.cmake            ← entry point of the build system
├── CMakeCraftPackage.cmake     ← standalone: fetch and deploy prebuilt packages
├── CMakePresets.json           ← incl. preset craft-selftest
├── Solution.json               ← project configuration (demo solution)
├── cmake/                      ← = CMAKECRAFT_DIR
│   ├── core/                   ← Phase 1: core modules
│   │   ├── Errors.cmake
│   │   ├── Debug.cmake
│   │   ├── Json.cmake
│   │   ├── Validation.cmake
│   │   ├── Context.cmake
│   │   ├── SourceCollect.cmake
│   │   ├── OutputDirs.cmake
│   │   ├── Warnings.cmake
│   │   ├── CompilerOptions.cmake
│   │   └── Configurations.cmake
│   ├── project/                ← Phase 2–4, 7, 8, 10, 11: project modules
│   │   ├── Solution.cmake
│   │   ├── Libraries.cmake, LibraryCollect.cmake, LibraryCreate.cmake
│   │   ├── Executables.cmake, ExecutableCollect.cmake, ExecutableCreate.cmake
│   │   ├── Externals.cmake
│   │   ├── Apps.cmake, AppCollect.cmake, AppCreate.cmake
│   │   ├── Packages.cmake, PackageBuild.cmake, SourcePackage.cmake
│   │   └── Tests.cmake, TestCollect.cmake, TestCreate.cmake
│   ├── externals/              ← externals system (phase 5, 6, 9, 10)
│   │   ├── Orchestrator.cmake
│   │   ├── core/Fetch.cmake
│   │   ├── local/Attach.cmake
│   │   ├── fetched/Handler.cmake
│   │   ├── system/Handler.cmake, PathResolver.cmake, packages/
│   │   ├── archive/Handler.cmake
│   │   ├── hooks/HookLoader.cmake, prefetch/, postfetch/
│   │   ├── registry/Targets.cmake
│   │   └── includes/           ← Include.cmake per local external
│   │       ├── bass/
│   │       ├── doctest/
│   │       ├── glad/
│   │       └── lua54/
│   └── buildSystemTest/        ← build system tests
│       ├── README.md
│       └── phase1.cmake … phase11.cmake
├── externals/                  ← local externals of the demo solution
│   ├── bass/
│   ├── calcext/
│   ├── doctest/
│   ├── glad/
│   └── lua54/
├── projects/                   ← demo projects
│   ├── apps/
│   ├── demos/
│   └── tests/
└── templates/                  ← templates (app, Source.cmake, consumer bootstrap)
```

---

## 9. Best Practices

### 9.1 No Direct message() Calls

```cmake
# ❌ Wrong
message(STATUS "Loading configuration...")

# ✅ Correct
dbg(${DBG_COMMON} "Loading configuration..." ID CMAKE_MAIN)
```

### 9.2 Errors via the Errors Module

```cmake
# ❌ Wrong
message(FATAL_ERROR "Something went wrong")

# ✅ Correct
cmake_fatal("E001" "Something went wrong")
```

### 9.3 Load Modules Only via `${CMAKECRAFT_DIR}`

```cmake
# ✅ Correct — works wherever CMakeCraft lives
include("${CMAKECRAFT_DIR}/project/Libraries.cmake")

# ❌ Wrong — couples to the location of the project
include(cmake/project/Libraries.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/project/Libraries.cmake)
```

The order of the pipelines is fixed by `CMakeCraft.cmake`; a project does not load modules itself.

### 9.4 Clean Up Variables

```cmake
# At the end of the file
unset(_sol_name)
unset(_sol_version)
```

### 9.5 Guard Against Multiple Includes

```cmake
# In every module
include_guard(GLOBAL)
```

`CMakeCraft.cmake` itself is protected by `CMAKECRAFT_INCLUDED`.

---

## 10. Troubleshooting

### 10.1 CMakeCraft.cmake Not Found

```
CMake Error at CMakeLists.txt:XX (include):
  include could not find requested file:
    <path>/CMakeCraft.cmake
```

**Solution:** Check the path in the `include()` of the project's `CMakeLists.txt` (snapshot,
`.externals/cmakecraft/<version>/` or `CMAKECRAFT_LOCAL_DIR`).

### 10.2 E005: No project() Line

```
[E005] <path>/CMakeLists.txt has no project() line. Add 'project(<Name> LANGUAGES NONE)' directly after cmake_minimum_required() - name and version still come from Solution.json. Then configure with --fresh.
```

**Solution:** Add `project(<Name> LANGUAGES NONE)` directly after `cmake_minimum_required()`, then configure with
`--fresh`.

### 10.3 Solution.json Missing

```
[E002] Solution.json not found: /path/to/project/Solution.json
```

**Solution:** Create `Solution.json` in the project root.

### 10.4 Library Not Found When Linking

```
[E101] Dependency 'CoreLib' for 'MyApp' does not exist
```

**Solution:** Check that the library is listed under `libraries` in `Solution.json` and that the name matches (a
`BUILD_ONLY` that leaves it out also leads here).

### 10.5 External Not Found

```
[E010] External 'glfw' not defined in externals block
```

**Solution:** Define the external in `Solution.json` under `externals`.

### 10.6 No Debug Output

**Solution:** `DEBUG_MESSAGES` must not be `OFF`:
```bash
cmake -B build -DDEBUG_MESSAGES=ON
```

### 10.7 Qt6 Not Found

```
Could not find a package configuration file provided by "Qt6"
```

**Solution:** Set `CMAKE_PREFIX_PATH`:
```bash
cmake -B build -DCMAKE_PREFIX_PATH=/path/to/Qt/6.6.0/gcc_64
```

---

## 11. See Also

### Core Modules (Phase 1)

- [Errors.md](core/Errors.md)
- [Debug.md](core/Debug.md)
- [Json.md](core/Json.md)
- [Validation.md](core/Validation.md)
- [Context.md](core/Context.md)
- [SourceCollect.md](core/SourceCollect.md)
- [OutputDirs.md](core/OutputDirs.md)
- [Warnings.md](core/Warnings.md)
- [CompilerOptions.md](core/CompilerOptions.md)

### Project Modules

- [Solution.md](project/Solution.md)
- [Libraries.md](project/Libraries.md)
- [Executables.md](project/Executables.md)
- [Externals.md](project/Externals.md)
- [Apps.md](project/Apps.md)
- [Packages.md](project/Packages.md)
- [Tests.md](project/Tests.md)

### Build System Tests

- [buildSystemTest_README.md](buildSystemTest/buildSystemTest_README.md)

### References

- [Solution_Schema.md](../references/Solution_Schema.md) — JSON schema
- [Externals.md](../references/Externals.md) — External libraries
- [CMakePresets.md](../references/CMakePresets.md) — Preset configuration
- [Neues_Projekt_Guide.md](../userguides/Neues_Projekt_Guide.md) — integrating CMakeCraft into a project

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.2** | **2026-11-09** | **Aligned with the code: entry point `CMakeCraft.cmake` (self-locating, `CMAKECRAFT_DIR`), `CMakeLists.txt` as a thin wrapper with the required `project()` line; execution order externals → libraries → executables → apps → packages → tests; phases 1–11 and phase tests 1–11; `RUN_BUILD_SYSTEM_TESTS` default `OFF`, preset `craft-selftest`; `BUILD_TESTS`, debug levels, debug IDs, directory tree and error messages (E005, E101, E010) as in the code** |
| 1.0.1 | 2026-10-09 | CMakeCraft v0.10.0: Added phase 10 (Packages) and phase test 10; CMake minimum 3.26 |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.0 | 2025-12-15 | Blueprint v0.5.0 format; all 9 phases documented; externals pipeline added; tests pipeline added |
| 0.1.1 | 2025-12-07 | Libraries.cmake added, SourceCollect.cmake in core |
| 0.1.0 | 2025-12-05 | Initial: clean start with debug system |
