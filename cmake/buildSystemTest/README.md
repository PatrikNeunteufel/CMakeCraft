# buildSystemTest — Selbsttests des Build-Systems (CMakeCraft)

> **In Konsumenten-Projekten (LumiViz & Co.) wird dieser Ordner NICHT benötigt.**
> Er kommt mit dem bezogenen CMakeCraft (`.externals/cmakecraft/<version>/`, siehe
> `cmakecraft.pin`) und wird nur bei `RUN_BUILD_SYSTEM_TESTS=ON` geladen — **bitte nicht
> löschen**, `CMakeCraft.cmake` referenziert die Dateien.

## Zweck

Phasentests der „CMake Architecture V2": `phase1.cmake` … `phase11.cmake` prüfen die
Build-System-Module (Core, Solution, Libraries, Externals, Tests, App-Container, Pakete,
Quellpakete, …) zur Configure-Zeit. Phase 11 konfiguriert dabei drei kleine Projekte unter
`<build>/phase11/` und baut eines davon — sie braucht deutlich länger als die übrigen.

## Wann laufen sie?

- **Default: AUS** (`RUN_BUILD_SYSTEM_TESTS` = OFF) — in Projekten laufen sie also nie mit.
- **Im CMakeCraft-Repo** (Entwicklung am Build-System): Preset **`craft-selftest`**
  verwenden — oder jedem Preset `-DRUN_BUILD_SYSTEM_TESTS=ON` mitgeben.
- **In Projekten sinnvoll als Smoke-Check** direkt nach einem Wechsel des Pins
  (siehe `docs/de/guide/userguides/Neues_Projekt_Guide.md`):
  ```bash
  cmake --preset <euer-preset> -DRUN_BUILD_SYSTEM_TESTS=ON     # einmalig testen
  cmake --preset <euer-preset>                                  # danach wieder normal
  ```
- Einzelne Phase: zusätzlich `-DTEST_PHASE=6` (o. ä.).

Doku: `docs/de/guide/module/buildSystemTest/` (je Phase `Phase<n>_doc.md`, Übersicht
`buildSystemTest_README.md`; englisch unter `docs/en/…`).
