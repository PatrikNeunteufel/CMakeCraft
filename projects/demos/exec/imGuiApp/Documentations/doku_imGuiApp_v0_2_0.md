# imGuiApp – Technische Dokumentation

> **Version:** 0.2.0  
> **Datum:** 2025-12-10  
> **Typ:** Modul-Doku  
> **Status:** Demo / Vorlage  
> **Sprache:** Deutsch

---

## 1. Übersicht

Die Anwendung **imGuiApp** ist eine Demo und **Vorlage** für die Integration von Dear ImGui mit OpenGL in CMake Architecture V2. Sie zeigt die vollständige Pipeline von Fenster-Erstellung bis UI-Rendering mit Docking-Support.

### Verwendete Technologien

| Komponente | Version | Typ | Funktion |
|------------|---------|-----|----------|
| Dear ImGui | v1.91.6-docking | Fetched External | UI Framework |
| GLFW | 3.4 | Fetched External | Fenster & Input |
| GLAD | - | Local External | OpenGL Loader |
| OpenGL | 3.3 Core | System | Rendering |
| BasicLogger | 1.0.0 | Internal Library | Logging |

---

## 2. Solution.json Konfiguration

### Minimal-Konfiguration

```json
{
    "externals": {
        "glad": {
            "path": "externals/glad"
        },
        "glfw": {
            "git": "https://github.com/glfw/glfw.git",
            "tag": "3.4"
        },
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "branch": "docking",
            "cmakeSupport": false
        }
    },
    "executables": [
        {
            "name": "imGuiApp",
            "version": "0.2.0",
            "type": "GUI",
            "path": "projects/exec/imGuiApp/src",
            "dependencies": ["BasicLogger"],
            "externals": ["glad", "glfw", "imgui"]
        }
    ]
}
```

### Erläuterung der Felder

| Feld | Wert | Bedeutung |
|------|------|-----------|
| `type` | `"GUI"` | Windows: kein Konsolenfenster (WinMain) |
| `externals` | `["glad", "glfw", "imgui"]` | Reihenfolge wichtig! |
| `cmakeSupport` | `false` | ImGui hat kein CMakeLists.txt → PostFetch Hook |

### Externals-Reihenfolge

**WICHTIG:** Die Reihenfolge in `externals` bestimmt die Verarbeitungsreihenfolge:

```
1. glad   → OpenGL Function Loader (muss zuerst)
2. glfw   → Fenster-Management (braucht OpenGL)
3. imgui  → UI Framework (braucht glad + glfw)
```

Der ImGui PostFetch Hook linkt automatisch gegen `glad` und `glfw` wenn diese Targets existieren.

---

## 3. ImGui Docking Branch

### Tag vs. Branch

```json
// Stabiler Release (ohne Docking)
"imgui": {
    "git": "https://github.com/ocornut/imgui.git",
    "tag": "v1.91.6",
    "cmakeSupport": false
}

// Docking Branch (mit Docking + Viewports)
"imgui": {
    "git": "https://github.com/ocornut/imgui.git",
    "branch": "docking",
    "cmakeSupport": false
}
```

### Docking-Features

| Feature | Beschreibung |
|---------|--------------|
| Docking | Fenster andocken/gruppieren |
| Tab Bars | Gedockte Fenster als Tabs |
| DockSpace | Zentrale Dock-Fläche |
| Viewports | Fenster außerhalb des Hauptfensters |

---

## 4. Initialisierungsreihenfolge

Die Initialisierung muss in einer bestimmten Reihenfolge erfolgen:

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Logger initialisieren                                     │
│    └─ BasicLogger::Logger logger("imgui.log")               │
├─────────────────────────────────────────────────────────────┤
│ 2. GLFW initialisieren                                       │
│    ├─ glfwSetErrorCallback()                                │
│    ├─ glfwInit()                                            │
│    ├─ glfwWindowHint() - OpenGL Version setzen              │
│    └─ glfwCreateWindow()                                    │
├─────────────────────────────────────────────────────────────┤
│ 3. OpenGL Kontext aktivieren                                 │
│    ├─ glfwMakeContextCurrent(window)                        │
│    └─ glfwSwapInterval(1) - VSync                           │
├─────────────────────────────────────────────────────────────┤
│ 4. GLAD laden                                                │
│    └─ gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)    │
├─────────────────────────────────────────────────────────────┤
│ 5. ImGui initialisieren                                      │
│    ├─ IMGUI_CHECKVERSION()                                  │
│    ├─ ImGui::CreateContext()                                │
│    ├─ ImGuiIO Flags setzen (Docking, Viewports)             │
│    ├─ ImGui::StyleColorsDark()                              │
│    ├─ ImGui_ImplGlfw_InitForOpenGL(window, true)            │
│    └─ ImGui_ImplOpenGL3_Init("#version 330")                │
├─────────────────────────────────────────────────────────────┤
│ 6. Main Loop                                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. ImGui Konfiguration (ImGuiIO)

### ConfigFlags

```cpp
ImGuiIO& io = ImGui::GetIO();

// Keyboard Navigation
io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;

// Gamepad Navigation (optional)
io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;

// Docking Support (Docking Branch erforderlich!)
io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;

// Multi-Viewport (Fenster außerhalb des Hauptfensters)
io.ConfigFlags |= ImGuiConfigFlags_ViewportsEnable;
```

### Docking-Optionen

```cpp
// Dock ohne Shift-Taste
io.ConfigDockingWithShift = false;

// Immer Tab-Leiste zeigen
io.ConfigDockingAlwaysTabBar = true;

// Transparente Fenster beim Docken
io.ConfigDockingTransparentPayload = true;
```

### Style-Anpassungen für Viewports

```cpp
ImGuiStyle& style = ImGui::GetStyle();
if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable) {
    // Keine abgerundeten Ecken für Platform Windows
    style.WindowRounding = 0.0f;
    // Volle Opazität für konsistentes Aussehen
    style.Colors[ImGuiCol_WindowBg].w = 1.0f;
}
```

---

## 6. DockSpace

### Vollbild-DockSpace

```cpp
// Erstellt einen DockSpace über das gesamte Hauptfenster
ImGui::DockSpaceOverViewport(0, ImGui::GetMainViewport());
```

### Benutzerdefinierter DockSpace

```cpp
ImGuiViewport* viewport = ImGui::GetMainViewport();

// Flags für den DockSpace
ImGuiDockNodeFlags dockspace_flags = ImGuiDockNodeFlags_None;

// Optional: Keine Tab-Leiste für den zentralen Node
// dockspace_flags |= ImGuiDockNodeFlags_NoTabBar;

// Erstelle DockSpace mit ID
ImGuiID dockspace_id = ImGui::GetID("MyDockSpace");
ImGui::DockSpace(dockspace_id, ImVec2(0.0f, 0.0f), dockspace_flags);
```

---

## 7. Main Loop Struktur

### Standard (ohne Viewports)

```cpp
while (!glfwWindowShouldClose(window)) {
    glfwPollEvents();
    
    // ImGui Frame starten
    ImGui_ImplOpenGL3_NewFrame();
    ImGui_ImplGlfw_NewFrame();
    ImGui::NewFrame();
    
    // UI zeichnen
    renderUI();
    
    // ImGui rendern
    ImGui::Render();
    
    // OpenGL Clear & Viewport
    int w, h;
    glfwGetFramebufferSize(window, &w, &h);
    glViewport(0, 0, w, h);
    glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // ImGui Draw Data rendern
    ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
    
    glfwSwapBuffers(window);
}
```

### Mit Viewports (Multi-Window)

```cpp
while (!glfwWindowShouldClose(window)) {
    glfwPollEvents();
    
    ImGui_ImplOpenGL3_NewFrame();
    ImGui_ImplGlfw_NewFrame();
    ImGui::NewFrame();
    
    renderUI();
    
    ImGui::Render();
    
    int w, h;
    glfwGetFramebufferSize(window, &w, &h);
    glViewport(0, 0, w, h);
    glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
    
    // WICHTIG: Viewport-Support für Multi-Window
    ImGuiIO& io = ImGui::GetIO();
    if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable) {
        GLFWwindow* backup = glfwGetCurrentContext();
        ImGui::UpdatePlatformWindows();
        ImGui::RenderPlatformWindowsDefault();
        glfwMakeContextCurrent(backup);
    }
    
    glfwSwapBuffers(window);
}
```

---

## 8. Include-Reihenfolge

**WICHTIG:** GLAD muss vor GLFW inkludiert werden!

```cpp
// 1. Eigene Header
#include <BasicLogger.h>

// 2. GLAD zuerst (OpenGL Loader)
#include <glad/glad.h>

// 3. GLFW nach GLAD
#include <GLFW/glfw3.h>

// 4. ImGui
#include <imgui.h>
#include <imgui_impl_glfw.h>
#include <imgui_impl_opengl3.h>

// 5. Standard Library
#include <string>
#include <iostream>
```

---

## 9. Cleanup

```cpp
void cleanup(GLFWwindow* window) {
    // ImGui Backends zuerst
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    
    // ImGui Context
    ImGui::DestroyContext();
    
    // GLFW
    glfwDestroyWindow(window);
    glfwTerminate();
}
```

---

## 10. PostFetch Hook (imgui.cmake)

Der PostFetch Hook erstellt das `imgui` Target mit allen Backends:

### Automatisch inkludierte Dateien

```
imgui/
├── imgui.cpp              ← Core
├── imgui_demo.cpp         ← Demo Window
├── imgui_draw.cpp         ← Rendering
├── imgui_tables.cpp       ← Tables API
├── imgui_widgets.cpp      ← Standard Widgets
└── backends/
    ├── imgui_impl_glfw.cpp    ← GLFW Backend
    ├── imgui_impl_opengl3.cpp ← OpenGL3 Backend
    └── imgui_impl_win32.cpp   ← Win32 Backend (Windows)
```

### Automatische Verlinkung

```cmake
# Wenn Target 'glad' existiert
target_link_libraries(imgui PUBLIC glad)
target_compile_definitions(imgui PRIVATE IMGUI_IMPL_OPENGL_LOADER_GLAD)

# Wenn Target 'glfw' existiert
target_link_libraries(imgui PUBLIC glfw)
```

---

## 11. Demo-Funktionen von ImGui

ImGui liefert eingebaute Demo/Debug-Funktionen:

```cpp
// Vollständiges Demo Window (alle Widgets)
ImGui::ShowDemoWindow(&show_demo);

// Performance Metriken
ImGui::ShowMetricsWindow(&show_metrics);

// Debug Log
ImGui::ShowDebugLogWindow(&show_debug_log);

// ID Stack Tool
ImGui::ShowIDStackToolWindow(&show_id_stack);

// Style Editor (Runtime Theme-Anpassung)
ImGui::Begin("Style Editor");
ImGui::ShowStyleEditor();
ImGui::End();

// About Window
ImGui::ShowAboutWindow(&show_about);
```

---

## 12. Projekt als Vorlage nutzen

### Neue ImGui-App erstellen

1. **Ordner erstellen:**
   ```
   projects/exec/MeineApp/src/
   ```

2. **main.cpp kopieren und anpassen**

3. **Solution.json erweitern:**
   ```json
   {
       "name": "MeineApp",
       "version": "1.0.0",
       "type": "GUI",
       "path": "projects/exec/MeineApp/src",
       "externals": ["glad", "glfw", "imgui"]
   }
   ```

4. **Bauen:**
   ```bash
   cmake --preset msvc-debug
   cmake --build build/msvc-debug --target MeineApp
   ```

---

## 13. Troubleshooting

| Problem | Ursache | Lösung |
|---------|---------|--------|
| Schwarzes Fenster | GLAD nicht initialisiert | `gladLoadGLLoader()` prüfen |
| Kein Fenster | GLFW Init fehlgeschlagen | Grafiktreiber prüfen |
| ImGui Crash | Context nicht erstellt | `ImGui::CreateContext()` prüfen |
| Docking funktioniert nicht | Falscher Branch | `branch: "docking"` verwenden |
| Viewport-Fenster flackern | VSync | `glfwSwapInterval(1)` |
| Include-Fehler | Reihenfolge | GLAD vor GLFW! |

---

## 14. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.2.0** | **2025-12-10** | **Docking aktiviert, Viewports, erweiterte Doku als Vorlage** |
| 0.1.1 | 2025-12-09 | Solution.json-Konfiguration ergänzt |
| 0.1.0 | 2025-12-09 | Initiale Version |
