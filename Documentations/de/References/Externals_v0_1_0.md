# Externals – CMake Architecture V2

> **Version:** 0.1.0  
> **Datum:** 2025-12-03  
> **Typ:** Referenz-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, Solution_Schema v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/References/Externals_v0_1_0.md)

Dieses Dokument dokumentiert alle verfügbaren External Libraries mit ihren Konfigurationsoptionen.

---

## 1. Übersicht

Externals werden zentral im `externals`-Block der Solution.json definiert.

### Typen

| Typ | Quelle | Beispiele |
|-----|--------|-----------|
| **Lokal** | `path` | BASS, Lua, doctest |
| **Fetched** | `git` | imgui, glfw, spdlog |

### Verwendung

```json
{
    "executables": [
        {
            "name": "MyApp",
            "externals": ["bass", "lua"],
            "external_options": {
                "bass": {
                    "BASS_FLAC": true,
                    "BASS_FX": true
                }
            }
        }
    ]
}
```

---

## 2. Lokale Externals

### BASS Audio Library

> **Typ:** Local  
> **Pfad:** `externals/bass`  
> **Plattformen:** Windows, Linux, macOS

```json
"externals": {
    "bass": { "path": "externals/bass" }
}
```

#### Decoders

| Option | Beschreibung |
|--------|--------------|
| `BASS_FLAC` | FLAC Decoder |
| `BASS_OPUS` | Opus Decoder |
| `BASS_DSD` | DSD (Direct Stream Digital) |
| `BASS_WV` | WavPack Decoder |
| `BASS_APE` | Monkey's Audio |
| `BASS_MPC` | Musepack Decoder |

#### Encoders

| Option | Beschreibung |
|--------|--------------|
| `BASS_ENC` | Encoding-Basis |
| `BASS_ENC_MP3` | MP3 Encoder |
| `BASS_ENC_OGG` | OGG Encoder |
| `BASS_ENC_FLAC` | FLAC Encoder |

#### Plugins

| Option | Beschreibung |
|--------|--------------|
| `BASS_FX` | DSP Effekte |
| `BASS_MIX` | Multi-Channel Mixing |
| `BASS_LOUD` | Loudness Messung |
| `BASS_MIDI` | MIDI Playback |

#### Platform-spezifisch

| Option | Plattform | Beschreibung |
|--------|-----------|--------------|
| `BASS_WASAPI` | Windows | WASAPI Exclusive Mode |
| `BASS_WMA` | Windows | WMA Decoder |

---

### Lua Scripting Engine

> **Typ:** Local  
> **Pfad:** `externals/lua`  
> **Plattformen:** Windows, Linux, macOS

```json
"externals": {
    "lua": { "path": "externals/lua" }
}
```

#### Options

| Option | Default | Beschreibung |
|--------|---------|--------------|
| `LUA_EMBEDDED` | true | Statisch einbetten |
| `LUA_32BIT_COMPAT` | false | 32-Bit Integer-Kompatibilität |

---

### doctest Testing Framework

> **Typ:** Local  
> **Pfad:** `externals/doctest`  
> **Plattformen:** Alle

```json
"externals": {
    "doctest": { "path": "externals/doctest" }
}
```

Header-only, keine Options nötig.

---

## 3. Fetched Externals

### imgui

> **Typ:** Fetched  
> **Repository:** github.com/ocornut/imgui

```json
"externals": {
    "imgui": {
        "git": "https://github.com/ocornut/imgui.git",
        "tag": "v1.90.1",
        "hooks": {
            "postFetch": "cmake/externals/Hooks/PostFetch/imgui.cmake"
        }
    }
}
```

> **Hinweis:** ImGui hat kein CMakeLists.txt, PostFetch-Hook erforderlich.

---

### glfw

> **Typ:** Fetched  
> **Repository:** github.com/glfw/glfw

```json
"externals": {
    "glfw": {
        "git": "https://github.com/glfw/glfw.git",
        "tag": "3.4"
    }
}
```

---

### glad

> **Typ:** Fetched  
> **Repository:** github.com/Dav1dde/glad

```json
"externals": {
    "glad": {
        "git": "https://github.com/Dav1dde/glad.git",
        "tag": "v2.0.4"
    }
}
```

---

### spdlog

> **Typ:** Fetched  
> **Repository:** github.com/gabime/spdlog

```json
"externals": {
    "spdlog": {
        "git": "https://github.com/gabime/spdlog.git",
        "tag": "v1.12.0"
    }
}
```

---

### fmt

> **Typ:** Fetched  
> **Repository:** github.com/fmtlib/fmt

```json
"externals": {
    "fmt": {
        "git": "https://github.com/fmtlib/fmt.git",
        "tag": "10.2.1"
    }
}
```

---

### nlohmann_json

> **Typ:** Fetched  
> **Repository:** github.com/nlohmann/json

```json
"externals": {
    "nlohmann_json": {
        "git": "https://github.com/nlohmann/json.git",
        "tag": "v3.11.3"
    }
}
```

---

## 4. Template für neue Externals

### Lokales External hinzufügen

1. Verzeichnis erstellen: `externals/[name]/`
2. `Include.cmake` erstellen:

```cmake
# externals/mylib/Include.cmake

include_guard(GLOBAL)

# Library linken
target_link_libraries(${EXECUTABLE_NAME} PRIVATE
    ${CMAKE_SOURCE_DIR}/externals/mylib/lib/mylib.lib
)

# Include-Pfad
target_include_directories(${EXECUTABLE_NAME} PRIVATE
    ${CMAKE_SOURCE_DIR}/externals/mylib/include
)

# DLL kopieren (Windows)
if(WIN32)
    add_custom_command(TARGET ${EXECUTABLE_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${CMAKE_SOURCE_DIR}/externals/mylib/lib/mylib.dll"
            $<TARGET_FILE_DIR:${EXECUTABLE_NAME}>
    )
endif()
```

3. In Solution.json eintragen:

```json
"externals": {
    "mylib": { "path": "externals/mylib" }
}
```

### Fetched External hinzufügen

1. In Solution.json:

```json
"externals": {
    "mylib": {
        "git": "https://github.com/author/mylib.git",
        "tag": "v1.0.0"
    }
}
```

2. Bei Bedarf PostFetch-Hook:

```cmake
# cmake/externals/Hooks/PostFetch/mylib.cmake

include_guard(GLOBAL)

FetchContent_GetProperties(mylib)
if(mylib_POPULATED)
    if(NOT TARGET mylib)
        add_library(mylib STATIC ...)
    endif()
endif()
```

---

## 5. Siehe auch

- [master_concept](../Concepts/master_concept_v0_1_0.md) – Architektur
- [Solution_Schema](Solution_Schema_v0_1_0.md) – JSON-Schema
- [guidelines](../Concepts/guidelines_v0_1_0.md) – Best Practices

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-03** | **Initial (Clean Start): Inhalte aus v1.0 übernommen, Blueprint-Format** |
