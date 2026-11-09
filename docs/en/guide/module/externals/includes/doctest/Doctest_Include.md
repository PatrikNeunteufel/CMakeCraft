# doctest/Include.cmake — doctest Testing Framework Integration

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5, Doc v0.5  
> **Target Audience:** Build System Developers, C++ Developers  
> **Language:** English  
> **German:** [Doctest_Include.md](../../../../../../de/guide/module/externals/includes/doctest/Doctest_Include.md)  
> **Module:** [cmake/externals/includes/doctest/Include.cmake](../../../../../../../cmake/externals/includes/doctest/Include.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Available Variables](#2-available-variables)
3. [Created Targets](#3-created-targets)
4. [Options](#4-options)
5. [Usage Examples](#5-usage-examples)
6. [Test Patterns](#6-test-patterns)
7. [Directory Structure](#7-directory-structure)
8. [Error Handling](#8-error-handling)
9. [See Also](#9-see-also)
10. [Changelog](#changelog)

---

## 1. Overview

`doctest/Include.cmake` integrates the **doctest testing framework** into the build system as a local external.

### Core Functions

| Function | Description |
|----------|-------------|
| Header-only | Only one header, no library needed |
| Fast | Extremely fast compilation |
| Lightweight | Minimal overhead |
| BDD style | Subcases for nested tests |

### Integration

Creates **no target of its own**. The module sets the include path `externals/doctest/` (where `doctest.h` lies directly) on the target `EXECUTABLE_NAME`, plus compile defines and warning switches depending on the options.

---

## 2. Available Variables

These variables are provided by the orchestrator:

| Variable | Description |
|----------|-------------|
| `EXTERNAL_NAME` | `"doctest"` |
| `EXTERNAL_ROOT` | Absolute path to `externals/doctest` (`path` from Solution.json) |
| `EXTERNAL_OPTIONS` | Target-specific options (JSON) |
| `EXECUTABLE_NAME` | Target that doctest is attached to |

---

## 3. Created Targets

| Target | Type | Description |
|--------|------|-------------|
| — | — | No target of its own; everything is attached `PRIVATE` to `EXECUTABLE_NAME` |

### Include Directories

```cmake
# doctest.h is in the root directory
target_include_directories(${EXECUTABLE_NAME} PRIVATE "${_doctest_root}")
```

`_doctest_root` is `EXTERNAL_ROOT`. In code this means `#include <doctest.h>`.

In addition: MSVC `/wd4251 /wd4275`, GCC/Clang `-Wno-unknown-pragmas`.

---

## 4. Options

Via `external_options` in Solution.json (per target):

| Option | Type | Default | Effect |
|--------|------|---------|--------|
| `DOCTEST_NO_SHORT_MACRO_NAMES` | bool | `false` | define `DOCTEST_CONFIG_NO_SHORT_MACRO_NAMES` |
| `DOCTEST_CONFIG_SUPER_FAST_ASSERTS` | bool | `false` | define `DOCTEST_CONFIG_SUPER_FAST_ASSERTS` |
| `DOCTEST_CONFIG_DISABLE` | bool | `false` | define `DOCTEST_CONFIG_DISABLE` |

### Compile-Time Configuration

These defines can be set in C++ before `#include <doctest.h>`:

| Define | Description |
|--------|-------------|
| `DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN` | Generate main() automatically |
| `DOCTEST_CONFIG_IMPLEMENT` | Implementation only, no main() |
| `DOCTEST_CONFIG_DISABLE` | Disable tests completely |
| `DOCTEST_CONFIG_NO_SHORT_MACRO_NAMES` | Only `DOCTEST_*` macros |

---

## 5. Usage Examples

### 5.1 Simple Unit Test

**Solution.json:**

```json
{
    "externals": {
        "doctest": { "path": "externals/doctest" }
    },
    "tests": [
        {
            "name": "MyTests",
            "framework": "doctest",
            "externals": ["doctest"]
        }
    ]
}
```

**test_main.cpp:**

```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.h>

TEST_CASE("Math operations") {
    CHECK(1 + 1 == 2);
    CHECK(2 * 3 == 6);
    CHECK(10 / 2 == 5);
}
```

### 5.2 Subcases (BDD Style)

```cpp
#include <doctest.h>
#include <string>

TEST_CASE("String operations") {
    std::string s = "Hello";
    
    SUBCASE("append") {
        s += " World";
        CHECK(s == "Hello World");
    }
    
    SUBCASE("length") {
        CHECK(s.length() == 5);
    }
    
    SUBCASE("clear") {
        s.clear();
        CHECK(s.empty());
    }
}
```

### 5.3 Test with Fixtures

```cpp
#include <doctest.h>
#include <vector>

TEST_CASE("Vector tests") {
    std::vector<int> vec;
    
    REQUIRE(vec.empty());
    
    SUBCASE("push_back") {
        vec.push_back(1);
        vec.push_back(2);
        
        CHECK(vec.size() == 2);
        CHECK(vec[0] == 1);
        CHECK(vec[1] == 2);
    }
    
    SUBCASE("reserve") {
        vec.reserve(100);
        
        CHECK(vec.capacity() >= 100);
        CHECK(vec.empty());  // Size is still 0
    }
}
```

### 5.4 Own main() Function

```cpp
#define DOCTEST_CONFIG_IMPLEMENT
#include <doctest.h>

int main(int argc, char** argv) {
    doctest::Context context;
    
    // Defaults
    context.setOption("abort-after", 5);
    context.setOption("order-by", "name");
    
    // Command-line arguments
    context.applyCommandLine(argc, argv);
    
    int result = context.run();
    
    if (context.shouldExit()) {
        return result;
    }
    
    // Own logic here...
    
    return result;
}
```

### 5.5 Disabling Tests in Production Code

```cpp
// In release builds: remove tests completely
#ifdef NDEBUG
    #define DOCTEST_CONFIG_DISABLE
#endif

#include <doctest.h>

// These tests exist only in debug builds
TEST_CASE("Debug-only test") {
    CHECK(1 == 1);
}
```

---

## 6. Test Patterns

### 6.1 Assertions

| Assertion | Description |
|-----------|-------------|
| `CHECK(expr)` | Checks, continues on failure |
| `REQUIRE(expr)` | Checks, aborts on failure |
| `CHECK_EQ(a, b)` | Equality with details |
| `CHECK_NE(a, b)` | Inequality |
| `CHECK_LT(a, b)` | Less than |
| `CHECK_GT(a, b)` | Greater than |
| `CHECK_THROWS(expr)` | Exception expected |
| `CHECK_NOTHROW(expr)` | No exception expected |

### 6.2 Test Organization

```cpp
TEST_SUITE("Math") {
    TEST_CASE("Addition") {
        CHECK(1 + 1 == 2);
    }
    
    TEST_CASE("Subtraction") {
        CHECK(5 - 3 == 2);
    }
}

TEST_SUITE("Strings") {
    TEST_CASE("Concatenation") {
        CHECK(std::string("a") + "b" == "ab");
    }
}
```

### 6.3 Parameterized Tests

```cpp
TEST_CASE_TEMPLATE("Type traits", T, int, float, double) {
    T value = T(42);
    CHECK(value == T(42));
}
```

---

## 7. Directory Structure

```
externals/doctest/
└── doctest.h
```

> **Note:** doctest consists of a single header only!

---

## 8. Error Handling

| Code | Description |
|------|-------------|
| E213 | Include.cmake not found |
| E214 | External path does not exist |

### Common Errors

**"doctest.h not found":**
```cpp
// Wrong (the local external provides no doctest/ subfolder):
#include <doctest/doctest.h>

// Correct:
#include <doctest.h>
```

**"Undefined reference to main":**
```cpp
// Missing:
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.h>
```

---

## 9. See Also

- [Testing.md](../../../../userguides/Testing.md) — Testing guide
- [Solution_Schema.md](../../../../references/Solution_Schema.md) — tests array
- [Attach_cmake.md](../../locals/Attach_cmake.md) — Local external handler
- [doctest GitHub](https://github.com/doctest/doctest) — Official documentation

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: no INTERFACE target, but the include path `externals/doctest/` on the target `EXECUTABLE_NAME`; `#include <doctest.h>` throughout (contradiction § 4/§ 8 resolved, as in the demo projects); options from `external_options`; variables and directory structure as in the code** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0, convention path `cmake/externals/includes/doctest/` |
| 0.1.0 | 2025-12-05 | Initial: header-only INTERFACE target |
