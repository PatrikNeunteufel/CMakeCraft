# Libraries.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/project/Libraries.cmake](../../../cmake/project/Libraries.cmake)  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [Libraries.md](../../en/modules/project/Libraries.md)

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

Das `Libraries.cmake` Modul ist die Hauptschleife für die Library-Pipeline. Analog zu Executables.cmake.

### Features

- Iteration über alle Libraries
- BUILD_ONLY Filterung
- Library-Typ-Unterstützung (STATIC, SHARED, INTERFACE)

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| Solution.cmake | Modul | SOLUTION_JSON |
| LibraryCollect.cmake | Modul | JSON → Context |
| LibraryCreate.cmake | Modul | Target-Erstellung |

---

## 3. Konzept

### 3.1 Library-Typen

| Typ | Beschreibung |
|-----|--------------|
| `STATIC` | Statische Library (.lib/.a) |
| `SHARED` | Dynamische Library (.dll/.so) |
| `INTERFACE` | Header-only Library |
| `OBJECT` | Object-Library |

---

## 4. API-Referenz

### 4.1 process_libraries()

Verarbeitet alle Libraries aus Solution.json.

```cmake
process_libraries()
```

---

## 5. Verwendungsbeispiele

### 5.1 CMakeLists.txt Integration

```cmake
include(cmake/project/Libraries.cmake)
process_libraries()
```

---

## 6. Fehlerbehandlung

| Code | Beschreibung |
|------|--------------|
| `E001` | Pflichtfeld fehlt |

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| INTERFACE für Header-only | STATIC für Header-only |
| public_headers definieren | Include-Pfade manuell setzen |

---

## 8. Siehe auch

- [LibraryCollect.cmake](LibraryCollect.md) — JSON-Parsing
- [LibraryCreate.cmake](LibraryCreate.md) — Target-Erstellung
- [Executables.cmake](Executables.md) — Analog für Executables

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.0 | 2025-12-05 | Initial |
