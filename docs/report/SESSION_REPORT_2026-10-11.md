# CMakeCraft_Session7_2026-10-11_msbuild-warnung-deploy-ziel

> **Zeitraum:** 2026-10-11 (abends) · **Status:** abgeschlossen ·
> **Tests am Ende:** Selbsttest `craft-selftest` 10 von 10 PASSED (Configure Exit 0), gelaufen
> auf dem Stand, der als `4ce24ca` committet ist
> **Basis:** `master` @ `ba74707` → `4ce24ca` · Tag `v0.11.1` @ `4ce24ca`, gepusht (Patrik)
>
> Sync `../sync_sichttest` (Prefix CC), Abschnitt „CMakeCraft v0.11.1: MSBuild-Warnung am
> Deploy-Ziel", von SH eröffnet und geleitet, mit CS; LV las mit.

## Schwerpunkt

**v0.11.1: die MSBuild-Warnung am Deploy-Ziel nachgestellt, ihre Ursache gefunden und behoben.**
Die Ursache ist eine andere, als der Report von Session 6 aus den Quellen geschlossen hatte.

## Befund und Ursache

- **Im schlichten Projekt kommt die Warnung nicht.** Probeprojekt unter `out/v0111/`,
  `Visual Studio 18 2026`: das Deploy-Projekt schreibt seine Recipe-Datei nach
  `<Projektordner>\x64\<Config>\<Ziel>\`, auch mit der Exe im Unterordner und mit `--target App`.
- **Auslöser ist die `Directory.Build.targets` des Comm Studio** (`UART/CMakeLists.txt:73–88`),
  die `IntDir` umleitet. MSBuild legt den Pfad der Recipe-Datei aus `IntDir` fest
  (`Microsoft.CppBuild.targets:37`, `$(IntDirFullPath)$(TargetName)$(TargetExt).recipe`), bevor
  `Directory.Build.targets` gelesen wird. Danach gilt das umgeleitete `IntDir`; nur dessen
  Ordner wird angelegt. Mit einer Datei nach dem Muster von CS kommt die Warnung im
  Probeprojekt je Bau, wortgleich (`Microsoft.CppBuild.targets(2630,5)`).
- **Berichtigung zu Session 6:** die Warnung entsteht im Deploy-Projekt selbst, nicht im Projekt
  der Exe. CS hatte das Projekt in `CS-20261010-1854` schon richtig genannt.
- CS nimmt in der Bedingung der Umleitung `ZERO_CHECK`, `ALL_BUILD`, `INSTALL`, `PACKAGE` und
  `RUN_TESTS` aus demselben Grund aus.

## Geändert (Commit `4ce24ca`)

- **`CMakeCraftPackage.cmake` 1.1.1:** `craft_package_deploy` setzt am Deploy-Ziel
  `VS_GLOBAL_GenerateDesktopDeployRecipeFile "false"` (`:408–413`). Sonst unverändert.
- **`CMakeCraft.cmake`:** Version 0.11.1, Changelog.
- **`cmake/buildSystemTest/phase10.cmake`:** Test 7 prüft die Eigenschaft am Deploy-Ziel.
- **Doku de/en:** `guide/module/CMakeCraftPackage.md` (Absatz zum Deploy-Target, Changelog,
  1.1.1), `guide/module/buildSystemTest/Phase10_doc.md` (1.1.1).
- Im selben Commit: der Report von Session 6 (`SESSION_REPORT_2026-10-10.md`).
- **Lokal, nicht versioniert:** `CLAUDE.md` („Ausstehend": v0.11.1, Werkzeuge für Proben).

**Entscheid Patrik (2026-10-11):** Option a — die Behebung bleibt in CMakeCraft (v0.11.1), obwohl
die Ursache im Aufbau des Comm Studio liegt. Grund: unsere Datei legt das Ziel an und benennt es;
sonst müsste jedes Projekt mit einer solchen Umleitung den Namen kennen und ausnehmen.

## Verifikation

Probeprojekt `out/v0111/proj2` (Exe im Unterordner), je zwei Bauten, **nur Debug**:

| Generator | `IntDir`-Umleitung | Warnung am Deploy-Ziel | Kopie neben der Exe |
|---|---|---|---|
| Visual Studio 18 2026 (CMake 4.3.1) | ja | vorher je Bau, mit 1.1.1 keine | ja |
| Visual Studio 18 2026 | nein | keine | ja |
| Visual Studio 17 2022 (CMake 4.1.2) | ja | keine | ja |
| Visual Studio 17 2022 | nein | keine | ja |
| Ninja (clang) | – | keine | ja |
| Ninja Multi-Config (clang) | – | keine | ja |

- Selbsttest 10 von 10 (`out/v0111/selftest.log`).
- **Bei CS bestätigt** (`CS-20261011-1843-…`, gegen den Tag, `Visual Studio 18 2026`): Zeilen mit
  `recipe` vorher je eine in Debug und Release, nachher keine; DLL und `sichttest\` neben beiden
  Exen gleich dem Paket; gelöschte DLL und Tester kommen beim Bau wieder.
- **Bei SH:** Pin auf `v0.11.1`, Build und Selbsttest dort Exit 0 (`SH-20261011-1844-…`).
- **Nicht gesehen:** bei CC Release und die Pin-Wechsel-Folge aus Session 5 (nur: das Deploy-Ziel
  läuft beim zweiten Bau wieder); bei CS der Tausch der Paketdatei ohne neues Configure; LV.
- **Nebenbefund:** unter `Visual Studio 17 2022` mit Umleitung warnt die Exe selbst
  (`App.dir\Debug\App.exe.recipe`). Kommt aus der Umleitung, nicht aus unserem Ziel; ein
  Vorher-Lauf unter VS 17 fehlt.

Bauprotokolle: `out/v0111/` (`vs18-dbt-build1-vorher.log` mit Warnung, `nach-*.log` ohne).
`out/` ist gitignored; die Protokolle bleiben liegen, bis jemand sie nicht mehr braucht.

## Stolperfallen

- **Aus den Quellen geschlossen, falsch eingeordnet.** Session 6 las die MSBuild-Dateien und
  schloss auf das Projekt der Exe; der erste Bau zeigte, dass die Warnung ohne die Umleitung gar
  nicht kommt. Die Ursache lag in einer Datei des Konsumenten, die im Bauverzeichnis liegt und
  im Probeprojekt fehlt. Lehre: bei einem Befund aus einem fremden Projekt zuerst dessen
  Bauverzeichnis ansehen (`Directory.Build.*`, Cache), bevor ein eigenes Probeprojekt gilt.
- **`out/cc7/` war nicht gelöscht**, anders als Session 6 schrieb; nur die Bauverzeichnisse
  fehlten. Probeprojekt und Skripte waren da und wurden wiederverwendet.
- **Das CMake im PATH (4.1.2) kennt `Visual Studio 18 2026` nicht**, und Ninja liegt nicht im
  PATH. Für Proben: CMake und Ninja aus
  `…\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\`
  (`-DCMAKE_MAKE_PROGRAM` für Ninja). Steht jetzt in `CLAUDE.md`.
- **Der Tag fiel vor der Messung bei CS.** SH hatte den Abschnitt mit „erst messen, dann taggen"
  eröffnet, während Patrik bei CC schon getaggt hatte. Ohne Folge, weil die Messung trägt; in der
  Nachricht an CS als Abweichung genannt.
- **Hook-Bedarf:** keiner. Zwei vorhandene Sperren griffen (Backslash im Heredoc, `rm -rf` mit
  Variable) und wurden umgangen, wie sie es verlangen; kein Fehler zum zweiten Mal.

## Sync

- Nachricht an CS mit Ursache, Änderung, Gegenprobe und Auftrag (`CC-20261011-1842-…`), Leerlauf
  mit Ergebnis (`CC-20261011-1844-…`), 902 von 4000 Token.
- `STATUS.md`, Hälfte CC: auf v0.11.1 gebracht, neuer Punkt CC-11 (erledigt, bei CS bestätigt),
  CC-8 um die Beobachtung von SH ergänzt.
- Abmeldung mit `abschluss/2026-10-11-CC.md`; den Sync stoppt SH, wenn alle vier abgemeldet sind
  (Anweisung Patrik, `SH-20261011-1850-…`).

## Offene Punkte / Plan für die nächste Session

1. **CC-8, Bootstrap:** zweite Beobachtung bei SH (erster Configure nach dem Pin-Wechsel auf
   `v0.11.1` Exit 1, Ordner lag danach da, zweiter aus dem Cache; ohne Fehlerzeile, nicht
   reproduziert). Erst mit einer mitgeschriebenen Fehlerzeile angehen.
2. **Die Kopie entfernt nichts** (unverändert aus Session 5); wird vor einem Wechsel von S bei SH
   entschieden.
3. Unverändert: Codes abgleichen, Altlasten der Modul-Doku, lange Pfade unter `projects/`,
   Bass-PreFetch-Hook, `CMakeUserPresets.json` → `.example`-Muster, Doku-Umzug Phase 2.
4. Nicht bei CC: LV hebt `cmakecraft.pin` auf `v0.11.1`; Commits bei CS (Paketdatei) und SH (Pin)
   macht Patrik.

---

> **Hinweis zur Ablage:** Der Steckbrief deklariert Session-Reports, Handover und
> Changelog/Logbuch als „—". Dieser Report liegt wie die vorigen im Fallback-Pfad
> `docs/report/`; ein Handover wurde nicht angelegt.
