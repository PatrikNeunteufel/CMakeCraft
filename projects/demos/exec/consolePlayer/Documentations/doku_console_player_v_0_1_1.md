# consolePlayer – Technische Dokumentation

> **Version:** 0.1.1 (doc v2)
> **Datum:** 2025-12-09
> **Typ:** Modul-Doku
> **Status:** In Entwicklung
> **Modul:** consolePlayer (BASS Console Player, `main.cpp`)
> **Modul-Version:** 0.1.0
> **Basiert auf:** Documentation_Blueprint v0.1.0

---
## 1. Solution.json-Konfiguration

Damit der **consolePlayer** im CMake-Architecture-V2-System korrekt generiert und gebaut wird,
muss im `Solution.json` im Abschnitt `executables` folgender Eintrag vorhanden sein:

```json
{
  "name": "consolePlayer",
  "version": "1.0.0",
  "dependencies": ["BasicLogger"],
  "externals": ["bass"],
  "external_options": {
    "bass": {
      "BASS_FLAC": true,
      "BASS_FX": true
    }
  }
}
```

**Bedeutung der wichtigsten Felder:**

- `dependencies: ["BasicLogger"]`: bindet den header-only **BasicLogger** ein.
- `externals: ["bass"]`: aktiviert die externe Audiobibliothek **BASS**.
- `external_options.bass.BASS_FLAC: true`: schaltet die Unterstützung für **FLAC-Dateien** frei.
- `external_options.bass.BASS_FX: true`: aktiviert **BASS_FX** für Time-Stretching, Tempo-Änderungen
  und weitere DSP-Effekte, wie in dieser Dokumentation beschrieben.

Der Executable-Typ wird wie bei anderen Konsolenanwendungen über die globalen Defaults gesetzt.

---
## 2. Übersicht

`consolePlayer` ist ein Windows-Konsolenplayer auf Basis der **BASS Audio Library** und **BASS_FX**, der:

- eine feste Playlist (UTF-16) aus einem Musik-Root-Verzeichnis abspielt,
- zwischen **normalem Playback** und **FX-Playback** (Time-Stretch, Pitch-stable) verwendet,
- einen **DX8-Reverb**-Effekt auf den FX-Kanal legen kann,
- über **Hotkeys** gesteuert wird (Play/Pause/Stop/Nächster Titel/FX-On/Off usw.),
- den Status fortlaufend in einer **Konsole** darstellt.

Die Anwendung ist bewusst als **technisches Demo-Tool** gedacht – nicht als vollwertiger Media-Player.

---
## 3. Abhängigkeiten

### 3.1 Interne Abhängigkeiten

- **BasicLogger**
  - zentraler Logger, wird früh initialisiert
  - Ausgabe in Konsole und optional Datei

### 3.2 Externe Abhängigkeiten

- **BASS** (Basis-Audio-Engine)
- **BASS_FX** (Time-Stretch, Pitch-Stable Playback)
- **BASSFLAC** (FLAC-Unterstützung)

> Hinweis: Die tatsächliche Konfiguration der BASS-Module erfolgt zentral über die Externals-/CMake-Integration
> und die `Solution.json`.

### 3.3 Systemvoraussetzungen

- Windows (Konsolenfenster erforderlich)
- BASS/BASS_FX/BASSFLAC DLLs im Suchpfad

---
## 4. Konzept / Design

### 4.1 Architektur

Die Anwendung ist als **Single Executable** mit klar getrennten Verantwortlichkeiten aufgebaut:

- **UI/Console Layer**
  - Funktionen: `ClearConsole`, `PrintTitle`, `PrintStatus`, `PrintPlaylist`, etc.
  - Darstellung von aktuellem Titel, FX-Status, Reverb-Status, Laufzeit, Fehlern

- **Player-/Audio-Layer**
  - Initialisiert BASS und BASS_FX
  - Lädt Playlist, hält aktuellen Index
  - Startet/stoppt/pausiert Wiedergabe
  - Schaltet zwischen Normal- und FX-Playback um
  - Konfiguriert Reverb-Parameter

- **Input-/Hotkey-Layer**
  - Polling von Tasten (typisch Win32: `GetAsyncKeyState`)
  - Mapping von Tasten auf Aktionen (z. B. `Space` = Play/Pause, `N` = Next, `F` = FX-Toggle)

### 4.2 Haupt-Loop

Der Main-Loop arbeitet typically wie folgt:

1. Hotkeys einlesen
2. Aktionen ausführen (Play/Pause/Next/FX/Reverb usw.)
3. Status ermitteln (aktueller Track, Zeit, FX-Status)
4. Konsole aktualisieren
5. Kurzes Sleep (CPU-Entlastung)

---
## 5. Audio-Pipeline

Die Audio-Pipeline basiert auf zwei Kernkonzepten:

- **Normaler Playback-Kanal** (ohne FX)
- **FX-Playback-Kanal** mit BASS_FX (Time-Stretch / Pitch-stable)

### 5.1 Normaler Playback-Kanal

- BASS-Stream aus Datei (MP3/FLAC/WAV etc.)
- Direkte Ausgabe an den Standard-BASS-Output
- Keine Tempo-/Pitch-Manipulation

### 5.2 FX-Playback-Kanal

- BASS_FX-Decoding + Tempo-Stream
- Tempoänderungen, Pitch-Stabilität
- Reverb-Effekt über DX8-FX-Kette

Typischer Ablauf pro Track:

1. Datei in BASS-Stream laden
2. FX-Stream aus Basis-Stream erzeugen
3. Normalen und FX-Kanal vorbereiten
4. Start je nach Modus (Normal oder FX)

### 5.3 Reverb-Effekt

- Anwendung eines DX8-Reverb-Effekts auf den FX-Kanal
- Umschaltbar per Hotkey
- Parameter vorkonfiguriert (z. B. „Raumgröße“, „Dämpfung“)

---
## 6. Playlist und Pfadhandling

- Playlist basiert auf einer Liste von Dateien in einem Musik-Root-Verzeichnis
- Pfade werden in Unicode (UTF-16) verarbeitet, um Umlaute und Sonderzeichen zu unterstützen
- Es gibt einen aktuellen Index, der auf den jeweils aktiven Track zeigt

Funktionen (schematisch):

- `LoadPlaylist(rootPath)` – erstellt die Playlist aus einem Verzeichnisbaum
- `GetCurrentTrack()` – liefert Pfad/Name des aktuellen Titels
- `NextTrack()` – erhöht Index, ggf. Wrap-Around

---
## 7. Hotkey-Handling und RunLoop

### 7.1 Hotkeys (Beispiele)

- `Space` – Play/Pause
- `S` – Stop
- `N` – Nächster Track
- `P` – Vorheriger Track (optional)
- `F` – FX-Mode an/aus
- `R` – Reverb an/aus
- `Q` – Beenden

### 7.2 RunLoop

Der RunLoop arbeitet in einer Schleife:

1. Abfragen des Hotkey-Zustands
2. Abhängig vom Tastendruck Aktionen ausführen
3. Status in der Konsole neu zeichnen
4. Kurzes Sleep (z. B. 10–30 ms) zur CPU-Entlastung

---
## 8. Fehlerbehandlung

- BASS-Rückgabewerte werden geprüft (z. B. `BASS_ErrorGetCode()`)
- Bei Fehlern erzeugt der BasicLogger Einträge auf `Error`-Level
- Typische Fehler:
  - Datei nicht gefunden
  - Nicht unterstütztes Format
  - Initialisierung von BASS/BASS_FX/BASSFLAC fehlgeschlagen

---
## 9. Best Practices

- Fehler immer loggen (Logger statt `printf`/`std::cout`)
- Bei Änderungen an der Audio-Pipeline konsequent testen (Normal/FX/Reverb)
- Pfad- und Unicode-Behandlung sauber halten
- BASS-DLLs klar im Projekt/Deployment strukturieren

---
## 10. Bekannte Einschränkungen

- Nur unter Windows voll lauffähig
- Kein GUI, reine Konsolensteuerung
- Keine komplexe Playlist-Verwaltung (z. B. Shuffle, Repeat-Listen)

---
## 11. Migration von früheren Versionen

- Prüfen, ob zusätzliche BASS-Plugins (z. B. BASSFLAC, BASS_FX) benötigt werden
- Sicherstellen, dass die Solution.json-Einträge für Externals vollständig sind
- Logging-Pfade und -Level prüfen

---
## 12. Siehe auch

- **MinimalConsole** – einfache Konsolenanwendung mit BasicLogger
- **imGuiApp** – ImGui-basierte GUI-Demo mit OpenGL
- **BasicLogger** – gemeinsame Logging-Basis

---
## 13. Changelog

- **0.1.1 (doc v2)** – Solution.json-Konfiguration ergänzt, Kapitelstruktur angepasst
- **0.1.0 (doc v1)** – Initiale Dokumentation für consolePlayer

