# CMakeLists.txt — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Reference  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Datei:** [CMakeLists.txt](../../CMakeLists.txt)  
> **Basiert auf:** Reference v0.5  
> **Sprache:** Deutsch  
> **English:** [CMakeLists.md](../en/reference/CMakeLists.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Struktur](#2-struktur)
3. [Konfiguration](#3-konfiguration)
4. [Module-Ladereihenfolge](#4-module-ladereihenfolge)
5. [Optionen](#5-optionen)
6. [Siehe auch](#6-siehe-auch)
7. [Changelog](#7-changelog)

---

## 1. Übersicht

Die `CMakeLists.txt` ist der Einstiegspunkt des Build-Systems. Sie lädt die Module in der korrekten Reihenfolge und initialisiert die Pipelines.

---

## 2. Struktur

```cmake
cmake_minimum_required(VERSION 3.19)

# Projekt-Definition
project(MySolution
    VERSION 0.1.0
    LANGUAGES CXX C
)

# Module laden
include(cmake/core/Errors.cmake)
include(cmake/core/Debug.cmake)
# ... weitere Core-Module ...

include(cmake/project/Solution.cmake)
include(cmake/project/Externals.cmake)
include(cmake/project/Libraries.cmake)
include(cmake/project/Executables.cmake)

# Pipelines ausführen
process_externals()
process_libraries()
process_executables()
```

---

## 3. Konfiguration

### 3.1 CMake-Version

```cmake
cmake_minimum_required(VERSION 3.19)
```

**Mindestens 3.19** für:
- Native JSON-Unterstützung
- FetchContent Verbesserungen
- Presets Support

### 3.2 Projekt-Definition

```cmake
project(${SOLUTION_NAME}
    VERSION ${SOLUTION_VERSION}
    LANGUAGES CXX C
)
```

Name und Version werden aus Solution.json gelesen.

---

## 4. Module-Ladereihenfolge

**Kritisch:** Module müssen in dieser Reihenfolge geladen werden:

```
1. Core-Module (Abhängigkeitsfrei)
   ├── Errors.cmake
   ├── Debug.cmake
   ├── Context.cmake
   ├── Json.cmake
   ├── Validation.cmake
   ├── SourceCollect.cmake
   ├── OutputDirs.cmake
   ├── Warnings.cmake
   └── CompilerOptions.cmake

2. Project-Module
   ├── Solution.cmake      ← Lädt Solution.json
   ├── Externals.cmake     ← Verarbeitet Externals
   ├── Libraries.cmake     ← Erstellt Library-Targets
   └── Executables.cmake   ← Erstellt Executable-Targets
```

---

## 5. Optionen

### 5.1 Build-Optionen

| Option | Default | Beschreibung |
|--------|---------|--------------|
| `BUILD_ONLY` | — | Nur bestimmte Targets bauen |
| `BUILD_TESTS` | ON | Tests aktivieren |
| `RUN_BUILD_SYSTEM_TESTS` | OFF | Build-System Tests |

### 5.2 Debug-Optionen

| Option | Default | Beschreibung |
|--------|---------|--------------|
| `DEBUG_MESSAGES` | ON | Debug-Ausgaben |
| `DEBUG_DEFAULT_LEVEL` | 2 | Standard Debug-Level |
| `DEBUG_CONTEXT` | OFF | Context-Dumps |

---

## 6. Siehe auch

- [Solution.cmake](modules/project/Solution.md) — Solution-Verarbeitung
- [CMakePresets](reference/CMakePresets.md) — Preset-Konfiguration
- [Solution_Schema](reference/Solution_Schema.md) — JSON-Schema

---

## 7. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf Reference v0.5 Blueprint** |
| 0.1.1 | 2025-12-06 | Externals-Integration |
| 0.1.0 | 2025-12-03 | Initial |
