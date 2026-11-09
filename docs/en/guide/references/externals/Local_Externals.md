# Local Externals — Overview

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Local_Externals.md](../../../../de/guide/references/externals/Local_Externals.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Conventions](#2-conventions)
3. [Categories](#3-categories)
4. [Quick Reference](#4-quick-reference)
5. [Include.cmake System](#5-includecmake-system)
6. [Usage](#6-usage)
7. [See Also](#7-see-also)
8. [Changelog](#changelog)

---

## 1. Overview

This reference lists **local external libraries** that are provided in the `externals/` folder. Unlike Git externals, these are not fetched but are precompiled, generated or present as sources.

### Scope

- **4 libraries** in 4 categories
- Precompiled libraries (BASS)
- Generated loaders (glad)
- Header-only libraries (doctest)
- Source-based libraries (lua54)

### Document Structure

The libraries are split by category into separate documents — **parallel to the Git categories**:

| Document | Category | Libraries | Git Counterpart |
|----------|----------|-----------|-----------------|
| [Local_Externals_Testing.md](Local_Externals_Testing.md) | Testing | doctest | Git_Externals_Testing.md |
| [Local_Externals_Scripting.md](Local_Externals_Scripting.md) | Scripting | lua54 | Git_Externals_Scripting.md |
| [Local_Externals_GUI.md](Local_Externals_GUI.md) | GUI | glad | Git_Externals_GUI.md |
| [Local_Externals_Media.md](Local_Externals_Media.md) | Media | BASS | Git_Externals_Media.md |

---

## 2. Conventions

### 2.1 Symbols

| Symbol | Meaning |
|--------|---------|
| ✅ | Available / Supported |
| ❌ | Not available |
| 📦 | Precompiled (binaries) |
| 🔧 | Generated (configurator) |
| 📄 | Header-only |
| 📝 | Compiled from sources |

### 2.2 Library Types

| Type | Description | Example |
|------|-------------|---------|
| **Precompiled** | DLLs/SOs with import libs | BASS |
| **Generated** | Created via web configurator | glad |
| **Header-Only** | Headers only, no compilation | doctest |
| **Source-based** | Compiled from sources | lua54 |

### 2.3 Include.cmake Paths

**Convention over Configuration:**

```
cmake/externals/includes/{name}/Include.cmake
```

| External | Include.cmake Path |
|----------|-------------------|
| doctest | `cmake/externals/includes/doctest/Include.cmake` |
| lua54 | `cmake/externals/includes/lua54/Include.cmake` |
| glad | `cmake/externals/includes/glad/Include.cmake` |
| bass | `cmake/externals/includes/bass/Include.cmake` |

---

## 3. Categories

### 3.1 Testing

Unit testing and benchmarking.

| Library | Type | Description | Platforms |
|---------|------|-------------|-----------|
| **doctest** | 📄 Header-Only | Fast testing framework | All |

→ Details: [Local_Externals_Testing.md](Local_Externals_Testing.md)

### 3.2 Scripting

Embedded scripting engines.

| Library | Type | Description | Platforms |
|---------|------|-------------|-----------|
| **lua54** | 📝 Source | Lua 5.4 scripting engine | All |

→ Details: [Local_Externals_Scripting.md](Local_Externals_Scripting.md)

### 3.3 GUI

OpenGL loading and rendering.

| Library | Type | Description | Platforms |
|---------|------|-------------|-----------|
| **glad** | 🔧 Generated | OpenGL function loader | All |

→ Details: [Local_Externals_GUI.md](Local_Externals_GUI.md)

### 3.4 Media

Audio processing and multimedia.

| Library | Type | Description | Platforms |
|---------|------|-------------|-----------|
| **BASS** | 📦 Precompiled | Audio library with plugin system | Win, Linux, macOS |

→ Details: [Local_Externals_Media.md](Local_Externals_Media.md)

---

## 4. Quick Reference

### 4.1 All Local Externals

| Library | Category | Type | Options | Detail Doc |
|---------|----------|------|---------|------------|
| **doctest** | Testing | 📄 Header-Only | — | [doctest_Include.md](../../module/externals/includes/doctest/Doctest_Include.md) |
| **lua54** | Scripting | 📝 Source | LUA_EMBEDDED | [lua54_Include.md](../../module/externals/includes/lua54/Lua54_Include.md) |
| **glad** | GUI | 🔧 Generated | — | [glad_Include.md](../../module/externals/includes/glad/Glad_Include.md) |
| **BASS** | Media | 📦 Precompiled | BASS_FLAC, BASS_FX, ... | [bass_Include.md](../../module/externals/includes/bass/Bass_Include.md) |

### 4.2 Category Mapping (Local ↔ Git)

| Category | Local Externals | Git Externals |
|----------|-----------------|---------------|
| **Testing** | doctest | googletest, catch2, benchmark |
| **Scripting** | lua54 | sol2, pybind11, chaiscript |
| **GUI** | glad | glfw, imgui, SDL2, raylib |
| **Media** | BASS | miniaudio, openal-soft, stb, glm |

### 4.3 Directory Structure

```
externals/
├── doctest/
│   └── include/
│       └── doctest/doctest.h
│
├── lua54/
│   └── src/
│       ├── lua.h
│       └── *.c
│
├── glad/
│   ├── include/
│   └── src/
│
└── bass/
    ├── include/
    └── lib/
```

### 4.4 Solution.json Overview

```json
{
    "externals": {
        "doctest": { "path": "externals/doctest" },
        "lua54": { "path": "externals/lua54" },
        "glad": { "path": "externals/glad" },
        "bass": { "path": "externals/bass" }
    }
}
```

---

## 5. Include.cmake System

### 5.1 Convention over Configuration

Local externals need an `Include.cmake` that creates the target:

```
cmake/externals/includes/{name}/Include.cmake
```

The `include` field in Solution.json is **optional** — the convention is used automatically.

### 5.2 Available Variables

The following variables are available in every Include.cmake:

| Variable | Description |
|----------|-------------|
| `EXTERNAL_NAME` | Name of the external (e.g. "bass") |
| `EXTERNAL_ROOT` | Absolute path to the external |
| `EXTERNAL_JSON` | JSON element from Solution.json |
| `EXTERNAL_OPTIONS` | Target-specific options |

### 5.3 Include.cmake Templates

**Header-only (doctest):**

```cmake
add_library(${EXTERNAL_NAME} INTERFACE)
target_include_directories(${EXTERNAL_NAME} INTERFACE
    "${EXTERNAL_ROOT}/include"
)
_register_external_target("${EXTERNAL_NAME}" "${EXTERNAL_NAME}" PRIMARY)
```

**From sources (lua54):**

```cmake
file(GLOB _lua_sources "${EXTERNAL_ROOT}/src/*.c")
add_library(lua54 STATIC ${_lua_sources})
target_include_directories(lua54 PUBLIC "${EXTERNAL_ROOT}/src")
_register_external_target("lua54" "lua54" PRIMARY)
```

**Generated (glad):**

```cmake
add_library(glad STATIC "${EXTERNAL_ROOT}/src/glad.c")
target_include_directories(glad PUBLIC "${EXTERNAL_ROOT}/include")
find_package(OpenGL REQUIRED)
target_link_libraries(glad PUBLIC OpenGL::GL)
_register_external_target("glad" "glad" PRIMARY)
```

**Precompiled (BASS):**

```cmake
add_library(bass SHARED IMPORTED GLOBAL)
set_target_properties(bass PROPERTIES
    IMPORTED_LOCATION "${EXTERNAL_ROOT}/lib/x64/bass.dll"
    IMPORTED_IMPLIB "${EXTERNAL_ROOT}/lib/x64/bass.lib"
)
target_include_directories(bass INTERFACE "${EXTERNAL_ROOT}/include")
_register_external_target("bass" "bass" PRIMARY)
```

---

## 6. Usage

### 6.1 Simple Local External

```json
{
    "externals": {
        "doctest": {
            "path": "externals/doctest"
        }
    },
    "tests": [
        {
            "name": "MyTests",
            "externals": ["doctest"]
        }
    ]
}
```

### 6.2 With Options (BASS Plugins)

```json
{
    "externals": {
        "bass": {
            "path": "externals/bass"
        }
    },
    "executables": [
        {
            "name": "AudioPlayer",
            "externals": ["bass"],
            "external_options": {
                "bass": {
                    "BASS_FLAC": true,
                    "BASS_FX": true
                }
            }
        }
    ]
}
```

### 6.3 Combined with Git Externals

```json
{
    "externals": {
        "glad": { "path": "externals/glad" },
        "glfw": { "git": "https://github.com/glfw/glfw.git", "tag": "3.4" },
        "imgui": { "git": "https://github.com/ocornut/imgui.git", "tag": "v1.91.6", "cmakeSupport": false }
    },
    "executables": [
        {
            "name": "MyGuiApp",
            "type": "GUI",
            "externals": ["glad", "glfw", "imgui"]
        }
    ]
}
```

> **Order matters:** glad → glfw → imgui

---

## 7. See Also

- [Externals.md](../Externals.md) — Main overview (Local + Git)
- [Git_Externals.md](Git_Externals.md) — Git Externals overview
- [Solution_Schema.md](../Solution_Schema.md) — External configuration
- [Attach_cmake.md](../../module/externals/locals/Attach_cmake.md) — Local External handler

### Category Documents

- [Local_Externals_Testing.md](Local_Externals_Testing.md) — doctest
- [Local_Externals_Scripting.md](Local_Externals_Scripting.md) — lua54
- [Local_Externals_GUI.md](Local_Externals_GUI.md) — glad
- [Local_Externals_Media.md](Local_Externals_Media.md) — BASS

### Detail Documentation (Include.cmake)

- [doctest_Include.md](../../module/externals/includes/doctest/Doctest_Include.md)
- [lua54_Include.md](../../module/externals/includes/lua54/Lua54_Include.md)
- [glad_Include.md](../../module/externals/includes/glad/Glad_Include.md)
- [bass_Include.md](../../module/externals/includes/bass/Bass_Include.md)

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.2 | 2025-12-15 | 4 categories parallel to Git: Testing, Scripting, GUI, Media |
| 0.5.0 | 2025-12-15 | Initial: overview for Local Externals |
