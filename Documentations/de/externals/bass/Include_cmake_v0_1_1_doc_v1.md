# BASS Audio Library – Include.cmake Dokumentation

> **Version:** 0.1.1 (doc v1)  
> **Datum:** 2025-12-09  
> **Typ:** External Include Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** externals/bass/Include.cmake  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** CMake_Blueprint v0.1, Externals v0.1
> **Sprache:** Deutsch

---

## 1. Übersicht

Die BASS Audio Library Integration ermöglicht die Einbindung der BASS Audio-Bibliothek
in CMake-Targets. Das Modul unterstützt plattformübergreifend Windows, Linux und macOS.

**Kernfunktionen:**
- Automatische Plattform-Erkennung (Win x86/x64, Linux, macOS)
- Plugin-System für optionale Decoder/Encoder/Effekte
- Automatisches DLL-Kopieren (Windows)
- Automatisches Hinzufügen der Plugin-Header-Verzeichnisse
- JSON-basierte Options-Konfiguration

**NEU in v0.1.1:**
- Plugin-Header werden automatisch zum Include-Pfad hinzugefügt
- Sonderbehandlung für bass_fx (verwendet `win/C/` statt `win/c/`)
- Korrigierte x64 lib-Pfade (`win/c/x64/`)

---

## 2. Erwartete Variablen

Das Modul erwartet folgende Variablen vom Orchestrator:

| Variable | Beschreibung | Beispiel |
|----------|--------------|----------|
| `EXTERNAL_NAME` | Name des Externals | `"bass"` |
| `EXTERNAL_ROOT` | Pfad zum External-Verzeichnis | `"/path/to/externals/bass"` |
| `EXTERNAL_OPTIONS` | JSON-String mit Plugin-Options | `"{\"BASS_FLAC\":true}"` |
| `EXECUTABLE_NAME` | Ziel-Target | `"MyApp"` |

---

## 3. Verzeichnisstruktur

```
externals/bass/
├── Include.cmake               ← Dieses Modul
├── bass24/                     ← BASS Core
│   └── win/
│       ├── bass.dll            (32-bit)
│       ├── x64/
│       │   └── bass.dll        (64-bit)
│       └── c/
│           ├── bass.h          ← Header
│           ├── bass.lib        (32-bit)
│           └── x64/
│               └── bass.lib    (64-bit)
├── bassflac24/                 ← FLAC Plugin (gleiche Struktur)
│   └── win/
│       ├── bassflac.dll
│       ├── x64/bassflac.dll
│       └── c/
│           ├── bassflac.h      ← Plugin-Header
│           ├── bassflac.lib
│           └── x64/bassflac.lib
├── bass_fx24/                  ← FX Plugin (ACHTUNG: Sonderfall!)
│   └── win/
│       ├── bass_fx.dll
│       ├── x64/bass_fx.dll
│       └── C/                  ← Großbuchstabe C!
│           ├── bass_fx.h
│           ├── bass_fx.lib
│           └── x64/bass_fx.lib
└── ...                         ← Weitere Plugins
```

**Wichtig:** Das Plugin `bass_fx24` verwendet `win/C/` (Großbuchstabe) statt `win/c/`.
Dies wird in v0.1.1 automatisch behandelt.

---

## 4. Verfügbare Options

### 4.1 Decoder

| Option | Plugin | Beschreibung |
|--------|--------|--------------|
| `BASS_FLAC` | bassflac24 | FLAC Audio Decoder |
| `BASS_OPUS` | bassopus24 | Opus Audio Decoder |
| `BASS_DSD` | bassdsd24 | DSD (Direct Stream Digital) |
| `BASS_WV` | basswv24 | WavPack Decoder |
| `BASS_APE` | bassape24 | Monkey's Audio |
| `BASS_MPC` | bass_mpc24 | Musepack Decoder |
| `BASS_ALAC` | bassalac24 | Apple Lossless |
| `BASS_TTA` | bass_tta24 | True Audio |
| `BASS_CD` | basscd24 | CD Audio Ripper |
| `BASS_WEBM` | basswebm24 | WebM Container |

### 4.2 Encoder

| Option | Plugin | Beschreibung |
|--------|--------|--------------|
| `BASS_ENC` | bassenc24 | Encoding Basis (Auto-aktiviert) |
| `BASS_ENC_MP3` | bassenc_mp324 | MP3 Encoder |
| `BASS_ENC_OGG` | bassenc_ogg24 | OGG Vorbis Encoder |
| `BASS_ENC_FLAC` | bassenc_flac24 | FLAC Encoder |

**Hinweis:** `BASS_ENC` wird automatisch aktiviert wenn ein Encoder aktiviert wird.

### 4.3 Plugins

| Option | Plugin | Beschreibung |
|--------|--------|--------------|
| `BASS_FX` | bass_fx24 | DSP Effekte |
| `BASS_MIX` | bassmix24 | Multi-Channel Mixing |
| `BASS_LOUD` | bassloud24 | Loudness Messung (EBU R128) |
| `BASS_MIDI` | bassmidi24 | MIDI Playback |

### 4.4 Platform-spezifisch

| Option | Plugin | Plattform | Beschreibung |
|--------|--------|-----------|--------------|
| `BASS_WASAPI` | basswasapi24 | Windows | WASAPI Exclusive Mode |
| `BASS_WMA` | basswma24 | Windows | WMA Decoder |
| `BASS_SSL` | bass_ssl | Windows | SSL/HTTPS Streaming |
| `BASS_HLS` | basshls24 | Alle | HLS Streaming |

---

## 5. Verwendung in Solution.json

### 5.1 External definieren

```json
{
    "externals": {
        "bass": {
            "path": "externals/bass"
        }
    }
}
```

### 5.2 In Executable verwenden

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
                    "BASS_MIX": true
                }
            }
        }
    ]
}
```

### 5.3 Minimale Konfiguration (nur Core)

```json
{
    "executables": [
        {
            "name": "SimplePlayer",
            "externals": ["bass"]
        }
    ]
}
```

---

## 6. C++ Verwendung

### 6.1 Header einbinden

```cpp
// BASS Core (immer verfügbar)
#include <bass.h>

// Plugin-Header (nur wenn Option aktiviert)
#include <bassflac.h>    // BASS_FLAC
#include <bassopus.h>    // BASS_OPUS
#include <bass_fx.h>     // BASS_FX
#include <bassmix.h>     // BASS_MIX
#include <bassmidi.h>    // BASS_MIDI
#include <bassenc.h>     // BASS_ENC
// ... etc.
```

### 6.2 Initialisierung

```cpp
// Initialize BASS (default device, 44100 Hz)
if (!BASS_Init(-1, 44100, 0, nullptr, nullptr)) {
    int error = BASS_ErrorGetCode();
    // Handle error
}
```

### 6.3 Audio abspielen

```cpp
// Create stream from file
HSTREAM stream = BASS_StreamCreateFile(
    FALSE,              // Not from memory
    "music.mp3",        // File path
    0, 0,               // Offset, length (0 = whole file)
    BASS_SAMPLE_FLOAT   // Float samples
);

// Start playback
BASS_ChannelPlay(stream, FALSE);

// ... wait for playback ...

// Cleanup
BASS_StreamFree(stream);
BASS_Free();
```

### 6.4 FLAC mit Plugin

```cpp
// FLAC files work automatically when BASS_FLAC is enabled
HSTREAM stream = BASS_StreamCreateFile(
    FALSE, "music.flac", 0, 0, BASS_SAMPLE_FLOAT
);
```

### 6.5 BASS_FX Effekte

```cpp
#include <bass_fx.h>

// Tempo-Stream erstellen (erlaubt Tempo/Pitch-Änderung)
HSTREAM tempoStream = BASS_FX_TempoCreate(originalStream, BASS_FX_FREESOURCE);

// Tempo ändern (-50% bis +100%)
BASS_ChannelSetAttribute(tempoStream, BASS_ATTRIB_TEMPO, -10.0f);  // 10% langsamer

// Pitch ändern (in Halbtönen)
BASS_ChannelSetAttribute(tempoStream, BASS_ATTRIB_TEMPO_PITCH, 2.0f);  // 2 Halbtöne höher
```

### 6.6 BASS_MIX Mixer

```cpp
#include <bassmix.h>

// Mixer-Stream erstellen
HSTREAM mixer = BASS_Mixer_StreamCreate(44100, 2, BASS_SAMPLE_FLOAT);

// Quellen zum Mixer hinzufügen
BASS_Mixer_StreamAddChannel(mixer, stream1, 0);
BASS_Mixer_StreamAddChannel(mixer, stream2, 0);

// Mixer abspielen
BASS_ChannelPlay(mixer, FALSE);
```

---

## 7. Plattform-Verhalten

### 7.1 Windows

- **Libraries:** `.lib` Dateien werden gelinkt
- **DLLs:** Werden automatisch ins Output-Verzeichnis kopiert
- **Architektur:** x86 und x64 werden automatisch erkannt

### 7.2 Linux

- **Libraries:** `.so` Dateien werden gelinkt
- **Pfad:** Muss im `LD_LIBRARY_PATH` sein oder mit rpath gesetzt

### 7.3 macOS

- **Libraries:** `.dylib` Dateien werden gelinkt
- **Framework:** Optional als Framework nutzbar

---

## 8. Fehlerbehebung

### E213 – Include.cmake nicht gefunden

```
[E213] Local external 'bass': Include.cmake not found
```

**Lösung:** Stelle sicher dass `externals/bass/Include.cmake` existiert.

### DLL nicht gefunden (Windows)

```
The code execution cannot proceed because bass.dll was not found.
```

**Lösung:** 
- Prüfe ob DLL im gleichen Verzeichnis wie die .exe liegt
- Prüfe Build-Ausgabe auf "Copying bass.dll" Meldung

### Plugin-Header nicht gefunden

```
fatal error: 'bass_fx.h' file not found
```

**Lösung:** 
- Stelle sicher dass die Option aktiviert ist: `"BASS_FX": true`
- Prüfe ob das Plugin-Verzeichnis existiert: `externals/bass/bass_fx24/`
- Bei bass_fx: Header liegt unter `win/C/` (großes C), wird automatisch behandelt

### Unsupported format

```
BASS_ERROR_FILEFORM: Unsupported file format
```

**Lösung:** Aktiviere den passenden Decoder in `external_options`:
- `.flac` → `BASS_FLAC: true`
- `.opus` → `BASS_OPUS: true`

### Linker-Fehler: undefined symbol BASS_*

```
undefined symbol: BASS_GetVersion
```

**Lösung:**
- Prüfe ob die richtige Architektur verwendet wird (x86 vs x64)
- x64 libs liegen unter `win/c/x64/`, nicht unter `win/c/`

---

## 9. Siehe auch

- [Externals](../../References/Externals_v0_1_0.md) – Alle Externals
- [Orchestrator.cmake](../../Modules/externals/Orchestrator_cmake_v0_1_0_doc_v1.md)
- [BASS Website](https://www.un4seen.com/) – Offizielle Dokumentation

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.1** | **2025-12-09** | **Plugin-Header automatisch inkludiert, bass_fx Sonderfall, korrigierte x64 lib-Pfade** |
| 0.1.0 | 2025-12-08 | Initial: Blueprint-konform, JSON-Options, Plattform-Support |
