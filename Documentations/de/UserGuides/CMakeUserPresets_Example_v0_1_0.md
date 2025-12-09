# CMakeUserPresets Example – CMake Architecture V2

> **Version:** 0.1.0  
> **Datum:** 2025-12-03  
> **Typ:** Benutzer-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** CMakePresets_Manual v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/UserGuides/CMakeUserPresets_Example_v0_1_0.md)

Dieses Dokument ist ein Template und Leitfaden für die Erstellung eigener `CMakeUserPresets.json`.

---

## 1. Übersicht

### Was sind User Presets?

| Datei | Zweck | Git |
|-------|-------|-----|
| `CMakePresets.json` | Team-weite Standards | ✅ Committen |
| `CMakeUserPresets.json` | **Persönliche** Anpassungen | ❌ Gitignore |

### Wann User Presets verwenden?

- Lokale Toolchain-Pfade (vcpkg, Conan, SDK)
- Persönliche Build-Jobs Anzahl
- Experimentelle Presets
- Code-Signing Konfiguration
- Eigene Kombinationen von Team-Presets

---

## 2. Minimales Template

```json
{
    "version": 6,
    "vendor": {
        "user-presets": {
            "version": "0.1.0",
            "author": "DEIN_NAME",
            "lastModified": "YYYY-MM-DD"
        }
    },
    "configurePresets": [],
    "buildPresets": [],
    "testPresets": []
}
```

---

## 3. Beispiel-Szenarien

### 3.1 Lokale vcpkg-Integration

```json
{
    "version": 6,
    "vendor": {
        "user-presets": {
            "version": "0.1.0",
            "author": "Max Mustermann",
            "lastModified": "2025-12-03"
        }
    },
    "configurePresets": [
        {
            "name": "with-vcpkg",
            "hidden": true,
            "description": "Lokale vcpkg-Installation",
            "cacheVariables": {
                "VCPKG_ROOT": "C:/Dev/vcpkg",
                "CMAKE_TOOLCHAIN_FILE": "C:/Dev/vcpkg/scripts/buildsystems/vcpkg.cmake",
                "VCPKG_FEATURE_FLAGS": "manifests,versions"
            }
        },
        {
            "name": "my-debug+vcpkg",
            "displayName": "Mein Debug + vcpkg",
            "inherits": ["windows-vs-x64-debug_dynamic", "with-vcpkg"]
        }
    ]
}
```

### 3.2 Schnellere Builds

```json
{
    "version": 6,
    "buildPresets": [
        {
            "name": "fast-debug",
            "displayName": "Schneller Debug Build (16 Jobs)",
            "configurePreset": "windows-vs-x64-debug_dynamic",
            "configuration": "Debug",
            "jobs": 16
        },
        {
            "name": "ultra-fast-ninja",
            "displayName": "Ultra-schneller Ninja Build",
            "configurePreset": "windows-ninja-multi",
            "configuration": "Debug",
            "jobs": 32
        }
    ]
}
```

### 3.3 Nur bestimmte Targets

```json
{
    "version": 6,
    "configurePresets": [
        {
            "name": "only-myapp",
            "displayName": "Nur MyApp bauen",
            "inherits": "windows-vs-x64-debug_dynamic",
            "cacheVariables": {
                "BUILD_ONLY": "MyApp",
                "BUILD_TESTS": "OFF"
            }
        },
        {
            "name": "only-tests",
            "displayName": "Nur Tests bauen",
            "inherits": "windows-vs-x64-debug_dynamic",
            "cacheVariables": {
                "BUILD_ONLY": "CoreTests;IntegrationTests"
            }
        }
    ]
}
```

### 3.4 Code-Signing für Releases

```json
{
    "version": 6,
    "packagePresets": [
        {
            "name": "my-signed-release",
            "displayName": "Signierter Release",
            "inherits": "package-windows-inno-Release",
            "variables": {
                "CPACK_INNOSETUP_EXECUTABLE_ARGUMENTS": "/Qp;/Smysigntool=$p"
            },
            "output": {
                "packageDirectory": "dist"
            }
        }
    ],
    "workflowPresets": [
        {
            "name": "release-signed",
            "displayName": "Release mit Signierung",
            "steps": [
                { "type": "configure", "name": "windows-vs-x64-release_dynamic" },
                { "type": "build", "name": "build-vs-x64-Release" },
                { "type": "test", "name": "ctest-vs-x64-Debug" },
                { "type": "package", "name": "my-signed-release" }
            ]
        }
    ]
}
```

### 3.5 Experimentelle Features

```json
{
    "version": 6,
    "configurePresets": [
        {
            "name": "experimental-modules",
            "displayName": "C++20 Modules Experiment",
            "inherits": "windows-vs-x64-debug_dynamic",
            "cacheVariables": {
                "CMAKE_CXX_STANDARD": "23",
                "CMAKE_CXX_SCAN_FOR_MODULES": "ON"
            }
        },
        {
            "name": "with-sanitizers",
            "displayName": "Alle Sanitizer aktiviert",
            "inherits": "linux-clang-debug",
            "cacheVariables": {
                "ENABLE_ASAN": "ON",
                "ENABLE_UBSAN": "ON",
                "ENABLE_TSAN": "OFF"
            }
        }
    ]
}
```

---

## 4. Vollständiges Beispiel

```json
{
    "version": 6,
    "vendor": {
        "user-presets": {
            "version": "0.1.0",
            "author": "Max Mustermann",
            "lastModified": "2025-12-03",
            "description": "Persönliche Entwicklungs-Presets"
        }
    },

    "configurePresets": [
        {
            "name": "with-vcpkg",
            "hidden": true,
            "cacheVariables": {
                "VCPKG_ROOT": "C:/Dev/vcpkg",
                "CMAKE_TOOLCHAIN_FILE": "C:/Dev/vcpkg/scripts/buildsystems/vcpkg.cmake"
            }
        },
        {
            "name": "my-dev",
            "displayName": "Meine Entwicklungsumgebung",
            "description": "Debug mit vcpkg, nur Hauptapp",
            "inherits": ["windows-vs-x64-debug_dynamic", "with-vcpkg"],
            "cacheVariables": {
                "BUILD_ONLY": "MyApp",
                "BUILD_TESTS": "OFF"
            }
        },
        {
            "name": "my-full",
            "displayName": "Vollständiger Build + vcpkg",
            "inherits": ["windows-vs-x64-debug_dynamic", "with-vcpkg"]
        }
    ],

    "buildPresets": [
        {
            "name": "my-fast",
            "displayName": "Schneller Build",
            "configurePreset": "my-dev",
            "configuration": "Debug",
            "jobs": 16
        }
    ],

    "testPresets": [
        {
            "name": "my-tests",
            "displayName": "Meine Tests",
            "configurePreset": "my-full",
            "configuration": "Debug",
            "output": { "outputOnFailure": true },
            "filter": {
                "include": {
                    "label": "unit"
                }
            }
        }
    ]
}
```

---

## 5. Best Practices

### ✅ Do's

- Vendor-Block mit Version und Datum pflegen
- Aussagekräftige `displayName` vergeben
- `hidden: true` für Bausteine verwenden
- Von Team-Presets erben statt kopieren
- Regelmäßig aufräumen

### ❌ Don'ts

- Keine absoluten Pfade ohne `hidden: true`
- Nicht Team-Presets überschreiben
- Keine sensiblen Daten (Passwörter, Keys)
- Nicht committen (muss in .gitignore sein!)

---

## 6. Troubleshooting

### Preset nicht sichtbar

```bash
cmake --list-presets
```

Prüfen:
- JSON-Syntax korrekt?
- `hidden: true` gesetzt?
- `condition` erfüllt?

### Vererbung funktioniert nicht

```json
// ❌ Falsch: String statt Array
"inherits": "windows-vs-x64-debug_dynamic"

// ✅ Richtig: Array
"inherits": ["windows-vs-x64-debug_dynamic"]
```

### vcpkg-Pfad falsch

```bash
# Prüfen ob Pfad existiert
ls C:/Dev/vcpkg/scripts/buildsystems/vcpkg.cmake
```

---

## 7. Siehe auch

- [CMakePresets_Manual](../References/CMakePresets_Manual_v0_1_0.md) – Konzepte
- [CMakePresets_Reference](../References/CMakePresets_Reference_v0_1_0.md) – Team-Presets
- [CMakeUserPresets_Reference](../References/CMakeUserPresets_Reference_v0_1_0.md) – Existierende User-Presets

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-03** | **Initial: Templates, Beispiel-Szenarien, Best Practices** |
