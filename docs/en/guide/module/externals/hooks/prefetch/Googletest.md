# PreFetch/googletest.cmake — GoogleTest PreFetch Hook

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5, Doc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [Googletest.md](../../../../../../de/guide/module/externals/hooks/prefetch/Googletest.md)  
> **Hook:** [cmake/externals/Hooks/PreFetch/googletest.cmake](../../../../../../../cmake/externals/hooks/prefetch/googletest.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Why a PreFetch Hook?](#2-why-a-prefetch-hook)
3. [Target Mapping](#3-target-mapping)
4. [Options Set](#4-options-set)
5. [Windows CRT Fix](#5-windows-crt-fix)
6. [Solution.json Configuration](#6-solutionjson-configuration)
7. [Created Targets](#7-created-targets)
8. [Usage in Tests](#8-usage-in-tests)
9. [See Also](#9-see-also)
10. [Changelog](#10-changelog)

---

## 1. Overview

The `googletest.cmake` PreFetch hook configures Google Test and Google Mock before the build. It defines target mappings and fixes the common Windows CRT linking error.

---

## 2. Why a PreFetch Hook?

**Problem 1 — Target names:**  
GoogleTest creates targets with names other than the external name (`gtest`, `gmock` instead of `googletest`).

**Problem 2 — Windows CRT:**  
Without `gtest_force_shared_crt=ON` there are linker errors on Windows:
```
LNK2038: mismatch detected for 'RuntimeLibrary'
```

**Problem 3 — Unneeded installation:**  
Without the hook, an install target is created that is not needed with FetchContent.

---

## 3. Target Mapping

The hook registers the GoogleTest targets via global properties:

```cmake
set_property(GLOBAL PROPERTY HOOK_KNOWN_TARGETS_${HOOK_EXTERNAL_NAME}
    "gtest;gtest_main;gmock;gmock_main"
)
set_property(GLOBAL PROPERTY HOOK_PRIMARY_TARGET_${HOOK_EXTERNAL_NAME}
    "gmock_main"
)
```

| Property | Value | Description |
|----------|-------|-------------|
| `HOOK_KNOWN_TARGETS` | `gtest;gtest_main;gmock;gmock_main` | All available targets |
| `HOOK_PRIMARY_TARGET` | `gmock_main` | Default target (contains gtest + gmock) |

---

## 4. Options Set

| Option | Value | Description |
|--------|-------|-------------|
| `BUILD_GMOCK` | `ON` | Build Google Mock as well |
| `INSTALL_GTEST` | `OFF` | No install target |
| `gtest_hide_internal_symbols` | `ON` | Hide internal symbols |

---

## 5. Windows CRT Fix

On Windows the following is set automatically:

```cmake
set(gtest_force_shared_crt ON CACHE BOOL 
    "Use shared (DLL) run-time lib even when Google Test is built as static lib." 
    FORCE
)
```

### Background

By default GoogleTest compiles with the **static CRT** (`/MT`), but most projects use the **dynamic CRT** (`/MD`). This leads to linker errors.

The option `gtest_force_shared_crt=ON` makes GoogleTest use the same CRT as the main project.

---

## 6. Solution.json Configuration

### External Definition

```json
{
    "googletest": {
        "git": "https://github.com/google/googletest.git",
        "tag": "v1.14.0"
    }
}
```

### Using It in Tests

```json
{
    "tests": [{
        "name": "UnitTests",
        "framework": "googletest",
        "externals": ["googletest"]
    }]
}
```

**Note:** The test system automatically adds `googletest` to the externals when `"framework": "googletest"` is set.

---

## 7. Created Targets

| Target | Type | Description |
|--------|------|-------------|
| `gtest` | STATIC | Google Test without main() |
| `gtest_main` | STATIC | Google Test with main() |
| `gmock` | STATIC | Google Mock without main() |
| `gmock_main` | STATIC | Google Mock with main() (recommended) |

**Recommendation:** Use `gmock_main` for most tests (PRIMARY target) — it contains both Google Test and Google Mock.

---

## 8. Usage in Tests

### Simple Test with gmock_main

```cpp
#include <gtest/gtest.h>

TEST(ExampleTest, BasicAssertion) {
    EXPECT_EQ(1 + 1, 2);
}
```

No own `main()` needed — it is provided by `gmock_main`.

### Test with Mocking

```cpp
#include <gtest/gtest.h>
#include <gmock/gmock.h>

class MockClass {
public:
    MOCK_METHOD(int, getValue, (), (const));
};

TEST(MockTest, Example) {
    MockClass mock;
    EXPECT_CALL(mock, getValue()).WillOnce(testing::Return(42));
    EXPECT_EQ(mock.getValue(), 42);
}
```

### Test with Its Own Main

```cpp
#include <gtest/gtest.h>

int main(int argc, char** argv) {
    testing::InitGoogleTest(&argc, argv);
    // Custom setup
    return RUN_ALL_TESTS();
}
```

For this, link `gtest` instead of `gtest_main`.

---

## 9. See Also

- [HookLoader_cmake.md](../HookLoader_cmake.md) — Hook system
- [Targets_cmake.md](../../registry/Targets_cmake.md) — Target registration
- [Catch2.md](Catch2.md) — Catch2 alternative
- [Tests.md](../../../project/Tests.md) — Test pipeline

---

## 10. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-16 | Initial documentation in Blueprint v0.5.0 format |
