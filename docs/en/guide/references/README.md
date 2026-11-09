# References — Lookup Documents

> **Version:** 1.0.0  
> **Date:** 2025-12-15  
> **Language:** English  
> **German:** [README.md](../../../de/guide/references/README.md)

---

## Quick Start

**Looking up an error code?**
1. [ErrorCodes.md](ErrorCodes.md) — All error codes E0xx-E9xx

**Understanding the JSON configuration?**
1. [Solution_Schema.md](Solution_Schema.md) — Solution.json schema
1. [Packages.md](Packages.md) — Building and consuming packages
2. [CMakePresets.md](CMakePresets.md) — CMakePresets.json
3. [CMakeUserPresets.md](CMakeUserPresets.md) — Your own presets

**Browsing the externals catalog?**
1. [Externals.md](Externals.md) — Overview of the externals system
2. [externals/Git_Externals.md](externals/Git_Externals.md) — Git-based libraries
3. [externals/Local_Externals.md](externals/Local_Externals.md) — Local libraries

**Looking up a term?**
1. [Glossar.md](Glossar.md) — All definitions

---

## Overview

Reference documents are lookup works without tutorial character. They document APIs, schemas, configuration options and definitions.

---

## Files

| File | Description |
|------|-------------|
| [ErrorCodes.md](ErrorCodes.md) | Complete error code reference (E001-E999) |
| [Solution_Schema.md](Solution_Schema.md) | JSON schema for Solution.json |
| [Packages.md](Packages.md) | Building packages (`packages`) and consuming them (external kind `archive`) |
| [CMakePresets.md](CMakePresets.md) | CMakePresets.json reference |
| [CMakeUserPresets.md](CMakeUserPresets.md) | CMakeUserPresets.json reference |
| [Externals.md](Externals.md) | Externals system overview |
| [Glossar.md](Glossar.md) | Term definitions A-Z |

---

## Subfolders

| Folder | Files | Description |
|--------|-------|-------------|
| [externals/](Externals.md) | 14 | Externals definitions (Git + Local) |

---

## Direct Access: Externals Catalog

### Git-Based Externals

| File | Category | Libraries |
|------|----------|-----------|
| [externals/Git_Externals.md](externals/Git_Externals.md) | Overview | All Git externals |
| [externals/Git_Externals_Core.md](externals/Git_Externals_Core.md) | Core | spdlog, fmt, nlohmann_json |
| [externals/Git_Externals_GUI.md](externals/Git_Externals_GUI.md) | GUI | GLFW, ImGui |
| [externals/Git_Externals_Testing.md](externals/Git_Externals_Testing.md) | Testing | doctest, Catch2, GoogleTest |
| [externals/Git_Externals_Media.md](externals/Git_Externals_Media.md) | Media | stb |
| [externals/Git_Externals_Scripting.md](externals/Git_Externals_Scripting.md) | Scripting | sol2 |
| [externals/Git_Externals_AI.md](externals/Git_Externals_AI.md) | AI/ML | onnxruntime |
| [externals/Git_Externals_Data.md](externals/Git_Externals_Data.md) | Data | sqlite3, rapidjson |
| [externals/Git_Externals_Network.md](externals/Git_Externals_Network.md) | Network | cpr, asio |

### Local Externals

| File | Category | Libraries |
|------|----------|-----------|
| [externals/Local_Externals.md](externals/Local_Externals.md) | Overview | All local externals |
| [externals/Local_Externals_GUI.md](externals/Local_Externals_GUI.md) | GUI | Qt6 |
| [externals/Local_Externals_Media.md](externals/Local_Externals_Media.md) | Media | BASS |
| [externals/Local_Externals_Scripting.md](externals/Local_Externals_Scripting.md) | Scripting | Lua |
| [externals/Local_Externals_Testing.md](externals/Local_Externals_Testing.md) | Testing | doctest (local) |

---

## See Also

- [../../README.md](../../README.md) — English documentation overview
- [../blueprints/Reference.md](../../autorenwerk/blueprints/Reference.md) — Reference blueprint
- [../userguides/](../userguides/README.md) — Practical guides
