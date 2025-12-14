# Externals.cmake — Dokumentation (Project)

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/project/Externals.cmake](../../../cmake/project/Externals.cmake)  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [Externals.md](../../en/modules/project/Externals.md)

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

Das `Externals.cmake` Modul (im project/-Ordner) ist der Einstiegspunkt für die External-Verarbeitung. Es liest den externals-Block aus Solution.json und delegiert an den Orchestrator.

### Features

- Externals-Block parsing
- Typ-Erkennung (lokal vs. git)
- Orchestrator-Delegation

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| Solution.cmake | Modul | SOLUTION_JSON |
| Json.cmake | Modul | JSON-Parsing |
| Orchestrator.cmake | Modul | External-Dispatch |

---

## 3. Konzept

### 3.1 Externals-Block

```json
{
    "externals": {
        "bass": {
            "path": "externals/bass"
        },
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.90.1"
        }
    }
}
```

### 3.2 Typ-Erkennung

| Feld | Typ |
|------|-----|
| `path` | Lokal |
| `git` | Fetched |

---

## 4. API-Referenz

### 4.1 process_externals()

Verarbeitet alle Externals aus Solution.json.

```cmake
process_externals()
```

---

## 5. Verwendungsbeispiele

```cmake
include(cmake/project/Externals.cmake)
process_externals()
```

---

## 6. Fehlerbehandlung

| Code | Beschreibung |
|------|--------------|
| `E012` | Kein Source-Feld (path/git) |
| `E013` | Mehrere Source-Felder |

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| Externals zentral in Solution.json | Per-Target External-Definition |
| Explizite Tags für Git-Externals | Ohne Version-Pin |

---

## 8. Siehe auch

- [Orchestrator.cmake](../externals/Orchestrator.md) — External-Dispatch
- [Fetch.cmake](../externals/core/Fetch.md) — Git-Fetch
- [Attach.cmake](../externals/local/Attach.md) — Lokale Externals

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.0 | 2025-12-06 | Initial |
