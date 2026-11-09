# CMakeUserPresets — Reference

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [CMakeUserPresets.md](../../../de/guide/references/CMakeUserPresets.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Conventions](#2-conventions)
3. [Hidden Building Blocks](#3-hidden-building-blocks)
4. [Configure Presets](#4-configure-presets)
5. [Build Presets](#5-build-presets)
6. [Test Presets](#6-test-presets)
7. [Package Presets](#7-package-presets)
8. [Workflow Presets](#8-workflow-presets)
9. [Quick Reference](#9-quick-reference)
10. [Usage](#10-usage)
11. [Customization](#11-customization)
12. [See Also](#12-see-also)
13. [Changelog](#13-changelog)

---

## 1. Overview

This reference documents the personal user presets in `CMakeUserPresets.json`. User presets extend the team presets with local configurations such as vcpkg paths, parallel builds and code signing.

### Preset Categories

| Category | Count | Description |
|----------|-------|-------------|
| Configure Presets | 7 | vcpkg combinations |
| Build Presets | 6 | Parallelized builds |
| Test Presets | 3 | CTest configurations |
| Package Presets | 1 | Code signing |
| Workflow Presets | 1 | Release + signing |

### Vendor Metadata

```json
{
    "version": 6,
    "vendor": {
        "user-presets": {
            "version": "0.5.0",
            "lastModified": "2025-12-14"
        }
    }
}
```

---

## 2. Conventions

### Naming Scheme

```
[base-preset]+[extension]

Examples:
- windows-vs-x64-debug_dynamic+vcpkg
- ninjamulti_testing+vcpkg
```

### Symbols

| Symbol | Meaning |
|--------|---------|
| + | Extension of a team preset |
| jobs=N | Parallel build jobs |

---

## 3. Hidden Building Blocks

### 3.1 with-vcpkg

Base preset for local vcpkg integration:

```json
{
    "name": "with-vcpkg",
    "hidden": true,
    "cacheVariables": {
        "VCPKG_ROOT": "C:/dev/vcpkg",
        "CMAKE_TOOLCHAIN_FILE": "C:/dev/vcpkg/scripts/buildsystems/vcpkg.cmake",
        "VCPKG_FEATURE_FLAGS": "manifests,versions"
    }
}
```

| Variable | Value | Description |
|----------|-------|-------------|
| `VCPKG_ROOT` | C:/dev/vcpkg | Local vcpkg path |
| `CMAKE_TOOLCHAIN_FILE` | .../vcpkg.cmake | Toolchain integration |
| `VCPKG_FEATURE_FLAGS` | manifests,versions | Modern features |

> **Note:** Adjust paths to your local installation!

---

## 4. Configure Presets

### 4.1 vcpkg Combinations

| Preset | Inherits From | Description |
|--------|---------------|-------------|
| `windows-vs-x64-debug_dynamic+vcpkg` | windows-vs-x64-debug_dynamic, with-vcpkg | VS Debug + vcpkg |
| `windows-vs-x64-testing_dynamic+vcpkg` | windows-vs-x64-testing_dynamic, with-vcpkg | VS Testing + vcpkg |
| `windows-ninja-multi+vcpkg` | windows-ninja-multi, with-vcpkg | Ninja Multi + vcpkg |
| `windows-ninja-multi-tests+vcpkg` | windows-ninja-multi-tests, with-vcpkg | Ninja Tests + vcpkg |
| `linux-clang-debug-asan+vcpkg` | linux-clang-debug-asan, with-vcpkg | Linux ASan + vcpkg |
| `linux-gcc-testing+vcpkg` | linux-gcc-testing, with-vcpkg | Linux GCC + vcpkg |

---

## 5. Build Presets

### 5.1 Parallelized Builds (jobs=8)

| Preset | Configure Preset | Config | Jobs |
|--------|------------------|--------|------|
| `ninjamulti_debug` | windows-ninja-multi | Debug | 8 |
| `ninjamulti_testing` | windows-ninja-multi-tests | Testing | 8 |
| `vs_x64_debug_md` | windows-vs-x64-debug_dynamic | Debug | 8 |
| `vs_x64_testing_md` | windows-vs-x64-testing_dynamic | Testing | 8 |

### 5.2 vcpkg Variants

| Preset | Configure Preset | Config | Jobs |
|--------|------------------|--------|------|
| `ninjamulti_testing+vcpkg` | windows-ninja-multi-tests+vcpkg | Testing | 8 |
| `vs_x64_testing_md+vcpkg` | windows-vs-x64-testing_dynamic+vcpkg | Testing | 8 |

---

## 6. Test Presets

| Preset | Configure Preset | Config | Output |
|--------|------------------|--------|--------|
| `ninjamulti_test_testing` | windows-ninja-multi-tests | Testing | outputOnFailure |
| `vs_x64_ctest_debug` | windows-vs-x64-debug_dynamic | Debug | outputOnFailure |
| `vs_x64_ctest_testing` | windows-vs-x64-testing_dynamic | Testing | outputOnFailure |

---

## 7. Package Presets

### 7.1 Code Signing Variant

```json
{
    "name": "package-windows-inno-Release+sign",
    "inherits": "package-windows-inno-Release",
    "variables": {
        "CPACK_INNOSETUP_EXECUTABLE_ARGUMENTS": "/Qp;/Smysigntool=$p"
    },
    "output": {
        "packageDirectory": "dist"
    }
}
```

| Setting | Value | Description |
|---------|-------|-------------|
| Base | package-windows-inno-Release | Team preset |
| ISCC args | /Qp;/Smysigntool=$p | Quiet + signtool |
| Output | dist/ | Local output directory |

---

## 8. Workflow Presets

### 8.1 wf-vs-x64-release-inno+sign

Complete release pipeline with code signing:

| Step | Type | Preset |
|------|------|--------|
| 1 | configure | windows-vs-x64-release_dynamic |
| 2 | build | build-vs-x64-Release |
| 3 | package | package-windows-inno-Release+sign |

---

## 9. Quick Reference

### 9.1 Most Common Combinations

| Use Case | Configure | Build |
|----------|-----------|-------|
| VS Debug + vcpkg | `windows-vs-x64-debug_dynamic+vcpkg` | `vs_x64_debug_md` |
| Ninja Testing + vcpkg | `windows-ninja-multi-tests+vcpkg` | `ninjamulti_testing+vcpkg` |
| Release + signing | (part of workflow) | `wf-vs-x64-release-inno+sign` |

### 9.2 User Preset vs Team Preset

| Aspect | Team Preset | User Preset |
|--------|-------------|-------------|
| File | CMakePresets.json | CMakeUserPresets.json |
| Git | ✓ Committed | ✗ .gitignored |
| Local paths | ✗ | ✓ |
| vcpkg | ✗ | ✓ |
| Code signing | ✗ | ✓ |

---

## 10. Usage

### 10.1 Daily Development

```bash
# VS Debug with vcpkg
cmake --preset windows-vs-x64-debug_dynamic+vcpkg

# Fast build (8 jobs)
cmake --build --preset vs_x64_debug_md
```

### 10.2 Tests

```bash
# Ninja Testing
cmake --preset windows-ninja-multi-tests+vcpkg
cmake --build --preset ninjamulti_testing+vcpkg
ctest --preset ninjamulti_test_testing
```

### 10.3 Release with Signing

```bash
cmake --workflow --preset wf-vs-x64-release-inno+sign
```

---

## 11. Customization

### 11.1 Change the vcpkg Path

```json
{
    "name": "with-vcpkg",
    "hidden": true,
    "cacheVariables": {
        "VCPKG_ROOT": "/pfad/zu/vcpkg",
        "CMAKE_TOOLCHAIN_FILE": "/pfad/zu/vcpkg/scripts/buildsystems/vcpkg.cmake"
    }
}
```

### 11.2 Change the Job Count

```json
{
    "name": "my-fast-build",
    "inherits": "vs_x64_debug_md",
    "jobs": 16
}
```

### 11.3 Custom Combinations

```json
{
    "name": "my-dev",
    "inherits": ["windows-vs-x64-debug_dynamic", "with-vcpkg"],
    "cacheVariables": {
        "BUILD_ONLY": "MyApp",
        "BUILD_TESTS": "OFF"
    }
}
```

---

## 12. See Also

- [CMakePresets_Manual.md](CMakePresets.md) — Concepts
- [CMakePresets_Reference.md](CMakePresets.md) — Team presets
- [CMakeUserPresets_Example.md](../userguides/CMakeUserPresets.md) — Template

---

## 13. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-14 | Blueprint v0.5.0 format: numbered TOC, reference header, quick reference, author field removed |
| 0.1.0 | 2025-12-03 | Initial: vcpkg integration, parallelized builds, code signing |
