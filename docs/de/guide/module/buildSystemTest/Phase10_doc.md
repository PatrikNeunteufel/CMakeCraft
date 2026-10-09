# phase10.cmake — Modul-Dokumentation

> **Version:** 1.0.0  
> **Datum:** 2026-10-09  
> **Typ:** ModuleDoc  
> **Pfad:** `cmake/buildSystemTest/phase10.cmake`  
> **Status:** Stabil  
> **Sprache:** Deutsch  

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Tests](#2-tests)
3. [Erfolgs-Flag](#3-erfolgs-flag)
4. [Siehe auch](#4-siehe-auch)
5. [Changelog](#5-changelog)

---

## 1. Übersicht

**Phase 10** testet das **Bauen und Beziehen vorgebauter Pakete** — den Block `packages`, die Library-Felder `output_name` und `defines`, `CMakeCraftPackage.cmake` und die External-Art `archive`.

| Aspekt | Beschreibung |
|--------|--------------|
| **Zweck** | Packages und Archive Externals validieren |
| **Debug-ID** | `PHASE10_TEST` |
| **Abhängigkeiten** | Packages.cmake, CMakeCraftPackage.cmake, archive/Handler.cmake, Validation.cmake |
| **Bedingung** | Tests 2 und 3 laufen nur, wenn die Demo-Library `PackDemo` bzw. das Demo-Paket `packdemo` vorhanden ist; sonst werden sie übersprungen |

Der Test schreibt ein Miniatur-Paket unter `<build>/phase10/` und bezieht es von dort. Kein Netzzugriff, nichts wird in den Quellbaum geschrieben.

**Nicht geprüft:** das Abweisen einer falschen Prüfsumme. Es ist absichtlich eine Warnung und würde die Ausgabe des Selbsttests verunreinigen.

---

## 2. Tests

### 2.1 Module verfügbar

Prüft, dass diese Kommandos definiert sind:

| Kommando | Modul |
|----------|-------|
| `craft_package_fetch` | CMakeCraftPackage.cmake |
| `craft_package_deploy` | CMakeCraftPackage.cmake |
| `_create_package_target` | Packages.cmake |
| `_handle_archive_external` | archive/Handler.cmake |
| `_apply_archive_external_to_target` | archive/Handler.cmake |

### 2.2 output_name und defines

Prüft an der Demo-Library `PackDemo` (nur wenn das Target existiert):

| Property | Erwartet |
|----------|----------|
| `OUTPUT_NAME` | `PackDemo1` |
| `COMPILE_DEFINITIONS` | enthält `PACK_DEMO_VERSION="1.2.0"` — `{version}` wurde ersetzt |

### 2.3 Package-Target

Prüft das Demo-Paket `packdemo` (nur wenn `packages` nicht leer ist und `PackDemo` existiert):

| Prüfung | Erwartet |
|---------|----------|
| Target `package_packdemo` | existiert |
| `MANUALLY_ADDED_DEPENDENCIES` | enthält `PackDemo` |
| `<build>/package/packdemo/VERSION` | Zeile `produkt=<Solution-Version>` — `version_file` wurde konfiguriert |

### 2.4 Bezug über URL und Cache

Legt unter `<build>/phase10/source/` ein Miniatur-Paket `phase10demo-v1.2.3` an (ein Header, ein Ordner `tools`, die Datei `VERSION`), packt es als Zip und schreibt eine Pin-Datei mit `file://`-URL und der berechneten SHA256.

| Prüfung | Erwartet |
|---------|----------|
| `craft_package_fetch()` | liefert eine nicht-leere Wurzel |
| Ort des Cache | `<build>/phase10/url/.externals/phase10demo/v1.2.3` |
| Inhalt | `include/phase10_demo.h` und `VERSION` vorhanden |
| Zweiter Bezug bei weggeräumtem Quellarchiv | dieselbe Wurzel — kommt aus dem Cache |

### 2.5 Archive External über Ausweichpfad

Schreibt eine zweite Pin-Datei, deren URL ins Leere zeigt und deren `PHASE10DEMO_FALLBACK_PATHS` auf `../source` verweist. Die External-Definition:

```json
{
    "archive": true,
    "pin": "<relativer Pfad zur Pin-Datei>",
    "include_dirs": ["include"],
    "define": "PHASE10_DEMO_VORHANDEN",
    "runtime": { "files": ["VERSION"], "dirs": ["tools"] }
}
```

| Prüfung | Erwartet |
|---------|----------|
| `validate_external_source()` | akzeptiert `archive` als Source-Feld |
| `ARCHIVE_EXTERNAL_phase10demo_ROOT` | `<build>/phase10/fallback/.externals/phase10demo/v1.2.3` |

### 2.6 Anwenden auf ein Target

Verwendet zwei INTERFACE-Libraries als Sonden (`_craft_phase10_probe`, `_craft_phase10_absent`).

| Prüfung | Erwartet |
|---------|----------|
| `_apply_archive_external_to_target()` auf die Sonde | `INTERFACE_INCLUDE_DIRECTORIES` enthält `<root>/include` |
| | `INTERFACE_COMPILE_DEFINITIONS` enthält `PHASE10_DEMO_VORHANDEN=1` |
| `craft_package_deploy(... ROOT "")` auf die zweite Sonde | weder Include-Pfad noch Define — ein fehlendes Paket lässt das Target unberührt |

---

## 3. Erfolgs-Flag

```cmake
set(PHASE10_TEST_PASSED TRUE CACHE BOOL "Phase 10 Test passed" FORCE)
```

---

## 4. Siehe auch

- [Packages.md](../project/Packages.md)
- [PackageBuild.md](../project/PackageBuild.md)
- [CMakeCraftPackage.md](../CMakeCraftPackage.md)
- [archive/Handler_cmake.md](../externals/archive/Handler_cmake.md)
- [LibraryCreate.md](../project/LibraryCreate.md)

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.0.0** | **2026-10-09** | **Initial (CMakeCraft v0.10.0)** |
