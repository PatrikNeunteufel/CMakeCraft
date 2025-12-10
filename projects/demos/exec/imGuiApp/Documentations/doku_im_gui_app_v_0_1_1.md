# imGuiApp – Technische Dokumentation

> **Modul:** imGuiApp (GUI Demo auf Basis von GLFW + GLAD + Dear ImGui)
> **Version:** 0.1.1
> **Status:** Demo / Prototyp
> **Datum:** 2025-12-09

---
## 1. Solution.json-Konfiguration

Damit die Anwendung **imGuiApp** im CMake-Architecture-V2-System korrekt generiert und gebaut wird,
muss im `Solution.json` im Abschnitt `executables` folgender Eintrag vorhanden sein:

```json
{
  "name": "imGuiApp",
  "version": "0.1.0",
  "type": "GUI",
  "path": "projects/exec/imGuiApp/src",
  "dependencies": ["BasicLogger"],
  "externals": ["glad", "glfw", "imgui"]
}
```

**Erläuterung der relevanten Felder:**

- `type: "GUI"` → die Anwendung wird als GUI-Executable gebaut (kein Konsolenfenster).
- `path` → verweist explizit auf den Quellordner des Projekts im Solution-Baum.
- `dependencies` → stellt sicher, dass der **BasicLogger** eingebunden wird.
- `externals: ["glad", "glfw", "imgui"]` → aktiviert die externen Komponenten:
  - **glfw** → Fenster- und Kontextverwaltung
  - **glad** → OpenGL Function Loader
  - **imgui** → GUI-Abstraktion (Docking, Widgets, Rendering über OpenGL)

Damit wird die im Dokument beschriebene Initialisierungsreihenfolge
(Logger → GLFW → Fenster → GLAD → ImGui) technisch automatisch abgebildet.

---
## 2. Übersicht

Die Anwendung **imGuiApp** dient als Demo und Einstieg in die Nutzung von Dear ImGui,
GLFW und GLAD in Kombination mit dem internen Logging-System.

Sie zeigt:

- Initialisierung des Render-Backends
- ImGui-Kontext-Erstellung
- Menü, Fenster, Docking
- Ausgabe von Logger-Informationen

---
## 3. Ziele & Einsatzzweck

- Beispieldemo für das UI-Framework
- Vorlage für zukünftige Visualizer
- modularer Einstieg in renderingnahe Applikationen

---
## 4. Komponenten

- **Win32 + GLFW** → Fenster und Input
- **GLAD** → OpenGL Loader
- **OpenGL** → Rendering Backend
- **Dear ImGui** → UI Layer
- **BasicLogger** → Logging

---
## 5. Initialisierung

Typische Reihenfolge beim Start:

1. Logger initialisieren
2. GLFW initialisieren
3. Fenster erstellen
4. OpenGL-Kontext aktivieren
5. GLAD laden
6. ImGui-Kontext erstellen
7. Rendering Loop starten

---
## 6. Rendering Loop

- Event Polling (GLFW)
- ImGui Frame Begin
- UI zeichnen
- Frame rendern

---
## 7. Logging

- BasicLogger als zentrales Logging
- Ausgabe im Debug-Fenster möglich (künftige Erweiterung)

---
## 8. Erweiterungsmöglichkeiten

- Docking-Layout persistent speichern
- Theme Switcher
- Panels (Logger, Console, Inspector, Scene)
- Audio-Visualisierung

---
## 9. Changelog

- **0.1.1** – Solution.json-Konfiguration ergänzt, Kapitelstruktur angepasst
- **0.1.0** – Initiale Dokumentation für imGuiApp

