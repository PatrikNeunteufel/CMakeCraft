# CMakePresets — Reference

> **Version:** 1.1.2  
> **Date:** 2026-11-09  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [CMakePresets.md](../../../de/guide/references/CMakePresets.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Conventions](#2-conventions)
3. [Configure Presets](#3-configure-presets)
4. [Build Presets](#4-build-presets)
5. [Test Presets](#5-test-presets)
6. [Package Presets](#6-package-presets)
7. [Workflow Presets](#7-workflow-presets)
8. [Hidden Building Blocks](#8-hidden-building-blocks)
9. [Cache Variables](#9-cache-variables)
10. [Quick Reference](#10-quick-reference)
11. [Usage](#11-usage)
12. [See Also](#12-see-also)
13. [Changelog](#13-changelog)

---

## 1. Overview

This reference documents all available team presets in `CMakePresets.json` for the CMake Architecture build system.

### Preset Categories

| Category | Count | Description |
|----------|-------|-------------|
| Configure Presets | 27 (plus 25 hidden building blocks) | Configure the build environment |
| Build Presets | 24 | Compile |
| Test Presets | 11 | Run CTest |
| Package Presets | 3 | Create installers |
| Workflow Presets | 5 | Complete pipelines |

### Vendor Metadata

```json
{
    "version": 6,
    "vendor": {
        "cmake-architecture-v2": {
            "version": "0.1.0",
            "date": "2025-12-03",
            "description": "Team-weite Presets für CMake Architecture V2"
        }
    }
}
```

---

## 2. Conventions

### Naming Scheme

```
[platform]-[generator]-[arch]-[config]_[variant]

platform:  windows, linux, macos
generator: vs, ninja, xcode
arch:      x64, ARM64, x86_64, arm64
config:    debug, release, testing
variant:   dynamic, static, asan, quality
```

### Symbols

| Symbol | Meaning |
|--------|---------|
| ✓ | Enabled/present |
| – | Default/not set |

---

## 3. Configure Presets

### 3.1 Windows • Visual Studio

| Preset | Arch | Config | CRT | Special Feature |
|--------|------|--------|-----|-----------------|
| `windows-vs-x64-debug_dynamic` | x64 | Debug | /MDd | Standard development |
| `windows-vs-x64-release_dynamic` | x64 | Release | /MD | Release builds |
| `windows-vs-x64-testing_dynamic` | x64 | Testing | /MD | Tests enabled |
| `windows-vs-ARM64-release_dynamic` | ARM64 | Release | /MD | ARM64 builds |
| `windows-vs-x64-debug_clangcl_asan` | x64 | Debug | – | Clang-CL + ASan |
| `windows-vs-x64-debug_quality` | x64 | Debug | /MDd | Clang-Tidy enabled |
| `windows-vs-x64-debug_apps-only` | x64 | Debug | /MDd | BUILD_TESTS=OFF |

**Configuration `Testing`** (since CMakeCraft v0.13.0): optimized, with asserts and debug info —
RelWithDebInfo without `NDEBUG`. MSVC/clang-cl `/O2 /Ob1 /Zi`, linker `/DEBUG /INCREMENTAL:NO`;
GCC/Clang `-O2 -g`. The flags are set by `cmake/core/Configurations.cmake`, only when
`CMAKE_<LANG>_FLAGS_TESTING` is empty (a value of your own via `-D` is kept). As with all
configurations, the CRT comes from `CMAKE_MSVC_RUNTIME_LIBRARY`. For stepping through code, use
`Debug`.

Under MSVC, every target CMakeCraft creates gets `/bigobj` in every configuration (since
v0.13.1): otherwise `/O2` and `/Zi` together break the limit of 2^16 sections per object file in
large files (C1128). `/bigobj` per file or in `compile_options` is therefore unnecessary.

### 3.2 Windows • Ninja (Single-Config)

| Preset | Compiler | Config | Special Feature |
|--------|----------|--------|-----------------|
| `windows-ninja-debug-msvc` | MSVC | Debug | – |
| `windows-ninja-release-msvc` | MSVC | Release | – |
| `windows-ninja-testing-msvc` | MSVC | Testing | Tests enabled |
| `windows-ninja-debug-clang` | Clang | Debug | – |
| `windows-ninja-release-clang` | Clang | Release | – |
| `windows-ninja-testing-clang` | Clang | Testing | Tests enabled |
| `craft-selftest` | Clang | Debug | Phase tests of the build system (`RUN_BUILD_SYSTEM_TESTS=ON`) |

**`craft-selftest`** inherits from `win-ninja-clang` (Ninja, `clang`/`clang++`) and sets
`CMAKE_BUILD_TYPE=Debug` and `RUN_BUILD_SYSTEM_TESTS=ON`: the configure run executes the phase tests
under `cmake/buildSystemTest/`; "green" means configure without errors. A single phase with an additional
`-DTEST_PHASE=<n>`. In consumer projects only needed as a smoke check after a snapshot sync.

### 3.3 Windows • Ninja (Multi-Config)

| Preset | Configs | Special Feature |
|--------|---------|-----------------|
| `windows-ninja-multi` | Debug, Release, Testing | Standard |
| `windows-ninja-multi-tests` | Debug, Release, Testing | ENABLE_TESTING_CONFIG=ON |

### 3.4 Linux • Ninja

| Preset | Compiler | Config | Special Feature |
|--------|----------|--------|-----------------|
| `linux-gcc-debug` | GCC | Debug | – |
| `linux-gcc-release` | GCC | Release | – |
| `linux-gcc-testing` | GCC | Testing | Tests enabled |
| `linux-clang-debug` | Clang | Debug | – |
| `linux-clang-release` | Clang | Release | – |
| `linux-clang-testing` | Clang | Testing | Tests enabled |
| `linux-clang-debug-asan` | Clang | Debug | AddressSanitizer |

### 3.5 macOS

| Preset | Generator | Arch | Config |
|--------|-----------|------|--------|
| `macos-xcode-arm64` | Xcode | ARM64 | Multi (Debug, Release) |
| `macos-xcode-x86_64` | Xcode | x86_64 | Multi (Debug, Release) |
| `macos-ninja-debug` | Ninja | – | Debug |
| `macos-ninja-testing` | Ninja | – | Testing |

---

## 4. Build Presets

### 4.1 Windows • Visual Studio

| Preset | Configure Preset | Config |
|--------|------------------|--------|
| `build-vs-x64-Debug` | windows-vs-x64-debug_dynamic | Debug |
| `build-vs-x64-Release` | windows-vs-x64-release_dynamic | Release |
| `build-vs-x64-Testing` | windows-vs-x64-testing_dynamic | Testing |
| `build-vs-ARM64-Release` | windows-vs-ARM64-release_dynamic | Release |

### 4.2 Windows • Ninja (Single)

| Preset | Configure Preset |
|--------|------------------|
| `build-ninja-debug-msvc` | windows-ninja-debug-msvc |
| `build-ninja-release-msvc` | windows-ninja-release-msvc |
| `build-ninja-testing-msvc` | windows-ninja-testing-msvc |
| `build-ninja-debug-clang` | windows-ninja-debug-clang |
| `build-ninja-release-clang` | windows-ninja-release-clang |
| `build-ninja-testing-clang` | windows-ninja-testing-clang |

### 4.3 Windows • Ninja (Multi)

| Preset | Configure Preset | Config |
|--------|------------------|--------|
| `build-ninja-multi-Debug` | windows-ninja-multi | Debug |
| `build-ninja-multi-Release` | windows-ninja-multi | Release |
| `build-ninja-multi-Testing` | windows-ninja-multi-tests | Testing |

### 4.4 Linux

| Preset | Configure Preset |
|--------|------------------|
| `build-linux-gcc-Debug` | linux-gcc-debug |
| `build-linux-gcc-Release` | linux-gcc-release |
| `build-linux-gcc-Testing` | linux-gcc-testing |
| `build-linux-clang-Debug` | linux-clang-debug |
| `build-linux-clang-Release` | linux-clang-release |
| `build-linux-clang-Testing` | linux-clang-testing |
| `build-linux-clang-Debug-asan` | linux-clang-debug-asan |

### 4.5 macOS

| Preset | Configure Preset | Config |
|--------|------------------|--------|
| `build-macos-xcode-Debug` | macos-xcode-arm64 | Debug |
| `build-macos-xcode-Release` | macos-xcode-arm64 | Release |
| `build-macos-ninja-Debug` | macos-ninja-debug | – |
| `build-macos-ninja-Testing` | macos-ninja-testing | – |

---

## 5. Test Presets

### 5.1 Windows

| Preset | Configure Preset | Config |
|--------|------------------|--------|
| `ctest-vs-x64-Debug` | windows-vs-x64-debug_dynamic | Debug |
| `ctest-vs-x64-Release` | windows-vs-x64-release_dynamic | Release |
| `ctest-vs-x64-Testing` | windows-vs-x64-testing_dynamic | Testing |
| `ctest-ninja-multi-Debug` | windows-ninja-multi | Debug |
| `ctest-ninja-multi-Testing` | windows-ninja-multi-tests | Testing |

### 5.2 Linux

| Preset | Configure Preset |
|--------|------------------|
| `ctest-linux-gcc-Testing` | linux-gcc-testing |
| `ctest-linux-gcc-Release` | linux-gcc-release |
| `ctest-linux-clang-Testing` | linux-clang-testing |
| `ctest-linux-clang-Debug-asan` | linux-clang-debug-asan |

### 5.3 macOS

| Preset | Configure Preset | Config |
|--------|------------------|--------|
| `ctest-macos-ninja-Testing` | macos-ninja-testing | – |
| `ctest-macos-xcode-Release` | macos-xcode-arm64 | Release |

---

## 6. Package Presets

| Preset | Generator | Platform | Config |
|--------|-----------|----------|--------|
| `package-windows-inno-Release` | INNOSETUP | Windows | Release |
| `package-macos-dmg-Release` | External | macOS | Release |
| `package-linux-tgz-Release` | TGZ | Linux | Release |

---

## 7. Workflow Presets

| Preset | Steps | Description |
|--------|-------|-------------|
| `wf-vs-x64-release-inno` | Configure → Build → Test → Package | Windows release with Inno Setup |
| `wf-linux-gcc-release-tgz` | Configure → Build → Test → Package | Linux release as TGZ |
| `wf-macos-xcode-release-dmg` | Configure → Build → Test → Package | macOS release as DMG |
| `wf-ninja-multi-testing` | Configure → Build → Test | Ninja Multi-Config Testing |
| `wf-linux-clang-debug-asan` | Configure → Build → Test | Linux with AddressSanitizer |

---

## 8. Hidden Building Blocks

These presets are only used for inheritance (`hidden: true`).

### 8.1 CRT Building Blocks (Windows)

| Preset | CRT |
|--------|-----|
| `MultiThreaded_Static` | /MT or /MTd |
| `MultiThreaded_Static_force_debug` | /MTd (always) |
| `MultiThreaded_Dynamic` | /MD or /MDd |
| `MultiThreaded_Dynamic_force_debug` | /MDd (always) |

### 8.2 Platform Bases

| Preset | Description |
|--------|-------------|
| `windows-vs-base` | VS generator, C++20, variables |
| `windows-ninja-base` | Ninja, compile_commands.json |
| `linux-base` | Ninja, C++20 |
| `macos-base` | C++20, PIC |

### 8.3 Architecture Bases

| Preset | Architecture |
|--------|--------------|
| `vs-Win32-base` | x86 |
| `vs-x64-base` | x64 |
| `vs-ARM-base` | ARM |
| `vs-ARM64-base` | ARM64 |

---

## 9. Cache Variables

All configure presets set these variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `BUILD_TESTS` | ON | Enable tests |
| `BUILD_ONLY` | "" | Selective targets |
| `ENABLE_CLANG_TIDY` | OFF | Code quality |
| `ENABLE_CLANG_FORMAT_CHECK` | OFF | Format check |
| `ACTIVE_CONFIGURE_PRESET` | ${presetName} | Current preset |

---

## 10. Quick Reference

### 10.1 Most Common Configure Presets

| Use Case | Preset |
|----------|--------|
| Windows Debug (IDE) | `windows-vs-x64-debug_dynamic` |
| Windows Release | `windows-vs-x64-release_dynamic` |
| Windows Tests | `windows-vs-x64-testing_dynamic` |
| Linux Debug | `linux-gcc-debug` |
| Linux Tests | `linux-gcc-testing` |
| macOS Debug | `macos-ninja-debug` |
| Sanitizer | `linux-clang-debug-asan` |
| Code quality | `windows-vs-x64-debug_quality` |

### 10.2 Most Common Workflows

| Use Case | Preset |
|----------|--------|
| Windows release + installer | `wf-vs-x64-release-inno` |
| Linux release + TGZ | `wf-linux-gcc-release-tgz` |
| Sanitizer tests | `wf-linux-clang-debug-asan` |

---

## 11. Usage

### 11.1 Configure

```bash
cmake --preset windows-vs-x64-debug_dynamic
```

### 11.2 Build

```bash
cmake --build --preset build-vs-x64-Debug
```

### 11.3 Test

```bash
ctest --preset ctest-vs-x64-Debug
```

### 11.4 Workflow

```bash
cmake --workflow --preset wf-vs-x64-release-inno
```

### 11.5 List Presets

```bash
cmake --list-presets
cmake --list-presets=build
cmake --list-presets=test
```

---

## 12. See Also

- CMakePresets_Manual.md — Concepts and best practices
- [CMakeUserPresets.md](CMakeUserPresets.md) — User presets
- [CMakeUserPresets_Example.md](../userguides/CMakeUserPresets.md) — Template

---

## 13. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.1.2** | **2026-11-09** | **Aligned with the code: presets `craft-selftest` (§3.2) and `ctest-vs-x64-Release` (§5.1, a step of `wf-vs-x64-release-inno`) added; counts and vendor metadata as in `CMakePresets.json`** |
| 1.1.1 | 2026-10-24 | `/bigobj` under MSVC (CMakeCraft v0.13.1) |
| 1.1.0 | 2026-10-24 | Configuration `Testing` described (optimized, asserts, debug info; CMakeCraft v0.13.0) |
| 0.5.0 | 2025-12-14 | Blueprint v0.5.0 format: numbered TOC, reference header, quick reference, usage |
| 0.1.0 | 2025-12-03 | Initial: all team presets documented, hidden building blocks, variables |
