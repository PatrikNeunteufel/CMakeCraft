# Externals — Referenz

> **Version:** 0.5.0  
> **Datum:** 2025-12-14  
> **Typ:** Reference  
> **Status:** Stabil  
> **Zielgruppe:** Alle Entwickler  
> **Sprache:** Deutsch  
> **English:** [Externals.md](../../en/reference/Externals.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Konventionen](#2-konventionen)
3. [Local Externals](#3-local-externals)
4. [Fetched Externals](#4-fetched-externals)
5. [JSON Schema](#5-json-schema)
6. [Schnellreferenz](#6-schnellreferenz)
7. [Verwendung](#7-verwendung)
8. [Fehlerbehandlung](#8-fehlerbehandlung)
9. [Siehe auch](#9-siehe-auch)
10. [Changelog](#10-changelog)

---

## 1. Übersicht

Diese Referenz dokumentiert alle verfügbaren External Libraries für das CMake Architecture V2 Build-System mit ihren Konfigurationsoptionen.

### External-Typen

| Typ | Quelle | Status | Beispiele |
|-----|--------|--------|-----------|
| **Local** | `path` | ✅ Phase 5 | BASS, Lua, doctest, glad |
| **Fetched** | `git` | ✅ Phase 6 | imgui, glfw, spdlog |

### Grundlegende Verwendung

```json
{
    "externals": {
        "bass": { "path": "externals/bass" },
        "glad": { "path": "externals/glad" },
        "glfw": { 
            "git": "https://github.com/glfw/glfw.git",
            "tag": "3.4"
        },
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.90.1",
            "cmakeSupport": false
        }
    },
    "executables": [
        {
            "name": "MyGuiApp",
            "type": "GUI",
            "externals": ["glad", "glfw", "imgui"]
        }
    ]
}
```

---

## 2. Konventionen

### Symbole

| Symbol | Bedeutung |
|--------|-----------|
| ✅ | Verfügbar/Unterstützt |
| ❌ | Nicht verfügbar |
| 🔧 | Hook erforderlich |

### Hook-Pfade

**Convention (automatisch gefunden):**
- PreFetch: `cmake/externals/Hooks/PreFetch/${name}.cmake`
- PostFetch: `cmake/externals/Hooks/PostFetch/${name}.cmake`

---

## 3. Local Externals

### 3.1 BASS Audio Library

> **Typ:** Local  
> **Pfad:** `externals/bass`  
> **Include.cmake Version:** 0.1.1  
> **Plattformen:** Windows, Linux, macOS

```json
"externals": {
    "bass": { "path": "externals/bass" }
}
```

#### Decoders

| Option | Plugin | Header | Beschreibung |
|--------|--------|--------|--------------|
| `BASS_FLAC` | bassflac24 | `bassflac.h` | FLAC Audio Decoder |
| `BASS_OPUS` | bassopus24 | `bassopus.h` | Opus Audio Decoder |
| `BASS_DSD` | bassdsd24 | `bassdsd.h` | DSD (Direct Stream Digital) |
| `BASS_WV` | basswv24 | `basswv.h` | WavPack Decoder |
| `BASS_APE` | bassape24 | `bass_ape.h` | Monkey's Audio |
| `BASS_MPC` | bass_mpc24 | `bass_mpc.h` | Musepack Decoder |
| `BASS_ALAC` | bassalac24 | `bassalac.h` | Apple Lossless |
| `BASS_TTA` | bass_tta24 | `bass_tta.h` | True Audio |
| `BASS_CD` | basscd24 | `basscd.h` | CD Audio Ripper |
| `BASS_WEBM` | basswebm24 | `basswebm.h` | WebM Container |

#### Encoders

| Option | Plugin | Header | Beschreibung |
|--------|--------|--------|--------------|
| `BASS_ENC` | bassenc24 | `bassenc.h` | Encoding-Basis (Auto-aktiviert) |
| `BASS_ENC_MP3` | bassenc_mp324 | `bassenc_mp3.h` | MP3 Encoder |
| `BASS_ENC_OGG` | bassenc_ogg24 | `bassenc_ogg.h` | OGG Vorbis Encoder |
| `BASS_ENC_FLAC` | bassenc_flac24 | `bassenc_flac.h` | FLAC Encoder |

#### Plugins

| Option | Plugin | Header | Beschreibung |
|--------|--------|--------|--------------|
| `BASS_FX` | bass_fx24 | `bass_fx.h` | DSP Effekte (Tempo, Pitch, Reverb) |
| `BASS_MIX` | bassmix24 | `bassmix.h` | Multi-Channel Mixing |
| `BASS_LOUD` | bassloud24 | `bassloud.h` | Loudness Messung (EBU R128) |
| `BASS_MIDI` | bassmidi24 | `bassmidi.h` | MIDI Playback |

---

### 3.2 Lua 5.4 Scripting Engine

> **Typ:** Local  
> **Pfad:** `externals/lua54`  
> **Include.cmake Version:** 0.1.0  
> **Plattformen:** Windows, Linux, macOS

```json
"externals": {
    "lua54": { "path": "externals/lua54" }
}
```

#### Options

| Option | Typ | Default | Beschreibung |
|--------|-----|---------|--------------|
| `LUA_EMBEDDED` | bool | `true` | Statisch einbetten (empfohlen) |
| `LUA_32BIT_COMPAT` | bool | `false` | 32-Bit Integer-Kompatibilität |
| `LUA_USE_READLINE` | bool | `false` | Readline-Support (nur Linux) |

---

### 3.3 doctest Testing Framework

> **Typ:** Local (Header-Only)  
> **Pfad:** `externals/doctest`  
> **Include.cmake Version:** 0.1.0  
> **Plattformen:** Alle

```json
"externals": {
    "doctest": { "path": "externals/doctest" }
}
```

#### Options

| Option | Typ | Default | Beschreibung |
|--------|-----|---------|--------------|
| `DOCTEST_NO_SHORT_MACRO_NAMES` | bool | `false` | Lange Makronamen |
| `DOCTEST_CONFIG_SUPER_FAST_ASSERTS` | bool | `false` | Schnellere Asserts |
| `DOCTEST_CONFIG_DISABLE` | bool | `false` | doctest deaktivieren |

---

### 3.4 GLAD OpenGL Loader

> **Typ:** Local (Generiert)  
> **Pfad:** `externals/glad`  
> **Include.cmake Version:** 0.1.0  
> **Plattformen:** Alle

```json
"externals": {
    "glad": { "path": "externals/glad" }
}
```

#### Generierung

GLAD muss manuell generiert werden:
1. https://glad.dav1d.de/ öffnen
2. OpenGL Core 3.3+ auswählen
3. ZIP herunterladen
4. Nach `externals/glad/` entpacken

#### Verzeichnisstruktur

```
externals/glad/
├── Include.cmake
├── include/
│   ├── glad/
│   │   └── glad.h
│   └── KHR/
│       └── khrplatform.h
└── src/
    └── glad.c
```

---

## 4. Fetched Externals

### 4.1 GLFW Window Library

> **Typ:** Fetched (Git)  
> **Repository:** https://github.com/glfw/glfw.git  
> **CMake-Support:** ✅ Ja  
> **Hook:** PreFetch (optional)

```json
"externals": {
    "glfw": {
        "git": "https://github.com/glfw/glfw.git",
        "tag": "3.4"
    }
}
```

#### PreFetch Hook (automatisch)

Der Hook `cmake/externals/Hooks/PreFetch/glfw.cmake` deaktiviert:
- GLFW_BUILD_EXAMPLES
- GLFW_BUILD_TESTS
- GLFW_BUILD_DOCS
- GLFW_INSTALL

#### Erstellte Targets

| Target | Beschreibung |
|--------|--------------|
| `glfw` | GLFW Library |

---

### 4.2 Dear ImGui

> **Typ:** Fetched (Git)  
> **Repository:** https://github.com/ocornut/imgui.git  
> **CMake-Support:** ❌ Nein  
> **Hook:** PostFetch (PFLICHT) 🔧

```json
"externals": {
    "imgui": {
        "git": "https://github.com/ocornut/imgui.git",
        "tag": "v1.90.1",
        "cmakeSupport": false
    }
}
```

#### PostFetch Hook

Der Hook `cmake/externals/Hooks/PostFetch/imgui.cmake` erstellt:

| Target | Komponenten |
|--------|-------------|
| `imgui` | Core + OpenGL3 + GLFW + Win32 Backends |

#### Automatisches Linking

Der Hook linkt automatisch:
- `glad` (wenn vorhanden) + `IMGUI_IMPL_OPENGL_LOADER_GLAD` Define
- `glfw` (wenn vorhanden)

#### Reihenfolge in Solution.json

```json
"externals": {
    "glad": { ... },   // 1. zuerst
    "glfw": { ... },   // 2. dann
    "imgui": { ... }   // 3. zuletzt
}
```

---

### 4.3 spdlog Logging Library

> **Typ:** Fetched (Git)  
> **Repository:** https://github.com/gabime/spdlog.git  
> **CMake-Support:** ✅ Ja

```json
"externals": {
    "spdlog": {
        "git": "https://github.com/gabime/spdlog.git",
        "tag": "v1.12.0"
    }
}
```

#### Erstellte Targets

| Target | Beschreibung |
|--------|--------------|
| `spdlog` | Header-Only oder Compiled |
| `spdlog::spdlog` | Alias |

---

## 5. JSON Schema

### 5.1 Lokales External

```json
{
    "name": {
        "path": "string (required)",
        "include": "string (optional)"
    }
}
```

### 5.2 Fetched External

```json
{
    "name": {
        "git": "string (required)",
        "tag": "string (one required)",
        "branch": "string (one required)",
        "commit": "string (one required)",
        "cmakeSupport": "boolean (default: true)",
        "preFetchHook": "string (optional)",
        "postFetchHook": "string (optional)"
    }
}
```

### 5.3 cmakeSupport Flag

| Wert | Bedeutung |
|------|-----------|
| `true` (default) | External hat CMakeLists.txt, erstellt eigene Targets |
| `false` | Kein CMakeLists.txt, PostFetch Hook MUSS Targets erstellen |

---

## 6. Schnellreferenz

### 6.1 Vergleich der Externals

| Feature | BASS | Lua | doctest | glad | glfw | imgui |
|---------|------|-----|---------|------|------|-------|
| **Typ** | Local | Local | Local | Local | Fetched | Fetched |
| **CMake-Support** | – | – | – | – | ✅ | ❌ |
| **Hook nötig** | – | – | – | – | Optional | Pflicht |
| **Hauptverwendung** | Audio | Scripting | Testing | OpenGL | Window | GUI |

### 6.2 Häufige Kombinationen

| Anwendungsfall | Externals |
|----------------|-----------|
| OpenGL GUI App | glad, glfw, imgui |
| Audio Player | bass (+ Decoder-Plugins) |
| Scripted App | lua54 |
| Testing | doctest oder googletest |

---

## 7. Verwendung

### 7.1 GUI-Anwendung Beispiel

```json
{
    "schemaVersion": "0.1",
    "solution": {
        "name": "ImGuiDemo",
        "version": "1.0.0"
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
        }
    },
    "executables": [
        {
            "name": "imGuiApp",
            "path": "src/imGuiApp",
            "type": "GUI",
            "externals": ["glad", "glfw", "imgui"]
        }
    ]
}
```

**Wichtig für Windows GUI:**
- `type: "GUI"` setzt automatisch `APP_WINDOWS_GUI` Define
- Verwende WinMain-Wrapper im Code

### 7.2 External-Options verwenden

```json
"executables": [
    {
        "name": "AudioPlayer",
        "externals": ["bass"],
        "external_options": {
            "bass": { 
                "BASS_FLAC": true,
                "BASS_OPUS": true,
                "BASS_FX": true
            }
        }
    }
]
```

---

## 8. Fehlerbehandlung

| Code | Beschreibung |
|------|--------------|
| E010 | External nicht im externals-Block definiert |
| E012 | Kein/mehrere Source-Felder (path/git) |
| E201 | Fetched External: Keine Targets nach Verarbeitung |
| E202 | Fetch fehlgeschlagen (Netzwerk, URL) |
| E213 | Lokales External: Include.cmake nicht gefunden |
| E214 | Lokales External: Pfad existiert nicht |
| E215 | Fetched External: Kein tag/branch/commit |
| E216 | Explizit definierter Hook nicht gefunden |
| E217 | PostFetch Hook erforderlich (cmakeSupport=false) aber nicht vorhanden |

---

## 9. Siehe auch

- [Solution_Schema.md](Solution_Schema.md) — JSON-Schema
- [Git_Externals_Reference.md](Git_Externals_Reference.md) — Umfangreiche Bibliotheks-Sammlung
- [Externals_UserGuide.md](../guides/Externals_UserGuide.md) — Verwendungsanleitung
- [Orchestrator.cmake](../modules/externals/Orchestrator_cmake.md) — Koordination
- [HookLoader.cmake](../modules/externals/HookLoader_cmake.md) — Hook-System

---

## 10. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-14** | **Blueprint v0.5.0 Format: Nummeriertes TOC, Reference-Header, Schnellreferenz, Verwendung** |
| 0.2.0 | 2025-12-09 | Phase 6: Git Externals (glfw, imgui), Hook-System, cmakeSupport Flag, GUI-Beispiel |
| 0.1.1 | 2025-12-09 | Phase 5: BASS, Lua, doctest mit Options |
| 0.1.0 | 2025-12-03 | Initial (Clean Start) |
