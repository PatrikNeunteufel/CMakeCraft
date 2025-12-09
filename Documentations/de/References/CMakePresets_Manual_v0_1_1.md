# CMake Presets Manual – CMake Architecture V2

> **Version:** 0.1.1  
> **Datum:** 2025-12-03  
> **Typ:** Referenz-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/References/CMakePresets_Manual_v0_1_1.md)

Dieses Manual beschreibt alle verfügbaren CMake-Presets und deren Verwendung.

---

## 1. Übersicht

### Dateien

| Datei | Zweck | Git |
|-------|-------|-----|
| `CMakePresets.json` | Team-weite Presets | ✅ Committen |
| `CMakeUserPresets.json` | Persönliche Presets | ❌ Gitignore |

### Eigene Versionierung mit vendor-Feld

CMake's Schema erlaubt ein `vendor`-Feld für eigene Metadaten (wird von CMake ignoriert):

```json
{
    "version": 6,
    "vendor": {
        "cmake-architecture-v2": {
            "version": "0.1.0",
            "date": "2025-12-03",
            "description": "Team-weite Presets für CMake Architecture V2"
        }
    },
    "configurePresets": [ ... ]
}
```

Für User-Presets:

```json
{
    "version": 6,
    "vendor": {
        "user-presets": {
            "version": "0.1.0",
            "author": "Name",
            "lastModified": "YYYY-MM-DD"
        }
    }
}
```

### Preset-Hierarchie

```
Configure Preset
    ↓
Build Preset
    ↓
Test Preset
    ↓
Package Preset
```

---

## 2. Cache-Variablen

### Build Control

| Variable | Default | Beschreibung |
|----------|---------|--------------|
| `BUILD_TESTS` | ON | Tests aktivieren |
| `BUILD_ONLY` | "" | Nur bestimmte Targets (`;`-separiert) |
| `RUN_BUILD_SYSTEM_TESTS` | OFF | Interne Tests |

### Code-Qualität

| Variable | Default | Beschreibung |
|----------|---------|--------------|
| `ENABLE_CLANG_TIDY` | OFF | Clang-Tidy aktivieren |
| `CLANG_TIDY_STRICT` | OFF | Warnings als Errors |
| `ENABLE_CLANG_FORMAT_CHECK` | OFF | Format-Checks |

### Compiler-Optionen

| Variable | Default | Beschreibung |
|----------|---------|--------------|
| `ENABLE_STRICT_CONFORMANCE` | ON | MSVC strict mode |
| `NO_EXCEPTIONS` | OFF | Exceptions deaktivieren |
| `NO_RTTI` | OFF | RTTI deaktivieren |

---

## 3. Configure Presets

### Windows • Visual Studio

```bash
# Debug mit dynamischer CRT
cmake --preset windows-vs-x64-debug_dynamic

# Release mit dynamischer CRT
cmake --preset windows-vs-x64-release_dynamic

# Debug mit statischer CRT
cmake --preset windows-vs-x64-debug_static

# Quality Checks (Clang-Tidy)
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
# Standard Build (alle Targets)
cmake --build --preset windows-vs-x64-debug_dynamic

# Nur bestimmte Targets
cmake --build --preset windows-vs-x64-debug_dynamic --target MyApp

# Paralleler Build
cmake --build --preset windows-vs-x64-debug_dynamic -j 8
```

---

## 5. Test Presets

```bash
# Alle Tests
ctest --preset windows-vs-x64-debug_dynamic

# Nur Unit-Tests
ctest --preset windows-vs-x64-debug_dynamic -L unit

# Verbose
ctest --preset windows-vs-x64-debug_dynamic -V

# Parallele Ausführung
ctest --preset windows-vs-x64-debug_dynamic -j 4
```

---

## 6. Workflow Presets

Kombiniert Configure, Build und Test:

```bash
cmake --workflow --preset windows-vs-x64-debug_dynamic
```

---

## 7. User Presets

`CMakeUserPresets.json` für persönliche Anpassungen:

```json
{
    "version": 6,
    "cmakeMinimumRequired": { "major": 3, "minor": 25, "patch": 0 },
    "configurePresets": [
        {
            "name": "my-dev",
            "displayName": "My Development Preset",
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

## 8. Best Practices

### Preset-Auswahl

| Situation | Empfohlenes Preset |
|-----------|-------------------|
| Tägliche Entwicklung | `*-debug_dynamic` |
| Release-Build | `*-release_dynamic` |
| Vor Commit/PR | `*-debug_quality` |
| CI/CD | `*-release_static` |
| Performance-Tests | `*-release_dynamic` |

### Build-Variablen

```bash
# Nur ein Target bauen
cmake -B build --preset windows-vs-x64-debug_dynamic -DBUILD_ONLY="MyApp"

# Ohne Tests
cmake -B build --preset windows-vs-x64-debug_dynamic -DBUILD_TESTS=OFF

# Mit Clang-Tidy
cmake -B build --preset windows-vs-x64-debug_dynamic -DENABLE_CLANG_TIDY=ON
```

---

## 9. Troubleshooting

### Preset nicht gefunden

```bash
cmake --list-presets  # Zeigt verfügbare Presets
```

### Generator-Fehler (Windows)

Visual Studio muss installiert sein für VS-Presets. Alternative: Ninja-Presets.

### Clang-Tidy langsam

Clang-Tidy erhöht Build-Zeit ~3-4x. Nur für Quality-Checks verwenden:

```bash
cmake --preset windows-vs-x64-debug_quality  # Nur vor Commit
```

### Cache-Probleme

```bash
rm -rf build/
cmake --preset <preset>
```

---

## 10. Preset-Naming-Konvention

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

---

## 11. Siehe auch

- [CMakePresets_Reference](CMakePresets_Reference_v0_1_0.md) – Alle Team-Presets im Detail
- [CMakeUserPresets_Reference](CMakeUserPresets_Reference_v0_1_0.md) – User-Presets
- [CMakeUserPresets_Example](../UserGuides/CMakeUserPresets_Example_v0_1_0.md) – Template
- [master_concept](../Concepts/master_concept_v0_1_0.md) – Architektur
- [guidelines](../Concepts/guidelines_v0_1_0.md) – Konventionen
- [CMake Presets Docs](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html) – Offizielle Doku

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.1** | **2025-12-03** | **vendor-Feld für eigene Versionierung dokumentiert, Querverweise auf Reference-Dokumente** |
| 0.1.0 | 2025-12-03 | Initial (Clean Start): Inhalte aus v1.1 übernommen, Blueprint-Format |
