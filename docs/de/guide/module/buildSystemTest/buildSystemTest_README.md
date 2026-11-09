# Build-System-Tests — Phasen-Testdokumentation

> **Version:** 1.0.1  
> **Datum:** 2026-11-09  
> **Sprache:** Deutsch  
> **English:** [buildSystemTest_README.md](../../../../en/guide/module/buildSystemTest/buildSystemTest_README.md)

---

## Quick-Start

**Build-System testen?**
```bash
cmake --preset craft-selftest                             # im CMakeCraft-Repo
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=ON                # allgemein
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=ON -DTEST_PHASE=8  # Nur Phase 8
```

**Einzelne Phase verstehen?**
- [Phase1_doc.md](Phase1_doc.md) — Core-Module
- [Phase8_doc.md](Phase8_doc.md) — App-Container (neu)

---

## Übersicht

Die Build-System-Tests validieren die korrekte Funktion aller CMake-Module. Jede Phase testet einen spezifischen Teil der Pipeline.

### Test-Architektur

```
CMakeCraft.cmake  (nach der Pipeline)
     │
     └── if(RUN_BUILD_SYSTEM_TESTS)          ← Default OFF
             │   foreach 1..11, gefiltert über TEST_PHASE
             │
             ├── phase1.cmake  → Core-Module
             ├── phase2.cmake  → Solution
             ├── phase3.cmake  → Executables
             ├── phase4.cmake  → Libraries
             ├── phase5.cmake  → Local Externals
             ├── phase6.cmake  → Git Externals
             ├── phase7.cmake  → Tests
             ├── phase8.cmake  → App-Container (neu)
             ├── phase9.cmake  → System Externals
             ├── phase10.cmake → Packages, Archive Externals
             └── phase11.cmake → compile_options je Library, Quellpakete

Dateien: cmake/buildSystemTest/phase<n>.cmake
```

---

## Dateien

| Datei | Phase | Beschreibung |
|-------|-------|--------------|
| [Phase1_doc.md](Phase1_doc.md) | 1 | Core-Module (Errors, Debug, Context, Json, etc.) |
| [Phase2_doc.md](Phase2_doc.md) | 2 | Solution.cmake, JSON-Loading |
| [Phase3_doc.md](Phase3_doc.md) | 3 | Executable-Pipeline |
| [Phase4_doc.md](Phase4_doc.md) | 4 | Library-Pipeline |
| [Phase5_doc.md](Phase5_doc.md) | 5 | Local Externals |
| [Phase6_doc.md](Phase6_doc.md) | 6 | Git Externals + Hooks |
| [Phase7_doc.md](Phase7_doc.md) | 7 | Test-Pipeline |
| [Phase8_doc.md](Phase8_doc.md) | 8 | App-Container-Pipeline |
| [Phase9_doc.md](Phase9_doc.md) | 9 | System Externals, Einstiegspunkt von Qt-GUI-Programmen |
| [Phase10_doc.md](Phase10_doc.md) | 10 | Packages, CMakeCraftPackage, Archive Externals |
| [Phase11_doc.md](Phase11_doc.md) | 11 | compile_options je Library, Quellpaket, E105, E106 |

---

## Phasen-Übersicht

| Phase | Status | Module | Tests |
|-------|--------|--------|-------|
| **1** | ✅ Stabil | Errors, Debug, Context, Json, Validation, OutputDirs, Warnings, CompilerOptions, SourceCollect | Modul-Verfügbarkeit, Funktions-Tests |
| **2** | ✅ Stabil | Solution | JSON-Loading, Properties |
| **3** | ✅ Stabil | Executables, ExecutableCollect, ExecutableCreate | Target-Erstellung, Linking |
| **4** | ✅ Stabil | Libraries, LibraryCollect, LibraryCreate | STATIC/SHARED, Dependencies |
| **5** | ✅ Stabil | Externals (Local) | Local-Attach, Include-Files |
| **6** | ✅ Stabil | Externals (Git) | FetchContent, Hooks, Caching |
| **7** | ✅ Stabil | Tests, TestCollect, TestCreate | Framework-Integration, CTest |
| **8** | ✅ In Entwicklung | Apps, AppCollect, AppCreate | Core/Runner/Tests Targets |
| **9** | ✅ Stabil | Externals (System), system/Handler, system/PathResolver, system/packages/Qt6 | Typ-Erkennung, Felder, Typ-Priorität, Package-Hooks, Einstiegspunkt von Qt-GUI-Programmen |
| **10** | ✅ Stabil | Packages, CMakeCraftPackage, archive/Handler | Package-Target, output_name/defines, Bezug über URL/Cache/Ausweichpfad, Anwenden auf Target |
| **11** | ✅ Stabil | LibraryCreate, SourcePackage, PackageBuild, CompilerOptions | compile_options am Ziel, erzeugtes CMakeLists.txt, Paket bauen, Bezieher ohne CMakeCraft bauen und ausführen, E105, E106 |

---

## Test-Flags

| Flag | Default | Beschreibung |
|------|---------|--------------|
| `RUN_BUILD_SYSTEM_TESTS` | OFF | Build-System-Tests aktivieren (im CMakeCraft-Repo: Preset `craft-selftest`) |
| `TEST_PHASE` | "" (alle) | Spezifische Phase(n) testen (`1`–`11`, Liste mit `;`); wirkt nur mit `RUN_BUILD_SYSTEM_TESTS=ON` |
| `BUILD_TESTS` | OFF | Projekt-Tests aktivieren (für Phase 7/8) |

### Beispiele

```bash
# Alle Phasen testen (im CMakeCraft-Repo)
cmake --preset craft-selftest

# Alle Phasen testen (allgemein)
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=ON

# Nur Phase 8 testen
cmake --preset craft-selftest -DTEST_PHASE=8

# Phase 7+8 mit Projekt-Tests
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=ON -DBUILD_TESTS=ON -DTEST_PHASE="7;8"

# Danach wieder ohne Phasentests (Cache-Wert zurücksetzen)
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=OFF
```

---

## Test-Output

Jede Phase gibt Debug-Output mit eigenem Tag:

```
-- [Phase8] === Phase 8 Test Start ===
-- [Phase8] Test 1: Apps array parsing...
-- [Phase8]   Found 1 app(s) in Solution.json
-- [Phase8] Test 3: App-Container targets...
-- [Phase8]   Core Library: DemoPlayer.Core
-- [Phase8]   Runner Executable: DemoPlayer
-- [Phase8] === Phase 8 Test PASSED ===
```

---

## Erfolgs-Flags

Jede Phase setzt ein Cache-Flag bei Erfolg:

| Phase | Flag |
|-------|------|
| 1 | `PHASE1_TEST_PASSED` |
| 2 | `PHASE2_TEST_PASSED` |
| 3 | `PHASE3_TEST_PASSED` |
| 4 | `PHASE4_TEST_PASSED` |
| 5 | `PHASE5_TEST_PASSED` |
| 6 | `PHASE6_TEST_PASSED` |
| 7 | `PHASE7_TEST_PASSED` |
| 8 | `PHASE8_TEST_PASSED` |
| 9 | `PHASE9_TEST_PASSED` |
| 10 | `PHASE10_TEST_PASSED` |
| 11 | `PHASE11_TEST_PASSED` |

---

## Siehe auch

- [../README.md](../README.md) — Modul-Übersicht
- [Implementation_Plan.md](../../../konzepte/abgeschlossen/Implementation_Plan.md) — Phasen-Planung
- [../../references/ErrorCodes.md](../../references/ErrorCodes.md) — Fehlercodes

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **An den Code angeglichen: `RUN_BUILD_SYSTEM_TESTS` Default `OFF`, Preset `craft-selftest`; Phasentests laufen aus `CMakeCraft.cmake`, Dateinamen `phase<n>.cmake` klein; `TEST_PHASE` wirkt nur zusammen mit `RUN_BUILD_SYSTEM_TESTS=ON`** |
| 1.0.0 | 2025-12-26 | Release 1 (aus newCMake übernommen, `2e00db7`) |
