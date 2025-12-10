# Solution Schema – CMake Architecture V2

> **Version:** 0.1.1  
> **Datum:** 2025-12-09  
> **Typ:** Referenz-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/References/Solution_Schema_v0_1_1.md)

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

## 4. externals Block

### 4.1 Lokales External

```json
"externals": {
    "bass": {
        "path": "externals/bass"
    }
}
```

| Feld | Pflicht | Beschreibung |
|------|---------|--------------|
| `path` | ✅ | Relativer Pfad zum External |
| `include` | ❌ | Override für Include.cmake Pfad |

### 4.2 Fetched External (Git)

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
| `cmakeSupport` | ❌ | Hat CMakeLists.txt (default: true) |
| `preFetchHook` | ❌ | Expliziter PreFetch Hook Pfad |
| `postFetchHook` | ❌ | Expliziter PostFetch Hook Pfad |

*Genau eines von `tag`, `branch`, `commit` erforderlich.

### 4.3 cmakeSupport Flag

| Wert | Bedeutung | Hook-Anforderung |
|------|-----------|------------------|
| `true` (default) | External hat CMakeLists.txt | PostFetch optional |
| `false` | Kein CMakeLists.txt | PostFetch **PFLICHT** |

**Beispiel ohne CMake-Support:**
```json
"externals": {
    "imgui": {
        "git": "https://github.com/ocornut/imgui.git",
        "tag": "v1.90.1",
        "cmakeSupport": false
    }
}
```

### 4.4 Hook-Konvention

**Standard-Pfade (automatisch gefunden):**
```
cmake/externals/Hooks/PreFetch/${name}.cmake
cmake/externals/Hooks/PostFetch/${name}.cmake
```

**Explizite Pfade:**
```json
"externals": {
    "mylib": {
        "git": "...",
        "preFetchHook": "cmake/custom/mylib_pre.cmake",
        "postFetchHook": "cmake/custom/mylib_post.cmake"
    }
}
```

---

## 5. libraries Block

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

## 6. executables Block

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

### type und APP_WINDOWS_GUI

Bei `type: "GUI"` auf Windows:
- `WIN32` Flag wird gesetzt (kein Console-Fenster)
- `APP_WINDOWS_GUI` Compile-Definition wird gesetzt

```cpp
#ifdef APP_WINDOWS_GUI
#include <Windows.h>
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int) {
    return main(__argc, __argv);
}
#endif
```

---

## 7. tests Block

```json
"tests": [
    {
        "name": "UnitTests",
        "path": "projects/tests/Unit/src",
        "type": "UNIT",
        "dependencies": ["CoreLib"],
        "externals": ["doctest"],
        "framework": "doctest"
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

---

## 8. Vollständiges Beispiel (GUI App)

```json
{
    "schemaVersion": "0.1",
    "solution": {
        "name": "ImGuiDemo",
        "version": "1.0.0"
    },
    "settings": {
        "standards": {
            "cxx_standard": 20
        }
    },
    "externals": {
        "glad": {
            "path": "externals/glad"
        },
        "glfw": {
            "git": "https://github.com/glfw/glfw.git",
            "tag": "3.4"
        },
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.90.1",
            "cmakeSupport": false
        },
        "doctest": {
            "path": "externals/doctest"
        }
    },
    "executables": [
        {
            "name": "imGuiApp",
            "path": "src/imGuiApp",
            "type": "GUI",
            "externals": ["glad", "glfw", "imgui"]
        }
    ],
    "tests": [
        {
            "name": "AppTests",
            "externals": ["doctest"]
        }
    ]
}
```

---

## 9. Schnellreferenz: Error Codes

| Code | Beschreibung |
|------|--------------|
| E001 | Pflichtfeld fehlt |
| E002 | Solution.json nicht gefunden |
| E010 | External nicht definiert |
| E012 | Kein/mehrere Source-Felder |
| E201 | Fetched External: kein Target |
| E215 | Kein tag/branch/commit |
| E216 | Hook nicht gefunden |
| E217 | PostFetch Hook erforderlich (cmakeSupport=false) |

---

## 10. Siehe auch

- [Externals](Externals_v0_2_0.md) – External-Referenz
- [ErrorCodes](ErrorCodes_v0_1_1.md) – Fehlercodes
- [Externals_UserGuide](../UserGuides/Externals_UserGuide_v0_2_0.md) – Verwendung

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.1** | **2025-12-09** | **Externals: cmakeSupport, preFetchHook, postFetchHook Felder, Hook-Konvention, APP_WINDOWS_GUI** |
| 0.1.0 | 2025-12-03 | Initial (Clean Start): Schema aus v1.2 |
