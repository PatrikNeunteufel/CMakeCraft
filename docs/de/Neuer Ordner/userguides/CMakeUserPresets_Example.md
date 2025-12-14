# CMakeUserPresets Example — Benutzerhandbuch

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Guide  
> **Status:** Stabil  
> **Zielgruppe:** C++ Entwickler  
> **Basiert auf:** Guide v0.5  
> **Sprache:** Deutsch  
> **English:** [CMakeUserPresets_Example.md](../en/guides/CMakeUserPresets_Example.md)

---

## Inhaltsverzeichnis

1. [Überblick](#1-überblick)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Schnellstart](#3-schnellstart)
4. [Template](#4-template)
5. [Beispiel-Szenarien](#5-beispiel-szenarien)
6. [Stolpersteine und Lösungen](#6-stolpersteine-und-lösungen)
7. [Troubleshooting](#7-troubleshooting)
8. [Siehe auch](#8-siehe-auch)
9. [Changelog](#9-changelog)

---

## 1. Überblick

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

## 2. Voraussetzungen

- [ ] CMake 3.19+
- [ ] `CMakePresets.json` im Projekt vorhanden
- [ ] `CMakeUserPresets.json` in `.gitignore`

---

## 3. Schnellstart

Erstelle `CMakeUserPresets.json` im Projekt-Root:

```json
{
    "version": 6,
    "configurePresets": [
        {
            "name": "my-debug",
            "displayName": "Mein Debug",
            "inherits": ["windows-ninja-debug"],
            "cacheVariables": {
                "BUILD_TESTS": "OFF"
            }
        }
    ],
    "buildPresets": [
        {
            "name": "my-fast",
            "configurePreset": "my-debug",
            "jobs": 16
        }
    ]
}
```

---

## 4. Template

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

## 5. Beispiel-Szenarien

### 5.1 Lokale vcpkg-Integration

```json
{
    "version": 6,
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
            "name": "my-debug+vcpkg",
            "displayName": "Mein Debug + vcpkg",
            "inherits": ["windows-ninja-debug", "with-vcpkg"]
        }
    ]
}
```

### 5.2 Schnellere Builds

```json
{
    "version": 6,
    "buildPresets": [
        {
            "name": "fast-debug",
            "displayName": "Schneller Debug Build",
            "configurePreset": "windows-ninja-debug",
            "jobs": 16
        },
        {
            "name": "ultra-fast",
            "displayName": "Ultra-schneller Build",
            "configurePreset": "windows-ninja-multi",
            "jobs": 32
        }
    ]
}
```

### 5.3 Qt6 Umgebungsvariable

```json
{
    "version": 6,
    "configurePresets": [
        {
            "name": "qt-env",
            "hidden": true,
            "environment": {
                "QT_ROOT": "C:/Qt/6.10.1/msvc2022_64"
            }
        },
        {
            "name": "windows-qt",
            "displayName": "Windows + Qt6",
            "inherits": ["windows-ninja-debug", "qt-env"]
        }
    ]
}
```

### 5.4 Nur bestimmte Targets

```json
{
    "version": 6,
    "configurePresets": [
        {
            "name": "only-myapp",
            "displayName": "Nur MyApp",
            "inherits": "windows-ninja-debug",
            "cacheVariables": {
                "BUILD_ONLY": "MyApp",
                "BUILD_TESTS": "OFF"
            }
        }
    ]
}
```

### 5.5 Experimentelle Features

```json
{
    "version": 6,
    "configurePresets": [
        {
            "name": "with-sanitizers",
            "displayName": "Mit Sanitizers",
            "inherits": "linux-clang-debug",
            "cacheVariables": {
                "ENABLE_ASAN": "ON",
                "ENABLE_UBSAN": "ON"
            }
        }
    ]
}
```

---

## 6. Stolpersteine und Lösungen

### 6.1 Vererbung funktioniert nicht

**Problem:** Preset erbt nicht korrekt.

**Lösung:** Array-Syntax verwenden:

```json
// ❌ Falsch
"inherits": "windows-ninja-debug"

// ✅ Richtig
"inherits": ["windows-ninja-debug"]
```

### 6.2 Pfad nicht gefunden

**Problem:** Toolchain/vcpkg-Pfad nicht gefunden.

**Lösung:** Pfad prüfen:
```bash
ls C:/Dev/vcpkg/scripts/buildsystems/vcpkg.cmake
```

### 6.3 Preset nicht sichtbar

**Problem:** Preset erscheint nicht in der Liste.

**Lösung:**
- JSON-Syntax prüfen
- `hidden: true` entfernen oder erben
- `condition` prüfen

---

## 7. Troubleshooting

### Presets auflisten

```bash
cmake --list-presets
```

### JSON validieren

```bash
python -m json.tool CMakeUserPresets.json
```

### Checkliste

- [ ] `CMakeUserPresets.json` im Projekt-Root?
- [ ] `version: 6` gesetzt?
- [ ] Parent-Preset existiert?
- [ ] JSON-Syntax korrekt?

### Best Practices

| ✅ Do | ❌ Don't |
|-------|---------|
| Vendor-Block pflegen | Committen |
| `hidden: true` für Bausteine | Absolute Pfade ohne hidden |
| Von Team-Presets erben | Team-Presets überschreiben |
| Aussagekräftige displayName | Sensible Daten speichern |

---

## 8. Siehe auch

- [CMakePresets_Manual](../reference/CMakePresets_Manual.md) — Konzepte
- [CMakePresets_Reference](../reference/CMakePresets_Reference.md) — Team-Presets
- [Qt6 Integration](Qt6_Integration_UserGuide.md) — Qt6 mit User Presets

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf Guide v0.5 Blueprint, Qt6-Beispiel** |
| 0.1.0 | 2025-12-03 | Initial: Templates, Beispiel-Szenarien |
