# CMakeLists.txt — Referenz

> **Version:** 1.0.2  
> **Datum:** 2026-11-09  
> **Typ:** Reference  
> **Status:** Stabil  
> **Zielgruppe:** Alle Entwickler  
> **Sprache:** Deutsch  
> **English:** [CMakeLists.md](../../../en/guide/module/CMakeLists.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Struktur](#2-struktur)
3. [Phasen](#3-phasen)
4. [Optionen](#4-optionen)
5. [Modul-Lade-Reihenfolge](#5-modul-lade-reihenfolge)
6. [Konsolen-Ausgaben](#6-konsolen-ausgaben)
7. [Build-System-Tests](#7-build-system-tests)
8. [Verzeichnisstruktur](#8-verzeichnisstruktur)
9. [Best Practices](#9-best-practices)
10. [Fehlerbehebung](#10-fehlerbehebung)
11. [Siehe auch](#11-siehe-auch)
12. [Changelog](#changelog)

---

## 1. Übersicht

Seit v0.7.0 ist der Einstieg in das Build-System die Datei **`CMakeCraft.cmake`** im Repo-Root. Sie ist
**selbst-lokalisierend**: Sie setzt `CMAKECRAFT_DIR` auf den Ordner `cmake/` neben sich (und `CMAKECRAFT_ROOT` auf
ihren eigenen Ordner) und lädt alle Module über `${CMAKECRAFT_DIR}`. CMakeCraft kann deshalb an beliebiger Stelle
liegen (Snapshot im Projekt, Checkout unter `.externals/`, Submodul, Nachbarordner).

Die `CMakeLists.txt` eines Projekts — auch die des CMakeCraft-Repos selbst — ist nur noch eine **Dünnfassung**: Sie
ruft `cmake_minimum_required()` und `project()` auf und bindet `CMakeCraft.cmake` ein. Das CMakeCraft-Repo nutzt
seinen Einstieg damit genau so wie ein Konsument („Dogfooding“ gegen die Demo-`Solution.json`).

Projektbezogene Eingaben bleiben relativ zum **konsumierenden Projekt** (`CMAKE_SOURCE_DIR`): `Solution.json`,
`projects/`, `externals/`, `.externals/`.

### Verantwortlichkeiten

| Datei | Aufgabe |
|-------|---------|
| **`CMakeLists.txt`** (Projekt) | Minimum-Version (3.26), `project(<Name> LANGUAGES NONE)`, `include(…/CMakeCraft.cmake)` |
| **`CMakeCraft.cmake`** | Include-Guard, Selbst-Lokalisierung (`CMAKECRAFT_DIR`), Optionen, Core-Module laden, `Solution.json` verarbeiten, `project()` mit Name/Version aus der Solution, Pipelines in fester Reihenfolge, optional Build-System-Tests |

### Minimale CMakeLists.txt

So sieht die `CMakeLists.txt` des CMakeCraft-Repos aus (Konsumenten ebenso, nur mit ihrem Pfad zu `CMakeCraft.cmake`):

```cmake
cmake_minimum_required(VERSION 3.26)
project(CMakeCraft LANGUAGES NONE)   # name/version come from Solution.json

include("${CMAKE_CURRENT_LIST_DIR}/CMakeCraft.cmake")
```

Die Zeile `project(<Name> LANGUAGES NONE)` ist seit v0.13.0 **Pflicht** (sonst E005, siehe
[10.2](#102-e005-keine-project-zeile)). Name und Version des Projekts kommen trotzdem aus `Solution.json`:
`CMakeCraft.cmake` ruft `project()` ein zweites Mal mit diesen Werten und `LANGUAGES C CXX` auf.

Wie ein Konsument CMakeCraft bezieht (Bootstrap-Fetch über `cmakecraft.pin`, Entwicklung gegen eine Arbeitskopie
mit `-DCMAKECRAFT_LOCAL_DIR=<checkout>`), beschreibt der [Neues_Projekt_Guide](../userguides/Neues_Projekt_Guide.md).

---

## 2. Struktur

### 2.1 Abschnitte von `CMakeCraft.cmake`

| Abschnitt | Beschreibung |
|-----------|--------------|
| **Include-Guard** | `CMAKECRAFT_INCLUDED` — ein Projekt lädt das Build-System nur einmal |
| **Selbst-Lokalisierung** | `CMAKECRAFT_ROOT` = Ordner von `CMakeCraft.cmake`, `CMAKECRAFT_DIR` = `${CMAKECRAFT_ROOT}/cmake` |
| **Options** | `BUILD_TESTS`, `RUN_BUILD_SYSTEM_TESTS`, `TEST_PHASE` |
| **Phase 1** | Core-Module laden (10 Module) |
| **Info** | Debug-Ausgaben zur Konfiguration (ID `CMAKE_MAIN`) |
| **Phase 2** | `project/Solution.cmake` laden |
| **Project** | Prüfung auf `project()`-Zeile (E005), `project()` mit Name/Version aus der Solution, `craft_setup_testing_configuration()` |
| **Testing** | `enable_testing()`, wenn `BUILD_TESTS` an ist — vor allen `add_test()`-Aufrufen |
| **Phase 5 & 6** | Externals (lokal, gefetcht, System, Archiv) — vor Libraries und Executables |
| **Phase 4** | Libraries — vor Executables |
| **Phase 3** | Executables |
| **Phase 8** | App-Container |
| **Phase 10** | Packages (braucht die Targets davor) |
| **Phase 7** | Tests (nur bei `BUILD_TESTS`) |
| **Build-System-Tests** | Phasentests 1–11 (nur bei `RUN_BUILD_SYSTEM_TESTS`) |
| **Cleanup** | Temporäre Variablen aufräumen |

### 2.2 Phasen-Nummern

> **Hinweis:** Die Phasen-Nummern entsprechen der **Entwicklungsreihenfolge**, nicht der Ausführungsreihenfolge.
> Externals (Phase 5/6) laufen vor Libraries (Phase 4), Libraries vor Executables (Phase 3).

---

## 3. Phasen

### Übersicht

| Phase | Name | Module | Status |
|-------|------|--------|--------|
| **1** | Core | Errors, Debug, Json, Validation, Context, SourceCollect, OutputDirs, Warnings, CompilerOptions, Configurations | ✅ |
| **2** | Solution | Solution | ✅ |
| **3** | Executables | Executables, ExecutableCollect, ExecutableCreate | ✅ |
| **4** | Libraries | Libraries, LibraryCollect, LibraryCreate | ✅ |
| **5** | Lokale Externals | Externals, externals/Orchestrator, local/Attach, includes/\<name\>/Include, registry/Targets | ✅ |
| **6** | Git-Externals & Hooks | core/Fetch, fetched/Handler, hooks/HookLoader (+ prefetch/postfetch) | ✅ |
| **7** | Tests | Tests, TestCollect, TestCreate | ✅ |
| **8** | App-Container | Apps, AppCollect, AppCreate | ✅ |
| **9** | System-Externals | system/Handler, system/PathResolver, system/packages (Qt6, Boost) | ✅ |
| **10** | Packages & Archiv-Externals | Packages, PackageBuild (Build-Zeit-Skript), archive/Handler, `CMakeCraftPackage.cmake` | ✅ |
| **11** | Bibliotheks-`compile_options` & Quellpaket | LibraryCreate, SourcePackage | ✅ |

### Ausführungsreihenfolge

```
 1. Core-Module      (Phase 1)
 2. Solution         (Phase 2)
 3. project()        ← Name/Version aus Solution.json
 4. enable_testing() ← nur bei BUILD_TESTS
 5. Externals        (Phase 5, 6, 9, 10) ← VOR Libraries und Executables!
 6. Libraries        (Phase 4)  ← VOR Executables!
 7. Executables      (Phase 3)
 8. Apps             (Phase 8)
 9. Packages         (Phase 10, 11) ← braucht die Targets davor
10. Tests            (Phase 7)  ← nur bei BUILD_TESTS
11. Phasentests 1–11            ← nur bei RUN_BUILD_SYSTEM_TESTS
```

---

## 4. Optionen

### 4.1 Cache-Variablen

| Option | Typ | Default | Beschreibung |
|--------|-----|---------|--------------|
| `BUILD_TESTS` | BOOL | `OFF` | Projekt-Tests bauen (`enable_testing()`, Phase 7, Test-Targets der Apps) |
| `RUN_BUILD_SYSTEM_TESTS` | BOOL | `OFF` | Build-System-Phasentests ausführen; im CMakeCraft-Repo über das Preset `craft-selftest` |
| `TEST_PHASE` | STRING | `""` | Nur diese Phase(n) testen, `1`–`11`; leer = alle |
| `DEBUG_MESSAGES` | BOOL | `ON` | Hauptschalter der Debug-Ausgaben (`Debug.cmake`) |
| `DEBUG_DEFAULT_LEVEL` | STRING | `2` | SHOW-Level für Debug-Kontexte ohne eigenes `LEVEL` (1–5) |
| `BUILD_ONLY` | STRING | `""` | Nur diese Libraries/Executables/Apps anlegen (Liste mit `;`); keine `option()`, wird von den Pipelines gelesen und in den Presets gesetzt |

`BUILD_TESTS`, `RUN_BUILD_SYSTEM_TESTS` und `TEST_PHASE` legt `CMakeCraft.cmake` an; `DEBUG_MESSAGES` und
`DEBUG_DEFAULT_LEVEL` setzt `core/Debug.cmake`, wenn sie nicht schon definiert sind.

### 4.2 Verwendung

```bash
# Standard-Build (ohne Projekt-Tests, ohne Phasentests)
cmake -B build

# Projekt-Tests bauen
cmake -B build -DBUILD_TESTS=ON

# Selbsttest des Build-Systems (im CMakeCraft-Repo)
cmake --preset craft-selftest

# Nur Phase 4 testen
cmake --preset craft-selftest -DTEST_PHASE=4

# Debug-Ausgaben ganz abschalten
cmake -B build -DDEBUG_MESSAGES=OFF

# Nur bestimmtes Target
cmake -B build -DBUILD_ONLY="MyApp"

# Qt6 Pfad setzen
cmake -B build -DCMAKE_PREFIX_PATH=/path/to/Qt/6.6.0/gcc_64
```

### 4.3 Debug-Level

Jede Ausgabe `dbg(<freq> …)` erscheint, wenn ihre Häufigkeitsstufe ≤ dem SHOW-Level des Kontexts ist.

| SHOW-Level | Konstante | Beschreibung |
|------------|-----------|--------------|
| 1 | `DBG_SHOW_LITTLE` | Nur das Wesentliche |
| 2 | `DBG_SHOW_SOME` | Standard (Default von `DEBUG_DEFAULT_LEVEL`) |
| 3 | `DBG_SHOW_MUCH` | Mehr Details |
| 4 | `DBG_SHOW_LOTS` | Viele Details |
| 5 | `DBG_SHOW_ALL` | Alles |

`DEBUG_DEFAULT_LEVEL` wirkt nur auf Kontexte ohne eigenes `LEVEL`. Die Pipelines setzen ihr Level selbst
(`CMAKE_MAIN`, `SOLUTION`, `EXTERNALS`, `LIBRARIES`, `EXECUTABLES`, `APPS`, `PACKAGES`: `DBG_SHOW_MUCH`;
`BUILD_TEST`: `DBG_SHOW_ALL`).

---

## 5. Modul-Lade-Reihenfolge

### 5.1 Phase 1: Core-Module

Die Reihenfolge ist **kritisch** — spätere Module hängen von früheren ab:

```cmake
include("${CMAKECRAFT_DIR}/core/Errors.cmake")          # 1. Fehlerbehandlung
include("${CMAKECRAFT_DIR}/core/Debug.cmake")           # 2. Debug-Ausgaben
include("${CMAKECRAFT_DIR}/core/Json.cmake")            # 3. JSON-Parsing
include("${CMAKECRAFT_DIR}/core/Validation.cmake")      # 4. Validierung
include("${CMAKECRAFT_DIR}/core/Context.cmake")         # 5. Context-System
include("${CMAKECRAFT_DIR}/core/SourceCollect.cmake")   # 6. Source-Sammlung
include("${CMAKECRAFT_DIR}/core/OutputDirs.cmake")      # 7. Output-Verzeichnisse
include("${CMAKECRAFT_DIR}/core/Warnings.cmake")        # 8. Compiler-Warnungen
include("${CMAKECRAFT_DIR}/core/CompilerOptions.cmake") # 9. Compiler-Optionen
include("${CMAKECRAFT_DIR}/core/Configurations.cmake")  # 10. Konfiguration Testing
```

### 5.2 Phase 2: Solution

```cmake
include("${CMAKECRAFT_DIR}/project/Solution.cmake")
```

Lädt und validiert `Solution.json` aus `CMAKE_SOURCE_DIR` und legt Name und Version in den globalen Properties
`SOLUTION_NAME` und `SOLUTION_VERSION` ab.

### 5.3 project() Aufruf

```cmake
get_property(_sol_name GLOBAL PROPERTY SOLUTION_NAME)
get_property(_sol_version GLOBAL PROPERTY SOLUTION_VERSION)

project("${_sol_name}" VERSION "${_sol_version}" LANGUAGES C CXX)

craft_setup_testing_configuration()
```

Vorher prüft `CMakeCraft.cmake`, dass die `CMakeLists.txt` des Projekts eine eigene `project()`-Zeile hat (E005).

### 5.4 Phase 5/6: Externals

```cmake
include("${CMAKECRAFT_DIR}/project/Externals.cmake")
```

Lädt den Externals-Orchestrator (`externals/Orchestrator.cmake`) mit den Handlern für lokale, gefetchte,
System- und Archiv-Externals. **Läuft vor Libraries und Executables**, damit deren Targets die Externals vorfinden.

### 5.5 Phase 4: Libraries

```cmake
include("${CMAKECRAFT_DIR}/project/Libraries.cmake")
```

**Muss vor Executables geladen werden!** Executables können gegen Libraries linken.

### 5.6 Phase 3: Executables

```cmake
include("${CMAKECRAFT_DIR}/project/Executables.cmake")
```

### 5.7 Phase 8: App-Container

```cmake
include("${CMAKECRAFT_DIR}/project/Apps.cmake")
```

### 5.8 Phase 10: Packages

```cmake
include("${CMAKECRAFT_DIR}/project/Packages.cmake")
```

Legt die Targets `package_<name>` an (lädt `SourcePackage.cmake` für Quellpakete, Phase 11).

### 5.9 Phase 7: Tests

```cmake
if(BUILD_TESTS)
    include("${CMAKECRAFT_DIR}/project/Tests.cmake")
endif()
```

---

## 6. Konsolen-Ausgaben

### 6.1 Regel

> **Konsolen-Ausgaben erfolgen über das Debug-System (`dbg()`).**  
> Keine direkten `message()`-Aufrufe außer für Fehler via `cmake_fatal()`.

### 6.2 Debug-IDs

| ID | Modul | Beschreibung |
|----|-------|--------------|
| `CMAKE_MAIN` | CMakeCraft.cmake | Hauptkonfiguration (Tag `CMake`) |
| `BUILD_TEST` | CMakeCraft.cmake | Build-System-Tests (Tag `BuildTest`) |
| `SOLUTION` | Solution.cmake | Solution-Verarbeitung |
| `EXTERNALS` | Externals.cmake | Externals-Pipeline |
| `LIBRARIES` | Libraries.cmake | Library-Pipeline |
| `EXECUTABLES` | Executables.cmake | Executable-Pipeline |
| `APPS` | Apps.cmake | App-Container-Pipeline |
| `PACKAGES` | Packages.cmake | Package-Pipeline |
| `TESTS` | TestCollect.cmake | Test-Sammlung; `Tests.cmake` selbst schreibt mit `message(STATUS "[Tests] …")` |

### 6.3 Beispiel-Ausgabe

Der Rahmen kommt aus `CMakeCraft.cmake` (ID `CMAKE_MAIN`); dazwischen schreiben die Pipelines mit ihrem eigenen
Tag (`[Solution]`, `[Externals]`, `[Libraries]`, `[Executables]`, `[Apps]`, `[Packages]`, `[Tests]`):

```
-- [CMake] === CMakeCraft (CMake Architecture V2) ===
-- [CMake] CMakeCraft Dir: <pfad>/CMakeCraft/cmake
-- [CMake] CMake Version: <version>
-- [CMake] Generator: Ninja
-- [CMake] Build Tests: OFF
-- [CMake] Build System Tests: OFF
-- [Solution] …
-- [CMake] Project: <Name> v<Version>
-- [Externals] …
-- [Libraries] …
-- [Executables] …
-- [Apps] …
-- [Packages] …
-- 
-- [CMake] === Configuration Complete ===
-- -------------------------------------------
```

---

## 7. Build-System-Tests

### 7.1 Phasen-Tests

Die Phasentests liegen unter `cmake/buildSystemTest/` und laufen nach der Pipeline, wenn
`RUN_BUILD_SYSTEM_TESTS` an ist (Default `OFF`). „Grün“ heißt: Configure ohne Fehler.

| Phase | Datei | Testet |
|-------|-------|--------|
| 1 | `phase1.cmake` | Core-Module |
| 2 | `phase2.cmake` | Solution.cmake (Properties, Settings) |
| 3 | `phase3.cmake` | Executable-Pipeline |
| 4 | `phase4.cmake` | Library-Pipeline |
| 5 | `phase5.cmake` | Externals-Pipeline (lokale Externals) |
| 6 | `phase6.cmake` | Git-Externals und Hooks |
| 7 | `phase7.cmake` | Test-Pipeline |
| 8 | `phase8.cmake` | App-Container-Pipeline |
| 9 | `phase9.cmake` | System-Externals |
| 10 | `phase10.cmake` | Packages und Archiv-Externals |
| 11 | `phase11.cmake` | `compile_options` von Bibliotheken und Quellpakete |

### 7.2 Test-Flags

Nach erfolgreichem Test setzt jede Phase ein Cache-Flag, `PHASE1_TEST_PASSED` bis `PHASE11_TEST_PASSED`:

```cmake
set(PHASE1_TEST_PASSED TRUE CACHE BOOL "Phase 1 Test passed" FORCE)
```

### 7.3 Aktivieren

```bash
# Im CMakeCraft-Repo: Preset (Ninja Clang Debug + RUN_BUILD_SYSTEM_TESTS=ON)
cmake --preset craft-selftest

# Allgemein
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=ON
```

In Konsumenten-Projekten sind die Phasentests nur als Smoke-Check nach einem Snapshot-Sync nötig.

### 7.4 Einzelne Phase testen

```bash
cmake --preset craft-selftest -DTEST_PHASE=4
```

---

## 8. Verzeichnisstruktur

```
CMakeCraft/
├── CMakeLists.txt              ← Dünnfassung (Diese Datei)
├── CMakeCraft.cmake            ← Einstieg des Build-Systems
├── CMakeCraftPackage.cmake     ← eigenständig: vorgebaute Pakete beziehen und verteilen
├── CMakePresets.json           ← u. a. Preset craft-selftest
├── Solution.json               ← Projekt-Konfiguration (Demo-Solution)
├── cmake/                      ← = CMAKECRAFT_DIR
│   ├── core/                   ← Phase 1: Core-Module
│   │   ├── Errors.cmake
│   │   ├── Debug.cmake
│   │   ├── Json.cmake
│   │   ├── Validation.cmake
│   │   ├── Context.cmake
│   │   ├── SourceCollect.cmake
│   │   ├── OutputDirs.cmake
│   │   ├── Warnings.cmake
│   │   ├── CompilerOptions.cmake
│   │   └── Configurations.cmake
│   ├── project/                ← Phase 2–4, 7, 8, 10, 11: Projekt-Module
│   │   ├── Solution.cmake
│   │   ├── Libraries.cmake, LibraryCollect.cmake, LibraryCreate.cmake
│   │   ├── Executables.cmake, ExecutableCollect.cmake, ExecutableCreate.cmake
│   │   ├── Externals.cmake
│   │   ├── Apps.cmake, AppCollect.cmake, AppCreate.cmake
│   │   ├── Packages.cmake, PackageBuild.cmake, SourcePackage.cmake
│   │   └── Tests.cmake, TestCollect.cmake, TestCreate.cmake
│   ├── externals/              ← Externals-System (Phase 5, 6, 9, 10)
│   │   ├── Orchestrator.cmake
│   │   ├── core/Fetch.cmake
│   │   ├── local/Attach.cmake
│   │   ├── fetched/Handler.cmake
│   │   ├── system/Handler.cmake, PathResolver.cmake, packages/
│   │   ├── archive/Handler.cmake
│   │   ├── hooks/HookLoader.cmake, prefetch/, postfetch/
│   │   ├── registry/Targets.cmake
│   │   └── includes/           ← Include.cmake pro lokalem External
│   │       ├── bass/
│   │       ├── doctest/
│   │       ├── glad/
│   │       └── lua54/
│   └── buildSystemTest/        ← Build-System-Tests
│       ├── README.md
│       └── phase1.cmake … phase11.cmake
├── externals/                  ← Lokale Externals der Demo-Solution
│   ├── bass/
│   ├── calcext/
│   ├── doctest/
│   ├── glad/
│   └── lua54/
├── projects/                   ← Demo-Projekte
│   ├── apps/
│   ├── demos/
│   └── tests/
└── templates/                  ← Vorlagen (App, Source.cmake, Konsumenten-Bootstrap)
```

---

## 9. Best Practices

### 9.1 Keine direkten message()-Aufrufe

```cmake
# ❌ Falsch
message(STATUS "Loading configuration...")

# ✅ Richtig
dbg(${DBG_COMMON} "Loading configuration..." ID CMAKE_MAIN)
```

### 9.2 Fehler über Errors-Modul

```cmake
# ❌ Falsch
message(FATAL_ERROR "Something went wrong")

# ✅ Richtig
cmake_fatal("E001" "Something went wrong")
```

### 9.3 Module nur über `${CMAKECRAFT_DIR}` laden

```cmake
# ✅ Richtig — funktioniert, wo immer CMakeCraft liegt
include("${CMAKECRAFT_DIR}/project/Libraries.cmake")

# ❌ Falsch — koppelt an den Ort des Projekts
include(cmake/project/Libraries.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/project/Libraries.cmake)
```

Die Reihenfolge der Pipelines legt `CMakeCraft.cmake` fest; ein Projekt lädt keine Module selbst.

### 9.4 Variablen aufräumen

```cmake
# Am Ende der Datei
unset(_sol_name)
unset(_sol_version)
```

### 9.5 Guard für mehrfaches Include

```cmake
# In jedem Modul
include_guard(GLOBAL)
```

`CMakeCraft.cmake` selbst schützt sich mit `CMAKECRAFT_INCLUDED`.

---

## 10. Fehlerbehebung

### 10.1 CMakeCraft.cmake nicht gefunden

```
CMake Error at CMakeLists.txt:XX (include):
  include could not find requested file:
    <pfad>/CMakeCraft.cmake
```

**Lösung:** Pfad im `include()` der Projekt-`CMakeLists.txt` prüfen (Snapshot, `.externals/cmakecraft/<version>/`
oder `CMAKECRAFT_LOCAL_DIR`).

### 10.2 E005: keine project()-Zeile

```
[E005] <pfad>/CMakeLists.txt has no project() line. Add 'project(<Name> LANGUAGES NONE)' directly after cmake_minimum_required() - name and version still come from Solution.json. Then configure with --fresh.
```

**Lösung:** `project(<Name> LANGUAGES NONE)` direkt nach `cmake_minimum_required()` einfügen, dann mit `--fresh`
konfigurieren.

### 10.3 Solution.json fehlt

```
[E002] Solution.json not found: /path/to/project/Solution.json
```

**Lösung:** `Solution.json` im Projekt-Root erstellen.

### 10.4 Library nicht gefunden beim Linken

```
[E101] Dependency 'CoreLib' for 'MyApp' does not exist
```

**Lösung:** Prüfen, dass die Library unter `libraries` in `Solution.json` steht und der Name stimmt (auch ein
`BUILD_ONLY`, das sie auslässt, führt hierher).

### 10.5 External nicht gefunden

```
[E010] External 'glfw' not defined in externals block
```

**Lösung:** External in `Solution.json` unter `externals` definieren.

### 10.6 Keine Debug-Ausgaben

**Lösung:** `DEBUG_MESSAGES` darf nicht `OFF` sein:
```bash
cmake -B build -DDEBUG_MESSAGES=ON
```

### 10.7 Qt6 nicht gefunden

```
Could not find a package configuration file provided by "Qt6"
```

**Lösung:** `CMAKE_PREFIX_PATH` setzen:
```bash
cmake -B build -DCMAKE_PREFIX_PATH=/path/to/Qt/6.6.0/gcc_64
```

---

## 11. Siehe auch

### Core-Module (Phase 1)

- [Errors.md](core/Errors.md)
- [Debug.md](core/Debug.md)
- [Json.md](core/Json.md)
- [Validation.md](core/Validation.md)
- [Context.md](core/Context.md)
- [SourceCollect.md](core/SourceCollect.md)
- [OutputDirs.md](core/OutputDirs.md)
- [Warnings.md](core/Warnings.md)
- [CompilerOptions.md](core/CompilerOptions.md)

### Project-Module

- [Solution.md](project/Solution.md)
- [Libraries.md](project/Libraries.md)
- [Executables.md](project/Executables.md)
- [Externals.md](project/Externals.md)
- [Apps.md](project/Apps.md)
- [Packages.md](project/Packages.md)
- [Tests.md](project/Tests.md)

### Build-System-Tests

- [buildSystemTest_README.md](buildSystemTest/buildSystemTest_README.md)

### Referenzen

- [Solution_Schema.md](../references/Solution_Schema.md) — JSON-Schema
- [Externals.md](../references/Externals.md) — External Libraries
- [CMakePresets.md](../references/CMakePresets.md) — Preset-Konfiguration
- [Neues_Projekt_Guide.md](../userguides/Neues_Projekt_Guide.md) — CMakeCraft in ein Projekt einbinden

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.0.2** | **2026-11-09** | **An den Code angeglichen: Einstieg `CMakeCraft.cmake` (selbst-lokalisierend, `CMAKECRAFT_DIR`), `CMakeLists.txt` als Dünnfassung mit Pflichtzeile `project()`; Ausführungsreihenfolge Externals → Libraries → Executables → Apps → Packages → Tests; Phasen 1–11 und Phasentests 1–11; `RUN_BUILD_SYSTEM_TESTS` Default `OFF`, Preset `craft-selftest`; `BUILD_TESTS`, Debug-Level, Debug-IDs, Verzeichnisbaum und Fehlermeldungen (E005, E101, E010) wie im Code** |
| 1.0.1 | 2026-10-09 | CMakeCraft v0.10.0: Phase 10 (Packages) und Phasentest 10 nachgetragen; CMake-Minimum 3.26 |
| 1.0.0 | 2025-12-26 | Release 1 (aus newCMake übernommen, `2e00db7`) |
| 0.5.0 | 2025-12-15 | Blueprint v0.5.0 Format; alle 9 Phasen dokumentiert; Externals-Pipeline hinzugefügt; Tests-Pipeline hinzugefügt |
| 0.1.1 | 2025-12-07 | Libraries.cmake hinzugefügt, SourceCollect.cmake in Core |
| 0.1.0 | 2025-12-05 | Initial: Clean Start mit Debug-System |
