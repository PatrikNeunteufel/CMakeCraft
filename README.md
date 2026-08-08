# CMakeCraft

**Ein modulares CMake-Build-System, das seine Solution aus einer JSON-Datei baut.**

Statt CMake-Code über ein Dutzend `CMakeLists.txt` zu verteilen, beschreibt ein
Projekt in **einer** `Solution.json`, woraus es besteht — Bibliotheken,
Programme, App-Container, Tests, Abhängigkeiten und externe Bibliotheken.
CMakeCraft liest das und erzeugt daraus die Targets.

Die Top-Level-`CMakeLists.txt` eines Projekts schrumpft dabei auf zwei Zeilen:

```cmake
cmake_minimum_required(VERSION 3.25)
include("${CMAKE_CURRENT_LIST_DIR}/CMakeCraftBootstrap.cmake")
```

> **Status:** in aktiver Entwicklung, Einzelentwickler-Projekt. Die API
> (`Solution.json`-Schema) ist noch nicht eingefroren; Versionen sind als
> Git-Tags markiert, damit Projekte auf einem festen Stand bleiben können.

---

## Wofür das gut ist

Gewachsene Build-Systeme haben ein wiederkehrendes Muster: die Definition eines
Targets liegt an drei Stellen, niemand weiß mehr, warum ein Include-Pfad gesetzt
ist, und ein neues Programm anzulegen heißt, eine bestehende `CMakeLists.txt` zu
kopieren und zu hoffen.

CMakeCraft dreht das um:

- **Eine Quelle der Wahrheit.** Was nicht in `Solution.json` steht, existiert
  nicht. Targets, Abhängigkeiten, Externals und Testläufe stehen an einer Stelle
  und lassen sich am Stück lesen.
- **Verständliche Fehler statt CMake-Rauschen.** Fehler haben nummerierte Codes
  mit erklärendem Text — `E104 Source.cmake not found (mode=explicit)` statt
  einer Fehlermeldung aus dem Generator-Innenleben.
  Referenz: [ErrorCodes.md](docs/de/guide/references/ErrorCodes.md).
- **Ein Weg für externe Bibliotheken**, egal woher sie kommen: lokal im
  Projektordner, per `git clone` beim Konfigurieren, oder aus einer
  Systeminstallation über `find_package`.
- **Explizite Quelldatei-Listen.** Es wird bewusst nicht geglobbt: eine neue
  Datei wird eingetragen. Dafür merkt der Build, wenn eine Datei verschwindet.
- **Wiederverwendbar über Projekte hinweg.** Das Build-System liegt nicht im
  Projekt, sondern wird versioniert bezogen (siehe unten).

Hauptplattform ist Windows (MSVC, Clang-CL, Ninja); Linux (GCC/Clang) und macOS
sind vorgesehen und in den Presets abgebildet, werden aber nicht regelmäßig
durchgebaut.

---

## In ein Projekt einbinden

Drei Dateien in den Projekt-Root kopieren — Vorlagen liegen unter
[`templates/consumer/`](templates/consumer/):

| Datei | Zweck |
|---|---|
| `CMakeCraftBootstrap.cmake` | holt CMakeCraft in der gepinnten Version, unverändert übernehmen |
| `cmakecraft.pin` | **die** Versionsangabe — ein Git-Tag plus Bezugsquellen |
| `CMakeLists.txt` | die zwei Zeilen von oben |

`cmakecraft.pin` ist der einzige Ort, an dem die Build-System-Version steht:

```cmake
set(CMAKECRAFT_VERSION "v0.9.0")
set(CMAKECRAFT_GIT_URL "https://github.com/PatrikNeunteufel/CMakeCraft.git")
set(CMAKECRAFT_FALLBACK_PATHS "../CMakeCraft")
```

Beim ersten Konfigurieren klont CMake diesen Tag nach
`.externals/cmakecraft/v0.9.0/` und lädt von dort den Entry-Point
`CMakeCraft.cmake`. Danach liegt alles im Cache und der Build ist offlinefähig.
**Ein Versionswechsel ist eine geänderte Zeile im Pin** — kein Kopieren, kein
Abgleichen, kein Submodule.

Wer am Build-System selbst arbeitet, umgeht Pin und Cache:

```bash
cmake --preset <preset> -DCMAKECRAFT_LOCAL_DIR=../CMakeCraft
```

Dann kommt CMakeCraft direkt aus der Arbeitskopie.

**Vollständige Anleitung für ein neues Projekt:**
[docs/de/guide/userguides/Neues_Projekt_Guide.md](docs/de/guide/userguides/Neues_Projekt_Guide.md)

---

## So sieht eine Solution aus

```jsonc
{
  "schemaVersion": "1.0",
  "solution": { "name": "MeinProjekt", "version": "0.1.0" },
  "settings": {
    "standards": { "cxx_standard": 20 },
    "sources":   { "mode": "explicit" }
  },

  "externals": {
    "doctest": { "path": "externals/doctest" },
    "glfw":    { "git": "https://github.com/glfw/glfw.git", "tag": "3.4" },
    "qt6":     { "system": true, "package": "Qt6", "components": ["Core", "Widgets"] }
  },

  "libraries": [
    { "name": "BasicLogger", "type": "INTERFACE",
      "public_headers": "projects/libs/BasicLogger/include" }
  ],

  "executables": [
    { "name": "MeinTool", "path": "projects/exec/MeinTool/src",
      "dependencies": ["BasicLogger"], "externals": ["glfw"] }
  ]
}
```

Die drei Externals-Zeilen zeigen die drei Bezugswege: **lokal**, **git**,
**System**. Dazu kommen App-Container (`apps`) — Kern-Bibliothek, Runner,
Tests und Precompiled Header als eine Einheit — und eigenständige Test-Targets
(`tests`) für doctest, GoogleTest und Catch2.

Alle Felder: [Solution_Schema.md](docs/de/guide/references/Solution_Schema.md) ·
Kurzfassung: [Solution_Cheatsheet.md](docs/de/guide/cheatsheets/Solution_Cheatsheet.md)

---

## Dieses Repository ausprobieren

CMakeCraft baut sich selbst — die eigene `CMakeLists.txt` ist genau die
Dünnfassung, die auch ein Konsument schreibt, und die mitgelieferte
`Solution.json` ist eine Demo-Solution mit Bibliothek, Programmen, App-Container
und Tests.

```bash
git clone https://github.com/PatrikNeunteufel/CMakeCraft.git
```

```bash
cmake --preset craft-selftest
```

Das Preset konfiguriert mit `RUN_BUILD_SYSTEM_TESTS=ON` und lässt dabei die
**Phasentests 1–9** mitlaufen: neun Prüfungen, die das Build-System an sich
selbst durchmisst — JSON-Auswertung, Target-Erzeugung, Externals, App-Container,
Tests. Läuft das Konfigurieren fehlerfrei durch, ist das Build-System gesund.
Einzelne Phase: zusätzlich `-DTEST_PHASE=5`.

> **Zwei Demo-Programme brauchen BASS.** `MinimalConsole` und `consolePlayer`
> linken gegen die proprietäre Audio-Bibliothek BASS, die nicht mitgeliefert
> werden darf. Das **Konfigurieren** und die Phasentests laufen ohne sie; erst
> ein vollständiger `cmake --build` bricht ab. Wer die beiden bauen will:
> [`externals/bass/SETUP.md`](externals/bass/SETUP.md). Wer sie nicht braucht,
> setzt sie in `Solution.json` auf `"skip": true`.

Weitere Presets (Visual Studio, Ninja, MSVC/Clang, Linux) stehen in
[`CMakePresets.json`](CMakePresets.json). Für lokale Pfade — Qt, vcpkg —
`CMakeUserPresets.example.json` nach `CMakeUserPresets.json` kopieren.

---

## Aufbau des Repositorys

| Pfad | Inhalt |
|---|---|
| `CMakeCraft.cmake` | Entry-Point, selbst-lokalisierend — der einzige Einstieg |
| `cmake/core/` | Fundament: Fehlercodes, Debug-Ausgabe, JSON-Auswertung, Validierung, Compiler-Optionen, Ausgabeverzeichnisse |
| `cmake/project/` | `Solution.json` → Targets: Libraries, Executables, Apps, Tests |
| `cmake/externals/` | Orchestrator plus die Handler `local/`, `fetched/`, `system/`; PreFetch-/PostFetch-Hooks; Include-Definitionen |
| `cmake/buildSystemTest/` | die Phasentests 1–9 |
| `templates/` | Kopiervorlagen: `consumer/` (Bootstrap), `App/` (App-Container), `Source_*.cmake`, `Solution.json` |
| `projects/`, `Solution.json` | die Demo-Solution |
| `externals/` | Local Externals der Demo-Solution (doctest, glad, Lua-Header) |
| `docs/` | die Dokumentation |

## Dokumentation

Führungssprache ist **Deutsch**; `docs/en/` ist die Übersetzung und kann
hinterherhinken.

| Bereich | Für wen |
|---|---|
| [docs/de/guide/](docs/de/guide/) | Ich **nutze** das Build-System — Anleitungen, Referenzen, Cheatsheets, Modul-Doku |
| [docs/de/konzepte/](docs/de/konzepte/) | Ich **ändere** das Build-System — Guidelines, Architektur-Konzepte |
| [docs/de/autorenwerk/](docs/de/autorenwerk/) | Ich **schreibe** Code oder Doku — Blueprints und Coding-Standards, projektunabhängig |

Einstiegspunkte: [Getting_Started.md](docs/de/guide/userguides/Getting_Started.md) ·
[Neues_Projekt_Guide.md](docs/de/guide/userguides/Neues_Projekt_Guide.md) ·
[Glossar.md](docs/de/guide/references/Glossar.md)

## Mitmachen

Fehlerberichte und Vorschläge sind willkommen — siehe
[.github/CONTRIBUTING.md](.github/CONTRIBUTING.md). Für alles, was über einen
Tippfehler hinausgeht, bitte erst ein Issue: `Solution.json` ist eine
öffentliche Schnittstelle, und Änderungen daran betreffen jedes Projekt, das
CMakeCraft nutzt.

---

## Lizenz

CMakeCraft steht wahlweise unter **MIT** ([LICENSE-MIT](LICENSE-MIT)) oder
**Apache-2.0** ([LICENSE-APACHE](LICENSE-APACHE)) — such dir aus, was besser
passt.

Ein Projekt, das CMakeCraft zum Bauen verwendet, wird dadurch **nicht** zu einem
abgeleiteten Werk und muss keine dieser Lizenzen übernehmen. Ein Build-System
erzeugt keinen Code, der in deine Binärdateien wandert.

Die mitgelieferte Demo-Solution enthält Fremdcode mit eigenen Bedingungen und
verweist auf das proprietäre **BASS**, das nicht Teil dieses Repositorys ist.
Vollständige Aufstellung: **[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)**.

Sofern du nicht ausdrücklich etwas anderes erklärst, gilt jeder Beitrag, den du
zur Aufnahme einreichst, als unter denselben beiden Lizenzen stehend.
