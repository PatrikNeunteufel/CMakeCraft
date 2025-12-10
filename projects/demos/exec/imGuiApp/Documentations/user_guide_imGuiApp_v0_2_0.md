# imGuiApp – Benutzerhandbuch

> **Version:** 0.2.0  
> **Datum:** 2025-12-10  
> **Typ:** Benutzer-Doku  
> **Status:** Demo / Vorlage

---

## 1. Einführung

**imGuiApp** ist eine Demo-Anwendung, die zeigt wie man Dear ImGui mit OpenGL verwendet. Sie dient als Vorlage für eigene GUI-Anwendungen.

### Was wird demonstriert?

- Fenstererstellung mit GLFW
- OpenGL Rendering via GLAD
- GUI mit Dear ImGui
- **Docking** (Fenster andocken)
- **Viewports** (Multi-Window)
- Logging mit BasicLogger

---

## 2. Voraussetzungen

| Anforderung | Minimum |
|-------------|---------|
| OpenGL | 3.3 Core |
| CMake | 3.19+ |
| Compiler | MSVC 2019+ / GCC 10+ / Clang 12+ |
| OS | Windows 10+, Linux, macOS |

---

## 3. Schnellstart

### Build

```bash
# Konfigurieren
cmake --preset msvc-debug

# Bauen
cmake --build build/msvc-debug --target imGuiApp

# Starten
./build/msvc-debug/Debug/imGuiApp.exe
```

### Erste Schritte

1. App starten
2. "About" Fenster zeigt Infos
3. "View" Menü → "Demo Window" aktivieren
4. Demo Window erkunden (alle ImGui Widgets)

---

## 4. Benutzeroberfläche

### Hauptfenster

```
┌─────────────────────────────────────────────────────────────┐
│ File │ View │ Help │                              FPS: 60.0│  ← Menüleiste
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─ About ─────────────┐  ┌─ Demo Window ────────────────┐ │
│  │ Phase 6 Demo        │  │ [All ImGui Widgets]          │ │
│  │ ...                 │  │ ...                          │ │
│  └─────────────────────┘  └──────────────────────────────┘ │
│                                                             │
│                         DockSpace                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Menüleiste

| Menü | Einträge |
|------|----------|
| **File** | Exit |
| **View** | Demo Window, About, Metrics, Style Editor |
| **Help** | Info |

---

## 5. Docking

### Was ist Docking?

Docking erlaubt es, Fenster aneinander "anzudocken" - ähnlich wie in Visual Studio oder Unity.

### Fenster andocken

1. **Fenster ziehen**: Titelleiste greifen
2. **Über anderes Fenster ziehen**: Docking-Vorschau erscheint
3. **Loslassen**: Fenster dockt an

### Docking-Positionen

```
         ┌─────┐
         │ Top │
    ┌────┼─────┼────┐
    │Left│Center│Right│
    └────┼─────┼────┘
         │Bottom│
         └─────┘
```

### Tabs

Wenn mehrere Fenster an derselben Position gedockt werden, erscheinen sie als Tabs:

```
┌─ Window A │ Window B │ Window C ─────────────────┐
│                                                   │
│ [Inhalt von aktivem Tab]                         │
│                                                   │
└───────────────────────────────────────────────────┘
```

### Undock

- **Doppelklick** auf Tab → Fenster löst sich
- **Ziehen** aus Tab-Leiste → Fenster wird frei

---

## 6. Viewports (Multi-Window)

### Was sind Viewports?

Mit Viewports können ImGui-Fenster **außerhalb** des Hauptfensters gezogen werden - als eigenständige OS-Fenster.

### Aktiviert?

Im "About" Fenster steht:
- `Viewports: Yes` → Aktiviert
- `Viewports: No` → Deaktiviert

### Verwendung

1. Fenster aus dem Hauptfenster ziehen
2. Es wird zu einem eigenständigen Fenster
3. Kann auf anderen Monitor gezogen werden

---

## 7. Demo Window

Das Demo Window zeigt **alle** ImGui-Funktionen:

### Kategorien

| Kategorie | Inhalt |
|-----------|--------|
| **Help** | Über ImGui |
| **Configuration** | IO Settings |
| **Window options** | Fenster-Flags |
| **Widgets** | Buttons, Sliders, Inputs... |
| **Layout** | Columns, Groups |
| **Popups** | Modals, Context Menus |
| **Tables** | Tabellen-API |
| **Inputs** | Keyboard, Mouse |
| **Plots** | Graphen, Histogramme |

### Tipp: Code kopieren

Im Demo Window ist der **Quellcode** für jedes Widget sichtbar! Einfach das gewünschte Widget finden und den Code in deine App kopieren.

---

## 8. Style Editor

### Öffnen

View → Style Editor

### Funktionen

- **Colors**: Alle Farben anpassen
- **Sizes**: Abstände, Rundungen
- **Fonts**: Schriftarten
- **Rendering**: Anti-Aliasing

### Preset-Themes

```cpp
ImGui::StyleColorsDark();   // Dunkel (Standard)
ImGui::StyleColorsLight();  // Hell
ImGui::StyleColorsClassic(); // Klassisch (ImGui 1.x)
```

---

## 9. Metrics Window

### Öffnen

View → Metrics

### Informationen

- Frame-Zeiten
- Vertex/Index Buffer Größe
- Fenster-Liste
- Draw Calls
- Memory Usage

Nützlich für **Performance-Optimierung**.

---

## 10. Hintergrundfarbe ändern

1. "About" Fenster öffnen
2. "Background" Color Picker nutzen
3. Farbe wählen

---

## 11. Logging

Die App schreibt Logs in `imgui.log`:

```
[INFO] === imGuiApp v0.2.0 - Phase 6 Demo ===
[INFO] GLFW initialized
[INFO] Window created: 1280x720
[INFO] GLAD initialized - OpenGL 4.6.0
[INFO] ImGui initialized - Version 1.91.6
[INFO]   Docking: Enabled
[INFO]   Viewports: Enabled
[INFO] Entering main loop...
[INFO] Shutting down...
[INFO] Application terminated successfully
```

---

## 12. Tastenkürzel

| Kürzel | Funktion |
|--------|----------|
| `Alt+F4` | Beenden |
| `Tab` | Nächstes Widget |
| `Shift+Tab` | Vorheriges Widget |
| `Enter` | Button aktivieren |
| `Esc` | Modal/Popup schließen |
| `Ctrl+Tab` | Nächster Tab (Docking) |

---

## 13. Troubleshooting

| Problem | Ursache | Lösung |
|---------|---------|--------|
| Fenster öffnet nicht | GLFW/Treiber | Grafiktreiber aktualisieren |
| Schwarzer Bildschirm | GLAD | Log-Datei prüfen |
| Demo Window fehlt | Deaktiviert | View → Demo Window |
| Docking funktioniert nicht | Falscher ImGui Branch | `branch: "docking"` verwenden |
| Viewports flackern | VSync | Sollte automatisch aktiv sein |
| Fenster außerhalb sichtbar | Viewport-Bug | Fenster zurück ins Hauptfenster ziehen |

---

## 14. Kurzreferenz

| Aspekt | Wert |
|--------|------|
| Fenster | 1280×720 |
| Renderer | OpenGL 3.3 Core |
| UI | Dear ImGui v1.91.6-docking |
| Features | Docking, Viewports |
| Logging | imgui.log |
| Steuerung | Maus + Tastatur |

---

## 15. Nächste Schritte

Nach dem Erkunden der Demo:

1. **Demo-Code lesen**: `imgui_demo.cpp` im ImGui Repo
2. **Eigene Fenster erstellen**: `ImGui::Begin()` / `ImGui::End()`
3. **Widgets hinzufügen**: Buttons, Sliders, etc.
4. **Layout anpassen**: Docking konfigurieren
5. **Style anpassen**: Colors, Sizes

---

## 16. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.2.0** | **2025-12-10** | **Docking & Viewports Anleitung, erweiterte UI-Doku** |
| 0.1.0 | 2025-12-09 | Erste Ausgabe |
