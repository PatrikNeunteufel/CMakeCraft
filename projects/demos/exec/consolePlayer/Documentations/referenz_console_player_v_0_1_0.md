# consolePlayer – Referenz

> **Version:** 0.1.0  
> **Datum:** 2025-12-09  
> **Typ:** Referenz-Doku  
> **Status:** In Entwicklung

---

## 1. Übersicht / Einleitung

Diese Referenz beschreibt die **Einstiegspunkte**, **Konfigurationskonstanten**, **Strukturen** und **Hotkeys** des `consolePlayer`.

Zielgruppe sind Entwickler, die:

- das Verhalten der Anwendung nachvollziehen oder erweitern,
- BASS/BASS_FX-Integration mit Tempo/Reverb nutzen möchten,
- den Konsolen-Runloop anpassen wollen.

---

## 2. Konventionen

- Rückgabewerte der `main`/`WinMain`/`commonMain`-Funktionen:
  - `0` – Erfolgreiche Ausführung
  - `1` – BASS-Initialisierung fehlgeschlagen
  - `2` – Audio-Stream-Erzeugung fehlgeschlagen
- Pfade: UTF-16 Wide-Strings (`wchar_t*`, `std::wstring`)
- Zeit-/Buffer-Angaben: Millisekunden (`DWORD`, `float`)

---

## 3. Einstiegspunkte

### 3.1 `int commonMain()`

**Beschreibung:**
Zentrale Start- und Ablauf-Funktion. Initialisiert BASS, erstellt `PlayerState`, startet ersten Track, führt Runloop aus und räumt am Ende auf.

**Signatur:**
```cpp
int commonMain();
```

**Rückgabewerte:**

| Wert | Bedeutung |
|-----:|-----------|
| 0    | Erfolg (geordneter Shutdown) |
| 1    | BASS konnte nicht initialisiert werden |
| 2    | Start des ersten Tracks fehlgeschlagen |

---

### 3.2 `int main(int argc, char* argv[])`

**Beschreibung:**
Standard-Entry-Point (Konsole). Gibt eine kurze Startmeldung aus und ruft `commonMain()` auf.

**Signatur:**
```cpp
int main(int /*argc*/, char* /*argv*/[]);
```

---

### 3.3 `int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)`

**Beschreibung:**
Alternative Entry-Funktion für GUI-Konfiguration (`APP_WINDOWS_GUI`). Ruft ebenfalls `commonMain()` auf.

**Signatur:**
```cpp
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int);
```

**Hinweis:**
Nur eingebunden, wenn `APP_WINDOWS_GUI` definiert ist.

---

### 3.4 `void RunLoop(PlayerState& ps)`

**Beschreibung:**
Haupt-Runloop für die Konsolen-Bedienung.

- Polling von Tastatureingaben via `GetAsyncKeyState`.
- Fokus-sensitives Verhalten (nur aktiv, wenn Konsole bzw. Fenster des Prozesses im Vordergrund oder nicht minimiert ist).
- Reagiert auf Hotkeys, aktualisiert PlayerState und ruft `RenderUI()` bei Änderungen.

---

## 4. Datenstrukturen

### 4.1 `struct PlayerState`

**Beschreibung:**
Kapselt den kompletten Player-Zustand:

```cpp
struct PlayerState
{
    int   trackIndex;       // aktueller Track-Index
    bool  useTempo;         // Tempo-Pipeline aktiv?
    float tempoPercent;     // aktueller Tempo-Wert in %
    DWORD tempoAlgoFlags;   // BASS_FX_TEMPO_ALGO_* Flags
    bool  reverbOn;         // Reverb aktiv?

    HSTREAM stream;         // aktuell spielbarer Stream
    HSTREAM srcDecode;      // dekodierender Quellstream (Tempo-Modus)
    HFX     reverbFx;       // Handle auf aktuellen Reverb-FX
};
```

**Initialwerte in `commonMain()`:**

- `trackIndex = 0`
- `useTempo = kUseTempoDefault` (true)
- `tempoPercent = kTempoPercentDefault` (0.0f)
- `tempoAlgoFlags = kTempoAlgoFlagsDefault` (z. B. `BASS_FX_TEMPO_ALGO_LINEAR`)
- `reverbOn = true`

---

## 5. Konfigurationskonstanten

### 5.1 Playlist / Pfade

```cpp
static const wchar_t* kMusicRoot = L"C:/.../music/";
static const wchar_t* kTracks[]  = { L"Album/Track1.mp3", ... };
static constexpr int  kTrackCount = ...;
```

- `kMusicRoot` – Basisverzeichnis aller Tracks.
- `kTracks[]` – Liste von relativen Pfaden.
- `kTrackCount` – Anzahl der Einträge.

### 5.2 Globale Defaults

```cpp
static const bool  kUseTempoDefault        = true;
static const float kTempoPercentDefault    = 0.0f;
static const DWORD kTempoAlgoFlagsDefault  = BASS_FX_TEMPO_ALGO_LINEAR;
static const DWORD kUpdatePeriodMs         = 20;
static const DWORD kBufferMs               = 900;
```

---

## 6. Hotkey-Referenz

### 6.1 Übersicht

| Taste                 | Wirkung                              |
|-----------------------|--------------------------------------|
| `Left` / `Right`      | Vorheriger / nächster Track         |
| `+` / `-`             | Tempo ±5 %                           |
| `F1` / `F2`           | SEQUENCE ±10 ms                      |
| `F3` / `F4`           | OVERLAP ±5 ms                        |
| `F5` / `F6`           | SEEKWINDOW ±10 ms                    |
| `F7`                  | QUICKALGO an/aus                     |
| `F8`                  | DX8-Reverb ein/aus                   |
| `ESC`                 | Wiedergabe stoppen & Programm beenden|

### 6.2 Wertebereiche

- Tempo: `[-95.0f, +95.0f]`
- Sequence: `[1.0f, 500.0f]` ms
- Overlap: `[1.0f, 200.0f]` ms
- Seekwindow: `[0.0f, 500.0f]` ms

---

## 7. BASS / BASS_FX Attribute

### 7.1 Tempo-Attribute

- `BASS_ATTRIB_TEMPO` – Tempo in %
- `BASS_ATTRIB_TEMPO_OPTION_SEQUENCE_MS` – Sequenzlänge in ms
- `BASS_ATTRIB_TEMPO_OPTION_OVERLAP_MS` – Überlappungszeit in ms
- `BASS_ATTRIB_TEMPO_OPTION_SEEKWINDOW_MS` – Suchfenster in ms
- `BASS_ATTRIB_TEMPO_OPTION_USE_QUICKALGO` – QuickAlgo (0/1)
- `BASS_ATTRIB_TEMPO_FREQ` – interne Verarbeitungsfrequenz

### 7.2 Reverb

- Effekt-Handle: `HFX reverbFx`
- Struktur: `BASS_DX8_REVERB`
  - `fInGain`
  - `fReverbMix`
  - `fReverbTime`
  - `fHighFreqRTRatio`

---

## 8. Logging / Debugging

### 8.1 Debug-Ausgabe

- `OutputDbg(const wchar_t* s)` – schreibt nach `OutputDebugStringW` (nur Windows).
- `ShowBassError(const wchar_t* caption)` – ermittelt `BASS_ErrorGetCode()` und schreibt Fehlermeldung + Code in Debug-Output und Konsole.

### 8.2 Version-Check

- `CheckVersionMismatch()` – vergleicht Hauptversion von BASS und BASS_FX (`(v >> 16)`), gibt ggf. Warnung aus.

### 8.3 Laufzeitstatus

- `PrintTempoState(HSTREAM stream)` – liest alle Tempo-Attribute und schreibt eine Statuszeile (Tempo, Seq, Ovl, Seek, Quick, ProcFreq) in die Konsole.

---

## 9. Siehe auch

- `Doku_consolePlayer_v0_1_0` – Architektur, Design, Audio-Pipeline.
- `UserGuide_consolePlayer_v0_1_0` – Installation, Verwendung, Troubleshooting.

---

## 10. Changelog

| Version | Datum       | Änderungen |
|--------:|------------|------------|
| **0.1.0** | 2025-12-09 | **Erste vollständige Referenz (Einstiegspunkte, PlayerState, Hotkeys, BASS-Attribute)** |

