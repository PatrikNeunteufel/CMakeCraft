# phase9.cmake — Module Documentation

> **Version:** 1.1.0  
> **Date:** 2026-11-09  
> **Type:** ModuleDoc  
> **Path:** `cmake/buildSystemTest/phase9.cmake`  
> **Status:** Stable  
> **Language:** English  
> **German:** [Phase9_doc.md](../../../../de/guide/module/buildSystemTest/Phase9_doc.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Tests](#2-tests)
3. [Success Flag](#3-success-flag)
4. [See Also](#4-see-also)
5. [Changelog](#5-changelog)

---

## 1. Overview

**Phase 9** tests the **system externals** — the detection of `system: true`, the fields `package`, `version`, `components`, `hints`, `backup` and `required`, the type priority `system` → `git` → `path`, the Handler and PathResolver modules, the package hooks, the entry point of Qt GUI programs, and the error codes E503–E505 of the system handler.

| Aspect | Description |
|--------|-------------|
| **Purpose** | Validate the system external pipeline |
| **Debug ID** | `PHASE9_TEST` |
| **Dependencies** | system/Handler.cmake, system/PathResolver.cmake, system/packages/Qt6.cmake, Orchestrator.cmake, Errors.cmake; test 12 additionally Debug.cmake and Json.cmake in the nested configures |
| **Condition** | Test 11 only runs on Windows with MSVC ABI (`MSVC` or `CMAKE_CXX_SIMULATE_ID` = `MSVC`); otherwise it is skipped |

Tests 1–10 only **report** (debug output, partly a warning via `cmake_warn`). Tests 11 and 12 abort hard via `cmake_fatal("ASSERT" …)`.

---

## 2. Tests

### 2.1 Test 1 — Detection of the External Type

Reads `SOLUTION_EXTERNALS_JSON` (global property) and counts the externals per type: `system` (field `system` true), else `git` (field `git` set), else `path` (field `path` set). Reports the three counts; no abort.

### 2.2 Test 2 — Fields of a System External

On the first system external:

| Field | Required | Behavior |
|-------|----------|----------|
| `package` | yes | reported; if missing, warning `W901` |
| `version` | no | reported |
| `components` | no | count and first component reported |
| `hints` | no | number of paths reported |
| `backup` | no | reported |
| `required` | no (default `true`) | reported |

### 2.3 Test 3 — Type Priority

Prints the order `system → git → path → E012` and checks that no external carries more than one of the fields `system`, `git`, `path`. Otherwise warning `W902` with the number of affected externals.

### 2.4 Test 4 — Targets of the System Externals

Reports which known targets exist: `Qt6::Core`, `Qt6::Widgets`, `Qt6::Gui`, `Qt6::OpenGL`, `Boost::boost` or `Boost::headers`, `opencv_core` or `OpenCV::core`. No abort if none exists.

### 2.5 Test 5 — Handler and PathResolver Modules

Reports whether `_handle_system_external()` and `_resolve_system_paths()` are defined, and prints where the orchestrator dispatches to (`system` → System/Handler.cmake, `git` → Core/Fetch.cmake, `path` → Local/Attach.cmake). No abort.

### 2.6 Test 6 — Error Code Range

Only prints the codes: errors `E502`–`E505`, warning `W501` (`phase9.cmake:282–294`; see ErrorCodes.md). No check — test 12 checks the error codes.

### 2.7 Test 7 — Qt6 as System External

Reports whether `qt6` is defined as a system external (with `package` and the number of `components`), whether it still takes the detour via `path`, and whether `find_package()` found Qt6 (`Qt6_FOUND` or `Qt6Core_FOUND`, plus `Qt6_VERSION`, `Qt6_DIR`). No abort.

### 2.8 Test 8 — Targets Using Qt6

Counts executables and libraries whose `LINK_LIBRARIES` contain a `Qt6::` target and reports the number. No abort.

### 2.9 Test 9 — Package Hooks

Checks whether `${CMAKECRAFT_DIR}/externals/system/packages/` exists and reports the `*.cmake` hooks found. If the folder is missing, message only ("optional").

### 2.10 Test 10 — Migration Status `path` → `system`

Checks for `qt6`, `boost`, `opencv` and `cuda` whether they still use `path` without `system`, and reports the number that could be migrated to `system`. No abort.

### 2.11 Test 11 — Entry Point of Qt GUI Programs

New with CMakeCraft v0.14.1 (2026-11-09). Background: `Qt6EntryPoint.lib` defines `WinMain` **and** `wWinMain`; without an explicit entry point, lld-link warns on every link (see [Qt6_cmake.md §2.4](../externals/system/packages/Qt6_cmake.md#24-_qt6_configure_entry_point)).

Only runs on Windows with MSVC ABI (`MSVC` or `CMAKE_CXX_SIMULATE_ID` = `MSVC`). For every executable in the `BUILDSYSTEM_TARGETS` of the source directory:

| Case | Expected | On mismatch |
|------|----------|-------------|
| Exe links Qt6 (`LINK_LIBRARIES` contains `Qt6::…`) | `LINK_OPTIONS` contain `LINKER:/ENTRY:WinMainCRTStartup` | `cmake_fatal("ASSERT" …)` |
| | the option depends, in a generator expression, on `TARGET_PROPERTY:<target>,WIN32_EXECUTABLE` | `cmake_fatal("ASSERT" …)` |
| | … and on `TARGET_PROPERTY:<target>,QT_NO_ENTRYPOINT` | `cmake_fatal("ASSERT" …)` |
| Exe without Qt6 | `LINK_OPTIONS` do **not** contain `LINKER:/ENTRY:WinMainCRTStartup` | `cmake_fatal("ASSERT" …)` |

Reports the number of Qt executables checked. Whether the linker then stays silent (lld-link without "found both wWinMain and WinMain") only shows when building.

### 2.12 Test 12 — Error Codes of System Externals and Complete Messages

New with CMakeCraft v0.14.1 (2026-11-09; `phase9.cmake:498–609`). Works under
`${CMAKE_BINARY_DIR}/phase9/`, which is emptied first.

**(a) Message parts.** A script calls `cmake_warn("W999" "part one: path;git\n" "  part two\n" "  part three")`
via `cmake -P`. If one of the three parts is missing from the output — including the one with a semicolon — the test aborts.

**(b) Error codes of the system handler.** A fake package `FakePkg` 1.2.0 with
`FakePkgConfig.cmake` and `FakePkgConfigVersion.cmake`; it only knows the component `Core` and sets
`FakePkg_NOT_FOUND_MESSAGE` for any other. Each case runs a nested configure with the generator of
the self-test (`-G`, plus `-A` and `CMAKE_MAKE_PROGRAM` if set), which loads `Errors.cmake`,
`Debug.cmake`, `Json.cmake` and `system/Handler.cmake` and calls `_handle_system_external("fake" …)`:

| Case | Solution entry | Expected |
|------|----------------|----------|
| `ok` | `FakePkg`, `version` `1.0`, `components` `[Core]` | configure succeeds |
| `comp` | `FakePkg`, `components` `[Core, Missing]` | fails; output contains `[E504]`, `Missing`, `Failed to find required FakePkg component` |
| `vers` | `FakePkg`, `version` `2.0`, `components` `[Core]` | fails; output contains `[E505]`, `'2.0'`, `(version 1.2.0)` |
| `none` | `NoSuchPkg` | fails; output contains `[E503]`, `Possible solutions`, `Install NoSuchPkg to a standard location` |

Every mismatch aborts via `cmake_fatal("ASSERT" …)`. The check of the last solution line also
shows that multi-part messages arrive complete.

### 2.13 Summary

If system externals are defined but none of their targets were found, only a note follows (normal if the libraries are not installed). The status stays `PASSED`.

---

## 3. Success Flag

```cmake
set(PHASE9_TEST_PASSED TRUE CACHE BOOL "Phase 9 Test passed" FORCE)
```

Only an abort in test 11 or test 12 prevents the flag.

---

## 4. See Also

- [system/Handler_cmake.md](../externals/system/Handler_cmake.md)
- [system/PathResolver_cmake.md](../externals/system/PathResolver_cmake.md)
- [system/packages/Qt6_cmake.md](../externals/system/packages/Qt6_cmake.md)
- [Orchestrator_cmake.md](../externals/Orchestrator_cmake.md)
- [ErrorCodes.md](../../references/ErrorCodes.md)
- [System_Externals_Concept.md](../../../konzepte/abgeschlossen/System_Externals_Concept.md)

---

## 5. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.1.0** | **2026-11-09** | **First version, written from the code `phase9.cmake` (module 1.1.0); test 11 (§2.11) new with CMakeCraft v0.14.1 — entry point of Qt GUI programs; test 6 names E502–E505 and W501 (E501/W502 dropped); test 12 (§2.12) new — message parts of `cmake_warn` and E503/E504/E505 of the system handler with the fake package FakePkg** |
