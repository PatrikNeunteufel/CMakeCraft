# Libraries.cmake — Modul-Dokumentation

> **Modul-Version:** 0.1.0  
> **Dokument-Version:** 0.1  
> **Datum:** 2025-12-07  
> **Pfad:** `cmake/project/Libraries.cmake`  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, Solution_Schema v0.1, guidelines v0.1

---

## 1. Übersicht

Das `Libraries.cmake` Modul ist der Orchestrator für die Library-Pipeline. Es verarbeitet alle Libraries aus der `Solution.json` und erstellt die entsprechenden CMake-Targets.

### Verantwortlichkeiten

- Iteration über alle Libraries in `SOLUTION_LIBRARIES_JSON`
- Koordination von LibraryCollect und LibraryCreate
- Skip-Logik (skip-Flag, BUILD_ONLY, Platform)
- Duplikat-Prüfung für Target-Namen

---

## 2. Abhängigkeiten

```cmake
# Voraussetzungen (müssen vorher geladen sein)
include(cmake/core/Errors.cmake)
include(cmake/core/Debug.cmake)
include(cmake/core/Context.cmake)
include(cmake/core/Json.cmake)
include(cmake/project/Solution.cmake)

# Werden automatisch geladen
# - LibraryCollect.cmake
# - LibraryCreate.cmake
```

---

## 3. Verarbeitungsablauf

```
┌─────────────────────────────────────────┐
│ 1. SOLUTION_LIBRARIES_JSON lesen        │
│ 2. Array-Länge ermitteln                │
└─────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ Für jede Library:                       │
│ 3. JSON extrahieren                     │
│ 4. Context erstellen                    │
│ 5. _collect_library() aufrufen          │
└─────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ 6. Skip-Check                           │
│ 7. BUILD_ONLY-Check                     │
│ 8. Platform-Check                       │
│ 9. Target-Duplikat-Check                │
└─────────────────────────────────────────┘
       │
       ▼ (wenn alle Checks bestanden)
┌─────────────────────────────────────────┐
│ 10. _create_library_target()            │
└─────────────────────────────────────────┘
```

---

## 4. Library-Typen

| Typ | CMake | Beschreibung |
|-----|-------|--------------|
| STATIC | `add_library(X STATIC)` | Statische Bibliothek (.a/.lib) |
| SHARED | `add_library(X SHARED)` | Dynamische Bibliothek (.so/.dll) |
| INTERFACE | `add_library(X INTERFACE)` | Header-Only Bibliothek |

### INTERFACE Libraries

INTERFACE Libraries sind besonders für Header-Only Libraries:

- Keine Quelldateien nötig
- Nur `public_headers` wird verwendet
- Dependencies werden als INTERFACE propagiert

```json
{
    "name": "BasicLogger",
    "type": "INTERFACE",
    "public_headers": "projects/libs/BasicLogger/include"
}
```

---

## 5. Debug-Ausgaben

### 5.1 Standard (SHOW_LEVEL = 2)

```
-- [Libraries] === Library Pipeline Start ===
-- [Libraries] Processing 1 library(ies)...
-- [Libraries] --- Processing: BasicLogger ---
-- [Libraries]   Created: BasicLogger
-- [Libraries] === Library Pipeline Complete ===
```

### 5.2 Verbose (SHOW_LEVEL = 5)

```bash
cmake -B build -DDEBUG_DEFAULT_LEVEL=5
```

Zeigt zusätzlich:
- Gesammelte Context-Daten
- Include-Verzeichnisse
- Link-Abhängigkeiten

---

## 6. Fehlerbehandlung

### E001: Name fehlt

```
[E001] Library #0 has no 'name' field
```

**Lösung:** `name` Feld zur Library hinzufügen.

### E102: Target existiert bereits

```
[E102] Target 'MyLib' already exists
```

**Lösung:** Eindeutige Namen verwenden.

### E003: Ungültiger Type

```
[E003] Invalid library type 'DYNAMIC' for 'MyLib'. Valid: STATIC;SHARED;INTERFACE
```

**Lösung:** Gültigen Type verwenden (STATIC, SHARED, INTERFACE).

---

## 7. Verwendung

Das Modul wird in CMakeLists.txt geladen:

```cmake
# Nach Solution.cmake
include(cmake/project/Libraries.cmake)

# Dann Executables (können Libraries verwenden)
include(cmake/project/Executables.cmake)
```

### Reihenfolge ist wichtig!

Libraries müssen **vor** Executables verarbeitet werden, damit Executables gegen sie linken können.

---

## 8. Siehe auch

- [LibraryCollect.cmake](LibraryCollect_cmake_v0_1_0_doc_v0_1.md) — Daten-Sammlung
- [LibraryCreate.cmake](LibraryCreate_cmake_v0_1_0_doc_v0_1.md) — Target-Erstellung
- [Solution_Schema](../References/Solution_Schema_v0_1_0.md) — Library-Felder
- [Executables.cmake](Executables_cmake_v0_1_0_doc_v0_1.md) — Analoges Modul für Executables

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-07** | **Initial: Library Pipeline, STATIC/SHARED/INTERFACE Support** |
