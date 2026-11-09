# Qt6.cmake — Qt6 Package Hook

> **Version:** 1.1.0  
> **Date:** 2026-11-09  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [Qt6_cmake.md](../../../../../../de/guide/module/externals/system/packages/Qt6_cmake.md)  
> **Module:** [cmake/externals/system/packages/Qt6.cmake](../../../../../../../cmake/externals/system/packages/Qt6.cmake)  
> **Module Version:** 1.1.0  
> **Phase:** 9 (System Externals)

---

## Table of Contents

1. [Overview](#1-overview)
2. [API Reference](#2-api-reference)
3. [Standard Paths](#3-standard-paths)
4. [Target Configuration](#4-target-configuration)
5. [Deployment](#5-deployment)
6. [Known Limitations](#6-known-limitations)
7. [Usage Examples](#7-usage-examples)
8. [Platform Differences](#8-platform-differences)
9. [See Also](#9-see-also)
10. [Changelog](#10-changelog)

---

## 1. Overview

`Qt6.cmake` is a **package hook** for Qt6 system externals. `system/Handler.cmake` loads it automatically when the
external definition contains `package="Qt6"`.

### Core Functions

- **Standard paths** — platform-specific Qt installation locations
- **AUTOMOC/AUTOUIC/AUTORCC** — enabled automatically for Qt targets
- **Entry point** — explicitly `WinMainCRTStartup` for Windows GUI programs (MSVC and clang)
- **Deployment** — windeployqt/macdeployqt integration

### Position in the Architecture

```
system/Handler.cmake
       │
       ├── package = "Qt6"
       ▼
┌─────────────────────┐
│  packages/Qt6.cmake │  ← this hook
└─────────────────────┘
       │
       ├── _get_Qt6_standard_paths()
       ├── _Qt6_post_find()
       └── _Qt6_configure_target()
              ├── _Qt6_configure_entry_point()
              └── _Qt6_configure_deployment()
```

---

## 2. API Reference

### 2.1 _get_Qt6_standard_paths()

Returns platform-specific Qt6 installation paths.

```cmake
_get_Qt6_standard_paths(OUT_VAR)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `OUT_VAR` | Var | Output: list of paths |

**Called:** automatically by `system/Handler.cmake` before `find_package()`.

---

### 2.2 _Qt6_post_find()

Called after `find_package(Qt6)` succeeded.

```cmake
_Qt6_post_find()
```

**Actions:**
- Stores the Qt prefix in the global property `QT6_PREFIX`
- Derives the path from the location of the `Qt6::Core` target

---

### 2.3 _Qt6_configure_target()

Configures a CMake target for use with Qt6.

```cmake
_Qt6_configure_target(TARGET_NAME)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `TARGET_NAME` | String | CMake target |

**Actions:**
- Enables AUTOMOC, AUTOUIC, AUTORCC
- Calls `_Qt6_configure_entry_point()`
- Calls `_Qt6_configure_deployment()`

---

### 2.4 _Qt6_configure_entry_point()

Sets the entry point of a Windows GUI program explicitly (since 1.1.0, CMakeCraft v0.14.1).

```cmake
_Qt6_configure_entry_point(TARGET_NAME)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `TARGET_NAME` | String | CMake target; only `EXECUTABLE` is affected |

**Why:** `Qt6EntryPoint.lib` (linked through `Qt6::Core` as soon as a target is `WIN32_EXECUTABLE`) defines **both**
functions, `WinMain` and `wWinMain`. Both jump into the same helper, which calls `main(__argc, __argv)`. Without an
explicit entry point:

| Linker | Behaviour without `/ENTRY` |
|--------|----------------------------|
| lld-link (clang) | picks `WinMain` and warns on every link: `found both wWinMain and WinMain; using latter` |
| link.exe (MSVC) | silently picks `WinMainCRTStartup` → `WinMain` |

**Action:** With MSVC and clang (MSVC ABI, i.e. `MSVC` or `CMAKE_CXX_SIMULATE_ID` = `MSVC`) the target gets

```cmake
target_link_options(<target> PRIVATE
    "$<$<AND:<WIN32_EXECUTABLE>,<not QT_NO_ENTRYPOINT>>:LINKER:/ENTRY:WinMainCRTStartup>")
```

- The condition matches the one under which Qt links `Qt6::EntryPoint`.
- It is a generator expression because an executable gets `WIN32_EXECUTABLE` only after its externals have been
  applied (`ExecutableCreate.cmake`).
- MinGW is left untouched.
- **Never set it globally:** CMake's compiler check links a console program without `WinMain`; `/ENTRY` in
  `CMAKE_EXE_LINKER_FLAGS` already breaks the configure step.

**Result** (measured 2026-11-09 on HoerTest_Helper, Release, Qt 6.10.1): clang without the warning; MSVC, according to
the map file, `WinMainCRTStartup` → `WinMain` from `Qt6EntryPoint` before and after. Self-test: phase 9, test 11.

---

### 2.5 _Qt6_configure_deployment()

Configures platform-specific Qt deployment.

```cmake
_Qt6_configure_deployment(TARGET_NAME)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `TARGET_NAME` | String | CMake target |

**Behaviour by target type:**

| Target type | Deployment |
|-------------|------------|
| EXECUTABLE | Yes (windeployqt/macdeployqt) |
| SHARED_LIBRARY | Yes |
| STATIC_LIBRARY | **No** (skipped) |
| INTERFACE_LIBRARY | **No** (skipped) |
| OBJECT_LIBRARY | **No** (skipped) |

---

## 3. Standard Paths

### Windows

```cmake
"C:/Qt/6.10.1/msvc2022_64"
"C:/Qt/6.10.0/msvc2022_64"
"C:/Qt/6.9.0/msvc2022_64"
"C:/Qt/6.8.1/msvc2022_64"
"C:/Qt/6.8.0/msvc2022_64"
"C:/Qt/6.7.3/msvc2022_64"
# ... further versions
# Alternative drives: D:, E:, I:
```

### macOS

```cmake
"$ENV{HOME}/Qt/6.8.0/macos"
"$ENV{HOME}/Qt/6.7.0/macos"
"/opt/homebrew/opt/qt@6"    # Homebrew (ARM)
"/usr/local/opt/qt@6"       # Homebrew (Intel)
```

### Linux

```cmake
"$ENV{HOME}/Qt/6.8.0/gcc_64"
"$ENV{HOME}/Qt/6.7.0/gcc_64"
"/opt/Qt/6.8.0/gcc_64"
"/usr/lib/qt6"               # system package
"/usr/lib/x86_64-linux-gnu/qt6"
```

---

## 4. Target Configuration

When `_Qt6_configure_target()` is called:

```cmake
set_target_properties(${TARGET_NAME} PROPERTIES
    AUTOMOC ON      # Meta-Object Compiler
    AUTOUIC ON      # UI compiler
    AUTORCC ON      # Resource compiler
)
```

### What AUTOMOC does

- Finds `Q_OBJECT` macros in headers
- Generates `moc_*.cpp` files automatically
- No manual `qt_wrap_cpp()` needed

### What AUTOUIC does

- Compiles `.ui` files into `ui_*.h`
- No manual `qt_wrap_ui()` needed

### What AUTORCC does

- Compiles `.qrc` resource files
- No manual `qt_add_resources()` needed

---

## 5. Deployment

### Windows (windeployqt)

```cmake
add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
    COMMAND "${_WINDEPLOYQT}"
        --no-translations
        --no-system-d3d-compiler
        --no-opengl-sw
        "$<TARGET_FILE:${TARGET_NAME}>"
)
```

**Copies automatically:**
- Qt6Core.dll, Qt6Widgets.dll, etc.
- platforms/qwindows.dll
- Further required plugins

### macOS (macdeployqt)

Only for bundle targets (`MACOSX_BUNDLE ON`):

```cmake
add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
    COMMAND "${_MACDEPLOYQT}"
        "$<TARGET_BUNDLE_DIR:${TARGET_NAME}>"
        -always-overwrite
)
```

**Also configures:**
- `INSTALL_RPATH`: `@executable_path/../lib`
- `BUILD_RPATH`: the Qt lib directory

### Linux (RPATH)

No deployment tool, but RPATH configuration:

```cmake
set_target_properties(${TARGET_NAME} PROPERTIES
    INSTALL_RPATH "$ORIGIN/../lib;${_qt_prefix}/lib"
    BUILD_RPATH "${_qt_prefix}/lib"
    INSTALL_RPATH_USE_LINK_PATH TRUE
)
```

---

## 6. Known Limitations

### 6.1 windeployqt and Fetched Qt-based Externals

**Problem:** When an executable depends on a **fetched Qt-based shared library** (e.g. qt-ads as a DLL), windeployqt
fails:

```
Unable to find dependent libraries of C:\Qt\6.10.1\...\bin\qt6advanceddockingd.dll
Cannot open '...qt6advanceddockingd.dll': The system cannot find the file specified.
```

**Cause:** windeployqt looks for DLL dependencies in the Qt bin directory, not in the build output.

**Solution:** Build fetched Qt-based externals as a **static library**:

```cmake
# In the external's PreFetch hook:
set(BUILD_STATIC ON CACHE BOOL "Build as static library" FORCE)
```

See [Qt-Ads_PreFetch.md](../../hooks/prefetch/Qt-Ads_PreFetch.md) for an example.

### 6.2 STATIC_LIBRARY Targets

windeployqt is skipped automatically for STATIC_LIBRARY targets, as it only works for executables and shared
libraries.

### 6.3 Entry Point Only Where the Executable Itself Names Qt6

`_Qt6_configure_entry_point()` runs for the target that lists the external `Qt6`. If only a library lists Qt6 and the
GUI executable does not, `Qt6::EntryPoint` still reaches the executable through the library, but the explicit entry
point does not — lld-link keeps warning. Remedy: list `Qt6` on the executable as well (for an app's runner under
`runner.externals`).

---

## 7. Usage Examples

### Solution.json

```json
{
    "externals": {
        "Qt6": {
            "system": true,
            "package": "Qt6",
            "components": ["Core", "Widgets", "Gui", "OpenGL"],
            "hints": ["${QT_ROOT}"]
        }
    },
    "executables": [
        {
            "name": "MyQtApp",
            "type": "GUI",
            "externals": ["Qt6"]
        }
    ]
}
```

### With qt-ads (static library)

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

**Important:** Qt6 must come alphabetically before qt-ads (upper-case Q < lower-case q).

### Recommended Environment Variable

```bash
# Windows
set QT_ROOT=C:\Qt\6.10.1\msvc2022_64

# Linux/macOS
export QT_ROOT=$HOME/Qt/6.8.0/gcc_64
```

---

## 8. Platform Differences

| Feature | Windows | macOS | Linux |
|---------|---------|-------|-------|
| Deployment tool | windeployqt | macdeployqt | — |
| RPATH | N/A | Yes | Yes |
| Bundle support | N/A | Yes | — |
| DLL copy | Automatic | In the bundle | Manual/RPATH |
| Explicit entry point | `WinMainCRTStartup` (MSVC ABI) | — | — |

---

## 9. See Also

- [Handler_cmake.md](../Handler_cmake.md) — loads this hook
- [PathResolver_cmake.md](../PathResolver_cmake.md) — path resolution
- [Qt-Ads_PreFetch.md](../../hooks/prefetch/Qt-Ads_PreFetch.md) — Qt-ADS hook (solves the windeployqt problem)
- [Qt6_Integration.md](../../../../userguides/Qt6_Integration.md) — user guide
- [Qt6 CMake Documentation](https://doc.qt.io/qt-6/cmake-manual.html) — official docs

---

## 10. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.1.0** | **2026-11-09** | **`_Qt6_configure_entry_point()`: explicit entry point `WinMainCRTStartup` for Windows GUI programs (MSVC and clang); limitation 6.3** |
| 1.0.0 | 2025-12-27 | Release: documented the windeployqt limitations with fetched externals |
| 0.6.1 | 2025-12-21 | Fix: skip deployment for STATIC_LIBRARY |
| 0.6.0 | 2025-12-18 | Initial: standard paths, AUTOMOC/AUTOUIC/AUTORCC, deployment |
