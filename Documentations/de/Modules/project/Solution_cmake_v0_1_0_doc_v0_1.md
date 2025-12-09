# Solution.cmake – Modul-Dokumentation

> **Modul-Version:** 0.1.0  
> **Dokument-Version:** 0.1.0  
> **Datum:** 2025-12-05  
> **Pfad:** `cmake/project/Solution.cmake`  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, Solution_Schema v0.1, guidelines v0.1  
> **Sprache:** Deutsch  

---

## 1. Übersicht

Das `Solution.cmake` Modul ist das Herzstück des Build-Systems. Es liest die `Solution.json` Konfigurationsdatei und setzt alle globalen Properties für nachfolgende Module.

### Verantwortlichkeiten

- Solution.json einlesen und validieren
- Schema-Version prüfen
- Metadaten extrahieren (Name, Version, Autoren)
- Build-Settings anwenden (Standards, Defaults, Source-Mode)
- Externals-Policy konfigurieren
- Daten für nachfolgende Pipelines bereitstellen

---

## 2. Abhängigkeiten

**Muss in dieser Reihenfolge geladen werden:**

```cmake
include(cmake/core/Errors.cmake)
include(cmake/core/Debug.cmake)
include(cmake/core/Json.cmake)
include(cmake/core/Validation.cmake)
# Optional aber empfohlen:
include(cmake/core/Context.cmake)
include(cmake/core/OutputDirs.cmake)
include(cmake/core/Warnings.cmake)
include(cmake/core/CompilerOptions.cmake)

# Dann Solution laden
include(cmake/project/Solution.cmake)
```

---

## 3. Voraussetzungen

### Solution.json

Eine `Solution.json` Datei muss im Projekt-Root existieren:

```
project/
├── CMakeLists.txt
├── Solution.json        ← Pflicht!
└── cmake/
    └── ...
```

**Minimale Solution.json:**
```json
{
    "schemaVersion": "0.1",
    "solution": {
        "name": "MyProject"
    }
}
```

---

## 4. Gesetzte GLOBAL Properties

Nach dem Laden von Solution.cmake stehen folgende Properties zur Verfügung:

### 4.1 Metadaten

| Property | Beschreibung | Beispiel |
|----------|--------------|----------|
| `SOLUTION_JSON` | Vollständiger JSON-String | `{...}` |
| `SOLUTION_NAME` | Projekt-Name | `"MySolution"` |
| `SOLUTION_VERSION` | Version (String) | `"0.1.0"` |
| `SOLUTION_DESCRIPTION` | Beschreibung | `"My Project"` |
| `SOLUTION_AUTHORS` | Autoren-Liste (`;`-separiert) | `"Author1;Author2"` |
| `SOLUTION_SCHEMA_VERSION` | Schema-Version | `"0.1"` |

### 4.2 Settings

| Property | Beschreibung | Default |
|----------|--------------|---------|
| `SOLUTION_CXX_STANDARD` | C++ Standard | - |
| `SOLUTION_C_STANDARD` | C Standard | - |
| `SOLUTION_DEFAULT_LIBRARY_TYPE` | Default für Libraries | `"STATIC"` |
| `SOLUTION_DEFAULT_EXECUTABLE_TYPE` | Default für Executables | `"CONSOLE"` |
| `SOLUTION_SOURCE_MODE` | Source-Collection-Mode | `"explicit"` |

### 4.3 Externals Policy

| Property | Beschreibung | Default |
|----------|--------------|---------|
| `SOLUTION_EXTERNALS_JSON` | Externals-Block als JSON | `"{}"` |
| `SOLUTION_SETTINGS_JSON` | Settings-Block als JSON | `"{}"` |
| `SOLUTION_EXTERNALS_POLICY_JSON` | Policy-Block als JSON | `"{}"` |
| `SOLUTION_EXTERNALS_CACHE_ROOT` | Cache-Verzeichnis | `"externals/_cache"` |
| `SOLUTION_EXTERNALS_SOURCE_ROOT` | Source-Verzeichnis | `"externals/_src"` |
| `SOLUTION_EXTERNALS_UPDATE_POLICY` | Update-Strategie | `"checkout"` |

### 4.4 CMake Cache Variables

Solution.cmake setzt auch direkt CMake-Variablen:

| Variable | Quelle |
|----------|--------|
| `CMAKE_CXX_STANDARD` | `settings.standards.cxx_standard` |
| `CMAKE_CXX_STANDARD_REQUIRED` | `settings.standards.cxx_standard_required` |
| `CMAKE_CXX_EXTENSIONS` | `settings.standards.cxx_extensions` |
| `CMAKE_C_STANDARD` | `settings.standards.c_standard` |
| `CMAKE_C_STANDARD_REQUIRED` | `settings.standards.c_standard_required` |
| `CMAKE_C_EXTENSIONS` | `settings.standards.c_extensions` |

---

## 5. Verwendung

### 5.1 Properties lesen

```cmake
# Nach include(cmake/project/Solution.cmake)

get_property(_name GLOBAL PROPERTY SOLUTION_NAME)
get_property(_version GLOBAL PROPERTY SOLUTION_VERSION)

message("Building: ${_name} v${_version}")
```

### 5.2 In CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.25)

# Core-Module laden
include(cmake/core/Errors.cmake)
include(cmake/core/Debug.cmake)
include(cmake/core/Json.cmake)
include(cmake/core/Validation.cmake)
include(cmake/core/Context.cmake)

# Solution laden
include(cmake/project/Solution.cmake)

# Projekt definieren mit Werten aus Solution.json
get_property(_name GLOBAL PROPERTY SOLUTION_NAME)
get_property(_version GLOBAL PROPERTY SOLUTION_VERSION)

project(
    "${_name}"
    VERSION "${_version}"
    LANGUAGES C CXX
)
```

### 5.3 Source-Mode verwenden

```cmake
get_property(_source_mode GLOBAL PROPERTY SOLUTION_SOURCE_MODE)

if("${_source_mode}" STREQUAL "explicit")
    # Source.cmake erforderlich
elseif("${_source_mode}" STREQUAL "glob")
    # Automatisches GLOB
elseif("${_source_mode}" STREQUAL "auto")
    # Source.cmake wenn vorhanden, sonst GLOB
endif()
```

### 5.4 Externals-JSON für spätere Verarbeitung

```cmake
get_property(_externals_json GLOBAL PROPERTY SOLUTION_EXTERNALS_JSON)

# Kann an Externals-Orchestrator weitergegeben werden
# include(cmake/externals/Orchestrator.cmake)
# process_externals("${_externals_json}")
```

---

## 6. Debug-Ausgaben

Solution.cmake nutzt das Debug-System mit Context `SOLUTION`:

### 6.1 Standard-Output (SHOW_LEVEL = 2)

```
-- [Solution] Solution.json loaded
-- [Solution] MySolution v0.1.0
-- [Solution] Externals defined: 8
-- -------------------------------------------
```

### 6.2 Verbose-Output (SHOW_LEVEL = 5)

```bash
cmake .. -DDEBUG_DEFAULT_LEVEL=5
```

```
-- [Solution] Solution.json loaded
-- [Solution] Schema version: 0.1
-- [Solution] MySolution v0.1.0
-- [Solution] Description: Multi-Project Solution...
-- [Solution] Authors: Author Name
-- [Solution] C++ Standard: 20
-- [Solution] C Standard: 17
-- [Solution] Default library type: STATIC
-- [Solution] Default executable type: CONSOLE
-- [Solution] Source mode: explicit
-- [Solution] Externals cache: externals/_cache
-- [Solution] Externals source: externals/_src
-- [Solution] Update policy: checkout
-- [Solution] Externals defined: 8
-- [Solution] Executables: 3, Libraries: 0, Tests: 1
-- -------------------------------------------
```

---

## 7. Fehlerbehandlung

### E002: Solution.json nicht gefunden

```
[E002] Solution.json not found: /path/to/project/Solution.json
```

**Lösung:** `Solution.json` im Projekt-Root erstellen.

### E002: schemaVersion fehlt

```
[E002] Solution.json: 'schemaVersion' missing or invalid JSON
```

**Lösung:** `"schemaVersion": "0.1"` zur Solution.json hinzufügen.

### E001: solution.name fehlt

```
[E001] Solution.json: 'solution.name' missing
```

**Lösung:** `solution.name` Feld hinzufügen.

### W001: Veraltete Schema-Version

```
[W001] Solution.json schemaVersion X.Y < 0.1, some features may not be available
```

**Lösung:** Schema auf 0.1 aktualisieren (optional, nur Warnung).

---

## 8. Solution.json Struktur

### 8.1 Vollständiges Beispiel

```json
{
    "schemaVersion": "0.1",
    
    "solution": {
        "name": "MySolution",
        "version": "0.1.0",
        "description": "My awesome project",
        "authors": ["Author Name"]
    },
    
    "settings": {
        "standards": {
            "cxx_standard": 20,
            "cxx_standard_required": true,
            "cxx_extensions": false,
            "c_standard": 17,
            "c_standard_required": true,
            "c_extensions": false
        },
        "defaults": {
            "library_type": "STATIC",
            "executable_type": "CONSOLE"
        },
        "sources": {
            "mode": "explicit"
        }
    },
    
    "externalsPolicy": {
        "cacheRoot": "externals/_cache",
        "sourceRoot": "externals/_src",
        "updatePolicy": "checkout"
    },
    
    "externals": {
        "bass": {
            "path": "externals/bass",
            "description": "Audio library"
        },
        "spdlog": {
            "git": "https://github.com/gabime/spdlog.git",
            "tag": "v1.12.0"
        }
    },
    
    "libraries": [],
    
    "executables": [
        {
            "name": "MyApp",
            "path": "projects/exec/MyApp/src",
            "type": "CONSOLE",
            "externals": ["bass", "spdlog"]
        }
    ],
    
    "tests": []
}
```

### 8.2 Version als Objekt

Alternativ kann die Version als Objekt angegeben werden:

```json
{
    "solution": {
        "name": "MySolution",
        "version": {
            "major": 1,
            "minor": 2,
            "patch": 3
        }
    }
}
```

Wird zu `"1.2.3"` konvertiert.

---

## 9. Source-Mode

**NEU in v0.1.0**

Der Source-Mode steuert, wie Quelldateien für Targets gesammelt werden:

| Mode | Beschreibung |
|------|--------------|
| `explicit` | Source.cmake erforderlich (Default) |
| `glob` | Automatisches GLOB_RECURSE |
| `auto` | Source.cmake wenn vorhanden, sonst GLOB |

```json
"settings": {
    "sources": {
        "mode": "explicit"
    }
}
```

---

## 10. Best Practices

### 10.1 Immer Schema-Version angeben

```json
{
    "schemaVersion": "0.1",
    ...
}
```

### 10.2 Vollständige Metadaten pflegen

```json
{
    "solution": {
        "name": "MyProject",
        "version": "1.0.0",
        "description": "Clear description of what this does",
        "authors": ["Your Name <email@example.com>"]
    }
}
```

### 10.3 Standards explizit setzen

```json
{
    "settings": {
        "standards": {
            "cxx_standard": 20,
            "cxx_standard_required": true,
            "cxx_extensions": false
        }
    }
}
```

### 10.4 Properties nach include() lesen

```cmake
# ✅ Korrekt
include(cmake/project/Solution.cmake)
get_property(_name GLOBAL PROPERTY SOLUTION_NAME)

# ❌ Falsch - Property existiert noch nicht
get_property(_name GLOBAL PROPERTY SOLUTION_NAME)
include(cmake/project/Solution.cmake)
```

---

## 11. Unterschiede zu v1.0

| Aspekt | v1.0 | v0.1.0 |
|--------|------|--------|
| Schema-Version | `"1.2"` | `"0.1"` |
| Source-Mode | - | `settings.sources.mode` |
| externalsPolicy.cacheRoot | `.externals` | `externals/_cache` |
| externalsPolicy.sourceRoot | - | `externals/_src` |
| externalsPolicy.updatePolicy | `if-missing` | `checkout` |

---

## 12. Siehe auch

- [Solution_Schema](../References/Solution_Schema_v0_1_0.md) – Vollständige Schema-Dokumentation
- [Json.cmake](Json_cmake_v0_1_0_doc_v0_1.md) – JSON-Hilfsfunktionen
- [Validation.cmake](Validation_cmake_v0_1_0_doc_v0_1.md) – Validierungsfunktionen
- [guidelines](../Concepts/guidelines_v0_1_0.md) – Projekt-Konventionen

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-05** | **Clean Start: Schema 0.1, Source-Mode hinzugefügt, externalsPolicy erweitert (sourceRoot), Englische Kommentare im Code** |
