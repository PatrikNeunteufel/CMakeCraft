# phase6.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Path:** `cmake/buildSystemTest/phase6.cmake`  
> **Status:** Stable  
> **Language:** English  
> **German:** [Phase6_doc.md](../../../../de/guide/module/buildSystemTest/Phase6_doc.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Tests](#2-tests)
3. [Success Flag](#3-success-flag)
4. [See Also](#4-see-also)
5. [Changelog](#changelog)

---

## 1. Overview

**Phase 6** tests the **Git externals pipeline** — FetchContent integration, hooks and target registry.

| Aspect | Description |
|--------|-------------|
| **Purpose** | Git externals & hooks validation |
| **Debug ID** | `PHASE6_TEST` |
| **Dependencies** | Phase 1-5, Fetch.cmake, HookLoader.cmake |

---

## 2. Tests

### 2.1 Git External with CMake Support (GLFW)

| Check | Description |
|-------|-------------|
| `TARGET glfw` | Target exists |
| `EXTERNAL_TARGET_glfw` | Entered in the registry |

### 2.2 Git External without CMake Support (ImGui)

Checks that the PostFetch hook creates the target:

```cmake
if(TARGET imgui OR TARGET imgui_docking)
    # PostFetch hook worked
endif()
```

### 2.3 Hook Reuse

Checks that `imgui_docking` reuses the `imgui` hook:

| Property | Description |
|----------|-------------|
| `EXTERNAL_HOOK_imgui` | Hook path |
| `EXTERNAL_HOOK_imgui_docking` | Should be the same |

Both targets should exist and be distinct.

### 2.4 Externals JSON Parsing

Checks JSON fields:

| Field | External | Description |
|-------|----------|-------------|
| `git` | glfw | Git URL |
| `cmakeSupport` | imgui | false |
| `hook` | imgui_docking | "imgui" |

### 2.5 Fetched External Linking

Checks the links of `imGuiApp`:

```cmake
get_target_property(_libs imGuiApp LINK_LIBRARIES)
# Should contain glfw and imgui
```

---

## 3. Success Flag

```cmake
set(PHASE6_TEST_PASSED TRUE CACHE BOOL "Phase 6 Test passed" FORCE)
```

---

## 4. See Also

- [Fetch.md](../externals/core/Fetch_cmake.md)
- [HookLoader.md](../externals/hooks/HookLoader_cmake.md)
- [Handler.md](../externals/fetched/Handler_cmake.md)
- [Targets.md](../externals/registry/Targets_cmake.md)
- [Git_Externals.md](../../references/externals/Git_Externals.md)

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-15 | Blueprint v0.5.0 format |
| 0.1.0 | 2025-12-12 | Initial |
