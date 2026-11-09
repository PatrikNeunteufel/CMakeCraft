# PreFetch/glfw.cmake — GLFW PreFetch Hook

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5, Doc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [Glfw.md](../../../../../../de/guide/module/externals/hooks/prefetch/Glfw.md)  
> **Hook:** [cmake/externals/hooks/prefetch/glfw.cmake](../../../../../../../cmake/externals/hooks/prefetch/glfw.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Why a PreFetch Hook?](#2-why-a-prefetch-hook)
3. [Options Set](#3-options-set)
4. [Solution.json Configuration](#4-solutionjson-configuration)
5. [Created Targets](#5-created-targets)
6. [See Also](#6-see-also)
7. [Changelog](#7-changelog)

---

## 1. Overview

The `glfw.cmake` PreFetch hook configures GLFW before the build to disable unneeded components.

---

## 2. Why a PreFetch Hook?

**Without the hook:** 20+ additional targets in the Solution Explorer (examples, tests, docs).

**With the hook:** Only the `glfw` and `update_mappings` targets.

---

## 3. Options Set

| Option | Value | Description |
|--------|-------|-------------|
| `GLFW_BUILD_EXAMPLES` | `OFF` | No example programs |
| `GLFW_BUILD_TESTS` | `OFF` | No test programs |
| `GLFW_BUILD_DOCS` | `OFF` | No documentation |
| `GLFW_INSTALL` | `OFF` | No install target |

---

## 4. Solution.json Configuration

```json
{
    "glfw": {
        "git": "https://github.com/glfw/glfw.git",
        "tag": "3.4"
    }
}
```

---

## 5. Created Targets

| Target | Type | Description |
|--------|------|-------------|
| `glfw` | STATIC | GLFW library |

---

## 6. See Also

- [HookLoader_cmake.md](../HookLoader_cmake.md) — Hook system
- [Imgui.md](../postfetch/Imgui.md) — ImGui hook (uses glfw)

---

## 7. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-15 | Documentation migrated to Blueprint v0.5.0 |
