# SourceCollect.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/core/SourceCollect.cmake](../../../cmake/core/SourceCollect.cmake)  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [SourceCollect.md](../../en/modules/core/SourceCollect.md)

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

Das `SourceCollect.cmake` Modul verwaltet die Sammlung von Source-Dateien für Executables und Libraries.

### Modi

| Mode | Beschreibung |
|------|--------------|
| `explicit` | Source.cmake erforderlich (Default, empfohlen) |
| `glob` | Automatisches Sammeln per Wildcard |
| `auto` | Source.cmake wenn vorhanden, sonst GLOB-Fallback |

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| Errors.cmake | Modul | `cmake_fatal()`, `cmake_warn()` |
| Debug.cmake | Modul | `dbg()` |
| Context.cmake | Modul | `ctx_get()` |

---

## 3. Konzept

### 3.1 Datei-Kategorien

| Kategorie | Extensions | Kompiliert? |
|-----------|------------|-------------|
| SOURCES | `.cpp`, `.cxx`, `.cc`, `.c` | ✅ |
| HEADERS | `.h`, `.hpp`, `.hxx`, `.hh` | ❌ |
| TEMPLATES | `.tpp`, `.txx`, `.ipp` | ❌ |
| INLINES | `.inl` | ❌ |
| MODULES | `.ixx`, `.cppm`, `.mpp` | ⚠️ C++20 |

### 3.2 Source.cmake Format

```cmake
set(MyApp_SOURCES
    main.cpp
    App.cpp
)

set(MyApp_HEADERS
    App.hpp
)
```

---

## 4. API-Referenz

### 4.1 _collect_sources_from_cmake()

Lädt Source.cmake und sammelt alle Dateien.

```cmake
_collect_sources_from_cmake(
    TARGET_NAME
    SOURCE_DIR
    OUT_SOURCES
    OUT_HEADERS
    OUT_EXTRAS
    OUT_MODULES
    OUT_INCLUDES
)
```

**Fehler:** `E104` wenn Source.cmake fehlt.

---

### 4.2 _collect_sources_glob()

GLOB-basierte Sammlung.

```cmake
_collect_sources_glob(
    SOURCE_DIR
    OUT_SOURCES
    OUT_HEADERS
    OUT_EXTRAS
    OUT_MODULES
)
```

---

### 4.3 collect_target_sources()

Hauptfunktion für Source-Sammlung.

```cmake
collect_target_sources(
    TARGET_NAME
    SOURCE_DIR
    SOURCE_MODE
    OUT_SOURCES
    OUT_HEADERS
    OUT_EXTRAS
    OUT_MODULES
    OUT_INCLUDES
)
```

---

## 5. Verwendungsbeispiele

### 5.1 Source.cmake erstellen

```cmake
# projects/demos/exec/MyApp/src/Source.cmake
set(MyApp_SOURCES
    main.cpp
    Application.cpp
    Window.cpp
)

set(MyApp_HEADERS
    Application.hpp
    Window.hpp
)
```

---

## 6. Fehlerbehandlung

| Code | Beschreibung |
|------|--------------|
| `E104` | Source.cmake nicht gefunden (explicit mode) |
| `W101` | Source.cmake definiert keine Dateien |
| `W109` | C++20 Module verwendet |
| `W110` | GLOB-Fallback aktiviert |

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| Explizite Source.cmake verwenden | GLOB in Produktion |
| Kategorien trennen (SOURCES/HEADERS) | Alles in eine Variable |
| Source.cmake bei neuen Dateien aktualisieren | Auf CMake-Reconfigure vertrauen |

---

## 8. Siehe auch

- [ExecutableCreate.cmake](../project/ExecutableCreate.md) — Verwendet SourceCollect
- [LibraryCreate.cmake](../project/LibraryCreate.md) — Verwendet SourceCollect

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.1 | 2025-12-05 | English translation |
| 0.1.0 | 2025-12-03 | Initial: Drei Modi, Datei-Kategorien |
