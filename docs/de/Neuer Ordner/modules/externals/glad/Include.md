# GLAD OpenGL Loader – Include.cmake

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [externals/glad/Include.cmake](../../../../externals/glad/Include.cmake)  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [Include.md](../../../en/modules/externals/glad/Include.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [Konzept](#3-konzept)
4. [API-Referenz](#4-api-referenz)
5. [Verwendungsbeispiele](#5-verwendungsbeispiele)
6. [Fehlerbehandlung](#6-fehlerbehandlung)
7. [Best Practices](#7-best-practices)
8. [Bekannte Einschränkungen](#8-bekannte-einschränkungen)
9. [Siehe auch](#9-siehe-auch)
10. [Changelog](#10-changelog)

---

## 1. Übersicht

GLAD (GL/GLES/EGL/GLX/WGL Loader-Generator) ist ein Tool das OpenGL-Loader-Code generiert. Der generierte Code wird als lokales External eingebunden und ermöglicht das Laden moderner OpenGL-Funktionen.

### Features

- Statische Library aus generiertem Code
- Automatische OpenGL-Verlinkung
- Plattformübergreifend (Windows, Linux, macOS)
- Unterstützt verschiedene OpenGL-Profile und Versionen

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| OpenGL | System | `find_package(OpenGL REQUIRED)` |
| CMake 3.19+ | System | Für JSON-Verarbeitung |

---

## 3. Konzept

### 3.1 Generierter Code

GLAD muss zunächst generiert werden, bevor es verwendet werden kann. Der Generator erstellt plattform-spezifischen C-Code.

### 3.2 Verzeichnisstruktur

```
externals/glad/
├── Include.cmake      ← Dieses Modul
├── include/
│   ├── glad/
│   │   └── glad.h     ← Generierter Header
│   └── KHR/
│       └── khrplatform.h
└── src/
    └── glad.c         ← Generierter Source
```

### 3.3 Statische Library

Das Modul erstellt eine statische Library aus `glad.c`:

```cmake
add_library(glad STATIC "${_path}/src/glad.c")
target_include_directories(glad PUBLIC "${_path}/include")
target_link_libraries(glad PUBLIC OpenGL::GL)
```

---

## 4. API-Referenz

### 4.1 Erwartete Variablen

| Variable | Pflicht | Beschreibung |
|----------|---------|--------------|
| `EXTERNAL_NAME` | ✓ | Name des Externals (`"glad"`) |
| `EXTERNAL_PATH` | ✓ | Pfad zum External-Verzeichnis |
| `EXECUTABLE_NAME` | ✓ | Ziel-Target |

### 4.2 Verfügbare Options

GLAD hat **keine** konfigurierbaren Options. Die OpenGL-Version und das Profil werden bei der Code-Generierung festgelegt.

### 4.3 Registrierte Targets

| Target | Typ | Beschreibung |
|--------|-----|--------------|
| `glad` | PRIMARY | GLAD Static Library |

### 4.4 Validierung

Das Modul validiert:

```cmake
if(NOT EXISTS "${_path}/include/glad/glad.h")
    message(FATAL_ERROR "[glad] glad.h not found")
endif()

if(NOT EXISTS "${_path}/src/glad.c")
    message(FATAL_ERROR "[glad] glad.c not found")
endif()
```

---

## 5. Verwendungsbeispiele

### 5.1 External definieren (Solution.json)

```json
{
    "externals": {
        "glad": {
            "path": "externals/glad"
        }
    }
}
```

### 5.2 Typische Kombination (OpenGL-Projekt)

```json
{
    "externals": {
        "glad": {
            "path": "externals/glad"
        },
        "glfw": {
            "git": "https://github.com/glfw/glfw.git",
            "tag": "3.4"
        }
    }
}
```

**Wichtig:** GLAD muss vor Targets definiert werden, die es verwenden (z.B. ImGui).

---

## 6. Fehlerbehandlung

### Error Codes

| Code | Konstante | Beschreibung |
|------|-----------|--------------|
| E213 | `E_LOCAL_INCLUDE_NOT_FOUND` | Include.cmake nicht gefunden |

### Häufige Fehler

| Fehler | Ursache | Lösung |
|--------|---------|--------|
| `glad.h not found` | GLAD nicht generiert | Web-Generator nutzen |
| `glad.c not found` | Unvollständige Installation | Komplettes ZIP entpacken |
| `undefined reference to glXXX` | GLAD nicht initialisiert | `gladLoadGLLoader()` aufrufen |
| `OpenGL not found` | System-Treiber fehlt | GPU-Treiber installieren |

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| GLAD vor ImGui/anderen GL-Libs definieren | GLAD nach abhängigen Libs |
| `gladLoadGLLoader()` nach Context-Erstellung | GL-Funktionen vor Init aufrufen |
| Core-Profile verwenden | Compatibility-Profile |

---

## 8. Bekannte Einschränkungen

- GLAD muss manuell generiert werden (nicht automatisch heruntergeladen)
- macOS: OpenGL deprecated seit 10.14 (Metal bevorzugen)
- Warnungen werden für generierten Code unterdrückt

---

## 9. Siehe auch

- [GLAD UserGuide](../../../guides/externals/GLAD_UserGuide.md) — Benutzerhandbuch
- [GLAD Generator](https://glad.dav1d.de/) — Web-Generator
- [imgui PostFetch Hook](../hooks/postfetch/imgui.md) — ImGui mit GLAD
- [glfw PreFetch Hook](../hooks/prefetch/glfw.md) — GLFW Window/Context

---

## 10. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.0 | 2025-12-09 | Initial: GLAD Integration, OpenGL-Linking |
