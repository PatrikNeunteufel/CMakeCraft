# Handler.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/externals/Fetched/Handler.cmake](../../../cmake/externals/Fetched/Handler.cmake)  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [Handler.md](../../en/modules/externals/fetched/Handler.md)

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

Das `Handler.cmake` Modul verarbeitet gefetchte Externals nach dem Download.

### Features

- Target-Erkennung
- CMake-Subdirectory Integration
- Options-Anwendung

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| Targets.cmake | Modul | Target-Registrierung |

---

## 3. Konzept

### 3.1 Handler-Pipeline

```
1. Gefetchtes External empfangen
2. CMakeLists.txt analysieren
3. Targets identifizieren
4. In Registry eintragen
```

---

## 4. API-Referenz

### 4.1 handle_fetched_external()

Verarbeitet ein gefetchtes External.

```cmake
handle_fetched_external(<EXT_NAME> <SOURCE_DIR>)
```

---

## 5. Verwendungsbeispiele

```cmake
handle_fetched_external("imgui" "${imgui_SOURCE_DIR}")
```

---

## 6. Fehlerbehandlung

| Code | Beschreibung |
|------|--------------|
| `E220` | Keine Targets gefunden |

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| PostFetch Hook für Anpassungen | Handler modifizieren |

---

## 8. Siehe auch

- [Fetch.cmake](../core/Fetch.md) — Git-Fetch
- [Targets.cmake](../registry/Targets.md) — Target-Registry

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.0 | 2025-12-07 | Initial |
