# CMakePresets Manual — Referenz

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Reference  
> **Status:** Stabil  
> **Zielgruppe:** Alle Entwickler  
> **Sprache:** Deutsch  
> **English:** [CMakePresets_Manual.md](../../en/reference/CMakePresets_Manual.md)

Dieses Manual beschreibt alle verfügbaren CMake-Presets und deren Verwendung.

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Konventionen](#2-konventionen)
3. [Configure Presets](#3-configure-presets)
4. [Build Presets](#4-build-presets)
5. [Test Presets](#5-test-presets)
6. [Cache-Variablen](#6-cache-variablen)
7. [User Presets](#7-user-presets)
8. [Schnellreferenz](#8-schnellreferenz)
9. [Siehe auch](#9-siehe-auch)

---

## 1. Übersicht

### Dateien

| Datei | Zweck | Git |
|-------|-------|-----|
| `CMakePresets.json` | Team-weite Presets | ✅ Committen |
| `CMakeUserPresets.json` | Persönliche Presets | ❌ Gitignore |

### Preset-Hierarchie

```
Configure Preset → Build Preset → Test Preset → Package Preset
```

---

## 2. Konventionen

### Naming

```
[os]-[generator]-[arch]-[buildtype]_[variant]
```

| Teil | Werte |
|------|-------|
| os | windows, linux, macos |
| generator | vs, ninja, make |
| arch | x64, x86, arm64 |
| buildtype | debug, release |
| variant | dynamic, static, quality |

### Versionierung (vendor-Feld)

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

---

## 3. Configure Presets

### Windows • Visual Studio

```bash
cmake --preset windows-vs-x64-debug_dynamic
cmake --preset windows-vs-x64-release_dynamic
cmake --preset windows-vs-x64-debug_static
cmake --preset windows-vs-x64-debug_quality
```

### Windows • Ninja + Clang

```bash
cmake --preset windows-ninja-clang-x64-debug
cmake --preset windows-ninja-clang-x64-release
```

### Linux • GCC

```bash
cmake --preset linux-gcc-x64-debug
cmake --preset linux-gcc-x64-release
```

### Linux • Clang

```bash
cmake --preset linux-clang-x64-debug
cmake --preset linux-clang-x64-release
```

### macOS • Apple Clang

```bash
cmake --preset macos-x64-debug
cmake --preset macos-x64-release
cmake --preset macos-arm64-debug
cmake --preset macos-arm64-release
```

---

## 4. Build Presets

```bash
# Standard Build
cmake --build --preset windows-vs-x64-debug_dynamic

# Einzelnes Target
cmake --build --preset windows-vs-x64-debug_dynamic --target MyApp

# Parallel
cmake --build --preset windows-vs-x64-debug_dynamic -j 8
```

---

## 5. Test Presets

```bash
# Alle Tests
ctest --preset windows-vs-x64-debug_dynamic

# Nach Label filtern
ctest --preset windows-vs-x64-debug_dynamic -L unit

# Parallel
ctest --preset windows-vs-x64-debug_dynamic -j 4

# Verbose
ctest --preset windows-vs-x64-debug_dynamic -V
```

---

## 6. Cache-Variablen

### Build Control

| Variable | Default | Beschreibung |
|----------|---------|--------------|
| `BUILD_TESTS` | ON | Tests aktivieren |
| `BUILD_ONLY` | "" | Nur bestimmte Targets |
| `RUN_BUILD_SYSTEM_TESTS` | OFF | Interne Tests |

### Code-Qualität

| Variable | Default | Beschreibung |
|----------|---------|--------------|
| `ENABLE_CLANG_TIDY` | OFF | Clang-Tidy |
| `CLANG_TIDY_STRICT` | OFF | Warnings als Errors |
| `ENABLE_CLANG_FORMAT_CHECK` | OFF | Format-Checks |

### Compiler

| Variable | Default | Beschreibung |
|----------|---------|--------------|
| `ENABLE_STRICT_CONFORMANCE` | ON | MSVC strict mode |
| `NO_EXCEPTIONS` | OFF | Exceptions deaktivieren |
| `NO_RTTI` | OFF | RTTI deaktivieren |

---

## 7. User Presets

`CMakeUserPresets.json`:

```json
{
    "version": 6,
    "cmakeMinimumRequired": { "major": 3, "minor": 25, "patch": 0 },
    "configurePresets": [
        {
            "name": "my-dev",
            "displayName": "My Development",
            "inherits": "windows-vs-x64-debug_dynamic",
            "cacheVariables": {
                "BUILD_ONLY": "MyApp",
                "BUILD_TESTS": "OFF"
            }
        }
    ]
}
```

---

## 8. Schnellreferenz

### Preset-Auswahl

| Situation | Preset |
|-----------|--------|
| Tägliche Entwicklung | `*-debug_dynamic` |
| Release-Build | `*-release_dynamic` |
| Vor Commit/PR | `*-debug_quality` |
| CI/CD | `*-release_static` |

### Hilfreiche Befehle

```bash
# Presets auflisten
cmake --list-presets

# Workflow (Configure + Build + Test)
cmake --workflow --preset windows-vs-x64-debug_dynamic

# Cache löschen
rm -rf build/
```

---

## 9. Siehe auch

- [CMakePresets_Reference.md](CMakePresets_Reference.md) — Alle Presets im Detail
- [CMakeUserPresets_Reference.md](CMakeUserPresets_Reference.md) — User-Presets Schema
- [CMakeUserPresets_Example.md](../guides/CMakeUserPresets_Example.md) — Template
- [CMake Presets Docs](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html)

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Reference Blueprint v0.5.0 Format** |
| 0.1.1 | 2025-12-03 | vendor-Feld dokumentiert |
| 0.1.0 | 2025-12-03 | Initial |
