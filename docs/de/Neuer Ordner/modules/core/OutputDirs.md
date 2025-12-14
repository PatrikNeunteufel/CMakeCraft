# OutputDirs.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/core/OutputDirs.cmake](../../../cmake/core/OutputDirs.cmake)  
> **Modul-Version:** 0.1.3  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [OutputDirs.md](../../en/modules/core/OutputDirs.md)

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

Das `OutputDirs.cmake` Modul konfiguriert die Output-Verzeichnisse für Build-Artefakte mit einer hierarchischen, organisierten Struktur.

### Features

- Automatische Verzeichnis-Erstellung
- Typen-basierte Gruppierung (demos, tests, libs)
- Multi-Config Generator Support

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| CMake 3.19+ | System | Basis |

---

## 3. Konzept

### 3.1 Verzeichnisstruktur

```
out/build/{preset}/
├── demos/
│   ├── exec/
│   │   └── MyApp/
│   │       └── MyApp.exe
│   └── libs/
│       └── CoreLib/
│           └── CoreLib.lib
├── tests/
│   └── unit/
│       └── MyTests/
│           └── MyTests.exe
└── libs/
    └── SharedLib/
        └── SharedLib.dll
```

### 3.2 Konfigurierte Variablen

| Variable | Beschreibung |
|----------|--------------|
| `CMAKE_RUNTIME_OUTPUT_DIRECTORY` | Executables (.exe, .dll) |
| `CMAKE_LIBRARY_OUTPUT_DIRECTORY` | Shared Libraries |
| `CMAKE_ARCHIVE_OUTPUT_DIRECTORY` | Static Libraries (.lib, .a) |

---

## 4. API-Referenz

### 4.1 setup_output_directories()

Konfiguriert globale Output-Verzeichnisse.

```cmake
setup_output_directories()
```

**Beschreibung:**  
Setzt `CMAKE_*_OUTPUT_DIRECTORY` Variablen basierend auf dem Build-Verzeichnis.

---

### 4.2 get_target_output_dir()

Ermittelt das Output-Verzeichnis für ein Target.

```cmake
get_target_output_dir(<TARGET_TYPE> <TARGET_NAME> <OUT_VAR>)
```

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `TARGET_TYPE` | ✓ | demos/tests/libs |
| `TARGET_NAME` | ✓ | Name des Targets |
| `OUT_VAR` | ✓ | Output-Variable |

---

## 5. Verwendungsbeispiele

### 5.1 Globale Konfiguration

```cmake
include(OutputDirs)
setup_output_directories()
```

### 5.2 Target-spezifisches Verzeichnis

```cmake
get_target_output_dir("demos" "MyApp" _output_dir)
# → out/build/preset/demos/exec/MyApp
```

---

## 6. Fehlerbehandlung

Dieses Modul wirft keine Fehler.

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| `setup_output_directories()` früh aufrufen | Manuell `CMAKE_*_OUTPUT_DIRECTORY` setzen |
| Typen-basierte Gruppierung nutzen | Alle Artefakte in einem Verzeichnis |

---

## 8. Siehe auch

- [ExecutableCreate.cmake](../project/ExecutableCreate.md) — Verwendet OutputDirs
- [LibraryCreate.cmake](../project/LibraryCreate.md) — Verwendet OutputDirs

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.3 | 2025-12-05 | Hierarchische Struktur |
| 0.1.0 | 2025-12-03 | Initial |
