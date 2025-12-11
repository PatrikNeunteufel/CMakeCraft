# Solution Schema – CMake Architecture V2

> **Version:** 0.1.3  
> **Datum:** 2025-12-11  
> **Typ:** Referenz-Doku  
> **Status:** Stabil  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch

Diese Dokumentation beschreibt das vollständige Schema der Solution.json für das CMake Architecture V2 Build-System.

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

### 4.4 System Externals (NEU in v0.1.3)

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

## 7. Vollständiges Beispiel

```json
{
    "schemaVersion": "0.1",
    "solution": {
        "name": "MyProject",
        "version": "1.0.0",
        "description": "Example project with Qt6"
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
    ]
}
```

---

## 8. Fehler-Codes

### External-bezogene Fehler

| Code | Beschreibung |
|------|--------------|
| E010 | External nicht in externals Block definiert |
| E012 | External hat weder path noch git Feld |
| E213 | Include.cmake für lokales External nicht gefunden |
| E216 | PostFetch Hook fehlt (cmakeSupport: false) |
| E218 | Hook-Datei nicht gefunden |
| E220 | Target nach Hook nicht registriert |

### Warnungen

| Code | Beschreibung |
|------|--------------|
| W302 | Hook-Wiederverwendung aktiv |

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.3** | **2025-12-11** | **System Externals: options Feld (hint, backup, components)** |
| 0.1.2 | 2025-12-10 | Hook-Wiederverwendung (hook Feld) |
| 0.1.1 | 2025-12-09 | Git Externals (git, tag, cmakeSupport) |
| 0.1.0 | 2025-12-05 | Initial Schema |
