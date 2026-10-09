# Neues Projekt mit CMakeCraft — Bedienungsanleitung

> **Version:** 1.0.0
> **Datum:** 2026-07-17
> **Typ:** Guide
> **Status:** Entwurf
> **Zielgruppe:** Entwickler, die ein neues, eigenständiges Projekt-Repo auf Basis von CMakeCraft aufsetzen
> **Sprache:** Deutsch

---

## Inhaltsverzeichnis

1. [Übersicht & Rollenverteilung](#1-übersicht--rollenverteilung)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Neues Projekt anlegen — Schritt für Schritt](#3-neues-projekt-anlegen--schritt-für-schritt)
4. [Externals & proprietäre Libraries (BASS & Co.)](#4-externals--proprietäre-libraries-bass--co)
5. [CMakeCraft erweitern oder korrigieren](#5-cmakecraft-erweitern-oder-korrigieren)
6. [Was wird wo versioniert?](#6-was-wird-wo-versioniert)
7. [Troubleshooting](#7-troubleshooting)
8. [Siehe auch](#8-siehe-auch)

---

## 1. Übersicht & Rollenverteilung

CMakeCraft ist der **Werkzeugkasten**, dein Projekt ist das **Werkstück**. Daraus folgt die
wichtigste Regel dieses Guides:

> **Versioniert wird das Projekt (z. B. LumiViz) in seinem eigenen Repo.
> CMakeCraft wird separat in seinem eigenen Repo versioniert und ist die
> Single Source of Truth (SSOT) für alle `cmake/`-Module.
> Die `cmake/`-Kopie im Projekt ist ein Snapshot — niemals der Ort der Wahrheit.**

| Rolle | Repo | Enthält | Ändert sich durch |
|---|---|---|---|
| **Build-System** | `CMakeCraft/` | `cmake/` (core, project, externals, buildSystemTest), `templates/`, Build-System-Doku | Build-System-Entwicklung (eigene Commits/Tags) |
| **Projekt** | z. B. `LumiViz/` | `Solution.json`, `projects/`, `externals/`, Presets, App-Doku — **plus Snapshot von `cmake/`** | Projektentwicklung; Build-System nur per Sync (§5) |

> **Stand seit v0.7.0 (2026-07-18):** Der Bezug läuft über **Bootstrap-Fetch** — das Projekt
> committet nur noch `CMakeCraftBootstrap.cmake` + `cmakecraft.pin` (Version); das Build-System
> wird beim Configure nach `.externals/cmakecraft/<version>/` geholt. Ein `cmake/`-Snapshot im
> Projekt ist damit Geschichte (Konzept: `docs/de/konzepte/Konzept_Versionierter_Bezug.md`).

---

## 2. Voraussetzungen

- **CMake ≥ 3.26**, ein C++20-Compiler (MSVC, Clang), **Ninja** und/oder Visual Studio 2022+
- **Git**
- Optional je nach Projekt: **Qt6** (Pfad für `QT_ROOT`), weitere SDKs
- Eine lokale **CMakeCraft-Arbeitskopie** (dieses Repo)

---

## 3. Neues Projekt anlegen — Schritt für Schritt

### Schritt 1: Projektordner und Git-Repo

```bash
mkdir MeinProjekt && cd MeinProjekt
git init
```

### Schritt 2: Bootstrap-Dateien übernehmen (KEIN cmake/-Snapshot mehr)

Die drei Pflichtdateien liegen als Vorlage in CMakeCraft unter
[`templates/consumer/`](../../../../templates/consumer/) — von dort in den
Projekt-Root kopieren:

| Datei | Zweck | Pflicht? |
|---|---|---|
| `CMakeCraftBootstrap.cmake` | holt CMakeCraft in der gepinnten Version nach `.externals/` — **unverändert** übernehmen | ✅ |
| `cmakecraft.pin` | **die** Versionsangabe (Tag) + Quellen (GitHub-URL, lokale Fallbacks) | ✅ |
| `CMakeLists.txt` | Dünnfassung (s. u.) | ✅ |
| `CMakePresets.json` | Projekt-Presets (aus CMakeCraft kopieren) | ✅ |
| `.gitignore`, `.gitattributes` | inkl. der bewussten Externals-Regeln (§4!) | ✅ |
| `clang-format`, `clang-tidy` | Code-Konventionen | empfohlen |
| `templates/` + `templates/Solution.json` | Vorlagen für Apps/Source.cmake/Solution | empfohlen |

Die komplette Top-Level-`CMakeLists.txt` eines Konsumenten:

```cmake
cmake_minimum_required(VERSION 3.26)
include("${CMAKE_CURRENT_LIST_DIR}/CMakeCraftBootstrap.cmake")
```

### Schritt 3: Version pinnen

In `cmakecraft.pin` die gewünschte CMakeCraft-Version (Git-Tag) eintragen — das ist der
**einzige** Ort, an dem die Build-System-Version steht:

```cmake
set(CMAKECRAFT_VERSION "v0.10.0")
set(CMAKECRAFT_GIT_URL "https://github.com/PatrikNeunteufel/CMakeCraft.git")
set(CMAKECRAFT_FALLBACK_PATHS "../CMakeCraft")
```

Für die **Build-System-Entwicklung** gegen eine Arbeitskopie (ohne Klon/Tag):
Configure mit `-DCMAKECRAFT_LOCAL_DIR=../CMakeCraft`.

### Schritt 4: Benutzer-Presets anlegen (lokal, nicht committen)

`CMakeUserPresets.json` enthält **maschinenspezifische** Pfade (z. B. `QT_ROOT`) und gehört
darum nicht ins Repo — committe stattdessen eine `CMakeUserPresets.example.json` als Vorlage:

```jsonc
// CMakeUserPresets.json (lokal)
{
  "version": 6,
  "configurePresets": [
    {
      "name": "user-paths", "hidden": true,
      "cacheVariables": { "QT_ROOT": "C:/Qt/6.7.0/msvc2022_64" }
    }
  ]
}
```

Details: [CMakeUserPresets.md](CMakeUserPresets.md)

### Schritt 5: Solution.json aufsetzen

Die Solution.json ist das Herzstück — **was nicht drinsteht, existiert nicht**. Minimal:

```jsonc
{
  "schemaVersion": "1.0",
  "solution": { "name": "MeinProjekt", "version": "0.1.0" },
  "settings": {
    "standards": { "cxx_standard": 20 },
    "sources": { "mode": "explicit" }
  },
  "externals": { },
  "libraries": [ ],
  "executables": [ ],
  "apps": [ ]
}
```

Referenz aller Felder: [Solution_Schema.md](../references/Solution_Schema.md) ·
Cheatsheet: [Solution_Cheatsheet.md](../cheatsheets/Solution_Cheatsheet.md)

### Schritt 6: Erste App / erstes Executable

- **App-Container** (Core-Lib + Runner + Tests + PCH): [App_Creation_Guide.md](App_Creation_Guide.md)
  — Startpunkt ist eine Kopie von `templates/App/` nach `projects/apps/<Name>/`.
- **Einfaches Executable / Library**: [Getting_Started.md](Getting_Started.md), Abschnitte 6–7.
- **Source-Listen sind explizit**: jede neue Datei in die zugehörige `Source.cmake` eintragen
  (`list(APPEND …)`, nie globben) — Format siehe [templates/README.md](../../../templates/README.md).

### Schritt 7: Konfigurieren und Bauen

```bash
cmake --preset vs-debug        # oder: ninja-debug / ninja-release
cmake --build --preset build
```

Beim ersten Configure werden Git-Externals (falls deklariert) nach `.externals/` gefetcht —
dafür ist einmalig Netz nötig. Build-Ausgaben landen unter `out/`.

### Schritt 8: Erster Commit

```bash
git add .
git commit -m "chore: Projekt-Setup mit CMakeCraft-Snapshot @<hash>"
```

Checkliste, was im ersten Commit **nicht** enthalten sein darf: `out/`, `.externals/`,
`CMakeUserPresets.json`, proprietäre Binaries (§4). Die kopierte `.gitignore` regelt das —
**nicht aufweichen** (§4).

---

## 4. Externals & proprietäre Libraries (BASS & Co.)

### 4.1 Die vier Externals-Quellen

| Quelle | Deklaration in Solution.json | Beispiel |
|---|---|---|
| **local** | `"path": "externals/<name>"` — liegt im Projekt-Repo | doctest, bass (SDK-Struktur), glad, lua54 |
| **fetched** | `"git": "<url>", "tag": "…"` — wird beim Configure nach `.externals/` geholt | qt-ads, googletest |
| **system** | `"system": true, "package": "…"` — via find_package | Qt6, onnxruntime |
| **archive** | `"archive": true, "pin": "<name>.pin"` — fertiges Paket in gepinnter Version, wird beim Configure nach `.externals/<name>/<version>/` geholt (seit v0.10.0) | sichttest |

Anleitung zum Einbinden: [Adding_Externals.md](Adding_Externals.md) · [Externals.md](Externals.md) ·
Pakete schnüren und beziehen: [Packages.md](../references/Packages.md)

### 4.2 Proprietäre Binaries: bewusst NICHT im Repo

Bei lizenzpflichtigen Libraries (namentlich **BASS**, un4seen) gilt:

- **Getrackt:** die SDK-*Struktur* (Header, Beispiel-Quellen, Doku) unter `externals/bass/`.
- **Bewusst untracked:** alle *Binaries* — Import-Libs (`win/c/x64/*.lib`), DLLs (`win/x64/`),
  Linux-Libs (`linux/libs/`), Beispiel-EXEs (`bin/`). Die .gitignore-Regeln `x64/`, `x86/`,
  `[Bb]in/` halten sie draußen. **Das ist Absicht (Lizenz) — niemals per `!externals/**`
  „reparieren" und niemals committen.**

**Konsequenz:** Ein frischer Klon/Checkout baut erst, wenn die Binaries lokal beschafft wurden.
Der typische Fehler sieht so aus:

```
…/externals/bass/bass24/win/c/x64/bass.lib', needed by '…', missing and no known rule to make it
```

### 4.3 Binaries bei Bedarf beschaffen

**Variante A — aus einer bestehenden Arbeitskopie kopieren** (übernimmt exakt die
ignorierten Dateien in korrekter Struktur):

```bash
cd <funktionierende-Arbeitskopie>
git ls-files -o -i --exclude-standard -z -- externals \
  | tar --null -cf - -T - | (cd <neues-Projekt> && tar -xf -)
```

**Variante B — Download von un4seen.com:** je benötigtem Addon das ZIP laden und in die
vorhandene SDK-Struktur entpacken. Was wohin gehört und welche Pakete ein Projekt braucht,
steht in der `externals/bass/SETUP.md` des jeweiligen Projekts
(Vorlage: [LumiViz/externals/bass/SETUP.md](../../../../LumiViz/externals/bass/SETUP.md)).

**Regeln für neue Projekte mit BASS:**
1. SDK-Struktur aus einem bestehenden Projekt oder von un4seen übernehmen und committen
   (ohne Binaries — die .gitignore erledigt das).
2. `externals/bass/SETUP.md` mitkopieren/anpassen und **committen**, damit sich jeder
   frische Checkout selbst erklärt.
3. Binaries per Variante A oder B lokal beschaffen.
4. In Solution.json deklarieren, z. B. `"bass": { "path": "externals/bass" }` und im
   App-Block `"external_options": { "bass": { "BASS_FLAC": true } }`.

---

## 5. CMakeCraft erweitern oder korrigieren

Früher oder später braucht ein Projekt etwas, das CMakeCraft (noch) nicht kann — ein neues
External-Include, einen Fetch-Hook, einen Fix in einem core-Modul. **Der Reflex „ich ändere
schnell die cmake/-Datei im Projekt" ist der Anfang der Divergenz** — genau so sind früher
Projekt- und Template-Stand auseinandergelaufen. Darum:

### 5.1 Standard-Weg (Erweiterung/Korrektur)

```
CMakeCraft ändern → gegen das Projekt testen → committen + taggen → Pin bumpen
```

1. **In der CMakeCraft-Arbeitskopie ändern** (einzig zulässiger Ort — im Projekt liegt kein
   Build-System-Code mehr).
2. **Testen:**
   ```bash
   # Selbsttest des Build-Systems (im CMakeCraft-Repo):
   cmake --preset craft-selftest
   # das anfordernde Projekt DIREKT gegen die Arbeitskopie bauen (kein Klon/Tag noetig):
   cmake --preset <projekt-preset> -DCMAKECRAFT_LOCAL_DIR=../CMakeCraft
   ```
3. **In CMakeCraft committen und Tag setzen** (z. B. `v0.7.1`) — Konsumenten pinnen Tags.
4. **Im Projekt den Pin bumpen:** in `cmakecraft.pin` die neue Version eintragen,
   `CMAKECRAFT_LOCAL_DIR` wieder leeren (Cache-Variable löschen oder auf "" setzen),
   Configure prüft den frischen Klon. Commit:
   ```
   chore(buildsystem): CMakeCraft v0.7.1 — <was die Version bringt>
   ```

### 5.2 Notfall-Weg (Fix fällt mitten in der Projektarbeit an)

1. Fix in der CMakeCraft-**Arbeitskopie** machen und im Projekt sofort mit
   `-DCMAKECRAFT_LOCAL_DIR=../CMakeCraft` weiterarbeiten — kein Warten auf Tag/Release.
2. Sobald der Fix steht: in CMakeCraft committen, Tag setzen, Pin bumpen (§5.1 Schritt 3–4).
3. **Nie** mit dauerhaft gesetztem `CMAKECRAFT_LOCAL_DIR` committen/abschließen — der Override
   ist ein Arbeitszustand, kein Projektzustand (er steht bewusst nur im CMake-Cache, nie im Repo).
   Übergangsweise darf der Pin auch auf einen **Branch** zeigen (`CMAKECRAFT_VERSION "master"`),
   muss aber vor Projekt-Releases wieder auf einen Tag.

### 5.3 Was gehört wohin?

| Änderung | Ort |
|---|---|
| Neues Target, neue App, External **deklarieren**, Optionen | **Projekt** (Solution.json, projects/) |
| Neues External-**Include** (`cmake/externals/includes/<name>/`), Pre-/Post-Fetch-**Hook**, neuer **Error-Code**, Fix in core/project-Modulen, neue Template-Variante | **CMakeCraft** (dann Sync) |
| Projekt-spezifische Presets | **Projekt** (`CMakePresets.json` des Projekts / UserPresets lokal) |
| Doku zum Build-System | **CMakeCraft** (`docs/`) |
| Doku zur App | **Projekt** |

Faustregel: **Könnte ein zweites Projekt davon profitieren → CMakeCraft.**

---

## 6. Was wird wo versioniert?

| Artefakt | Projekt-Repo | CMakeCraft-Repo | nur lokal |
|---|---|---|---|
| Solution.json, projects/, App-Doku | ✅ | | |
| `cmake/`-Snapshot + `BUILDSYSTEM_VERSION.md` | ✅ (als Kopie) | ✅ (als SSOT) | |
| templates/, Build-System-Doku | (Kopie optional) | ✅ | |
| externals/ SDK-Strukturen + SETUP.md | ✅ | | |
| **Proprietäre Binaries (bass.lib, DLLs, …)** | ❌ nie | ❌ nie | ✅ |
| CMakeUserPresets.json (lokale Pfade) | ❌ (nur .example) | ❌ | ✅ |
| out/, .externals/, .vs/ | ❌ | ❌ | ✅ |

Empfehlung: für beide Repos ein **gehostetes Remote** (z. B. GitHub) zusätzlich zu lokalen
Kopien/USB — Klone von USB-Sticks haben schon Dateien verloren.

---

## 7. Troubleshooting

| Symptom | Ursache | Lösung |
|---|---|---|
| `…/externals/bass/…/x64/bass.lib … missing and no known rule to make it` | Proprietäre Binaries sind bewusst untracked (§4.2) | Beschaffen nach §4.3 / SETUP.md |
| Configure-Fehler `E002 Solution.json not found` | Solution.json fehlt/falscher Ort | Solution.json im Projekt-Root anlegen (§3.5) |
| `E010 External not defined` | Target referenziert External, das im `externals`-Block fehlt | Solution.json ergänzen; [ErrorCodes.md](../references/ErrorCodes.md) |
| qt-ads/Git-External fehlt | `.externals/` noch nicht gefetcht (erster Configure braucht Netz) | Configure mit Netzverbindung wiederholen |
| Qt nicht gefunden | `QT_ROOT` nicht gesetzt | `CMakeUserPresets.json` (§3.4) |
| Neue Datei wird nicht gebaut | nicht in `Source.cmake` eingetragen | `list(APPEND …)` ergänzen (§3.6) |
| Linker: `undefined symbol … staticMetaObject / qt_metacall / Signale` | AUTOMOC lief nicht — `cmake/externals/system/packages/Qt6.cmake` fehlt im Checkout (historisch: VS-Regel `**/packages/*` hatte sie verschluckt) | Snapshot-Sync aus CMakeCraft (§5.1 Schritt 4); danach frisch konfigurieren |
| `[Bootstrap] … konnte aus keiner Quelle geholt werden` | kein Netz + kein Cache + kein lokaler Fallback | Netz herstellen, `CMAKECRAFT_FALLBACK_PATHS` auf lokalen Checkout zeigen lassen, oder `-DCMAKECRAFT_LOCAL_DIR=<pfad>` |
| `CMake Warning (dev): No project() command is present` beim Configure | erwartet: `project()` wird im CMakeCraft-Entry-Point gerufen, nicht wörtlich in der Dünnfassungs-CMakeLists | harmlos — ignorieren (oder `-Wno-dev`) |
| Build-System verhält sich „alt" trotz neuem Pin | `.externals/cmakecraft/<version>/` ist ein Cache pro Version; gleicher Tag wird nie neu geholt | Tags nie umhängen! Neuer Stand = neuer Tag. Notfalls `.externals/cmakecraft/` löschen |
| Build-System verhält sich anders als erwartet | vergessener `CMAKECRAFT_LOCAL_DIR`-Override im Cache | Configure-Ausgabe prüfen (`[Bootstrap] … LOKAL-OVERRIDE`); Variable leeren |
| CLI: `Could not read presets` / VS zeigt nur noch x64-Debug-Standardkonfigurationen | Preset-Datei verletzt das Schema. Achtung: **Preset-JSONs vertragen KEINE Kommentare** — `/* */` bricht das CLI, `"$comment"` bräuchte Schema v10 (CMake ≥ 3.31), aber Visual Studio kann nur v2–v9 und fällt bei v10 still auf Default-Konfigurationen zurück | Presets über `displayName`/`description` dokumentieren, Schema-Version 6 belassen. Kommentar-Konvention `"_comment"` gilt nur für **Nicht-Preset-JSONs** (z. B. Solution.json). Nach Reparatur: in VS den Ordner neu laden |

Mehr: [Getting_Started.md](Getting_Started.md) Abschnitt 12–13 · Debug-Ausgaben via
`-DDEBUG_MESSAGES=ON -DDEBUG_DEFAULT_LEVEL=3`

---

## 8. Siehe auch

- [Getting_Started.md](Getting_Started.md) — Grundlagen, erstes Executable/Library
- [App_Creation_Guide.md](App_Creation_Guide.md) — App-Container (Core/Runner/Tests/PCH)
- [Adding_Externals.md](Adding_Externals.md) · [Externals.md](Externals.md) — Externals einbinden
- [CMakeUserPresets.md](CMakeUserPresets.md) — Benutzer-Presets
- [Solution_Schema.md](../references/Solution_Schema.md) — Schema-Referenz
- [Testing.md](Testing.md) — Tests mit doctest
- `externals/bass/SETUP.md` (im jeweiligen Projekt) — BASS-Binaries beschaffen

---

## Changelog

- **1.1.0** (2026-10-09): CMake 3.26, Pin-Beispiel v0.10.0, vierte Externals-Quelle `archive` (§4.1)
- **1.0.0** (2026-07-17): Erstfassung — Projekt-Setup, Lib-Beschaffung, Sync-Workflow (SSOT CMakeCraft)
