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

> **Hinweis:** Aktuell wird der Snapshot manuell synchronisiert (dieser Guide, §5).
> Geplant ist ein Bootstrap-/Submodule-Bezug mit gepinnter Version („Phase 1"), der den
> manuellen Sync ersetzt — die Regeln in §5 bleiben dieselben, nur der Kopierschritt entfällt.

---

## 2. Voraussetzungen

- **CMake ≥ 3.25**, ein C++20-Compiler (MSVC, Clang), **Ninja** und/oder Visual Studio 2022+
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

### Schritt 2: Build-System-Snapshot aus CMakeCraft kopieren

Diese Dateien/Ordner werden aus der CMakeCraft-Arbeitskopie kopiert:

| Aus CMakeCraft | Zweck | Pflicht? |
|---|---|---|
| `CMakeLists.txt` | Top-Level-Einstieg (lädt `cmake/`-Module, liest Solution.json) | ✅ |
| `cmake/` | das komplette Build-System (core, project, externals, buildSystemTest) | ✅ |
| `templates/` | Vorlagen für Apps/Source.cmake (nur als Kopierquelle) | empfohlen |
| `CMakePresets.json` | Projekt-Presets (vs-debug, ninja-release, …) | ✅ |
| `.gitignore`, `.gitattributes` | inkl. der bewussten Externals-Regeln (§4!) | ✅ |
| `clang-format`, `clang-tidy` | Code-Konventionen | empfohlen |
| `templates/Solution.json` | Startpunkt für die eigene Solution.json | ✅ (als Vorlage) |

```bash
# im neuen Projektordner (Pfade anpassen):
CRAFT=../CMakeCraft
cp $CRAFT/CMakeLists.txt $CRAFT/CMakePresets.json $CRAFT/.gitignore $CRAFT/.gitattributes \
   $CRAFT/clang-format $CRAFT/clang-tidy .
cp -r $CRAFT/cmake $CRAFT/templates .
cp $CRAFT/templates/Solution.json ./Solution.json
```

### Schritt 3: Herkunft dokumentieren (wichtig!)

Solange der Snapshot manuell gepflegt wird, muss nachvollziehbar sein, **welcher
CMakeCraft-Stand** im Projekt steckt. Lege `BUILDSYSTEM_VERSION.md` im Projekt-Root an:

```bash
echo "CMakeCraft-Snapshot: $(git -C $CRAFT rev-parse --short HEAD) ($(date +%F))" > BUILDSYSTEM_VERSION.md
```

Diese Datei wird bei **jedem Sync** (§5) aktualisiert und mitcommittet.

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
Cheatsheet: [Solution_Cheatsheet.md](../cheatsheet/Solution_Cheatsheet.md)

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

### 4.1 Die drei Externals-Quellen

| Quelle | Deklaration in Solution.json | Beispiel |
|---|---|---|
| **local** | `"path": "externals/<name>"` — liegt im Projekt-Repo | doctest, bass (SDK-Struktur), glad, lua54 |
| **fetched** | `"git": "<url>", "tag": "…"` — wird beim Configure nach `.externals/` geholt | qt-ads, googletest |
| **system** | `"system": true, "package": "…"` — via find_package | Qt6, onnxruntime |

Anleitung zum Einbinden: [Adding_Externals.md](Adding_Externals.md) · [Externals.md](Externals.md)

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

### 5.1 Standard-Weg (geplante Erweiterung/Korrektur)

```
CMakeCraft ändern → dort testen → dort committen → ins Projekt syncen
```

1. **In der CMakeCraft-Arbeitskopie ändern** (nicht im Projekt!).
2. **Testen** mit den Phasentests des Build-Systems:
   ```bash
   cmake --preset ninja-debug -DRUN_BUILD_SYSTEM_TESTS=ON        # alle Phasen
   cmake --preset ninja-debug -DRUN_BUILD_SYSTEM_TESTS=ON -DTEST_PHASE=6   # gezielt
   ```
   Zusätzlich: das anfordernde Projekt einmal gegen den geänderten Stand bauen (Schritt 4
   vorziehen), bevor committet wird.
3. **In CMakeCraft committen** — aussagekräftig, mit Error-Code-/Modul-Bezug. Bei
   release-würdigen Ständen **Tag** setzen (z. B. `v0.6.1`); Konventionen:
   [Guidelines.md](../../en/projects/buildsystem/standards/Guidelines.md) *(Pfad im
   jeweiligen Projekt: Build-System-Standards)*.
4. **Ins Projekt synchronisieren** — den kompletten `cmake/`-Baum spiegeln, nicht einzelne
   Dateien picken (verhindert Teil-Syncs):
   ```powershell
   # Windows (PowerShell), im Projekt-Root:
   robocopy ..\CMakeCraft\cmake .\cmake /MIR
   ```
   ```bash
   # Git Bash, im Projekt-Root:
   rm -rf cmake && cp -r ../CMakeCraft/cmake .
   ```
   Falls sich auch `CMakeLists.txt` oder `templates/` geändert haben: mitkopieren.
5. **`BUILDSYSTEM_VERSION.md` aktualisieren** (neuer Hash/Tag + Datum).
6. **Im Projekt committen:**
   ```
   chore(buildsystem): sync CMakeCraft @<hash> — <was der Sync bringt>
   ```

### 5.2 Notfall-Weg (Fix fällt mitten in der Projektarbeit an)

Es ist erlaubt, im Projekt **lokal** zu fixen, um nicht blockiert zu sein — aber mit Pflichten:

1. Fix im Projekt-`cmake/` machen, weiterarbeiten.
2. **Noch am selben Tag** den Fix nach CMakeCraft zurückspielen (Datei rüberkopieren,
   Phasentests, Commit in CMakeCraft).
3. Danach regulären Sync (§5.1 Schritt 4–6) ausführen, damit Projekt-Snapshot == CMakeCraft.
4. **Nie** einen Projekt-Commit machen, der cmake/-Änderungen enthält, ohne dass dieselbe
   Änderung in CMakeCraft committet ist. Divergenz-Check jederzeit:
   ```bash
   git diff --no-index ../CMakeCraft/cmake ./cmake   # leer = synchron
   ```

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
| Build-System verhält sich anders als in CMakeCraft | Snapshot divergiert | `git diff --no-index ../CMakeCraft/cmake ./cmake`, dann Sync (§5.1) |
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

- **1.0.0** (2026-07-17): Erstfassung — Projekt-Setup, Lib-Beschaffung, Sync-Workflow (SSOT CMakeCraft)
