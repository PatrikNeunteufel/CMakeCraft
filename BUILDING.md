# CMakeCraft bauen und prüfen

Diese Anleitung gilt für **dieses Repository** — also für den Fall, dass du am
Build-System selbst arbeitest oder es ausprobieren willst.

Willst du CMakeCraft nur in einem eigenen Projekt **benutzen**, brauchst du
nichts davon: dort gehst du nach
[docs/de/guide/userguides/Neues_Projekt_Guide.md](docs/de/guide/userguides/Neues_Projekt_Guide.md)
vor, und CMakeCraft wird beim Konfigurieren automatisch geholt.

- [1. Voraussetzungen](#1-voraussetzungen)
- [2. Selbsttest — der wichtigste Lauf](#2-selbsttest--der-wichtigste-lauf)
- [3. Die Demo-Solution bauen](#3-die-demo-solution-bauen)
- [4. Optionale Vorbereitungen](#4-optionale-vorbereitungen)
- [5. Am Build-System aus einem Projekt heraus arbeiten](#5-am-build-system-aus-einem-projekt-heraus-arbeiten)
- [6. Wenn etwas schiefgeht](#6-wenn-etwas-schiefgeht)

---

## 1. Voraussetzungen

| Was | Version | Anmerkung |
|---|---|---|
| **CMake** | ≥ 3.25 | wegen der Preset-Version 6 |
| **Git** | beliebig | wird **während** der Konfiguration aufgerufen, um Git-Externals zu holen |
| **C++-Compiler mit C++20** | MSVC 2022, Clang 15+, GCC 12+ | Windows ist die Hauptplattform |
| **Ninja** | beliebig | für die Ninja-Presets, u. a. den Selbsttest |

Für den Selbsttest ist das alles. Optional — nur für einzelne Demo-Targets:

| Was | Wofür |
|---|---|
| **Qt 6** | Demo-Executable `QtMarkdownViewer` |
| **BASS 2.4 + BASSFLAC** | Demo-Executables `MinimalConsole` und `consolePlayer`, siehe [Abschnitt 4](#4-optionale-vorbereitungen) |

Beim ersten Konfigurieren wird **eine Netzverbindung** gebraucht: Git-Externals
(GoogleTest, Catch2, …) werden nach `.externals/` geklont. Danach liegen sie im
Cache und der Build ist offlinefähig.

---

## 2. Selbsttest — der wichtigste Lauf

```bash
cmake --preset craft-selftest
```

Das Preset ist Ninja + Clang + Debug mit `RUN_BUILD_SYSTEM_TESTS=ON`. Es lässt
die **Phasentests 1–9** aus `cmake/buildSystemTest/` mitlaufen — sie prüfen das
Build-System an sich selbst: JSON-Auswertung, Validierung, Target-Erzeugung,
Externals aller drei Bezugswege, App-Container, Test-Targets.

**Die Phasentests laufen zur Konfigurationszeit.** „Grün" heißt hier: das
Konfigurieren läuft ohne Fehler durch. Ein `cmake --build` ist dafür nicht nötig.

Eine einzelne Phase prüfen:

```bash
cmake --preset craft-selftest -DTEST_PHASE=5
```

Die Phasentests sind standardmäßig **aus** (`RUN_BUILD_SYSTEM_TESTS=OFF`) — sie
sollen in Konsumenten-Projekten nicht bei jedem Configure mitlaufen. Dort sind
sie nur nach einem Versionswechsel als Rauchtest sinnvoll.

Was die einzelnen Phasen abdecken, steht in
[`cmake/buildSystemTest/README.md`](cmake/buildSystemTest/README.md).

---

## 3. Die Demo-Solution bauen

Die mitgelieferte `Solution.json` ist eine Vorführung: eine INTERFACE-Bibliothek,
mehrere Executables, ein App-Container mit Unit-, Integrations- und
Performance-Tests. Sie zu bauen ist der zweite Nachweis, dass das Build-System
funktioniert — der erste ist der Selbsttest.

**Windows — Visual Studio 2022, x64, Debug:**

```bash
cmake --preset windows-vs-x64-debug_dynamic
```

```bash
cmake --build --preset build-vs-x64-Debug
```

**Windows — Ninja, Clang, Debug:**

```bash
cmake --preset windows-ninja-debug-clang
```

```bash
cmake --build --preset build-ninja-debug-clang
```

**Linux — GCC, Debug:**

```bash
cmake --preset linux-gcc-debug
```

```bash
cmake --build --preset build-linux-gcc-Debug
```

Die Ausgaben landen unter `out/build/<preset>/`. Alle verfügbaren Presets:
`cmake --list-presets`.

### Tests der Demo-Solution

Die Test-Targets sind standardmäßig **aus** (`BUILD_TESTS=OFF`). Die
Testing-Presets schalten sie ein:

```bash
cmake --preset windows-vs-x64-testing_dynamic
```

```bash
cmake --build --preset build-vs-x64-Testing
```

```bash
ctest --preset ctest-vs-x64-Testing
```

Die meisten eigenständigen Test-Targets in `Solution.json` stehen auf
`"skip": true` — sie sind als Beispiele für die drei unterstützten Frameworks
gedacht (doctest, GoogleTest, Catch2), nicht als Testsuite. Die Tests des
App-Containers `MyVisualizer` laufen.

---

## 4. Optionale Vorbereitungen

### Qt finden lassen

Gebraucht nur für das Demo-Executable `QtMarkdownViewer`. CMakeCraft sucht Qt
über Umgebungsvariablen — `QT_ROOT`, `QT_DIR`, `Qt6_ROOT` oder `Qt6_DIR`, die
erste existierende gewinnt. Zusätzlich wird eine Liste üblicher
Installationspfade abgesucht (`cmake/externals/system/packages/Qt6.cmake`).

**Windows (PowerShell, nur für diese Sitzung):**

```powershell
$env:QT_ROOT = "C:/Qt/6.10.1/msvc2022_64"
```

**Linux/macOS:**

```bash
export QT_ROOT=$HOME/Qt/6.10.1/gcc_64
```

Dauerhafter geht es über eine eigene `CMakeUserPresets.json` — eine Vorlage
liegt bei:

```bash
cp CMakeUserPresets.example.json CMakeUserPresets.json
```

Die Datei ist bewusst **nicht versioniert**; dort gehören deine lokalen Pfade
hinein (Qt, vcpkg-Toolchain) und eigene Presets, die auf den mitgelieferten
aufbauen. Details: [CMakeUserPresets.md](docs/de/guide/userguides/CMakeUserPresets.md)

### BASS beschaffen

Gebraucht nur für die Demo-Executables `MinimalConsole` und `consolePlayer`.
**BASS ist proprietär und darf über dieses Repository nicht weitergegeben
werden** — weder Binärdateien noch Header, Beispiele oder Dokumentation.

Ohne diesen Schritt konfiguriert alles sauber und die Phasentests laufen durch;
erst der Build der beiden Programme bricht ab — an der fehlenden
Bibliotheksdatei, noch bevor übersetzt wird. Wer sie nicht braucht, setzt sie in
`Solution.json` auf `"skip": true`.

Anleitung: [`externals/bass/SETUP.md`](externals/bass/SETUP.md).

---

## 5. Am Build-System aus einem Projekt heraus arbeiten

Der übliche Fall: Du entwickelst ein Projekt, stößt auf eine Lücke im
Build-System und willst sie beheben, ohne für jede Zwischenversion einen Git-Tag
zu setzen.

Konfiguriere das **Projekt** mit einem Verweis auf deine CMakeCraft-Arbeitskopie:

```bash
cmake --preset <projekt-preset> -DCMAKECRAFT_LOCAL_DIR=../CMakeCraft
```

Der Bootstrap umgeht dann Pin und Cache und lädt den Entry-Point direkt aus dem
Checkout. Änderungen wirken beim nächsten Configure sofort.

**Wichtig:** Änderungen an `cmake/**` passieren **hier**, nie im Snapshot oder
Cache eines Projekts. Ist der Fix fertig, wird hier getaggt und im Projekt die
Version in `cmakecraft.pin` hochgezogen. Verfahren:
[Neues_Projekt_Guide.md §5](docs/de/guide/userguides/Neues_Projekt_Guide.md).

---

## 6. Wenn etwas schiefgeht

### `E214 Local external 'bass': Path does not exist`

Der Ordner `externals/bass/` fehlt. Er muss existieren — auch wenn nur
`SETUP.md` darin liegt. Prüfe, ob dein Checkout vollständig ist.

### `bass.lib … missing and no known rule to make it`

BASS ist nicht beschafft. Das ist Absicht — siehe
[Abschnitt 4](#4-optionale-vorbereitungen). Entweder BASS nach
[`externals/bass/SETUP.md`](externals/bass/SETUP.md) beschaffen oder die beiden
Demo-Executables in `Solution.json` auf `"skip": true` setzen.

### `E104 Source.cmake not found (mode=explicit)`

Die Quelldatei-Listen sind explizit — jedes Target braucht seine
`Source.cmake`. Vorlagen: `templates/Source_*.cmake`. Es wird bewusst nicht
geglobbt.

### Qt wird nicht gefunden

Setze `QT_ROOT` auf das Verzeichnis **mit** `bin/` und `lib/` darin, nicht auf
das Qt-Wurzelverzeichnis darüber. Prüfen lässt es sich am Configure-Log: der
Qt6-Handler gibt aus, wo er sucht und was er findet.

### Ein Git-External wird bei jedem Configure neu geholt

Dann liegt der Cache nicht, wo er erwartet wird. Git-Externals landen in
`.externals/` **relativ zum Projekt**, nicht relativ zu CMakeCraft. Ein
gelöschtes `out/` betrifft `.externals/` nicht — beides sind getrennte Ordner.

### Mehr Ausgabe

```bash
cmake --preset craft-selftest -DDEBUG_DEFAULT_LEVEL=5
```

Die Debug-Ausgabe ist gestuft (1 = knapp bis 5 = alles) und lässt sich mit
`-DDEBUG_MESSAGES=OFF` ganz abschalten. Alle Fehlercodes mit Erklärung:
[ErrorCodes.md](docs/de/guide/references/ErrorCodes.md).
