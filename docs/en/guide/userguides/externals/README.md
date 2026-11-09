# Externals — Library-Specific Guides

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Language:** English  
> **German:** [README.md](../../../../de/guide/userguides/externals/README.md)

---

## Quick Start

**Audio application?**
1. [Bass.md](Bass.md) — BASS Audio Library

**GUI application?**
1. [Glfw.md](Glfw.md) — GLFW for window/input
2. [Imgui.md](Imgui.md) — Dear ImGui for UI
3. [Qt6.md](Qt6.md) — Qt6 Framework

**OpenGL rendering?**
1. [Glad.md](Glad.md) — OpenGL loader
2. [Glfw.md](Glfw.md) — OpenGL context

**Adding scripting?**
1. [Lua54.md](Lua54.md) — Lua 5.4 scripting engine

**Writing tests?**
1. [Doctest.md](Doctest.md) — Fast and simple (recommended)
2. [Googletest.md](Googletest.md) — Comprehensive with mocking
3. [Catch2.md](Catch2.md) — BDD style

---

## Overview

Library-specific user guides show how individual external libraries are used in projects. Each guide contains setup, configuration and examples.

---

## Files

### Audio

| Guide | Library | Type |
|-------|---------|------|
| [Bass.md](Bass.md) | BASS Audio Library | Local |

### GUI

| Guide | Library | Type |
|-------|---------|------|
| [Glfw.md](Glfw.md) | GLFW | Git (fetched) |
| [Imgui.md](Imgui.md) | Dear ImGui | Git (fetched) |
| [Qt6.md](Qt6.md) | Qt6 Framework | System (find_package) |

### OpenGL

| Guide | Library | Type |
|-------|---------|------|
| [Glad.md](Glad.md) | GLAD OpenGL Loader | Local |

### Scripting

| Guide | Library | Type |
|-------|---------|------|
| [Lua54.md](Lua54.md) | Lua 5.4 | Local |

### Testing

| Guide | Library | Type | Recommendation |
|-------|---------|------|----------------|
| [Doctest.md](Doctest.md) | doctest | Git/Local | ⭐ Standard |
| [Googletest.md](Googletest.md) | Google Test | Git | For complex tests |
| [Catch2.md](Catch2.md) | Catch2 | Git | For BDD style |

---

## See Also

- [../README.md](../README.md) — User guides overview
- [../Externals.md](../Externals.md) — Externals overview
- [../Adding_Externals.md](../Adding_Externals.md) — Adding a new external
- [../../references/Externals.md](../../references/Externals.md) — Externals reference
- [../../module/externals/](../../module/externals/README.md) — Externals modules

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.1 | 2026-11-09 | Aligned with the code: Qt6 listed as a system external (`find_package`) instead of "Local" |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
