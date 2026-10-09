# CMakeCraftPackage.cmake — Vorgebaute Pakete beziehen und ausliefern

> **Version:** 1.1.0  
> **Datum:** 2026-10-09  
> **Typ:** ModuleDoc  
> **Status:** Aktiv  
> **Basiert auf:** ModuleDoc v0.5  
> **Zielgruppe:** Build-System-Entwickler  
> **Sprache:** Deutsch  
> **English:** [CMakeCraftPackage.md](../../../en/guide/module/CMakeCraftPackage.md)  
> **Modul:** [CMakeCraftPackage.cmake](../../../../CMakeCraftPackage.cmake)  
> **Modul-Version:** 1.1.0 (eigene Version der Datei, unabhängig von der CMakeCraft-Version)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [Konzept](#3-konzept)
4. [API-Referenz](#4-api-referenz)
5. [Verarbeitungsablauf](#5-verarbeitungsablauf)
6. [Verwendungsbeispiele](#6-verwendungsbeispiele)
7. [Fehlerbehandlung](#7-fehlerbehandlung)
8. [Siehe auch](#8-siehe-auch)
9. [Changelog](#9-changelog)

---

## 1. Übersicht

`CMakeCraftPackage.cmake` bezieht ein **vorgebautes Paket** (Header, Laufzeitdateien, Werkzeuge) in einer festgelegten Version und wendet es auf Targets an. Die Datei liegt im Repo-Root und ist **eigenständig**: Sie verwendet nichts aus dem CMakeCraft-Kern. Ein Projekt, das nicht mit CMakeCraft baut, kann eine unveränderte Kopie mitführen und direkt einbinden.

CMakeCraft selbst ruft die Datei aus der External-Art `archive` auf (siehe [archive/Handler_cmake.md](externals/archive/Handler_cmake.md)).

### Kernfunktionen

- **Beziehen** — `craft_package_fetch()`: Entwickler-Override, Cache, Download, Ausweichpfade
- **Prüfen** — SHA256 des Archivs und Version aus der Datei `VERSION` im Paket
- **Ausliefern** — `craft_package_deploy()`: Include-Pfad, Define, Kopien neben die ausführbare Datei
- **Fehlendes Paket ist kein Fehler** — Warnung, leere Wurzel, `craft_package_deploy()` tut dann nichts

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| CMake 3.26+ | System | Wegen `copy_directory_if_different`; ältere Fassungen brechen beim Einbinden mit `FATAL_ERROR` ab |

**Keine** anderen Module als Abhängigkeit. Fehler und Warnungen laufen über `message()` mit dem Präfix `[CraftPackage]`, nicht über `cmake_fatal`/`cmake_warn`.

Beim Einbinden setzt die Datei:

| Wirkung | Beschreibung |
|---------|--------------|
| `include_guard(GLOBAL)` | Mehrfaches Einbinden ist unschädlich |
| `CMAKECRAFT_PACKAGE_VERSION` | Variable mit der Version dieser Datei (`1.0.0`) |
| Policy `CMP0174` → `NEW` | Nur wenn die Policy existiert; ein leeres `ROOT` gilt damit als regulärer Parameter von `craft_package_deploy()` |

---

## 3. Konzept

### 3.1 Pin-Datei

Die Pin-Datei ist ein CMake-Skript. `<NAME>` ist der Paketname in Großbuchstaben, als C-Bezeichner umgeformt (`string(MAKE_C_IDENTIFIER)`).

```cmake
set(<NAME>_VERSION "v0.2.0")
set(<NAME>_URL     "https://.../<archiv>.zip")
set(<NAME>_SHA256  "<64 Hex-Ziffern>")
set(<NAME>_FALLBACK_PATHS "../Other/out/package")   # optional, Verzeichnisse
```

| Variable | Pflicht | Beschreibung |
|----------|---------|--------------|
| `<NAME>_VERSION` | ✓ | Festgelegte Version; fehlt sie, wird gewarnt und ohne Paket gebaut |
| `<NAME>_URL` | — | Adresse des Archivs; ihr letzter Pfadteil ist zugleich der Dateiname, der in den Ausweichpfaden gesucht wird |
| `<NAME>_SHA256` | ✓ (außer bei Cache-Treffer oder Override) | Prüfsumme des Archivs; geprüft wird, dass der Wert nur aus Hex-Ziffern besteht — ohne Prüfsumme wird nichts bezogen |
| `<NAME>_FALLBACK_PATHS` | — | Verzeichnisse, in denen dieselbe Archivdatei liegt (gleiche Prüfsumme) |

Relative Pfade in der Pin-Datei und in `<NAME>_LOCAL_DIR` beziehen sich auf das Verzeichnis der Pin-Datei.

### 3.2 Aufbau des Pakets

Das Archiv enthält einen Ordner auf oberster Ebene oder den Inhalt direkt. In der Paketwurzel liegt eine Datei `VERSION`, deren Zeile `produkt=<x.y.z>` zur festgelegten Version passen muss. Ein führendes `v` oder `V` der Pin-Version wird beim Vergleich ignoriert.

### 3.3 Reihenfolge der Quellen

| # | Quelle | Beschreibung |
|---|--------|--------------|
| 1 | `-D<NAME>_LOCAL_DIR=<dir>` | Entwickler-Override, wird unverändert und **ungeprüft** verwendet |
| 2 | Cache | Default: `<Pin-Verzeichnis>/.externals/<name>/<version>/` |
| 3 | Download von `<NAME>_URL` | Gegen `<NAME>_SHA256` geprüft |
| 4 | `<NAME>_FALLBACK_PATHS` | Verzeichnisse mit derselben Archivdatei, gleiche Prüfsumme |

### 3.4 Abgebrochene Läufe

Das Archiv wird neben dem Cache-Verzeichnis entpackt (`<cache>.unpack`) und erst nach bestandener Prüfung von Prüfsumme und Version an seinen Platz umbenannt. Ein abgebrochener Lauf hinterlässt damit nichts, das wie ein Paket im Cache aussieht. Der Download landet in `<cache>.download/` und wird nach dem Versuch wieder entfernt.

---

## 4. API-Referenz

### 4.1 craft_package_fetch()

```cmake
craft_package_fetch(NAME <name> PIN_FILE <file> [CACHE_DIR <dir>] OUT_ROOT <var>)
```

**Beschreibung:**  
Bezieht das Paket in der festgelegten Version und liefert seine Wurzel.

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `NAME` | ✓ | Paketname; seine Großschreibung ist das Präfix der Pin-Variablen und von `<NAME>_LOCAL_DIR` |
| `PIN_FILE` | ✓ | Pin-Datei (relativ: zu `CMAKE_CURRENT_SOURCE_DIR`) |
| `CACHE_DIR` | — | Verzeichnis des entpackten Pakets, relativ zu `CMAKE_CURRENT_SOURCE_DIR` (Default: `<Pin-Verzeichnis>/.externals/<name>/<version>`) |
| `OUT_ROOT` | ✓ | Erhält die Paketwurzel, oder `""` wenn das Paket nicht verfügbar ist |

**Rückgabe:**  
`OUT_ROOT` im aufrufenden Scope (`PARENT_SCOPE`). Zusätzlich legt die Funktion die Cache-Variable `<NAME>_LOCAL_DIR` (Typ `PATH`, Default leer) an.

**Fehler:**  
- `FATAL_ERROR`, wenn `NAME`, `PIN_FILE` oder `OUT_ROOT` fehlen
- Alles andere ist eine `WARNING` mit leerem `OUT_ROOT` (siehe [Fehlerbehandlung](#7-fehlerbehandlung))

---

### 4.2 craft_package_deploy()

```cmake
craft_package_deploy(TARGET <target> ROOT <dir>
                     [INCLUDE_DIRS <dir>...] [DEFINE <name>]
                     [RUNTIME_FILES <file>...] [RUNTIME_DIRS <dir>...]
                     [NAME <name>] [NO_RUNTIME])
```

**Beschreibung:**  
Wendet ein bezogenes Paket auf ein Target an.

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `TARGET` | ✓ | Bestehendes Target |
| `ROOT` | ✓ | Paketwurzel aus `craft_package_fetch()`; leer oder kein Verzeichnis = Paket fehlt, es geschieht nichts |
| `INCLUDE_DIRS` | — | Include-Verzeichnisse, relativ zu `ROOT` (nur Include-Pfad — es wird nichts gelinkt) |
| `DEFINE` | — | Compile-Definition `<name>=1` auf dem Target |
| `RUNTIME_FILES` | — | Dateien, relativ zu `ROOT`, die bei jedem Build neben die ausführbare Datei kopiert werden |
| `RUNTIME_DIRS` | — | Verzeichnisse, relativ zu `ROOT`, die als gleichnamiger Unterordner neben die ausführbare Datei kopiert werden |
| `NAME` | — | Paketname, Teil des Namens des Deploy-Targets (`<target>_deploy_<name>`; Default: `package`) |
| `NO_RUNTIME` | — | Nur Include-Pfad und Define, keine Kopien |

**Verhalten:**

| Target-Typ | Include-Pfad und Define | Laufzeit-Kopien |
|------------|-------------------------|-----------------|
| `INTERFACE_LIBRARY` | `INTERFACE` | keine |
| `EXECUTABLE` | `PRIVATE` | ja (eigenes Target `<target>_deploy_<name>`), außer bei `NO_RUNTIME` |
| andere | `PRIVATE` | keine |

Kopiert wird nach `$<TARGET_FILE_DIR:target>`, also je Konfiguration, und nur bei Unterschied (`copy_if_different`, `copy_directory_if_different`).

**Das Deploy-Target:** Die Kopien macht ein eigenes Target (`add_custom_target`, nicht in `ALL`), von dem die ausführbare Datei abhängt (`add_dependencies`). Es läuft damit bei jedem Build der ausführbaren Datei — unabhängig davon, ob sie selbst übersetzt oder gelinkt wird. Ein `POST_BUILD`-Schritt (bis 1.0.0) lief nur beim Linken; nach einem Wechsel der gepinnten Version blieben die alten Dateien liegen.

- Der Zielordner wird vor dem Kopieren angelegt (das Target läuft vor dem ersten Linken).
- Ist der Name schon vergeben (zweiter Aufruf für dasselbe Target und denselben Namen), wird `_2`, `_3`, … angehängt.
- Das Target übernimmt den IDE-Ordner (`FOLDER`) der ausführbaren Datei; gelesen wird er am Ende des Verzeichnisses (`cmake_language(DEFER)`), weil der Aufrufer ihn oft erst danach setzt.
- Die Datei setzt für ihre Funktionen CMP0112 auf NEW: `$<TARGET_FILE_DIR:...>` im Deploy-Target darf keine Abhängigkeit auf die ausführbare Datei erzeugen — sie läuft in der Gegenrichtung.
- Dateien, die ein früheres Paket kopiert hat und das neue nicht mehr enthält, bleiben liegen.

**Rückgabe:**  
Keine.

**Fehler:**  
- `FATAL_ERROR`, wenn `TARGET` leer ist oder nicht existiert

---

## 5. Verarbeitungsablauf

```
craft_package_fetch(NAME, PIN_FILE, [CACHE_DIR], OUT_ROOT)
    │
    ├── 0. OUT_ROOT = ""; Pin-Datei vorhanden?
    │   └── Nein → WARNING, Ende
    │
    ├── 1. <NAME>_LOCAL_DIR gesetzt?
    │   ├── Verzeichnis → OUT_ROOT = dieses Verzeichnis, Ende (ungeprüft)
    │   └── kein Verzeichnis → WARNING, Ende
    │
    ├── 2. Pin-Datei einbinden
    │   └── <NAME>_VERSION leer → WARNING, Ende
    │
    ├── 3. Cache: steht in <cache>/VERSION die gewünschte Version?
    │   └── Ja → OUT_ROOT = <cache>, Ende
    │
    ├── 4. <NAME>_SHA256 nicht hexadezimal → WARNING, Ende
    │
    ├── 5. Download (wenn <NAME>_URL gesetzt)
    │   ├── INACTIVITY_TIMEOUT 30, TLS_VERIFY ON
    │   └── Erfolg → prüfen und entpacken → OUT_ROOT = <cache>, Ende
    │
    ├── 6. Ausweichpfade der Reihe nach
    │   └── <dir>/<Archivname> vorhanden → prüfen und entpacken
    │       → OUT_ROOT = <cache>, Ende
    │
    └── 7. WARNING mit allen Versuchen und ihren Gründen
```

**Prüfen und entpacken** (`_craft_package_unpack`):

1. SHA256 der Archivdatei vergleichen (Groß-/Kleinschreibung der erwarteten Summe egal)
2. Nach `<cache>.unpack` entpacken
3. Paketwurzel bestimmen: der Inhalt direkt, oder — wenn dort keine `VERSION` liegt und genau ein Ordner enthalten ist — dieser Ordner
4. `produkt=` aus `VERSION` mit der gewünschten Version vergleichen
5. Altes Cache-Verzeichnis entfernen, Paketwurzel dorthin umbenennen

Der Download läuft bewusst ohne `EXPECTED_HASH`: `file(DOWNLOAD)` würde einen fehlgeschlagenen Download sonst zum fatalen Fehler machen. Die Prüfsumme wird beim Entpacken verglichen.

---

## 6. Verwendungsbeispiele

### 6.1 Eigenständig (ohne CMakeCraft)

```cmake
include("${CMAKE_CURRENT_LIST_DIR}/cmake/CMakeCraftPackage.cmake")

craft_package_fetch(
    NAME     toolkit
    PIN_FILE "toolkit.pin"
    OUT_ROOT _toolkit_root
)

craft_package_deploy(
    TARGET        MyApp
    ROOT          "${_toolkit_root}"
    INCLUDE_DIRS  include
    DEFINE        TOOLKIT_VORHANDEN
    RUNTIME_FILES bin/toolkit.dll
    RUNTIME_DIRS  tools
)
```

Pin-Datei `toolkit.pin` dazu:

```cmake
set(TOOLKIT_VERSION "v0.2.0")
set(TOOLKIT_URL     "https://example.org/toolkit-v0.2.0.zip")
set(TOOLKIT_SHA256  "<64 Hex-Ziffern>")
```

### 6.2 Entwicklung gegen ein lokal entpacktes Paket

```bash
cmake -B build -DTOOLKIT_LOCAL_DIR=../Toolkit/out/package/toolkit-v0.2.0
```

### 6.3 Paket fehlt

```cmake
craft_package_deploy(TARGET MyApp ROOT "" INCLUDE_DIRS include DEFINE TOOLKIT_VORHANDEN)
# Weder Include-Pfad noch Define noch Kopien - der Code prüft das Define selbst.
```

---

## 7. Fehlerbehandlung

Die Datei verwendet keine Fehlercodes des CMakeCraft-Kerns.

### Fatale Fehler

| Bedingung | Meldung |
|-----------|---------|
| CMake älter als 3.26 | `[CraftPackage] CMake 3.26 or newer is required` |
| `craft_package_fetch` ohne `NAME`, `PIN_FILE` oder `OUT_ROOT` | `NAME, PIN_FILE and OUT_ROOT are mandatory` |
| `craft_package_deploy` mit leerem oder unbekanntem `TARGET` | `TARGET '<name>' does not exist` |

### Warnungen (Build läuft ohne das Paket weiter)

| Bedingung |
|-----------|
| Pin-Datei nicht gefunden |
| `<NAME>_LOCAL_DIR` gesetzt, aber kein Verzeichnis |
| `<NAME>_VERSION` in der Pin-Datei nicht gesetzt |
| `<NAME>_SHA256` fehlt oder ist nicht hexadezimal |
| Paket aus keiner Quelle beziehbar — die Meldung nennt je Versuch den Grund (Download-Status, Prüfsumme weicht ab, Version in `VERSION` passt nicht, Datei nicht gefunden, Cache-Verzeichnis nicht entfernbar, Verschieben in den Cache fehlgeschlagen) und die Abhilfen |

---

## 8. Siehe auch

- [externals/archive/Handler_cmake.md](externals/archive/Handler_cmake.md) — External-Art `archive`, ruft diese Datei auf
- [project/Packages.md](project/Packages.md) — erzeugt Pakete im hier erwarteten Aufbau
- [buildSystemTest/Phase10_doc.md](buildSystemTest/Phase10_doc.md) — Phasentest

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.1.0** | **2026-10-09** | **CMakeCraft v0.11.0: craft_package_deploy kopiert über ein eigenes Target `<target>_deploy_<name>` statt `POST_BUILD` — die Kopie läuft bei jedem Build, auch ohne neues Linken. Neues Argument `NAME`** |
| 1.0.0 | 2026-10-09 | Initial (CMakeCraft v0.10.0): craft_package_fetch, craft_package_deploy |
