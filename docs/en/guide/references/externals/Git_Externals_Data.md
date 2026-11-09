# Git Externals: Data & Serialization — Reference

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Git_Externals_Data.md](../../../../de/guide/references/externals/Git_Externals_Data.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [JSON](#2-json)
3. [Other Formats](#3-other-formats)
4. [Database](#4-database)
5. [Compression](#5-compression)
6. [Quick Reference](#6-quick-reference)
7. [See Also](#7-see-also)
8. [Changelog](#8-changelog)

---

## 1. Overview

This document describes libraries for data serialization, databases and compression.

### Categories

| Category | Libraries |
|----------|-----------|
| JSON | nlohmann_json, rapidjson, simdjson |
| Other formats | yaml-cpp, tomlplusplus |
| Database | SQLiteCpp |
| Compression | zstd, lz4 |

---

## 2. JSON

### 2.1 nlohmann_json

> **Purpose:** JSON for Modern C++ - intuitive, STL-like API.

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/nlohmann/json.git` |
| **Current Tag** | `v3.11.3` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch recommended |
| **Header-only** | ✅ |

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

**Usage:**
```cpp
#include <nlohmann/json.hpp>
using json = nlohmann::json;

json j = {{"name", "John"}, {"age", 30}};
std::string s = j.dump(4);  // Pretty print

auto parsed = json::parse(R"({"key": "value"})");
std::string value = parsed["key"];
```

---

### 2.2 rapidjson

> **Purpose:** Extremely fast JSON parser/generator (SAX & DOM).

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/Tencent/rapidjson.git` |
| **Current Tag** | `v1.1.0` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch recommended |
| **Header-only** | ✅ |

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

**Usage:**
```cpp
#include <rapidjson/document.h>
#include <rapidjson/writer.h>

rapidjson::Document d;
d.Parse(R"({"key": "value"})");
const char* value = d["key"].GetString();
```

---

### 2.3 simdjson

> **Purpose:** SIMD-accelerated JSON parser (fastest available).

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/simdjson/simdjson.git` |
| **Current Tag** | `v3.6.3` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch recommended |

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

**Usage:**
```cpp
#include <simdjson.h>

simdjson::ondemand::parser parser;
auto json = simdjson::padded_string::load("data.json");
auto doc = parser.iterate(json);
std::string_view value = doc["key"];
```

---

## 3. Other Formats

### 3.1 yaml-cpp

> **Purpose:** YAML 1.2 parser and emitter for C++.

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/jbeder/yaml-cpp.git` |
| **Current Tag** | `0.8.0` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch recommended |

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

**Usage:**
```cpp
#include <yaml-cpp/yaml.h>

YAML::Node config = YAML::LoadFile("config.yaml");
std::string name = config["name"].as<std::string>();
int port = config["server"]["port"].as<int>();
```

---

### 3.2 tomlplusplus

> **Purpose:** Header-only TOML v1.0 parser and serializer.

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/marzer/tomlplusplus.git` |
| **Current Tag** | `v3.4.0` |
| **CMake Support** | ✅ |
| **Hook** | – |
| **Header-only** | ✅ |

```json
"tomlplusplus": {
    "git": "https://github.com/marzer/tomlplusplus.git",
    "tag": "v3.4.0"
}
```

**Usage:**
```cpp
#include <toml++/toml.hpp>

auto config = toml::parse_file("config.toml");
std::string_view name = config["package"]["name"].value_or("default"sv);
```

---

## 4. Database

### 4.1 SQLiteCpp

> **Purpose:** Modern C++ wrapper for SQLite3.

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/SRombauts/SQLiteCpp.git` |
| **Current Tag** | `3.3.1` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch recommended |
| **Dependencies** | SQLite3 (bundled) |

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

**Usage:**
```cpp
#include <SQLiteCpp/SQLiteCpp.h>

SQLite::Database db("example.db", SQLite::OPEN_READWRITE | SQLite::OPEN_CREATE);
db.exec("CREATE TABLE test (id INTEGER PRIMARY KEY, value TEXT)");

SQLite::Statement query(db, "SELECT * FROM test WHERE id = ?");
query.bind(1, 42);
while (query.executeStep()) {
    std::string value = query.getColumn(1);
}
```

---

## 5. Compression

### 5.1 zstd

> **Purpose:** Fast compression with a high compression ratio (Facebook).

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/facebook/zstd.git` |
| **Current Tag** | `v1.5.5` |
| **CMake Support** | ✅ (in build/cmake) |
| **Hook** | PreFetch recommended |
| **Note** | SOURCE_SUBDIR: `build/cmake` |

```json
"zstd": {
    "git": "https://github.com/facebook/zstd.git",
    "tag": "v1.5.5"
}
```

**Note:** CMakeLists.txt is in `build/cmake/`. With FetchContent:
```cmake
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

### 5.2 lz4

> **Purpose:** Extremely fast compression (best decompression speed).

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/lz4/lz4.git` |
| **Current Tag** | `v1.9.4` |
| **CMake Support** | ✅ (in build/cmake) |
| **Hook** | PreFetch recommended |
| **Note** | SOURCE_SUBDIR: `build/cmake` |

```json
"lz4": {
    "git": "https://github.com/lz4/lz4.git",
    "tag": "v1.9.4"
}
```

---

## 6. Quick Reference

| Library | Tag | CMake | Hook | Main Use |
|---------|-----|-------|------|----------|
| nlohmann_json | v3.11.3 | ✅ | PreFetch | Intuitive JSON API |
| rapidjson | v1.1.0 | ✅ | PreFetch | High-performance JSON |
| simdjson | v3.6.3 | ✅ | PreFetch | SIMD-accelerated JSON |
| yaml-cpp | 0.8.0 | ✅ | PreFetch | YAML parsing |
| tomlplusplus | v3.4.0 | ✅ | – | TOML parsing |
| sqlitecpp | 3.3.1 | ✅ | PreFetch | SQLite wrapper |
| zstd | v1.5.5 | ✅* | PreFetch | Fast compression |
| lz4 | v1.9.4 | ✅* | PreFetch | Fastest decompression |

*SOURCE_SUBDIR required

---

## 7. See Also

- [Git_Externals_Reference.md](Git_Externals.md) — Main overview
- [Git_Externals_Core.md](Git_Externals_Core.md) — Logging & Testing
- [Git_Externals_Network.md](Git_Externals_Network.md) — Networking

---

## 8. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-14 | Initial: extracted from Git_Externals_Reference |
