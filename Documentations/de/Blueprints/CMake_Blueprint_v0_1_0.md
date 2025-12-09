# CMake Blueprint – CMake Architecture V2

> **Version:** 0.1.0  
> **Datum:** 2025-12-03  
> **Typ:** Blueprint  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** Documentation_Blueprint v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Blueprints/CMake_Blueprint_v0_1_0.md)

Dieses Dokument definiert die **verbindliche Struktur** für alle CMake-Module (.cmake Dateien) im CMake Architecture V2 Projekt.

---

## 1. Übersicht

### 1.1 Modul-Kategorien

| Kategorie | Pfad | Beschreibung |
|-----------|------|--------------|
| **Core** | `cmake/core/` | Grundbausteine (Errors, Debug, Context, Json, ...) |
| **Project** | `cmake/project/` | Pipelines (Solution, Executables, Libraries, Tests) |
| **Externals** | `cmake/externals/` | External-Handling (Orchestrator, Fetch, Registry, ...) |
| **Info** | `cmake/info/` | Informationsausgabe (Base, Preset) |
| **BuildSystemTest** | `cmake/buildSystemTest/` | Interne Tests für das Build-System |

### 1.2 Modul-Typen

| Typ | Beschreibung | Beispiele |
|-----|--------------|-----------|
| **Utility** | Wiederverwendbare Hilfsfunktionen | Errors.cmake, Debug.cmake, Json.cmake |
| **Pipeline** | Verarbeitet Solution.json Abschnitte | Executables.cmake, Libraries.cmake |
| **Orchestrator** | Koordiniert andere Module | Orchestrator.cmake |
| **Config** | Konfiguriert Targets | CompilerOptions.cmake, Warnings.cmake |
| **Hook** | Anpassung für Externals | PreFetch/*.cmake, PostFetch/*.cmake |
| **Include** | Setup für lokale Externals | externals/*/Include.cmake |

### 1.3 Geplante Module

> **Status-Legende:**  
> ✅ Implementiert | 🔄 In Arbeit | ⬜ Ausstehend

#### Core-Module
| Modul | Status | Beschreibung |
|-------|--------|--------------|
| Errors.cmake | ⬜ | Fehlerbehandlung (cmake_fatal, cmake_warn) |
| Debug.cmake | ⬜ | Debug-System (dbg, dbg_init) |
| Context.cmake | ⬜ | Context-Objekt-Pattern |
| Json.cmake | ⬜ | JSON-Hilfsfunktionen |
| Validation.cmake | ⬜ | Schema-Validierung |
| SourceCollect.cmake | ⬜ | Source-Datei-Management |
| OutputDirs.cmake | ⬜ | Output-Verzeichnisse |
| Warnings.cmake | ⬜ | Warning-Level |
| CompilerOptions.cmake | ⬜ | Compiler-Konfiguration |

#### Project-Module
| Modul | Status | Beschreibung |
|-------|--------|--------------|
| Solution.cmake | ⬜ | Solution.json laden |
| Executables.cmake | ⬜ | Executable-Pipeline |
| ExecutableCollect.cmake | ⬜ | Executable-Daten sammeln |
| ExecutableCreate.cmake | ⬜ | Executable-Target erstellen |
| Libraries.cmake | ⬜ | Library-Pipeline |
| Tests.cmake | ⬜ | Test-Pipeline |

#### Externals-Module
| Modul | Status | Beschreibung |
|-------|--------|--------------|
| Orchestrator.cmake | ⬜ | External-Dispatch |
| Fetch.cmake | ⬜ | Git-Fetch |
| Registry.cmake | ⬜ | Target-Registry |
| HookLoader.cmake | ⬜ | Hook-System |

---

## 2. Versionierung

### 2.1 Semantic Versioning

CMake-Module verwenden SemVer:

| Teil | Bedeutung | Wann erhöhen? |
|------|-----------|---------------|
| **0.x.x** | Pre-Release | Noch nicht stabil |
| **MAJOR** | Breaking | API-Änderung, Funktion entfernt |
| **MINOR** | Feature | Neue Funktion, neuer Parameter (optional) |
| **PATCH** | Fix | Bugfix, Performance |

### 2.2 Version im Header

```cmake
# Version: 0.1.0
```

### 2.3 Wann Version erhöhen?

| Änderung | Version |
|----------|---------|
| Neuer optionaler Parameter | MINOR |
| Neuer Pflicht-Parameter | MAJOR |
| Funktion entfernt | MAJOR |
| Funktion deprecated | MINOR |
| Bugfix | PATCH |
| Performance-Verbesserung | PATCH |
| Neuer Error Code | MINOR |
| Verhalten geändert (Breaking) | MAJOR |

---

## 3. Datei-Header

### 3.1 Standard-Header (Pflicht)

Jede .cmake Datei **muss** mit diesem Header beginnen:

```cmake
# cmake/[pfad]/[ModulName].cmake
# ==============================
# [Kurze Beschreibung - eine Zeile]
#
# Version: X.Y.Z
# Datum:   YYYY-MM-DD
# Status:  [In Entwicklung | Stabil | Deprecated]
# Autor:   [Name/Team]
#
# Abhängigkeiten:
#   - [Modul1].cmake
#   - [Modul2].cmake

include_guard(GLOBAL)
```

### 3.2 Erweiterter Header (für komplexe Module)

```cmake
# cmake/core/Context.cmake
# ========================
# Context-Objekt-Pattern für isolierte Namensräume
#
# Version: 0.1.0
# Datum:   2025-12-03
# Status:  In Entwicklung
# Autor:   [Name/Team]
#
# Abhängigkeiten:
#   - Errors.cmake (cmake_fatal, cmake_assert)
#   - Debug.cmake (dbg, dbg_init)
#
# Stellt bereit:
#   - ctx_create(PREFIX)
#   - ctx_set(PREFIX KEY VALUE)
#   - ctx_get(PREFIX KEY OUT_VAR)
#   - ctx_dump(PREFIX)
#
# Verwendet von:
#   - ExecutableCollect.cmake
#   - LibraryCollect.cmake
#   - TestCollect.cmake

include_guard(GLOBAL)
```

### 3.3 Header-Felder

| Feld | Pflicht | Beschreibung |
|------|---------|--------------|
| Pfad-Kommentar | ✅ | Vollständiger Pfad zur Datei |
| Trennlinie | ✅ | `=` Zeichen, Länge = Pfad-Kommentar |
| Beschreibung | ✅ | Eine Zeile, was das Modul tut |
| Version | ✅ | SemVer (MAJOR.MINOR.PATCH) |
| Datum | ✅ | ISO-Format (YYYY-MM-DD) |
| Status | ✅ | In Entwicklung, Stabil, oder Deprecated |
| Autor | ⬜ | Name oder Team |
| Abhängigkeiten | ✅ | Liste der benötigten Module (oder "Keine") |
| Stellt bereit | ⬜ | Öffentliche API (Funktionen) |
| Verwendet von | ⬜ | Module die dieses verwenden |

### 3.4 Trennlinien-Länge

Die Trennlinie aus `=` Zeichen sollte **exakt** so lang sein wie der Pfad-Kommentar:

```cmake
# cmake/core/Context.cmake
# ========================
```

```cmake
# cmake/project/ExecutableCreate.cmake
# =====================================
```

---

## 4. Datei-Struktur

### 4.1 Empfohlene Reihenfolge

```cmake
# ============================================
# 1. HEADER (siehe Abschnitt 3)
# ============================================

# cmake/core/Example.cmake
# ========================
# Beispiel-Modul zur Demonstration der Struktur
#
# Version: 0.1.0
# Datum:   2025-12-03
# Status:  In Entwicklung
# Abhängigkeiten: Errors.cmake

include_guard(GLOBAL)

# ============================================
# 2. KONSTANTEN / DEFAULTS
# ============================================

set(_EXAMPLE_DEFAULT_VALUE "default")
set(_EXAMPLE_SUPPORTED_TYPES "A;B;C")

# ============================================
# 3. PRIVATE FUNKTIONEN (mit _ Prefix)
# ============================================

#-----------------------------------------------
# _example_helper(INPUT OUT_VAR)
# Interne Hilfsfunktion - nicht für externe Verwendung
#-----------------------------------------------
function(_example_helper INPUT OUT_VAR)
    # Implementation
    set(${OUT_VAR} "${INPUT}_processed" PARENT_SCOPE)
endfunction()

# ============================================
# 4. ÖFFENTLICHE FUNKTIONEN
# ============================================

#[[
    example_do_something(NAME [OPTIONS])
    
    Führt die Hauptaktion des Moduls aus.
    
    Parameter:
        NAME        - Pflicht: Name des Targets
        TYPE        - Optional: Einer von A, B, C (Default: A)
        SHOW_DEBUG  - Optional: Debug-Ausgaben aktivieren
    
    Fehler:
        E001 - wenn NAME leer ist
        E002 - wenn TYPE ungültig ist
    
    Beispiel:
        example_do_something(MyTarget TYPE B)
]]
function(example_do_something NAME)
    # Argument-Parsing
    cmake_parse_arguments(
        ARG                          # Prefix
        "SHOW_DEBUG"                 # Optionen (Flags)
        "TYPE"                       # Ein-Wert-Argumente
        ""                           # Multi-Wert-Argumente
        ${ARGN}
    )
    
    # Defaults
    if(NOT DEFINED ARG_TYPE)
        set(ARG_TYPE "A")
    endif()
    
    # Validierung
    if("${NAME}" STREQUAL "")
        cmake_fatal("E001" "NAME ist Pflicht")
    endif()
    
    if(NOT ARG_TYPE IN_LIST _EXAMPLE_SUPPORTED_TYPES)
        cmake_fatal("E002" "Ungültiger TYPE: ${ARG_TYPE}")
    endif()
    
    # Implementation
    _example_helper("${NAME}" _result)
    
    # Debug (wenn aktiviert)
    if(ARG_SHOW_DEBUG)
        message(STATUS "[Example] ${NAME} -> ${_result}")
    endif()
endfunction()

# ============================================
# 5. MODUL-INITIALISIERUNG (wenn nötig)
# ============================================

# Optional: Code der beim include() ausgeführt wird
# Sollte minimal sein - nur wenn unbedingt nötig!
```

### 4.2 Abschnitte

| Abschnitt | Pflicht | Beschreibung |
|-----------|---------|--------------|
| Header | ✅ | Siehe Abschnitt 3 |
| include_guard | ✅ | Verhindert doppeltes Laden |
| Konstanten | ⬜ | Modul-weite Defaults, Listen |
| Private Funktionen | ⬜ | Mit `_` Prefix, interne Helfer |
| Öffentliche Funktionen | ✅ | Die eigentliche API |
| Initialisierung | ⬜ | Nur wenn unbedingt nötig |

### 4.3 Abschnitts-Trenner

Verwende konsistente Trenner zwischen Abschnitten:

```cmake
# ============================================
# ABSCHNITTSNAME
# ============================================
```

Für Unter-Abschnitte oder einzelne Funktionen:

```cmake
#-----------------------------------------------
# Funktionsname oder Beschreibung
#-----------------------------------------------
```

---

## 5. Namenskonventionen

### 5.1 Funktionen

| Typ | Prefix | Beispiele |
|-----|--------|-----------|
| Öffentliche API | `cmake_` | `cmake_fatal()`, `cmake_warn()` |
| Context-API | `ctx_` | `ctx_create()`, `ctx_set()` |
| JSON-Helper | `_json_` | `_json_get_string()` |
| Source-Helper | `_collect_` | `_collect_sources_from_cmake()` |
| Interne/Private | `_` | `_helper()`, `_validate()` |
| Validierung | `validate_` | `validate_external_source()` |
| Hook-Loader | `load_` | `load_prefetch_hook()` |
| Modul-spezifisch | `[modul]_` | `example_do_something()` |

### 5.2 Variablen

| Typ | Konvention | Beispiele |
|-----|------------|-----------|
| Lokale Variable | `_snake_case` | `_name`, `_ext_list`, `_result` |
| Modul-Konstante | `_UPPER_SNAKE` | `_EXAMPLE_DEFAULT_VALUE` |
| Output-Parameter | `OUT_VAR` | `function(foo OUT_VAR)` |
| Parsed Arguments | `ARG_*` | `ARG_TYPE`, `ARG_SHOW_DEBUG` |
| Globale Property | `UPPER_SNAKE_CASE` | `SOLUTION_JSON`, `SOLUTION_NAME` |
| Context-Key | `UPPER_SNAKE_CASE` | `ctx_set(EXE NAME "...")` |
| Cache-Variable | `UPPER_SNAKE_CASE` | `BUILD_TESTS`, `ENABLE_CLANG_TIDY` |

### 5.3 Dateien

```
[ModulName].cmake
```

| Regel | Richtig | Falsch |
|-------|---------|--------|
| PascalCase | `Context.cmake` | `context.cmake` |
| Keine Underscores | `CompilerOptions.cmake` | `Compiler_Options.cmake` |
| Aussagekräftig | `Validation.cmake` | `Val.cmake` |

---

## 6. Funktions-Dokumentation

### 6.1 Dokumentations-Block (öffentliche Funktionen)

Vor jeder öffentlichen Funktion:

```cmake
#[[
    function_name(REQUIRED_PARAM [OPTIONAL_PARAMS...])
    
    Kurze Beschreibung was die Funktion tut.
    Kann über mehrere Zeilen gehen.
    
    Parameter:
        REQUIRED_PARAM  - Beschreibung (Pflicht)
        OPTIONAL_PARAM  - Beschreibung (Optional, Default: X)
        FLAG            - Beschreibung (Flag, kein Wert)
    
    Rückgabe:
        OUT_VAR wird auf ... gesetzt
    
    Fehler:
        E001 - wenn REQUIRED_PARAM leer
        E002 - wenn OPTIONAL_PARAM ungültig
    
    Beispiel:
        function_name(MyTarget OPTIONAL_PARAM "value" FLAG)
]]
function(function_name REQUIRED_PARAM)
    # ...
endfunction()
```

### 6.2 Kurz-Dokumentation (private Funktionen)

```cmake
#-----------------------------------------------
# _helper_function(INPUT OUT_VAR)
# Kurze Beschreibung - nicht für externe Verwendung
#-----------------------------------------------
function(_helper_function INPUT OUT_VAR)
    # ...
endfunction()
```

### 6.3 Inline-Kommentare

```cmake
function(example NAME)
    # Argument-Parsing
    cmake_parse_arguments(ARG "FLAG" "VALUE" "LIST" ${ARGN})
    
    # Defaults setzen
    if(NOT DEFINED ARG_VALUE)
        set(ARG_VALUE "default")  # Standard wenn nicht angegeben
    endif()
    
    # Validierung: NAME darf nicht leer sein
    if("${NAME}" STREQUAL "")
        cmake_fatal("E001" "NAME ist Pflicht")
    endif()
    
    # Hauptlogik
    # TODO: Implementierung
endfunction()
```

---

## 7. Fehlerbehandlung

### 7.1 Fehler-Funktionen

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

### 7.2 Fehlercode-Bereiche

| Bereich | Codes | Beschreibung |
|---------|-------|--------------|
| JSON/Parsing | `E0xx` | Fehlende Pflichtfelder, ungültiges JSON |
| Target-Erstellung | `E1xx` | Target existiert, Abhängigkeit fehlt, Source.cmake |
| Externals | `E2xx` | Fetch fehlgeschlagen, Include.cmake fehlt |
| Deprecation | `W0xx` | Veraltete Features/Syntax |
| Konfiguration | `W1xx` | Suboptimale Einstellungen |
| Tools/Setup | `W2xx` | Fehlende Tools |

### 7.3 Neue Fehlercodes

Bei neuen Fehlercodes:
1. Passenden Bereich wählen
2. Nächste freie Nummer verwenden
3. In `ErrorCodes.md` dokumentieren
4. In Modul-Dokumentation aufnehmen

---

## 8. Debug-Ausgaben

### 8.1 Debug-System verwenden

```cmake
# Am Anfang des Moduls
set(_SHOW_MODULE_DEBUG OFF)  # Schnelles Ein/Ausschalten

dbg_init(
    ID MODULE_DBG 
    LEVEL ${DBG_SHOW_MUCH} 
    SWITCH ${_SHOW_MODULE_DEBUG} 
    TAG "MODULE"
)

# Im Code
dbg(${DBG_OFTEN} "=== Phase Start ===" ID MODULE_DBG)
dbg(${DBG_COMMON} "Processing ${_name}" ID MODULE_DBG)
dbg(${DBG_RARE} "Details: ${_details}" ID MODULE_DBG)

# Am Ende
enddbgblock(ID MODULE_DBG)
```

### 8.2 Debug-Level

| Level | Verwenden für |
|-------|---------------|
| `DBG_OFTEN` | Start/Ende von Phasen, wichtige Entscheidungen |
| `DBG_COMMON` | Gefundene Dateien, aktivierte Features |
| `DBG_NORMAL` | Zwischenschritte, normale Operationen |
| `DBG_RARE` | Detaillierte Werte, Pfade, Variablen |
| `DBG_ULTRA_RARE` | Interne Details, Loop-Iterationen |

---

## 9. Best Practices

### 9.1 Do's ✅

```cmake
# ✅ include_guard verwenden
include_guard(GLOBAL)

# ✅ Aussagekräftige Variablennamen
set(_source_directory "${CMAKE_CURRENT_SOURCE_DIR}/src")

# ✅ Defaults explizit setzen
if(NOT DEFINED ARG_TYPE)
    set(ARG_TYPE "CONSOLE")
endif()

# ✅ Früh validieren
if("${_name}" STREQUAL "")
    cmake_fatal("E001" "Name ist Pflicht")
endif()

# ✅ PARENT_SCOPE für Output-Parameter
function(get_value OUT_VAR)
    set(${OUT_VAR} "result" PARENT_SCOPE)
endfunction()

# ✅ GLOBAL PROPERTY für scope-übergreifende Daten
set_property(GLOBAL PROPERTY MY_DATA "${_value}")
get_property(_value GLOBAL PROPERTY MY_DATA)
```

### 9.2 Don'ts ❌

```cmake
# ❌ Globale Variablen ohne Namespace
set(MY_VAR "value")  # Verschmutzt globalen Namespace

# ❌ Magische Strings/Zahlen
if("${_type}" STREQUAL "1")  # Was bedeutet "1"?

# ❌ Fehlende Validierung
function(process NAME)
    add_executable(${NAME} ...)  # Keine Prüfung!
endfunction()

# ❌ Hartcodierte Pfade
set(_path "/home/user/project/src")

# ❌ Mehrere Verantwortlichkeiten
function(do_everything)  # Zu viel in einer Funktion
    # ... 200 Zeilen ...
endfunction()

# ❌ Fehlende Dokumentation
function(xyz A B C)  # Was macht das?
endfunction()
```

---

## 10. Spezielle Module

### 10.1 Hook-Dateien

```cmake
# cmake/externals/Hooks/PostFetch/imgui.cmake
# ============================================
# PostFetch Hook für ImGui
#
# Version: 0.1.0
# Datum:   2025-12-03
# Status:  In Entwicklung
# Typ:     PostFetch Hook
# External: imgui
#
# Abhängigkeiten: Keine (standalone)

include_guard(GLOBAL)  # Wichtig für shared Hooks!

message(STATUS "[ImGui PostFetch] Creating target...")

FetchContent_GetProperties(imgui)
if(imgui_POPULATED)
    if(NOT TARGET imgui)
        add_library(imgui STATIC
            ${imgui_SOURCE_DIR}/imgui.cpp
            ${imgui_SOURCE_DIR}/imgui_draw.cpp
            # ...
        )
    endif()
else()
    cmake_fatal("E201" "imgui: FetchContent fehlgeschlagen")
endif()
```

### 10.2 Include.cmake für lokale Externals

```cmake
# externals/bass/Include.cmake
# ============================
# Setup für BASS Audio Library
#
# Version: 0.1.0
# Datum:   2025-12-03
# Status:  In Entwicklung
# Typ:     Local External Include
#
# Erwartet:
#   EXTERNAL_ROOT      - Pfad zum External-Verzeichnis
#   EXTERNAL_OPTIONS   - JSON-String mit Options (optional)
#
# Erstellt Target: bass
#
# Abhängigkeiten: Keine

include_guard(GLOBAL)

# Pfade
set(_bass_root "${EXTERNAL_ROOT}")
set(_bass_include "${_bass_root}/include")
set(_bass_lib "${_bass_root}/lib")

# Target erstellen
add_library(bass SHARED IMPORTED GLOBAL)

# Platform-spezifisch
if(WIN32)
    set_target_properties(bass PROPERTIES
        IMPORTED_LOCATION "${_bass_lib}/bass.dll"
        IMPORTED_IMPLIB "${_bass_lib}/bass.lib"
    )
elseif(APPLE)
    set_target_properties(bass PROPERTIES
        IMPORTED_LOCATION "${_bass_lib}/libbass.dylib"
    )
else()
    set_target_properties(bass PROPERTIES
        IMPORTED_LOCATION "${_bass_lib}/libbass.so"
    )
endif()

target_include_directories(bass INTERFACE "${_bass_include}")
```

---

## 11. Review-Checkliste

Vor Commit eines CMake-Moduls prüfen:

- [ ] Header vollständig (Pfad, Beschreibung, Version, Datum, Status, Abhängigkeiten)
- [ ] Trennlinie korrekte Länge
- [ ] `include_guard(GLOBAL)` vorhanden
- [ ] Öffentliche Funktionen mit `#[[ ]]` dokumentiert
- [ ] Private Funktionen mit `_` Prefix
- [ ] Variablen mit `_` Prefix (lokal) oder `_UPPER` (Konstanten)
- [ ] Fehlerbehandlung mit korrekten Error Codes
- [ ] Debug-Ausgaben mit dbg() System (wenn sinnvoll)
- [ ] Keine hardcodierten Pfade
- [ ] Keine magischen Strings/Zahlen
- [ ] Version erhöht bei Änderungen
- [ ] Entsprechende Dokumentation aktualisiert/erstellt

---

## 12. Siehe auch

- [Documentation_Blueprint](Documentation_Blueprint_v0_1_0.md) – Struktur für Dokumentationen
- [guidelines](guidelines_v0_1_0.md) – CMake Coding-Konventionen
- [ErrorCodes](ErrorCodes_v0_1_0.md) – Alle Fehlercodes

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-03** | **Initial: Header-Struktur, Datei-Struktur, Namenskonventionen, Funktions-Dokumentation, Best Practices, Pre-Release Start** |
