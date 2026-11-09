# Orchestrator.cmake — External Type Dispatcher

> **Version:** 1.0.2  
> **Datum:** 2026-11-09  
> **Typ:** ModuleDoc  
> **Status:** Aktiv  
> **Basiert auf:** ModuleDoc v0.5, Doc v0.5  
> **Zielgruppe:** Build-System-Entwickler  
> **Sprache:** Deutsch  
> **English:** [Orchestrator_cmake.md](../../../../en/guide/module/externals/Orchestrator_cmake.md)  
> **Modul:** [cmake/externals/Orchestrator.cmake](../../../../../cmake/externals/Orchestrator.cmake)  
> **Modul-Version:** 1.0.0

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [API-Referenz](#3-api-referenz)
4. [Type Detection](#4-type-detection)
5. [Processing Flow](#5-processing-flow)
6. [Verwendungsbeispiele](#6-verwendungsbeispiele)
7. [Fehlerbehandlung](#7-fehlerbehandlung)
8. [Debug-Ausgaben](#8-debug-ausgaben)
9. [Siehe auch](#9-siehe-auch)
10. [Changelog](#10-changelog)

---

## 1. Übersicht

`Orchestrator.cmake` ist der zentrale Entry-Point für die Verarbeitung von Externals. Das Modul erkennt den Typ eines Externals anhand der JSON-Felder und dispatcht zur entsprechenden Handler-Funktion.

### Kernfunktionen

- **Type Detection** — Erkennt System, Fetched, Local und Archive anhand der JSON-Felder
- **Dispatch** — Delegiert an `_handle_system_external()`, `_handle_fetched_external()`, `_attach_local_external()` oder `_handle_archive_external()`
- **Options Extraction** — Extrahiert target-spezifische External-Optionen
- **Apply** — Wendet Externals auf CMake-Targets an

### Architektur-Position

```
Externals.cmake (project)
         │
         ▼
┌─────────────────────┐
│  Orchestrator.cmake │  ← Entry-Point
└──────────┬──────────┘
           │
      ┌────┴───────┬────────────┬────────────┐
      ▼            ▼            ▼            ▼
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ system/  │ │ local/   │ │ fetched/ │ │ archive/ │
│ Handler  │ │ Attach   │ │ Handler  │ │ Handler  │
└──────────┘ └──────────┘ └──────────┘ └──────────┘
```

---

## 2. Abhängigkeiten

### Benötigte Module

| Modul | Zweck |
|-------|-------|
| `Errors.cmake` | Fehlerbehandlung (`cmake_fatal`, `cmake_warn`) |
| `Debug.cmake` | Debug-Ausgaben (`dbg`) |
| `Json.cmake` | JSON-Parsing (`_json_get_string`, `_json_has_key`) |
| `Validation.cmake` | Source-Validierung (`validate_external_source`) |

### Auto-geladene Module

| Modul | Zweck |
|-------|-------|
| `local/Attach.cmake` | Handler für lokale Externals |
| `fetched/Handler.cmake` | Handler für Git-basierte Externals |
| `system/Handler.cmake` | Handler für System Externals (find_package) |
| `archive/Handler.cmake` | Handler für Archive Externals (vorgebautes Paket, festgelegte Version) |

---

## 3. API-Referenz

### 3.1 _orchestrate_external()

Hauptfunktion zur Verarbeitung eines Externals.

```cmake
_orchestrate_external(EXT_NAME EXT_JSON)
```

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| `EXT_NAME` | String | Name des Externals (z.B. "bass", "spdlog") |
| `EXT_JSON` | JSON | JSON-Definition aus Solution.json |

**Verhalten:**
1. Validiert das Source-Feld (`validate_external_source()`: genau eines von `system`, `git`, `path`, `archive`; sonst E012)
2. Erkennt den Typ anhand des vorhandenen Felds (Priorität system → git → path → archive)
3. Dispatcht zu entsprechendem Handler

---

### 3.2 _get_external_options_for_target()

Extrahiert target-spezifische Optionen für ein External.

```cmake
_get_external_options_for_target(TARGET_NAME EXT_NAME TARGET_JSON OUT_VAR)
```

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| `TARGET_NAME` | String | Name des Targets (für Debug) |
| `EXT_NAME` | String | Name des Externals |
| `TARGET_JSON` | JSON | JSON des Targets (Executable/Library) |
| `OUT_VAR` | Variable | Ausgabe: Options-JSON oder `{}` |

---

### 3.3 apply_external_to_target()

Wendet ein External auf ein CMake-Target an.

```cmake
apply_external_to_target(TARGET_NAME EXT_NAME EXT_OPTIONS)
```

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| `TARGET_NAME` | String | CMake-Target, das das External nutzt |
| `EXT_NAME` | String | Name des Externals |
| `EXT_OPTIONS` | JSON | Options-JSON für dieses External |

**Verhalten:**
1. Prüft ob External in `SKIPPED_EXTERNALS` → **E013 FATAL**
2. Holt External-Definition aus `SOLUTION_EXTERNALS_JSON`
3. Erkennt Typ (Prüfreihenfolge hier: system → path → git → archive)
4. Wendet typ-spezifisch an

**Für System Externals:**

Ruft `_apply_system_external_to_target(TARGET_NAME EXT_NAME EXT_OPTIONS)` auf.

**Für lokale Externals — setzt Variablen:**

| Variable | Beschreibung |
|----------|--------------|
| `EXTERNAL_NAME` | Name des Externals |
| `EXTERNAL_ROOT` | Root-Pfad des Externals |
| `EXTERNAL_OPTIONS` | JSON-Options-String |
| `EXECUTABLE_NAME` | Target-Name (Legacy) |

**Für Fetched Externals:**

Linkt das registrierte Target via `_link_external_to_target()`.

**Für Archive Externals:**

Ruft `_apply_archive_external_to_target(TARGET_NAME EXT_NAME EXT_JSON EXT_OPTIONS)` auf — Include-Pfad, Define und Dateien neben die ausführbare Datei.

---

## 4. Type Detection

### Erkennungslogik (Priorität)

| JSON-Feld | Erkannter Typ | Handler |
|-----------|---------------|---------|
| `"system": true` | System | `_handle_system_external()` |
| `"git"` | Fetched | `_handle_fetched_external()` |
| `"path"` | Local | `_attach_local_external()` |
| `"archive": true` | Archive | `_handle_archive_external()` |
| Keines | Fehler E012 | — |

> **Priorität:** system → git → path → archive

### Beispiel-Definitionen

**System:**
```json
{
    "qt6": {
        "system": true,
        "package": "Qt6",
        "components": ["Core", "Widgets"]
    }
}
```

**Lokal:**
```json
{
    "bass": {
        "path": "externals/bass",
        "version": "2.4.17"
    }
}
```

**Fetched:**
```json
{
    "spdlog": {
        "git": "https://github.com/gabime/spdlog.git",
        "tag": "v1.12.0"
    }
}
```

**Archive:**
```json
{
    "toolkit": {
        "archive": true,
        "pin": "toolkit.pin"
    }
}
```

---

## 5. Processing Flow

### Orchestration Flow

```
┌─────────────────────────────────────────────────────────┐
│              _orchestrate_external()                     │
├─────────────────────────────────────────────────────────┤
│  1. validate_external_source()                          │
│     └─ E012 wenn kein oder mehr als ein Source-Feld     │
│                                                         │
│  2. "system": true  → _is_system                        │
│     "git"           → _is_fetched                       │
│     "path"          → _is_local                         │
│     "archive": true → _is_archive                       │
│                                                         │
│  3. Dispatch (Priorität system → git → path → archive): │
│     ├─ _is_system  → _handle_system_external()          │
│     ├─ _is_fetched → _handle_fetched_external()         │
│     ├─ _is_local   → _attach_local_external()           │
│     └─ _is_archive → _handle_archive_external()         │
└─────────────────────────────────────────────────────────┘
```

---

## 6. Verwendungsbeispiele

### Basis-Verwendung (automatisch via ExecutableCreate)

```cmake
# In ExecutableCreate.cmake - automatisch aufgerufen
foreach(_ext IN LISTS _externals)
    _get_external_options_for_target("${_name}" "${_ext}" "${_exe_json}" _ext_opts)
    apply_external_to_target("${_name}" "${_ext}" "${_ext_opts}")
endforeach()
```

### Custom Include Path (optional)

```json
{
    "bass": {
        "path": "externals/bass",
        "include": "cmake/custom/bass_special.cmake"
    }
}
```

> **Hinweis:** Das `include` Feld ist optional und relativ zu `CMAKE_SOURCE_DIR`. Default: `${CMAKECRAFT_DIR}/externals/includes/{name}/Include.cmake` (also `cmake/externals/includes/{name}/Include.cmake` im CMakeCraft-Baum).

---

## 7. Fehlerbehandlung

### Fehler-Codes

| Code | Fehler | Beschreibung |
|------|--------|--------------|
| E010 | External nicht definiert | External nicht in `externals` Block |
| E012 | Kein Source-Feld | Weder `path` noch `git` noch `system` noch `archive` vorhanden |
| E013 | Geskipptes External verwendet | Target referenziert External mit `skip: true` |
| E213 | Include.cmake fehlt | Lokales External ohne Include.cmake |

### Skip-Validierung

`apply_external_to_target()` prüft vor der Anwendung, ob das External geskippt ist:

```cmake
get_property(_skipped_list GLOBAL PROPERTY SKIPPED_EXTERNALS)
if("${EXT_NAME}" IN_LIST _skipped_list)
    cmake_fatal("E013" "External '${EXT_NAME}' is skipped but used by target '${TARGET_NAME}'...")
endif()
```

### Warnungen

| Code | Warnung | Beschreibung |
|------|---------|--------------|
| W101 | External nicht ready | Fetched External noch nicht verfügbar |

---

## 8. Debug-Ausgaben

### Debug-ID: `EXTERNALS`

| Level | Ausgabe |
|-------|---------|
| `DBG_RARE` | Type: SYSTEM / FETCHED (git) / LOCAL / ARCHIVE |
| `DBG_RARE` | Applying {ext} to {target} |
| `DBG_ULTRA_RARE` | Options für External |

### Aktivierung

Der Kontext `EXTERNALS` wird in `project/Externals.cmake` mit `LEVEL ${DBG_SHOW_MUCH}` (3) angelegt; Ausgaben auf
`DBG_RARE` (4) und `DBG_ULTRA_RARE` (5) erscheinen erst, wenn dieses Level dort angehoben wird. Einen Cache-Schalter
je Kontext gibt es nicht; `-DDEBUG_MESSAGES=OFF` schaltet alle Debug-Ausgaben ab.

---

## 9. Siehe auch

- [Attach_cmake.md](locals/Attach_cmake.md) — Lokale Externals
- [Handler_cmake.md](fetched/Handler_cmake.md) — Git Externals
- [archive/Handler_cmake.md](archive/Handler_cmake.md) — Archive Externals
- [Targets_cmake.md](registry/Targets_cmake.md) — Target Registry
- [Externals_cmake.md](../project/Externals.md) — Entry-Point (Project)

---

## 10. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.0.2** | **2026-11-09** | **An den Code angeglichen: alle vier Typen (`system`, `git`, `path`, `archive`) in Übersicht, Architektur, `_orchestrate_external()` und Ablauf; Ordner klein (`local/`, `fetched/`, `system/`); Default-Include `${CMAKECRAFT_DIR}/externals/includes/{name}/Include.cmake`; Debug-Aktivierung ohne das nicht vorhandene `DEBUG_CATEGORIES`** |
| **1.0.1** | **2026-10-09** | **CMakeCraft v0.10.0: External-Art `archive`: Erkennung in `_orchestrate_external()`, Anwenden in `apply_external_to_target()`** |
| 1.0.0 | 2025-12-26 | Release 1 (aus newCMake übernommen, `2e00db7`) |
| 0.7.0 | 2025-12-20 | Skip-Validierung: E013 bei Verwendung geskippter Externals in apply_external_to_target() |
| 0.6.0 | 2025-12-18 | Phase 9: System Externals Support, `_handle_system_external()` |
| 0.5.0 | 2025-12-15 | Dokumentation auf Blueprint v0.5.0 migriert |
