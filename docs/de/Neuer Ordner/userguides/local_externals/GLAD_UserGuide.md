# GLAD OpenGL Loader — Benutzerhandbuch

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Guide  
> **Status:** Stabil  
> **Zielgruppe:** C++ Entwickler  
> **Modul:** externals/glad/Include.cmake v0.1.0  
> **Basiert auf:** Guide v0.5  
> **Sprache:** Deutsch  
> **English:** [GLAD_UserGuide.md](../../en/guides/externals/GLAD_UserGuide.md)

---

## Inhaltsverzeichnis

1. [Überblick](#1-überblick)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Schnellstart](#3-schnellstart)
4. [GLAD generieren](#4-glad-generieren)
5. [C++ Integration](#5-c-integration)
6. [OpenGL-Profile und Versionen](#6-opengl-profile-und-versionen)
7. [Stolpersteine und Lösungen](#7-stolpersteine-und-lösungen)
8. [Troubleshooting](#8-troubleshooting)
9. [Siehe auch](#9-siehe-auch)
10. [Changelog](#10-changelog)

---

## 1. Überblick

GLAD (GL/GLES/EGL/GLX/WGL Loader-Generator) lädt moderne OpenGL-Funktionen zur Laufzeit. Da verschiedene GPU-Treiber unterschiedliche OpenGL-Versionen unterstützen, ermöglicht GLAD portablen OpenGL-Code.

### Features

- Unterstützt OpenGL 3.3+ bis 4.6
- Core und Compatibility Profile
- Plattformübergreifend (Windows, Linux, macOS)
- Automatische OpenGL-Verlinkung

---

## 2. Voraussetzungen

- [ ] CMake Architecture V2 Build-System
- [ ] OpenGL-fähige Grafikkarte und Treiber
- [ ] GLAD Code generiert (siehe Abschnitt 4)

### GLAD muss generiert sein

Im Gegensatz zu anderen Externals wird GLAD nicht heruntergeladen, sondern muss **manuell generiert** werden.

---

## 3. Schnellstart

**1. GLAD generieren** (einmalig, siehe Abschnitt 4)

**2. Solution.json:**

```json
{
    "externals": {
        "glad": {
            "path": "externals/glad"
        }
    }
}
```

**3. C++ Code:**

```cpp
#include <glad/glad.h>
#include <GLFW/glfw3.h>

int main() {
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    
    GLFWwindow* window = glfwCreateWindow(800, 600, "OpenGL", NULL, NULL);
    glfwMakeContextCurrent(window);
    
    // GLAD initialisieren NACH Context-Erstellung!
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        return -1;
    }
    
    // Jetzt OpenGL verwenden
    glViewport(0, 0, 800, 600);
    
    while (!glfwWindowShouldClose(window)) {
        glClear(GL_COLOR_BUFFER_BIT);
        glfwSwapBuffers(window);
        glfwPollEvents();
    }
    
    glfwTerminate();
    return 0;
}
```

---

## 4. GLAD generieren

### 4.1 Web-Generator (empfohlen)

1. Öffne https://glad.dav1d.de/
2. Wähle folgende Einstellungen:

| Einstellung | Empfohlen |
|-------------|-----------|
| Language | C/C++ |
| Specification | OpenGL |
| API gl | Version 3.3 (oder höher) |
| Profile | **Core** |
| Options | ✓ Generate a loader |

3. Klicke **GENERATE**
4. Lade das ZIP herunter
5. Extrahiere nach `externals/glad/`:

```
externals/glad/
├── include/
│   ├── glad/
│   │   └── glad.h
│   └── KHR/
│       └── khrplatform.h
└── src/
    └── glad.c
```

6. Füge `Include.cmake` hinzu (siehe unten)

### 4.2 Kommandozeile (glad2)

```bash
pip install glad2
glad --api gl:core=3.3 --out-path externals/glad c
```

### 4.3 Include.cmake erstellen

Falls nicht vorhanden, erstelle `externals/glad/Include.cmake`:

```cmake
# GLAD OpenGL Loader
# Version: 0.1.0

set(_path "${EXTERNAL_PATH}")

add_library(glad STATIC "${_path}/src/glad.c")
target_include_directories(glad PUBLIC "${_path}/include")

find_package(OpenGL REQUIRED)
target_link_libraries(glad PUBLIC OpenGL::GL)

if(MSVC)
    target_compile_options(glad PRIVATE /W0)
else()
    target_compile_options(glad PRIVATE -w)
endif()

_register_external_target("glad" "glad" PRIMARY)
```

---

## 5. C++ Integration

### 5.1 Initialisierungs-Reihenfolge

**Kritisch:** Die Reihenfolge ist wichtig!

1. OpenGL Context erstellen (z.B. mit GLFW)
2. `gladLoadGLLoader()` aufrufen
3. OpenGL-Funktionen verwenden

```cpp
// 1. Context erstellen
GLFWwindow* window = glfwCreateWindow(800, 600, "App", NULL, NULL);
glfwMakeContextCurrent(window);

// 2. GLAD initialisieren
if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
    std::cerr << "GLAD Initialisierung fehlgeschlagen!" << std::endl;
    return -1;
}

// 3. OpenGL verwenden
glViewport(0, 0, 800, 600);
```

### 5.2 Version prüfen

```cpp
// Nach GLAD-Init
std::cout << "OpenGL Version: " << glGetString(GL_VERSION) << std::endl;
std::cout << "GLSL Version: " << glGetString(GL_SHADING_LANGUAGE_VERSION) << std::endl;
std::cout << "Renderer: " << glGetString(GL_RENDERER) << std::endl;
```

### 5.3 Extension prüfen

```cpp
if (GLAD_GL_ARB_debug_output) {
    std::cout << "Debug Output Extension verfügbar" << std::endl;
}
```

---

## 6. OpenGL-Profile und Versionen

### 6.1 Core vs Compatibility Profile

| Profile | Beschreibung |
|---------|--------------|
| **Core** | Nur moderne API, deprecated Funktionen entfernt |
| **Compatibility** | Alte + neue API, für Legacy-Code |

**Empfehlung:** Core Profile für neue Projekte.

### 6.2 Version wählen

| Version | Features | Verbreitung |
|---------|----------|-------------|
| 3.3 | Modern, stabil | Sehr hoch |
| 4.0 | Tessellation | Hoch |
| 4.3 | Compute Shaders | Mittel |
| 4.6 | Neueste Features | Nur aktuelle GPUs |

**Empfehlung:** 3.3 für maximale Kompatibilität, 4.3+ für Compute Shaders.

### 6.3 GLFW Context Hints

```cpp
glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

#ifdef __APPLE__
glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
#endif
```

---

## 7. Stolpersteine und Lösungen

### 7.1 GLAD vor GLFW inkludieren

**Problem:**
```
error: gl.h included before glad.h
```

**Lösung:** GLAD immer **vor** GLFW/SDL/etc. inkludieren:

```cpp
#include <glad/glad.h>  // ERST glad
#include <GLFW/glfw3.h> // DANN glfw
```

### 7.2 GLAD vor Context-Erstellung aufrufen

**Problem:**
```
gladLoadGLLoader failed
```

**Ursache:** Kein aktiver OpenGL Context.

**Lösung:** Context erstellen bevor `gladLoadGLLoader()`:

```cpp
glfwMakeContextCurrent(window);  // Context aktivieren
gladLoadGLLoader(...);           // DANN GLAD initialisieren
```

### 7.3 Falsche OpenGL-Version

**Problem:** Nur OpenGL 1.1 Funktionen verfügbar.

**Ursache:** Software-Renderer oder falscher Context.

**Lösung:**
1. GPU-Treiber aktualisieren
2. Context Hints korrekt setzen
3. Prüfen ob Hardware-Beschleunigung aktiv

---

## 8. Troubleshooting

### Checkliste

- [ ] GLAD generiert (glad.h und glad.c vorhanden)?
- [ ] Include.cmake vorhanden?
- [ ] OpenGL Context vor `gladLoadGLLoader()` erstellt?
- [ ] glad.h vor anderen GL-Headers inkludiert?
- [ ] GPU-Treiber aktuell?

### Häufige Fehler

| Fehler | Lösung |
|--------|--------|
| `glad.h not found` | GLAD generieren (Abschnitt 4) |
| `glad.c not found` | Vollständiges ZIP extrahieren |
| `gladLoadGLLoader failed` | Context vor Init erstellen |
| `undefined reference to glXXX` | OpenGL Library linken |

### Plattform-spezifisch

**Linux:**
```bash
sudo apt install libgl1-mesa-dev
```

**macOS:**
- OpenGL deprecated seit 10.14
- Maximum OpenGL 4.1 (kein 4.3+)
- Für moderne Graphics: Metal verwenden

---

## 9. Siehe auch

- [GLAD Include.cmake](../../modules/externals/glad/Include.md) — Technische Dokumentation
- [GLAD Generator](https://glad.dav1d.de/) — Web-Generator
- [GLFW PreFetch Hook](../../modules/externals/hooks/prefetch/glfw.md) — Window/Context
- [OpenGL Reference](https://www.khronos.org/opengl/) — Offizielle Spezifikation

---

## 10. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Neu: Vollständiges Benutzerhandbuch mit Generierung, Profile, Versionen** |
