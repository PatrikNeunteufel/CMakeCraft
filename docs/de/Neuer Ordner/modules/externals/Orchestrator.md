# Orchestrator.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/externals/Orchestrator.cmake](../../../cmake/externals/Orchestrator.cmake)  
> **Modul-Version:** 0.2.0  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [Orchestrator.md](../../en/modules/externals/Orchestrator.md)

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

Das `Orchestrator.cmake` Modul ist der zentrale Dispatcher für die External-Verarbeitung. Es erkennt den External-Typ und delegiert an das entsprechende Modul.

### Features

- Typ-Erkennung (lokal/git)
- Modul-Dispatch
- Target-Linking für Executables/Libraries

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| Attach.cmake | Modul | Lokale Externals |
| Fetch.cmake | Modul | Git-Externals |
| Targets.cmake | Modul | Target-Registry |

---

## 3. Konzept

### 3.1 Dispatch-Logik

```
External-Definition
    │
    ├── path? → Attach.cmake (lokal)
    │
    └── git? → Fetch.cmake (fetched)
```

### 3.2 Linking-Pipeline

```
Executable/Library definiert externals: ["bass", "imgui"]
    │
    └── Orchestrator.cmake
        ├── Targets aus Registry holen
        └── target_link_libraries() aufrufen
```

---

## 4. API-Referenz

### 4.1 orchestrate_external()

Verarbeitet ein einzelnes External.

```cmake
orchestrate_external(<EXT_NAME> <EXT_JSON>)
```

---

### 4.2 link_externals_to_target()

Linkt Externals an ein Target.

```cmake
link_externals_to_target(<TARGET_NAME> <EXTERNALS_LIST>)
```

---

## 5. Verwendungsbeispiele

### 5.1 External verarbeiten

```cmake
orchestrate_external("bass" "${_bass_json}")
```

### 5.2 An Target linken

```cmake
link_externals_to_target(MyApp "bass;imgui;glfw")
```

---

## 6. Fehlerbehandlung

| Code | Beschreibung |
|------|--------------|
| `E012` | Kein Source-Feld |
| `E200` | External nicht in Registry |

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| Orchestrator für alle Externals | Direkte Modul-Aufrufe |
| Registry für Target-Lookup | Manuelles target_link_libraries |

---

## 8. Siehe auch

- [Attach.cmake](local/Attach.md) — Lokale Externals
- [Fetch.cmake](core/Fetch.md) — Git-Externals
- [Targets.cmake](registry/Targets.md) — Target-Registry

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.2.0 | 2025-12-08 | Link-Pipeline |
| 0.1.0 | 2025-12-06 | Initial |
