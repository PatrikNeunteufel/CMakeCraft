# BASS Audio Library – Include.cmake

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [externals/bass/Include.cmake](../../../../externals/bass/Include.cmake)  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [Include.md](../../../en/modules/externals/bass/Include.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [Konzept](#3-konzept)
4. [API-Referenz](#4-api-referenz)
5. [Verwendungsbeispiele](#5-verwendungsbeispiele)
6. [Fehlerbehandlung](#6-fehlerbehandlung)
7. [Best Practices](#7-best-practices)
8. [Bekannte Einschränkungen](#8-bekannte-einschränkungen)
9. [Siehe auch](#9-siehe-auch)
10. [Changelog](#10-changelog)

---

## 1. Übersicht

Die BASS Audio Library Integration ermöglicht die Einbindung der BASS Audio-Bibliothek in CMake-Targets. Das Modul unterstützt plattformübergreifend Windows, Linux und macOS mit einem umfangreichen Plugin-System.

### Features

- Automatische Plattform-Erkennung (Win x86/x64, Linux, macOS)
- Plugin-System für optionale Decoder/Encoder/Effekte
- Automatisches DLL-Kopieren (Windows)
- Automatisches Hinzufügen der Plugin-Header-Verzeichnisse
- JSON-basierte Options-Konfiguration

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| CMake 3.19+ | System | Für JSON-Verarbeitung |
| Errors.cmake | Modul | Fehlerbehandlung |

**Keine** externen System-Libraries erforderlich – BASS ist vollständig selbstständig.

---

## 3. Konzept

### 3.1 Plugin-Architektur

BASS verwendet ein modulares Plugin-System. Der Core (`bass24/`) stellt Grundfunktionen bereit, Plugins erweitern die Funktionalität:

```
bass24/           ← Core (immer geladen)
├── bassflac24/   ← FLAC Decoder
├── bassopus24/   ← Opus Decoder
├── bass_fx24/    ← DSP Effekte
└── bassmix24/    ← Multi-Channel Mixing
```

### 3.2 Verzeichnisstruktur

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
├── bassflac24/                 ← FLAC Plugin
└── bass_fx24/                  ← FX Plugin (Sonderfall: win/C/)
```

### 3.3 Plattform-Pfade

| Plattform | Library-Pfad | Header-Pfad |
|-----------|--------------|-------------|
| Windows x86 | `win/c/` | `win/c/` |
| Windows x64 | `win/c/x64/` | `win/c/` |
| Linux | `linux/` | `linux/` |
| macOS | `macos/` | `macos/` |

**Sonderfall:** `bass_fx24` verwendet `win/C/` (Großbuchstabe) statt `win/c/`.

---

## 4. API-Referenz

### 4.1 Erwartete Variablen

Das Modul erwartet folgende Variablen vom Orchestrator:

| Variable | Pflicht | Beschreibung |
|----------|---------|--------------|
| `EXTERNAL_NAME` | ✓ | Name des Externals (`"bass"`) |
| `EXTERNAL_ROOT` | ✓ | Pfad zum External-Verzeichnis |
| `EXTERNAL_OPTIONS` | — | JSON-String mit Plugin-Options |
| `EXECUTABLE_NAME` | ✓ | Ziel-Target |

### 4.2 Verfügbare Options

#### Decoder

| Option | Plugin-Verzeichnis | Beschreibung |
|--------|-------------------|--------------|
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

#### Encoder

| Option | Plugin-Verzeichnis | Beschreibung |
|--------|-------------------|--------------|
| `BASS_ENC` | bassenc24 | Encoding Basis (Auto-aktiviert) |
| `BASS_ENC_MP3` | bassenc_mp324 | MP3 Encoder |
| `BASS_ENC_OGG` | bassenc_ogg24 | OGG Vorbis Encoder |
| `BASS_ENC_FLAC` | bassenc_flac24 | FLAC Encoder |

#### Plugins

| Option | Plugin-Verzeichnis | Beschreibung |
|--------|-------------------|--------------|
| `BASS_FX` | bass_fx24 | DSP Effekte |
| `BASS_MIX` | bassmix24 | Multi-Channel Mixing |
| `BASS_LOUD` | bassloud24 | Loudness Messung (EBU R128) |
| `BASS_MIDI` | bassmidi24 | MIDI Playback |

#### Plattform-spezifisch

| Option | Plugin | Plattform | Beschreibung |
|--------|--------|-----------|--------------|
| `BASS_WASAPI` | basswasapi24 | Windows | WASAPI Exclusive Mode |
| `BASS_WMA` | basswma24 | Windows | WMA Decoder |
| `BASS_SSL` | bass_ssl | Windows | SSL/HTTPS Streaming |
| `BASS_HLS` | basshls24 | Alle | HLS Streaming |

### 4.3 Registrierte Targets

| Target | Typ | Beschreibung |
|--------|-----|--------------|
| `bass` | PRIMARY | BASS Core Library |
| `bass_flac` | SECONDARY | FLAC Plugin (wenn aktiviert) |
| `bass_fx` | SECONDARY | FX Plugin (wenn aktiviert) |
| ... | ... | Weitere Plugins |

---

## 5. Verwendungsbeispiele

### 5.1 External definieren (Solution.json)

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

## 6. Fehlerbehandlung

### Error Codes

| Code | Konstante | Beschreibung |
|------|-----------|--------------|
| E213 | `E_LOCAL_INCLUDE_NOT_FOUND` | Include.cmake nicht gefunden |

### Häufige Fehler

| Fehler | Ursache | Lösung |
|--------|---------|--------|
| `bass.dll was not found` | DLL nicht im Output | Build-Ausgabe prüfen |
| `bass_fx.h not found` | Option nicht aktiviert | `"BASS_FX": true` setzen |
| `undefined symbol: BASS_*` | Falsche Architektur | x86/x64 prüfen |

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| Nur benötigte Plugins aktivieren | Alle Plugins aktivieren |
| `BASS_ENC` automatisch aktivieren lassen | Encoder ohne `BASS_ENC` verwenden |
| Plugin-Header nach Core-Header einbinden | Plugin vor Core inkludieren |

---

## 8. Bekannte Einschränkungen

- `bass_fx24` verwendet abweichende Verzeichnisstruktur (`win/C/`)
- Encoder benötigen immer `BASS_ENC` als Basis
- Einige Plugins sind plattform-spezifisch (WASAPI, WMA nur Windows)

---

## 9. Siehe auch

- [BASS UserGuide](../../../guides/externals/BASS_UserGuide.md) — Benutzerhandbuch
- [Externals Reference](../../../reference/Externals.md) — Alle Externals
- [Orchestrator.cmake](../Orchestrator.md) — External-Dispatch
- [BASS Website](https://www.un4seen.com/) — Offizielle Dokumentation

---

## 10. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint, strukturierte Options-Dokumentation** |
| 0.1.1 | 2025-12-09 | Plugin-Header automatisch inkludiert, bass_fx Sonderfall |
| 0.1.0 | 2025-12-08 | Initial: Blueprint-konform, JSON-Options, Plattform-Support |
