# Lua 5.4 Scripting Engine – Include.cmake

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [externals/lua54/Include.cmake](../../../../externals/lua54/Include.cmake)  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [Include.md](../../../en/modules/externals/lua54/Include.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [Konzept](#3-konzept)
4. [API-Referenz](#4-api-referenz)
5. [Verwendungsbeispiele](#5-verwendungsbeispiele)
6. [Fehlerbehandlung](#6-fehlerbehandlung)
7. [Best Practices](#7-best-practices)
8. [Bekannte Einschränkungen](#8-bekannte-einschränkungen)
9. [Siehe auch](#9-siehe-auch)
10. [Changelog](#10-changelog)

---

## 1. Übersicht

Lua 5.4 ist eine leichtgewichtige Skriptsprache, ideal für eingebettete Anwendungen. Diese Integration unterstützt sowohl statisches als auch dynamisches Linken.

### Features

- Plattformübergreifend (Windows, Linux, macOS)
- Statisches Einbetten (empfohlen) oder dynamisches Linken
- Optionale 32-Bit Integer-Kompatibilität
- Linux: Readline-Support für interaktive Shell

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| CMake 3.19+ | System | Für JSON-Verarbeitung |
| dl (Linux) | System | Dynamisches Laden |
| m (Linux) | System | Mathematik-Library |
| readline (Linux) | Optional | Interaktive Shell |

---

## 3. Konzept

### 3.1 Einbettungs-Modi

| Modus | Beschreibung | Use Case |
|-------|--------------|----------|
| Embedded (static) | Lua wird in Executable eingebettet | Standalone-Apps |
| Dynamic (shared) | Lua als separate DLL | Plugin-Systeme |

### 3.2 Verzeichnisstruktur

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

### 3.3 Plattform-Definitionen

| Plattform | Compile-Definition |
|-----------|-------------------|
| Linux | `LUA_USE_LINUX` |
| macOS | `LUA_USE_MACOSX` |
| Windows | — |

---

## 4. API-Referenz

### 4.1 Erwartete Variablen

| Variable | Pflicht | Beschreibung |
|----------|---------|--------------|
| `EXTERNAL_NAME` | ✓ | Name des Externals (`"lua54"`) |
| `EXTERNAL_ROOT` | ✓ | Pfad zum External-Verzeichnis |
| `EXTERNAL_OPTIONS` | — | JSON-String mit Options |
| `EXECUTABLE_NAME` | ✓ | Ziel-Target |

### 4.2 Verfügbare Options

| Option | Typ | Default | Beschreibung |
|--------|-----|---------|--------------|
| `LUA_EMBEDDED` | bool | `true` | Statische Library verwenden |
| `LUA_32BIT_COMPAT` | bool | `false` | 32-Bit Integer-Kompatibilität |
| `LUA_USE_READLINE` | bool | `false` | Readline-Support (nur Linux) |

#### LUA_EMBEDDED

**Empfohlen: `true`**

| Wert | Verhalten |
|------|-----------|
| `true` | Lua statisch eingebettet, keine externe DLL |
| `false` | Lua als DLL, wird ins Output kopiert |

#### LUA_32BIT_COMPAT

Aktiviert `LUA_32BITS` für Kompatibilität mit älteren Lua-Skripten.

#### LUA_USE_READLINE

**Nur Linux.** Aktiviert GNU Readline für bessere interaktive Shell. Erfordert `libreadline-dev`.

### 4.3 Registrierte Targets

| Target | Typ | Beschreibung |
|--------|-----|--------------|
| `lua54` | PRIMARY | Lua Library |

---

## 5. Verwendungsbeispiele

### 5.1 External definieren (Solution.json)

```json
{
    "externals": {
        "lua54": {
            "path": "externals/lua54"
        }
    }
}
```

### 5.2 In Executable verwenden

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

### 5.3 Mit dynamischem Linken

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

## 6. Fehlerbehandlung

### Error Codes

| Code | Konstante | Beschreibung |
|------|-----------|--------------|
| E213 | `E_LOCAL_INCLUDE_NOT_FOUND` | Include.cmake nicht gefunden |

### Häufige Fehler

| Fehler | Ursache | Lösung |
|--------|---------|--------|
| `undefined reference to luaL_newstate` | Library nicht gelinkt | `lua54` in externals prüfen |
| `lua54.dll nicht gefunden` | DLL nicht kopiert | `LUA_EMBEDDED: true` verwenden |
| `LUA_USE_LINUX undefined` | Falsche Platform-Detection | Automatisch auf Linux |

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| `LUA_EMBEDDED: true` für Standalone | Dynamic für Standalone |
| `luaL_openlibs()` für Standardbibliotheken | Einzelne Libs manuell laden |
| `lua_close()` am Ende | Lua State leaken |

---

## 8. Bekannte Einschränkungen

- macOS verwendet System-Lua (`brew install lua`)
- Readline nur auf Linux verfügbar
- 32-Bit Kompatibilität kann Performance beeinflussen

---

## 9. Siehe auch

- [Lua54 UserGuide](../../../guides/externals/Lua54_UserGuide.md) — Benutzerhandbuch
- [Lua Manual](https://www.lua.org/manual/5.4/) — Offizielle Dokumentation
- [Lua C API](https://www.lua.org/manual/5.4/manual.html#4) — C API Reference

---

## 10. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.0 | 2025-12-08 | Initial: Blueprint-konform, Embedded/Dynamic Support |
