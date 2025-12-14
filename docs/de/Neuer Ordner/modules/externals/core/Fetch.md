# Fetch.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/externals/Core/Fetch.cmake](../../../cmake/externals/Core/Fetch.cmake)  
> **Modul-Version:** 0.2.0  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [Fetch.md](../../en/modules/externals/core/Fetch.md)

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

Das `Fetch.cmake` Modul lädt Git-basierte Externals über FetchContent.

### Features

- Git-Repository Cloning
- Tag/Branch/Commit Support
- PreFetch/PostFetch Hooks
- Shallow Clone Option

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| FetchContent | CMake | Native FetchContent API |
| HookLoader.cmake | Modul | Hook-Ausführung |
| Targets.cmake | Modul | Target-Registrierung |

---

## 3. Konzept

### 3.1 Fetch-Pipeline

```
1. PreFetch Hook (optional)
2. FetchContent_Declare()
3. FetchContent_MakeAvailable()
4. PostFetch Hook (optional)
5. Target-Registrierung
```

### 3.2 Version-Pinning

| Feld | Priorität | Beschreibung |
|------|-----------|--------------|
| `tag` | Hoch | Release-Tag |
| `branch` | Mittel | Branch-Name |
| `commit` | Niedrig | Commit-SHA |

---

## 4. API-Referenz

### 4.1 fetch_external()

Lädt ein Git-External.

```cmake
fetch_external(<EXT_NAME> <EXT_JSON>)
```

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `EXT_NAME` | ✓ | External-Name |
| `EXT_JSON` | ✓ | JSON mit git/tag/branch/commit |

---

## 5. Verwendungsbeispiele

### 5.1 Mit Tag

```json
{
    "imgui": {
        "git": "https://github.com/ocornut/imgui.git",
        "tag": "v1.90.1"
    }
}
```

### 5.2 Mit Branch

```json
{
    "mylib": {
        "git": "https://github.com/user/mylib.git",
        "branch": "develop"
    }
}
```

---

## 6. Fehlerbehandlung

| Code | Beschreibung |
|------|--------------|
| `E215` | Kein tag/branch/commit |
| `E216` | Git-URL ungültig |
| `E217` | Fetch fehlgeschlagen |

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| Tags für Releases | Ohne Version-Pin |
| Shallow Clone wenn möglich | Vollständige Historie |

---

## 8. Siehe auch

- [HookLoader.cmake](hooks/HookLoader.md) — Hook-System
- [Handler.cmake](fetched/Handler.md) — Post-Fetch Handling
- [Orchestrator.cmake](Orchestrator.md) — Dispatcher

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.2.0 | 2025-12-08 | Hook-Integration |
| 0.1.0 | 2025-12-06 | Initial |
