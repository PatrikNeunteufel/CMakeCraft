# Boost.cmake — Boost Package Hook

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** Aktiv  
> **Based on:** ModuleDoc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [Boost_cmake.md](Boost_cmake.md)  
> **Module:** [cmake/externals/system/packages/Boost.cmake](../../../../../../cmake/externals/system/packages/Boost.cmake)  
> **Module Version:** 1.0.0  
> **Phase:** 9 (System Externals)

---

## Table of Contents

1. [Overview](#1-übersicht)
2. [API-Reference](#2-api-referenz)
3. [Standard-Pfade](#3-standard-pfade)
4. [Target-Configuration](#4-target-konfiguration)
5. [Usagesbeispiele](#5-verwendungsbeispiele)
6. [Boost-Komponenten](#6-boost-komponenten)
7. [See Also](#7-siehe-auch)
8. [Changelog](#8-changelog)

---

## 1. Overview

`Boost.cmake` ist ein **Package-Hook** für Boost System Externals. Er wird automatisch von `system/Handler.cmake` geladen, wenn `package="Boost"` in der External-Definition steht.

### Kernfunktionen

- **Standard-Pfade** — Plattform-spezifische Boost-Installationsorte
- **Post-Find** — Debug-Ausgabe nach erfolgreichem find_package
- **MSVC Auto-Linking** — Deaktiviert für explizites Linking

### Architecture-Position

```
system/Handler.cmake
       │
       ├── package = "Boost"
       ▼
┌───────────────────────┐
│  packages/Boost.cmake │  ← Dieser Hook
└───────────────────────┘
       │
       ├── _get_Boost_standard_paths()
       ├── _Boost_post_find()
       └── _Boost_configure_target()
```

---

## 2. API-Reference

### 2.1 _get_Boost_standard_paths()

Liefert plattform-spezifische Boost-Installationspfade.

```cmake
_get_Boost_standard_paths(OUT_VAR)
```

| Parameters | Typ | Description |
|-----------|-----|--------------|
| `OUT_VAR` | Var | Ausgabe: Liste von Pfaden |

**Aufruf:** Automatisch von `system/Handler.cmake` vor `find_package()`.

---

### 2.2 _Boost_post_find()

Wird nach erfolgreichem `find_package(Boost)` aufgerufen.

```cmake
_Boost_post_find()
```

**Aktionen:**
- Debug-Ausgabe: Version und Include-Pfad
- Keine weitere Configuration erforderlich

---

### 2.3 _Boost_configure_target()

Konfiguriert ein CMake-Target für Boost-Usage.

```cmake
_Boost_configure_target(TARGET_NAME)
```

| Parameters | Typ | Description |
|-----------|-----|--------------|
| `TARGET_NAME` | String | CMake-Target |

**Aktionen (nur MSVC):**
- Definiert `BOOST_ALL_NO_LIB` — Deaktiviert Auto-Linking
- Ermöglicht explizites Linking via `target_link_libraries()`

---

## 3. Standard-Pfade

### Windows

```cmake
"C:/local/boost_1_84_0"
"C:/local/boost_1_83_0"
"C:/local/boost_1_82_0"
"C:/local/boost_1_81_0"
"C:/Boost"
"D:/Boost"
```

### macOS

```cmake
"/opt/homebrew/opt/boost"   # Homebrew (ARM)
"/usr/local/opt/boost"      # Homebrew (Intel)
"/opt/local/include"        # MacPorts
```

### Linux

```cmake
"/usr/include/boost"        # System-Paket (Debian/Ubuntu)
"/usr/local/include/boost"  # Manuell installiert
```

---

## 4. Target-Configuration

### MSVC Auto-Linking Problem

MSVC hat eine Boost-spezifische "Auto-Linking" Funktion, die automatisch Libraries verlinkt basierend auf `#pragma comment(lib, ...)`. Dies kann zu Konflikten führen.

### Lösung

```cmake
target_compile_definitions(${TARGET_NAME} PRIVATE BOOST_ALL_NO_LIB)
```

**Effekt:** 
- Deaktiviert Auto-Linking
- Alle Boost-Libraries müssen explizit via CMake gelinkt werden
- Verhindert Versionskonflikte

---

## 5. Usagesbeispiele

### Solution.json — Basis

```json
{
    "externals": {
        "boost": {
            "system": true,
            "package": "Boost",
            "version": "1.80"
        }
    }
}
```

### Solution.json — Mit Komponenten

```json
{
    "externals": {
        "boost": {
            "system": true,
            "package": "Boost",
            "components": ["filesystem", "system", "thread"],
            "hints": ["${BOOST_ROOT}"]
        }
    },
    "executables": [
        {
            "name": "MyApp",
            "externals": ["boost"]
        }
    ]
}
```

### Empfohlene Umgebungsvariable

```bash
# Windows
set BOOST_ROOT=C:\local\boost_1_84_0

# Linux/macOS
export BOOST_ROOT=/usr/local/boost_1_84_0
```

---

## 6. Boost-Komponenten

### Header-Only (keine Komponente nötig)

Diese Boost-Libraries sind Header-Only und brauchen keine `components`:

- `boost/algorithm`
- `boost/any`
- `boost/asio` (meist)
- `boost/bind`
- `boost/function`
- `boost/lexical_cast`
- `boost/optional`
- `boost/smart_ptr`
- `boost/variant`

### Compiled Components

Diese benötigen explizite `components`:

| Komponente | Description |
|------------|--------------|
| `filesystem` | Dateisystem-Operationen |
| `system` | System-Errorbehandlung |
| `thread` | Threading-Support |
| `regex` | Reguläre Ausdrücke |
| `date_time` | Datum/Zeit |
| `serialization` | Objektserialisierung |
| `program_options` | Kommandozeilenparser |
| `iostreams` | I/O-Streams |
| `log` | Logging-Framework |

### CMake-Targets

Nach `find_package(Boost COMPONENTS ...)`:

```cmake
Boost::filesystem
Boost::system
Boost::thread
# etc.
```

---

## 7. See Also

- [Handler_cmake.md](../Handler_cmake.md) — Lädt diesen Hook
- [PathResolver_cmake.md](../PathResolver_cmake.md) — Pfad-Auflösung
- [Boost CMake Documentation](https://cmake.org/cmake/help/latest/module/FindBoost.html) — CMake FindBoost

---

## 8. Changelog

| Version | Datum | Changes |
|---------|-------|------------|
| **0.6.0** | **2025-12-18** | **Initial: Standard-Pfade, Post-Find Debug, BOOST_ALL_NO_LIB für MSVC** |
