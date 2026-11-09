# Externals — User Guide

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Guide  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Externals.md](../../../de/guide/userguides/Externals.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Integrating External Libraries](#2-integrating-external-libraries)
3. [Combinations](#3-combinations)
4. [Order and Dependencies](#4-order-and-dependencies)
5. [Typical Project Setups](#5-typical-project-setups)
6. [Troubleshooting](#6-troubleshooting)
7. [Detail Guides](#7-detail-guides)
8. [See Also](#8-see-also)
9. [Changelog](#changelog)

---

## 1. Overview

This guide explains how external libraries are combined in the CMake Architecture build system. For detailed information on individual externals, see the [detail guides](#7-detail-guides).

### External Types

| Type | Source | Examples |
|------|--------|----------|
| **Local** | `path` | doctest, lua54, glad, BASS |
| **Git** | `git` | glfw, imgui, googletest, Qt6 |

### Basic Principle

```json
{
    "externals": {
        "name": { "path": "..." }
    },
    "executables": [
        {
            "name": "MyApp",
            "externals": ["name"]
        }
    ]
}
```

---

## 2. Integrating External Libraries

### 2.1 Local External

```json
{
    "externals": {
        "doctest": {
            "path": "externals/doctest"
        }
    }
}
```

### 2.2 Git External

```json
{
    "externals": {
        "glfw": {
            "git": "https://github.com/glfw/glfw.git",
            "tag": "3.4"
        }
    }
}
```

### 2.3 Git External Without CMake Support

```json
{
    "externals": {
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.91.6",
            "cmakeSupport": false
        }
    }
}
```

### 2.4 With Options

```json
{
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

---

## 3. Combinations

### 3.1 OpenGL GUI Application

The classic combination for OpenGL-based GUI applications:

| External | Type | Function |
|----------|------|----------|
| **glad** | Local | OpenGL function loader |
| **glfw** | Git | Window & input |
| **imgui** | Git | Immediate mode GUI |

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

### 3.2 Scripted Application

Lua scripting with convenient C++ bindings:

| External | Type | Function |
|----------|------|----------|
| **lua54** | Local | Lua 5.4 core engine |
| **sol2** | Git | Modern C++ bindings |

```json
{
    "externals": {
        "lua54": { "path": "externals/lua54" },
        "sol2": { "git": "https://github.com/ThePhD/sol2.git", "tag": "v3.3.1" }
    },
    "executables": [
        {
            "name": "ScriptedApp",
            "externals": ["lua54", "sol2"]
        }
    ]
}
```

### 3.3 Audio Player

Professional audio playback with plugins:

| External | Type | Function |
|----------|------|----------|
| **BASS** | Local | Audio core + plugins |

```json
{
    "externals": {
        "bass": { "path": "externals/bass" }
    },
    "executables": [
        {
            "name": "AudioPlayer",
            "externals": ["bass"],
            "external_options": {
                "bass": {
                    "BASS_FLAC": true,
                    "BASS_OPUS": true,
                    "BASS_FX": true
                }
            }
        }
    ]
}
```

### 3.4 Unit Testing

| Combination | Use case |
|-------------|----------|
| **doctest** (Local) | Fast tests, header-only |
| **googletest** (Git) | Mocking with GMock |
| **catch2** (Git) | BDD-style testing |

```json
{
    "externals": {
        "doctest": { "path": "externals/doctest" }
    },
    "tests": [
        {
            "name": "UnitTests",
            "framework": "doctest",
            "externals": ["doctest"]
        }
    ]
}
```

### 3.5 Qt6 Desktop Application

Professional desktop application with Qt6:

| External | Type | Function |
|----------|------|----------|
| **Qt6** | System | GUI framework |

```json
{
    "externals": {
        "qt6": {
            "system": true,
            "components": ["Widgets", "Core", "Gui"]
        }
    },
    "executables": [
        {
            "name": "QtApp",
            "type": "GUI",
            "externals": ["qt6"]
        }
    ]
}
```

### 3.6 Game with Scripting and Audio

Complex combination for games:

```json
{
    "externals": {
        "glad": { "path": "externals/glad" },
        "glfw": { "git": "https://github.com/glfw/glfw.git", "tag": "3.4" },
        "imgui": { "git": "https://github.com/ocornut/imgui.git", "tag": "v1.91.6", "cmakeSupport": false },
        "lua54": { "path": "externals/lua54" },
        "sol2": { "git": "https://github.com/ThePhD/sol2.git", "tag": "v3.3.1" },
        "bass": { "path": "externals/bass" }
    },
    "executables": [
        {
            "name": "MyGame",
            "type": "GUI",
            "externals": ["glad", "glfw", "imgui", "lua54", "sol2", "bass"],
            "external_options": {
                "bass": { "BASS_FLAC": true }
            }
        }
    ]
}
```

---

## 4. Order and Dependencies

### 4.1 Critical Orders

Some externals have **dependencies** that require a specific order:

| Combination | Order | Reason |
|-------------|-------|--------|
| OpenGL + ImGui | glad → glfw → imgui | imgui needs an OpenGL context |
| Lua + sol2 | lua54 → sol2 | sol2 wraps lua54 |

### 4.2 glad → glfw → imgui

```
1. glad      - Loads OpenGL functions
2. glfw      - Creates a window with an OpenGL context
3. imgui     - Uses OpenGL for rendering
```

**In code:**

```cpp
// 1. Initialize GLFW
glfwInit();
GLFWwindow* window = glfwCreateWindow(800, 600, "App", nullptr, nullptr);
glfwMakeContextCurrent(window);

// 2. Load GLAD (AFTER MakeContextCurrent!)
gladLoadGLLoader((GLADloadproc)glfwGetProcAddress);

// 3. Initialize ImGui (AFTER GLAD!)
IMGUI_CHECKVERSION();
ImGui::CreateContext();
ImGui_ImplGlfw_InitForOpenGL(window, true);
ImGui_ImplOpenGL3_Init("#version 330");
```

### 4.3 lua54 → sol2

```
1. lua54    - Lua core engine
2. sol2     - C++ wrapper around lua54
```

**In code:**

```cpp
// sol2 includes lua automatically
#include <sol/sol.hpp>

sol::state lua;  // Uses lua54 internally
lua.open_libraries(sol::lib::base);
```

---

## 5. Typical Project Setups

### 5.1 Minimal GUI Project

```json
{
    "solution": {
        "name": "MinimalGui",
        "version": "1.0.0"
    },
    "externals": {
        "glad": { "path": "externals/glad" },
        "glfw": { "git": "https://github.com/glfw/glfw.git", "tag": "3.4" }
    },
    "executables": [
        {
            "name": "MinimalGui",
            "type": "GUI",
            "externals": ["glad", "glfw"]
        }
    ]
}
```

### 5.2 Project with Tests

```json
{
    "solution": {
        "name": "TestedProject",
        "version": "1.0.0"
    },
    "externals": {
        "doctest": { "path": "externals/doctest" }
    },
    "libraries": [
        {
            "name": "CoreLib",
            "type": "static"
        }
    ],
    "executables": [
        {
            "name": "MainApp",
            "libraries": ["CoreLib"]
        }
    ],
    "tests": [
        {
            "name": "CoreTests",
            "framework": "doctest",
            "externals": ["doctest"],
            "libraries": ["CoreLib"]
        }
    ]
}
```

### 5.3 Multi-Executable Project

```json
{
    "solution": {
        "name": "MultiApp",
        "version": "1.0.0"
    },
    "externals": {
        "glad": { "path": "externals/glad" },
        "glfw": { "git": "https://github.com/glfw/glfw.git", "tag": "3.4" },
        "imgui": { "git": "https://github.com/ocornut/imgui.git", "tag": "v1.91.6", "cmakeSupport": false },
        "doctest": { "path": "externals/doctest" }
    },
    "executables": [
        {
            "name": "Editor",
            "type": "GUI",
            "externals": ["glad", "glfw", "imgui"]
        },
        {
            "name": "CLI",
            "type": "console"
        }
    ],
    "tests": [
        {
            "name": "AllTests",
            "framework": "doctest",
            "externals": ["doctest"]
        }
    ]
}
```

---

## 6. Troubleshooting

### 6.1 "undefined reference to gl..."

**Problem:** OpenGL functions not found

**Solution:** Put glad before glfw in the externals list, and call `gladLoadGLLoader()` after `glfwMakeContextCurrent()`.

### 6.2 "imgui.h not found"

**Problem:** ImGui header not found

**Solution:** Set `"cmakeSupport": false` for imgui, check the PostFetch hook.

### 6.3 "lua.h not found" with sol2

**Problem:** sol2 does not find Lua

**Solution:** lua54 BEFORE sol2 in the externals list.

### 6.4 BASS Plugin Not Loaded

**Problem:** FLAC/Opus files are not played

**Solution:** Enable the corresponding option in `external_options`:

```json
"external_options": {
    "bass": { "BASS_FLAC": true }
}
```

### 6.5 Qt6 Not Found

**Problem:** CMake does not find Qt6

**Solution:** Set `CMAKE_PREFIX_PATH` to the Qt6 installation:

```bash
cmake -DCMAKE_PREFIX_PATH=/path/to/Qt/6.x.x/gcc_64 ..
```

---

## 7. Detail Guides

For detailed information on individual externals:

### Local Externals

| External | Guide | Description |
|----------|-------|-------------|
| doctest | [externals/doctest.md](externals/Doctest.md) | Header-only testing |
| lua54 | [externals/lua54.md](externals/Lua54.md) | Lua 5.4 scripting |
| glad | [externals/glad.md](externals/Glad.md) | OpenGL loader |
| BASS | [externals/bass.md](externals/Bass.md) | Audio with plugins |

### Git Externals

| External | Guide | Description |
|----------|-------|-------------|
| glfw | [externals/glfw.md](externals/Glfw.md) | Window & input |
| imgui | [externals/imgui.md](externals/Imgui.md) | Immediate mode GUI |
| googletest | [externals/googletest.md](externals/Googletest.md) | Testing + GMock |
| catch2 | [externals/catch2.md](externals/Catch2.md) | BDD-style testing |
| Qt6 | [externals/qt6.md](externals/Qt6.md) | Desktop GUI framework |

---

## 8. See Also

- [Externals.md](../references/Externals.md) — Reference of all externals
- [Local_Externals.md](../references/externals/Local_Externals.md) — Local externals reference
- [Git_Externals.md](../references/externals/Git_Externals.md) — Git externals reference
- [Solution_Schema.md](../references/Solution_Schema.md) — JSON schema

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.2 | 2025-12-15 | Focus on combinations; detail guides moved out |
| 0.5.0 | 2025-12-14 | Initial |
