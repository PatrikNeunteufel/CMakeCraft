# Handler.cmake — Archive External Handler

> **Version:** 1.1.0  
> **Date:** 2026-10-09  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [Handler_cmake.md](../../../../../de/guide/module/externals/archive/Handler_cmake.md)  
> **Module:** [cmake/externals/archive/Handler.cmake](../../../../../../cmake/externals/archive/Handler.cmake)  
> **Module Version:** 1.1.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [API Reference](#3-api-reference)
4. [Processing Flow](#4-processing-flow)
5. [Usage Examples](#5-usage-examples)
6. [Error Handling](#6-error-handling)
7. [Debug Output](#7-debug-output)
8. [See Also](#8-see-also)
9. [Changelog](#9-changelog)

---

## 1. Overview

`Handler.cmake` is the handler for **archive externals** — prebuilt packages fetched in a pinned version. It translates the fields of an external from Solution.json into calls of the standalone file `CMakeCraftPackage.cmake`.

### Core Functions

- **Platform filter** — on platforms not listed the external is absent
- **Fetch** — `craft_package_fetch()` with the pin file of the external
- **Remember** — package root as a global property
- **Apply** — include path, define and runtime copies via `craft_package_deploy()`

An archive external that cannot be obtained is **absent**: W304 at configure, targets get neither include path nor define nor copies.

### Architecture Position

```
Orchestrator.cmake
       │
       ├── archive: true
       ▼
┌─────────────────────┐
│  archive/Handler    │  ← This handler
└─────────┬───────────┘
          │
          ▼
CMakeCraftPackage.cmake
(craft_package_fetch, craft_package_deploy)
```

---

## 2. Dependencies

### Required Modules

| Module | Purpose |
|--------|---------|
| `Errors.cmake` | `cmake_fatal`, `cmake_warn` |
| `Debug.cmake` | `dbg` |
| `Json.cmake` | JSON parsing |

### Auto-loaded Modules

| Module | Condition |
|--------|-----------|
| `${CMAKECRAFT_ROOT}/CMakeCraftPackage.cmake` | Always (when the handler is included) |

---

## 3. API Reference

### 3.1 _handle_archive_external()

Fetches the package and remembers its root.

```cmake
_handle_archive_external(EXT_NAME EXT_JSON)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `EXT_NAME` | String | Name of the external; upper-case it is the prefix of the pin variables and of `-D<NAME>_LOCAL_DIR` |
| `EXT_JSON` | JSON | JSON definition from Solution.json |

**Required JSON fields:**

| Field | Type | Description |
|-------|------|-------------|
| `archive` | bool | Must be `true` |
| `pin` | string | Pin file, relative to the project root (variables: see [CMakeCraftPackage.md](../../CMakeCraftPackage.md)) |

**Optional fields:**

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `platforms` | array | `[]` (= all) | `windows`, `linux`, `macos`, `unix`; on any other platform the external is absent |
| `include_dirs` | array | `[]` | Include directories inside the package |
| `define` | string | "" | Compile definition `<define>=1` on each target |
| `runtime` | object | `{}` | `{ "files": [...], "dirs": [...] }` — copied next to each executable that names the external; the target `<executable>_deploy_<external>` copies on every build |

**Sets:**

| Global Property | Description |
|-----------------|-------------|
| `ARCHIVE_EXTERNAL_<name>_ROOT` | Package root, or `""` if the external is absent |

---

### 3.2 _apply_archive_external_to_target()

Applies an archive external to a CMake target.

```cmake
_apply_archive_external_to_target(TARGET_NAME EXT_NAME EXT_JSON EXT_OPTIONS)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `TARGET_NAME` | String | CMake target |
| `EXT_NAME` | String | Name of the external |
| `EXT_JSON` | JSON | JSON definition of the external |
| `EXT_OPTIONS` | JSON | Options of this target for the external (`external_options`) |

**Options per target:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `runtime` | bool | `true` | `false` = no copies, include path and define only |

**Behavior:**
1. Reads the package root from `ARCHIVE_EXTERNAL_<name>_ROOT`
2. Reads `include_dirs`, `define`, `runtime.files`, `runtime.dirs` from the external definition
3. Calls `craft_package_deploy()` — with an empty root nothing happens there

---

## 4. Processing Flow

```
_handle_archive_external(EXT_NAME, EXT_JSON)
    │
    ├── 1. ARCHIVE_EXTERNAL_{name}_ROOT = ""
    │
    ├── 2. read pin (mandatory) → E220 if missing
    │
    ├── 3. Platform filter (only if platforms is given)
    │   ├── windows → WIN32
    │   ├── linux   → CMAKE_SYSTEM_NAME is "Linux"
    │   ├── macos   → APPLE
    │   ├── unix    → UNIX
    │   └── no match → done (root stays empty, no warning)
    │
    ├── 4. craft_package_fetch()
    │   ├── NAME     = EXT_NAME
    │   └── PIN_FILE = ${CMAKE_SOURCE_DIR}/{pin}
    │       (override → cache → download → fallback paths)
    │
    ├── 5. ARCHIVE_EXTERNAL_{name}_ROOT = result
    │
    └── 6. result empty → W304
```

Since no `CACHE_DIR` is passed, the unpacked package sits at the default location of `craft_package_fetch()`: `<directory of the pin file>/.externals/<name>/<version>/`.

---

## 5. Usage Examples

### Solution.json

```json
{
    "externals": {
        "toolkit": {
            "archive": true,
            "pin": "toolkit.pin",
            "platforms": ["windows"],
            "include_dirs": ["include"],
            "define": "TOOLKIT_AVAILABLE",
            "runtime": {
                "files": ["bin/toolkit.dll"],
                "dirs": ["tools"]
            }
        }
    }
}
```

### Target Without Runtime Copies

```json
{
    "name": "MyTool",
    "externals": ["toolkit"],
    "external_options": {
        "toolkit": { "runtime": false }
    }
}
```

### Automatic Flow

```cmake
# In Orchestrator.cmake - automatically if archive: true
_handle_archive_external("toolkit" "${_ext_json}")

# In apply_external_to_target() - for externals: ["toolkit"]
_apply_archive_external_to_target("MyApp" "toolkit" "${_ext_json}" "${EXT_OPTIONS}")
```

---

## 6. Error Handling

### Error Codes

| Code | Error | Description |
|------|-------|-------------|
| E220 | Pin field missing | `pin` is a mandatory field |

### Warnings

| Code | Warning | Description |
|------|---------|-------------|
| W304 | External not available | The package could not be obtained — targets build without it |

Before W304, `craft_package_fetch()` issues its own warning with the reasons (see [CMakeCraftPackage.md](../../CMakeCraftPackage.md)).

### E220 Error Message

```
[E220] Archive external 'toolkit': 'pin' field is required.
  Example: { "archive": true, "pin": "toolkit.pin" }
```

---

## 7. Debug Output

### Debug ID: `EXTERNALS`

| Level | Output |
|-------|--------|
| `DBG_COMMON` | Archive external '{name}': not for this platform |
| `DBG_COMMON` | Archive external '{name}': {root} |

---

## 8. See Also

- [CMakeCraftPackage.md](../../CMakeCraftPackage.md) — pin file, fetching, deployment
- [Orchestrator_cmake.md](../Orchestrator_cmake.md) — dispatches here
- [Validation.md](../../core/Validation.md) — `archive` as source field
- [Packages.md](../../project/Packages.md) — produces packages that can be fetched here
- [Phase10_doc.md](../../buildSystemTest/Phase10_doc.md) — phase test

---

## 9. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.1.0** | **2026-10-09** | **CMakeCraft v0.11.0: passes the name of the external as `NAME` to `craft_package_deploy()` — the deploy target is called `<executable>_deploy_<external>`** |
| 1.0.0 | 2026-10-09 | Initial (CMakeCraft v0.10.0): external kind `archive`, E220, W304 |
