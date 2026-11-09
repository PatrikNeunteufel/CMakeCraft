# Handler.cmake — System External Handler

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [Handler_cmake.md](../../../../../de/guide/module/externals/system/Handler_cmake.md)  
> **Module:** [cmake/externals/system/Handler.cmake](../../../../../../cmake/externals/system/Handler.cmake)  
> **Module Version:** 1.0.0  
> **Phase:** 9 (System Externals)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [API Reference](#3-api-reference)
4. [Processing Flow](#4-processing-flow)
5. [Package Hooks](#5-package-hooks)
6. [Usage Examples](#6-usage-examples)
7. [Error Handling](#7-error-handling)
8. [Debug Output](#8-debug-output)
9. [See Also](#9-see-also)
10. [Changelog](#10-changelog)

---

## 1. Overview

`Handler.cmake` is the central handler for **system externals** — large, externally installed packages such as Qt6 or Boost that are found via `find_package()`.

### Core Functions

- **Path resolution** — Multi-stage search for installation paths
- **find_package()** — CMake-native package search with component support
- **Package hooks** — Package-specific configuration (Qt6, Boost)
- **Registration** — Stores the result for later use

### Architecture Position

```
Orchestrator.cmake
       │
       ├── system: true
       ▼
┌─────────────────────┐
│  system/Handler     │  ← This handler
└─────────┬───────────┘
          │
    ┌─────┴─────┐
    ▼           ▼
PathResolver  Package-Hooks
              (Qt6, Boost)
```

---

## 2. Dependencies

### Required Modules

| Module | Purpose |
|--------|---------|
| `Errors.cmake` | `cmake_fatal`, `cmake_warn` |
| `Debug.cmake` | `dbg` |
| `Json.cmake` | JSON parsing |
| `PathResolver.cmake` | Path resolution |

### Auto-loaded Modules

| Module | Condition |
|--------|-----------|
| `packages/Qt6.cmake` | If `package="Qt6"` |
| `packages/Boost.cmake` | If `package="Boost"` |

---

## 3. API Reference

### 3.1 _handle_system_external()

Main function for processing a system external.

```cmake
_handle_system_external(EXT_NAME EXT_JSON)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `EXT_NAME` | String | Name of the external (e.g. "qt6") |
| `EXT_JSON` | JSON | JSON definition from Solution.json |

**Required JSON fields:**

| Field | Type | Description |
|-------|------|-------------|
| `system` | bool | Must be `true` |
| `package` | string | Name for find_package() |

**Optional fields:**

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `version` | string | — | Minimum version for `find_package()` (e.g. `"6.5"`, no `>=` operators) |
| `components` | array | `[]` | Package components |
| `hints` | array | `[]` | Additional search paths |
| `backup` | string | — | Fallback path (with warning) |
| `required` | bool | `true` | With `false` no error if the package is missing |

`find_package()` always runs **without** `REQUIRED` (`Handler.cmake:270`, `:273`): with
`REQUIRED` CMake would abort with its own message before CMakeCraft can name the cause. Without
`REQUIRED` CMake's diagnostics still appear, as a warning. If the package is not found and the
external is `required`, the handler calls `_system_external_not_found()` (`Handler.cmake:290`);
otherwise it only reports `[<name>] <Package> not found (optional)` (`:293`).

---

### 3.2 _apply_system_external_to_target()

Links a system external to a CMake target.

```cmake
_apply_system_external_to_target(TARGET_NAME EXT_NAME EXT_OPTIONS)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `TARGET_NAME` | String | CMake target |
| `EXT_NAME` | String | Name of the external |
| `EXT_OPTIONS` | JSON | Options (currently unused) |

**Behavior:**
1. Fetches the registered package name and components
2. Links the `Package::Component` targets
3. Calls the `_Package_configure_target()` hook (if defined)

If the external is not registered, E503 `System external '<name>' not properly registered`
follows (`Handler.cmake:331`).

---

### 3.3 _system_external_not_found()

Names the cause when `find_package()` did not find a `required` external, and aborts with
E503, E504 or E505 (`Handler.cmake:52–133`).

```cmake
_system_external_not_found(EXT_NAME PACKAGE VERSION COMPONENTS)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `EXT_NAME` | String | Name of the external |
| `PACKAGE` | String | Package name from `package` |
| `VERSION` | String | `version` from Solution.json, or empty |
| `COMPONENTS` | List | `components` from Solution.json, or empty |

It reads the variables that `find_package()` leaves in the caller: `<Package>_DIR`,
`<Package>_CONSIDERED_CONFIGS`, `<Package>_CONSIDERED_VERSIONS` and
`<Package>_NOT_FOUND_MESSAGE` (`Handler.cmake:53–56`).

| Situation after `find_package()` | Result | Line |
|----------------------------------|--------|------|
| `<Package>_DIR` set (configuration accepted), `components` set | E504 with the package's reason | `:91` |
| `<Package>_DIR` set, no `components` | E503 with the package's reason | `:101` |
| Configurations considered, none accepted, `version` set | E505 with every considered file and its version | `:109` |
| Configurations considered, none accepted, no `version` | E503 with the same `Considered:` lines | `:120` |
| nothing considered | E503 (package not found) | `:128` |

All E503 variants end with the same solution lines (`Handler.cmake:73–86`).

---

## 4. Processing Flow

```
_handle_system_external(EXT_NAME, EXT_JSON)
    │
    ├── 1. Parse JSON
    │   ├── package (required) → E502 if missing
    │   ├── version, components, hints, backup
    │   └── required (default: true)
    │
    ├── 2. Load package hook (if present)
    │   └── packages/{package}.cmake
    │       └── call _get_{package}_standard_paths()
    │
    ├── 3. Resolve path via PathResolver
    │   ├── ENV variables
    │   ├── hints[]
    │   ├── standard paths
    │   └── backup (with W501 warning)
    │
    ├── 4. Extend CMAKE_PREFIX_PATH
    │
    ├── 5. Call find_package()
    │   ├── With COMPONENTS if given
    │   └── Never with REQUIRED (CMake's diagnostics appear as a warning)
    │
    ├── 6. Check result
    │   ├── Found → call post-find hook
    │   ├── Not found, required → _system_external_not_found()
    │   │                         → E503 / E504 / E505
    │   └── Not found, required=false → status message, continue
    │
    └── 7. Register
        ├── EXTERNAL_{name}_TYPE = "SYSTEM"
        ├── EXTERNAL_{name}_PACKAGE
        ├── EXTERNAL_{name}_COMPONENTS
        └── EXTERNAL_{name}_REGISTERED = TRUE
```

---

## 5. Package Hooks

Package hooks enable package-specific configuration.

### Hook Path

```
cmake/externals/system/packages/{Package}.cmake
```

### Available Hook Functions

| Function | Call Time | Purpose |
|----------|-----------|---------|
| `_get_{Package}_standard_paths()` | Before find_package | Standard installation paths |
| `_{Package}_post_find()` | After find_package | Post-processing |
| `_{Package}_configure_target()` | On apply_external | Target configuration |

### Example: Qt6 Hook

```cmake
# packages/Qt6.cmake

function(_get_Qt6_standard_paths OUT_VAR)
    set(_paths "C:/Qt/6.8.0/msvc2022_64" ...)
    set(${OUT_VAR} "${_paths}" PARENT_SCOPE)
endfunction()

function(_Qt6_configure_target TARGET_NAME)
    set_target_properties(${TARGET_NAME} PROPERTIES
        AUTOMOC ON
        AUTOUIC ON
        AUTORCC ON
    )
endfunction()
```

---

## 6. Usage Examples

### Solution.json

```json
{
    "externals": {
        "qt6": {
            "system": true,
            "package": "Qt6",
            "components": ["Core", "Widgets", "Gui"],
            "hints": ["${QT_ROOT}"],
            "backup": "C:/Qt/6.8.0/msvc2022_64"
        },
        "boost": {
            "system": true,
            "package": "Boost",
            "components": ["filesystem", "system"],
            "required": false
        }
    }
}
```

### Automatic Flow

```cmake
# In Orchestrator.cmake - automatically if system: true
_handle_system_external("qt6" "${_ext_json}")

# In ExecutableCreate.cmake - for externals: ["qt6"]
_apply_system_external_to_target("MyApp" "qt6" "{}")
```

---

## 7. Error Handling

### Error Codes

| Code | Error | Description |
|------|-------|-------------|
| E502 | Package field missing | `package` is a mandatory field (`Handler.cmake:180`) |
| E503 | find_package failed | Package not found or no configuration accepted (with required=true; `:101`, `:120`, `:128`); external not registered when linking (`:331`) |
| E504 | Component missing | Package found, but not with all components from `components` (`:91`) |
| E505 | Version not satisfied | `version` set, only configurations with an unsuitable version considered (`:109`) |

### Warnings

| Code | Warning | Description |
|------|---------|-------------|
| W501 | Backup used | Fallback path instead of ENV/hints |

### E503 Error Message

Package not found (`Handler.cmake:128`):

```
[E503] System external 'qt6': find_package(Qt6) failed.

  Possible solutions:
    1. Set Qt6_ROOT environment variable
    2. Add 'hints' in Solution.json
    3. Install Qt6 to a standard location

  Example Solution.json:
    "qt6": {
      "system": true,
      "package": "Qt6",
      "hints": ["C:/Path/To/Qt6"]
    }
```

### E504 Error Message

```
[E504] System external 'qt6': Qt6 was found (<Qt6_DIR>), but not with all requested components: Core, Widgets, Charts
  Reason given by the package: <Qt6_NOT_FOUND_MESSAGE>

  Possible solutions:
    1. Install the missing component(s) for this Qt6 installation
    2. Remove components the project does not use from 'components' in Solution.json
```

The message names all requested components; which one is missing is stated in the package's reason.

### E505 Error Message

```
[E505] System external 'qt6': no Qt6 with a version compatible to the requested '6.9' was found.
  Considered:
    C:/Qt/6.8.0/msvc2022_64/lib/cmake/Qt6/Qt6Config.cmake (version 6.8.0)

  Possible solutions:
    1. Install a compatible Qt6 version and point Qt6_ROOT or 'hints' to it
    2. Adjust 'version' in Solution.json
```

---

## 8. Debug Output

### Debug ID: `EXTERNALS`

| Level | Output |
|-------|--------|
| `DBG_COMMON` | Processing system external |
| `DBG_RARE` | Package, components, hints |
| `DBG_RARE` | find_package() call |
| `DBG_ULTRA_RARE` | CMAKE_PREFIX_PATH |

### Activation

```bash
cmake -DDEBUG_CATEGORIES="EXTERNALS" ..
```

---

## 9. See Also

- [PathResolver_cmake.md](PathResolver_cmake.md) — Path resolution
- [packages/Qt6_cmake.md](packages/Qt6_cmake.md) — Qt6-specific hooks
- [packages/Boost_cmake.md](packages/Boost_cmake.md) — Boost-specific hooks
- [Orchestrator_cmake.md](../Orchestrator_cmake.md) — Dispatches here
- [Solution_Schema.md](../../../references/Solution_Schema.md) — JSON schema (§5.4)

---

## 10. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-11-09** | **Module 1.1.0 (CMakeCraft v0.14.1): `find_package()` without `REQUIRED`; new function `_system_external_not_found()` (§3.3) names E503, E504 or E505; flow §4 and error table §7 adjusted, messages of E504 and E505** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| **0.6.0** | **2025-12-18** | **Initial: Phase 9 system externals, find_package integration, package hooks** |
