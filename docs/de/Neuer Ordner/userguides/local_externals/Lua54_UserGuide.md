# Lua 5.4 Scripting Engine — Benutzerhandbuch

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Guide  
> **Status:** Stabil  
> **Zielgruppe:** C++ Entwickler  
> **Modul:** externals/lua54/Include.cmake v0.1.0  
> **Basiert auf:** Guide v0.5  
> **Sprache:** Deutsch  
> **English:** [Lua54_UserGuide.md](../../en/guides/externals/Lua54_UserGuide.md)

---

## Inhaltsverzeichnis

1. [Überblick](#1-überblick)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Schnellstart](#3-schnellstart)
4. [Einbettungs-Modi](#4-einbettungs-modi)
5. [Lua-Skripte ausführen](#5-lua-skripte-ausführen)
6. [C++ und Lua verbinden](#6-c-und-lua-verbinden)
7. [Options konfigurieren](#7-options-konfigurieren)
8. [Stolpersteine und Lösungen](#8-stolpersteine-und-lösungen)
9. [Troubleshooting](#9-troubleshooting)
10. [Siehe auch](#10-siehe-auch)
11. [Changelog](#11-changelog)

---

## 1. Überblick

Lua ist eine leichtgewichtige Skriptsprache, die sich perfekt für Konfigurationsdateien, Gameplay-Scripting und Plugin-Systeme eignet.

### Features

- Eingebettet (statisch) oder dynamisch linkbar
- Vollständige Lua 5.4 Unterstützung
- C++ ↔ Lua Interoperabilität
- Plattformübergreifend

---

## 2. Voraussetzungen

- [ ] CMake Architecture V2 Build-System
- [ ] Lua 5.4 in `externals/lua54/` vorhanden

### Verzeichnisstruktur prüfen

```
externals/lua54/
├── Include.cmake
└── win/
    ├── include/
    │   ├── lua.h
    │   ├── lualib.h
    │   ├── lauxlib.h
    │   └── luaconf.h
    ├── lib/
    │   └── lua54.lib
    └── bin/
        └── lua54.dll
```

---

## 3. Schnellstart

**1. Solution.json:**

```json
{
    "externals": {
        "lua54": {
            "path": "externals/lua54"
        }
    },
    "executables": [
        {
            "name": "ScriptHost",
            "externals": ["lua54"]
        }
    ]
}
```

**2. C++ Code:**

```cpp
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <iostream>

int main() {
    // Lua State erstellen
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    
    // Lua-Code ausführen
    luaL_dostring(L, "print('Hallo aus Lua!')");
    
    // Cleanup
    lua_close(L);
    return 0;
}
```

---

## 4. Einbettungs-Modi

### 4.1 Statisch eingebettet (Standard)

Lua wird direkt in die Executable kompiliert. **Empfohlen** für Standalone-Anwendungen.

```json
{
    "executables": [
        {
            "name": "ScriptHost",
            "externals": ["lua54"]
        }
    ]
}
```

**Vorteile:** Keine externe DLL, einfache Verteilung

### 4.2 Dynamisch gelinkt

Lua als separate DLL. Nützlich für Plugin-Systeme.

```json
{
    "executables": [
        {
            "name": "ScriptHost",
            "externals": ["lua54"],
            "external_options": {
                "lua54": {
                    "LUA_EMBEDDED": false
                }
            }
        }
    ]
}
```

**Vorteile:** Plugins können eigenes Lua laden, kleinere Executable

---

## 5. Lua-Skripte ausführen

### 5.1 Wie führe ich einen Lua-String aus?

```cpp
lua_State* L = luaL_newstate();
luaL_openlibs(L);

if (luaL_dostring(L, "x = 10 + 20; print(x)") != LUA_OK) {
    std::cerr << "Lua Error: " << lua_tostring(L, -1) << std::endl;
    lua_pop(L, 1);
}

lua_close(L);
```

### 5.2 Wie führe ich eine Lua-Datei aus?

```cpp
lua_State* L = luaL_newstate();
luaL_openlibs(L);

if (luaL_dofile(L, "script.lua") != LUA_OK) {
    std::cerr << "Lua Error: " << lua_tostring(L, -1) << std::endl;
    lua_pop(L, 1);
}

lua_close(L);
```

### 5.3 Wie lese ich Lua-Variablen?

```cpp
// Nach luaL_dofile("config.lua"):
// config.lua: width = 800; height = 600

lua_getglobal(L, "width");
int width = lua_tointeger(L, -1);
lua_pop(L, 1);

lua_getglobal(L, "height");
int height = lua_tointeger(L, -1);
lua_pop(L, 1);

std::cout << "Größe: " << width << "x" << height << std::endl;
```

### 5.4 Wie lese ich Lua-Tabellen?

```lua
-- config.lua
settings = {
    width = 800,
    height = 600,
    fullscreen = false
}
```

```cpp
lua_getglobal(L, "settings");
if (lua_istable(L, -1)) {
    lua_getfield(L, -1, "width");
    int width = lua_tointeger(L, -1);
    lua_pop(L, 1);
    
    lua_getfield(L, -1, "height");
    int height = lua_tointeger(L, -1);
    lua_pop(L, 1);
    
    lua_getfield(L, -1, "fullscreen");
    bool fullscreen = lua_toboolean(L, -1);
    lua_pop(L, 1);
}
lua_pop(L, 1);  // settings Tabelle
```

---

## 6. C++ und Lua verbinden

### 6.1 Wie exponiere ich C++-Funktionen an Lua?

```cpp
// C++ Funktion die von Lua aufgerufen werden kann
int cpp_add(lua_State* L) {
    double a = luaL_checknumber(L, 1);
    double b = luaL_checknumber(L, 2);
    lua_pushnumber(L, a + b);
    return 1;  // Anzahl Rückgabewerte
}

int main() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    
    // Funktion registrieren
    lua_register(L, "add", cpp_add);
    
    // Jetzt in Lua verfügbar
    luaL_dostring(L, "result = add(10, 20); print(result)");  // Gibt 30 aus
    
    lua_close(L);
    return 0;
}
```

### 6.2 Wie rufe ich Lua-Funktionen aus C++ auf?

```lua
-- script.lua
function calculate(x, y)
    return x * y + 100
end
```

```cpp
luaL_dofile(L, "script.lua");

// Funktion auf Stack pushen
lua_getglobal(L, "calculate");

// Argumente pushen
lua_pushnumber(L, 10);
lua_pushnumber(L, 5);

// Funktion aufrufen (2 Args, 1 Rückgabewert)
if (lua_pcall(L, 2, 1, 0) != LUA_OK) {
    std::cerr << "Lua Error: " << lua_tostring(L, -1) << std::endl;
    lua_pop(L, 1);
} else {
    double result = lua_tonumber(L, -1);
    lua_pop(L, 1);
    std::cout << "Ergebnis: " << result << std::endl;  // 150
}
```

### 6.3 Wie übergebe ich Tabellen an Lua?

```cpp
// Neue Tabelle erstellen
lua_newtable(L);

// Werte einfügen
lua_pushstring(L, "name");
lua_pushstring(L, "Player1");
lua_settable(L, -3);

lua_pushstring(L, "health");
lua_pushinteger(L, 100);
lua_settable(L, -3);

// Als globale Variable setzen
lua_setglobal(L, "player");

// In Lua: print(player.name, player.health)
```

### 6.4 Wie erstelle ich ein Lua-Modul?

```cpp
static int mylib_hello(lua_State* L) {
    lua_pushstring(L, "Hello from mylib!");
    return 1;
}

static int mylib_add(lua_State* L) {
    double a = luaL_checknumber(L, 1);
    double b = luaL_checknumber(L, 2);
    lua_pushnumber(L, a + b);
    return 1;
}

static const struct luaL_Reg mylib[] = {
    {"hello", mylib_hello},
    {"add", mylib_add},
    {NULL, NULL}
};

int luaopen_mylib(lua_State* L) {
    luaL_newlib(L, mylib);
    return 1;
}

// Registrieren
luaL_requiref(L, "mylib", luaopen_mylib, 1);
lua_pop(L, 1);

// In Lua: local mylib = require("mylib"); print(mylib.hello())
```

---

## 7. Options konfigurieren

### 7.1 32-Bit Integer-Kompatibilität

Für ältere Lua-Skripte die 32-Bit Integer erwarten:

```json
"external_options": {
    "lua54": {
        "LUA_32BIT_COMPAT": true
    }
}
```

### 7.2 Readline-Support (nur Linux)

Für eine bessere interaktive Shell:

```json
"external_options": {
    "lua54": {
        "LUA_USE_READLINE": true
    }
}
```

**Voraussetzung:**
```bash
sudo apt install libreadline-dev
```

### 7.3 Options-Übersicht

| Option | Default | Beschreibung |
|--------|---------|--------------|
| `LUA_EMBEDDED` | `true` | Statische Library |
| `LUA_32BIT_COMPAT` | `false` | 32-Bit Integer-Modus |
| `LUA_USE_READLINE` | `false` | Readline (Linux) |

---

## 8. Stolpersteine und Lösungen

### 8.1 extern "C" vergessen

**Problem:**
```
undefined reference to `lua_newstate'
```

**Ursache:** Lua ist C, nicht C++. Header müssen mit `extern "C"` verlinkt werden.

**Lösung:** Die Standard-Header machen das automatisch, aber bei manuellen Deklarationen:

```cpp
extern "C" {
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
}
```

### 8.2 Stack nicht aufgeräumt

**Problem:** Speicherleck oder Stack Overflow nach vielen Operationen.

**Lösung:** Immer `lua_pop()` nach dem Lesen von Werten:

```cpp
lua_getglobal(L, "value");
int val = lua_tointeger(L, -1);
lua_pop(L, 1);  // Nicht vergessen!
```

### 8.3 DLL nicht gefunden

**Problem:**
```
lua54.dll was not found
```

**Lösung:** Entweder `LUA_EMBEDDED: true` verwenden oder DLL manuell kopieren.

---

## 9. Troubleshooting

### Checkliste

- [ ] `lua54` in Solution.json unter `externals` definiert?
- [ ] Executable verwendet `"externals": ["lua54"]`?
- [ ] `luaL_openlibs()` nach `luaL_newstate()` aufgerufen?
- [ ] `lua_close()` am Ende?
- [ ] Stack nach Operationen aufgeräumt?

### Häufige Fehler

| Fehler | Lösung |
|--------|--------|
| `undefined reference to lua*` | Library linken prüfen |
| `lua54.dll not found` | `LUA_EMBEDDED: true` verwenden |
| `attempt to call nil` | Funktion existiert nicht in Lua |
| `stack overflow` | `lua_pop()` nicht vergessen |

### Lua-Stack debuggen

```cpp
void dumpStack(lua_State* L) {
    int top = lua_gettop(L);
    std::cout << "Stack size: " << top << std::endl;
    for (int i = 1; i <= top; i++) {
        int type = lua_type(L, i);
        std::cout << i << ": " << lua_typename(L, type);
        if (type == LUA_TNUMBER) {
            std::cout << " = " << lua_tonumber(L, i);
        } else if (type == LUA_TSTRING) {
            std::cout << " = " << lua_tostring(L, i);
        }
        std::cout << std::endl;
    }
}
```

---

## 10. Siehe auch

- [Lua54 Include.cmake](../../modules/externals/lua54/Include.md) — Technische Dokumentation
- [Lua Manual](https://www.lua.org/manual/5.4/) — Offizielle Dokumentation
- [Lua C API](https://www.lua.org/manual/5.4/manual.html#4) — C API Reference

---

## 11. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Neu: Vollständiges Benutzerhandbuch mit Einbettung, C++/Lua-Verbindung** |
