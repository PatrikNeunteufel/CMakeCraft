# Lua 5.4 — UserGuide

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Guide  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Lua54.md](../../../../de/guide/userguides/externals/Lua54.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Installation](#2-installation)
3. [Solution.json Configuration](#3-solutionjson-configuration)
4. [C++ Usage](#4-c-usage)
5. [Advanced Techniques](#5-advanced-techniques)
6. [Combination with sol2](#6-combination-with-sol2)
7. [Best Practices](#7-best-practices)
8. [Troubleshooting](#8-troubleshooting)
9. [Further Information](#9-further-information)
10. [Changelog](#changelog)

---

## 1. Overview

**Lua 5.4** is a lightweight, embeddable scripting engine.

| Aspect | Value |
|--------|-------|
| **Type** | Local External (source-based) |
| **Path** | `externals/lua54` |
| **License** | MIT |
| **Website** | [lua.org](https://www.lua.org/) |

### Why Lua?

| Advantage | Description |
|-----------|-------------|
| 🪶 **Lightweight** | ~300KB footprint |
| 🔌 **Embeddable** | Simple C API |
| ⚡ **Fast** | Performant VM |
| 📝 **Flexible** | Configuration, modding, scripting |

### Use Cases

| Use | Description |
|-----|-------------|
| **Configuration** | Lua files instead of JSON/XML |
| **Modding** | Players can extend games |
| **Scripting** | Moving gameplay logic out of the engine |
| **Automation** | Build scripts, tools |

---

## 2. Installation

### 2.1 Download

```bash
# From lua.org
curl -R -O https://www.lua.org/ftp/lua-5.4.6.tar.gz
tar zxf lua-5.4.6.tar.gz
mv lua-5.4.6/src externals/lua54/src
```

### 2.2 Directory Structure

```
externals/lua54/
└── src/
    ├── lua.h           # Main header
    ├── luaconf.h       # Configuration
    ├── lualib.h        # Standard libraries
    ├── lauxlib.h       # Auxiliary library
    ├── lapi.c
    ├── lcode.c
    └── ... (more .c files)
```

---

## 3. Solution.json Configuration

### 3.1 Minimal

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

### 3.2 With Options

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
            "externals": ["lua54"],
            "external_options": {
                "lua54": {
                    "LUA_EMBEDDED": false,
                    "LUA_32BIT_COMPAT": false
                }
            }
        }
    ]
}
```

### 3.3 Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `LUA_EMBEDDED` | bool | `false` | Link statically. The default is dynamic; under Windows `true` needs a static `lua54.lib` — with an import library the target links but does not start without `lua54.dll` |
| `LUA_32BIT_COMPAT` | bool | `false` | 32-bit integer/float (sets the compile define `LUA_32BITS`) |
| `LUA_USE_READLINE` | bool | `false` | Readline support (Linux only; links `readline`) |

---

## 4. C++ Usage

### 4.1 Basics

```cpp
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

int main() {
    // Create Lua state
    lua_State* L = luaL_newstate();
    
    // Open standard libraries
    luaL_openlibs(L);
    
    // Run Lua code
    luaL_dostring(L, "print('Hello from Lua!')");
    
    // Clean up
    lua_close(L);
    return 0;
}
```

### 4.2 Running a Lua File

**script.lua:**
```lua
print("Script loaded!")

function greet(name)
    return "Hello, " .. name .. "!"
end
```

**C++:**
```cpp
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <iostream>

int main() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    
    // Load and run file
    if (luaL_dofile(L, "script.lua") != LUA_OK) {
        std::cerr << "Error: " << lua_tostring(L, -1) << std::endl;
        lua_close(L);
        return 1;
    }
    
    // Call function
    lua_getglobal(L, "greet");      // Function onto stack
    lua_pushstring(L, "World");     // Argument onto stack
    
    if (lua_pcall(L, 1, 1, 0) != LUA_OK) {
        std::cerr << "Error: " << lua_tostring(L, -1) << std::endl;
    } else {
        const char* result = lua_tostring(L, -1);
        std::cout << result << std::endl;  // "Hello, World!"
    }
    
    lua_close(L);
    return 0;
}
```

### 4.3 Loading a Configuration File

**config.lua:**
```lua
config = {
    window = {
        width = 1920,
        height = 1080,
        fullscreen = false,
        title = "My Application"
    },
    graphics = {
        vsync = true,
        antialiasing = 4
    },
    audio = {
        volume = 0.8,
        muted = false
    }
}
```

**C++:**
```cpp
struct Config {
    int width, height;
    bool fullscreen;
    std::string title;
    bool vsync;
    int antialiasing;
    float volume;
    bool muted;
};

Config loadConfig(const char* filename) {
    Config cfg;
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    
    if (luaL_dofile(L, filename) != LUA_OK) {
        throw std::runtime_error(lua_tostring(L, -1));
    }
    
    lua_getglobal(L, "config");
    
    // Window settings
    lua_getfield(L, -1, "window");
    lua_getfield(L, -1, "width");
    cfg.width = lua_tointeger(L, -1);
    lua_pop(L, 1);
    
    lua_getfield(L, -1, "height");
    cfg.height = lua_tointeger(L, -1);
    lua_pop(L, 1);
    
    lua_getfield(L, -1, "fullscreen");
    cfg.fullscreen = lua_toboolean(L, -1);
    lua_pop(L, 1);
    
    lua_getfield(L, -1, "title");
    cfg.title = lua_tostring(L, -1);
    lua_pop(L, 2);  // title + window table
    
    // Graphics settings
    lua_getfield(L, -1, "graphics");
    lua_getfield(L, -1, "vsync");
    cfg.vsync = lua_toboolean(L, -1);
    lua_pop(L, 1);
    
    lua_getfield(L, -1, "antialiasing");
    cfg.antialiasing = lua_tointeger(L, -1);
    lua_pop(L, 2);  // antialiasing + graphics table
    
    // Audio settings
    lua_getfield(L, -1, "audio");
    lua_getfield(L, -1, "volume");
    cfg.volume = lua_tonumber(L, -1);
    lua_pop(L, 1);
    
    lua_getfield(L, -1, "muted");
    cfg.muted = lua_toboolean(L, -1);
    lua_pop(L, 3);  // muted + audio table + config table
    
    lua_close(L);
    return cfg;
}
```

### 4.4 Exporting a C Function to Lua

```cpp
// C function that can be called from Lua
int lua_add(lua_State* L) {
    // Get arguments from the stack
    double a = luaL_checknumber(L, 1);
    double b = luaL_checknumber(L, 2);
    
    // Push result onto the stack
    lua_pushnumber(L, a + b);
    
    // Number of return values
    return 1;
}

int lua_print_message(lua_State* L) {
    const char* msg = luaL_checkstring(L, 1);
    std::cout << "[C++] " << msg << std::endl;
    return 0;  // No return value
}

int main() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    
    // Register functions
    lua_pushcfunction(L, lua_add);
    lua_setglobal(L, "add");
    
    lua_pushcfunction(L, lua_print_message);
    lua_setglobal(L, "print_message");
    
    // Use in Lua
    luaL_dostring(L, R"(
        local result = add(10, 20)
        print("10 + 20 = " .. result)
        print_message("Hello from Lua!")
    )");
    
    lua_close(L);
    return 0;
}
```

### 4.5 Variables Between C++ and Lua

```cpp
// C++ → Lua
lua_pushnumber(L, 42);
lua_setglobal(L, "answer");

lua_pushstring(L, "Hello");
lua_setglobal(L, "greeting");

lua_pushboolean(L, true);
lua_setglobal(L, "enabled");

// Lua → C++
lua_getglobal(L, "player_score");
if (lua_isnumber(L, -1)) {
    int score = lua_tointeger(L, -1);
}
lua_pop(L, 1);

lua_getglobal(L, "player_name");
if (lua_isstring(L, -1)) {
    std::string name = lua_tostring(L, -1);
}
lua_pop(L, 1);
```

---

## 5. Advanced Techniques

### 5.1 Creating Tables

```cpp
// Create table: { name = "Player", health = 100, x = 0, y = 0 }
lua_newtable(L);

lua_pushstring(L, "Player");
lua_setfield(L, -2, "name");

lua_pushnumber(L, 100);
lua_setfield(L, -2, "health");

lua_pushnumber(L, 0);
lua_setfield(L, -2, "x");

lua_pushnumber(L, 0);
lua_setfield(L, -2, "y");

lua_setglobal(L, "player");
```

### 5.2 Creating Arrays

```cpp
// Create array: { "apple", "banana", "cherry" }
lua_newtable(L);

const char* fruits[] = {"apple", "banana", "cherry"};
for (int i = 0; i < 3; i++) {
    lua_pushstring(L, fruits[i]);
    lua_rawseti(L, -2, i + 1);  // Lua arrays start at 1
}

lua_setglobal(L, "fruits");
```

### 5.3 Metatables (Object Orientation)

```cpp
// Userdata with metatable
struct Vector2 {
    float x, y;
};

int vector2_new(lua_State* L) {
    float x = luaL_optnumber(L, 1, 0);
    float y = luaL_optnumber(L, 2, 0);
    
    Vector2* v = (Vector2*)lua_newuserdata(L, sizeof(Vector2));
    v->x = x;
    v->y = y;
    
    luaL_getmetatable(L, "Vector2");
    lua_setmetatable(L, -2);
    
    return 1;
}

int vector2_add(lua_State* L) {
    Vector2* a = (Vector2*)luaL_checkudata(L, 1, "Vector2");
    Vector2* b = (Vector2*)luaL_checkudata(L, 2, "Vector2");
    
    Vector2* result = (Vector2*)lua_newuserdata(L, sizeof(Vector2));
    result->x = a->x + b->x;
    result->y = a->y + b->y;
    
    luaL_getmetatable(L, "Vector2");
    lua_setmetatable(L, -2);
    
    return 1;
}

int vector2_tostring(lua_State* L) {
    Vector2* v = (Vector2*)luaL_checkudata(L, 1, "Vector2");
    lua_pushfstring(L, "Vector2(%f, %f)", v->x, v->y);
    return 1;
}

void register_vector2(lua_State* L) {
    luaL_newmetatable(L, "Vector2");
    
    lua_pushcfunction(L, vector2_add);
    lua_setfield(L, -2, "__add");
    
    lua_pushcfunction(L, vector2_tostring);
    lua_setfield(L, -2, "__tostring");
    
    lua_pop(L, 1);
    
    lua_pushcfunction(L, vector2_new);
    lua_setglobal(L, "Vector2");
}
```

**Lua:**
```lua
local a = Vector2(1, 2)
local b = Vector2(3, 4)
local c = a + b
print(c)  -- Vector2(4.0, 6.0)
```

### 5.4 Error Handling

```cpp
int safeCall(lua_State* L, const char* code) {
    int result = luaL_dostring(L, code);
    
    if (result != LUA_OK) {
        const char* error = lua_tostring(L, -1);
        std::cerr << "Lua Error: " << error << std::endl;
        lua_pop(L, 1);
        return -1;
    }
    
    return 0;
}

// With traceback
int traceback(lua_State* L) {
    const char* msg = lua_tostring(L, 1);
    luaL_traceback(L, L, msg, 1);
    return 1;
}

int safeCallWithTraceback(lua_State* L, const char* code) {
    lua_pushcfunction(L, traceback);
    int errfunc = lua_gettop(L);
    
    int result = luaL_loadstring(L, code);
    if (result != LUA_OK) {
        std::cerr << "Load Error: " << lua_tostring(L, -1) << std::endl;
        lua_pop(L, 2);
        return -1;
    }
    
    result = lua_pcall(L, 0, LUA_MULTRET, errfunc);
    if (result != LUA_OK) {
        std::cerr << lua_tostring(L, -1) << std::endl;
        lua_pop(L, 2);
        return -1;
    }
    
    lua_remove(L, errfunc);
    return 0;
}
```

---

## 6. Combination with sol2

For more convenient C++ bindings, **sol2** is recommended:

### 6.1 Solution.json

```json
{
    "externals": {
        "lua54": { "path": "externals/lua54" },
        "sol2": { "git": "https://github.com/ThePhD/sol2.git", "tag": "v3.3.1" }
    }
}
```

### 6.2 Simple Usage

```cpp
#include <sol/sol.hpp>

int main() {
    sol::state lua;
    lua.open_libraries(sol::lib::base, sol::lib::math, sol::lib::string);
    
    // Variables
    lua["x"] = 42;
    int x = lua["x"];
    
    // Functions (lambda)
    lua["add"] = [](int a, int b) { return a + b; };
    int result = lua["add"](2, 3);
    
    // Run script
    lua.script(R"(
        print("x = " .. x)
        print("2 + 3 = " .. add(2, 3))
    )");
    
    return 0;
}
```

### 6.3 Exporting Classes

```cpp
#include <sol/sol.hpp>

class Player {
public:
    std::string name;
    int health = 100;
    int x = 0, y = 0;
    
    Player(const std::string& n) : name(n) {}
    
    void damage(int amount) { 
        health = std::max(0, health - amount); 
    }
    
    void move(int dx, int dy) { 
        x += dx; 
        y += dy; 
    }
    
    bool isAlive() const { 
        return health > 0; 
    }
};

int main() {
    sol::state lua;
    lua.open_libraries(sol::lib::base);
    
    lua.new_usertype<Player>("Player",
        sol::constructors<Player(const std::string&)>(),
        "name", &Player::name,
        "health", &Player::health,
        "x", &Player::x,
        "y", &Player::y,
        "damage", &Player::damage,
        "move", &Player::move,
        "isAlive", &Player::isAlive
    );
    
    lua.script(R"(
        local player = Player.new("Hero")
        print(player.name .. " starts with " .. player.health .. " HP")
        
        player:damage(30)
        player:move(10, 5)
        
        print("Position: " .. player.x .. ", " .. player.y)
        print("Health: " .. player.health)
        print("Alive: " .. tostring(player:isAlive()))
    )");
    
    return 0;
}
```

---

## 7. Best Practices

### 7.1 Stack Management

```cpp
// ALWAYS clean up the stack!
void badExample(lua_State* L) {
    lua_getglobal(L, "value");  // Stack: +1
    int value = lua_tointeger(L, -1);
    // ERROR: stack not cleaned up!
}

void goodExample(lua_State* L) {
    lua_getglobal(L, "value");  // Stack: +1
    int value = lua_tointeger(L, -1);
    lua_pop(L, 1);              // Stack: -1 (balanced)
}
```

### 7.2 RAII for lua_State

```cpp
class LuaState {
public:
    LuaState() : L(luaL_newstate()) {
        luaL_openlibs(L);
    }
    
    ~LuaState() {
        lua_close(L);
    }
    
    // No copy
    LuaState(const LuaState&) = delete;
    LuaState& operator=(const LuaState&) = delete;
    
    operator lua_State*() { return L; }
    
private:
    lua_State* L;
};

// Usage
void example() {
    LuaState lua;
    luaL_dostring(lua, "print('Hello')");
}  // Automatic cleanup
```

### 7.3 Hot-Reloading Scripts

```cpp
class ScriptManager {
public:
    void loadScript(const std::string& name, const std::string& path) {
        scripts[name] = path;
        reloadScript(name);
    }
    
    void reloadScript(const std::string& name) {
        if (luaL_dofile(L, scripts[name].c_str()) != LUA_OK) {
            std::cerr << "Reload failed: " << lua_tostring(L, -1) << std::endl;
            lua_pop(L, 1);
        }
    }
    
    void reloadAll() {
        for (const auto& [name, path] : scripts) {
            reloadScript(name);
        }
    }
    
private:
    lua_State* L;
    std::unordered_map<std::string, std::string> scripts;
};
```

---

## 8. Troubleshooting

### 8.1 "lua.h not found"

**Problem:** Header not found

**Solution:** Check the path — Include.cmake expects `externals/lua54/src/lua.h`

### 8.2 Stack Overflow/Underflow

**Problem:** Lua crashes or behaves strangely

**Solution:** Check the stack balance with:
```cpp
int top_before = lua_gettop(L);
// ... operations ...
int top_after = lua_gettop(L);
assert(top_before == top_after);  // Should be equal
```

### 8.3 "attempt to call a nil value"

**Problem:** Function does not exist

**Solution:** Check whether the function was registered:
```cpp
lua_getglobal(L, "myFunction");
if (lua_isnil(L, -1)) {
    std::cerr << "Function not found!" << std::endl;
}
lua_pop(L, 1);
```

### 8.4 Memory Leaks

**Problem:** Memory grows continuously

**Solution:** Call `lua_close()`, or use sol2 (RAII).

---

## 9. Further Information

### Official Resources

| Resource | Link |
|----------|------|
| **Website** | [lua.org](https://www.lua.org/) |
| **Reference Manual** | [lua.org/manual/5.4](https://www.lua.org/manual/5.4/) |
| **Programming in Lua** | [lua.org/pil](https://www.lua.org/pil/) |
| **Source Code** | [lua.org/ftp](https://www.lua.org/ftp/) |

### See Also

- [Externals.md](../Externals.md) — Externals combinations
- [Local_Externals_Scripting.md](../../references/externals/Local_Externals_Scripting.md) — Reference
- [Git_Externals_Scripting.md](../../references/externals/Git_Externals_Scripting.md) — sol2, pybind11

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.2 | 2025-12-15 | Initial: detailed UserGuide for Lua 5.4 |
