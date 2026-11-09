# Core — Core Modules

> **Version:** 1.0.0  
> **Date:** 2025-12-17  
> **Language:** English  
> **German:** [core_README.md](../../../../de/guide/module/core/core_README.md)

---

## Quick Start

**Report errors?**
1. [Errors.md](Errors.md) — `cmake_fatal()`, `cmake_warn()`

**Debug output?**
1. [Debug.md](Debug.md) — `dbg()`, debug levels

**Parse JSON?**
1. [Json.md](Json.md) — `_json_get_string()`, `_json_get_number()`, etc.

**Context pattern?**
1. [Context.md](Context.md) — `ctx_create()`, `ctx_set()`, `ctx_get()`

---

## Overview

The core modules form the foundation of the build system. They are independent of the project pipeline and are used by all other modules.

### Dependency Hierarchy

```
Errors.cmake          ← No dependencies (base)
     │
     ▼
Debug.cmake           ← Uses Errors
     │
     ▼
Context.cmake         ← Uses Debug
Json.cmake            ← No dependencies
Validation.cmake      ← Uses Json, Errors
     │
     ▼
OutputDirs.cmake      ← Uses Debug
Warnings.cmake        ← Uses Debug
CompilerOptions.cmake ← Uses Debug, Json
SourceCollect.cmake   ← Uses Errors, Debug
```

---

## Files

| File | Description |
|------|-------------|
| [Errors.md](Errors.md) | Centralized error messages (`cmake_fatal`, `cmake_warn`) |
| [Debug.md](Debug.md) | Debug output system with levels and context |
| [Context.md](Context.md) | Global build context (GLOBAL PROPERTY pattern) |
| [Json.md](Json.md) | JSON parsing functions |
| [Validation.md](Validation.md) | Schema validation for Solution.json |
| [OutputDirs.md](OutputDirs.md) | Configure output directories |
| [Warnings.md](Warnings.md) | Configure compiler warnings |
| [CompilerOptions.md](CompilerOptions.md) | Compiler options (standard, optimization) |
| [SourceCollect.md](SourceCollect.md) | Source file collection (GLOB/explicit) |

---

## Module Categories

### Error Handling & Debugging

| Module | Functions |
|--------|-----------|
| **Errors** | `cmake_fatal()`, `cmake_warn()` |
| **Debug** | `dbg()`, `dbg_init()`, `enddbgblock()`, `dbgspace()` |

### Data Structures

| Module | Functions |
|--------|-----------|
| **Context** | `ctx_create()`, `ctx_set()`, `ctx_get()`, `ctx_dump()` |
| **Json** | `_json_get_string()`, `_json_get_number()`, `_json_get_bool_from_key()`, etc. |
| **Validation** | Schema check, required field validation |

### Build Configuration

| Module | Functions |
|--------|-----------|
| **OutputDirs** | `setup_output_dirs()` |
| **Warnings** | `apply_warnings()` |
| **CompilerOptions** | `apply_compiler_options()` |
| **SourceCollect** | `collect_sources()`, `collect_files()` |

---

## Debug Levels

The debug system uses 5 levels:

| Level | Constant | Usage |
|-------|----------|-------|
| 1 | `DBG_OFTEN` | Phase start/end |
| 2 | `DBG_COMMON` | Important steps |
| 3 | `DBG_NORMAL` | Details |
| 4 | `DBG_RARE` | Rarely needed |
| 5 | `DBG_ULTRA_RARE` | Loop iterations |

```cmake
dbg(${DBG_COMMON} "Processing ${_name}" ID MY_MODULE)
```

---

## Error Codes

Core modules use the ranges:

| Range | Codes | Module |
|-------|-------|--------|
| E0xx | E001-E099 | General (Errors, Validation) |
| E1xx | E100-E199 | Context, SourceCollect |
| W0xx | W001-W099 | Warnings (Errors) |
| W1xx | W100-W199 | Warnings (SourceCollect, Warnings) |

→ Complete list: [../../references/ErrorCodes.md](../../references/ErrorCodes.md)

---

## See Also

- [../README.md](../README.md) — module overview
- [../project/project_README.md](../project/project_README.md) — project modules
- [../../references/ErrorCodes.md](../../references/ErrorCodes.md) — error code reference
- [../../projects/buildsystem/standards/Guidelines.md](../../../konzepte/Guidelines.md) — CMake coding standards
