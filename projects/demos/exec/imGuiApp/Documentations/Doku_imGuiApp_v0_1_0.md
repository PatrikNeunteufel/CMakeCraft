# imGuiApp – Technische Dokumentation

> **Version:** 0.1.0 (doc v1)  
> **Datum:** 2025-12-09  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung  
> **Modul:** imGuiApp (Demo-Applikation, `main.cpp`)  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** Documentation_Blueprint v0.1.0 :contentReference[oaicite:0]{index=0}  

---

## 1. Übersicht

`imGuiApp` ist eine einfache Beispielanwendung, die die Integration von

- **GLFW** (Fenster- und Kontextverwaltung)  
- **GLAD** (OpenGL-Loader)  
- **Dear ImGui** (GUI)  
- **BasicLogger** (interner Logger)  

im Kontext der *CMake Architecture V2* demonstriert. :contentReference[oaicite:1]{index=1}  

Hauptziele der Anwendung:

- Nachweis, dass **Externals per CMake-Fetch/Registry** korrekt eingebunden sind  
- Minimaler, aber vollständiger **Render-Loop mit ImGui**  
- Nutzung eines **einheitlichen Logging-Systems** (`BasicLogger`)  
- Plattformübergreifende Entry Points (`main` / `WinMain`)  

Die Applikation zeigt das ImGui-Demo-Fenster und ein eigenes „About“-Fenster mit Informationen zu Architektur, Externals und Laufzeitdaten.

---

## 2. Abhängigkeiten

### 2.1 Interne Abhängigkeiten

- `BasicLogger`  
  - Namespace: `BasicLogger`  
  - Klasse: `Logger`  
  - Wird global instanziiert: `BasicLogger::Logger logger("imgui.log");`  

Verwendung:

- Konfiguration des Log-Levels (`Debug`)  
- Deaktivierung der Konsolenausgabe (nur Logdatei)  
- Fehler- und Info-Logging im gesamten Lebenszyklus der App :contentReference[oaicite:2]{index=2}  

### 2.2 Externe Bibliotheken (Externals)

- **GLFW**  
  - Kontext: Fenstererzeugung, Event-Loop, OpenGL-Kontext  
  - Nutzt Error-Callback (`glfwSetErrorCallback`)  

- **GLAD**  
  - Lädt OpenGL-Funktionszeiger (`gladLoadGLLoader`)  
  - Muss **vor** jeglichem OpenGL-Aufruf initialisiert werden  

- **Dear ImGui**  
  - Kernbibliothek (`imgui.h`)  
  - Backend-Bindings:
    - `imgui_impl_glfw.h`  
    - `imgui_impl_opengl3.h`  

---

## 3. Konzept / Design

### 3.1 Struktur

Die Anwendung ist bewusst **monolithisch** in einer Datei (`main.cpp`) gehalten, um als kompaktes Demo für:

- CMake-Externals  
- Logging-Integration  
- ImGui-Setup  

zu dienen. :contentReference[oaicite:3]{index=3}  

Wesentliche Design-Entscheidungen:

1. **Gemeinsamer Code in `commonMain()`**  
   - Plattformunabhängige Hauptlogik liegt zentral in einer Funktion
   - Plattform-spezifische Entry Points (`main` VS `WinMain`) rufen nur `commonMain()` auf

2. **Globaler Logger**  
   - Eine globale Instanz `logger` steht überall zur Verfügung  
   - Vereinheitlichte Fehlerbehandlung über Logging statt `std::cerr`  

3. **Explizite Initialisierungsreihenfolge**  
   1. Logger-Setup  
   2. GLFW initialisieren  
   3. Fenster erstellen  
   4. OpenGL-Kontext setzen + GLAD laden  
   5. ImGui-Kontext + Backends initialisieren  
   6. Haupt-Renderloop  
   7. Geordnete Freigabe aller Ressourcen  

4. **Minimaler State**  
   - Wenige Zustandsvariablen:
     - `showDemoWindow`, `showAboutWindow`  
     - `clearColor` (Hintergrund)  
     - `frameCount`  

### 3.2 Fehlerbehandlung

Fehler werden primär über:

- **Return Codes** (`return 1` bei fatalen Fehlern)  
- **Logging** (Fehlerbeschreibung via `logger.error(...)`)  

abgebildet.

Typische Fehlerpfade:

- GLFW konnte nicht initialisiert werden  
- Fenster konnte nicht erzeugt werden  
- GLAD konnte nicht initialisiert werden  

In jedem dieser Fälle erfolgt:

- Logging einer sinnvollen Fehlermeldung  
- Geordneter Abbruch (inkl. `glfwTerminate()` wenn nötig) :contentReference[oaicite:4]{index=4}  

---

## 4. API-Referenz (High-Level)

Da es sich um eine Single-File-Demo handelt, existiert keine formale öffentliche API im Sinne von exportierten Funktionen oder Klassen. Für Integrationszwecke sind folgende Punkte relevant:

- **Globale Funktionen:**
  - `int commonMain();`  
  - `void glfwErrorCallback(int error, const char* description);`  
- **Entry Points:**
  - `int main(int argc, char* argv[]);` (Standard)  
  - `int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int);` (optional, via `APP_WINDOWS_GUI`)  

Die **vollständige Funktions- und Parameterbeschreibung** findet sich in der Referenz-Dokumentation (`Referenz_imGuiApp_v0_1_0.md`).

---

## 5. Verwendungsbeispiele

### 5.1 Einbindung als Demo-Projekt in CMake Architecture V2

Typischer Einsatzzweck:

- Als **Demo-Executable** im CMake-Projekt  
- Über `add_executable(imGuiApp ...)`  
- Linken gegen:
  - `BasicLogger`  
  - `imgui`  
  - `glfw`  
  - `glad`  
  - OpenGL-Systembibliothek  

### 5.2 Erweiterungsideen

- Zusätzliche ImGui-Fenster für:
  - Logging-Ansicht  
  - Statistiken (z. B. CPU/Memory/FPS)  
- Integration eines Renderers (z. B. Dreieck, Waveform, etc.) im Hintergrund  
- Konfiguration der Logger-Einstellungen über GUI  
- Umschalten zwischen verschiedenen Demo-Szenen  

---

## 6. Fehlerbehandlung / Error Codes

Die Anwendung definiert keine eigenen Error Codes, sondern arbeitet mit:

- Return Code `0`: Erfolg  
- Return Code `1`: Fataler Fehler (Initialisierung fehlgeschlagen)  

Fehler werden im Logfile `imgui.log` dokumentiert, z. B.:

- `"Failed to initialize GLFW"`  
- `"Failed to create GLFW window"`  
- `"Failed to initialize GLAD"` :contentReference[oaicite:5]{index=5}  

---

## 7. Best Practices

- **GLAD vor allen OpenGL-Aufrufen initialisieren**  
- **ImGui-Kontext immer geordnet freigeben** (`Shutdown`/`DestroyContext`)  
- Fenster bei Fehlern **immer zerstören**, bevor `glfwTerminate()` aufgerufen wird  
- Den Logger möglichst früh initialisieren, um alle Phasen (Init → Loop → Shutdown) abzudecken  
- `glfwSetErrorCallback` früh setzen, damit auch frühe Fehler geloggt werden  

---

## 8. Bekannte Einschränkungen

- Keine Unterstützung für:
  - Multi-Viewport ImGui  
  - Multi-Monitor-Fenster-Layouts  
  - High-DPI-Skalierung  
- Keine Konfigurierbarkeit über Kommandozeilenparameter  
- Kein explizites Ressourcen-Management für Texturen/Shader/etc. (nur Clear-Color + ImGui)  

---

## 9. Migration von früheren Versionen

Derzeit nicht relevant, da `v0.1.0` die erste Version ist.

---

## 10. Siehe auch

- `Referenz_imGuiApp_v0_1_0.md` – Detail-Referenz zu Funktionen, Parametern, Logging  
- `UserGuide_imGuiApp_v0_1_0.md` – Anleitung zum Bauen und Verwenden der Anwendung  
- `Documentation_Blueprint_v0_1_0.md` – Vorgaben zur Dokumentationsstruktur :contentReference[oaicite:6]{index=6}  

---

## 11. Changelog

| Version | Datum | Änderungen |
|--------:|-------|------------|
| **0.1.0** | **2025-12-09** | **Initiale technische Dokumentation für imGuiApp (Architektur, Abhängigkeiten, Lebenszyklus, Fehlerpfade)** |
