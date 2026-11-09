# Orchestrator.cmake — External Type Dispatcher

> **Version:** 1.0.2  
> **Date:** 2026-11-09  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5, Doc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [Orchestrator_cmake.md](../../../../de/guide/module/externals/Orchestrator_cmake.md)  
> **Module:** [cmake/externals/Orchestrator.cmake](../../../../../cmake/externals/Orchestrator.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [API Reference](#3-api-reference)
4. [Type Detection](#4-type-detection)
5. [Processing Flow](#5-processing-flow)
6. [Usage Examples](#6-usage-examples)
7. [Error Handling](#7-error-handling)
8. [Debug Output](#8-debug-output)
9. [See Also](#9-see-also)
10. [Changelog](#10-changelog)

---

## 1. Overview

`Orchestrator.cmake` is the central entry point for processing externals. The module detects the type of an external from its JSON fields and dispatches to the corresponding handler function.

### Core Functions

- **Type Detection** — Detects system, fetched, local and archive from the JSON fields
- **Dispatch** — Delegates to `_handle_system_external()`, `_handle_fetched_external()`, `_attach_local_external()` or `_handle_archive_external()`
- **Options Extraction** — Extracts target-specific external options
- **Apply** — Applies externals to CMake targets

### Architecture Position

```
Externals.cmake (project)
         │
         ▼
┌─────────────────────┐
│  Orchestrator.cmake │  ← Entry-Point
└──────────┬──────────┘
           │
      ┌────┴───────┬────────────┬────────────┐
      ▼            ▼            ▼            ▼
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ system/  │ │ local/   │ │ fetched/ │ │ archive/ │
│ Handler  │ │ Attach   │ │ Handler  │ │ Handler  │
└──────────┘ └──────────┘ └──────────┘ └──────────┘
```

---

## 2. Dependencies

### Required Modules

| Module | Purpose |
|--------|---------|
| `Errors.cmake` | Error handling (`cmake_fatal`, `cmake_warn`) |
| `Debug.cmake` | Debug output (`dbg`) |
| `Json.cmake` | JSON parsing (`_json_get_string`, `_json_has_key`) |
| `Validation.cmake` | Source validation (`validate_external_source`) |

### Auto-loaded Modules

| Module | Purpose |
|--------|---------|
| `local/Attach.cmake` | Handler for local externals |
| `fetched/Handler.cmake` | Handler for Git-based externals |
| `system/Handler.cmake` | Handler for system externals (find_package) |
| `archive/Handler.cmake` | Handler for archive externals (prebuilt package, pinned version) |

---

## 3. API Reference

### 3.1 _orchestrate_external()

Main function for processing an external.

```cmake
_orchestrate_external(EXT_NAME EXT_JSON)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `EXT_NAME` | String | Name of the external (e.g. "bass", "spdlog") |
| `EXT_JSON` | JSON | JSON definition from Solution.json |

**Behavior:**
1. Validates the source field (`validate_external_source()`: exactly one of `system`, `git`, `path`, `archive`; otherwise E012)
2. Detects the type from the field present (priority system → git → path → archive)
3. Dispatches to the corresponding handler

---

### 3.2 _get_external_options_for_target()

Extracts target-specific options for an external.

```cmake
_get_external_options_for_target(TARGET_NAME EXT_NAME TARGET_JSON OUT_VAR)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `TARGET_NAME` | String | Name of the target (for debug) |
| `EXT_NAME` | String | Name of the external |
| `TARGET_JSON` | JSON | JSON of the target (executable/library) |
| `OUT_VAR` | Variable | Output: options JSON or `{}` |

---

### 3.3 apply_external_to_target()

Applies an external to a CMake target.

```cmake
apply_external_to_target(TARGET_NAME EXT_NAME EXT_OPTIONS)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `TARGET_NAME` | String | CMake target that uses the external |
| `EXT_NAME` | String | Name of the external |
| `EXT_OPTIONS` | JSON | Options JSON for this external |

**Behavior:**
1. Checks whether the external is in `SKIPPED_EXTERNALS` → **E013 FATAL**
2. Fetches the external definition from `SOLUTION_EXTERNALS_JSON`
3. Detects the type (check order here: system → path → git → archive)
4. Applies it according to its type

**For system externals:**

Calls `_apply_system_external_to_target(TARGET_NAME EXT_NAME EXT_OPTIONS)`.

**For local externals — sets variables:**

| Variable | Description |
|----------|-------------|
| `EXTERNAL_NAME` | Name of the external |
| `EXTERNAL_ROOT` | Root path of the external |
| `EXTERNAL_OPTIONS` | JSON options string |
| `EXECUTABLE_NAME` | Target name (legacy) |

**For fetched externals:**

Links the registered target via `_link_external_to_target()`.

**For archive externals:**

Calls `_apply_archive_external_to_target(TARGET_NAME EXT_NAME EXT_JSON EXT_OPTIONS)` — include path, define and files next to the executable.

---

## 4. Type Detection

### Detection Logic (Priority)

| JSON Field | Detected Type | Handler |
|------------|---------------|---------|
| `"system": true` | System | `_handle_system_external()` |
| `"git"` | Fetched | `_handle_fetched_external()` |
| `"path"` | Local | `_attach_local_external()` |
| `"archive": true` | Archive | `_handle_archive_external()` |
| None | Error E012 | — |

> **Priority:** system → git → path → archive

### Example Definitions

**System:**
```json
{
    "qt6": {
        "system": true,
        "package": "Qt6",
        "components": ["Core", "Widgets"]
    }
}
```

**Local:**
```json
{
    "bass": {
        "path": "externals/bass",
        "version": "2.4.17"
    }
}
```

**Fetched:**
```json
{
    "spdlog": {
        "git": "https://github.com/gabime/spdlog.git",
        "tag": "v1.12.0"
    }
}
```

**Archive:**
```json
{
    "toolkit": {
        "archive": true,
        "pin": "toolkit.pin"
    }
}
```

---

## 5. Processing Flow

### Orchestration Flow

```
┌─────────────────────────────────────────────────────────┐
│              _orchestrate_external()                     │
├─────────────────────────────────────────────────────────┤
│  1. validate_external_source()                          │
│     └─ E012 if no source field or more than one         │
│                                                         │
│  2. "system": true  → _is_system                        │
│     "git"           → _is_fetched                       │
│     "path"          → _is_local                         │
│     "archive": true → _is_archive                       │
│                                                         │
│  3. Dispatch (priority system → git → path → archive):  │
│     ├─ _is_system  → _handle_system_external()          │
│     ├─ _is_fetched → _handle_fetched_external()         │
│     ├─ _is_local   → _attach_local_external()           │
│     └─ _is_archive → _handle_archive_external()         │
└─────────────────────────────────────────────────────────┘
```

---

## 6. Usage Examples

### Basic Usage (automatic via ExecutableCreate)

```cmake
# In ExecutableCreate.cmake - called automatically
foreach(_ext IN LISTS _externals)
    _get_external_options_for_target("${_name}" "${_ext}" "${_exe_json}" _ext_opts)
    apply_external_to_target("${_name}" "${_ext}" "${_ext_opts}")
endforeach()
```

### Custom Include Path (optional)

```json
{
    "bass": {
        "path": "externals/bass",
        "include": "cmake/custom/bass_special.cmake"
    }
}
```

> **Note:** The `include` field is optional and relative to `CMAKE_SOURCE_DIR`. Default: `${CMAKECRAFT_DIR}/externals/includes/{name}/Include.cmake` (i.e. `cmake/externals/includes/{name}/Include.cmake` in the CMakeCraft tree).

---

## 7. Error Handling

### Error Codes

| Code | Error | Description |
|------|-------|-------------|
| E010 | External not defined | External not in the `externals` block |
| E012 | No source field | Neither `path` nor `git` nor `system` nor `archive` present |
| E013 | Skipped external used | Target references an external with `skip: true` |
| E213 | Include.cmake missing | Local external without Include.cmake |

### Skip Validation

`apply_external_to_target()` checks before applying whether the external is skipped:

```cmake
get_property(_skipped_list GLOBAL PROPERTY SKIPPED_EXTERNALS)
if("${EXT_NAME}" IN_LIST _skipped_list)
    cmake_fatal("E013" "External '${EXT_NAME}' is skipped but used by target '${TARGET_NAME}'...")
endif()
```

### Warnings

| Code | Warning | Description |
|------|---------|-------------|
| W101 | External not ready | Fetched external not yet available |

---

## 8. Debug Output

### Debug ID: `EXTERNALS`

| Level | Output |
|-------|--------|
| `DBG_RARE` | Type: SYSTEM / FETCHED (git) / LOCAL / ARCHIVE |
| `DBG_RARE` | Applying {ext} to {target} |
| `DBG_ULTRA_RARE` | Options for the external |

### Activation

The context `EXTERNALS` is created in `project/Externals.cmake` with `LEVEL ${DBG_SHOW_MUCH}` (3); output at
`DBG_RARE` (4) and `DBG_ULTRA_RARE` (5) only appears once that level is raised there. There is no cache switch per
context; `-DDEBUG_MESSAGES=OFF` switches all debug output off.

---

## 9. See Also

- [Attach_cmake.md](locals/Attach_cmake.md) — Local externals
- [Handler_cmake.md](fetched/Handler_cmake.md) — Git externals
- [archive/Handler_cmake.md](archive/Handler_cmake.md) — Archive externals
- [Targets_cmake.md](registry/Targets_cmake.md) — Target registry
- [Externals.md](../project/Externals.md) — Entry point (project)

---

## 10. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.2** | **2026-11-09** | **Aligned with the code: all four kinds (`system`, `git`, `path`, `archive`) in overview, architecture, `_orchestrate_external()` and flow; folders in lowercase (`local/`, `fetched/`, `system/`); default include `${CMAKECRAFT_DIR}/externals/includes/{name}/Include.cmake`; debug activation without the non-existent `DEBUG_CATEGORIES`** |
| **1.0.1** | **2026-10-09** | **CMakeCraft v0.10.0: External kind `archive`: detection in `_orchestrate_external()`, application in `apply_external_to_target()`** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.7.0 | 2025-12-20 | Skip validation: E013 when skipped externals are used in apply_external_to_target() |
| 0.6.0 | 2025-12-18 | Phase 9: system externals support, `_handle_system_external()` |
| 0.5.0 | 2025-12-15 | Documentation migrated to Blueprint v0.5.0 |
