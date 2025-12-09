# Guidelines – CMake Architecture V2

> **Version:** 0.1.0  
> **Datum:** 2025-12-03  
> **Typ:** Konzept-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, ErrorCodes v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Concepts/guidlines_v0_1_0.md)

Dieses Dokument enthält Coding-Konventionen, Stil-Entscheidungen und bekannte Fallstricke für die Implementierung des CMake Build-Systems.

---

## 1. Datei-Struktur

Jede `.cmake`-Datei beginnt mit dem Standard-Header (siehe [CMake_Blueprint](../Blueprints/CMake_Blueprint_v0_1_0.md)):

```cmake
# cmake/pfad/Dateiname.cmake
# ===========================
# Kurze Beschreibung (1 Zeile)
#
# Version: X.Y.Z
# Datum:   YYYY-MM-DD
# Status:  In Entwicklung
# Abhängigkeiten: [Liste]

include_guard(GLOBAL)
```

**Warum `include_guard(GLOBAL)`?**
- Verhindert mehrfaches Laden derselben Datei
- `GLOBAL` statt `DIRECTORY`, weil Module aus verschiedenen Verzeichnissen geladen werden können

---

## 2. Namenskonventionen

### Funktionen

| Typ | Prefix | Beispiele |
|-----|--------|-----------|
| Öffentliche API | `cmake_` | `cmake_fatal()`, `cmake_warn()` |
| Context-API | `ctx_` | `ctx_create()`, `ctx_set()`, `ctx_get()` |
| JSON-Helper | `_json_` | `_json_get_string()`, `_json_has_key()` |
| Source-Helper | `_collect_` | `_collect_sources_from_cmake()` |
| Interne/Private | `_` | `_collect_executable()`, `_helper()` |
| Validierung | `validate_` | `validate_external_source()` |
| Hook-Loader | `load_` | `load_prefetch_hook()` |

### Variablen

| Typ | Konvention | Beispiele |
|-----|------------|-----------|
| Lokale Variable | `_snake_case` | `_name`, `_ext_list` |
| Modul-Konstante | `_UPPER_SNAKE` | `_DEFAULT_VALUE` |
| Output-Parameter | `OUT_VAR` | `function(foo OUT_VAR)` |
| Parsed Arguments | `ARG_*` | `ARG_TYPE`, `ARG_FLAG` |
| Globale Properties | `UPPER_SNAKE_CASE` | `SOLUTION_JSON` |
| Context-Keys | `UPPER_SNAKE_CASE` | `ctx_set(EXE NAME)` |
| Cache-Variablen | `UPPER_SNAKE_CASE` | `BUILD_TESTS` |

### Fehlercodes

| Bereich | Prefix | Beispiele |
|---------|--------|-----------|
| JSON/Parsing | `E0xx` | E001, E002, E010, E012 |
| Target-Erstellung | `E1xx` | E101, E102, E103, E104 |
| Externals | `E2xx` | E201, E213, E214, E215, E216 |
| Deprecation | `W0xx` | W001, W002 |
| Konfiguration | `W1xx` | W101-W110 |
| Tools/Setup | `W2xx` | W201 |

---

## 3. Cache-Variablen

### Build Control

| Variable | Typ | Default | Beschreibung |
|----------|-----|---------|--------------|
| `BUILD_TESTS` | BOOL | ON | Tests aktivieren |
| `BUILD_ONLY` | STRING | "" | Nur bestimmte Targets |
| `RUN_BUILD_SYSTEM_TESTS` | BOOL | OFF | Interne Build-Tests |

### Code-Qualität

| Variable | Typ | Default | Beschreibung |
|----------|-----|---------|--------------|
| `ENABLE_CLANG_TIDY` | BOOL | OFF | Clang-Tidy aktivieren |
| `CLANG_TIDY_STRICT` | BOOL | OFF | Warnings als Errors |
| `ENABLE_CLANG_FORMAT_CHECK` | BOOL | OFF | Format-Checks |

### Compiler-Optionen

| Variable | Typ | Default | Beschreibung |
|----------|-----|---------|--------------|
| `ENABLE_STRICT_CONFORMANCE` | BOOL | ON | MSVC strict mode |
| `NO_EXCEPTIONS` | BOOL | OFF | Exceptions deaktivieren |
| `NO_RTTI` | BOOL | OFF | RTTI deaktivieren |

---

## 4. Error-Handling

### Funktionen

```cmake
# Fataler Fehler - bricht Build ab
cmake_fatal("E001" "Beschreibung mit ${variable}")

# Warnung - Build läuft weiter
cmake_warn("W001" "Beschreibung mit ${variable}")

# Assertion - für interne Prüfungen
cmake_assert(DEFINED _variable "Variable muss definiert sein")

# Feld-Validierung
cmake_require_field(CTX "name" "Executable")
```

### Fehler-Format

```
[E101] Dependency 'CoreLib' für 'MyApp' existiert nicht
 ^      ^                                ^
 |      |                                |
 Code   Beschreibung                     Context
```

---

## 5. Executable-Pipeline

Ein Executable durchläuft diese Schritte:

```
1. ExecutableCollect    → JSON → Context
2. Validation           → Pflichtfelder prüfen
3. ExecutableCreate     → add_executable()
4. SourceCollect        → Sources sammeln
5. Dependencies         → Interne Libs linken
6. Externals            → Externe Libs linken
7. CompilerOptions      → Flags setzen
8. Warnings             → Warning-Level
9. OutputDirs           → Zielverzeichnisse
```

---

## 6. Local Externals Best Practices

### Include.cmake sollte:

```cmake
# ✅ Libraries linken
target_link_libraries(${EXECUTABLE_NAME} PRIVATE bass)

# ✅ Include-Verzeichnisse
target_include_directories(${EXECUTABLE_NAME} PRIVATE ...)

# ✅ Compile-Definitions
target_compile_definitions(${EXECUTABLE_NAME} PRIVATE ...)

# ✅ DLLs kopieren
add_custom_command(TARGET ${EXECUTABLE_NAME} POST_BUILD ...)
```

### Include.cmake sollte NICHT:

```cmake
# ❌ KEINE Executables erstellen
add_executable(bass_example ...)

# ❌ KEINE Beispiel-Subdirectories
add_subdirectory(examples)
add_subdirectory(tests)

# ❌ KEINE globalen Cache-Variablen
set(GLOBAL_VAR "value" CACHE INTERNAL "")
```

**Problem:** IDE Clutter durch unerwünschte Targets.

---

## 7. Hook-System Best Practices

### Wann Hooks verwenden?

| Situation | Hook nötig? |
|-----------|-------------|
| Standard CMake-Projekt | ❌ Nein |
| CMake-Variablen VOR Fetch | ✅ PreFetch |
| Kein CMakeLists.txt | ✅ PostFetch |
| Patches nötig | ✅ PostFetch |
| Lokales External | ❌ Include.cmake |

### Hook-Struktur

```cmake
# cmake/externals/Hooks/PostFetch/imgui.cmake

include_guard(GLOBAL)  # Wichtig für shared Hooks!

message(STATUS "[ImGui PostFetch] Creating target...")

FetchContent_GetProperties(imgui)
if(imgui_POPULATED)
    if(NOT TARGET imgui)
        add_library(imgui STATIC ...)
    endif()
endif()
```

---

## 8. Source.cmake Best Practices

### Explizite Listen bevorzugen

```cmake
# ✅ Empfohlen: Explizite Auflistung
set(_local_sources
    "${CMAKE_CURRENT_LIST_DIR}/main.cpp"
    "${CMAKE_CURRENT_LIST_DIR}/app.cpp"
)
```

### GLOB nur für generierte Dateien

```cmake
# ✅ OK: GLOB mit Excludes für generierte Dateien
collect_files(_generated
    DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/generated"
    EXTENSIONS cpp
    EXCLUDE "*_test.cpp"
)
```

### Hierarchische Struktur

```cmake
# Hauptverzeichnis
list(APPEND ${TARGET_NAME}_SOURCES ${_local_sources})

# Unterverzeichnisse einbinden
include("${CMAKE_CURRENT_LIST_DIR}/core/Source.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/ui/Source.cmake")
```

---

## 9. Debug-System

### Verwendung

```cmake
# Am Anfang des Moduls
set(_SHOW_DEBUG OFF)
dbg_init(ID MY_DBG LEVEL ${DBG_SHOW_MUCH} SWITCH ${_SHOW_DEBUG} TAG "MODUL")

# Im Code
dbg(${DBG_OFTEN} "Phase Start" ID MY_DBG)
dbg(${DBG_COMMON} "Processing ${_name}" ID MY_DBG)
dbg(${DBG_RARE} "Details: ${_val}" ID MY_DBG)

# Am Ende
enddbgblock(ID MY_DBG)
```

### Debug-Level

| Level | Verwenden für |
|-------|---------------|
| `DBG_OFTEN` | Phasen-Start/Ende |
| `DBG_COMMON` | Features, Dateien |
| `DBG_NORMAL` | Zwischenschritte |
| `DBG_RARE` | Details, Pfade |
| `DBG_ULTRA_RARE` | Loop-Iterationen |

---

## 10. Clang-Tidy & Clang-Format

### Philosophie

| Was | Wo |
|-----|----|
| `.clang-format` | Root-Verzeichnis |
| `.clang-tidy` | Root-Verzeichnis |
| Enable/Disable | CMake Cache-Variable |

### Integration

```cmake
if(ENABLE_CLANG_TIDY)
    find_program(CLANG_TIDY_EXE NAMES clang-tidy)
    if(CLANG_TIDY_EXE)
        set_target_properties(${TARGET} PROPERTIES
            CXX_CLANG_TIDY "${CLANG_TIDY_EXE};--config-file=..."
        )
    endif()
endif()
```

---

## 11. Per-Target Compiler Overrides

```cmake
# Legacy-Code: Strict mode überspringen
apply_compiler_options(LegacyTarget SKIP_STRICT_CONFORMANCE)

# Win32 API: min/max Makros erlauben
apply_compiler_options(Win32Target SKIP_NOMINMAX)

# Externe Lib: Exceptions erzwingen
apply_compiler_options(ExternalLib FORCE_EXCEPTIONS)

# Tests: Clang-Tidy überspringen
apply_compiler_options(TestTarget SKIP_CLANG_TIDY)
```

---

## 12. Siehe auch

- [master_concept](master_concept_v0_1_0.md) – Architektur
- [ErrorCodes](../References/ErrorCodes_v0_1_0.md) – Fehlercodes
- [CMake_Blueprint](../Blueprints/CMake_Blueprint_v0_1_0.md) – Modul-Struktur
- [Documentation_Blueprint](../Blueprints/Documentation_Blueprint_v0_1_0.md) – Doku-Struktur

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-03** | **Initial (Clean Start): Inhalte aus v1.7 übernommen, Blueprint-Format, Source.cmake Best Practices hinzugefügt** |
