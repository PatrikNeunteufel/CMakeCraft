# imGuiApp – Technische Dokumentation

> **Version:** 0.1.0 (doc v1)
> **Datum:** 2025-12-09
> **Typ:** Modul-Doku
> **Status:** In Entwicklung
> **Modul:** imGuiApp (Demo-Applikation, `main.cpp`)
> **Modul-Version:** 0.1.0
> **Basiert auf:** Documentation_Blueprint v0.1.0

---

## 1. Übersicht

`imGuiApp` ist eine Beispielanwendung, die die Integration von GLFW, GLAD, Dear ImGui und BasicLogger im Kontext der CMake Architecture V2 demonstriert.

Hauptziele:
- Demonstration des Externals-Fetching
- Minimaler ImGui Renderloop
- GUI + Logging + OpenGL
- Plattformübergreifender Start (main / WinMain)

---

## 2. Abhängigkeiten

### Interne:
- BasicLogger – Logging-System

### Externe:
- GLFW – Fensterverwaltung
- GLAD – OpenGL-Loader
- Dear ImGui – GUI Framework

---

## 3. Konzept / Design

### Architekturentscheidungen:
- `commonMain()` enthält plattformunabhängige App-Logik
- Globale Loggerinstanz
- Explizite Initialisierungsreihenfolge
- Minimaler State: DemoWindow, AboutWindow, clearColor, frameCount

### Lebenszyklus:
1. Logger konfigurieren
2. GLFW starten
3. Fenster erstellen
4. GLAD laden
5. ImGui Kontexte + Backends
6. Hauptloop (Events → Frame → Render → Swap)
7. Shutdown

---

## 4. API-Referenz (High-Level)

### Wichtige Funktionen:
- `int commonMain()` – Zentrale App-Logik
- `void glfwErrorCallback(error, description)` – GLFW-Fehlerbehandlung
- `main()` / `WinMain()` – Entry Points

---

## 5. Verwendungsbeispiele
- Als Demo-Executable
- Logger-Integration
- ImGui Widgets

---

## 6. Fehlerbehandlung / Error Codes

| Fehler           | Verhalten         |
|----------------|-----------------|
| GLFW Init fail | return 1 + log  |
| Window fail    | return 1 + log  |
| GLAD fail      | return 1 + log  |

---

## 7. Best Practices
- GLAD vor OpenGL
- Geordnetes Shutdown
- Logger früh initialisieren

---

## 8. Bekannte Einschränkungen
- Keine Shader/Texturen
- Kein CLI
- Kein Multi-Viewport

---

## 9. Migration
Erste Version – keine Migration.

---

## 10. Siehe auch
- Referenz_imGuiApp_v0_1_0
- UserGuide_imGuiApp_v0_1_0

---

## 11. Changelog

| Version | Datum | Änderungen |
|--------|------|------------|
| **0.1.0** | 2025-12-09 | Initiale technische Dokumentation |

