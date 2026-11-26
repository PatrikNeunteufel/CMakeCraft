# Documentation.cmake — Modul-Dokumentation

> **Version:** 1.0.0  
> **Datum:** 2026-11-26  
> **Typ:** ModuleDoc  
> **Status:** Aktiv  
> **Basiert auf:** ModuleDoc v0.5  
> **Zielgruppe:** Build-System-Entwickler  
> **Sprache:** Deutsch  
> **English:** [Documentation.md](../../../../en/guide/module/project/Documentation.md)  
> **Modul:** [`cmake/project/Documentation.cmake`](../../../../../cmake/project/Documentation.cmake)  
> **Modul-Version:** 1.0.0  
> **Phase:** 12 (Documentation)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [API-Referenz](#3-api-referenz)
4. [JSON-Mapping](#4-json-mapping)
5. [Fehlerbehandlung](#5-fehlerbehandlung)
6. [Siehe auch](#6-siehe-auch)
7. [Changelog](#7-changelog)

---

## 1. Übersicht

Das Modul legt aus dem Block `documentation.doxygen` der Solution.json **ein Ziel** an (Vorgabe
`docs`), das Doxygen mit der **Doxyfile des Projekts** aufruft. Die Doxyfile wird unverändert
übergeben; das Arbeitsverzeichnis ist der Projekt-Root (`CMAKE_SOURCE_DIR`), sodass ihre
relativen Pfade genau so gelten wie bei `doxygen <doxyfile>` aus dem Root.

| Eigenschaft | Wert |
|-------------|------|
| Teil von `ALL` | nein — `cmake --build <build> --target docs` |
| Exitcode von Doxygen | durchgereicht (`WARN_AS_ERROR = YES` in der Doxyfile lässt das Ziel scheitern) |
| Doxygen fehlt | W202 beim Konfigurieren; das Ziel gibt es, es scheitert beim Bauen mit Meldung |
| Ohne Block | kein `find_package(Doxygen)`, kein Ziel |
| Target-Property | `CRAFT_DOXYFILE` (Pfad wie in Solution.json), `FOLDER` = `Documentation` |

### Position im Ablauf

`CMakeCraft.cmake` bindet das Modul als Phase 12 ein — nach Packages, vor den Tests. Es braucht
keine anderen Ziele.

---

## 2. Abhängigkeiten

| Modul | Verwendung |
|-------|------------|
| Errors.cmake | `cmake_fatal`, `cmake_warn` |
| Debug.cmake | `dbg`, `dbg_init`, `enddbgblock` |
| Json.cmake | `_json_get_type`, `_json_get_object`, `_json_get_string`, `_json_get_string_or_default` |
| Solution.cmake | Global Property `SOLUTION_JSON` |
| FindDoxygen (CMake) | `find_package(Doxygen QUIET)`, Ziel `Doxygen::doxygen` |

---

## 3. API-Referenz

### 3.1 _create_doxygen_target()

```cmake
_create_doxygen_target(<DOXYGEN_JSON>)
```

| Parameter | Typ | Pflicht | Beschreibung |
|-----------|-----|---------|--------------|
| `DOXYGEN_JSON` | String | ✓ | JSON-String von `documentation.doxygen` |

Prüft die Felder, sucht Doxygen und legt das Ziel an (`add_custom_target` ohne `ALL`,
`WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}`, `USES_TERMINAL`). Die gefundene Doxygen-Fassung steht in
der Debug-Ausgabe (`[Documentation] Target 'docs': Doxygen 1.12.0 (…)`).

### 3.2 Pipeline beim Einbinden

Beim `include()` liest das Modul `documentation` aus `SOLUTION_JSON`. Fehlt der Block, geschieht
nichts. Ist `documentation.doxygen` ein Objekt, wird `_create_doxygen_target()` aufgerufen.

---

## 4. JSON-Mapping

| Feld | Pflicht | Default | Beschreibung |
|------|---------|---------|--------------|
| `doxyfile` | ✓ | — | Pfad der Doxyfile relativ zum Projekt-Root (absolut ist erlaubt) |
| `target` | — | `docs` | Name des Ziels |

Eine von CMakeCraft erzeugte Konfiguration ([Future_Enhancements.md](../../../konzepte/Future_Enhancements.md)
§8.3) gibt es nicht; ohne `doxyfile` bricht das Konfigurieren mit E001 ab.

---

## 5. Fehlerbehandlung

| Code | Auslöser |
|------|----------|
| E001 | `doxyfile` fehlt oder ist leer; `documentation` oder `documentation.doxygen` ist kein Objekt |
| E102 | Ein Ziel mit dem Namen aus `target` gibt es schon |
| E107 | Die Doxyfile gibt es nicht (oder es ist ein Ordner) |
| W202 | Doxygen nicht gefunden |

---

## 6. Siehe auch

- [Solution_Schema.md](../../references/Solution_Schema.md) §10 — der Block `documentation`
- [Phase12_doc.md](../buildSystemTest/Phase12_doc.md) — Selbsttest
- [ErrorCodes.md](../../references/ErrorCodes.md) — E107, W202

---

## 7. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.0.0** | **2026-11-26** | **Initial (CMakeCraft v0.15.0)** |
