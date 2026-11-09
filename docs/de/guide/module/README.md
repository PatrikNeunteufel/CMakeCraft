# Module — CMake-Modul-Dokumentation

> **Version:** 1.0.1  
> **Datum:** 2026-11-09  
> **Sprache:** Deutsch  
> **English:** [README.md](../../../en/guide/module/README.md)

---

## Quick-Start

**Das Build-System verstehen?** Hier sind alle CMake-Module dokumentiert.

Starte mit:
1. [core/](core/core_README.md) — Kern-Module (Errors, Context, Debug)
2. [project/](project/project_README.md) — Projekt-Pipeline (Executables, Libraries, Tests)

**Externes verwalten?**
1. [externals/](externals/README.md) — External-Management-System

---

## Übersicht

Die Modul-Dokumentation beschreibt alle CMake-Module des Build-Systems. Jedes Modul hat eine standardisierte Dokumentation nach dem [ModuleDoc Blueprint](../../autorenwerk/blueprints/ModuleDoc.md).

### Modul-Kategorien

| Kategorie | Beschreibung | Module |
|-----------|--------------|--------|
| **Core** | Grundlegende Funktionen | 10 Module |
| **Project** | Projekt-Erstellung | 17 Module |
| **Externals** | Dependency-Management | 9 Module + Hooks, Includes, Systempakete |

---

## Dateien

| Datei | Beschreibung |
|-------|--------------|
| [CMakeLists.md](CMakeLists.md) | Einstieg `CMakeCraft.cmake` und Dünnfassung `CMakeLists.txt` |
| [CMakeCraftPackage.md](CMakeCraftPackage.md) | Eigenständige Datei im Repo-Root: vorgebaute Pakete beziehen und ausliefern |

---

## Unterordner

| Ordner | Beschreibung |
|--------|--------------|
| [buildSystemTest/](buildSystemTest/buildSystemTest_README.md) | Phasen-Testdokumentation (Phase 1–11) |
| [core/](core/core_README.md) | Kern-Module (Errors, Debug, Context, etc.) |
| [externals/](externals/README.md) | External-Management-System |
| [project/](project/project_README.md) | Projekt-Pipeline (Executables, Libraries, Apps, Tests) |

---

## Modul-Übersicht

### Core-Module (Phase 1)

```
core/
├── Errors.cmake        → Zentralisierte Fehlermeldungen
├── Debug.cmake         → Debug-Output-System
├── Context.cmake       → Globaler Build-Context
├── Json.cmake          → JSON-Parsing
├── Validation.cmake    → Schema-Validierung
├── OutputDirs.cmake    → Output-Verzeichnisse
├── Warnings.cmake      → Compiler-Warnungen
├── CompilerOptions.cmake → Compiler-Optionen
├── Configurations.cmake → Konfiguration Testing
└── SourceCollect.cmake → Source-Sammlung
```

### Project-Module (Phase 2–4, 7, 8, 10, 11)

```
project/
├── Solution.cmake           → Projekt-Initialisierung
├── Executables.cmake        → Executable-Pipeline
├── ExecutableCollect.cmake  → Executable-Discovery
├── ExecutableCreate.cmake   → Executable-Erstellung
├── Libraries.cmake          → Library-Pipeline
├── LibraryCollect.cmake     → Library-Discovery
├── LibraryCreate.cmake      → Library-Erstellung
├── Tests.cmake              → Test-Pipeline
├── TestCollect.cmake        → Test-Discovery
├── TestCreate.cmake         → Test-Erstellung
├── Apps.cmake               → App-Container-Pipeline (Phase 8)
├── AppCollect.cmake         → App-Discovery
├── AppCreate.cmake          → App-Erstellung (Core/Runner/Tests)
├── Externals.cmake          → Externals-Integration
├── Packages.cmake           → Package-Pipeline (Phase 10)
├── SourcePackage.cmake      → Quellpaket einer Bibliothek (Phase 11)
└── PackageBuild.cmake       → Build-Zeit-Skript der Package-Targets
```

### Externals-Module (Phase 5, 6, 9, 10)

```
externals/
├── Orchestrator.cmake       → Haupt-Orchestrierung
├── core/Fetch.cmake         → Git-Fetch
├── fetched/Handler.cmake    → Fetched-Library-Handler
├── archive/Handler.cmake    → Archive-External-Handler (vorgebaute Pakete)
├── local/Attach.cmake       → Local-Library-Attach
├── system/Handler.cmake     → System-External-Handler (find_package)
├── system/PathResolver.cmake → Suchpfade der System-Externals
├── system/packages/         → Paket-Hooks (Qt6, Boost)
├── registry/Targets.cmake   → Target-Registry
├── hooks/HookLoader.cmake   → Hook-System
└── includes/                → Library-Include-Files
```

---

## Siehe auch

- [../blueprints/ModuleDoc.md](../../autorenwerk/blueprints/ModuleDoc.md) — ModuleDoc Blueprint
- [../references/ErrorCodes.md](../references/ErrorCodes.md) — Fehlercodes

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **An den Code angeglichen: Phasentests 1–11; Modulzahlen (Core 10 mit `Configurations.cmake`, Project 17); Phasen der Modulgruppen; Externals-Baum mit `local/` und `system/`** |
| 1.0.0 | 2025-12-26 | Release 1 (aus newCMake übernommen, `2e00db7`) |
