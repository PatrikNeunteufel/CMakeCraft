# LibraryCreate.cmake — Modul-Dokumentation

> **Modul-Version:** 0.1.0  
> **Dokument-Version:** 0.1  
> **Datum:** 2025-12-07  
> **Pfad:** `cmake/project/LibraryCreate.cmake`  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, Solution_Schema v0.1, guidelines v0.1  
> **Sprache:** Deutsch  

---

## 1. Übersicht

Das `LibraryCreate.cmake` Modul erstellt CMake Library-Targets aus den im Context gespeicherten Daten.

### Verantwortlichkeiten

- Sources sammeln (außer INTERFACE)
- `add_library()` aufrufen
- Include-Directories setzen
- Dependencies linken
- Compiler-Optionen anwenden
- Output-Verzeichnisse konfigurieren

---

## 2. Abhängigkeiten

```cmake
# Voraussetzungen
include(cmake/core/Errors.cmake)
include(cmake/core/Debug.cmake)
include(cmake/core/Context.cmake)
include(cmake/core/SourceCollect.cmake)
include(cmake/core/CompilerOptions.cmake)
include(cmake/core/Warnings.cmake)
include(cmake/core/OutputDirs.cmake)
```

---

## 3. API

### _create_library_target()

```cmake
_create_library_target(CTX_PREFIX)
```

**Parameter:**
- `CTX_PREFIX` — Context-Prefix mit Library-Daten

**Aktionen:**
1. Daten aus Context lesen
2. Sources sammeln (STATIC/SHARED) oder überspringen (INTERFACE)
3. `add_library()` aufrufen
4. Include-Directories setzen
5. Dependencies linken
6. Compiler-Optionen anwenden
7. Output-Directories setzen

---

## 4. Library-Typen im Detail

### 4.1 STATIC Library

```cmake
add_library(MyLib STATIC ${_sources})
```

- Erzeugt `.a` (Linux/macOS) oder `.lib` (Windows)
- Wird in Executable eingebunden
- Sources erforderlich

### 4.2 SHARED Library

```cmake
add_library(MyLib SHARED ${_sources})
```

- Erzeugt `.so` (Linux), `.dylib` (macOS), `.dll` (Windows)
- Wird zur Laufzeit geladen
- Sources erforderlich

### 4.3 INTERFACE Library

```cmake
add_library(MyLib INTERFACE)
```

- **Keine Sources**
- Nur Header und Properties
- Ideal für Header-Only Libraries
- Dependencies werden als INTERFACE propagiert

---

## 5. Include-Directories

### Private (nur für Library selbst)

```cmake
target_include_directories(${_name} PRIVATE "${_source_dir}")
```

### Public (für Library und alle die sie nutzen)

```cmake
target_include_directories(${_name} PUBLIC
    "${CMAKE_SOURCE_DIR}/${_public_headers}"
)
```

### INTERFACE Library

```cmake
target_include_directories(${_name} INTERFACE
    "${CMAKE_SOURCE_DIR}/${_public_headers}"
)
```

---

## 6. Dependency Linking

### STATIC/SHARED

```cmake
target_link_libraries(${_name} PUBLIC ${_dependencies})
```

PUBLIC bedeutet: Dependencies werden an Targets weitergegeben, die diese Library nutzen.

### INTERFACE

```cmake
target_link_libraries(${_name} INTERFACE ${_dependencies})
```

---

## 7. Source Collection

Verwendet den globalen `SOLUTION_SOURCE_MODE`:

| Mode | Verhalten |
|------|-----------|
| `explicit` | Source.cmake erforderlich |
| `glob` | Automatisches GLOB |
| `auto` | Source.cmake wenn vorhanden, sonst GLOB |

**INTERFACE Libraries:** Überspringen Source Collection komplett.

---

## 8. Fehlerbehandlung

### E104: Source.cmake nicht gefunden

```
[E104] Source.cmake not found: /path/to/lib/src/Source.cmake
```

**Lösung:** Source.cmake erstellen oder `sources.mode: "glob"` verwenden.

### E105: Keine Sources gefunden

```
[E105] No source files found for library 'MyLib' in /path/to/src
```

**Lösung:** Quelldateien hinzufügen oder auf INTERFACE umstellen.

### E101: Dependency existiert nicht

```
[E101] Dependency 'CoreLib' for library 'MyLib' does not exist
```

**Lösung:** Dependency zuerst definieren oder Name korrigieren.

---

## 9. Debug-Ausgaben

```
-- [Libraries]   Sources: 5 file(s)
-- [Libraries]   Target created: CoreLib (STATIC)
```

Oder für INTERFACE:

```
-- [Libraries]   Created INTERFACE library: BasicLogger
```

---

## 10. Beispiel-Ablauf

### INTERFACE Library (BasicLogger)

1. Context enthält: `TYPE=INTERFACE`, `PUBLIC_HEADERS=.../include`
2. `add_library(BasicLogger INTERFACE)`
3. `target_include_directories(BasicLogger INTERFACE ...)`
4. Fertig (keine Sources, keine Compiler-Optionen)

### STATIC Library (CoreLib)

1. Context enthält: `TYPE=STATIC`, `PATH=.../src`
2. Sources sammeln via Source.cmake oder GLOB
3. `add_library(CoreLib STATIC ${sources})`
4. Private + Public Includes setzen
5. Dependencies linken
6. `apply_compiler_options(CoreLib)`
7. `apply_warning_level(CoreLib)`
8. `apply_output_directories(CoreLib "LIBRARY")`

---

## 11. Siehe auch

- [LibraryCollect.cmake](LibraryCollect_cmake_v0_1_0_doc_v0_1.md) — Daten-Sammlung
- [Libraries.cmake](Libraries_cmake_v0_1_0_doc_v0_1.md) — Orchestrator
- [SourceCollect.cmake](SourceCollect_cmake_v0_1_1_doc_v1.md) — Source-Management
- [ExecutableCreate.cmake](ExecutableCreate_cmake_v0_1_0_doc_v0_1.md) — Analoges Modul

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-07** | **Initial: STATIC/SHARED/INTERFACE Support, Source Collection** |
