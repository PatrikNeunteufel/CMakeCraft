# CMakeLists.txt – Modul-Dokumentation

> **Version:** 0.1.0  
> **Dokument-Version:** 0.1.0  
> **Datum:** 2025-12-05  
> **Pfad:** `CMakeLists.txt`  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch  

---

## 1. Übersicht

Die `CMakeLists.txt` ist die Top-Level-Konfiguration des modularen Build-Systems. Sie orchestriert das Laden aller Module und Pipelines.

### Verantwortlichkeiten

- CMake Minimum-Version definieren
- Build-Optionen bereitstellen
- Core-Module in korrekter Reihenfolge laden
- Solution.json verarbeiten
- Projekt mit CMake `project()` definieren
- Pipelines (Executables, Libraries, Tests) starten
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
| **Phase 3+** | Pipelines (Executables, Libraries, Tests) |
| **Tests** | Build-System-Tests (optional) |
| **Cleanup** | Temporäre Variablen aufräumen |

### 2.2 Modul-Lade-Reihenfolge

```cmake
# Phase 1: Core (Reihenfolge wichtig!)
include(cmake/core/Errors.cmake)      # 1. Fehlerbehandlung
include(cmake/core/Debug.cmake)       # 2. Debug-Ausgaben
include(cmake/core/Json.cmake)        # 3. JSON-Parsing
include(cmake/core/Validation.cmake)  # 4. Validierung
include(cmake/core/Context.cmake)     # 5. Context-System
include(cmake/core/OutputDirs.cmake)  # 6. Output-Verzeichnisse
include(cmake/core/Warnings.cmake)    # 7. Compiler-Warnungen
include(cmake/core/CompilerOptions.cmake) # 8. Compiler-Optionen

# Phase 2: Solution
include(cmake/project/Solution.cmake)

# Phase 3: Pipelines
include(cmake/project/Executables.cmake)
# include(cmake/project/Libraries.cmake)
# include(cmake/project/Tests.cmake)
```

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

# Nur Phase 2 testen
cmake -B build -DTEST_PHASE=2

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
-- -------------------------------------------
-- [Executables] === Executable Pipeline Start ===
-- [Executables] Processing 2 executable(s)...
-- [Executables] --- Processing: MyApp ---
-- [Executables]   Created: MyApp
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
| 4+ | (geplant) | Libraries, Externals, Tests |

### 5.2 Test-Flags

Nach erfolgreichem Test wird ein Cache-Flag gesetzt:

```cmake
PHASE1_TEST_PASSED = TRUE
PHASE2_TEST_PASSED = TRUE
PHASE3_TEST_PASSED = TRUE
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
│   │   ├── OutputDirs.cmake
│   │   ├── Warnings.cmake
│   │   └── CompilerOptions.cmake
│   ├── project/                ← Phase 2+ Module
│   │   ├── Solution.cmake
│   │   ├── Executables.cmake
│   │   ├── ExecutableCollect.cmake
│   │   └── ExecutableCreate.cmake
│   └── buildSystemTest/        ← Test-Module
│       ├── phase1.cmake
│       ├── phase2.cmake
│       └── phase3.cmake
└── projects/
    └── exec/                   ← Executables
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

### 7.3 Variablen aufräumen

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

### Problem: Keine Debug-Ausgaben

**Lösung:** Debug-Level prüfen:
```bash
cmake -B build -DDEBUG_DEFAULT_LEVEL=5
```

---

## 9. Siehe auch

- [Solution.cmake](Modules/Solution_cmake_v0_1_0_doc_v0_1.md) – Solution-Verarbeitung
- [Executables.cmake](Modules/Executables_cmake_v0_1_0_doc_v0_1.md) – Executable-Pipeline
- [Debug.cmake](Modules/Debug_cmake_v0_1_0_doc_v0_1.md) – Debug-System
- [guidelines](Concepts/guidelines_v0_1_0.md) – Projekt-Konventionen

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-05** | **Clean Start: Strukturiert, Debug-basierte Ausgaben, Englische Kommentare** |
