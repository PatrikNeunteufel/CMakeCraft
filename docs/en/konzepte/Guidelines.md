# Guidelines — CMake Build System

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Standard  
> **Status:** Stable  
> **Target Audience:** Build System Developers  
> **Scope:** All CMake modules in `cmake/`  
> **Enforcement:** Code review, build system tests  
> **Language:** English  
> **German:** [Guidelines.md](../../de/konzepte/Guidelines.md)

This document contains coding conventions, style decisions and best practices for the implementation of the CMake build system.

---

## Table of Contents

1. [Overview](#1-overview)
2. [File Structure](#2-file-structure)
3. [Naming Conventions](#3-naming-conventions)
4. [Cache Variables](#4-cache-variables)
5. [Error Handling](#5-error-handling)
6. [Pipelines](#6-pipelines)
7. [Local Externals](#7-local-externals)
8. [Hook System](#8-hook-system)
9. [Source.cmake](#9-sourcecmake)
10. [Debug System](#10-debug-system)
11. [Code Quality](#11-code-quality)
12. [Compiler Overrides](#12-compiler-overrides)
13. [Checklist](#13-checklist)
14. [See Also](#14-see-also)
15. [Changelog](#15-changelog)

---

## 1. Overview

### Goals

- Uniform code style for all CMake modules
- Consistent naming
- Clear error handling
- Testable modules

### Scope

| Directory | Affected |
|-------------|-----------|
| `cmake/core/` | ✅ |
| `cmake/project/` | ✅ |
| `cmake/externals/` | ✅ |
| `cmake/buildSystemTest/` | ✅ |
| `externals/*/Include.cmake` | ✅ |

---

## 2. File Structure

### 2.1 Standard Header

**Rule:** Every `.cmake` file begins with the standard header.

**Obligation:** MUST

```cmake
# ==============================================================================
# cmake/path/FileName.cmake — Short description
# ==============================================================================
#
# Version:      X.Y.Z
# Date:         YYYY-MM-DD
# Status:       [In Development | Stable | Deprecated]
# Dependencies: [List or "None"]
#
# ==============================================================================

include_guard(GLOBAL)
```

### 2.2 Include Guard

**Rule:** All modules use `include_guard(GLOBAL)`.

**Obligation:** MUST

**Rationale:** `GLOBAL` instead of `DIRECTORY`, because modules can be loaded from different directories.

---

## 3. Naming Conventions

### 3.1 Functions

| Type | Prefix | Examples | Obligation |
|-----|--------|-----------|-----------------|
| Public API | `cmake_` | `cmake_fatal()`, `cmake_warn()` | MUST |
| Context API | `ctx_` | `ctx_create()`, `ctx_set()`, `ctx_get()` | MUST |
| JSON helper | `_json_` | `_json_get_string()`, `_json_has_key()` | MUST |
| Source helper | `_collect_` | `_collect_sources_from_cmake()` | SHOULD |
| Internal/private | `_` | `_helper()`, `_process_item()` | MUST |
| Validation | `validate_` | `validate_external_source()` | SHOULD |
| Hook loader | `load_` | `load_prefetch_hook()` | SHOULD |

### 3.2 Variables

| Type | Convention | Examples | Obligation |
|-----|------------|-----------|-----------------|
| Local variable | `_snake_case` | `_name`, `_ext_list` | MUST |
| Module constant | `_UPPER_SNAKE` | `_DEFAULT_VALUE` | SHOULD |
| Output parameters | `OUT_VAR` | `function(foo OUT_VAR)` | MUST |
| Parsed arguments | `ARG_*` | `ARG_TYPE`, `ARG_FLAG` | MUST |
| Global properties | `UPPER_SNAKE_CASE` | `SOLUTION_JSON` | MUST |
| Context keys | `UPPER_SNAKE_CASE` | `ctx_set(EXE NAME)` | MUST |
| Cache variables | `UPPER_SNAKE_CASE` | `BUILD_TESTS` | MUST |

### 3.3 Error Codes

| Area | Prefix | Description |
|---------|--------|--------------|
| JSON/parsing | `E0xx` | E001-E005, E010, E012, E013 |
| Target creation | `E1xx` | E101, E102, E104-E106 |
| Externals | `E2xx` | E201-E203, E213-E216, E218-E220 |
| Tests | `E3xx` | E301-E305 |
| AppContainer | `E4xx` | E400-E407 |
| System externals | `E5xx` | E502-E505 |
| Deprecation | `W0xx` | — |
| Configuration | `W1xx` | W101-W104, W109-W112 |
| Tools/setup | `W2xx` | W201 |
| Externals | `W3xx` | W302-W304 |
| AppContainer | `W4xx` | W401-W403 |
| System externals | `W5xx` | W501 |
| Self-test | `W6xx`-`W9xx` | W601, W602, W701, W801-W803, W901, W902, W999 — only in `cmake/buildSystemTest/` |

The table lists the codes that the code raises with `cmake_fatal`/`cmake_warn` (`cmake/`, `CMakeCraft.cmake`; as of 2026-11-09). `cmake/core/Errors.cmake` additionally describes E103, E217, W001, W002, W105-W108 and W301, which are never raised, and marks them as such there (W001 only appears in `validate_solution_schema()`, which nothing calls). The system handler raises E504 and E505 since CMakeCraft v0.14.1 (`cmake/externals/system/Handler.cmake:91`, `:109`); E501 and W502 are dropped with it. The completed concepts also name E306, E501 and W502.

---

## 4. Cache Variables

### 4.1 Build Control

| Variable | Type | Default | Description |
|----------|-----|---------|--------------|
| `BUILD_TESTS` | BOOL | ON | Enable project tests |
| `BUILD_ONLY` | STRING | "" | Only specific targets |
| `RUN_BUILD_SYSTEM_TESTS` | BOOL | OFF | CMake module tests |

### 4.2 Externals

| Variable | Type | Default | Description |
|----------|-----|---------|--------------|
| `EXTERNALS_OFFLINE` | BOOL | OFF | Cache only, no network |
| `EXTERNALS_FORCE_FETCH` | BOOL | OFF | Ignore cache |

### 4.3 Code Quality

| Variable | Type | Default | Description |
|----------|-----|---------|--------------|
| `ENABLE_CLANG_TIDY` | BOOL | OFF | Enable Clang-Tidy |
| `CLANG_TIDY_STRICT` | BOOL | OFF | Warnings as errors |
| `ENABLE_CLANG_FORMAT_CHECK` | BOOL | OFF | Format checks |

### 4.4 Compiler Options

| Variable | Type | Default | Description |
|----------|-----|---------|--------------|
| `ENABLE_STRICT_CONFORMANCE` | BOOL | ON | MSVC strict mode |
| `NO_EXCEPTIONS` | BOOL | OFF | Disable exceptions |
| `NO_RTTI` | BOOL | OFF | Disable RTTI |

---

## 5. Error Handling

### 5.1 Functions

**Rule:** Uniform error handling via `Errors.cmake`.

**Obligation:** MUST

```cmake
# Fatal error - aborts the build
cmake_fatal("E001" "Description with ${variable}")

# Warning - build continues
cmake_warn("W001" "Description with ${variable}")

# Assertion - for internal checks
cmake_assert(DEFINED _variable "Variable must be defined")

# Field validation
cmake_require_field(CTX "name" "Executable")
```

### 5.2 Error Format

**Rule:** Error messages follow this format.

**Obligation:** MUST

```
[E101] Dependency 'CoreLib' for 'MyApp' does not exist
 ^      ^                                ^
 |      |                                |
 Code   Description                      Context
```

---

## 6. Pipelines

### 6.1 Executable Pipeline

```
1. ExecutableCollect    → JSON → Context
2. Validation           → Check required fields
3. ExecutableCreate     → add_executable()
4. SourceCollect        → Collect sources
5. Dependencies         → Link internal libs
6. Externals            → Link external libs
7. CompilerOptions      → Set flags
8. Warnings             → Warning level
9. OutputDirs           → Target directories
```

### 6.2 Library Pipeline

Analogous to executables, additionally:
- PUBLIC/PRIVATE headers
- STATIC/SHARED/INTERFACE types

### 6.3 Test Pipeline

```
1. TestCollect          → JSON → Context
2. Validation           → Check required fields
3. TestCreate           → add_executable()
4. Framework-Setup      → doctest/googletest/catch2
5. CTest-Registration   → add_test()
6. Labels/Timeout       → Set properties
```

### 6.4 App Container Pipeline (Phase 8)

```
1. AppCollect           → JSON → Context
2. Validation           → Check required fields
3. AppCreate:
   a. Core Library      → add_library(STATIC)
   b. Runner Executable → add_executable()
   c. App Tests         → Test targets
```

---

## 7. Local Externals

### 7.1 Include.cmake MUST

**Obligation:** MUST

```cmake
# ✅ Link libraries
target_link_libraries(${EXECUTABLE_NAME} PRIVATE bass)

# ✅ Include directories
target_include_directories(${EXECUTABLE_NAME} PRIVATE ...)

# ✅ Compile definitions
target_compile_definitions(${EXECUTABLE_NAME} PRIVATE ...)

# ✅ Copy DLLs (Windows)
add_custom_command(TARGET ${EXECUTABLE_NAME} POST_BUILD ...)
```

### 7.2 Include.cmake MUST NOT

**Obligation:** MUST NOT

```cmake
# ❌ Do NOT create executables
add_executable(bass_example ...)

# ❌ NO example subdirectories
add_subdirectory(examples)
add_subdirectory(tests)

# ❌ NO global cache variables
set(GLOBAL_VAR "value" CACHE INTERNAL "")
```

**Rationale:** IDE clutter caused by unwanted targets.

---

## 8. Hook System

### 8.1 When to Use Hooks?

| Situation | Hook needed? |
|-----------|-------------|
| Standard CMake project | ❌ No |
| CMake variables BEFORE fetch | ✅ PreFetch |
| No CMakeLists.txt | ✅ PostFetch |
| Patches needed | ✅ PostFetch |
| Local external | ❌ Include.cmake |

### 8.2 Hook Structure

**Rule:** Hooks use `include_guard(GLOBAL)`.

**Obligation:** MUST

```cmake
# cmake/externals/Hooks/PostFetch/imgui.cmake

include_guard(GLOBAL)  # Important for shared hooks!

message(STATUS "[ImGui PostFetch] Creating target...")

FetchContent_GetProperties(imgui)
if(imgui_POPULATED)
    if(NOT TARGET imgui)
        add_library(imgui STATIC ...)
    endif()
endif()
```

---

## 9. Source.cmake

### 9.1 Prefer Explicit Lists

**Obligation:** SHOULD

```cmake
# ✅ Recommended: explicit listing
set(_local_sources
    "${CMAKE_CURRENT_LIST_DIR}/main.cpp"
    "${CMAKE_CURRENT_LIST_DIR}/app.cpp"
)
```

### 9.2 GLOB Only for Generated Files

**Obligation:** MAY

```cmake
# ✅ OK: GLOB with excludes for generated files
collect_files(_generated
    DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/generated"
    EXTENSIONS cpp
    EXCLUDE "*_test.cpp"
)
```

### 9.3 Hierarchical Structure

**Obligation:** SHOULD

```cmake
# Main directory
list(APPEND ${TARGET_NAME}_SOURCES ${_local_sources})

# Include subdirectories
include("${CMAKE_CURRENT_LIST_DIR}/core/Source.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/ui/Source.cmake")
```

---

## 10. Debug System

### 10.1 Usage

**Obligation:** SHOULD

```cmake
# At the beginning of the module
set(_SHOW_DEBUG OFF)
dbg_init(ID MY_DBG LEVEL ${DBG_SHOW_MUCH} SWITCH ${_SHOW_DEBUG} TAG "MODUL")

# In the code
dbg(${DBG_OFTEN} "Phase Start" ID MY_DBG)
dbg(${DBG_COMMON} "Processing ${_name}" ID MY_DBG)
dbg(${DBG_RARE} "Details: ${_val}" ID MY_DBG)

# At the end
enddbgblock(ID MY_DBG)
```

### 10.2 Debug Levels

| Level | Use for |
|-------|---------------|
| `DBG_OFTEN` | Phase start/end |
| `DBG_COMMON` | Features, files |
| `DBG_NORMAL` | Intermediate steps |
| `DBG_RARE` | Details, paths |
| `DBG_ULTRA_RARE` | Loop iterations |

---

## 11. Code Quality

### 11.1 Clang-Tidy & Clang-Format

| What | Where |
|-----|----|
| `.clang-format` | Root directory |
| `.clang-tidy` | Root directory |
| Enable/Disable | CMake cache variable |

### 11.2 Integration

```cmake
if(ENABLE_CLANG_TIDY)
    find_program(CLANG_TIDY_EXE NAMES clang-tidy)
    if(CLANG_TIDY_EXE)
        set_target_properties(${TARGET} PROPERTIES
            CXX_CLANG_TIDY "${CLANG_TIDY_EXE};--config-file=..."
        )
    endif()
endif()
```

---

## 12. Compiler Overrides

**Rule:** Per-target overrides for special situations.

**Obligation:** MAY

```cmake
# Legacy code: skip strict mode
apply_compiler_options(OldModule SKIP_STRICT_CONFORMANCE)

# Win32 API: allow min/max macros
apply_compiler_options(Win32Target SKIP_NOMINMAX)

# External lib: force exceptions
apply_compiler_options(ExternalLib FORCE_EXCEPTIONS)

# Tests: skip Clang-Tidy
apply_compiler_options(TestTarget SKIP_CLANG_TIDY)
```

---

## 13. Checklist

Check before code review:

**File structure:**
- [ ] Standard header present
- [ ] `include_guard(GLOBAL)` present
- [ ] Dependencies documented

**Naming conventions:**
- [ ] Function prefixes correct (`cmake_`, `ctx_`, `_json_`, `_`)
- [ ] Variable conventions followed
- [ ] Error codes in the correct range

**Error handling:**
- [ ] `cmake_fatal()` for fatal errors
- [ ] `cmake_warn()` for warnings
- [ ] Error format followed

**Best practices:**
- [ ] No global variables
- [ ] Context pattern used
- [ ] Debug output with `dbg()`

---

## 14. See Also

- [Master_Concept.md](abgeschlossen/Master_Concept.md) — Architecture
- [Implementation_Plan.md](abgeschlossen/Implementation_Plan.md) — Phase plan
- [CMake_Standard.md](../autorenwerk/standards/CMake_Standard.md) — General CMake style
- [ErrorCodes](../guide/references/ErrorCodes.md) — Error codes reference

---

## 15. Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: §3.3 lists the error codes actually raised (E0xx–E5xx, W0xx–W5xx, self-test W6xx–W9xx); CMakeCraft v0.14.1: E5xx with E502–E505, W001 as not raised (W0xx empty), E501/W502 dropped** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.0 | 2025-12-14 | Blueprint v0.5.0 (Standard), error codes extended (E3xx-E5xx, W3xx-W5xx), externals caching variables, app container pipeline, checklist added |
| 0.1.0 | 2025-12-03 | Initial (clean start): content taken over from v1.7 |
