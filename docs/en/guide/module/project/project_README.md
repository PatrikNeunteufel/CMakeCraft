# Project — Project Pipeline Modules

> **Version:** 1.0.0  
> **Date:** 2025-12-17  
> **Language:** English  
> **German:** [README.md](../../../../de/guide/module/project/project_README.md)

---

## Quick Start

**Creating an executable?**
1. [Executables.md](Executables.md) — Pipeline overview
2. [ExecutableCollect.md](ExecutableCollect.md) — JSON parsing
3. [ExecutableCreate.md](ExecutableCreate.md) — Target creation

**Creating a library?**
1. [Libraries.md](Libraries.md) — Pipeline overview
2. [LibraryCollect.md](LibraryCollect.md) — JSON parsing
3. [LibraryCreate.md](LibraryCreate.md) — Target creation

**Creating an app container?** (Phase 8)
1. [Apps.md](Apps.md) — Pipeline overview
2. [AppCollect.md](AppCollect.md) — JSON parsing
3. [AppCreate.md](AppCreate.md) — Target creation (Core/Runner/Tests)

**Defining tests?**
1. [Tests.md](Tests.md) — Test pipeline
2. [TestCollect.md](TestCollect.md) — JSON parsing
3. [TestCreate.md](TestCreate.md) — Test target creation

**Building a package?** (Phase 10)
1. [Packages.md](Packages.md) — Block `packages` → target `package_<name>`
2. [PackageBuild.md](PackageBuild.md) — Build-time script (folder, zip, checksum)
3. [SourcePackage.md](SourcePackage.md) — Source package of a library with a plain `CMakeLists.txt` (Phase 11)

---

## Overview

The project modules form the main pipeline of the build system. They process `Solution.json` and create CMake targets for executables, libraries, tests and app containers.

### Pipeline Architecture

```
Solution.json
     │
     ▼
Solution.cmake          ← Loads and parses Solution.json
     │
     ├── Externals.cmake      ← External dependencies
     │
     ├── Libraries.cmake      ← Library pipeline
     │   ├── LibraryCollect   → JSON → Context
     │   └── LibraryCreate    → Context → Target
     │
     ├── Executables.cmake    ← Executable pipeline
     │   ├── ExecutableCollect → JSON → Context
     │   └── ExecutableCreate  → Context → Target
     │
     ├── Apps.cmake           ← App container pipeline (Phase 8)
     │   ├── AppCollect       → JSON → Context
     │   └── AppCreate        → Core/Runner/Tests Targets
     │
     ├── Packages.cmake       ← Package pipeline (Phase 10)
     │   ├── SourcePackage    → Source package of a library (Phase 11)
     │   └── PackageBuild     → Build-time script (cmake -P)
     │
     └── Tests.cmake          ← Test pipeline
         ├── TestCollect      → JSON → Context
         └── TestCreate       → Context → Test Target
```

---

## Files

### Solution & Externals

| File | Phase | Description |
|------|-------|-------------|
| [Solution.md](Solution.md) | 2 | Load and parse Solution.json |
| [Externals.md](Externals.md) | 5-6 | Orchestrate external integration |

### Executables (Phase 3)

| File | Description |
|------|-------------|
| [Executables.md](Executables.md) | Executable pipeline orchestrator |
| [ExecutableCollect.md](ExecutableCollect.md) | JSON parsing → context |
| [ExecutableCreate.md](ExecutableCreate.md) | Context → CMake target |

### Libraries (Phase 4)

| File | Description |
|------|-------------|
| [Libraries.md](Libraries.md) | Library pipeline orchestrator |
| [LibraryCollect.md](LibraryCollect.md) | JSON parsing → context |
| [LibraryCreate.md](LibraryCreate.md) | Context → CMake target |

### Tests (Phase 7)

| File | Description |
|------|-------------|
| [Tests.md](Tests.md) | Test pipeline orchestrator |
| [TestCollect.md](TestCollect.md) | JSON parsing → context |
| [TestCreate.md](TestCreate.md) | Context → test target |

### App Containers (Phase 8)

| File | Description |
|------|-------------|
| [Apps.md](Apps.md) | App container pipeline orchestrator |
| [AppCollect.md](AppCollect.md) | JSON parsing → context |
| [AppCreate.md](AppCreate.md) | Context → Core/Runner/Tests targets |

### Packages (Phase 10)

| File | Description |
|------|-------------|
| [Packages.md](Packages.md) | Block `packages` → target `package_<name>` (manifest, version file) |
| [PackageBuild.md](PackageBuild.md) | Build-time script: package folder, zip archive, SHA256 |
| [SourcePackage.md](SourcePackage.md) | Source package of a library: generated plain `CMakeLists.txt`, carried-over local externals, `SHA256SUMS` |

---

## Pipeline Pattern

All pipelines follow the same Collect/Create pattern:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   JSON      │ ──▶ │   Context   │ ──▶ │   Target    │
│ (Solution)  │     │  (Collect)  │     │  (Create)   │
└─────────────┘     └─────────────┘     └─────────────┘
```

| Phase | Orchestrator | Collect | Create |
|-------|--------------|---------|--------|
| 3 | Executables.cmake | ExecutableCollect | ExecutableCreate |
| 4 | Libraries.cmake | LibraryCollect | LibraryCreate |
| 7 | Tests.cmake | TestCollect | TestCreate |
| 8 | Apps.cmake | AppCollect | AppCreate |

---

## App Container vs. Executable

| Aspect | Executable | App container |
|--------|------------|---------------|
| **Targets** | 1 (executable) | 3+ (Core, Runner, Tests) |
| **Testability** | Limited | Complete (Core testable) |
| **Structure** | Flat | Hierarchical (src/, main/, tests/) |
| **Use case** | Simple tools | Complex applications |

---

## See Also

- [../README.md](../README.md) — Module overview
- [../core/README.md](../core/core_README.md) — Core modules
- [../../references/Solution_Schema.md](../../references/Solution_Schema.md) — JSON schema
- [../../projects/buildsystem/concepts/AppContainer_Concept.md](../../../konzepte/abgeschlossen/AppContainer_Concept.md) — App container concept
