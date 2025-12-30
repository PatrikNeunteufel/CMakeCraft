# PostFetch/qt-ads.cmake — Qt-ADS PostFetch Hook

> **Version:** 2.0.0  
> **Date:** 2025-12-30  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5, Doc v0.5  
> **Audience:** Build System Developers  
> **Language:** English  
> **German:** [Qt-Ads_PostFetch.md](../../../../de/modules/externals/hooks/postfetch/Qt-Ads.md)  
> **Hook:** [cmake/externals/hooks/postfetch/qt-ads.cmake](../../../../../../cmake/externals/hooks/postfetch/qt-ads.cmake)  
> **Module Version:** 2.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Why a PostFetch Hook?](#2-why-a-postfetch-hook)
3. [Supported Versions](#3-supported-versions)
4. [Target Detection](#4-target-detection)
5. [Created Targets](#5-created-targets)
6. [Debug Output (v2.0.0)](#6-debug-output-v200)
7. [Solution.json Configuration](#7-solutionjson-configuration)
8. [Usage in Executables/Apps](#8-usage-in-executablesapps)
9. [Dependencies](#9-dependencies)
10. [Error Handling](#10-error-handling)
11. [See Also](#11-see-also)
12. [Changelog](#12-changelog)

---

## 1. Overview

The `qt-ads.cmake` PostFetch Hook registers the Qt Advanced Docking System target in the External Registry. Qt-ADS uses different target names depending on the version, which the hook automatically detects.

**Since v1.1.0:** The hook only registers the target. DLL copy logic has been removed since qt-ads is built as a **static library** (see PreFetch Hook).

**New in v2.0.0:** Support for Qt-ADS 4.4.x with new target naming and debug output when target is not found.

---

## 2. Why a PostFetch Hook?

Qt-ADS creates targets with different names depending on the version:

| Version | Target Name |
|---------|-------------|
| 4.3.x (Qt6) | `qt6advanceddocking` |
| 4.4.x (Qt6) | `qtadvanceddocking-qt6` |
| Qt5 (legacy) | `qtadvanceddocking` or `qtadvanceddocking-qt5` |

The build system cannot automatically find these targets under `qt-ads` without a hook.

**Without Hook:** `[E201] Fetched external 'qt-ads': No target in registry`

**With Hook:** Target is correctly registered and can be used.

---

## 3. Supported Versions

| Qt-ADS Version | Target Name | Namespace Alias |
|----------------|-------------|-----------------|
| **4.4.x** (Qt6) | `qtadvanceddocking-qt6` | `ads::qtadvanceddocking-qt6` |
| **4.3.x** (Qt6) | `qt6advanceddocking` | — |
| 4.x (Qt5) | `qtadvanceddocking-qt5` | — |
| Legacy | `qtadvanceddocking` | — |

### Breaking Change in 4.4.x

Qt-ADS 4.4.x changed the target naming:
- **Old (4.3.x):** `qt6advanceddocking`
- **New (4.4.x):** `qtadvanceddocking-qt6` with namespace `ads::`

The PostFetch Hook supports both conventions automatically.

---

## 4. Target Detection

The hook checks all possible target names in priority order:

```cmake
# Qt-ADS 4.4.x (preferred)
if(TARGET qtadvanceddocking-qt6)
    _register_external_target("${HOOK_EXTERNAL_NAME}" "qtadvanceddocking-qt6" PRIMARY)

# Qt-ADS 4.4.x namespace alias
elseif(TARGET ads::qtadvanceddocking-qt6)
    _register_external_target("${HOOK_EXTERNAL_NAME}" "ads::qtadvanceddocking-qt6" PRIMARY)

# Qt-ADS 4.3.x (legacy)
elseif(TARGET qt6advanceddocking)
    _register_external_target("${HOOK_EXTERNAL_NAME}" "qt6advanceddocking" PRIMARY)

# Qt5 fallback
elseif(TARGET qtadvanceddocking-qt5)
    _register_external_target("${HOOK_EXTERNAL_NAME}" "qtadvanceddocking-qt5" PRIMARY)

elseif(TARGET qtadvanceddocking)
    _register_external_target("${HOOK_EXTERNAL_NAME}" "qtadvanceddocking" PRIMARY)
endif()
```

This allows the hook to work with all Qt-ADS versions and Qt5/Qt6.

---

## 5. Created Targets

| Target | Type | Version | Description |
|--------|------|---------|-------------|
| `qtadvanceddocking-qt6` | **STATIC** | 4.4.x | Qt6 Advanced Docking (new) |
| `ads::qtadvanceddocking-qt6` | **ALIAS** | 4.4.x | Namespace alias |
| `qt6advanceddocking` | **STATIC** | 4.3.x | Qt6 Advanced Docking (legacy) |
| `qtadvanceddocking-qt5` | **STATIC** | 4.x | Qt5 fallback |
| `qtadvanceddocking` | **STATIC** | legacy | Old naming |

**Note:** All targets are built as **STATIC** library (configured in PreFetch Hook).

---

## 6. Debug Output (v2.0.0)

If no known target is found, the hook lists all available targets for diagnosis:

```cmake
if(NOT _target_found)
    message(WARNING "[qt-ads] No known target found!")
    message(STATUS "[qt-ads] Checking for targets containing 'ads' or 'docking'...")
    
    get_property(_all_targets DIRECTORY "${HOOK_SOURCE_DIR}" PROPERTY BUILDSYSTEM_TARGETS)
    foreach(_target IN LISTS _all_targets)
        string(TOLOWER "${_target}" _target_lower)
        if(_target_lower MATCHES "ads|docking|advanceddocking")
            message(STATUS "[qt-ads]   Found potential target: ${_target}")
        endif()
    endforeach()
endif()
```

This output helps diagnose new Qt-ADS versions with potentially changed target names.

---

## 7. Solution.json Configuration

### 7.1 Qt-ADS 4.3.x

```json
{
    "externals": {
        "Qt6": {
            "system": true,
            "package": "Qt6",
            "components": ["Core", "Widgets", "Gui"],
            "hints": ["${QT_ROOT}"]
        },
        "qt-ads": {
            "git": "https://github.com/githubuser0xFFFF/Qt-Advanced-Docking-System.git",
            "tag": "4.3.1"
        }
    }
}
```

### 7.2 Qt-ADS 4.4.x

```json
{
    "externals": {
        "Qt6": {
            "system": true,
            "package": "Qt6",
            "components": ["Core", "Widgets", "Gui", "GuiPrivate"],
            "hints": ["${QT_ROOT}"]
        },
        "qt-ads": {
            "git": "https://github.com/githubuser0xFFFF/Qt-Advanced-Docking-System.git",
            "tag": "4.4.0"
        }
    }
}
```

**Important:** `GuiPrivate` must be included in the Qt6 components (see PreFetch documentation).

---

## 8. Usage in Executables/Apps

### 8.1 In Executable

```json
{
    "executables": [{
        "name": "MyDockingApp",
        "type": "GUI",
        "externals": ["Qt6", "qt-ads"]
    }]
}
```

### 8.2 In App Container

```json
{
    "apps": [{
        "name": "MyVisualizer",
        "core": {
            "externals": ["Qt6", "qt-ads"]
        },
        "runner": {
            "type": "GUI",
            "externals": ["Qt6"]
        }
    }]
}
```

### 8.3 In Code

The registered target name is always `qt-ads`, regardless of the actual CMake target:

```cpp
// CMakeLists.txt or Solution.json
// externals: ["qt-ads"]

// C++ Code
#include "DockManager.h"
// Works with both 4.3.x AND 4.4.x
```

---

## 9. Dependencies

| External | Type | Description |
|----------|------|-------------|
| `Qt6` | System | Qt6 Core, Widgets, Gui (must be loaded first) |
| `Qt6::GuiPrivate` | System | Only for Qt-ADS 4.4.x (loaded in PreFetch) |

### Order in Solution.json

Qt6 **must come before** qt-ads in alphabetical sorting:
- ✅ `Qt6` → `qt-ads` (uppercase Q before lowercase q)
- ❌ `qt6` → `qt-ads` (both with lowercase q, wrong order)

---

## 10. Error Handling

### 10.1 No Target Found

**Symptom:**
```
[qt-ads] No known target found!
[qt-ads] Expected one of: qtadvanceddocking-qt6, qt6advanceddocking, qtadvanceddocking
```

**Causes:**
1. Qt was not found
2. Qt-ADS could not be compiled
3. New Qt-ADS version with unknown target name

**Solution:**
1. Ensure Qt6 is loaded before qt-ads
2. Check CMake output for compilation errors
3. Check debug output for potential targets

### 10.2 Qt-ADS 4.4.x Fails

**Symptom:**
```
CMake Error: Qt6::GuiPrivate not found
```

**Solution:** Check PreFetch Hook or downgrade to 4.3.1 (see PreFetch documentation).

### 10.3 Successful Registration

With correct configuration:

```
-- [qt-ads] PostFetch: Registering target
-- [qt-ads] Registered: qtadvanceddocking-qt6 (v4.4.x, STATIC)
-- [qt-ads] PostFetch complete
```

or for 4.3.x:

```
-- [qt-ads] PostFetch: Registering target
-- [qt-ads] Registered: qt6advanceddocking (v4.3.x, STATIC)
-- [qt-ads] PostFetch complete
```

---

## 11. See Also

- [Qt-Ads_PreFetch.md](../prefetch/Qt-Ads.md) — PreFetch Hook (Build options, Qt6::GuiPrivate, **DLL problem solution**)
- [HookLoader.md](../../hooks/HookLoader_cmake.md) — Hook system
- [Targets.md](../../registry/Targets_cmake.md) — Target registration
- [Qt6.md](../../system/packages/Qt6.md) — Qt6 System External

---

## 12. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **2.0.0** | **2025-12-30** | **New: Support for Qt-ADS 4.4.x target names (`qtadvanceddocking-qt6`)** |
| | | **New: Support for `ads::` namespace alias** |
| | | **New: Debug output when target not found** |
| | | **New: Qt5 fallback targets (`qtadvanceddocking-qt5`)** |
| 1.1.0 | 2025-12-27 | Removed: POST_LINK hook for DLL copy (no longer needed) |
| | | Updated: Documentation for static library |
| 1.0.0 | 2025-12-21 | Initial: PostFetch Hook for Qt-ADS target registration |
