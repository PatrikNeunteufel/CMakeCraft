# Konzept: Versionierter CMakeCraft-Bezug für Konsumenten-Projekte

> **Version:** 1.0.0
> **Datum:** 2026-07-18
> **Typ:** Concept
> **Status:** Entwurf — Entscheidung ausstehend
> **Bezug:** LumiViz-Umbauplan Phase 1; Neues_Projekt_Guide.md §5 (heutiger manueller Sync)

---

## 1. Ziel

Konsumenten-Projekte (LumiViz, künftige) sollen das Build-System **nicht mehr als kopierten
Snapshot** tragen, sondern **versioniert beziehen**: Das Projekt deklariert nur noch *welche
CMakeCraft-Version* es will; Divergenz wird technisch unmöglich statt nur verboten.

## 2. Tiefenanalyse: Ist-Kopplung (Messung vom 2026-07-18)

Untersucht: alle Pfad-Annahmen in `cmake/**` und `CMakeLists.txt` (Stand a98ff3a).

| Kopplung | Fundstellen | Bewertung |
|---|---|---|
| `${CMAKE_SOURCE_DIR}/cmake/…` (Ort des Build-Systems) | **6**: HookLoader.cmake:39/40, Orchestrator.cmake:238, local/Attach.cmake:86, system/Handler.cmake:99, phase9.cmake:395 | **einzige echte Ortskopplung** — muss auf Variable umgestellt werden |
| `include(cmake/…)` in CMakeLists.txt | ~24 Zeilen (9 core, 6 project, 9 buildSystemTest) | wandert in einen Entry-Point innerhalb CMakeCrafts |
| `${CMAKE_SOURCE_DIR}/Solution.json`, `projects/`, `externals/`, `.externals/`, `.clang-*` | ~41 | **korrekt projektbezogen** — bleibt unverändert |

**Fazit:** Nur 6 Pfade + 1 Include-Block sind ortsgebunden. Das Build-System ist fast schon
relocatable; benötigt wird eine Variable `CMAKECRAFT_DIR` + ein Entry-Point.

## 3. Schritt A (Voraussetzung, optionsunabhängig): CMakeCraft relocatable machen

1. **Entry-Point `CMakeCraft.cmake`** im CMakeCraft-Root:
   - setzt `CMAKECRAFT_DIR = ${CMAKE_CURRENT_LIST_DIR}` (selbst-lokalisierend),
   - übernimmt alle heutigen Includes aus der Top-Level-CMakeLists (core → Solution → project()
     → Externals/Libraries/Executables/Apps/Tests → optional buildSystemTest),
   - Konsument ruft eine Funktion/ein Include — Reihenfolge bleibt intern gekapselt.
2. Die **6 harten Pfade** von `${CMAKE_SOURCE_DIR}/cmake/…` auf `${CMAKECRAFT_DIR}/…` umstellen.
3. CMakeCrafts **eigene CMakeLists.txt nutzt den Entry-Point** (Dogfooding: CMakeCraft ist
   selbst Konsument Nr. 0, `CMAKECRAFT_DIR = <root>/cmake`).
4. Verifikation: `craft-selftest` grün; Demo-Solution baut.
5. **Tag `v0.7.0`** = erste relocatable Version.

Projektbezogene Pfade (`Solution.json`, `projects/`, `externals/`, `.externals/`) bleiben
bewusst am `CMAKE_SOURCE_DIR` — das ist der Vertrag „Projekt liefert Solution, CMakeCraft baut".

## 4. Bezugs-Optionen (Entscheidung)

### Option B — Bootstrap-Fetch (Empfehlung) 🏆

Committet im Projekt sind nur zwei kleine Dinge:
- `cmakecraft.pin` (o. ä.): `v0.7.0` + Repo-URL(s)
- `bootstrap.cmake` (~40 Zeilen, stabil): prüft `.externals/cmakecraft/<version>`; wenn fehlt →
  `git clone --depth 1 --branch <tag>` von GitHub (Fallback: lokaler Pfad, z. B.
  Geschwister-Checkout `../CMakeCraft`); dann `include(…/CMakeCraft.cmake)`.

| Pro | Contra |
|---|---|
| exakt die Philosophie der eigenen Git-Externals (Tag-Pin → `.externals/`) | erster Configure braucht Netz **oder** den lokalen Fallback |
| kein Submodule-Handling (VS-transparent, kein `--recurse`, kein Detached-HEAD) | Bootstrap-Datei ist ein Mini-Snapshot (klein halten!) |
| Versionswechsel = 1 Zeile in `cmakecraft.pin` ändern | |
| mehrere Projekte teilen denselben Mechanismus | |

### Option A — Git-Submodule

`git submodule add <url> cmakecraft/` im Projekt; CMakeLists inkludiert
`cmakecraft/CMakeCraft.cmake`.

| Pro | Contra |
|---|---|
| Pin per Gitlink (kein eigener Mechanismus) | Submodule-Reibung: `clone --recurse-submodules`, vergessene `submodule update`, Detached-HEAD-Verwirrung |
| offline nach dem Klonen | VS-Submodule-Support ist rudimentär |
| | Historie zeigt nur Hashes, keine sprechende Version |

### Option C — Status quo formalisiert (Zwischenlösung, läuft bereits)

Spiegel-Sync + `BUILDSYSTEM_VERSION.md` + Guide §5. Kein Aufwand, aber Divergenz bleibt
menschlich möglich. Bleibt der definierte **Rollback-Zustand**.

## 5. Schritt B: LumiViz-Migration (bei Option B)

1. Branch `phase1-buildsystem-bezug` in LumiViz.
2. `bootstrap.cmake` + `cmakecraft.pin` (= `v0.7.0`) hinzufügen; CMakeLists.txt →
   Dünnfassung (~15 Zeilen: cmake_minimum_required, Optionen, Bootstrap-Include).
3. `cmake/`-Ordner **löschen** (git rm) — er kommt fortan aus `.externals/cmakecraft/`.
4. `BUILDSYSTEM_VERSION.md` löschen (ersetzt durch `cmakecraft.pin`);
   Guide §5 umschreiben: „Sync" = Tag-Bump im Pin (+ Notfall-Weg: Pin auf Branch/Commit).
5. `templates/`, `clang-format/-tidy`, Presets bleiben Projektkopien (wie Guide §6).

## 6. Verifikation (Abnahmekriterien)

- CMakeCraft: `craft-selftest` grün (CLI) · Demo-Solution baut (VS).
- LumiViz: Configure+Build **VS-IDE und CLI**, MyViz startet · zweiter Configure **offline**
  (Cache-Fallback greift) · Fallback „kein Netz + kein Cache" liefert verständliche
  Fehlermeldung mit Anleitung.
- `git status` beider Repos sauber; frischer LumiViz-Klon auf leerem Verzeichnis baut
  (BASS-Binaries gemäß SETUP.md vorausgesetzt).

## 7. Rollback

Migration läuft auf Branch; `master` behält den funktionierenden Snapshot-Stand (Option C).
Rollback = Branch verwerfen. Nach Merge: Rollback = Revert-Commit; der alte Zustand ist
vollständig in der Historie.

## 8. Aufwandsschätzung

| Schritt | Umfang |
|---|---|
| A: Entry-Point + 6 Pfade + Dogfooding + Selftest | ~2–3 h konzentrierte Arbeit |
| B: Bootstrap + LumiViz-Dünnfassung + Doku | ~1–2 h |
| Verifikation beider Repos (beide Wege) | ~1 h |

## 9. Anschlussthemen (nicht Teil dieses Konzepts)

- Bass-PreFetch-Hook (automatischer Binaries-Download von un4seen)
- `CMakeUserPresets.json` → `.example`-Muster (aktuell committet mit lokalen Pfaden)
- Build-System-Doku-Umzug LumiViz→CMakeCraft (Phase 2)
