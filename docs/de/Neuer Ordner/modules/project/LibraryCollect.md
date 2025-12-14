# LibraryCollect.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/project/LibraryCollect.cmake](../../../cmake/project/LibraryCollect.cmake)  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [LibraryCollect.md](../../en/modules/project/LibraryCollect.md)

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

Das `LibraryCollect.cmake` Modul extrahiert Library-Daten aus JSON und speichert sie in einem Context-Objekt.

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| Context.cmake | Modul | ctx_create/set/get |
| Json.cmake | Modul | JSON-Zugriff |

---

## 3. Konzept

### 3.1 Extrahierte Felder

| Feld | Pflicht | Default |
|------|---------|---------|
| `name` | ✓ | — |
| `type` | — | `STATIC` |
| `public_headers` | — | — |
| `alias` | — | — |

---

## 4. API-Referenz

### 4.1 _collect_library()

Sammelt Library-Daten in Context.

```cmake
_collect_library(<LIB_JSON> <CTX>)
```

---

## 5. Verwendungsbeispiele

```cmake
ctx_create(LIB_0)
_collect_library("${_lib_json}" LIB_0)
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
| public_headers für Include-Pfade | Manuelle target_include_directories |

---

## 8. Siehe auch

- [LibraryCreate.cmake](LibraryCreate.md) — Target-Erstellung
- [ExecutableCollect.cmake](ExecutableCollect.md) — Analog für Executables

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.0 | 2025-12-05 | Initial |
