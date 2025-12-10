# MinimalWindow – Technische Dokumentation

> **Version:** 0.1.1 (doc v1)  
> **Datum:** 2025-12-09  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung  
> **Modul:** MinimalWindow (Win32 GUI Demo mit Logger, `main.cpp`)  
> **Modul-Version:** 0.1.1  

---

## 1. Übersicht

`MinimalWindow` ist eine **einfache Win32 GUI-Anwendung**, die zeigt:

- Fenstererstellung per WinAPI (Wide / Unicode)
- Menüleiste mit 3 Kategorien (File, Action, Help)
- Menücommands via `WM_COMMAND`
- BasicLogger als **Live-Logging-Konsole** über eigene Console (UTF‑8)
- MessageBox-Dialog (About)

Damit dient die App als **Minimal-Vorlage für GUI‑Projekte**, die:

- Logging **sichtbar, während die GUI läuft**, ausgeben möchten
- Menücommand‑Routing implementieren
- Unicode unterstützen (Wide API)

---

## 2. Abhängigkeiten

### 2.1 Interne Abhängigkeit

- `BasicLogger`  
  - Logging in Konsole (stdout/stderr)
  - Level-Konfiguration über `setLogLevel`

### 2.2 Externe

- **Windows API** (`windows.h`)
  - Fenster, Menü, Events (WM_COMMAND / WM_CLOSE / WM_DESTROY)
  - MessageBox
  - Console handling (AllocConsole)

Keine weiteren externen Bibliotheken.

---

## 3. Architektur / Aufbau

### 3.1 Hauptkomponenten

| Komponente | Aufgabe |
|----------|--------|
| `CreateLoggingConsole()` | Erstellt separate UTF‑8 Konsole für Logs |
| `WindowProc()` | Eventverarbeitung für Commands & Lifecycle |
| `CreateMainMenu()` | Erzeugt Menübar + File/Action/Help |
| `WinMain()` | Start, Registrierung, Fenstererzeugung, MessageLoop |

### 3.2 Fenster-Lifecycle

1️⃣ `RegisterClassW` – Registrierung eines Window-Types  
2️⃣ `CreateWindowExW` – echtes Top-Level-Fenster  
3️⃣ `ShowWindow` + `UpdateWindow`  
4️⃣ Message-Loop (`GetMessageW`, `DispatchMessageW`)  
5️⃣ `WM_CLOSE` → `DestroyWindow`  
6️⃣ `WM_DESTROY` → `PostQuitMessage(0)`

### 3.3 Logging-Entscheidungen

- Separate Console → Logs immer sichtbar, GUI bleibt oben
- UTF‑8 → Log-Ausgabe unterstützt Sonderzeichen
- Kein File‑Logging per Default, aber vorbereitet

---

## 4. Menüsystem

| Menü | Command | ID | Aktion |
|------|--------|-----|--------|
| File | Exit | 1001 | Fenster schließen |
| Action | One | 2001 | Info‑Log "Action One" |
| Action | Two | 2002 | Info‑Log "Action Two" |
| Help | About | 3001 | MessageBox (UTF‑16) + Log |

Das Routing erfolgt über `WM_COMMAND` in `WindowProc`.

---

## 5. Wichtige Funktionen

### 5.1 `CreateLoggingConsole()`
- `AllocConsole()` erstellt neue Konsoleninstanz
- `freopen_s` verbindet stdout/stderr/stdin mit `CONOUT$`
- UTF‑8 Ausgabe per `SetConsoleOutputCP(CP_UTF8)`

### 5.2 `WindowProc()`
- Verarbeitet `WM_COMMAND`, `WM_CLOSE`, `WM_DESTROY`

### 5.3 `CreateMainMenu()`
- Dynamic Build der Menüstruktur per `AppendMenuW`

### 5.4 `WinMain()`
- Einfacher Setup & Lifetime Controller

---

## 6. Fehlerbehandlung

| Situation | Log | Verhalten |
|----------|-----|-----------|
| RegisterClassW fail | logError | Stop, Enter abwarten |
| CreateWindow fail | logError | Stop, Enter abwarten |
| WM_COMMAND invalid | none | ignored |

Keine Exceptions – rein prozedural.

---

## 7. Bekannte Einschränkungen

- Nur Windows (WinAPI exklusiv)
- Kein High DPI oder Resize Handling
- Kein Accelerator (nur direkte Menu ID Checks)
- Kein File-Logging per Default

---

## 8. Erweiterungsideen

- Tray-Icon
- File-Dialog (OpenFile)
- Logging-Fenster als eigenes Child-Window
- Theme / Dark-Mode
- Accelerator-Table (CTRL+S, ALT+F etc.)

---

## 9. Solution.json-Konfiguration

Damit der **BasicLogger** im CMake Architecture V2 System korrekt eingebunden wird, muss im `Solution.json`
unter `libraries` folgender Eintrag existieren:

```json
{
  "name": "BasicLogger",
  "version": "1.0.0",
  "type": "INTERFACE",
  "public_headers": "projects/libs/BasicLogger/include"
}

```

---

## 10. Changelog

| Version | Änderungen |
|--------|------------|
| 0.1.1 | Dokumentation, Logger-Konsole, Menüstruktur |

