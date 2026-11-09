# Registry/Targets.cmake — External Target Registry

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5, Doc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [Targets_cmake.md](../../../../../de/guide/module/externals/registry/Targets_cmake.md)  
> **Module:** [cmake/externals/Registry/Targets.cmake](../../../../../../cmake/externals/registry/Targets.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [API Reference](#3-api-reference)
4. [Auto-Detection](#4-auto-detection)
5. [Target Linking](#5-target-linking)
6. [Usage Examples](#6-usage-examples)
7. [Error Handling](#7-error-handling)
8. [See Also](#8-see-also)
9. [Changelog](#9-changelog)

---

## 1. Overview

`Registry/Targets.cmake` manages the target registration for fetched externals.

### Core Functions

- **Registers targets** — Assigns targets to an external
- **Auto-detection** — Detects standard target names automatically
- **Primary target** — Determines the main target for linking
- **Linking** — Connects externals with consumer targets

### Design Principle

**No hard-coded mappings** — Target assignments are determined dynamically.

---

## 2. Dependencies

| Module | Purpose |
|--------|---------|
| `Errors.cmake` | Error handling |
| `Debug.cmake` | Debug output |

---

## 3. API Reference

### 3.1 _register_external_target()

```cmake
_register_external_target(EXT_NAME TARGET_NAME [PRIMARY])
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `EXT_NAME` | String | Name of the external |
| `TARGET_NAME` | String | CMake target name |
| `PRIMARY` | Flag | Marks it as the primary target |

---

### 3.2 _auto_register_external_targets()

```cmake
_auto_register_external_targets(EXT_NAME)
```

Detects and registers targets automatically.

---

### 3.3 _get_external_primary_target()

```cmake
_get_external_primary_target(EXT_NAME OUT_VAR)
```

Returns the primary target.

---

### 3.4 _link_external_to_target()

```cmake
_link_external_to_target(CONSUMER_TARGET EXT_NAME [SCOPE <scope>])
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `CONSUMER_TARGET` | String | Target that uses the external |
| `EXT_NAME` | String | Name of the external |
| `SCOPE` | Keyword | PRIVATE/PUBLIC/INTERFACE (default: PRIVATE) |

---

## 4. Auto-Detection

### Detected Patterns

| Pattern | Example |
|---------|---------|
| `${EXT_NAME}` | `spdlog` |
| `${EXT_NAME}::${EXT_NAME}` | `spdlog::spdlog` |
| `${ext_lower}` | `spdlog` |
| `${EXT_UPPER}` | `SPDLOG` |

### Hook Hints for Special Names

```cmake
# cmake/externals/hooks/prefetch/catch2.cmake
set_property(GLOBAL PROPERTY HOOK_KNOWN_TARGETS_${HOOK_EXTERNAL_NAME}
    "Catch2;Catch2WithMain"
)
set_property(GLOBAL PROPERTY HOOK_PRIMARY_TARGET_${HOOK_EXTERNAL_NAME}
    "Catch2WithMain"
)
```

`HOOK_EXTERNAL_NAME` is the name of the external from `Solution.json` (`catch2` in the demo solution).

---

## 5. Target Linking

### Keyword Signature

```cmake
target_link_libraries(${CONSUMER_TARGET} ${SCOPE} ${_primary})
```

**Important:** Always use the keyword signature!

---

## 6. Usage Examples

### PostFetch: Registering a Target

```cmake
add_library(${HOOK_EXTERNAL_NAME} STATIC ...)
_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)
```

### Manual Linking

```cmake
_link_external_to_target(MyLibrary spdlog SCOPE PUBLIC)
```

---

## 7. Error Handling

| Code | Error | Description |
|------|-------|-------------|
| E201 | No targets | External has no registered targets |
| E203 | Target not found | Primary target does not exist |

---

## 8. See Also

- [Handler_cmake.md](../fetched/Handler_cmake.md) — Calls auto-register
- [HookLoader_cmake.md](../hooks/HookLoader_cmake.md) — Hook system
- [Orchestrator_cmake.md](../Orchestrator_cmake.md) — Calls linking

---

## 9. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: § 4 catch2 hint as in `hooks/prefetch/catch2.cmake` (`"Catch2;Catch2WithMain"`, primary `Catch2WithMain`, property name via `HOOK_EXTERNAL_NAME`)** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.0 | 2025-12-15 | Documentation migrated to Blueprint v0.5.0 |
