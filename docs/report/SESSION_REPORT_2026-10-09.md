# CMakeCraft_Session4_2026-10-09_sichttest-paket-v0-10-0

> **Zeitraum:** 2026-10-09 · **Status:** abgeschlossen ·
> **Tests am Ende:** Selbsttest `craft-selftest` 10 von 10 PASSED (Stand `1a83ace`; danach nur
> Doku und die Bootstrap-Vorlage geändert, kein weiterer Lauf)
> **Basis:** `master` @ `33ef321` → `8d7483c` · Tag **`v0.10.0` @ `25165cf`**, gepusht ·
> `8d7483c` liegt einen Commit über dem Tag und ist noch nicht gepusht
>
> Gebaut wurde im Sync `../sync_sichttest` (Prefix CC), zwei Abschnitte, beide von SH
> eröffnet und geleitet: Schritte 3 und 4 (CMakeCraft v0.10.0, erstes Paket) und der Anfang
> von Schritt 5 (Gegenprobe des Bezugs in LumiViz).

## Schwerpunkt

**CMakeCraft v0.10.0: ein fertiges Paket schnüren und beziehen.** Der Entwurf vom
2026-10-08 ist umgesetzt, bei SichtTest_Helper (schnüren) und LumiViz (beziehen)
gegengeprüft, getaggt und von beiden gepinnt. Das erste Paket `sichttest-v0.2.0-win64.zip`
ist als Release veröffentlicht und wurde in LumiViz über den Pin von GitHub bezogen.

## Neu

- **`CMakeCraftPackage.cmake`** (Repo-Wurzel, eigenständig, Versionszeile 1.0.0):
  `craft_package_fetch` (Override `<NAME>_LOCAL_DIR` → Zwischenspeicher → Herunterladen mit
  Prüfsumme → Fallback-Pfade; geprüft wird `produkt=` in `VERSION`; Fehlschlag ist eine
  Warnung) und `craft_package_deploy` (Include-Pfad und Define PRIVATE, Dateien und Ordner
  neben die Exe).
- **`cmake/project/Packages.cmake`, `PackageBuild.cmake`:** Block `packages` →
  Target `package_<name>` (nicht in ALL) → `<Projekt>/out/package/` mit Ordner, `.zip`,
  `.zip.sha256`. Quellen je Eintrag: `headers_of`, `binary_of`, `output_dir_of`, `from`.
- **`cmake/externals/archive/Handler.cmake`:** External-Art `archive` (`pin`, `platforms`,
  `include_dirs`, `define`, `runtime { files, dirs }`; je Target
  `external_options.<name>.runtime: false`).
- **`cmake/buildSystemTest/phase10.cmake`:** schnürt ein Kleinpaket im Build-Baum und bezieht
  es über `file://`-Adresse, Zwischenspeicher und Fallback-Pfad; ohne Netz.
- **Demo:** Bibliothek `PackDemo` (SHARED, `output_name`, `defines`) und Paket `packdemo` in
  der Demo-`Solution.json` — schließt die Selbsttest-Lücke aus Session 2 für die Paketseite.
- **Doku:** Referenz `docs/{de,en}/guide/references/Packages.md`; Modul-Doku für die fünf
  neuen Module (de + en, von einem Agenten geschrieben, von mir an zwei Stellen berichtigt).
- **Fehlercodes:** E220 (Archiv-External ohne `pin`), W112 (Paket nennt fehlendes Target),
  W304 (Archiv-External nicht verfügbar).

## Geändert

- **Bibliotheken** kennen `output_name` und `defines`; `{version}` in `defines` wird bei
  Bibliotheken und Executables durch die Version des Targets ersetzt
  (`LibraryCollect.cmake`, `LibraryCreate.cmake`, `ExecutableCreate.cmake`). Zusatz zum
  Entwurf, von Patrik bestätigt (1a) — Anlass war der Befund von SH, dass die Produktversion
  in v0.9.2 kein Target erreicht.
- **Orchestrator, Validation, Errors:** Art `archive` als viertes Quellfeld.
- **`CMakeCraft.cmake`:** Version 0.10.0, Phase 10 (Packages) nach den Apps, Phasentests 1–10.
- **Mindestversion CMake 3.26** (`CMakeLists.txt`, README, Vorlage, `Neues_Projekt_Guide.md`).
- **Doku-Nebenbefunde von SH berichtigt:** `hooks.preFetch`/`hooks.postFetch` statt
  `preFetchHook`/`postFetchHook`; `EXTERNAL_ROOT` statt `EXTERNAL_PATH` in 10 Dateien;
  `version` eines System Externals ohne `>=`. Dazu die Fehlertabelle in
  `Solution_Schema.md` §12.1 (E216–E220, W302), die den Code falsch beschrieb.
- **Nach dem Tag (`8d7483c`):** die Bootstrap-Vorlage gibt bei einem fehlgeschlagenen Klon
  die Meldung von git aus; `Packages.md` §3.2 (Kopie läuft beim Bau der Exe) und §3.4
  (Zwischenspeicher gilt über die Version).
- **Lokal, nicht versioniert:** `CLAUDE.md` (Phasentests 1–10, Landkarte, „Ausstehend").

## Entscheide von Patrik (2026-10-09)

| Punkt | Entscheid |
|---|---|
| `defines` für Bibliotheken und `{version}` | bleiben in v0.10.0 |
| Zeitpunkt des Tags | erst nach der Gegenprobe bei LV — so geschehen |
| Kopie der Laufzeitdateien nach einem Paketwechsel | Behebung in der nächsten Version, kein v0.10.1 |

## Stolperfallen

- **Warncode doppelt vergeben.** W111 war schon belegt (`SourceCollect.cmake:435`), stand
  aber nicht in der Liste in `Errors.cmake`; ich hatte ihn für das Paket-Target genommen und
  SH so gemeldet. Jetzt W112, im Sync berichtigt. **Hook-/Prüfer-Kandidat:** ein Abgleich
  aller `cmake_fatal`/`cmake_warn`-Codes in `cmake/` gegen die Liste in `Errors.cmake`
  (doppelt vergeben, nicht gelistet) — von Hand per `grep` gefunden, und nur zufällig.
- **`-MarkRead` markiert mehr, als gelesen wurde** — wieder einmal (13:49: zwei markiert,
  eine gelesen; nachgelesen). Derselbe Kandidat wie am 08.10., Werkzeug des Syncs.
- **Gemeldeter Commit war nicht da.** Auf „Nachträge committet" stand `HEAD` unverändert, drei
  Dateien waren noch geändert. Nach jeder Commit- oder Tag-Meldung `git log` und
  `git status` ansehen, bevor sie in den Sync weitergeht.
- **Abgeschnittene Ausgabe als Fehler gelesen.** Der „leere Grund" in der Warnung war ein
  `cut -c1-200` hinter einem langen Scratchpad-Pfad, kein Fehler im Code — einzeln
  nachgestellt, bevor etwas geändert wurde.
- **Heredoc und Backslash.** Der Hook hat es einmal abgewiesen, einmal habe ich ihn bewusst
  übergangen; dabei wurde `\\n` zu `\n` und ein Anker passte nicht. Patch-Skripte mit
  Backslashes über das Write-Werkzeug anlegen.
- **Weitergegebene Anordnung.** Der Abschluss kam als Nachricht der SH-Sitzung; abgeschlossen
  wurde nach Patriks Wort in dieser Sitzung.
- **`"archive": false`** besteht `validate_external_source` (prüft nur den Schlüssel) und
  endet im Orchestrator mit E012. Beobachtung des Doku-Agenten, nicht geändert.

## Verifikation

- **Selbsttest:** `cmake --preset craft-selftest`, 10 von 10 PASSED; `package_packdemo`
  gebaut (Ordner, `.zip`, `.zip.sha256`).
- **Probeprojekte im Scratchpad** (Ninja und Ninja Multi-Config, clang): schnüren; Abbruch in
  falscher Konfiguration bei unberührtem Paket; `exclude` in zwei Ordnertiefen; Bezug über
  Fallback-Pfad und Zwischenspeicher; falsche Prüfsumme → Warnung, Bau ohne Paket; Kopie
  von Datei und Ordner; `runtime: false`; Bezug ohne CMakeCraft.
- **SH:** geschnürt mit Arbeitskopie und danach mit dem Pin v0.10.0 über den Bootstrap;
  Paket vollständig (windeployqt-Ordner, 19 Dateien), `--selbsttest` Exit 0.
- **LV:** bezogen über Fallback-Pfad und durch Herunterladen von der Release-Adresse auf
  GitHub; Release-clang, Debug-MSVC, Testing-MSVC (Visual-Studio-Generator).
- **Nicht gesehen:** ein Lauf mit getrenntem Netz; Schnüren mit MSVC (mein Versuch mit dem
  VS-Generator scheiterte im Scratchpad schon am Compilertest); der Bezug im Comm Studio;
  in LumiViz sind die Köpfe noch nicht eingebunden und die DLL nicht geladen.
- **Ungeklärt:** einmaliger Fehlschlag 128 beim Bootstrap-Klon von GitHub bei SH; bei LV
  nicht aufgetreten.

## Offene Punkte / Plan für die nächste Session

1. **Kopie der Laufzeitdateien ohne neues Linken** (aufgeschoben, Entscheid Patrik): die
   Kopie hängt als POST_BUILD an der Exe; nach einem Pin-Wechsel bleibt die alte liegen, bis
   die Exe neu gebaut wird. Eigenes Ziel in `craft_package_deploy`; Gegenprobe mit dem
   VS-Generator; die Datei trägt CS als Kopie, also Versionszeile heben. Wird dringlich,
   sobald SH ein neues Paket liefert (möglich durch den Entscheid P2 bei LV: Projektdatei
   unter `.sichttest/`).
2. **`compile_options` für App-Tests** (LV: `/bigobj`, C1128 im Debug-MSVC-Bau).
3. **Push von `8d7483c`**; ob die Bootstrap-Vorlage bei SH und LV getauscht wird, entscheidet
   Patrik.
4. **Codes abgleichen** (siehe Stolperfallen); dabei W111 in `ErrorCodes.md` nachtragen.
5. **Altlasten in der Modul-Doku** (vom Agenten gemeldet, nicht angefasst):
   `module/CMakeLists.md` beschreibt die alte monolithische Fassung; tote Links in den
   Modul-READMEs; `Orchestrator_cmake.md` kennt in Übersicht und Diagrammen nur Local und
   Fetched; die en-Dateien sind im Bestand deutscher Text mit einzelnen englischen Wörtern.
6. **Lange Pfade:** drei Demo-/Testdateien unter `projects/` sprengen den Klon in sehr tiefe
   Zielpfade (Nebenbefund SH).
7. **Selbsttest-Lücke, Rest:** die Demo-Solution trägt kein Archiv-External; Phasentest 10
   ruft den Handler direkt.
8. Unverändert aus `CLAUDE.md` „Ausstehend": Bass-PreFetch-Hook (hätte mit `archive` jetzt
   seinen Unterbau), `CMakeUserPresets.json` → `.example`-Muster, Doku-Umzug Phase 2.

---

> **Hinweis zur Ablage:** Der Steckbrief deklariert Session-Reports, Handover und
> Changelog/Logbuch als „—". Dieser Report liegt wie die vorigen im Fallback-Pfad
> `docs/report/`; ein Handover wurde nicht angelegt. Das Changelog der Version steht im Kopf
> von `CMakeCraft.cmake`.
