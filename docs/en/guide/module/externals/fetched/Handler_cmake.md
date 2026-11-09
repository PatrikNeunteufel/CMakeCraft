# Fetched/Handler.cmake — Git External Pipeline

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5, Doc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [Handler_cmake.md](../../../../../de/guide/module/externals/fetched/Handler_cmake.md)  
> **Module:** [cmake/externals/Fetched/Handler.cmake](../../../../../../cmake/externals/fetched/Handler.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [API Reference](#3-api-reference)
4. [Processing Pipeline](#4-processing-pipeline)
5. [Hook Integration](#5-hook-integration)
6. [Usage Examples](#6-usage-examples)
7. [Error Handling](#7-error-handling)
8. [See Also](#8-see-also)
9. [Changelog](#9-changelog)

---

## 1. Overview

`Fetched/Handler.cmake` orchestrates the complete processing of Git-based externals.

### Pipeline Overview

```
┌─────────────────────────────────────────────────────────────┐
│                  _handle_fetched_external()                  │
├─────────────────────────────────────────────────────────────┤
│  1. Declare    → _fetch_git_external()                      │
│  2. PreFetch   → _load_prefetch_hook()                      │
│  3. Available  → _make_external_available()                 │
│  4. PostFetch  → _load_postfetch_hook()                     │
│  5. Register   → _auto_register_external_targets()          │
│  6. Validate   → _validate_external_targets()               │
│  7. Ready      → EXTERNAL_${NAME}_READY = TRUE              │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Dependencies

### Required Modules

| Module | Purpose |
|--------|---------|
| `Errors.cmake` | Error handling |
| `Debug.cmake` | Debug output |
| `Json.cmake` | JSON parsing |

### Auto-loaded Modules

| Module | Purpose |
|--------|---------|
| `Core/Fetch.cmake` | FetchContent wrapper |
| `Hooks/HookLoader.cmake` | Hook system |
| `Registry/Targets.cmake` | Target registry |

---

## 3. API Reference

### 3.1 _handle_fetched_external()

```cmake
_handle_fetched_external(EXT_NAME EXT_JSON)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `EXT_NAME` | String | Name of the external |
| `EXT_JSON` | JSON | JSON definition |

**Sets property:** `EXTERNAL_${NAME}_READY = TRUE`

---

### 3.2 _is_external_ready()

```cmake
_is_external_ready(EXT_NAME OUT_VAR)
```

Checks whether an external has been completely processed.

---

## 4. Processing Pipeline

### Detailed Flow

| Step | Action | Description |
|------|--------|-------------|
| 1 | Declare | `_fetch_git_external()` — Checks the cache |
| 2 | PreFetch | `_load_prefetch_hook()` — Sets CMake options |
| 3 | Available | `_make_external_available()` — Download |
| 4 | PostFetch | `_load_postfetch_hook()` — Creates targets |
| 5 | Register | `_auto_register_external_targets()` — Registers targets |
| 6 | Validate | `_validate_external_targets()` — Checks |
| 7 | Ready | `EXTERNAL_${NAME}_READY = TRUE` |

---

## 5. Hook Integration

### When Are Hooks Needed?

| Scenario | PreFetch | PostFetch |
|----------|----------|-----------|
| CMake support, standard config | ✗ | ✗ |
| CMake support, disable tests | ✓ | ✗ |
| No CMake support (e.g. ImGui) | ✗ | ✓ |
| Special target names | ✓ | ✗ |

---

## 6. Usage Examples

### Standard CMake External

```json
{
    "spdlog": {
        "git": "https://github.com/gabime/spdlog.git",
        "tag": "v1.12.0"
    }
}
```

### External Without CMake Support

```json
{
    "imgui": {
        "git": "https://github.com/ocornut/imgui.git",
        "tag": "v1.89.9",
        "cmakeSupport": false
    }
}
```

---

## 7. Error Handling

| Code | Error | Description |
|------|-------|-------------|
| E201 | No targets | External without targets, PostFetch hook missing |
| E202 | Fetch failed | FetchContent could not load it |

---

## 8. See Also

- [Fetch_cmake.md](../core/Fetch_cmake.md) — FetchContent wrapper
- [HookLoader_cmake.md](../hooks/HookLoader_cmake.md) — Hook system
- [Targets_cmake.md](../registry/Targets_cmake.md) — Target registry
- [Orchestrator_cmake.md](../Orchestrator_cmake.md) — Type dispatcher

---

## 9. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-15 | Documentation migrated to Blueprint v0.5.0 |
