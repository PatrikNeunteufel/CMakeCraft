# imGuiApp – Referenz

> **Version:** 0.1.0  
> **Datum:** 2025-12-09  
> **Typ:** Referenz-Doku  
> **Status:** In Entwicklung

---

## 1. Übersicht
Diese Referenz beschreibt Einstiegspunkte, Parameter, Abläufe und Konfiguration der `imGuiApp`.

---

## 2. Einstiegspunkte

### `int commonMain()`
Zentrale Funktion – Initialisierung, Main-Loop, Shutdown.

| Rückgabe | Bedeutung |
|---------|-----------|
| 0       | Erfolg     |
| 1       | Initialisierungsfehler |

---

### `void glfwErrorCallback(int error, const char* description)`
GLFW internal -> Loggt Fehler über globalen Logger.

---

### `int main()` / `int WINAPI WinMain(...)`
Plattformabhängige Entry Points, beide rufen `commonMain()`.

---

## 3. Konfiguration

### Fenster
| Parameter | Wert |
|----------|------|
| Breite   | 1280 |
| Höhe     | 720  |
| Titel    | "ImGui Demo - CMake Architecture V2" |

### App State
- Demo Fenster sichtbar
- About Fenster sichtbar
- Hintergrundfarbe
- Frame Counter

---

## 4. Logging
- Datei: `imgui.log`
- Level: Debug
- Standard: Keine Konsolenausgabe

### Beispiel Logs
- Init: GLFW, Window, GLAD, ImGui
- Fehler: Init fails
- Shutdown: success

---

## 5. Debugging

| Problem | Ursache | Lösung |
|--------|--------|--------|
| Schwarzes Bild | GLAD nicht init | Kontext + Loader prüfen |
| Kein Fenster | GLFW Init fail | Logdatei prüfen |
| Demo Window fehlt | Flag false | About -> Button |

---

## 6. Siehe auch
- Doku_imGuiApp_v0_1_0
- UserGuide_imGuiApp_v0_1_0

---

## 7. Changelog
| Version | Datum | Änderungen |
|--------|------|------------|
| **0.1.0** | 2025-12-09 | Erste vollständige Referenz |

