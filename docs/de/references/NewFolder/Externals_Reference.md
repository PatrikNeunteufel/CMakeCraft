# Externals — Lokale Bibliotheken Referenz

> **Version:** 0.5.0  
> **Datum:** 2025-12-15  
> **Typ:** Reference  
> **Status:** Aktiv  
> **Basiert auf:** Reference v0.5, Doc v0.5  
> **Zielgruppe:** Build-System-Entwickler, Projekt-Maintainer  
> **Sprache:** Deutsch  
> **English:** [Externals_Reference.md](../../en/reference/Externals_Reference.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Architektur](#2-architektur)
3. [Verzeichnisstruktur](#3-verzeichnisstruktur)
4. [BASS Audio Library](#4-bass-audio-library)
5. [Lua 5.4](#5-lua-54)
6. [doctest](#6-doctest)
7. [GLAD (OpenGL Loader)](#7-glad-opengl-loader)
8. [Qt6 (Fetch-Helper)](#8-qt6-fetch-helper)
9. [Include.cmake Convention](#9-includecmake-convention)
10. [Solution.json Konfiguration](#10-solutionjson-konfiguration)
11. [Neue Externals hinzufügen](#11-neue-externals-hinzufügen)
12. [Changelog](#12-changelog)

---

## 1. Übersicht

Dieses Dokument beschreibt die Verzeichnisstrukturen für lokale Externals und wie die `Include.cmake` Dateien zu den Library-Dateien navigieren.

### Zwei Arten von Externals

| Typ | Beschreibung | Beispiele |
|-----|--------------|-----------|
| **Lokale Externals** | Manuell heruntergeladene Libraries im `externals/` Ordner | BASS, Lua, doctest, GLAD |
| **Fetched Externals** | Automatisch via Git heruntergeladen nach `.externals/` | spdlog, glfw, imgui |

### Lizenz-Separation

Aus Lizenzgründen werden CMake-Code und Library-Dateien getrennt:

```
project-root/
├── cmake/externals/Includes/     ← CMake Code (IN Git)
│   ├── bass/Include.cmake
│   ├── lua54/Include.cmake
│   └── ...
│
└── externals/                    ← Library-Dateien (NICHT in Git)
    ├── bass/
    ├── lua54/
    └── ...
```

---

## 2. Architektur

### Convention over Configuration

**Default Include-Pfad:**

```
cmake/externals/Includes/{name}/Include.cmake
```

Wobei `{name}` der External-Name aus der Solution.json ist.

**Beispiele:**
- `"bass": {...}` → `cmake/externals/Includes/bass/Include.cmake`
- `"lua54": {...}` → `cmake/externals/Includes/lua54/Include.cmake`

### Navigations-Prinzip

```
cmake/externals/Includes/bass/Include.cmake
            │
            │  EXTERNAL_ROOT = ${CMAKE_SOURCE_DIR}/externals/bass
            │
            ▼
externals/bass/bass24/win/c/bass.h
externals/bass/bass24/win/c/x64/bass.lib
externals/bass/bass24/win/x64/bass.dll
```

### Variablen vom Orchestrator

| Variable | Beschreibung | Beispiel |
|----------|--------------|----------|
| `EXTERNAL_NAME` | Name des Externals | `"bass"` |
| `EXTERNAL_ROOT` | Absoluter Pfad zum External | `"C:/Project/externals/bass"` |
| `EXTERNAL_OPTIONS` | JSON mit target-spezifischen Optionen | `{"BASS_FLAC": true}` |
| `EXECUTABLE_NAME` | Target das konfiguriert wird | `"MyApp"` |

---

## 3. Verzeichnisstruktur

### Gesamtübersicht

```
project-root/
│
├── cmake/
│   └── externals/
│       └── Includes/                 ← Include.cmake Dateien (IN Git)
│           ├── bass/
│           │   └── Include.cmake
│           ├── lua54/
│           │   └── Include.cmake
│           ├── doctest/
│           │   └── Include.cmake
│           ├── glad/
│           │   └── Include.cmake
│           └── qt6/
│               └── Include.cmake     ← SONDERFALL: Fetch-Helper
│
├── externals/                        ← Library-Dateien (NICHT in Git)
│   ├── bass/                         ← BASS Audio (proprietär)
│   │   ├── bass24/
│   │   ├── bass_fx24/
│   │   └── ...
│   ├── lua54/                        ← Lua Scripting
│   ├── doctest/                      ← Testing Framework
│   └── glad/                         ← OpenGL Loader
│
└── .externals/                       ← Fetched Externals (Git-ignoriert)
    ├── spdlog/
    ├── glfw/
    └── imgui/
```

### .gitignore Konfiguration

```gitignore
# Lokale Externals (proprietär, nicht in Git)
/externals/bass/
/externals/lua54/
/externals/glad/

# Fetched Externals (auto-download)
/.externals/

# Include.cmake IST in Git (in cmake/)
# cmake/externals/Includes/** → WIRD COMMITED
```

---

## 4. BASS Audio Library

### Übersicht

| Eigenschaft | Wert |
|-------------|------|
| **Typ** | Proprietär (Lizenz erforderlich für kommerzielle Nutzung) |
| **Website** | [un4seen.com](https://www.un4seen.com/bass.html) |
| **Struktur** | Multi-Plugin Architektur |

### Verzeichnisstruktur

```
externals/bass/
├── bass24/                           ← Core Library (PFLICHT)
│   ├── win/
│   │   ├── c/
│   │   │   ├── bass.h                # C Header
│   │   │   ├── bass.lib              # x86 Import Library
│   │   │   └── x64/
│   │   │       └── bass.lib          # x64 Import Library
│   │   ├── bass.dll                  # x86 DLL
│   │   └── x64/
│   │       └── bass.dll              # x64 DLL
│   ├── linux/
│   │   ├── bass.h
│   │   └── libs/
│   │       └── x86_64/libbass.so
│   └── osx/
│       ├── c/bass.h
│       └── libbass.dylib
│
├── bass_fx24/                        ← Effects Plugin
├── bassflac24/                       ← FLAC Decoder Plugin
├── bassopus24/                       ← Opus Codec Plugin
├── bassmidi24/                       ← MIDI Plugin
├── bassmix24/                        ← Mixer Plugin
├── bassenc24/                        ← Encoding Base
└── ...                               ← Weitere Plugins
```

### Solution.json Beispiel

```json
{
    "externals": {
        "bass": {
            "path": "externals/bass",
            "version": "2.4.17"
        }
    },
    "executables": [{
        "name": "AudioPlayer",
        "externals": ["bass"],
        "external_options": {
            "bass": {
                "BASS_FLAC": true,
                "BASS_FX": true,
                "BASS_MIX": true
            }
        }
    }]
}
```

> **Hinweis:** Kein `include` Feld nötig — Convention: `cmake/externals/Includes/bass/Include.cmake`

---

## 5. Lua 5.4

### Verzeichnisstruktur

```
externals/lua54/
├── win/
│   ├── include/
│   │   ├── lua.h
│   │   ├── lualib.h
│   │   ├── lauxlib.h
│   │   └── luaconf.h
│   ├── lib/
│   │   └── lua54.lib
│   └── bin/
│       └── lua54.dll
│
└── linux/
    ├── include/
    │   └── [gleiche Header]
    └── lib/
        ├── liblua54.a
        └── liblua54.so
```

### Solution.json Beispiel

```json
{
    "externals": {
        "lua54": {
            "path": "externals/lua54",
            "version": "5.4.6"
        }
    },
    "executables": [{
        "name": "ScriptHost",
        "externals": ["lua54"],
        "external_options": {
            "lua54": {
                "LUA_EMBEDDED": true
            }
        }
    }]
}
```

> **Include.cmake Convention:** `cmake/externals/Includes/lua54/Include.cmake`

---

## 6. doctest

### Verzeichnisstruktur

```
externals/doctest/
└── doctest.h                  # Einzige Datei (Header-Only)
```

### Solution.json Beispiel

```json
{
    "externals": {
        "doctest": {
            "path": "externals/doctest",
            "version": "2.4.11"
        }
    }
}
```

---

## 7. GLAD (OpenGL Loader)

### Verzeichnisstruktur

```
externals/glad/
├── include/
│   ├── glad/
│   │   └── glad.h
│   └── KHR/
│       └── khrplatform.h
└── src/
    └── glad.c
```

### GLAD generieren

1. Besuche [glad.dav1d.de](https://glad.dav1d.de/)
2. Einstellungen: Language C/C++, Specification OpenGL, Profile Core, API gl 3.3+
3. Download und in `externals/glad/` entpacken

### Solution.json Beispiel

```json
{
    "externals": {
        "glad": {
            "path": "externals/glad"
        }
    }
}
```

---

## 8. Qt6 (Fetch-Helper)

### ⚠️ SONDERFALL

Qt6 ist **kein lokales External** mit Library-Dateien. Es ist ein **Fetch-Helper**, der Qt6 auf dem System findet.

### Verzeichnisstruktur

```
externals/qt6/
└── (LEER!)                    ← Keine Dateien hier!
```

**Die Include.cmake sucht Qt6 an:**
1. `QT_ROOT` Environment Variable
2. `QT6_DIR` Environment Variable
3. `CMAKE_PREFIX_PATH`
4. Solution.json `hint` Feld
5. Standard-Installationspfade
6. Solution.json `backup` Feld (Fallback)

### Solution.json Beispiel

```json
{
    "externals": {
        "qt6": {
            "path": "externals/qt6",
            "options": {
                "components": ["Core", "Widgets", "Gui", "OpenGL"],
                "hint": "${QT_ROOT}",
                "backup": "E:/Backup/Qt/6.7.0/msvc2022_64"
            }
        }
    }
}
```

### Qt6 Installation

```bash
# Windows (nach Qt Online Installer)
set QT_ROOT=C:\Qt\6.7.0\msvc2022_64

# Linux
export QT_ROOT=$HOME/Qt/6.7.0/gcc_64
```

---

## 9. Include.cmake Convention

### Default-Pfad

```
cmake/externals/Includes/{name}/Include.cmake
```

| External-Name | Include.cmake Pfad |
|---------------|-------------------|
| `bass` | `cmake/externals/Includes/bass/Include.cmake` |
| `lua54` | `cmake/externals/Includes/lua54/Include.cmake` |
| `doctest` | `cmake/externals/Includes/doctest/Include.cmake` |
| `glad` | `cmake/externals/Includes/glad/Include.cmake` |
| `qt6` | `cmake/externals/Includes/qt6/Include.cmake` |

### Custom Include Path (optional)

Nur wenn vom Default abgewichen werden muss:

```json
{
    "mylib": {
        "path": "externals/mylib",
        "include": "cmake/custom/mylib_special.cmake"
    }
}
```

---

## 10. Solution.json Konfiguration

### Vollständiges Beispiel

```json
{
    "project": "MyApplication",
    "version": "1.0.0",
    
    "externals": {
        "bass": {
            "path": "externals/bass",
            "version": "2.4.17"
        },
        "lua54": {
            "path": "externals/lua54",
            "version": "5.4.6"
        },
        "doctest": {
            "path": "externals/doctest"
        },
        "glad": {
            "path": "externals/glad"
        },
        "qt6": {
            "path": "externals/qt6",
            "options": {
                "components": ["Core", "Widgets", "Gui"]
            }
        },
        "spdlog": {
            "git": "https://github.com/gabime/spdlog.git",
            "tag": "v1.12.0"
        }
    },
    
    "executables": [
        {
            "name": "MainApp",
            "externals": ["bass", "lua54", "glad", "qt6"],
            "external_options": {
                "bass": {
                    "BASS_FLAC": true,
                    "BASS_FX": true
                },
                "lua54": {
                    "LUA_EMBEDDED": true
                }
            }
        }
    ]
}
```

> **Hinweis:** Kein `include` Feld nötig — alle verwenden den Default Convention Path.

---

## 11. Neue Externals hinzufügen

### Schritt-für-Schritt

1. **Library herunterladen** und in `externals/mylib/` entpacken

2. **Include.cmake erstellen** in `cmake/externals/Includes/mylib/Include.cmake`:

```cmake
# cmake/externals/Includes/mylib/Include.cmake

message(STATUS "[${EXTERNAL_NAME}] Attaching to ${EXECUTABLE_NAME}")

set(_lib_root "${EXTERNAL_ROOT}")

if(WIN32)
    target_include_directories(${EXECUTABLE_NAME} PRIVATE
        "${_lib_root}/include"
    )
    target_link_libraries(${EXECUTABLE_NAME} PRIVATE
        "${_lib_root}/lib/mylib.lib"
    )
elseif(UNIX)
    target_include_directories(${EXECUTABLE_NAME} PRIVATE
        "${_lib_root}/include"
    )
    target_link_libraries(${EXECUTABLE_NAME} PRIVATE
        "${_lib_root}/lib/libmylib.so"
    )
endif()

message(STATUS "[${EXTERNAL_NAME}] Integration complete")
```

3. **Solution.json aktualisieren**:

```json
{
    "externals": {
        "mylib": {
            "path": "externals/mylib",
            "version": "1.0.0"
        }
    }
}
```

4. **.gitignore aktualisieren**:

```gitignore
/externals/mylib/
```

---

## 12. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-15** | **Initial: Externals-Referenz mit Convention-over-Configuration** |
