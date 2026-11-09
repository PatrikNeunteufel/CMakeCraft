# doctest — UserGuide

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Guide  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Doctest.md](../../../../de/guide/userguides/externals/Doctest.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Installation](#2-installation)
3. [Solution.json Configuration](#3-solutionjson-configuration)
4. [C++ Usage](#4-c-usage)
5. [Advanced Techniques](#5-advanced-techniques)
6. [Best Practices](#6-best-practices)
7. [Troubleshooting](#7-troubleshooting)
8. [Further Information](#8-further-information)
9. [Changelog](#changelog)

---

## 1. Overview

**doctest** is a fast, header-only C++ testing framework with minimal compile time.

| Aspect | Value |
|--------|-------|
| **Type** | Local External (header-only) |
| **Path** | `externals/doctest` |
| **License** | MIT |
| **Website** | [github.com/doctest/doctest](https://github.com/doctest/doctest) |

### Why doctest?

| Advantage | Description |
|-----------|-------------|
| ⚡ **Fast** | Extremely fast compilation |
| 📄 **Header-Only** | Just one header, no library |
| 🪶 **Lightweight** | Minimal overhead (~17KB) |
| 🔀 **Subcases** | BDD-style nested tests |

---

## 2. Installation

### 2.1 Download

```bash
# From GitHub
git clone https://github.com/doctest/doctest.git externals/doctest

# Or just the header
mkdir -p externals/doctest/include/doctest
curl -o externals/doctest/include/doctest/doctest.h \
  https://raw.githubusercontent.com/doctest/doctest/master/doctest/doctest.h
```

### 2.2 Directory Structure

```
externals/doctest/
└── include/
    └── doctest/
        └── doctest.h
```

---

## 3. Solution.json Configuration

### 3.1 Minimal

```json
{
    "externals": {
        "doctest": {
            "path": "externals/doctest"
        }
    },
    "tests": [
        {
            "name": "UnitTests",
            "framework": "doctest",
            "externals": ["doctest"]
        }
    ]
}
```

### 3.2 With Library Tests

```json
{
    "externals": {
        "doctest": {
            "path": "externals/doctest"
        }
    },
    "libraries": [
        {
            "name": "CoreLib",
            "type": "static"
        }
    ],
    "tests": [
        {
            "name": "CoreTests",
            "framework": "doctest",
            "externals": ["doctest"],
            "libraries": ["CoreLib"]
        }
    ]
}
```

### 3.3 Multiple Test Suites

```json
{
    "tests": [
        {
            "name": "UnitTests",
            "framework": "doctest",
            "externals": ["doctest"],
            "sources": ["tests/unit"]
        },
        {
            "name": "IntegrationTests",
            "framework": "doctest",
            "externals": ["doctest"],
            "sources": ["tests/integration"]
        }
    ]
}
```

---

## 4. C++ Usage

### 4.1 Simple Test

```cpp
// tests/test_math.cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest/doctest.h>

TEST_CASE("Addition") {
    CHECK(1 + 1 == 2);
    CHECK(2 + 3 == 5);
    CHECK(-1 + 1 == 0);
}

TEST_CASE("Subtraction") {
    CHECK(5 - 3 == 2);
    CHECK(0 - 1 == -1);
}
```

### 4.2 Assertions

| Assertion | Description | On Failure |
|-----------|-------------|------------|
| `CHECK(expr)` | Checks expression | Continue |
| `REQUIRE(expr)` | Checks expression | Abort |
| `CHECK_EQ(a, b)` | Equality | Continue |
| `CHECK_NE(a, b)` | Inequality | Continue |
| `CHECK_LT(a, b)` | a < b | Continue |
| `CHECK_GT(a, b)` | a > b | Continue |
| `CHECK_LE(a, b)` | a <= b | Continue |
| `CHECK_GE(a, b)` | a >= b | Continue |
| `CHECK_THROWS(expr)` | Exception expected | Continue |
| `CHECK_NOTHROW(expr)` | No exception | Continue |

```cpp
TEST_CASE("Various assertions") {
    int x = 42;
    
    CHECK(x == 42);
    CHECK_EQ(x, 42);
    CHECK_NE(x, 0);
    CHECK_GT(x, 0);
    CHECK_LE(x, 100);
    
    CHECK_THROWS(throw std::runtime_error("error"));
    CHECK_NOTHROW(x = 1);
}
```

### 4.3 Subcases (BDD Style)

Subcases enable nested tests with shared setup:

```cpp
TEST_CASE("String operations") {
    std::string s = "Hello";  // Shared setup
    
    SUBCASE("append") {
        s += " World";
        CHECK(s == "Hello World");
        CHECK(s.length() == 11);
    }
    
    SUBCASE("clear") {
        s.clear();
        CHECK(s.empty());
        CHECK(s.length() == 0);
    }
    
    SUBCASE("substring") {
        SUBCASE("from start") {
            CHECK(s.substr(0, 2) == "He");
        }
        SUBCASE("from middle") {
            CHECK(s.substr(2, 2) == "ll");
        }
    }
}
```

**Execution order:**
```
String operations → append
String operations → clear
String operations → substring → from start
String operations → substring → from middle
```

### 4.4 Test Suites

```cpp
TEST_SUITE("Math") {
    TEST_CASE("Addition") {
        CHECK(1 + 1 == 2);
    }
    
    TEST_CASE("Multiplication") {
        CHECK(2 * 3 == 6);
    }
}

TEST_SUITE("Strings") {
    TEST_CASE("Concatenation") {
        CHECK(std::string("a") + "b" == "ab");
    }
}
```

### 4.5 Fixtures

```cpp
struct DatabaseFixture {
    DatabaseFixture() {
        // Setup: called before each TEST_CASE_FIXTURE
        db.connect("test.db");
    }
    
    ~DatabaseFixture() {
        // Teardown: called after each TEST_CASE_FIXTURE
        db.disconnect();
    }
    
    Database db;
};

TEST_CASE_FIXTURE(DatabaseFixture, "Insert record") {
    db.insert("key", "value");
    CHECK(db.get("key") == "value");
}

TEST_CASE_FIXTURE(DatabaseFixture, "Delete record") {
    db.insert("key", "value");
    db.remove("key");
    CHECK_FALSE(db.exists("key"));
}
```

### 4.6 Parameterized Tests

```cpp
TEST_CASE("Parameterized test") {
    std::vector<std::pair<int, int>> test_data = {
        {1, 1}, {2, 4}, {3, 9}, {4, 16}
    };
    
    for (const auto& [input, expected] : test_data) {
        CAPTURE(input);  // Shows the value on failure
        CHECK(input * input == expected);
    }
}
```

### 4.7 Exception Testing

```cpp
void might_throw(int x) {
    if (x < 0) throw std::invalid_argument("negative");
    if (x > 100) throw std::out_of_range("too large");
}

TEST_CASE("Exception handling") {
    CHECK_THROWS(might_throw(-1));
    CHECK_THROWS_AS(might_throw(-1), std::invalid_argument);
    CHECK_THROWS_WITH(might_throw(-1), "negative");
    
    CHECK_NOTHROW(might_throw(50));
}
```

---

## 5. Advanced Techniques

### 5.1 Your Own main() Function

```cpp
#define DOCTEST_CONFIG_IMPLEMENT
#include <doctest/doctest.h>

int main(int argc, char** argv) {
    doctest::Context context;
    
    // Set defaults
    context.setOption("abort-after", 5);
    context.setOption("order-by", "name");
    
    // Parse command line
    context.applyCommandLine(argc, argv);
    
    // Run tests
    int res = context.run();
    
    // Cleanup
    if (context.shouldExit()) {
        return res;
    }
    
    // Your own code after the tests
    return res;
}
```

### 5.2 Disabling Tests in Production Code

```cpp
// Do not compile tests in release builds
#ifdef NDEBUG
#define DOCTEST_CONFIG_DISABLE
#endif

#include <doctest/doctest.h>

// These tests are ignored in release builds
TEST_CASE("Debug only test") {
    CHECK(1 == 1);
}
```

### 5.3 Test Filters (Command Line)

```bash
# Only tests with "Math" in the name
./tests --test-case="*Math*"

# Exclude tests
./tests --test-case-exclude="*Slow*"

# Specific suite
./tests --test-suite="Unit"

# Verbose output
./tests --success

# List all tests
./tests --list-test-cases
```

### 5.4 Reporters

```bash
# Standard (console)
./tests

# Compact
./tests --reporters=compact

# XML (for CI)
./tests --reporters=xml --out=results.xml
```

---

## 6. Best Practices

### 6.1 File Organization

```
project/
├── src/
│   └── math.cpp
├── include/
│   └── math.h
└── tests/
    ├── test_main.cpp      # Only DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
    ├── test_math.cpp      # Tests without main()
    └── test_strings.cpp   # Tests without main()
```

**test_main.cpp:**
```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest/doctest.h>
```

**test_math.cpp:**
```cpp
#include <doctest/doctest.h>
#include "math.h"

TEST_CASE("Math functions") {
    // Tests...
}
```

### 6.2 Meaningful Error Messages

```cpp
TEST_CASE("User validation") {
    User user{"John", -5};  // Invalid age
    
    // Bad: no info on failure
    CHECK(user.isValid());
    
    // Better: with INFO
    INFO("User: ", user.name, ", Age: ", user.age);
    CHECK(user.isValid());
    
    // Even better: with CAPTURE
    CAPTURE(user.name);
    CAPTURE(user.age);
    CHECK(user.isValid());
}
```

### 6.3 AAA Pattern

```cpp
TEST_CASE("Order total calculation") {
    // Arrange
    Order order;
    order.addItem(Item{"Book", 10.0});
    order.addItem(Item{"Pen", 2.50});
    
    // Act
    double total = order.calculateTotal();
    
    // Assert
    CHECK(total == doctest::Approx(12.50));
}
```

---

## 7. Troubleshooting

### 7.1 "doctest/doctest.h not found"

**Problem:** Header not found

**Solution:** Check the path in Solution.json:
```json
"doctest": {
    "path": "externals/doctest"  // Must contain include/doctest/doctest.h
}
```

### 7.2 "multiple definition of main"

**Problem:** main() defined more than once

**Solution:** `DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN` in ONE file only:
```cpp
// test_main.cpp - ONLY HERE
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest/doctest.h>

// other_tests.cpp - WITHOUT main
#include <doctest/doctest.h>
```

### 7.3 Floating-Point Comparisons

**Problem:** Float comparisons fail

**Solution:** Use `doctest::Approx`:
```cpp
CHECK(result == doctest::Approx(3.14159).epsilon(0.001));
```

### 7.4 Tests Are Not Executed

**Problem:** Tests do not show up

**Solution:** Check whether `DOCTEST_CONFIG_DISABLE` is set.

---

## 8. Further Information

### Official Resources

| Resource | Link |
|----------|------|
| **GitHub** | [github.com/doctest/doctest](https://github.com/doctest/doctest) |
| **Documentation** | [github.com/doctest/doctest/blob/master/doc/markdown/readme.md](https://github.com/doctest/doctest/blob/master/doc/markdown/readme.md) |
| **Tutorial** | [github.com/doctest/doctest/blob/master/doc/markdown/tutorial.md](https://github.com/doctest/doctest/blob/master/doc/markdown/tutorial.md) |
| **Assertion Reference** | [github.com/doctest/doctest/blob/master/doc/markdown/assertions.md](https://github.com/doctest/doctest/blob/master/doc/markdown/assertions.md) |

### See Also

- [Externals.md](../Externals.md) — Externals combinations
- [Local_Externals_Testing.md](../../references/externals/Local_Externals_Testing.md) — Reference
- [googletest.md](Googletest.md) — Alternative with mocking
- [catch2.md](Catch2.md) — Alternative with BDD

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.2 | 2025-12-15 | Initial: detailed UserGuide for doctest |
