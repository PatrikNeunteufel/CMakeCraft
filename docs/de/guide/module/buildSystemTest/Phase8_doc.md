# phase8.cmake — Modul-Dokumentation

> **Version:** 1.0.0  
> **Datum:** 2026-11-09  
> **Typ:** ModuleDoc  
> **Pfad:** `cmake/buildSystemTest/phase8.cmake`  
> **Status:** Stabil  
> **Sprache:** Deutsch  
> **English:** [Phase8_doc.md](../../../../en/guide/module/buildSystemTest/Phase8_doc.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Tests](#2-tests)
3. [Erfolgs-Flag](#3-erfolgs-flag)
4. [Siehe auch](#4-siehe-auch)
5. [Changelog](#5-changelog)

---

## 1. Übersicht

**Phase 8** testet die **App-Container-Pipeline** — den Block `apps` in Solution.json, die Targets `<App>.Core` (Bibliothek) und `<App>` (Runner), die App-Tests und das Sammeln von `external_options` und `compile_options` für App-Tests.

| Aspekt | Beschreibung |
|--------|--------------|
| **Zweck** | App-Container-Pipeline validieren |
| **Debug-ID** | `PHASE8_TEST` |
| **Abhängigkeiten** | Apps.cmake (AppCollect, AppCreate), Context.cmake, Json.cmake, Errors.cmake |
| **Bedingung** | Tests 4 und 9 laufen nur bei `BUILD_TESTS=ON`; Test 2b nur, wenn `_collect_app()` definiert ist; sonst werden sie übersprungen |

Die meisten Tests **melden** nur (Debug-Ausgabe, teils Warnung über `cmake_warn`). Hart ab über `cmake_fatal("ASSERT" …)` bricht nur Test 2b.

---

## 2. Tests

### 2.1 Test 1 — Array `apps` in Solution.json

Liest `SOLUTION_JSON` (globale Property) und das Array `apps`. Für die erste App meldet er `name` und ob die Abschnitte `core`, `runner` (mit `runner.type`) und `tests` vorhanden sind.

| Fall | Verhalten |
|------|-----------|
| `apps` fehlt | Meldung „optional“, kein Fehler |
| `SOLUTION_JSON` nicht verfügbar | Warnung `W801` |

### 2.2 Test 2 — Modul AppCollect verfügbar

Meldet, ob `_collect_app()` definiert ist. Kein Abbruch, wenn nicht.

### 2.3 Test 2b — external_options und compile_options der App-Test-Targets

Die Demo-Solution hat keinen App-Test mit Externals; deshalb sammelt der Test eine wörtliche App-Definition `Phase8Probe` mit zwei Test-Targets in den Kontext `PHASE8_PROBE`:

```json
{
    "name": "Phase8Probe",
    "tests": {
        "framework": "doctest",
        "targets": [
            {
                "name": "WithOptions",
                "type": "unit",
                "externals": [ "bass" ],
                "external_options": { "bass": { "BASS_MIX": true } },
                "compile_options": [ "-DP8_ONE", "$<$<CXX_COMPILER_ID:MSVC>:/bigobj>" ]
            },
            { "name": "WithoutOptions", "type": "unit" }
        ]
    }
}
```

| Prüfung | Erwartet | Bei Abweichung |
|---------|----------|----------------|
| `TESTS_TARGET_0_EXTERNAL_OPTIONS` | `bass.BASS_MIX` ist `true` | `cmake_fatal("ASSERT" …)` |
| `TESTS_TARGET_1_EXTERNAL_OPTIONS` | `{}` | `cmake_fatal("ASSERT" …)` |
| `TESTS_TARGET_0_COMPILE_OPTIONS` | `-DP8_ONE;$<$<CXX_COMPILER_ID:MSVC>:/bigobj>` — Liste, Generator Expression unverändert | `cmake_fatal("ASSERT" …)` |
| `TESTS_TARGET_1_COMPILE_OPTIONS` | leer | `cmake_fatal("ASSERT" …)` |
| `COMPILE_OPTIONS` am Demo-Target `MyVisualizer.UnitTests` (nur wenn es existiert) | enthält `$<$<CXX_COMPILER_ID:MSVC>:/bigobj>` | `cmake_fatal("ASSERT" …)` |

### 2.4 Test 3 — App-Container-Targets

Durchsucht `BUILDSYSTEM_TARGETS` des Quellverzeichnisses nach Targets mit Endung `.Core` und meldet zu jedem, ob das Runner-Target `<App>` existiert. Zählt beide; kein Abbruch.

### 2.5 Test 4 — App-Test-Targets (nur `BUILD_TESTS=ON`)

Zählt und meldet Targets mit Endung `.UnitTests` und `.IntegrationTests`. Kein Abbruch.

### 2.6 Test 5 — Eigenschaften der Core-Bibliothek

Am ersten `.Core`-Target:

| Prüfung | Erwartet | Bei Abweichung |
|---------|----------|----------------|
| `TYPE` | `STATIC_LIBRARY` | Warnung `W802` |
| `INCLUDE_DIRECTORIES`, `LINK_LIBRARIES` | nur gemeldet | — |

### 2.7 Test 6 — Runner linkt gegen Core

Prüft, ob `LINK_LIBRARIES` des Runners `<App>` das Target `<App>.Core` enthält. Fehlt es, Warnung `W803`.

### 2.8 Test 7 — Verzeichnis-Konvention

Prüft, ob `projects/apps/` existiert, zählt die App-Ordner und meldet für den ersten, ob `src/` und `main/` (Pflicht) sowie `include/`, `tests/` und `pch/` (optional) vorhanden sind. Fehlende Ordner werden nur als `MISSING` gemeldet, kein Abbruch.

### 2.9 Test 8 — Bereich der Fehlercodes

Gibt nur die Bereiche aus: App-Container-Fehler `E401`–`E407`, Warnungen `W401`–`W403` (definiert in ErrorCodes.md). Keine Prüfung.

### 2.10 Test 9 — CTest-Integration der App-Tests (nur `BUILD_TESTS=ON`)

Meldet, ob CTest aktiviert ist (`CMAKE_TESTING_ENABLED`), und für den ersten Test `<App>.UnitTests` bzw. `<App>.IntegrationTests` die Test-Properties `TIMEOUT` und `LABELS`. Kein Abbruch.

### 2.11 Test 10 — IDE-Ordner

Meldet die Property `FOLDER` des ersten `.Core`-Targets und ob sie mit `Apps/` beginnt. Kein Abbruch.

### 2.12 Zusammenfassung

Sind Apps definiert, aber keine `.Core`-Targets entstanden, lautet der Status `WARNING` statt `PASSED` (nur Meldung).

---

## 3. Erfolgs-Flag

```cmake
set(PHASE8_TEST_PASSED TRUE CACHE BOOL "Phase 8 Test passed" FORCE)
```

Das Flag wird auch bei Status `WARNING` gesetzt; nur ein Abbruch in Test 2b verhindert es.

---

## 4. Siehe auch

- [Apps.md](../project/Apps.md)
- [AppCollect.md](../project/AppCollect.md)
- [AppCreate.md](../project/AppCreate.md)
- [ErrorCodes.md](../../references/ErrorCodes.md)
- [AppContainer_Concept.md](../../../konzepte/abgeschlossen/AppContainer_Concept.md)

---

## 5. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.0.0** | **2026-11-09** | **Erstfassung, aus dem Code `phase8.cmake` (Modul 1.0.0) nachgetragen** |
