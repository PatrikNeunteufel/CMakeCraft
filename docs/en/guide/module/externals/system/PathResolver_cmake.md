# PathResolver.cmake — System External Path Resolution

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [PathResolver_cmake.md](../../../../../de/guide/module/externals/system/PathResolver_cmake.md)  
> **Module:** [cmake/externals/system/PathResolver.cmake](../../../../../../cmake/externals/system/PathResolver.cmake)  
> **Module Version:** 1.0.0  
> **Phase:** 9 (System Externals)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [API Reference](#3-api-reference)
4. [Search Priority](#4-search-priority)
5. [Environment Variables](#5-environment-variables)
6. [Usage Examples](#6-usage-examples)
7. [Debug Output](#7-debug-output)
8. [See Also](#8-see-also)
9. [Changelog](#9-changelog)

---

## 1. Overview

`PathResolver.cmake` is responsible for the **multi-stage path resolution** of system externals. It searches various sources for installation paths before `find_package()` is called.

### Core Functions

- **ENV variables** — Looks for `{PACKAGE}_ROOT`, `{PACKAGE}_DIR`, etc.
- **hints[]** — Uses paths from Solution.json
- **Standard paths** — Package-specific installation locations
- **Backup** — Fallback path with warning

### Architecture Position

```
system/Handler.cmake
       │
       ├── _resolve_system_path()
       ▼
┌─────────────────────┐
│    PathResolver     │  ← This module
└─────────────────────┘
       │
       ├── 1. ENV variables
       ├── 2. hints[]
       ├── 3. Package hook paths
       └── 4. backup
```

---

## 2. Dependencies

| Module | Purpose |
|--------|---------|
| `Debug.cmake` | `dbg` for debug output |

---

## 3. API Reference

### 3.1 _resolve_system_path()

Multi-stage path resolution for system packages.

```cmake
_resolve_system_path(
    EXT_NAME 
    PACKAGE 
    HINTS 
    ADDITIONAL_PATHS 
    BACKUP 
    OUT_PATH 
    OUT_IS_BACKUP
)
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `EXT_NAME` | String | Name of the external (for debug) |
| `PACKAGE` | String | Package name (e.g. "Qt6", "Boost") |
| `HINTS` | List | Hint paths from Solution.json |
| `ADDITIONAL_PATHS` | List | Paths from the package hook |
| `BACKUP` | String | Backup path (optional) |
| `OUT_PATH` | Var | Output: resolved path |
| `OUT_IS_BACKUP` | Var | Output: TRUE if the backup was used |

**Returns:**
- `OUT_PATH` — Resolved path or empty
- `OUT_IS_BACKUP` — TRUE if the backup path was used

---

## 4. Search Priority

The search runs in a fixed order — the first existing path wins:

```
┌─────────────────────────────────────────────────────────────┐
│                    Search priority                           │
├─────────────────────────────────────────────────────────────┤
│  1. ENV variables                                           │
│     ├── ${PACKAGE}_ROOT    (e.g. Qt6_ROOT)                  │
│     ├── ${PACKAGE}_DIR     (e.g. Qt6_DIR)                   │
│     ├── ${PACKAGE}_HOME    (e.g. Qt6_HOME)                  │
│     └── ${BASE}_ROOT       (e.g. QT_ROOT for Qt6)           │
│                                                             │
│  2. hints[] from Solution.json                              │
│     └── With ${VAR} expansion                               │
│                                                             │
│  3. Standard paths from the package hook                    │
│     └── _get_{Package}_standard_paths()                     │
│                                                             │
│  4. backup from Solution.json                               │
│     └── Triggers W501 warning                               │
│                                                             │
│  5. Empty (find_package() defaults)                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Environment Variables

### Supported Patterns

For a package `Qt6` the following ENV variables are checked:

| Variable | Example |
|----------|---------|
| `Qt6_ROOT` | `C:/Qt/6.8.0/msvc2022_64` |
| `Qt6_DIR` | `C:/Qt/6.8.0/msvc2022_64` |
| `Qt6_HOME` | `C:/Qt/6.8.0/msvc2022_64` |
| `QT_ROOT` | (without version number) |
| `QT_DIR` | (without version number) |
| `QT_HOME` | (without version number) |

### Example: Qt6

```bash
# Set one of these:
export QT_ROOT="C:/Qt/6.8.0/msvc2022_64"
export Qt6_ROOT="C:/Qt/6.8.0/msvc2022_64"
```

### Example: Boost

```bash
export BOOST_ROOT="C:/local/boost_1_84_0"
export Boost_ROOT="C:/local/boost_1_84_0"
```

---

## 6. Usage Examples

### In Handler.cmake (automatic)

```cmake
_resolve_system_path(
    "${EXT_NAME}"           # "qt6"
    "${_package}"           # "Qt6"
    "${_hints}"             # from Solution.json
    "${_additional_paths}"  # from the package hook
    "${_backup}"            # fallback
    _resolved_path          # output
    _used_backup            # output
)

if(_used_backup)
    cmake_warn("W501" "Using backup location...")
endif()
```

### hints[] with Variable Expansion

```json
{
    "qt6": {
        "system": true,
        "package": "Qt6",
        "hints": [
            "${QT_ROOT}",
            "${HOME}/Qt/6.8.0/gcc_64"
        ]
    }
}
```

The `${VAR}` syntax is expanded to `$ENV{VAR}`.

### backup for Developer Machines

```json
{
    "qt6": {
        "system": true,
        "package": "Qt6",
        "hints": ["${QT_ROOT}"],
        "backup": "C:/Qt/6.8.0/msvc2022_64"
    }
}
```

**Important:** `backup` always triggers W501 — for CI/CD the ENV variable should be set.

---

## 7. Debug Output

### Debug ID: `EXTERNALS`

| Level | Output |
|-------|--------|
| `DBG_RARE` | Found via ENV {VAR}: {path} |
| `DBG_RARE` | Found via hint: {path} |
| `DBG_RARE` | Found at standard path: {path} |
| `DBG_RARE` | Found at BACKUP: {path} |
| `DBG_RARE` | No path found, relying on find_package() defaults |
| `DBG_ULTRA_RARE` | ENV {VAR} set but doesn't exist |
| `DBG_ULTRA_RARE` | Hint references undefined ENV |

### Activation

```bash
cmake -DDEBUG_CATEGORIES="EXTERNALS" -DDEBUG_LEVEL=3 ..
```

---

## 8. See Also

- [Handler_cmake.md](Handler_cmake.md) — Uses PathResolver
- [packages/Qt6_cmake.md](packages/Qt6_cmake.md) — Qt6 standard paths
- [packages/Boost_cmake.md](packages/Boost_cmake.md) — Boost standard paths
- [Solution_Schema.md](../../../references/Solution_Schema.md) — hints/backup syntax

---

## 9. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.6.0 | 2025-12-18 | Initial: multi-stage path resolution, ENV expansion, ${VAR} syntax in hints |
