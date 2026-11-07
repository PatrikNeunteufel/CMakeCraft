# phase11.cmake — Modul-Dokumentation

> **Version:** 1.0.0  
> **Datum:** 2026-11-07  
> **Typ:** ModuleDoc  
> **Pfad:** `cmake/buildSystemTest/phase11.cmake`  
> **Status:** Stabil  
> **Sprache:** Deutsch  
> **English:** [Phase11_doc.md](../../../../en/guide/module/buildSystemTest/Phase11_doc.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Tests](#2-tests)
3. [Erfolgs-Flag](#3-erfolgs-flag)
4. [Siehe auch](#4-siehe-auch)
5. [Changelog](#5-changelog)

---

## 1. Übersicht

**Phase 11** testet `compile_options` an Bibliotheken und das **Quellpaket einer Bibliothek**
(CMakeCraft v0.14.0) — bis zu einem einfachen CMake-Projekt ohne CMakeCraft, das das Paket
einbindet, baut und ausführt.

| Aspekt | Beschreibung |
|--------|--------------|
| **Zweck** | `compile_options` je Bibliothek, Quellpaket, E105, E106 validieren |
| **Debug-ID** | `PHASE11_TEST` |
| **Abhängigkeiten** | LibraryCreate.cmake, SourcePackage.cmake, PackageBuild.cmake, CompilerOptions.cmake |
| **Demo** | Bibliothek `CalcDemo` (STATIC, `compile_options` je Compiler-Familie, `defines`), lokales Header-External `calcext` mit eigener `Include.cmake` (INTERFACE-Ziel mit `SYSTEM`-Include und Define `CALCEXT_NO_THREADS`), Paket `calcdemo` |
| **Bedingung** | Tests 2–5 laufen nur, wenn `CalcDemo` und `package_calcdemo` vorhanden sind |

Alles wird unter `<build>/phase11/` geschrieben. Die geschachtelten Projekte (Tests 5–7)
nutzen Generator, Plattform, Toolset, `CMAKE_MAKE_PROGRAM` und Compiler dieses Builds; kein
Netzzugriff. Die Phase konfiguriert drei Projekte und baut eines — sie dauert deutlich länger
als die übrigen (Ninja/Clang etwa 12 s, Visual Studio etwa 40 s).

`calcext.h` bricht mit `#error` ab, wenn `CALCEXT_NO_THREADS` fehlt: ein Paket, das nur den
Include-Ordner des Externals überträgt, fällt im Test 5 auf.

---

## 2. Tests

### 2.1 Funktionen verfügbar

`craft_language_rules`, `_create_source_package_target`, `_craft_target_snapshot`,
`_craft_record_external_effect` sind definiert.

### 2.2 compile_options an der Bibliothek

Die `compile_options` von `CalcDemo` aus `Solution.json` stehen als **letzte** Einträge in
`COMPILE_OPTIONS` des Ziels; jede Sprachregel des aktuellen Compilers
(`craft_language_rules`) steht davor.

### 2.3 Erzeugtes CMakeLists.txt

Die Schablone von `package_calcdemo` enthält die Generator Expressions wörtlich,
`add_library(CalcDemo STATIC`, den Alias, das INTERFACE-Ziel `calcext` mit
`CALCEXT_NO_THREADS`, das Define der Bibliothek, den Link und den Prüfsummen-Platzhalter;
`CXX_EXTENSIONS` steht wie am Ziel. Sie enthält **nicht** `CMakeCraft.cmake`, `CMAKECRAFT_`,
`include(`, `craft_language`, `/W4`, `/MP`, `/bigobj`.

### 2.4 Paket bauen

`PackageBuild.cmake` läuft mit einer Kopie des Manifests, deren Ausgabeordner unter
`<build>/phase11/out` liegt. Geprüft: `CMakeLists.txt`, `VERSION` (= `0.3.0\n`, Version der
Bibliothek), `SHA256SUMS`, `include/calc_demo.h`, `src/calc_demo.cpp`, `src/calc_detail.h`,
`externals/calcext/calcext.h` und `LICENSE.md` vorhanden; `externals/calcext/Include.cmake` und
`src/Source.cmake` **nicht**; `.zip` und `.zip.sha256` vorhanden; kein Platzhalter mehr im
`CMakeLists.txt`. `CMakeLists.txt`, `VERSION`, `SHA256SUMS` und `.zip.sha256` enthalten kein CR
(als Hex gelesen — ein Lesen als Text verbirgt das CR unter Windows). `SHA256SUMS`: jede Zeile im Format von `sha256sum`, jede Prüfsumme
stimmt, jede Datei genau einmal, sortiert.

### 2.5 Einfaches CMake-Projekt als Bezieher

Ein Projekt ohne CMakeCraft (`add_subdirectory` des entpackten Pakets, `add_executable`,
`target_link_libraries(… CalcDemo::CalcDemo)`) prüft beim Konfigurieren, dass die erste Option
der Bibliothek an ihrem Ziel steht, wird gebaut und ausgeführt. Die Exe rechnet
`mul_add(0.1, 10.0, -1.0)` (zwei Rundungen ergeben genau 0) und prüft den Wert aus `calcext`;
erwartet: Exit 0 und `calc_demo 0`.

### 2.6 E105

Ein geschachteltes CMakeCraft-Projekt mit einer INTERFACE-Bibliothek mit `compile_options`
muss mit `[E105]` abbrechen.

### 2.7 E106

Ein geschachteltes CMakeCraft-Projekt mit einer STATIC-Bibliothek, die das System-External
`Threads` nennt, und einem Quellpaket dieser Bibliothek muss mit `[E106]` abbrechen und das
External nennen.

---

## 3. Erfolgs-Flag

```cmake
set(PHASE11_TEST_PASSED TRUE CACHE BOOL "Phase 11 Test passed" FORCE)
```

---

## 4. Siehe auch

- [SourcePackage.cmake](../project/SourcePackage.md)
- [Packages.md](../../references/Packages.md) §2.5
- [Phase10_doc.md](Phase10_doc.md) — Pakete und Archive Externals

---

## 5. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.0.0** | **2026-11-07** | **Initial (CMakeCraft v0.14.0)** |
