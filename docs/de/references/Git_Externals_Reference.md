# Git Externals — Referenz

> **Version:** 0.5.0  
> **Datum:** 2025-12-14  
> **Typ:** Reference  
> **Status:** Stabil  
> **Zielgruppe:** Alle Entwickler  
> **Sprache:** Deutsch  
> **English:** [Git_Externals_Reference.md](../../en/reference/Git_Externals_Reference.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Konventionen](#2-konventionen)
3. [Kategorien](#3-kategorien)
4. [Schnellreferenz](#4-schnellreferenz)
5. [Hook-Anforderungen](#5-hook-anforderungen)
6. [Verwendung](#6-verwendung)
7. [Siehe auch](#7-siehe-auch)
8. [Changelog](#8-changelog)

---

## 1. Übersicht

Diese Referenz listet externe Bibliotheken, die via Git gefetcht werden können. Für jede Bibliothek sind CMake-Support, Hook-Anforderungen und Beispielkonfiguration dokumentiert.

### Umfang

- **50+ Bibliotheken** in 15 Kategorien
- Vollständige Konfigurationsbeispiele
- PreFetch/PostFetch Hook-Vorlagen
- Kompatibilitätshinweise

### Dokumentstruktur

Die Bibliotheken sind nach Kategorien in separate Dokumente aufgeteilt:

| Dokument | Kategorien | Bibliotheken |
|----------|------------|--------------|
| [Git_Externals_Core.md](Git_Externals_Core.md) | Logging, Testing, Utility | spdlog, fmt, googletest, catch2, abseil, magic_enum |
| [Git_Externals_GUI.md](Git_Externals_GUI.md) | GUI, Graphics, Vulkan | glfw, imgui, SDL2/3, raylib, sokol, vulkan |
| [Git_Externals_Data.md](Git_Externals_Data.md) | JSON, Database, Compression | nlohmann_json, rapidjson, yaml-cpp, SQLiteCpp, zstd |
| [Git_Externals_Network.md](Git_Externals_Network.md) | Networking, Threading | cpp-httplib, cpr, asio, taskflow, concurrentqueue |
| [Git_Externals_Media.md](Git_Externals_Media.md) | Audio, Image, Math | miniaudio, openal-soft, stb, glm, Eigen |
| [Git_Externals_AI.md](Git_Externals_AI.md) | KI/ML, CUDA/GPU | llama.cpp, whisper.cpp, onnxruntime, thrust, cutlass |

---

## 2. Konventionen

### 2.1 Symbole

| Symbol | Bedeutung |
|--------|-----------|
| ✅ | Ja / Vorhanden / Empfohlen |
| ❌ | Nein / Nicht vorhanden |
| ⚠️ | Eingeschränkt / Komplex |
| 🔧 | Hook erforderlich |

### 2.2 Hook-Typen

| Hook | Wann benötigt |
|------|---------------|
| **PreFetch** | Options setzen (Examples/Tests deaktivieren) |
| **PostFetch** | Target manuell erstellen (kein CMakeLists.txt) |

### 2.3 Komplexitätsstufen

| Level | Symbol | Bedeutung |
|-------|--------|-----------|
| Einfach | 🟢 | Kein Hook nötig, direktes FetchContent |
| Mittel | 🟡 | PreFetch Hook empfohlen |
| Komplex | 🔴 | PostFetch Hook oder komplexe Konfiguration |

---

## 3. Kategorien

### 3.1 Core & Utility

Grundlegende Bibliotheken für Logging, Testing und allgemeine Entwicklung.

| Bibliothek | Zweck | CMake | Hook |
|------------|-------|-------|------|
| **spdlog** | Fast C++ logging library | ✅ | PreFetch |
| **fmt** | Modern formatting library | ✅ | PreFetch |
| **googletest** | Google's C++ test framework | ✅ | PreFetch |
| **catch2** | BDD-style testing | ✅ | PreFetch |
| **benchmark** | Micro-benchmarking | ✅ | PreFetch |
| **abseil** | Google's C++ common libraries | ✅ | PreFetch |
| **magic_enum** | Enum reflection | ✅ | – |
| **argparse** | Argument parser | ✅ | – |
| **CLI11** | Command line parser | ✅ | PreFetch |

→ Details: [Git_Externals_Core.md](Git_Externals_Core.md)

### 3.2 GUI & Graphics

Bibliotheken für grafische Benutzeroberflächen und Rendering.

| Bibliothek | Zweck | CMake | Hook |
|------------|-------|-------|------|
| **glfw** | Window & input handling | ✅ | PreFetch |
| **imgui** | Immediate mode GUI | ❌ | PostFetch 🔧 |
| **SDL2/SDL3** | Cross-platform multimedia | ✅ | PreFetch |
| **raylib** | Simple game programming | ✅ | PreFetch |
| **sokol** | Minimal cross-platform libs | ❌ | PostFetch 🔧 |

→ Details: [Git_Externals_GUI.md](Git_Externals_GUI.md)

### 3.3 Data & Serialization

JSON, YAML, Datenbanken und Kompression.

| Bibliothek | Zweck | CMake | Hook |
|------------|-------|-------|------|
| **nlohmann_json** | JSON for Modern C++ | ✅ | PreFetch |
| **rapidjson** | Fast JSON parser | ✅ | PreFetch |
| **simdjson** | SIMD-accelerated JSON | ✅ | PreFetch |
| **yaml-cpp** | YAML parser | ✅ | PreFetch |
| **tomlplusplus** | TOML parser | ✅ | – |
| **SQLiteCpp** | SQLite C++ wrapper | ✅ | PreFetch |
| **zstd** | Fast compression | ✅ | PreFetch |
| **lz4** | Extremely fast compression | ✅ | PreFetch |

→ Details: [Git_Externals_Data.md](Git_Externals_Data.md)

### 3.4 Networking & Threading

HTTP, WebSocket, Async-IO und Threading.

| Bibliothek | Zweck | CMake | Hook |
|------------|-------|-------|------|
| **cpp-httplib** | Header-only HTTP/HTTPS | ✅ | – |
| **cpr** | C++ Requests (curl wrapper) | ✅ | PreFetch |
| **asio** | Async I/O | ⚠️ | PostFetch 🔧 |
| **ixwebsocket** | WebSocket client/server | ✅ | PreFetch |
| **taskflow** | Parallel task programming | ✅ | PreFetch |
| **thread-pool** | Thread pool library | ✅ | – |
| **concurrentqueue** | Lock-free queue | ✅ | – |

→ Details: [Git_Externals_Network.md](Git_Externals_Network.md)

### 3.5 Media & Math

Audio, Bild-Verarbeitung und Mathematik.

| Bibliothek | Zweck | CMake | Hook |
|------------|-------|-------|------|
| **miniaudio** | Single-file audio | ❌ | PostFetch 🔧 |
| **openal-soft** | 3D audio API | ✅ | PreFetch |
| **stb** | Single-file image libs | ❌ | PostFetch 🔧 |
| **glm** | OpenGL Mathematics | ✅ | PreFetch |
| **Eigen** | Linear algebra | ✅ | PreFetch |
| **entt** | Entity Component System | ✅ | – |

→ Details: [Git_Externals_Media.md](Git_Externals_Media.md)

### 3.6 AI & GPU Computing

Machine Learning, LLM Inference und CUDA.

| Bibliothek | Zweck | CMake | Hook |
|------------|-------|-------|------|
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

## 4. Schnellreferenz

### 4.1 Kein Hook nötig (🟢 Einfach)

Header-only oder gut konfigurierte Libraries:

```
entt, magic_enum, argparse, tomlplusplus
thread-pool, concurrentqueue
cpp-httplib
vulkan-headers, volk, vma
```

### 4.2 PreFetch Hook empfohlen (🟡 Mittel)

Tests/Examples deaktivieren:

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

### 4.3 PostFetch Hook erforderlich (🔴 Komplex)

Kein CMakeLists.txt oder spezielle Konfiguration:

```
imgui (+ Varianten)
sokol
asio (standalone)
miniaudio
stb
```

---

## 5. Hook-Anforderungen

### 5.1 PreFetch Hook Template

```cmake
# cmake/externals/Hooks/PreFetch/${name}.cmake

# Tests/Examples deaktivieren
set(${NAME}_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(${NAME}_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(${NAME}_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(${NAME}_INSTALL OFF CACHE BOOL "" FORCE)
```

### 5.2 PostFetch Hook Template (Header-only)

```cmake
# cmake/externals/Hooks/PostFetch/${name}.cmake

add_library(${HOOK_EXTERNAL_NAME} INTERFACE)
target_include_directories(${HOOK_EXTERNAL_NAME} 
    INTERFACE "${HOOK_SOURCE_DIR}/include"
)
_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)
```

### 5.3 PostFetch Hook Template (Compiled)

```cmake
# cmake/externals/Hooks/PostFetch/${name}.cmake

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

## 6. Verwendung

### 6.1 Basic Fetched External

```json
"externals": {
    "spdlog": {
        "git": "https://github.com/gabime/spdlog.git",
        "tag": "v1.14.1"
    }
}
```

### 6.2 External ohne CMake-Support

```json
"externals": {
    "imgui": {
        "git": "https://github.com/ocornut/imgui.git",
        "tag": "v1.91.6",
        "cmakeSupport": false
    }
}
```

### 6.3 Hook-Wiederverwendung

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

## 7. Siehe auch

- [Externals.md](Externals.md) — Local Externals & Basics
- [Solution_Schema.md](Solution_Schema.md) — External-Konfiguration
- [HookLoader.cmake](../modules/externals/HookLoader_cmake.md) — Hook-System

### Kategorie-Dokumente

- [Git_Externals_Core.md](Git_Externals_Core.md) — Logging, Testing, Utility
- [Git_Externals_GUI.md](Git_Externals_GUI.md) — GUI, Graphics, Vulkan
- [Git_Externals_Data.md](Git_Externals_Data.md) — JSON, Database, Compression
- [Git_Externals_Network.md](Git_Externals_Network.md) — Networking, Threading
- [Git_Externals_Media.md](Git_Externals_Media.md) — Audio, Image, Math
- [Git_Externals_AI.md](Git_Externals_AI.md) — KI/ML, CUDA/GPU

---

## 8. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-14** | **Blueprint v0.5.0: Aufteilung in Kategorie-Dokumente, Hauptdokument als Übersicht, verbesserte Navigation** |
| 0.1.0 | 2025-12-10 | Initial: 50+ Externals in 15 Kategorien, Hook-Anforderungen, CUDA/AI Section |
