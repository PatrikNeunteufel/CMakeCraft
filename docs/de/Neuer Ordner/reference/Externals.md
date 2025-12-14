# Externals — Referenz

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Reference  
> **Status:** In Entwicklung  
> **Zielgruppe:** Alle Entwickler  
> **Sprache:** Deutsch  
> **English:** [Externals.md](../../en/reference/Externals.md)

Diese Referenz dokumentiert alle verfügbaren External Libraries mit ihren Konfigurationsoptionen.

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Konventionen](#2-konventionen)
3. [Local Externals](#3-local-externals)
4. [Fetched Externals](#4-fetched-externals)
5. [System Externals](#5-system-externals)
6. [Schnellreferenz](#6-schnellreferenz)
7. [Verwendung in Code](#7-verwendung-in-code)
8. [Siehe auch](#8-siehe-auch)

---

## 1. Übersicht

Externals werden zentral im `externals`-Block der Solution.json definiert.

### Typen

| Typ | Erkennungsfeld | Status |
|-----|----------------|--------|
| **Local** | `path` | ✅ Implementiert |
| **Fetched** | `git` | ✅ Implementiert |
| **System** | `system` | 🔄 Phase 9 |

---

## 2. Konventionen

### JSON Schema

**Lokales External:**
```json
{
    "name": {
        "path": "externals/name"
    }
}
```

**Fetched External:**
```json
{
    "name": {
        "git": "https://github.com/...",
        "tag": "v1.0.0",
        "cmakeSupport": true
    }
}
```

**System External (Phase 9):**
```json
{
    "name": {
        "system": true,
        "package": "PackageName",
        "components": ["Core", "Gui"]
    }
}
```

### Hook-Pfade (Convention)

| Typ | Pfad |
|-----|------|
| PreFetch | `cmake/externals/Hooks/PreFetch/${name}.cmake` |
| PostFetch | `cmake/externals/Hooks/PostFetch/${name}.cmake` |

---

## 3. Local Externals

### 3.1 BASS Audio Library

| Aspekt | Wert |
|--------|------|
| **Typ** | Local |
| **Pfad** | `externals/bass` |
| **Include.cmake** | v0.1.1 |
| **Plattformen** | Windows, Linux, macOS |

```json
"bass": { "path": "externals/bass" }
```

#### Decoder Options

| Option | Plugin | Beschreibung |
|--------|--------|--------------|
| `BASS_FLAC` | bassflac24 | FLAC Audio |
| `BASS_OPUS` | bassopus24 | Opus Audio |
| `BASS_DSD` | bassdsd24 | DSD |
| `BASS_WV` | basswv24 | WavPack |
| `BASS_APE` | bassape24 | Monkey's Audio |
| `BASS_MPC` | bass_mpc24 | Musepack |
| `BASS_ALAC` | bassalac24 | Apple Lossless |
| `BASS_TTA` | bass_tta24 | True Audio |
| `BASS_CD` | basscd24 | CD Audio |
| `BASS_WEBM` | basswebm24 | WebM Container |

#### Encoder Options

| Option | Plugin | Beschreibung |
|--------|--------|--------------|
| `BASS_ENC` | bassenc24 | Encoding-Basis |
| `BASS_ENC_MP3` | bassenc_mp324 | MP3 Encoder |
| `BASS_ENC_OGG` | bassenc_ogg24 | OGG Vorbis |
| `BASS_ENC_FLAC` | bassenc_flac24 | FLAC Encoder |

#### Plugin Options

| Option | Plugin | Beschreibung |
|--------|--------|--------------|
| `BASS_FX` | bass_fx24 | DSP Effekte |
| `BASS_MIX` | bassmix24 | Multi-Channel Mixing |
| `BASS_LOUD` | bassloud24 | Loudness (EBU R128) |
| `BASS_MIDI` | bassmidi24 | MIDI Playback |

---

### 3.2 Lua 5.4

| Aspekt | Wert |
|--------|------|
| **Typ** | Local |
| **Pfad** | `externals/lua54` |
| **Include.cmake** | v0.1.0 |
| **Plattformen** | Windows, Linux, macOS |

```json
"lua54": { "path": "externals/lua54" }
```

#### Options

| Option | Default | Beschreibung |
|--------|---------|--------------|
| `LUA_EMBEDDED` | `true` | Statisch einbetten |
| `LUA_32BIT_COMPAT` | `false` | 32-Bit Integer |
| `LUA_USE_READLINE` | `false` | Readline (Linux) |

---

### 3.3 doctest

| Aspekt | Wert |
|--------|------|
| **Typ** | Local (Header-Only) |
| **Pfad** | `externals/doctest` |
| **Include.cmake** | v0.1.0 |
| **Plattformen** | Alle |

```json
"doctest": { "path": "externals/doctest" }
```

#### Options

| Option | Default | Beschreibung |
|--------|---------|--------------|
| `DOCTEST_NO_SHORT_MACRO_NAMES` | `false` | Lange Makronamen |
| `DOCTEST_CONFIG_SUPER_FAST_ASSERTS` | `false` | Schnellere Asserts |
| `DOCTEST_CONFIG_DISABLE` | `false` | doctest deaktivieren |

---

### 3.4 GLAD OpenGL Loader

| Aspekt | Wert |
|--------|------|
| **Typ** | Local (Generiert) |
| **Pfad** | `externals/glad` |
| **Include.cmake** | v0.1.0 |
| **Plattformen** | Alle |

```json
"glad": { "path": "externals/glad" }
```

**Generierung:** https://glad.dav1d.de/ → OpenGL Core 3.3+

---

## 4. Fetched Externals

### 4.1 GLFW

| Aspekt | Wert |
|--------|------|
| **Typ** | Fetched (Git) |
| **Repository** | https://github.com/glfw/glfw.git |
| **CMake-Support** | ✅ Ja |
| **Hook** | PreFetch (optional) |

```json
"glfw": {
    "git": "https://github.com/glfw/glfw.git",
    "tag": "3.4"
}
```

**PreFetch Hook deaktiviert:** GLFW_BUILD_EXAMPLES, GLFW_BUILD_TESTS, GLFW_BUILD_DOCS

**Target:** `glfw`

---

### 4.2 Dear ImGui

| Aspekt | Wert |
|--------|------|
| **Typ** | Fetched (Git) |
| **Repository** | https://github.com/ocornut/imgui.git |
| **CMake-Support** | ❌ Nein |
| **Hook** | PostFetch (PFLICHT) |

```json
"imgui": {
    "git": "https://github.com/ocornut/imgui.git",
    "tag": "v1.91.6",
    "cmakeSupport": false
}
```

**PostFetch Hook erstellt:** Core + OpenGL3 + GLFW + Win32 Backends

**Target:** `imgui`

**Variante mit Docking:**
```json
"imgui_docking": {
    "git": "https://github.com/ocornut/imgui.git",
    "tag": "v1.91.6-docking",
    "cmakeSupport": false,
    "hook": "imgui"
}
```

---

### 4.3 spdlog

| Aspekt | Wert |
|--------|------|
| **Typ** | Fetched (Git) |
| **Repository** | https://github.com/gabime/spdlog.git |
| **CMake-Support** | ✅ Ja |
| **Hook** | Nicht erforderlich |

```json
"spdlog": {
    "git": "https://github.com/gabime/spdlog.git",
    "tag": "v1.12.0"
}
```

**Target:** `spdlog`, `spdlog::spdlog`

---

### 4.4 googletest

| Aspekt | Wert |
|--------|------|
| **Typ** | Fetched (Git) |
| **Repository** | https://github.com/google/googletest.git |
| **CMake-Support** | ✅ Ja |

```json
"googletest": {
    "git": "https://github.com/google/googletest.git",
    "tag": "v1.14.0"
}
```

---

### 4.5 Catch2

| Aspekt | Wert |
|--------|------|
| **Typ** | Fetched (Git) |
| **Repository** | https://github.com/catchorg/Catch2.git |
| **CMake-Support** | ✅ Ja |

```json
"catch2": {
    "git": "https://github.com/catchorg/Catch2.git",
    "tag": "v3.5.2"
}
```

---

## 5. System Externals

> **Status:** 🔄 Phase 9 (geplant)

### 5.1 Qt6 (aktueller Workaround)

```json
"qt6": {
    "path": "externals/qt6",
    "options": {
        "hint": "${QT_ROOT}",
        "backup": "E:/Backup/Qt/6.7.0/msvc2022_64",
        "components": ["Core", "Widgets", "Gui"]
    }
}
```

### 5.2 Qt6 (Phase 9 Ziel)

```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "version": ">=6.5.0",
    "components": ["Core", "Widgets", "Gui"],
    "hints": ["${QT_ROOT}"],
    "backup": "E:/Backup/Qt/6.7.0"
}
```

---

## 6. Schnellreferenz

### External-Vergleich

| External | Typ | CMake | Hook | Verwendung |
|----------|-----|-------|------|------------|
| BASS | Local | — | — | Audio |
| Lua | Local | — | — | Scripting |
| doctest | Local | — | — | Testing |
| glad | Local | — | — | OpenGL |
| glfw | Fetched | ✅ | Optional | Window |
| imgui | Fetched | ❌ | Pflicht | GUI |
| spdlog | Fetched | ✅ | — | Logging |
| googletest | Fetched | ✅ | — | Testing |
| catch2 | Fetched | ✅ | — | Testing |

### Fehler-Codes

| Code | Beschreibung |
|------|--------------|
| E010 | External nicht im externals-Block |
| E012 | Kein/mehrere Source-Felder |
| E201 | Kein Target in Registry |
| E202 | Fetch fehlgeschlagen |
| E213 | Include.cmake fehlt |
| E214 | Pfad existiert nicht |
| E215 | Kein tag/branch/commit |
| E216 | Hook nicht gefunden |
| E217 | PostFetch Hook erforderlich |

---

## 7. Verwendung in Code

### Solution.json

```json
{
    "externals": {
        "glad": { "path": "externals/glad" },
        "glfw": { "git": "https://github.com/glfw/glfw.git", "tag": "3.4" },
        "imgui": { "git": "https://github.com/ocornut/imgui.git", "tag": "v1.91.6", "cmakeSupport": false }
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

### External Options

```json
{
    "executables": [
        {
            "name": "AudioApp",
            "externals": ["bass"],
            "external_options": {
                "bass": { "BASS_FLAC": true, "BASS_FX": true }
            }
        }
    ]
}
```

---

## 8. Siehe auch

- [Solution_Schema.md](Solution_Schema.md) — JSON-Schema
- [Externals_UserGuide.md](../guides/Externals_UserGuide.md) — Verwendungsanleitung
- [Adding_Externals_UserGuide.md](../guides/Adding_Externals_UserGuide.md) — Neue Externals hinzufügen
- [Orchestrator.cmake](../modules/externals/Orchestrator.md) — Koordination
- [System_Externals.md](../projects/buildsystem/concepts/System_Externals.md) — Phase 9 Konzept

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Reference Blueprint v0.5.0 Format, System Externals Vorschau** |
| 0.2.0 | 2025-12-09 | Git Externals, Hook-System |
| 0.1.1 | 2025-12-09 | BASS, Lua, doctest mit Options |
| 0.1.0 | 2025-12-03 | Initial |
