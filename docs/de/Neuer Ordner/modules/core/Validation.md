# Validation.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/core/Validation.cmake](../../../cmake/core/Validation.cmake)  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [Validation.md](../../en/modules/core/Validation.md)

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

Das `Validation.cmake` Modul stellt **Validierungsfunktionen** für Solution.json und External-Definitionen bereit.

### Features

- Schema-Konformität prüfen
- Pflichtfeld-Validierung
- External-Source-Validierung
- Best-Practice-Warnungen

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| Errors.cmake | Modul | `cmake_fatal()`, `cmake_warn()` |
| Json.cmake | Modul | `_json_has_key()`, `_json_get_string()` |

---

## 3. Konzept

### 3.1 Validierungsebenen

| Ebene | Funktionen | Prüft |
|-------|------------|-------|
| **Schema** | `validate_solution_schema()` | Schema-Version |
| **Entity** | `validate_required_fields()` | Pflichtfelder |
| **External** | `validate_external_source()` | Source-Feld |
| **Local** | `validate_local_external()` | Include.cmake |
| **Fetched** | `validate_fetched_external()` | tag/branch/commit |

### 3.2 Fehlercode-Zuordnung

| Code | Bedeutung |
|------|-----------|
| `E001` | Pflichtfeld fehlt |
| `E012` | Kein/Mehrere Source-Felder |
| `E213` | Include.cmake nicht gefunden |
| `E215` | Kein tag/branch/commit |
| `W001` | Schema-Version Warnung |

---

## 4. API-Referenz

### 4.1 validate_external_source()

Prüft dass genau ein Source-Feld vorhanden ist.

```cmake
validate_external_source(<EXT_NAME> <EXT_JSON>)
```

**Erlaubte Source-Felder:** `path`, `git`, `vcpkg`, `conan`, `find_package`

**Fehler:** `E012` wenn kein oder mehrere Source-Felder.

---

### 4.2 validate_required_fields()

Prüft dass alle Pflichtfelder existieren.

```cmake
validate_required_fields(<JSON> <ENTITY_TYPE> <ENTITY_NAME> FIELDS <field1> [field2...])
```

**Fehler:** `E001` wenn Pflichtfeld fehlt.

---

### 4.3 validate_local_external()

Validiert lokale External-Definition.

```cmake
validate_local_external(<EXT_NAME> <EXT_PATH>)
```

**Fehler:** `E213` wenn Include.cmake fehlt.

---

### 4.4 validate_fetched_external()

Validiert Git-External-Definition.

```cmake
validate_fetched_external(<EXT_NAME> <EXT_JSON>)
```

**Fehler:** `E215` wenn tag/branch/commit fehlt.

---

## 5. Verwendungsbeispiele

### 5.1 External validieren

```cmake
validate_external_source("bass" "${_json}")
validate_local_external("bass" "externals/bass")
```

### 5.2 Pflichtfelder prüfen

```cmake
validate_required_fields("${_exe_json}" "Executable" "MyApp" FIELDS name path)
```

---

## 6. Fehlerbehandlung

| Code | Funktion | Beschreibung |
|------|----------|--------------|
| `E001` | validate_required_fields | Pflichtfeld fehlt |
| `E012` | validate_external_source | Kein/Mehrere Source-Felder |
| `E213` | validate_local_external | Include.cmake nicht gefunden |
| `E215` | validate_fetched_external | Kein tag/branch/commit |

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| Früh validieren | Erst bei Verwendung prüfen |
| Alle Pflichtfelder listen | Einzelne Prüfungen |
| Error Codes verwenden | Generische Fehlermeldungen |

---

## 8. Siehe auch

- [Errors.cmake](Errors.md) — Fehlerbehandlung
- [Json.cmake](Json.md) — JSON-Zugriff
- [Solution.cmake](../project/Solution.md) — Verwendet Validation

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.1 | 2025-12-05 | English translation |
| 0.1.0 | 2025-12-04 | Initial |
