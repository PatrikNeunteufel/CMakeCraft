# PackageBuild.cmake — Modul-Dokumentation

> **Version:** 1.0.0  
> **Datum:** 2026-10-09  
> **Typ:** ModuleDoc  
> **Status:** Aktiv  
> **Basiert auf:** ModuleDoc v0.5  
> **Zielgruppe:** Build-System-Entwickler  
> **Sprache:** Deutsch  
> **English:** [PackageBuild.md](../../../../en/guide/module/project/PackageBuild.md)  
> **Modul:** [`cmake/project/PackageBuild.cmake`](../../../../../cmake/project/PackageBuild.cmake)  
> **Modul-Version:** 1.0.0  
> **Phase:** 10 (Packages)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [Aufruf](#3-aufruf)
4. [Verarbeitung](#4-verarbeitung)
5. [Fehlerbehandlung](#5-fehlerbehandlung)
6. [Siehe auch](#6-siehe-auch)
7. [Changelog](#7-changelog)

---

## 1. Übersicht

`PackageBuild.cmake` ist das **Build-Zeit-Skript** des Targets `package_<name>`. Es wird nicht eingebunden, sondern über `cmake -P` ausgeführt. Es stellt den Paketordner zusammen, schreibt das Archiv und dessen Prüfsumme.

### Kernidee

Trennung von Configure- und Build-Zeit: [Packages.cmake](Packages.md) beschreibt das Paket in einem Manifest, dieses Skript führt das Manifest aus. Der Paketordner wird bei jedem Lauf von Grund auf neu aufgebaut.

### Ergebnis in `CRAFT_PKG_OUT_DIR`

| Pfad | Inhalt |
|------|--------|
| `<archive>/` | Der zusammengestellte Ordner |
| `<archive>.zip` | Der Ordner als Zip-Archiv (ein Ordner auf oberster Ebene) |
| `<archive>.zip.sha256` | Eine Zeile `<hash>  <archive>.zip` (Format von `sha256sum`) |

---

## 2. Abhängigkeiten

| Modul | Verwendung |
|-------|------------|
| — | Keine (Skript-Modus; liest das von Packages.cmake geschriebene Manifest) |

Das Skript definiert keine Funktionen und verwendet weder `cmake_fatal` noch `dbg`. Meldungen tragen das Präfix `[Package]`.

---

## 3. Aufruf

```bash
cmake -DCRAFT_PKG_MANIFEST=<manifest.cmake> -P PackageBuild.cmake
```

| Variable | Pflicht | Beschreibung |
|----------|---------|--------------|
| `CRAFT_PKG_MANIFEST` | ✓ | Pfad des Manifests (`manifest-<CONFIG>.cmake`) |

Den Aufruf setzt `Packages.cmake` als Kommando des Targets `package_<name>` ab; von Hand ist er nicht nötig.

### Gelesene Manifest-Variablen

| Variable | Verwendung |
|----------|------------|
| `CRAFT_PKG_NAME` | Paketname für Meldungen |
| `CRAFT_PKG_ARCHIVE` | Ordner- und Archivname (Pflicht) |
| `CRAFT_PKG_OUT_DIR` | Zielverzeichnis (Pflicht) |
| `CRAFT_PKG_REQUIRED_CONFIG` | Einzig erlaubte Konfiguration, oder leer |
| `CRAFT_PKG_CONFIG` | Konfiguration dieses Builds |
| `CRAFT_PKG_VERSION_FILE` | Konfigurierte Versionsdatei, oder leer |
| `CRAFT_PKG_ITEMS` | Liste der Inhalts-Indizes |
| `CRAFT_PKG_ITEM_<i>_KIND` | `files`, `file` oder `dir` |
| `CRAFT_PKG_ITEM_<i>_SRC` | Quelle (Ordner oder Datei) |
| `CRAFT_PKG_ITEM_<i>_TO` | Zielordner innerhalb des Pakets |
| `CRAFT_PKG_ITEM_<i>_FILES` | Dateien relativ zur Quelle (Art `files`) |
| `CRAFT_PKG_ITEM_<i>_EXCLUDE` | Ausschluss-Muster (Art `dir`) |

---

## 4. Verarbeitung

```
PackageBuild.cmake
    │
    ├── 1. Manifest einbinden
    │   ├── nicht gefunden → FATAL_ERROR
    │   └── CRAFT_PKG_ARCHIVE oder CRAFT_PKG_OUT_DIR leer → FATAL_ERROR
    │
    ├── 2. Konfiguration prüfen
    │   └── CRAFT_PKG_REQUIRED_CONFIG gesetzt und ≠ CRAFT_PKG_CONFIG → FATAL_ERROR
    │
    ├── 3. Aufräumen
    │   ├── <out>/<archive>/ entfernen und neu anlegen
    │   └── <archive>.zip und <archive>.zip.sha256 entfernen
    │
    ├── 4. Inhalte kopieren (je Eintrag nach <out>/<archive>/<TO>)
    │   ├── files → jede genannte Datei, Unterordner bleiben erhalten
    │   ├── file  → eine Datei
    │   └── dir   → der ganze Ordner, EXCLUDE als PATTERN ... EXCLUDE
    │
    ├── 5. Versionsdatei (falls gesetzt) → <out>/<archive>/VERSION
    │
    ├── 6. Archiv schreiben
    │   └── cmake -E tar cf <archive>.zip --format=zip -- <archive>
    │       (Arbeitsverzeichnis: CRAFT_PKG_OUT_DIR)
    │
    └── 7. SHA256 berechnen → <archive>.zip.sha256
```

Am Ende gibt das Skript den Archivpfad und die Prüfsumme als `STATUS`-Meldung aus.

---

## 5. Fehlerbehandlung

Alle Fehler sind `message(FATAL_ERROR ...)` ohne Fehlercode; sie brechen den Build des Targets ab.

| Bedingung | Meldung |
|-----------|---------|
| Manifest nicht angegeben oder nicht vorhanden | `[Package] manifest not found` |
| `CRAFT_PKG_ARCHIVE` oder `CRAFT_PKG_OUT_DIR` leer | `[Package] manifest is incomplete` |
| Build-Konfiguration weicht von `config` ab | `'<name>' is built from configuration '<config>' only` |
| Art `files`: genannte Datei fehlt | `file not found: <src>/<file>` |
| Art `file`: Datei fehlt | `file not found: <src>` |
| Art `dir`: Ordner fehlt | `folder not found: <src>` |
| Archiv konnte nicht geschrieben werden | `writing the archive failed (<result>)` |

---

## 6. Siehe auch

- [Packages.cmake](Packages.md) — schreibt das Manifest, legt das Target an
- [CMakeCraftPackage.cmake](../CMakeCraftPackage.md) — bezieht das hier erzeugte Archiv und prüft dessen SHA256

---

## 7. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.0.0** | **2026-10-09** | **Initial (CMakeCraft v0.10.0): Paketordner, Zip-Archiv, Prüfsumme** |
