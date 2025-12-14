# App-Container — Konzept

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Concept  
> **Status:** Entwurf  
> **Zielgruppe:** Build-System-Entwickler  
> **Bezug:** Phase 8, cmake/project/Apps.cmake  
> **Sprache:** Deutsch  
> **English:** [AppContainer.md](../../en/projects/buildsystem/concepts/AppContainer.md)

---

## Inhaltsverzeichnis

1. [Einleitung](#1-einleitung)
2. [Problemstellung](#2-problemstellung)
3. [Lösungsansatz](#3-lösungsansatz)
4. [Verzeichnisstruktur](#4-verzeichnisstruktur)
5. [Solution.json Integration](#5-solutionjson-integration)
6. [Architektur](#6-architektur)
7. [Error Codes](#7-error-codes)
8. [Build-Ausgabe](#8-build-ausgabe)
9. [Migration](#9-migration)
10. [Implementierungsplan](#10-implementierungsplan)
11. [Offene Punkte](#11-offene-punkte)
12. [Siehe auch](#12-siehe-auch)


---

## 1. Einleitung

Das App-Container Konzept ermöglicht **testbare Anwendungsarchitekturen** durch klare Trennung von Business-Logik und Entry Point.

### Ziele

- Volle Testbarkeit der Anwendungslogik
- Keine Code-Duplizierung für Tests
- Klare Separation of Concerns
- Kompatibilität mit Legacy-Executables

### Abgrenzung

| Modus | Beschreibung | Testbarkeit |
|-------|--------------|-------------|
| **Legacy** | Monolithisches Executable (`executables[]`) | Eingeschränkt |
| **App-Container** | Core-Library + Runner (`apps[]`) | Volle Testbarkeit |

---

## 2. Problemstellung

Das aktuelle Build-System unterstützt Executables als monolithische Einheiten:

| Problem | Beschreibung |
|---------|--------------|
| **Nicht testbar** | Business-Logik ist mit `main()` vermischt |
| **Code-Duplizierung** | Um Module zu testen, müssen Sources manuell kopiert werden |
| **Zirkuläre Dependencies** | Test-Targets können nicht einfach gegen Executable-Code linken |

---

## 3. Lösungsansatz

Ein **App-Container** trennt die Anwendungslogik von der Einstiegspunkt-Logik:

```
┌─────────────────────────────────────────────────────────────┐
│                      App-Container                          │
│   ┌─────────────────────────────────────────────────────┐   │
│   │             AppName.Core (STATIC Library)           │   │
│   │   ┌─────────┐  ┌─────────┐  ┌─────────┐             │   │
│   │   │ Module A│  │ Module B│  │ Module C│   ...       │   │
│   │   └─────────┘  └─────────┘  └─────────┘             │   │
│   └─────────────────────────────────────────────────────┘   │
│                            │                                │
│             ┌──────────────┼──────────────┐                 │
│             ▼              ▼              ▼                 │
│       ┌───────────┐  ┌────────────┐  ┌────────────┐         │
│       │   main/   │  │ Unit Tests │  │ Int. Tests │         │
│       │ (Runner)  │  │            │  │            │         │
│       └───────────┘  └────────────┘  └────────────┘         │
│             │                                               │
│             ▼                                               │
│       ┌─────────────┐                                       │
│       │   AppName   │                                       │
│       │ (Executable)│                                       │
│       └─────────────┘                                       │
└─────────────────────────────────────────────────────────────┘
```

### Designprinzipien

| Prinzip | Umsetzung |
|---------|-----------|
| **Single Source of Truth** | Alles in `Solution.json`, keine separate `app.json` |
| **Convention over Configuration** | Feste Verzeichnisstruktur, minimale Konfiguration |
| **Zentrale Externals** | Externals nur in `externals{}` Block, nie in Apps |
| **Konsistenz** | Gleiche Patterns wie Legacy (Source.cmake, PCH, etc.) |

---

## 4. Verzeichnisstruktur

### App-Container Layout

```
projects/apps/{AppName}/
├── include/                      # PUBLIC Headers (Core Library)
│   │
│   ├── Application.hpp
│   ├── ModuleA.hpp
│   └── ModuleB.hpp
├── src/                          # Implementation (Core Library)
│   │
│   ├── Application.cpp
│   ├── ModuleA.cpp
│   └── ModuleB.cpp
├── main/                         # Entry Point (Runner Executable)
│   └── main.cpp
├── pch/                          # Precompiled Header (optional)
│   ├── pch.hpp
│   └── pch.cpp
└── tests/                        # App-spezifische Tests
    ├── unit/
    │   ├── test_ModuleA.cpp
    │   └── test_ModuleB.cpp
    └── integration/
        └── test_Application.cpp
```

### Symmetrie include/ ↔ src/

Die Verzeichnisstruktur unter `include/` und `src/` ist symmetrisch:

```
include/AudioPlayer/Application.hpp
    ↕
src/AudioPlayer/Application.cpp
```

Dies ermöglicht:
- Klare Zuordnung Header ↔ Implementation
- Namespace-konsistente Includes: `#include <AudioPlayer/Application.hpp>`
- IDE-freundliche Navigation

---

## 5. Solution.json Integration

### apps Sektion

```json
{
    "apps": [
        {
            "name": "AudioPlayer",
            "displayName": "Audio Player Application",
            "version": "2.0.0",
            
            "core": {
                "dependencies": ["BasicLogger"],
                "externals": ["bass", "spdlog"]
            },
            
            "runner": {
                "type": "WINDOW",
                "externals": ["imgui_docking", "glad", "glfw"]
            },
            
            "pch": {
                "enabled": true
            },
            
            "tests": {
                "framework": "doctest",
                "unit": {
                    "timeout": 30,
                    "labels": ["unit", "audio"]
                },
                "integration": {
                    "timeout": 120,
                    "labels": ["integration", "audio"],
                    "externals": ["bass"]
                }
            }
        }
    ]
}
```

### App-Definition Schema

| Feld | Typ | Required | Default | Beschreibung |
|------|-----|----------|---------|--------------|
| `name` | string | ✅ | - | Eindeutiger App-Name |
| `displayName` | string | ❌ | `name` | Anzeigename |
| `version` | string | ❌ | `"1.0.0"` | App-Version |
| `path` | string | ❌ | `"projects/apps/{name}"` | Basis-Pfad |
| `core` | object | ❌ | `{}` | Core-Library Konfiguration |
| `runner` | object | ❌ | `{}` | Runner-Executable Konfiguration |
| `pch` | object | ❌ | `{ "enabled": false }` | PCH Konfiguration |
| `tests` | object | ❌ | `{}` | Test-Konfiguration |
| `active` | boolean | ❌ | `true` | App aktiv/inaktiv |

### Core-Definition

| Feld | Typ | Default | Beschreibung |
|------|-----|---------|--------------|
| `dependencies` | array | `[]` | Interne Library-Dependencies |
| `externals` | array | `[]` | Externe Dependencies |
| `defines` | array | `[]` | Compile Definitions |

### Runner-Definition

| Feld | Typ | Default | Beschreibung |
|------|-----|---------|--------------|
| `type` | string | `"CONSOLE"` | `CONSOLE` oder `WINDOW` |
| `externals` | array | `[]` | Runner-spezifische Externals |
| `defines` | array | `[]` | Compile Definitions |

### Tests-Definition

| Feld | Typ | Default | Beschreibung |
|------|-----|---------|--------------|
| `framework` | string | `"doctest"` | Test-Framework |
| `unit` | object | - | Unit-Test Konfiguration |
| `integration` | object | - | Integration-Test Konfiguration |

---

## 6. Architektur

### Generierte Targets

| Target | Typ | Beschreibung |
|--------|-----|--------------|
| `{AppName}.Core` | STATIC Library | Business-Logik |
| `{AppName}` | Executable | Runner mit Entry Point |
| `{AppName}.UnitTests` | Test Executable | Unit Tests |
| `{AppName}.IntegrationTests` | Test Executable | Integration Tests |

### Dependency-Graph

```
{AppName}.Core
    ↑
    ├── {AppName} (Runner)
    ├── {AppName}.UnitTests
    └── {AppName}.IntegrationTests
```

### CMake-Ablauf

```cmake
# 1. Core Library erstellen
add_library(${APP_NAME}.Core STATIC ${CORE_SOURCES})
target_include_directories(${APP_NAME}.Core PUBLIC include/)

# 2. Runner Executable erstellen
add_executable(${APP_NAME} ${RUNNER_SOURCES})
target_link_libraries(${APP_NAME} PRIVATE ${APP_NAME}.Core)

# 3. Tests erstellen
add_executable(${APP_NAME}.UnitTests ${UNIT_SOURCES})
target_link_libraries(${APP_NAME}.UnitTests PRIVATE ${APP_NAME}.Core)
```

---

## 7. Error Codes

### App-Container Errors (E4xx)

| Code | Beschreibung |
|------|--------------|
| E401 | App definition: 'name' is required |
| E402 | App path does not exist |
| E403 | App has no src/ directory |
| E404 | App has no source files in src/ |
| E405 | App dependency not found |
| E406 | App has no main/ directory |
| E407 | App has no source files in main/ |

### App-Container Warnings (W4xx)

| Code | Beschreibung |
|------|--------------|
| W401 | App has no include/ directory |
| W402 | PCH enabled but header not found |
| W403 | Tests directory exists but no sources found |

---

## 8. Build-Ausgabe

```
out/build/{preset}/
├── apps/
│   └── AudioPlayer/
│       ├── bin/
│       │   └── Debug/
│       │       └── AudioPlayer.exe
│       ├── lib/
│       │   └── Debug/
│       │       └── AudioPlayer.Core.lib
│       └── tests/
│           └── Debug/
│               ├── AudioPlayer.UnitTests.exe
│               └── AudioPlayer.IntegrationTests.exe
├── exec/                          # Legacy executables
└── lib/                           # Global libraries
```

---

## 9. Migration

### Von Legacy zu App-Container

**1. Verzeichnis erstellen:**
```bash
mkdir -p projects/apps/MyApp/{include/MyApp,src/MyApp,main,tests/unit}
```

**2. Code aufteilen:**
- Business-Logik → `src/MyApp/`
- Public Headers → `include/MyApp/`
- `main()` → `main/main.cpp`

**3. Solution.json aktualisieren:**
- App zu `apps[]` hinzufügen
- Altes Executable aus `executables[]` entfernen

**4. Tests erstellen:**
- Unit Tests in `tests/unit/`
- Integration Tests in `tests/integration/`

### Koexistenz

Legacy und App-Container können parallel existieren:

```json
{
    "apps": [
        { "name": "NewApp", ... }
    ],
    "executables": [
        { "name": "LegacyTool", ... }
    ]
}
```

---

## 10. Implementierungsplan

| Phase | Beschreibung | Abhängigkeiten |
|-------|--------------|----------------|
| 8.1 | `AppCollect.cmake` - Discovery & Parsing | Solution.cmake |
| 8.2 | `AppCreate.cmake` - Core Library | SourceCollect, Externals |
| 8.3 | `AppCreate.cmake` - Runner Executable | Core Library |
| 8.4 | `AppCreate.cmake` - App Tests | TestCreate patterns |
| 8.5 | Solution.json Schema Update | - |
| 8.6 | Build-System Tests | Alle Module |
| 8.7 | Dokumentation | Alle Module |

**Geschätzter Aufwand:** ~12-15 Stunden

---

## 11. Offene Punkte

| Frage | Optionen | Empfehlung |
|-------|----------|------------|
| System-Tests in Apps? | Eigener Ordner `tests/system/` | Später bei Bedarf |
| Performance-Tests? | Eigener Ordner `tests/performance/` | Später bei Bedarf |
| Mehrere Runner? | `runners/gui/`, `runners/cli/` | V2 Feature |
| Shared Core Library? | `core.type: "SHARED"` | Nicht in V1 |

---

## 12. Siehe auch

- [master_concept.md](master_concept.md) — Gesamtarchitektur
- [implementation_plan.md](implementation_plan.md) — Phasen-Plan
- [future_enhancements.md](future_enhancements.md) — Zukünftige App-Container Features

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Neues Header-Format, Dateiname ohne Version** |
| 0.2.0 | 2025-12-12 | Schema-Details, CMake-Implementierung |
| 0.1.0 | 2025-12-10 | Initial |