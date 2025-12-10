# MinimalWindow – Technische Dokumentation

> **Modul:** MinimalWindow (Win32 GUI Minimalbeispiel)
> **Version:** 0.1.2
> **Status:** Demo / Beispiel
> **Datum:** 2025-12-09

---
## 1. Solution.json-Konfiguration

Damit die Anwendung **MinimalWindow** im CMake-Architecture-V2-System korrekt generiert und gebaut wird,
muss im `Solution.json` im Abschnitt `executables` folgender Eintrag vorhanden sein:

```json
{
  "name": "MinimalWindow",
  "version": "0.1.0",
  "type": "GUI",
  "path": "projects/exec/MinimalWindow/src",
  "skip": false,
  "dependencies": ["BasicLogger"]
}
```

**Bedeutung der Felder:**

- `type: "GUI"`: erzwingt eine GUI-Executable (kein Konsolenfenster, WinMain)
- `path`: legt explizit fest, wo der Quellcode der GUI-Anwendung liegt (überschreibt Default-Struktur)
- `dependencies: ["BasicLogger"]`: bindet die Logging-Funktionalität ein
- `skip: false`: stellt sicher, dass die Executable erzeugt wird und nicht übersprungen wird

> Hinweis: Die Versionsnummer im Solution.json (0.1.0) muss nicht zwingend der Doku-Version entsprechen, solange
> der Build kompatibel bleibt. Die Doku-Version beschreibt Inhalte; die Solution-Version identifiziert das Paket.

---

## 2. Überblick

**MinimalWindow** ist ein Minimalbeispiel einer nativen Win32 GUI Anwendung ohne zusätzliche Frameworks.
Ziel ist es zu demonstrieren, wie

- ein Fenster erzeugt wird,
- Nachrichten empfangen und verarbeitet werden,
- und wie das Logging über BasicLogger integriert wird.

---

## 3. Ziele und Einsatzzweck

- Minimalbeispiel für Win32-Fenster
- Basis für spätere GUI-Framework-Integration (ImGui, SDL, Qt, etc.)
- Demonstration einfacher GUI-Elemente und Events

---

## 4. Architektur und Aufbau

- Einstiegspunkt: `WinMain`
- Registrierung der Fensterklasse
- Erzeugen des Hauptfensters
- Nachrichtenschleife (`GetMessage`, `TranslateMessage`, `DispatchMessage`)
- Verarbeitung in `WndProc`

---

## 5. Initialisierung und Ablauf

1. Logger initialisieren
2. Fensterklasse registrieren
3. Fenster erzeugen
4. Anzeigen (`ShowWindow`), Aktualisieren (`UpdateWindow`)
5. Nachrichtenschleife ausführen

---

## 6. Logging

Der **BasicLogger** wird für Debugging und Statusausgaben verwendet.
Typische Einträge:

```cpp
LOG_INFO("Window created");
LOG_ERROR("Failed to register window class");
```

---

## 7. Fensterverhalten (WndProc)

### Typische Nachrichten

- `WM_PAINT`: Rendern
- `WM_DESTROY`: Beenden
- `WM_CLOSE`: Benutzeraktion → Anfrage zum Schließen

### Hinweis

Der Fokus liegt auf Minimalismus, nicht auf vollständiger Eventabdeckung.

---

## 8. Erweiterungsmöglichkeiten

- Menüleiste, Statusbar, Buttons
- Rendering (GDI/DirectX/OpenGL)
- Integration als Hostfenster für ImGui

---

## 9. Bekannte Einschränkungen

- Reines Win32 API (keine Multiplattformfähigkeit)
- Kein Layout-Management
- Kein High-DPI Support

---

## 10. Wartung und Versionierung

- Diese Dokumentation beschreibt den Stand **0.1.2**.
- Solution.json bleibt auf `"version": "0.1.0"`, was für den Build ausreichend ist.

