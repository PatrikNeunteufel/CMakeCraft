# imgui.cmake PostFetch Hook – Dokumentation

> **Version:** 0.2.0 (doc v1)  
> **Datum:** 2025-12-09  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/externals/Hooks/PostFetch/imgui.cmake  
> **Modul-Version:** 0.2.0  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Hooks/imgui_PostFetch_v0_2_0.md)

---

## 1. Übersicht

Dieser PostFetch-Hook erstellt CMake-Targets für Dear ImGui. ImGui hat kein eigenes CMakeLists.txt, daher ist dieser Hook **erforderlich**.

### Änderungen in v0.2.0

- **NEU:** Kombiniertes Target-Ansatz (alle Backends in einem Target)
- **NEU:** Automatisches GLAD-Linking wenn verfügbar
- **NEU:** Automatisches GLFW-Linking wenn verfügbar
- **ENTFERNT:** Separate Backend-Targets

---

## 2. Aufrufzeitpunkt

```
1. FetchContent_Declare()
2. PreFetch Hook (falls vorhanden)
3. FetchContent_MakeAvailable()
4. >>> PostFetch Hook <<<    ← Hier
5. Auto-Register Targets
```

---

## 3. Erstellte Targets

| Target | Typ | Beschreibung |
|--------|-----|--------------|
| `imgui` | STATIC | Kombiniertes ImGui mit allen Backends |

---

## 4. Enthaltene Komponenten

### 4.1 Core ImGui

| Datei | Beschreibung |
|-------|--------------|
| `imgui.cpp` | Hauptimplementierung |
| `imgui_demo.cpp` | Demo-Window |
| `imgui_draw.cpp` | Rendering |
| `imgui_tables.cpp` | Table-Widget |
| `imgui_widgets.cpp` | Standard-Widgets |

### 4.2 OpenGL3 Backend

| Datei | Beschreibung |
|-------|--------------|
| `backends/imgui_impl_opengl3.cpp` | OpenGL3/ES2/ES3 Renderer |

**Compile-Definition:** `IMGUI_IMPL_OPENGL_LOADER_GLAD` (wenn GLAD verfügbar)

### 4.3 GLFW Backend

| Datei | Beschreibung |
|-------|--------------|
| `backends/imgui_impl_glfw.cpp` | GLFW Input/Window Handler |

### 4.4 Win32 Backend (nur Windows)

| Datei | Beschreibung |
|-------|--------------|
| `backends/imgui_impl_win32.cpp` | Native Windows Input |

---

## 5. Automatisches Linking

Der Hook prüft ob bestimmte Targets existieren und linkt sie automatisch:

```cmake
if(TARGET glad)
    target_link_libraries(imgui PUBLIC glad)
    target_compile_definitions(imgui PRIVATE IMGUI_IMPL_OPENGL_LOADER_GLAD)
endif()

if(TARGET glfw)
    target_link_libraries(imgui PUBLIC glfw)
endif()
```

**Wichtig:** Deshalb muss die Reihenfolge in Solution.json stimmen!

---

## 6. Solution.json Konfiguration

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
            "tag": "v1.90.1",
            "cmakeSupport": false
        }
    }
}
```

### Reihenfolge ist wichtig!

1. **glad** – Wird zuerst verarbeitet, erstellt `glad` Target
2. **glfw** – Wird als zweites verarbeitet, erstellt `glfw` Target
3. **imgui** – Wird zuletzt verarbeitet, findet `glad` und `glfw` Targets

---

## 7. Implementierung

```cmake
# cmake/externals/Hooks/PostFetch/imgui.cmake
# PostFetch Hook for Dear ImGui
# Version: 0.2.0

# Get source directory from FetchContent
string(TOLOWER "${HOOK_EXTERNAL_NAME}" _ext_lower)
FetchContent_GetProperties(${_ext_lower})
set(_imgui_src "${${_ext_lower}_SOURCE_DIR}")

message(STATUS "[imgui] Creating target from: ${_imgui_src}")

# Collect Source Files
set(_imgui_sources
    "${_imgui_src}/imgui.cpp"
    "${_imgui_src}/imgui_demo.cpp"
    "${_imgui_src}/imgui_draw.cpp"
    "${_imgui_src}/imgui_tables.cpp"
    "${_imgui_src}/imgui_widgets.cpp"
)

# Add OpenGL3 Backend
if(EXISTS "${_imgui_src}/backends/imgui_impl_opengl3.cpp")
    list(APPEND _imgui_sources "${_imgui_src}/backends/imgui_impl_opengl3.cpp")
    message(STATUS "[imgui]   + OpenGL3 backend")
endif()

# Add GLFW Backend
if(EXISTS "${_imgui_src}/backends/imgui_impl_glfw.cpp")
    list(APPEND _imgui_sources "${_imgui_src}/backends/imgui_impl_glfw.cpp")
    message(STATUS "[imgui]   + GLFW backend")
endif()

# Add Win32 Backend (Windows only)
if(WIN32 AND EXISTS "${_imgui_src}/backends/imgui_impl_win32.cpp")
    list(APPEND _imgui_sources "${_imgui_src}/backends/imgui_impl_win32.cpp")
    message(STATUS "[imgui]   + Win32 backend")
endif()

# Create Combined ImGui Library
add_library(imgui STATIC ${_imgui_sources})

target_include_directories(imgui PUBLIC
    "${_imgui_src}"
    "${_imgui_src}/backends"
)

target_compile_features(imgui PUBLIC cxx_std_11)

# Suppress warnings (external code)
if(MSVC)
    target_compile_options(imgui PRIVATE /W0)
else()
    target_compile_options(imgui PRIVATE -w)
endif()

# Link GLAD if available
if(TARGET glad)
    target_link_libraries(imgui PUBLIC glad)
    target_compile_definitions(imgui PRIVATE IMGUI_IMPL_OPENGL_LOADER_GLAD)
    message(STATUS "[imgui]   Linked: glad")
endif()

# Link GLFW if available
if(TARGET glfw)
    target_link_libraries(imgui PUBLIC glfw)
    message(STATUS "[imgui]   Linked: glfw")
endif()

# Register Target
_register_external_target("imgui" "imgui" PRIMARY)

message(STATUS "[imgui] Target 'imgui' created (combined with backends)")
message(STATUS "[imgui] PostFetch hook complete")
```

---

## 8. Verwendung im Code

```cpp
#include "imgui.h"
#include "imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"

int main() {
    // GLFW + OpenGL initialisieren...
    
    // ImGui Context erstellen
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    
    // Backends initialisieren
    ImGui_ImplGlfw_InitForOpenGL(window, true);
    ImGui_ImplOpenGL3_Init("#version 330");
    
    // Main loop
    while (!glfwWindowShouldClose(window)) {
        // Neuer Frame
        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();
        
        // UI zeichnen
        ImGui::ShowDemoWindow();
        
        // Rendern
        ImGui::Render();
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
        
        glfwSwapBuffers(window);
        glfwPollEvents();
    }
    
    // Cleanup
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();
    
    return 0;
}
```

---

## 9. Debug-Ausgaben

```
-- [imgui] Creating target from: /path/to/_deps/imgui-src
-- [imgui]   + OpenGL3 backend
-- [imgui]   + GLFW backend
-- [imgui]   + Win32 backend          (nur Windows)
-- [imgui]   Linked: glad
-- [imgui]   Linked: glfw
-- [imgui] Target 'imgui' created (combined with backends)
-- [imgui] PostFetch hook complete
```

---

## 10. Fehlerbehebung

### "imgui_impl_glfw.h not found"

**Problem:** Include-Pfad fehlt.

**Lösung:** Prüfen dass `${_imgui_src}/backends` in Include-Directories ist.

### "undefined reference to gladLoadGLLoader"

**Problem:** GLAD nicht gelinkt.

**Lösung:** 
1. Prüfen dass `glad` vor `imgui` in Solution.json steht
2. Prüfen dass `glad` Target existiert

### "LNK2019: unresolved external symbol WinMain"

**Problem:** Windows GUI ohne WinMain.

**Lösung:** Siehe [ExecutableCreate.cmake](../Modules/project/ExecutableCreate_cmake_v0_1_2_doc_v1.md) – APP_WINDOWS_GUI Pattern verwenden.

---

## 11. Alternative Backends

Der Hook kann erweitert werden um andere Backends zu unterstützen:

### Vulkan Backend

```cmake
if(EXISTS "${_imgui_src}/backends/imgui_impl_vulkan.cpp")
    list(APPEND _imgui_sources "${_imgui_src}/backends/imgui_impl_vulkan.cpp")
    find_package(Vulkan REQUIRED)
    target_link_libraries(imgui PUBLIC Vulkan::Vulkan)
endif()
```

### SDL2 Backend

```cmake
if(EXISTS "${_imgui_src}/backends/imgui_impl_sdl2.cpp")
    list(APPEND _imgui_sources "${_imgui_src}/backends/imgui_impl_sdl2.cpp")
    find_package(SDL2 REQUIRED)
    target_link_libraries(imgui PUBLIC SDL2::SDL2)
endif()
```

---

## 12. Siehe auch

- [HookLoader.cmake](../Modules/Externals/HookLoader_cmake_v0_1_0_doc_v1.md) – Hook-System
- [Handler.cmake](../Modules/Externals/Handler_cmake_v0_1_0_doc_v1.md) – Fetched Handler
- [glfw PreFetch Hook](glfw_PreFetch_v0_1_0_doc_v1.md) – PreFetch Beispiel
- [glad Include.cmake](../externals/glad_Include_cmake_v0_1_0_doc_v1.md) – GLAD Integration
- [ExecutableCreate.cmake](../Modules/project/ExecutableCreate_cmake_v0_1_2_doc_v1.md) – APP_WINDOWS_GUI

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.2.0 (doc v1)** | **2025-12-09** | **Kombiniertes Target, automatisches GLAD/GLFW-Linking, Win32 Backend** |
| 0.1.0 | 2025-12-08 | Initial: Separate Backend-Targets |
