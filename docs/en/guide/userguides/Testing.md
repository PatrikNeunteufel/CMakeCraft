# Testing – User Guide

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Guide  
> **Status:** Stable  
> **Target Audience:** C++ developers  
> **Module:** Tests.cmake, TestCollect.cmake, TestCreate.cmake  
> **Language:** English  
> **German:** [Testing_UserGuide.md](../../../de/guide/userguides/Testing.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Quick Start](#3-quick-start)
4. [Test Types](#4-test-types)
5. [Framework Comparison](#5-framework-comparison)
6. [Project Structure](#6-project-structure)
7. [Solution.json Configuration](#7-solutionjson-configuration)
8. [Writing Tests](#8-writing-tests)
9. [Running Tests](#9-running-tests)
10. [Best Practices](#10-best-practices)
11. [Pitfalls and Solutions](#11-pitfalls-and-solutions)
12. [Troubleshooting](#12-troubleshooting)
13. [See Also](#13-see-also)

---

## 1. Overview

The test system lets you define and run tests for project code. Tests are configured in `Solution.json` just like executables and libraries.

### Scope

| Test kind | Purpose | Activation |
|-----------|---------|------------|
| **Project tests** | Test application code | `BUILD_TESTS=ON` |
| **Build system tests** | Test CMake modules | `RUN_BUILD_SYSTEM_TESTS=ON` |

This guide covers **project tests**.

### Features

- Declarative configuration via Solution.json
- Several test frameworks (doctest, GoogleTest, Catch2)
- Test types (unit, integration, performance, etc.)
- CTest integration (labels, timeout, parallel)
- Automatic framework linking

---

## 2. Prerequisites

### Checklist

- [ ] **CMake Architecture** set up
- [ ] **Test framework** defined as an external (doctest, GoogleTest, or Catch2)
- [ ] **Library to be tested** present (in the `libraries` block)
- [ ] **CTest** available (comes with CMake)

### Recommended Versions

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CMake | 3.21 | 3.28+ |
| doctest | 2.4.0 | 2.4.11 |
| GoogleTest | 1.12.0 | 1.14.0 |
| Catch2 | 3.0.0 | 3.5.0 |

### Framework as an External

```json
{
    "externals": {
        "doctest": {
            "path": "externals/doctest"
        }
    }
}
```

---

## 3. Quick Start

### 3.1 Extend Solution.json

```json
{
    "externals": {
        "doctest": {
            "path": "externals/doctest"
        }
    },
    "tests": [
        {
            "name": "MyLib_Tests",
            "type": "unit",
            "framework": "doctest",
            "dependencies": ["MyLib"],
            "externals": ["doctest"]
        }
    ]
}
```

### 3.2 Create a Test File

`projects/tests/unit/MyLib_Tests/src/test_main.cpp`:

```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest/doctest.h>
#include "MyLib/Calculator.h"

TEST_CASE("Calculator add") {
    Calculator calc;
    CHECK(calc.add(2, 3) == 5);
    CHECK(calc.add(-1, 1) == 0);
}
```

### 3.3 Build and Run

```bash
# Configure with tests
cmake --preset windows-ninja-debug-msvc -DBUILD_TESTS=ON

# Build
cmake --build out/build/windows-ninja-debug-msvc

# Run tests
ctest --test-dir out/build/windows-ninja-debug-msvc
```

---

## 4. Test Types

| Type | Description | Scope | Duration |
|------|-------------|-------|----------|
| `unit` | Individual functions/classes | Isolated | Fast |
| `integration` | Interaction of components | Several modules | Medium |
| `system` | Whole system (end-to-end) | Complete | Slow |
| `performance` | Benchmarks | Performance | Variable |
| `smoke` | Basic functionality | Critical paths | Very fast |

### Recommendations

| Type | When to use |
|------|-------------|
| **unit** | For every class/function |
| **integration** | After unit tests, before a release |
| **system** | CI/CD pipeline, release tests |
| **performance** | Regression tracking, optimization |
| **smoke** | Quick validation after a build |

---

## 5. Framework Comparison

### 5.1 Overview

| Framework | Strengths | Weaknesses |
|-----------|-----------|------------|
| **doctest** | Fastest compilation, header-only | No mocking |
| **GoogleTest** | Mocking, feature-rich | Slow compilation |
| **Catch2** | BDD style, sections, benchmarks | Larger binaries |

### 5.2 Decision Tree

```
Do you need mocking?
├─ Yes → GoogleTest
└─ No
    ├─ BDD style wanted?
    │   ├─ Yes → Catch2
    │   └─ No
    │       ├─ Fast compilation important?
    │       │   ├─ Yes → doctest
    │       │   └─ No → Catch2 or doctest
    │       └─ Integrated benchmarks?
    │           ├─ Yes → Catch2
    │           └─ No → doctest
    └─ Parameterized tests?
        ├─ Yes → GoogleTest
        └─ No → doctest or Catch2
```

### 5.3 Feature Matrix

| Feature | doctest | GoogleTest | Catch2 |
|---------|:-------:|:----------:|:------:|
| Compile time | ⭐⭐⭐ | ⭐ | ⭐⭐ |
| Header-only | ✅ | ❌ | ❌ |
| Mocking | ❌ | ✅ | ❌ |
| BDD style | ❌ | ❌ | ✅ |
| Sections | ❌ | ❌ | ✅ |
| Benchmarks | ❌ | ❌ | ✅ |
| Parameterized | ⭐ | ⭐⭐⭐ | ⭐⭐ |
| Death tests | ❌ | ✅ | ❌ |
| Matchers | ⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| Test discovery | ✅ | ✅ | ✅ |

### 5.4 Which Framework When?

#### doctest (Default) – Recommended for:

- Unit tests
- CI/CD (fast builds)
- Header-only libraries
- Simple test suites

#### GoogleTest – Recommended for:

- When mocking is needed
- Complex test fixtures
- Parameterized tests with many variants
- Death tests (crash behavior)
- Large projects with many developers

#### Catch2 – Recommended for:

- BDD style (SCENARIO/GIVEN/WHEN/THEN)
- Complex setup scenarios (sections)
- Integrated benchmarks
- Readable test output

---

## 6. Project Structure

### Recommended Structure

```
projects/
├── demos/
│   ├── exec/
│   │   └── MyApp/
│   └── libs/
│       └── CoreLib/
│           ├── include/
│           │   └── CoreLib/
│           │       └── Calculator.h
│           └── src/
│               └── Calculator.cpp
└── tests/
    ├── unit/
    │   └── CoreLib_Tests/
    │       └── src/
    │           ├── test_main.cpp
    │           └── test_Calculator.cpp
    ├── integration/
    │   └── Pipeline_Tests/
    │       └── src/
    │           └── test_pipeline.cpp
    └── performance/
        └── Benchmarks/
            └── src/
                └── bench_sorting.cpp
```

### Path Convention

If `path` is not given:

```
projects/tests/{type}/{name}/src
```

---

## 7. Solution.json Configuration

### 7.1 Minimal Configuration

```json
"tests": [
    {
        "name": "MyLib_Tests"
    }
]
```

**Defaults:**
- `type`: `"unit"`
- `framework`: `"doctest"`
- `path`: `projects/tests/unit/MyLib_Tests/src`
- `timeout`: 60
- `parallel`: true

### 7.2 Complete Configuration

```json
"tests": [
    {
        "name": "CoreLib_UnitTests",
        "displayName": "CoreLib Unit Tests",
        "version": "1.0.0",
        "type": "unit",
        "framework": "doctest",
        "path": "projects/tests/unit/CoreLib_Tests/src",
        "target": "CoreLib",
        "dependencies": ["CoreLib"],
        "externals": ["doctest"],
        "timeout": 30,
        "labels": ["unit", "core", "fast"],
        "parallel": true,
        "skip": false,
        "platforms": ["windows", "linux", "macos"],
        "defines": ["TEST_MODE"],
        "compile_options": ["-Wno-unused-variable"]
    }
]
```

### 7.3 Field Reference

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | string | **Required** | Test target name |
| `displayName` | string | `name` | Display name (IDE) |
| `type` | string | `"unit"` | Test type |
| `framework` | string | `"doctest"` | Test framework |
| `path` | string | Convention | Source directory |
| `target` | string | - | Tested target |
| `dependencies` | string[] | `[]` | Internal libraries |
| `externals` | string[] | `[]` | External libraries |
| `timeout` | int | 60 | Timeout (seconds) |
| `labels` | string[] | `[type]` | CTest labels |
| `parallel` | bool | true | Can run in parallel |
| `skip` | bool | false | Skip |

---

## 8. Writing Tests

### 8.1 doctest

**test_main.cpp:**
```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest/doctest.h>
```

**test_Calculator.cpp:**
```cpp
#include <doctest/doctest.h>
#include "CoreLib/Calculator.h"

TEST_CASE("Calculator::add") {
    Calculator calc;
    
    SUBCASE("positive numbers") {
        CHECK(calc.add(2, 3) == 5);
        CHECK(calc.add(100, 200) == 300);
    }
    
    SUBCASE("negative numbers") {
        CHECK(calc.add(-1, -1) == -2);
        CHECK(calc.add(-5, 3) == -2);
    }
    
    SUBCASE("zero") {
        CHECK(calc.add(0, 0) == 0);
        CHECK(calc.add(5, 0) == 5);
    }
}

TEST_CASE("Calculator::divide") {
    Calculator calc;
    
    CHECK(calc.divide(10, 2) == 5);
    CHECK_THROWS_AS(calc.divide(1, 0), std::domain_error);
}
```

### 8.2 GoogleTest

**test_main.cpp:**
```cpp
#include <gtest/gtest.h>

int main(int argc, char** argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
```

**test_Calculator.cpp:**
```cpp
#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "CoreLib/Calculator.h"

class CalculatorTest : public ::testing::Test {
protected:
    Calculator calc;
};

TEST_F(CalculatorTest, AddPositive) {
    EXPECT_EQ(calc.add(2, 3), 5);
    EXPECT_EQ(calc.add(100, 200), 300);
}

TEST_F(CalculatorTest, AddNegative) {
    EXPECT_EQ(calc.add(-1, -1), -2);
}

TEST_F(CalculatorTest, DivideByZeroThrows) {
    EXPECT_THROW(calc.divide(1, 0), std::domain_error);
}

// Parameterized test
class AddTest : public ::testing::TestWithParam<std::tuple<int, int, int>> {};

TEST_P(AddTest, ReturnsCorrectSum) {
    auto [a, b, expected] = GetParam();
    Calculator calc;
    EXPECT_EQ(calc.add(a, b), expected);
}

INSTANTIATE_TEST_SUITE_P(
    Additions,
    AddTest,
    ::testing::Values(
        std::make_tuple(1, 1, 2),
        std::make_tuple(2, 3, 5),
        std::make_tuple(-1, 1, 0)
    )
);
```

### 8.3 Catch2 (BDD Style)

**test_main.cpp:**
```cpp
#define CATCH_CONFIG_MAIN
#include <catch2/catch_all.hpp>
```

**test_Calculator.cpp:**
```cpp
#include <catch2/catch_all.hpp>
#include "CoreLib/Calculator.h"

SCENARIO("Calculator handles basic operations", "[calculator][unit]") {
    GIVEN("A calculator instance") {
        Calculator calc;
        
        WHEN("adding positive numbers") {
            auto result = calc.add(2, 3);
            
            THEN("the result is correct") {
                REQUIRE(result == 5);
            }
        }
        
        WHEN("adding negative numbers") {
            auto result = calc.add(-1, -1);
            
            THEN("the result is negative") {
                REQUIRE(result == -2);
            }
        }
        
        WHEN("dividing by zero") {
            THEN("an exception is thrown") {
                REQUIRE_THROWS_AS(calc.divide(1, 0), std::domain_error);
            }
        }
    }
}

// Benchmarks (Catch2)
TEST_CASE("Sorting Benchmark", "[benchmark]") {
    std::vector<int> data(1000);
    std::iota(data.begin(), data.end(), 0);
    
    BENCHMARK("std::sort random") {
        std::shuffle(data.begin(), data.end(), std::mt19937{});
        std::sort(data.begin(), data.end());
        return data;
    };
}
```

---

## 9. Running Tests

### 9.1 All Tests

```bash
ctest --test-dir out/build/windows-ninja-debug-msvc
```

### 9.2 Filter by Label

```bash
# Unit tests only
ctest -L unit

# Fast tests only
ctest -L fast

# No slow tests
ctest -LE slow

# Combined
ctest -L unit -L fast
```

### 9.3 Filter by Name

```bash
# Specific test
ctest -R CoreLib_Tests

# Pattern
ctest -R ".*Audio.*"

# Exclude
ctest -E ".*Benchmark.*"
```

### 9.4 Parallel

```bash
# With 8 jobs
ctest -j8

# All CPUs
ctest -j$(nproc)    # Linux
ctest -j%NUMBER_OF_PROCESSORS%  # Windows
```

### 9.5 Verbose

```bash
# Output on failure
ctest --output-on-failure

# Always verbose
ctest -V

# Extra verbose
ctest -VV
```

### 9.6 Combined

```bash
# Unit tests, parallel, verbose on failure
ctest -L unit -j8 --output-on-failure
```

---

## 10. Best Practices

### 10.1 Test Naming

```cpp
// ❌ Bad
TEST_CASE("Test1") { }
TEST_CASE("It works") { }

// ✅ Good
TEST_CASE("Calculator::add returns sum of two integers") { }
TEST_CASE("Parser throws on invalid input") { }
```

### 10.2 Test Isolation

```cpp
// ❌ Bad - global state
static int counter = 0;
TEST_CASE("First") { counter++; }
TEST_CASE("Second") { CHECK(counter == 1); }  // Depends on the order

// ✅ Good - every test is independent
TEST_CASE("Counter increments") {
    Counter c;
    c.increment();
    CHECK(c.value() == 1);
}
```

### 10.3 Arrange-Act-Assert

```cpp
TEST_CASE("User::setEmail validates format") {
    // Arrange
    User user;
    
    // Act
    bool result = user.setEmail("invalid-email");
    
    // Assert
    CHECK(result == false);
    CHECK(user.email().empty());
}
```

### 10.4 Use Labels Sensibly

```json
"labels": ["unit", "database", "slow"]
```

```bash
# CI: fast tests first
ctest -L fast
ctest -LE fast  # Then the rest
```

### 10.5 Set Timeouts

```json
// Fast unit tests
"timeout": 10

// Integration tests
"timeout": 60

// Performance tests
"timeout": 300
```

---

## 11. Pitfalls and Solutions

### 11.1 Test Not Found

**Problem:**
```
No tests were found!!!
```

**Cause:** `BUILD_TESTS=ON` not set or the tests array is empty.

**Solution:**
1. Configure CMake with `-DBUILD_TESTS=ON`
2. Check the `tests` array in Solution.json
3. Does the source path exist?

### 11.2 Framework Header Not Found

**Problem:**
```
fatal error: 'doctest/doctest.h' file not found
```

**Cause:** Test framework not linked as an external.

**Solution:** Add the framework to the test's `externals`:

```json
"tests": [
    {
        "name": "MyLib_Tests",
        "externals": ["doctest"]  // ← Here!
    }
]
```

### 11.3 Dependency Not Found

**Problem:**
```
[E101] Dependency 'CoreLib' for test 'CoreLib_Tests' does not exist
```

**Cause:** The library to be tested does not exist or is misspelled.

**Solution:**
1. Define the library in the `libraries` array
2. Copy the name exactly (case-sensitive)
3. Set `dependencies` correctly

### 11.4 Tests Are Not Built

**Problem:** Tests do not appear in the IDE/build.

**Cause:** `BUILD_TESTS` is OFF (default).

**Solution:**
```bash
cmake --preset ... -DBUILD_TESTS=ON
```

Or in CMakeUserPresets.json:
```json
{
    "cacheVariables": {
        "BUILD_TESTS": "ON"
    }
}
```

### 11.5 Linker Error with the Tested Library

**Problem:**
```
undefined reference to 'Calculator::add(int, int)'
```

**Cause:** Library not listed in `dependencies`.

**Solution:**
```json
"tests": [
    {
        "name": "CoreLib_Tests",
        "dependencies": ["CoreLib"]  // ← Enter the library here
    }
]
```

---

## 12. Troubleshooting

### Checklist for Problems

1. ☐ `BUILD_TESTS=ON` set?
2. ☐ Test defined in the `tests` array?
3. ☐ Framework present as an external?
4. ☐ Framework in the test's `externals` list?
5. ☐ Dependencies correct (library exists)?
6. ☐ Source path exists?
7. ☐ CMake cache deleted? (`cmake --fresh`)

### Common Errors

| Error | Solution |
|-------|----------|
| `No tests were found` | Set `BUILD_TESTS=ON` |
| `doctest.h file not found` | Add the external to `externals` |
| `Dependency does not exist` | Add the library to `libraries` |
| `Test timeout` | Increase the timeout |
| `undefined reference` | Add the dependency to `dependencies` |

### Debug Output

```bash
# CTest verbose
ctest -VV --output-on-failure

# CMake test discovery
cmake --build ... --target help | grep -i test

# Run a single test directly
./out/build/.../bin/CoreLib_Tests
```

---

## 13. See Also

- [Solution_Schema.md](../references/Solution_Schema.md) – JSON schema for tests
- [ErrorCodes.md](../references/ErrorCodes.md) – Test-related error codes
- [Externals UserGuide](Externals.md) – Test frameworks as externals

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.1 | 2026-11-09 | Aligned with the code: preset `windows-ninja-debug` does not exist, replaced by `windows-ninja-debug-msvc` (`CMakePresets.json`) |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| **0.5.0** | **2025-12-14** | **Blueprint v0.5.0 conformance: prerequisites, pitfalls/troubleshooting separated, see also** |
| 0.1.0 | 2025-12-11 | Initial: framework comparison, configuration, examples |
