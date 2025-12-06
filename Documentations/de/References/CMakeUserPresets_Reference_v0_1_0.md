# CMakeUserPresets Reference – CMake Architecture V2

> **Version:** 0.1.0  
> **Datum:** 2025-12-03  
> **Typ:** Referenz-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Autor:** Patrik Neunteufel  
> **Basiert auf:** CMakePresets_Manual v0.1, CMakePresets_Reference v0.1
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/References/CMakeUserPresets_Reference_v0_1_0.md)

Diese Referenz dokumentiert die persönlichen User-Presets in `CMakeUserPresets.json`.

---

## 1. Übersicht

### Vendor-Metadaten

```json
{
    "version": 6,
    "vendor": {
        "user-presets": {
            "version": "0.1.0",
            "author": "Patrik Neunteufel",
            "lastModified": "2025-12-03"
        }
    }
}
```

### Preset-Kategorien

| Kategorie | Anzahl | Beschreibung |
|-----------|--------|--------------|
| Configure Presets | 7 | vcpkg-Kombinationen |
| Build Presets | 6 | Parallelisierte Builds |
| Test Presets | 3 | CTest-Konfigurationen |
| Package Presets | 1 | Code-Signing |
| Workflow Presets | 1 | Release + Signing |

---

## 2. Hidden Building Block

### with-vcpkg

Basis-Preset für lokale vcpkg-Integration:

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

| Variable | Wert | Beschreibung |
|----------|------|--------------|
| `VCPKG_ROOT` | H:/Dev/vcpkg | Lokaler vcpkg-Pfad |
| `CMAKE_TOOLCHAIN_FILE` | .../vcpkg.cmake | Toolchain-Integration |
| `VCPKG_FEATURE_FLAGS` | manifests,versions | Moderne Features |

> **Hinweis:** Pfade anpassen an lokale Installation!

---

## 3. Configure Presets

### vcpkg-Kombinationen

| Preset | Erbt von | Beschreibung |
|--------|----------|--------------|
| `windows-vs-x64-debug_dynamic+vcpkg` | windows-vs-x64-debug_dynamic, with-vcpkg | VS Debug + vcpkg |
| `windows-vs-x64-testing_dynamic+vcpkg` | windows-vs-x64-testing_dynamic, with-vcpkg | VS Testing + vcpkg |
| `windows-ninja-multi+vcpkg` | windows-ninja-multi, with-vcpkg | Ninja Multi + vcpkg |
| `windows-ninja-multi-tests+vcpkg` | windows-ninja-multi-tests, with-vcpkg | Ninja Tests + vcpkg |
| `linux-clang-debug-asan+vcpkg` | linux-clang-debug-asan, with-vcpkg | Linux ASan + vcpkg |
| `linux-gcc-testing+vcpkg` | linux-gcc-testing, with-vcpkg | Linux GCC + vcpkg |

---

## 4. Build Presets

### Parallelisierte Builds (jobs=8)

| Preset | Configure Preset | Config | Jobs |
|--------|------------------|--------|------|
| `ninjamulti_debug` | windows-ninja-multi | Debug | 8 |
| `ninjamulti_testing` | windows-ninja-multi-tests | Testing | 8 |
| `vs_x64_debug_md` | windows-vs-x64-debug_dynamic | Debug | 8 |
| `vs_x64_testing_md` | windows-vs-x64-testing_dynamic | Testing | 8 |

### vcpkg-Varianten

| Preset | Configure Preset | Config | Jobs |
|--------|------------------|--------|------|
| `ninjamulti_testing+vcpkg` | windows-ninja-multi-tests+vcpkg | Testing | 8 |
| `vs_x64_testing_md+vcpkg` | windows-vs-x64-testing_dynamic+vcpkg | Testing | 8 |

---

## 5. Test Presets

| Preset | Configure Preset | Config | Output |
|--------|------------------|--------|--------|
| `ninjamulti_test_testing` | windows-ninja-multi-tests | Testing | outputOnFailure |
| `vs_x64_ctest_debug` | windows-vs-x64-debug_dynamic | Debug | outputOnFailure |
| `vs_x64_ctest_testing` | windows-vs-x64-testing_dynamic | Testing | outputOnFailure |

---

## 6. Package Presets

### Code-Signing Variante

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

| Einstellung | Wert | Beschreibung |
|-------------|------|--------------|
| Basis | package-windows-inno-Release | Team-Preset |
| ISCC Args | /Qp;/Smysigntool=$p | Quiet + Signtool |
| Output | dist/ | Lokales Ausgabeverzeichnis |

---

## 7. Workflow Presets

### wf-vs-x64-release-inno+sign

Komplette Release-Pipeline mit Code-Signing:

| Schritt | Type | Preset |
|---------|------|--------|
| 1 | configure | windows-vs-x64-release_dynamic |
| 2 | build | build-vs-x64-Release |
| 3 | package | package-windows-inno-Release+sign |

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

## 9. Anpassung

### vcpkg-Pfad ändern

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

### Job-Anzahl ändern

```json
{
    "name": "my-fast-build",
    "inherits": "vs_x64_debug_md",
    "jobs": 16
}
```

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

## 10. Siehe auch

- [CMakePresets_Manual](CMakePresets_Manual_v0_1_0.md) – Konzepte
- [CMakePresets_Reference](CMakePresets_Reference_v0_1_0.md) – Team-Presets
- [CMakeUserPresets_Example](../UserGuides/CMakeUserPresets_Example_v0_1_0.md) – Template

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-03** | **Initial: vcpkg-Integration, parallelisierte Builds, Code-Signing** |
