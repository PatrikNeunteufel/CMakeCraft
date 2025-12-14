# ExecutableCollect.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/project/ExecutableCollect.cmake](../../../cmake/project/ExecutableCollect.cmake)  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [ExecutableCollect.md](../../en/modules/project/ExecutableCollect.md)

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

Das `ExecutableCollect.cmake` Modul extrahiert Executable-Daten aus JSON und speichert sie in einem Context-Objekt.

### Features

- JSON → Context Transformation
- Pflichtfeld-Validierung
- Default-Werte anwenden

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| Context.cmake | Modul | ctx_create/set/get |
| Json.cmake | Modul | JSON-Zugriff |
| Errors.cmake | Modul | Fehlerbehandlung |

---

## 3. Konzept

### 3.1 Extrahierte Felder

| Feld | Pflicht | Default |
|------|---------|---------|
| `name` | ✓ | — |
| `path` | — | Berechnet aus name |
| `version` | — | `0.1.0` |
| `type` | — | `CONSOLE` |
| `skip` | — | `false` |
| `dependencies` | — | `[]` |
| `externals` | — | `[]` |

---

## 4. API-Referenz

### 4.1 _collect_executable()

Sammelt Executable-Daten in Context.

```cmake
_collect_executable(<EXE_JSON> <CTX>)
```

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `EXE_JSON` | ✓ | JSON-String des Executables |
| `CTX` | ✓ | Context-Prefix (z.B. `EXE_0`) |

---

## 5. Verwendungsbeispiele

### 5.1 Typische Verwendung

```cmake
ctx_create(EXE_0)
_collect_executable("${_exe_json}" EXE_0)

ctx_get(EXE_0 NAME _name)
ctx_get(EXE_0 PATH _path)
```

---

## 6. Fehlerbehandlung

| Code | Beschreibung |
|------|--------------|
| `E001` | Pflichtfeld 'name' fehlt |

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| Alle Felder über Context zugreifen | Direkt JSON parsen |
| Defaults für optionale Felder | Auf leere Werte verlassen |

---

## 8. Siehe auch

- [Context.cmake](../core/Context.md) — Context-Pattern
- [ExecutableCreate.cmake](ExecutableCreate.md) — Verwendet gesammelte Daten
- [Executables.cmake](Executables.md) — Ruft Collect auf

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.0 | 2025-12-04 | Initial |
