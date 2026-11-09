# lua54/Include.cmake — Lua 5.4 Scripting Engine Integration

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5, Doc v0.5  
> **Target Audience:** Build System Developers, C++ Developers  
> **Language:** English  
> **German:** [Lua54_Include.md](../../../../../../de/guide/module/externals/includes/lua54/Lua54_Include.md)  
> **Module:** [cmake/externals/includes/lua54/Include.cmake](../../../../../../../cmake/externals/includes/lua54/Include.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Available Variables](#2-available-variables)
3. [Created Targets](#3-created-targets)
4. [Options](#4-options)
5. [Platform Support](#5-platform-support)
6. [Usage Examples](#6-usage-examples)
7. [Directory Structure](#7-directory-structure)
8. [Error Handling](#8-error-handling)
9. [See Also](#9-see-also)
10. [Changelog](#changelog)

---

## 1. Overview

`lua54/Include.cmake` integrates the **Lua 5.4 scripting engine** into the build system as a local external.

### Core Functions

| Function | Description |
|----------|-------------|
| Embedded scripting | Embed Lua in C++ applications |
| Configuration | Lua files as a configuration format |
| Extensible | Export C functions to Lua |
| Lightweight | Minimal footprint (~300KB) |

### Integration

Creates **no target of its own** and compiles no Lua sources. The module attaches the shipped, prebuilt files from `externals/lua54/` to the target `EXECUTABLE_NAME`: include path, library (`win/lib/lua54.lib` or `linux/lib/liblua54.a`/`.so`) and, on Windows in the dynamic case, `lua54.dll` next to the target.

---

## 2. Available Variables

These variables are provided by the orchestrator:

| Variable | Description |
|----------|-------------|
| `EXTERNAL_NAME` | `"lua54"` |
| `EXTERNAL_ROOT` | Absolute path to `externals/lua54` (`path` from Solution.json) |
| `EXTERNAL_OPTIONS` | Target-specific options (JSON) |
| `EXECUTABLE_NAME` | Target that Lua is attached to |

---

## 3. Created Targets

| Target | Type | Description |
|--------|------|-------------|
| — | — | No target of its own; everything is attached `PRIVATE` to `EXECUTABLE_NAME` |

### What Is Set on the Target

| Platform | Include path | Linked | Other |
|----------|--------------|--------|-------|
| Windows | `win/include` | `win/lib/lua54.lib` (in both modes) | dynamic: POST_BUILD copy of `win/bin/lua54.dll` next to the target |
| Linux | `win/include` | `linux/lib/liblua54.a` (embedded) or `liblua54.so` (dynamic), plus `dl`, `m` | define `LUA_USE_LINUX`; with `LUA_USE_READLINE`: define `LUA_USE_READLINE`, links `readline` |
| macOS | `win/include` | `lua` (system Lua, e.g. via Homebrew) | define `LUA_USE_MACOSX`; warning `macOS: Using system Lua or compile from sources` |
| other | — | — | warning `Unsupported platform`, the module returns |

---

## 4. Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `LUA_EMBEDDED` | bool | `false` | Link statically. The default is dynamic; on Windows `true` needs a static `lua54.lib` — with an import library the target links but does not start without `lua54.dll` |
| `LUA_32BIT_COMPAT` | bool | `false` | 32-bit integer/float (sets the compile define `LUA_32BITS`) |
| `LUA_USE_READLINE` | bool | `false` | Readline support (Linux only; links `readline`) |

### 4.1 LUA_EMBEDDED

If `true`, Lua is linked statically and no `lua54.dll` is copied next to the target. The default is `false` (dynamic): linking is against `lua54.lib`, and `lua54.dll` is copied next to the target after the build.

On Windows, `true` requires a **static** `lua54.lib`. If the file is an import library for the DLL, the target links but does not start, because the DLL is missing.

### 4.2 LUA_32BIT_COMPAT

For resource-constrained systems. Uses 32-bit integer and float instead of 64-bit.

---

## 5. Platform Support

### 5.1 Prebuilt Libraries per Platform

Lua is not built from sources; the module uses what lies under `externals/lua54/`:

| Platform | Status | Notes |
|----------|--------|-------|
| Windows | ✅ | `win/lib/lua54.lib`, `win/bin/lua54.dll` |
| Linux | ✅ | `linux/lib/liblua54.a`, `linux/lib/liblua54.so` |
| macOS | ⚠️ | No shipped library; links the system Lua `lua` |

### 5.2 Platform Defines

```cmake
# Linux
target_compile_definitions(${EXECUTABLE_NAME} PRIVATE LUA_USE_LINUX)
# macOS
target_compile_definitions(${EXECUTABLE_NAME} PRIVATE LUA_USE_MACOSX)
```

---

## 6. Usage Examples

### 6.1 Basic Usage

**Solution.json:**

```json
{
    "externals": {
        "lua54": { "path": "externals/lua54" }
    },
    "executables": [
        {
            "name": "ScriptedApp",
            "externals": ["lua54"]
        }
    ]
}
```

**C++:**

```cpp
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

int main() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    
    luaL_dostring(L, "print('Hello from Lua!')");
    
    lua_close(L);
    return 0;
}
```

### 6.2 Loading a Configuration File

**config.lua:**

```lua
config = {
    window_width = 1920,
    window_height = 1080,
    fullscreen = false,
    title = "My Game"
}
```

**C++:**

```cpp
lua_State* L = luaL_newstate();
luaL_openlibs(L);

if (luaL_dofile(L, "config.lua") == LUA_OK) {
    lua_getglobal(L, "config");
    
    lua_getfield(L, -1, "window_width");
    int width = lua_tointeger(L, -1);
    lua_pop(L, 1);
    
    lua_getfield(L, -1, "fullscreen");
    bool fullscreen = lua_toboolean(L, -1);
    lua_pop(L, 1);
    
    lua_getfield(L, -1, "title");
    const char* title = lua_tostring(L, -1);
    lua_pop(L, 2);
    
    // Use width, fullscreen, title...
}

lua_close(L);
```

### 6.3 Exporting a C Function to Lua

**C++:**

```cpp
// Function that can be called from Lua
int lua_add(lua_State* L) {
    double a = luaL_checknumber(L, 1);
    double b = luaL_checknumber(L, 2);
    lua_pushnumber(L, a + b);
    return 1;  // One return value
}

int main() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    
    // Register the function
    lua_pushcfunction(L, lua_add);
    lua_setglobal(L, "add");
    
    // Use it in Lua
    luaL_dostring(L, "print(add(2, 3))");  // Output: 5
    
    lua_close(L);
    return 0;
}
```

---

## 7. Directory Structure

```
externals/lua54/
├── win/
│   ├── include/      ← lua.h, lua.hpp, luaconf.h, lualib.h, lauxlib.h
│   ├── lib/          ← lua54.lib
│   └── bin/          ← lua54.dll
└── linux/
    └── lib/          ← liblua54.a, liblua54.so
```

---

## 8. Error Handling

| Code | Description |
|------|-------------|
| E213 | Include.cmake not found (`Orchestrator.cmake`) |
| E214 | External path does not exist (`local/Attach.cmake`) |

### Lua Runtime Errors

```cpp
if (luaL_dofile(L, "script.lua") != LUA_OK) {
    const char* error = lua_tostring(L, -1);
    std::cerr << "Lua Error: " << error << std::endl;
    lua_pop(L, 1);
}
```

---

## 9. See Also

- [Externals_Reference.md](../../../../references/Externals.md) — All externals
- [Externals_UserGuide.md](../../../../userguides/Externals.md) — Usage guide
- [Attach_cmake.md](../../locals/Attach_cmake.md) — Local external handler
- [Lua 5.4 Reference Manual](https://www.lua.org/manual/5.4/) — Official documentation

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: no STATIC target built from sources, but the prebuilt `win/lib/lua54.lib` (+ `lua54.dll`) or `linux/lib/liblua54.a`/`.so` on the target `EXECUTABLE_NAME`; variables (`EXECUTABLE_NAME` instead of `EXTERNAL_JSON`), platforms, defines and directory structure as in the code** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0, convention path `cmake/externals/includes/lua54/` |
| 0.1.0 | 2025-12-05 | Initial: Lua 5.4 compiled from sources |
