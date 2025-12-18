# Solution Schema — Referenz

> **Version:** 0.5.2  
> **Datum:** 2025-12-18  
> **Typ:** Reference  
> **Status:** Stabil  
> **Zielgruppe:** Alle Entwickler  
> **Sprache:** Deutsch  
> **English:** [Solution_Schema.md](../../en/references/Solution_Schema.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Konventionen](#2-konventionen)
3. [solution Block](#3-solution-block)
4. [settings Block](#4-settings-block)
5. [externals Block](#5-externals-block)
6. [executables Array](#6-executables-array)
7. [libraries Array](#7-libraries-array)
8. [tests Array](#8-tests-array)
9. [Schnellreferenz](#9-schnellreferenz)
10. [Vollständiges Beispiel](#10-vollständiges-beispiel)
11. [Fehler-Codes](#11-fehler-codes)
12. [Siehe auch](#12-siehe-auch)
13. [Changelog](#13-changelog)

---

## 1. Übersicht

Diese Referenz beschreibt das vollständige Schema der Solution.json für das CMake Architecture V2 Build-System. Die Solution.json ist das Herzstück der deklarativen Konfiguration.

### Root-Level Struktur

```json
{
    "schemaVersion": "0.1",
    "solution": { },
    "settings": { },
    "externalsPolicy": { },
    "externals": { },
    "libraries": [ ],
    "executables": [ ],
    "tests": [ ]
}
```

### Block-Übersicht

| Block | Pflicht | Beschreibung |
|-------|---------|--------------|
| `schemaVersion` | ✅ | Version des JSON-Schemas (nur MAJOR.MINOR) |
| `solution` | ✅ | Metadaten (Name, Version, Autoren) |
| `settings` | – | Globale Build-Einstellungen |
| `externalsPolicy` | – | External-Verhalten |
| `externals` | – | Zentrale External-Definitionen |
| `libraries` | – | Interne Libraries |
| `executables` | – | Ausführbare Programme |
| `tests` | – | Test-Targets |

---

## 2. Konventionen

### Symbole

| Symbol | Bedeutung |
|--------|-----------|
| ✅ | Pflichtfeld |
| – | Optional / Standard |

### Pfad-Konventionen

Alle Pfade sind relativ zu `CMAKE_SOURCE_DIR` (Projekt-Root).

### Umgebungsvariablen

Syntax: `${VAR_NAME}` wird zu `$ENV{VAR_NAME}` expandiert.

```json
"hint": "${QT_ROOT}"        // → C:/Qt/6.10.1/msvc2022_64
"hint": "${HOME}/Qt/6.10.1" // → /home/user/Qt/6.10.1
```

---

## 3. solution Block

```json
"solution": {
    "name": "MySolution",
    "version": "1.0.0",
    "description": "Beschreibung",
    "authors": ["Name"]
}
```

| Feld | Pflicht | Typ | Beschreibung |
|------|---------|-----|--------------|
| `name` | ✅ | string | Projektname (→ PROJECT_NAME) |
| `version` | ✅ | string | Semantische Version (MAJOR.MINOR.PATCH) |
| `description` | – | string | Beschreibung für IDEs/Dokumentation |
| `authors` | – | string[] | Autoren-Liste |

---

## 4. settings Block

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

### 4.1 standards

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `cxx_standard` | 20 | C++ Standard (11, 14, 17, 20, 23) |
| `cxx_standard_required` | true | Standard erzwingen |
| `cxx_extensions` | false | Compiler-Erweiterungen |

### 4.2 defaults

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `library_type` | `"STATIC"` | Standard Library-Typ |
| `executable_type` | `"CONSOLE"` | Standard Executable-Typ |

### 4.3 sources

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `mode` | `"auto"` | Source-Collection (explicit, glob, auto) |

---

## 5. externals Block

Der zentrale Ort für alle External-Definitionen.

### 5.1 External-Typen

| Typ | Erkennungsmerkmal | Beschreibung |
|-----|-------------------|--------------|
| **Local** | `path` Feld | Vorkompilierte Bibliotheken in `externals/` |
| **Fetched** | `git` Feld | Via Git geklont |
| **System** | `path` + `options` | Große externe Installationen (Qt6, Boost) |

### 5.2 Local Externals
```json
"externals": {
    "bass": {
        "path": "externals/bass"
    }
}
```

| Feld | Pflicht | Beschreibung |
|------|---------|--------------|
| `path` | ✅ | Pfad relativ zu CMAKE_SOURCE_DIR |
| `include` | — | Pfad zur Include.cmake (optional) |

#### Include.cmake Convention

**Default-Pfad (Convention over Configuration):**

```markdown
cmake/externals/includes/{name}/Include.cmake
```
Wobei `{name}` der External-Schlüssel ist (z.B. `bass`, `lua54`).

**Beispiele:**

| External | Convention-Pfad |
|----------|-----------------|
| `"bass": {...}` | `cmake/externals/includes/bass/Include.cmake` |
| `"lua54": {...}` | `cmake/externals/includes/lua54/Include.cmake` |
| `"doctest": {...}` | `cmake/externals/includes/doctest/Include.cmake` |

**Custom Include (optional):**

Nur verwenden wenn vom Default abgewichen werden muss:
```json
"externals": {
    "mylib": {
        "path": "externals/mylib",
        "include": "cmake/custom/mylib_special.cmake"
    }
}
```

> **Empfehlung:** Immer die Convention verwenden. Das `include` Feld nur für Sonderfälle.

### 5.3 Fetched Externals

```json
"externals": {
    "spdlog": {
        "git": "https://github.com/gabime/spdlog.git",
        "tag": "v1.12.0",
        "shallow": true,
        "cmakeSupport": true
    }
}
```

| Feld | Pflicht | Beschreibung |
|------|---------|--------------|
| `git` | ✅ | Repository-URL |
| `tag` | – | Git Tag oder Branch |
| `commit` | – | Spezifischer Commit-Hash |
| `shallow` | – | Shallow Clone (Default: true) |
| `cmakeSupport` | – | Hat CMakeLists.txt (Default: true) |
| `preFetchHook` | – | Pfad zu PreFetch Hook |
| `postFetchHook` | – | Pfad zu PostFetch Hook |
| `hook` | – | Hook-Wiederverwendung |

### 5.4 System Externals

Für große, extern installierte Bibliotheken wie Qt6, Boost, OpenCV:

```json
"externals": {
    "qt6": {
        "path": "externals/qt6",
        "options": {
            "hint": "${QT_ROOT}",
            "backup": "E:/Backup/Qt/6.10.1/msvc2022_64",
            "components": ["Core", "Widgets", "Gui", "OpenGL"]
        }
    }
}
```

#### options Feld

| Option | Typ | Beschreibung |
|--------|-----|--------------|
| `hint` | string | Pfad zur Installation (Umgebungsvariablen erlaubt) |
| `backup` | string | Fallback-Pfad (mit WARNING wenn verwendet) |
| `components` | string[] | Zu ladende Module/Komponenten |

### 5.5 cmakeSupport Flag

| Wert | Bedeutung | Hook-Anforderung |
|------|-----------|------------------|
| `true` (default) | External hat CMakeLists.txt | PostFetch optional |
| `false` | Kein CMakeLists.txt | PostFetch **PFLICHT** |

### 5.6 hook Feld (Hook-Wiederverwendung)

```json
"externals": {
    "imgui": {
        "git": "https://github.com/ocornut/imgui.git",
        "tag": "v1.91.6",
        "cmakeSupport": false
    },
    "imgui_docking": {
        "git": "https://github.com/ocornut/imgui.git",
        "tag": "v1.91.6-docking",
        "cmakeSupport": false,
        "hook": "imgui"
    }
}
```

| External | Hook-Datei | `HOOK_EXTERNAL_NAME` | Target |
|----------|------------|----------------------|--------|
| `imgui` | `imgui.cmake` | `"imgui"` | `imgui` |
| `imgui_docking` | `imgui.cmake` | `"imgui_docking"` | `imgui_docking` |

---

## 6. executables Array

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
        "externals": ["qt6", "spdlog"],
        "external_options": {
            "bass": { "BASS_FLAC": true }
        }
    }
]
```

### 6.1 Pflichtfelder

| Feld | Beschreibung |
|------|--------------|
| `name` | Eindeutiger Target-Name |

### 6.2 Optionale Felder

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `displayName` | `name` | Anzeigename |
| `version` | Solution-Version | Executable-Version |
| `type` | `CONSOLE` | `CONSOLE`, `GUI`, `WORKER` |
| `path` | `projects/exec/{name}/src` | Source-Verzeichnis |
| `skip` | `false` | Build überspringen |
| `pch` | – | Precompiled Headers Config (siehe [§ 6.5](#65-pch-object-precompiled-headers)) |
| `dependencies` | `[]` | Interne Libraries |
| `externals` | `[]` | External-Referenzen |
| `external_options` | `{}` | Per-External Options |
| `platforms` | `[]` (alle) | Plattform-Filter |
| `defines` | `[]` | Preprocessor-Definitionen |
| `compile_options` | `[]` | Compiler-Flags |
| `link_options` | `[]` | Linker-Flags |

### 6.3 type Werte

| Typ | Windows | macOS | Linux |
|-----|---------|-------|-------|
| `CONSOLE` | Normal | Normal | Normal |
| `GUI` | WIN32 | MACOSX_BUNDLE | Normal |
| `WORKER` | Normal | Normal | Normal |

### 6.4 external_options

Per-Target Options für Externals:

```json
"external_options": {
    "bass": {
        "BASS_FLAC": true,
        "BASS_FX": true
    }
}
```

### 6.5 pch Object (Precompiled Headers)

```json
"pch": {
    "enabled": true,
    "header": "stdafx.h",
    "path": "common/pch"
}
```

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `enabled` | `false` | PCH aktivieren |
| `header` | `pch.h` | Name der PCH-Datei |
| `path` | – | Custom-Pfad (relativ zu `projects/`) |

**Aktivierung (implizit):**

PCH wird automatisch aktiviert wenn:
- `enabled: true` explizit gesetzt ist, ODER
- `header` angegeben ist und `enabled` nicht `false`, ODER
- `path` angegeben ist und `enabled` nicht `false`

**Suchpfad-Priorität** (wenn `path` nicht angegeben):

| Priorität | Pfad |
|-----------|------|
| 1 | `{target-path}/pch/{header}` |
| 2 | `{target-path}/src/{header}` |
| 3 | `{target-path}/{header}` |

Wenn `path` angegeben: `projects/{path}/{header}`

---

## 7. libraries Array

```json
"libraries": [
    {
        "name": "CoreLib",
        "version": "1.0.0",
        "type": "STATIC",
        "path": "projects/libs/CoreLib/src",
        "public_headers": "projects/libs/CoreLib/include"
    }
]
```

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `name` | ✅ Pflicht | Target-Name |
| `version` | Solution-Version | Library-Version |
| `type` | Settings-Default | `STATIC`, `SHARED`, `INTERFACE` |
| `path` | Convention | Source-Verzeichnis |
| `public_headers` | – | Public Include-Verzeichnis |
| `pch` | – | Precompiled Headers Config (siehe [§ 6.5](#65-pch-object-precompiled-headers)) |

---

## 8. tests Array

### 8.1 Grundstruktur

```json
"tests": [
    {
        "name": "CoreLib_UnitTests",
        "displayName": "CoreLib Unit Tests",
        "type": "unit",
        "framework": "doctest",
        "dependencies": ["CoreLib"],
        "externals": ["doctest"],
        "timeout": 30,
        "labels": ["unit", "core", "fast"],
        "parallel": true
    }
]
```

### 8.2 Pflichtfelder

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `name` | string | Eindeutiger Test-Target-Name |

### 8.3 Optionale Felder

| Feld | Typ | Default | Beschreibung |
|------|-----|---------|--------------|
| `displayName` | string | `name` | Anzeigename |
| `version` | string | Solution-Version | Test-Version |
| `type` | string | `"unit"` | Test-Typ |
| `framework` | string | `"doctest"` | Test-Framework |
| `path` | string | Convention | Source-Verzeichnis |
| `target` | string | – | Zu testendes Target (für Coverage) |
| `dependencies` | string[] | `[]` | Interne Libraries |
| `externals` | string[] | `[]` | Externe Libraries |
| `external_options` | object | `{}` | Per-External Options |
| `timeout` | int | 60 | Timeout in Sekunden |
| `labels` | string[] | `[type]` | CTest Labels |
| `parallel` | bool | true | Parallel ausführbar |
| `skip` | bool | false | Test überspringen |
| `source_from` | string | – | Sources von Executable übernehmen |
| `exclude_sources` | string[] | `[]` | Auszuschließende Sources |

### 8.4 Test-Typen

| Typ | Beschreibung | Empfohlene Labels |
|-----|--------------|-------------------|
| `unit` | Einzelne Funktionen/Klassen testen | `fast`, `isolated` |
| `integration` | Komponenten-Zusammenspiel | `slow`, `database` |
| `system` | Gesamtsystem (End-to-End) | `e2e`, `slow` |
| `performance` | Benchmarks, Performance-Tests | `benchmark`, `slow` |
| `smoke` | Schnelle Basis-Tests | `fast`, `critical` |

### 8.5 Unterstützte Frameworks

| Framework | External-Name | Beschreibung |
|-----------|---------------|--------------|
| `doctest` | `doctest` | Schnell, Header-only, ideal für Unit Tests |
| `googletest` | `googletest` | Feature-reich, Mocking (GMock) |
| `catch2` | `catch2` | BDD-Style, Sections, Benchmarks |

### 8.6 source_from (Executable-Sources testen)

Für Tests die Module aus einem Executable testen (ohne dessen main):

```json
"tests": [
    {
        "name": "MyApp_ModuleY_Tests",
        "type": "unit",
        "framework": "doctest",
        "source_from": "MyApp",
        "exclude_sources": ["main.cpp"],
        "externals": ["doctest"]
    }
]
```

### 8.7 CTest-Integration

```bash
# Alle Tests ausführen
ctest --test-dir build

# Nach Label filtern
ctest -L unit        # Nur Unit Tests
ctest -L fast        # Nur schnelle Tests
ctest -LE slow       # Keine langsamen Tests

# Parallel ausführen
ctest -j8            # 8 parallele Jobs
```

---

## 9. Schnellreferenz

### 9.1 Pflichtfelder

| Block | Feld |
|-------|------|
| Root | `schemaVersion` |
| solution | `name`, `version` |
| executables[] | `name` |
| libraries[] | `name` |
| tests[] | `name` |
| externals (local) | `path` (include optional) |
| externals (fetched) | `git`, (tag\|branch\|commit) |

### 9.2 Defaults

| Einstellung | Default-Wert |
|-------------|--------------|
| C++ Standard | 20 |
| Library-Typ | STATIC |
| Executable-Typ | CONSOLE |
| Source-Mode | auto |
| Test-Framework | doctest |
| Test-Timeout | 60s |

---

## 10. Vollständiges Beispiel

```json
{
    "schemaVersion": "0.1",
    "solution": {
        "name": "MyProject",
        "version": "1.0.0",
        "description": "Example project with Qt6 and Tests"
    },
    "settings": {
        "standards": { "cxx_standard": 20 },
        "defaults": {
            "library_type": "STATIC",
            "executable_type": "CONSOLE"
        },
        "sources": { "mode": "auto" }
    },
    "externals": {
        "bass": { "path": "externals/bass" },
        "doctest": { "path": "externals/doctest" },
        "glfw": {
            "git": "https://github.com/glfw/glfw.git",
            "tag": "3.4"
        },
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.91.6",
            "cmakeSupport": false
        },
        "qt6": {
            "path": "externals/qt6",
            "options": {
                "hint": "${QT_ROOT}",
                "components": ["Core", "Widgets", "Gui"]
            }
        }
    },
    "libraries": [
        {
            "name": "CoreLib",
            "version": "1.0.0",
            "type": "STATIC",
            "path": "projects/libs/CoreLib/src",
            "public_headers": "projects/libs/CoreLib/include"
        }
    ],
    "executables": [
        {
            "name": "ConsoleApp",
            "type": "CONSOLE",
            "dependencies": ["CoreLib"],
            "externals": ["bass"],
            "external_options": {
                "bass": { "BASS_FLAC": true }
            }
        },
        {
            "name": "QtApp",
            "type": "GUI",
            "externals": ["qt6"]
        }
    ],
    "tests": [
        {
            "name": "CoreLib_UnitTests",
            "type": "unit",
            "framework": "doctest",
            "dependencies": ["CoreLib"],
            "externals": ["doctest"],
            "labels": ["unit", "core", "fast"],
            "timeout": 30
        }
    ]
}
```
> **Hinweis:** Für lokale externals ist **kein** `include` Feld nötig — die Convention `cmake/externals/includes/{name}/Include.cmake` wird automatisch verwendet.

---

## 11. Fehler-Codes

### 11.1 External-bezogene Fehler

| Code | Beschreibung |
|------|--------------|
| E010 | External nicht in externals Block definiert |
| E012 | External hat weder path noch git Feld |
| E213 | Include.cmake für lokales External nicht gefunden |
| E216 | PostFetch Hook fehlt (cmakeSupport: false) |
| E218 | Hook-Datei nicht gefunden |
| E220 | Target nach Hook nicht registriert |

### 11.2 Test-bezogene Fehler

| Code | Beschreibung |
|------|--------------|
| E301 | Unbekanntes Test-Framework |
| E302 | source_from Executable existiert nicht |
| E303 | Test-Source-Verzeichnis nicht gefunden |

### 11.3 Warnungen

| Code | Beschreibung |
|------|--------------|
| W302 | Hook-Wiederverwendung aktiv |

---

## 12. Siehe auch

- [Externals.md](Externals.md) — External Libraries Referenz
- [ErrorCodes.md](ErrorCodes.md) — Vollständige Fehlercode-Referenz
- [CMakePresets Reference](CMakePresets.md) — Build-Presets

---

## 13. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.2** | **2025-12-18** | **PCH-Objekt vollständig dokumentiert (§ 6.5): implizite Aktivierung, Suchpfad-Priorität, pch für libraries hinzugefügt** |
| 0.5.1 | 2025-12-15 | Include.cmake Convention dokumentiert (§ 5.2), include Feld als optional, Hook-Pfade kleingeschrieben |
| 0.5.0 | 2025-12-14 | Blueprint v0.5.0 Format: Nummeriertes TOC, Reference-Header, Schnellreferenz, Änderungsblöcke ins Changelog integriert |
| 0.1.4 | 2025-12-12 | tests Array dokumentiert: Typen, Frameworks, source_from, CTest |
| 0.1.3 | 2025-12-11 | System Externals: options Feld (hint, backup, components) |
| 0.1.2 | 2025-12-10 | Hook-Wiederverwendung (hook Feld) |
| 0.1.1 | 2025-12-09 | Git Externals (git, tag, cmakeSupport) |
| 0.1.0 | 2025-12-05 | Initial Schema |
