# MinimalConsole – Technische Dokumentation

> **Modul:** MinimalConsole (C++ Konsolenanwendung)
> **Version:** 2.0.1
> **Status:** Demo / Beispiel
> **Datum:** 2025-12-09

---
## 1. Solution.json-Konfiguration

Damit die Anwendung **MinimalConsole** im CMake-Architecture-V2-System korrekt generiert und gebaut wird,
muss im `Solution.json` im Abschnitt `executables` folgender Eintrag vorhanden sein:

```json
{
  "name": "MinimalConsole",
  "version": "2.0.0",
  "dependencies": ["BasicLogger"],
  "externals": ["bass"],
  "external_options": {
    "bass": {
      "BASS_FLAC": true
    }
  }
}
```

**Bedeutung der Felder:**

- `name`: Name der Executable; identisch mit dem CMake-Zielnamen.
- `version`: Versionskennzeichnung im Solution-System (unabhängig von dieser Dokumentenversion 2.0.1).
- `dependencies: ["BasicLogger"]`: bindet die header-only Library **BasicLogger** ein.
- `externals: ["bass"]`: aktiviert die externe Audiobibliothek **BASS**.
- `external_options.bass.BASS_FLAC: true`: stellt sicher, dass BASS mit **FLAC-Unterstützung** gebaut/gelinkt wird.

Der Executable-Typ (`CONSOLE`) wird über die globalen Defaults (`settings.defaults.executable_type`) gesetzt
und muss im Eintrag nicht explizit angegeben werden.

---

## 2. Übersicht

**MinimalConsole** ist eine einfache Konsolenanwendung, die primär als Beispiel- und Test-Executable dient.
Sie demonstriert

- die Einbindung des **BasicLogger**
- den Zugriff auf die BASS-Bibliothek (z. B. erste Audiotests)
- die grundsätzliche Struktur eines C++-Konsolenprogramms im Architektur-V2-System

---

## 3. Ziele und Einsatzzweck

- Minimaler Einstiegspunkt für neue Konsolen-Apps
- Testen von Logging-Funktionalität (BasicLogger)
- Basis für spätere Erweiterungen (Audio, Tools, Scripts)

---

## 4. Architektur und Aufbau

- Einstiegspunkt: klassisches `int main(int argc, char* argv[])`
- Frühe Initialisierung des **BasicLogger** (Konfiguration von Log-Level und Ausgabemedien)
- Optionale Initialisierung von BASS (sofern im jeweiligen Beispielcode genutzt)

Die Anwendung ist bewusst klein gehalten und soll als Vorlage für weitere Konsolenprojekte dienen.

---

## 5. Abhängigkeiten

### 5.1 Interne Abhängigkeiten

- **BasicLogger** (header-only)

### 5.2 Externe Abhängigkeiten

- **BASS** (Audio Library)
- Optional: BASS-Plugins wie `BASSFLAC`, je nach Beispielcode

Die Konfiguration der externen Abhängigkeiten erfolgt zentral über `Solution.json`
und die Externals-Mechanik des Buildsystems.

---

## 6. Initialisierung und Programmablauf

Typischer Programmablauf in `MinimalConsole`:

1. Start von `main()`
2. Initialisierung des BasicLogger (z. B. Setzen von Log-Level und Ausgabezielen)
3. Optional: Initialisierung von BASS (Audio-Subsystem)
4. Ausführung der eigentlichen Beispiel-/Testlogik
5. Aufräumen und geordneter Programmende

---

## 7. Logging-Beispiele

Schematischer Beispielcode (abhängig von der konkreten Implementierung des BasicLogger):

```cpp
#include <BasicLogger.h>

int main()
{
    LOG_INFO("MinimalConsole started");

    // Beispiel: Warnung
    LOG_WARNING("This is a demo warning message");

    // Beispiel: Fehler
    LOG_ERROR("This is a demo error message");

    return 0;
}
```

---

## 8. Erweiterungsmöglichkeiten

- Einbau von Kommandozeilenparametern
- Erweiterte Audiofunktionen (Wiedergabe, Analyse) über BASS
- Integration weiterer Libraries (z. B. Parser, Tools)

---

## 9. Wartung und Versionierung

- Diese Dokumentation beschreibt den Stand der Anwendung **MinimalConsole** in Version **2.0.1**.
- Die Solution.json-Konfiguration referenziert weiterhin `version: "2.0.0"`, was für den Build ausreichend ist.
  Eine Angleichung von Code-/Doku-Version und Solution.json-Version kann bei Bedarf separat erfolgen.

