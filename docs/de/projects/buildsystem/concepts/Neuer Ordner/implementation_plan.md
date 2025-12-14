# Implementation Plan — CMake Architecture V2

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Concept  
> **Status:** In Entwicklung  
> **Basiert auf:** master_concept v0.5  
> **Zielgruppe:** Build-System-Entwickler  
> **Sprache:** Deutsch  
> **English:** [implementation_plan.md](../../en/projects/buildsystem/concepts/implementation_plan.md)

Dieser Plan beschreibt die schrittweise Umsetzung des CMake Build-Systems.

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Phase 1: Foundation](#2-phase-1-foundation)
3. [Phase 2: Solution & Validation](#3-phase-2-solution--validation)
4. [Phase 3: Executable Pipeline](#4-phase-3-executable-pipeline)
5. [Phase 4: Library Pipeline](#5-phase-4-library-pipeline)
6. [Phase 5: Lokale Externals](#6-phase-5-lokale-externals)
7. [Phase 6: Fetched Externals + Hooks](#7-phase-6-fetched-externals--hooks)
8. [Phase 7: Test Pipeline](#8-phase-7-test-pipeline)
9. [Phase 8: App-Container](#9-phase-8-app-container)
10. [Phase 9: System Externals](#10-phase-9-system-externals)
11. [Checkliste](#11-checkliste)
12. [Siehe auch](#12-siehe-auch)


---

## 1. Übersicht

### Status der Dateien

| Datei | Status |
|-------|--------|
| `CMakePresets.json` | ✅ Stabil |
| `Solution.json` | ✅ Schema v0.1 |
| `CMakeLists.txt` | ✅ Stabil |
| `cmake/*.cmake` | ✅ Phase 1-7 implementiert |

### Phasen-Übersicht

```
Phase 1: Foundation (Core-Module)           ✅
    ↓
Phase 2: Solution & Validation              ✅
    ↓
Phase 3: Executable Pipeline                ✅
    ↓
Phase 4: Library Pipeline                   ✅
    ↓
Phase 5: Lokale Externals                   ✅
    ↓
Phase 6: Fetched Externals + Hooks          ✅
    ↓
Phase 7: Test Pipeline                      ✅
    ↓
Phase 8: App-Container                      🔄
    ↓
Phase 9: System Externals                   🔄
    ↓
Zukünftige Erweiterungen                    → future_enhancements.md
```

---

## 2. Phase 1: Foundation

> **Status:** ✅ Abgeschlossen

**Ziel:** Grundlegende Infrastruktur für alle weiteren Module.

### Module

| Modul | Beschreibung | Status |
|-------|--------------|--------|
| `Errors.cmake` | `cmake_fatal()`, `cmake_warn()`, `cmake_assert()` | ✅ |
| `Debug.cmake` | Debug-System mit Leveln | ✅ |
| `Context.cmake` | Context-Objekt-Pattern | ✅ |
| `Json.cmake` | JSON-Hilfsfunktionen | ✅ |
| `Validation.cmake` | Schema-Validierung | ✅ |
| `SourceCollect.cmake` | Source-Datei-Management | ✅ |
| `OutputDirs.cmake` | Zielverzeichnisse | ✅ |
| `Warnings.cmake` | Warning-Level | ✅ |
| `CompilerOptions.cmake` | Compiler-Konfiguration | ✅ |

### Erfolgskriterium

```bash
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=ON
# Phase 1 Tests bestehen ✅
```

---

## 3. Phase 2: Solution & Validation

> **Status:** ✅ Abgeschlossen

**Ziel:** Solution.json einlesen und validieren.

### Module

| Modul | Beschreibung | Status |
|-------|--------------|--------|
| `Solution.cmake` | JSON laden, GLOBAL Properties setzen | ✅ |

### Erfolgskriterium

```cmake
# Nach include(Solution.cmake):
# - SOLUTION_JSON ist gesetzt ✅
# - SOLUTION_NAME ist verfügbar ✅
# - SOLUTION_VERSION ist verfügbar ✅
# - SOLUTION_SETTINGS_JSON ist verfügbar ✅
```

---

## 4. Phase 3: Executable Pipeline

> **Status:** ✅ Abgeschlossen

**Ziel:** Executables aus Solution.json erstellen.

### Module

| Modul | Beschreibung | Status |
|-------|--------------|--------|
| `Executables.cmake` | Hauptschleife über Executables | ✅ |
| `ExecutableCollect.cmake` | JSON → Context | ✅ |
| `ExecutableCreate.cmake` | Target erstellen | ✅ |

### Pipeline

```
1. JSON parsen
2. Context erstellen (ctx_create)
3. Felder extrahieren (ctx_set)
4. BUILD_ONLY prüfen
5. skip prüfen
6. Source.cmake laden oder GLOB
7. add_executable()
8. PCH konfigurieren
9. CompilerOptions anwenden
10. Warnings setzen
11. OutputDirs setzen
```

### Erfolgskriterium

```bash
cmake -B build
cmake --build build
./build/bin/MinimalConsole  # "Hello World" ✅
```

---

## 5. Phase 4: Library Pipeline

> **Status:** ✅ Abgeschlossen

**Ziel:** Libraries aus Solution.json erstellen.

### Module

| Modul | Beschreibung | Status |
|-------|--------------|--------|
| `Libraries.cmake` | Hauptschleife | ✅ |
| `LibraryCollect.cmake` | JSON → Context | ✅ |
| `LibraryCreate.cmake` | Target erstellen | ✅ |
| `Dependencies.cmake` | Interne Abhängigkeiten | ✅ |

### Library-Typen

| Typ | CMake |
|-----|-------|
| STATIC | `add_library(X STATIC)` |
| SHARED | `add_library(X SHARED)` |
| INTERFACE | `add_library(X INTERFACE)` |

### Erfolgskriterium

```cmake
# Library wird erstellt ✅
# Executable kann gegen Library linken ✅
target_link_libraries(MyApp PRIVATE CoreLib)
```

---

## 6. Phase 5: Lokale Externals

> **Status:** ✅ Abgeschlossen

**Ziel:** Lokale Externals einbinden.

### Module

| Modul | Beschreibung | Status |
|-------|--------------|--------|
| `Orchestrator.cmake` | Dispatch nach External-Typ | ✅ |
| `Local/Attach.cmake` | Include.cmake aufrufen | ✅ |

### Include.cmake Files

| External | Status |
|----------|--------|
| BASS | ✅ |
| Lua | ✅ |
| doctest | ✅ |
| glad | ✅ |

### Erfolgskriterium

```cmake
# BASS lädt korrekt ✅
# target_link_libraries funktioniert ✅
# DLLs werden kopiert ✅
# W103/W104 Prüfung ✅
```

---

## 7. Phase 6: Fetched Externals + Hooks

> **Status:** ✅ Abgeschlossen (Fetch v0.2)

**Ziel:** Git-Externals fetchen, Hook-System.

### Module

| Modul | Beschreibung | Status |
|-------|--------------|--------|
| `Core/Fetch.cmake` | FetchContent-Wrapper | ✅ |
| `Core/Handler.cmake` | External-Handler | ✅ |
| `Hooks/HookLoader.cmake` | Hook-System | ✅ |
| `Registry/Targets.cmake` | Target-Registry | ✅ |

### Hook-Ablauf

```
1. Convention-Pfad prüfen
2. Expliziten Pfad prüfen (E216 wenn fehlt)
3. PreFetch Hook laden (wenn vorhanden)
4. FetchContent_Declare/MakeAvailable
5. PostFetch Hook laden (wenn vorhanden)
6. Target in Registry eintragen
```

### Hooks implementiert

| External | PreFetch | PostFetch |
|----------|----------|-----------|
| GLFW | ✅ | - |
| ImGui | - | ✅ |

### Erfolgskriterium

```cmake
# spdlog wird gefetcht ✅
# ImGui PostFetch Hook erstellt Target ✅
# E216 bei fehlendem expliziten Hook ✅
```

---

## 8. Phase 7: Test Pipeline

> **Status:** ✅ Abgeschlossen (v0.1)

**Ziel:** Test-Targets, CTest-Integration.

### Module

| Modul | Beschreibung | Status |
|-------|--------------|--------|
| `Tests.cmake` | Test-Pipeline | ✅ |

### Features

| Feature | Status |
|---------|--------|
| CTest-Integration | ✅ |
| Framework-Erkennung (doctest) | ✅ |
| Labels | ✅ |
| Timeout | ✅ |
| BUILD_TESTS Cache-Variable | ✅ |
| RUN_BUILD_SYSTEM_TESTS | ✅ |

### Erfolgskriterium

```bash
ctest --test-dir build  # Tests laufen ✅
```

---

## 9. Phase 8: App-Container

> **Status:** 🔄 In Planung  
> **Detail-Dokument:** [AppContainer.md](AppContainer.md)

**Ziel:** Testbare Anwendungsarchitektur durch Trennung von Business-Logik und Entry Point.

### Module (geplant)

| Modul | Beschreibung | Status |
|-------|--------------|--------|
| `Apps.cmake` | App-Container Pipeline | ⬜ |
| `AppCollect.cmake` | JSON → Context | ⬜ |
| `AppCreate.cmake` | Targets erstellen | ⬜ |

### Verzeichnisstruktur

```
projects/apps/{AppName}/
├── include/                # PUBLIC Headers
├── src/                    # Implementation
├── main/                   # Entry Point
├── pch/                    # Precompiled Header (optional)
└── tests/
    ├── unit/
    └── integration/
```

### Generierte Targets

| Target | Typ |
|--------|-----|
| `{AppName}.Core` | STATIC Library |
| `{AppName}` | Executable |
| `{AppName}.UnitTests` | Test Executable |
| `{AppName}.IntegrationTests` | Test Executable |

### Solution.json

```json
{
    "apps": [{
        "name": "AudioPlayer",
        "core": {
            "dependencies": ["BasicLogger"],
            "externals": ["bass"]
        },
        "runner": {
            "type": "WINDOW",
            "externals": ["imgui"]
        },
        "tests": {
            "framework": "doctest"
        }
    }]
}
```

### Erfolgskriterium

```bash
# App-Container baut
cmake --build build --target AudioPlayer
cmake --build build --target AudioPlayer.UnitTests

# Tests laufen gegen Core Library
ctest -L AudioPlayer
```

### Teilphasen

| Phase | Beschreibung | Status |
|-------|--------------|--------|
| 8.1 | `AppCollect.cmake` - Discovery & Parsing | ⬜ |
| 8.2 | `AppCreate.cmake` - Core Library | ⬜ |
| 8.3 | `AppCreate.cmake` - Runner Executable | ⬜ |
| 8.4 | `AppCreate.cmake` - App Tests | ⬜ |
| 8.5 | Solution.json Schema Update | ⬜ |
| 8.6 | Build-System Tests | ⬜ |
| 8.7 | Dokumentation | ⬜ |

---

## 10. Phase 9: System Externals

> **Status:** 🔄 In Planung  
> **Detail-Dokument:** [System_Externals.md](System_Externals.md)

**Ziel:** Integration von system-installierten Bibliotheken (Qt6, Boost, OpenCV).

### Module (geplant)

| Modul | Beschreibung | Status |
|-------|--------------|--------|
| `System/Handler.cmake` | System External Handler | ⬜ |
| `System/PathResolver.cmake` | Pfad-Auflösung | ⬜ |
| `System/Packages/*.cmake` | Package-spezifische Logik | ⬜ |

### Solution.json

```json
{
    "externals": {
        "qt6": {
            "system": true,
            "package": "Qt6",
            "version": ">=6.5.0",
            "components": ["Core", "Widgets", "Gui"],
            "hints": ["${QT_ROOT}"],
            "backup": "E:/Backup/Libs/Qt/6.7.0"
        }
    }
}
```

### Suchreihenfolge

1. Umgebungsvariablen (`${PACKAGE}_ROOT`, `${PACKAGE}_DIR`)
2. CMAKE_PREFIX_PATH
3. hints[] aus Solution.json
4. Standard-Pfade (plattformspezifisch)
5. backup Pfad (mit Warning)
6. Fehler wenn nichts gefunden

### Erfolgskriterium

```cmake
# Qt6 wird gefunden und gelinkt
# Backup-Pfad mit Warning
# Klare Fehlermeldung bei nicht gefundenem Package
```

---

## 11. Checkliste

### Phase 1 ✅

- [x] Errors.cmake
- [x] Debug.cmake
- [x] Context.cmake
- [x] Json.cmake
- [x] Validation.cmake
- [x] SourceCollect.cmake
- [x] OutputDirs.cmake
- [x] Warnings.cmake
- [x] CompilerOptions.cmake
- [x] Phase 1 Tests bestehen

### Phase 2 ✅

- [x] Solution.cmake
- [x] SOLUTION_* Properties gesetzt
- [x] Schema-Validierung funktioniert

### Phase 3 ✅

- [x] Executables.cmake
- [x] ExecutableCollect.cmake
- [x] ExecutableCreate.cmake
- [x] MinimalConsole baut und läuft

### Phase 4 ✅

- [x] Libraries.cmake
- [x] LibraryCollect.cmake
- [x] LibraryCreate.cmake
- [x] Dependencies.cmake
- [x] Executable linkt gegen Library

### Phase 5 ✅

- [x] Orchestrator.cmake
- [x] Local/Attach.cmake
- [x] BASS lädt korrekt
- [x] W103/W104 Prüfung

### Phase 6 ✅

- [x] Core/Fetch.cmake (v0.2)
- [x] Core/Handler.cmake
- [x] Hooks/HookLoader.cmake
- [x] Registry/Targets.cmake
- [x] Git-External wird gefetcht
- [x] Hook-System funktioniert
- [x] E216 bei fehlendem Hook

### Phase 7 ✅

- [x] Tests.cmake (v0.1)
- [x] CTest-Integration
- [x] Framework-Erkennung
- [x] Labels und Timeout

### Phase 8 🔄

- [ ] Apps.cmake
- [ ] AppCollect.cmake
- [ ] AppCreate.cmake
- [ ] Core Library erstellt
- [ ] Runner Executable erstellt
- [ ] App-Tests erstellt
- [ ] Schema-Update
- [ ] Dokumentation

### Phase 9 🔄

- [ ] System/Handler.cmake
- [ ] System/PathResolver.cmake
- [ ] Qt6 Package
- [ ] Boost Package
- [ ] Backup-Pfad mit Warning
- [ ] Dokumentation

---

## 12. Siehe auch

- [master_concept.md](master_concept.md) — Architektur
- [guidelines.md](../standards/guidelines.md) — Konventionen
- [AppContainer.md](AppContainer.md) — Phase 8 Detail
- [System_Externals.md](System_Externals.md) — Phase 9 Detail
- [future_enhancements.md](future_enhancements.md) — Zukünftige Erweiterungen
- [Solution_Schema.md](../../../reference/Solution_Schema.md) — JSON-Schema
- [ErrorCodes.md](../../../reference/ErrorCodes.md) — Fehlercodes

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Neues Header-Format, Phase 6-7 als abgeschlossen markiert, Phase 8 (AppContainer) und Phase 9 (System Externals) hinzugefügt** |
| 0.1.0 | 2025-12-03 | Initial (Clean Start): Phasen aus v1.5 übernommen |