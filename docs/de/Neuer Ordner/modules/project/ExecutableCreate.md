# ExecutableCreate.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/project/ExecutableCreate.cmake](../../../cmake/project/ExecutableCreate.cmake)  
> **Modul-Version:** 0.1.2  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [ExecutableCreate.md](../../en/modules/project/ExecutableCreate.md)

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

Das `ExecutableCreate.cmake` Modul erstellt das CMake-Target aus Context-Daten.

### Features

- Target-Erstellung (GUI/CONSOLE)
- Source-Collection (explizit/glob)
- PCH-Konfiguration
- External-Integration

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| Context.cmake | Modul | ctx_get |
| SourceCollect.cmake | Modul | Source-Sammlung |
| CompilerOptions.cmake | Modul | Compiler-Config |
| Warnings.cmake | Modul | Warning-Level |
| Orchestrator.cmake | Modul | External-Linking |

---

## 3. Konzept

### 3.1 Erstellungs-Pipeline

```
1. Context-Daten lesen
2. Sources sammeln
3. add_executable() aufrufen
4. PCH konfigurieren
5. Compiler-Optionen anwenden
6. Warnings setzen
7. Dependencies linken
8. Externals linken
```

### 3.2 Target-Typen

| Typ | CMake-Flag | Beschreibung |
|-----|------------|--------------|
| `GUI` | `WIN32` | Windows GUI-Anwendung |
| `CONSOLE` | — | Konsolen-Anwendung |

---

## 4. API-Referenz

### 4.1 _create_executable_target()

Erstellt das CMake-Target.

```cmake
_create_executable_target(<CTX>)
```

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `CTX` | ✓ | Context-Prefix mit Executable-Daten |

---

## 5. Verwendungsbeispiele

### 5.1 Pipeline-Integration

```cmake
ctx_create(EXE_0)
_collect_executable("${_exe_json}" EXE_0)
_create_executable_target(EXE_0)
```

---

## 6. Fehlerbehandlung

| Code | Beschreibung |
|------|--------------|
| `E104` | Source.cmake nicht gefunden (explicit mode) |
| `E105` | Keine Source-Dateien gefunden |

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| Sources über Source.cmake definieren | GLOB in Produktion |
| Externals in Solution.json | Manuelles target_link_libraries |

---

## 8. Siehe auch

- [ExecutableCollect.cmake](ExecutableCollect.md) — Daten-Sammlung
- [SourceCollect.cmake](../core/SourceCollect.md) — Source-Management
- [Orchestrator.cmake](../externals/Orchestrator.md) — External-Linking

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.2 | 2025-12-07 | External-Integration |
| 0.1.0 | 2025-12-04 | Initial |
