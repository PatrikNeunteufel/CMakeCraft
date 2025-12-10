# consolePlayer – Benutzerhandbuch

> **Version:** 0.1.0  
> **Datum:** 2025-12-09  
> **Typ:** Benutzer-Doku  
> **Status:** In Entwicklung

---

## 1. Einführung / Übersicht

`consolePlayer` ist ein **Konsolen-Musikplayer** für Windows, der:

- eine feste Playlist aus einem Musikordner abspielt,
- mit der **BASS Audio Library** arbeitet,
- über **BASS_FX** das Tempo (Time-Stretch) ändern kann, ohne die Tonhöhe zu verändern,
- einen **DX8-Hall (Reverb)** als Effekt zuschalten kann,
- komplett über **Tastatur-Hotkeys** gesteuert wird.

Zielgruppe sind Entwickler und Power-User, die schnell Musik mit Tempo-/Effektkontrolle testen möchten.

---

## 2. Voraussetzungen

### 2.1 System

- Betriebssystem: **Windows** (DX8 Reverb setzt DirectX voraus)
- Open-Source-/Dev-Umgebung (z. B. Visual Studio, CMake-Projekt) optional für Build

### 2.2 BASS / BASS_FX Runtime

Im Programmverzeichnis (oder in einem Verzeichnis im `PATH`) müssen liegen:

- `bass.dll`
- `bass_fx.dll`

Ohne diese DLLs kann die Anwendung nicht starten bzw. Tempo-Funktionen stehen nicht zur Verfügung.

### 2.3 Musikdateien

- Unterstützte Formate (abhängig von BASS und ggf. Plugins):
  - MP3, FLAC, usw.
- Der **Musikordner** muss zum Wert von `kMusicRoot` passen, z. B.:
  - `C:/Users/<user>/source/repos/Visuals_Project/music/`

Die in `kTracks[]` hinterlegte Playlist muss auf reale Dateien zeigen.

---

## 3. Installation & Setup

1. **Binary bereitstellen**
   - `consolePlayer.exe` in ein beliebiges Verzeichnis kopieren.

2. **DLLs bereitstellen**
   - `bass.dll` und `bass_fx.dll` in dasselbe Verzeichnis legen **oder** ein Verzeichnis im `PATH` verwenden.

3. **Musikordner anlegen**
   - Pfad entsprechend `kMusicRoot` im Code anpassen oder dazu passende Ordner- und Datei-Struktur erstellen.

4. **Playlist prüfen**
   - Sicherstellen, dass alle Einträge in `kTracks[]` als Dateien existieren.

---

## 4. Schnellstart

> Hinweis: Die Build-Schritte sind beispielhaft. Falls bereits ein fertiges Binary vorliegt, kann dieser Abschnitt übersprungen werden.

### 4.1 Beispiel-Build (CMake)

```bash
cmake -B build -S .
cmake --build build --target consolePlayer --config Release
```

### 4.2 Start des Players

Im Verzeichnis mit `consolePlayer.exe` und den DLLs:

```bash
consolePlayer.exe
```

Beim Start sollte in der Konsole u. a. stehen:

- eine Titelzeile des Players
- eine Liste der verfügbaren Hotkeys
- der aktuell ausgewählte Track mit seinem relativen Pfad

Die Wiedergabe des ersten Tracks beginnt automatisch.

---

## 5. Bedienung

### 5.1 Hotkeys

| Taste                 | Funktion                                   |
|-----------------------|--------------------------------------------|
| `Left` / `Right`      | Vorheriger / nächster Track                |
| `+` / `-`             | Tempo erhöhen / verringern (±5 %)          |
| `F1` / `F2`           | `SEQUENCE` +10 / -10 ms                     |
| `F3` / `F4`           | `OVERLAP` +5 / -5 ms                        |
| `F5` / `F6`           | `SEEKWINDOW` +10 / -10 ms                   |
| `F7`                  | Quick-Algorithmus (Tempo) an/aus           |
| `F8`                  | Reverb (DX8) ein/aus                        |
| `ESC`                 | Wiedergabe stoppen und Programm beenden    |

> Tipp: Die Änderungen werden sofort hörbar; gleichzeitig aktualisiert der Player die Konsole und zeigt die aktuellen Werte an.

### 5.2 Anzeige in der Konsole

Der Player zeigt:

- Titelzeile und kurze Beschreibung
- Hotkey-Übersicht
- Aktuellen Track (Index / Gesamtanzahl + Pfad)
- Reverb-Status (ON/OFF)
- Bei aktivem Tempo-Modus:
  - Tempo in %
  - Sequence / Overlap / SeekWindow in ms
  - QuickAlgo ON/OFF
  - interne Verarbeitungsfrequenz
- Letzte Aktion (z. B. `"tempo +5%"`, `"reverb OFF"`)

---

## 6. Tipps zur Verwendung

### 6.1 Tempo-Anpassung

- Positive Werte (z. B. +10 %) beschleunigen den Track.
- Negative Werte (z. B. -20 %) verlangsamen den Track.
- Die Grenze liegt bei etwa ±95 % (hart im Code begrenzt).

### 6.2 Fein-Tuning der Time-Stretch-Parameter

- `SEQUENCE_MS` beeinflusst die Länge der Analysefenster.
- `OVERLAP_MS` steuert, wie stark sich die Fenster überlappen.
- `SEEKWINDOW_MS` bestimmt, wie weit gesucht werden darf, um passende Fragmente zu finden.

Kleine Schritte (±5/10 ms) erlauben es, hörbare Artefakte zu reduzieren und CPU-Last zu optimieren.

### 6.3 Reverb

- Reverb kann mit `F8` ein- oder ausgeschaltet werden.
- Sinnvoll z. B. für Hall-Effekte bei Vocals oder sparsamer Atmosphäre.

---

## 7. Troubleshooting

### 7.1 Programm startet nicht / sofortiger Exit

Mögliche Ursachen:

- `bass.dll` oder `bass_fx.dll` fehlt oder ist inkompatibel.
- BASS konnte das Audio-Device nicht initialisieren.

**Maßnahmen:**

- Prüfen, ob beide DLLs im Programmverzeichnis liegen.
- Treiber und Soundkarte testen.
- Konsole auf Fehlermeldungen des Players prüfen (z. B. BASS-Errorcode).

### 7.2 Kein Ton / Track wird nicht abgespielt

Mögliche Ursachen:

- Pfad in `kMusicRoot` oder `kTracks[]` zeigt ins Leere.
- Stream-Erzeugung schlägt fehl.

**Maßnahmen:**

- Dateipfade genau prüfen.
- Sicherstellen, dass die Audiodateien in einem von BASS unterstützten Format vorliegen.

### 7.3 Artefakte bei starkem Tempo

Mögliche Ursachen:

- Extremwerte bei Tempo (nahe ±95 %).
- Ungünstige Kombination von Sequence/Overlap/Seekwindow.

**Maßnahmen:**

- Tempo wieder näher an 0 % bringen.
- Sequence/Overlap/Seekwindow schrittweise anpassen.
- QuickAlgo ggf. deaktivieren, wenn Qualität wichtiger ist als CPU-Last.

---

## 8. Kurzreferenz

| Bereich     | Info                                       |
|------------|--------------------------------------------|
| Plattform  | Windows (DX8 Reverb)                       |
| Engine     | BASS + BASS_FX                             |
| UI         | Konsole (Clear/Redraw bei jedem Event)     |
| Playlist   | statisches `kTracks[]` + `kMusicRoot`       |
| Tempo      | -95 % bis +95 %, in 5 %-Schritten          |
| Effekt     | DX8 Reverb, pro Stream zuschaltbar         |
| Beenden    | `ESC`                                      |

---

## 9. Changelog

| Version | Datum       | Änderungen |
|--------:|------------|------------|
| **0.1.0** | 2025-12-09 | **Erste Ausgabe des Benutzerhandbuchs (Setup, Hotkeys, Troubleshooting)** |

