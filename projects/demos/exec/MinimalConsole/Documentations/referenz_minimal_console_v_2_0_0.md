# MinimalConsole – Referenz

> **Version:** 2.0.0  
> **Datum:** 2025-12-08  
> **Typ:** Referenz-Doku  
> **Status:** In Entwicklung

---

## 1. Übersicht / Einleitung

Diese Referenz beschreibt die wichtigsten Funktionen, Konstanten und Abläufe der Demo-Anwendung
`MinimalConsole`. Sie richtet sich primär an Entwickler, die:

- die BASS-Integration verstehen oder wiederverwenden möchten,
- Pfad- und Fehlerbehandlung nachvollziehen wollen,
- das Verhalten von `main()` präzise kennen müssen.

---

## 2. Konventionen

- Rückgabewerte von `main()`:
  - `0` = Erfolg
  - `1` = Fehler (BASS-Init, Datei nicht gefunden, Stream-/Play-Error)
- Zeitangaben: Sekunden (`double`) oder Millisekunden (`std::chrono`)
- Pfade: `std::string` (UTF-8 / ANSI, je nach Plattform/Build)

---

## 3. Funktionen

### 3.1 `std::string getMusicPath()`

**Beschreibung:**
Ermittelt den benutzten Pfad zur Audiodatei. Testet mehrere Kandidaten und gibt den ersten existierenden
Pfad zurück. Falls keiner existiert, wird trotzdem ein sinnvoller Standardpfad (Index 0 der Liste)
zurückgegeben, damit die Fehlerbehandlung in `main()` eine klare Meldung generieren kann.

**Signatur:**
```cpp
std::string getMusicPath();
```

**Logik (vereinfacht):**

1. Liste möglicher Pfade (absolut + relativ)
2. Schleife `for (path : paths)` → `if (fs::exists(path)) return path;`
3. Fallback: `return paths[0];`

---

### 3.2 `std::string formatTime(double seconds)`

**Beschreibung:**
Formatiert eine Zeit in Sekunden als String `"MM:SS"`.

**Signatur:**
```cpp
std::string formatTime(double seconds);
```

**Beispiel:**

- Input: `125.3` → Output: `"02:05"`

---

### 3.3 `const char* getBassError(int errorCode)`

**Beschreibung:**
Übersetzt einen BASS-Fehlercode (z. B. von `BASS_ErrorGetCode()`) in einen lesbaren englischen
Fehlertext, etwa `"Memory error"`, `"Can't open file"`, `"Unsupported format"`, `"Version mismatch"` usw.

**Signatur:**
```cpp
const char* getBassError(int errorCode);
```

**Hinweis:**
Nicht alle BASS-Fehlercodes sind abgedeckt, aber gängige Fälle werden abgebildet. Unbekannte Codes
werden als `"Unknown error"` zurückgegeben.

---

### 3.4 `int main()`

**Beschreibung:**
Zentrale Funktion der Anwendung. Führt BASS-Init, Dateiprüfung, Stream-Erzeugung, Playback,
Fortschrittsanzeige und Cleanup durch.

**Signatur:**
```cpp
int main();
```

**Rückgabewerte:**

| Wert | Bedeutung |
|-----:|-----------|
| 0    | Erfolg (Playback lief und wurde geordnet beendet) |
| 1    | Fehler bei BASS-Init, Datei nicht gefunden, Stream-Erzeugung oder Playback-Start |

---

## 4. Wichtige Ablaufschritte in `main()`

1. **Logger einrichten**
   - `BasicLogger::Logger logger("minimal_console.log");`
   - Level → Debug, Konsolenausgabe → aus.
2. **BASS-Version protokollieren**
   - `DWORD bassVersion = BASS_GetVersion();`
3. **BASS initialisieren**
   - `BASS_Init(-1, 44100, 0, nullptr, nullptr);`
4. **Musikpfad ermitteln**
   - `std::string musicPath = getMusicPath();`
5. **Existenz der Datei prüfen**
   - `if (!fs::exists(musicPath)) { ...; return 1; }`
6. **Stream erzeugen**
   - `HSTREAM stream = BASS_StreamCreateFile(...);`
7. **Stream-Info + Dauer abfragen**
   - `BASS_ChannelGetInfo()`, `BASS_ChannelGetLength()`, `BASS_ChannelBytes2Seconds()`.
8. **Wiedergabe starten**
   - `BASS_ChannelPlay(stream, FALSE);`
9. **Fortschritt anzeigen**
   - Schleife mit `BASS_ChannelIsActive()` + `BASS_ChannelGetPosition()` + Ausgabe über `std::cout`.
10. **Cleanup**
    - `BASS_ChannelStop(stream);`
    - `BASS_StreamFree(stream);`
    - `BASS_Free();`

---

## 5. BASS-spezifische Details

### 5.1 Stream-Erstellung

```cpp
HSTREAM stream = BASS_StreamCreateFile(
    FALSE,
    musicPath.c_str(),
    0,
    0,
    BASS_SAMPLE_FLOAT
);
```

- `FALSE` → Stream aus Datei, nicht aus Speicher.
- `BASS_SAMPLE_FLOAT` → Gleitkomma-Samples (hohe Qualität, gut für DSP).

### 5.2 Statusabfrage

- Zustand ermitteln:
  - `DWORD state = BASS_ChannelIsActive(stream);`
- Typische Werte:
  - `BASS_ACTIVE_PLAYING` – aktiv
  - andere Werte → beendet / Fehler / gestoppt

### 5.3 Zeitumrechnung

- Gesamtlänge in Bytes → Sekunden:
  - `QWORD lengthBytes = BASS_ChannelGetLength(stream, BASS_POS_BYTE);`
  - `double lengthSeconds = BASS_ChannelBytes2Seconds(stream, lengthBytes);`

- Position analog mit `BASS_ChannelGetPosition()`.

---

## 6. Logger-Verhalten

- Logdatei: `minimal_console.log` im aktuellen Arbeitsverzeichnis.
- Level: **Debug** (alle Events, inkl. Details zu BASS-Version, Format, Dauer).
- Konsole: wird bewusst nicht für Logger-Meldungen genutzt, sondern nur für User-Ausgaben (Titel, Fortschritt).

Typische Einträge:

- `=== MinimalConsole v2.0.0 - BASS Audio Demo ===`
- `Initializing BASS Audio Library...`
- `BASS Version: <x.y>`
- `BASS initialized successfully`
- `Loading: <musicPath>`
- `Format: <freq> Hz, <chans> channels`
- `Duration: MM:SS`
- `Starting playback...`
- `Stopping playback...`
- `Releasing BASS...`
- `=== MinimalConsole finished ===`

---

## 7. Exitcodes

Zur Integration in Skripte oder Testumgebungen sind die Exitcodes von `main()` relevant:

| Code | Bedeutung                            |
|-----:|--------------------------------------|
| 0    | Erfolg                               |
| 1    | Fehler (BASS-Init/File/Stream/Play)  |

Eine feinere Unterteilung (z. B. unterschiedliche Codes pro Fehlerart) wäre in späteren Versionen denkbar.

---

## 8. Siehe auch

- `Doku_MinimalConsole_v2_0_0` – Gesamtarchitektur, BASS-Integration, Pfadstrategie.
- `UserGuide_MinimalConsole_v2_0_0` – Verwendung, Voraussetzungen, Troubleshooting.

---

## 9. Changelog

| Version | Datum       | Änderungen |
|--------:|------------|------------|
| **2.0.0** | 2025-12-08 | **Erste vollständige Referenz (Funktionen, Ablaufschritte, BASS-Details)** |

