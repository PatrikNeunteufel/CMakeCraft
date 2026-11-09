# bass/Include.cmake — BASS Audio Library Integration

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5, Doc v0.5  
> **Target Audience:** Build System Developers, C++ Developers  
> **Language:** English  
> **German:** [Bass_Include.md](../../../../../../de/guide/module/externals/includes/bass/Bass_Include.md)  
> **Module:** [cmake/externals/includes/bass/Include.cmake](../../../../../../../cmake/externals/includes/bass/Include.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Available Variables](#2-available-variables)
3. [Created Targets](#3-created-targets)
4. [Options](#4-options)
5. [Platform Support](#5-platform-support)
6. [Usage Examples](#6-usage-examples)
7. [Directory Structure](#7-directory-structure)
8. [Error Handling](#8-error-handling)
9. [See Also](#9-see-also)
10. [Changelog](#changelog)

---

## 1. Overview

`bass/Include.cmake` integrates the **BASS Audio Library** by un4seen into the build system as a local external.

### Core Functions

| Function | Description |
|----------|-------------|
| Audio playback | MP3, WAV, OGG, FLAC (with plugin) |
| Streaming | Internet streams, Shoutcast |
| Recording | Audio recording |
| Plugins | Decoders, encoders, effects |

### Target Creation

Creates a `SHARED IMPORTED` target `bass` with platform-specific library paths.

---

## 2. Available Variables

These variables are provided by the orchestrator:

| Variable | Description |
|----------|-------------|
| `EXTERNAL_NAME` | `"bass"` |
| `EXTERNAL_ROOT` | Absolute path to `externals/bass` |
| `EXTERNAL_JSON` | JSON element from Solution.json |
| `EXTERNAL_OPTIONS` | Target-specific options (JSON) |

---

## 3. Created Targets

### 3.1 Primary Target

| Target | Type | Description |
|--------|------|-------------|
| `bass` | SHARED IMPORTED | BASS core library |

### 3.2 Plugin Targets (Optional)

Created only if the corresponding option is enabled:

| Target | Option | Description |
|--------|--------|-------------|
| `bass::flac` | `BASS_FLAC` | FLAC decoder |
| `bass::opus` | `BASS_OPUS` | Opus decoder |
| `bass::fx` | `BASS_FX` | DSP effects |
| `bass::mix` | `BASS_MIX` | Multi-channel mixing |
| `bass::enc` | `BASS_ENC` | Encoding base |
| `bass::enc_mp3` | `BASS_ENC_MP3` | MP3 encoder |
| `bass::enc_ogg` | `BASS_ENC_OGG` | OGG encoder |
| `bass::enc_flac` | `BASS_ENC_FLAC` | FLAC encoder |
| `bass::midi` | `BASS_MIDI` | MIDI playback |
| `bass::loud` | `BASS_LOUD` | Loudness (EBU R128) |

---

## 4. Options

### 4.1 Decoders

| Option | Plugin | Header | Description |
|--------|--------|--------|-------------|
| `BASS_FLAC` | bassflac | `bassflac.h` | FLAC audio decoder |
| `BASS_OPUS` | bassopus | `bassopus.h` | Opus audio decoder |
| `BASS_DSD` | bassdsd | `bassdsd.h` | DSD (Direct Stream Digital) |
| `BASS_WV` | basswv | `basswv.h` | WavPack decoder |
| `BASS_APE` | bassape | `bass_ape.h` | Monkey's Audio |
| `BASS_MPC` | bass_mpc | `bass_mpc.h` | Musepack decoder |
| `BASS_ALAC` | bassalac | `bassalac.h` | Apple Lossless |
| `BASS_TTA` | bass_tta | `bass_tta.h` | True Audio |
| `BASS_CD` | basscd | `basscd.h` | CD audio ripper |
| `BASS_WEBM` | basswebm | `basswebm.h` | WebM container |

### 4.2 Encoders

| Option | Plugin | Header | Description |
|--------|--------|--------|-------------|
| `BASS_ENC` | bassenc | `bassenc.h` | Encoding base (automatic with an encoder) |
| `BASS_ENC_MP3` | bassenc_mp3 | `bassenc_mp3.h` | MP3 encoder |
| `BASS_ENC_OGG` | bassenc_ogg | `bassenc_ogg.h` | OGG Vorbis encoder |
| `BASS_ENC_FLAC` | bassenc_flac | `bassenc_flac.h` | FLAC encoder |

### 4.3 Plugins

| Option | Plugin | Header | Description |
|--------|--------|--------|-------------|
| `BASS_FX` | bass_fx | `bass_fx.h` | DSP effects (tempo, pitch, reverb) |
| `BASS_MIX` | bassmix | `bassmix.h` | Multi-channel mixing |
| `BASS_LOUD` | bassloud | `bassloud.h` | Loudness measurement (EBU R128) |
| `BASS_MIDI` | bassmidi | `bassmidi.h` | MIDI playback |

---

## 5. Platform Support

### 5.1 Library Paths

| Platform | DLL/SO | Import Lib |
|----------|--------|------------|
| Windows x64 | `lib/x64/bass.dll` | `lib/x64/bass.lib` |
| Windows x86 | `lib/x86/bass.dll` | `lib/x86/bass.lib` |
| Linux | `lib/libbass.so` | — |
| macOS | `lib/libbass.dylib` | — |

### 5.2 Architecture Detection

```cmake
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(_arch "x64")
else()
    set(_arch "x86")
endif()
```

---

## 6. Usage Examples

### 6.1 Basic Usage

**Solution.json:**

```json
{
    "externals": {
        "bass": { "path": "externals/bass" }
    },
    "executables": [
        {
            "name": "AudioPlayer",
            "externals": ["bass"]
        }
    ]
}
```

**C++:**

```cpp
#include <bass.h>

int main() {
    BASS_Init(-1, 44100, 0, nullptr, nullptr);
    
    HSTREAM stream = BASS_StreamCreateFile(FALSE, "music.mp3", 0, 0, 0);
    BASS_ChannelPlay(stream, FALSE);
    
    // Wait until finished
    while (BASS_ChannelIsActive(stream) == BASS_ACTIVE_PLAYING) {
        Sleep(100);
    }
    
    BASS_StreamFree(stream);
    BASS_Free();
    return 0;
}
```

### 6.2 With Plugins

**Solution.json:**

```json
{
    "executables": [
        {
            "name": "FlacPlayer",
            "externals": ["bass"],
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

**C++:**

```cpp
#include <bass.h>
#include <bassflac.h>
#include <bass_fx.h>

// FLAC is detected automatically
HSTREAM stream = BASS_StreamCreateFile(FALSE, "music.flac", 0, 0, BASS_STREAM_DECODE);

// Tempo stream for pitch/speed changes
HSTREAM tempo = BASS_FX_TempoCreate(stream, BASS_FX_FREESOURCE);
BASS_ChannelSetAttribute(tempo, BASS_ATTRIB_TEMPO, -20.0f);  // 20% slower
```

---

## 7. Directory Structure

```
externals/bass/
├── include/
│   ├── bass.h
│   ├── bassflac.h
│   ├── bassopus.h
│   ├── bass_fx.h
│   └── ...
└── lib/
    ├── x64/
    │   ├── bass.dll
    │   ├── bass.lib
    │   ├── bassflac.dll
    │   └── ...
    └── x86/
        └── ...
```

---

## 8. Error Handling

| Code | Description |
|------|-------------|
| E213 | Include.cmake not found |
| E214 | External path does not exist |
| W105 | Plugin DLL not found (option enabled but file missing) |

> Currently not raised (as of 2026-11-09). The case is not reported:
> `cmake/externals/includes/bass/Include.cmake` knows no W105, its only warning is
> `[<name>] Unsupported platform` (`:91`). W105 stands in `cmake/core/Errors.cmake:179` for
> "Version not SemVer compliant" and is never raised either.

---

## 9. See Also

- [Externals_Reference.md](../../../../references/Externals.md) — All options in detail
- [Externals_UserGuide.md](../../../../userguides/Externals.md) — Usage guide
- [Attach_cmake.md](../../locals/Attach_cmake.md) — Local external handler

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-11-09** | **W105 in §8 marked as currently not raised** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| **0.5.1** | **2025-12-16** | **SYSTEM includes to suppress compiler warnings** |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0, convention path `cmake/externals/includes/bass/` |
| 0.1.1 | 2025-12-09 | Plugin system with options, encoder targets |
| 0.1.0 | 2025-12-05 | Initial: BASS core target |
