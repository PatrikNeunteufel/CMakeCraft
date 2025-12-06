# Implementation Plan – CMake Architecture V2

> **Version:** 0.1.0  
> **Datum:** 2025-12-03  
> **Typ:** Konzept-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, Solution_Schema v0.1, ErrorCodes v0.1
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Concepts/implementation_plan_v0_1_0.md)

Dieser Plan beschreibt die schrittweise Umsetzung des CMake Build-Systems.

---

## 1. Übersicht

### Status der Dateien

| Datei | Status | Aktion |
|-------|--------|--------|
| `CMakePresets.json` | ✅ | Minimal anpassen |
| `Solution.json` | 🔄 | Nach Schema v0.1 erstellen |
| `CMakeLists.txt` | 🔄 | Neu, minimal |
| `cmake/*.cmake` | 🔄 | Schrittweise implementieren |

### Phasen-Übersicht

```
Phase 1: Foundation (Core-Module)
    ↓
Phase 2: Solution & Validation
    ↓
Phase 3: Executable Pipeline
    ↓
Phase 4: Library Pipeline
    ↓
Phase 5: Lokale Externals
    ↓
Phase 6: Fetched Externals + Hooks
    ↓
Phase 7: Tests & Polish
```

---

## 2. Phase 1: Foundation

**Ziel:** Grundlegende Infrastruktur für alle weiteren Module.

### Module

| Modul | Beschreibung |
|-------|--------------|
| `Errors.cmake` | `cmake_fatal()`, `cmake_warn()`, `cmake_assert()` |
| `Debug.cmake` | Debug-System mit Leveln |
| `Context.cmake` | Context-Objekt-Pattern |
| `Json.cmake` | JSON-Hilfsfunktionen |
| `Validation.cmake` | Schema-Validierung |
| `SourceCollect.cmake` | Source-Datei-Management |
| `OutputDirs.cmake` | Zielverzeichnisse |
| `Warnings.cmake` | Warning-Level |
| `CompilerOptions.cmake` | Compiler-Konfiguration |

### Erfolgskriterium

```bash
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=ON
# Phase 1 Tests bestehen
```

---

## 3. Phase 2: Solution & Validation

**Ziel:** Solution.json einlesen und validieren.

### Module

| Modul | Beschreibung |
|-------|--------------|
| `Solution.cmake` | JSON laden, GLOBAL Properties setzen |

### Funktionen

```cmake
# Solution.json laden
_load_solution_json()

# Pflichtfelder validieren
validate_solution_structure()

# Settings mit Defaults mergen
_apply_settings_defaults()
```

### Erfolgskriterium

```cmake
# Nach include(Solution.cmake):
# - SOLUTION_JSON ist gesetzt
# - SOLUTION_NAME ist verfügbar
# - SOLUTION_VERSION ist verfügbar
# - SOLUTION_SETTINGS_JSON ist verfügbar
```

---

## 4. Phase 3: Executable Pipeline

**Ziel:** Executables aus Solution.json erstellen.

### Module

| Modul | Beschreibung |
|-------|--------------|
| `Executables.cmake` | Hauptschleife über Executables |
| `ExecutableCollect.cmake` | JSON → Context |
| `ExecutableCreate.cmake` | Target erstellen |

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
./build/bin/MinimalConsole  # "Hello World"
```

---

## 5. Phase 4: Library Pipeline

**Ziel:** Libraries aus Solution.json erstellen.

### Module

| Modul | Beschreibung |
|-------|--------------|
| `Libraries.cmake` | Hauptschleife |
| `LibraryCollect.cmake` | JSON → Context |
| `LibraryCreate.cmake` | Target erstellen |
| `Dependencies.cmake` | Interne Abhängigkeiten |

### Library-Typen

| Typ | CMake |
|-----|-------|
| STATIC | `add_library(X STATIC)` |
| SHARED | `add_library(X SHARED)` |
| INTERFACE | `add_library(X INTERFACE)` |

### Erfolgskriterium

```cmake
# Library wird erstellt
# Executable kann gegen Library linken
target_link_libraries(MyApp PRIVATE CoreLib)
```

---

## 6. Phase 5: Lokale Externals

**Ziel:** Lokale Externals einbinden.

### Module

| Modul | Beschreibung |
|-------|--------------|
| `Orchestrator.cmake` | Dispatch nach External-Typ |
| `Local/Attach.cmake` | Include.cmake aufrufen |

### Ablauf

```
1. External-Typ erkennen (path → local)
2. Include.cmake Pfad bestimmen
3. Variablen setzen (EXECUTABLE_NAME, EXTERNAL_ELEMENT_OPTIONS)
4. Include.cmake laden
5. Warnings prüfen (W103, W104)
```

### Erfolgskriterium

```cmake
# BASS lädt korrekt
# target_link_libraries funktioniert
# DLLs werden kopiert
```

---

## 7. Phase 6: Fetched Externals + Hooks

**Ziel:** Git-Externals fetchen, Hook-System.

### Module

| Modul | Beschreibung |
|-------|--------------|
| `Core/Fetch.cmake` | FetchContent-Wrapper |
| `Core/Hash.cmake` | Config-Hashing |
| `Core/Policies.cmake` | Update-Strategie |
| `Hooks/HookLoader.cmake` | Hook-System |
| `Registry/Targets.cmake` | Target-Registry |

### Hook-Ablauf

```
1. Convention-Pfad prüfen
2. Expliziten Pfad prüfen (E216 wenn fehlt)
3. PreFetch Hook laden (wenn vorhanden)
4. FetchContent_Declare/MakeAvailable
5. PostFetch Hook laden (wenn vorhanden)
6. Target in Registry eintragen
```

### Erfolgskriterium

```cmake
# spdlog wird gefetcht
# ImGui PostFetch Hook erstellt Target
# E216 bei fehlendem expliziten Hook
```

---

## 8. Phase 7: Tests & Polish

**Ziel:** Test-Targets, Dokumentation, Cleanup.

### Module

| Modul | Beschreibung |
|-------|--------------|
| `Tests.cmake` | Test-Pipeline |
| `TestCollect.cmake` | JSON → Context |
| `TestCreate.cmake` | Test-Target erstellen |

### Features

- CTest-Integration
- Framework-Erkennung
- Labels und Timeout
- Parallele Ausführung

### Dokumentation

- [ ] master_concept finalisieren
- [ ] guidelines finalisieren
- [ ] ErrorCodes komplett
- [ ] UserManual erstellen

---

## 9. Checkliste

### Phase 1 ✅

- ✅ Errors.cmake
- ✅ Debug.cmake
- ✅ Context.cmake
- ✅ Json.cmake
- ✅ Validation.cmake
- ✅ SourceCollect.cmake
- ✅ OutputDirs.cmake
- ✅ Warnings.cmake
- ✅ CompilerOptions.cmake
- ✅ Phase 1 Tests bestehen

### Phase 2

- ✅ Solution.cmake
- ✅ SOLUTION_* Properties gesetzt
- ✅ Schema-Validierung funktioniert

### Phase 3

- ✅ Executables.cmake
- ✅ ExecutableCollect.cmake
- ✅ ExecutableCreate.cmake
- ✅ MinimalConsole baut und läuft

### Phase 4

- [ ] Libraries.cmake
- [ ] LibraryCollect.cmake
- [ ] LibraryCreate.cmake
- [ ] Dependencies.cmake
- [ ] Executable linkt gegen Library

### Phase 5

- [ ] Orchestrator.cmake
- [ ] Local/Attach.cmake
- [ ] BASS lädt korrekt
- [ ] W103/W104 Prüfung

### Phase 6

- [ ] Core/Fetch.cmake
- [ ] Hooks/HookLoader.cmake
- [ ] Registry/Targets.cmake
- [ ] Git-External wird gefetcht
- [ ] Hook-System funktioniert
- [ ] E216 bei fehlendem Hook

### Phase 7

- [ ] Tests.cmake
- [ ] CTest-Integration
- [ ] Dokumentation komplett
- [ ] Git-Tag für Release

---

## 10. Siehe auch

- [master_concept](master_concept_v0_1_0.md) – Architektur
- [guidelines](guidelines_v0_1_0.md) – Konventionen
- [Solution_Schema](../References/Solution_Schema_v0_1_0.md) – JSON-Schema
- [ErrorCodes](../References/ErrorCodes_v0_1_0.md) – Fehlercodes

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-03** | **Initial (Clean Start): Phasen aus v1.5 übernommen, Blueprint-Format, SourceCollect in Phase 1** |
