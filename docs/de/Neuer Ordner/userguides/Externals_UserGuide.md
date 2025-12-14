# Externals — Benutzerhandbuch

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Guide  
> **Status:** Stabil  
> **Zielgruppe:** C++ Entwickler  
> **Basiert auf:** Guide v0.5  
> **Sprache:** Deutsch  
> **English:** [Externals_UserGuide.md](../en/guides/Externals_UserGuide.md)

---

## Inhaltsverzeichnis

1. [Überblick](#1-überblick)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Schnellstart](#3-schnellstart)
4. [Lokale Externals](#4-lokale-externals)
5. [Git Externals](#5-git-externals)
6. [GUI-Anwendung mit OpenGL/ImGui](#6-gui-anwendung-mit-openglimgui)
7. [Options verwenden](#7-options-verwenden)
8. [Stolpersteine und Lösungen](#8-stolpersteine-und-lösungen)
9. [Troubleshooting](#9-troubleshooting)
10. [Siehe auch](#10-siehe-auch)
11. [Changelog](#11-changelog)

---

## 1. Überblick

Externals sind externe Bibliotheken, die in Projekten verwendet werden. Das Build-System unterstützt zwei Typen:

| Typ | Beschreibung | Beispiel |
|-----|--------------|----------|
| **Lokal** | Im Projekt-Verzeichnis | BASS, Lua, doctest |
| **Git** | Von GitHub/GitLab | spdlog, GLFW, ImGui |

### Was passiert automatisch?

- Download (bei Git Externals)
- Include-Pfade
- Library-Linking
- DLL-Kopieren (Windows)

---

## 2. Voraussetzungen

- [ ] CMake Architecture V2 Build-System
- [ ] Externals in `externals/` Verzeichnis (lokal)
- [ ] Netzwerkverbindung (für Git Externals)

---

## 3. Schnellstart

### Lokales External

```json
{
    "externals": {
        "bass": { "path": "externals/bass" }
    },
    "executables": [
        {
            "name": "MyApp",
            "externals": ["bass"]
        }
    ]
}
```

### Git External

```json
{
    "externals": {
        "spdlog": {
            "git": "https://github.com/gabime/spdlog.git",
            "tag": "v1.12.0"
        }
    },
    "executables": [
        {
            "name": "MyApp",
            "externals": ["spdlog"]
        }
    ]
}
```

---

## 4. Lokale Externals

### 4.1 BASS Audio

```json
"externals": {
    "bass": { "path": "externals/bass" }
}
```

```cpp
#include <bass.h>

BASS_Init(-1, 44100, 0, nullptr, nullptr);
HSTREAM stream = BASS_StreamCreateFile(FALSE, "music.mp3", 0, 0, 0);
BASS_ChannelPlay(stream, FALSE);
```

### 4.2 Lua Scripting

```json
"externals": {
    "lua54": { "path": "externals/lua54" }
}
```

```cpp
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

lua_State* L = luaL_newstate();
luaL_openlibs(L);
luaL_dostring(L, "print('Hello from Lua!')");
lua_close(L);
```

### 4.3 doctest Testing

```json
"externals": {
    "doctest": { "path": "externals/doctest" }
}
```

```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.h>

TEST_CASE("Math") {
    CHECK(1 + 1 == 2);
}
```

---

## 5. Git Externals

### 5.1 Mit CMake-Support

```json
"externals": {
    "spdlog": {
        "git": "https://github.com/gabime/spdlog.git",
        "tag": "v1.12.0"
    }
}
```

### 5.2 Ohne CMake-Support

```json
"externals": {
    "imgui": {
        "git": "https://github.com/ocornut/imgui.git",
        "tag": "v1.90.1",
        "cmakeSupport": false
    }
}
```

### 5.3 Mit Branch statt Tag

```json
"externals": {
    "mylib": {
        "git": "https://github.com/user/mylib.git",
        "branch": "develop"
    }
}
```

---

## 6. GUI-Anwendung mit OpenGL/ImGui

### 6.1 Solution.json

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
    },
    "executables": [
        {
            "name": "MyGuiApp",
            "type": "GUI",
            "externals": ["glad", "glfw", "imgui"]
        }
    ]
}
```

**Wichtig:** Reihenfolge beachten: glad → glfw → imgui

### 6.2 GLAD generieren

1. Öffne https://glad.dav1d.de/
2. Wähle: C/C++, OpenGL, Version 3.3, Core Profile
3. Klicke GENERATE
4. Entpacke nach `externals/glad/`

### 6.3 main.cpp

```cpp
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include "imgui.h"
#include "imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"

int main() {
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    
    GLFWwindow* window = glfwCreateWindow(1280, 720, "App", nullptr, nullptr);
    glfwMakeContextCurrent(window);
    gladLoadGLLoader((GLADloadproc)glfwGetProcAddress);
    
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGui_ImplGlfw_InitForOpenGL(window, true);
    ImGui_ImplOpenGL3_Init("#version 330");
    
    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();
        
        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();
        
        ImGui::ShowDemoWindow();
        
        ImGui::Render();
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
        glfwSwapBuffers(window);
    }
    
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();
    glfwTerminate();
    return 0;
}
```

---

## 7. Options verwenden

### 7.1 BASS Plugins aktivieren

```json
"executables": [
    {
        "name": "AudioPlayer",
        "externals": ["bass"],
        "external_options": {
            "bass": {
                "BASS_FLAC": true,
                "BASS_OPUS": true,
                "BASS_FX": true
            }
        }
    }
]
```

### 7.2 Lua dynamisch linken

```json
"external_options": {
    "lua54": {
        "LUA_EMBEDDED": false
    }
}
```

### 7.3 doctest Makros anpassen

```json
"external_options": {
    "doctest": {
        "DOCTEST_NO_SHORT_MACRO_NAMES": true
    }
}
```

---

## 8. Stolpersteine und Lösungen

### 8.1 unresolved external symbol WinMain

**Problem:** Windows GUI-Anwendung ohne WinMain.

**Lösung:**
```cpp
#ifdef APP_WINDOWS_GUI
#include <Windows.h>
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int) {
    return main(__argc, __argv);
}
#endif
```

### 8.2 imgui_impl_glfw.h not found

**Problem:** Include-Pfad fehlt.

**Lösung:** Reihenfolge prüfen: glad → glfw → imgui

### 8.3 External 'xxx' not defined

**Problem:** External verwendet aber nicht definiert.

**Lösung:** External im `externals`-Block definieren.

---

## 9. Troubleshooting

### Checkliste

- [ ] External in `externals` Block definiert?
- [ ] Executable verwendet `"externals": [...]`?
- [ ] Include.cmake vorhanden (lokal)?
- [ ] Netzwerk verfügbar (Git)?
- [ ] Tag/Branch existiert?

### Häufige Fehler

| Fehler | Lösung |
|--------|--------|
| `External not defined` | In `externals` Block definieren |
| `Include.cmake not found` | Include.cmake erstellen |
| `Git download failed` | URL/Tag prüfen |
| `DLL not found` | Build-System prüfen |

---

## 10. Siehe auch

- [BASS UserGuide](externals/BASS_UserGuide.md) — BASS Audio Library
- [doctest UserGuide](externals/doctest_UserGuide.md) — Testing Framework
- [GLAD UserGuide](externals/GLAD_UserGuide.md) — OpenGL Loader
- [Lua54 UserGuide](externals/Lua54_UserGuide.md) — Lua Scripting
- [Externals Reference](../reference/Externals.md) — Vollständige Options-Liste

---

## 11. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf Guide v0.5 Blueprint, separate External-UserGuides** |
| 0.2.0 | 2025-12-09 | Git Externals, GUI-App Anleitung |
| 0.1.0 | 2025-12-09 | Initial: Local Externals |
