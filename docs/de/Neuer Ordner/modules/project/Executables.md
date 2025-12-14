# Executables.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/project/Executables.cmake](../../../cmake/project/Executables.cmake)  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [Executables.md](../../en/modules/project/Executables.md)

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

Das `Executables.cmake` Modul ist die Hauptschleife für die Executable-Pipeline. Es iteriert über alle Executables in Solution.json und delegiert an Collect/Create-Module.

### Features

- Iteration über alle Executables
- BUILD_ONLY Filterung
- skip-Flag Unterstützung

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| Solution.cmake | Modul | SOLUTION_JSON Property |
| ExecutableCollect.cmake | Modul | JSON → Context |
| ExecutableCreate.cmake | Modul | Target-Erstellung |
| Context.cmake | Modul | Context-Management |

---

## 3. Konzept

### 3.1 Pipeline-Ablauf

```
1. SOLUTION_JSON laden
2. Executables-Array extrahieren
3. Für jedes Executable:
   a. Context erstellen (EXE_N)
   b. ExecutableCollect aufrufen
   c. BUILD_ONLY prüfen
   d. skip prüfen
   e. ExecutableCreate aufrufen
```

---

## 4. API-Referenz

### 4.1 process_executables()

Verarbeitet alle Executables aus Solution.json.

```cmake
process_executables()
```

**Beschreibung:**  
Hauptfunktion die vom CMakeLists.txt aufgerufen wird.

---

## 5. Verwendungsbeispiele

### 5.1 CMakeLists.txt Integration

```cmake
include(cmake/project/Executables.cmake)
process_executables()
```

---

## 6. Fehlerbehandlung

| Code | Beschreibung |
|------|--------------|
| `E001` | Pflichtfeld fehlt (via ExecutableCollect) |

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| BUILD_ONLY für schnelle Iteration | Alle Targets immer bauen |
| skip für temporäres Deaktivieren | Aus Solution.json entfernen |

---

## 8. Siehe auch

- [ExecutableCollect.cmake](ExecutableCollect.md) — JSON-Parsing
- [ExecutableCreate.cmake](ExecutableCreate.md) — Target-Erstellung
- [Libraries.cmake](Libraries.md) — Analog für Libraries

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.0 | 2025-12-04 | Initial |
