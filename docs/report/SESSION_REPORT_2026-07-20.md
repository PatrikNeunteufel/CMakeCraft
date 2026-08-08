# CMakeCraft_Session1_2026-07-20

> **Zeitraum:** 2026-07-20 · **Status:** abgeschlossen ·
> **Tests am Ende:** Selbsttest `craft-selftest` **grün** (Phasen 1–9 PASSED,
> Configure ohne Fehler) · Positiv-/Negativtest des neuen Pfads verifiziert
> **Basis:** `master` @ `340ac53` (= Tag `v0.7.1`) · **Feature committet als
> `602a96f`** (`feat: dependencies-Array für App-Test-Targets + Doku-Abgleich`) ·
> **empfohlener Tag: `v0.7.2` auf `602a96f`**

## Schwerpunkt

**App-Test-Targets lesen und linken ihr `dependencies`-Array.** Befund aus
LumiViz-Session 33: pro Test-Target in `apps[].tests.targets[]` deklarierte
`dependencies` (interne Libraries) wurden beim Collect gar nicht gelesen und
folglich nie gelinkt — Tests erreichten Libs nur transitiv als PUBLIC-Dependency
von `{App}.Core`. Ursache + Fix umgesetzt, verifiziert und Doku (Schema +
Modul-Doku, de=SSOT/en) nachgezogen.

## Neu

- **`tests.targets[].dependencies`** wird jetzt unterstützt (vorher stiller
  No-Op-Key):
  - [`cmake/project/AppCollect.cmake`](../../cmake/project/AppCollect.cmake) liest
    das Array pro Test-Target und legt es als Context-Key
    `TESTS_TARGET_{n}_DEPENDENCIES` ab (gleiches Muster wie `externals` direkt
    daneben).
  - [`cmake/project/AppCreate.cmake`](../../cmake/project/AppCreate.cmake):
    `_create_app_test_target` bekommt einen neuen Parameter `DEPENDENCIES` und
    linkt jede interne Library **`PRIVATE`** mit **E101**-Prüfung — exakt analog
    `TestCreate.cmake:259-265`. Zusätzlich zu `{App}.Core`, d. h. Tests hängen
    nicht mehr davon ab, dass die Lib zufällig PUBLIC am Core klebt.

## Geändert

- **Referenz-Doku** [`Solution_Schema.md`](../de/guide/references/Solution_Schema.md)
  (de + [en](../en/guide/references/Solution_Schema.md)): `dependencies`-Zeile in
  §9.8 (tests.targets[]-Objekt), **E101** in §12.4 (App-Tests-Fehler),
  Changelog-Eintrag **0.7.3**.
- **Modul-Doku** [`AppCollect.md`](../de/guide/module/project/AppCollect.md)
  (de + [en](../en/guide/module/project/AppCollect.md)): §5.5/§5.6 auf den
  aktuellen `tests.targets[]`-Stand gebracht — echte `TESTS_TARGET_{n}_*`-Keys
  (inkl. neuem `DEPENDENCIES`) statt des alten, nie implementierten
  `tests.unit`/`tests.integration`-Schemas; Beispiel 6.2 umgestellt; Fehlerliste
  §7 korrigiert. Changelog **0.7.3**.
- **Demo-Solution** [`Solution.json`](../../Solution.json): `MyVisualizer.UnitTests`
  bekommt `"dependencies": [ "BasicLogger" ]`, damit der Selbsttest den neuen
  Pfad dauerhaft ausübt.

## Stolperfallen

- **Doku-Divergenz aufgedeckt:** Die Modul-Doku `AppCollect.md` §5.5 beschrieb
  noch das `tests.unit`/`tests.integration`-Schema von **vor v0.6.0** — das seit
  v0.6.0 implementierte `targets[]`-Array fehlte komplett. Beim Abgleich fiel
  außerdem auf, dass die Doku für `_collect_app` **E401** nannte, der Code aber
  **E400** wirft (E401 kommt aus `Apps.cmake`). Beides korrigiert.
- **`framework`-Default:** Doku sagte „Default `doctest`", der Code lässt
  `TESTS_FRAMEWORK` aber **leer** und löst erst in AppCreate auf
  (per-Target > global > E301). Auf den Code-Stand gebracht.
- **PowerShell/BOM:** `Set-Content -Encoding utf8` schob beim Test-Roundtrip ein
  BOM in `Solution.json` — mit `UTF8Encoding($false)` wieder entfernt; finaler
  Diff ist BOM-frei.
- **Zwei Arbeitskopien:** Bearbeitet wurde zunächst im Session-Worktree
  (`.claude/worktrees/practical-franklin-d2147d`, Branch
  `claude/practical-franklin-d2147d`); Änderungen anschließend per `git apply`
  byte-identisch in die Haupt-Arbeitskopie übertragen (dort committet Patrik).

## Verifikation

- **Selbsttest** `cmake --preset craft-selftest` (Ninja Clang Debug,
  `RUN_BUILD_SYSTEM_TESTS=ON`; Ninja/Clang aus der VS-18-Installation in den PATH
  gelegt): **alle 9 Phasen PASSED**, „Configuring done", Exit 0.
- **Positivfall:** `BasicLogger` (INTERFACE-Lib) taucht in den Include-Pfaden des
  `MyVisualizer.UnitTests`-Objekts in `build.ninja` auf.
- **Negativfall:** erfundene Dependency am App-Test-Target bricht Configure sauber
  ab mit `[E101] Dependency 'AppTestBogusDep' for test 'MyVisualizer.UnitTests'
  does not exist` (Call-Stack: AppCreate.cmake → Apps.cmake). Danach zurückgesetzt.
- **Kein Code-Rebuild nötig** für die Doku-Nachträge (nur Markdown).

## Offene Punkte / Plan für die nächste Session

1. **Tag** (macht Patrik): Der Feature-Commit ist bereits als `602a96f` gelandet;
   noch offen ist nur das Tag `v0.7.2` darauf (klein, additiv, abwärtskompatibel
   — bestehende Solution.json bauen unverändert) sowie das Committen dieses
   Reports (`docs/report/SESSION_REPORT_2026-07-20.md`).
2. **LumiViz konsumieren:** nach dem Tag in LumiViz `cmakecraft.pin` auf `v0.7.2`
   bumpen; dann greifen dort die `dependencies` von `EelTranspiler`/`AvsParser`
   an den App-Test-Targets direkt (statt nur transitiv). → Thema für die nächste
   LumiViz-Session.
3. **Doku-Versionsserien:** Die Doku-Changelogs (`0.7.3`) laufen bewusst getrennt
   von den Repo-Tags (`v0.7.2`), weil die Schema-Doku intern schon einen
   0.7.2-Eintrag hatte. Falls Patrik Tag- und Doku-Serie synchronisieren will,
   die zwei Changelog-Einträge auf die Tag-Wahl anpassen.

---

> **Hinweis zur Ablage:** Der CMakeCraft-Steckbrief deklariert Session-Reports
> als „—" (Entwicklung läuft normal aus LumiViz heraus). Dieser Report liegt daher
> im Skill-**Fallback**-Pfad `docs/report/`. Das eigentliche Session-Tracking der
> Produktarbeit bleibt in LumiViz (`.claude/sessions/`, Session 33 = Auslöser).
