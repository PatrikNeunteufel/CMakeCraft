# Externals — Reference

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Externals.md](../../../de/guide/references/Externals.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Categories](#2-categories)
3. [Testing](#3-testing)
4. [Scripting](#4-scripting)
5. [GUI](#5-gui)
6. [Media](#6-media)
7. [Core](#7-core)
8. [Data](#8-data)
9. [Network](#9-network)
10. [AI](#10-ai)
11. [Quick Reference](#11-quick-reference)
12. [See Also](#12-see-also)
13. [Changelog](#changelog)

---

## 1. Overview

This reference provides a **categorized overview** of all available external libraries for the CMake Architecture build system.

### External Types

| Type | Source | Description |
|------|--------|-------------|
| **Local** | `path` | Precompiled/generated libraries in the `externals/` folder |
| **Git** | `git` | Libraries cloned via Git |

### Basic Usage

```json
{
    "externals": {
        "bass": { "path": "externals/bass" },
        "glad": { "path": "externals/glad" },
        "glfw": { 
            "git": "https://github.com/glfw/glfw.git",
            "tag": "3.4"
        }
    },
    "executables": [
        {
            "name": "MyApp",
            "externals": ["bass", "glad", "glfw"]
        }
    ]
}
```

---

## 2. Categories

### Overview

The categories are structured **in parallel for Local and Git**:

| Category | Local | Git | Main Use |
|----------|-------|-----|----------|
| [Testing](#3-testing) | doctest | googletest, catch2, benchmark | Unit tests, benchmarks |
| [Scripting](#4-scripting) | lua54 | sol2, pybind11, chaiscript | Embedded scripting |
| [GUI](#5-gui) | glad | glfw, imgui, SDL2/3, raylib | Graphics, window, UI |
| [Media](#6-media) | BASS | miniaudio, openal-soft, stb, glm | Audio, image, math |
| [Core](#7-core) | — | spdlog, fmt, abseil, magic_enum | Logging, utility |
| [Data](#8-data) | — | nlohmann_json, yaml-cpp, SQLiteCpp | JSON, DB, compression |
| [Network](#9-network) | — | cpp-httplib, asio, taskflow | HTTP, threading |
| [AI](#10-ai) | — | llama.cpp, whisper.cpp, onnxruntime | ML, LLM, CUDA |

### Detail Documents

| Category | Local | Git |
|----------|-------|-----|
| Testing | [Local_Externals_Testing.md](externals/Local_Externals_Testing.md) | [Git_Externals_Testing.md](externals/Git_Externals_Testing.md) |
| Scripting | [Local_Externals_Scripting.md](externals/Local_Externals_Scripting.md) | [Git_Externals_Scripting.md](externals/Git_Externals_Scripting.md) |
| GUI | [Local_Externals_GUI.md](externals/Local_Externals_GUI.md) | [Git_Externals_GUI.md](externals/Git_Externals_GUI.md) |
| Media | [Local_Externals_Media.md](externals/Local_Externals_Media.md) | [Git_Externals_Media.md](externals/Git_Externals_Media.md) |
| Core | — | [Git_Externals_Core.md](externals/Git_Externals_Core.md) |
| Data | — | [Git_Externals_Data.md](externals/Git_Externals_Data.md) |
| Network | — | [Git_Externals_Network.md](externals/Git_Externals_Network.md) |
| AI | — | [Git_Externals_AI.md](externals/Git_Externals_AI.md) |

---

## 3. Testing

### Local

| Library | Type | Description | Details |
|---------|------|-------------|---------|
| **doctest** | 📄 Header-only | Fast testing framework | [Local_Externals_Testing.md](externals/Local_Externals_Testing.md) |

### Git

| Library | Description | CMake | Hook | Details |
|---------|-------------|-------|------|---------|
| **googletest** | Google Test + GMock | ✅ | PreFetch | [Git_Externals_Testing.md](externals/Git_Externals_Testing.md) |
| **catch2** | BDD-style testing | ✅ | PreFetch | [Git_Externals_Testing.md](externals/Git_Externals_Testing.md) |
| **benchmark** | Google Benchmark | ✅ | PreFetch | [Git_Externals_Testing.md](externals/Git_Externals_Testing.md) |

### Recommendation

| Use Case | Recommendation |
|----------|----------------|
| Fast unit tests | **doctest** (Local) |
| Mocking needed | googletest (Git) |
| BDD style | catch2 (Git) |
| Performance tests | benchmark (Git) |

---

## 4. Scripting

### Local

| Library | Type | Description | Details |
|---------|------|-------------|---------|
| **lua54** | 📝 Source | Lua 5.4 scripting engine | [Local_Externals_Scripting.md](externals/Local_Externals_Scripting.md) |

### Git

| Library | Description | CMake | Hook | Details |
|---------|-------------|-------|------|---------|
| **sol2** | C++ Lua bindings | ✅ | — | [Git_Externals_Scripting.md](externals/Git_Externals_Scripting.md) |
| **pybind11** | Python bindings | ✅ | — | [Git_Externals_Scripting.md](externals/Git_Externals_Scripting.md) |
| **chaiscript** | Embedded scripting | ✅ | — | [Git_Externals_Scripting.md](externals/Git_Externals_Scripting.md) |

### Recommendation

| Use Case | Recommendation |
|----------|----------------|
| Configuration, modding | **lua54** (Local) + sol2 (Git) |
| Python integration | pybind11 (Git) |
| C++-like syntax | chaiscript (Git) |

---

## 5. GUI

### Local

| Library | Type | Description | Details |
|---------|------|-------------|---------|
| **glad** | 🔧 Generated | OpenGL function loader | [Local_Externals_GUI.md](externals/Local_Externals_GUI.md) |

### Git

| Library | Description | CMake | Hook | Details |
|---------|-------------|-------|------|---------|
| **glfw** | Window/input library | ✅ | PreFetch | [Git_Externals_GUI.md](externals/Git_Externals_GUI.md) |
| **imgui** | Immediate mode GUI | ❌ | PostFetch 🔧 | [Git_Externals_GUI.md](externals/Git_Externals_GUI.md) |
| **SDL2** | Multimedia library | ✅ | PreFetch | [Git_Externals_GUI.md](externals/Git_Externals_GUI.md) |
| **SDL3** | Multimedia (modern) | ✅ | PreFetch | [Git_Externals_GUI.md](externals/Git_Externals_GUI.md) |
| **raylib** | Game development | ✅ | PreFetch | [Git_Externals_GUI.md](externals/Git_Externals_GUI.md) |

### Typical Combination (OpenGL + ImGui)

```json
"externals": {
    "glad": { "path": "externals/glad" },
    "glfw": { "git": "https://github.com/glfw/glfw.git", "tag": "3.4" },
    "imgui": { "git": "https://github.com/ocornut/imgui.git", "tag": "v1.91.6", "cmakeSupport": false }
}
```

> **Order matters:** glad → glfw → imgui

---

## 6. Media

### Local

| Library | Type | Description | Details |
|---------|------|-------------|---------|
| **BASS** | 📦 Precompiled | Audio library with plugins | [Local_Externals_Media.md](externals/Local_Externals_Media.md) |

### Git

| Library | Description | CMake | Hook | Details |
|---------|-------------|-------|------|---------|
| **miniaudio** | Single-header audio | ❌ | PostFetch 🔧 | [Git_Externals_Media.md](externals/Git_Externals_Media.md) |
| **openal-soft** | 3D audio | ✅ | PreFetch | [Git_Externals_Media.md](externals/Git_Externals_Media.md) |
| **stb** | Image loading | ❌ | PostFetch 🔧 | [Git_Externals_Media.md](externals/Git_Externals_Media.md) |
| **glm** | OpenGL Mathematics | ✅ | PreFetch | [Git_Externals_Media.md](externals/Git_Externals_Media.md) |
| **Eigen** | Linear algebra | ✅ | PreFetch | [Git_Externals_Media.md](externals/Git_Externals_Media.md) |

### Recommendation

| Use Case | Recommendation |
|----------|----------------|
| Music player, plugins | **BASS** (Local) |
| Simple sounds | miniaudio (Git) |
| 3D game audio | openal-soft (Git) |

---

## 7. Core

### Git

| Library | Description | CMake | Hook | Details |
|---------|-------------|-------|------|---------|
| **spdlog** | Fast logging | ✅ | PreFetch | [Git_Externals_Core.md](externals/Git_Externals_Core.md) |
| **fmt** | String formatting | ✅ | PreFetch | [Git_Externals_Core.md](externals/Git_Externals_Core.md) |
| **abseil** | Google's C++ library | ✅ | PreFetch | [Git_Externals_Core.md](externals/Git_Externals_Core.md) |
| **magic_enum** | Enum reflection | ✅ | — | [Git_Externals_Core.md](externals/Git_Externals_Core.md) |
| **argparse** | Argument parsing | ✅ | — | [Git_Externals_Core.md](externals/Git_Externals_Core.md) |
| **CLI11** | CLI parsing | ✅ | PreFetch | [Git_Externals_Core.md](externals/Git_Externals_Core.md) |

---

## 8. Data

### Git

| Library | Description | CMake | Hook | Details |
|---------|-------------|-------|------|---------|
| **nlohmann_json** | JSON for Modern C++ | ✅ | PreFetch | [Git_Externals_Data.md](externals/Git_Externals_Data.md) |
| **rapidjson** | Fast JSON | ✅ | — | [Git_Externals_Data.md](externals/Git_Externals_Data.md) |
| **yaml-cpp** | YAML parser | ✅ | PreFetch | [Git_Externals_Data.md](externals/Git_Externals_Data.md) |
| **toml++** | TOML parser | ✅ | — | [Git_Externals_Data.md](externals/Git_Externals_Data.md) |
| **SQLiteCpp** | SQLite wrapper | ✅ | PreFetch | [Git_Externals_Data.md](externals/Git_Externals_Data.md) |
| **zstd** | Fast compression | ✅ | PreFetch | [Git_Externals_Data.md](externals/Git_Externals_Data.md) |

---

## 9. Network

### Git

| Library | Description | CMake | Hook | Details |
|---------|-------------|-------|------|---------|
| **cpp-httplib** | HTTP client/server | ✅ | — | [Git_Externals_Network.md](externals/Git_Externals_Network.md) |
| **cpr** | C++ Requests | ✅ | PreFetch | [Git_Externals_Network.md](externals/Git_Externals_Network.md) |
| **asio** | Async I/O | ⚠️ | PostFetch 🔧 | [Git_Externals_Network.md](externals/Git_Externals_Network.md) |
| **taskflow** | Parallel programming | ✅ | PreFetch | [Git_Externals_Network.md](externals/Git_Externals_Network.md) |
| **concurrentqueue** | Lock-free queue | ✅ | — | [Git_Externals_Network.md](externals/Git_Externals_Network.md) |

---

## 10. AI

### Git

| Library | Description | CMake | Hook | Details |
|---------|-------------|-------|------|---------|
| **llama.cpp** | LLM inference | ✅ | PreFetch | [Git_Externals_AI.md](externals/Git_Externals_AI.md) |
| **whisper.cpp** | Speech-to-text | ✅ | PreFetch | [Git_Externals_AI.md](externals/Git_Externals_AI.md) |
| **onnxruntime** | ML inference | ⚠️ | PreFetch | [Git_Externals_AI.md](externals/Git_Externals_AI.md) |
| **ncnn** | Neural network | ✅ | PreFetch | [Git_Externals_AI.md](externals/Git_Externals_AI.md) |

> **Note:** AI/ML libraries are often complex to integrate. See the detail documentation.

---

## 11. Quick Reference

### All Local Externals

| Library | Category | Type | Include.cmake |
|---------|----------|------|---------------|
| **doctest** | Testing | 📄 Header-only | `cmake/externals/includes/doctest/` |
| **lua54** | Scripting | 📝 Source | `cmake/externals/includes/lua54/` |
| **glad** | GUI | 🔧 Generated | `cmake/externals/includes/glad/` |
| **BASS** | Media | 📦 Precompiled | `cmake/externals/includes/bass/` |

### Popular Combinations

| Application | Externals |
|-------------|-----------|
| OpenGL GUI app | glad (L), glfw (G), imgui (G) |
| Audio player | BASS (L) + BASS_FLAC, BASS_FX |
| Scripted game | lua54 (L), sol2 (G), raylib (G) |
| REST API client | cpp-httplib (G), nlohmann_json (G) |
| Unit test suite | doctest (L) or googletest (G) |

*(L) = Local, (G) = Git*

---

## 12. See Also

### Overview Documents

- [Local_Externals.md](externals/Local_Externals.md) — Overview of local externals
- [Git_Externals.md](externals/Git_Externals.md) — Overview of Git externals

### Category Detail Documents

| Category | Local | Git |
|----------|-------|-----|
| Testing | [Local_Externals_Testing.md](externals/Local_Externals_Testing.md) | [Git_Externals_Testing.md](externals/Git_Externals_Testing.md) |
| Scripting | [Local_Externals_Scripting.md](externals/Local_Externals_Scripting.md) | [Git_Externals_Scripting.md](externals/Git_Externals_Scripting.md) |
| GUI | [Local_Externals_GUI.md](externals/Local_Externals_GUI.md) | [Git_Externals_GUI.md](externals/Git_Externals_GUI.md) |
| Media | [Local_Externals_Media.md](externals/Local_Externals_Media.md) | [Git_Externals_Media.md](externals/Git_Externals_Media.md) |
| Core | — | [Git_Externals_Core.md](externals/Git_Externals_Core.md) |
| Data | — | [Git_Externals_Data.md](externals/Git_Externals_Data.md) |
| Network | — | [Git_Externals_Network.md](externals/Git_Externals_Network.md) |
| AI | — | [Git_Externals_AI.md](externals/Git_Externals_AI.md) |

### Further References

- [Solution_Schema.md](Solution_Schema.md) — JSON schema for the externals block
- [Externals_UserGuide.md](../userguides/Externals.md) — Usage guide

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.2 | 2025-12-15 | 8 categories: Testing, Scripting, GUI, Media, Core, Data, Network, AI — in parallel for Local + Git |
| 0.5.0 | 2025-12-15 | Categorized overview for Local + Git externals |
