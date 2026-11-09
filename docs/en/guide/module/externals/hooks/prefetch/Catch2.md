# PreFetch/catch2.cmake — Catch2 PreFetch Hook

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5, Doc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [Catch2.md](../../../../../../de/guide/module/externals/hooks/prefetch/Catch2.md)  
> **Hook:** [cmake/externals/Hooks/PreFetch/catch2.cmake](../../../../../../../cmake/externals/hooks/prefetch/catch2.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Why a PreFetch Hook?](#2-why-a-prefetch-hook)
3. [Target Mapping](#3-target-mapping)
4. [Options Set](#4-options-set)
5. [Solution.json Configuration](#5-solutionjson-configuration)
6. [Created Targets](#6-created-targets)
7. [Usage in Tests](#7-usage-in-tests)
8. [See Also](#8-see-also)
9. [Changelog](#9-changelog)

---

## 1. Overview

The `catch2.cmake` PreFetch hook configures Catch2 v3 before the build. It defines target mappings for auto-registration and disables unneeded components.

**Important:** Catch2 v3 is **no longer header-only**! It must be linked as a library.

---

## 2. Why a PreFetch Hook?

**Problem 1 — Target names:**  
Catch2 creates targets with names other than the external name (`Catch2`, `Catch2WithMain` instead of `catch2`).

**Problem 2 — Unneeded targets:**  
Without the hook, tests, examples and extras are built as well.

---

## 3. Target Mapping

The hook registers the Catch2 targets via global properties:

```cmake
set_property(GLOBAL PROPERTY HOOK_KNOWN_TARGETS_${HOOK_EXTERNAL_NAME}
    "Catch2;Catch2WithMain"
)
set_property(GLOBAL PROPERTY HOOK_PRIMARY_TARGET_${HOOK_EXTERNAL_NAME}
    "Catch2WithMain"
)
```

| Property | Value | Description |
|----------|-------|-------------|
| `HOOK_KNOWN_TARGETS` | `Catch2;Catch2WithMain` | All available targets |
| `HOOK_PRIMARY_TARGET` | `Catch2WithMain` | Default target for linking |

---

## 4. Options Set

| Option | Value | Description |
|--------|-------|-------------|
| `CATCH_BUILD_TESTING` | `OFF` | Do not build its own tests |
| `CATCH_BUILD_EXAMPLES` | `OFF` | Do not build examples |
| `CATCH_INSTALL_DOCS` | `OFF` | Do not install docs |
| `CATCH_INSTALL_EXTRAS` | `OFF` | No CMake extras |
| `BUILD_SHARED_LIBS` | `OFF` | Build as a static library |

---

## 5. Solution.json Configuration

### External Definition

```json
{
    "catch2": {
        "git": "https://github.com/catchorg/Catch2.git",
        "tag": "v3.5.2"
    }
}
```

### Using It in Tests

```json
{
    "tests": [{
        "name": "CoreTests",
        "framework": "catch2",
        "externals": ["catch2"]
    }]
}
```

**Note:** The test system automatically adds `catch2` to the externals when `"framework": "catch2"` is set.

---

## 6. Created Targets

| Target | Type | Description |
|--------|------|-------------|
| `Catch2` | STATIC | Catch2 without main() |
| `Catch2WithMain` | STATIC | Catch2 with main() (recommended) |

**Recommendation:** Use `Catch2WithMain` for most tests (PRIMARY target).

---

## 7. Usage in Tests

### Simple Test with Catch2WithMain

```cpp
#include <catch2/catch_test_macros.hpp>

TEST_CASE("Example test", "[example]") {
    REQUIRE(1 + 1 == 2);
}
```

No own `main()` needed — it is provided by `Catch2WithMain`.

### Test with Its Own Main

```cpp
#define CATCH_CONFIG_RUNNER
#include <catch2/catch_all.hpp>

int main(int argc, char* argv[]) {
    // Custom setup
    return Catch::Session().run(argc, argv);
}
```

For this, link `Catch2` instead of `Catch2WithMain`.

---

## 8. See Also

- [HookLoader_cmake.md](../HookLoader_cmake.md) — Hook system
- [Targets_cmake.md](../../registry/Targets_cmake.md) — Target registration
- [Googletest.md](Googletest.md) — GoogleTest alternative
- [Tests.md](../../../project/Tests.md) — Test pipeline

---

## 9. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-16 | Initial documentation in Blueprint v0.5.0 format |
