# CMakeCraft_Session11_2026-11-26_ziel-docs-doxygen

> **Zeitraum:** 2026-11-26 · **Status:** abgeschlossen ·
> **Tests am Ende:** Selbsttest Phase 12 6 von 6 PASSED; voller Lauf `craft-selftest` Phasen 1–10 PASSED, Phase 11
> Test 5 scheitert an der Umgebung (unten), Phase 12 einzeln grün; Gegenprobe Generator `Visual Studio 18 2026`
> **Basis:** `master` @ `4e6dbe8` → `92624ef` (v0.15.0); Commit und Tag durch Patrik, Tag gepusht
>
> Auftrag von Novaseed über den neuen Sync `../sync_ns_cc`: ein Bauziel `docs` aus `Solution.json`, das die Doxyfile
> des Projekts ausführt (Entscheid DO2-1 a in Novaseed: kein eigenes CMake dort).

## Schwerpunkt

**v0.15.0: Ziel `docs` für die API-Referenz.** Ein neuer Block `documentation.doxygen` legt ein Ziel an, das
Doxygen mit der Doxyfile des Projekts unverändert im Projekt-Root aufruft — nicht Teil von `ALL`, Exitcode
durchgereicht.

## Sync

- **`../sync_ns_cc`** (neu, Leitung NOVA): Hook in `.claude/settings.json` ergänzt (SessionStart +
  UserPromptSubmit), Steckbrief-Zeile *Sync* ergänzt, CC-Hälfte in `STATUS.md` übernommen.
- Ablauf: Antwort auf F1–F3 (`CC-20261126-2003`), Leerlauf beider Seiten, Freigabe Patrik weitergegeben
  (`CC-20261126-2017`), Meldung „gebaut“ und Meldung „Tag gesetzt“ an NOVA. 1373 von 4000 Token.
- NOVA hat den Pin auf v0.15.0 gehoben und den Block eingetragen; Prüfung 1–4 bestanden (`NOVA-20261126-2036`:
  Configure ohne Warnung, `--target docs` 336 Dateien wie von Hand, ALL ohne Doxygen, elf Testziele grün). Thema von
  beiden Seiten erledigt; Sync auf Patriks Wort gestoppt (2026-11-26 20:37), Zugestelltes archiviert.
- `../sync_hoertest`: ungelesene Nachricht von LV (2026-11-10, F2 entschieden HF2 a / HF3 a) — in dieser Sitzung
  nicht bearbeitet.

## Entscheide (Patrik)

- **Freigabe v0.15.0** nach Leerlauf beider Seiten.
- **C3 a:** keine von CMakeCraft erzeugte Doxygen-Konfiguration in v0.15.0 (§8.3 bleibt Entwurf; Kipppunkt: ein
  Konsument ohne eigene Doxyfile). Das Schema hält den Platz frei: ohne `doxyfile` heute E001.
- Von CC gesetzt und von NOVA mitgetragen: kein Schalter `WARN_AS_ERROR` in `Solution.json` (gehört in die Doxyfile),
  keine Mindestfassung von Doxygen, `schemaVersion` bleibt 1.0 (eine 1.1 löste bei allen 1.0-Konsumenten W101 aus).

## Neu und geändert (Commit `92624ef`, v0.15.0)

- **Code**
  - `cmake/project/Documentation.cmake` 1.0.0 (Phase 12, nach Packages): `_create_doxygen_target()`,
    `find_package(Doxygen QUIET)` nur bei vorhandenem Block, `add_custom_target` ohne `ALL` mit
    `WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}`, `USES_TERMINAL`, `FOLDER Documentation`, Property `CRAFT_DOXYFILE`.
    Ohne Doxygen: W202 und ein Ziel, das mit Meldung scheitert (`cmake -E false`). E107 (Doxyfile fehlt), E001
    (`doxyfile` fehlt, Block kein Objekt), E102 (Zielname belegt).
  - `CMakeCraft.cmake` 0.15.0 (Include, Phasenschleife 1–12, Changelog); `Errors.cmake` 1.1.1 (Katalog E107, W202).
  - Selbsttest `phase12.cmake`: kein Ziel ohne Block; Doxyfile im Root, ALL ohne Doxygen, `--target docs` schreibt
    `apidoc/html/index.html`; Doxyfile im Unterordner mit `WARN_AS_ERROR` und `target: apidocs` scheitert an der
    Warnung; W202 über `CMAKE_DISABLE_FIND_PACKAGE_Doxygen`; E107; E001.
  - `templates/consumer/cmakecraft.pin` → v0.15.0.
- **Doku (de, en gespiegelt durch einen Hilfsagenten, Stichprobe geprüft)**
  - `Solution_Schema.md` 1.0.8: neuer §10 *documentation Block*, alte §10–14 → §11–15 (ältere Changelog-Einträge
    nennen die alte Nummerierung).
  - `Solution_Cheatsheet.md` 1.1.0 (dazu `packages` in der Root-Tabelle nachgetragen), `ErrorCodes.md` 1.7.0,
    `Guidelines.md` 1.0.2, `Future_Enhancements.md` 1.1.0 (§8.3), Modul-Doku `Documentation.md` und
    `Phase12_doc.md` neu, `CMakeLists.md`, `module/README.md`, `project_README.md`, `buildSystemTest_README.md`,
    `Neues_Projekt_Guide.md` 1.4.3, `Getting_Started.md` 1.0.2.

## Verifikation

- Phase 12 einzeln: 6/6 PASSED (Ninja/Clang, Doxygen 1.12.0).
- Voller Lauf: Phasen 1–10 PASSED; Phase 11 Test 5 (einfacher Bezieher, kompiliert mit STL-Headern) scheitert mit
  STL1000. Der Lauf bricht dort ab, Phase 12 lief deshalb im vollen Lauf nicht — einzeln grün.
- VS-Gegenprobe (`out/vsprobe`, danach gelöscht): Konfigurieren ohne Warnung, `docs` in der `.slnx` für alle
  Konfigurationen `Build Project="false"`, „Projektmappe erstellen“ ohne Doxygen, `--target docs` schreibt die HTML.
- `find_package(Doxygen)` findet `C:/Program Files/doxygen/bin` auch ohne PATH-Eintrag (Probe unter `LANGUAGES NONE`).
- **Nicht gemessen:** Novaseed gegen v0.15.0 (Seite NOVA); Linux.

## Stolperfallen

- **Umgebung, nicht Code:** VS-BuildTools seit 2026-11-19 auf MSVC 14.52 (`…\18\BuildTools\VC\Tools\MSVC\14.52.37025`),
  die STL verlangt Clang 22; installiert ist LLVM 20.1.7. Trifft jeden clang-Bau mit STL-Headern auf diesem Rechner
  (Selbsttest Phase 11, vermutlich auch die clang-Presets von LV und HT). Abhilfe: LLVM 22.
- **Doxygen legt von `OUTPUT_DIRECTORY` nur die letzte Ebene an** (`out/docs` ohne `out/` → Fehler). Doxygens eigenes
  Verhalten, an NOVA gemeldet; im Test auf eine Ebene (`apidoc`) gestellt.
- **CMake bricht lange Fehlermeldungen um:** ein Regex `\[E107\][^\n]*Missing` über die Ausgabe eines
  verschachtelten Configures greift dann nicht. Code und Detail getrennt prüfen (Phase 11 hat dasselbe Muster, bisher
  nur zufällig kurz genug).
- **Write-Werkzeug entfernt Leerzeichen am Zeilenende** in mehrzeiligen Python-Strings: Markdown-Kopfzeilen mit zwei
  Leerzeichen passten als patchlib-Anker nicht mehr. Anker für solche Zeilen als einzeilige Literale schreiben.
  **Hook-Kandidat:** Warnung, wenn ein mit Write geschriebenes `.py` einen `patch(`-Anker mit Markdown-Kopfzeile
  (`> **…:**`) über Zeilenende enthält — von Hand umgangen (Edit statt Skript) und dem Hilfsagenten als Regel
  mitgegeben.

## Offene Punkte / Plan für die nächste Session

1. LLVM auf 22 heben (Patrik), dann voller Selbsttest 12/12.
2. Hörtest-Sync: Nachricht von LV (F2 entschieden) lesen und einordnen.
3. Aus Session 10 weiter offen: LumiViz gegen v0.14.1/v0.15.0 bauen; zaunfester Markdown-Scanner.
