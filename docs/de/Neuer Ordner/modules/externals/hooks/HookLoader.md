# HookLoader.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/externals/Hooks/HookLoader.cmake](../../../cmake/externals/Hooks/HookLoader.cmake)  
> **Modul-Version:** 0.2.0  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [HookLoader.md](../../en/modules/externals/hooks/HookLoader.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [Konzept](#3-konzept)
4. [API-Referenz](#4-api-referenz)
5. [Verwendungsbeispiele](#5-verwendungsbeispiele)
6. [Fehlerbehandlung](#6-fehlerbehandlung)
7. [Best Practices](#7-best-practices)
8. [Siehe auch](#8-siehe-auch)
9. [Changelog](#9-changelog)

---

## 1. Übersicht

Das `HookLoader.cmake` Modul lädt und führt PreFetch/PostFetch Hooks für Externals aus.

### Features

- PreFetch Hooks (vor FetchContent)
- PostFetch Hooks (nach FetchContent)
- Automatische Hook-Erkennung
- Hook-Variablen Injection

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| CMake 3.19+ | System | Basis |

---

## 3. Konzept

### 3.1 Hook-Verzeichnisse

```
cmake/externals/Hooks/
├── PreFetch/
│   ├── glfw.cmake
│   └── googletest.cmake
└── PostFetch/
    └── imgui.cmake
```

### 3.2 Injizierte Variablen

| Variable | Beschreibung |
|----------|--------------|
| `HOOK_EXTERNAL_NAME` | Name des Externals |
| `HOOK_SOURCE_DIR` | Source-Verzeichnis (PostFetch) |
| `HOOK_BINARY_DIR` | Binary-Verzeichnis (PostFetch) |

---

## 4. API-Referenz

### 4.1 load_prefetch_hook()

Lädt PreFetch Hook wenn vorhanden.

```cmake
load_prefetch_hook(<EXT_NAME>)
```

---

### 4.2 load_postfetch_hook()

Lädt PostFetch Hook wenn vorhanden.

```cmake
load_postfetch_hook(<EXT_NAME> <SOURCE_DIR> <BINARY_DIR>)
```

---

## 5. Verwendungsbeispiele

### 5.1 PreFetch Hook (glfw.cmake)

```cmake
# cmake/externals/Hooks/PreFetch/glfw.cmake
message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch: Configuring GLFW")
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
```

### 5.2 PostFetch Hook (imgui.cmake)

```cmake
# cmake/externals/Hooks/PostFetch/imgui.cmake
message(STATUS "[${HOOK_EXTERNAL_NAME}] PostFetch: Creating ImGui target")
add_library(imgui STATIC
    ${HOOK_SOURCE_DIR}/imgui.cpp
    # ...
)
```

---

## 6. Fehlerbehandlung

Keine Fehler — Hooks sind optional.

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| Hook-Namen = External-Namen | Generische Hook-Namen |
| Optionen im PreFetch setzen | Optionen nach Fetch ändern |

---

## 8. Siehe auch

- [Fetch.cmake](../core/Fetch.md) — Ruft Hooks auf
- [glfw PreFetch](prefetch/glfw.md) — Beispiel PreFetch
- [imgui PostFetch](postfetch/imgui.md) — Beispiel PostFetch

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.2.0 | 2025-12-08 | Variable Injection |
| 0.1.0 | 2025-12-07 | Initial |
