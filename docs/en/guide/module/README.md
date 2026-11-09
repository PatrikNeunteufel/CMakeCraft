# Modules — CMake Module Documentation

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Language:** English  
> **German:** [README.md](../../../de/guide/module/README.md)

---

## Quick Start

**Want to understand the build system?** All CMake modules are documented here.

Start with:
1. [core/](core/core_README.md) — core modules (Errors, Context, Debug)
2. [project/](project/project_README.md) — project pipeline (Executables, Libraries, Tests)

**Managing externals?**
1. [externals/](externals/README.md) — external management system

---

## Overview

The module documentation describes all CMake modules of the build system. Each module has a standardized documentation following the [ModuleDoc Blueprint](../../autorenwerk/blueprints/ModuleDoc.md).

### Module Categories

| Category | Description | Modules |
|----------|-------------|---------|
| **Core** | Basic functions | 10 modules |
| **Project** | Project creation | 17 modules |
| **Externals** | Dependency management | 9 modules + hooks, includes, system packages |

---

## Files

| File | Description |
|------|-------------|
| [CMakeLists.md](CMakeLists.md) | Entry point `CMakeCraft.cmake` and thin `CMakeLists.txt` |
| [CMakeCraftPackage.md](CMakeCraftPackage.md) | Standalone file in the repo root: fetch and deploy prebuilt packages |

---

## Subfolders

| Folder | Description |
|--------|-------------|
| [buildSystemTest/](buildSystemTest/buildSystemTest_README.md) | Phase test documentation (phase 1–11) |
| [core/](core/core_README.md) | Core modules (Errors, Debug, Context, etc.) |
| [externals/](externals/README.md) | External management system |
| [project/](project/project_README.md) | Project pipeline (Executables, Libraries, Apps, Tests) |

---

## Module Overview

### Core Modules (Phase 1)

```
core/
├── Errors.cmake        → Centralized error messages
├── Debug.cmake         → Debug output system
├── Context.cmake       → Global build context
├── Json.cmake          → JSON parsing
├── Validation.cmake    → Schema validation
├── OutputDirs.cmake    → Output directories
├── Warnings.cmake      → Compiler warnings
├── CompilerOptions.cmake → Compiler options
├── Configurations.cmake → Testing configuration
└── SourceCollect.cmake → Source collection
```

### Project Modules (Phase 2–4, 7, 8, 10, 11)

```
project/
├── Solution.cmake           → Project initialization
├── Executables.cmake        → Executable pipeline
├── ExecutableCollect.cmake  → Executable discovery
├── ExecutableCreate.cmake   → Executable creation
├── Libraries.cmake          → Library pipeline
├── LibraryCollect.cmake     → Library discovery
├── LibraryCreate.cmake      → Library creation
├── Tests.cmake              → Test pipeline
├── TestCollect.cmake        → Test discovery
├── TestCreate.cmake         → Test creation
├── Apps.cmake               → App container pipeline (phase 8)
├── AppCollect.cmake         → App discovery
├── AppCreate.cmake          → App creation (Core/Runner/Tests)
├── Externals.cmake          → Externals integration
├── Packages.cmake           → Package pipeline (phase 10)
├── SourcePackage.cmake      → Source package of a library (phase 11)
└── PackageBuild.cmake       → Build-time script of the package targets
```

### Externals Modules (Phase 5, 6, 9, 10)

```
externals/
├── Orchestrator.cmake       → Main orchestration
├── core/Fetch.cmake         → Git fetch
├── fetched/Handler.cmake    → Fetched library handler
├── archive/Handler.cmake    → Archive external handler (prebuilt packages)
├── local/Attach.cmake       → Local library attach
├── system/Handler.cmake     → System external handler (find_package)
├── system/PathResolver.cmake → Search paths of system externals
├── system/packages/         → Package hooks (Qt6, Boost)
├── registry/Targets.cmake   → Target registry
├── hooks/HookLoader.cmake   → Hook system
└── includes/                → Library include files
```

---

## See Also

- [../blueprints/ModuleDoc.md](../../autorenwerk/blueprints/ModuleDoc.md) — ModuleDoc Blueprint
- [../references/ErrorCodes.md](../references/ErrorCodes.md) — error codes

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: phase tests 1–11; module counts (core 10 with `Configurations.cmake`, project 17); phases of the module groups; externals tree with `local/` and `system/`** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
