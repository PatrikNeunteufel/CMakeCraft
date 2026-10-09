# CMakeCraft_Session5_2026-10-09_laufzeitkopie-eigenes-ziel

> **Zeitraum:** 2026-10-09 (abends) · **Status:** abgeschlossen ·
> **Tests am Ende:** Selbsttest `craft-selftest` 10 von 10 PASSED (Arbeitskopie vor dem Commit
> `6e5de20`; danach nichts mehr geändert)
> **Basis:** `master` @ `72b7b45` → `6e5de20` · Tag **`v0.11.0` @ `6e5de20`**, Tag und `master`
> gepusht
>
> Gebaut wurde im Sync `../sync_sichttest` (Prefix CC), Abschnitt „LumiViz bindet ein"
> (Konzept §13 Schritt 4), von SH eröffnet und geleitet. Auftrag von Patrik in dieser Sitzung:
> zuerst CC-7, danach CC-9.

## Schwerpunkt

**CMakeCraft v0.11.0: die Laufzeitdateien eines Archiv-Externals kommen ohne neues Linken an.**
Der am Nachmittag aufgeschobene Punkt (CC-7) ist gebaut, unter dem Visual-Studio-Generator
gegengeprüft, getaggt und von LumiViz gepinnt und bestätigt. Dazu `compile_options` für
App-Tests (CC-9), ebenfalls bei LumiViz bestätigt.

## Neu

- **Deploy-Ziel** (`CMakeCraftPackage.cmake` 1.1.0): `craft_package_deploy` legt für eine Exe
  mit Laufzeitdateien ein Ziel `<Exe>_deploy_<Name>` an (`add_custom_target`, nicht in ALL),
  von dem die Exe abhängt. Es läuft bei jedem Bau der Exe und bei jedem Bau von allem. Neues
  optionales Argument `NAME`; ohne Angabe heißt das Ziel `<Target>_deploy_package`. Der
  Handler der External-Art `archive` gibt den Namen des Externals mit.
- **`compile_options` an `apps[].tests.targets[]`** (`AppCollect.cmake`, `AppCreate.cmake`):
  Liste, PRIVATE am Test-Target, nach `apply_compiler_options()` gesetzt. Ein Flag, das nur
  ein Compiler versteht, steht in einer Generator Expression
  (`$<$<CXX_COMPILER_ID:MSVC>:/bigobj>`).
- **Phasentest 10, Test 7:** zwei Exe-Ziele außerhalb von ALL; das Deploy-Ziel existiert, die
  Exe hängt davon ab, mit `"runtime": false` entsteht keines.
- **Phasentest 8, Test 2b:** `compile_options` werden gesammelt (Generator Expression
  unverändert) und stehen am Demo-Target `MyVisualizer.UnitTests`.

## Geändert

- **Kein POST_BUILD mehr** für die Kopie. Der Zielordner wird vor dem Kopieren angelegt, weil
  das Ziel vor dem ersten Linken läuft. Die Datei setzt für ihre Funktionen CMP0112 auf NEW:
  `$<TARGET_FILE_DIR:…>` im Deploy-Ziel darf keine Abhängigkeit auf die Exe erzeugen, sie läuft
  in der Gegenrichtung.
- **IDE-Ordner:** das Deploy-Ziel übernimmt `FOLDER` der Exe, gelesen am Ende des
  Verzeichnisses (`cmake_language(DEFER)`), weil CMakeCraft den Ordner erst nach den Externals
  setzt.
- **`CMakeCraft.cmake`:** Version 0.11.0 mit Changelog-Eintrag.
- **Demo-`Solution.json`:** `MyVisualizer.UnitTests` trägt `compile_options` mit `/bigobj` für
  MSVC.
- **Doku (de + en):** `references/Packages.md` §3.2 und §5 (1.1.0), `references/Solution_Schema.md`
  §5.8 und §9.8 (0.9.0), Modul-Doku `CMakeCraftPackage.md`, `externals/archive/Handler_cmake.md`,
  `buildSystemTest/Phase10_doc.md`, `project/AppCollect.md`, `project/AppCreate.md`.
- **Lokal, nicht versioniert:** `CLAUDE.md` („Ausstehend").

## Entscheide von Patrik (2026-10-09, abends)

| Punkt | Entscheid |
|---|---|
| Reihenfolge | CC-7 vor dem Pin-Wechsel bei LumiViz, danach CC-9 |
| Versionsnummer | v0.11.0 |

## Stolperfallen

- **Der Visual-Studio-Generator baut nicht im Scratchpad.** Der Pfad unter `%TEMP%` ist zu
  lang; MSBuild scheitert schon am Compilertest (FileTracker FTK1011, dazu die Warnung
  MSB8029). Das war der ungeklärte Fehlschlag aus Session 4. Probeprojekte für diesen
  Generator liegen unter dem ignorierten `out/`. Steht jetzt in `CLAUDE.md`.
- **`cmake_language(DEFER CALL …)` wertet Variablen erst beim Ausführen aus.** Der erste
  Selbsttest brach am Ende des Configure ab (`get_target_property() called with non-existent
  target ""`): die Funktionsvariablen waren dann weg. Die Namen müssen über
  `cmake_language(EVAL CODE …)` festgeschrieben werden. Im Probeprojekt fiel es nicht auf,
  weil die Stelle erst danach dazukam — nach der Änderung habe ich die VS-Probe wiederholt.
- **Heredoc und Backslash,** wieder: der Hook hat zwei Patch-Skripte abgewiesen (zurecht).
  Seitdem über das Write-Werkzeug angelegt. Kein neuer Kandidat, der Hook greift.
- **Der Wächter endet sofort, solange eine Frage an die eigene Seite offen ist.**
  `sync_check.ps1` mahnt die unbeantwortete Frage bei jedem Lauf an; der Wächter hält das für
  eine Zustellung. Er trägt also erst wieder, wenn geantwortet ist. Kandidat für das Werkzeug
  des Syncs: im Wächter-Aufruf nur Neues melden, nicht die Mahnung.
- **„Gepusht" war zuerst nur der Tag.** Nach der Meldung stand `master` am Remote noch auf
  `72b7b45`; `git ls-remote` hat es gezeigt. Für den Bezug ohne Belang (der Bootstrap klont
  über den Tag), im Sync deshalb mit dem Tag als Beleg gemeldet. Die Regel aus Session 4 hat
  getragen: nach jeder Commit-, Tag- oder Push-Meldung nachsehen.
- **Der Leerlauf muss nach jeder inhaltlichen Nachricht erneuert werden** — fünfmal in diesem
  Abschnitt, jedes Mal mit „Ergebnis unverändert". Kostet kein Budget, aber Runden in der
  Sitzung.

## Verifikation

- **Selbsttest:** `cmake --preset craft-selftest`, 10 von 10 PASSED. Dazu gebaut:
  `_craft_phase10_exe` (Dateien und Ordner liegen neben der Exe) und `MyVisualizer.UnitTests`
  (clang).
- **Probeprojekt unter `out/cc7/`** (zwei Paketversionen, Pin-Datei mit Fallback-Pfad), fünf
  Schritte je Generator: erster Bau · Bau ohne Änderung · Pin gewechselt und nur die Exe gebaut
  (kein eigener Configure) · Kopien gelöscht und alles gebaut · Pin zurück und nur das
  Deploy-Ziel gebaut. In jedem Schritt die richtigen Dateien neben der Exe, der Zeitstempel
  der Exe nach dem ersten Bau unverändert. Gesehen mit **Visual Studio 17 2022** (Debug und
  Release), **Ninja** und **Ninja Multi-Config** (clang).
- **Kosten:** am Paket v0.3.0 von SH (Ordner `sichttest`, 19 Dateien, 51 MB) rund 0,2 s je Bau,
  wenn nichts zu kopieren ist.
- **CC-9 unter MSVC:** Configure der Demo-Solution mit dem VS-Generator; `/bigobj` steht in
  `MyVisualizer.UnitTests.vcxproj` und in keinem anderen Projekt.
- **LumiViz** (Meldungen LV 19:05 und 19:31): Pin v0.11.0; Kopie der DLL gelöscht, nur gebaut →
  wieder da, Exe unberührt (Release-clang, Ninja). `LumiViz.UnitTests` baut im Debug-MSVC ohne
  C1128; im clang-Bau steht das Flag nicht.
- **Nicht gesehen:** F5 in der IDE (nur `cmake --build` mit dem VS-Generator); ein Lauf mit
  getrenntem Netz; Schnüren mit MSVC; der Bezug im Comm Studio.

## Offene Punkte / Plan für die nächste Session

1. **Die Kopie entfernt nichts.** Dateien, die ein früheres Paket neben die Exe gelegt hat und
   die das neue nicht mehr enthält, bleiben liegen. Wird greifbar, sobald SH die Schnittstelle
   hebt (`SichttestSteuerung2.dll`): die alte DLL bliebe stehen. Nicht entschieden, ob und wie
   CMakeCraft das abräumt.
2. **Ein echter Paketwechsel linkt bei LumiViz trotzdem neu** (Befund LV): der Include-Pfad
   trägt die Version, Kern und Runner übersetzen neu. Für die Kopie ohne Belang, sie hängt
   nicht mehr am Linken. Notiert, kein Eingriff geplant.
3. **Schritt 6 (Comm Studio):** CS übernimmt `CMakeCraftPackage.cmake` als Kopie — jetzt aus
   dem Tag `v0.11.0` (Versionszeile 1.1.0), nicht mehr aus `v0.10.0`. Aufruf wie `Packages.md`
   §5; der aktuelle Pin des Pakets ist v0.3.3 (SH 22:33).
4. Unverändert aus dem Report von heute Nachmittag: Codes abgleichen (`cmake_fatal`/
   `cmake_warn` gegen die Liste in `Errors.cmake`, W111 in `ErrorCodes.md`); Altlasten der
   Modul-Doku; lange Pfade unter `projects/`; die Demo-Solution trägt kein Archiv-External;
   Bootstrap-Fehlschlag 128 bei SH ungeklärt; ob die neue Bootstrap-Vorlage bei SH und LV
   getauscht wird.
5. Unverändert aus `CLAUDE.md` „Ausstehend": Bass-PreFetch-Hook, `CMakeUserPresets.json` →
   `.example`-Muster, Doku-Umzug Phase 2.

---

> **Hinweis zur Ablage:** Der Steckbrief deklariert Session-Reports, Handover und
> Changelog/Logbuch als „—". Dieser Report liegt wie die vorigen im Fallback-Pfad
> `docs/report/`, als zweiter des Tages mit Suffix `b`; ein Handover wurde nicht angelegt. Das
> Changelog der Version steht im Kopf von `CMakeCraft.cmake`. Das Probeprojekt unter
> `out/cc7/` ist ignoriert und kann gelöscht werden.
