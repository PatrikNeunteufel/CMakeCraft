# Externals.cmake – Dokumentation

> **Version:** 0.1.0 (doc v1)  
> **Datum:** 2025-12-08  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/project/Externals.cmake  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch

---

## 1. Übersicht

Das `Externals.cmake` Modul ist die **Hauptschleife** für die Verarbeitung aller
externen Abhängigkeiten aus der Solution.json.

**Kernaufgaben:**
- Liest den `externals` Block aus Solution.json
- Iteriert über alle definierten Externals
- Dispatcht an den Orchestrator zur Typ-spezifischen Verarbeitung
- Speichert Externals-JSON global für spätere Verwendung

---

## 2. Abhängigkeiten

| Modul | Version | Verwendung |
|-------|---------|------------|
| Errors.cmake | 0.1.x | cmake_fatal(), cmake_warn() |
| Debug.cmake | 0.1.x | dbg(), dbg_init() |
| Json.cmake | 0.1.x | JSON-Parsing |
| Solution.cmake | 0.1.x | SOLUTION_JSON Property |
| Orchestrator.cmake | 0.1.x | External-Type-Dispatch |

---

## 3. Ablauf

```
                    ┌─────────────────────┐
                    │   Solution.json     │
                    │   "externals": {}   │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │  Externals.cmake    │
                    │  (Hauptschleife)    │
                    └──────────┬──────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
     ┌────────▼────────┐  ┌────▼────┐  ┌───────▼───────┐
     │  bass (local)   │  │  lua    │  │ imgui (git)   │
     └────────┬────────┘  └────┬────┘  └───────┬───────┘
              │                │               │
     ┌────────▼────────────────▼───────────────▼───────┐
     │              Orchestrator.cmake                  │
     │         (_orchestrate_external)                  │
     └─────────────────────────────────────────────────┘
```

---

## 4. Gesetzte Properties

| Property | Typ | Beschreibung |
|----------|-----|--------------|
| `SOLUTION_EXTERNALS_JSON` | GLOBAL | Kompletter externals-Block als JSON |

---

## 5. Verwendung

### 5.1 Solution.json

```json
{
    "externals": {
        "bass": { "path": "externals/bass" },
        "lua": { "path": "externals/lua" },
        "imgui": { 
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.90.1"
        }
    }
}
```

### 5.2 Einbindung in CMakeLists.txt

```cmake
# MUSS vor Libraries und Executables kommen!
include(cmake/project/Externals.cmake)
include(cmake/project/Libraries.cmake)
include(cmake/project/Executables.cmake)
```

---

## 6. Debug-Ausgabe

```
-- [Externals] === Externals Pipeline Start ===
-- [Externals] Processing 2 external(s)...
-- [Externals] --- Processing: bass ---
-- [Externals]   Type: LOCAL
-- [Externals]   Path: externals/bass
-- [Externals]   Registered: bass
-- [Externals] --- Processing: imgui ---
-- [Externals]   Type: FETCHED (git)
-- [Externals] === Externals Pipeline Complete ===
```

---

## 7. Fehler

| Code | Beschreibung |
|------|--------------|
| E012 | Kein gültiges Source-Feld (path/git) |
| E213 | Include.cmake nicht gefunden |
| E214 | External-Pfad existiert nicht |

---

## 8. Siehe auch

- [Orchestrator.cmake](../externals/Orchestrator_cmake_v0_1_0_doc_v1.md) – Type-Dispatch
- [Local/Attach.cmake](../externals/Local/Attach_cmake_v0_1_0_doc_v1.md) – Lokale Externals
- [Solution_Schema](../../References/Solution_Schema_v0_1_0.md) – JSON-Schema

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-08** | **Initial: Hauptschleife, Orchestrator-Integration** |
