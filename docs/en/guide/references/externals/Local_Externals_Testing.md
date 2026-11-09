# Local Externals — Testing

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Local_Externals_Testing.md](../../../../de/guide/references/externals/Local_Externals_Testing.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [doctest Testing Framework](#2-doctest-testing-framework)
3. [See Also](#3-see-also)
4. [Changelog](#changelog)

---

## 1. Overview

This document describes local testing externals for the CMake Architecture build system.

| Library | Description | License |
|---------|-------------|---------|
| **doctest** | Fast header-only testing framework | MIT |

---

## 2. doctest Testing Framework

### Quick Info

| Aspect | Value |
|--------|-------|
| **Type** | 📄 Header-Only |
| **Path** | `externals/doctest` |
| **Include.cmake** | `cmake/externals/includes/doctest/Include.cmake` |
| **Platforms** | All |
| **GitHub** | [doctest/doctest](https://github.com/doctest/doctest) |

### Why doctest?

| Advantage | Description |
|-----------|-------------|
| **Fast** | Extremely fast compilation |
| **Header-Only** | Just one header, no library |
| **Lightweight** | Minimal overhead |
| **BDD-Style** | Subcases for nested tests |

### Solution.json

```json
{
    "externals": {
        "doctest": {
            "path": "externals/doctest"
        }
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

### Directory Structure

```
externals/doctest/
└── include/
    └── doctest/
        └── doctest.h
```

> **Note:** doctest consists of a single header only!

### Usage Example

```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest/doctest.h>

TEST_CASE("Math operations") {
    CHECK(1 + 1 == 2);
    CHECK(2 * 3 == 6);
    CHECK(10 / 2 == 5);
}
```

### Subcases (BDD Style)

```cpp
#include <doctest/doctest.h>
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

### Assertions

| Assertion | Description |
|-----------|-------------|
| `CHECK(expr)` | Checks, continues on failure |
| `REQUIRE(expr)` | Checks, aborts on failure |
| `CHECK_EQ(a, b)` | Equality with details |
| `CHECK_NE(a, b)` | Inequality |
| `CHECK_THROWS(expr)` | Exception expected |
| `CHECK_NOTHROW(expr)` | No exception expected |

### Test Suites

```cpp
TEST_SUITE("Math") {
    TEST_CASE("Addition") {
        CHECK(1 + 1 == 2);
    }
    
    TEST_CASE("Subtraction") {
        CHECK(5 - 3 == 2);
    }
}
```

### Compile-Time Configuration

| Define | Description |
|--------|-------------|
| `DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN` | Generate main() automatically |
| `DOCTEST_CONFIG_IMPLEMENT` | Implementation only, no main() |
| `DOCTEST_CONFIG_DISABLE` | Disable tests completely |

### Comparison with Git Alternatives

| Feature | doctest (Local) | googletest (Git) | catch2 (Git) |
|---------|-----------------|------------------|--------------|
| **Header-Only** | ✅ | ❌ | ✅ |
| **Compile time** | ⚡ Very fast | 🐢 Slow | 🐌 Slower |
| **Mocking** | ❌ | ✅ GMock | ❌ |
| **BDD Subcases** | ✅ | ❌ | ✅ |
| **Footprint** | Minimal | Large | Medium |

### Detail Documentation

→ [doctest_Include.md](../../module/externals/includes/doctest/Doctest_Include.md)

---

## 3. See Also

- [Externals.md](../Externals.md) — Main overview of all externals
- [Local_Externals.md](Local_Externals.md) — Local Externals overview
- [Git_Externals_Testing.md](Git_Externals_Testing.md) — Git testing externals (googletest, catch2)
- [Testing_UserGuide.md](../../userguides/Testing.md) — Testing guide

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.2 | 2025-12-15 | Own category Testing (parallel to Git) |
