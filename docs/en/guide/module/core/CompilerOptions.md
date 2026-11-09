# CompilerOptions.cmake — Module Documentation

> **Version:** 1.0.1  
> **Date:** 2026-11-07  
> **Type:** ModuleDoc  
> **Status:** In development (pre-release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [CompilerOptions.md](../../../../de/guide/module/core/CompilerOptions.md)  
> **Module:** [`cmake/core/CompilerOptions.cmake`](../../../../../cmake/core/CompilerOptions.cmake)  
> **Module Version:** 1.3.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Concept](#3-concept)
4. [API Reference](#4-api-reference)
5. [Usage Examples](#5-usage-examples)
6. [Cache Variables](#6-cache-variables)
7. [Platform Details](#7-platform-details)
8. [Best Practices](#8-best-practices)
9. [Performance Impact](#9-performance-impact)
10. [See Also](#10-see-also)
11. [Changelog](#changelog)

---

## 1. Overview

The `CompilerOptions.cmake` module configures compiler-specific options for targets. It supports precise compiler detection and per-target overrides.

### Responsibilities

| Area | Description |
|------|-------------|
| Compiler detection | MSVC, GCC, Clang (incl. Apple/Clang-CL) |
| Strict conformance | `/permissive-`, `/Zc:*` (MSVC) |
| Feature control | Exceptions, RTTI |
| Code quality | Clang-Tidy integration |
| Per-target overrides | Flags for special targets |

---

## 2. Dependencies

| Module | Version | Usage |
|--------|---------|-------|
| Debug.cmake | 0.1.1 | `dbg_init`, `dbg`, `enddbgblock` |
| Errors.cmake | 0.1.2 | `cmake_warn` |

---

## 3. Concept

### 3.1 Precise Compiler Detection

```cmake
if(MSVC)                                    # Windows MSVC
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU") # GCC
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    if(APPLE)                               # Apple Clang
    elseif(WIN32)                           # Clang-CL
    else()                                  # Linux Clang
    endif()
endif()
```

### 3.2 Per-Target Override Flags

| Flag | Function |
|------|----------|
| `SKIP_STRICT_CONFORMANCE` | Skip MSVC `/permissive-` |
| `SKIP_NOMINMAX` | Do not define `NOMINMAX` |
| `FORCE_EXCEPTIONS` | Keep exceptions enabled |
| `FORCE_RTTI` | Keep RTTI enabled |
| `SKIP_CLANG_TIDY` | Skip Clang-Tidy |

---

## 4. API Reference

### apply_compiler_options()

Applies compiler options to a target.

```cmake
apply_compiler_options(<TARGET_NAME>
    [SKIP_STRICT_CONFORMANCE]
    [SKIP_NOMINMAX]
    [FORCE_EXCEPTIONS]
    [FORCE_RTTI]
    [SKIP_CLANG_TIDY]
    [SHOW_DEBUG]
    [DEBUG_TAG <tag>]
)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `TARGET_NAME` | String | ✓ | CMake target |
| `SKIP_STRICT_CONFORMANCE` | Flag | — | Skip MSVC strict mode |
| `SKIP_NOMINMAX` | Flag | — | Allow min/max macros |
| `FORCE_EXCEPTIONS` | Flag | — | Force exceptions (ignores `NO_EXCEPTIONS`) |
| `FORCE_RTTI` | Flag | — | Force RTTI (ignores `NO_RTTI`) |
| `SKIP_CLANG_TIDY` | Flag | — | Skip Clang-Tidy |
| `SHOW_DEBUG` | Flag | — | Enable debug output |
| `DEBUG_TAG` | String | — | Custom tag for debug output |

**Returns:** Nothing (modifies target properties)

**Errors:**

| Code | Condition |
|------|-----------|
| W201 | `ENABLE_CLANG_TIDY=ON` but clang-tidy not found |

**Example:**

```cmake
apply_compiler_options(MyApp)
apply_compiler_options(LegacyLib SKIP_STRICT_CONFORMANCE FORCE_EXCEPTIONS)
```

### craft_language_rules() (since v0.14.0)

Single source of the switches that set **language rules** — strict conformance, `NOMINMAX`,
exceptions, RTTI — for all compiler families at once. `apply_compiler_options()` applies the
list of the current compiler; a source package
([SourcePackage.cmake](../project/SourcePackage.md)) writes all lists into its generated
`CMakeLists.txt`, so that the consumer compiles under the same rules. Warnings
(`Warnings.cmake`), `/MP` and `/bigobj` are not language rules and stay in
`apply_compiler_options()`.

```cmake
craft_language_rules(<PREFIX>
    [SKIP_STRICT_CONFORMANCE] [SKIP_NOMINMAX] [FORCE_EXCEPTIONS] [FORCE_RTTI])
```

| Result | Content |
|--------|---------|
| `<PREFIX>_MSVC_OPTIONS` | MSVC frontend (cl, clang-cl; CMake `MSVC`): `/permissive- /Zc:preprocessor /Zc:__cplusplus` with strict conformance, `/EHs-c-` with `NO_EXCEPTIONS`, `/GR-` with `NO_RTTI` |
| `<PREFIX>_MSVC_DEFINES` | `NOMINMAX`, except with `SKIP_NOMINMAX` |
| `<PREFIX>_GNU_OPTIONS` | GCC and Clang with GNU frontend: `-fno-exceptions`, `-fno-rtti` as above |

The flags have the same meaning as for `apply_compiler_options()`.

---

## 5. Usage Examples

### 5.1 Basic Usage

```cmake
apply_compiler_options(MyTarget)
```

**Result (MSVC):**
- `/permissive-`
- `/Zc:preprocessor`
- `/Zc:__cplusplus`
- `NOMINMAX`

### 5.2 Legacy Code

```cmake
# Strict conformance would break legacy code
apply_compiler_options(LegacyApp SKIP_STRICT_CONFORMANCE)
```

### 5.3 Win32 API

```cmake
# The Win32 API uses min/max macros
apply_compiler_options(Win32App SKIP_NOMINMAX)
```

### 5.4 External Library with Exceptions

```cmake
# Global NO_EXCEPTIONS=ON, but this library needs exceptions
apply_compiler_options(ThirdPartyLib FORCE_EXCEPTIONS)
```

### 5.5 Tests without Clang-Tidy

```cmake
# Clang-Tidy would make tests slower
apply_compiler_options(SlowTests SKIP_CLANG_TIDY)
```

### 5.6 Combined

```cmake
apply_compiler_options(SpecialApp
    SKIP_STRICT_CONFORMANCE
    FORCE_EXCEPTIONS
    SKIP_CLANG_TIDY
)
```

---

## 6. Cache Variables

### 6.1 Global Options

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `ENABLE_STRICT_CONFORMANCE` | BOOL | ON | MSVC `/permissive-` |
| `NO_EXCEPTIONS` | BOOL | OFF | `-fno-exceptions` / `/EHs-c-` globally |
| `NO_RTTI` | BOOL | OFF | `-fno-rtti` / `/GR-` globally |

### 6.2 Code Quality

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `ENABLE_CLANG_TIDY` | BOOL | OFF | Enable Clang-Tidy |
| `CLANG_TIDY_STRICT` | BOOL | OFF | Warnings = errors |
| `ENABLE_CLANG_FORMAT_CHECK` | BOOL | OFF | Format check (phase 7) |

---

## 7. Platform Details

### 7.1 Windows

| Compiler | Detected as | Options |
|----------|-------------|---------|
| MSVC | `MSVC` | `/permissive-`, `/Zc:*`, `NOMINMAX` |
| MinGW GCC | `GNU` + `WIN32` | GCC standard |
| Clang-CL | `Clang` + `WIN32` | Same as MSVC |

### 7.2 Linux

| Compiler | Detected as | Options |
|----------|-------------|---------|
| GCC | `GNU` | GCC standard |
| Clang | `Clang` | Clang standard |

### 7.3 macOS

| Compiler | Detected as | Options |
|----------|-------------|---------|
| Apple Clang | `Clang` + `APPLE` | Apple-specific |
| Homebrew GCC | `GNU` + `APPLE` | GCC standard |

---

## 8. Best Practices

1. **Default = strict** — only skip when needed
2. **Global defaults via cache** — `-DNO_EXCEPTIONS=ON`
3. **Use local overrides sparingly** — only where necessary
4. **Clang-Tidy only for quality checks** — too slow for daily builds
5. **.clang-tidy in the project root** — is used automatically

---

## 9. Performance Impact

### 9.1 Clang-Tidy

| Configuration | Build time | Factor |
|---------------|------------|--------|
| Without | 1:00 min | 1.0x |
| With | 3:30 min | 3.5x |

### 9.2 NO_EXCEPTIONS/NO_RTTI

| Configuration | Binary size | Performance |
|---------------|-------------|-------------|
| Standard | 2.4 MB | Baseline |
| NO_EXCEPTIONS | 2.1 MB (-12%) | +2% |
| NO_RTTI | 2.3 MB (-4%) | +1% |
| Both | 2.0 MB (-17%) | +3% |

---

## 10. See Also

- [Warnings.cmake](Warnings.md) — warning levels
- [Debug.cmake](Debug.md) — debug system
- [Errors.cmake](Errors.md) — error handling
- [guidelines](../../../konzepte/Guidelines.md) — conventions
- [CMakePresets_Reference](../../references/CMakePresets.md) — presets

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-11-07** | **CMakeCraft v0.14.0: `craft_language_rules()`: language-rule switches of all compiler families in one place, used by `apply_compiler_options()` and source packages; module version 1.3.0** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.0 | 2025-12-15 | **Migration to Blueprint v0.5.0: new header with target audience/language/English link/module link, numbered table of contents with anchors, chapter numbering, corrected dependencies** |
| 0.1.1 | 2025-12-05 | English translation (Language Standards v0.1.1) |
| 0.1.0 | 2025-12-03 | Initial (clean start): content taken over from v2.0, blueprint format, per-target overrides |
