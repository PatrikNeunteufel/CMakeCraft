# Git Externals: Core & Utility — Referenz

> **Version:** 0.5.0  
> **Datum:** 2025-12-14  
> **Typ:** Reference  
> **Status:** Stabil  
> **Zielgruppe:** Alle Entwickler  
> **Sprache:** Deutsch  
> **English:** [Git_Externals_Core.md](../../en/reference/Git_Externals_Core.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Logging & Debugging](#2-logging--debugging)
3. [Testing](#3-testing)
4. [Utility / General](#4-utility--general)
5. [Schnellreferenz](#5-schnellreferenz)
6. [Siehe auch](#6-siehe-auch)
7. [Changelog](#7-changelog)

---

## 1. Übersicht

Dieses Dokument beschreibt grundlegende Bibliotheken für Logging, Testing und allgemeine Entwicklungsaufgaben.

### Kategorien

| Kategorie | Bibliotheken |
|-----------|--------------|
| Logging | spdlog, fmt |
| Testing | googletest, catch2, benchmark |
| Utility | abseil, magic_enum, argparse, CLI11 |

---

## 2. Logging & Debugging

### 2.1 spdlog

> **Zweck:** Schnelle, header-only/compiled C++ Logging-Bibliothek mit Formatierung, Rotation und Sinks.

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/gabime/spdlog.git` |
| **Aktueller Tag** | `v1.14.1` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch empfohlen |
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

**Verwendung:**
```cpp
#include <spdlog/spdlog.h>

spdlog::info("Welcome to spdlog!");
spdlog::error("Error message: {}", error_code);
```

---

### 2.2 fmt

> **Zweck:** Moderne Formatierungs-Bibliothek (Basis für C++20 std::format).

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/fmtlib/fmt.git` |
| **Aktueller Tag** | `10.2.1` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch empfohlen |

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

**Verwendung:**
```cpp
#include <fmt/core.h>
#include <fmt/chrono.h>

std::string s = fmt::format("Hello, {}!", "world");
fmt::print("Time: {:%H:%M}\n", std::chrono::system_clock::now());
```

---

## 3. Testing

### 3.1 googletest

> **Zweck:** Google's C++ Test-Framework mit Mocking (GMock).

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/google/googletest.git` |
| **Aktueller Tag** | `v1.14.0` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch empfohlen |
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

**Verwendung:**
```cpp
#include <gtest/gtest.h>

TEST(MyTest, BasicAssert) {
    EXPECT_EQ(1 + 1, 2);
}
```

---

### 3.2 Catch2

> **Zweck:** BDD-style Testing mit Sections und Benchmarks.

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/catchorg/Catch2.git` |
| **Aktueller Tag** | `v3.5.2` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch empfohlen |
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

**Verwendung:**
```cpp
#include <catch2/catch_test_macros.hpp>

TEST_CASE("Factorials are computed", "[factorial]") {
    REQUIRE(factorial(1) == 1);
    REQUIRE(factorial(2) == 2);
}
```

---

### 3.3 benchmark (Google)

> **Zweck:** Micro-Benchmarking-Framework für Performance-Tests.

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/google/benchmark.git` |
| **Aktueller Tag** | `v1.8.3` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch erforderlich |

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

**Verwendung:**
```cpp
#include <benchmark/benchmark.h>

static void BM_StringCreation(benchmark::State& state) {
    for (auto _ : state)
        std::string empty_string;
}
BENCHMARK(BM_StringCreation);

BENCHMARK_MAIN();
```

---

## 4. Utility / General

### 4.1 abseil-cpp

> **Zweck:** Google's C++ Common Libraries (Strings, Containers, Synchronization).

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/abseil/abseil-cpp.git` |
| **Aktueller Tag** | `20240116.2` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch erforderlich |

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

### 4.2 magic_enum

> **Zweck:** Statische Enum-Reflection ohne Makros.

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/Neargye/magic_enum.git` |
| **Aktueller Tag** | `v0.9.5` |
| **CMake Support** | ✅ |
| **Hook** | – |
| **Header-only** | ✅ |

```json
"magic_enum": {
    "git": "https://github.com/Neargye/magic_enum.git",
    "tag": "v0.9.5"
}
```

**Verwendung:**
```cpp
#include <magic_enum.hpp>

enum class Color { RED, GREEN, BLUE };

auto name = magic_enum::enum_name(Color::RED);  // "RED"
auto value = magic_enum::enum_cast<Color>("GREEN");  // Color::GREEN
```

---

### 4.3 argparse

> **Zweck:** Einfacher Argument-Parser im Python-Stil.

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/p-ranav/argparse.git` |
| **Aktueller Tag** | `v3.0` |
| **CMake Support** | ✅ |
| **Hook** | – |
| **Header-only** | ✅ |

```json
"argparse": {
    "git": "https://github.com/p-ranav/argparse.git",
    "tag": "v3.0"
}
```

**Verwendung:**
```cpp
#include <argparse/argparse.hpp>

argparse::ArgumentParser program("myapp");
program.add_argument("--verbose").flag();
program.parse_args(argc, argv);
```

---

### 4.4 CLI11

> **Zweck:** Feature-reicher Command-Line-Parser.

| Aspekt | Wert |
|--------|------|
| **Repository** | `https://github.com/CLIUtils/CLI11.git` |
| **Aktueller Tag** | `v2.4.1` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch empfohlen |
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

**Verwendung:**
```cpp
#include <CLI/CLI.hpp>

CLI::App app{"My App"};
std::string filename;
app.add_option("-f,--file", filename, "Input file");
CLI11_PARSE(app, argc, argv);
```

---

## 5. Schnellreferenz

| Bibliothek | Tag | CMake | Hook | Hauptverwendung |
|------------|-----|-------|------|-----------------|
| spdlog | v1.14.1 | ✅ | PreFetch | Fast logging |
| fmt | 10.2.1 | ✅ | PreFetch | String formatting |
| googletest | v1.14.0 | ✅ | PreFetch | Unit testing + mocking |
| catch2 | v3.5.2 | ✅ | PreFetch | BDD testing |
| benchmark | v1.8.3 | ✅ | PreFetch | Micro-benchmarks |
| abseil | 20240116.2 | ✅ | PreFetch | Google's C++ libs |
| magic_enum | v0.9.5 | ✅ | – | Enum reflection |
| argparse | v3.0 | ✅ | – | Simple arg parsing |
| CLI11 | v2.4.1 | ✅ | PreFetch | Full-featured CLI |

---

## 6. Siehe auch

- [Git_Externals_Reference.md](Git_Externals_Reference.md) — Hauptübersicht
- [Git_Externals_GUI.md](Git_Externals_GUI.md) — GUI & Graphics
- [Git_Externals_Data.md](Git_Externals_Data.md) — Data & Serialization
- [Externals.md](Externals.md) — Local Externals

---

## 7. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-14** | **Initial: Ausgelagert aus Git_Externals_Reference, Verwendungsbeispiele hinzugefügt** |
