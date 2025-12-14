# LibraryCreate.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/project/LibraryCreate.cmake](../../../cmake/project/LibraryCreate.cmake)  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [LibraryCreate.md](../../en/modules/project/LibraryCreate.md)

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

Das `LibraryCreate.cmake` Modul erstellt das CMake-Library-Target aus Context-Daten.

### Features

- STATIC/SHARED/INTERFACE/OBJECT Support
- Public Header Konfiguration
- Alias-Target Erstellung

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| Context.cmake | Modul | ctx_get |
| SourceCollect.cmake | Modul | Source-Sammlung |

---

## 3. Konzept

### 3.1 Library-Typen

| Typ | CMake-Befehl | Verwendung |
|-----|--------------|------------|
| `STATIC` | `add_library(... STATIC)` | Standard |
| `SHARED` | `add_library(... SHARED)` | DLL/SO |
| `INTERFACE` | `add_library(... INTERFACE)` | Header-only |
| `OBJECT` | `add_library(... OBJECT)` | Objekt-Dateien |

---

## 4. API-Referenz

### 4.1 _create_library_target()

Erstellt das CMake-Library-Target.

```cmake
_create_library_target(<CTX>)
```

---

## 5. Verwendungsbeispiele

```cmake
ctx_create(LIB_0)
_collect_library("${_lib_json}" LIB_0)
_create_library_target(LIB_0)
```

---

## 6. Fehlerbehandlung

| Code | Beschreibung |
|------|--------------|
| `E104` | Source.cmake nicht gefunden |

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| Alias für Namespace (MyProject::Core) | Ohne Alias verwenden |
| public_headers für Include-Propagation | Manuelles INTERFACE_INCLUDE_DIRECTORIES |

---

## 8. Siehe auch

- [LibraryCollect.cmake](LibraryCollect.md) — Daten-Sammlung
- [ExecutableCreate.cmake](ExecutableCreate.md) — Analog für Executables

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.0 | 2025-12-05 | Initial |
