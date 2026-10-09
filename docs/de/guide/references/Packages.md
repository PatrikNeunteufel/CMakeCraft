# Pakete schnüren und beziehen — Referenz

> **Version:** 1.0.0  
> **Datum:** 2026-10-09  
> **Typ:** Reference  
> **Status:** Stabil  
> **Zielgruppe:** Alle Entwickler  
> **Sprache:** Deutsch  
> **English:** [Packages.md](../../../en/guide/references/Packages.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Schnüren: Block `packages`](#2-schnüren-block-packages)
3. [Beziehen: External-Art `archive`](#3-beziehen-external-art-archive)
4. [Die Pin-Datei](#4-die-pin-datei)
5. [Ohne CMakeCraft: `CMakeCraftPackage.cmake`](#5-ohne-cmakecraft-cmakecraftpackagecmake)
6. [Felder für Bibliotheken: `output_name`, `defines`](#6-felder-für-bibliotheken-output_name-defines)
7. [Fehler und Warnungen](#7-fehler-und-warnungen)
8. [Siehe auch](#8-siehe-auch)
9. [Changelog](#9-changelog)

---

## 1. Übersicht

Seit v0.10.0 kann ein Projekt ein **fertiges Paket** erzeugen (Köpfe, gebaute Dateien, ganze
Ausgabeordner) und ein anderes Projekt kann es in **gepinnter Version** beziehen.

| Seite | Mittel | Ergebnis |
|-------|--------|----------|
| Schnüren | Block `packages` in `Solution.json` | Target `package_<name>` schreibt Ordner, `.zip` und `.zip.sha256` nach `<Projekt>/out/package/` |
| Beziehen | External mit `"archive": true` und Pin-Datei | Include-Pfad, Define und Laufzeitdateien an jedem Target, das das External nennt |
| Beziehen ohne CMakeCraft | `CMakeCraftPackage.cmake` direkt einbinden | dieselbe Logik als zwei Funktionen |

Nichts davon ist von sich aus aktiv. Ein Projekt ohne `packages` und ohne Archiv-External
verhält sich wie zuvor. Voraussetzung ist **CMake 3.26**.

Das Hochladen eines Pakets (etwa als Release) ist nicht Teil des Build-Systems.

---

## 2. Schnüren: Block `packages`

```json
"packages": [
    {
        "name": "sichttest",
        "archive": "sichttest-v{version}-win64",
        "config": "Release",
        "contents": [
            { "to": "include",   "headers_of": "SichttestSteuerung",
              "files": ["sichttest_steuerung.h", "sichttest_steuerung.hpp"] },
            { "to": "bin",       "binary_of": "SichttestSteuerung" },
            { "to": "sichttest", "output_dir_of": "Sichttest", "exclude": ["*.pdb", "*.ilk"] }
        ],
        "version_file": "packaging/VERSION.in"
    }
]
```

### 2.1 Felder

| Feld | Pflicht | Typ | Beschreibung |
|------|---------|-----|--------------|
| `name` | ✅ | string | Paketname; das Target heißt `package_<name>` |
| `contents` | ✅ | array | Was ins Paket kommt (§2.2) |
| `archive` | – | string | Name von Ordner und Archiv; `{version}` ist die Version der Solution. Default: `<name>-v{version}` |
| `config` | – | string | Einzige Konfiguration, aus der geschnürt werden darf (z. B. `"Release"`). Ohne Angabe: jede |
| `version_file` | – | string | Schablone relativ zum Projekt; `@VERSION@` wird durch die Version der Solution ersetzt, das Ergebnis liegt als `VERSION` im Paket |

### 2.2 Einträge in `contents`

Jeder Eintrag nennt mit `to` den Zielordner im Paket und **genau eine** Quelle:

| Quelle | Wert | Kopiert wird |
|--------|------|--------------|
| `headers_of` | Name einer Bibliothek | ihr Ordner `public_headers`; mit `files` nur die genannten Dateien |
| `binary_of` | Name eines Targets | die gebaute Datei des Targets (bei einer DLL die `.dll`), mit ihrem `output_name` |
| `output_dir_of` | Name eines Targets | der Ausgabeordner des Targets **mit allen Unterordnern** — also auch, was `windeployqt` dort ablegt |
| `from` | Ordner relativ zum Projekt | der Ordner; mit `files` nur die genannten Dateien |

| Zusatzfeld | Gilt für | Beschreibung |
|------------|----------|--------------|
| `files` | `headers_of`, `from` | Liste von Dateien relativ zur Quelle |
| `exclude` | `output_dir_of`, `headers_of`/`from` ohne `files` | Muster auf Dateinamen (`*.pdb`), wirken in jeder Tiefe |

### 2.3 Aufruf und Ergebnis

```bash
cmake --build <build> --target package_sichttest
```

Das Target gehört nicht zu `ALL`. Es baut zuerst die genannten Targets und schreibt dann nach
`<Projekt>/out/package/`:

```
out/package/
├── sichttest-v0.2.0-win64/           der Paketordner
├── sichttest-v0.2.0-win64.zip        derselbe Ordner als Archiv (ein Ordner auf oberster Ebene)
└── sichttest-v0.2.0-win64.zip.sha256 Prüfsumme im Format von sha256sum
```

- Der Paketordner wird bei jedem Lauf **neu aufgebaut** (löschen, dann kopieren).
- Weicht die Konfiguration von `config` ab, bricht das Target mit Klartext ab; ein
  vorhandenes Paket bleibt stehen.
- `out/package/` gehört in die `.gitignore` des Projekts.

> **Die Prüfsumme gilt für genau diese Datei.** Zwei Läufe mit gleichem Inhalt ergeben
> verschiedene Prüfsummen (das Archiv trägt Zeitstempel). In eine Pin-Datei gehört deshalb die
> Prüfsumme der **veröffentlichten** Datei, nicht die eines späteren Laufs.

### 2.4 Die Datei `VERSION`

Der Bezug (§3) prüft im Paket die Zeile `produkt=<Version>` gegen den Pin. Ein Paket, das
bezogen werden soll, braucht deshalb eine `version_file`, deren Schablone diese Zeile trägt:

```
produkt=@VERSION@
```

Weitere Zeilen sind frei.

---

## 3. Beziehen: External-Art `archive`

```json
"externals": {
    "sichttest": {
        "archive": true,
        "pin": "sichttest.pin",
        "platforms": ["windows"],
        "include_dirs": ["include"],
        "define": "SICHTTEST_VORHANDEN",
        "runtime": { "files": ["bin/SichttestSteuerung1.dll"], "dirs": ["sichttest"] }
    }
}
```

### 3.1 Felder

| Feld | Pflicht | Typ | Beschreibung |
|------|---------|-----|--------------|
| `archive` | ✅ | boolean | Muss `true` sein |
| `pin` | ✅ | string | Pin-Datei relativ zum Projekt (§4) |
| `platforms` | – | string[] | `windows`, `linux`, `macos`, `unix`; auf jeder anderen Plattform fehlt das External, ohne Warnung |
| `include_dirs` | – | string[] | Include-Ordner im Paket. Es wird **nichts gelinkt** |
| `define` | – | string | Define `<Name>=1` an jedem Target, das das External nennt |
| `runtime.files` | – | string[] | Dateien im Paket, die neben jede Exe kopiert werden |
| `runtime.dirs` | – | string[] | Ordner im Paket, die als gleichnamiger Unterordner neben jede Exe kopiert werden |

Das gemeinsame Feld `skip` gilt wie bei den anderen Arten.

### 3.2 Was ein Target bekommt

Ein Target nennt das External wie jedes andere unter `externals`:

| Target | Include-Pfad | Define | Laufzeitdateien |
|--------|--------------|--------|-----------------|
| Executable | ja | ja | ja — nach jedem Bau, je Konfiguration, nur bei Änderung |
| Bibliothek (STATIC, SHARED) | ja | ja | nein |

Include-Pfad und Define gelten **nur für das Target, das das External nennt** (PRIVATE); sie
vererben sich nicht an Targets, die davon abhängen. Ein Test-Target, das einen Kopf des Pakets
über einen öffentlichen Kopf seiner Bibliothek einbindet, muss das External deshalb selbst
nennen — oder die Bibliothek hält die Einbindung in einer `.cpp`.

Die Laufzeitdateien werden **beim Bau der Exe** kopiert, nicht beim Configure. Nach einem
Wechsel der Paketversion bleibt die alte Kopie neben der Exe liegen, bis die Exe neu gebaut
wird.

Abschalten der Kopien für ein einzelnes Target:

```json
"external_options": { "sichttest": { "runtime": false } }
```

### 3.3 Fehlt das Paket

Lässt sich das Paket nicht beziehen, ist das **kein Fehler**: Es gibt die Warnung W304, und
die Targets bekommen weder Include-Pfad noch Define noch Kopien. Der Quelltext unterscheidet
über das Define:

```cpp
#ifdef SICHTTEST_VORHANDEN
#  include <sichttest_steuerung.hpp>
#endif
```

### 3.4 Reihenfolge der Quellen

`<NAME>` ist der Name des Externals in Großbuchstaben.

| # | Quelle | Bemerkung |
|---|--------|-----------|
| 1 | `-D<NAME>_LOCAL_DIR=<Ordner>` | ausgepacktes Paket, wird ungeprüft benutzt (Entwicklung) |
| 2 | Zwischenspeicher `<Ordner der Pin-Datei>/.externals/<name>/<version>/` | gilt, wenn `VERSION` dort zum Pin passt |
| 3 | Herunterladen von `<NAME>_URL` | Prüfsumme `<NAME>_SHA256` |
| 4 | `<NAME>_FALLBACK_PATHS` | Ordner, in denen dieselbe Archivdatei liegt; gleiche Prüfsumme |

Ist das Paket einmal im Zwischenspeicher, braucht kein weiterer Configure das Netz.

Der Zwischenspeicher gilt über die **Version**, nicht über die Prüfsumme. Wird ein Paket unter
derselben Version neu geschnürt, bleibt der alte Inhalt liegen, bis der Ordner
`.externals/<name>/<version>/` gelöscht ist.

---

## 4. Die Pin-Datei

Ein CMake-Skript mit vier Variablen, Vorbild `cmakecraft.pin`:

```cmake
set(SICHTTEST_VERSION "v0.2.0")
set(SICHTTEST_URL     "https://github.com/<Konto>/<Repo>/releases/download/${SICHTTEST_VERSION}/sichttest-${SICHTTEST_VERSION}-win64.zip")
set(SICHTTEST_SHA256  "<64 Hex-Zeichen>")
set(SICHTTEST_FALLBACK_PATHS "../SichtTest_Helper/out/package")
```

| Variable | Pflicht | Beschreibung |
|----------|---------|--------------|
| `<NAME>_VERSION` | ✅ | Gepinnte Version. Ein führendes `v` wird beim Vergleich mit `produkt=` überlesen |
| `<NAME>_URL` | – | Adresse des Archivs. Ihr Dateiname ist auch der, der in den Fallback-Pfaden gesucht wird |
| `<NAME>_SHA256` | ✅ | Prüfsumme des Archivs. Ohne sie wird nichts bezogen |
| `<NAME>_FALLBACK_PATHS` | – | Liste von Ordnern; relative Pfade gelten ab dem Ordner der Pin-Datei |

Der Pin steht **nur** hier; `Solution.json` verweist mit `"pin"` darauf.

---

## 5. Ohne CMakeCraft: `CMakeCraftPackage.cmake`

Die Datei im Wurzelordner von CMakeCraft trägt die ganze Bezugs- und Verteillogik und hängt
von nichts im Kern ab. Ein Projekt, das nicht mit CMakeCraft baut, übernimmt eine
**unveränderte Kopie** (Versionszeile im Kopf) und ruft zwei Funktionen:

```cmake
include("${CMAKE_CURRENT_LIST_DIR}/CMakeCraftPackage.cmake")

craft_package_fetch(NAME sichttest PIN_FILE sichttest.pin OUT_ROOT _sichttest_root)

craft_package_deploy(TARGET MeineApp ROOT "${_sichttest_root}"
    INCLUDE_DIRS  include
    DEFINE        SICHTTEST_VORHANDEN
    RUNTIME_FILES bin/SichttestSteuerung1.dll
    RUNTIME_DIRS  sichttest)
```

| Funktion | Argument | Beschreibung |
|----------|----------|--------------|
| `craft_package_fetch` | `NAME` | Paketname; Präfix der Pin-Variablen in Großbuchstaben |
| | `PIN_FILE` | Pin-Datei (relativ: zu `CMAKE_CURRENT_SOURCE_DIR`) |
| | `CACHE_DIR` | optional: Ordner des ausgepackten Pakets statt des Defaults |
| | `OUT_ROOT` | Variable für die Paketwurzel; leer, wenn das Paket fehlt |
| `craft_package_deploy` | `TARGET` | vorhandenes Target |
| | `ROOT` | Paketwurzel; leer = nichts geschieht |
| | `INCLUDE_DIRS`, `DEFINE` | wie `include_dirs`, `define` |
| | `RUNTIME_FILES`, `RUNTIME_DIRS` | wie `runtime.files`, `runtime.dirs` |
| | `NO_RUNTIME` | nur Include-Pfad und Define |

---

## 6. Felder für Bibliotheken: `output_name`, `defines`

Zum Schnüren gehören zwei Felder, die Bibliotheken seit v0.10.0 kennen:

```json
{
    "name": "SichttestSteuerung",
    "type": "SHARED",
    "output_name": "SichttestSteuerung1",
    "defines": ["STS_PRODUKT=\"{version}\""]
}
```

| Feld | Beschreibung |
|------|--------------|
| `output_name` | Dateiname ohne Endung; der Target-Name bleibt |
| `defines` | Preprocessor-Definitionen, PRIVATE am Target (bei `INTERFACE`: INTERFACE) |

`{version}` in `defines` wird bei Bibliotheken **und** Executables durch die Version des
Targets ersetzt (eigenes `version`, sonst die der Solution).

Wer `output_name` nachträglich setzt, findet die Datei mit dem alten Namen weiter im
Build-Ordner; `binary_of` nimmt die richtige.

---

## 7. Fehler und Warnungen

| Code | Wann | Folge |
|------|------|-------|
| E001 | `packages[]` ohne `name` oder `contents`; Eintrag ohne oder mit mehreren Quellen; `version_file` oder `from`-Ordner fehlt; Bibliothek ohne öffentliche Köpfe | Abbruch |
| E102 | Target `package_<name>` existiert schon | Abbruch |
| E220 | Archiv-External ohne `pin` | Abbruch |
| W112 | Ein Paket nennt ein Target, das es nicht gibt (übersprungen, andere Plattform) | `package_<name>` wird nicht angelegt |
| W304 | Archiv-External nicht verfügbar | Targets bauen ohne das Paket |

Dazu kommen Warnungen aus `CMakeCraftPackage.cmake` mit dem Präfix `[CraftPackage]`; sie
nennen jede versuchte Quelle mit Grund.

---

## 8. Siehe auch

- [Solution_Schema.md](Solution_Schema.md) — Schema der `Solution.json`
- [ErrorCodes.md](ErrorCodes.md) — Fehlercode-Referenz
- [Neues_Projekt_Guide.md](../userguides/Neues_Projekt_Guide.md) — Bezug von CMakeCraft selbst (`cmakecraft.pin`)

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.0.0** | **2026-10-09** | **Erste Fassung zu CMakeCraft v0.10.0** |
