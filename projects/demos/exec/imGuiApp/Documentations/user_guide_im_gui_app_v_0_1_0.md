# imGuiApp – Benutzerhandbuch

> **Version:** 0.1.0
> **Datum:** 2025-12-09
> **Typ:** Benutzer-Doku
> **Status:** In Entwicklung

---

## 1. Einführung
`imGuiApp` demonstriert:
- Fenstererstellung mit GLFW
- OpenGL Rendering via GLAD
- GUI Rendering mit Dear ImGui
- Logging

---

## 2. Voraussetzungen
- OpenGL 3.3
- CMake Buildsystem
- Compiler (MSVC / GCC / Clang)

---

## 3. Schnellstart

### Build
```
cmake -B build -S .
cmake --build build --target imGuiApp --config Debug
```

### Start
```
./imGuiApp
```

---

## 4. Bedienung

### ImGui Demo
- Zeigt Widgets, Layout und Interaktionen

### About Fenster
- FPS Anzeige
- Frame Counter
- Infos zu Externals
- Button: Demo Window toggeln
- Color Picker: Hintergrundfarbe ändern

---

## 5. Troubleshooting

| Problem | Ursache | Lösung |
|--------|--------|--------|
| Fenster fehlt | GLFW Init | Treiber & Log prüfen |
| Schwarzer Screen | GLAD | Loader + Kontext |
| Demo Window fehlt | Flag | Button nutzen |

---

## 6. Kurzreferenz
| Bereich | Info |
|--------|------|
| Fenster | 1280x720 |
| Renderer | OpenGL 3.3 |
| UI | Dear ImGui |
| Logging | imgui.log |
| Steuerung | Maus + Tastatur |

---

## 7. Changelog
| Version | Datum | Änderungen |
|--------|------|------------|
| **0.1.0** | 2025-12-09 | Erste Ausgabe |

