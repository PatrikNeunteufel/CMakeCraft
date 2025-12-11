# Externe Bibliotheken – Referenz für Git-Fetched Externals

> **Version:** 0.1.0  
> **Datum:** 2025-12-10  
> **Typ:** Referenz-Doku  
> **Status:** Sammlung  
> **Sprache:** Deutsch

---

## Übersicht

Diese Referenz listet externe Bibliotheken, die via Git gefetcht werden können. Für jede Bibliothek sind CMake-Support, Hook-Anforderungen und Beispielkonfiguration dokumentiert.

### Legende

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

## 1. Logging & Debugging

### spdlog

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/gabime/spdlog.git` |
| **Aktueller Tag** | `v1.14.1` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |
| **Abhängigkeiten** | fmt (optional, bundled) |

```json
"spdlog": {
    "git": "https://github.com/gabime/spdlog.git",
    "tag": "v1.14.1"
}
```

**PreFetch Hook (spdlog.cmake):**
```cmake
set(SPDLOG_BUILD_EXAMPLE OFF CACHE BOOL "" FORCE)
set(SPDLOG_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(SPDLOG_BUILD_BENCH OFF CACHE BOOL "" FORCE)
set(SPDLOG_INSTALL OFF CACHE BOOL "" FORCE)
# Optional: Externe fmt verwenden
# set(SPDLOG_FMT_EXTERNAL ON CACHE BOOL "" FORCE)
```

---

### fmt

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/fmtlib/fmt.git` |
| **Aktueller Tag** | `10.2.1` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |

```json
"fmt": {
    "git": "https://github.com/fmtlib/fmt.git",
    "tag": "10.2.1"
}
```

**PreFetch Hook (fmt.cmake):**
```cmake
set(FMT_DOC OFF CACHE BOOL "" FORCE)
set(FMT_TEST OFF CACHE BOOL "" FORCE)
set(FMT_INSTALL OFF CACHE BOOL "" FORCE)
```

---

## 2. Testing

### googletest

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/google/googletest.git` |
| **Aktueller Tag** | `v1.14.0` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |
| **Targets** | `gtest`, `gtest_main`, `gmock`, `gmock_main` |

```json
"googletest": {
    "git": "https://github.com/google/googletest.git",
    "tag": "v1.14.0"
}
```

**PreFetch Hook (googletest.cmake):**
```cmake
set(BUILD_GMOCK ON CACHE BOOL "" FORCE)
set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
# Windows: Prevent overriding parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
```

---

### Catch2

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/catchorg/Catch2.git` |
| **Aktueller Tag** | `v3.5.2` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |
| **Targets** | `Catch2`, `Catch2WithMain` |

```json
"catch2": {
    "git": "https://github.com/catchorg/Catch2.git",
    "tag": "v3.5.2"
}
```

**PreFetch Hook (catch2.cmake):**
```cmake
set(CATCH_BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(CATCH_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(CATCH_INSTALL_DOCS OFF CACHE BOOL "" FORCE)
set(CATCH_INSTALL_EXTRAS OFF CACHE BOOL "" FORCE)
```

---

### benchmark (Google)

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/google/benchmark.git` |
| **Aktueller Tag** | `v1.8.3` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Erforderlich |
| **PostFetch Hook** | ❌ |

```json
"benchmark": {
    "git": "https://github.com/google/benchmark.git",
    "tag": "v1.8.3"
}
```

**PreFetch Hook (benchmark.cmake):**
```cmake
set(BENCHMARK_ENABLE_TESTING OFF CACHE BOOL "" FORCE)
set(BENCHMARK_ENABLE_INSTALL OFF CACHE BOOL "" FORCE)
set(BENCHMARK_ENABLE_GTEST_TESTS OFF CACHE BOOL "" FORCE)
set(BENCHMARK_USE_BUNDLED_GTEST OFF CACHE BOOL "" FORCE)
```

---

## 3. GUI / Graphics

### glfw

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/glfw/glfw.git` |
| **Aktueller Tag** | `3.4` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Erforderlich |
| **PostFetch Hook** | ❌ |
| **Target** | `glfw` |

```json
"glfw": {
    "git": "https://github.com/glfw/glfw.git",
    "tag": "3.4"
}
```

**PreFetch Hook (glfw.cmake):**
```cmake
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_INSTALL OFF CACHE BOOL "" FORCE)
```

---

### imgui

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/ocornut/imgui.git` |
| **Aktueller Tag** | `v1.91.6` (stable), `v1.91.6-docking` (docking) |
| **CMake Support** | ❌ |
| **PreFetch Hook** | ❌ |
| **PostFetch Hook** | ✅ Erforderlich 🔧 |
| **Abhängigkeiten** | Backend (GLFW, SDL, etc.) + Renderer (OpenGL, Vulkan, etc.) |

```json
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
```

**PostFetch Hook:** Siehe `cmake/externals/Hooks/PostFetch/imgui.cmake`

---

### SDL2 / SDL3

| Aspekt | SDL2 | SDL3 |
|--------|------|------|
| **Repository** | `https://github.com/libsdl-org/SDL.git` | `https://github.com/libsdl-org/SDL.git` |
| **Aktueller Tag** | `release-2.30.0` | `release-3.2.0` |
| **CMake Support** | ✅ | ✅ |
| **PreFetch Hook** | ✅ Empfohlen | ✅ Empfohlen |
| **PostFetch Hook** | ❌ | ❌ |

```json
"sdl2": {
    "git": "https://github.com/libsdl-org/SDL.git",
    "tag": "release-2.30.0"
}
```

**PreFetch Hook (sdl2.cmake):**
```cmake
set(SDL_TEST OFF CACHE BOOL "" FORCE)
set(SDL_TESTS OFF CACHE BOOL "" FORCE)
set(SDL2_DISABLE_INSTALL ON CACHE BOOL "" FORCE)
```

---

### raylib

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/raysan5/raylib.git` |
| **Aktueller Tag** | `5.0` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |

```json
"raylib": {
    "git": "https://github.com/raysan5/raylib.git",
    "tag": "5.0"
}
```

**PreFetch Hook (raylib.cmake):**
```cmake
set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(BUILD_GAMES OFF CACHE BOOL "" FORCE)
```

---

### sokol

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/floooh/sokol.git` |
| **Aktueller Tag** | Kein Tag (branch: master) |
| **CMake Support** | ❌ (Header-only) |
| **PreFetch Hook** | ❌ |
| **PostFetch Hook** | ✅ Erforderlich 🔧 |

```json
"sokol": {
    "git": "https://github.com/floooh/sokol.git",
    "branch": "master",
    "cmakeSupport": false
}
```

**PostFetch Hook (sokol.cmake):**
```cmake
add_library(${HOOK_EXTERNAL_NAME} INTERFACE)
target_include_directories(${HOOK_EXTERNAL_NAME} INTERFACE "${HOOK_SOURCE_DIR}")
_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)
```

---

## 4. JSON / Serialisierung

### nlohmann/json

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/nlohmann/json.git` |
| **Aktueller Tag** | `v3.11.3` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |
| **Target** | `nlohmann_json::nlohmann_json` |

```json
"nlohmann_json": {
    "git": "https://github.com/nlohmann/json.git",
    "tag": "v3.11.3"
}
```

**PreFetch Hook (nlohmann_json.cmake):**
```cmake
set(JSON_BuildTests OFF CACHE BOOL "" FORCE)
set(JSON_Install OFF CACHE BOOL "" FORCE)
set(JSON_MultipleHeaders OFF CACHE BOOL "" FORCE)
```

---

### rapidjson

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/Tencent/rapidjson.git` |
| **Aktueller Tag** | `v1.1.0` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |

```json
"rapidjson": {
    "git": "https://github.com/Tencent/rapidjson.git",
    "tag": "v1.1.0"
}
```

**PreFetch Hook (rapidjson.cmake):**
```cmake
set(RAPIDJSON_BUILD_DOC OFF CACHE BOOL "" FORCE)
set(RAPIDJSON_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(RAPIDJSON_BUILD_TESTS OFF CACHE BOOL "" FORCE)
```

---

### simdjson

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/simdjson/simdjson.git` |
| **Aktueller Tag** | `v3.6.3` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |

```json
"simdjson": {
    "git": "https://github.com/simdjson/simdjson.git",
    "tag": "v3.6.3"
}
```

**PreFetch Hook (simdjson.cmake):**
```cmake
set(SIMDJSON_BUILD_STATIC ON CACHE BOOL "" FORCE)
set(SIMDJSON_DEVELOPER_MODE OFF CACHE BOOL "" FORCE)
```

---

### tomlplusplus

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/marzer/tomlplusplus.git` |
| **Aktueller Tag** | `v3.4.0` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ❌ |
| **PostFetch Hook** | ❌ |

```json
"tomlplusplus": {
    "git": "https://github.com/marzer/tomlplusplus.git",
    "tag": "v3.4.0"
}
```

---

### yaml-cpp

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/jbeder/yaml-cpp.git` |
| **Aktueller Tag** | `0.8.0` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |

```json
"yaml-cpp": {
    "git": "https://github.com/jbeder/yaml-cpp.git",
    "tag": "0.8.0"
}
```

**PreFetch Hook (yaml-cpp.cmake):**
```cmake
set(YAML_CPP_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(YAML_CPP_BUILD_TOOLS OFF CACHE BOOL "" FORCE)
set(YAML_CPP_BUILD_CONTRIB OFF CACHE BOOL "" FORCE)
set(YAML_CPP_INSTALL OFF CACHE BOOL "" FORCE)
```

---

## 5. Networking / HTTP

### cpp-httplib

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/yhirose/cpp-httplib.git` |
| **Aktueller Tag** | `v0.15.3` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ❌ |
| **PostFetch Hook** | ❌ |
| **Header-only** | ✅ |

```json
"cpp-httplib": {
    "git": "https://github.com/yhirose/cpp-httplib.git",
    "tag": "v0.15.3"
}
```

---

### cpr (C++ Requests)

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/libcpr/cpr.git` |
| **Aktueller Tag** | `1.10.5` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |
| **Abhängigkeiten** | libcurl (bundled oder system) |

```json
"cpr": {
    "git": "https://github.com/libcpr/cpr.git",
    "tag": "1.10.5"
}
```

**PreFetch Hook (cpr.cmake):**
```cmake
set(CPR_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(CPR_BUILD_TESTS_SSL OFF CACHE BOOL "" FORCE)
set(CPR_USE_SYSTEM_CURL OFF CACHE BOOL "" FORCE)  # Bundled curl verwenden
```

---

### asio (Standalone)

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/chriskohlhoff/asio.git` |
| **Aktueller Tag** | `asio-1-29-0` |
| **CMake Support** | ⚠️ (Header-only, kein native CMake) |
| **PreFetch Hook** | ❌ |
| **PostFetch Hook** | ✅ Empfohlen 🔧 |

```json
"asio": {
    "git": "https://github.com/chriskohlhoff/asio.git",
    "tag": "asio-1-29-0",
    "cmakeSupport": false
}
```

**PostFetch Hook (asio.cmake):**
```cmake
add_library(${HOOK_EXTERNAL_NAME} INTERFACE)
target_include_directories(${HOOK_EXTERNAL_NAME} INTERFACE "${HOOK_SOURCE_DIR}/asio/include")
target_compile_definitions(${HOOK_EXTERNAL_NAME} INTERFACE ASIO_STANDALONE)
_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)
```

---

### ixwebsocket

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/machinezone/IXWebSocket.git` |
| **Aktueller Tag** | `v11.4.4` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |

```json
"ixwebsocket": {
    "git": "https://github.com/machinezone/IXWebSocket.git",
    "tag": "v11.4.4"
}
```

**PreFetch Hook (ixwebsocket.cmake):**
```cmake
set(USE_TLS ON CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
```

---

## 6. Math / Geometry

### glm

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/g-truc/glm.git` |
| **Aktueller Tag** | `1.0.1` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |
| **Header-only** | ✅ |

```json
"glm": {
    "git": "https://github.com/g-truc/glm.git",
    "tag": "1.0.1"
}
```

**PreFetch Hook (glm.cmake):**
```cmake
set(GLM_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)
```

---

### Eigen

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://gitlab.com/libeigen/eigen.git` |
| **Aktueller Tag** | `3.4.0` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |
| **Header-only** | ✅ |

```json
"eigen": {
    "git": "https://gitlab.com/libeigen/eigen.git",
    "tag": "3.4.0"
}
```

**PreFetch Hook (eigen.cmake):**
```cmake
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(EIGEN_BUILD_DOC OFF CACHE BOOL "" FORCE)
set(EIGEN_BUILD_PKGCONFIG OFF CACHE BOOL "" FORCE)
```

---

### entt

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/skypjack/entt.git` |
| **Aktueller Tag** | `v3.13.2` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ❌ |
| **PostFetch Hook** | ❌ |
| **Header-only** | ✅ |

```json
"entt": {
    "git": "https://github.com/skypjack/entt.git",
    "tag": "v3.13.2"
}
```

---

## 7. Utility / General

### abseil-cpp

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/abseil/abseil-cpp.git` |
| **Aktueller Tag** | `20240116.2` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Erforderlich |
| **PostFetch Hook** | ❌ |

```json
"abseil": {
    "git": "https://github.com/abseil/abseil-cpp.git",
    "tag": "20240116.2"
}
```

**PreFetch Hook (abseil.cmake):**
```cmake
set(ABSL_BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(ABSL_USE_GOOGLETEST_HEAD OFF CACHE BOOL "" FORCE)
set(ABSL_ENABLE_INSTALL OFF CACHE BOOL "" FORCE)
set(ABSL_PROPAGATE_CXX_STD ON CACHE BOOL "" FORCE)
```

---

### magic_enum

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/Neargye/magic_enum.git` |
| **Aktueller Tag** | `v0.9.5` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ❌ |
| **PostFetch Hook** | ❌ |
| **Header-only** | ✅ |

```json
"magic_enum": {
    "git": "https://github.com/Neargye/magic_enum.git",
    "tag": "v0.9.5"
}
```

---

### argparse

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/p-ranav/argparse.git` |
| **Aktueller Tag** | `v3.0` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ❌ |
| **PostFetch Hook** | ❌ |
| **Header-only** | ✅ |

```json
"argparse": {
    "git": "https://github.com/p-ranav/argparse.git",
    "tag": "v3.0"
}
```

---

### CLI11

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/CLIUtils/CLI11.git` |
| **Aktueller Tag** | `v2.4.1` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |
| **Header-only** | ✅ |

```json
"cli11": {
    "git": "https://github.com/CLIUtils/CLI11.git",
    "tag": "v2.4.1"
}
```

**PreFetch Hook (cli11.cmake):**
```cmake
set(CLI11_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(CLI11_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(CLI11_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
```

---

## 8. Compression

### zstd

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/facebook/zstd.git` |
| **Aktueller Tag** | `v1.5.5` |
| **CMake Support** | ✅ (in build/cmake) |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |

```json
"zstd": {
    "git": "https://github.com/facebook/zstd.git",
    "tag": "v1.5.5"
}
```

**Hinweis:** CMakeLists.txt ist in `build/cmake/`, daher:
```cmake
# In FetchContent
FetchContent_Declare(zstd
    GIT_REPOSITORY https://github.com/facebook/zstd.git
    GIT_TAG v1.5.5
    SOURCE_SUBDIR build/cmake
)
```

**PreFetch Hook (zstd.cmake):**
```cmake
set(ZSTD_BUILD_PROGRAMS OFF CACHE BOOL "" FORCE)
set(ZSTD_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(ZSTD_BUILD_SHARED OFF CACHE BOOL "" FORCE)
set(ZSTD_BUILD_STATIC ON CACHE BOOL "" FORCE)
```

---

### lz4

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/lz4/lz4.git` |
| **Aktueller Tag** | `v1.9.4` |
| **CMake Support** | ✅ (in build/cmake) |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |

```json
"lz4": {
    "git": "https://github.com/lz4/lz4.git",
    "tag": "v1.9.4"
}
```

**Hinweis:** SOURCE_SUBDIR `build/cmake` erforderlich.

---

## 9. Audio

### miniaudio

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/mackron/miniaudio.git` |
| **Aktueller Tag** | `0.11.21` |
| **CMake Support** | ❌ (Single-header) |
| **PreFetch Hook** | ❌ |
| **PostFetch Hook** | ✅ Erforderlich 🔧 |

```json
"miniaudio": {
    "git": "https://github.com/mackron/miniaudio.git",
    "tag": "0.11.21",
    "cmakeSupport": false
}
```

**PostFetch Hook (miniaudio.cmake):**
```cmake
add_library(${HOOK_EXTERNAL_NAME} INTERFACE)
target_include_directories(${HOOK_EXTERNAL_NAME} INTERFACE "${HOOK_SOURCE_DIR}")
_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)
message(STATUS "[${HOOK_EXTERNAL_NAME}] Note: Define MINIAUDIO_IMPLEMENTATION in ONE .cpp file")
```

---

### openal-soft

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/kcat/openal-soft.git` |
| **Aktueller Tag** | `1.23.1` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |

```json
"openal-soft": {
    "git": "https://github.com/kcat/openal-soft.git",
    "tag": "1.23.1"
}
```

**PreFetch Hook (openal-soft.cmake):**
```cmake
set(ALSOFT_UTILS OFF CACHE BOOL "" FORCE)
set(ALSOFT_EXAMPLES OFF CACHE BOOL "" FORCE)
set(ALSOFT_TESTS OFF CACHE BOOL "" FORCE)
set(ALSOFT_INSTALL OFF CACHE BOOL "" FORCE)
```

---

## 10. Image / Media

### stb

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/nothings/stb.git` |
| **Aktueller Tag** | Kein Tag (branch: master) |
| **CMake Support** | ❌ (Single-headers) |
| **PreFetch Hook** | ❌ |
| **PostFetch Hook** | ✅ Erforderlich 🔧 |

```json
"stb": {
    "git": "https://github.com/nothings/stb.git",
    "branch": "master",
    "cmakeSupport": false
}
```

**PostFetch Hook (stb.cmake):**
```cmake
add_library(${HOOK_EXTERNAL_NAME} INTERFACE)
target_include_directories(${HOOK_EXTERNAL_NAME} INTERFACE "${HOOK_SOURCE_DIR}")
_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)
message(STATUS "[${HOOK_EXTERNAL_NAME}] Note: Define STB_*_IMPLEMENTATION in ONE .cpp file")
```

**Verwendung:**
```cpp
// In EINER .cpp Datei:
#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include <stb_image_write.h>
```

---

## 11. Threading / Async

### taskflow

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/taskflow/taskflow.git` |
| **Aktueller Tag** | `v3.6.0` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |
| **Header-only** | ✅ |

```json
"taskflow": {
    "git": "https://github.com/taskflow/taskflow.git",
    "tag": "v3.6.0"
}
```

**PreFetch Hook (taskflow.cmake):**
```cmake
set(TF_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(TF_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(TF_BUILD_BENCHMARKS OFF CACHE BOOL "" FORCE)
```

---

### thread-pool

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/bshoshany/thread-pool.git` |
| **Aktueller Tag** | `v4.1.0` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ❌ |
| **PostFetch Hook** | ❌ |
| **Header-only** | ✅ |

```json
"thread-pool": {
    "git": "https://github.com/bshoshany/thread-pool.git",
    "tag": "v4.1.0"
}
```

---

### concurrentqueue

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/cameron314/concurrentqueue.git` |
| **Aktueller Tag** | `v1.0.4` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ❌ |
| **PostFetch Hook** | ❌ |
| **Header-only** | ✅ |

```json
"concurrentqueue": {
    "git": "https://github.com/cameron314/concurrentqueue.git",
    "tag": "v1.0.4"
}
```

---

## 12. Database / Storage

### SQLiteCpp

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/SRombauts/SQLiteCpp.git` |
| **Aktueller Tag** | `3.3.1` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |
| **Abhängigkeiten** | SQLite3 (bundled) |

```json
"sqlitecpp": {
    "git": "https://github.com/SRombauts/SQLiteCpp.git",
    "tag": "3.3.1"
}
```

**PreFetch Hook (sqlitecpp.cmake):**
```cmake
set(SQLITECPP_RUN_CPPLINT OFF CACHE BOOL "" FORCE)
set(SQLITECPP_RUN_CPPCHECK OFF CACHE BOOL "" FORCE)
set(SQLITECPP_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(SQLITECPP_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
```

---

## 13. CUDA / GPU Computing

### CUDA Toolkit (System)

| Aspekt | Wert |
|--------|------|
| **Verfügbarkeit** | System-Installation erforderlich |
| **CMake Support** | ✅ (via find_package) |
| **Git-fetchbar** | ❌ |

**CMake Integration:**
```cmake
find_package(CUDAToolkit REQUIRED)
target_link_libraries(MyApp PRIVATE CUDA::cudart CUDA::cublas)
```

---

### Thrust

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/NVIDIA/thrust.git` |
| **Aktueller Tag** | `2.2.0` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |
| **Header-only** | ✅ |

```json
"thrust": {
    "git": "https://github.com/NVIDIA/thrust.git",
    "tag": "2.2.0"
}
```

**PreFetch Hook (thrust.cmake):**
```cmake
set(THRUST_ENABLE_TESTING OFF CACHE BOOL "" FORCE)
set(THRUST_ENABLE_EXAMPLES OFF CACHE BOOL "" FORCE)
```

---

### CUB

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/NVIDIA/cub.git` |
| **Aktueller Tag** | `2.2.0` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |
| **Header-only** | ✅ |

```json
"cub": {
    "git": "https://github.com/NVIDIA/cub.git",
    "tag": "2.2.0"
}
```

---

### cutlass (NVIDIA)

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/NVIDIA/cutlass.git` |
| **Aktueller Tag** | `v3.4.1` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |
| **Beschreibung** | CUDA Templates for Linear Algebra |

```json
"cutlass": {
    "git": "https://github.com/NVIDIA/cutlass.git",
    "tag": "v3.4.1"
}
```

**PreFetch Hook (cutlass.cmake):**
```cmake
set(CUTLASS_ENABLE_TESTS OFF CACHE BOOL "" FORCE)
set(CUTLASS_ENABLE_EXAMPLES OFF CACHE BOOL "" FORCE)
set(CUTLASS_ENABLE_TOOLS OFF CACHE BOOL "" FORCE)
```

---

## 14. KI / Machine Learning

### onnxruntime

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/microsoft/onnxruntime.git` |
| **Aktueller Tag** | `v1.17.0` |
| **CMake Support** | ⚠️ (Komplex) |
| **PreFetch Hook** | ✅ Erforderlich |
| **PostFetch Hook** | ❌ |
| **Beschreibung** | ONNX Model Inference |
| **Komplexität** | 🔴 Hoch |

```json
"onnxruntime": {
    "git": "https://github.com/microsoft/onnxruntime.git",
    "tag": "v1.17.0"
}
```

**Hinweis:** Sehr komplexer Build. Empfohlen: Pre-built Binaries verwenden.

**PreFetch Hook (onnxruntime.cmake):**
```cmake
set(onnxruntime_BUILD_UNIT_TESTS OFF CACHE BOOL "" FORCE)
set(onnxruntime_BUILD_SHARED_LIB ON CACHE BOOL "" FORCE)
set(onnxruntime_ENABLE_PYTHON OFF CACHE BOOL "" FORCE)
```

---

### llama.cpp

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/ggerganov/llama.cpp.git` |
| **Aktueller Tag** | `b2000+` (häufige Releases) |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |
| **Beschreibung** | LLM Inference (LLaMA, Mistral, etc.) |
| **GPU Support** | CUDA, Metal, Vulkan |

```json
"llama_cpp": {
    "git": "https://github.com/ggerganov/llama.cpp.git",
    "tag": "b2500"
}
```

**PreFetch Hook (llama_cpp.cmake):**
```cmake
set(LLAMA_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_SERVER OFF CACHE BOOL "" FORCE)
# GPU Backends
set(LLAMA_CUDA ON CACHE BOOL "" FORCE)        # NVIDIA
# set(LLAMA_METAL ON CACHE BOOL "" FORCE)     # Apple
# set(LLAMA_VULKAN ON CACHE BOOL "" FORCE)    # Cross-platform
```

---

### whisper.cpp

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/ggerganov/whisper.cpp.git` |
| **Aktueller Tag** | `v1.6.2` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |
| **Beschreibung** | OpenAI Whisper Speech Recognition |
| **GPU Support** | CUDA, Metal, Vulkan |

```json
"whisper_cpp": {
    "git": "https://github.com/ggerganov/whisper.cpp.git",
    "tag": "v1.6.2"
}
```

**PreFetch Hook (whisper_cpp.cmake):**
```cmake
set(WHISPER_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(WHISPER_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(WHISPER_CUDA ON CACHE BOOL "" FORCE)  # Für NVIDIA GPU
```

---

### stable-diffusion.cpp

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/leejet/stable-diffusion.cpp.git` |
| **Aktueller Tag** | `master-...` (häufige Updates) |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |
| **Beschreibung** | Stable Diffusion Image Generation |
| **GPU Support** | CUDA, Metal, Vulkan |

```json
"stable_diffusion_cpp": {
    "git": "https://github.com/leejet/stable-diffusion.cpp.git",
    "branch": "master",
    "cmakeSupport": true
}
```

---

### ggml

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/ggerganov/ggml.git` |
| **Aktueller Tag** | (häufige Updates) |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |
| **Beschreibung** | Tensor Library (Backend für llama.cpp, whisper.cpp) |
| **GPU Support** | CUDA, Metal, Vulkan, SYCL |

```json
"ggml": {
    "git": "https://github.com/ggerganov/ggml.git",
    "branch": "master"
}
```

**PreFetch Hook (ggml.cmake):**
```cmake
set(GGML_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GGML_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GGML_CUDA ON CACHE BOOL "" FORCE)
```

---

### ncnn

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/Tencent/ncnn.git` |
| **Aktueller Tag** | `20240102` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |
| **Beschreibung** | High-performance Neural Network Inference |
| **GPU Support** | Vulkan |

```json
"ncnn": {
    "git": "https://github.com/Tencent/ncnn.git",
    "tag": "20240102"
}
```

**PreFetch Hook (ncnn.cmake):**
```cmake
set(NCNN_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(NCNN_BUILD_TOOLS OFF CACHE BOOL "" FORCE)
set(NCNN_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(NCNN_BUILD_BENCHMARK OFF CACHE BOOL "" FORCE)
set(NCNN_VULKAN ON CACHE BOOL "" FORCE)
```

---

### TensorRT (NVIDIA)

| Aspekt | Wert |
|--------|------|
| **Verfügbarkeit** | System-Installation / Download von NVIDIA |
| **CMake Support** | ⚠️ (find_package) |
| **Git-fetchbar** | ❌ (Lizenz) |
| **Beschreibung** | High-performance Deep Learning Inference |

**Hinweis:** TensorRT muss separat von NVIDIA heruntergeladen werden.

---

### OpenCV (mit CUDA)

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/opencv/opencv.git` |
| **Aktueller Tag** | `4.9.0` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Erforderlich |
| **PostFetch Hook** | ❌ |
| **Komplexität** | 🔴 Hoch (viele Dependencies) |

```json
"opencv": {
    "git": "https://github.com/opencv/opencv.git",
    "tag": "4.9.0"
}
```

**PreFetch Hook (opencv.cmake):**
```cmake
set(BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(BUILD_PERF_TESTS OFF CACHE BOOL "" FORCE)
set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_apps OFF CACHE BOOL "" FORCE)
set(BUILD_DOCS OFF CACHE BOOL "" FORCE)
# CUDA
set(WITH_CUDA ON CACHE BOOL "" FORCE)
set(WITH_CUDNN ON CACHE BOOL "" FORCE)
set(OPENCV_DNN_CUDA ON CACHE BOOL "" FORCE)
```

**Hinweis:** OpenCV ist sehr groß. Empfohlen: Pre-built oder selektive Module.

---

### dlib

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/davisking/dlib.git` |
| **Aktueller Tag** | `v19.24.4` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ✅ Empfohlen |
| **PostFetch Hook** | ❌ |
| **Beschreibung** | ML Toolkit (Face Detection, etc.) |
| **GPU Support** | CUDA |

```json
"dlib": {
    "git": "https://github.com/davisking/dlib.git",
    "tag": "v19.24.4"
}
```

**PreFetch Hook (dlib.cmake):**
```cmake
set(DLIB_NO_GUI_SUPPORT OFF CACHE BOOL "" FORCE)
set(DLIB_USE_CUDA ON CACHE BOOL "" FORCE)
set(DLIB_GIF_SUPPORT OFF CACHE BOOL "" FORCE)
set(DLIB_JPEG_SUPPORT ON CACHE BOOL "" FORCE)
set(DLIB_PNG_SUPPORT ON CACHE BOOL "" FORCE)
```

---

## 15. Vulkan / Graphics (Low-Level)

### Vulkan-Headers

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/KhronosGroup/Vulkan-Headers.git` |
| **Aktueller Tag** | `v1.3.280` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ❌ |
| **PostFetch Hook** | ❌ |

```json
"vulkan-headers": {
    "git": "https://github.com/KhronosGroup/Vulkan-Headers.git",
    "tag": "v1.3.280"
}
```

---

### volk (Vulkan Loader)

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/zeux/volk.git` |
| **Aktueller Tag** | `1.3.280` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ❌ |
| **PostFetch Hook** | ❌ |

```json
"volk": {
    "git": "https://github.com/zeux/volk.git",
    "tag": "1.3.280"
}
```

---

### VulkanMemoryAllocator

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator.git` |
| **Aktueller Tag** | `v3.0.1` |
| **CMake Support** | ✅ |
| **PreFetch Hook** | ❌ |
| **PostFetch Hook** | ❌ |

```json
"vma": {
    "git": "https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator.git",
    "tag": "v3.0.1"
}
```

---

## Zusammenfassung: Hook-Anforderungen

### Kein Hook nötig

Einfache Header-only oder gut konfigurierte Libraries:

- `entt`, `magic_enum`, `argparse`, `tomlplusplus`
- `thread-pool`, `concurrentqueue`
- `vulkan-headers`, `volk`, `vma`

### PreFetch Hook empfohlen

Tests/Examples deaktivieren:

- `spdlog`, `fmt`, `glfw`, `sdl2`, `raylib`
- `googletest`, `catch2`, `benchmark`
- `nlohmann_json`, `rapidjson`, `simdjson`, `yaml-cpp`
- `glm`, `eigen`, `taskflow`
- `cpr`, `cli11`, `sqlitecpp`
- `openal-soft`, `zstd`, `lz4`
- `abseil`, `ixwebsocket`
- CUDA/AI: `thrust`, `cub`, `cutlass`, `llama_cpp`, `whisper_cpp`, `ggml`, `ncnn`, `dlib`

### PostFetch Hook erforderlich 🔧

Kein CMakeLists.txt oder spezielle Konfiguration:

- `imgui` (+ Varianten)
- `sokol`
- `asio` (standalone)
- `miniaudio`
- `stb`

---

## Siehe auch

- [Solution_Schema](Solution_Schema_v0_1_2.md) – External-Konfiguration
- [HookLoader.cmake](../Modules/HookLoader_cmake_v0_2_0_doc_v1.md) – Hook-System
- [Future_Enhancements](../Concepts/Future_Enhancements_v0_1_0.md) – vcpkg/Conan Integration

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-10** | **Initial: 50+ Externals in 15 Kategorien, Hook-Anforderungen, CUDA/AI Section** |
