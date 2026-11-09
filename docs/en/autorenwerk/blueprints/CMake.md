# CMake — Standard for CMake Scripts

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Blueprint  
> **Status:** In Development  
> **Based on:** Blueprint v0.5  
> **Target Audience:** Build system developers  
> **Scope:** All .cmake files  
> **Language:** English  
> **German:** [CMake.md](../../../de/autorenwerk/blueprints/CMake.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Module Categories](#2-module-categories)
3. [File Header](#3-file-header)
4. [Naming Conventions](#4-naming-conventions)
5. [Function Documentation](#5-function-documentation)
6. [Code Structure](#6-code-structure)
7. [Error Handling](#7-error-handling)
8. [Versioning](#8-versioning)
9. [Best Practices](#9-best-practices)
10. [Review Checklist](#10-review-checklist)
11. [See Also](#11-see-also)
12. [Changelog](#changelog)

---

## 1. Overview

This blueprint defines the **binding structure** for all CMake modules (.cmake files) in the CMake Architecture project.

### Goals

- Uniform module structure
- Consistent in-code documentation
- Clear naming conventions
- Standardized error handling

### Delimitation

| Document | Focus |
|----------|-------|
| **CMake Blueprint** | Structure of .cmake files |
| **CMake Standard** | General CMake conventions |
| **ModuleDoc Blueprint** | Structure of the module documentation |

---

## 2. Module Categories

### 2.1 Categories and Paths

| Category | Path | Description |
|-----------|------|--------------|
| **Core** | `cmake/core/` | Basic building blocks (Errors, Debug, Context, ...) |
| **Project** | `cmake/project/` | Pipelines (Executables, Libraries, Tests) |
| **Externals** | `cmake/externals/` | External handling (Orchestrator, Fetch, ...) |
| **BuildSystemTest** | `cmake/buildSystemTest/` | Internal build system tests |

### 2.2 Module Types

| Type | Description | Examples |
|-----|--------------|-----------|
| **Utility** | Reusable helper functions | Errors.cmake, Json.cmake |
| **Pipeline** | Processes Solution.json | Executables.cmake |
| **Orchestrator** | Coordinates other modules | Orchestrator.cmake |
| **Config** | Configures targets | Warnings.cmake |
| **Hook** | Customization for externals | PreFetch/*.cmake |
| **Include** | Setup for local externals | externals/*/Include.cmake |

---

## 3. File Header

### 3.1 Required Header

Every .cmake file starts with this header:

```cmake
# cmake/[path]/[ModuleName].cmake
# ==============================
# [Short description of the module]
#
# Version: X.Y.Z
# Date:    YYYY-MM-DD
# Status:  [Development | Stable | Deprecated]
# Author:  CMake Architecture Team
#
# Dependencies:
#   - [Dependency 1]
#   - [Dependency 2]
#   - None (base module)
#
# Provides:
#   - function_1()
#   - function_2()
#   - MACRO_NAME
#
# Used by:
#   - [Module that uses this one]
#   - [Another module]
```

### 3.2 Header Fields

| Field | Required | Description |
|------|---------|--------------|
| Path comment | ✓ | Full path to the module |
| Short description | ✓ | One line on what the module does |
| Version | ✓ | SemVer format |
| Date | ✓ | ISO 8601 |
| Status | ✓ | Development / Stable / Deprecated |
| Author | ✓ | Team or person |
| Dependencies | ✓ | List or "None" |
| Provides | ✓ | Public API |
| Used by | Optional | Where is this module used? |

### 3.3 Include Guard

Always after the header:

```cmake
include_guard(GLOBAL)
```

---

## 4. Naming Conventions

### 4.1 File Names

| Category | Pattern | Example |
|-----------|--------|----------|
| Core | `[Name].cmake` | `Context.cmake` |
| Project | `[Name].cmake` | `Executables.cmake` |
| Pipeline | `[Type][Action].cmake` | `ExecutableCollect.cmake` |
| Hook | `[external].cmake` | `imgui.cmake` |
| Include | `Include.cmake` | `externals/bass/Include.cmake` |

### 4.2 Function Names

| Type | Pattern | Example |
|-----|--------|----------|
| Public | `modul_action()` | `ctx_create()`, `cmake_fatal()` |
| Internal | `_modul_action()` | `_json_parse_object()` |
| Pipeline | `pipeline_action()` | `executables_process()` |

### 4.3 Variables

| Scope | Pattern | Example |
|-------|--------|----------|
| Local | `_snake_case` | `_result`, `_temp_list` |
| Cache | `UPPER_SNAKE_CASE` | `DEBUG_CONTEXT` |
| Global Property | `${PREFIX}_${KEY}` | `EXE_MyApp_NAME` |
| Output | `OUT_VAR` (parameter) | `ctx_get(... OUT_VAR)` |

---

## 5. Function Documentation

### 5.1 Documentation Block Format

Every public function gets a documentation block:

```cmake
# ============================================================================
# function_name - Short description
# ============================================================================
#[[
    function_name(PARAM1 PARAM2 [OPTIONAL])
    
    Detailed description of what the function does.
    
    Parameters:
        PARAM1   - Mandatory: Description
        PARAM2   - Mandatory: Description
        OPTIONAL - Optional: Description (Default: value)
    
    Returns:
        What the function returns (variable, property, etc.)
    
    Example:
        function_name("value1" "value2")
        function_name("value1" "value2" "optional")
    
    Errors:
        E0xxx - If condition is not met
    
    Since: v0.1.0
]]
function(function_name PARAM1 PARAM2)
    # Implementation
endfunction()
```

### 5.2 Separator Lines

Always a visual separation between functions:

```cmake
# ============================================================================
# function_one - Description
# ============================================================================
function(function_one)
endfunction()

# ============================================================================
# function_two - Description
# ============================================================================
function(function_two)
endfunction()
```

---

## 6. Code Structure

### 6.1 Module Layout

```cmake
# 1. Header (required)
# cmake/core/Example.cmake
# ========================
# ...

# 2. Include Guard (required)
include_guard(GLOBAL)

# 3. Cache variables (optional)
set(EXAMPLE_DEBUG OFF CACHE BOOL "Enable debug output")

# 4. Dependencies (optional)
include("${CMAKECRAFT_DIR}/core/Errors.cmake")

# 5. Private Helpers (optional)
function(_example_helper)
endfunction()

# 6. Public API (required)
function(example_main)
endfunction()
```

### 6.2 Indentation

- **4 spaces**, no tabs
- Indent nested blocks

```cmake
function(example)
    if(CONDITION)
        foreach(item IN LISTS items)
            message(STATUS "${item}")
        endforeach()
    endif()
endfunction()
```

---

## 7. Error Handling

### 7.1 Using the Error Functions

Always use the Errors module:

```cmake
include("${CMAKECRAFT_DIR}/core/Errors.cmake")

# Fatal error (aborts)
cmake_fatal(E0501 "Executable '${name}' not found")

# Warning (continues)
cmake_warn(W0201 "Deprecated option '${opt}' used")
```

### 7.2 Error Code Categories

| Prefix | Category |
|--------|-----------|
| E01xx | Core |
| E02xx | Validation |
| E03xx | Output |
| E04xx | Warnings |
| E05xx | Executable |
| E06xx | Library |
| E07xx | Test |
| E20xx | External |

---

## 8. Versioning

### 8.1 Semantic Versioning

Modules use SemVer:

| Part | Meaning | When to increment? |
|------|-----------|---------------|
| MAJOR | Breaking changes | API change, parameter change |
| MINOR | New features | New function, new parameter |
| PATCH | Bug fixes | Bug fix, optimization |

### 8.2 Keep the Version in the Header Up to Date

On every change:
1. Increment the version in the header
2. Update the date
3. Adjust the documentation (if necessary)

### 8.3 Shared Major Number from CMakeCraft v2.0.0

A module's version is independent of the CMakeCraft version (many modules are already at 1.x). The first major
release of CMakeCraft is **v2.0.0** (not v1.0.0); with it, all `.cmake` files and all documents go to 2.0.0. From
then on product, modules and docs share the major number; minor and patch count per file. Rule:
[Doku_Standard.md](../standards/Doku_Standard.md) §2.

---

## 9. Best Practices

### 9.1 Do's ✓

| Rule | Example |
|-------|----------|
| GLOBAL PROPERTY for context | `set_property(GLOBAL PROPERTY ...)` |
| Error handling with Errors.cmake | `cmake_fatal(E0501 "...")` |
| Documentation for every public function | See section 5 |
| Validate early | Check required parameters at the start |
| Meaningful variable names | `_executable_name` instead of `_n` |

### 9.2 Don'ts ✗

| Avoid | Reason | Instead |
|-----------|-------|-------------|
| `PARENT_SCOPE` for context | Does not work across >2 levels | GLOBAL PROPERTY |
| Hard-coded paths | Not portable | `CMAKE_CURRENT_*` |
| `message(FATAL_ERROR)` directly | Inconsistent messages | `cmake_fatal()` |
| Global variables | Side effects | Context pattern |
| Undocumented functions | Unmaintainable | Documentation block |

---

## 10. Review Checklist

Check before merging a CMake module:

**Header:**
- [ ] Required header complete
- [ ] Version up to date
- [ ] Dependencies correct

**Code:**
- [ ] `include_guard(GLOBAL)` present
- [ ] Naming conventions followed
- [ ] All public functions documented
- [ ] Error handling via Errors.cmake

**Quality:**
- [ ] No hard-coded paths
- [ ] No PARENT_SCOPE for context data
- [ ] Tests present (if possible)

---

## 11. See Also

- [Cpp.md](Cpp.md) — C++/C file structure
- [ModuleDoc.md](ModuleDoc.md) — Documentation for modules
- [CMake.md](../standards/CMake_Standard.md) — CMake coding standard
- [ErrorCodes.md](../../guide/references/ErrorCodes.md) — All error codes

---

## Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: modules are included via `${CMAKECRAFT_DIR}`, never via relative `cmake/…` paths (§ 6.1, § 7.1; `CMakeCraft.cmake`:133, :149, `cmake/project/Apps.cmake`:36); § 8.3 shared major number from CMakeCraft v2.0.0 (decision V2 a)** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.0 | 2025-12-13 | New: table of contents with anchors, error handling categories, extended best practices |
| 0.1.0 | 2025-12-03 | Initial (as CMake_Blueprint) |
