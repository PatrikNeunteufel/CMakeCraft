# CMakeCraft_Session10_2026-11-09_sync-lesen

> **Zeitraum:** 2026-11-09 · **Status:** abgeschlossen ·
> **Tests am Ende:** Selbsttest `craft-selftest` 11 von 11 PASSED (Configure Exit 0), Phase 9 mit den neuen Tests 11
> und 12; Gegenprobe HoerTest_Helper Release-clang und Release-MSVC, `--selbsttest` je 118 von 118
> **Basis:** `master` @ `8b68d25` (v0.14.0) → `0c027f0` (v0.14.1); Tag und Branch gepusht (Patrik)
>
> Begonnen als Lesesitzung („lies rein informativ mal den synch“). Daraus: Beitritt zu `../sync_hoertest`,
> WinMain-Befund von HT, vollständige englische Doku, Angleich der Doku an den Code, Fehlercode-Umbau und
> Versionsregeln. Zwischendurch angehalten (`session-pause`, 19:34–20:06).

## Schwerpunkt

**v0.14.1 und eine Doku, die in beiden Sprachen stimmt.** Der Code bekam drei Korrekturen (Qt-Einstiegspunkt,
vollständige Fehlermeldungen, Fehlerfälle von System-Externals). Die Doku wurde vollständig ins Englische übersetzt,
in beiden Sprachen an den Code angeglichen und nach festen Versionsregeln durchnummeriert.

## Sync

- **`../sync_hoertest`:** CC tritt bei (Patrik: „für Hörtests dasselbe wie für Sichttests“); HT bestätigt mit
  HT15–HT18 a. Bezug von Hoertest wie Sichttest (Release je Tag, `hoertest.pin`, External `archive`), Repo
  `HoerTest_Helper`, Pin `v0.14.0`. CC-2: Schnüren aus einem Pfad mit „ö“ geprüft (Zip, `sha256sum -c`, LF,
  Selbsttest aus dem Paket 118/118). CC-3: WinMain-Warnung (unten). HT hat v0.14.1 bezogen, voller Neubau ohne
  Warnung, 118/118. **Offen:** F2 bei LV (Hoertest neben die LumiViz-Exe oder nur im Zwischenspeicher).
  Nachrichten von CC: 7, 2242 von 4000 Token.
- `../sync_sichttest` und `../sync_LumiViz_CMakeCraft`: gestoppt, nur gelesen. Die CC-Hälfte im Sichttest-Sync
  nennt noch v0.13.1 als Stand (nicht nachgetragen).
- IC ist seit 09.11. aufgelöst (LumiViz S182, LP2 b); das Quellpaket aus v0.14.0 hat damit vorerst keinen Bezieher.

## Entscheide (Patrik)

- **W1 a:** Einstiegspunkt für Qt-GUI ausdrücklich setzen (v0.14.1).
- **D1 a:** `docs/en` vollständig übersetzen.
- **Befunde angleichen:** hier statt in eigener Sitzung.
- **K1 a / S1 a / C1 a / N1 a / K2 a / V2 a:** siehe unten.

## Neu und geändert (Commit `0c027f0`, v0.14.1)

- **Code**
  - `Qt6.cmake` 1.1.0, `_Qt6_configure_entry_point()`: `LINKER:/ENTRY:WinMainCRTStartup` für Exes mit Qt6 unter
    MSVC-ABI (Generator Expression auf `WIN32_EXECUTABLE` und `QT_NO_ENTRYPOINT`). Ursache: `Qt6EntryPoint.lib`
    definiert `WinMain` und `wWinMain`; lld-link warnte, link.exe wählte still dasselbe.
  - `Errors.cmake` 1.1.0: `cmake_fatal`/`cmake_warn` fügen alle Meldungsteile zusammen (`ARGV<n>`, Semikolons
    bleiben). Vorher ging bei E012, E502, E503, E220, W501 alles nach der ersten Zeile verloren. Katalog vollständig,
    nie ausgelöste Codes gekennzeichnet.
  - `system/Handler.cmake` 1.1.0: `find_package` ohne `REQUIRED`; `_system_external_not_found()` meldet E503
    (nicht gefunden), E504 (Komponente fehlt), E505 (Version). E501/W502 entfallen. Unterscheidung über
    `<Pkg>_DIR`, `_CONSIDERED_CONFIGS/VERSIONS`, `_NOT_FOUND_MESSAGE` (an Qt 6.10.1 gemessen).
  - Selbsttest Phase 9 (1.1.0): Test 11 (Einstiegspunkt), Test 12 (Meldungsteile; FakePkg 1.2.0 in verschachtelten
    Configures: ok, E504, E505, E503).
  - Veraltete Kommentare (Schema 1.0, Fehlerbereiche, Externals-Typen, PathResolver, `buildSystemTest/README.md`,
    `craft-selftest`, clang-format/-tidy, `APP_WINDOWS_GUI` in `templates/App` und `MyVisualizer`). Pin-Vorlage
    v0.14.1, `Neues_Projekt_Guide` 1.4.x.
- **Doku**
  - `docs/en` vollständig aus `docs/de` (neun Hilfsagenten je Bereich); fünf fehlende en-Dateien angelegt;
    `Phase8_doc.md` und `Phase9_doc.md` neu (de/en).
  - Angleich an den Code in beiden Sprachen (fünf Hilfsagenten, Stichproben gegen den Code); Befunde und Umsetzung in
    `docs/report/Doku_Befunde_2026-11-09.md`.
  - Verweise, Anker, Groß-/Kleinschreibung, Sprach-Kopfzeilen repariert (vorher ~165 tote Verweise je Sprache);
    verschachtelte Codeblöcke in acht Blueprints, überzähliger Zaun in `Tutorial.md`.
  - **S1 a:** de maßgeblich, en im selben Commit, Dateinamen gleich (`Language_Standard`, `Doc.md`).
    **N1 a:** zusammengesetzter Begriff zusammen, mehrere Begriffe mit Underscore.
  - **K1 a:** Doku-Versionen ab dem Doku-Release 1.0.0 („Release 1“, newCMake, `2e00db7`, 2025-12-26):
    Eintrag 1.0.0 nachgetragen (112 de-Dateien, drei mit eigenem Beleg), spätere 0.x-Einträge auf 1.0.N, Kopf =
    jüngster Eintrag. **K2 a:** keine CMakeCraft-Version im Kopf. **V2 a:** erstes Major-Release von CMakeCraft heißt
    v2.0.0; dann gehen Doku und `.cmake`-Dateien gemeinsam auf 2.0.0 (`Doku_Standard` §2, `CMake.md` §8.3).

## Verifikation

- Selbsttest 11/11 nach jedem Code-Schritt; zuletzt mit gelöschtem `TEST_PHASE`.
- Qt-Einstiegspunkt: Kopie von HoerTest_Helper gegen die Arbeitskopie, clang ohne Warnung, MSVC laut Map-Datei
  unverändert `WinMainCRTStartup` → `WinMain`; je 118/118. Demo `QtMarkdownViewer` linkt mit `/ENTRY`.
- C1: `cmake -P`-Probe mit Semikolon; HoerTest erneut clang/MSVC 118/118 (Qt6 gefunden, kein E5xx).
- Doku: `linkcheck2` (Datei, Groß-/Kleinschreibung, Anker) 0/0/0 in de und en; Sprach-Kopfzeilen 0; keine
  verschachtelten Zäune; Restdeutsch in en nur gewollt (Zitate, Glossarspalte); K1-Prüfung (Codeblock, Reihenfolge,
  Kopf) ohne Funde; Kopfversionen de = en.
- **Nicht gemessen:** LumiViz gegen v0.14.1 (Qt-Apps über `AppCreate`), Schnüren unter MSVC.

## Stolperfallen

- **Codeblöcke in Markdown-Skripten (zweimal):** Erst übersah `linkcheck.py` tote Verweise in verschachtelten
  Blöcken, dann schrieb `k1.py` den Eintrag 1.0.0 in Beispiel-Changelogs von vier Blueprints. Beide Male war die
  Ursache dieselbe: Überschriften und Tabellen in Codeblöcken nicht übersprungen. **Hook-/Werkzeug-Kandidat:** ein
  gemeinsamer, zaunfester Markdown-Scanner unter `~/.claude/tools/` für alle Doku-Skripte (Vorlage:
  `iter_lines()` in `linkcheck2.py`).
- **Falsche Einordnung des Release:** „Release 1“ (2025-12-26) gehört zu newCMake; die 1.0.0 ist eine Doku-Version,
  keine CMakeCraft-Version. Ich hatte es zuerst als Produkt-Release gelesen und K1 darauf aufgebaut; Patrik hat es
  richtiggestellt.
- **`TEST_PHASE` im Cache:** Nach `-DTEST_PHASE=9` lief der nächste „volle“ Selbsttest nur Phase 9 (1 PASSED,
  Exit 0). Seither mit `-UTEST_PHASE`. Kandidat: der Selbsttest meldet am Ende die Zahl der gelaufenen Phasen.
- **Makro für Meldungsteile verworfen:** In CMake-Makros ersetzt `ARGV<n>` textuell; das Zusammenfügen steht deshalb
  in beiden Funktionen selbst.
- **`/ENTRY` global bricht den Compilertest** (Konsolenprogramm ohne `WinMain`); deshalb am Ziel.
- **`HALTEPUNKT.md` landete im Commit `0c027f0`** (Fallback von `session-pause` ohne Handover). H1 a: Datei
  aufgelöst, `/HALTEPUNKT.md` in der `.gitignore`.
- Nebenbei: Ein „Speichern unter“-Dialog um ~22:20 kam nicht aus dieser Sitzung (wahrscheinlich der LumiViz-Lauf
  in Visual Studio).

## Offene Punkte / Plan für die nächste Session

1. Hinweise ohne Entscheid aus `docs/report/Doku_Befunde_2026-11-09.md`: `templates/projects/` unbenutzt
   (`<doctest/doctest.h>`), `validate_required_fields()`/`validate_solution_schema()` nie aufgerufen, mehrfach belegte
   Codes (W101, E400/E401, App-/Test-Codes), `CMakeLists.md` → `CMakeCraft_cmake.md`, Status von
   `Konzept_Versionierter_Bezug.md`, `Tests.cmake` mit `message(STATUS)`.
2. Zaunfester Markdown-Scanner als gemeinsames Werkzeug (Stolperfalle oben).
3. LumiViz gegen v0.14.1 bauen (Qt-Runner mit `/ENTRY`); Pin bei LV.
4. F2 im Hörtest-Sync abwarten.
5. Unverändert: Test für zwei Bibliotheken mit demselben External (Prüfsummen-Wächter), Linux-Prüfung des
   Quellpakets (ohne IC offen), Bauzeit Testing-MSVC, CC-8 Bootstrap, die Kopie entfernt nichts,
   `ENABLE_TESTING_CONFIG`, lange Pfade, Bass-PreFetch-Hook, `CMakeUserPresets.json` → `.example`.

---

> **Hinweis zur Ablage:** Der Steckbrief deklariert Session-Reports, Handover und Changelog/Logbuch als „—“. Dieser
> Report liegt wie die vorigen im Fallback-Pfad `docs/report/`. Der Changelog steht im Kopf von `CMakeCraft.cmake`.
