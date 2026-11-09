# Git Externals — Overview

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Git_Externals.md](../../../../de/guide/references/externals/Git_Externals.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Conventions](#2-conventions)
3. [Categories](#3-categories)
4. [Quick Reference](#4-quick-reference)
5. [Hook Requirements](#5-hook-requirements)
6. [Usage](#6-usage)
7. [See Also](#7-see-also)
8. [Changelog](#changelog)

---

## 1. Overview

This reference lists external libraries that can be fetched via Git. For each library, CMake support, hook requirements and an example configuration are documented.

### Scope

- **50+ libraries** in 8 categories
- Complete configuration examples
- PreFetch/PostFetch hook templates
- Compatibility notes

### Document Structure

The libraries are split by category into separate documents — **parallel to the Local categories**:

| Document | Category | Libraries | Local Counterpart |
|----------|----------|-----------|-------------------|
| [Git_Externals_Testing.md](Git_Externals_Testing.md) | Testing | googletest, catch2, benchmark | Local_Externals_Testing.md |
| [Git_Externals_Scripting.md](Git_Externals_Scripting.md) | Scripting | sol2, pybind11, chaiscript | Local_Externals_Scripting.md |
| [Git_Externals_GUI.md](Git_Externals_GUI.md) | GUI | glfw, imgui, SDL2, raylib | Local_Externals_GUI.md |
| [Git_Externals_Media.md](Git_Externals_Media.md) | Media | miniaudio, openal-soft, stb, glm | Local_Externals_Media.md |
| [Git_Externals_Core.md](Git_Externals_Core.md) | Core | spdlog, fmt, abseil, magic_enum | — |
| [Git_Externals_Data.md](Git_Externals_Data.md) | Data | nlohmann_json, yaml-cpp, SQLiteCpp | — |
| [Git_Externals_Network.md](Git_Externals_Network.md) | Network | cpp-httplib, asio, taskflow | — |
| [Git_Externals_AI.md](Git_Externals_AI.md) | AI | llama.cpp, whisper.cpp, onnxruntime | — |

---

## 2. Conventions

### 2.1 Symbols

| Symbol | Meaning |
|--------|---------|
| ✅ | Yes / Available / Recommended |
| ❌ | No / Not available |
| ⚠️ | Limited / Complex |
| 🔧 | Hook required |

### 2.2 Hook Types

| Hook | When needed |
|------|-------------|
| **PreFetch** | Set options (disable examples/tests) |
| **PostFetch** | Create target manually (no CMakeLists.txt) |

### 2.3 Complexity Levels

| Level | Symbol | Meaning |
|-------|--------|---------|
| Simple | 🟢 | No hook needed, direct FetchContent |
| Medium | 🟡 | PreFetch hook recommended |
| Complex | 🔴 | PostFetch hook or complex configuration |

---

## 3. Categories

### 3.1 Testing

Unit testing, mocking and benchmarking.

| Library | Purpose | CMake | Hook |
|---------|---------|-------|------|
| **googletest** | Google Test + GMock | ✅ | PreFetch |
| **catch2** | BDD-style testing | ✅ | PreFetch |
| **benchmark** | Micro-benchmarking | ✅ | PreFetch |

→ Details: [Git_Externals_Testing.md](Git_Externals_Testing.md)

### 3.2 Scripting

C++ bindings for scripting languages.

| Library | Purpose | CMake | Hook |
|---------|---------|-------|------|
| **sol2** | C++ Lua Bindings | ✅ | — |
| **pybind11** | Python Bindings | ✅ | — |
| **chaiscript** | Embedded Scripting | ✅ | — |

→ Details: [Git_Externals_Scripting.md](Git_Externals_Scripting.md)

### 3.3 GUI & Graphics

Libraries for graphical user interfaces and rendering.

| Library | Purpose | CMake | Hook |
|---------|---------|-------|------|
| **glfw** | Window & input handling | ✅ | PreFetch |
| **imgui** | Immediate mode GUI | ❌ | PostFetch 🔧 |
| **SDL2/SDL3** | Cross-platform multimedia | ✅ | PreFetch |
| **raylib** | Simple game programming | ✅ | PreFetch |
| **sokol** | Minimal cross-platform libs | ❌ | PostFetch 🔧 |

→ Details: [Git_Externals_GUI.md](Git_Externals_GUI.md)

### 3.4 Media & Math

Audio, image processing and mathematics.

| Library | Purpose | CMake | Hook |
|---------|---------|-------|------|
| **miniaudio** | Single-file audio | ❌ | PostFetch 🔧 |
| **openal-soft** | 3D audio API | ✅ | PreFetch |
| **stb** | Single-file image libs | ❌ | PostFetch 🔧 |
| **glm** | OpenGL Mathematics | ✅ | PreFetch |
| **Eigen** | Linear algebra | ✅ | PreFetch |
| **entt** | Entity Component System | ✅ | — |

→ Details: [Git_Externals_Media.md](Git_Externals_Media.md)

### 3.5 Core & Utility

Logging, formatting and general development.

| Library | Purpose | CMake | Hook |
|---------|---------|-------|------|
| **spdlog** | Fast C++ logging library | ✅ | PreFetch |
| **fmt** | Modern formatting library | ✅ | PreFetch |
| **abseil** | Google's C++ common libraries | ✅ | PreFetch |
| **magic_enum** | Enum reflection | ✅ | — |
| **argparse** | Argument parser | ✅ | — |
| **CLI11** | Command line parser | ✅ | PreFetch |

→ Details: [Git_Externals_Core.md](Git_Externals_Core.md)

### 3.6 Data & Serialization

JSON, YAML, databases and compression.

| Library | Purpose | CMake | Hook |
|---------|---------|-------|------|
| **nlohmann_json** | JSON for Modern C++ | ✅ | PreFetch |
| **rapidjson** | Fast JSON parser | ✅ | PreFetch |
| **simdjson** | SIMD-accelerated JSON | ✅ | PreFetch |
| **yaml-cpp** | YAML parser | ✅ | PreFetch |
| **tomlplusplus** | TOML parser | ✅ | — |
| **SQLiteCpp** | SQLite C++ wrapper | ✅ | PreFetch |
| **zstd** | Fast compression | ✅ | PreFetch |
| **lz4** | Extremely fast compression | ✅ | PreFetch |

→ Details: [Git_Externals_Data.md](Git_Externals_Data.md)

### 3.7 Networking & Threading

HTTP, WebSocket, async I/O and threading.

| Library | Purpose | CMake | Hook |
|---------|---------|-------|------|
| **cpp-httplib** | Header-only HTTP/HTTPS | ✅ | — |
| **cpr** | C++ Requests (curl wrapper) | ✅ | PreFetch |
| **asio** | Async I/O | ⚠️ | PostFetch 🔧 |
| **ixwebsocket** | WebSocket client/server | ✅ | PreFetch |
| **taskflow** | Parallel task programming | ✅ | PreFetch |
| **thread-pool** | Thread pool library | ✅ | — |
| **concurrentqueue** | Lock-free queue | ✅ | — |

→ Details: [Git_Externals_Network.md](Git_Externals_Network.md)

### 3.8 AI & GPU Computing

Machine learning, LLM inference and CUDA.

| Library | Purpose | CMake | Hook |
|---------|---------|-------|------|
| **llama.cpp** | LLM inference | ✅ | PreFetch |
| **whisper.cpp** | Speech recognition | ✅ | PreFetch |
| **ggml** | Tensor library | ✅ | PreFetch |
| **onnxruntime** | ONNX inference | ⚠️ | PreFetch |
| **thrust** | CUDA parallel algorithms | ✅ | PreFetch |
| **cub** | CUDA building blocks | ✅ | PreFetch |
| **cutlass** | CUDA linear algebra | ✅ | PreFetch |
| **ncnn** | Neural network inference | ✅ | PreFetch |

→ Details: [Git_Externals_AI.md](Git_Externals_AI.md)

---

## 4. Quick Reference

### 4.1 No Hook Needed (🟢 Simple)

Header-only or well-configured libraries:

```
entt, magic_enum, argparse, tomlplusplus
thread-pool, concurrentqueue, cpp-httplib
sol2, pybind11, chaiscript
```

### 4.2 PreFetch Hook Recommended (🟡 Medium)

Disable tests/examples:

```
spdlog, fmt, glfw, sdl2, raylib
googletest, catch2, benchmark
nlohmann_json, rapidjson, simdjson, yaml-cpp
glm, eigen, taskflow
cpr, cli11, sqlitecpp
openal-soft, zstd, lz4
abseil, ixwebsocket
llama_cpp, whisper_cpp, ggml, ncnn
thrust, cub, cutlass
```

### 4.3 PostFetch Hook Required (🔴 Complex)

No CMakeLists.txt or special configuration:

```
imgui (+ variants)
sokol
asio (standalone)
miniaudio
stb
```

---

## 5. Hook Requirements

### 5.1 PreFetch Hook Template

```cmake
# cmake/externals/hooks/prefetch/${name}.cmake

# Disable tests/examples
set(${NAME}_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(${NAME}_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(${NAME}_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(${NAME}_INSTALL OFF CACHE BOOL "" FORCE)
```

### 5.2 PostFetch Hook Template (Header-only)

```cmake
# cmake/externals/hooks/postfetch/${name}.cmake

add_library(${HOOK_EXTERNAL_NAME} INTERFACE)
target_include_directories(${HOOK_EXTERNAL_NAME} 
    INTERFACE "${HOOK_SOURCE_DIR}/include"
)
_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)
```

### 5.3 PostFetch Hook Template (Compiled)

```cmake
# cmake/externals/hooks/postfetch/${name}.cmake

add_library(${HOOK_EXTERNAL_NAME} STATIC
    "${HOOK_SOURCE_DIR}/src/file1.cpp"
    "${HOOK_SOURCE_DIR}/src/file2.cpp"
)
target_include_directories(${HOOK_EXTERNAL_NAME} 
    PUBLIC "${HOOK_SOURCE_DIR}/include"
)
_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)
```

---

## 6. Usage

### 6.1 Basic Fetched External

```json
"externals": {
    "spdlog": {
        "git": "https://github.com/gabime/spdlog.git",
        "tag": "v1.14.1"
    }
}
```

### 6.2 External Without CMake Support

```json
"externals": {
    "imgui": {
        "git": "https://github.com/ocornut/imgui.git",
        "tag": "v1.91.6",
        "cmakeSupport": false
    }
}
```

### 6.3 Hook Reuse

```json
"externals": {
    "imgui": {
        "git": "https://github.com/ocornut/imgui.git",
        "tag": "v1.91.6",
        "cmakeSupport": false
    },
    "imgui_docking": {
        "git": "https://github.com/ocornut/imgui.git",
        "tag": "v1.91.6-docking",
        "cmakeSupport": false,
        "hook": "imgui"
    }
}
```

---

## 7. See Also

- [Externals.md](../Externals.md) — Main overview (Local + Git)
- [Local_Externals.md](Local_Externals.md) — Local Externals overview
- [Solution_Schema.md](../Solution_Schema.md) — External configuration
- [HookLoader_cmake.md](../../module/externals/hooks/HookLoader_cmake.md) — Hook system

### Category Documents

- [Git_Externals_Testing.md](Git_Externals_Testing.md) — googletest, catch2, benchmark
- [Git_Externals_Scripting.md](Git_Externals_Scripting.md) — sol2, pybind11, chaiscript
- [Git_Externals_GUI.md](Git_Externals_GUI.md) — glfw, imgui, SDL2, raylib
- [Git_Externals_Media.md](Git_Externals_Media.md) — miniaudio, openal-soft, stb, glm
- [Git_Externals_Core.md](Git_Externals_Core.md) — spdlog, fmt, abseil
- [Git_Externals_Data.md](Git_Externals_Data.md) — nlohmann_json, yaml-cpp, SQLiteCpp
- [Git_Externals_Network.md](Git_Externals_Network.md) — cpp-httplib, asio, taskflow
- [Git_Externals_AI.md](Git_Externals_AI.md) — llama.cpp, whisper.cpp, onnxruntime

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.2 | 2025-12-15 | 8 categories: Testing, Scripting, GUI, Media, Core, Data, Network, AI — parallel to Local |
| 0.5.0 | 2025-12-14 | Split into category documents |
| 0.1.0 | 2025-12-10 | Initial: 50+ externals in 15 categories |
