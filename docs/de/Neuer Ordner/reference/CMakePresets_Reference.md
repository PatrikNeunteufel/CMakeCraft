# CMakePresets — Referenz

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Reference  
> **Status:** Stabil  
> **Zielgruppe:** Alle Entwickler  
> **Sprache:** Deutsch  
> **English:** [CMakePresets_Reference.md](../../en/reference/CMakePresets_Reference.md)

Diese Referenz dokumentiert alle verfügbaren Team-Presets in `CMakePresets.json`.

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Konventionen](#2-konventionen)
3. [Configure Presets](#3-configure-presets)
4. [Build Presets](#4-build-presets)
5. [Test Presets](#5-test-presets)
6. [Workflow Presets](#6-workflow-presets)
7. [Hidden Building Blocks](#7-hidden-building-blocks)
8. [Schnellreferenz](#8-schnellreferenz)
9. [Siehe auch](#9-siehe-auch)

---

## 1. Übersicht

### Preset-Kategorien

| Kategorie | Anzahl | Beschreibung |
|-----------|--------|--------------|
| Configure Presets | 35+ | Build-Umgebung |
| Build Presets | 20+ | Kompilieren |
| Test Presets | 12 | CTest |
| Package Presets | 3 | Installer |
| Workflow Presets | 5 | Pipelines |

---

## 2. Konventionen

### Vendor-Metadaten

```json
{
    "version": 6,
    "vendor": {
        "cmake-architecture-v2": {
            "version": "0.5.0",
            "date": "2025-12-13"
        }
    }
}
```

### V2 Cache-Variablen

| Variable | Default | Beschreibung |
|----------|---------|--------------|
| `BUILD_TESTS` | ON | Tests aktivieren |
| `BUILD_ONLY` | "" | Selektive Targets |
| `ENABLE_CLANG_TIDY` | OFF | Code-Qualität |
| `ACTIVE_CONFIGURE_PRESET` | ${presetName} | Aktuelles Preset |

---

## 3. Configure Presets

### Windows • Visual Studio

| Preset | Arch | Config | CRT | Besonderheit |
|--------|------|--------|-----|--------------|
| `windows-vs-x64-debug_dynamic` | x64 | Debug | /MDd | Standard |
| `windows-vs-x64-release_dynamic` | x64 | Release | /MD | Release |
| `windows-vs-x64-testing_dynamic` | x64 | Testing | /MD | Tests |
| `windows-vs-ARM64-release_dynamic` | ARM64 | Release | /MD | ARM64 |
| `windows-vs-x64-debug_clangcl_asan` | x64 | Debug | — | ASan |
| `windows-vs-x64-debug_quality` | x64 | Debug | /MDd | Clang-Tidy |
| `windows-vs-x64-debug_apps-only` | x64 | Debug | /MDd | Ohne Tests |

### Windows • Ninja (Single-Config)

| Preset | Compiler | Config |
|--------|----------|--------|
| `windows-ninja-debug-msvc` | MSVC | Debug |
| `windows-ninja-release-msvc` | MSVC | Release |
| `windows-ninja-testing-msvc` | MSVC | Testing |
| `windows-ninja-debug-clang` | Clang | Debug |
| `windows-ninja-release-clang` | Clang | Release |
| `windows-ninja-testing-clang` | Clang | Testing |

### Windows • Ninja (Multi-Config)

| Preset | Configs |
|--------|---------|
| `windows-ninja-multi` | Debug, Release, Testing |
| `windows-ninja-multi-tests` | Debug, Release, Testing + ENABLE_TESTING_CONFIG |

### Linux

| Preset | Compiler | Config | Besonderheit |
|--------|----------|--------|--------------|
| `linux-gcc-debug` | GCC | Debug | — |
| `linux-gcc-release` | GCC | Release | — |
| `linux-gcc-testing` | GCC | Testing | Tests |
| `linux-clang-debug` | Clang | Debug | — |
| `linux-clang-release` | Clang | Release | — |
| `linux-clang-testing` | Clang | Testing | Tests |
| `linux-clang-debug-asan` | Clang | Debug | ASan |

### macOS

| Preset | Generator | Arch |
|--------|-----------|------|
| `macos-xcode-arm64` | Xcode | ARM64 |
| `macos-xcode-x86_64` | Xcode | x86_64 |
| `macos-ninja-debug` | Ninja | — |
| `macos-ninja-testing` | Ninja | — |

---

## 4. Build Presets

### Windows

| Preset | Configure Preset | Config |
|--------|------------------|--------|
| `build-vs-x64-Debug` | windows-vs-x64-debug_dynamic | Debug |
| `build-vs-x64-Release` | windows-vs-x64-release_dynamic | Release |
| `build-vs-x64-Testing` | windows-vs-x64-testing_dynamic | Testing |
| `build-ninja-debug-msvc` | windows-ninja-debug-msvc | — |
| `build-ninja-release-msvc` | windows-ninja-release-msvc | — |
| `build-ninja-multi-Debug` | windows-ninja-multi | Debug |
| `build-ninja-multi-Release` | windows-ninja-multi | Release |

### Linux

| Preset | Configure Preset |
|--------|------------------|
| `build-linux-gcc-Debug` | linux-gcc-debug |
| `build-linux-gcc-Release` | linux-gcc-release |
| `build-linux-gcc-Testing` | linux-gcc-testing |
| `build-linux-clang-Debug` | linux-clang-debug |
| `build-linux-clang-Debug-asan` | linux-clang-debug-asan |

### macOS

| Preset | Configure Preset | Config |
|--------|------------------|--------|
| `build-macos-xcode-Debug` | macos-xcode-arm64 | Debug |
| `build-macos-xcode-Release` | macos-xcode-arm64 | Release |
| `build-macos-ninja-Debug` | macos-ninja-debug | — |

---

## 5. Test Presets

| Preset | Plattform | Configure Preset |
|--------|-----------|------------------|
| `ctest-vs-x64-Debug` | Windows | windows-vs-x64-debug_dynamic |
| `ctest-vs-x64-Testing` | Windows | windows-vs-x64-testing_dynamic |
| `ctest-ninja-multi-Testing` | Windows | windows-ninja-multi-tests |
| `ctest-linux-gcc-Testing` | Linux | linux-gcc-testing |
| `ctest-linux-clang-Testing` | Linux | linux-clang-testing |
| `ctest-linux-clang-Debug-asan` | Linux | linux-clang-debug-asan |
| `ctest-macos-ninja-Testing` | macOS | macos-ninja-testing |

---

## 6. Workflow Presets

| Preset | Schritte | Beschreibung |
|--------|----------|--------------|
| `wf-vs-x64-release-inno` | Configure → Build → Test → Package | Windows + Inno Setup |
| `wf-linux-gcc-release-tgz` | Configure → Build → Test → Package | Linux TGZ |
| `wf-macos-xcode-release-dmg` | Configure → Build → Test → Package | macOS DMG |
| `wf-ninja-multi-testing` | Configure → Build → Test | Multi-Config Testing |
| `wf-linux-clang-debug-asan` | Configure → Build → Test | ASan Testing |

---

## 7. Hidden Building Blocks

Nur zur Vererbung (`hidden: true`).

### CRT-Bausteine (Windows)

| Preset | CRT |
|--------|-----|
| `MultiThreaded_Static` | /MT, /MTd |
| `MultiThreaded_Dynamic` | /MD, /MDd |
| `MultiThreaded_Static_force_debug` | /MTd (immer) |
| `MultiThreaded_Dynamic_force_debug` | /MDd (immer) |

### Plattform-Basen

| Preset | Beschreibung |
|--------|--------------|
| `windows-vs-base` | VS Generator, C++20 |
| `windows-ninja-base` | Ninja, compile_commands |
| `linux-base` | Ninja, C++20 |
| `macos-base` | C++20, PIC |

### Architektur-Basen

| Preset | Architektur |
|--------|-------------|
| `vs-Win32-base` | x86 |
| `vs-x64-base` | x64 |
| `vs-ARM-base` | ARM |
| `vs-ARM64-base` | ARM64 |

---

## 8. Schnellreferenz

### Empfohlene Presets

| Situation | Configure | Build | Test |
|-----------|-----------|-------|------|
| Windows Dev | `windows-vs-x64-debug_dynamic` | `build-vs-x64-Debug` | `ctest-vs-x64-Debug` |
| Windows CI | `windows-vs-x64-testing_dynamic` | `build-vs-x64-Testing` | `ctest-vs-x64-Testing` |
| Linux Dev | `linux-gcc-debug` | `build-linux-gcc-Debug` | — |
| Linux CI | `linux-gcc-testing` | `build-linux-gcc-Testing` | `ctest-linux-gcc-Testing` |
| macOS Dev | `macos-ninja-debug` | `build-macos-ninja-Debug` | — |

---

## 9. Siehe auch

- [CMakePresets_Manual.md](CMakePresets_Manual.md) — Konzepte und Best Practices
- [CMakeUserPresets_Reference.md](CMakeUserPresets_Reference.md) — User-Presets
- [CMakeUserPresets_Example.md](../guides/CMakeUserPresets_Example.md) — Template

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Reference Blueprint v0.5.0 Format** |
| 0.1.0 | 2025-12-03 | Initial |
