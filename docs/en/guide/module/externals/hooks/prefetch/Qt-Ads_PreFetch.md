# PreFetch/qt-ads.cmake — Qt-ADS PreFetch Hook

> **Version:** 2.1.0  
> **Date:** 2025-12-30  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5, Doc v0.5  
> **Audience:** Build System Developers  
> **Language:** English  
> **German:** [Qt-Ads_PreFetch.md](../../../../de/modules/externals/hooks/prefetch/Qt-Ads.md)  
> **Hook:** [cmake/externals/hooks/prefetch/qt-ads.cmake](../../../../../../cmake/externals/hooks/prefetch/qt-ads.cmake)  
> **Module Version:** 2.1.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Why a PreFetch Hook?](#2-why-a-prefetch-hook)
3. [Supported Versions](#3-supported-versions)
4. [Set Options](#4-set-options)
5. [Qt6::GuiPrivate (v2.1.0)](#5-qt6guiprivate-v210)
6. [The DLL Problem and Its Solution](#6-the-dll-problem-and-its-solution)
7. [Solution.json Configuration](#7-solutionjson-configuration)
8. [Dependencies](#8-dependencies)
9. [Error Handling](#9-error-handling)
10. [See Also](#10-see-also)
11. [Changelog](#11-changelog)

---

## 1. Overview

The `qt-ads.cmake` PreFetch Hook configures the Qt Advanced Docking System before the build. The main functions are:

1. **BUILD_STATIC=ON** — Builds qt-ads as a static library (eliminates DLL deployment issues)
2. **Load Qt6::GuiPrivate** — Required for Qt-ADS 4.4.x (Breaking Change!)
3. **BUILD_EXAMPLES=OFF** — No example targets
4. **ADS_INSTALL=OFF** — No installation (FetchContent)

---

## 2. Why a PreFetch Hook?

**Without Hook:**
- Examples and demo targets are built (10+ additional targets)
- **Shared Library (DLL)** is created → windeployqt errors!
- Qt-ADS 4.4.x fails due to missing Qt6::GuiPrivate

**With Hook:**
- Only `qt6advanceddocking` or `qtadvanceddocking-qt6` target
- **Static Library** (no DLL deployment needed)
- Qt6::GuiPrivate is automatically loaded
- windeployqt runs without errors

---

## 3. Supported Versions

| Qt-ADS Version | Target Name | Notes |
|----------------|-------------|-------|
| **4.3.x** | `qt6advanceddocking` | Original configuration |
| **4.4.x** | `qtadvanceddocking-qt6` | **Breaking Change:** Requires Qt6::GuiPrivate! |

### Breaking Change in 4.4.x

Qt-ADS 4.4.x uses Qt Private APIs and therefore has:
- Different target name: `qtadvanceddocking-qt6` instead of `qt6advanceddocking`
- New dependency: `Qt6::GuiPrivate`
- Namespace alias: `ads::qtadvanceddocking-qt6`

---

## 4. Set Options

| Option | Value | Description |
|--------|-------|-------------|
| `BUILD_STATIC` | `ON` | **Static Library** instead of Shared (DLL) |
| `BUILD_EXAMPLES` | `OFF` | No example programs |
| `ADS_INSTALL` | `OFF` | No installation (FetchContent) |

### Important: Correct Variable Name

The variable is called **`BUILD_STATIC`**, not `ADS_BUILD_STATIC`!

```cmake
# CORRECT:
set(BUILD_STATIC ON CACHE BOOL "Build qt-ads as static library" FORCE)

# WRONG (does NOT work):
set(ADS_BUILD_STATIC ON CACHE BOOL "..." FORCE)
```

See: [Qt-ADS CMakeLists.txt](https://github.com/githubuser0xFFFF/Qt-Advanced-Docking-System/blob/master/CMakeLists.txt)

---

## 5. Qt6::GuiPrivate (v2.1.0)

### 5.1 Why Required?

Qt-ADS 4.4.x uses Qt Private APIs for extended docking features. These APIs are contained in `Qt6::GuiPrivate` and must be loaded **before** `FetchContent_MakeAvailable()`.

### 5.2 Automatic Loading

The PreFetch Hook loads Qt6::GuiPrivate automatically:

```cmake
find_package(Qt6 QUIET COMPONENTS GuiPrivate)
if(TARGET Qt6::GuiPrivate)
    message(STATUS "[qt-ads]   Qt6::GuiPrivate: Found")
else()
    find_package(Qt6 REQUIRED COMPONENTS Gui)
    if(NOT TARGET Qt6::GuiPrivate)
        message(WARNING "[qt-ads] Qt6::GuiPrivate not available")
    endif()
endif()
```

### 5.3 On Error

If Qt6::GuiPrivate is not available:

```
[qt-ads] Qt6::GuiPrivate not available - Qt-ADS 4.4.x may fail to configure
[qt-ads] Consider using Qt-ADS 4.3.1 or ensuring Qt6 private headers are installed
```

**Solutions:**
1. Install Qt6 Private Headers (Qt Installer → Additional Libraries)
2. Downgrade to Qt-ADS 4.3.1 (tag: `4.3.1` in Solution.json)

---

## 6. The DLL Problem and Its Solution

### 6.1 The Problem

When qt-ads is built as a **Shared Library (DLL)**, the following error occurs:

```
Unable to find dependent libraries of C:\Qt\6.10.1\msvc2022_64\bin\qt6advanceddockingd.dll
Cannot open 'C:/Qt/6.10.1/msvc2022_64/bin/qt6advanceddockingd.dll': The system cannot find the file specified.
```

### 6.2 Cause

1. **windeployqt** scans the executable for DLL dependencies
2. It finds the dependency `qt6advanceddockingd.dll`
3. windeployqt searches for this DLL in the **Qt bin directory** (`C:\Qt\...\bin\`)
4. The DLL is not there (it was built via FetchContent)
5. **windeployqt aborts** — Qt DLLs are also not copied!

### 6.3 Attempted Solutions (that DO NOT work)

| Approach | Problem |
|----------|---------|
| Copy DLL before windeployqt | windeployqt still searches in Qt directory |
| Extend PATH | windeployqt ignores PATH for dependency analysis |
| `--ignore-library-errors` flag | Not available in all Qt versions |
| Ignore windeployqt errors | Qt DLLs are still not copied |

### 6.4 The Solution: Static Library

With `BUILD_STATIC=ON`, qt-ads is built as a **static library** (`.lib`):

| Aspect | Shared (DLL) | Static (LIB) |
|--------|--------------|--------------|
| Output | `qt6advanceddockingd.dll` | `qt6advanceddockingd.lib` |
| Deployment | DLL must be copied | Linked into executable |
| windeployqt | ❌ Error | ✅ No problem |
| EXE file size | Smaller | Larger (~2-3 MB) |

**Advantages of static library:**
- ✅ No DLL copying needed
- ✅ windeployqt runs without errors
- ✅ Simpler deployment (everything in one EXE)
- ✅ No DLL hell problems

---

## 7. Solution.json Configuration

### 7.1 Qt-ADS 4.3.x (stable)

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

### 7.2 Qt-ADS 4.4.x (latest features)

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

**Important:** `GuiPrivate` must be included in the Qt6 components, as Qt-ADS 4.4.x uses Qt Private APIs.

### 7.3 Important: Order

Qt6 must be processed **before** qt-ads. This is ensured by alphabetical sorting:
- `Qt6` (Q=81 ASCII) → processed first
- `qt-ads` (q=113 ASCII) → processed afterward

---

## 8. Dependencies

| External | Type | Description |
|----------|------|-------------|
| `Qt6` | System | Qt6 Core, Widgets, Gui must be loaded first |
| `Qt6::GuiPrivate` | System (optional) | Only required for Qt-ADS 4.4.x |

---

## 9. Error Handling

### 9.1 qt-ads is still built as DLL

**Symptom:**
```
[27/45] Linking CXX shared library x64\bin\qt6advanceddockingd.dll
```

**Cause:** CMake cache still contains old values.

**Solution:**
```cmd
rd /s /q .externals\qt-ads
rd /s /q out\build\<preset-name>
```

Then reconfigure CMake.

### 9.2 Qt-ADS 4.4.x does not configure

**Symptom:**
```
CMake Error: Could not find a package configuration file provided by "Qt6" with any of the following names:
  Qt6GuiPrivate.cmake
```

**Cause:** Qt6::GuiPrivate not installed.

**Solution:**
1. Open Qt Installer
2. Enable Private Headers under "Additional Libraries"
3. OR: Use Qt-ADS 4.3.1 (no GuiPrivate needed)

### 9.3 Check in CMake Output

With correct configuration:

```
-- [qt-ads] PreFetch: Configuring build options
-- [qt-ads]   Qt6::GuiPrivate: Found
-- [qt-ads]   BUILD_STATIC: ON (static library)
-- [qt-ads]   BUILD_EXAMPLES: OFF
-- [qt-ads]   ADS_INSTALL: OFF
-- [qt-ads] PreFetch complete
```

---

## 10. See Also

- [Qt-Ads_PostFetch.md](../postfetch/Qt-Ads.md) — PostFetch Hook (Target registration)
- [HookLoader.md](../../hooks/HookLoader_cmake.md) — Hook system
- [Qt6.md](../../../../userguides/externals/Qt6.md) — Qt6 System External

---

## 11. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **2.1.0** | **2025-12-30** | **New: Qt6::GuiPrivate support for Qt-ADS 4.4.x** |
| | | **New: ADS_INSTALL=OFF option** |
| | | **New: Documentation for 4.3.x vs 4.4.x breaking changes** |
| 1.1.0 | 2025-12-27 | Fix: `BUILD_STATIC` instead of `ADS_BUILD_STATIC` |
| | | New: Detailed documentation of the DLL problem |
| 1.0.0 | 2025-12-21 | Initial: PreFetch Hook for Qt-ADS |
