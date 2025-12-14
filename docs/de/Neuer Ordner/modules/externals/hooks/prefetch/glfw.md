# glfw.cmake (PreFetch) — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/externals/Hooks/PreFetch/glfw.cmake](../../../../cmake/externals/Hooks/PreFetch/glfw.cmake)  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [glfw.md](../../../en/modules/externals/hooks/prefetch/glfw.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [Konzept](#3-konzept)
4. [Konfiguration](#4-konfiguration)
5. [Verwendungsbeispiele](#5-verwendungsbeispiele)
6. [Fehlerbehandlung](#6-fehlerbehandlung)
7. [Best Practices](#7-best-practices)
8. [Siehe auch](#8-siehe-auch)
9. [Changelog](#9-changelog)

---

## 1. Übersicht

Der `glfw.cmake` PreFetch Hook konfiguriert GLFW-Optionen vor dem FetchContent.

### Features

- Docs/Tests/Examples deaktivieren
- Build-Optionen optimieren

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| HookLoader.cmake | Modul | Lädt den Hook |

---

## 3. Konzept

### 3.1 Gesetzte Optionen

| Option | Wert | Beschreibung |
|--------|------|--------------|
| `GLFW_BUILD_DOCS` | OFF | Keine Dokumentation |
| `GLFW_BUILD_TESTS` | OFF | Keine Tests |
| `GLFW_BUILD_EXAMPLES` | OFF | Keine Beispiele |

---

## 4. Konfiguration

```cmake
# cmake/externals/Hooks/PreFetch/glfw.cmake
message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch: Configuring GLFW")

set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)

message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch complete")
```

---

## 5. Verwendungsbeispiele

### 5.1 Solution.json

```json
{
    "externals": {
        "glfw": {
            "git": "https://github.com/glfw/glfw.git",
            "tag": "3.3.9"
        }
    }
}
```

Hook wird automatisch geladen wenn vorhanden.

---

## 6. Fehlerbehandlung

Keine Fehler — Hook ist optional.

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| Unnötige Builds deaktivieren | Alles aktiviert lassen |
| FORCE für CMake-Optionen | Ohne FORCE setzen |

---

## 8. Siehe auch

- [HookLoader.cmake](../HookLoader.md) — Hook-System
- [Fetch.cmake](../../core/Fetch.md) — Ruft Hooks auf

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.0 | 2025-12-07 | Initial |
