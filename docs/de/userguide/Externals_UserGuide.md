# Externals – Benutzerhandbuch

> **Version:** 0.5.0  
> **Datum:** 2025-12-14  
> **Typ:** Guide  
> **Status:** Stabil  
> **Zielgruppe:** C++ Entwickler  
> **Sprache:** Deutsch  
> **English:** [Externals_UserGuide.md](../../en/guides/Externals_UserGuide.md)

---

## Inhaltsverzeichnis

1. [Überblick](#1-überblick)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Schnellstart](#3-schnellstart)
4. [GUI-Anwendung mit OpenGL/ImGui](#4-gui-anwendung-mit-openglimgui)
5. [BASS Audio Library](#5-bass-audio-library)
6. [Lua Scripting](#6-lua-scripting)
7. [doctest Testing](#7-doctest-testing)
8. [Logging mit spdlog](#8-logging-mit-spdlog)
9. [Best Practices](#9-best-practices)
10. [Stolpersteine und Lösungen](#10-stolpersteine-und-lösungen)
11. [Troubleshooting](#11-troubleshooting)
12. [Siehe auch](#12-siehe-auch)

---

## 1. Überblick

Dieser Guide erklärt, wie externe Bibliotheken in CMake Architecture V2 Projekten verwendet werden.

### Features

- **Lokale Externals:** Bibliotheken im `externals/` Ordner
- **Git Externals:** Automatischer Download via FetchContent
- **Automatisches Linking:** Include-Pfade und Libraries werden automatisch konfiguriert
- **DLL-Kopieren:** Windows-DLLs werden automatisch ins Build-Verzeichnis kopiert
- **Options:** Bibliotheks-spezifische Konfiguration (z.B. BASS-Plugins)

### Unterstützte External-Typen

| Typ | Beschreibung | Beispiel |
|-----|--------------|----------|
| **Local** | Im Projekt enthalten | BASS, Lua, doctest |
| **Git** | Per FetchContent geladen | GLFW, ImGui, spdlog |
| **System** | Systemweit installiert | Qt6, OpenGL |

---

## 2. Voraussetzungen

### Checkliste

- [ ] **CMake Architecture V2** eingerichtet
- [ ] **Solution.json** vorhanden
- [ ] **Git** installiert (für Git Externals)
- [ ] **Internetverbindung** (für Git Externals)

### Für spezifische Externals

| External | Zusätzliche Voraussetzung |
|----------|---------------------------|
| GLAD | OpenGL-Treiber, GLAD Generator |
| Qt6 | Qt6 Installation |
| BASS | BASS SDK Download |

---

## 3. Schnellstart

### 3.1 Lokales External hinzufügen

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

### 3.2 Git External hinzufügen

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

## 4. GUI-Anwendung mit OpenGL/ImGui

Dies ist das häufigste Szenario für grafische Anwendungen.

### 4.1 Solution.json

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

### 4.2 GLAD generieren

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

### 4.3 main.cpp für Windows GUI

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

### 4.4 Bauen

```bash
cmake --preset msvc-debug
cmake --build build/msvc-debug
```

---

## 5. BASS Audio Library

### 5.1 Einfache Audio-Wiedergabe

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

### 5.2 FLAC-Dateien mit Plugin

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

### 5.3 Audio-Effekte

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

## 6. Lua Scripting

### 6.1 Einbetten

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

### 6.2 Konfigurationsdatei laden

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

## 7. doctest Testing

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

## 8. Logging mit spdlog

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

## 9. Best Practices

### 9.1 Externals zentral definieren

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

### 9.2 Options nur wo nötig

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

### 9.3 Versionierung mit Tags

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

## 10. Stolpersteine und Lösungen

### 10.1 "LNK2019: unresolved external symbol WinMain"

**Problem:** Windows GUI-Anwendung ohne WinMain.

**Ursache:** Bei `type: "GUI"` erwartet Windows einen WinMain Entry Point, nicht main().

**Lösung:** WinMain-Wrapper hinzufügen:

```cpp
#ifdef APP_WINDOWS_GUI
#include <Windows.h>
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int) {
    return main(__argc, __argv);
}
#endif
```

### 10.2 "imgui_impl_glfw.h not found"

**Problem:** Include-Pfad fehlt.

**Ursache:** ImGui-Backends sind nicht im Include-Pfad.

**Lösung:** Prüfe dass die Externals-Reihenfolge stimmt: glad → glfw → imgui. Der PostFetch-Hook für ImGui fügt die Backends hinzu.

### 10.3 "undefined reference to gladLoadGLLoader"

**Problem:** GLAD nicht gelinkt.

**Ursache:** GLAD wurde nicht vor anderen OpenGL-Externals gelinkt.

**Lösung:** 
1. `glad` muss vor `imgui` in Solution.json stehen
2. GLAD muss generiert sein (siehe Abschnitt 4.2)

### 10.4 "External 'xxx' not defined"

**Problem:** External wird verwendet aber nicht definiert.

**Ursache:** External fehlt im `externals`-Block der Solution.json.

**Lösung:** External im `externals`-Block definieren:

```json
"externals": {
    "xxx": { "path": "externals/xxx" }
}
```

### 10.5 Git Download schlägt fehl

**Problem:** Netzwerkfehler beim Fetch.

**Ursache:** Netzwerkproblem, falsche URL, oder Tag existiert nicht.

**Lösung:**
1. URL prüfen (im Browser testen)
2. Netzwerkverbindung prüfen
3. Tag/Branch existiert? (GitHub-Releases prüfen)
4. Firewall/Proxy-Einstellungen

---

## 11. Troubleshooting

### Checkliste bei Problemen

1. ☐ External in `externals`-Block definiert?
2. ☐ External in Executable's `externals`-Liste?
3. ☐ Reihenfolge korrekt? (Abhängigkeiten zuerst)
4. ☐ CMake-Cache gelöscht? (`cmake --fresh`)
5. ☐ Include.cmake vorhanden (bei lokalen Externals)?
6. ☐ Git-Tag korrekt? (bei Git Externals)

### Häufige Fehler

| Fehler | Lösung |
|--------|--------|
| `External 'xxx' not defined` | Zu `externals`-Block hinzufügen |
| `Target not found` | Include.cmake prüfen / PostFetch-Hook fehlt |
| `undefined reference` | Reihenfolge prüfen, External verlinken |
| `file not found` | Include-Pfade prüfen |
| `FetchContent failed` | URL und Tag prüfen |

### Debug-Ausgabe

```bash
# Verbose CMake
cmake --preset ... --debug-output

# Nur Externals debuggen
cmake --preset ... -DEXTERNALS_DEBUG=ON
```

---

## 12. Siehe auch

- [Externals.md](../reference/Externals.md) – Vollständige Options-Liste
- [Solution_Schema.md](../reference/Solution_Schema.md) – JSON-Schema
- [Adding_Externals_UserGuide.md](Adding_Externals_UserGuide.md) – Neue Externals hinzufügen
- [Git_Externals_Reference.md](../reference/Git_Externals_Reference.md) – Git External Übersicht

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-14** | **Blueprint v0.5.0 Konformität: Überblick, Voraussetzungen, Stolpersteine/Troubleshooting getrennt, Siehe auch** |
| 0.2.0 | 2025-12-09 | Git Externals (glfw, imgui, spdlog), GUI-App Anleitung, APP_WINDOWS_GUI |
| 0.1.0 | 2025-12-09 | Initial: Local Externals (BASS, Lua, doctest) |
