# Solution.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/project/Solution.cmake](../../../cmake/project/Solution.cmake)  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [Solution.md](../../en/modules/project/Solution.md)

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

Das `Solution.cmake` Modul ist das Herzstück des Build-Systems. Es liest die `Solution.json` Konfigurationsdatei und setzt alle globalen Properties.

### Verantwortlichkeiten

- Solution.json einlesen und validieren
- Schema-Version prüfen
- Metadaten extrahieren (Name, Version, Autoren)
- Build-Settings anwenden
- Externals-Policy konfigurieren

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| Errors.cmake | Modul | Fehlerbehandlung |
| Debug.cmake | Modul | Debug-Ausgaben |
| Json.cmake | Modul | JSON-Parsing |
| Validation.cmake | Modul | Schema-Validierung |

---

## 3. Konzept

### 3.1 Gesetzte GLOBAL Properties

**Metadaten:**

| Property | Beschreibung |
|----------|--------------|
| `SOLUTION_JSON` | Vollständiger JSON-String |
| `SOLUTION_NAME` | Projekt-Name |
| `SOLUTION_VERSION` | Version |
| `SOLUTION_DESCRIPTION` | Beschreibung |
| `SOLUTION_AUTHORS` | Autoren-Liste |

**Settings:**

| Property | Default |
|----------|---------|
| `SOLUTION_CXX_STANDARD` | — |
| `SOLUTION_C_STANDARD` | — |
| `SOLUTION_DEFAULT_LIBRARY_TYPE` | `STATIC` |
| `SOLUTION_SOURCE_MODE` | `explicit` |

---

## 4. API-Referenz

### 4.1 _load_solution_json()

Lädt Solution.json aus dem Projekt-Root.

```cmake
_load_solution_json()
```

**Setzt:** `SOLUTION_JSON` als GLOBAL PROPERTY.

**Fehler:** `E002` wenn Solution.json nicht gefunden.

---

### 4.2 _extract_solution_metadata()

Extrahiert Metadaten aus dem JSON.

```cmake
_extract_solution_metadata()
```

---

### 4.3 _apply_solution_settings()

Wendet Settings mit Defaults an.

```cmake
_apply_solution_settings()
```

---

## 5. Verwendungsbeispiele

### 5.1 Minimale Solution.json

```json
{
    "schemaVersion": "0.1",
    "solution": {
        "name": "MyProject"
    }
}
```

### 5.2 Properties abrufen

```cmake
get_property(_name GLOBAL PROPERTY SOLUTION_NAME)
get_property(_version GLOBAL PROPERTY SOLUTION_VERSION)
message(STATUS "Building ${_name} v${_version}")
```

---

## 6. Fehlerbehandlung

| Code | Beschreibung |
|------|--------------|
| `E002` | Solution.json nicht gefunden |
| `E003` | Ungültiges JSON |
| `W001` | Schema-Version veraltet |

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| GLOBAL PROPERTY für Zugriff | Direkte Variablen |
| Schema-Version aktuell halten | Veraltete Schemas |

---

## 8. Siehe auch

- [Solution_Schema](../reference/Solution_Schema.md) — JSON-Schema
- [Executables.cmake](Executables.md) — Verwendet Solution-Daten
- [Libraries.cmake](Libraries.md) — Verwendet Solution-Daten

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.1 | 2025-12-07 | Settings-Extraktion |
| 0.1.0 | 2025-12-03 | Initial |
