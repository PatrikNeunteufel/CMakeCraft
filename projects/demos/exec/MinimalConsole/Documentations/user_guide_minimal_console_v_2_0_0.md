# MinimalConsole – Benutzerhandbuch

> **Version:** 2.0.0  
> **Datum:** 2025-12-08  
> **Typ:** Benutzer-Doku  
> **Status:** In Entwicklung

---

## 1. Einführung / Übersicht

`MinimalConsole` ist eine sehr einfache **BASS Audio Demo** für die Konsole. Die Anwendung:

- initialisiert die **BASS Audio Library**,
- lädt **eine** vordefinierte Musikdatei (z. B. "London Grammar - Californian Soil"),
- spielt diese Datei voll durch,
- zeigt den Fortschritt im Format `MM:SS / MM:SS` in der Konsole an,
- protokolliert alle Schritte in einer Logdatei (`minimal_console.log`).

Sie dient als **Minimalbeispiel** für:

- BASS-Init + Stream-Handling
- Integration in ein CMake-Projekt
- Grundlegende Fehlerbehandlung und Logging.

---

## 2. Voraussetzungen

### 2.1 System

- Betriebssystem: Windows oder jedes System, auf dem BASS verfügbar ist (in der Praxis meist Windows).
- Konsole/Terminal zum Starten der Anwendung.

### 2.2 BASS Runtime

Im Verzeichnis der Anwendung (oder in einem Verzeichnis im `PATH`) müssen sich befinden:

- `bass.dll`

Optional (für FLAC-Files):

- BASS FLAC Plugin (z. B. `bassflac.dll`), sofern FLAC verwendet wird.

### 2.3 Musikdatei

- Eine Musikdatei (MP3/FLAC usw.), deren Pfad zu `getMusicPath()` passt.
- Typischer Projektaufbau:
  - `music/London Grammar - Californian Soil/02 Californian Soil.mp3`

---

## 3. Installation & Setup

1. **Binary bereitstellen**
   - `MinimalConsole.exe` in ein Arbeitsverzeichnis kopieren.

2. **BASS-DLL kopieren**
   - `bass.dll` in dasselbe Verzeichnis legen **oder** sicherstellen, dass sie über `PATH` gefunden wird.

3. **Musikordner anlegen**
   - Entweder den Code von `getMusicPath()` auf deinen eigenen Pfad anpassen
   - oder die im Code erwartete Ordnerstruktur anlegen (inkl. `music/...`).

4. **(Optional) FLAC-Plugin**
   - Falls FLAC-Dateien abgespielt werden, das FLAC-Plugin für BASS installieren und einbinden.

---

## 4. Schnellstart

> Hinweis: Wenn du bereits ein fertiges Binary hast, kannst du direkt zu „Programm starten“ springen.

### 4.1 Beispiel-Build (CMake)

Aus Sicht eines CMake-Projekts könnte der Build z. B. so aussehen:

```bash
cmake -B build -S .
cmake --build build --target MinimalConsole --config Debug
```

### 4.2 Programm starten

Im Verzeichnis mit `MinimalConsole.exe` und `bass.dll`:

```bash
MinimalConsole.exe
```

Du solltest sehen:

- Eine kurze "Now Playing"-Überschrift,
- einen Hinweis zum Stoppen (Info-Text),
- eine laufende Zeile mit `Progress: MM:SS / MM:SS`.

Die Wiedergabe läuft, bis der Track von selbst endet.

---

## 5. Aufgabenorientierte Nutzung

### 5.1 Nur „spielt einen Track durch“

Die Demo ist bewusst minimal gehalten:

- Es gibt **keine interaktive Steuerung** (kein Pause, kein Skip, kein Stop).
- Der Player eignet sich dafür, schnell zu testen, ob:
  - BASS korrekt initialisiert,
  - das Audio-Device funktioniert,
  - der Pfad zur Datei stimmt,
  - der Build korrekt verlinkt ist.

### 5.2 Pfad zur Musikdatei ändern

Der Pfad wird in der Funktion `getMusicPath()` bestimmt. Dort ist eine Liste aus möglichen Pfaden
hinterlegt. Um die Demo auf andere Dateien anzupassen, kannst du:

1. Einen neuen absoluten Pfad ergänzen (z. B. `"D:/Music/test.mp3"`).
2. Die relative Pfadvariante anpassen, wenn du die Projektstruktur änderst.

Es wird immer der **erste existierende** Eintrag der Liste verwendet.

### 5.3 Fortschrittsanzeige verstehen

- Die Anzeige hat das Format `Progress: MM:SS / MM:SS`.
- Sie wird etwa einmal pro Sekunde aktualisiert.
- Die Ausgabe basiert auf der aktuellen BASS-Position im Stream.

---

## 6. Troubleshooting

### 6.1 Programm beendet sich sofort

Mögliche Ursachen:

- `bass.dll` wurde nicht gefunden oder passt nicht zur Architektur (z. B. 32-Bit vs. 64-Bit).
- BASS konnte kein Ausgabegerät initialisieren.
- Die Musikdatei existiert nicht unter einem der erwarteten Pfade.

**Vorgehen:**

1. `minimal_console.log` im Programmverzeichnis öffnen.
2. Prüfen, ob eine Meldung vom Typ
   - `"BASS_Init failed: ..."` oder
   - `"Music file not found: ..."` oder
   - `"Failed to create stream: ..."`
   vorhanden ist.
3. DLLs, Dateipfade und Audiogerät prüfen.

### 6.2 Kein Ton hörbar, obwohl das Programm läuft

Mögliche Ursachen:

- Falsches Ausgabegerät, Lautstärke im System auf 0, Mute aktiv.
- Datei wird korrekt abgespielt, aber über ein nicht erwartetes Audio-Device.

**Lösungen:**

- Systemlautstärke prüfen.
- Prüfen, ob andere Audioanwendungen Ton abspielen können.

### 6.3 "Unsupported format" / "Codec not available"

Mögliche Ursachen:

- Ungültiges oder korruptes Audioformat.
- Für FLAC fehlt das entsprechende BASS-Plugin.

**Lösungen:**

- Testweise eine einfache MP3-Datei verwenden.
- Plugin für das gewünschte Format installieren.

---

## 7. Kurzreferenz

| Bereich   | Info                                         |
|----------|----------------------------------------------|
| Plattform| Windows / BASS-fähige Systeme                |
| Engine   | BASS                                         |
| Datei    | Ein fest definierter Track (hart kodiert)    |
| Anzeige  | Fortschritt: `MM:SS / MM:SS`                 |
| Logging  | `minimal_console.log`                        |
| Beenden  | Automatisch bei Ende der Datei               |

---

## 8. Changelog

| Version | Datum       | Änderungen |
|--------:|------------|------------|
| **2.0.0** | 2025-12-08 | **Erste Ausgabe des Benutzerhandbuchs (Setup, Schnellstart, Troubleshooting)** |

