# CMakeCraft_Session8_2026-10-24_mp-testing-bigobj

> **Zeitraum:** 2026-10-23 (abends) bis 2026-10-24 · **Status:** abgeschlossen ·
> **Tests am Ende:** Selbsttest `craft-selftest` 10 von 10 PASSED (Configure Exit 0) auf dem Stand
> von `v0.13.1`
> **Basis:** `master` @ `85cf800` → `7915d6c` (v0.12.0) → `0e7335e` (v0.13.0) → `59328e1`
> (v0.13.1); alle drei Tags gepusht (Patrik)
>
> Gestartet aus der LumiViz-Sitzung 148 (Auftrag MP1 a). Sync `../sync_sichttest` (Prefix CC),
> Abschnitt „CMakeCraft v0.12.0", von SH auf Patriks Wort eröffnet und geleitet, mit LV und CS;
> am 24.10. 17:03 von SH gestoppt.

## Schwerpunkt

**Drei Fassungen, alle aus Befunden von LumiViz:** parallele Kompilierung unter MSVC (v0.12.0), die
Konfiguration `Testing` mit Flags und richtiger CRT (v0.13.0) und `/bigobj` (v0.13.1).

## Neu und geändert

### v0.12.0 — `/MP` aus `settings.msvc.parallel_compile` (Commit `7915d6c`)

- **Entscheid Patrik 1 a + 2 a:** Feld `settings.msvc.parallel_compile` in der `Solution.json`,
  nur global, kein Feld je Ziel. Ohne Eintrag gilt 8 (nach der Messung bestätigt), `0`/`1` = aus,
  ein ungültiger Wert ergibt E004.
- `Solution.cmake` 1.1.0 liest das Feld (`SOLUTION_MSVC_PARALLEL_COMPILE`);
  `CompilerOptions.cmake` 1.1.0 setzt `$<$<COMPILE_LANGUAGE:C,CXX>:/MP<n>>`, nur wenn
  `CMAKE_CXX_COMPILER_ID STREQUAL "MSVC"`. clang-cl setzt zwar `MSVC`, bleibt aber unberührt.
- Phase 2 prüft den Wert. Doku: `Solution_Schema` §4.4, `ErrorCodes` (E004), `Phase2_doc`,
  `Neues_Projekt_Guide`.

### v0.13.0 — `Testing` optimiert, Pflichtzeile `project()` (Commit `0e7335e`)

- **Befund (Frage von LV):** `Testing` baute ohne Optimierung **und mit statischer CRT `/MT`**. Die
  Exe importierte weder `MSVCP140` noch `VCRUNTIME140`; Qt lief daneben mit `/MD`.
  - F1: Weil `project()` aus der `Solution.json` kommt, fehlte im obersten `CMakeLists.txt` jedes
    literale `project()`. CMake setzt dann `project(Project)` vor `cmake_minimum_required` und
    richtet die Compiler nach alten Policies ein (`CMAKE_CXX_FLAGS_DEBUG` = `/MDd …`).
    `CMAKE_MSVC_RUNTIME_LIBRARY` griff nicht; Debug und Release stimmten nur über ihre
    Standard-Flags. Nachgestellt im Probeprojekt.
  - F2: CMake gibt einer eigenen Konfiguration keine Flags, also liefen `/Od` bzw. `-O0`.
  - `_DEBUG` (Vermutung von LV) gab es nicht; es war ein Treffer in `QT_NO_DEBUG`.
- **Entscheid Patrik TC1 a:**
  - Neues Modul `core/Configurations.cmake`: MSVC/clang-cl `/O2 /Ob1 /Zi`, Linker
    `/DEBUG /INCREMENTAL:NO`; GCC/Clang `-O2 -g`; kein `NDEBUG`. Gesetzt wird nur, wenn der Wert
    leer ist.
  - `CMakeCraft.cmake` verlangt die Zeile `project(<Name> LANGUAGES NONE)` im obersten
    `CMakeLists.txt`, sonst E005.
  - Eigene `CMakeLists.txt`, `templates/consumer/` und Anleitung ziehen nach.
- Doku: `CMakePresets` (was `Testing` ist), `ErrorCodes` (E005), `Phase2_doc` (Phase 2 prüft die
  Testing-Flags), `Neues_Projekt_Guide` 1.3.0.

### v0.13.1 — `/bigobj` (Commit `59328e1`)

- **Befund LV:** Testing-MSVC brach in `LumiViz.Core` mit C1128 ab. `/O2` schließt `/Gy` ein, und
  zusammen mit `/Zi` reißen große Dateien die Grenze von 2^16 Abschnitten je .obj.
- **Entscheid Patrik BG1 a:** `/bigobj` für alle MSVC-Ziele in jeder Konfiguration, in
  `apply_compiler_options` neben `/MP` (`CompilerOptions.cmake` 1.2.0). Doku: `CMakePresets` 1.1.1.

## Verifikation

- **Selbsttest:** 10 von 10 nach jeder Fassung. Seit v0.13.0 läuft er ohne Dev-Warnung, und
  `Testing` hat `-O2 -g`.
- **Probeprojekte unter `out/`** (danach gelöscht):
  - VS 18: `/MP` 16, 8 und aus; E004 bei ungültigem Wert. Unter Clang/Ninja kein `/MP`.
  - VS 17 2022: ohne Zeile E005; mit Zeile hat `Testing` `MaxSpeed`, `MultiThreadedDLL` und eine
    PDB, die Exe importiert `MSVCP140`/`VCRUNTIME140`. `/bigobj` in allen drei Konfigurationen.
- **Messung an LumiViz** (Testing-MSVC, voller Neubau `LumiViz.UnitTests`, mit
  `CMAKECRAFT_LOCAL_DIR`, danach wieder auf den Pin konfiguriert, dort nichts geändert):

  | Lauf | Zeit | RAM belegt vorher → Spitze (31 GB) | alle cl.exe zusammen |
  |---|---|---|---|
  | ohne `/MP` (LumiViz S148) | 880 s | – | – |
  | `CL=/MP8` (LumiViz S148) | 186 s | – | – |
  | v0.12.0, `/MP8` | 244 s | 12,8 → 21,4 GB | 7,7 GB |
  | v0.12.0, `/MP16` | 204 s | 15,9 → 25,3 GB | 10,1 GB |

  Die beiden v0.12.0-Läufe sind nicht streng vergleichbar, weil LV parallel weiterarbeitete.
  qt-ads und miniz bekommen kein `/MP`; das erklärt vermutlich einen Teil des Abstands zu
  `CL=/MP8`.
- **Bei LV bestätigt (v0.13.1):** Release-clang und Testing-MSVC bauen; Testing hat `MaxSpeed`,
  `/MD` und `/bigobj`. *Loop Körper* 41/41 in 44 s (Release-clang 17 s). Ein Neubau der Unit-Tests
  in Testing-MSVC dauert jetzt 11 min 44 s.
- **Bei SH bestätigt (v0.13.1):** Zeile gesetzt, `--fresh`, alles gebaut, Selbsttest grün, Pin
  committet (`f46392d`). CS ist nicht betroffen.

## Stolperfallen

- **`--fresh` verliert `CMAKE_MAKE_PROGRAM`.** Ninja liegt nicht im PATH; nach `--fresh` fand CMake
  es nicht mehr, bei CC (Selbsttest) und bei SH. Abhilfe: `-DCMAKE_MAKE_PROGRAM`. Steht schon in
  `CLAUDE.md`.
- **PowerShell 5.1 mit `ErrorActionPreference = Stop`** wertet die erste CMake-Warnung auf stderr
  als Abbruch. Der erste Messlauf brach so ab; danach liefen die Läufe über `Start-Process`.
- **`sync_post.ps1 -An` nimmt nur einen Empfänger oder `alle`**, `-CC` dagegen eine Liste.
  `-An 'SH,CS'` wurde abgelehnt.
- **Gestoppter Sync lehnt jede Nachricht ab.** Der Auftrag „Nachricht ablegen, ohne den Sync zu
  starten" war so nicht ausführbar; Patrik entschied, dass SH einen Abschnitt eröffnet.
- **Zeilenenden:** `CMakePresets.md` lag nach Patriks Commit von v0.13.0 als LF in der
  Arbeitskopie (Repo `* text=auto`, `core.autocrlf=true`). Ohne Folge, der Diff zeigt nur die
  geänderten Zeilen.
- **Hook-Bedarf:** keiner. Die Sperre gegen Backslashes im Heredoc griff zweimal und wurde, wie sie
  es verlangt, über das Edit-Werkzeug umgangen. Kein Fehler kam zum zweiten Mal vor.

## Sync

- Nachrichten von CC: Info v0.12.0 (`CC-20261024-1053`), Befund `Testing` (`-1350`), Frage an SH/CS
  (`-1415`), Antwort C1128 (`-1535`), Tags v0.13.0/v0.13.1 (`-1455`, `-1619`) und Leerlauf.
  2237 von 4000 Token.
- `STATUS.md`, Hälfte CC: auf den Stand v0.13.1 gebracht, neue Punkte CC-12 bis CC-14 (erledigt).
- Den Abschnitt hat SH am 24.10. 17:03 gestoppt.

## Offene Punkte / Plan für die nächste Session

1. **Bauzeit Testing-MSVC:** Ein Neubau der Unit-Tests dauert jetzt 11 min 44 s. Kandidat ist die
   PCH für Test-Ziele (bei LV vorgemerkt, einzeln vorzulegen).
2. **CC-8, Bootstrap:** unverändert; erst mit einer mitgeschriebenen Fehlerzeile angehen.
3. **Die Kopie entfernt nichts** (aus Session 5), unverändert.
4. **`ENABLE_TESTING_CONFIG`** steht in den Presets, wird in `cmake/` aber nirgends gelesen.
   Aufräumen oder belegen.
5. Unverändert: lange Pfade unter `projects/`, Bass-PreFetch-Hook, `CMakeUserPresets.json` →
   `.example`-Muster, Doku-Umzug Phase 2.

---

> **Hinweis zur Ablage:** Der Steckbrief deklariert Session-Reports, Handover und
> Changelog/Logbuch als „—". Dieser Report liegt wie die vorigen im Fallback-Pfad
> `docs/report/`. Der Changelog steht im Kopf von `CMakeCraft.cmake` und ist mit den drei
> Commits nachgezogen.
