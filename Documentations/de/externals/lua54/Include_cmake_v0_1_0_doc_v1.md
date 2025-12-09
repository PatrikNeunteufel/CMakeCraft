# Lua 5.4 Scripting Engine – Include.cmake Dokumentation

> **Version:** 0.1.0 (doc v1)  
> **Datum:** 2025-12-08  
> **Typ:** External Include Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** externals/lua54/Include.cmake  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** CMake_Blueprint v0.1, Externals v0.1  
> **Sprache:** Deutsch

---

## 1. Übersicht

Lua 5.4 ist eine leichtgewichtige Skriptsprache, ideal für eingebettete Anwendungen.
Diese Integration unterstützt sowohl statisches als auch dynamisches Linken.

**Kernfunktionen:**
- Plattformübergreifend (Windows, Linux, macOS)
- Statisches Einbetten (empfohlen) oder dynamisches Linken
- Optionale 32-Bit Integer-Kompatibilität
- Linux: Readline-Support für interaktive Shell

---

## 2. Verzeichnisstruktur

```
externals/lua54/
├── Include.cmake           ← Dieses Modul
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

## 3. Verfügbare Options

| Option | Typ | Default | Beschreibung |
|--------|-----|---------|--------------|
| `LUA_EMBEDDED` | bool | `true` | Statische Library verwenden |
| `LUA_32BIT_COMPAT` | bool | `false` | 32-Bit Integer-Kompatibilität |
| `LUA_USE_READLINE` | bool | `false` | Readline-Support (nur Linux) |

### 3.1 LUA_EMBEDDED

**Empfohlen: `true`**

| Modus | Beschreibung |
|-------|--------------|
| Embedded (static) | Lua wird in die Executable eingebettet, keine externe DLL nötig |
| Dynamic (shared) | Lua als separate DLL, wird ins Output-Verzeichnis kopiert |

### 3.2 LUA_32BIT_COMPAT

Aktiviert `LUA_32BITS` für Kompatibilität mit älteren Lua-Skripten die
32-Bit Integer-Verhalten erwarten.

### 3.3 LUA_USE_READLINE

Nur Linux: Aktiviert GNU Readline für eine bessere interaktive Shell.
Erfordert `libreadline-dev` auf dem System.

---

## 4. Verwendung in Solution.json

### 4.1 External definieren

```json
{
    "externals": {
        "lua54": {
            "path": "externals/lua54"
        }
    }
}
```

### 4.2 In Executable verwenden

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

### 4.3 Mit dynamischem Linken

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

---

## 5. C++ Verwendung

### 5.1 Lua State erstellen

```cpp
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

int main() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);  // Standardbibliotheken laden
    
    // Lua-Code ausführen
    luaL_dostring(L, "print('Hello from Lua!')");
    
    lua_close(L);
    return 0;
}
```

### 5.2 Lua-Datei ausführen

```cpp
lua_State* L = luaL_newstate();
luaL_openlibs(L);

if (luaL_dofile(L, "script.lua") != LUA_OK) {
    std::cerr << "Error: " << lua_tostring(L, -1) << std::endl;
    lua_pop(L, 1);
}

lua_close(L);
```

### 5.3 C-Funktion für Lua registrieren

```cpp
int my_cpp_function(lua_State* L) {
    double x = luaL_checknumber(L, 1);
    double y = luaL_checknumber(L, 2);
    lua_pushnumber(L, x + y);
    return 1;  // Anzahl Rückgabewerte
}

// Registrieren:
lua_register(L, "add", my_cpp_function);

// In Lua:
// result = add(10, 20)  --> 30
```

### 5.4 Lua-Tabelle lesen

```cpp
lua_getglobal(L, "config");
if (lua_istable(L, -1)) {
    lua_getfield(L, -1, "width");
    int width = lua_tointeger(L, -1);
    lua_pop(L, 1);
    
    lua_getfield(L, -1, "height");
    int height = lua_tointeger(L, -1);
    lua_pop(L, 1);
}
lua_pop(L, 1);  // config table
```

---

## 6. Platform-Verhalten

### Windows

- Statisches oder dynamisches Linken
- DLL wird automatisch kopiert (bei `LUA_EMBEDDED: false`)
- Keine zusätzlichen System-Libraries erforderlich

### Linux

- Zusätzliche Libraries: `dl`, `m` (automatisch gelinkt)
- Compile-Definition: `LUA_USE_LINUX`
- Optional: Readline-Support

### macOS

- Verwendet System-Lua (`brew install lua`)
- Compile-Definition: `LUA_USE_MACOSX`
- Warnung wenn kein System-Lua gefunden

---

## 7. Fehlerbehebung

### undefined reference to `luaL_newstate`

**Ursache:** Library nicht gelinkt.  
**Lösung:** Prüfe ob `lua54` in `externals` der Solution.json eingetragen ist.

### lua54.dll nicht gefunden

**Ursache:** DLL nicht im Executable-Verzeichnis.  
**Lösung:** 
- Setze `LUA_EMBEDDED: false` um DLL automatisch zu kopieren
- Oder verwende `LUA_EMBEDDED: true` (empfohlen)

### LUA_USE_LINUX undefined

**Ursache:** Falsche Platform-Detection.  
**Lösung:** Wird automatisch gesetzt auf Linux-Systemen.

---

## 8. Siehe auch

- [Externals](../../References/Externals_v0_1_0.md) – Alle Externals
- [Lua Manual](https://www.lua.org/manual/5.4/) – Offizielle Dokumentation
- [Lua C API](https://www.lua.org/manual/5.4/manual.html#4) – C API Reference

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-08** | **Initial: Blueprint-konform, Embedded/Dynamic Support** |
