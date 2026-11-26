# phase12.cmake — Modul-Dokumentation

> **Version:** 1.0.0  
> **Datum:** 2026-11-26  
> **Typ:** ModuleDoc  
> **Pfad:** `cmake/buildSystemTest/phase12.cmake`  
> **Status:** Stabil  
> **Sprache:** Deutsch  
> **English:** [Phase12_doc.md](../../../../en/guide/module/buildSystemTest/Phase12_doc.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Tests](#2-tests)
3. [Erfolgs-Flag](#3-erfolgs-flag)
4. [Siehe auch](#4-siehe-auch)
5. [Changelog](#5-changelog)

---

## 1. Übersicht

**Phase 12** testet das Ziel für die API-Referenz aus dem Block `documentation.doxygen`
(CMakeCraft v0.15.0). Doxygen läuft mit der Doxyfile des Projekts im Projekt-Root.

| Aspekt | Beschreibung |
|--------|--------------|
| **Zweck** | Ziel `docs`, `target`, Exitcode von Doxygen, W202, E107, E001 validieren |
| **Debug-ID** | `PHASE12_TEST` |
| **Abhängigkeiten** | Documentation.cmake |
| **Demo** | keine — die Demo-Solution hat keinen Block `documentation`; alles läuft in geschachtelten Projekten |
| **Bedingung** | Tests 2–3 laufen nur, wenn Doxygen installiert ist (sonst ein Hinweis in der Ausgabe) |

Alles wird unter `<build>/phase12/` geschrieben. Die geschachtelten Projekte nutzen Generator,
Plattform, Toolset, `CMAKE_MAKE_PROGRAM` und Compiler dieses Builds. Jedes hat eine
`Solution.json` nur mit `documentation`, einen Header `src/phase12.h` (eine dokumentierte und
eine undokumentierte Funktion) und eine Doxyfile mit `INPUT = src` und
`OUTPUT_DIRECTORY = apidoc`, beide relativ zum Projekt-Root.

---

## 2. Tests

### 2.1 Modul geladen, kein Ziel ohne Block

`_create_doxygen_target` ist definiert. Hat die Demo-Solution keinen Block `documentation`,
gibt es kein Ziel `docs`.

### 2.2 Doxyfile des Projekts, nicht Teil von ALL

`{ "doxygen": { "doxyfile": "Doxyfile" } }`: Konfigurieren ohne W202. Der gewöhnliche Bau legt
`apidoc/` nicht an; `--target docs` schreibt `apidoc/html/index.html` **im Projekt-Root** —
damit ist belegt, dass Doxygen dort läuft.

### 2.3 Eigener Zielname, Exitcode durchgereicht

Doxyfile `doc/Strict.doxyfile` (in einem Unterordner; `INPUT = src` gilt trotzdem relativ zum
Root) mit `EXTRACT_ALL = NO`, `WARN_IF_UNDOCUMENTED = YES`, `WARN_AS_ERROR = YES` und
`"target": "apidocs"`. Das Ziel `apidocs` muss scheitern, und die Ausgabe muss
`phase12_undocumented` nennen.

### 2.4 Doxygen nicht gefunden: W202

Konfigurieren mit `-DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=TRUE` läuft durch und meldet `[W202]`;
`--target docs` scheitert mit „Doxygen not found“.

### 2.5 E107

`"doxyfile": "Missing.doxyfile"` muss mit `[E107]` abbrechen und den Dateinamen nennen (beide
getrennt gesucht, weil CMake lange Meldungen umbricht).

### 2.6 E001

`{ "doxygen": { "target": "docs" } }` ohne `doxyfile` muss mit `[E001]` abbrechen und das Feld
nennen.

---

## 3. Erfolgs-Flag

```cmake
set(PHASE12_TEST_PASSED TRUE CACHE BOOL "Phase 12 Test passed" FORCE)
```

---

## 4. Siehe auch

- [Documentation.cmake](../project/Documentation.md)
- [Solution_Schema.md](../../references/Solution_Schema.md) §10

---

## 5. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.0.0** | **2026-11-26** | **Initial (CMakeCraft v0.15.0)** |
