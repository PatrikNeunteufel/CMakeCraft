# Solution Schema — Referenz

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Reference  
> **Status:** Stabil  
> **Zielgruppe:** Alle Entwickler  
> **Sprache:** Deutsch  
> **English:** [Solution_Schema.md](../../en/reference/Solution_Schema.md)

Diese Referenz beschreibt das vollständige Schema der Solution.json für das CMake Architecture V2 Build-System.

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Konventionen](#2-konventionen)
3. [Root-Level Blöcke](#3-root-level-blöcke)
4. [solution Block](#4-solution-block)
5. [settings Block](#5-settings-block)
6. [externals Block](#6-externals-block)
7. [libraries Array](#7-libraries-array)
8. [executables Array](#8-executables-array)
9. [apps Array](#9-apps-array)
10. [tests Array](#10-tests-array)
11. [Schnellreferenz](#11-schnellreferenz)
12. [Verwendung](#12-verwendung)
13. [Siehe auch](#13-siehe-auch)

---

## 1. Übersicht

Die Solution.json ist das Herzstück der deklarativen Konfiguration. Sie definiert alle Aspekte des Build-Systems.

**Aktuelle Schema-Version:** `0.1`

---

## 2. Konventionen

### Symbole

| Symbol | Bedeutung |
|--------|-----------|
| ✅ | Pflichtfeld |
| — | Optional |

### Typen

| Typ | Beschreibung |
|-----|--------------|
| `string` | Zeichenkette |
| `number` | Zahl |
| `boolean` | true/false |
| `array` | Liste |
| `object` | Objekt |

---

## 3. Root-Level Blöcke

```json
{
    "schemaVersion": "0.1",
    "solution": { },
    "settings": { },
    "externals": { },
    "libraries": [ ],
    "executables": [ ],
    "apps": [ ],
    "tests": [ ]
}
```

| Block | Pflicht | Beschreibung |
|-------|---------|--------------|
| `schemaVersion` | ✅ | Schema-Version (MAJOR.MINOR) |
| `solution` | ✅ | Metadaten |
| `settings` | — | Globale Einstellungen |
| `externals` | — | Zentrale External-Definitionen |
| `libraries` | — | Interne Libraries |
| `executables` | — | Ausführbare Programme (Legacy) |
| `apps` | — | App-Container (Phase 8) |
| `tests` | — | Test-Targets |

---

## 4. solution Block

```json
"solution": {
    "name": "MySolution",
    "version": "1.0.0",
    "description": "Beschreibung",
    "authors": ["Name"]
}
```

| Feld | Typ | Pflicht | Beschreibung |
|------|-----|---------|--------------|
| `name` | string | ✅ | Projektname (→ PROJECT_NAME) |
| `version` | string | ✅ | SemVer (MAJOR.MINOR.PATCH) |
| `description` | string | — | Beschreibung |
| `authors` | array | — | Autoren-Liste |

---

## 5. settings Block

```json
"settings": {
    "standards": {
        "cxx_standard": 20,
        "cxx_standard_required": true,
        "cxx_extensions": false
    },
    "defaults": {
        "library_type": "STATIC",
        "executable_type": "CONSOLE"
    },
    "sources": {
        "mode": "auto"
    }
}
```

### 5.1 standards

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `cxx_standard` | 20 | C++ Standard (11, 14, 17, 20, 23) |
| `cxx_standard_required` | true | Standard erzwingen |
| `cxx_extensions` | false | Compiler-Erweiterungen |

### 5.2 defaults

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `library_type` | `"STATIC"` | STATIC, SHARED, INTERFACE |
| `executable_type` | `"CONSOLE"` | CONSOLE, GUI, WORKER |

### 5.3 sources

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `mode` | `"auto"` | explicit, glob, auto |

---

## 6. externals Block

### 6.1 Local External

```json
"bass": {
    "path": "externals/bass"
}
```

| Feld | Typ | Pflicht | Beschreibung |
|------|-----|---------|--------------|
| `path` | string | ✅ | Pfad zu Include.cmake |

### 6.2 Fetched External

```json
"spdlog": {
    "git": "https://github.com/gabime/spdlog.git",
    "tag": "v1.12.0",
    "shallow": true,
    "cmakeSupport": true
}
```

| Feld | Typ | Pflicht | Beschreibung |
|------|-----|---------|--------------|
| `git` | string | ✅ | Repository-URL |
| `tag` | string | ✅* | Git Tag |
| `branch` | string | ✅* | Git Branch |
| `commit` | string | ✅* | Commit-Hash |
| `shallow` | boolean | — | Shallow Clone (Default: true) |
| `cmakeSupport` | boolean | — | Hat CMakeLists.txt (Default: true) |
| `hook` | string | — | Hook-Wiederverwendung |

*Eines von tag/branch/commit erforderlich.

### 6.3 System External (Phase 9)

```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "version": ">=6.5.0",
    "components": ["Core", "Widgets"],
    "hints": ["${QT_ROOT}"],
    "backup": "E:/Backup/Qt/6.7.0"
}
```

| Feld | Typ | Pflicht | Beschreibung |
|------|-----|---------|--------------|
| `system` | boolean | ✅ | Kennzeichnet System External |
| `package` | string | ✅ | find_package Name |
| `version` | string | — | Version Constraint |
| `components` | array | — | Package-Komponenten |
| `hints` | array | — | Suchpfade |
| `backup` | string | — | Fallback-Pfad |

### 6.4 System External (aktueller Workaround)

```json
"qt6": {
    "path": "externals/qt6",
    "options": {
        "hint": "${QT_ROOT}",
        "backup": "E:/Backup/Qt/6.7.0",
        "components": ["Core", "Widgets"]
    }
}
```

### 6.5 cmakeSupport

| Wert | Bedeutung | Hook-Anforderung |
|------|-----------|------------------|
| `true` | Hat CMakeLists.txt | PostFetch optional |
| `false` | Kein CMakeLists.txt | PostFetch **PFLICHT** |

### 6.6 hook (Wiederverwendung)

```json
"imgui_docking": {
    "git": "https://github.com/ocornut/imgui.git",
    "tag": "v1.91.6-docking",
    "cmakeSupport": false,
    "hook": "imgui"
}
```

---

## 7. libraries Array

```json
"libraries": [
    {
        "name": "CoreLib",
        "version": "1.0.0",
        "type": "STATIC",
        "path": "projects/libs/CoreLib/src",
        "public_headers": "projects/libs/CoreLib/include",
        "dependencies": [],
        "externals": []
    }
]
```

| Feld | Typ | Pflicht | Default | Beschreibung |
|------|-----|---------|---------|--------------|
| `name` | string | ✅ | — | Eindeutiger Name |
| `version` | string | — | Solution-Version | Library-Version |
| `type` | string | — | `"STATIC"` | STATIC, SHARED, INTERFACE |
| `path` | string | — | Convention | Source-Verzeichnis |
| `public_headers` | string | — | — | Public Include-Pfad |
| `dependencies` | array | — | `[]` | Interne Libraries |
| `externals` | array | — | `[]` | Externe Libraries |

---

## 8. executables Array

```json
"executables": [
    {
        "name": "MyApp",
        "displayName": "My Application",
        "version": "1.0.0",
        "type": "GUI",
        "path": "projects/apps/MyApp/src",
        "skip": false,
        "dependencies": ["CoreLib"],
        "externals": ["qt6"],
        "external_options": {
            "bass": { "BASS_FLAC": true }
        }
    }
]
```

| Feld | Typ | Pflicht | Default | Beschreibung |
|------|-----|---------|---------|--------------|
| `name` | string | ✅ | — | Eindeutiger Name |
| `displayName` | string | — | name | Anzeigename |
| `version` | string | — | Solution-Version | Executable-Version |
| `type` | string | — | `"CONSOLE"` | CONSOLE, GUI, WORKER |
| `path` | string | — | Convention | Source-Verzeichnis |
| `skip` | boolean | — | `false` | Build überspringen |
| `dependencies` | array | — | `[]` | Interne Libraries |
| `externals` | array | — | `[]` | Externe Libraries |
| `external_options` | object | — | `{}` | Options pro External |
| `pch` | object | — | — | PCH-Konfiguration |

---

## 9. apps Array

> **Status:** 🔄 Phase 8 (geplant)

```json
"apps": [
    {
        "name": "AudioPlayer",
        "displayName": "Audio Player",
        "version": "2.0.0",
        
        "core": {
            "dependencies": ["BasicLogger"],
            "externals": ["bass", "spdlog"]
        },
        
        "runner": {
            "type": "WINDOW",
            "externals": ["imgui", "glad", "glfw"]
        },
        
        "pch": {
            "enabled": true
        },
        
        "tests": {
            "framework": "doctest",
            "unit": { "timeout": 30 },
            "integration": { "timeout": 120 }
        }
    }
]
```

| Feld | Typ | Pflicht | Default | Beschreibung |
|------|-----|---------|---------|--------------|
| `name` | string | ✅ | — | Eindeutiger Name |
| `displayName` | string | — | name | Anzeigename |
| `version` | string | — | `"1.0.0"` | App-Version |
| `path` | string | — | `projects/apps/{name}` | Basis-Pfad |
| `core` | object | — | `{}` | Core-Library Config |
| `runner` | object | — | `{}` | Runner-Executable Config |
| `pch` | object | — | `{}` | PCH-Konfiguration |
| `tests` | object | — | `{}` | Test-Konfiguration |
| `active` | boolean | — | `true` | App aktiv/inaktiv |

### 9.1 core

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `dependencies` | `[]` | Interne Libraries |
| `externals` | `[]` | Externe Libraries |
| `defines` | `[]` | Compile Definitions |

### 9.2 runner

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `type` | `"CONSOLE"` | CONSOLE oder WINDOW |
| `externals` | `[]` | Runner-spezifische Externals |
| `defines` | `[]` | Compile Definitions |

---

## 10. tests Array

```json
"tests": [
    {
        "name": "CoreLib_UnitTests",
        "displayName": "CoreLib Unit Tests",
        "type": "unit",
        "framework": "doctest",
        "path": "projects/tests/unit/CoreLib",
        "dependencies": ["CoreLib"],
        "externals": ["doctest"],
        "labels": ["unit", "fast"],
        "timeout": 30,
        "parallel": true
    }
]
```

| Feld | Typ | Pflicht | Default | Beschreibung |
|------|-----|---------|---------|--------------|
| `name` | string | ✅ | — | Eindeutiger Name |
| `displayName` | string | — | name | Anzeigename |
| `type` | string | — | `"unit"` | unit, integration, system, performance |
| `framework` | string | — | `"doctest"` | doctest, googletest, catch2 |
| `path` | string | — | Convention | Source-Verzeichnis |
| `dependencies` | array | — | `[]` | Interne Libraries |
| `externals` | array | — | `[]` | Externe Libraries |
| `labels` | array | — | `[]` | CTest Labels |
| `timeout` | number | — | 30 | Timeout in Sekunden |
| `parallel` | boolean | — | `true` | Parallel ausführbar |
| `source_from` | string | — | — | Executable für Sources |
| `exclude_sources` | array | — | `[]` | Auszuschließende Dateien |

### 10.1 Test-Typen

| Typ | Beschreibung | Default Labels |
|-----|--------------|----------------|
| `unit` | Isolierte Funktions-/Klassen-Tests | `unit`, `fast` |
| `integration` | Komponenten-Zusammenspiel | `integration`, `slow` |
| `system` | End-to-End Tests | `e2e`, `slow` |
| `performance` | Benchmarks | `benchmark`, `slow` |

### 10.2 Frameworks

| Framework | External | Beschreibung |
|-----------|----------|--------------|
| `doctest` | `doctest` | Schnell, Header-only |
| `googletest` | `googletest` | Feature-reich, GMock |
| `catch2` | `catch2` | BDD-Style, Sections |

---

## 11. Schnellreferenz

### Pflichtfelder

| Block | Pflichtfelder |
|-------|---------------|
| Root | `schemaVersion`, `solution` |
| solution | `name`, `version` |
| libraries | `name` |
| executables | `name` |
| apps | `name` |
| tests | `name` |
| externals (local) | `path` |
| externals (git) | `git`, tag/branch/commit |
| externals (system) | `system`, `package` |

### Fehler-Codes

| Code | Beschreibung |
|------|--------------|
| E001 | Pflichtfeld fehlt |
| E002 | Solution.json nicht gefunden |
| E010 | External nicht definiert |
| E012 | Kein/mehrere Source-Felder |
| E301 | Unbekanntes Test-Framework |
| E302 | source_from Executable fehlt |

---

## 12. Verwendung

### Vollständiges Beispiel

```json
{
    "schemaVersion": "0.1",
    "solution": {
        "name": "MyProject",
        "version": "1.0.0"
    },
    "settings": {
        "standards": { "cxx_standard": 20 },
        "sources": { "mode": "auto" }
    },
    "externals": {
        "doctest": { "path": "externals/doctest" },
        "spdlog": { "git": "https://github.com/gabime/spdlog.git", "tag": "v1.12.0" }
    },
    "libraries": [
        { "name": "CoreLib", "path": "projects/libs/CoreLib/src" }
    ],
    "executables": [
        { "name": "MyApp", "dependencies": ["CoreLib"], "externals": ["spdlog"] }
    ],
    "tests": [
        { "name": "CoreLib_Tests", "framework": "doctest", "dependencies": ["CoreLib"] }
    ]
}
```

---

## 13. Siehe auch

- [master_concept.md](../projects/buildsystem/concepts/master_concept.md) — Architektur
- [ErrorCodes.md](ErrorCodes.md) — Fehlercodes
- [Externals.md](Externals.md) — External-Referenz
- [AppContainer.md](../projects/buildsystem/concepts/AppContainer.md) — App-Container Konzept

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Reference Blueprint v0.5.0 Format, apps Array (Phase 8), system Externals (Phase 9)** |
| 0.1.4 | 2025-12-12 | tests Array dokumentiert |
| 0.1.3 | 2025-12-11 | System Externals options |
| 0.1.2 | 2025-12-10 | Hook-Wiederverwendung |
| 0.1.1 | 2025-12-09 | Git Externals |
| 0.1.0 | 2025-12-05 | Initial |
