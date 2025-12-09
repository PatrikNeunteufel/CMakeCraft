# Solution Schema – CMake Architecture V2

> **Version:** 0.1.0  
> **Datum:** 2025-12-03  
> **Typ:** Referenz-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/References/Solution_Schema_v0_1_0.md)

Diese Dokumentation beschreibt das vollständige Schema der Solution.json für das CMake Architecture V2 Build-System.

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

### Schema-Versionierung

Die `schemaVersion` verwendet **nur MAJOR.MINOR** (z.B. `"0.1"`), kein PATCH:

| Änderung | Auswirkung |
|----------|------------|
| Neues Feld hinzugefügt | MINOR ↑ |
| Feld entfernt/umbenannt | MAJOR ↑ |
| Feld-Typ geändert | MAJOR ↑ |
| Neuer Executable/Library/External | ❌ Keine Schema-Änderung |
| Andere Tag-Version bei External | ❌ Keine Schema-Änderung |
| Werte in bestehenden Feldern | ❌ Keine Schema-Änderung |

**Begründung:** Das Schema definiert die *Struktur*, nicht den *Inhalt*. Parameter-Änderungen innerhalb der definierten Struktur betreffen das Schema nicht.
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
| `version` | ❌ | Version (SemVer empfohlen) |
| `description` | ❌ | Beschreibung |
| `authors` | ❌ | Autorenliste |

---

## 3. settings Block

```json
"settings": {
    "standards": {
        "cxx_standard": 20,
        "c_standard": 17
    },
    "defaults": {
        "executable_type": "CONSOLE",
        "library_type": "STATIC"
    },
    "sources": {
        "mode": "explicit"
    }
}
```

### standards

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `cxx_standard` | 20 | C++ Standard (11, 14, 17, 20, 23) |
| `c_standard` | 17 | C Standard (99, 11, 17) |

### defaults

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `executable_type` | "CONSOLE" | GUI, CONSOLE, CLI, HEADLESS, WORKER |
| `library_type` | "STATIC" | STATIC, SHARED, INTERFACE |

### sources

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `mode` | "explicit" | explicit, glob, auto |

---

## 4. externalsPolicy Block

```json
"externalsPolicy": {
    "cacheRoot": "externals/_cache",
    "sourceRoot": "externals/_src",
    "updatePolicy": "checkout",
    "lockfile": true
}
```

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `cacheRoot` | "externals/_cache" | Build-Cache |
| `sourceRoot` | "externals/_src" | Source-Verzeichnis |
| `updatePolicy` | "checkout" | checkout, fetch, always, never |
| `lockfile` | false | Lockfile erstellen |

---

## 5. externals Block

### Lokales External

```json
"externals": {
    "bass": {
        "path": "externals/bass"
    }
}
```

| Feld | Pflicht | Beschreibung |
|------|---------|--------------|
| `path` | ✅ | Relativer Pfad |
| `include` | ❌ | Override für Include.cmake |

### Fetched External

```json
"externals": {
    "spdlog": {
        "git": "https://github.com/gabime/spdlog.git",
        "tag": "v1.12.0"
    }
}
```

| Feld | Pflicht | Beschreibung |
|------|---------|--------------|
| `git` | ✅ | Repository URL |
| `tag` | ❌* | Git-Tag |
| `branch` | ❌* | Git-Branch |
| `commit` | ❌* | Commit-Hash |
| `shallow` | ❌ | Shallow Clone |
| `cmake_args` | ❌ | Extra CMake-Argumente |
| `hooks` | ❌ | Pre/PostFetch Hooks |

*Genau eines von `tag`, `branch`, `commit` erforderlich.

### Hooks

```json
"externals": {
    "imgui": {
        "git": "...",
        "tag": "v1.90.1",
        "hooks": {
            "preFetch": "cmake/externals/Hooks/PreFetch/imgui.cmake",
            "postFetch": "cmake/externals/Hooks/PostFetch/imgui.cmake"
        }
    }
}
```

---

## 6. libraries Block

```json
"libraries": [
    {
        "name": "CoreLib",
        "version": "1.0.0",
        "path": "projects/libs/Core/src",
        "type": "STATIC",
        "public_headers": "projects/libs/Core/include",
        "dependencies": [],
        "externals": []
    }
]
```

| Feld | Pflicht | Default | Beschreibung |
|------|---------|---------|--------------|
| `name` | ✅ | - | Eindeutiger Name |
| `version` | ❌ | - | SemVer Version |
| `path` | ❌ | `projects/libs/${name}/src` | Source-Pfad |
| `type` | ❌ | settings.defaults | STATIC, SHARED, INTERFACE |
| `public_headers` | ❌ | - | Öffentliche Header |
| `dependencies` | ❌ | [] | Interne Abhängigkeiten |
| `externals` | ❌ | [] | Externe Abhängigkeiten |
| `skip` | ❌ | false | Überspringen |

---

## 7. executables Block

```json
"executables": [
    {
        "name": "MyApp",
        "displayName": "My Application",
        "version": "1.0.0",
        "path": "projects/exec/MyApp/src",
        "type": "GUI",
        "dependencies": ["CoreLib"],
        "externals": ["imgui", "bass"],
        "pch": {
            "enabled": true,
            "header": "pch.h"
        }
    }
]
```

| Feld | Pflicht | Default | Beschreibung |
|------|---------|---------|--------------|
| `name` | ✅ | - | Eindeutiger Name |
| `displayName` | ❌ | name | Anzeigename |
| `description` | ❌ | - | Beschreibung |
| `version` | ❌ | - | SemVer Version |
| `path` | ❌ | `projects/exec/${name}/src` | Source-Pfad |
| `type` | ❌ | settings.defaults | GUI, CONSOLE, CLI, HEADLESS, WORKER |
| `dependencies` | ❌ | [] | Interne Libraries |
| `externals` | ❌ | [] | Externe Abhängigkeiten |
| `external_options` | ❌ | {} | Per-External Optionen |
| `pch` | ❌ | - | Precompiled Header |
| `platforms` | ❌ | alle | windows, linux, macos |
| `skip` | ❌ | false | Überspringen |

### pch Block

```json
"pch": {
    "enabled": true,
    "header": "pch.h",
    "path": "projects/exec/MyApp/src"
}
```

### external_options

```json
"external_options": {
    "bass": {
        "BASS_FLAC": true,
        "BASS_OPUS": true
    }
}
```

---

## 8. tests Block

```json
"tests": [
    {
        "name": "UnitTests",
        "path": "projects/tests/Unit/src",
        "type": "UNIT",
        "dependencies": ["CoreLib"],
        "externals": ["doctest"],
        "framework": "doctest",
        "parallel": true,
        "timeout": 60,
        "labels": ["unit", "fast"]
    }
]
```

| Feld | Pflicht | Default | Beschreibung |
|------|---------|---------|--------------|
| `name` | ✅ | - | Eindeutiger Name |
| `path` | ❌ | `projects/tests/${name}/src` | Source-Pfad |
| `type` | ❌ | UNIT | UNIT, INTEGRATION, SYSTEM, PERFORMANCE |
| `dependencies` | ❌ | [] | Zu testende Libraries |
| `externals` | ❌ | [] | Test-Framework etc. |
| `framework` | ❌ | auto | doctest, gtest, catch2, boost_test |
| `parallel` | ❌ | true | Parallel ausführbar |
| `timeout` | ❌ | type-abhängig | Timeout in Sekunden |
| `labels` | ❌ | [] | CTest Labels |

### Framework Auto-Detection Priorität

1. Explizites `framework` Feld
2. `gtest` / `googletest` in externals
3. `catch2` / `catch` in externals
4. `doctest` in externals
5. `boost_test` in externals
6. `custom`

### Timeout-Defaults nach Type

| Type | Default Timeout |
|------|-----------------|
| UNIT | 30s |
| INTEGRATION | 120s |
| SYSTEM | 300s |
| PERFORMANCE | 600s |

---

## 9. Schnellreferenz: Error Codes

| Code | Beschreibung |
|------|--------------|
| E001 | Pflichtfeld fehlt |
| E002 | Solution.json nicht gefunden |
| E010 | External nicht definiert |
| E012 | Kein/mehrere Source-Felder |
| E101 | Abhängigkeit existiert nicht |
| E102 | Target existiert bereits |
| E103 | Zirkuläre Abhängigkeit |
| E104 | Source.cmake nicht gefunden |
| E215 | Kein tag/branch/commit |
| E216 | Hook nicht gefunden |
| W001 | Veraltetes Schema |
| W105 | Version nicht SemVer |
| W106 | Keine Version |
| W107 | Settings Override |

---

## 10. Vollständiges Beispiel

```json
{
    "schemaVersion": "0.1",
    "solution": {
        "name": "AudioSuite",
        "version": "2.0.0",
        "description": "Audio Processing Suite",
        "authors": ["Audio Team"]
    },
    "settings": {
        "standards": {
            "cxx_standard": 20
        },
        "sources": {
            "mode": "explicit"
        }
    },
    "externals": {
        "bass": {
            "path": "externals/bass"
        },
        "spdlog": {
            "git": "https://github.com/gabime/spdlog.git",
            "tag": "v1.12.0"
        },
        "doctest": {
            "path": "externals/doctest"
        }
    },
    "libraries": [
        {
            "name": "CoreLib",
            "version": "1.0.0",
            "path": "projects/libs/Core/src"
        }
    ],
    "executables": [
        {
            "name": "AudioPlayer",
            "version": "2.0.0",
            "type": "GUI",
            "dependencies": ["CoreLib"],
            "externals": ["bass", "spdlog"],
            "pch": { "enabled": true }
        }
    ],
    "tests": [
        {
            "name": "CoreTests",
            "dependencies": ["CoreLib"],
            "externals": ["doctest"]
        }
    ]
}
```

---

## 11. Siehe auch

- [master_concept](../Concepts/master_concept_v0_1_0.md) – Architektur
- [guidelines](../Concepts/guidelines_v0_1_0.md) – Konventionen
- [ErrorCodes](ErrorCodes_v0_1_0.md) – Fehlercodes
- [Json.cmake](../Modules/Json_cmake_v0_1_0_doc_v1.md) – JSON-Parsing

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-03** | **Initial (Clean Start): Schema aus v1.2 übernommen, sources.mode hinzugefügt, Schema-Versionierung (nur MAJOR.MINOR) dokumentiert, Blueprint-Format** |
