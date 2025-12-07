# LibraryCollect.cmake — Modul-Dokumentation

> **Modul-Version:** 0.1.0  
> **Dokument-Version:** 0.1  
> **Datum:** 2025-12-07  
> **Pfad:** `cmake/project/LibraryCollect.cmake`  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, Solution_Schema v0.1, guidelines v0.1

---

## 1. Übersicht

Das `LibraryCollect.cmake` Modul extrahiert Library-Daten aus dem JSON-Element und speichert sie strukturiert in einem Context-Objekt.

### Verantwortlichkeiten

- JSON-Felder auslesen
- Defaults anwenden
- Daten in Context speichern
- Validierung der Werte

---

## 2. Abhängigkeiten

```cmake
# Voraussetzungen
include(cmake/core/Errors.cmake)
include(cmake/core/Debug.cmake)
include(cmake/core/Context.cmake)
include(cmake/core/Json.cmake)
```

---

## 3. API

### _collect_library()

```cmake
_collect_library(JSON_ELEMENT CTX_PREFIX)
```

**Parameter:**
- `JSON_ELEMENT` — JSON-Objekt für diese Library
- `CTX_PREFIX` — Context-Prefix (z.B. "LIB_CoreLib")

**Gesetzte Context-Keys:**

| Key | Typ | Beschreibung |
|-----|-----|--------------|
| `NAME` | String | Library-Name (Pflicht) |
| `VERSION` | String | Version (optional) |
| `PATH` | String | Source-Pfad |
| `TYPE` | String | STATIC, SHARED, INTERFACE |
| `PUBLIC_HEADERS` | String | Öffentliche Header |
| `DEPENDENCIES` | List | Interne Dependencies |
| `EXTERNALS` | List | Externe Dependencies |
| `SKIP` | Bool | Skip-Flag |
| `PLATFORM` | String | Ziel-Plattform |

---

## 4. Default-Werte

### 4.1 Path Convention

Wenn `path` nicht angegeben:
```
projects/libs/{name}/src
```

**Beispiel:** `name: "CoreLib"` → `projects/libs/CoreLib/src`

### 4.2 Type Default

Reihenfolge der Auflösung:
1. Expliziter Wert im JSON
2. `SOLUTION_DEFAULT_LIBRARY_TYPE` Property
3. Fallback: `STATIC`

### 4.3 Public Headers Convention

Wenn `public_headers` nicht angegeben, wird geprüft ob existiert:
```
projects/libs/{name}/include
```

Falls ja, wird dieser Pfad automatisch verwendet.

---

## 5. JSON-Beispiele

### 5.1 Minimal

```json
{
    "name": "CoreLib"
}
```

Resultierende Context-Keys:
- `NAME` = `"CoreLib"`
- `PATH` = `"projects/libs/CoreLib/src"`
- `TYPE` = `"STATIC"` (oder Solution-Default)
- `SKIP` = `FALSE`

### 5.2 Header-Only

```json
{
    "name": "BasicLogger",
    "type": "INTERFACE",
    "public_headers": "projects/libs/BasicLogger/include"
}
```

### 5.3 Vollständig

```json
{
    "name": "AudioLib",
    "version": "1.0.0",
    "path": "libs/audio/src",
    "type": "SHARED",
    "public_headers": "libs/audio/include",
    "dependencies": ["CoreLib"],
    "externals": ["bass"],
    "skip": false,
    "platform": "windows"
}
```

---

## 6. Validierung

### Type-Validierung

Gültige Werte: `STATIC`, `SHARED`, `INTERFACE`

```cmake
set(_valid_types "STATIC;SHARED;INTERFACE")
if(NOT "${_type}" IN_LIST _valid_types)
    cmake_fatal("E003" "Invalid library type...")
endif()
```

---

## 7. Debug-Ausgaben

Bei hohem Debug-Level (4-5):

```
-- [Libraries]   Collected: CoreLib
-- [Libraries]     Type: STATIC
-- [Libraries]     Path: projects/libs/CoreLib/src
-- [Libraries]     Public Headers: projects/libs/CoreLib/include
-- [Libraries]     Dependencies: 
-- [Libraries]     Externals: 
```

---

## 8. Fehlerbehandlung

### E001: Name fehlt

```
[E001] Library has no 'name' field
```

**Lösung:** `name` Feld hinzufügen (Pflichtfeld).

### E003: Ungültiger Type

```
[E003] Invalid library type 'DYNAMIC'...
```

**Lösung:** STATIC, SHARED oder INTERFACE verwenden.

---

## 9. Siehe auch

- [LibraryCreate.cmake](LibraryCreate_cmake_v0_1_0_doc_v0_1.md) — Target-Erstellung
- [Libraries.cmake](Libraries_cmake_v0_1_0_doc_v0_1.md) — Orchestrator
- [Context.cmake](Context_cmake_v0_1_1_doc_v1.md) — Context-System
- [Solution_Schema](../References/Solution_Schema_v0_1_0.md) — Alle Felder

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-07** | **Initial: JSON-Extraktion, Defaults, Type-Validierung** |
