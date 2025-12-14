# App-Container — Architektur-Konzept

> **Version:** 0.5.0  
> **Datum:** 2025-12-14  
> **Typ:** Concept  
> **Status:** Entwurf  
> **Phase:** 8 (geplant)  
> **Zielgruppe:** Build-System-Entwickler, Architekten  
> **Sprache:** Deutsch  
> **English:** [AppContainer_Concept.md](../../en/concepts/AppContainer_Concept.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Verzeichnisstruktur](#2-verzeichnisstruktur)
   - 2.1 [App-Container Layout](#21-app-container-layout)
   - 2.2 [Symmetrie include/ ↔ src/](#22-symmetrie-include--src)
   - 2.3 [Gesamtstruktur im Projekt](#23-gesamtstruktur-im-projekt)
   - 2.4 [Path Convention](#24-path-convention)
3. [Solution.json Integration](#3-solutionjson-integration)
4. [CMake-Module](#4-cmake-module)
5. [Error Codes](#5-error-codes)
6. [Build-Ausgabe Struktur](#6-build-ausgabe-struktur)
7. [Beispiel: Vollständiger App-Container](#7-beispiel-vollständiger-app-container)
8. [Migration: Executable → App-Container](#8-migration-executable--app-container)
9. [Implementierungsplan](#9-implementierungsplan)
10. [Offene Entscheidungen](#10-offene-entscheidungen)
11. [Siehe auch](#11-siehe-auch)
12. [Changelog](#12-changelog)

---

## 1. Übersicht

### 1.1 Motivation

Das aktuelle Build-System unterstützt Executables als monolithische Einheiten. Das führt zu Problemen bei der Testbarkeit:

| Problem | Beschreibung |
|---------|--------------|
| **Nicht testbar** | Business-Logik ist mit `main()` vermischt |
| **Code-Duplizierung** | Um Module zu testen, müssen Sources manuell kopiert werden |
| **Zirkuläre Dependencies** | Test-Targets können nicht einfach gegen Executable-Code linken |

### 1.2 Lösung: App-Container

Ein **App-Container** trennt die Anwendungslogik von der Einstiegspunkt-Logik:

```
┌─────────────────────────────────────────────────────────────────┐
│                      App-Container                              │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              AppName.Core (STATIC Library)                │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐                    │  │
│  │  │ Module A│  │ Module B│  │ Module C│   ...              │  │
│  │  └─────────┘  └─────────┘  └─────────┘                    │  │
│  └───────────────────────────────────────────────────────────┘  │
│                           │                                     │
│            ┌──────────────┼──────────────┐                      │
│            ▼              ▼              ▼                      │
│     ┌───────────┐  ┌────────────┐  ┌────────────┐               │
│     │   main/   │  │ Unit Tests │  │ Int. Tests │               │
│     │ (Runner)  │  │            │  │            │               │
│     └───────────┘  └────────────┘  └────────────┘               │
│            │                                                    │
│            ▼                                                    │
│     ┌───────────┐                                               │
│     │ AppName   │                                               │
│     │(Executable)│                                              │
│     └───────────┘                                               │
└─────────────────────────────────────────────────────────────────┘
```

### 1.3 Kompatibilität

| Modus | JSON-Array | Beschreibung | Testbarkeit |
|-------|------------|--------------|-------------|
| **Executable** | `executables[]` | Monolithisches Executable | Eingeschränkt |
| **App-Container** | `apps[]` | Getrennte Core-Library + Runner | Volle Testbarkeit |

**Beide Modi verwenden dieselben Default-Pfade:**
- Executables: `projects/exec/{name}/`
- App-Container: `projects/apps/{name}/`

**Bestehende Projekte funktionieren weiterhin** — die `executables[]` Sektion bleibt vollständig unterstützt.

### 1.4 Designprinzipien

| Prinzip | Umsetzung |
|---------|-----------|
| **Single Source of Truth** | Alles in `Solution.json`, keine separate `app.json` |
| **Convention over Configuration** | Feste Verzeichnisstruktur, minimale Konfiguration |
| **Zentrale Externals** | Externals nur in `externals{}` Block, nie in Apps |
| **Konsistenz** | Gleiche Patterns wie Legacy (Source.cmake, PCH, etc.) |

---

## 2. Verzeichnisstruktur

### 2.1 App-Container Layout

```
projects/apps/{AppName}/
├── include/                      # PUBLIC Headers (Core Library)
│   ├── Application.hpp
│   ├── ModuleA.hpp
│   └── ModuleB.hpp
├── src/                          # Implementation (Core Library)
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

### 2.2 Symmetrie include/ ↔ src/

Die Verzeichnisstruktur unter `include/` und `src/` ist symmetrisch:

```
projects/apps/AudioPlayer/include/Application.hpp
    ↕
projects/apps/AudioPlayer/src/Application.cpp
```

Dies ermöglicht:
- Klare Zuordnung Header ↔ Implementation
- Namespace-konsistente Includes: `#include <Application.hpp>` oder mit App-Prefix via Include-Pfad
- IDE-freundliche Navigation

### 2.3 Gesamtstruktur im Projekt

**Default-Pfade** (wenn kein `path` in Solution.json):

```
projects/
├── apps/                           # Default für App-Container (NEU)
│   ├── AudioPlayer/
│   │   ├── include/
│   │   ├── src/
│   │   ├── main/
│   │   ├── pch/
│   │   └── tests/
│   └── ImageViewer/
│       └── ...
│
├── exec/                           # Default für Executables
│   └── MyTool/
│       └── src/
│
├── libs/                           # Default für Libraries
│   └── CoreLib/
│       └── src/
│
└── tests/                          # Globale Tests
    ├── unit/
    ├── integration/
    └── system/
```

**Demo-Pfade** (Alternative für Build-System-Release):

```
projects/demos/
├── apps/                           # Demo App-Container
│   └── DemoPlayer/
├── exec/                           # Demo Executables
│   └── MinimalConsole/
└── libs/                           # Demo Libraries
    └── BasicLogger/
```

### 2.4 Path Convention

| Target-Typ | Default-Pfad | Beispiel |
|------------|--------------|----------|
| Executable | `projects/exec/{name}/` | `projects/exec/MyTool/` |
| Library | `projects/libs/{name}/` | `projects/libs/CoreLib/` |
| App-Container | `projects/apps/{name}/` | `projects/apps/AudioPlayer/` |
| Test | `projects/tests/{type}/{name}/` | `projects/tests/unit/CoreLib_Tests/` |

Wenn `path` explizit gesetzt ist, wird dieser verwendet (z.B. `projects/demos/exec/MinimalConsole`).

---

## 3. Solution.json Integration

### 3.1 Neue `apps` Sektion

```json
{
    "solution": {
        "name": "MySolution",
        "version": "1.0.0"
    },
    
    "settings": {
        "cppStandard": 20,
        "sources": { "mode": "auto" }
    },
    
    "externals": {
        "bass": { "path": "externals/bass" },
        "imgui_docking": { 
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.91.6-docking",
            "hook": "imgui"
        },
        "glfw": { "git": "https://github.com/glfw/glfw.git", "tag": "3.4" },
        "glad": { "path": "externals/glad" },
        "doctest": { "path": "externals/doctest" },
        "spdlog": { "git": "https://github.com/gabime/spdlog.git", "tag": "v1.13.0" }
    },
    
    "libraries": [
        {
            "name": "BasicLogger",
            "path": "projects/demos/libs/BasicLogger"
        }
    ],
    
    "apps": [
        {
            "name": "AudioPlayer",
            "displayName": "Audio Player Application",
            "version": "2.0.0",
            "description": "A testable audio player",
            
            "core": {
                "dependencies": ["BasicLogger"],
                "externals": ["bass", "spdlog"]
            },
            
            "runner": {
                "type": "WINDOW",
                "externals": ["imgui_docking", "glad", "glfw"]
            },
            
            "pch": {
                "enabled": true,
                "header": "pch/pch.hpp",
                "source": "pch/pch.cpp"
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
            },
            
            "platforms": ["windows", "linux", "macos"]
        }
    ],
    
    "executables": [
        {
            "name": "MinimalConsole",
            "path": "projects/demos/exec/MinimalConsole/src",
            "type": "CONSOLE"
        }
    ]
}
```

### 3.2 App-Definition Schema

| Feld | Typ | Required | Default | Beschreibung |
|------|-----|----------|---------|--------------|
| `name` | string | ✅ | — | Eindeutiger App-Name |
| `displayName` | string | ❌ | `name` | Anzeigename |
| `version` | string | ❌ | `"1.0.0"` | App-Version |
| `description` | string | ❌ | `""` | Beschreibung |
| `path` | string | ❌ | `"projects/apps/{name}"` | Basis-Pfad |
| `core` | object | ❌ | `{}` | Core-Library Konfiguration |
| `runner` | object | ❌ | `{}` | Runner-Executable Konfiguration |
| `pch` | object | ❌ | `{ "enabled": false }` | PCH Konfiguration |
| `tests` | object | ❌ | `{}` | Test-Konfiguration |
| `platforms` | array | ❌ | alle | Zielplattformen |
| `active` | boolean | ❌ | `true` | App aktiv/inaktiv |

### 3.3 Core-Definition Schema

| Feld | Typ | Required | Default | Beschreibung |
|------|-----|----------|---------|--------------|
| `dependencies` | array | ❌ | `[]` | Interne Library-Dependencies |
| `externals` | array | ❌ | `[]` | Externe Dependencies |
| `defines` | array | ❌ | `[]` | Compile Definitions |

### 3.4 Runner-Definition Schema

| Feld | Typ | Required | Default | Beschreibung |
|------|-----|----------|---------|--------------|
| `type` | string | ❌ | `"CONSOLE"` | CONSOLE, WINDOW |
| `externals` | array | ❌ | `[]` | Zusätzliche Externals (GUI, etc.) |
| `defines` | array | ❌ | `[]` | Runner-spezifische Defines |

### 3.5 Tests-Definition Schema

| Feld | Typ | Required | Default | Beschreibung |
|------|-----|----------|---------|--------------|
| `framework` | string | ❌ | `"doctest"` | Test-Framework |
| `unit` | object | ❌ | `{}` | Unit-Test Konfiguration |
| `integration` | object | ❌ | `{}` | Integration-Test Konfiguration |

---

## 4. CMake-Module

### 4.1 Modul-Übersicht

| Modul | Beschreibung |
|-------|--------------|
| `Apps.cmake` | Hauptschleife über apps Array |
| `AppCollect.cmake` | JSON → Context |
| `AppCreate.cmake` | Core, Runner, Tests erstellen |

### 4.2 Pipeline

```
1. Apps.cmake: apps Array iterieren
2. AppCollect: JSON parsen, Context erstellen
3. Platform-Filter prüfen
4. active prüfen
5. AppCreate:
   a. Core Library erstellen
   b. Runner Executable erstellen
   c. Tests erstellen (wenn BUILD_TESTS=ON)
```

### 4.3 Generierte Targets

Für eine App `AudioPlayer`:

| Target | Typ | Beschreibung |
|--------|-----|--------------|
| `AudioPlayer.Core` | STATIC Library | Business-Logik |
| `AudioPlayer` | Executable | Entry Point + Core |
| `AudioPlayer.UnitTests` | Executable | Unit Tests gegen Core |
| `AudioPlayer.IntegrationTests` | Executable | Integration Tests |

---

## 5. Error Codes

### 5.1 App-Container Errors (E4xx)

| Code | Beschreibung |
|------|--------------|
| E401 | App definition: 'name' is required |
| E402 | App path does not exist |
| E403 | App has no src/ directory |
| E404 | App has no source files in src/ |
| E405 | App dependency not found |
| E406 | App has no main/ directory |
| E407 | App has no source files in main/ |

### 5.2 App-Container Warnings (W4xx)

| Code | Beschreibung |
|------|--------------|
| W401 | App has no include/ directory |
| W402 | PCH enabled but header not found |
| W403 | Tests directory exists but no sources found |

---

## 6. Build-Ausgabe Struktur

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
├── exec/                          # Executables
│   └── MinimalConsole/
│       └── bin/Debug/
└── lib/                           # Libraries
    └── BasicLogger/
```

---

## 7. Beispiel: Vollständiger App-Container

### 7.1 Solution.json Ausschnitt

```json
{
    "apps": [
        {
            "name": "AudioPlayer",
            "displayName": "Audio Player",
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
                    "labels": ["unit", "audio", "fast"]
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

### 7.2 Verzeichnisstruktur

```
projects/apps/AudioPlayer/
├── include/
│   ├── Application.hpp
│   ├── AudioEngine.hpp
│   ├── Playlist.hpp
│   └── Track.hpp
├── src/
│   ├── Application.cpp
│   ├── AudioEngine.cpp
│   ├── Playlist.cpp
│   └── Track.cpp
├── main/
│   └── main.cpp
├── pch/
│   ├── pch.hpp
│   └── pch.cpp
└── tests/
    ├── unit/
    │   ├── test_AudioEngine.cpp
    │   ├── test_Playlist.cpp
    │   └── test_Track.cpp
    └── integration/
        └── test_Application.cpp
```

### 7.3 main/main.cpp (Minimal)

```cpp
// Entry point only - all logic in AudioPlayer.Core

#include <Application.hpp>

int main(int argc, char* argv[]) {
    AudioPlayer::Application app;
    
    if (!app.initialize(argc, argv)) {
        return 1;
    }
    
    return app.run();
}
```

**Hinweis:** Der Include-Pfad `projects/apps/AudioPlayer/include/` wird automatisch als PUBLIC Include-Directory für `AudioPlayer.Core` gesetzt.

### 7.4 Generierte Targets

```
AudioPlayer.Core            - STATIC Library
AudioPlayer                 - WINDOW Executable
AudioPlayer.UnitTests       - Test Executable
AudioPlayer.IntegrationTests - Test Executable
```

### 7.5 CTest Ausführung

```bash
# Alle App-Tests
ctest -L AudioPlayer

# Nur Unit Tests
ctest -L "AudioPlayer" -L "unit"

# Nur Integration Tests  
ctest -R "IntegrationTests"
```

---

## 8. Migration: Executable → App-Container

### 8.1 Schritt-für-Schritt

1. **Verzeichnis erstellen:**
   ```bash
   mkdir -p projects/apps/MyApp/{include,src,main,tests/unit}
   ```

2. **Code aufteilen:**
   - Business-Logik → `src/`
   - Public Headers → `include/`
   - `main()` → `main/main.cpp`

3. **Solution.json aktualisieren:**
   - App zu `apps[]` hinzufügen
   - Altes Executable aus `executables[]` entfernen

4. **Tests erstellen:**
   - Unit Tests in `tests/unit/`
   - Integration Tests in `tests/integration/`

### 8.2 Koexistenz

Executables und App-Container können parallel existieren:

```json
{
    "apps": [
        { "name": "NewApp", ... }
    ],
    "executables": [
        { "name": "SimpleTool", ... }
    ]
}
```

**Wann Executable, wann App-Container?**

| Kriterium | Executable (`executables[]`) | App-Container (`apps[]`) |
|-----------|------------------------------|--------------------------|
| Testbarkeit | Eingeschränkt | Voll |
| Komplexität | Einfache Tools | Business-Anwendungen |
| Code-Umfang | Klein (<1000 LOC) | Groß (>1000 LOC) |
| Abhängigkeiten | Wenige | Viele Module |

---

## 9. Implementierungsplan

| Phase | Beschreibung | Abhängigkeiten |
|-------|--------------|----------------|
| 8.1 | `AppCollect.cmake` — Discovery & Parsing | Solution.cmake |
| 8.2 | `AppCreate.cmake` — Core Library | SourceCollect, Externals |
| 8.3 | `AppCreate.cmake` — Runner Executable | Core Library |
| 8.4 | `AppCreate.cmake` — App Tests | TestCreate patterns |
| 8.5 | Solution.json Schema Update | — |
| 8.6 | Build-System Tests | Alle Module |
| 8.7 | Dokumentation | Alle Module |

**Geschätzter Aufwand:** ~12-15 Stunden

---

## 10. Offene Entscheidungen

| Frage | Optionen | Empfehlung |
|-------|----------|------------|
| System-Tests in Apps? | Eigener Ordner `tests/system/` | Später bei Bedarf |
| Performance-Tests? | Eigener Ordner `tests/performance/` | Später bei Bedarf |
| Mehrere Runner? | `runners/gui/`, `runners/cli/` | V2 Feature |
| Shared Core Library? | `core.type: "SHARED"` | Nicht in V1 |

---

## 11. Siehe auch

- [master_concept.md](master_concept.md) — Architektur-Übersicht
- [implementation_plan.md](implementation_plan.md) — Phasen-Plan
- [Test_Pipeline_Concept.md](../../reference/Test_Pipeline_Concept.md) — Test-Framework-Integration
- [guidelines.md](../../standards/guidelines.md) — Coding-Konventionen

---

## 12. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-14** | **Blueprint v0.5.0 Format, Path Convention klargestellt (projects/exec, projects/libs, projects/apps als Defaults), "Legacy"-Begriff entfernt (bezog sich auf Konzept, nicht Pfad), UTF-8 korrigiert** |
| 0.2.0 | 2025-12-12 | Core/Runner-Trennung, Test-Integration, vollständige CMake-Module |
| 0.1.0 | 2025-12-10 | Initial: Grundkonzept App-Container |
