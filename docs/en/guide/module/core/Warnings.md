# Warnings.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** In development (pre-release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [Warnings.md](../../../../de/guide/module/core/Warnings.md)  
> **Module:** [`cmake/core/Warnings.cmake`](../../../../../cmake/core/Warnings.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Concept](#3-concept)
4. [API Reference](#4-api-reference)
5. [Usage Examples](#5-usage-examples)
6. [Third-Party Code](#6-third-party-code)
7. [See Also](#7-see-also)
8. [Changelog](#changelog)

---

## 1. Overview

The `Warnings.cmake` module configures **compiler-specific warning levels** for targets. It enables high warning levels to promote code quality.

### Core Idea

Uniform, high warning levels for all targets — consistent across all compilers.

### Responsibilities

| Area | Description |
|------|-------------|
| MSVC | /W4 (high warning level) |
| GCC | -Wall -Wextra -Wpedantic |
| Clang | -Wall -Wextra -Wpedantic |

### Used By

- ExecutableCreate.cmake
- LibraryCreate.cmake

---

## 2. Dependencies

| Module | Version | Usage |
|--------|---------|-------|
| — | — | None (standalone module) |

**Design decision:** Warnings.cmake is a minimalist standalone module without debug or error integration.

→ See [Open clarifications](../../../konzepte/abgeschlossen/Offene_Abklaerungen_Core_Module.md) for details on a possible dbg() integration.

---

## 3. Concept

### 3.1 Compiler-Specific Flags

| Compiler | Flags | Description |
|----------|-------|-------------|
| MSVC | `/W4` | High warning level |
| GCC | `-Wall -Wextra -Wpedantic` | Standard + extra + pedantic |
| Clang | `-Wall -Wextra -Wpedantic` | Same as GCC |

### 3.2 Warning Levels (MSVC)

| Level | Meaning |
|-------|---------|
| `/W0` | No warnings |
| `/W1` | Severe only |
| `/W2` | Significant |
| `/W3` | Production quality |
| `/W4` | Informational (recommended) ✅ |
| `/Wall` | All (very many!) |

### 3.3 Warning Flags (GCC/Clang)

| Flag | Meaning |
|------|---------|
| `-Wall` | "All" (most important warnings) |
| `-Wextra` | Additional warnings |
| `-Wpedantic` | Strict ISO C++ conformance |

---

## 4. API Reference

### 4.1 apply_warnings()

Sets the warning level for a target.

```cmake
apply_warnings(<TARGET_NAME>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `TARGET_NAME` | String | ✓ | CMake target (must already exist) |

**Prerequisite:** The target must already have been created with `add_executable()` or `add_library()`.

**Returns:** Nothing (sets compile options)

**Example:**

```cmake
add_executable(MyApp main.cpp)
apply_warnings(MyApp)
```

---

## 5. Usage Examples

### 5.1 Simple Usage

```cmake
add_executable(MyApp main.cpp)
apply_warnings(MyApp)
```

### 5.2 In the Executable Pipeline

```cmake
function(_create_executable_target CTX)
    ctx_get(${CTX} NAME _name)
    
    add_executable(${_name} ${_sources})
    setup_output_dirs(${_name})
    apply_warnings(${_name})           # ← warnings
    apply_compiler_options(${_name})   # ← further options
endfunction()
```

### 5.3 For Libraries

```cmake
add_library(CoreLib STATIC core.cpp)
apply_warnings(CoreLib)
```

---

## 6. Third-Party Code

### 6.1 Disabling Warnings

For external code without strict warnings:

```cmake
# Own code with warnings
add_library(MyLib ...)
apply_warnings(MyLib)

# Third-party without strict warnings
add_library(ThirdParty ...)
if(MSVC)
    target_compile_options(ThirdParty PRIVATE /W0)
else()
    target_compile_options(ThirdParty PRIVATE -w)
endif()
```

### 6.2 Disabling Individual Warnings

```cmake
# MSVC: disable specific warnings
target_compile_options(${TARGET} PRIVATE 
    /wd4996   # deprecated functions
    /wd4100   # unused parameter
)

# GCC/Clang: disable specific warnings
target_compile_options(${TARGET} PRIVATE 
    -Wno-unused-parameter
    -Wno-deprecated-declarations
)
```

### 6.3 Enabling Additional Warnings

```cmake
# Optional strict warnings
target_compile_options(${TARGET} PRIVATE 
    -Wshadow           # Variable shadows another
    -Wconversion       # Implicit conversions
    -Wnon-virtual-dtor # Non-virtual destructors
)
```

---

## 7. See Also

- [CompilerOptions.cmake](CompilerOptions.md) — further compiler options (Clang-Tidy, RTTI, exceptions)
- [ExecutableCreate.cmake](../project/ExecutableCreate.md) — uses apply_warnings
- [LibraryCreate.cmake](../project/LibraryCreate.md) — uses apply_warnings

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0: new header with target audience/language/English link/module link, numbered table of contents with anchors, chapter numbering |
| 0.1.1 | 2025-12-05 | English translation (Language Standards v0.1.1) |
| 0.1.0 | 2025-12-03 | Initial (clean start): apply_warnings for MSVC/GCC/Clang |
