# imGuiApp – Referenz

> **Version:** 0.2.0  
> **Datum:** 2025-12-10  
> **Typ:** Referenz-Doku  
> **Status:** Demo / Vorlage

---

## 1. Übersicht

Schnellreferenz für die imGuiApp - Einstiegspunkte, API, Konfiguration.

---

## 2. Einstiegspunkte

### `int commonMain()`

Zentrale Funktion – plattformunabhängige Logik.

```cpp
int commonMain() {
    initGLFW();     // → GLFWwindow*
    initGLAD();     // → bool
    initImGui();    // → void
    mainLoop();     // → void
    cleanup();      // → void
    return 0;
}
```

| Rückgabe | Bedeutung |
|----------|-----------|
| 0 | Erfolg |
| 1 | Initialisierungsfehler |

### `GLFWwindow* initGLFW()`

Initialisiert GLFW und erstellt Fenster.

| Rückgabe | Bedeutung |
|----------|-----------|
| `GLFWwindow*` | Erfolg |
| `nullptr` | Fehler |

### `bool initGLAD()`

Lädt OpenGL Funktionen via GLAD.

### `void initImGui(GLFWwindow* window)`

Erstellt ImGui Context mit Docking + Viewports.

### `void renderUI(AppState& state)`

Zeichnet alle UI-Elemente.

### `void mainLoop(GLFWwindow* window, AppState& state)`

Haupt-Renderloop mit Viewport-Support.

### `void cleanup(GLFWwindow* window)`

Ressourcen freigeben.

---

## 3. Structs

### `AppState`

```cpp
struct AppState {
    bool showDemoWindow = true;
    bool showAboutWindow = true;
    bool showMetricsWindow = false;
    bool showStyleEditor = false;
    ImVec4 clearColor = ImVec4(0.1f, 0.1f, 0.12f, 1.0f);
    int frameCount = 0;
};
```

### `Config` (namespace)

```cpp
namespace Config {
    constexpr int WINDOW_WIDTH = 1280;
    constexpr int WINDOW_HEIGHT = 720;
    constexpr const char* WINDOW_TITLE = "ImGui Demo...";
    constexpr const char* LOG_FILE = "imgui.log";
    constexpr const char* GLSL_VERSION = "#version 330";
}
```

---

## 4. ImGui ConfigFlags

| Flag | Wert | Beschreibung |
|------|------|--------------|
| `NavEnableKeyboard` | 1 << 0 | Tastaturnavigation |
| `NavEnableGamepad` | 1 << 1 | Gamepad-Support |
| `DockingEnable` | 1 << 6 | Docking aktivieren |
| `ViewportsEnable` | 1 << 10 | Multi-Window |

### Aktivierung

```cpp
ImGuiIO& io = ImGui::GetIO();
io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;
io.ConfigFlags |= ImGuiConfigFlags_ViewportsEnable;
```

---

## 5. ImGui Demo-Funktionen

| Funktion | Beschreibung |
|----------|--------------|
| `ShowDemoWindow()` | Alle Widgets demonstriert |
| `ShowMetricsWindow()` | Performance & Internals |
| `ShowDebugLogWindow()` | Debug-Ausgaben |
| `ShowIDStackToolWindow()` | ID-Stack Debugger |
| `ShowStyleEditor()` | Theme anpassen |
| `ShowAboutWindow()` | ImGui-Info |

---

## 6. DockSpace API

### Vollbild-DockSpace

```cpp
ImGui::DockSpaceOverViewport(0, ImGui::GetMainViewport());
```

### Benutzerdefiniert

```cpp
ImGuiID id = ImGui::GetID("MyDockSpace");
ImGui::DockSpace(id, ImVec2(0, 0), flags);
```

### DockNodeFlags

| Flag | Beschreibung |
|------|--------------|
| `None` | Standard |
| `NoTabBar` | Keine Tab-Leiste |
| `NoResize` | Nicht resizable |
| `NoSplit` | Nicht teilbar |
| `NoDockingInCentralNode` | Zentrum nicht dockbar |
| `PassthruCentralNode` | Input durchreichen |

---

## 7. Viewport-Support

### Im Main Loop

```cpp
if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable) {
    GLFWwindow* backup = glfwGetCurrentContext();
    ImGui::UpdatePlatformWindows();
    ImGui::RenderPlatformWindowsDefault();
    glfwMakeContextCurrent(backup);
}
```

---

## 8. Solution.json Referenz

### Minimal

```json
{
    "name": "MyApp",
    "type": "GUI",
    "externals": ["glad", "glfw", "imgui"]
}
```

### Vollständig

```json
{
    "name": "imGuiApp",
    "version": "0.2.0",
    "type": "GUI",
    "path": "projects/exec/imGuiApp/src",
    "dependencies": ["BasicLogger"],
    "externals": ["glad", "glfw", "imgui"]
}
```

### Externals für ImGui

```json
"externals": {
    "glad": { "path": "externals/glad" },
    "glfw": { "git": "...", "tag": "3.4" },
    "imgui": { "git": "...", "branch": "docking", "cmakeSupport": false }
}
```

---

## 9. Include-Reihenfolge

```cpp
#include <glad/glad.h>      // 1. GLAD zuerst!
#include <GLFW/glfw3.h>     // 2. GLFW
#include <imgui.h>          // 3. ImGui Core
#include <imgui_impl_glfw.h>    // 4. GLFW Backend
#include <imgui_impl_opengl3.h> // 5. OpenGL Backend
```

---

## 10. Logging

| Aspekt | Wert |
|--------|------|
| Datei | `imgui.log` |
| Level | Debug |
| Console | Deaktiviert |

### Log-Ereignisse

- GLFW Init
- Window Created
- GLAD Init + OpenGL Version
- ImGui Init + Version
- Docking/Viewport Status
- Shutdown

---

## 11. Error Codes

| Code | Bedeutung | Lösung |
|------|-----------|--------|
| Return 1 | GLFW Init fehlgeschlagen | Treiber prüfen |
| Return 1 | GLAD Init fehlgeschlagen | OpenGL Context prüfen |
| Crash | ImGui Context fehlt | `CreateContext()` aufrufen |

---

## 12. Plattform-Defines

| Define | Beschreibung |
|--------|--------------|
| `APP_WINDOWS_GUI` | Windows GUI (WinMain) |
| `_WIN32` | Windows (Clang/MSVC) |
| `WIN32` | Windows (MSVC) |
| `__APPLE__` | macOS |

---

## 13. Siehe auch

- [Technische Dokumentation](doku_imGuiApp_v0_2_0.md)
- [Benutzerhandbuch](user_guide_imGuiApp_v0_2_0.md)
- [ImGui Wiki](https://github.com/ocornut/imgui/wiki)
- [ImGui Demo Code](https://github.com/ocornut/imgui/blob/docking/imgui_demo.cpp)

---

## 14. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.2.0** | **2025-12-10** | **Docking, Viewports, ConfigFlags, DockSpace API** |
| 0.1.0 | 2025-12-09 | Erste Referenz |
