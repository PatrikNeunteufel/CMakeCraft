# glad/Include.cmake – Dokumentation

> **Version:** 0.1.0 (doc v1)  
> **Datum:** 2025-12-09  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** externals/glad/Include.cmake  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/externals/glad_Include_cmake_v0_1_0.md)

---

## 1. Übersicht

Die `glad/Include.cmake` Datei integriert den GLAD OpenGL Loader als lokales External. GLAD generiert plattform-spezifischen Code zum Laden von OpenGL-Funktionen.

### Was ist GLAD?

GLAD (GL/GLES/EGL/GLX/WGL Loader-Generator) ist ein Tool das OpenGL-Loader-Code generiert. Der generierte Code wird als lokales External eingebunden, nicht als Git-Dependency.

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| OpenGL | System | `find_package(OpenGL REQUIRED)` |

---

## 3. Verzeichnisstruktur

```
externals/glad/
├── Include.cmake      ← Diese Datei
├── include/
│   ├── glad/
│   │   └── glad.h     ← Generierter Header
│   └── KHR/
│       └── khrplatform.h
└── src/
    └── glad.c         ← Generierter Source
```

---

## 4. GLAD generieren

### 4.1 Web-Generator

1. Öffne https://glad.dav1d.de/
2. Wähle:
   - Language: **C/C++**
   - Specification: **OpenGL**
   - API gl: **Version 3.3** (oder höher)
   - Profile: **Core**
   - Options: **Generate a loader**
3. Klicke **GENERATE**
4. Lade das ZIP herunter
5. Extrahiere nach `externals/glad/`

### 4.2 Kommandozeile (glad2)

```bash
pip install glad2
glad --api gl:core=3.3 --out-path externals/glad c
```

---

## 5. Include.cmake Implementierung

```cmake
# externals/glad/Include.cmake
# GLAD OpenGL Loader
# Version: 0.1.0

# Kompatibilität: Unterstütze beide Variablen-Namen
if(DEFINED EXTERNAL_NAME)
    set(_name "${EXTERNAL_NAME}")
elseif(DEFINED EXTERNAL_ELEMENT_NAME)
    set(_name "${EXTERNAL_ELEMENT_NAME}")
else()
    set(_name "glad")
endif()

if(DEFINED EXTERNAL_PATH)
    set(_path "${EXTERNAL_PATH}")
elseif(DEFINED EXTERNAL_ELEMENT_PATH)
    set(_path "${EXTERNAL_ELEMENT_PATH}")
else()
    message(FATAL_ERROR "[glad] EXTERNAL_PATH not defined")
endif()

# Validierung
if(NOT EXISTS "${_path}/include/glad/glad.h")
    message(FATAL_ERROR "[glad] glad.h not found in ${_path}/include/glad/")
endif()

if(NOT EXISTS "${_path}/src/glad.c")
    message(FATAL_ERROR "[glad] glad.c not found in ${_path}/src/")
endif()

# Library Target erstellen
add_library(glad STATIC "${_path}/src/glad.c")

target_include_directories(glad PUBLIC
    "${_path}/include"
)

# OpenGL linken
find_package(OpenGL REQUIRED)
target_link_libraries(glad PUBLIC OpenGL::GL)

# Warnungen unterdrücken (generierter Code)
if(MSVC)
    target_compile_options(glad PRIVATE /W0)
else()
    target_compile_options(glad PRIVATE -w)
endif()

# Target registrieren
_register_external_target("glad" "glad" PRIMARY)

message(STATUS "[glad] GLAD OpenGL loader configured")
```

---

## 6. Verwendung im Code

### 6.1 Initialisierung

```cpp
#include <glad/glad.h>
#include <GLFW/glfw3.h>

int main() {
    // GLFW initialisieren
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    GLFWwindow* window = glfwCreateWindow(800, 600, "OpenGL", NULL, NULL);
    glfwMakeContextCurrent(window);

    // GLAD initialisieren (NACH Context-Erstellung!)
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        // Fehlerbehandlung
        return -1;
    }

    // Jetzt können OpenGL-Funktionen verwendet werden
    glViewport(0, 0, 800, 600);
    
    // ...
}
```

### 6.2 Wichtige Reihenfolge

1. OpenGL Context erstellen (z.B. via GLFW)
2. `gladLoadGLLoader()` aufrufen
3. OpenGL-Funktionen nutzen

---

## 7. Solution.json Konfiguration

```json
{
    "externals": {
        "glad": {
            "path": "externals/glad"
        }
    }
}
```

### 7.1 Typische Kombination

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

**Reihenfolge wichtig!** GLAD muss vor ImGui kommen damit `TARGET glad` existiert wenn ImGui linkt.

---

## 8. Fehlerbehandlung

| Fehler | Ursache | Lösung |
|--------|---------|--------|
| `glad.h not found` | GLAD nicht generiert | Web-Generator nutzen |
| `glad.c not found` | Unvollständige Installation | Komplettes ZIP entpacken |
| `undefined reference to glXXX` | GLAD nicht initialisiert | `gladLoadGLLoader()` aufrufen |
| `OpenGL not found` | System-Treiber fehlt | GPU-Treiber installieren |

---

## 9. Plattform-Hinweise

### Windows

- OpenGL-Headers von Windows SDK
- Treiber-abhängige Funktionen über GLAD geladen

### Linux

```bash
# Benötigte Pakete (Ubuntu/Debian)
sudo apt install libgl1-mesa-dev
```

### macOS

- OpenGL deprecated seit macOS 10.14
- Für Legacy-Support: Metal bevorzugen

---

## 10. Debug

### OpenGL Version prüfen

```cpp
const GLubyte* version = glGetString(GL_VERSION);
printf("OpenGL Version: %s\n", version);
```

### GLAD Debug Extension

Im Web-Generator "Generate Debug" aktivieren für zusätzliche Fehlerprüfung.

---

## 11. Siehe auch

- [Attach.cmake](../Modules/Externals/Attach_cmake_v0_1_0_doc_v1.md) – Local Handler
- [imgui PostFetch Hook](../Hooks/imgui_PostFetch_v0_2_0_doc_v1.md) – GLAD-Linking
- [glfw PreFetch Hook](../Hooks/glfw_PreFetch_v0_1_0_doc_v1.md) – Window/Context
- https://glad.dav1d.de/ – GLAD Generator

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0 (doc v1)** | **2025-12-09** | **Initial: GLAD Integration, OpenGL-Linking, Generierung** |
