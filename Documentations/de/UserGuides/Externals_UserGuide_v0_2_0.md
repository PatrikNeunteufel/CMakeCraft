# Externals UserGuide – CMake Architecture V2

> **Version:** 0.2.0  
> **Datum:** 2025-12-09  
> **Typ:** Benutzer-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, Externals v0.2  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/UserGuides/Externals_UserGuide_v0_2_0.md)

Dieser Guide erklärt, wie externe Bibliotheken in Projekten verwendet werden.

---

## 1. Schnellstart

### 1.1 Lokales External hinzufügen

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

### 1.2 Git External hinzufügen

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

Das war's! CMake kümmert sich um:
- Download (bei Git Externals)
- Include-Pfade
- Library-Linking
- DLL-Kopieren (Windows)

---

## 2. GUI-Anwendung mit OpenGL/ImGui

Dies ist das häufigste Szenario für grafische Anwendungen.

### 2.1 Solution.json

```json
{
    "schemaVersion": "0.1",
    "solution": {
        "name": "MyGuiApp",
        "version": "1.0.0"
    },
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
            "path": "src/MyGuiApp",
            "type": "GUI",
            "externals": ["glad", "glfw", "imgui"]
        }
    ]
}
```

**Wichtig:**
1. **Reihenfolge:** glad → glfw → imgui (imgui linkt automatisch gegen die anderen)
2. **type: "GUI":** Für Windows-Anwendungen ohne Console-Fenster
3. **cmakeSupport: false:** ImGui hat kein CMakeLists.txt

### 2.2 GLAD generieren

Bevor du bauen kannst, musst du GLAD generieren:

1. Öffne https://glad.dav1d.de/
2. Wähle:
   - Language: **C/C++**
   - Specification: **OpenGL**
   - API gl: **Version 3.3** (oder höher)
   - Profile: **Core**
3. Klicke **GENERATE**
4. Lade ZIP herunter
5. Entpacke nach `externals/glad/`

Erstelle `externals/glad/Include.cmake`:

```cmake
# externals/glad/Include.cmake
add_library(glad STATIC "${CMAKE_CURRENT_LIST_DIR}/src/glad.c")
target_include_directories(glad PUBLIC "${CMAKE_CURRENT_LIST_DIR}/include")
find_package(OpenGL REQUIRED)
target_link_libraries(glad PUBLIC OpenGL::GL)
_register_external_target("glad" "glad" PRIMARY)
```

### 2.3 main.cpp für Windows GUI

```cpp
#include "imgui.h"
#include "imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"
#include <glad/glad.h>
#include <GLFW/glfw3.h>

// Windows GUI Entry Point
#ifdef APP_WINDOWS_GUI
#include <Windows.h>
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
    return main(__argc, __argv);
}
#endif

int main(int argc, char* argv[])
{
    // GLFW initialisieren
    if (!glfwInit())
        return -1;

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    GLFWwindow* window = glfwCreateWindow(1280, 720, "My App", nullptr, nullptr);
    if (!window) {
        glfwTerminate();
        return -1;
    }

    glfwMakeContextCurrent(window);
    glfwSwapInterval(1);  // VSync

    // GLAD laden
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        return -1;
    }

    // ImGui initialisieren
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;

    ImGui::StyleColorsDark();

    ImGui_ImplGlfw_InitForOpenGL(window, true);
    ImGui_ImplOpenGL3_Init("#version 330");

    // Main Loop
    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();

        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();

        // Deine UI hier
        ImGui::ShowDemoWindow();

        // Rendern
        ImGui::Render();
        int display_w, display_h;
        glfwGetFramebufferSize(window, &display_w, &display_h);
        glViewport(0, 0, display_w, display_h);
        glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());

        glfwSwapBuffers(window);
    }

    // Cleanup
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();

    glfwDestroyWindow(window);
    glfwTerminate();

    return 0;
}
```

### 2.4 Bauen

```bash
cmake --preset msvc-debug
cmake --build build/msvc-debug
```

---

## 3. BASS Audio Library

### 3.1 Einfache Audio-Wiedergabe

```json
{
    "externals": {
        "bass": { "path": "externals/bass" }
    },
    "executables": [
        {
            "name": "AudioPlayer",
            "externals": ["bass"]
        }
    ]
}
```

```cpp
#include <bass.h>

int main() {
    BASS_Init(-1, 44100, 0, nullptr, nullptr);
    
    HSTREAM stream = BASS_StreamCreateFile(FALSE, "music.mp3", 0, 0, 0);
    BASS_ChannelPlay(stream, FALSE);
    
    // Warten bis fertig
    while (BASS_ChannelIsActive(stream) == BASS_ACTIVE_PLAYING) {
        Sleep(100);
    }
    
    BASS_StreamFree(stream);
    BASS_Free();
    return 0;
}
```

### 3.2 FLAC-Dateien mit Plugin

```json
{
    "executables": [
        {
            "name": "FlacPlayer",
            "externals": ["bass"],
            "external_options": {
                "bass": {
                    "BASS_FLAC": true
                }
            }
        }
    ]
}
```

```cpp
#include <bass.h>
#include <bassflac.h>  // Jetzt verfügbar!

// FLAC wird automatisch erkannt
HSTREAM stream = BASS_StreamCreateFile(FALSE, "music.flac", 0, 0, 0);
```

### 3.3 Audio-Effekte

```json
"external_options": {
    "bass": {
        "BASS_FX": true,
        "BASS_MIX": true
    }
}
```

```cpp
#include <bass.h>
#include <bass_fx.h>

// Tempo-Stream für Pitch/Speed-Änderung
HSTREAM original = BASS_StreamCreateFile(FALSE, "music.mp3", 0, 0, BASS_STREAM_DECODE);
HSTREAM tempo = BASS_FX_TempoCreate(original, BASS_FX_FREESOURCE);

// Tempo: -20% langsamer
BASS_ChannelSetAttribute(tempo, BASS_ATTRIB_TEMPO, -20.0f);

// Pitch: 3 Halbtöne höher
BASS_ChannelSetAttribute(tempo, BASS_ATTRIB_TEMPO_PITCH, 3.0f);

BASS_ChannelPlay(tempo, FALSE);
```

---

## 4. Lua Scripting

### 4.1 Einbetten

```json
{
    "externals": {
        "lua54": { "path": "externals/lua54" }
    }
}
```

```cpp
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

int main() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    
    luaL_dostring(L, "print('Hello from Lua!')");
    
    lua_close(L);
    return 0;
}
```

### 4.2 Konfigurationsdatei laden

**config.lua:**
```lua
config = {
    window_width = 1920,
    window_height = 1080,
    fullscreen = false
}
```

**C++:**
```cpp
lua_State* L = luaL_newstate();
luaL_openlibs(L);

if (luaL_dofile(L, "config.lua") == LUA_OK) {
    lua_getglobal(L, "config");
    
    lua_getfield(L, -1, "window_width");
    int width = lua_tointeger(L, -1);
    lua_pop(L, 1);
    
    lua_getfield(L, -1, "fullscreen");
    bool fs = lua_toboolean(L, -1);
    lua_pop(L, 2);
}

lua_close(L);
```

---

## 5. doctest Testing

```json
{
    "externals": {
        "doctest": { "path": "externals/doctest" }
    },
    "executables": [
        {
            "name": "MyTests",
            "externals": ["doctest"]
        }
    ]
}
```

```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.h>

TEST_CASE("Math") {
    CHECK(1 + 1 == 2);
    CHECK(2 * 3 == 6);
}

TEST_CASE("Strings") {
    std::string s = "Hello";
    
    SUBCASE("append") {
        s += " World";
        CHECK(s == "Hello World");
    }
    
    SUBCASE("length") {
        CHECK(s.length() == 5);
    }
}
```

---

## 6. Logging mit spdlog

```json
{
    "externals": {
        "spdlog": {
            "git": "https://github.com/gabime/spdlog.git",
            "tag": "v1.12.0"
        }
    }
}
```

```cpp
#include <spdlog/spdlog.h>

int main() {
    spdlog::info("Welcome to spdlog!");
    spdlog::error("An error occurred: {}", 42);
    spdlog::warn("Easy padding in numbers: {:08d}", 12);
    
    return 0;
}
```

---

## 7. Häufige Probleme

### 7.1 "LNK2019: unresolved external symbol WinMain"

**Problem:** Windows GUI-Anwendung ohne WinMain.

**Lösung:** WinMain-Wrapper hinzufügen:

```cpp
#ifdef APP_WINDOWS_GUI
#include <Windows.h>
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int) {
    return main(__argc, __argv);
}
#endif
```

### 7.2 "imgui_impl_glfw.h not found"

**Problem:** Include-Pfad fehlt.

**Lösung:** Prüfe dass die Externals-Reihenfolge stimmt: glad → glfw → imgui.

### 7.3 "undefined reference to gladLoadGLLoader"

**Problem:** GLAD nicht gelinkt.

**Lösung:** 
1. `glad` muss vor `imgui` in Solution.json stehen
2. GLAD muss generiert sein (siehe Abschnitt 2.2)

### 7.4 "External 'xxx' not defined"

**Problem:** External wird verwendet aber nicht definiert.

**Lösung:** External im `externals`-Block der Solution.json definieren.

### 7.5 Git Download schlägt fehl

**Problem:** Netzwerkfehler beim Fetch.

**Lösung:**
1. URL prüfen
2. Netzwerkverbindung prüfen
3. Tag/Branch existiert?

---

## 8. Best Practices

### 8.1 Externals zentral definieren

```json
{
    "externals": {
        "bass": { "path": "externals/bass" },
        "spdlog": { "git": "...", "tag": "v1.12.0" }
    },
    "executables": [
        { "name": "App1", "externals": ["bass"] },
        { "name": "App2", "externals": ["bass", "spdlog"] }
    ]
}
```

### 8.2 Options nur wo nötig

```json
// ✅ Gut: Nur was gebraucht wird
"external_options": {
    "bass": {
        "BASS_FLAC": true
    }
}

// ❌ Schlecht: Alles aktivieren
"external_options": {
    "bass": {
        "BASS_FLAC": true,
        "BASS_OPUS": true,
        "BASS_DSD": true,
        // ... etc
    }
}
```

### 8.3 Versionierung mit Tags

```json
// ✅ Gut: Fester Tag
"spdlog": {
    "git": "...",
    "tag": "v1.12.0"
}

// ⚠️ Vorsicht: Branch ändert sich
"spdlog": {
    "git": "...",
    "branch": "main"
}
```

---

## 9. Siehe auch

- [Externals Reference](../References/Externals_v0_2_0.md) – Vollständige Options-Liste
- [Solution_Schema](../References/Solution_Schema_v0_1_0.md) – JSON-Schema
- [ExecutableCreate.cmake](../Modules/project/ExecutableCreate_cmake_v0_1_2_doc_v1.md) – APP_WINDOWS_GUI

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.2.0** | **2025-12-09** | **Git Externals (glfw, imgui, spdlog), GUI-App Anleitung, APP_WINDOWS_GUI** |
| 0.1.0 | 2025-12-09 | Initial: Local Externals (BASS, Lua, doctest) |
