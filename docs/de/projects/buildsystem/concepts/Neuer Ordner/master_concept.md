# Master Concept — CMake Architecture V2

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Concept  
> **Status:** In Entwicklung  
> **Zielgruppe:** Build-System-Entwickler, Architekten  
> **Sprache:** Deutsch  
> **English:** [master_concept.md](../../en/projects/buildsystem/concepts/master_concept.md)

Dieses Dokument dient als **zentrale Referenz** für das CMake Build-System. Es definiert die Struktur, Prinzipien und das technische Fundament.

---

## Inhaltsverzeichnis

1. [Vision](#1-vision)
2. [Projektstruktur](#2-projektstruktur)
3. [Solution.json Schema](#3-solutionjson-schema)
4. [External-Typen](#4-external-typen)
5. [Hook-System](#5-hook-system)
6. [Context-Objekt Pattern](#6-context-objekt-pattern)
7. [Source-Management](#7-source-management)
8. [Error-Handling](#8-error-handling)
9. [Pipelines](#9-pipelines)
10. [Cache-Variablen](#10-cache-variablen)
11. [Phasen-Übersicht](#11-phasen-übersicht)
12. [Dokumentation](#12-dokumentation)
13. [Siehe auch](#13-siehe-auch)


---

## 1. Vision

Ein modulares, stabiles und plattformübergreifendes CMake-System, das große Multi-Executable-Projekte verwalten kann, JSON-gesteuert ist und minimalen globalen Zustand besitzt.

### Kernprinzipien

| Prinzip | Beschreibung |
|---------|--------------|
| **Deklarativ über JSON** | Imperativ nur wo nötig |
| **Kein globaler State** | Alles über Context-Objekte |
| **Testbar auf jeder Ebene** | Unit, Integration, End-to-End |
| **Fail-fast** | Klare Fehlermeldungen |
| **Single Source of Truth** | Für External-Versionen |
| **Convention over Configuration** | Für optionale Features |

---

## 2. Projektstruktur

Die CMake-Infrastruktur ist in klar getrennte Verantwortungsbereiche aufgeteilt.

```
CMakeLists.txt                         # Top-Level: Module laden
Solution.json                          # JSON-Definition aller Targets
CMakePresets.json                      # Build-Presets

cmake/
  core/                                # Grundbausteine
    Errors.cmake                       # Error-Handling
    Debug.cmake                        # Debug-System
    Context.cmake                      # Context-Objekt-Pattern
    Json.cmake                         # JSON-Helferfunktionen
    Validation.cmake                   # Schema-Validierung
    SourceCollect.cmake                # Source-Datei-Management
    OutputDirs.cmake                   # Zielordner
    Warnings.cmake                     # Warnlevel
    CompilerOptions.cmake              # Compiler-Optionen

  externals/                           # External-System
    Orchestrator.cmake                 # High-Level Workflow
    Core/                              # Für fetched Externals
      Fetch.cmake
      Handler.cmake
    Hooks/                             # Hook-System
      HookLoader.cmake
      PreFetch/
      PostFetch/
    Local/                             # Für lokale Externals
      Attach.cmake
    Registry/                          # Target-Verwaltung
      Targets.cmake

  project/                             # Pipelines
    Solution.cmake                     # Solution.json laden
    Executables.cmake                  # Executable-Pipeline
    ExecutableCollect.cmake
    ExecutableCreate.cmake
    Libraries.cmake                    # Library-Pipeline
    LibraryCollect.cmake
    LibraryCreate.cmake
    Tests.cmake                        # Test-Pipeline
    Dependencies.cmake                 # Interne Abhängigkeiten
    Apps.cmake                         # App-Container-Pipeline (Phase 8)

externals/                             # Lokale Externals im Repo
  bass/
    Include.cmake
  lua/
    Include.cmake
  doctest/
    Include.cmake
```

---

## 3. Solution.json Schema

Die Solution.json ist das Herzstück der deklarativen Konfiguration.

**Aktuelle Schema-Version:** `0.1`

### Root-Level Struktur

```json
{
    "schemaVersion": "0.1",
    "solution": { },
    "settings": { },
    "externalsPolicy": { },
    "externals": { },
    "libraries": [ ],
    "executables": [ ],
    "apps": [ ],
    "tests": [ ]
}
```

| Block | Pflicht | Beschreibung |
|-------|---------|--------------|
| `schemaVersion` | ✅ | Version des JSON-Schemas |
| `solution` | ✅ | Metadaten (Name, Version, Autoren) |
| `settings` | ❌ | Globale Build-Einstellungen |
| `externalsPolicy` | ❌ | Cache-Verzeichnis, Update-Strategie |
| `externals` | ❌ | Zentrale External-Definitionen |
| `libraries` | ❌ | Interne Libraries |
| `executables` | ❌ | Ausführbare Programme (Legacy) |
| `apps` | ❌ | App-Container (Phase 8) |
| `tests` | ❌ | Test-Targets |

### Zentraler Externals-Block

**Alle External-Definitionen werden zentral definiert.** Executables/Apps referenzieren nur über Namen.

| Problem (dezentral) | Lösung (zentral) |
|---------------------|------------------|
| Version-Drift | Eine Version für alle |
| Update-Aufwand | Eine Stelle ändern |
| Inkonsistente Flags | Einheitliche Konfiguration |

---

## 4. External-Typen

Der Typ wird automatisch über das vorhandene Feld erkannt:

| Erkennungsfeld | Typ | Status |
|----------------|-----|--------|
| `path` | **local** | ✅ Implementiert (Phase 5) |
| `git` | **fetched** | ✅ Implementiert (Phase 6) |
| `system` | **system** | 🔄 Geplant (Phase 9) |
| `vcpkg` | **vcpkg** | ⬜ Geplant |
| `conan` | **conan** | ⬜ Geplant |

**Validierung:** Genau eines dieser Felder muss vorhanden sein (Error E012).

### Lokale Externals

Liegen bereits im Repository.

```json
"externals": {
    "bass": { "path": "externals/bass" },
    "lua": { "path": "externals/lua" }
}
```

**Convention:** Jedes lokale External muss eine `Include.cmake` haben.

### Fetched Externals

Werden aus Git geklont.

```json
"externals": {
    "spdlog": {
        "git": "https://github.com/gabime/spdlog.git",
        "tag": "v1.12.0"
    }
}
```

| Feld | Pflicht | Beschreibung |
|------|---------|--------------|
| `git` | ✅ | Repository URL |
| `tag` | ❌* | Git-Tag |
| `branch` | ❌* | Git-Branch |
| `commit` | ❌* | Commit-Hash |
| `hooks` | ❌ | Pre/PostFetch Hooks |

*Genau eines von `tag`, `branch`, `commit` erforderlich (Error E215).

### System Externals (Phase 9)

Bereits installierte System-Bibliotheken.

```json
"externals": {
    "qt6": {
        "system": true,
        "package": "Qt6",
        "components": ["Core", "Widgets", "Gui"],
        "hints": ["${QT_ROOT}"]
    }
}
```

→ Siehe [System_Externals.md](System_Externals.md)

---

## 5. Hook-System

Für Externals die spezielle Behandlung benötigen.

### Convention over Configuration

| Situation | Verhalten |
|-----------|-----------|
| Keine Hooks angegeben, kein Convention-Pfad | Kein Hook |
| Keine Hooks angegeben, Convention-Pfad existiert | Auto-Load |
| Hooks explizit angegeben, Datei existiert | Laden |
| Hooks explizit angegeben, Datei fehlt | **Error E216** |

**Convention-Pfade:**
- PreFetch: `cmake/externals/Hooks/PreFetch/${name}.cmake`
- PostFetch: `cmake/externals/Hooks/PostFetch/${name}.cmake`

---

## 6. Context-Objekt Pattern

Statt globaler Variablen nutzt jedes Target einen eigenen Namensraum.

```cmake
ctx_create(EXE_MyApp)
ctx_set(EXE_MyApp NAME "MyApp")
ctx_set(EXE_MyApp PATH "src/app")
ctx_get(EXE_MyApp NAME _name)
```

**Vorteile:**
- Isolierte Namensräume
- Parallele Verarbeitung möglich
- Kein State-Leaking

---

## 7. Source-Management

Drei Modi für Source-Dateien:

| Mode | Beschreibung |
|------|--------------|
| `explicit` | Source.cmake erforderlich (Default) |
| `glob` | Automatisches Sammeln |
| `auto` | Source.cmake wenn vorhanden, sonst GLOB |

**Empfehlung:** `explicit` für maximale Kontrolle.

---

## 8. Error-Handling

Einheitliches System über `Errors.cmake`:

```cmake
cmake_fatal("E001" "Beschreibung")   # Bricht ab
cmake_warn("W001" "Beschreibung")    # Läuft weiter
cmake_assert(CONDITION "Message")    # Interne Prüfung
```

**Fehlercode-Bereiche:**

| Bereich | Prefix | Beschreibung |
|---------|--------|--------------|
| JSON/Parsing | E0xx | E001, E002, E010, E012 |
| Target-Erstellung | E1xx | E101, E102, E103, E104 |
| Externals | E2xx | E201, E213, E214, E215, E216 |
| App-Container | E4xx | E401-E407 (Phase 8) |
| Deprecation | W0xx | W001, W002 |
| Konfiguration | W1xx | W101-W110 |
| Tools/Setup | W2xx | W201 |
| App-Container | W4xx | W401-W403 (Phase 8) |

---

## 9. Pipelines

### Executable-Pipeline

1. **Collect:** JSON → Context
2. **Validate:** Pflichtfelder, Abhängigkeiten
3. **Create:** CMake-Target erstellen
4. **Configure:** PCH, Sources, Externals, Options

### Library-Pipeline

Analog zu Executables, zusätzlich:
- PUBLIC/PRIVATE Headers
- STATIC/SHARED/INTERFACE Typen

### Test-Pipeline

- CTest-Integration
- Framework-Erkennung (doctest, gtest, catch2)
- Labels und Timeout-Konfiguration

### App-Container-Pipeline (Phase 8)

Testbare Anwendungsarchitektur:
1. **Core Library:** Business-Logik als STATIC Library
2. **Runner:** Entry Point (main.cpp)
3. **Tests:** Unit- und Integration-Tests gegen Core

→ Siehe [AppContainer.md](AppContainer.md)

---

## 10. Cache-Variablen

| Variable | Default | Beschreibung |
|----------|---------|--------------|
| `BUILD_TESTS` | ON | Tests aktivieren |
| `BUILD_ONLY` | "" | Nur bestimmte Targets |
| `RUN_BUILD_SYSTEM_TESTS` | OFF | Interne Build-Tests |
| `ENABLE_CLANG_TIDY` | OFF | Code-Qualitätschecks |
| `ENABLE_STRICT_CONFORMANCE` | ON | MSVC strict mode |
| `NO_EXCEPTIONS` | OFF | Exceptions deaktivieren |
| `NO_RTTI` | OFF | RTTI deaktivieren |

---

## 11. Phasen-Übersicht

### Abgeschlossene Phasen

| Phase | Beschreibung | Status |
|-------|--------------|--------|
| **Phase 1** | Foundation (Core-Module) | ✅ Abgeschlossen |
| **Phase 2** | Solution & Validation | ✅ Abgeschlossen |
| **Phase 3** | Executable Pipeline | ✅ Abgeschlossen |
| **Phase 4** | Library Pipeline | ✅ Abgeschlossen |
| **Phase 5** | Lokale Externals | ✅ Abgeschlossen |
| **Phase 6** | Fetched Externals + Hooks (Fetch v0.2) | ✅ Abgeschlossen |
| **Phase 7** | Test Pipeline (v0.1) | ✅ Abgeschlossen |

### Aktive Phasen

| Phase | Beschreibung | Status | Detail-Dokument |
|-------|--------------|--------|-----------------|
| **Phase 8** | App-Container | 🔄 In Planung | [AppContainer.md](AppContainer.md) |
| **Phase 9** | System Externals | 🔄 In Planung | [System_Externals.md](System_Externals.md) |

### Phase 8: App-Container (Kurzübersicht)

Testbare Anwendungsarchitektur durch Trennung von Business-Logik und Entry Point:

```
projects/apps/{AppName}/
├── include/                # PUBLIC Headers
├── src/                    # Implementation
├── main/                   # Entry Point
└── tests/
    ├── unit/
    └── integration/
```

**Generierte Targets:**
- `{AppName}.Core` — STATIC Library
- `{AppName}` — Executable
- `{AppName}.UnitTests` — Test Executable
- `{AppName}.IntegrationTests` — Test Executable

### Phase 9: System Externals (Kurzübersicht)

Integration von system-installierten Bibliotheken (Qt6, Boost, OpenCV):

```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "components": ["Core", "Widgets"],
    "hints": ["${QT_ROOT}"]
}
```

**Features:**
- Automatische Pfad-Auflösung
- Umgebungsvariablen-Support
- Backup-Pfade mit Warnung

### Zukünftige Erweiterungen

Weitere geplante Features sind in [future_enhancements.md](future_enhancements.md) dokumentiert:

- Lockfile-System für reproduzierbare Builds
- vcpkg/Conan Integration
- C++20 Modules Support
- CI/CD Generatoren
- und mehr...

---

## 12. Dokumentation

| Dokument | Beschreibung |
|----------|--------------|
| [implementation_plan.md](implementation_plan.md) | Detaillierter Umsetzungsplan |
| [guidelines.md](../standards/guidelines.md) | Coding-Konventionen |
| [Solution_Schema.md](../../../reference/Solution_Schema.md) | JSON-Schema-Dokumentation |
| [ErrorCodes.md](../../../reference/ErrorCodes.md) | Alle Fehlercodes |

---

## 13. Siehe auch

- [implementation_plan.md](implementation_plan.md) — Phasen-basierter Plan
- [AppContainer.md](AppContainer.md) — Phase 8 Detail
- [System_Externals.md](System_Externals.md) — Phase 9 Detail
- [future_enhancements.md](future_enhancements.md) — Geplante Erweiterungen

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Neues Header-Format, Phase 8 (AppContainer) und Phase 9 (System Externals) hinzugefügt, Link zu Future Enhancements** |
| 0.1.0 | 2025-12-03 | Initial (Clean Start): Struktur aus v1.7 übernommen |