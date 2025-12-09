# CMakePresets Reference – CMake Architecture V2

> **Version:** 0.1.0  
> **Datum:** 2025-12-03  
> **Typ:** Referenz-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** CMakePresets_Manual v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/References/CMakePresets_Reference_v0_1_0.md)

Diese Referenz dokumentiert alle verfügbaren Team-Presets in `CMakePresets.json`.

---

## 1. Übersicht

### Preset-Kategorien

| Kategorie | Anzahl | Beschreibung |
|-----------|--------|--------------|
| Configure Presets | 35+ | Build-Umgebung konfigurieren |
| Build Presets | 20+ | Kompilieren |
| Test Presets | 12 | CTest ausführen |
| Package Presets | 3 | Installer erstellen |
| Workflow Presets | 5 | Komplette Pipelines |

### Vendor-Metadaten

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

## 2. Configure Presets

### Windows • Visual Studio

| Preset | Arch | Config | CRT | Besonderheit |
|--------|------|--------|-----|--------------|
| `windows-vs-x64-debug_dynamic` | x64 | Debug | /MDd | Standard-Entwicklung |
| `windows-vs-x64-release_dynamic` | x64 | Release | /MD | Release-Builds |
| `windows-vs-x64-testing_dynamic` | x64 | Testing | /MD | Tests aktiviert |
| `windows-vs-ARM64-release_dynamic` | ARM64 | Release | /MD | ARM64-Builds |
| `windows-vs-x64-debug_clangcl_asan` | x64 | Debug | - | Clang-CL + ASan |
| `windows-vs-x64-debug_quality` | x64 | Debug | /MDd | Clang-Tidy aktiviert |
| `windows-vs-x64-debug_apps-only` | x64 | Debug | /MDd | BUILD_TESTS=OFF |

### Windows • Ninja (Single-Config)

| Preset | Compiler | Config | Besonderheit |
|--------|----------|--------|--------------|
| `windows-ninja-debug-msvc` | MSVC | Debug | - |
| `windows-ninja-release-msvc` | MSVC | Release | - |
| `windows-ninja-testing-msvc` | MSVC | Testing | Tests aktiviert |
| `windows-ninja-debug-clang` | Clang | Debug | - |
| `windows-ninja-release-clang` | Clang | Release | - |
| `windows-ninja-testing-clang` | Clang | Testing | Tests aktiviert |

### Windows • Ninja (Multi-Config)

| Preset | Configs | Besonderheit |
|--------|---------|--------------|
| `windows-ninja-multi` | Debug, Release, Testing | Standard |
| `windows-ninja-multi-tests` | Debug, Release, Testing | ENABLE_TESTING_CONFIG=ON |

### Linux • Ninja

| Preset | Compiler | Config | Besonderheit |
|--------|----------|--------|--------------|
| `linux-gcc-debug` | GCC | Debug | - |
| `linux-gcc-release` | GCC | Release | - |
| `linux-gcc-testing` | GCC | Testing | Tests aktiviert |
| `linux-clang-debug` | Clang | Debug | - |
| `linux-clang-release` | Clang | Release | - |
| `linux-clang-testing` | Clang | Testing | Tests aktiviert |
| `linux-clang-debug-asan` | Clang | Debug | AddressSanitizer |

### macOS

| Preset | Generator | Arch | Config |
|--------|-----------|------|--------|
| `macos-xcode-arm64` | Xcode | ARM64 | Multi (Debug, Release) |
| `macos-xcode-x86_64` | Xcode | x86_64 | Multi (Debug, Release) |
| `macos-ninja-debug` | Ninja | - | Debug |
| `macos-ninja-testing` | Ninja | - | Testing |

---

## 3. Build Presets

### Windows • Visual Studio

| Preset | Configure Preset | Config |
|--------|------------------|--------|
| `build-vs-x64-Debug` | windows-vs-x64-debug_dynamic | Debug |
| `build-vs-x64-Release` | windows-vs-x64-release_dynamic | Release |
| `build-vs-x64-Testing` | windows-vs-x64-testing_dynamic | Testing |
| `build-vs-ARM64-Release` | windows-vs-ARM64-release_dynamic | Release |

### Windows • Ninja (Single)

| Preset | Configure Preset |
|--------|------------------|
| `build-ninja-debug-msvc` | windows-ninja-debug-msvc |
| `build-ninja-release-msvc` | windows-ninja-release-msvc |
| `build-ninja-testing-msvc` | windows-ninja-testing-msvc |
| `build-ninja-debug-clang` | windows-ninja-debug-clang |
| `build-ninja-release-clang` | windows-ninja-release-clang |
| `build-ninja-testing-clang` | windows-ninja-testing-clang |

### Windows • Ninja (Multi)

| Preset | Configure Preset | Config |
|--------|------------------|--------|
| `build-ninja-multi-Debug` | windows-ninja-multi | Debug |
| `build-ninja-multi-Release` | windows-ninja-multi | Release |
| `build-ninja-multi-Testing` | windows-ninja-multi-tests | Testing |

### Linux

| Preset | Configure Preset |
|--------|------------------|
| `build-linux-gcc-Debug` | linux-gcc-debug |
| `build-linux-gcc-Release` | linux-gcc-release |
| `build-linux-gcc-Testing` | linux-gcc-testing |
| `build-linux-clang-Debug` | linux-clang-debug |
| `build-linux-clang-Release` | linux-clang-release |
| `build-linux-clang-Testing` | linux-clang-testing |
| `build-linux-clang-Debug-asan` | linux-clang-debug-asan |

### macOS

| Preset | Configure Preset | Config |
|--------|------------------|--------|
| `build-macos-xcode-Debug` | macos-xcode-arm64 | Debug |
| `build-macos-xcode-Release` | macos-xcode-arm64 | Release |
| `build-macos-ninja-Debug` | macos-ninja-debug | - |
| `build-macos-ninja-Testing` | macos-ninja-testing | - |

---

## 4. Test Presets

### Windows

| Preset | Configure Preset | Config |
|--------|------------------|--------|
| `ctest-vs-x64-Debug` | windows-vs-x64-debug_dynamic | Debug |
| `ctest-vs-x64-Testing` | windows-vs-x64-testing_dynamic | Testing |
| `ctest-ninja-multi-Debug` | windows-ninja-multi | Debug |
| `ctest-ninja-multi-Testing` | windows-ninja-multi-tests | Testing |

### Linux

| Preset | Configure Preset |
|--------|------------------|
| `ctest-linux-gcc-Testing` | linux-gcc-testing |
| `ctest-linux-gcc-Release` | linux-gcc-release |
| `ctest-linux-clang-Testing` | linux-clang-testing |
| `ctest-linux-clang-Debug-asan` | linux-clang-debug-asan |

### macOS

| Preset | Configure Preset | Config |
|--------|------------------|--------|
| `ctest-macos-ninja-Testing` | macos-ninja-testing | - |
| `ctest-macos-xcode-Release` | macos-xcode-arm64 | Release |

---

## 5. Package Presets

| Preset | Generator | Plattform | Config |
|--------|-----------|-----------|--------|
| `package-windows-inno-Release` | INNOSETUP | Windows | Release |
| `package-macos-dmg-Release` | External | macOS | Release |
| `package-linux-tgz-Release` | TGZ | Linux | Release |

---

## 6. Workflow Presets

| Preset | Schritte | Beschreibung |
|--------|----------|--------------|
| `wf-vs-x64-release-inno` | Configure → Build → Test → Package | Windows Release mit Inno Setup |
| `wf-linux-gcc-release-tgz` | Configure → Build → Test → Package | Linux Release als TGZ |
| `wf-macos-xcode-release-dmg` | Configure → Build → Test → Package | macOS Release als DMG |
| `wf-ninja-multi-testing` | Configure → Build → Test | Ninja Multi-Config Testing |
| `wf-linux-clang-debug-asan` | Configure → Build → Test | Linux mit AddressSanitizer |

---

## 7. Hidden Building Blocks

Diese Presets werden nur zur Vererbung verwendet (`hidden: true`):

### CRT-Bausteine (Windows)

| Preset | CRT |
|--------|-----|
| `MultiThreaded_Static` | /MT bzw. /MTd |
| `MultiThreaded_Static_force_debug` | /MTd (immer) |
| `MultiThreaded_Dynamic` | /MD bzw. /MDd |
| `MultiThreaded_Dynamic_force_debug` | /MDd (immer) |

### Plattform-Basen

| Preset | Beschreibung |
|--------|--------------|
| `windows-vs-base` | VS Generator, C++20, V2 Variablen |
| `windows-ninja-base` | Ninja, compile_commands.json |
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

## 8. Cache-Variablen

Alle Configure Presets setzen diese V2-Variablen:

| Variable | Default | Beschreibung |
|----------|---------|--------------|
| `BUILD_TESTS` | ON | Tests aktivieren |
| `BUILD_ONLY` | "" | Selektive Targets |
| `ENABLE_CLANG_TIDY` | OFF | Code-Qualität |
| `ENABLE_CLANG_FORMAT_CHECK` | OFF | Format-Prüfung |
| `ACTIVE_CONFIGURE_PRESET` | ${presetName} | Aktuelles Preset |

---

## 9. Siehe auch

- [CMakePresets_Manual](CMakePresets_Manual_v0_1_0.md) – Konzepte und Best Practices
- [CMakeUserPresets_Reference](CMakeUserPresets_Reference_v0_1_0.md) – User-Presets
- [CMakeUserPresets_Example](../UserGuides/CMakeUserPresets_Example_v0_1_0.md) – Template

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-03** | **Initial: Alle Team-Presets dokumentiert, Hidden Building Blocks, V2-Variablen** |
