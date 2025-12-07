# CMakeLists.txt — Modul-Dokumentation

> **Version:** 0.1.1  
> **Dokument-Version:** 0.1.1  
> **Datum:** 2025-12-07  
> **Pfad:** `CMakeLists.txt`  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, guidelines v0.1

---

## 1. Übersicht

Die `CMakeLists.txt` ist die Top-Level-Konfiguration des modularen Build-Systems. Sie orchestriert das Laden aller Module und Pipelines.

### Verantwortlichkeiten

- CMake Minimum-Version definieren
- Build-Optionen bereitstellen
- Core-Module in korrekter Reihenfolge laden
- Solution.json verarbeiten
- Projekt mit CMake `project()` definieren
- Pipelines (Libraries, Executables, Tests) starten
- Optional: Build-System-Tests ausführen

---

## 2. Struktur

### 2.1 Abschnitte

| Abschnitt | Beschreibung |
|-----------|--------------|
| **Options** | Cache-Variablen für Build-Konfiguration |
| **Phase 1** | Core-Module laden |
| **Info** | Debug-Ausgaben zur Konfiguration |
| **Phase 2** | Solution.cmake laden |
| **Project** | CMake `project()` Aufruf |
| **Phase 4** | Libraries (muss vor Executables!) |
| **Phase 3** | Executables |
| **Phase 7** | Tests (geplant) |
| **Tests** | Build-System-Tests (optional) |
| **Cleanup** | Temporäre Variablen aufräumen |

### 2.2 Modul-Lade-Reihenfolge

```cmake
# Phase 1: Core (Reihenfolge wichtig!)
include(cmake/core/Errors.cmake)          # 1. Fehlerbehandlung
include(cmake/core/Debug.cmake)           # 2. Debug-Ausgaben
include(cmake/core/Json.cmake)            # 3. JSON-Parsing
include(cmake/core/Validation.cmake)      # 4. Validierung
include(cmake/core/Context.cmake)         # 5. Context-System
include(cmake/core/SourceCollect.cmake)   # 6. Source-Sammlung
include(cmake/core/OutputDirs.cmake)      # 7. Output-Verzeichnisse
include(cmake/core/Warnings.cmake)        # 8. Compiler-Warnungen
include(cmake/core/CompilerOptions.cmake) # 9. Compiler-Optionen

# Phase 2: Solution
include(cmake/project/Solution.cmake)

# Phase 4: Libraries (MUSS vor Executables!)
include(cmake/project/Libraries.cmake)

# Phase 3: Executables
include(cmake/project/Executables.cmake)

# Phase 7: Tests (geplant)
# include(cmake/project/Tests.cmake)
```

**Wichtig:** Libraries müssen **vor** Executables geladen werden, damit Executables gegen Libraries linken können!

---

## 3. Optionen

### 3.1 Cache-Variablen

| Option | Default | Beschreibung |
|--------|---------|--------------|
| `RUN_BUILD_SYSTEM_TESTS` | `ON` | Build-System-Tests ausführen |
| `TEST_PHASE` | `""` | Spezifische Phase(n) testen |
| `DEBUG_MESSAGES` | `ON` | Debug-Ausgaben aktivieren |
| `DEBUG_DEFAULT_LEVEL` | `2` | Debug-Verbosity (1-5) |
| `BUILD_ONLY` | `""` | Nur bestimmte Targets bauen |

### 3.2 Verwendung

```bash
# Standard-Build
cmake -B build

# Ohne Tests
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=OFF

# Nur Phase 4 testen
cmake -B build -DTEST_PHASE=4

# Verbose Debug
cmake -B build -DDEBUG_DEFAULT_LEVEL=5

# Nur bestimmtes Target
cmake -B build -DBUILD_ONLY="MyApp"
```

---

## 4. Konsolen-Ausgaben

### 4.1 Regel

> Alle Konsolen-Ausgaben erfolgen über das Debug-System (`dbg()`).  
> Keine direkten `message()`-Aufrufe außer für Fehler und Warnungen (über `cmake_fatal()`/`cmake_warn()`).

### 4.2 Debug-IDs

| ID | Modul | Beschreibung |
|----|-------|--------------|
| `CMAKE_MAIN` | CMakeLists.txt | Hauptkonfiguration |
| `BUILD_TEST` | Tests | Build-System-Tests |
| `SOLUTION` | Solution.cmake | Solution-Verarbeitung |
| `LIBRARIES` | Libraries.cmake | Library-Pipeline |
| `EXECUTABLES` | Executables.cmake | Executable-Pipeline |

### 4.3 Beispiel-Ausgabe

```
-- [CMake] === CMake Architecture V2 ===
-- [CMake] CMake Version: 3.28.0
-- [CMake] Generator: Ninja
-- [CMake] Build System Tests: ON
-- [Solution] Solution.json loaded
-- [Solution] MyProject v0.1.0
-- [Solution] Externals defined: 3
-- [Solution] Executables: 1, Libraries: 1, Tests: 0
-- -------------------------------------------
-- [Libraries] === Library Pipeline Start ===
-- [Libraries] Processing 1 library(ies)...
-- [Libraries] --- Processing: BasicLogger ---
-- [Libraries]   Created: BasicLogger
-- [Libraries] === Library Pipeline Complete ===
-- -------------------------------------------
-- [Executables] === Executable Pipeline Start ===
-- [Executables] Processing 1 executable(s)...
-- [Executables] --- Processing: MinimalConsole ---
-- [Executables]   Created: MinimalConsole
-- [Executables] === Executable Pipeline Complete ===
-- -------------------------------------------
-- [CMake] === Configuration Complete ===
```

---

## 5. Build-System-Tests

### 5.1 Phasen-Tests

| Phase | Datei | Testet |
|-------|-------|--------|
| 1 | `phase1.cmake` | Core-Module (Context, JSON, Debug) |
| 2 | `phase2.cmake` | Solution.cmake (Properties, Settings) |
| 3 | `phase3.cmake` | Executable-Pipeline |
| 4 | `phase4.cmake` | Library-Pipeline |
| 5+ | (geplant) | Externals, Tests |

### 5.2 Test-Flags

Nach erfolgreichem Test wird ein Cache-Flag gesetzt:

```cmake
PHASE1_TEST_PASSED = TRUE
PHASE2_TEST_PASSED = TRUE
PHASE3_TEST_PASSED = TRUE
PHASE4_TEST_PASSED = TRUE
```

### 5.3 Deaktivieren

```bash
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=OFF
```

---

## 6. Verzeichnisstruktur

```
project/
├── CMakeLists.txt              ← Diese Datei
├── Solution.json               ← Projekt-Konfiguration
├── cmake/
│   ├── core/                   ← Phase 1 Module
│   │   ├── Errors.cmake
│   │   ├── Debug.cmake
│   │   ├── Json.cmake
│   │   ├── Validation.cmake
│   │   ├── Context.cmake
│   │   ├── SourceCollect.cmake
│   │   ├── OutputDirs.cmake
│   │   ├── Warnings.cmake
│   │   └── CompilerOptions.cmake
│   ├── project/                ← Phase 2+ Module
│   │   ├── Solution.cmake
│   │   ├── Libraries.cmake
│   │   ├── LibraryCollect.cmake
│   │   ├── LibraryCreate.cmake
│   │   ├── Executables.cmake
│   │   ├── ExecutableCollect.cmake
│   │   └── ExecutableCreate.cmake
│   └── buildSystemTest/        ← Test-Module
│       ├── phase1.cmake
│       ├── phase2.cmake
│       ├── phase3.cmake
│       └── phase4.cmake
└── projects/
    ├── libs/                   ← Libraries
    │   └── BasicLogger/
    │       └── include/
    │           └── BasicLogger.h
    └── exec/                   ← Executables
        └── MinimalConsole/
            └── src/
                └── main.cpp
```

---

## 7. Best Practices

### 7.1 Keine direkten message()-Aufrufe

```cmake
# ❌ Falsch
message(STATUS "Loading configuration...")

# ✅ Richtig
dbg(${DBG_COMMON} "Loading configuration..." ID CMAKE_MAIN)
```

### 7.2 Fehler über Module

```cmake
# ❌ Falsch
message(FATAL_ERROR "Something went wrong")

# ✅ Richtig
cmake_fatal("E001" "Something went wrong")
```

### 7.3 Libraries vor Executables

```cmake
# ✅ Korrekte Reihenfolge
include(cmake/project/Libraries.cmake)    # ZUERST
include(cmake/project/Executables.cmake)  # DANN

# ❌ Falsche Reihenfolge - Executables können nicht linken!
include(cmake/project/Executables.cmake)
include(cmake/project/Libraries.cmake)
```

### 7.4 Variablen aufräumen

```cmake
# Am Ende der Datei
unset(_sol_name)
unset(_sol_version)
```

---

## 8. Fehlerbehebung

### Problem: Module nicht gefunden

```
CMake Error at CMakeLists.txt:XX (include):
  include could not find requested file: cmake/core/Errors.cmake
```

**Lösung:** Sicherstellen, dass `cmake/core/` Verzeichnis existiert und Module vorhanden sind.

### Problem: Solution.json fehlt

```
[E002] Solution.json not found: /path/to/project/Solution.json
```

**Lösung:** `Solution.json` im Projekt-Root erstellen.

### Problem: Library nicht gefunden beim Linken

```
[E101] Dependency 'BasicLogger' for executable 'MyApp' does not exist
```

**Lösung:** Sicherstellen, dass `Libraries.cmake` **vor** `Executables.cmake` geladen wird.

### Problem: Keine Debug-Ausgaben

**Lösung:** Debug-Level prüfen:
```bash
cmake -B build -DDEBUG_DEFAULT_LEVEL=5
```

---

## 9. Siehe auch

- [Solution.cmake](Modules/Solution_cmake_v0_1_1_doc_v0_1.md) — Solution-Verarbeitung
- [Libraries.cmake](Modules/Libraries_cmake_v0_1_0_doc_v0_1.md) — Library-Pipeline
- [Executables.cmake](Modules/Executables_cmake_v0_1_0_doc_v0_1.md) — Executable-Pipeline
- [Debug.cmake](Modules/Debug_cmake_v0_1_0_doc_v0_1.md) — Debug-System
- [guidelines](Concepts/guidelines_v0_1_0.md) — Projekt-Konventionen

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.1** | **2025-12-07** | **Libraries.cmake hinzugefügt, SourceCollect.cmake in Core-Module aufgenommen, Phase 4 Tests aktiviert** |
| 0.1.0 | 2025-12-05 | Clean Start: Strukturiert, Debug-basierte Ausgaben, Englische Kommentare |
