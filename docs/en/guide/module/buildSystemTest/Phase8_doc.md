# phase8.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2026-11-09  
> **Type:** ModuleDoc  
> **Path:** `cmake/buildSystemTest/phase8.cmake`  
> **Status:** Stable  
> **Language:** English  
> **German:** [Phase8_doc.md](../../../../de/guide/module/buildSystemTest/Phase8_doc.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Tests](#2-tests)
3. [Success Flag](#3-success-flag)
4. [See Also](#4-see-also)
5. [Changelog](#5-changelog)

---

## 1. Overview

**Phase 8** tests the **app container pipeline** — the `apps` block in Solution.json, the targets `<App>.Core` (library) and `<App>` (runner), the app tests, and the collection of `external_options` and `compile_options` for app tests.

| Aspect | Description |
|--------|-------------|
| **Purpose** | Validate the app container pipeline |
| **Debug ID** | `PHASE8_TEST` |
| **Dependencies** | Apps.cmake (AppCollect, AppCreate), Context.cmake, Json.cmake, Errors.cmake |
| **Condition** | Tests 4 and 9 only run with `BUILD_TESTS=ON`; test 2b only if `_collect_app()` is defined; otherwise they are skipped |

Most tests only **report** (debug output, partly a warning via `cmake_warn`). Only test 2b aborts hard via `cmake_fatal("ASSERT" …)`.

---

## 2. Tests

### 2.1 Test 1 — `apps` Array in Solution.json

Reads `SOLUTION_JSON` (global property) and the `apps` array. For the first app it reports `name` and whether the sections `core`, `runner` (with `runner.type`) and `tests` are present.

| Case | Behavior |
|------|----------|
| `apps` missing | message "optional", no error |
| `SOLUTION_JSON` not available | warning `W801` |

### 2.2 Test 2 — AppCollect Module Available

Reports whether `_collect_app()` is defined. No abort if it is not.

### 2.3 Test 2b — external_options and compile_options of App Test Targets

The demo solution has no app test with externals; therefore the test collects a literal app definition `Phase8Probe` with two test targets into the context `PHASE8_PROBE`:

```json
{
    "name": "Phase8Probe",
    "tests": {
        "framework": "doctest",
        "targets": [
            {
                "name": "WithOptions",
                "type": "unit",
                "externals": [ "bass" ],
                "external_options": { "bass": { "BASS_MIX": true } },
                "compile_options": [ "-DP8_ONE", "$<$<CXX_COMPILER_ID:MSVC>:/bigobj>" ]
            },
            { "name": "WithoutOptions", "type": "unit" }
        ]
    }
}
```

| Check | Expected | On mismatch |
|-------|----------|-------------|
| `TESTS_TARGET_0_EXTERNAL_OPTIONS` | `bass.BASS_MIX` is `true` | `cmake_fatal("ASSERT" …)` |
| `TESTS_TARGET_1_EXTERNAL_OPTIONS` | `{}` | `cmake_fatal("ASSERT" …)` |
| `TESTS_TARGET_0_COMPILE_OPTIONS` | `-DP8_ONE;$<$<CXX_COMPILER_ID:MSVC>:/bigobj>` — a list, generator expression unchanged | `cmake_fatal("ASSERT" …)` |
| `TESTS_TARGET_1_COMPILE_OPTIONS` | empty | `cmake_fatal("ASSERT" …)` |
| `COMPILE_OPTIONS` on the demo target `MyVisualizer.UnitTests` (only if it exists) | contains `$<$<CXX_COMPILER_ID:MSVC>:/bigobj>` | `cmake_fatal("ASSERT" …)` |

### 2.4 Test 3 — App Container Targets

Searches the `BUILDSYSTEM_TARGETS` of the source directory for targets ending in `.Core` and reports for each whether the runner target `<App>` exists. Counts both; no abort.

### 2.5 Test 4 — App Test Targets (only `BUILD_TESTS=ON`)

Counts and reports targets ending in `.UnitTests` and `.IntegrationTests`. No abort.

### 2.6 Test 5 — Properties of the Core Library

On the first `.Core` target:

| Check | Expected | On mismatch |
|-------|----------|-------------|
| `TYPE` | `STATIC_LIBRARY` | warning `W802` |
| `INCLUDE_DIRECTORIES`, `LINK_LIBRARIES` | only reported | — |

### 2.7 Test 6 — Runner Links Against Core

Checks whether the `LINK_LIBRARIES` of the runner `<App>` contain the target `<App>.Core`. If not, warning `W803`.

### 2.8 Test 7 — Directory Convention

Checks whether `projects/apps/` exists, counts the app folders and reports for the first one whether `src/` and `main/` (required) as well as `include/`, `tests/` and `pch/` (optional) are present. Missing folders are only reported as `MISSING`, no abort.

### 2.9 Test 8 — Error Code Range

Only prints the ranges: app container errors `E401`–`E407`, warnings `W401`–`W403` (defined in ErrorCodes.md). No check.

### 2.10 Test 9 — CTest Integration of the App Tests (only `BUILD_TESTS=ON`)

Reports whether CTest is enabled (`CMAKE_TESTING_ENABLED`) and, for the first test `<App>.UnitTests` resp. `<App>.IntegrationTests`, the test properties `TIMEOUT` and `LABELS`. No abort.

### 2.11 Test 10 — IDE Folders

Reports the `FOLDER` property of the first `.Core` target and whether it starts with `Apps/`. No abort.

### 2.12 Summary

If apps are defined but no `.Core` targets were created, the status is `WARNING` instead of `PASSED` (message only).

---

## 3. Success Flag

```cmake
set(PHASE8_TEST_PASSED TRUE CACHE BOOL "Phase 8 Test passed" FORCE)
```

The flag is also set with status `WARNING`; only an abort in test 2b prevents it.

---

## 4. See Also

- [Apps.md](../project/Apps.md)
- [AppCollect.md](../project/AppCollect.md)
- [AppCreate.md](../project/AppCreate.md)
- [ErrorCodes.md](../../references/ErrorCodes.md)
- [AppContainer_Concept.md](../../../konzepte/abgeschlossen/AppContainer_Concept.md)

---

## 5. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2026-11-09** | **First version, written from the code `phase8.cmake` (module 1.0.0)** |
