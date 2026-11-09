# Local Externals — Scripting

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Local_Externals_Scripting.md](../../../../de/guide/references/externals/Local_Externals_Scripting.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Lua 5.4 Scripting Engine](#2-lua-54-scripting-engine)
3. [See Also](#3-see-also)
4. [Changelog](#changelog)

---

## 1. Overview

This document describes local scripting externals for the CMake Architecture build system.

| Library | Description | License |
|---------|-------------|---------|
| **lua54** | Lua 5.4 scripting engine | MIT |

---

## 2. Lua 5.4 Scripting Engine

### Quick Info

| Aspect | Value |
|--------|-------|
| **Type** | 📝 Source-based |
| **Path** | `externals/lua54` |
| **Include.cmake** | `cmake/externals/includes/lua54/Include.cmake` |
| **Platforms** | All |
| **Website** | [lua.org](https://www.lua.org/) |

### Why Lua?

| Advantage | Description |
|-----------|-------------|
| **Lightweight** | Minimal footprint (~300KB) |
| **Embeddable** | Easy to embed in C++ |
| **Flexible** | Configuration, modding, scripting |
| **Fast** | Very performant VM |

### Solution.json

```json
{
    "externals": {
        "lua54": {
            "path": "externals/lua54"
        }
    },
    "executables": [
        {
            "name": "ScriptedApp",
            "externals": ["lua54"]
        }
    ]
}
```

### Directory Structure

```
externals/lua54/
└── src/
    ├── lua.h
    ├── luaconf.h
    ├── lualib.h
    ├── lauxlib.h
    ├── lapi.c
    ├── lcode.c
    ├── ... (more .c files)
    └── lutf8lib.c
```

### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `LUA_EMBEDDED` | bool | `false` | Link statically. The default is dynamic; under Windows `true` needs a static `lua54.lib` — with an import library the target links but does not start without `lua54.dll` |
| `LUA_32BIT_COMPAT` | bool | `false` | 32-bit integer/float (sets the compile define `LUA_32BITS`) |
| `LUA_USE_READLINE` | bool | `false` | Readline support (Linux only; links `readline`) |

### Usage Example

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

### Loading a Configuration File

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
}

lua_close(L);
```

### Exporting a C Function to Lua

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
    
    // Register function
    lua_pushcfunction(L, lua_add);
    lua_setglobal(L, "add");
    
    // Use in Lua
    luaL_dostring(L, "print(add(2, 3))");  // Output: 5
    
    lua_close(L);
    return 0;
}
```

### Combination with sol2 (Git)

For more convenient C++ bindings, sol2 is recommended:

```json
{
    "externals": {
        "lua54": { "path": "externals/lua54" },
        "sol2": { "git": "https://github.com/ThePhD/sol2.git", "tag": "v3.3.1" }
    }
}
```

```cpp
#include <sol/sol.hpp>

int main() {
    sol::state lua;
    lua.open_libraries(sol::lib::base);
    
    // Simpler!
    lua["add"] = [](int a, int b) { return a + b; };
    
    lua.script("print(add(2, 3))");
    
    return 0;
}
```

### Use Cases

| Use | Description |
|-----|-------------|
| **Configuration** | Lua files instead of JSON/XML |
| **Modding** | Players can extend games |
| **Scripting** | Gameplay logic in Lua |
| **Automation** | Build scripts, tools |

### Comparison with Git Alternatives

| Feature | lua54 (Local) | sol2 (Git) | pybind11 (Git) |
|---------|---------------|------------|----------------|
| **Language** | Lua | Lua (C++ wrapper) | Python |
| **Footprint** | ~300KB | Header-only | Larger |
| **C++ Integration** | Manual | Automatic | Automatic |
| **Use case** | Core engine | C++ bindings | Python bindings |

### Detail Documentation

→ [lua54_Include.md](../../module/externals/includes/lua54/Lua54_Include.md)

---

## 3. See Also

- [Externals.md](../Externals.md) — Main overview of all externals
- [Local_Externals.md](Local_Externals.md) — Local Externals overview
- [Git_Externals_Scripting.md](Git_Externals_Scripting.md) — Git scripting externals (sol2, pybind11)
- [Lua 5.4 Reference Manual](https://www.lua.org/manual/5.4/) — Official documentation

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.2 | 2025-12-15 | Own category Scripting (parallel to Git) |
