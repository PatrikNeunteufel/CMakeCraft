# LibraryCreate.cmake — Modul-Dokumentation

> **Version:** 1.0.0  
> **Datum:** 2025-12-20  
> **Typ:** ModuleDoc  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5  
> **Zielgruppe:** Build-System-Entwickler  
> **Sprache:** Deutsch  
> **English:** [LibraryCreate.md](LibraryCreate.md)  
> **Modul:** [`cmake/project/LibraryCreate.cmake`](../../../../cmake/project/LibraryCreate.cmake)  
> **Modul-Version:** 1.1.0

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [API-Referenz](#3-api-referenz)
4. [Library-Typen](#4-library-typen)
5. [Verarbeitung](#5-verarbeitung)
6. [Fehlerbehandlung](#6-fehlerbehandlung)
7. [Siehe auch](#7-siehe-auch)
8. [Changelog](#8-changelog)

---

## 1. Übersicht

Das `LibraryCreate.cmake` Modul **erstellt CMake-Library-Targets** aus einem vorbereiteten Context. Es unterstützt STATIC, SHARED und INTERFACE Libraries.

### Kernidee

Analog zu ExecutableCreate — der Context enthält alle Daten, Create erstellt das Target.

### Verantwortlichkeiten

| Bereich | Beschreibung |
|---------|--------------|
| Target-Erstellung | add_library() mit korrektem Typ |
| Source-Sammlung | GLOB oder Source.cmake |
| Public Headers | Include-Directories setzen |
| Abhängigkeiten | Interne Libraries, Externals |

---

## 2. Abhängigkeiten

| Modul | Version | Verwendung |
|-------|---------|------------|
| Context.cmake | 0.5.0 | `ctx_get` |
| Errors.cmake | 0.5.0 | `cmake_fatal`, `cmake_warn` |
| Debug.cmake | 0.5.0 | `dbg` |
| OutputDirs.cmake | 0.5.0 | `setup_output_dirs` |
| Warnings.cmake | 0.5.0 | `apply_warnings` |
| CompilerOptions.cmake | 0.5.0 | `apply_compiler_options` |
| Orchestrator.cmake | 0.7.0 | `apply_external_to_target` |

---

## 3. API-Referenz

### 3.1 _create_library_target()

Erstellt ein CMake-Library-Target aus dem Context.

```cmake
_create_library_target(<CTX>)
```

**Parameter:**

| Parameter | Typ | Pflicht | Beschreibung |
|-----------|-----|---------|--------------|
| `CTX` | String | ✓ | Context-Prefix (z.B. `LIB_0`) |

**Erwartete Context-Keys:**

| Key | Verwendung |
|-----|------------|
| NAME | Target-Name |
| PATH | Source-Verzeichnis |
| TYPE | STATIC, SHARED, INTERFACE |
| VERSION | Target-Version |
| PUBLIC_HEADERS | Öffentliche Include-Verzeichnis |
| DEPENDENCIES | Interne Libraries |
| EXTERNALS | Externe Dependencies |
| EXTERNAL_OPTIONS | Per-External Optionen (JSON) |
| OUTPUT_NAME | Dateiname ohne Endung (leer = Target-Name) |
| DEFINES | Präprozessor-Definitionen; `{version}` steht für VERSION |
| COMPILE_OPTIONS | Compiler-Flags der Library (PRIVATE, nach `apply_compiler_options`); bei INTERFACE E105 |

---

## 4. Library-Typen

### 4.1 STATIC Library

```cmake
add_library(${name} STATIC ${sources})
```

Standard für die meisten Libraries.

### 4.2 SHARED Library

```cmake
add_library(${name} SHARED ${sources})
```

Erzeugt .dll/.so/.dylib.

### 4.3 INTERFACE Library

```cmake
add_library(${name} INTERFACE)
target_include_directories(${name} INTERFACE ${public_headers})
```

Header-Only Library — keine Sources, nur Include-Directories.

---

## 5. Verarbeitung

### 5.1 Ablauf

```
_create_library_target(CTX)
    │
    ├── 1. Context-Daten lesen
    │
    ├── 2. TYPE == INTERFACE?
    │   ├── Ja → E105, wenn COMPILE_OPTIONS gesetzt
    │   │       add_library(INTERFACE)
    │   │       └── Nur Public Headers setzen
    │   │
    │   └── Nein → Weiter mit STATIC/SHARED
    │
    ├── 3. Source-Verzeichnis validieren
    │   └── E001 wenn nicht existiert
    │
    ├── 4. Target erstellen (STATIC/SHARED)
    │
    ├── 5. Sources sammeln (GLOB)
    │
    ├── 6. Public Headers setzen
    │   └── PUBLIC Include-Directory
    │
    ├── 7. Interne Dependencies linken
    │
    ├── 8. Externals anwenden (mit Optionen)
    │   ├── _craft_target_snapshot()          Stand vorher
    │   ├── apply_external_to_target(name, ext, options)
    │   └── _craft_record_external_effect()   was das External hinzufügte
    │
    ├── 9. Standard-Module anwenden
    │   ├── apply_warnings()
    │   ├── apply_compiler_options()
    │   ├── target_compile_options(PRIVATE COMPILE_OPTIONS)   danach
    │   └── setup_output_dirs()
    │
    ├── 10. Version als Property setzen
    │
    └── 11. Beschreibung für ein Quellpaket (CRAFT_LIB_*)
```

### 5.2 Public Headers

```cmake
target_include_directories(${name}
    PUBLIC "${CMAKE_SOURCE_DIR}/${public_headers}"
    PRIVATE "${src_dir}"
)
```

- **PUBLIC:** Für Consumer der Library sichtbar
- **PRIVATE:** Nur intern verwendet

Ist `PUBLIC_HEADERS` gesetzt, erhält das Target zusätzlich die Property `CRAFT_PUBLIC_HEADERS_DIR` mit dem absoluten Pfad (`${CMAKE_SOURCE_DIR}/${public_headers}`) — auch bei INTERFACE Libraries. [Packages.cmake](Packages.md) liest sie für `headers_of`.

### 5.3 Defines und Output Name

Direkt nach dem Lesen des Context wird in `DEFINES` jedes `{version}` durch die Version des Targets ersetzt.

```cmake
# INTERFACE Library
target_compile_definitions(${name} INTERFACE ${defines})

# STATIC / SHARED Library (nach dem Anwenden der Externals)
target_compile_definitions(${name} PRIVATE ${defines})
set_target_properties(${name} PROPERTIES OUTPUT_NAME "${output_name}")  # nur wenn nicht leer
```

- **DEFINES:** `INTERFACE` bei INTERFACE Libraries, sonst `PRIVATE`
- **OUTPUT_NAME:** nur bei STATIC/SHARED; der Dateiname weicht dann vom Target-Namen ab, der Target-Name bleibt

### 5.4 Compile Options (seit v0.14.0)

```cmake
apply_warnings(${name})
apply_compiler_options(${name})
target_compile_options(${name} PRIVATE ${compile_options})   # nur wenn nicht leer
```

Die Flags der Library stehen **nach** den Vorgaben, damit ein Flag der Library eine Vorgabe
überstimmt (bei MSVC gewinnt das spätere `/fp:`). Generator Expressions bleiben unverändert.
Eine INTERFACE Library mit `compile_options` bricht mit **E105** ab.

### 5.5 Beschreibung für ein Quellpaket (seit v0.14.0)

Am Ende setzt das Modul bei STATIC/SHARED die Properties, aus denen
[SourcePackage.cmake](SourcePackage.md) das erzeugte `CMakeLists.txt` baut:

| Property | Inhalt |
|----------|--------|
| `CRAFT_LIB_SOURCE_DIR` | absoluter Source-Ordner (`path`) |
| `CRAFT_LIB_FILES` | Sources, Headers und Extras aus `collect_sources()` |
| `CRAFT_LIB_MODULES` | C++20-Module-Units |
| `CRAFT_LIB_PRIVATE_INCLUDES` | Source-Ordner, Includes aus `Source.cmake`, `pch/` |
| `CRAFT_LIB_DEFINES`, `CRAFT_LIB_COMPILE_OPTIONS` | wie gesetzt (`{version}` ersetzt) |
| `CRAFT_LIB_PCH` | gefundener PCH-Header oder leer |
| `CRAFT_LIB_DEPENDENCIES`, `CRAFT_LIB_EXTERNALS` | wie im JSON |
| `CRAFT_LIB_VERSION`, `CRAFT_LIB_OUTPUT_NAME` | wie im JSON (Version mit Rückfall auf die Solution) |
| `CRAFT_EXT_<ext>_LINKS` | Einträge, die das External zu `LINK_LIBRARIES` hinzufügte |
| `CRAFT_EXT_<ext>_PUBLIC` | davon PUBLIC gelinkte (ohne `$<LINK_ONLY:…>` in `INTERFACE_LINK_LIBRARIES`) |
| `CRAFT_EXT_<ext>_OTHER` | Namen aller anderen Properties, die das External am Ziel änderte |

`_craft_target_snapshot` und `_craft_record_external_effect` vergleichen dafür die Properties
in `_CRAFT_EXTERNAL_EFFECT_PROPERTIES` (Link-, Include-, Define-, Options-, Feature-,
Link-Options-, Source- und PCH-Properties, jeweils auch `INTERFACE_*`) vor und nach
`apply_external_to_target`.

---

## 6. Fehlerbehandlung

### 6.1 Fatal Errors

| Code | Bedingung | Lösung |
|------|-----------|--------|
| E001 | Source-Pfad existiert nicht | Pfad prüfen/anlegen |
| E101 | Interne Dependency existiert nicht | Library-Reihenfolge prüfen |
| E105 | `compile_options` an einer INTERFACE Library | Flags an eine STATIC Library verlegen oder entfernen |

### 6.2 Warnings

| Code | Bedingung | Empfehlung |
|------|-----------|------------|
| W101 | Keine Sources gefunden | Source-Dateien hinzufügen |

---

## 7. Siehe auch

- [Libraries.cmake](Libraries.md) — Ruft _create_library_target auf
- [LibraryCollect.cmake](LibraryCollect.md) — Befüllt den Context
- [ExecutableCreate.cmake](ExecutableCreate.md) — Analoges Modul für Executables

---

## 8. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.14.0** | **2026-11-07** | **COMPILE_OPTIONS (PRIVATE, nach `apply_compiler_options`, E105 bei INTERFACE); Beschreibung für Quellpakete (`CRAFT_LIB_*`, `CRAFT_EXT_*`); Modul-Version 1.1.0** |
| 0.10.0 | 2026-10-09 | OUTPUT_NAME und DEFINES (mit `{version}`); Target-Property `CRAFT_PUBLIC_HEADERS_DIR` |
| 0.6.0 | 2025-12-20 | EXTERNAL_OPTIONS Support: apply_external_to_target() statt direktem Linking |
| 0.5.1 | 2025-12-17 | collect_sources() Integration, SourceCollect.cmake Dependency |
| 0.5.0 | 2025-12-15 | Migration auf Blueprint v0.5.0 |
| 0.1.0 | 2025-12-07 | Initial (Clean Start): STATIC/SHARED/INTERFACE Support |
