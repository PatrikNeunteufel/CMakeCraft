# ExecutableCollect.cmake – Modul-Dokumentation

> **Modul-Version:** 0.1.0  
> **Dokument-Version:** 0.1.0  
> **Datum:** 2025-12-05  
> **Pfad:** `cmake/project/ExecutableCollect.cmake`  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, Solution_Schema v0.1, guidelines v0.1

---

## 1. Übersicht

Das `ExecutableCollect.cmake` Modul sammelt alle Daten eines Executables aus JSON und speichert sie in einem Context. Es ist für das Parsen und Normalisieren der Executable-Definitionen zuständig.

### Verantwortlichkeiten

- JSON-Felder extrahieren
- Default-Werte anwenden
- Daten normalisieren (z.B. TYPE uppercase)
- Context mit allen Keys befüllen

---

## 2. Abhängigkeiten

**Muss vorher geladen werden:**

```cmake
include(cmake/core/Json.cmake)
include(cmake/core/Context.cmake)
include(cmake/core/Debug.cmake)
```

---

## 3. Bereitgestellte Funktion

### _collect_executable

```cmake
_collect_executable(EXE_JSON CTX)
```

**Parameter:**

| Parameter | Beschreibung |
|-----------|--------------|
| `EXE_JSON` | JSON-String des Executables |
| `CTX` | Context-Prefix (z.B. `EXE_0`, `EXE_1`) |

**Beispiel:**

```cmake
ctx_create(EXE_0)
_collect_executable("${_exe_json}" EXE_0)

ctx_get(EXE_0 NAME _name)
ctx_get(EXE_0 PATH _path)
```

---

## 4. Gesetzte Context-Keys

### 4.1 Pflichtfelder

| Key | Quelle | Beschreibung |
|-----|--------|--------------|
| `NAME` | `name` | Target-Name (Pflicht) |

### 4.2 Optionale Felder mit Defaults

| Key | JSON-Feld | Default | Beschreibung |
|-----|-----------|---------|--------------|
| `DISPLAY_NAME` | `displayName` | NAME | Anzeigename |
| `DESCRIPTION` | `description` | `""` | Beschreibung |
| `VERSION` | `version` | Solution-Version | Versionsnummer |
| `PATH` | `path` | `projects/exec/{name}/src` | Source-Pfad |
| `TYPE` | `type` | Settings-Default oder `CONSOLE` | Executable-Typ |
| `SKIP` | `skip` | `FALSE` | Überspringen? |

### 4.3 PCH (Precompiled Headers)

| Key | JSON-Feld | Default | Beschreibung |
|-----|-----------|---------|--------------|
| `PCH_ENABLED` | `pch.enabled` | `FALSE` | PCH aktiviert? |
| `PCH_HEADER` | `pch.header` | `pch.h` | PCH-Header-Datei |

### 4.4 Dependencies

| Key | JSON-Feld | Default | Beschreibung |
|-----|-----------|---------|--------------|
| `DEPENDENCIES` | `dependencies` | `[]` | Interne Libraries |
| `EXTERNALS` | `externals` | `[]` | Externe Abhängigkeiten |
| `EXTERNAL_OPTIONS` | `external_options` | `{}` | Per-External Optionen |

### 4.5 Build-Optionen

| Key | JSON-Feld | Default | Beschreibung |
|-----|-----------|---------|--------------|
| `PLATFORMS` | `platforms` | `[]` (alle) | Unterstützte Plattformen |
| `DEFINES` | `defines` | `[]` | Preprocessor-Definitionen |
| `COMPILE_OPTIONS` | `compile_options` | `[]` | Compiler-Optionen |
| `LINK_OPTIONS` | `link_options` | `[]` | Linker-Optionen |

---

## 5. Default-Werte

### 5.1 Path Convention

Wenn `path` nicht angegeben:
```
projects/exec/{name}/src
```

**Beispiel:** `name: "MyApp"` → `projects/exec/MyApp/src`

### 5.2 Type Default

Reihenfolge der Auflösung:
1. Expliziter Wert im JSON
2. `SOLUTION_DEFAULT_EXECUTABLE_TYPE` Property
3. Fallback: `CONSOLE`

### 5.3 Version Default

Wenn `version` nicht angegeben wird die Solution-Version verwendet.

---

## 6. JSON-Beispiel

### 6.1 Minimal

```json
{
    "name": "MyApp"
}
```

Resultierende Context-Keys:
- `NAME` = `"MyApp"`
- `PATH` = `"projects/exec/MyApp/src"`
- `TYPE` = `"CONSOLE"` (oder Solution-Default)
- `SKIP` = `FALSE`

### 6.2 Vollständig

```json
{
    "name": "MyApp",
    "displayName": "My Application",
    "description": "A sample application",
    "version": "1.2.3",
    "path": "src/apps/myapp",
    "type": "GUI",
    "skip": false,
    "pch": {
        "enabled": true,
        "header": "pch.h"
    },
    "dependencies": ["CoreLib", "AudioLib"],
    "externals": ["imgui", "bass"],
    "external_options": {
        "bass": {
            "BASS_FLAC": true
        }
    },
    "platforms": ["windows", "linux"],
    "defines": ["USE_FEATURE_X"],
    "compile_options": ["-Wextra"],
    "link_options": []
}
```

---

## 7. Debug-Ausgaben

Bei hohem Debug-Level (4-5):

```
-- [Executables]   Collected MyApp:
-- [Executables]     PATH: src/apps/myapp
-- [Executables]     TYPE: GUI
-- [Executables]     SKIP: FALSE
-- [Executables]     PCH: TRUE (pch.h)
-- [Executables]     DEPENDENCIES: CoreLib;AudioLib
-- [Executables]     EXTERNALS: imgui;bass
-- [Executables]     PLATFORMS: windows;linux
```

---

## 8. Fehlerbehandlung

### E001: Name fehlt

```
[E001] Executable has no 'name' field
```

**Lösung:** `name` Feld hinzufügen (Pflichtfeld).

---

## 9. Siehe auch

- [ExecutableCreate.cmake](ExecutableCreate_cmake_v0_1_0_doc_v0_1.md) – Target-Erstellung
- [Executables.cmake](Executables_cmake_v0_1_0_doc_v0_1.md) – Orchestrator
- [Context.cmake](Context_cmake_v0_1_0_doc_v0_1.md) – Context-System
- [Solution_Schema](../References/Solution_Schema_v0_1_0.md) – Alle Felder

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-05** | **Clean Start: Englische Kommentare, v0.1 Schema** |
