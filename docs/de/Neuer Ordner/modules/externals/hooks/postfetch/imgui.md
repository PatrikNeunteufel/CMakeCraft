# imgui.cmake (PostFetch) — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/externals/Hooks/PostFetch/imgui.cmake](../../../../cmake/externals/Hooks/PostFetch/imgui.cmake)  
> **Modul-Version:** 0.2.0  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [imgui.md](../../../en/modules/externals/hooks/postfetch/imgui.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [Konzept](#3-konzept)
4. [Erstellte Targets](#4-erstellte-targets)
5. [Verwendungsbeispiele](#5-verwendungsbeispiele)
6. [Fehlerbehandlung](#6-fehlerbehandlung)
7. [Best Practices](#7-best-practices)
8. [Siehe auch](#8-siehe-auch)
9. [Changelog](#9-changelog)

---

## 1. Übersicht

Der `imgui.cmake` PostFetch Hook erstellt CMake-Targets aus den ImGui-Quellen, da ImGui keine eigene CMakeLists.txt hat.

### Features

- imgui Core-Library Target
- Backend-Targets (GLFW, OpenGL3, etc.)
- Automatische Source-Konfiguration

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| HookLoader.cmake | Modul | Lädt den Hook |
| HOOK_SOURCE_DIR | Variable | Vom HookLoader injiziert |

---

## 3. Konzept

### 3.1 ImGui hat keine CMakeLists.txt

ImGui ist ein "Drop-in" Projekt ohne Build-System. Der PostFetch Hook erstellt die nötigen Targets.

### 3.2 Erstellte Struktur

```
imgui (STATIC)
    │
    ├── imgui.cpp
    ├── imgui_draw.cpp
    ├── imgui_tables.cpp
    ├── imgui_widgets.cpp
    └── imgui_demo.cpp

imgui_backend_glfw (STATIC)
    │
    └── backends/imgui_impl_glfw.cpp

imgui_backend_opengl3 (STATIC)
    │
    └── backends/imgui_impl_opengl3.cpp
```

---

## 4. Erstellte Targets

| Target | Typ | Beschreibung |
|--------|-----|--------------|
| `imgui` | STATIC | Core-Library |
| `imgui_backend_glfw` | STATIC | GLFW-Backend |
| `imgui_backend_opengl3` | STATIC | OpenGL3-Backend |
| `imgui_backend_vulkan` | STATIC | Vulkan-Backend (optional) |
| `imgui_backend_dx11` | STATIC | DirectX11-Backend (optional) |

---

## 5. Verwendungsbeispiele

### 5.1 Solution.json

```json
{
    "externals": {
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.90.1"
        }
    },
    "executables": [
        {
            "name": "MyApp",
            "externals": ["imgui", "glfw"]
        }
    ]
}
```

### 5.2 Im Code

```cpp
#include <imgui.h>
#include <imgui_impl_glfw.h>
#include <imgui_impl_opengl3.h>
```

---

## 6. Fehlerbehandlung

| Code | Beschreibung |
|------|--------------|
| `E221` | ImGui-Quellen nicht gefunden |

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| Benötigte Backends aktivieren | Alle Backends einbinden |
| Mit GLFW/OpenGL3 starten | Komplexe Backends ohne Erfahrung |

---

## 8. Siehe auch

- [HookLoader.cmake](../HookLoader.md) — Hook-System
- [Fetch.cmake](../../core/Fetch.md) — Ruft Hooks auf
- [GLFW PreFetch](../prefetch/glfw.md) — GLFW-Konfiguration

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.2.0 | 2025-12-08 | Backend-Targets |
| 0.1.0 | 2025-12-07 | Initial |
