# consolePlayer – Technische Dokumentation

> **Version:** 0.1.0 (doc v1)
> **Datum:** 2025-12-09
> **Typ:** Modul-Doku
> **Status:** In Entwicklung
> **Modul:** consolePlayer (BASS Console Player, `main.cpp`)
> **Modul-Version:** 0.1.0
> **Basiert auf:** Documentation_Blueprint v0.1.0

---

## 1. Übersicht

`consolePlayer` ist ein Windows-Konsolenplayer auf Basis der **BASS Audio Library** und **BASS_FX**, der:

- eine feste Playlist (UTF-16) aus einem Musik-Root-Verzeichnis abspielt,
- wahlweise eine **Tempo-Pipeline** (Time-Stretch, Pitch-stable) verwendet,
- einen **DX8-Reverb**-Effekt auf den Ausgabekanal legen kann,
- über **Hotkeys** komplett in der Konsole gesteuert wird,
- bei jeder Interaktion die Konsole **vollständig neu zeichnet** (Titel, Menü, Status).

Ziel ist ein kompaktes, aber robustes Beispiel für:

- BASS + BASS_FX Integration mit Unicode-Pfaden,
- Echtzeit-Tempoanpassung und Fine-Tuning der Time-Stretch-Parameter,
- DX8-Effekte auf einem Stream (Reverb),
- stabilen Konsolen-UI-Loop mit Hotkey-Polling.

---

## 2. Abhängigkeiten

### 2.1 Interne Abhängigkeiten

- `pch.h`
  - Enthält Standard-Header (z. B. `<iostream>`) und projektspezifische Includes.

### 2.2 Externe Bibliotheken

- **BASS** (`bass.h`, `bass.lib`, `bass.dll`)
  - Audiowiedergabe, Stream-Erzeugung, Buffer-Konfiguration
  - Initialisierung via `BASS_Init()`
- **BASS_FX** (`bass_fx.h`, `bass_fx.lib`, `bass_fx.dll`)
  - Tempo-/Pitch-Effekte (Time-Stretch)
  - `BASS_FX_TempoCreate()`, zusätzliche Attribute
- **Win32 API** (nur Windows)
  - `windows.h`, Konsolenmanipulation (Clear, Cursor, Buffer), Hotkeys (`GetAsyncKeyState`), Fensterzustand

Hinweis: Auf Nicht-Windows-Systemen sind weite Teile stubbed/ignored, realer Betrieb ist praktisch nur unter Windows vorgesehen.

---

## 3. Konzept / Design

### 3.1 Architektur

Die Anwendung ist als **Single Executable** mit klar getrennten Verantwortlichkeiten aufgebaut:

- **UI/Console Layer**
  - Funktionen: `ClearConsole`, `PrintTitle`, `PrintMenu`, `RenderUI`
  - Zeichnet die komplette Oberfläche nach jedem relevanten Event neu
- **Audio Layer (BASS/BASS_FX)**
  - Initialisierung: `BASS_SetConfig`, `BASS_Init`, `CheckVersionMismatch`
  - Stream-Erzeugung: `CreatePlayableStream`, `StartTrack`, `StopAndFree`
  - Effektverarbeitung: `ApplyDx8Reverb`, `SetInitialTempoTuning`, `PrintTempoState`
- **State Management**
  - Struktur `PlayerState` hält alle laufzeitrelevanten Parameter
- **Main Loop / Input**
  - `RunLoop` pollt Hotkeys (mit Toleranz gegenüber Fokusverlust), reagiert auf Eingaben und aktualisiert die UI.

### 3.2 Design-Entscheidungen

- **Console-only UI**: Kein MessageBox, kein GUI-Framework. Alle Meldungen über Konsole und (optional) Debug-Output.
- **Konsequentes Clear/Redraw**: Statt "diff-basiertem" Update wird bei jeder relevanten Änderung der komplette Screen neu aufgebaut – einfach, robust, ideal für ein Demo.
- **Tolerantes Fokus-Handling**: Die Eingabelogik berücksichtigt, ob die Konsole aktiv ist. Dadurch wird verhindert, dass Hotkeys im Hintergrund versehentlich ausgelöst werden.
- **Tempo-Pipeline optional**: Das System kann entweder einen **Tempo-Stream** (dekodierende Quelle + FX-Pipeline) oder einen einfachen "plain" Stream verwenden.

---

## 4. Audio-Pipeline

### 4.1 Grundinitialisierung

- `BASS_SetConfig(BASS_CONFIG_UPDATEPERIOD, kUpdatePeriodMs)` – klein halten für reaktive Wiedergabe.
- `BASS_SetConfig(BASS_CONFIG_BUFFER, kBufferMs)` – ausreichend groß, um Dropouts bei starken Tempoänderungen zu vermeiden.
- `BASS_Init(-1, 44100, 0, nullptr, nullptr)` – globales Device, 44.1 kHz.

### 4.2 Stream-Erzeugung (mit Tempo)

1. `BASS_StreamCreateFile(..., BASS_STREAM_DECODE | BASS_UNICODE)` erzeugt einen **dekodierenden Quellstream** (`srcDecode`).
2. `BASS_FX_TempoCreate(srcDecode, BASS_FX_FREESOURCE | tempoAlgoFlags)` erstellt einen **Tempo-Stream**.
3. `SetInitialTempoTuning()` setzt Starttempo (0%), Sequence, Overlap, SeekWindow und QuickAlgo.
4. `BASS_ChannelPlay(tempoStream, FALSE)` startet die Wiedergabe.

### 4.3 Stream-Erzeugung (ohne Tempo)

- Direktes `BASS_StreamCreateFile(..., BASS_UNICODE)` ohne Dekodier-Flag
- Keine BASS_FX-Tempo-Stufe, geringere Latenz und CPU-Last.

### 4.4 Reverb-Pipeline (DX8)

- `ApplyDx8Reverb(chan, enable, fxHandle)`:
  - Bei Aktivierung: `BASS_ChannelSetFX(BASS_FX_DX8_REVERB, 0)`
  - Parameter über `BASS_FXGetParameters` / `BASS_FXSetParameters` angepasst:
    - `fInGain`, `fReverbMix`, `fReverbTime`, `fHighFreqRTRatio`
  - Bei Deaktivierung: `BASS_ChannelRemoveFX`

---

## 5. Playlist und Pfadhandling

- `kMusicRoot` definiert das **Basisverzeichnis** für alle Tracks.
- `kTracks[]` ist ein statisches Array aus `const wchar_t*` und enthält relative Pfade (inkl. Unterordner, Albumstruktur, FLAC/MP3).
- `JoinPath()` konkateniert `kMusicRoot` + Track-Relativpfad (ohne zusätzliche Separator-Logik, weil `kMusicRoot` bereits mit `/` bzw. `\\` endet).
- `kTrackCount` wird über `sizeof(kTracks)/sizeof(kTracks[0])` ermittelt.

Die Tracknavigation erfolgt über `trackIndex` im `PlayerState` und modulare Arithmetik für Vor/Zurück mit Wrap-Around.

---

## 6. Hotkey-Handling und RunLoop

### 6.1 Eingabekonzept

- Nutzung von `GetAsyncKeyState(vk)` mit Maskierung `0x0001` für "wurde seit letztem Check gedrückt".
- Alle relevanten Keys werden pro Tick geprüft, typische Ticks von 10 ms (`Sleep(10)`).
- ESC (`VK_ESCAPE`) beendet die Anwendung.

### 6.2 Unterstützte Hotkeys

- `[Left] / [Right]` – vorheriger / nächster Track, startet jeweils den neuen Track direkt.
- `+ / -` – Tempo in 5%-Schritten, begrenzt auf [-95%, +95%].
- `F1 / F2` – `SEQUENCE_MS` ±10 ms.
- `F3 / F4` – `OVERLAP_MS` ±5 ms.
- `F5 / F6` – `SEEKWINDOW_MS` ±10 ms.
- `F7` – Umschalten Quick-Algorithmus (ON/OFF).
- `F8` – Reverb ON/OFF.
- `ESC` – Stop + Exit.

### 6.3 UI-Redraw

- Jede relevante Änderung (Track, Tempo, Parameter, Reverb, Fokuswechsel) setzt `changed = true` und führt zu einem `RenderUI()` Aufruf.
- `RenderUI()` ruft u. a. `PrintTempoState()` auf, um den aktuellen DSP-Zustand anzuzeigen.

---

## 7. Fehlerbehandlung

- **Initialisierung**
  - BASS-Init-Fehler → `ShowBassError("Failed to init BASS")`, Rückgabecode `1`.
  - Stream-Fehler → `ShowBassError("Create ... failed")`, Rückgabecode `2`.
- **Laufzeit**
  - Playback-Fehler `BASS_ChannelPlay` → Fehlermeldung + Stop/Freigabe des Streams.
- **BASS Version Mismatch**
  - `CheckVersionMismatch()` prüft Hauptversion von BASS vs BASS_FX und gibt Warnung über `OutputDbg` aus.

Die eigentlichen BASS-Fehlercodes werden über `BASS_ErrorGetCode()` ermittelt und in `ShowBassError()` formatiert.

---

## 8. Best Practices

- `BASS_SetConfig()` **vor** `BASS_Init()` aufrufen.
- Für Tempo-Pipeline immer einen **dekodierenden** Quellstream verwenden.
- `BASS_FX_TempoCreate()` mit sinnvollen Flags (z. B. `BASS_FX_FREESOURCE`) aufrufen, um Ressourcenlecks zu vermeiden.
- Bei Trackwechsel immer `StopAndFree()` ausführen, bevor ein neuer Stream erzeugt wird.
- Hotkeys nur auswerten, wenn die Konsole (bzw. ein Fenster desselben Prozesses) aktiv ist.
- DX8-Effekte nur unter Windows verwenden; unter anderen Systemen frühzeitig stummschalten bzw. ausklammern.

---

## 9. Bekannte Einschränkungen

- Plattformfokus: Windows; Linux/macOS haben keine vollständige Funktionsabdeckung.
- Keine CLI-Argumentverarbeitung (z. B. für Playlists, Pfadangaben, Optionen).
- Kein automatisches Handling, falls `kMusicRoot` oder Tracks nicht existieren.
- Keine Lautstärke-/Balance-Steuerung, nur Tempo und Reverb.

---

## 10. Migration von früheren Versionen

`v0.1.0` ist die erste dokumentierte Version – keine Migration nötig.

---

## 11. Siehe auch

- `Referenz_consolePlayer_v0_1_0` – Detailreferenz für Funktionen, State und Hotkeys.
- `UserGuide_consolePlayer_v0_1_0` – Anleitung zur Installation, Konfiguration und Bedienung.

---

## 12. Changelog

| Version | Datum       | Änderungen |
|--------:|------------|------------|
| **0.1.0** | 2025-12-09 | **Initiale technische Dokumentation (Architektur, Audio-Pipeline, RunLoop, Fehlerbehandlung)** |

