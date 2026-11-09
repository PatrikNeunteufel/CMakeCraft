# BASS — UserGuide

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Guide  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Bass.md](../../../../de/guide/userguides/externals/Bass.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Installation](#2-installation)
3. [Solution.json Configuration](#3-solutionjson-configuration)
4. [C++ Usage](#4-c-usage)
5. [Plugins](#5-plugins)
6. [Effects](#6-effects)
7. [Advanced Techniques](#7-advanced-techniques)
8. [Troubleshooting](#8-troubleshooting)
9. [Further Information](#9-further-information)
10. [Changelog](#changelog)

---

## 1. Overview

**BASS** is a professional audio library with an extensive plugin system.

| Aspect | Value |
|--------|-------|
| **Type** | Local External (precompiled) |
| **Path** | `externals/bass` |
| **License** | Free for non-commercial / Commercial |
| **Website** | [un4seen.com](https://www.un4seen.com/bass.html) |

### Why BASS?

| Advantage | Description |
|-----------|-------------|
| 🎵 **Plugins** | 20+ format plugins |
| 🎚️ **Effects** | DSP, tempo, pitch, reverb |
| 🔊 **3D Audio** | Surround sound support |
| 📱 **Cross-Platform** | Windows, Linux, macOS |

---

## 2. Installation

### 2.1 Download

From [un4seen.com/bass.html](https://www.un4seen.com/bass.html):

1. Download the BASS library
2. Download the required add-ons (FLAC, FX, etc.)
3. Extract to `externals/bass/`

### 2.2 Directory Structure

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
    │   ├── bass_fx.dll
    │   └── ...
    └── x86/
        └── ...
```

### 2.3 Copying DLLs

The DLLs must be available at runtime. The build system copies them automatically into the output directory.

---

## 3. Solution.json Configuration

### 3.1 Minimal

```json
{
    "externals": {
        "bass": {
            "path": "externals/bass"
        }
    },
    "executables": [
        {
            "name": "AudioPlayer",
            "externals": ["bass"]
        }
    ]
}
```

### 3.2 With Plugins

```json
{
    "externals": {
        "bass": {
            "path": "externals/bass"
        }
    },
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

### 3.3 All Options

#### Decoders

| Option | Plugin | Description |
|--------|--------|-------------|
| `BASS_FLAC` | bassflac | FLAC audio |
| `BASS_OPUS` | bassopus | Opus audio |
| `BASS_DSD` | bassdsd | DSD (Direct Stream Digital) |
| `BASS_WV` | basswv | WavPack |
| `BASS_APE` | bassape | Monkey's Audio |
| `BASS_MPC` | bass_mpc | Musepack |
| `BASS_ALAC` | bassalac | Apple Lossless |
| `BASS_TTA` | bass_tta | True Audio |
| `BASS_CD` | basscd | CD audio |
| `BASS_WEBM` | basswebm | WebM container |

#### Encoders

| Option | Plugin | Description |
|--------|--------|-------------|
| `BASS_ENC` | bassenc | Encoding base |
| `BASS_ENC_MP3` | bassenc_mp3 | MP3 encoder |
| `BASS_ENC_OGG` | bassenc_ogg | OGG Vorbis encoder |
| `BASS_ENC_FLAC` | bassenc_flac | FLAC encoder |

#### Effects & Mixing

| Option | Plugin | Description |
|--------|--------|-------------|
| `BASS_FX` | bass_fx | DSP effects |
| `BASS_MIX` | bassmix | Multi-channel mixing |
| `BASS_LOUD` | bassloud | Loudness (EBU R128) |
| `BASS_MIDI` | bassmidi | MIDI playback |

---

## 4. C++ Usage

### 4.1 Basics

```cpp
#include <bass.h>
#include <iostream>

int main() {
    // Initialize BASS
    // -1 = default device, 44100 Hz, 0 = default flags
    if (!BASS_Init(-1, 44100, 0, nullptr, nullptr)) {
        std::cerr << "BASS_Init failed: " << BASS_ErrorGetCode() << std::endl;
        return 1;
    }
    
    std::cout << "BASS initialized successfully!" << std::endl;
    std::cout << "Version: " << HIWORD(BASS_GetVersion()) << "." 
              << LOWORD(BASS_GetVersion()) << std::endl;
    
    // ... play audio ...
    
    // Shut down BASS
    BASS_Free();
    return 0;
}
```

### 4.2 Playing MP3/WAV

```cpp
#include <bass.h>
#include <iostream>
#include <thread>
#include <chrono>

int main() {
    BASS_Init(-1, 44100, 0, nullptr, nullptr);
    
    // Create stream
    HSTREAM stream = BASS_StreamCreateFile(
        FALSE,          // Not from memory
        "music.mp3",    // File path
        0,              // Offset
        0,              // Length (0 = whole file)
        0               // Flags
    );
    
    if (!stream) {
        std::cerr << "Failed to create stream: " << BASS_ErrorGetCode() << std::endl;
        BASS_Free();
        return 1;
    }
    
    // Start playback
    BASS_ChannelPlay(stream, FALSE);
    
    // Wait until finished
    while (BASS_ChannelIsActive(stream) == BASS_ACTIVE_PLAYING) {
        // Show position
        double pos = BASS_ChannelBytes2Seconds(stream, BASS_ChannelGetPosition(stream, BASS_POS_BYTE));
        double len = BASS_ChannelBytes2Seconds(stream, BASS_ChannelGetLength(stream, BASS_POS_BYTE));
        std::cout << "\rPosition: " << (int)pos << "s / " << (int)len << "s" << std::flush;
        
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
    
    std::cout << std::endl << "Playback finished!" << std::endl;
    
    // Clean up
    BASS_StreamFree(stream);
    BASS_Free();
    return 0;
}
```

### 4.3 Volume and Position

```cpp
HSTREAM stream = BASS_StreamCreateFile(FALSE, "music.mp3", 0, 0, 0);
BASS_ChannelPlay(stream, FALSE);

// Volume (0.0 - 1.0)
BASS_ChannelSetAttribute(stream, BASS_ATTRIB_VOL, 0.5f);

// Read volume
float volume;
BASS_ChannelGetAttribute(stream, BASS_ATTRIB_VOL, &volume);

// Set position (in seconds)
double newPos = 30.0;  // 30 seconds
QWORD bytes = BASS_ChannelSeconds2Bytes(stream, newPos);
BASS_ChannelSetPosition(stream, bytes, BASS_POS_BYTE);

// Pause
BASS_ChannelPause(stream);

// Resume
BASS_ChannelPlay(stream, FALSE);

// Stop (back to the beginning)
BASS_ChannelStop(stream);
```

### 4.4 Stream from URL

```cpp
// Internet stream
HSTREAM stream = BASS_StreamCreateURL(
    "http://example.com/radio.mp3",
    0,                  // Offset
    BASS_STREAM_BLOCK,  // Download in blocks
    nullptr,            // Callback
    nullptr             // User data
);

if (stream) {
    BASS_ChannelPlay(stream, FALSE);
}
```

### 4.5 Multiple Streams at Once

```cpp
HSTREAM music = BASS_StreamCreateFile(FALSE, "music.mp3", 0, 0, 0);
HSTREAM sfx = BASS_StreamCreateFile(FALSE, "explosion.wav", 0, 0, 0);

// Play both
BASS_ChannelPlay(music, FALSE);
BASS_ChannelSetAttribute(music, BASS_ATTRIB_VOL, 0.7f);

BASS_ChannelPlay(sfx, FALSE);
BASS_ChannelSetAttribute(sfx, BASS_ATTRIB_VOL, 1.0f);
```

---

## 5. Plugins

### 5.1 Playing FLAC

```cpp
#include <bass.h>
#include <bassflac.h>

int main() {
    BASS_Init(-1, 44100, 0, nullptr, nullptr);
    
    // The FLAC plugin is used automatically
    HSTREAM stream = BASS_StreamCreateFile(FALSE, "music.flac", 0, 0, 0);
    
    if (stream) {
        BASS_ChannelPlay(stream, FALSE);
        // ...
        BASS_StreamFree(stream);
    }
    
    BASS_Free();
    return 0;
}
```

### 5.2 Playing Opus

```cpp
#include <bass.h>
#include <bassopus.h>

HSTREAM stream = BASS_StreamCreateFile(FALSE, "music.opus", 0, 0, 0);
```

### 5.3 Format Information

```cpp
BASS_CHANNELINFO info;
BASS_ChannelGetInfo(stream, &info);

std::cout << "Channels: " << info.chans << std::endl;
std::cout << "Sample Rate: " << info.freq << " Hz" << std::endl;
std::cout << "Original Freq: " << info.origres << " Hz" << std::endl;

// Format type
switch (info.ctype) {
    case BASS_CTYPE_STREAM_MP3: std::cout << "MP3" << std::endl; break;
    case BASS_CTYPE_STREAM_OGG: std::cout << "OGG" << std::endl; break;
    case BASS_CTYPE_STREAM_FLAC: std::cout << "FLAC" << std::endl; break;
    case BASS_CTYPE_STREAM_WAV: std::cout << "WAV" << std::endl; break;
    default: std::cout << "Unknown" << std::endl;
}
```

---

## 6. Effects

### 6.1 BASS_FX Setup

```cpp
#include <bass.h>
#include <bass_fx.h>

BASS_Init(-1, 44100, 0, nullptr, nullptr);

// Create the stream as DECODE (for FX processing)
HSTREAM original = BASS_StreamCreateFile(
    FALSE, "music.mp3", 0, 0, 
    BASS_STREAM_DECODE  // Important!
);

// Create tempo stream
HSTREAM tempo = BASS_FX_TempoCreate(original, BASS_FX_FREESOURCE);
```

### 6.2 Changing Tempo

```cpp
// Tempo: -50% to +100%
// -20 = 20% slower
BASS_ChannelSetAttribute(tempo, BASS_ATTRIB_TEMPO, -20.0f);

// Read tempo
float currentTempo;
BASS_ChannelGetAttribute(tempo, BASS_ATTRIB_TEMPO, &currentTempo);
```

### 6.3 Changing Pitch

```cpp
// Pitch in semitones: -12 to +12
// 3 = 3 semitones higher
BASS_ChannelSetAttribute(tempo, BASS_ATTRIB_TEMPO_PITCH, 3.0f);
```

### 6.4 Playback Rate

```cpp
// Rate: 0.0 to 4.0 (normal = 1.0)
// Changes tempo AND pitch (like vinyl)
BASS_ChannelSetAttribute(tempo, BASS_ATTRIB_TEMPO_FREQ, 
    44100 * 1.5f);  // 50% faster
```

### 6.5 Reverb Effect

```cpp
// Add reverb
HFX reverb = BASS_ChannelSetFX(stream, BASS_FX_DX8_REVERB, 1);

// Set parameters
BASS_DX8_REVERB params;
params.fInGain = 0.0f;
params.fReverbMix = -10.0f;
params.fReverbTime = 1000.0f;
params.fHighFreqRTRatio = 0.5f;
BASS_FXSetParameters(reverb, &params);
```

### 6.6 Equalizer

```cpp
// 3-band EQ
HFX eq = BASS_ChannelSetFX(stream, BASS_FX_DX8_PARAMEQ, 1);

BASS_DX8_PARAMEQ params;
params.fCenter = 100.0f;   // Bass: 100 Hz
params.fBandwidth = 12.0f;
params.fGain = 6.0f;       // +6 dB
BASS_FXSetParameters(eq, &params);
```

---

## 7. Advanced Techniques

### 7.1 Callbacks

```cpp
// Position sync callback
void CALLBACK SyncCallback(HSYNC handle, DWORD channel, DWORD data, void* user) {
    std::cout << "Reached sync point!" << std::endl;
}

// At 30 seconds
QWORD pos = BASS_ChannelSeconds2Bytes(stream, 30.0);
BASS_ChannelSetSync(stream, BASS_SYNC_POS, pos, SyncCallback, nullptr);

// At the end
BASS_ChannelSetSync(stream, BASS_SYNC_END, 0, SyncCallback, nullptr);
```

### 7.2 Visualization (FFT)

```cpp
float fft[256];
BASS_ChannelGetData(stream, fft, BASS_DATA_FFT512);

// fft[0..255] contains frequency data
for (int i = 0; i < 256; i++) {
    float magnitude = fft[i];
    // Visualize...
}
```

### 7.3 Recording

```cpp
// Start recording
HRECORD record = BASS_RecordStart(44100, 2, 0, nullptr, nullptr);

// ... record ...

// Stop recording and save as WAV
BASS_ChannelStop(record);

// Create the WAV file manually or use bassenc
```

### 7.4 Loop Points

```cpp
// Set loop
QWORD loopStart = BASS_ChannelSeconds2Bytes(stream, 10.0);
QWORD loopEnd = BASS_ChannelSeconds2Bytes(stream, 20.0);

BASS_ChannelSetPosition(stream, loopStart, BASS_POS_BYTE);
BASS_ChannelFlags(stream, BASS_SAMPLE_LOOP, BASS_SAMPLE_LOOP);

// Custom loop
BASS_ChannelSetSync(stream, BASS_SYNC_POS | BASS_SYNC_MIXTIME, 
    loopEnd, [](HSYNC, DWORD channel, DWORD, void* start) {
        BASS_ChannelSetPosition(channel, *(QWORD*)start, BASS_POS_BYTE);
    }, &loopStart);
```

---

## 8. Troubleshooting

### 8.1 BASS_Init failed

**Problem:** `BASS_Init` returns FALSE

**Solutions:**
```cpp
int error = BASS_ErrorGetCode();
switch (error) {
    case BASS_ERROR_DEVICE:
        std::cerr << "Invalid device" << std::endl;
        break;
    case BASS_ERROR_ALREADY:
        std::cerr << "Already initialized" << std::endl;
        break;
    case BASS_ERROR_DRIVER:
        std::cerr << "No audio driver" << std::endl;
        break;
}
```

### 8.2 Stream Not Created

**Problem:** `BASS_StreamCreateFile` returns 0

**Solutions:**
```cpp
int error = BASS_ErrorGetCode();
switch (error) {
    case BASS_ERROR_FILEOPEN:
        std::cerr << "File not found" << std::endl;
        break;
    case BASS_ERROR_FILEFORM:
        std::cerr << "Unknown format (plugin missing?)" << std::endl;
        break;
    case BASS_ERROR_CODEC:
        std::cerr << "Codec not available" << std::endl;
        break;
}
```

### 8.3 DLL Not Found

**Problem:** `bass.dll` not found

**Solution:** The DLLs must be in the same directory as the EXE or in the PATH.

### 8.4 Plugin Not Loaded

**Problem:** FLAC/Opus files are not played

**Solution:** Check `external_options` in Solution.json:
```json
"external_options": {
    "bass": { "BASS_FLAC": true }
}
```

---

## 9. Further Information

### Official Resources

| Resource | Link |
|----------|------|
| **Website** | [un4seen.com](https://www.un4seen.com/) |
| **BASS Download** | [un4seen.com/bass.html](https://www.un4seen.com/bass.html) |
| **Documentation** | [un4seen.com/doc](https://www.un4seen.com/doc/) |
| **Forum** | [un4seen.com/forum](https://www.un4seen.com/forum/) |
| **Add-ons** | [un4seen.com/bass.html#addons](https://www.un4seen.com/bass.html#addons) |

### See Also

- [Externals.md](../Externals.md) — Externals combinations
- [Local_Externals_Media.md](../../references/externals/Local_Externals_Media.md) — Reference
- [Git_Externals_Media.md](../../references/externals/Git_Externals_Media.md) — Alternatives (miniaudio, openal-soft)

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.2 | 2025-12-15 | Initial: detailed UserGuide for BASS |
