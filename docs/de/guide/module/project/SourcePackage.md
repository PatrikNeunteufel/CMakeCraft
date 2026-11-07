# SourcePackage.cmake — Modul-Dokumentation

> **Version:** 1.0.0  
> **Datum:** 2026-11-07  
> **Typ:** ModuleDoc  
> **Status:** Aktiv  
> **Basiert auf:** ModuleDoc v0.5  
> **Zielgruppe:** Build-System-Entwickler  
> **Sprache:** Deutsch  
> **English:** [SourcePackage.md](../../../../en/guide/module/project/SourcePackage.md)  
> **Modul:** [`cmake/project/SourcePackage.cmake`](../../../../../cmake/project/SourcePackage.cmake)  
> **Modul-Version:** 1.0.0  
> **Phase:** 11 (Quellpakete)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [API-Referenz](#3-api-referenz)
4. [Verarbeitung](#4-verarbeitung)
5. [Fehlerbehandlung](#5-fehlerbehandlung)
6. [Siehe auch](#6-siehe-auch)
7. [Changelog](#7-changelog)

---

## 1. Übersicht

`SourcePackage.cmake` legt für einen Eintrag `{ "name": …, "library": … }` im Block `packages`
das Target `package_<name>` an. Das Paket enthält die Quellen einer **STATIC-Bibliothek** und
ein erzeugtes `CMakeLists.txt` aus einfachem CMake: ein Bezieher ohne CMakeCraft bindet es mit
`add_subdirectory()` ein und übersetzt die Bibliothek mit denselben Schaltern.

### Kernidee

Alles, was das `CMakeLists.txt` braucht, ist zur Configure-Zeit bekannt — CMakeCraft hat die
Bibliothek eben angelegt. Das Modul liest die Beschreibung, die
[LibraryCreate.cmake](LibraryCreate.md) am Ziel hinterlegt (`CRAFT_LIB_*`, `CRAFT_EXT_*`), und
schreibt das `CMakeLists.txt` mit `file(WRITE)`. So bleiben Generator Expressions in
`compile_options` **wörtlich** stehen; `file(GENERATE)` würde sie für den eigenen Compiler
auflösen. Nur die Prüfsummen der External-Ordner hängen vom Inhalt zur Bauzeit ab; dafür steht
im Text ein Platzhalter, den [PackageBuild.cmake](PackageBuild.md) ersetzt.

### Ergebnis eines Builds von `package_<name>`

Siehe [Packages.md](../../references/Packages.md) §2.5: `src/`, `include/`,
`externals/<ext>/`, `CMakeLists.txt`, `VERSION`, `SHA256SUMS`, dazu `.zip` und `.zip.sha256`.

---

## 2. Abhängigkeiten

| Modul | Verwendung |
|-------|------------|
| Errors.cmake | `cmake_fatal`, `cmake_warn` |
| Debug.cmake | `dbg` |
| Json.cmake | `_json_get_string`, `_json_get_string_or_default`, `_json_has_key`, `_json_get_object`, `_json_get_bool_or_default` |
| CompilerOptions.cmake | `craft_language_rules` — die Sprachregeln aller Compiler-Familien |
| LibraryCreate.cmake | Target-Properties `CRAFT_LIB_*`, `CRAFT_EXT_*`, `CRAFT_PUBLIC_HEADERS_DIR` |
| Packages.cmake | ruft `_create_source_package_target()` für Einträge mit `library` auf |
| PackageBuild.cmake | wird zur Build-Zeit über `cmake -P` ausgeführt |

---

## 3. API-Referenz

### 3.1 _create_source_package_target()

```cmake
_create_source_package_target(<PKG_JSON> <NAME>)
```

| Parameter | Typ | Pflicht | Beschreibung |
|-----------|-----|---------|--------------|
| `PKG_JSON` | String | ✓ | JSON-String des Eintrags |
| `NAME` | String | ✓ | sein Feld `name` |

Legt das Target `package_<name>` an (nicht in `ALL`), dazu im Build-Ordner
`package/<name>/CMakeLists.txt.in` und `package/<name>/manifest-source.cmake`. Das Target
trägt die Properties `CRAFT_PACKAGE_MANIFEST` und `CRAFT_PACKAGE_CMAKELISTS` (vom Phasentest
gelesen).

### 3.2 Hilfsfunktionen (intern)

| Funktion | Zweck |
|----------|-------|
| `_craft_pkg_bracket(VALUE OUT)` | Wert als CMake-Bracket-Argument `[=[…]=]`, damit Anführungszeichen und `$<…>` unverändert bleiben |
| `_craft_pkg_place(PATH SRC_DIR PUB_DIR OUT)` | Ort eines Pfads im Paket: `include/…` unter den öffentlichen Köpfen, `src/…` unter `path`, sonst leer |
| `_craft_pkg_external(LIB EXT CODE ROOT DROP)` | Block des `CMakeLists.txt` für ein lokales External; Ordner und wegzulassende `Include.cmake` |

---

## 4. Verarbeitung

```
_create_source_package_target(PKG_JSON NAME)
    │
    ├── 1. contents / config / version_file vorhanden? → E001
    ├── 2. Bibliothek fehlt → W112, kein Target
    ├── 3. nicht STATIC → E106;  C++20-Module → E106
    │
    ├── 4. Dateien einordnen (_craft_pkg_place)
    │   ├── unter public_headers → include/… (kommt mit dem Ordner)
    │   ├── unter path           → src/…     (einzeln kopiert)
    │   └── sonst                → E106
    │   Ebenso die privaten Includes und der PCH-Header
    │
    ├── 5. Externals (_craft_pkg_external)
    │   ├── nicht lokal (system, git, archive) → E106
    │   ├── CRAFT_EXT_<ext>_OTHER gesetzt (Ziel direkt verändert) → E106
    │   └── je gelinktes Ziel: INTERFACE, nicht importiert, keine Link-Bibliotheken,
    │       Quellen, Link-Optionen, PCH; Include-Ordner im External-Ordner → sonst E106
    │       → Block "if(NOT TARGET …) add_library(… INTERFACE) … else() Prüfsumme vergleichen"
    │
    ├── 6. CMakeLists.txt.in schreiben (file(WRITE))
    │   ├── Prüfung: Ziel existiert schon / Abhängigkeiten fehlen
    │   ├── Externals, add_library(STATIC) + Alias <name>::<name>
    │   ├── Include-Ordner, defines
    │   ├── if(MSVC) / elseif(GNU|Clang): craft_language_rules
    │   ├── compile_options (wörtlich)
    │   ├── cxx_std_<n>, CXX_STANDARD, CXX_STANDARD_REQUIRED, CXX_EXTENSIONS
    │   ├── OUTPUT_NAME, VERSION, PCH
    │   └── target_link_libraries: dependencies (PUBLIC), Externals (PUBLIC/PRIVATE wie gelinkt)
    │
    └── 7. Manifest schreiben, add_custom_target(package_<name> … PackageBuild.cmake)
```

`craft_language_rules` wird ohne Flags aufgerufen — genau so, wie
`apply_compiler_options(${name})` in LibraryCreate.cmake die Sprachregeln für eine Bibliothek
setzt. Fehlt `CXX_EXTENSIONS` am Ziel (in der Solution nicht gesetzt), schreibt das Modul `ON`,
die Vorgabe von CMake für GNU und Clang.

---

## 5. Fehlerbehandlung

| Code | Bedingung |
|------|-----------|
| E001 | `library` leer, oder zusammen mit `contents`, `config` oder `version_file` |
| E106 | Bibliothek nicht STATIC; C++20-Module; Datei, Include-Ordner oder PCH außerhalb von `path` und `public_headers` |
| E106 | External nicht lokal; verändert das Ziel direkt; bringt ein Ziel, das nicht Header-only-INTERFACE ist; Include-Ordner außerhalb seines Ordners |
| W112 | Bibliothek existiert nicht (geskippt, andere Plattform) — `package_<name>` wird nicht angelegt |

---

## 6. Siehe auch

- [Packages.md](../../references/Packages.md) §2.5 — Referenz für Nutzer
- [Packages.cmake](Packages.md) — Block `packages`
- [PackageBuild.cmake](PackageBuild.md) — Build-Zeit-Skript
- [LibraryCreate.cmake](LibraryCreate.md) — Beschreibung am Ziel
- [CompilerOptions.cmake](../core/CompilerOptions.md) — `craft_language_rules`
- [Phase11_doc.md](../buildSystemTest/Phase11_doc.md) — Phasentest

---

## 7. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.0.0** | **2026-11-07** | **Initial (CMakeCraft v0.14.0): Quellpaket einer STATIC-Bibliothek mit erzeugtem einfachem CMakeLists.txt, übertragenen lokalen Externals, E106** |
