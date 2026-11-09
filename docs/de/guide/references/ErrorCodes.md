# ErrorCodes — Referenz

> **Version:** 1.6.1  
> **Datum:** 2026-11-09  
> **Typ:** Reference  
> **Status:** Stabil  
> **Zielgruppe:** Alle Entwickler  
> **Sprache:** Deutsch  
> **English:** [ErrorCodes.md](../../../en/guide/references/ErrorCodes.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Konventionen](#2-konventionen)
3. [Fatal Errors (E)](#3-fatal-errors-e)
4. [Warnings (W)](#4-warnings-w)
5. [Schnellreferenz](#5-schnellreferenz)
6. [Verwendung in Code](#6-verwendung-in-code)
7. [Siehe auch](#7-siehe-auch)
8. [Changelog](#8-changelog)

---

## 1. Übersicht

Diese Referenz dokumentiert alle Fehlercodes des CMake Architecture Build-Systems mit Erklärungen und Lösungsvorschlägen.

### Fehlercode-Format

```
[E|W][K][NN]

E = Error (Build bricht ab)
W = Warning (Build läuft weiter)
K = Kategorie (1 Ziffer)
NN = Nummer (2 Ziffern)
```

### Zielgruppe

- Entwickler bei der Fehlersuche
- Build-System-Entwickler für konsistente Fehlermeldungen

---

## 2. Konventionen

### 2.1 Fehlercode-Bereiche

| Bereich | Codes | Beschreibung |
|---------|-------|--------------|
| JSON/Parsing | `E0xx` | Fehlende Pflichtfelder, ungültiges JSON |
| Target-Erstellung | `E1xx` | Target existiert bereits, Abhängigkeit fehlt |
| Externals | `E2xx` | Fetch fehlgeschlagen, Include.cmake fehlt |
| Tests | `E3xx` | Framework, Source-Fehler |
| App-Container | `E4xx` | App-Struktur, Verzeichnisse |
| System Externals | `E5xx` | find_package, Komponenten |
| Deprecation | `W0xx` | Veraltete Features/Syntax |
| Konfiguration | `W1xx` | Suboptimale Einstellungen |
| Tools/Setup | `W2xx` | Fehlende Tools |
| External-Caching | `W3xx` | Offline-Modus, Hook-Wiederverwendung |
| App-Container | `W4xx` | Optionale Verzeichnisse |
| System External-Warnungen | `W5xx` | Backup-Verwendung |
| Phasentests | `W6xx`–`W9xx` | Warnungen der Selbsttests (nur mit `RUN_BUILD_SYSTEM_TESTS=ON`) |

### 2.2 Schweregrade

| Symbol | Typ | Bedeutung |
|--------|-----|-----------|
| ⛔ | FATAL_ERROR | Build bricht ab |
| ⚠️ | WARNING | Build läuft weiter |

---

## 3. Fatal Errors (E)

### 3.1 E0xx — JSON/Parsing Errors

#### E001 — Pflichtfeld fehlt

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Meldung** (Beispiele):
```
[E001] Executable has no 'name' field
[E001] Executable 'MyApp': Required field 'name' missing
[E001] Solution.json: 'solution.name' missing
```

Der Text nennt je nach Stelle das Objekt (`Executable`, `Library`, `Test`, `Package`, `Local external` …)
und das fehlende oder leere Feld.

**Lösung:**
```json
{
    "name": "MyApp",
    "path": "src/apps/myapp"
}
```

---

#### E002 — Solution.json nicht gefunden

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Meldung:**
```
[E002] Solution.json not found: <Pfad>/Solution.json
[E002] Solution.json: 'schemaVersion' missing or invalid JSON
[E002] Solution.json: 'schemaVersion' has invalid format '1' (expected: MAJOR.MINOR)
```

**Lösung:**
- Stelle sicher, dass `Solution.json` im Projekt-Root liegt
- `schemaVersion` als `"MAJOR.MINOR"` angeben (aktuell `"1.0"`)
- Prüfe Schreibweise (Groß-/Kleinschreibung)

---

#### E003 — Schema-Version inkompatibel

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.6.0 |

**Meldung:**
```
[E003] Solution.json: schemaVersion 0.6 incompatible (expected major: 1, current: 1.0)
[E003] Invalid library type 'OBJECT' for 'MyLib'. Valid: STATIC, SHARED, INTERFACE
```

**Ursache:** Die Major-Version des Schemas in Solution.json stimmt nicht mit der vom Build-System unterstützten Version
überein (aktuell `1.0`, `cmake/project/Solution.cmake:50`). Derselbe Code meldet auch einen ungültigen
Library-Typ (`LibraryCollect.cmake:105`).

**Lösung:**
- `schemaVersion` in Solution.json auf kompatible Version setzen (z.B. `"1.0"`)
- Oder Build-System aktualisieren, wenn neuere Schema-Version benötigt wird

---

#### E004 — Ungültiger Wert im settings-Block

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.12.0 |

**Meldung:**
```
[E004] Solution.json: settings.msvc.parallel_compile must be a non-negative integer, got 'viele'
```

**Ursache:** Ein Feld im `settings`-Block hat einen Wert, den CMakeCraft nicht verwenden kann.

**Lösung:**
- `settings.msvc.parallel_compile` als ganze Zahl ≥ 0 angeben (`0` oder `1` = aus), siehe
  [Solution_Schema.md §4.4](Solution_Schema.md#44-msvc)

---

#### E005 — Top-Level-CMakeLists.txt ohne project()

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.13.0 |

**Meldung:**
```
[E005] .../CMakeLists.txt has no project() line. Add 'project(<Name> LANGUAGES NONE)' directly after cmake_minimum_required() ...
```

**Ursache:** Ohne ausgeschriebenes `project()` im obersten `CMakeLists.txt` setzt CMake ein
eigenes `project(Project)` in Zeile 1, **vor** `cmake_minimum_required()`. Die Compiler werden
dann nach alten Regeln eingerichtet: `CMAKE_MSVC_RUNTIME_LIBRARY` greift nicht, und die
Konfiguration `Testing` baut mit der statischen CRT (`/MT`).

**Lösung:**
```cmake
cmake_minimum_required(VERSION 3.26)
project(MeinProjekt LANGUAGES NONE)   # Name/Version kommen aus Solution.json
include("${CMAKE_CURRENT_LIST_DIR}/CMakeCraftBootstrap.cmake")
```
Danach einmal mit `--fresh` konfigurieren — im Cache stehen sonst die alten Flags.

---

#### E010 — External nicht in externals-Block definiert

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Meldung:**
```
[E010] External 'imgui' not defined in externals block
[E010] Test framework 'doctest' not defined in externals block
```

**Lösung:**
```json
{
    "externals": {
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.90.1"
        }
    }
}
```

---

#### E012 — External-Source-Feld Fehler

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Meldung:**
```
[E012] External 'mylib': No source field specified.
  Required: one of 'system', 'git', 'path', or 'archive'
  ...
[E012] External 'mylib': Multiple source fields specified: path;git
  Only one source field is allowed.
```

**Lösung:** Genau EIN Source-Feld pro External: `system`, `git`, `path` oder `archive`
(`Validation.cmake:58`; `vcpkg`, `conan`, `find_package` passieren die Prüfung, enden aber im
Orchestrator mit `[E012] External 'mylib': No valid source field (system/git/path/archive)`).

---

#### E013 — Geskipptes External verwendet

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.7.1 |

**Meldung:**
```
[E013] External 'future_lib' is skipped but used by target 'MyApp'. Remove from externals list or set skip: false
```

**Ursache:** Ein External mit `skip: true` wird von einem Target referenziert.

**Lösung:** 
- External aus der `externals`-Liste des Targets entfernen, ODER
- `skip: false` setzen (oder `skip` entfernen) im External-Block

---

### 3.2 E1xx — Target-Erstellung Errors

#### E101 — Abhängigkeit existiert nicht

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Lösung:** Library in Solution.json definieren oder Schreibfehler korrigieren.

---

#### E102 — Target existiert bereits

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Lösung:** Target-Namen müssen über Libraries, Executables UND Tests hinweg eindeutig sein.

---

#### E103 — Zirkuläre Abhängigkeit

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

> Derzeit nicht ausgelöst (Stand 2026-11-09). Der Fall wird nicht gemeldet: CMakeCraft
> erkennt Zirkelbezüge zwischen Targets nicht (`cmake/core/Errors.cmake:97`).

**Beschreibung:** Eine zirkuläre Abhängigkeit zwischen Targets wurde erkannt (A → B → C → A).

**Lösung:** Gemeinsamen Code in separate Library extrahieren.

---

#### E104 — Source.cmake nicht gefunden

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Beschreibung:** Der Source-Mode ist `explicit` und das Source-Verzeichnis enthält keine `Source.cmake` Datei.

**Lösung:** Source.cmake erstellen oder Mode auf `auto` ändern.

---

#### E105 — compile_options an einer INTERFACE-Library

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.14.0 |

**Beschreibung:** Eine Library mit `"type": "INTERFACE"` trägt `compile_options`. Eine
Header-Library hat keine eigene Übersetzung; das Flag würde nirgends wirken.

**Lösung:** Die Rechnung in `.cpp`-Dateien einer `STATIC`-Library legen und die Flags dort
setzen — oder `compile_options` entfernen.

---

#### E106 — Quellpaket nicht abbildbar

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.14.0 |

**Beschreibung:** Ein Eintrag `{ "library": … }` im Block `packages` nennt eine Library, die
sich nicht in einfachem CMake beschreiben lässt: sie ist nicht `STATIC`, hat C++20-Module, eine
Datei oder ein Include-Ordner liegt außerhalb von `path` und `public_headers`, oder ein
External ist nicht lokal (system, fetched, archive) beziehungsweise bringt mehr als ein
Header-only-`INTERFACE`-Ziel mit Include-Ordnern im eigenen Ordner, Defines, Compile-Optionen
und -Features. Die Meldung nennt die Library und gegebenenfalls das External.

**Lösung:** Die Library oder das External so umstellen, dass es passt, oder kein Quellpaket
schnüren (Binärpaket mit `contents`). Siehe [Packages.md](Packages.md) §2.5.

---

### 3.3 E2xx — Externals Errors

#### E201 — Fetched External: Kein Target in Registry

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Meldung:**
```
[E201] Fetched external 'mylib': No target in registry. PostFetch hook required?
[E201] Fetched external 'mylib': No CMake support, PostFetch hook required but no targets created
```

Die zweite Meldung kommt bei `cmakeSupport: false`, wenn nach dem PostFetch-Hook kein Target
registriert ist (`cmake/externals/fetched/Handler.cmake:118`).

**Lösung:**
1. Prüfe ob das External ein CMake-Projekt ist
2. Erstelle ggf. einen PostFetch-Hook
3. Oder verwende lokales External mit eigenem Include.cmake

---

#### E202 — External Fetch fehlgeschlagen

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Lösung:**
- Netzwerkverbindung prüfen
- URL in Solution.json prüfen
- Tag/Branch existiert?

---

#### E203 — Target eines Externals nicht gefunden

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | — |

**Meldung:**
```
[E203] Target 'glfw' for external 'glfw' not found
```

**Beschreibung:** Das in der Registry eingetragene Haupt-Target eines Externals existiert beim
Verlinken nicht (`cmake/externals/registry/Targets.cmake:263`).

**Lösung:** Hook oder Include.cmake prüfen, die das Target anlegen und registrieren.

---

#### E213 — Lokales External: Include.cmake nicht gefunden

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Lösung:** Datei erstellen: `externals/${name}/Include.cmake`

---

#### E214 — Lokales External: Pfad existiert nicht

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Lösung:** Pfad in Solution.json prüfen.

---

#### E215 — Fetched External: Kein tag/branch/commit

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Lösung:** Eines von `tag`, `branch` oder `commit` angeben.

---

#### E216 — Explizit angegebener Hook nicht gefunden

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Lösung:** Hook-Datei erstellen oder Hook-Angabe entfernen.

---

#### E217 — PostFetch Hook erforderlich aber nicht vorhanden

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.1 |

**Meldung:**
```
[E217] External 'imgui': PostFetch hook required (cmakeSupport=false) but not found
```

> Derzeit nicht ausgelöst (Stand 2026-11-09). Der Fall wird gemeldet als E201:
> `Fetched external '<name>': No CMake support, PostFetch hook required but no targets created`
> (`cmake/externals/fetched/Handler.cmake:118`).

**Lösung:**
1. PostFetch Hook erstellen: `cmake/externals/hooks/postfetch/${name}.cmake`
2. Oder `cmakeSupport: true` setzen (wenn External doch CMakeLists.txt hat)

---

#### E218 — Nicht im Cache und Offline-Modus aktiv

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.2 |

**Meldung:**
```
[E218] External 'glfw': Not cached and offline mode enabled
```

**Beschreibung:** `EXTERNALS_OFFLINE` verbietet das Holen, aber unter
`.externals/<name>/` liegt nichts Brauchbares. Seit v0.9.1 nennt die Meldung
auch den Fall, dass dort zwar etwas liegt, es aber kein vollständiger Klon ist.

**Lösung:**
1. Einmal mit Netzverbindung und ohne `EXTERNALS_OFFLINE` konfigurieren
2. Oder ein befülltes `.externals/` von einer anderen Arbeitskopie übernehmen

---

#### E219 — Cache-Verzeichnis lässt sich nicht entfernen

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.9.1 |

**Meldung:**
```
[E219] External 'glfw': Could not remove the cache directory
    .../.externals/glfw
  It is left over from an aborted fetch and has to go before the external can be fetched again.
  ...
```

**Beschreibung:** Ein unbrauchbares Cache-Verzeichnis muss weg, bevor neu
geklont werden kann — das Löschen ist aber gescheitert. Das Build-System kann
an dieser Stelle nichts mehr tun.

**Lösung:**
1. Programme schließen, die im Verzeichnis etwas offen halten (Editor,
   Explorer-Fenster, Terminal mit `cd` dorthin, Virenscanner)
2. `.externals/<name>/` von Hand löschen
3. Erneut konfigurieren

Bleibt es dabei, ist meist der **Pfad zu lang**: der Projektpfad plus die
Verzeichnistiefe des Fremdprojekts überschreitet unter Windows die Grenze der
Werkzeugkette. Dann das Projekt an einen kürzeren Pfad legen oder lange Pfade
in Windows und Git aktivieren (`git config --global core.longpaths true`).

---

#### E220 — Archive External: Feld `pin` fehlt

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.10.0 |

**Meldung:**
```
[E220] Archive external 'sichttest': 'pin' field is required.
  Example: { "archive": true, "pin": "sichttest.pin" }
```

**Beschreibung:** Ein External mit `"archive": true` nennt keine Pin-Datei. Version,
Adresse und Prüfsumme stehen nur dort.

**Lösung:** Pin-Datei anlegen und mit `"pin"` nennen — siehe [Packages.md](Packages.md) §4.

---

### 3.4 E3xx — Test Errors

#### E301 — Unbekanntes Test-Framework

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.4 |

**Meldung:**
```
[E301] Test 'MyTests': Unknown framework 'boost'. Valid: doctest;googletest;catch2
[E301] App 'MyApp': No framework specified for test 'UnitTests'. Set tests.framework or targets[].framework
```

**Lösung:** Gültige Frameworks: `doctest`, `googletest`, `catch2`

---

#### E302 — source_from Executable existiert nicht

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.4 |

**Meldung:**
```
[E302] source_from: Executable 'MyApp' not found
```

Bei Apps meldet derselbe Code ein unbekanntes Framework eines Test-Targets:
`[E302] App 'MyApp': Unknown framework 'boost' for test 'UnitTests'. Valid: doctest;googletest;catch2`
(`AppCreate.cmake:630`).

**Lösung:** Executable-Name in `source_from` prüfen.

---

#### E303 — Test-Source-Verzeichnis nicht gefunden

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.4 |

**Meldung:**
```
[E303] Test 'MyTests': Source path does not exist: <Pfad>
```

Bei Apps meldet derselbe Code ein Test-Target ohne `name`:
`[E303] App 'MyApp': Test target [0] missing required 'name' field` (`AppCollect.cmake:351`).

**Lösung:** Pfad in Solution.json prüfen oder Verzeichnis erstellen.

---

#### E304 — App-Test-Target ohne type

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | — |

**Meldung:**
```
[E304] App 'MyApp': Test target 'UnitTests' missing required 'type' field
```

**Lösung:** `type` im Eintrag von `apps[].tests.targets[]` angeben (`unit`, `integration`, …).

---

#### E305 — Pfad eines App-Test-Targets existiert nicht

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | — |

**Meldung:**
```
[E305] App 'MyApp': Test 'UnitTests' path does not exist: <Pfad>
```

**Lösung:** Ordner anlegen oder `path` berichtigen (Vorgabe: `tests/{type}/{name}`).

---

### 3.5 E4xx — App-Container Errors

#### E400 — App-Definition ohne name (Sammelphase)

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.2.0 (Phase 8) |

**Meldung:**
```
[E400] App definition missing required 'name' field
```

**Beschreibung:** Prüfung beim Einlesen einer App (`AppCollect.cmake:183`). Im normalen Ablauf meldet
E401 denselben Fehler zuerst.

**Lösung:** `name` Feld in der App-Definition hinzufügen.

---

#### E401 — App: name ist Pflichtfeld

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.2.0 (Phase 8) |

**Meldung:**
```
[E401] App #0 has no 'name' field
```

**Lösung:** `name` Feld in der App-Definition hinzufügen.

---

#### E402 — App-Pfad existiert nicht

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.2.0 (Phase 8) |

**Lösung:** Pfad prüfen oder Verzeichnis erstellen.

---

#### E403 — App hat kein src/ Verzeichnis

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.2.0 (Phase 8) |

**Lösung:** `src/` Verzeichnis im App-Container erstellen.

---

#### E404 — App hat keine Source-Dateien in src/

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.2.0 (Phase 8) |

**Lösung:** Source-Dateien (.cpp) in `src/` hinzufügen.

---

#### E405 — App-Dependency nicht gefunden

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.2.0 (Phase 8) |

**Lösung:** Abhängigkeit in Solution.json definieren.

---

#### E406 — App hat kein main/ Verzeichnis

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.2.0 (Phase 8) |

**Lösung:** `main/` Verzeichnis für Entry-Point erstellen.

---

#### E407 — App hat keine Source-Dateien in main/

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.2.0 (Phase 8) |

**Lösung:** Entry-Point Datei (main.cpp) in `main/` hinzufügen.

---

### 3.6 E5xx — System External Errors

Der System-Handler ruft `find_package()` **ohne** `REQUIRED` auf
(`cmake/externals/system/Handler.cmake:270`, `:273`). Bleibt `<Paket>_FOUND` falsch und ist das
External `required` (Vorgabe), benennt `_system_external_not_found()` die Ursache als E503, E504
oder E505 (`Handler.cmake:290`). CMakes eigene Diagnose steht davor als Warnung. Ist das External
`"required": false`, gibt es keinen Fehler, nur `[<name>] <Paket> not found (optional)`
(`Handler.cmake:293`).

#### E502 — package-Feld fehlt

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.2.0 |

**Meldung** (`cmake/core/Validation.cmake:94`, `cmake/externals/system/Handler.cmake:180`):
```
[E502] System external 'qt6': 'package' field is required.
  Example: { "system": true, "package": "Qt6" }
```

**Lösung:** `package` Feld für System Externals angeben.

---

#### E503 — find_package fehlgeschlagen

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.2.0 |

**Meldung**, wenn CMake keine Konfigurationsdatei des Pakets findet (`Handler.cmake:128`):
```
[E503] System external 'qt6': find_package(Qt6) failed.

  Possible solutions:
    1. Set Qt6_ROOT environment variable
    2. Add 'hints' in Solution.json
    3. Install Qt6 to a standard location

  Example Solution.json:
    "qt6": {
      "system": true,
      "package": "Qt6",
      "hints": ["C:/Path/To/Qt6"]
    }
```

Zwei weitere Fassungen mit denselben Lösungszeilen:

- Konfigurationsdateien gefunden, aber keine angenommen und keine `version` gesetzt
  (`Handler.cmake:120`): `find_package(Qt6) failed - no configuration file was accepted.`,
  danach `Considered:` mit je einer Zeile `<Datei> (version <Version>)`.
- Konfiguration angenommen, das Paket meldet sich aber als nicht gefunden, ohne dass
  `components` gesetzt ist (`Handler.cmake:101`): zusätzlich
  `Reason given by the package: <Paket>_NOT_FOUND_MESSAGE`.

Ein External, das beim Verlinken nicht registriert ist, meldet
`[E503] System external '<name>' not properly registered` (`Handler.cmake:331`).

**Lösung:** Paket installieren oder seinen Ort über `<Paket>_ROOT`, `hints` in Solution.json
oder `CMAKE_PREFIX_PATH` angeben.

---

#### E504 — Komponente nicht gefunden

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.2.0 (ausgelöst seit v0.14.1) |

**Meldung** (`Handler.cmake:91`):
```
[E504] System external 'qt6': Qt6 was found (<Qt6_DIR>), but not with all requested components: Core, Widgets, Charts
  Reason given by the package: <Qt6_NOT_FOUND_MESSAGE>

  Possible solutions:
    1. Install the missing component(s) for this Qt6 installation
    2. Remove components the project does not use from 'components' in Solution.json
```

**Beschreibung:** Die Konfiguration des Pakets wurde angenommen (`<Paket>_DIR` gesetzt), es
fehlt aber mindestens eine der Komponenten aus `components`. Die Meldung nennt alle
angeforderten Komponenten; welche fehlt, sagt der Grund des Pakets (`<Paket>_NOT_FOUND_MESSAGE`).

**Lösung:** Fehlende Komponente für diese Installation nachinstallieren oder aus `components`
streichen.

---

#### E505 — Version nicht erfüllt

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.2.0 (ausgelöst seit v0.14.1) |

**Meldung** (`Handler.cmake:109`):
```
[E505] System external 'qt6': no Qt6 with a version compatible to the requested '6.9' was found.
  Considered:
    C:/Qt/6.8.0/msvc2022_64/lib/cmake/Qt6/Qt6Config.cmake (version 6.8.0)

  Possible solutions:
    1. Install a compatible Qt6 version and point Qt6_ROOT or 'hints' to it
    2. Adjust 'version' in Solution.json
```

**Beschreibung:** `version` ist gesetzt, und CMake hat nur Konfigurationsdateien mit
unpassender Version betrachtet. Ohne `version` ist derselbe Fall E503.

**Lösung:** Passende Version installieren und über `<Paket>_ROOT` oder `hints` angeben, oder
`version` in Solution.json anpassen.

---

## 4. Warnings (W)

### 4.1 W0xx — Deprecation Warnings

#### W001 — Veraltetes Schema

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.1.0 |

> Derzeit nicht ausgelöst (Stand 2026-11-09). Der Fall wird gemeldet als E002, E003, W101 oder
> W102 (`cmake/project/Solution.cmake:82`, `:94`, `:102`, `:107`, `:109`). W001 steht nur in
> `validate_solution_schema()` (`cmake/core/Validation.cmake:221`, `:227`), das niemand aufruft.

**Beschreibung:** Die Solution.json verwendet ein veraltetes Schema.

---

#### W002 — Veraltete Syntax/Feld

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.1.0 |

> Derzeit nicht ausgelöst (Stand 2026-11-09). Der Fall wird nicht gemeldet: kein Modul
> prüft auf veraltete Felder.

**Beschreibung:** Ein Feld oder Syntax wird in Zukunft entfernt.

---

### 4.2 W1xx — Konfiguration/Validation Warnings

#### W101 — Schema-Version zu niedrig

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.6.0 |

**Meldung:**
```
[W101] Solution.json: schemaVersion <MAJOR.MINOR> < 1.0, some features may not be available
```

**Beschreibung:** Die Solution.json verwendet eine ältere Minor-Version des Schemas. Neuere Features des
Build-Systems sind möglicherweise nicht verfügbar. Beim heutigen Stand `1.0` (Minor 0) kann diese Meldung nicht
auftreten.

**Weitere Auslöser:** Der Code verwendet W101 auch für andere Hinweise, unter anderem:
`Invalid source.mode '<mode>', using 'explicit'` (`SourceCollect.cmake:75`),
`Source.cmake for '<target>' defines no compilable files` (`SourceCollect.cmake:417`),
`Executable|Library '<name>': No source files found in <path>`, `Test '<name>': No source files found`,
`Executable|Library '<name>': PCH enabled but '<header>' not found in pch/, src/, or root`,
`External '<name>' not ready when applying to <target>` und `External '<name>': No target to link`.

**Lösung:** `schemaVersion` in Solution.json auf aktuelle Version aktualisieren.

---

#### W102 — Schema-Version zu hoch

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.6.0 |

**Meldung:**
```
[W102] Solution.json: schemaVersion 1.1 > 1.0, some features may not work correctly
```

**Beschreibung:** Die Solution.json verwendet eine neuere Schema-Version als das Build-System unterstützt. Einige Features funktionieren möglicherweise nicht korrekt.

**Lösung:** Build-System aktualisieren oder `schemaVersion` reduzieren.

---

#### W103 — Include.cmake erstellt Executables

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.1.0 |

**Beschreibung:** Eine Include.cmake eines Externals erstellt Executable-Targets (IDE Clutter).

---

#### W104 — Include.cmake bindet Beispiele ein

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.1.0 |

**Beschreibung:** Eine Include.cmake bindet Beispiel- oder Test-Verzeichnisse ein.

---

#### W105 — Version nicht SemVer-konform

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.1.0 |

> Derzeit nicht ausgelöst (Stand 2026-11-09). Der Fall wird nicht gemeldet: kein Modul
> prüft das Versionsformat. Ebenso nie ausgelöst sind W106–W108 (`cmake/core/Errors.cmake:180–183`).

**Korrektes Format:** `MAJOR.MINOR.PATCH` (z.B. `1.0.0`)

---

#### W109 — C++20 Module verwendet

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.1.0 |

**Beschreibung:** Das Target verwendet C++20 Module Interface Units, die noch experimentell sind.

---

#### W110 — GLOB-Fallback aktiv

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.1.0 |

**Beschreibung:** Keine Source.cmake gefunden, GLOB wird als Fallback verwendet.

---

#### W111 — Source.cmake vorhanden, aber leer

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | — |

**Meldung:**
```
[W111] Source.cmake exists but defines no files: <Pfad>/Source.cmake
```

**Beschreibung:** Im Source-Mode `auto` liegt eine `Source.cmake`, die keine Dateien einträgt; das
Build-System fällt auf GLOB zurück (`SourceCollect.cmake:435`).

---

#### W112 — Paket nennt ein Target, das es nicht gibt

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.10.0 |

**Beschreibung:** Ein Eintrag in `packages[].contents` (`headers_of`, `binary_of`,
`output_dir_of`) nennt ein Target, das in diesem Configure nicht existiert — übersprungen,
durch `BUILD_ONLY` ausgeblendet oder für eine andere Plattform. Das Target `package_<name>`
wird dann nicht angelegt.

**Lösung:** Stimmt der Name, ist nichts zu tun. Sonst den Namen in `Solution.json` berichtigen.

---

### 4.3 W2xx — Tools/Setup Warnings

#### W201 — Clang-Tidy nicht gefunden

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.1.0 |

**Beschreibung:** `ENABLE_CLANG_TIDY=ON` ist gesetzt, aber clang-tidy wurde nicht gefunden.

---

### 4.4 W3xx — External-Caching Warnings

#### W301 — External aus Cache verwendet (Offline-Modus)

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.1.2 |

> Derzeit nicht ausgelöst (Stand 2026-11-09). Der Fall wird nicht gemeldet: ein passender
> Cache wird still benutzt (`cmake/externals/core/Fetch.cmake:143–146`); weicht die Version ab,
> kommt W302 (`Fetch.cmake:151`).

**Beschreibung:** Offline-Modus aktiv, gecachtes External wird verwendet.

---

#### W302 — Version weicht ab, Offline-Modus nutzt den Cache

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.1.2 |

**Meldung:**
```
[W302] External 'glfw': Version mismatch but offline mode - using cached
```

**Beschreibung:** Die gecachte Fassung entspricht nicht dem in `Solution.json`
angegebenen tag/branch/commit. Weil `EXTERNALS_OFFLINE` gesetzt ist, wird sie
trotzdem verwendet, statt den Build abzubrechen.

**Lösung:** Ohne Offline-Modus konfigurieren, damit die richtige Fassung geholt wird.

---

#### W303 — Unvollständiger Klon im Cache

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.9.1 |

**Meldung:**
```
[W303] External 'glfw': Incomplete clone in cache (leftover of an aborted fetch) - removing and fetching again: .../.externals/glfw
[W303] External 'glfw': Cache directory is not a git clone - removing and fetching again: .../.externals/glfw
```

**Beschreibung:** In `.externals/<name>/` lag der Rest eines abgebrochenen
Klons — ein `.git` ohne ausgecheckten Stand. `git clone` legt `.git` früh an und
füllt es danach; bricht der Vorgang ab (Netz weg, Strg-C, Platte voll), bleibt
genau das liegen.

CMakeCraft erkennt das, löscht das Verzeichnis und holt neu. **Es ist nichts zu
tun** — die Warnung sagt nur, warum an dieser Stelle ein Download passiert,
obwohl scheinbar etwas im Cache lag.

Vor v0.9.1 wurde dieser Zustand als „Version mismatch" gemeldet, was in die
falsche Richtung wies.

**Lösung:** keine. Tritt die Warnung bei *jedem* Configure auf, bricht der
Klon reproduzierbar ab — dann die Netzverbindung oder den Plattenplatz prüfen.

---

#### W304 — Archive External nicht verfügbar

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.10.0 |

**Meldung:**
```
[W304] Archive external 'sichttest' is not available - targets build without it
```

**Beschreibung:** Das Paket ließ sich aus keiner Quelle beziehen (Zwischenspeicher leer, kein
Netz, kein Treffer in den Fallback-Pfaden, Prüfsumme oder Version passt nicht). Unmittelbar davor
steht eine Warnung `[CraftPackage]`, die jede versuchte Quelle mit Grund nennt.

Der Build läuft weiter: Targets, die das External nennen, bekommen weder Include-Pfad noch
Define noch Laufzeitdateien.

**Lösung:** Netz herstellen, das Archiv in einen Fallback-Pfad legen oder
`-D<NAME>_LOCAL_DIR=<ausgepacktes Paket>` setzen — siehe [Packages.md](Packages.md) §3.4.

---

### 4.5 W4xx — App-Container Warnings

#### W401 — App hat kein include/ Verzeichnis

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.2.0 (Phase 8) |

**Beschreibung:** Das App-Container Verzeichnis hat kein `include/` für Public Headers.

**Weiterer Auslöser:** `[W401] App '<name>': tests.targets is empty` (`AppCollect.cmake:338`).

---

#### W402 — PCH aktiviert aber Header nicht gefunden

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.2.0 (Phase 8) |

**Beschreibung:** Precompiled Header ist aktiviert, aber die angegebene Header-Datei existiert nicht.

**Weiterer Auslöser:** ein Test-Target mit `parallel: true`, dessen Typ üblicherweise seriell läuft
(`[W402] App '<name>': Test '<test>' (type '<type>') has parallel=true. …`, `AppCollect.cmake:435`).

---

#### W403 — Tests-Verzeichnis existiert aber keine Sources

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.2.0 (Phase 8) |

**Beschreibung:** Ein `tests/` Verzeichnis existiert im App-Container, enthält aber keine Test-Dateien.

**Meldungen:**
```
[W403] App 'MyApp': tests.targets configured but no tests/ directory
[W403] Test 'MyApp.UnitTests': No source files found
```

---

### 4.6 W5xx — System External Warnings

#### W501 — Backup-Pfad verwendet

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.2.0 |

**Meldung** (`cmake/externals/system/Handler.cmake:245`):
```
[W501] [qt6] Using backup location: C:/Qt/6.8.0/msvc2022_64
  Consider setting Qt6_ROOT environment variable.
```

**Beschreibung:** Primärer Pfad nicht gefunden, Backup-Pfad wird verwendet.

---

### 4.7 W6xx–W9xx — Warnungen der Phasentests

Nur im Selbsttest (`RUN_BUILD_SYSTEM_TESTS=ON`, Preset `craft-selftest`); Dateien unter
`cmake/buildSystemTest/`. Sie zeigen an, dass ein Prüfschritt nicht oder nicht vollständig laufen konnte.

| Code | Datei | Meldung | Bedeutung |
|------|-------|---------|-----------|
| W601 | `phase6.cmake:36`, `:213` | `GLFW target not found - may not be used by any executable` / `Phase 6: could not create the test repository - clone detection not verified` | Git-External-Test: Target `glfw` fehlt, oder das Test-Repository für die Klon-Erkennung ließ sich nicht anlegen |
| W602 | `phase6.cmake:117` | `SOLUTION_EXTERNALS_JSON not set` | externals-Block nicht geladen, Prüfung übersprungen |
| W701 | `phase7.cmake:77` | `SOLUTION_JSON not available` | Solution.json nicht geladen, Phase 7 übersprungen |
| W801 | `phase8.cmake:75` | `SOLUTION_JSON not available` | Solution.json nicht geladen, Phase 8 (App-Container) übersprungen |
| W802 | `phase8.cmake:253` | `Core library should be STATIC, found: <type>` | `<App>.Core` ist keine STATIC-Library |
| W803 | `phase8.cmake:289` | `Runner does not link against Core` | Die App-Executable linkt `<App>.Core` nicht |
| W901 | `phase9.cmake:121` | `System external '<name>' missing 'package' field` | System External ohne `package` |
| W902 | `phase9.cmake:217` | `<n> external(s) have conflicting type fields` | Externals mit mehr als einem von `system`, `git`, `path` |
| W999 | `phase1.cmake:120`, `phase3.cmake:68`, `:235` | `Test warning (expected, can be ignored)` u. a. | Probewarnung von Phase 1 (erwartet); Phase 3: keine Executables definiert bzw. keine Targets erzeugt |

---

## 5. Schnellreferenz

### 5.1 Fatal Errors (E)

| Code | Kategorie | Beschreibung |
|------|-----------|--------------|
| E001 | JSON | Pflichtfeld fehlt |
| E002 | JSON | Solution.json nicht gefunden |
| E003 | JSON | Schema-Version inkompatibel (Major) |
| E004 | JSON | Ungültiger Wert im settings-Block |
| E005 | Setup | Top-Level-CMakeLists.txt ohne project() |
| E010 | JSON | External nicht im externals-Block |
| E012 | JSON | Kein/mehrere Source-Felder |
| E013 | External | Geskipptes External verwendet |
| E101 | Target | Abhängigkeit existiert nicht |
| E102 | Target | Target existiert bereits |
| E103 | Target | Zirkuläre Abhängigkeit (derzeit nicht ausgelöst) |
| E104 | Target | Source.cmake nicht gefunden (mode=explicit) |
| E105 | Target | compile_options an einer INTERFACE-Library |
| E106 | Target | Quellpaket nicht in einfachem CMake abbildbar |
| E201 | External | Fetched External: kein Target in Registry |
| E202 | External | External Fetch fehlgeschlagen |
| E203 | External | Target eines Externals nicht gefunden |
| E213 | External | Lokales External: Include.cmake fehlt |
| E214 | External | Lokales External: Pfad existiert nicht |
| E215 | External | Fetched External: kein tag/branch/commit |
| E216 | External | Explizit angegebener Hook fehlt |
| E217 | External | PostFetch Hook erforderlich (cmakeSupport=false; derzeit nicht ausgelöst, gemeldet als E201) |
| E218 | External | Nicht im Cache und Offline-Modus aktiv |
| E219 | External | Cache-Verzeichnis lässt sich nicht entfernen |
| E220 | External | Archive External: Feld `pin` fehlt |
| E301 | Test | Unbekanntes Test-Framework |
| E302 | Test | source_from Executable existiert nicht |
| E303 | Test | Test-Source-Verzeichnis nicht gefunden |
| E304 | Test | App-Test-Target ohne type |
| E305 | Test | Pfad eines App-Test-Targets existiert nicht |
| E400 | AppContainer | App-Definition ohne name (Sammelphase) |
| E401 | AppContainer | name ist Pflichtfeld |
| E402 | AppContainer | App-Pfad existiert nicht |
| E403 | AppContainer | Kein src/ Verzeichnis |
| E404 | AppContainer | Keine Sources in src/ |
| E405 | AppContainer | Dependency nicht gefunden |
| E406 | AppContainer | Kein main/ Verzeichnis |
| E407 | AppContainer | Keine Sources in main/ |
| E502 | System | package-Feld fehlt |
| E503 | System | find_package fehlgeschlagen |
| E504 | System | Komponente nicht gefunden |
| E505 | System | Version nicht erfüllt |

### 5.2 Warnings (W)

| Code | Kategorie | Beschreibung |
|------|-----------|--------------|
| W001 | Deprecation | Veraltetes Schema (derzeit nicht ausgelöst) |
| W002 | Deprecation | Veraltete Syntax/Feld (derzeit nicht ausgelöst) |
| W101 | Config | Schema-Version zu niedrig |
| W102 | Config | Schema-Version zu hoch |
| W103 | Config | Include.cmake erstellt Executables |
| W104 | Config | Include.cmake bindet Beispiel-Verzeichnisse ein |
| W105 | Config | Version nicht SemVer-konform (derzeit nicht ausgelöst) |
| W109 | Config | C++20 Module verwendet (experimentell) |
| W110 | Config | GLOB-Fallback aktiv |
| W111 | Config | Source.cmake vorhanden, aber leer |
| W112 | Config | Paket nennt ein Target, das es nicht gibt |
| W201 | Tools | Clang-Tidy nicht gefunden |
| W301 | Caching | External aus Cache (Offline-Modus; derzeit nicht ausgelöst) |
| W302 | Caching | Version weicht ab, Offline-Modus nutzt den Cache |
| W303 | Caching | Unvollständiger Klon im Cache — entfernt und neu geholt |
| W304 | Externals | Archive External nicht verfügbar — Targets bauen ohne es |
| W401 | AppContainer | Kein include/ Verzeichnis |
| W402 | AppContainer | PCH Header nicht gefunden |
| W403 | AppContainer | Tests-Verzeichnis ohne Sources |
| W501 | System | Backup-Pfad verwendet |
| W601–W999 | Phasentests | Warnungen der Selbsttests, siehe §4.7 |

---

## 6. Verwendung in Code

```cmake
include("${CMAKECRAFT_DIR}/core/Errors.cmake")

# Fehler auslösen (Build bricht ab)
cmake_fatal("E002" "Solution.json not found: ${_solution_file}")

# Mehrteilige Meldung: alle Teile nach CODE werden ohne Trenner aneinandergehängt,
# auch Teile mit Semikolon (seit Errors.cmake 1.1.0, CMakeCraft v0.14.1)
cmake_fatal("E012"
    "External '${EXT_NAME}': Multiple source fields specified: ${_found_fields}\n"
    "  Only one source field is allowed.")

# Warnung auslösen (Build läuft weiter)
cmake_warn("W201" "ENABLE_CLANG_TIDY=ON but clang-tidy not found for target '${TARGET_NAME}'")

# Assertion (sollte nie auftreten)
cmake_assert(condition "Internal error: invalid state")
```

---

## 7. Siehe auch

- [Errors.cmake](../module/core/Errors.md) — Fehler-Modul Dokumentation
- [Debug.cmake](../module/core/Debug.md) — Debug-System
- [Solution_Schema.md](Solution_Schema.md) — JSON-Schema Referenz

---

## 8. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.6.1** | **2026-11-09** | **An den Code angeglichen: Meldungen von E001, E002, E003, E010, E012, E201, E301–E303, E401, W101, W102, W303, W403 wörtlich; E003 mit Schema `1.0` (`cmake/project/Solution.cmake:50`); weitere Auslöser von E003, E302, E303, W101, W401, W402; E203, E304, E305, E400, W111 und die Phasentest-Warnungen W601–W999 (§4.7) ergänzt; E217-Hook-Pfad klein; §6 mit dreistelligen Codes. CMakeCraft v0.14.1: E501 und W502 entfallen; E503 mit den drei Fassungen aus `system/Handler.cmake`, E504 und E505 ausgelöst und mit Meldung; Meldungen von E502 und W501; E103, E217, W001, W002, W105 (W106–W108) und W301 als derzeit nicht ausgelöst gekennzeichnet; §6 mit mehrteiliger Meldung** |
| **1.6.0** | **2026-11-07** | **E105 (compile_options an INTERFACE-Library) und E106 (Quellpaket nicht abbildbar) hinzugefügt, CMakeCraft v0.14.0** |
| 1.5.0 | 2026-10-24 | **E005 hinzugefügt (Top-Level-CMakeLists.txt ohne project(), CMakeCraft v0.13.0)** |
| 1.4.0 | 2026-10-23 | E004 hinzugefügt (ungültiger Wert im settings-Block, CMakeCraft v0.12.0) |
| **1.3.0** | **2026-10-09** | **E220, W112 und W304 hinzugefügt (Pakete und Archive Externals, CMakeCraft v0.10.0)** |
| 1.2.0 | 2026-08-08 | E219 und W303 (unvollständiger Klon im Cache) hinzugefügt; E218 nachdokumentiert; W302-Beschreibung auf den Code korrigiert (beschrieb bis dahin „Hook-Wiederverwendung") |
| 1.1.0 | 2025-12-28 | E003 (Schema Major inkompatibel), W101/W102 (Schema Minor Warnungen) hinzugefügt |
| 1.0.0 | 2025-12-14 | Blueprint v0.5.0 Format: Nummeriertes TOC, E3xx (Tests), E4xx/W4xx (AppContainer), E5xx/W5xx (System Externals), W3xx (Caching) |
| 0.1.1 | 2025-12-09 | E217 hinzugefügt (PostFetch Hook required for cmakeSupport=false) |
| 0.1.0 | 2025-12-03 | Initial (Clean Start): Alle Codes aus v1.4 |
