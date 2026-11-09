# Local/Attach.cmake — Local External Handler

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5, Doc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [Attach_cmake.md](../../../../../de/guide/module/externals/locals/Attach_cmake.md)  
> **Module:** [cmake/externals/Local/Attach.cmake](../../../../../../cmake/externals/local/Attach.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [API Reference](#3-api-reference)
4. [Include.cmake Convention](#4-includecmake-convention)
5. [Usage Examples](#5-usage-examples)
6. [Error Handling](#6-error-handling)
7. [See Also](#7-see-also)
8. [Changelog](#8-changelog)

---

## 1. Overview

`Local/Attach.cmake` processes local externals — libraries that are placed in the project manually (e.g. proprietary libraries such as BASS).

### Core Functions

- **Path validation** — Checks whether the external directory exists
- **Include.cmake lookup** — Convention or custom path
- **Best-practice checks** — Warnings for problematic patterns
- **Registration** — Stores paths for later use

---

## 2. Dependencies

| Module | Purpose |
|--------|---------|
| `Errors.cmake` | Error handling (`cmake_fatal`, `cmake_warn`) |
| `Debug.cmake` | Debug output (`dbg`) |
| `Json.cmake` | JSON parsing |
| `Validation.cmake` | Source validation |

---

## 3. API Reference

### 3.1 _attach_local_external()

```cmake
_attach_local_external(EXT_NAME EXT_JSON)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `EXT_NAME` | String | Name of the external |
| `EXT_JSON` | JSON | JSON definition with a `path` field |

**Sets properties:**

| Property | Description |
|----------|-------------|
| `EXTERNAL_${NAME}_PATH` | Absolute path to the external |
| `EXTERNAL_${NAME}_INCLUDE` | Path to the Include.cmake |
| `EXTERNAL_${NAME}_REGISTERED` | TRUE if registered |

---

### 3.2 is_external_registered()

```cmake
is_external_registered(EXT_NAME OUT_VAR)
```

Checks whether an external is registered.

---

## 4. Include.cmake Convention

### Convention Path (Default)

```
cmake/externals/includes/{name}/Include.cmake
```

**Example:** External `bass` → `cmake/externals/includes/bass/Include.cmake`

### Custom Include Path (optional)

```json
{
    "bass": {
        "path": "externals/bass",
        "include": "cmake/custom/bass_special.cmake"
    }
}
```

> **Note:** The `include` field is optional. If it is not given, the convention path is used.

---

## 5. Usage Examples

### Minimal (Convention)

```json
{
    "bass": {
        "path": "externals/bass"
    }
}
```

→ Looks up automatically: `cmake/externals/includes/bass/Include.cmake`

### With Version

```json
{
    "lua54": {
        "path": "externals/lua54",
        "version": "5.4.6"
    }
}
```

→ Looks up: `cmake/externals/includes/lua54/Include.cmake`

---

## 6. Error Handling

| Code | Error | Description |
|------|-------|-------------|
| E001 | Path empty | `path` field is empty |
| E213 | Include.cmake missing | Include.cmake not found |
| E214 | Path does not exist | External directory not present |

### Warnings

| Code | Warning | Description |
|------|---------|-------------|
| W103 | add_executable | External creates an executable |
| W104 | add_subdirectory | Examples/tests are added |

---

## 7. See Also

- [Orchestrator_cmake.md](../Orchestrator_cmake.md) — Type dispatcher
- [Externals_Reference.md](../../../references/Externals.md) — Directory structures

---

## 8. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-15 | Documentation migrated to Blueprint v0.5.0 |
