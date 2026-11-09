# lua54/Include.cmake — Lua 5.4 Scripting Engine Integration

> **Version:** 1.0.1  
> **Datum:** 2026-11-09  
> **Typ:** ModuleDoc  
> **Status:** Aktiv  
> **Basiert auf:** ModuleDoc v0.5, Doc v0.5  
> **Zielgruppe:** Build-System-Entwickler, C++ Entwickler  
> **Sprache:** Deutsch  
> **English:** [lua54_Include.md](../../../../../../en/guide/module/externals/includes/lua54/Lua54_Include.md)  
> **Modul:** [cmake/externals/includes/lua54/Include.cmake](../../../../../../../cmake/externals/includes/lua54/Include.cmake)  
> **Modul-Version:** 1.0.0

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Verfügbare Variablen](#2-verfügbare-variablen)
3. [Erstellte Targets](#3-erstellte-targets)
4. [Options](#4-options)
5. [Plattform-Unterstützung](#5-plattform-unterstützung)
6. [Verwendungsbeispiele](#6-verwendungsbeispiele)
7. [Verzeichnisstruktur](#7-verzeichnisstruktur)
8. [Fehlerbehandlung](#8-fehlerbehandlung)
9. [Siehe auch](#9-siehe-auch)
10. [Changelog](#changelog)

---

## 1. Übersicht

Die `lua54/Include.cmake` integriert die **Lua 5.4 Scripting Engine** als lokales External in das Build-System.

### Kernfunktionen

| Funktion | Beschreibung |
|----------|--------------|
| Embedded Scripting | Lua in C++ Anwendungen einbetten |
| Konfiguration | Lua-Dateien als Konfigurationsformat |
| Erweiterbar | C-Funktionen nach Lua exportieren |
| Lightweight | Minimaler Footprint (~300KB) |

### Einbindung

Legt **kein eigenes Target** an und kompiliert keine Lua-Quellen. Das Modul hängt die mitgelieferten, fertig gebauten Dateien aus `externals/lua54/` an das Target `EXECUTABLE_NAME`: Include-Pfad, Bibliothek (`win/lib/lua54.lib` bzw. `linux/lib/liblua54.a`/`.so`) und unter Windows im dynamischen Fall die `lua54.dll` neben das Target.

---

## 2. Verfügbare Variablen

Diese Variablen werden vom Orchestrator bereitgestellt:

| Variable | Beschreibung |
|----------|--------------|
| `EXTERNAL_NAME` | `"lua54"` |
| `EXTERNAL_ROOT` | Absoluter Pfad zu `externals/lua54` (`path` aus Solution.json) |
| `EXTERNAL_OPTIONS` | Target-spezifische Options (JSON) |
| `EXECUTABLE_NAME` | Target, an das Lua angehängt wird |

---

## 3. Erstellte Targets

| Target | Typ | Beschreibung |
|--------|-----|--------------|
| — | — | Kein eigenes Target; alles wird `PRIVATE` an `EXECUTABLE_NAME` gehängt |

### Was am Target gesetzt wird

| Plattform | Include-Pfad | Gelinkt | Weiteres |
|-----------|--------------|---------|----------|
| Windows | `win/include` | `win/lib/lua54.lib` (in beiden Modi) | dynamisch: POST_BUILD-Kopie `win/bin/lua54.dll` neben das Target |
| Linux | `win/include` | `linux/lib/liblua54.a` (embedded) oder `liblua54.so` (dynamisch), dazu `dl`, `m` | Define `LUA_USE_LINUX`; mit `LUA_USE_READLINE`: Define `LUA_USE_READLINE`, linkt `readline` |
| macOS | `win/include` | `lua` (System-Lua, z. B. über Homebrew) | Define `LUA_USE_MACOSX`; Warnung `macOS: Using system Lua or compile from sources` |
| andere | — | — | Warnung `Unsupported platform`, Abbruch des Moduls |

---

## 4. Options

| Option | Typ | Default | Beschreibung |
|--------|-----|---------|--------------|
| `LUA_EMBEDDED` | bool | `false` | Statisch linken. Vorgabe ist dynamisch; `true` braucht unter Windows eine statische `lua54.lib` — mit einer Import-Bibliothek linkt das Target, startet aber ohne `lua54.dll` nicht |
| `LUA_32BIT_COMPAT` | bool | `false` | 32-bit Integer/Float (setzt das Compile-Define `LUA_32BITS`) |
| `LUA_USE_READLINE` | bool | `false` | Readline-Unterstützung (nur Linux; linkt `readline`) |

### 4.1 LUA_EMBEDDED

Wenn `true`, wird Lua statisch gelinkt und keine `lua54.dll` neben das Target kopiert. Die Vorgabe ist `false` (dynamisch): gelinkt wird gegen `lua54.lib`, die `lua54.dll` wird nach dem Bau neben das Target kopiert.

Unter Windows setzt `true` eine **statische** `lua54.lib` voraus. Ist die Datei eine Import-Bibliothek zur DLL, linkt das Target zwar, startet aber nicht, weil die DLL fehlt.

### 4.2 LUA_32BIT_COMPAT

Für ressourcenbeschränkte Systeme. Verwendet 32-bit Integer und Float statt 64-bit.

---

## 5. Plattform-Unterstützung

### 5.1 Fertige Bibliotheken je Plattform

Lua wird nicht aus Quellen gebaut; das Modul nutzt, was unter `externals/lua54/` liegt:

| Plattform | Status | Hinweise |
|-----------|--------|----------|
| Windows | ✅ | `win/lib/lua54.lib`, `win/bin/lua54.dll` |
| Linux | ✅ | `linux/lib/liblua54.a`, `linux/lib/liblua54.so` |
| macOS | ⚠️ | Keine mitgelieferte Bibliothek; linkt das System-Lua `lua` |

### 5.2 Plattform-Defines

```cmake
# Linux
target_compile_definitions(${EXECUTABLE_NAME} PRIVATE LUA_USE_LINUX)
# macOS
target_compile_definitions(${EXECUTABLE_NAME} PRIVATE LUA_USE_MACOSX)
```

---

## 6. Verwendungsbeispiele

### 6.1 Basis-Verwendung

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

### 6.2 Konfigurationsdatei laden

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
    
    // Verwende width, fullscreen, title...
}

lua_close(L);
```

### 6.3 C-Funktion nach Lua exportieren

**C++:**

```cpp
// Funktion die von Lua aufgerufen werden kann
int lua_add(lua_State* L) {
    double a = luaL_checknumber(L, 1);
    double b = luaL_checknumber(L, 2);
    lua_pushnumber(L, a + b);
    return 1;  // Ein Rückgabewert
}

int main() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    
    // Funktion registrieren
    lua_pushcfunction(L, lua_add);
    lua_setglobal(L, "add");
    
    // In Lua verwenden
    luaL_dostring(L, "print(add(2, 3))");  // Ausgabe: 5
    
    lua_close(L);
    return 0;
}
```

---

## 7. Verzeichnisstruktur

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

## 8. Fehlerbehandlung

| Code | Beschreibung |
|------|--------------|
| E213 | Include.cmake nicht gefunden (`Orchestrator.cmake`) |
| E214 | External-Pfad existiert nicht (`local/Attach.cmake`) |

### Lua Runtime-Fehler

```cpp
if (luaL_dofile(L, "script.lua") != LUA_OK) {
    const char* error = lua_tostring(L, -1);
    std::cerr << "Lua Error: " << error << std::endl;
    lua_pop(L, 1);
}
```

---

## 9. Siehe auch

- [Externals_Reference.md](../../../../references/Externals.md) — Alle Externals
- [Externals_UserGuide.md](../../../../userguides/Externals.md) — Verwendungsanleitung
- [Attach_cmake.md](../../locals/Attach_cmake.md) — Local External Handler
- [Lua 5.4 Reference Manual](https://www.lua.org/manual/5.4/) — Offizielle Dokumentation

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **An den Code angeglichen: kein eigenes STATIC-Target aus Quellen, sondern fertige `win/lib/lua54.lib` (+ `lua54.dll`) bzw. `linux/lib/liblua54.a`/`.so` am Target `EXECUTABLE_NAME`; Variablen (`EXECUTABLE_NAME` statt `EXTERNAL_JSON`), Plattformen, Defines und Verzeichnisstruktur wie im Code** |
| 1.0.0 | 2025-12-26 | Release 1 (aus newCMake übernommen, `2e00db7`) |
| 0.5.0 | 2025-12-15 | Migration auf Blueprint v0.5.0, Convention-Pfad `cmake/externals/includes/lua54/` |
| 0.1.0 | 2025-12-05 | Initial: Lua 5.4 aus Quellen kompiliert |
