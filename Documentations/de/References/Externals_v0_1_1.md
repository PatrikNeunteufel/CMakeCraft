# Externals – CMake Architecture V2

> **Version:** 0.1.1  
> **Datum:** 2025-12-09  
> **Typ:** Referenz-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, Solution_Schema v0.1
> **Sprache:** Deutsch

Dieses Dokument dokumentiert alle verfügbaren External Libraries mit ihren Konfigurationsoptionen.

---

## 1. Übersicht

Externals werden zentral im `externals`-Block der Solution.json definiert.

### Typen

| Typ | Quelle | Status | Beispiele |
|-----|--------|--------|-----------|
| **Lokal** | `path` | ✅ Phase 5 | BASS, Lua, doctest |
| **Fetched** | `git` | ⬜ Phase 6 | imgui, glfw, spdlog |

### Grundlegende Verwendung

```json
{
    "externals": {
        "bass": { "path": "externals/bass" },
        "lua54": { "path": "externals/lua54" },
        "doctest": { "path": "externals/doctest" }
    },
    "executables": [
        {
            "name": "MyApp",
            "externals": ["bass", "lua54"],
            "external_options": {
                "bass": {
                    "BASS_FLAC": true,
                    "BASS_FX": true
                }
            }
        },
        {
            "name": "MyTests",
            "externals": ["doctest"]
        }
    ]
}
```

---

## 2. BASS Audio Library

> **Typ:** Local  
> **Pfad:** `externals/bass`  
> **Include.cmake Version:** 0.1.1  
> **Plattformen:** Windows, Linux, macOS

```json
"externals": {
    "bass": { "path": "externals/bass" }
}
```

### Decoders

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

### Encoders

| Option | Plugin | Header | Beschreibung |
|--------|--------|--------|--------------|
| `BASS_ENC` | bassenc24 | `bassenc.h` | Encoding-Basis (Auto-aktiviert) |
| `BASS_ENC_MP3` | bassenc_mp324 | `bassenc_mp3.h` | MP3 Encoder |
| `BASS_ENC_OGG` | bassenc_ogg24 | `bassenc_ogg.h` | OGG Vorbis Encoder |
| `BASS_ENC_FLAC` | bassenc_flac24 | `bassenc_flac.h` | FLAC Encoder |

### Plugins

| Option | Plugin | Header | Beschreibung |
|--------|--------|--------|--------------|
| `BASS_FX` | bass_fx24 | `bass_fx.h` | DSP Effekte (Tempo, Pitch, Reverb) |
| `BASS_MIX` | bassmix24 | `bassmix.h` | Multi-Channel Mixing |
| `BASS_LOUD` | bassloud24 | `bassloud.h` | Loudness Messung (EBU R128) |
| `BASS_MIDI` | bassmidi24 | `bassmidi.h` | MIDI Playback |

### Platform-spezifisch

| Option | Plugin | Plattform | Beschreibung |
|--------|--------|-----------|--------------|
| `BASS_WASAPI` | basswasapi24 | Windows | WASAPI Exclusive Mode |
| `BASS_WMA` | basswma24 | Windows | WMA Decoder |
| `BASS_SSL` | bass_ssl | Windows | SSL/HTTPS Streaming |
| `BASS_HLS` | basshls24 | Alle | HLS Streaming |

### Beispiel: Audio-Player mit Effekten

```json
{
    "executables": [
        {
            "name": "AudioPlayer",
            "externals": ["bass"],
            "external_options": {
                "bass": {
                    "BASS_FLAC": true,
                    "BASS_OPUS": true,
                    "BASS_FX": true,
                    "BASS_MIX": true,
                    "BASS_WASAPI": true
                }
            }
        }
    ]
}
```

---

## 3. Lua 5.4 Scripting Engine

> **Typ:** Local  
> **Pfad:** `externals/lua54`  
> **Include.cmake Version:** 0.1.0  
> **Plattformen:** Windows, Linux, macOS

```json
"externals": {
    "lua54": { "path": "externals/lua54" }
}
```

### Options

| Option | Typ | Default | Beschreibung |
|--------|-----|---------|--------------|
| `LUA_EMBEDDED` | bool | `true` | Statisch einbetten (empfohlen) |
| `LUA_32BIT_COMPAT` | bool | `false` | 32-Bit Integer-Kompatibilität |
| `LUA_USE_READLINE` | bool | `false` | Readline-Support (nur Linux) |

### Beispiel: Embedded Scripting

```json
{
    "executables": [
        {
            "name": "GameEngine",
            "externals": ["lua54"],
            "external_options": {
                "lua54": {
                    "LUA_EMBEDDED": true
                }
            }
        }
    ]
}
```

### Verzeichnisstruktur

```
externals/lua54/
├── Include.cmake
└── win/
    ├── include/
    │   ├── lua.h
    │   ├── lualib.h
    │   ├── lauxlib.h
    │   └── luaconf.h
    ├── lib/
    │   └── lua54.lib
    └── bin/
        └── lua54.dll
```

---

## 4. doctest Testing Framework

> **Typ:** Local (Header-Only)  
> **Pfad:** `externals/doctest`  
> **Include.cmake Version:** 0.1.0  
> **Plattformen:** Alle

```json
"externals": {
    "doctest": { "path": "externals/doctest" }
}
```

### Options

| Option | Typ | Default | Beschreibung |
|--------|-----|---------|--------------|
| `DOCTEST_NO_SHORT_MACRO_NAMES` | bool | `false` | Lange Makronamen verwenden |
| `DOCTEST_CONFIG_SUPER_FAST_ASSERTS` | bool | `false` | Schnellere Asserts |
| `DOCTEST_CONFIG_DISABLE` | bool | `false` | doctest komplett deaktivieren |

### Beispiel: Test-Executable

```json
{
    "executables": [
        {
            "name": "CoreLibTests",
            "externals": ["doctest"],
            "dependencies": ["CoreLib"]
        }
    ]
}
```

### Verzeichnisstruktur

```
externals/doctest/
├── Include.cmake
└── doctest.h        ← Single-Header Library
```

---

## 5. Vergleich der Externals

| Feature | BASS | Lua 5.4 | doctest |
|---------|------|---------|---------|
| **Typ** | Binary | Binary | Header-Only |
| **Hauptverwendung** | Audio | Scripting | Testing |
| **DLL erforderlich** | Ja (Win) | Optional | Nein |
| **Options verfügbar** | Viele | Wenige | Wenige |
| **Plattformen** | Win/Lin/Mac | Win/Lin/Mac | Alle |

---

## 6. Fehlerbehandlung

### E010 – External nicht definiert

```
[E010] External 'bass' not defined in externals block
```

**Lösung:** External im `externals` Block der Solution.json definieren.

### E213 – Include.cmake nicht gefunden

```
[E213] Local external 'bass': Include.cmake not found
```

**Lösung:** `Include.cmake` im External-Verzeichnis erstellen.

### E214 – Pfad existiert nicht

```
[E214] Local external 'bass': Path does not exist: externals/bass
```

**Lösung:** External-Verzeichnis anlegen oder Pfad korrigieren.

---

## 7. Template für neue lokale Externals

```cmake
# externals/mylib/Include.cmake
# ==============================
# Integration für MyLib
#
# Version: 0.1.0
# Date:    2025-XX-XX

# Variable Kompatibilität
if(NOT DEFINED EXTERNAL_OPTIONS AND DEFINED EXTERNAL_ELEMENT_OPTIONS)
    set(EXTERNAL_OPTIONS "${EXTERNAL_ELEMENT_OPTIONS}")
endif()
if(NOT DEFINED EXTERNAL_NAME AND DEFINED EXTERNAL_ELEMENT_NAME)
    set(EXTERNAL_NAME "${EXTERNAL_ELEMENT_NAME}")
endif()

message(STATUS "[${EXTERNAL_NAME}] Attaching to ${EXECUTABLE_NAME}")

set(_mylib_root "${EXTERNAL_ROOT}")

# Include-Verzeichnis
target_include_directories(${EXECUTABLE_NAME} PRIVATE
    "${_mylib_root}/include"
)

# Library linken
if(WIN32)
    target_link_libraries(${EXECUTABLE_NAME} PRIVATE
        "${_mylib_root}/lib/mylib.lib"
    )
    # DLL kopieren
    add_custom_command(TARGET ${EXECUTABLE_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${_mylib_root}/bin/mylib.dll"
            $<TARGET_FILE_DIR:${EXECUTABLE_NAME}>
        COMMENT "[MyLib] Copying mylib.dll"
    )
endif()

message(STATUS "[${EXTERNAL_NAME}] Integration complete")
```

---

## 8. Siehe auch

- [master_concept](../Concepts/master_concept_v0_1_0.md) – Architektur
- [Solution_Schema](Solution_Schema_v0_1_0.md) – JSON-Schema
- [guidelines](../Concepts/guidelines_v0_1_0.md) – Best Practices
- [BASS Include.cmake Doku](../externals/bass/Include_cmake_v0_1_1_doc_v1.md)
- [Lua Include.cmake Doku](../externals/lua54/Include_cmake_v0_1_0_doc_v1.md)
- [doctest Include.cmake Doku](../externals/doctest/Include_cmake_v0_1_0_doc_v1.md)

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.1** | **2025-12-09** | **Phase 5: Vollständige Doku für BASS, Lua, doctest mit allen Options** |
| 0.1.0 | 2025-12-03 | Initial (Clean Start) |
