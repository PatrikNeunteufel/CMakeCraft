# AppCollect.cmake — Dokumentation

> **Version:** 1.0.0  
> **Date:** 2026-07-20  
> **Type:** ModuleDoc  
> **Status:** In Development  
> **Target Audience:** Build System Developers  
> **Module:** [cmake/project/AppCollect.cmake](../../../../cmake/project/AppCollect.cmake)  
> **Module Version:** 1.0.0  
> **Based on:** ModuleDoc v0.5  
> **Language:** English  
> **German:** [AppCollect.md](AppCollect.md)

---

## Table of Contents

1. [Overview](#1-übersicht)
2. [Dependencies](#2-abhängigkeiten)
3. [Concept](#3-konzept)
4. [API-Reference](#4-api-referenz)
5. [Context-Keys](#5-context-keys)
6. [Usagesbeispiele](#6-verwendungsbeispiele)
7. [Errorbehandlung](#7-fehlerbehandlung)
8. [Best Practices](#8-best-practices)
9. [See Also](#9-siehe-auch)
10. [Changelog](#10-changelog)

---

## 1. Overview

Das `AppCollect`-Modul ist verantwortlich für das **Parsen von App-Container-Definitionen** aus der Solution.json und das Speichern der extrahierten Daten in einem Context-Objekt.

### Zweck

- Extraktion aller App-Container-Felder aus JSON
- Transformation in typisierte Context-Keys
- Anwendung von Default-Werten
- Validierung von Requiredfeldern

### Features

- Vollständiges Parsing der `apps[]` JSON-Struktur
- Separate Behandlung von Core-, Runner- und Test-Configuration
- Intelligente Defaults (Convention over Configuration)
- Debug-Output für Diagnose

---

## 2. Dependencies

| Abhängigkeit | Typ | Description |
|--------------|-----|--------------|
| CMake 3.19+ | System | JSON-Functions, `include_guard(GLOBAL)` |
| `Json.cmake` | Modul | JSON-Parsing-Functions |
| `Context.cmake` | Modul | Context-Object-Pattern |
| `Debug.cmake` | Modul | Debug-Ausgabe |
| `Errors.cmake` | Modul | Errorbehandlung |

---

## 3. Concept

### 3.1 App-Container-Architecture

Ein App-Container trennt Business-Logik (Core) vom Entry-Point (Runner):

```
┌─────────────────────────────────────────┐
│           App-Container                  │
│  ┌─────────────────────────────────┐    │
│  │      AppName.Core (STATIC)      │    │
│  │  ┌─────────┐ ┌─────────┐        │    │
│  │  │ Module A│ │ Module B│        │    │
│  │  └─────────┘ └─────────┘        │    │
│  └─────────────────────────────────┘    │
│                  │                       │
│         ┌───────┼───────┐               │
│         ▼       ▼       ▼               │
│  ┌──────────┐ ┌─────┐ ┌─────┐           │
│  │  Runner  │ │Unit │ │Int. │           │
│  │  (main)  │ │Tests│ │Tests│           │
│  └──────────┘ └─────┘ └─────┘           │
└─────────────────────────────────────────┘
```

### 3.2 JSON → Context Transformation

AppCollect transformiert die hierarchische JSON-Struktur in flache Context-Keys:

```
JSON:                          Context:
{                              
  "name": "AudioPlayer",   →   NAME = "AudioPlayer"
  "core": {                    
    "externals": ["bass"]  →   CORE_EXTERNALS = "bass"
  },                           
  "runner": {                  
    "type": "WINDOW"       →   RUNNER_TYPE = "WINDOW"
  }                            
}                              
```

### 3.3 Default-Werte

Das Modul wendet folgende Defaults an:

| Feld | Default | Begründung |
|------|---------|------------|
| `path` | `projects/apps/{name}` | Convention over Configuration |
| `runner.type` | `CONSOLE` | Häufigster Fall |
| `pch.header` | `pch.h` | Standard-Name, Pfad via Suchpriorität |
| `tests.framework` | `""` (empty) | Resolved in AppCreate: per-target > global > E301 |
| `targets[].path` | `tests/{type}/{name}` | Convention over Configuration |
| `targets[].timeout` | Type-based | e.g. unit=30s, integration=120s (see [Solution_Schema § 9.9](../../references/Solution_Schema.md#99-test-typen-und-defaults)) |
| `targets[].labels` | Type-based | e.g. unit → `["unit", "fast"]` |
| `targets[].parallel` | Type-based | `FALSE` for performance, system, fuzz, security, ui |

---

## 4. API-Reference

### 4.1 _collect_app()

```cmake
_collect_app(APP_JSON CTX)
```

**Description:**  
Parst eine App-Container-Definition aus JSON und speichert alle Felder im angegebenen Context.

**Parameters:**

| Parameters | Required | Description |
|-----------|---------|--------------|
| `APP_JSON` | ✓ | JSON-String der App-Definition |
| `CTX` | ✓ | Context-Prefix (z.B. `APP_0`, `APP_1`) |

**Rückgabe:**  
Keine direkte Rückgabe. Alle Werte werden als Context-Keys gespeichert.

**Example:**

```cmake
ctx_create(APP_0)
_collect_app("${_app_json}" APP_0)

ctx_get(APP_0 NAME _name)
ctx_get(APP_0 CORE_EXTERNALS _core_ext)
ctx_get(APP_0 RUNNER_TYPE _type)
```

**Error:**
- `E400` if the `name` field is missing
- `E303`/`E304` if a test target is missing `name` or `type`

---

## 5. Context-Keys

### 5.1 Basis-Keys

| Key | Typ | JSON-Pfad | Default |
|-----|-----|-----------|---------|
| `NAME` | String | `name` | ⛔ Required |
| `DISPLAY_NAME` | String | `displayName` | = NAME |
| `DESCRIPTION` | String | `description` | `""` |
| `VERSION` | String | `version` | Solution-Version |
| `PATH` | String | `path` | `projects/apps/{name}` |
| `SKIP` | Bool | `skip` | `FALSE` |
| `PLATFORMS` | List | `platforms[]` | `[]` (alle) |

### 5.2 Core-Keys

| Key | Typ | JSON-Pfad | Default |
|-----|-----|-----------|---------|
| `CORE_DEPENDENCIES` | List | `core.dependencies[]` | `[]` |
| `CORE_EXTERNALS` | List | `core.externals[]` | `[]` |
| `CORE_EXTERNAL_OPTIONS` | JSON | `core.external_options` | `{}` |

### 5.3 Runner-Keys

| Key | Typ | JSON-Pfad | Default |
|-----|-----|-----------|---------|
| `RUNNER_TYPE` | String | `runner.type` | `CONSOLE` |
| `RUNNER_EXTERNALS` | List | `runner.externals[]` | `[]` |
| `RUNNER_EXTERNAL_OPTIONS` | JSON | `runner.external_options` | `{}` |

### 5.4 PCH-Keys

| Key | Typ | JSON-Pfad | Default |
|-----|-----|-----------|---------|
| `PCH_ENABLED` | Bool | `pch.enabled` | `FALSE` |
| `PCH_HEADER` | String | `pch.header` | `pch.h` |
| `PCH_PATH` | String | `pch.path` | `""` (leer) |

**Note:** PCH wird implizit aktiviert wenn `pch.header` oder `pch.path` angegeben ist und `pch.enabled` nicht explizit `false` ist.

### 5.5 Test-Keys (global)

| Key | Typ | JSON-Pfad | Default |
|-----|-----|-----------|---------|
| `TESTS_FRAMEWORK` | String | `tests.framework` | `""` (empty, resolved in AppCreate) |
| `TESTS_SKIP` | Bool | `tests.skip` | `FALSE` |
| `TESTS_TARGETS_COUNT` | Number | (length of `tests.targets[]`) | `0` |

### 5.6 Test-Target-Keys (per entry in tests.targets[])

`{n}` is the 0-based index into the `targets[]` array.

| Key | Typ | JSON-Pfad | Default |
|-----|-----|-----------|---------|
| `TESTS_TARGET_{n}_NAME` | String | `targets[].name` | ⛔ Required (E303) |
| `TESTS_TARGET_{n}_TYPE` | String | `targets[].type` | ⛔ Required (E304) |
| `TESTS_TARGET_{n}_SKIP` | Bool | `targets[].skip` | `FALSE` |
| `TESTS_TARGET_{n}_PATH` | String | `targets[].path` | `tests/{type}/{name}` |
| `TESTS_TARGET_{n}_FRAMEWORK` | String | `targets[].framework` | `""` (→ `TESTS_FRAMEWORK`) |
| `TESTS_TARGET_{n}_TIMEOUT` | Number | `targets[].timeout` | Type-based |
| `TESTS_TARGET_{n}_LABELS` | List | `targets[].labels[]` | Type-based |
| `TESTS_TARGET_{n}_DEPENDENCIES` | List | `targets[].dependencies[]` | `[]` |
| `TESTS_TARGET_{n}_EXTERNALS` | List | `targets[].externals[]` | `[]` |
| `TESTS_TARGET_{n}_PARALLEL` | Bool | `targets[].parallel` | Type-based |

The type-based defaults (timeout, labels, parallel) come from `_get_test_type_defaults()`; the table is in [Solution_Schema § 9.9](../../references/Solution_Schema.md#99-test-typen-und-defaults).

---

## 6. Usagesbeispiele

### 6.1 Minimale App-Definition

**JSON:**
```json
{
    "apps": [
        {
            "name": "SimpleApp"
        }
    ]
}
```

**Resultierende Context-Keys:**
```cmake
NAME = "SimpleApp"
DISPLAY_NAME = "SimpleApp"
PATH = "projects/apps/SimpleApp"
RUNNER_TYPE = "CONSOLE"
TESTS_FRAMEWORK = ""
TESTS_TARGETS_COUNT = 0
# ... (alle anderen mit Defaults)
```

### 6.2 Vollständige App-Definition

**JSON:**
```json
{
    "apps": [
        {
            "name": "AudioPlayer",
            "displayName": "Audio Player Application",
            "version": "2.0.0",
            
            "core": {
                "dependencies": ["BasicLogger"],
                "externals": ["bass", "spdlog"]
            },
            
            "runner": {
                "type": "WINDOW",
                "externals": ["imgui_docking", "glad", "glfw"]
            },
            
            "pch": {
                "enabled": true
            },
            
            "tests": {
                "framework": "doctest",
                "targets": [
                    {
                        "name": "UnitTests",
                        "type": "unit",
                        "timeout": 30,
                        "labels": ["unit", "audio"]
                    },
                    {
                        "name": "IntegrationTests",
                        "type": "integration",
                        "timeout": 120,
                        "labels": ["integration", "audio"],
                        "dependencies": ["BasicLogger"],
                        "externals": ["bass"]
                    }
                ]
            },
            
            "platforms": ["windows", "linux", "macos"]
        }
    ]
}
```

### 6.3 Usage in Apps.cmake

```cmake
# Iteration über apps Array
foreach(_idx RANGE 0 ${_last_idx})
    _json_array_get("${_solution_json}" "apps" ${_idx} _app_json)
    
    # Context erstellen und befüllen
    ctx_create(APP_${_idx})
    _collect_app("${_app_json}" APP_${_idx})
    
    # Werte nutzen
    ctx_get(APP_${_idx} NAME _name)
    ctx_get(APP_${_idx} SKIP _skip)
    
    if(_skip)
        continue()
    endif()
    
    # Weiter mit AppCreate...
endforeach()
```

---

## 7. Errorbehandlung

### 7.1 Ausgelöste Error

| Code | Bedingung | Meldung |
|------|-----------|---------|
| `E400` | `name` field missing | `App definition missing required 'name' field` |
| `E303` | Test target without `name` | `Test target [{n}] missing required 'name' field` |
| `E304` | Test target without `type` | `Test target '{name}' missing required 'type' field` |

### 7.2 Ausgelöste Warnings

| Code | Bedingung |
|------|-----------|
| `W401` | `tests.targets` is present but empty |
| `W402` | `parallel: true` on a serial test type (performance, system, fuzz, security, ui) |

### 7.3 Error-Kontext

AppCollect löst nur Parsing-Error aus. Validierungsfehler (Pfad existiert nicht, unbekanntes Framework, unbekannte Dependency, etc.) werden von `AppCreate` behandelt (E301/E302/E305, E101).

---

## 8. Best Practices

### 8.1 Do's

| Empfehlung | Begründung |
|------------|------------|
| Context nach Collect sofort prüfen | Frühe Errorerkennung |
| Debug-Level ULTRA_RARE für Details nutzen | Vollständige Diagnose |
| Defaults dokumentieren | Transparenz für Anwender |

### 8.2 Don'ts

| Vermeiden | Grund |
|-----------|-------|
| Validierung in Collect | Separation of Concerns |
| Direkte JSON-Zugriffe nach Collect | Context ist Single Source of Truth |
| Hardcoded Defaults ändern | Brechen bestehende Apps |

---

## 9. See Also

- [Apps.cmake](Apps.md) — Orchestrator für App-Pipeline
- [AppCreate.cmake](AppCreate.md) — Target-Erstellung
- [Context.cmake](../core/Context.md) — Context-Object-Pattern
- [Json.cmake](../core/Json.md) — JSON-Parsing
- [AppContainer_Concept.md](../../../konzepte/abgeschlossen/AppContainer_Concept.md) — Concept-Dokument
- [ErrorCodes.md](../../references/ErrorCodes.md) — Errorcode-Reference (E4xx)

---

## 10. Changelog

| Version | Datum | Changes |
|---------|-------|------------|
| **0.7.3** | **2026-07-20** | **Test keys updated to the tests.targets[] structure (§ 5.5/5.6): TESTS_TARGET_{n}_* keys documented incl. new DEPENDENCIES key, old tests.unit/tests.integration schema removed; example 6.2 and error list (§ 7) corrected (E400 instead of E401, E303/E304, W401/W402)** |
| 0.7.0 | 2025-12-20 | CORE_EXTERNAL_OPTIONS und RUNNER_EXTERNAL_OPTIONS hinzugefügt |
| 0.5.1 | 2025-12-18 | PCH-Defaults korrigiert: header auf pch.h, PCH_SOURCE entfernt, PCH_PATH hinzugefügt, implizite Aktivierung dokumentiert |
| 0.5.0 | 2025-12-17 | Initial: Phase 8 App-Container JSON-Parsing, Core/Runner/Tests-Trennung, vollständige Context-Keys |
