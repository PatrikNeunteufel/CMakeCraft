# Git Externals — Testing

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Git_Externals_Testing.md](../../../../de/guide/references/externals/Git_Externals_Testing.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [googletest](#2-googletest)
3. [catch2](#3-catch2)
4. [benchmark](#4-benchmark)
5. [Quick Reference](#5-quick-reference)
6. [See Also](#6-see-also)
7. [Changelog](#changelog)

---

## 1. Overview

This document describes Git testing externals for the CMake Architecture build system.

| Library | Description | CMake | Hook |
|---------|-------------|-------|------|
| **googletest** | Google Test + GMock | ✅ | PreFetch |
| **catch2** | BDD-style testing | ✅ | PreFetch |
| **benchmark** | Google Benchmark | ✅ | PreFetch |

---

## 2. googletest

### Quick Info

| Aspect | Value |
|--------|-------|
| **Repository** | https://github.com/google/googletest |
| **Recommended Tag** | v1.14.0 |
| **CMake Support** | ✅ |
| **Hook** | PreFetch (recommended) |

### Solution.json

```json
{
    "externals": {
        "googletest": {
            "git": "https://github.com/google/googletest.git",
            "tag": "v1.14.0"
        }
    }
}
```

### PreFetch Hook

```cmake
# cmake/externals/hooks/prefetch/googletest.cmake
set(BUILD_GMOCK ON CACHE BOOL "" FORCE)
set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
```

### Usage Example

```cpp
#include <gtest/gtest.h>

TEST(MathTest, Addition) {
    EXPECT_EQ(1 + 1, 2);
    EXPECT_EQ(2 + 3, 5);
}

TEST(MathTest, Subtraction) {
    EXPECT_EQ(5 - 3, 2);
}

int main(int argc, char** argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
```

### With GMock

```cpp
#include <gmock/gmock.h>

class MockDatabase {
public:
    MOCK_METHOD(bool, Connect, (const std::string& host));
    MOCK_METHOD(std::string, Query, (const std::string& sql));
};

TEST(DatabaseTest, ConnectCalled) {
    MockDatabase db;
    EXPECT_CALL(db, Connect("localhost")).WillOnce(testing::Return(true));
    
    EXPECT_TRUE(db.Connect("localhost"));
}
```

### Targets

| Target | Description |
|--------|-------------|
| `gtest` | Google Test core |
| `gtest_main` | With main() |
| `gmock` | Google Mock core |
| `gmock_main` | With main() |

---

## 3. catch2

### Quick Info

| Aspect | Value |
|--------|-------|
| **Repository** | https://github.com/catchorg/Catch2 |
| **Recommended Tag** | v3.5.2 |
| **CMake Support** | ✅ |
| **Hook** | PreFetch (recommended) |

### Solution.json

```json
{
    "externals": {
        "catch2": {
            "git": "https://github.com/catchorg/Catch2.git",
            "tag": "v3.5.2"
        }
    }
}
```

### PreFetch Hook

```cmake
# cmake/externals/hooks/prefetch/catch2.cmake
set(CATCH_BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(CATCH_INSTALL_DOCS OFF CACHE BOOL "" FORCE)
set(CATCH_INSTALL_EXTRAS OFF CACHE BOOL "" FORCE)
```

### Usage Example

```cpp
#include <catch2/catch_test_macros.hpp>

TEST_CASE("Math operations", "[math]") {
    SECTION("addition") {
        REQUIRE(1 + 1 == 2);
        REQUIRE(2 + 3 == 5);
    }
    
    SECTION("subtraction") {
        REQUIRE(5 - 3 == 2);
    }
}
```

### BDD Style

```cpp
#include <catch2/catch_test_macros.hpp>

SCENARIO("Vector can be sized and resized", "[vector]") {
    GIVEN("A vector with some items") {
        std::vector<int> v(5);
        
        WHEN("the size is increased") {
            v.resize(10);
            
            THEN("the size changes") {
                REQUIRE(v.size() == 10);
            }
        }
    }
}
```

### Targets

| Target | Description |
|--------|-------------|
| `Catch2::Catch2` | Header-only interface |
| `Catch2::Catch2WithMain` | With main() |

---

## 4. benchmark

### Quick Info

| Aspect | Value |
|--------|-------|
| **Repository** | https://github.com/google/benchmark |
| **Recommended Tag** | v1.8.3 |
| **CMake Support** | ✅ |
| **Hook** | PreFetch (recommended) |

### Solution.json

```json
{
    "externals": {
        "benchmark": {
            "git": "https://github.com/google/benchmark.git",
            "tag": "v1.8.3"
        }
    }
}
```

### PreFetch Hook

```cmake
# cmake/externals/hooks/prefetch/benchmark.cmake
set(BENCHMARK_ENABLE_TESTING OFF CACHE BOOL "" FORCE)
set(BENCHMARK_ENABLE_INSTALL OFF CACHE BOOL "" FORCE)
set(BENCHMARK_ENABLE_GTEST_TESTS OFF CACHE BOOL "" FORCE)
```

### Usage Example

```cpp
#include <benchmark/benchmark.h>
#include <vector>

static void BM_VectorPushBack(benchmark::State& state) {
    for (auto _ : state) {
        std::vector<int> v;
        for (int i = 0; i < state.range(0); ++i) {
            v.push_back(i);
        }
    }
}
BENCHMARK(BM_VectorPushBack)->Range(8, 8<<10);

static void BM_VectorReserve(benchmark::State& state) {
    for (auto _ : state) {
        std::vector<int> v;
        v.reserve(state.range(0));
        for (int i = 0; i < state.range(0); ++i) {
            v.push_back(i);
        }
    }
}
BENCHMARK(BM_VectorReserve)->Range(8, 8<<10);

BENCHMARK_MAIN();
```

### Targets

| Target | Description |
|--------|-------------|
| `benchmark::benchmark` | Core library |
| `benchmark::benchmark_main` | With main() |

---

## 5. Quick Reference

| Library | Tag | CMake | Hook | Targets |
|---------|-----|-------|------|---------|
| googletest | v1.14.0 | ✅ | PreFetch | gtest, gtest_main, gmock |
| catch2 | v3.5.2 | ✅ | PreFetch | Catch2::Catch2WithMain |
| benchmark | v1.8.3 | ✅ | PreFetch | benchmark::benchmark_main |

### Comparison with the Local Alternative

| Feature | doctest (Local) | googletest (Git) | catch2 (Git) |
|---------|-----------------|------------------|--------------|
| **Header-Only** | ✅ | ❌ | ✅ |
| **Compile time** | ⚡ Very fast | 🐢 Slow | 🐌 Slower |
| **Mocking** | ❌ | ✅ GMock | ❌ |
| **BDD Subcases** | ✅ | ❌ | ✅ |

---

## 6. See Also

- [Externals.md](../Externals.md) — Main overview of all externals
- [Git_Externals.md](Git_Externals.md) — Git Externals overview
- [Local_Externals_Testing.md](Local_Externals_Testing.md) — Local Testing (doctest)
- [Testing_UserGuide.md](../../userguides/Testing.md) — Testing guide

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.2 | 2025-12-15 | Own category Testing (split out from Git_Externals_Core) |
