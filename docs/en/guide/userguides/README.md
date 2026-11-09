# User Guides

> **Version:** 1.0.0  
> **Date:** 2025-12-15  
> **Language:** English  
> **German:** [README.md](../../../de/guide/userguides/README.md)

---

## Quick Start

**New to the project?**
1. [Getting_Started.md](Getting_Started.md) — First steps, setting up the project
2. [../references/Glossar.md](../references/Glossar.md) — Clarify terms

**Using external libraries?**
1. [Externals.md](Externals.md) — Overview of the externals system
2. [Adding_Externals.md](Adding_Externals.md) — Adding a new external
3. [externals/](externals/README.md) — Library-specific guides

**Writing tests?**
1. [Testing.md](Testing.md) — Setting up and using the test framework
2. [externals/Doctest.md](externals/Doctest.md) — doctest guide
3. [externals/Googletest.md](externals/Googletest.md) — GoogleTest guide

**Configuring the build?**
1. [CMakeUserPresets.md](CMakeUserPresets.md) — Creating your own presets
2. [../references/CMakePresets.md](../references/CMakePresets.md) — Preset reference

**Using Qt6?**
1. [Qt6_Integration.md](Qt6_Integration.md) — Setting up Qt6
2. [externals/Qt6.md](externals/Qt6.md) — Qt6 details

---

## Overview

User guides are practical instructions for concrete tasks. They follow the [Guide Blueprint](../../autorenwerk/blueprints/Guide.md) and are aimed at end users.

---

## Files

| File | Description |
|------|-------------|
| [Getting_Started.md](Getting_Started.md) | First steps — clone, configure, build the project |
| [Externals.md](Externals.md) | Using externals — integrating Git and local libraries |
| [Adding_Externals.md](Adding_Externals.md) | Adding a new external — step by step |
| [Testing.md](Testing.md) | Writing tests — setting up the framework, creating tests |
| [CMakeUserPresets.md](CMakeUserPresets.md) | CMakeUserPresets.json — your own build configurations |
| [Qt6_Integration.md](Qt6_Integration.md) | Qt6 integration — setup and usage |

---

## Subfolders

| Folder | Files | Description |
|--------|-------|-------------|
| [externals/](externals/README.md) | 9 | Library-specific guides |

---

## Library Guides (Direct Access)

### Audio

| Guide | Description |
|-------|-------------|
| [externals/Bass.md](externals/Bass.md) | BASS Audio Library — setup, plugins, examples |

### GUI

| Guide | Description |
|-------|-------------|
| [externals/Glfw.md](externals/Glfw.md) | GLFW — window/input library |
| [externals/Imgui.md](externals/Imgui.md) | Dear ImGui — immediate mode GUI |
| [externals/Qt6.md](externals/Qt6.md) | Qt6 — framework integration |

### OpenGL

| Guide | Description |
|-------|-------------|
| [externals/Glad.md](externals/Glad.md) | GLAD — OpenGL loader |

### Scripting

| Guide | Description |
|-------|-------------|
| [externals/Lua54.md](externals/Lua54.md) | Lua 5.4 — scripting engine |

### Testing

| Guide | Description |
|-------|-------------|
| [externals/Doctest.md](externals/Doctest.md) | doctest — fast testing |
| [externals/Googletest.md](externals/Googletest.md) | Google Test — comprehensive testing |
| [externals/Catch2.md](externals/Catch2.md) | Catch2 — BDD-style testing |

---

## See Also

- [../../README.md](../../README.md) — English documentation overview
- [../blueprints/Guide.md](../../autorenwerk/blueprints/Guide.md) — Guide Blueprint
- [../references/](../references/README.md) — References
