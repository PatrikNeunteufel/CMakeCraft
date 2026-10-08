# CMakeCraft_Session3_2026-10-08_sichttest-paket-bezug

> **Zeitraum:** 2026-10-08 · **Status:** abgeschlossen ·
> **Tests am Ende:** kein Lauf — in dieser Sitzung wurde an `cmake/` nichts geändert
> (letzter Selbsttest: 2026-10-05, 9 von 9 PASSED, Stand `af09dbf` = Tag `v0.9.2`)
> **Basis:** `master` @ `af09dbf` · nichts committet
>
> Reine Abstimmungssitzung: lesen, entwerfen, im Sync klären. Gebaut wird in einer
> späteren Sitzung (Schritt 3 der gestaffelten Freigabe, siehe unten).

## Schwerpunkt

**Entwurf für v0.10.0: ein fertiges Paket schnüren und beziehen.** CMakeCraft wurde als
vierter Teilnehmer in den Sync `../sync_sichttest` aufgenommen (Prefix CC; SH =
SichtTest_Helper, LV = LumiViz, CS = Communication Studio). Anlass: Das Werkzeug
`Sichttest.exe` soll die geprüfte Anwendung über eine DLL steuern; jede Version liefert ein
fertiges Paket (Köpfe, DLL, Tester mit seinem Qt) als GitHub-Release, die Anwendungen
beziehen es über einen Pin. Beides kann v0.9.2 nicht. Verbindliche Spezifikation:
`SichtTest_Helper/docs/Konzept_Steuerung.md` (Fassung 08.10.2026).

## Neu

Versioniert nur **dieser Report**.

Lokal, nicht versioniert (beide Dateien sind gitignored):

- **Steckbrief** in `CLAUDE.md`: Zeile **Sync** mit beiden Sync-Verzeichnissen und dem
  Prefix CC.
- `.claude/settings.json` hat je einen zweiten Hook-Eintrag (`SessionStart`,
  `UserPromptSubmit`) für `sync_sichttest`; der Eintrag für `sync_LumiViz_CMakeCraft`
  steht daneben.

## Der Entwurf (Ergebnis der Abstimmung, noch nicht gebaut)

Alles in **v0.10.0**; Mindestversion CMake **3.26** (statt 3.25).

1. **Eigenständige Datei `CMakeCraftPackage.cmake`** — gehört CMakeCraft, ohne Abhängigkeit
   vom Kern, Versionszeile im Kopf; das Comm Studio (baut ohne CMakeCraft) trägt eine
   unveränderte Kopie. Vorbild: `templates/consumer/CMakeCraftBootstrap.cmake`.
   - `craft_package_fetch(NAME … PIN_FILE … [CACHE_DIR …] OUT_ROOT …)` — Reihenfolge:
     `<NAME>_LOCAL_DIR` → Cache (Vorgabe `.externals/<name>/<version>/`) →
     `file(DOWNLOAD)` mit `EXPECTED_HASH SHA256` und Entpacken → Fallback-Pfade (dort das
     `.zip`, gleiche Prüfsumme). Geprüft wird `produkt=` in der Datei `VERSION` des Pakets.
     Scheitert der Bezug: Warnung, kein Abbruch.
   - `craft_package_deploy(TARGET … ROOT … INCLUDE_DIRS … RUNTIME_FILES … RUNTIME_DIRS …
     [DEFINE …])` — Include-Pfad ohne Link und Define `<NAME>=1` an jedem Target; Dateien
     und Ordner neben die Exe je Konfiguration (`copy_directory_if_different`), nur wenn das
     Target eine Exe ist. Fehlt das Paket: weder Pfad noch Define noch Kopie.
2. **External-Art `archive`** in `Solution.json`:

   ```json
   "sichttest": {
     "archive": true,
     "pin": "sichttest.pin",
     "platforms": ["windows"],
     "include_dirs": ["include"],
     "define": "SICHTTEST_VORHANDEN",
     "runtime": { "files": ["bin/SichttestSteuerung1.dll"], "dirs": ["sichttest"] }
   }
   ```

   Abschalten je Target: `"external_options": { "sichttest": { "runtime": false } }`.
   Der Pin steht **nur** in der Pin-Datei (`SICHTTEST_VERSION`, `SICHTTEST_URL`,
   `SICHTTEST_SHA256`, `SICHTTEST_FALLBACK_PATHS`).
3. **Block `packages`** in `Solution.json` → Target `package_<name>` (nicht in ALL):

   ```json
   "packages": [
     {
       "name": "sichttest",
       "archive": "sichttest-v{version}-win64",
       "config": "Release",
       "contents": [
         { "to": "include",   "headers_of": "SichttestSteuerung",
           "files": ["sichttest_steuerung.h", "sichttest_steuerung.hpp", "sichttest_steuerung_qt.hpp"] },
         { "to": "bin",       "binary_of": "SichttestSteuerung" },
         { "to": "sichttest", "output_dir_of": "Sichttest", "exclude": ["*.pdb", "*.ilk"] }
       ],
       "version_file": "packaging/VERSION.in"
     }
   ]
   ```

   Ergebnis in `<Projekt>/out/package/`: Ordner, `.zip`, `.zip.sha256`. Das Hochladen als
   Release macht Patrik.
4. **`output_name`** für Bibliotheken (heute heißt die Datei wie das Target).
5. Phasentest für alle vier; Doku de + en (`Solution_Schema.md`, Referenz Archiv-Externals,
   `Neues_Projekt_Guide.md`, Modul-Doku); dabei die drei Doku-Nebenbefunde von SH.

**Nichts davon ist per Default aktiv.** Ein Projekt schaltet es über Pin-Datei, External und
die `externals`-Liste eines Targets zu.

## Entscheide von Patrik (2026-10-08)

| Punkt | Entscheid |
|---|---|
| Wem die Bezugslogik gehört | CMakeCraft (`CMakeCraftPackage.cmake`); SH schreibt kein eigenes Skript |
| Wo der Pin steht | nur in `sichttest.pin`; `Solution.json` verweist mit `"pin"` darauf |
| Version | alles in v0.10.0, CMake 3.26 |
| E7 (in der SH-Sitzung) | Repo SichtTest_Helper öffentlich; Bezug per einfachem Download |
| Freigabe (in der SH-Sitzung, gestaffelt) | v0.10.0 entsteht erst in Schritt 3+4, zusammen mit SH, in einem **neu eröffneten** Sync |

## Am Quelltext v0.9.2 nachgelesen

- Ein `path`-External darf ein eigenes Skript nennen (`"include"`), das je Ziel-Target
  läuft: `cmake/externals/Orchestrator.cmake:231-235`, `:259`;
  `cmake/externals/local/Attach.cmake:80-83`. Include-Pfad ohne Link und Kopie neben die
  Exe wären damit heute schon möglich — der Bezug nicht.
- `path` muss beim Configure existieren (`Attach.cmake:70-72`, E214) und ist fest relativ
  zu `CMAKE_SOURCE_DIR` (`Attach.cmake:64`, `Orchestrator.cmake:229`).
- Kein `file(DOWNLOAD`, kein `install(`, kein `export(` in `cmake/` (Suche leer).
- Ausgabeorte sind fest (`cmake/core/OutputDirs.cmake:108-116`); windeployqt läuft als
  POST_BUILD (`cmake/externals/system/packages/Qt6.cmake:200-208`) — `output_dir_of` kann
  sich darauf stützen.
- Bibliotheken kennen kein `output_name`, `defines`, `compile_options`, `link_options`
  (gelesene Schlüssel in `cmake/project/LibraryCollect.cmake`).

## Stolperfallen

- **`-MarkRead` markiert mehr, als gelesen wurde.** Dreimal in dieser Sitzung setzte der
  Schalter das Wasserzeichen über Nachrichten, die zwischen Lesen und Markieren eingetroffen
  waren; ich habe sie jeweils nachgelesen. **Hook-/Prüfer-Kandidat** (Werkzeug des Syncs,
  nicht dieses Repo): `sync_check.ps1 -MarkRead` nennt die markierten Dateien oder nimmt eine
  Obergrenze (`-Bis <datei>`).
- **`sync_post.ps1 -An` nimmt einen Empfänger oder `alle`**, keine Liste. Der Entwurf ging
  deshalb an alle statt an SH und LV.
- **Der Hook meldet „es darf gebaut werden", die Freigabe war aber gestaffelt.** Der Wortlaut
  der Freigabe-Nachricht geht vor dem Sammelhinweis des Werkzeugs.
- **Weitergegebene Anordnungen.** Freigabe und Abschluss kamen als Nachricht der SH-Sitzung
  („Patrik hat angeordnet …"). Abgeschlossen wurde erst nach Patriks Bestätigung in dieser
  Sitzung.
- **Zählung verschätzt:** `EXTERNAL_PATH` zunächst mit 18 Doku-Dateien angegeben; nachgezählt
  sind es 10. Vor dem Ablegen der Nachricht berichtigt.

## Verifikation

- **Kein Build, kein Selbsttest** — es gab keine Änderung an `cmake/`.
- Der Entwurf ist **gelesen, nicht erprobt**. Ungeprüfte Annahmen: `copy_directory_if_different`
  mit einem Ordner samt Qt-Plugins; `file(DOWNLOAD)` gegen eine GitHub-Release-Adresse
  (Weiterleitung); `/permissive- /Zc:preprocessor /Zc:__cplusplus` auf C-Dateien unter MSVC.
- Die Leerlauf-Ergebnisse von SH, LV und CS decken sich mit dem von CC (im Sync nachgelesen).

## Offene Punkte / Plan für die nächste Session

1. **v0.10.0 bauen** — erst, wenn SH Schritt 2 (DLL, Köpfe, Tester) fertig hat und den Sync
   neu eröffnet. Erster Punkt dort: was bei SH vom Konzept abwich. Dann in dieser
   Reihenfolge: `CMakeCraftPackage.cmake` → `packages` + `output_name` (SH braucht es zuerst)
   → External-Art `archive` → Phasentest → Doku.
2. **Gegenprobe vor dem Tag** mit `-DCMAKECRAFT_LOCAL_DIR=../CMakeCraft`: bei SH schnüren,
   bei LV beziehen aus `../SichtTest_Helper/out/package` über den Fallback-Pfad, ohne Netz.
3. **Selbsttest-Lücke** (aus Session 2, unverändert): die Demo-Solution braucht ein External,
   das den neuen Pfad ausübt — ein kleines mitgeliefertes Archiv-Paket würde beides abdecken.
4. **Doku-Nebenbefunde** (bestätigt, mit v0.10.0): `preFetchHook`/`postFetchHook` statt
   `hooks.preFetch`/`hooks.postFetch` in `Solution_Schema.md:234-235`; `EXTERNAL_PATH` statt
   `EXTERNAL_ROOT` in 10 Doku-Dateien; `version ">=6.5.0"` in `Solution_Schema.md:249,262`.
5. **Nicht committet:** dieser Report und weiterhin `SESSION_REPORT_2026-10-05.md`.
6. **Sync:** `../sync_sichttest` wird von SH gestoppt, sobald alle Hälften in `abschluss/`
   liegen. Die Hooks in `.claude/settings.json` bleiben eingebaut und schweigen.
7. Unverändert aus `CLAUDE.md` „Ausstehend": Bass-PreFetch-Hook (bekäme mit `archive`
   seinen Unterbau), `CMakeUserPresets.json` → `.example`-Muster, Doku-Umzug Phase 2.

---

> **Hinweis zur Ablage:** Der Steckbrief deklariert Session-Reports, Handover und
> Changelog/Logbuch als „—". Dieser Report liegt wie die beiden vorigen im Fallback-Pfad
> `docs/report/`; ein Handover wurde nicht angelegt.
