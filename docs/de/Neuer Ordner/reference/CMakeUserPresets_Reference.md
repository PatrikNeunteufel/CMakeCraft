# CMakeUserPresets — Referenz

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Reference  
> **Status:** Stabil  
> **Zielgruppe:** Alle Entwickler  
> **Sprache:** Deutsch  
> **English:** [CMakeUserPresets_Reference.md](../../en/reference/CMakeUserPresets_Reference.md)

Diese Referenz dokumentiert die persönlichen User-Presets in `CMakeUserPresets.json`.

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Konventionen](#2-konventionen)
3. [Hidden Building Blocks](#3-hidden-building-blocks)
4. [Configure Presets](#4-configure-presets)
5. [Build Presets](#5-build-presets)
6. [Test Presets](#6-test-presets)
7. [Schnellreferenz](#7-schnellreferenz)
8. [Verwendung](#8-verwendung)
9. [Siehe auch](#9-siehe-auch)

---

## 1. Übersicht

`CMakeUserPresets.json` enthält persönliche Anpassungen und wird **nicht** ins Repository committed.

### Preset-Kategorien

| Kategorie | Beschreibung |
|-----------|--------------|
| Configure | vcpkg-Kombinationen |
| Build | Parallelisierte Builds |
| Test | CTest-Konfigurationen |
| Package | Code-Signing |
| Workflow | Release + Signing |

---

## 2. Konventionen

### Vendor-Metadaten

```json
{
    "version": 6,
    "vendor": {
        "user-presets": {
            "version": "0.5.0",
            "author": "Name",
            "lastModified": "2025-12-13"
        }
    }
}
```

### Vererbung

```json
{
    "name": "my-preset",
    "inherits": ["team-preset", "with-vcpkg"],
    "cacheVariables": { ... }
}
```

---

## 3. Hidden Building Blocks

### with-vcpkg

```json
{
    "name": "with-vcpkg",
    "hidden": true,
    "cacheVariables": {
        "VCPKG_ROOT": "H:/Dev/vcpkg",
        "CMAKE_TOOLCHAIN_FILE": "H:/Dev/vcpkg/scripts/buildsystems/vcpkg.cmake",
        "VCPKG_FEATURE_FLAGS": "manifests,versions"
    }
}
```

| Variable | Beschreibung |
|----------|--------------|
| `VCPKG_ROOT` | Lokaler vcpkg-Pfad |
| `CMAKE_TOOLCHAIN_FILE` | Toolchain-Integration |
| `VCPKG_FEATURE_FLAGS` | Moderne Features |

> **Hinweis:** Pfade an lokale Installation anpassen!

---

## 4. Configure Presets

### vcpkg-Kombinationen

| Preset | Erbt von |
|--------|----------|
| `windows-vs-x64-debug_dynamic+vcpkg` | windows-vs-x64-debug_dynamic, with-vcpkg |
| `windows-vs-x64-testing_dynamic+vcpkg` | windows-vs-x64-testing_dynamic, with-vcpkg |
| `windows-ninja-multi+vcpkg` | windows-ninja-multi, with-vcpkg |
| `windows-ninja-multi-tests+vcpkg` | windows-ninja-multi-tests, with-vcpkg |
| `linux-gcc-testing+vcpkg` | linux-gcc-testing, with-vcpkg |
| `linux-clang-debug-asan+vcpkg` | linux-clang-debug-asan, with-vcpkg |

---

## 5. Build Presets

### Parallelisierte Builds (jobs=8)

| Preset | Configure Preset | Jobs |
|--------|------------------|------|
| `ninjamulti_debug` | windows-ninja-multi | 8 |
| `ninjamulti_testing` | windows-ninja-multi-tests | 8 |
| `vs_x64_debug_md` | windows-vs-x64-debug_dynamic | 8 |
| `vs_x64_testing_md` | windows-vs-x64-testing_dynamic | 8 |

### vcpkg-Varianten

| Preset | Configure Preset | Jobs |
|--------|------------------|------|
| `ninjamulti_testing+vcpkg` | windows-ninja-multi-tests+vcpkg | 8 |
| `vs_x64_testing_md+vcpkg` | windows-vs-x64-testing_dynamic+vcpkg | 8 |

---

## 6. Test Presets

| Preset | Configure Preset | Output |
|--------|------------------|--------|
| `ninjamulti_test_testing` | windows-ninja-multi-tests | outputOnFailure |
| `vs_x64_ctest_debug` | windows-vs-x64-debug_dynamic | outputOnFailure |
| `vs_x64_ctest_testing` | windows-vs-x64-testing_dynamic | outputOnFailure |

---

## 7. Schnellreferenz

### Typische Anpassungen

| Anpassung | Methode |
|-----------|---------|
| vcpkg-Pfad | `with-vcpkg` Building Block |
| Job-Anzahl | `"jobs": 16` |
| Selektive Targets | `"BUILD_ONLY": "MyApp"` |
| Ohne Tests | `"BUILD_TESTS": "OFF"` |

### Eigene Kombinationen

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

## 8. Verwendung

### Tägliche Entwicklung

```bash
# VS Debug mit vcpkg
cmake --preset windows-vs-x64-debug_dynamic+vcpkg

# Schneller Build (8 Jobs)
cmake --build --preset vs_x64_debug_md
```

### Tests

```bash
# Ninja Testing
cmake --preset windows-ninja-multi-tests+vcpkg
cmake --build --preset ninjamulti_testing+vcpkg
ctest --preset ninjamulti_test_testing
```

### Release mit Signing

```bash
cmake --workflow --preset wf-vs-x64-release-inno+sign
```

---

## 9. Siehe auch

- [CMakePresets_Manual.md](CMakePresets_Manual.md) — Konzepte
- [CMakePresets_Reference.md](CMakePresets_Reference.md) — Team-Presets
- [CMakeUserPresets_Example.md](../guides/CMakeUserPresets_Example.md) — Template

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Reference Blueprint v0.5.0 Format** |
| 0.1.0 | 2025-12-03 | Initial |
