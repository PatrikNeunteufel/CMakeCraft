# CMakeCraft_Session6_2026-10-10_sync-abschluss-sichttest

> **Zeitraum:** 2026-10-10 (abends) · **Status:** abgeschlossen ·
> **Tests am Ende:** nicht gelaufen — in dieser Sitzung wurde nichts gebaut und kein Modul
> geändert; letzter Stand ist der Selbsttest 10 von 10 aus Session 5 (`6e5de20`)
> **Basis:** `master` @ `ba74707`, unverändert · Tag `v0.11.0` @ `6e5de20`
>
> Sync `../sync_sichttest` (Prefix CC), Abschnitt „Comm Studio bindet ein" (Konzept §13
> Schritte 5/6), von SH eröffnet und geleitet, mit CS. CC war nicht beteiligt und hat in dem
> Abschnitt keine Nachricht abgelegt.

## Schwerpunkt

**Abschluss-Hälfte von CC für den Abschnitt „Comm Studio bindet ein" und Einordnung eines
Befunds von CS:** das Deploy-Ziel aus `craft_package_deploy` bringt unter dem Generator
`Visual Studio 18 2026` je Bau eine MSBuild-Warnung. Eingeordnet aus den Quellen, nicht
gebaut. Entscheid von Patrik: Behebung als v0.11.1 in der nächsten CC-Sitzung.

## Neu

- Nichts am Build-System. Dieser Report und die Hälfte `abschluss/2026-10-10-CC.md` im
  Sync-Verzeichnis.

## Geändert

- **Lokal, nicht versioniert:** `CLAUDE.md` („Ausstehend": MSBuild-Warnung am Deploy-Ziel).

## Zur Kenntnis aus dem Abschnitt (gemeldet von CS und SH, nicht von CC gesehen)

- **Der Bezug ohne CMakeCraft trägt im fremden Projekt.** CS bezieht das Paket mit der
  byte-gleichen Kopie von `CMakeCraftPackage.cmake` aus Tag `v0.11.0` (Versionszeile 1.1.0),
  Generator `Visual Studio 18 2026`, Debug und Release: Download, Prüfsumme, Entpacken, beim
  zweiten Configure aus dem Zwischenspeicher (CS 15:15). Das war der Punkt „der Bezug im Comm
  Studio" aus der Liste des Ungesehenen von Session 5.
- **CC-7 trägt auch unter MSBuild.** Nach dem Pin-Wechsel auf v0.3.4 lag der neue Tester in
  beiden Bauarten neben der Exe, ohne dass sie neu gelinkt wurde (CS 16:12).
- CS setzt `CACHE_DIR` auf `externalsw/sichttest/<version>` und liest dafür die Pin-Datei vor
  `craft_package_fetch` selbst ein. Kein Änderungswunsch; notiert, falls das öfter gebraucht
  wird.
- Aktueller Pin der Anwendungen: Sichttest `v0.3.4` (CS gehoben, LV steht auf v0.3.3).

## Befund: MSBuild-Warnung am Deploy-Ziel

**Meldung (CS 15:15, wörtlich aus der Nachricht):** „Die Remotebereitstellung ist möglicherweise
langsam/ineffizient. Ein Teil des Pfades …\comm_studio_deploy_sichttest.recipe konnte nicht
gefunden werden" (`Microsoft.CppBuild.targets(2630,5)`), je Bau, kopiert wird trotzdem.

**Was die Quellen sagen** (gelesen in
`…\Microsoft Visual Studio\18\Community\MSBuild\Microsoft\VC\v180\`):

- Zeile 2630 ist die Aufgabe `GenerateDesktopDeployRecipe` im Ziel `CreateRecipeFile`. Die
  Warnung entsteht also im Projekt der **Exe**, nicht im Deploy-Projekt: die Exe sammelt die
  `.recipe`-Dateien aller Projekte, auf die sie verweist (`Microsoft.CppBuild.targets:2628`).
- Ein verwiesenes Projekt nennt seine Recipe-Datei, sobald `DesktopDeployRecipeFile` gesetzt ist
  (`:1917`), ohne zu prüfen, ob sie existiert. Gesetzt ist sie, wenn
  `GenerateDesktopDeployRecipeFile` wahr ist (`:37`); das ist die Vorgabe für jedes Projekt ohne
  `ApplicationType` (`Microsoft.Cpp.Common.props:234`).
- Der Verweis der Exe auf das Deploy-Projekt kommt aus `add_dependencies`
  (`CMakeCraftPackage.cmake:402`); das Deploy-Projekt ist ein Utility-Projekt
  (`add_custom_target`, `:397`).
- Die Recipe-Datei dient der Fernbereitstellung beim Remote-Debuggen. Für das Kopieren neben
  die Exe hat sie keine Bedeutung — das deckt sich mit „kopiert wird trotzdem".

**Was nicht geklärt ist:** warum die Datei am genannten Ort fehlt. Auch Utility-Projekte
durchlaufen `CreateRecipeFile` (`:128`); nach den Quellen müsste das Deploy-Projekt seine Datei
also schreiben. „Ein Teil des Pfades" heißt, dass schon der Ordner fehlt. Den vollen Pfad kenne
ich nicht (in der Nachricht gekürzt), und die Probe-Bäume aus Session 5 unter `out/cc7/` sind
gelöscht. Ob dieselbe Warnung unter `Visual Studio 17 2022` kam, ist damit offen: in Session 5
habe ich sie nicht notiert, das belegt nicht, dass sie fehlte. Die Zeilen in den v170-Targets
sind dieselben (dort `:2601`).

**Kandidat für die Behebung, ungeprüft:** am Deploy-Ziel
`VS_GLOBAL_GenerateDesktopDeployRecipeFile` auf `false` setzen. Dann bleibt
`DesktopDeployRecipeFile` dort leer, das Projekt nennt keine Recipe-Datei, und die Exe hat
nichts zu suchen. Eine Zeile, wirkt nur unter den Visual-Studio-Generatoren. Trägt die
Annahme, dass die Eigenschaft aus dem Block `Globals` vor `Microsoft.Cpp.Common.props` gelesen
wird — das zeigt erst ein Bau.

**Entscheid Patrik (2026-10-10):** behoben wird in einer eigenen kleinen Version **v0.11.1**
(Paketdatei 1.1.1), in der nächsten CC-Sitzung, ohne weiteren Inhalt. CS tauscht die Kopie und
LV hebt den Pin, wann es passt. Vorbehalt aus der Vorlage: trägt der Kandidat in der Probe
nicht oder verlangt die Ursache einen Umbau des Deploy-Ziels, wird neu vorgelegt.

## Stolperfallen

- **Probe-Bäume gelöscht, Befund nicht nachprüfbar.** Der Report von Session 5 nannte
  `out/cc7/` „kann gelöscht werden"; die Bau-Ausgaben des VS-Generators fehlen jetzt für den
  Vergleich. Für die nächste Probe: das Bauprotokoll (`cmake --build … > datei`) neben die
  Skripte legen, nicht nur das Ergebnis notieren.
- **Hook-Bedarf:** keiner. Nichts von Hand durchgesetzt, kein Fehler zum zweiten Mal.

## Verifikation

- **Nichts gebaut, nichts gemessen.** Alle Aussagen zum Befund stammen aus den MSBuild-Dateien
  (mit Datei und Zeile oben) und aus `CMakeCraftPackage.cmake`; die Warnung selbst habe ich
  nicht gesehen.
- `git status` zu Beginn sauber.

## Offene Punkte / Plan für die nächste Session

1. **MSBuild-Warnung am Deploy-Ziel als v0.11.1** (Entscheid Patrik). Ablauf: Probeprojekt unter `out/` mit `Visual Studio 18 2026`, erst die Warnung nachstellen
   (Bauprotokoll sichern, vollen Pfad lesen), dann der Kandidat, dann Gegenprobe mit
   `Visual Studio 17 2022`, Ninja und Ninja Multi-Config.
2. **Die Kopie entfernt nichts** (unverändert aus Session 5); wird vor einem Wechsel von S bei
   SH entschieden.
3. Unverändert: Codes abgleichen, Altlasten der Modul-Doku, lange Pfade unter `projects/`,
   Bootstrap-Fehlschlag 128 bei SH, Bass-PreFetch-Hook, `CMakeUserPresets.json` →
   `.example`-Muster, Doku-Umzug Phase 2.
4. **Sync:** gestoppt. Die nächsten Abschnitte (Stufe 3 mit CS, Pin v0.3.4 bei LV) brauchen CC
   nur bei einem Befund am Bezug.

---

> **Hinweis zur Ablage:** Der Steckbrief deklariert Session-Reports, Handover und
> Changelog/Logbuch als „—". Dieser Report liegt wie die vorigen im Fallback-Pfad
> `docs/report/`; ein Handover wurde nicht angelegt.
