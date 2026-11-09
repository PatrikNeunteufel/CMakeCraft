# Boost.cmake — Boost Package Hook

> **Version:** 1.0.0  
> **Date:** 2025-12-20  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [Boost_cmake.md](../../../../../../de/guide/module/externals/system/packages/Boost_cmake.md)  
> **Module:** [cmake/externals/system/packages/Boost.cmake](../../../../../../../cmake/externals/system/packages/Boost.cmake)  
> **Module Version:** 1.0.0  
> **Phase:** 9 (System Externals)

---

## Table of Contents

1. [Overview](#1-overview)
2. [API Reference](#2-api-reference)
3. [Standard Paths](#3-standard-paths)
4. [Target Configuration](#4-target-configuration)
5. [Usage Examples](#5-usage-examples)
6. [Boost Components](#6-boost-components)
7. [See Also](#7-see-also)
8. [Changelog](#8-changelog)

---

## 1. Overview

`Boost.cmake` is a **package hook** for Boost system externals. It is loaded automatically by `system/Handler.cmake` when `package="Boost"` is in the external definition.

### Core Functions

- **Standard paths** — Platform-specific Boost installation locations
- **Post-find** — Debug output after a successful find_package
- **MSVC auto-linking** — Disabled in favor of explicit linking

### Architecture Position

```
system/Handler.cmake
       │
       ├── package = "Boost"
       ▼
┌───────────────────────┐
│  packages/Boost.cmake │  ← This hook
└───────────────────────┘
       │
       ├── _get_Boost_standard_paths()
       ├── _Boost_post_find()
       └── _Boost_configure_target()
```

---

## 2. API Reference

### 2.1 _get_Boost_standard_paths()

Returns platform-specific Boost installation paths.

```cmake
_get_Boost_standard_paths(OUT_VAR)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `OUT_VAR` | Var | Output: list of paths |

**Call:** Automatically by `system/Handler.cmake` before `find_package()`.

---

### 2.2 _Boost_post_find()

Called after a successful `find_package(Boost)`.

```cmake
_Boost_post_find()
```

**Actions:**
- Debug output: version and include path
- No further configuration required

---

### 2.3 _Boost_configure_target()

Configures a CMake target for Boost use.

```cmake
_Boost_configure_target(TARGET_NAME)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `TARGET_NAME` | String | CMake target |

**Actions (MSVC only):**
- Defines `BOOST_ALL_NO_LIB` — disables auto-linking
- Enables explicit linking via `target_link_libraries()`

---

## 3. Standard Paths

### Windows

```cmake
"C:/local/boost_1_84_0"
"C:/local/boost_1_83_0"
"C:/local/boost_1_82_0"
"C:/local/boost_1_81_0"
"C:/Boost"
"D:/Boost"
```

### macOS

```cmake
"/opt/homebrew/opt/boost"   # Homebrew (ARM)
"/usr/local/opt/boost"      # Homebrew (Intel)
"/opt/local/include"        # MacPorts
```

### Linux

```cmake
"/usr/include/boost"        # System package (Debian/Ubuntu)
"/usr/local/include/boost"  # Installed manually
```

---

## 4. Target Configuration

### MSVC Auto-Linking Problem

MSVC has a Boost-specific "auto-linking" feature that links libraries automatically based on `#pragma comment(lib, ...)`. This can lead to conflicts.

### Solution

```cmake
target_compile_definitions(${TARGET_NAME} PRIVATE BOOST_ALL_NO_LIB)
```

**Effect:** 
- Disables auto-linking
- All Boost libraries must be linked explicitly via CMake
- Prevents version conflicts

---

## 5. Usage Examples

### Solution.json — Basic

```json
{
    "externals": {
        "boost": {
            "system": true,
            "package": "Boost",
            "version": "1.80"
        }
    }
}
```

### Solution.json — With Components

```json
{
    "externals": {
        "boost": {
            "system": true,
            "package": "Boost",
            "components": ["filesystem", "system", "thread"],
            "hints": ["${BOOST_ROOT}"]
        }
    },
    "executables": [
        {
            "name": "MyApp",
            "externals": ["boost"]
        }
    ]
}
```

### Recommended Environment Variable

```bash
# Windows
set BOOST_ROOT=C:\local\boost_1_84_0

# Linux/macOS
export BOOST_ROOT=/usr/local/boost_1_84_0
```

---

## 6. Boost Components

### Header-Only (No Component Needed)

These Boost libraries are header-only and need no `components`:

- `boost/algorithm`
- `boost/any`
- `boost/asio` (mostly)
- `boost/bind`
- `boost/function`
- `boost/lexical_cast`
- `boost/optional`
- `boost/smart_ptr`
- `boost/variant`

### Compiled Components

These need explicit `components`:

| Component | Description |
|-----------|-------------|
| `filesystem` | File system operations |
| `system` | System error handling |
| `thread` | Threading support |
| `regex` | Regular expressions |
| `date_time` | Date/time |
| `serialization` | Object serialization |
| `program_options` | Command-line parser |
| `iostreams` | I/O streams |
| `log` | Logging framework |

### CMake Targets

After `find_package(Boost COMPONENTS ...)`:

```cmake
Boost::filesystem
Boost::system
Boost::thread
# etc.
```

---

## 7. See Also

- [Handler_cmake.md](../Handler_cmake.md) — Loads this hook
- [PathResolver_cmake.md](../PathResolver_cmake.md) — Path resolution
- [Boost CMake Documentation](https://cmake.org/cmake/help/latest/module/FindBoost.html) — CMake FindBoost

---

## 8. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-20** | **Release version (date from the header; the file entered the repo only with `6fc7f4a`)** |
| 0.6.0 | 2025-12-18 | Initial: standard paths, post-find debug, BOOST_ALL_NO_LIB for MSVC |
