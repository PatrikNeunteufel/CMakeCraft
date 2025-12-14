# BASS Audio Library — Benutzerhandbuch

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Guide  
> **Status:** Stabil  
> **Zielgruppe:** C++ Entwickler  
> **Modul:** externals/bass/Include.cmake v0.1.1  
> **Basiert auf:** Guide v0.5  
> **Sprache:** Deutsch  
> **English:** [BASS_UserGuide.md](../../en/guides/externals/BASS_UserGuide.md)

---

## Inhaltsverzeichnis

1. [Überblick](#1-überblick)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Schnellstart](#3-schnellstart)
4. [Decoder konfigurieren](#4-decoder-konfigurieren)
5. [Encoder aktivieren](#5-encoder-aktivieren)
6. [Plugins verwenden](#6-plugins-verwenden)
7. [C++ Integration](#7-c-integration)
8. [Stolpersteine und Lösungen](#8-stolpersteine-und-lösungen)
9. [Troubleshooting](#9-troubleshooting)
10. [Siehe auch](#10-siehe-auch)
11. [Changelog](#11-changelog)

---

## 1. Überblick

Die BASS Audio Library ermöglicht professionelle Audiowiedergabe in C++-Projekten. Dieses Handbuch erklärt die Konfiguration und Verwendung aller verfügbaren Optionen.

### Features

- MP3, WAV, OGG Core-Formate (ohne Plugins)
- Zusätzliche Decoder: FLAC, Opus, DSD, WavPack, etc.
- Encoder: MP3, OGG, FLAC
- DSP-Effekte: Tempo, Pitch, Reverb
- Multi-Channel Mixing
- Loudness-Messung (EBU R128)

---

## 2. Voraussetzungen

- [ ] CMake Architecture V2 Build-System
- [ ] BASS Library in `externals/bass/` vorhanden
- [ ] Gewünschte Plugins in entsprechenden Unterordnern

### Plugin-Struktur prüfen

```
externals/bass/
├── bass24/           ← Core (erforderlich)
├── bassflac24/       ← FLAC (optional)
├── bassopus24/       ← Opus (optional)
├── bass_fx24/        ← FX (optional)
└── ...
```

---

## 3. Schnellstart

**1. Solution.json – External definieren:**

```json
{
    "externals": {
        "bass": {
            "path": "externals/bass"
        }
    }
}
```

**2. Solution.json – In Executable verwenden:**

```json
{
    "executables": [
        {
            "name": "AudioPlayer",
            "externals": ["bass"]
        }
    ]
}
```

**3. C++ Code:**

```cpp
#include <bass.h>

int main() {
    // BASS initialisieren
    if (!BASS_Init(-1, 44100, 0, nullptr, nullptr)) {
        return 1;
    }
    
    // Audio abspielen
    HSTREAM stream = BASS_StreamCreateFile(FALSE, "music.mp3", 0, 0, 0);
    BASS_ChannelPlay(stream, FALSE);
    
    // ... warten ...
    
    BASS_StreamFree(stream);
    BASS_Free();
    return 0;
}
```

---

## 4. Decoder konfigurieren

### 4.1 Wie aktiviere ich FLAC-Support?

Füge `BASS_FLAC` in den `external_options` hinzu:

```json
{
    "executables": [
        {
            "name": "AudioPlayer",
            "externals": ["bass"],
            "external_options": {
                "bass": {
                    "BASS_FLAC": true
                }
            }
        }
    ]
}
```

FLAC-Dateien funktionieren dann automatisch:

```cpp
// Funktioniert jetzt mit .flac Dateien
HSTREAM stream = BASS_StreamCreateFile(FALSE, "music.flac", 0, 0, 0);
```

### 4.2 Verfügbare Decoder

| Option | Format | Verzeichnis |
|--------|--------|-------------|
| `BASS_FLAC` | FLAC | bassflac24 |
| `BASS_OPUS` | Opus | bassopus24 |
| `BASS_DSD` | DSD | bassdsd24 |
| `BASS_WV` | WavPack | basswv24 |
| `BASS_APE` | Monkey's Audio | bassape24 |
| `BASS_MPC` | Musepack | bass_mpc24 |
| `BASS_ALAC` | Apple Lossless | bassalac24 |
| `BASS_TTA` | True Audio | bass_tta24 |
| `BASS_CD` | CD Audio | basscd24 |
| `BASS_WEBM` | WebM | basswebm24 |

### 4.3 Mehrere Decoder aktivieren

```json
"external_options": {
    "bass": {
        "BASS_FLAC": true,
        "BASS_OPUS": true,
        "BASS_DSD": true
    }
}
```

---

## 5. Encoder aktivieren

### 5.1 Wie nehme ich Audio auf?

Encoder benötigen die Basis-Library `BASS_ENC`. Diese wird **automatisch aktiviert** wenn ein Encoder verwendet wird.

```json
"external_options": {
    "bass": {
        "BASS_ENC_MP3": true
    }
}
```

### 5.2 Verfügbare Encoder

| Option | Format | Automatische Abhängigkeit |
|--------|--------|---------------------------|
| `BASS_ENC_MP3` | MP3 | BASS_ENC |
| `BASS_ENC_OGG` | OGG Vorbis | BASS_ENC |
| `BASS_ENC_FLAC` | FLAC | BASS_ENC |

### 5.3 Encoding-Beispiel

```cpp
#include <bass.h>
#include <bassenc.h>
#include <bassenc_mp3.h>

// Encoding starten
HENCODE encoder = BASS_Encode_MP3_StartFile(
    stream,           // Quell-Stream
    NULL,             // CLI-Options (NULL = Default)
    0,                // Flags
    "output.mp3"      // Ausgabedatei
);

// Audio durch Encoder schicken
BASS_ChannelPlay(stream, FALSE);

// ... nach Abschluss ...

BASS_Encode_Stop(encoder);
```

---

## 6. Plugins verwenden

### 6.1 Wie aktiviere ich DSP-Effekte?

```json
"external_options": {
    "bass": {
        "BASS_FX": true
    }
}
```

**Tempo und Pitch ändern:**

```cpp
#include <bass_fx.h>

// Tempo-Stream erstellen
HSTREAM tempoStream = BASS_FX_TempoCreate(originalStream, BASS_FX_FREESOURCE);

// Tempo ändern (-50% bis +100%)
BASS_ChannelSetAttribute(tempoStream, BASS_ATTRIB_TEMPO, -10.0f);  // 10% langsamer

// Pitch ändern (in Halbtönen)
BASS_ChannelSetAttribute(tempoStream, BASS_ATTRIB_TEMPO_PITCH, 2.0f);  // 2 Halbtöne höher
```

### 6.2 Wie aktiviere ich Multi-Channel Mixing?

```json
"external_options": {
    "bass": {
        "BASS_MIX": true
    }
}
```

**Mehrere Streams mischen:**

```cpp
#include <bassmix.h>

// Mixer erstellen
HSTREAM mixer = BASS_Mixer_StreamCreate(44100, 2, BASS_SAMPLE_FLOAT);

// Quellen hinzufügen
BASS_Mixer_StreamAddChannel(mixer, stream1, 0);
BASS_Mixer_StreamAddChannel(mixer, stream2, 0);

// Mixer abspielen
BASS_ChannelPlay(mixer, FALSE);
```

### 6.3 Wie messe ich Loudness?

```json
"external_options": {
    "bass": {
        "BASS_LOUD": true
    }
}
```

```cpp
#include <bassloud.h>

HLOUDNESS loudness = BASS_Loudness_Start(stream, BASS_LOUDNESS_INTEGRATED, 0);

// Nach Wiedergabe:
float loudnessValue;
BASS_Loudness_GetLevel(loudness, BASS_LOUDNESS_INTEGRATED, &loudnessValue);
// Ergebnis in LUFS (z.B. -14 LUFS)

BASS_Loudness_Stop(loudness);
```

### 6.4 Plugin-Übersicht

| Option | Funktion |
|--------|----------|
| `BASS_FX` | DSP-Effekte (Tempo, Pitch, Reverb) |
| `BASS_MIX` | Multi-Channel Mixing |
| `BASS_LOUD` | Loudness-Messung (EBU R128) |
| `BASS_MIDI` | MIDI-Playback |

### 6.5 Plattform-spezifische Plugins

| Option | Plattform | Funktion |
|--------|-----------|----------|
| `BASS_WASAPI` | Windows | WASAPI Exclusive Mode |
| `BASS_WMA` | Windows | WMA Decoder |
| `BASS_SSL` | Windows | SSL/HTTPS Streaming |
| `BASS_HLS` | Alle | HLS Streaming |

---

## 7. C++ Integration

### 7.1 Header einbinden

```cpp
// Core (immer)
#include <bass.h>

// Plugins (wenn aktiviert)
#include <bassflac.h>    // BASS_FLAC
#include <bassopus.h>    // BASS_OPUS
#include <bass_fx.h>     // BASS_FX
#include <bassmix.h>     // BASS_MIX
#include <bassenc.h>     // BASS_ENC
```

### 7.2 Fehlerbehandlung

```cpp
if (!BASS_Init(-1, 44100, 0, nullptr, nullptr)) {
    int error = BASS_ErrorGetCode();
    switch (error) {
        case BASS_ERROR_DEVICE:
            std::cerr << "Kein Audio-Gerät gefunden" << std::endl;
            break;
        case BASS_ERROR_ALREADY:
            std::cerr << "BASS bereits initialisiert" << std::endl;
            break;
        default:
            std::cerr << "BASS Error: " << error << std::endl;
    }
}
```

### 7.3 Stream-Informationen

```cpp
BASS_CHANNELINFO info;
BASS_ChannelGetInfo(stream, &info);

std::cout << "Sample Rate: " << info.freq << std::endl;
std::cout << "Channels: " << info.chans << std::endl;
std::cout << "Format: " << info.ctype << std::endl;
```

---

## 8. Stolpersteine und Lösungen

### 8.1 Plugin-Header werden nicht gefunden

**Problem:**
```
fatal error: 'bass_fx.h' file not found
```

**Ursache:** Option nicht aktiviert oder Plugin-Verzeichnis fehlt.

**Lösung:**
1. Option in `external_options` aktivieren: `"BASS_FX": true`
2. Prüfen ob `bass_fx24/` im `externals/bass/` Verzeichnis existiert

### 8.2 Unsupported file format

**Problem:**
```
BASS_ERROR_FILEFORM: Unsupported file format
```

**Ursache:** Decoder für Format nicht aktiviert.

**Lösung:** Passenden Decoder aktivieren:
- `.flac` → `"BASS_FLAC": true`
- `.opus` → `"BASS_OPUS": true`
- `.dsd` → `"BASS_DSD": true`

### 8.3 DLL nicht gefunden (Windows)

**Problem:**
```
The code execution cannot proceed because bass.dll was not found.
```

**Lösung:**
- Build-Ausgabe auf "Copying bass.dll" prüfen
- DLL manuell in Executable-Verzeichnis kopieren

---

## 9. Troubleshooting

### Checkliste

- [ ] BASS in Solution.json unter `externals` definiert?
- [ ] Executable verwendet `"externals": ["bass"]`?
- [ ] Plugin-Verzeichnisse vorhanden?
- [ ] Options korrekt unter `external_options` gesetzt?
- [ ] CMake-Cache nach Änderungen gelöscht?

### Häufige Fehler

| Fehler | Lösung |
|--------|--------|
| `bass.dll not found` | DLL ins Output-Verzeichnis kopieren |
| `bass_fx.h not found` | `"BASS_FX": true` aktivieren |
| `undefined symbol` | Architektur (x86/x64) prüfen |
| `Unsupported format` | Passenden Decoder aktivieren |

---

## 10. Siehe auch

- [BASS Include.cmake](../../modules/externals/bass/Include.md) — Technische Dokumentation
- [Externals Reference](../../reference/Externals.md) — Alle Externals
- [BASS Website](https://www.un4seen.com/) — Offizielle Dokumentation

---

## 11. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Neu: Vollständige Options-Dokumentation, Encoder, Plugins** |
