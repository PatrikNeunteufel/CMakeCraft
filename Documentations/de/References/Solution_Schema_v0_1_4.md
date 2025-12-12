# Solution Schema – CMake Architecture V2

> **Version:** 0.1.4  
> **Datum:** 2025-12-12  
> **Typ:** Referenz-Doku  
> **Status:** Stabil  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch

Diese Dokumentation beschreibt das vollständige Schema der Solution.json für das CMake Architecture V2 Build-System.

---

## Änderungen in v0.1.4

- **Neu:** `tests` Array vollständig dokumentiert
- **Neu:** Test-Typen (unit, integration, system, performance, smoke)
- **Neu:** Framework-Auswahl (doctest, googletest, catch2)
- **Neu:** CTest-Integration (labels, timeout, parallel)
- **Neu:** `source_from` und `exclude_sources` für Executable-Source-Tests

---

## Änderungen in v0.1.3

- **Neu:** `options` Feld für lokale Externals dokumentiert (System Externals wie Qt6)
- **Neu:** `hint`, `backup`, `components` Options für Qt6
- **Verbessert:** Beispiele für System Externals

---

## 1. Übersicht

Die Solution.json ist das Herzstück der deklarativen Konfiguration. Sie definiert alle Aspekte des Build-Systems in einer einzigen Datei.

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

| Block | Pflicht | Beschreibung |
|-------|---------|--------------|
| `schemaVersion` | ✅ | Version des JSON-Schemas (nur MAJOR.MINOR) |
| `solution` | ✅ | Metadaten (Name, Version, Autoren) |
| `settings` | ❌ | Globale Build-Einstellungen |
| `externalsPolicy` | ❌ | External-Verhalten |
| `externals` | ❌ | Zentrale External-Definitionen |
| `libraries` | ❌ | Interne Libraries |
| `executables` | ❌ | Ausführbare Programme |
| `tests` | ❌ | Test-Targets |

---

## 2. solution Block

```json
"solution": {
    "name": "MySolution",
    "version": "1.0.0",
    "description": "Beschreibung",
    "authors": ["Name"]
}
```

| Feld | Pflicht | Beschreibung |
|------|---------|--------------|
| `name` | ✅ | Projektname (→ PROJECT_NAME) |
| `version` | ✅ | Semantische Version (MAJOR.MINOR.PATCH) |
| `description` | ❌ | Beschreibung für IDEs/Dokumentation |
| `authors` | ❌ | Autoren-Liste |

---

## 3. settings Block

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

### 3.1 standards

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `cxx_standard` | 20 | C++ Standard (11, 14, 17, 20, 23) |
| `cxx_standard_required` | true | Standard erzwingen |
| `cxx_extensions` | false | Compiler-Erweiterungen |

### 3.2 defaults

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `library_type` | `"STATIC"` | Standard Library-Typ |
| `executable_type` | `"CONSOLE"` | Standard Executable-Typ |

### 3.3 sources

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `mode` | `"auto"` | Source-Collection (explicit, glob, auto) |

---

## 4. externals Block

Der zentrale Ort für alle External-Definitionen.

### 4.1 External-Typen

| Typ | Erkennungsmerkmal | Beschreibung |
|-----|-------------------|--------------|
| **Local** | `path` Feld | Vorkompilierte Bibliotheken in `externals/` |
| **Fetched** | `git` Feld | Via Git geklont |
| **System** | `path` + `options` | Große externe Installationen (Qt6, Boost) |

### 4.2 Local Externals

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

**Include.cmake wird geladen von:** `${path}/Include.cmake`

### 4.3 Fetched Externals

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
| `tag` | ❌ | Git Tag oder Branch |
| `commit` | ❌ | Spezifischer Commit-Hash |
| `shallow` | ❌ | Shallow Clone (Default: true) |
| `cmakeSupport` | ❌ | Hat CMakeLists.txt (Default: true) |
| `preFetchHook` | ❌ | Pfad zu PreFetch Hook |
| `postFetchHook` | ❌ | Pfad zu PostFetch Hook |
| `hook` | ❌ | Hook-Wiederverwendung (siehe 4.6) |

### 4.4 System Externals

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

**Unterschied zu Local Externals:**
- `path` zeigt auf einen Ordner der NUR `Include.cmake` enthält
- Eigentliche Installation ist extern (C:/Qt/..., /opt/homebrew/...)
- `options` steuert die Pfad-Auflösung

#### options Feld

| Option | Typ | Beschreibung |
|--------|-----|--------------|
| `hint` | string | Pfad zur Installation (Umgebungsvariablen erlaubt) |
| `backup` | string | Fallback-Pfad (mit WARNING wenn verwendet) |
| `components` | string[] | Zu ladende Module/Komponenten |

**Umgebungsvariablen in Pfaden:**

Unterstützte Syntax: `${VAR_NAME}` wird zu `$ENV{VAR_NAME}` expandiert.

```json
"hint": "${QT_ROOT}"        // → C:/Qt/6.10.1/msvc2022_64
"hint": "${HOME}/Qt/6.10.1" // → /home/user/Qt/6.10.1
```

**Qt6-spezifische options:**

| Option | Default | Beschreibung |
|--------|---------|--------------|
| `hint` | - | Qt-Installationspfad |
| `backup` | - | Backup-Pfad (USB, Netzwerk) |
| `components` | `["Core", "Gui", "Widgets"]` | Qt-Module |

### 4.5 cmakeSupport Feld

| Wert | Bedeutung | Hook-Anforderung |
|------|-----------|------------------|
| `true` (default) | External hat CMakeLists.txt | PostFetch optional |
| `false` | Kein CMakeLists.txt | PostFetch **PFLICHT** |

### 4.6 hook Feld (Hook-Wiederverwendung)

Das `hook` Feld ermöglicht die Wiederverwendung von Hooks für Varianten:

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

| Aspekt | Beschreibung |
|--------|--------------|
| **Typ** | `string` |
| **Optional** | Ja |
| **Default** | Name des Externals selbst |
| **Wert** | Name des Hooks (Dateiname ohne .cmake) |

**Verhalten:**

| External | Hook-Datei | `HOOK_EXTERNAL_NAME` | Target |
|----------|------------|----------------------|--------|
| `imgui` | `imgui.cmake` | `"imgui"` | `imgui` |
| `imgui_docking` | `imgui.cmake` | `"imgui_docking"` | `imgui_docking` |

---

## 5. executables Array

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

### 5.1 Pflichtfelder

| Feld | Beschreibung |
|------|--------------|
| `name` | Eindeutiger Target-Name |

### 5.2 Optionale Felder

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `displayName` | `name` | Anzeigename |
| `version` | Solution-Version | Executable-Version |
| `type` | `CONSOLE` | `CONSOLE`, `GUI`, `WORKER` |
| `path` | `projects/exec/{name}/src` | Source-Verzeichnis |
| `skip` | `false` | Build überspringen |
| `pch` | - | Precompiled Headers Config |
| `dependencies` | `[]` | Interne Libraries |
| `externals` | `[]` | External-Referenzen |
| `external_options` | `{}` | Per-External Options |
| `platforms` | `[]` (alle) | Plattform-Filter |
| `defines` | `[]` | Preprocessor-Definitionen |
| `compile_options` | `[]` | Compiler-Flags |
| `link_options` | `[]` | Linker-Flags |

### 5.3 type Werte

| Typ | Windows | macOS | Linux |
|-----|---------|-------|-------|
| `CONSOLE` | Normal | Normal | Normal |
| `GUI` | WIN32 | MACOSX_BUNDLE | Normal |
| `WORKER` | Normal | Normal | Normal |

### 5.4 external_options

Per-Target Options für Externals:

```json
"external_options": {
    "bass": {
        "BASS_FLAC": true,
        "BASS_FX": true
    }
}
```

Diese Options werden in `EXTERNAL_ELEMENT_OPTIONS` an die Include.cmake übergeben.

---

## 6. libraries Array

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

### 6.1 Felder

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `name` | ✅ Pflicht | Target-Name |
| `version` | Solution-Version | Library-Version |
| `type` | Settings-Default | `STATIC`, `SHARED`, `INTERFACE` |
| `path` | Convention | Source-Verzeichnis |
| `public_headers` | - | Public Include-Verzeichnis |

---

## 7. tests Array

Das `tests` Array definiert Test-Targets für Projekt-Code (Unit Tests, Integration Tests, etc.).

### 7.1 Grundstruktur

```json
"tests": [
    {
        "name": "CoreLib_UnitTests",
        "displayName": "CoreLib Unit Tests",
        "version": "1.0.0",
        "type": "unit",
        "framework": "doctest",
        "path": "projects/tests/unit/CoreLib_Tests/src",
        "target": "CoreLib",
        "dependencies": ["CoreLib"],
        "externals": ["doctest"],
        "timeout": 30,
        "labels": ["unit", "core", "fast"],
        "parallel": true
    }
]
```

### 7.2 Pflichtfelder

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `name` | string | Eindeutiger Test-Target-Name |

### 7.3 Optionale Felder

| Feld | Typ | Default | Beschreibung |
|------|-----|---------|--------------|
| `displayName` | string | `name` | Anzeigename |
| `version` | string | Solution-Version | Test-Version |
| `type` | string | `"unit"` | Test-Typ (siehe 7.4) |
| `framework` | string | `"doctest"` | Test-Framework (siehe 7.5) |
| `path` | string | Convention | Source-Verzeichnis |
| `target` | string | - | Zu testendes Target (für Coverage) |
| `dependencies` | string[] | `[]` | Interne Libraries |
| `externals` | string[] | `[]` | Externe Libraries |
| `external_options` | object | `{}` | Per-External Options |
| `timeout` | int | 60 | Timeout in Sekunden |
| `labels` | string[] | `[type]` | CTest Labels |
| `parallel` | bool | true | Parallel ausführbar |
| `skip` | bool | false | Test überspringen |
| `platforms` | string[] | alle | Plattform-Filter |
| `defines` | string[] | `[]` | Preprocessor-Definitionen |
| `compile_options` | string[] | `[]` | Compiler-Flags |
| `source_from` | string | - | Sources von Executable übernehmen (siehe 7.7) |
| `exclude_sources` | string[] | `[]` | Auszuschließende Sources (mit source_from) |

### 7.4 Test-Typen

| Typ | Beschreibung | Empfohlene Labels |
|-----|--------------|-------------------|
| `unit` | Einzelne Funktionen/Klassen testen | `fast`, `isolated` |
| `integration` | Komponenten-Zusammenspiel | `slow`, `database` |
| `system` | Gesamtsystem (End-to-End) | `e2e`, `slow` |
| `performance` | Benchmarks, Performance-Tests | `benchmark`, `slow` |
| `smoke` | Schnelle Basis-Tests | `fast`, `critical` |

### 7.5 Unterstützte Frameworks

| Framework | External-Name | Beschreibung |
|-----------|---------------|--------------|
| `doctest` | `doctest` | Schnell, Header-only, ideal für Unit Tests |
| `googletest` | `googletest` | Feature-reich, Mocking (GMock) |
| `catch2` | `catch2` | BDD-Style, Sections, Benchmarks |

### 7.6 Path Convention

Wenn `path` nicht angegeben:

```
projects/tests/{type}/{name}/src
```

**Beispiele:**

| name | type | Resultat |
|------|------|----------|
| `CoreLib_Tests` | `unit` | `projects/tests/unit/CoreLib_Tests/src` |
| `Pipeline_Tests` | `integration` | `projects/tests/integration/Pipeline_Tests/src` |

### 7.7 source_from (Executable-Sources testen)

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

**Verhalten:**
- Sources werden aus dem Executable-Pfad übernommen
- `exclude_sources` filtert Dateien aus (Pattern-Match)
- Test-eigene Sources (aus `path`) werden hinzugefügt
- Includes werden automatisch gesetzt

**Empfehlung:** Besser ist es, testbare Module in eine interne Library zu extrahieren.

### 7.8 CTest-Integration

Tests werden automatisch bei CTest registriert:

```bash
# Alle Tests ausführen
ctest --test-dir build

# Nach Label filtern
ctest -L unit        # Nur Unit Tests
ctest -L fast        # Nur schnelle Tests
ctest -LE slow       # Keine langsamen Tests

# Nach Name filtern
ctest -R CoreLib     # Pattern-Match

# Parallel ausführen
ctest -j8            # 8 parallele Jobs
```

### 7.9 Beispiele

**Unit Test mit Library:**
```json
{
    "name": "CoreLib_UnitTests",
    "type": "unit",
    "framework": "doctest",
    "dependencies": ["CoreLib"],
    "externals": ["doctest"],
    "labels": ["unit", "fast"],
    "timeout": 30
}
```

**Integration Test:**
```json
{
    "name": "AudioPipeline_IntegrationTests",
    "type": "integration",
    "framework": "catch2",
    "dependencies": ["CoreLib", "AudioEngine"],
    "externals": ["catch2", "bass"],
    "external_options": {
        "bass": { "BASS_FLAC": true }
    },
    "labels": ["integration", "audio", "slow"],
    "timeout": 120,
    "parallel": false
}
```

**Executable-Module testen:**
```json
{
    "name": "MyApp_ModuleTests",
    "type": "unit",
    "framework": "doctest",
    "source_from": "MyApp",
    "exclude_sources": ["main.cpp"],
    "externals": ["doctest"],
    "labels": ["unit"]
}
```

---

## 8. Vollständiges Beispiel

```json
{
    "schemaVersion": "0.1",
    "solution": {
        "name": "MyProject",
        "version": "1.0.0",
        "description": "Example project with Qt6 and Tests"
    },
    "settings": {
        "standards": {
            "cxx_standard": 20
        },
        "defaults": {
            "library_type": "STATIC",
            "executable_type": "CONSOLE"
        },
        "sources": {
            "mode": "auto"
        }
    },
    "externals": {
        "bass": {
            "path": "externals/bass"
        },
        "doctest": {
            "path": "externals/doctest"
        },
        "glfw": {
            "git": "https://github.com/glfw/glfw.git",
            "tag": "3.4"
        },
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
        },
        "googletest": {
            "git": "https://github.com/google/googletest.git",
            "tag": "v1.14.0"
        },
        "catch2": {
            "git": "https://github.com/catchorg/Catch2.git",
            "tag": "v3.5.2"
        },
        "qt6": {
            "path": "externals/qt6",
            "options": {
                "hint": "${QT_ROOT}",
                "backup": "E:/Backup/Qt/6.10.1/msvc2022_64",
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
        },
        {
            "name": "AudioEngine",
            "version": "1.0.0",
            "type": "STATIC",
            "path": "projects/libs/AudioEngine/src",
            "public_headers": "projects/libs/AudioEngine/include",
            "dependencies": ["CoreLib"]
        }
    ],
    "executables": [
        {
            "name": "ConsoleApp",
            "displayName": "Console Demo",
            "version": "1.0.0",
            "type": "CONSOLE",
            "path": "projects/apps/ConsoleApp/src",
            "dependencies": ["CoreLib"],
            "externals": ["bass"],
            "external_options": {
                "bass": { "BASS_FLAC": true }
            }
        },
        {
            "name": "ImGuiApp",
            "displayName": "ImGui Demo",
            "version": "1.0.0",
            "type": "GUI",
            "path": "projects/apps/ImGuiApp/src",
            "externals": ["glfw", "imgui_docking"]
        },
        {
            "name": "QtApp",
            "displayName": "Qt6 Demo",
            "version": "1.0.0",
            "type": "GUI",
            "path": "projects/apps/QtApp/src",
            "externals": ["qt6"]
        }
    ],
    "tests": [
        {
            "name": "CoreLib_UnitTests",
            "displayName": "CoreLib Unit Tests",
            "type": "unit",
            "framework": "doctest",
            "dependencies": ["CoreLib"],
            "externals": ["doctest"],
            "labels": ["unit", "core", "fast"],
            "timeout": 30
        },
        {
            "name": "AudioEngine_UnitTests",
            "displayName": "AudioEngine Unit Tests",
            "type": "unit",
            "framework": "googletest",
            "dependencies": ["AudioEngine"],
            "externals": ["googletest"],
            "labels": ["unit", "audio"],
            "timeout": 60
        },
        {
            "name": "Integration_Tests",
            "displayName": "Integration Tests",
            "type": "integration",
            "framework": "catch2",
            "dependencies": ["CoreLib", "AudioEngine"],
            "externals": ["catch2"],
            "labels": ["integration", "slow"],
            "timeout": 120,
            "parallel": false
        }
    ]
}
```

---

## 9. Fehler-Codes

### External-bezogene Fehler

| Code | Beschreibung |
|------|--------------|
| E010 | External nicht in externals Block definiert |
| E012 | External hat weder path noch git Feld |
| E213 | Include.cmake für lokales External nicht gefunden |
| E216 | PostFetch Hook fehlt (cmakeSupport: false) |
| E218 | Hook-Datei nicht gefunden |
| E220 | Target nach Hook nicht registriert |

### Test-bezogene Fehler

| Code | Beschreibung |
|------|--------------|
| E301 | Unbekanntes Test-Framework |
| E302 | source_from Executable existiert nicht |
| E303 | Test-Source-Verzeichnis nicht gefunden |

### Warnungen

| Code | Beschreibung |
|------|--------------|
| W302 | Hook-Wiederverwendung aktiv |

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.4** | **2025-12-12** | **tests Array dokumentiert: Typen, Frameworks, source_from, CTest** |
| 0.1.3 | 2025-12-11 | System Externals: options Feld (hint, backup, components) |
| 0.1.2 | 2025-12-10 | Hook-Wiederverwendung (hook Feld) |
| 0.1.1 | 2025-12-09 | Git Externals (git, tag, cmakeSupport) |
| 0.1.0 | 2025-12-05 | Initial Schema |
