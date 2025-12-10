# MinimalConsole – Technische Dokumentation

> **Version:** 2.0.0 (doc v1)  
> **Datum:** 2025-12-08  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung  
> **Modul:** MinimalConsole (BASS Audio Player Demo, `main.cpp`)  
> **Modul-Version:** 2.0.0  
> **Basiert auf:** Documentation_Blueprint v0.1.0

---

## 1. Übersicht

`MinimalConsole` ist eine kompakte **Konsolen-Demoanwendung**, die die Integration der
**BASS Audio Library** in das CMake Architecture V2 Projekt zeigt.

Kernfunktionen:

- Initialisiert BASS mit Standard-Audiogerät (44100 Hz)
- Lädt **eine** vordefinierte Audiodatei (MP3/FLAC, je nach BASS/Plugin)
- Spielt den Stream bis zum Ende ab
- Zeigt im Terminal eine einfache Fortschrittsanzeige `MM:SS / MM:SS`
- Protokolliert alle wichtigen Schritte über `BasicLogger` in eine Logdatei

Ziel:

- Minimaler, aber realer **End-to-End-Pfad** von CMake → BASS-Init → Stream → Playback → Cleanup.

---

## 2. Abhängigkeiten

### 2.1 Interne Abhängigkeiten

- `BasicLogger`  
  - Header: `<BasicLogger.h>`  
  - Wird für alle Logausgaben (Init, Fehler, Status) verwendet.

### 2.2 Externe Bibliotheken

- **BASS**
  - Header: `<bass.h>`
  - Lib/DLL: `bass.lib` / `bass.dll`
  - Verwendet für: Initialisierung, Stream-Erzeugung, Playback, Längen-/Positionsabfragen.

- **(Optional) BASS FLAC Plugin**
  - Falls FLAC-Dateien abgespielt werden sollen, muss das FLAC-Plugin für BASS vorhanden und korrekt eingebunden sein.

### 2.3 Standardbibliothek

- `<iostream>`, `<string>` – Konsolenausgabe, String-Verarbeitung
- `<thread>`, `<chrono>` – Zeitsteuerung für Fortschrittsanzeige
- `<filesystem>` – Dateipfaderkennung (`fs::exists`)

---

## 3. Konzept / Design

### 3.1 Single-File-Demo

Die komplette Anwendungslogik befindet sich in `main.cpp`. Dadurch lässt sich das Beispiel leicht
in andere Projekte kopieren oder für Tutorials nutzen.

### 3.2 Phasenstruktur im `main()`

1. **Logger initialisieren**
2. **BASS-Version ausgeben** und BASS initialisieren
3. **Pfad zur Musikdatei ermitteln** (`getMusicPath()` + `std::filesystem::exists`)
4. **Stream erzeugen** (`BASS_StreamCreateFile`)
5. **Stream-Informationen** (Format, Dauer) loggen
6. **Wiedergabe starten** (`BASS_ChannelPlay`)
7. **Fortschritts-Schleife**: Laufende Wiedergabe mit positiver Zeit/Restzeit-Ausgabe
8. **Aufräumen**: Stream stoppen/freigeben, BASS freigeben, Logger-Abschluss

### 3.3 Verhalten bei Fehlern

- Jeder kritische Schritt (BASS-Init, Stream-Erzeugung, Playback-Start) ist abgesichert.
- Fehler führen zu:
  - Logeintrag mit klarer Beschreibung + BASS-Fehlertyp über `getBassError()`
  - Frühzeitigem `return` mit Fehlercode
  - Sauberem Release von BASS-Ressourcen (falls bereits initialisiert)

---

## 4. BASS-Integration

### 4.1 Initialisierung

- Version:
  - `DWORD bassVersion = BASS_GetVersion();`
  - Ausgabe als `<HIWORD>.<LOWORD>` in das Log

- Init:
  - `BASS_Init(-1, 44100, 0, nullptr, nullptr);`
  - `-1` → Standardausgabegerät
  - `44100` → Sample Rate

Fehlerfall:

- `BASS_Init` gibt `FALSE` zurück
- `BASS_ErrorGetCode()` wird ausgelesen
- Fehlertext über `getBassError()` bestimmt
- Logeintrag + Beenden mit `return 1`.

### 4.2 Streamerzeugung & Format

```cpp
HSTREAM stream = BASS_StreamCreateFile(
    FALSE,                 // nicht aus Speicher
    musicPath.c_str(),     // Pfad zur Datei
    0,                     // Offset
    0,                     // Länge (0 = gesamte Datei)
    BASS_SAMPLE_FLOAT      // Gleitkomma-Samples
);
```

- Bei Erfolg: `stream != 0`
- Formatabfrage:
  - `BASS_ChannelGetInfo(stream, &info)`
  - Log: `info.freq` (Hz) und `info.chans` (Kanäle)

### 4.3 Dauer & Fortschritt

- Gesamtdauer:
  - `lengthBytes = BASS_ChannelGetLength(stream, BASS_POS_BYTE)`
  - `lengthSeconds = BASS_ChannelBytes2Seconds(stream, lengthBytes)`

- Laufende Position:
  - `posBytes = BASS_ChannelGetPosition(stream, BASS_POS_BYTE)`
  - `posSeconds = BASS_ChannelBytes2Seconds(stream, posBytes)`

Formatierung erfolgt mit `formatTime(double seconds)` in `MM:SS`.

### 4.4 Wiedergabe und Zustände

- Start:
  - `BASS_ChannelPlay(stream, FALSE)`

- Laufender Zustand:
  - `BASS_ChannelIsActive(stream)`
  - Abbruch der Schleife, wenn Zustand != `BASS_ACTIVE_PLAYING`.

### 4.5 Cleanup

1. `BASS_ChannelStop(stream)`
2. `BASS_StreamFree(stream)`
3. `BASS_Free()`

---

## 5. Logger-Integration

- Loggerinstanz:

```cpp
BasicLogger::Logger logger("minimal_console.log");
logger.setLevel(BasicLogger::Level::Debug);
logger.setConsoleOutput(false);
```

- Alle wichtigen Ereignisse werden in `minimal_console.log` aufgezeichnet:
  - Start der Anwendung
  - BASS-Version
  - Erfolg/Misserfolg von `BASS_Init`
  - Pfad zur Audiodatei
  - Stream-Format (Frequenz, Kanäle)
  - Dauer der Datei
  - Start/Ende der Wiedergabe
  - BASS-Fehler mit Klartextbeschreibung

---

## 6. Pfadstrategie (`getMusicPath`)

Die Musikdatei soll an möglichst wenig Stellen konfiguriert werden müssen. Deshalb versucht
`getMusicPath()` mehrere Optionen nacheinander:

1. Ein absoluter, entwicklerspezifischer Pfad (z. B. persönlicher Projektordner)
2. Ein relativer Pfad zur `music`-Struktur aus Sicht des Build-Verzeichnisses
3. Ein generischer Fallback (z. B. `music/...`)

Erste gefundene existierende Datei (`fs::exists(path) == true`) wird verwendet.

Falls keine Variante existiert:

- Wird trotzdem ein Pfad zurückgegeben (Option 0),
- aber beim erneuten `fs::exists(musicPath)`-Check in `main()` wird der Fehler sauber behandelt
  (Log + Hinweis zur Pfadkorrektur).

---

## 7. Wiedergabe-Loop & Fortschrittsanzeige

- Schleife läuft, solange `BASS_ChannelIsActive(stream) == BASS_ACTIVE_PLAYING`.
- Alle 100 ms wird geschlafen (`std::this_thread::sleep_for(100ms)`).
- Einmal pro Sekunde (über `std::chrono::steady_clock`) wird die aktuelle Position gelesen und
der Fortschritt in der Konsole als `"Progress: MM:SS / MM:SS"` angezeigt.
- Die Schleife endet entweder automatisch, wenn der Track fertig ist, oder wenn der Stream in einem
Fehlerzustand landet.

Hinweis: Der Konsolentext weist auf `Press Enter to stop playback...` hin, aktuell wird die
Wiedergabe aber nicht explizit durch Enter beendet, sondern läuft bis zum Ende durch.

---

## 8. Fehlerbehandlung / Return-Codes

- `return 0` – Erfolgreiches Beenden (Playback wurde gestartet und geordnet beendet)
- `return 1` – Allgemeiner BASS-Fehler (Init, File, Stream, Play)
- Weitere Differenzierung könnte in künftigen Versionen ergänzt werden (z. B. unterschiedliche Codes
  für Init-Fehler vs. Stream-Fehler).

Fehlertexte werden über `getBassError(int errorCode)` in lesbare, englische Beschreibungen übersetzt.

---

## 9. Best Practices

- Vor Einsatz in anderen Projekten Pfadlogik in `getMusicPath()` an die jeweilige Projektstruktur anpassen.
- Sicherstellen, dass zur Zielplattform passende BASS-DLLs vorhanden sind (32-/64-Bit).
- Bei Einsatz als Vorlage für größere Player:
  - Lautstärkeregelung, Pause/Resume und Fehler-UI ergänzen.
  - GUI-Oberfläche oder ImGui-Integration hinzufügen.

---

## 10. Bekannte Einschränkungen

- Nur **ein** fest kodierter Track wird abgespielt.
- Keine Unterstützung für Playlists oder Benutzerinteraktion (abgesehen vom Beenden durch Track-Ende).
- Keine explizite Abfrage von Benutzereingaben (Enter-Taste wird aktuell nicht ausgewertet).
- Kein visuelles Feedback außer Fortschrittszeile im Terminal.

---

## 11. Migration von früheren Versionen

- `v2.0.0` ist die erste dokumentierte Version in diesem Blueprint-Kontext.
- Frühere Versionen (z. B. 1.x) werden nicht als stabiler Referenzstand betrachtet.

---

## 12. Siehe auch

- `Referenz_MinimalConsole_v2_0_0` – Funktions- und Parameterreferenz.
- `UserGuide_MinimalConsole_v2_0_0` – Anleitung zum Bauen, Starten und Verwenden.

---

## 13. Changelog

| Version | Datum       | Änderungen |
|--------:|------------|------------|
| **2.0.0** | 2025-12-08 | **Erste detaillierte technische Dokumentation (BASS-Integration, Pfadstrategie, Playback-Loop, Logger)** |

