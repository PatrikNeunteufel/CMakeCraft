# Doku-Befunde aus der Übersetzung (D1 a) — Stand nach dem Angleich, 2026-11-09 (CMakeCraft Session 10)

Beim vollständigen Übersetzen von `docs/en` aus `docs/de` fielen Widersprüche zwischen Doku und Code auf. Am selben Tag
wurden sie am Code geprüft und die Doku in **beiden Sprachen** angeglichen (fünf Hilfsagenten je Bereich, danach
Stichproben gegen den Code, Verweis-/Anker-/Restdeutsch-Prüfung über beide Bäume: 0 Funde; Selbsttest 11/11).
Jede geänderte Datei trägt einen Changelog-Eintrag vom 2026-11-09; Kopf-Versionen sind unverändert (K1 offen).

## Erledigt

| Bereich | Was |
|---|---|
| `guide/references/` | `ErrorCodes.md` 1.6.1: Meldungen wörtlich wie im Code, Beispiele dreistellig, E217-Pfad, Phasentest-Warnungen W601–W999, fehlende Codes E203/E304/E305/E400/W111, E002/E003/E401/W101–W102/W303/W401–W403 berichtigt. Schema-Version `1.0` in `Solution_Schema.md` §11 und Cheatsheet (`Solution.cmake:50-51,100-108`). `CMakePresets.md`: `craft-selftest`, `ctest-vs-x64-Release`, Vendor-Angaben, Anzahlen. `App_Template_Reference.md`: `templates/App/`, Testlayout, Define `APP_WINDOWS_GUI`, entstehende Targets. `Git_Externals_GUI.md` Hook-Pfad |
| `guide/module/` | `CMakeLists.md` neu (Einstieg `CMakeCraft.cmake`, Ablauf, Optionen, Phasentests 1–11). `README.md`, `buildSystemTest_README.md` (Vorgabe OFF), `Apps.md` (`tests.targets[]`, `${CMAKECRAFT_DIR}`), `AppCreate.md` (E301/E302/E305), `Orchestrator_cmake.md`, Externals-`README.md`, `HookLoader_cmake.md`, `Targets_cmake.md`, `Lua54_Include.md`, `Doctest_Include.md` (`<doctest.h>`), `Validation.md`, `CMakeCraftPackage.md` (1.1.1) |
| `guide/userguides/` | `Getting_Started.md` gegen das heutige Verfahren, `Neues_Projekt_Guide.md` 1.4.2 (Pin statt Snapshot, E005, `QT_ROOT` als `environment`, vorhandene Presets), `Qt6_Integration.md` (System-External), externals/`Qt6.md` (`package`), externals/`README.md`, `Adding_Externals.md` (Hook-Pfade, `HOOKS_DEBUG` gestrichen), `App_Creation_Guide.md`, `CMakeUserPresets.md` (`inherits`, Preset-Namen), `Testing.md` (Preset-Namen) |
| `konzepte/` | Hinweise „Stand Code“ in abgeschlossenen Konzepten (E306, W401/W403, E5xx, E012, `${CMAKECRAFT_DIR}`); `Guidelines.md` §3.3 auf die ausgelösten Codes; `Master_Concept.md` `EXTERNALS_FORCE_FETCH` OFF; `Konzept_Versionierter_Bezug.md` §3 `CMAKECRAFT_DIR`, Abweichungen zum umgesetzten Bootstrap; Implementation_Plan „Runner linkt gegen Core“ |
| `autorenwerk/` | Blueprints auf den heutigen Baum (Structure, Doc, ModuleDoc, CppModuleDoc, Guide, Reference, Concept, Standard, Blueprint, README_Blueprint, ImplementationPlan), `CMake.md` `${CMAKECRAFT_DIR}`, Doc.md Sprungpfad und Abschnitt 4.3/4.4/4.5, Tutorial Hook-Pfad, ClangFormat/ClangTidy-Kopf, Standard.md `do_something()`; Doku_Standard Hook-Meldungen wörtlich; Git_Remote_Repository_Guide §6.2/§11.4/§11.6/§11.7 (`git help remote`); C/Cpp-Standard Changelog-Verortung, Beispiele an die Regeln, `std::optional<Result>` |
| Code-Kommentare | `Solution.cmake` (Schema 1.0), `Errors.cmake` (Bereiche E3xx–E5xx, W4xx–W9xx), `Orchestrator.cmake` (Typen), `system/Handler.cmake` (Versionsbeispiel), `PathResolver.cmake` (Umgebungsnamen), `CMakeLists.txt` (Pfad), `cmake/buildSystemTest/README.md`, `CMakePresets.json` (`craft-selftest`), `clang-format`/`clang-tidy` (Blueprint-Pfad), `templates/App` und Demo `MyVisualizer` (`APP_WINDOWS_GUI`, Kopierpfad) |

## Entschieden und umgesetzt (Patrik 2026-11-09, „Alle a“)

| Nr. | Umsetzung |
|---|---|
| S1 a | `Language_Standard` (§1, §4.1–§4.5, §9.2) und `Doc.md` (§4.5, §8.2, §9.3) an `Doku_Standard`: Primärsprache maßgeblich, Englisch im selben Commit, Dateinamen in allen Sprachordnern gleich, deutsche Namen zulässig |
| N1 a | `Doc.md` §8.2: zusammengesetzter Begriff zusammen (`ErrorCodes.md`), mehrere Begriffe mit Underscore (`Getting_Started.md`) |
| C1 a | Code (v0.14.1): `cmake_fatal`/`cmake_warn` geben alle Meldungsteile aus (`Errors.cmake` 1.1.0, über `ARGV<n>`, Semikolons bleiben); System-Handler 1.1.0 ruft `find_package` ohne `REQUIRED` und meldet E503/E504/E505 selbst (`_system_external_not_found`), E501/W502 entfallen; Katalog in `Errors.cmake` vollständig, nie ausgelöste Codes gekennzeichnet; Selbsttest Phase 9 Test 12. Doku: `ErrorCodes.md`, `Errors.md`, `Validation.md`, `Handler_cmake.md`, `Phase9_doc.md`, `Guidelines.md`, Stand-Code-Hinweise der Konzepte, `Qt6_Integration.md`, externals/`Qt6.md`, `Solution_Schema.md`, `Solution.md`, `Bass_Include.md`. Gegenprobe HoerTest_Helper clang/MSVC je 118/118 |
| K1 a | Doku-Versionen zählen ab dem Doku-Release 1.0.0 („Release 1“, newCMake, `2e00db7`, 2025-12-26) weiter: Eintrag 1.0.0 nachgetragen (112 de-Dateien, je eine Ausnahme mit eigenem Beleg: `CppModuleDoc.md` seit `cb2f6e5`, `Boost_cmake.md` laut Kopf, `Konzept_Versionierter_Bezug.md` seit `290b104`), spätere 0.x-Einträge auf 1.0.N umnummeriert (Einträge, die nach der CMakeCraft-Version zählten, nennen sie im Text), Kopf = jüngster Eintrag; de und en gleich. Prüfung: keine Reihenfolgefehler, kein Kopf ungleich jüngstem Eintrag |
| K2 a | Keine CMakeCraft-Version im Kopf; Bindung über den Git-Tag, im Text „seit vX“, im Changelog `CMakeCraft vX: …` (`Doku_Standard` §2, `Doc.md` §11.3) |
| V2 a | Erstes Major-Release von CMakeCraft = v2.0.0; dann alle Dokumente und `.cmake`-Dateien auf 2.0.0, gemeinsame Major-Nummer (`Doku_Standard` §2, `CMake.md` §8.3, `CLAUDE.md`) |

## Offen — Entscheidung nötig

Keine.

## Offen — Hinweise ohne Entscheid (später)

- `templates/projects/{App,Lib}` wird nirgends referenziert; die Tests binden `<doctest/doctest.h>` ein (nur mit gefetchtem doctest auflösbar; das lokale External braucht `<doctest.h>`). Behalten, berichtigen oder entfernen.
- `cmake/project/Tests.cmake`: Kopf „Used by: CMakeLists.txt“; schreibt mit `message(STATUS)` statt `dbg()`.
- Mehrfach belegte Codes: W101 (~10 Bedeutungen), E003/E301–E303/W401–W403 in Apps und eigenständigen Tests verschieden, E400/E401 für denselben Fall (`AppCollect.cmake:183`, `Apps.cmake:86`).
- `docs/{de,en}/guide/module/CMakeLists.md` beschreibt jetzt `CMakeCraft.cmake`; passender Name wäre `CMakeCraft_cmake.md`.
- Köpfe überholt (K1 abwarten): `Orchestrator_cmake.md` (1.0.0/2025-12-20), `Konzept_Versionierter_Bezug.md` Status „Entwurf — Entscheidung ausstehend“ (seit v0.7.0 umgesetzt).
- `Doku_Standard` §4: `git commit --dry-run` führt keine pre-commit-Hooks aus (ungeprüft).
- C-Standard: §13 `getTicks()` gegen `modul_snake_case`; `p`-Präfix mit camelCase (`pBuffer`).
- `README_Blueprint` §2.1 verlangt READMEs in `autorenwerk/blueprints/` und `guide/module/core/` (es gibt keine bzw. `core_README.md`).
- `lua54`: unter Linux/macOS kommen die Header aus `win/include` (Eigenheit des Codes).
- `validate_required_fields()` und `validate_solution_schema()` (`core/Validation.cmake`) ruft kein Modul auf; nur
  `validate_external_source()` wird benutzt. Behalten oder entfernen.
- E504 nennt alle angeforderten Komponenten; welche fehlt, steht im Grund, den das Paket liefert (Qt nennt die erste).
