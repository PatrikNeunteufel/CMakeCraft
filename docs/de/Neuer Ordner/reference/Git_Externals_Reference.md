# Git Externals — Referenz

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Reference  
> **Status:** Sammlung  
> **Zielgruppe:** Alle Entwickler  
> **Sprache:** Deutsch  
> **English:** [Git_Externals_Reference.md](../../en/reference/Git_Externals_Reference.md)

Diese Referenz listet externe Bibliotheken, die via Git gefetcht werden können.

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Konventionen](#2-konventionen)
3. [Logging & Debugging](#3-logging--debugging)
4. [Testing](#4-testing)
5. [JSON & Serialisierung](#5-json--serialisierung)
6. [Windowing & Input](#6-windowing--input)
7. [GUI](#7-gui)
8. [Graphics & Rendering](#8-graphics--rendering)
9. [Math & Geometry](#9-math--geometry)
10. [Audio](#10-audio)
11. [Networking](#11-networking)
12. [Compression](#12-compression)
13. [Database](#13-database)
14. [Utilities](#14-utilities)
15. [Schnellreferenz](#15-schnellreferenz)
16. [Siehe auch](#16-siehe-auch)

---

## 1. Übersicht

Für jede Bibliothek sind CMake-Support, Hook-Anforderungen und Beispielkonfiguration dokumentiert.

---

## 2. Konventionen

### Symbole

| Symbol | Bedeutung |
|--------|-----------|
| ✅ | Ja / Vorhanden / Empfohlen |
| ❌ | Nein / Nicht vorhanden |
| ⚠️ | Eingeschränkt / Komplex |
| 🔧 | Hook erforderlich |

### Hook-Typen

| Hook | Wann benötigt |
|------|---------------|
| **PreFetch** | Options setzen (Examples/Tests deaktivieren) |
| **PostFetch** | Target manuell erstellen (kein CMakeLists.txt) |

---

## 3. Logging & Debugging

### spdlog

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/gabime/spdlog.git` |
| **Tag** | `v1.14.1` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |

```json
"spdlog": {
    "git": "https://github.com/gabime/spdlog.git",
    "tag": "v1.14.1"
}
```

**PreFetch Hook:**
```cmake
set(SPDLOG_BUILD_EXAMPLE OFF CACHE BOOL "" FORCE)
set(SPDLOG_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(SPDLOG_BUILD_BENCH OFF CACHE BOOL "" FORCE)
```

---

### fmt

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/fmtlib/fmt.git` |
| **Tag** | `10.2.1` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |

```json
"fmt": {
    "git": "https://github.com/fmtlib/fmt.git",
    "tag": "10.2.1"
}
```

---

## 4. Testing

### googletest

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/google/googletest.git` |
| **Tag** | `v1.14.0` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |

```json
"googletest": {
    "git": "https://github.com/google/googletest.git",
    "tag": "v1.14.0"
}
```

**PreFetch Hook:**
```cmake
set(BUILD_GMOCK ON CACHE BOOL "" FORCE)
set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
```

---

### Catch2

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/catchorg/Catch2.git` |
| **Tag** | `v3.5.2` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |

```json
"catch2": {
    "git": "https://github.com/catchorg/Catch2.git",
    "tag": "v3.5.2"
}
```

---

### benchmark (Google)

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/google/benchmark.git` |
| **Tag** | `v1.8.3` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |

```json
"benchmark": {
    "git": "https://github.com/google/benchmark.git",
    "tag": "v1.8.3"
}
```

---

## 5. JSON & Serialisierung

### nlohmann_json

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/nlohmann/json.git` |
| **Tag** | `v3.11.3` |
| **CMake Support** | ✅ |
| **Header-Only** | ✅ |

```json
"nlohmann_json": {
    "git": "https://github.com/nlohmann/json.git",
    "tag": "v3.11.3"
}
```

---

### rapidjson

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/Tencent/rapidjson.git` |
| **Tag** | `v1.1.0` |
| **CMake Support** | ✅ |
| **Header-Only** | ✅ |

```json
"rapidjson": {
    "git": "https://github.com/Tencent/rapidjson.git",
    "tag": "v1.1.0"
}
```

---

### simdjson

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/simdjson/simdjson.git` |
| **Tag** | `v3.6.3` |
| **CMake Support** | ✅ |

```json
"simdjson": {
    "git": "https://github.com/simdjson/simdjson.git",
    "tag": "v3.6.3"
}
```

---

### yaml-cpp

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/jbeder/yaml-cpp.git` |
| **Tag** | `0.8.0` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |

```json
"yaml-cpp": {
    "git": "https://github.com/jbeder/yaml-cpp.git",
    "tag": "0.8.0"
}
```

---

## 6. Windowing & Input

### GLFW

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/glfw/glfw.git` |
| **Tag** | `3.4` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |

```json
"glfw": {
    "git": "https://github.com/glfw/glfw.git",
    "tag": "3.4"
}
```

**PreFetch Hook:**
```cmake
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_INSTALL OFF CACHE BOOL "" FORCE)
```

---

### SDL2

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/libsdl-org/SDL.git` |
| **Tag** | `release-2.30.0` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |

```json
"sdl2": {
    "git": "https://github.com/libsdl-org/SDL.git",
    "tag": "release-2.30.0"
}
```

---

### SDL3

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/libsdl-org/SDL.git` |
| **Branch** | `main` |
| **CMake Support** | ✅ |
| **Status** | ⚠️ Beta |

```json
"sdl3": {
    "git": "https://github.com/libsdl-org/SDL.git",
    "branch": "main"
}
```

---

## 7. GUI

### Dear ImGui

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/ocornut/imgui.git` |
| **Tag** | `v1.91.6` |
| **CMake Support** | ❌ |
| **PostFetch Hook** | 🔧 PFLICHT |

```json
"imgui": {
    "git": "https://github.com/ocornut/imgui.git",
    "tag": "v1.91.6",
    "cmakeSupport": false
}
```

**Variante mit Docking:**
```json
"imgui_docking": {
    "git": "https://github.com/ocornut/imgui.git",
    "tag": "v1.91.6-docking",
    "cmakeSupport": false,
    "hook": "imgui"
}
```

---

### ImPlot

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/epezent/implot.git` |
| **Tag** | `v0.16` |
| **CMake Support** | ❌ |
| **PostFetch Hook** | 🔧 PFLICHT |
| **Abhängigkeiten** | imgui |

```json
"implot": {
    "git": "https://github.com/epezent/implot.git",
    "tag": "v0.16",
    "cmakeSupport": false
}
```

---

## 8. Graphics & Rendering

### glm

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/g-truc/glm.git` |
| **Tag** | `1.0.1` |
| **CMake Support** | ✅ |
| **Header-Only** | ✅ |

```json
"glm": {
    "git": "https://github.com/g-truc/glm.git",
    "tag": "1.0.1"
}
```

---

### stb

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/nothings/stb.git` |
| **Branch** | `master` |
| **CMake Support** | ❌ |
| **PostFetch Hook** | 🔧 PFLICHT |
| **Header-Only** | ✅ |

```json
"stb": {
    "git": "https://github.com/nothings/stb.git",
    "branch": "master",
    "cmakeSupport": false
}
```

---

### Vulkan-Headers

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/KhronosGroup/Vulkan-Headers.git` |
| **Tag** | `v1.3.275` |
| **CMake Support** | ✅ |

```json
"vulkan-headers": {
    "git": "https://github.com/KhronosGroup/Vulkan-Headers.git",
    "tag": "v1.3.275"
}
```

---

## 9. Math & Geometry

### Eigen

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://gitlab.com/libeigen/eigen.git` |
| **Tag** | `3.4.0` |
| **CMake Support** | ✅ |
| **Header-Only** | ✅ |

```json
"eigen": {
    "git": "https://gitlab.com/libeigen/eigen.git",
    "tag": "3.4.0"
}
```

---

## 10. Audio

### miniaudio

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/mackron/miniaudio.git` |
| **Tag** | `0.11.21` |
| **CMake Support** | ❌ |
| **PostFetch Hook** | 🔧 PFLICHT |
| **Header-Only** | ✅ |

```json
"miniaudio": {
    "git": "https://github.com/mackron/miniaudio.git",
    "tag": "0.11.21",
    "cmakeSupport": false
}
```

---

### OpenAL Soft

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/kcat/openal-soft.git` |
| **Tag** | `1.23.1` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |

```json
"openal-soft": {
    "git": "https://github.com/kcat/openal-soft.git",
    "tag": "1.23.1"
}
```

---

## 11. Networking

### Asio (standalone)

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/chriskohlhoff/asio.git` |
| **Tag** | `asio-1-29-0` |
| **CMake Support** | ❌ |
| **PostFetch Hook** | 🔧 PFLICHT |
| **Header-Only** | ✅ |

```json
"asio": {
    "git": "https://github.com/chriskohlhoff/asio.git",
    "tag": "asio-1-29-0",
    "cmakeSupport": false
}
```

---

### cpr (C++ Requests)

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/libcpr/cpr.git` |
| **Tag** | `1.10.5` |
| **CMake Support** | ✅ |
| **Abhängigkeiten** | libcurl |

```json
"cpr": {
    "git": "https://github.com/libcpr/cpr.git",
    "tag": "1.10.5"
}
```

---

## 12. Compression

### zstd

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/facebook/zstd.git` |
| **Tag** | `v1.5.5` |
| **CMake Support** | ✅ |
| **CMake Path** | `build/cmake` |

```json
"zstd": {
    "git": "https://github.com/facebook/zstd.git",
    "tag": "v1.5.5"
}
```

---

### lz4

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/lz4/lz4.git` |
| **Tag** | `v1.9.4` |
| **CMake Support** | ✅ |
| **CMake Path** | `build/cmake` |

```json
"lz4": {
    "git": "https://github.com/lz4/lz4.git",
    "tag": "v1.9.4"
}
```

---

## 13. Database

### SQLiteCpp

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/SRombauts/SQLiteCpp.git` |
| **Tag** | `3.3.1` |
| **CMake Support** | ✅ |
| **Abhängigkeiten** | SQLite3 (bundled) |

```json
"sqlitecpp": {
    "git": "https://github.com/SRombauts/SQLiteCpp.git",
    "tag": "3.3.1"
}
```

---

## 14. Utilities

### CLI11

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/CLIUtils/CLI11.git` |
| **Tag** | `v2.4.1` |
| **CMake Support** | ✅ |
| **Header-Only** | ✅ |

```json
"cli11": {
    "git": "https://github.com/CLIUtils/CLI11.git",
    "tag": "v2.4.1"
}
```

---

### Taskflow

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/taskflow/taskflow.git` |
| **Tag** | `v3.6.0` |
| **CMake Support** | ✅ |
| **Header-Only** | ✅ |

```json
"taskflow": {
    "git": "https://github.com/taskflow/taskflow.git",
    "tag": "v3.6.0"
}
```

---

### Abseil

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/abseil/abseil-cpp.git` |
| **Tag** | `20240116.1` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |

```json
"abseil": {
    "git": "https://github.com/abseil/abseil-cpp.git",
    "tag": "20240116.1"
}
```

---

## 15. Schnellreferenz

### PreFetch Hook empfohlen

Tests/Examples deaktivieren:

| Kategorie | Externals |
|-----------|-----------|
| Logging | spdlog, fmt |
| Testing | googletest, catch2, benchmark |
| JSON | nlohmann_json, rapidjson, yaml-cpp |
| Window | glfw, sdl2 |
| Math | glm, eigen, taskflow |
| Network | cpr |
| Compress | zstd, lz4 |
| Utils | cli11, abseil |

### PostFetch Hook erforderlich 🔧

Kein CMakeLists.txt:

| External | Grund |
|----------|-------|
| imgui | Kein CMake, Backends wählbar |
| implot | Kein CMake, imgui-abhängig |
| stb | Header-only Collection |
| asio | Standalone Header-only |
| miniaudio | Single-Header Library |
| sokol | Header-only Collection |

---

## 16. Siehe auch

- [Externals.md](Externals.md) — External-Übersicht
- [Solution_Schema.md](Solution_Schema.md) — JSON-Schema
- [Adding_Externals_UserGuide.md](../guides/Adding_Externals_UserGuide.md) — Neue Externals hinzufügen

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Reference Blueprint v0.5.0 Format, kompaktere Struktur** |
| 0.1.0 | 2025-12-10 | Initial: 50+ Externals |
