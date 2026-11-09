# Local Externals — Media

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Local_Externals_Media.md](../../../../de/guide/references/externals/Local_Externals_Media.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [BASS Audio Library](#2-bass-audio-library)
3. [See Also](#3-see-also)
4. [Changelog](#changelog)

---

## 1. Overview

This document describes local media externals for the CMake Architecture build system: audio, image, video.

| Library | Description | License |
|---------|-------------|---------|
| **BASS** | Professional audio library with plugins | Commercial / Free for non-commercial |

---

## 2. BASS Audio Library

### Quick Info

| Aspect | Value |
|--------|-------|
| **Type** | 📦 Precompiled |
| **Path** | `externals/bass` |
| **Include.cmake** | `cmake/externals/includes/bass/Include.cmake` |
| **Platforms** | Windows, Linux, macOS |
| **Website** | [un4seen.com](https://www.un4seen.com/bass.html) |

### Solution.json

```json
{
    "externals": {
        "bass": {
            "path": "externals/bass"
        }
    }
}
```

### Directory Structure

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

### Plugin System

BASS supports plugins via `external_options`:

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
                    "BASS_FX": true
                }
            }
        }
    ]
}
```

### Available Options

#### Decoders

| Option | Plugin | Description |
|--------|--------|-------------|
| `BASS_FLAC` | bassflac | FLAC audio decoder |
| `BASS_OPUS` | bassopus | Opus audio decoder |
| `BASS_DSD` | bassdsd | DSD (Direct Stream Digital) |
| `BASS_WV` | basswv | WavPack decoder |
| `BASS_APE` | bassape | Monkey's Audio |
| `BASS_MPC` | bass_mpc | Musepack decoder |
| `BASS_ALAC` | bassalac | Apple Lossless |
| `BASS_TTA` | bass_tta | True Audio |
| `BASS_CD` | basscd | CD audio ripper |
| `BASS_WEBM` | basswebm | WebM container |

#### Encoders

| Option | Plugin | Description |
|--------|--------|-------------|
| `BASS_ENC` | bassenc | Encoding base (automatic with any encoder) |
| `BASS_ENC_MP3` | bassenc_mp3 | MP3 encoder |
| `BASS_ENC_OGG` | bassenc_ogg | OGG Vorbis encoder |
| `BASS_ENC_FLAC` | bassenc_flac | FLAC encoder |

#### Effects & Mixing

| Option | Plugin | Description |
|--------|--------|-------------|
| `BASS_FX` | bass_fx | DSP effects (tempo, pitch, reverb) |
| `BASS_MIX` | bassmix | Multi-channel mixing |
| `BASS_LOUD` | bassloud | Loudness measurement (EBU R128) |
| `BASS_MIDI` | bassmidi | MIDI playback |

### Usage Example

```cpp
#include <bass.h>

int main() {
    // Initialize
    BASS_Init(-1, 44100, 0, nullptr, nullptr);
    
    // Load stream
    HSTREAM stream = BASS_StreamCreateFile(
        FALSE, "music.mp3", 0, 0, 0
    );
    
    // Play
    BASS_ChannelPlay(stream, FALSE);
    
    // Wait
    while (BASS_ChannelIsActive(stream) == BASS_ACTIVE_PLAYING) {
        Sleep(100);
    }
    
    // Clean up
    BASS_StreamFree(stream);
    BASS_Free();
    
    return 0;
}
```

### With Plugins (FLAC + Effects)

```cpp
#include <bass.h>
#include <bassflac.h>
#include <bass_fx.h>

int main() {
    BASS_Init(-1, 44100, 0, nullptr, nullptr);
    
    // Load FLAC (plugin is detected automatically)
    HSTREAM original = BASS_StreamCreateFile(
        FALSE, "music.flac", 0, 0, BASS_STREAM_DECODE
    );
    
    // Tempo stream for effects
    HSTREAM tempo = BASS_FX_TempoCreate(original, BASS_FX_FREESOURCE);
    
    // Adjust tempo: 20% slower
    BASS_ChannelSetAttribute(tempo, BASS_ATTRIB_TEMPO, -20.0f);
    
    // Pitch: 3 semitones higher
    BASS_ChannelSetAttribute(tempo, BASS_ATTRIB_TEMPO_PITCH, 3.0f);
    
    BASS_ChannelPlay(tempo, FALSE);
    
    // ...
    
    return 0;
}
```

### Comparison with Git Alternatives

| Feature | BASS (Local) | miniaudio (Git) | openal-soft (Git) |
|---------|--------------|-----------------|-------------------|
| **Type** | Precompiled | Header-only | CMake |
| **License** | Commercial | Public Domain | LGPL |
| **Plugins** | ✅ 20+ | ❌ | ❌ |
| **Effects** | ✅ | ❌ | ❌ |
| **3D Audio** | ✅ | ✅ | ✅ |
| **Streaming** | ✅ | ✅ | ❌ |
| **Recording** | ✅ | ✅ | ✅ |

### Recommendation

| Use Case | Recommendation |
|----------|----------------|
| Music player with formats | **BASS** |
| Simple sounds | miniaudio |
| 3D game audio | openal-soft |
| Professional effects | **BASS** |

### Detail Documentation

→ [bass_Include.md](../../module/externals/includes/bass/Bass_Include.md)

---

## 3. See Also

- [Externals.md](../Externals.md) — Main overview of all externals
- [Local_Externals.md](Local_Externals.md) — Local Externals overview
- [Git_Externals_Media.md](Git_Externals_Media.md) — Git media externals (miniaudio, openal-soft, stb)

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.2 | 2025-12-15 | Own category Media (parallel to Git) |
