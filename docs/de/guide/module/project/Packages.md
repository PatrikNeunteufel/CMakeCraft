# Packages.cmake — Modul-Dokumentation

> **Version:** 1.0.0  
> **Datum:** 2026-10-09  
> **Typ:** ModuleDoc  
> **Status:** Aktiv  
> **Basiert auf:** ModuleDoc v0.5  
> **Zielgruppe:** Build-System-Entwickler  
> **Sprache:** Deutsch  
> **English:** [Packages.md](../../../../en/guide/module/project/Packages.md)  
> **Modul:** [`cmake/project/Packages.cmake`](../../../../../cmake/project/Packages.cmake)  
> **Modul-Version:** 1.0.0  
> **Phase:** 10 (Packages)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [API-Referenz](#3-api-referenz)
4. [JSON-Mapping](#4-json-mapping)
5. [Verarbeitung](#5-verarbeitung)
6. [Fehlerbehandlung](#6-fehlerbehandlung)
7. [Debug-Ausgaben](#7-debug-ausgaben)
8. [Siehe auch](#8-siehe-auch)
9. [Changelog](#9-changelog)

---

## 1. Übersicht

Das `Packages.cmake` Modul erzeugt je Eintrag des Blocks `packages` in der Solution.json **ein Target `package_<name>`**. Das Target gehört nicht zu `ALL`; es wird gezielt gebaut und schreibt dann ein Paket nach `<Projekt>/out/package/`.

### Ergebnis eines Builds von `package_<name>`

| Pfad in `out/package/` | Inhalt |
|------------------------|--------|
| `<archive>/` | Der zusammengestellte Ordner |
| `<archive>.zip` | Der Ordner als Archiv (ein Ordner auf oberster Ebene) |
| `<archive>.zip.sha256` | Prüfsumme im Format von `sha256sum` |

### Verantwortlichkeiten

| Bereich | Beschreibung |
|---------|--------------|
| JSON-Parsing | Felder eines Package-Eintrags lesen und prüfen |
| Manifest | Je Konfiguration eine Datei `manifest-<CONFIG>.cmake` erzeugen |
| Versionsdatei | Vorlage zur Configure-Zeit nach `<build>/package/<name>/VERSION` konfigurieren |
| Target | `package_<name>` anlegen, Abhängigkeiten auf die gepackten Targets setzen |

Das eigentliche Zusammenstellen geschieht zur Build-Zeit in [PackageBuild.cmake](PackageBuild.md).

### Position im Ablauf

`CMakeCraft.cmake` bindet das Modul als Phase 10 ein — nach Libraries, Executables und Apps (deren Targets müssen existieren) und vor den Tests.

---

## 2. Abhängigkeiten

| Modul | Verwendung |
|-------|------------|
| Errors.cmake | `cmake_fatal`, `cmake_warn` |
| Debug.cmake | `dbg`, `dbg_init`, `enddbgblock` |
| Json.cmake | `_json_get_string`, `_json_get_string_or_default`, `_json_array_length`, `_json_array_get`, `_json_get_array_as_list`, `_json_has_key` |
| Solution.cmake | Global Properties `SOLUTION_JSON`, `SOLUTION_VERSION` |
| PackageBuild.cmake | Wird zur Build-Zeit über `cmake -P` ausgeführt |
| LibraryCreate.cmake | Setzt die Target-Property `CRAFT_PUBLIC_HEADERS_DIR`, die `headers_of` liest |

---

## 3. API-Referenz

### 3.1 _create_package_target()

Erzeugt das Target `package_<name>` aus einem Eintrag von `packages`.

```cmake
_create_package_target(<PKG_JSON>)
```

**Parameter:**

| Parameter | Typ | Pflicht | Beschreibung |
|-----------|-----|---------|--------------|
| `PKG_JSON` | String | ✓ | JSON-String eines Eintrags von `packages` |

**Rückgabe:** Keine (legt Target, Manifest und ggf. Versionsdatei an)

### 3.2 Pipeline beim Einbinden

Beim `include()` liest das Modul `packages` aus der Global Property `SOLUTION_JSON` und ruft `_create_package_target()` je Eintrag auf. Fehlt der Block oder ist er leer, geschieht nichts.

---

## 4. JSON-Mapping

### 4.1 Felder eines Package-Eintrags

| Feld | Pflicht | Default | Beschreibung |
|------|---------|---------|--------------|
| `name` | ✓ | — | Paketname; das Target heißt `package_<name>` |
| `archive` | — | `<name>-v{version}` | Ordner- und Archivname; `{version}` ist die Solution-Version |
| `config` | — | "" | Die einzige Konfiguration, aus der das Paket gebaut werden darf (z.B. `Release`) |
| `version_file` | — | "" | Vorlage relativ zum Projekt-Root; wird mit `@VERSION@` (Solution-Version) konfiguriert und als Datei `VERSION` in die Paketwurzel geschrieben |
| `contents` | ✓ | — | Array der Inhalte, mindestens ein Eintrag |

### 4.2 Felder eines `contents`-Eintrags

Jeder Eintrag hat `to` und **genau eine** Quelle.

| Feld | Beschreibung |
|------|--------------|
| `to` | Zielordner innerhalb des Pakets |
| `headers_of` | Öffentlicher Header-Ordner einer Library (Property `CRAFT_PUBLIC_HEADERS_DIR`), optional durch `files` eingegrenzt |
| `binary_of` | Die gebaute Datei eines Targets (`$<TARGET_FILE:...>`) |
| `output_dir_of` | Der Ausgabeordner eines Targets (`$<TARGET_FILE_DIR:...>`) mit allen Unterordnern, abzüglich `exclude` |
| `from` | Ordner relativ zum Projekt-Root, optional durch `files` eingegrenzt |
| `files` | Array von Dateien relativ zur Quelle; wirkt bei `headers_of` und `from` |
| `exclude` | Array von Mustern, die beim Kopieren eines ganzen Ordners ausgelassen werden |

Daraus ergibt sich die Kopier-Art im Manifest:

| Quelle | Art | Bedeutung |
|--------|-----|-----------|
| `binary_of` | `file` | Eine Datei |
| `headers_of` / `from` mit `files` | `files` | Die genannten Dateien, Unterordner bleiben erhalten |
| alles andere | `dir` | Der ganze Ordner, abzüglich `exclude` |

### 4.3 Beispiel (Demo-Solution)

```json
"packages": [
    {
        "name": "packdemo",
        "archive": "packdemo-v{version}",
        "contents": [
            { "to": "include", "headers_of": "PackDemo", "files": [ "pack_demo.h" ] },
            { "to": "bin", "binary_of": "PackDemo" }
        ],
        "version_file": "projects/demos/packaging/VERSION.in"
    }
]
```

Die Vorlage `projects/demos/packaging/VERSION.in`:

```
produkt=@VERSION@
```

Bauen:

```bash
cmake --build <build> --target package_packdemo
```

---

## 5. Verarbeitung

```
_create_package_target(PKG_JSON)
    │
    ├── 1. name lesen                      → E001 wenn leer
    │      Target package_<name> vorhanden → E102
    │
    ├── 2. archive ({version} ersetzen), config lesen
    │
    ├── 3. contents durchlaufen            → E001 wenn fehlt oder leer
    │   ├── genau eine Quelle?             → E001 sonst
    │   ├── Quelle nennt ein Target, das nicht existiert
    │   │       → W112, Paket wird NICHT angelegt (return)
    │   ├── headers_of ohne öffentliche Header → E001
    │   ├── from: Ordner existiert nicht       → E001
    │   ├── binary_of / output_dir_of → Abhängigkeit auf das Target merken
    │   └── Manifest-Zeilen CRAFT_PKG_ITEM_<i>_{KIND,TO,SRC,FILES,EXCLUDE}
    │
    ├── 4. version_file (falls angegeben)  → E001 wenn nicht gefunden
    │   └── configure_file(... @ONLY) → <build>/package/<name>/VERSION
    │
    ├── 5. Manifest schreiben (file(GENERATE))
    │   └── <build>/package/<name>/manifest-$<CONFIG>.cmake
    │
    └── 6. add_custom_target(package_<name>)
        ├── cmake -DCRAFT_PKG_MANIFEST=<manifest> -P PackageBuild.cmake
        └── add_dependencies(package_<name> <Targets aus Schritt 3>)
```

### Manifest-Variablen

| Variable | Inhalt |
|----------|--------|
| `CRAFT_PKG_NAME` | Paketname |
| `CRAFT_PKG_ARCHIVE` | Ordner- und Archivname |
| `CRAFT_PKG_OUT_DIR` | `${CMAKE_SOURCE_DIR}/out/package` |
| `CRAFT_PKG_REQUIRED_CONFIG` | Wert von `config` |
| `CRAFT_PKG_CONFIG` | `$<CONFIG>` des Builds |
| `CRAFT_PKG_VERSION_FILE` | Pfad der konfigurierten Versionsdatei, oder leer |
| `CRAFT_PKG_ITEMS` | Liste der Inhalts-Indizes |
| `CRAFT_PKG_ITEM_<i>_*` | `KIND`, `TO`, `SRC`, `FILES`, `EXCLUDE` je Inhalt |

Generator-Ausdrücke im Manifest werden zur Generate-Zeit aufgelöst.

---

## 6. Fehlerbehandlung

### 6.1 Fatal Errors

| Code | Bedingung |
|------|-----------|
| E001 | `name` fehlt |
| E001 | `contents` fehlt oder ist leer |
| E001 | Ein `contents`-Eintrag hat nicht genau eine der Quellen `headers_of`, `binary_of`, `output_dir_of`, `from` |
| E001 | `headers_of`: Library hat keine öffentlichen Header |
| E001 | `from`: Ordner existiert nicht |
| E001 | `version_file` nicht gefunden |
| E102 | Target `package_<name>` existiert bereits |

### 6.2 Warnings

| Code | Bedingung | Folge |
|------|-----------|-------|
| W112 | Eine Quelle nennt ein Target, das nicht existiert (geskippt oder andere Plattform) | `package_<name>` wird nicht angelegt |

Fehler zur Build-Zeit: siehe [PackageBuild.cmake](PackageBuild.md).

---

## 7. Debug-Ausgaben

### Debug-ID: `PACKAGES` (Tag `Packages`)

| Level | Ausgabe |
|-------|---------|
| `DBG_OFTEN` | Package Pipeline Start / Complete, Anzahl der Pakete |
| `DBG_COMMON` | Created: package_{name} -> out/package/{archive} |

---

## 8. Siehe auch

- [PackageBuild.cmake](PackageBuild.md) — Build-Zeit-Skript des Targets
- [LibraryCreate.cmake](LibraryCreate.md) — setzt `CRAFT_PUBLIC_HEADERS_DIR`
- [CMakeCraftPackage.cmake](../CMakeCraftPackage.md) — bezieht Pakete in diesem Aufbau
- [Phase10_doc.md](../buildSystemTest/Phase10_doc.md) — Phasentest

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.0.0** | **2026-10-09** | **Initial (CMakeCraft v0.10.0): Block `packages`, Target `package_<name>`** |
