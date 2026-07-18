# Boost.cmake — Boost Package Hook

> **Version:** 1.0.0  
> **Datum:** 2025-12-20  
> **Typ:** ModuleDoc  
> **Status:** Aktiv  
> **Basiert auf:** ModuleDoc v0.5  
> **Zielgruppe:** Build-System-Entwickler  
> **Sprache:** Deutsch  
> **English:** [Boost_cmake.md](../../../../../en/modules/externals/system/packages/Boost_cmake.md)  
> **Modul:** [cmake/externals/system/packages/Boost.cmake](../../../../../../cmake/externals/system/packages/Boost.cmake)  
> **Modul-Version:** 1.0.0  
> **Phase:** 9 (System Externals)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [API-Referenz](#2-api-referenz)
3. [Standard-Pfade](#3-standard-pfade)
4. [Target-Konfiguration](#4-target-konfiguration)
5. [Verwendungsbeispiele](#5-verwendungsbeispiele)
6. [Boost-Komponenten](#6-boost-komponenten)
7. [Siehe auch](#7-siehe-auch)
8. [Changelog](#8-changelog)

---

## 1. Übersicht

`Boost.cmake` ist ein **Package-Hook** für Boost System Externals. Er wird automatisch von `system/Handler.cmake` geladen, wenn `package="Boost"` in der External-Definition steht.

### Kernfunktionen

- **Standard-Pfade** — Plattform-spezifische Boost-Installationsorte
- **Post-Find** — Debug-Ausgabe nach erfolgreichem find_package
- **MSVC Auto-Linking** — Deaktiviert für explizites Linking

### Architektur-Position

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

## 2. API-Referenz

### 2.1 _get_Boost_standard_paths()

Liefert plattform-spezifische Boost-Installationspfade.

```cmake
_get_Boost_standard_paths(OUT_VAR)
```

| Parameter | Typ | Beschreibung |
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
- Keine weitere Konfiguration erforderlich

---

### 2.3 _Boost_configure_target()

Konfiguriert ein CMake-Target für Boost-Verwendung.

```cmake
_Boost_configure_target(TARGET_NAME)
```

| Parameter | Typ | Beschreibung |
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

## 4. Target-Konfiguration

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

## 5. Verwendungsbeispiele

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

| Komponente | Beschreibung |
|------------|--------------|
| `filesystem` | Dateisystem-Operationen |
| `system` | System-Fehlerbehandlung |
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

## 7. Siehe auch

- [Handler_cmake.md](../Handler_cmake.md) — Lädt diesen Hook
- [PathResolver_cmake.md](../PathResolver_cmake.md) — Pfad-Auflösung
- [Boost CMake Documentation](https://cmake.org/cmake/help/latest/module/FindBoost.html) — CMake FindBoost

---

## 8. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.6.0** | **2025-12-18** | **Initial: Standard-Pfade, Post-Find Debug, BOOST_ALL_NO_LIB für MSVC** |
