# App-Container Architektur-Konzept

**Version:** 0.2.0  
**Datum:** 2025-12-12  
**Status:** ENTWURF  
**Autor:** CMake Architecture V2 Team

---

## 1. Übersicht

### 1.1 Motivation

Das aktuelle Build-System unterstützt Executables als monolithische Einheiten. Das führt zu Problemen bei der Testbarkeit:

| Problem | Beschreibung |
|---------|--------------|
| **Nicht testbar** | Business-Logik ist mit `main()` vermischt |
| **Code-Duplizierung** | Um Module zu testen, müssen Sources manuell kopiert werden |
| **Zirkuläre Dependencies** | Test-Targets können nicht einfach gegen Executable-Code linken |

### 1.2 Lösung: App-Container

Ein **App-Container** trennt die Anwendungslogik von der Einstiegspunkt-Logik:

```
┌─────────────────────────────────────────────────────────────┐
│                      App-Container                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              AppName.Core (STATIC Library)           │   │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐             │   │
│  │  │ Module A│  │ Module B│  │ Module C│   ...       │   │
│  │  └─────────┘  └─────────┘  └─────────┘             │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│            ┌──────────────┼──────────────┐                 │
│            ▼              ▼              ▼                 │
│     ┌───────────┐  ┌────────────┐  ┌────────────┐         │
│     │   main/   │  │ Unit Tests │  │ Int. Tests │         │
│     │ (Runner)  │  │            │  │            │         │
│     └───────────┘  └────────────┘  └────────────┘         │
│            │                                                │
│            ▼                                                │
│     ┌───────────┐                                          │
│     │ AppName   │                                          │
│     │(Executable)│                                          │
│     └───────────┘                                          │
└─────────────────────────────────────────────────────────────┘
```

### 1.3 Kompatibilität

| Modus | Beschreibung | Testbarkeit |
|-------|--------------|-------------|
| **Legacy** | Monolithisches Executable (`executables[]`) | Nur über `source_from` |
| **App-Container** | Getrennte Core-Library + Runner (`apps[]`) | Volle Testbarkeit |

**Legacy bleibt vollständig unterstützt** - bestehende Projekte funktionieren weiterhin ohne Änderung.

### 1.4 Designprinzipien

| Prinzip | Umsetzung |
|---------|-----------|
| **Single Source of Truth** | Alles in `Solution.json`, keine separate `app.json` |
| **Convention over Configuration** | Feste Verzeichnisstruktur, minimale Konfiguration |
| **Zentrale Externals** | Externals nur in `externals{}` Block, nie in Apps |
| **Konsistenz** | Gleiche Patterns wie Legacy (Source.cmake, PCH, etc.) |

---

## 2. Verzeichnisstruktur

### 2.1 App-Container Layout

```
projects/apps/{AppName}/
├── include/                      # PUBLIC Headers (Core Library)
│   └── {AppName}/
│       ├── Application.hpp
│       ├── ModuleA.hpp
│       └── ModuleB.hpp
├── src/                          # Implementation (Core Library)
│   └── {AppName}/
│       ├── Application.cpp
│       ├── ModuleA.cpp
│       └── ModuleB.cpp
├── main/                         # Entry Point (Runner Executable)
│   └── main.cpp
├── pch/                          # Precompiled Header (optional)
│   ├── pch.hpp
│   └── pch.cpp
└── tests/                        # App-spezifische Tests
    ├── unit/
    │   ├── test_ModuleA.cpp
    │   └── test_ModuleB.cpp
    └── integration/
        └── test_Application.cpp
```

### 2.2 Symmetrie include/ ↔ src/

Die Verzeichnisstruktur unter `include/` und `src/` ist symmetrisch:

```
include/AudioPlayer/Application.hpp
    ↕
src/AudioPlayer/Application.cpp
```

Dies ermöglicht:
- Klare Zuordnung Header ↔ Implementation
- Namespace-konsistente Includes: `#include <AudioPlayer/Application.hpp>`
- IDE-freundliche Navigation

### 2.3 Gesamtstruktur im Projekt

```
projects/
├── apps/                           # App-Container (NEU)
│   ├── AudioPlayer/
│   │   ├── include/
│   │   ├── src/
│   │   ├── main/
│   │   ├── pch/
│   │   └── tests/
│   └── ImageViewer/
│       └── ...
│
├── demos/                          # Legacy Struktur (unverändert)
│   ├── exec/
│   │   └── MinimalConsole/
│   └── libs/
│       └── BasicLogger/
│
└── tests/                          # Globale Tests (unverändert)
    ├── unit/
    ├── integration/
    └── system/
```

---

## 3. Solution.json Integration

### 3.1 Neue `apps` Sektion

```json
{
    "solution": {
        "name": "MySolution",
        "version": "1.0.0"
    },
    
    "settings": {
        "cppStandard": 20,
        "sources": { "mode": "auto" }
    },
    
    "externals": {
        "bass": { "path": "externals/bass" },
        "imgui_docking": { 
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.91.6-docking",
            "hook": "imgui"
        },
        "glfw": { "git": "https://github.com/glfw/glfw.git", "tag": "3.4" },
        "glad": { "path": "externals/glad" },
        "doctest": { "path": "externals/doctest" },
        "spdlog": { "git": "https://github.com/gabime/spdlog.git", "tag": "v1.13.0" }
    },
    
    "libraries": [
        {
            "name": "BasicLogger",
            "path": "projects/demos/libs/BasicLogger"
        }
    ],
    
    "apps": [
        {
            "name": "AudioPlayer",
            "displayName": "Audio Player Application",
            "version": "2.0.0",
            "description": "A testable audio player",
            
            "core": {
                "dependencies": ["BasicLogger"],
                "externals": ["bass", "spdlog"]
            },
            
            "runner": {
                "type": "WINDOW",
                "externals": ["imgui_docking", "glad", "glfw"]
            },
            
            "pch": {
                "enabled": true,
                "header": "pch/pch.hpp",
                "source": "pch/pch.cpp"
            },
            
            "tests": {
                "framework": "doctest",
                "unit": {
                    "timeout": 30,
                    "labels": ["unit", "audio"]
                },
                "integration": {
                    "timeout": 120,
                    "labels": ["integration", "audio"],
                    "externals": ["bass"]
                }
            },
            
            "platforms": ["windows", "linux", "macos"]
        }
    ],
    
    "executables": [
        {
            "name": "LegacyTool",
            "path": "projects/demos/exec/LegacyTool/src",
            "type": "CONSOLE"
        }
    ],
    
    "tests": [
        {
            "name": "GlobalUnitTests",
            "type": "unit",
            "framework": "doctest",
            "path": "projects/tests/unit/Global"
        }
    ]
}
```

### 3.2 App-Definition Schema

| Feld | Typ | Required | Default | Beschreibung |
|------|-----|----------|---------|--------------|
| `name` | string | ✅ | - | Eindeutiger App-Name |
| `displayName` | string | ❌ | `name` | Anzeigename |
| `version` | string | ❌ | `"1.0.0"` | App-Version |
| `description` | string | ❌ | `""` | Beschreibung |
| `path` | string | ❌ | `"projects/apps/{name}"` | Basis-Pfad |
| `core` | object | ❌ | `{}` | Core-Library Konfiguration |
| `runner` | object | ❌ | `{}` | Runner-Executable Konfiguration |
| `pch` | object | ❌ | `{ "enabled": false }` | PCH Konfiguration |
| `tests` | object | ❌ | `{}` | Test-Konfiguration |
| `platforms` | array | ❌ | alle | Zielplattformen |
| `active` | boolean | ❌ | `true` | App aktiv/inaktiv |

### 3.3 Core-Definition Schema

| Feld | Typ | Required | Default | Beschreibung |
|------|-----|----------|---------|--------------|
| `dependencies` | array | ❌ | `[]` | Interne Library-Dependencies |
| `externals` | array | ❌ | `[]` | Externe Dependencies |
| `defines` | array | ❌ | `[]` | Compile Definitions |

**Hinweis:** Core ist immer `STATIC`. Die Pfade `include/` und `src/` sind Convention.

### 3.4 Runner-Definition Schema

| Feld | Typ | Required | Default | Beschreibung |
|------|-----|----------|---------|--------------|
| `type` | string | ❌ | `"CONSOLE"` | `CONSOLE` oder `WINDOW` |
| `externals` | array | ❌ | `[]` | Runner-spezifische Externals |
| `defines` | array | ❌ | `[]` | Compile Definitions |

**Hinweis:** Runner linkt automatisch gegen `{AppName}.Core`. Pfad `main/` ist Convention.

### 3.5 Tests-Definition Schema

| Feld | Typ | Required | Default | Beschreibung |
|------|-----|----------|---------|--------------|
| `framework` | string | ❌ | `"doctest"` | Test-Framework |
| `unit` | object | ❌ | - | Unit-Test Konfiguration |
| `integration` | object | ❌ | - | Integration-Test Konfiguration |

**Unit/Integration Sub-Schema:**

| Feld | Typ | Required | Default | Beschreibung |
|------|-----|----------|---------|--------------|
| `timeout` | integer | ❌ | `30` | Timeout in Sekunden |
| `labels` | array | ❌ | `["{type}"]` | CTest Labels |
| `externals` | array | ❌ | `[]` | Zusätzliche Externals |
| `enabled` | boolean | ❌ | `true` | Tests aktiviert |

---

## 4. Source.cmake Integration

### 4.1 Platzierung

Source.cmake Dateien können optional auf Bereichs-Ebene platziert werden:

```
projects/apps/AudioPlayer/
├── include/
│   └── Source.cmake              # Optional: explizite Header-Liste
├── src/
│   └── Source.cmake              # Optional: explizite Source-Liste
├── main/
│   └── Source.cmake              # Optional: explizite Main-Sources
└── tests/
    ├── unit/
    │   └── Source.cmake          # Optional: explizite Unit-Test Sources
    └── integration/
        └── Source.cmake          # Optional: explizite Integration-Test Sources
```

### 4.2 Verhalten nach `sources.mode`

| Mode | Source.cmake vorhanden | Source.cmake fehlt |
|------|------------------------|-------------------|
| `explicit` | Verwendet | **FEHLER** |
| `glob` | Ignoriert | GLOB rekursiv |
| `auto` | Verwendet | GLOB rekursiv (Fallback) |

### 4.3 GLOB-Roots

| Bereich | GLOB-Root | Pattern | Rekursiv |
|---------|-----------|---------|----------|
| Core Headers | `include/` | `*.hpp, *.h` | ✅ |
| Core Sources | `src/` | `*.cpp, *.cxx, *.cc` | ✅ |
| Main Sources | `main/` | `*.cpp` | ✅ |
| PCH | `pch/` | `pch.hpp, pch.cpp` | ❌ |
| Unit Tests | `tests/unit/` | `*.cpp` | ✅ |
| Integration Tests | `tests/integration/` | `*.cpp` | ✅ |

### 4.4 Source.cmake Beispiel (Core)

```cmake
# projects/apps/AudioPlayer/src/Source.cmake

set(SOURCES
    AudioPlayer/Application.cpp
    AudioPlayer/ModuleA.cpp
    AudioPlayer/ModuleB.cpp
    AudioPlayer/Utils/Helper.cpp
)
```

---

## 5. Generierte CMake-Targets

### 5.1 Target-Übersicht

Aus einem App-Container `AudioPlayer` werden folgende Targets generiert:

| Target | Typ | Beschreibung |
|--------|-----|--------------|
| `AudioPlayer.Core` | STATIC Library | Business-Logik, testbar |
| `AudioPlayer` | Executable | Runner + Core verlinkt |
| `AudioPlayer.UnitTests` | Test Executable | Unit Tests (wenn konfiguriert) |
| `AudioPlayer.IntegrationTests` | Test Executable | Integration Tests (wenn konfiguriert) |

### 5.2 Dependency-Graph

```
AudioPlayer.UnitTests
    ├── AudioPlayer.Core
    │   ├── BasicLogger (internal)
    │   ├── bass (external)
    │   └── spdlog (external)
    └── doctest (test framework)

AudioPlayer.IntegrationTests
    ├── AudioPlayer.Core
    │   └── ... (same as above)
    ├── bass (additional external)
    └── doctest (test framework)

AudioPlayer (Executable)
    ├── AudioPlayer.Core
    │   └── ... (same as above)
    ├── imgui_docking (runner external)
    ├── glad (runner external)
    └── glfw (runner external)
```

### 5.3 Include-Pfade

| Target | Include Directories |
|--------|---------------------|
| `AudioPlayer.Core` | `include/` (PUBLIC), `src/` (PRIVATE) |
| `AudioPlayer` | Erbt von Core |
| `AudioPlayer.UnitTests` | Erbt von Core, + `tests/unit/` |
| `AudioPlayer.IntegrationTests` | Erbt von Core, + `tests/integration/` |

---

## 6. CMake-Module

### 6.1 Neue Module

```
cmake/
├── project/
│   ├── Apps.cmake              # Apps Pipeline Entry Point
│   ├── AppCollect.cmake        # App Discovery & Parsing
│   └── AppCreate.cmake         # App-Container Target Creation
```

### 6.2 Verarbeitungsreihenfolge in CMakeLists.txt

```cmake
# Phase 1-2: Core & Solution (unverändert)
include(cmake/core/Errors.cmake)
include(cmake/project/Solution.cmake)

# Phase 3: Externals (unverändert)
include(cmake/project/Externals.cmake)

# Phase 4: Libraries (unverändert)
include(cmake/project/Libraries.cmake)

# Phase 5: App-Containers (NEU)
if(DEFINED SOLUTION_APPS AND SOLUTION_APPS)
    include(cmake/project/Apps.cmake)
endif()

# Phase 6: Legacy Executables (unverändert)
include(cmake/project/Executables.cmake)

# Phase 7: Global Tests (unverändert)
if(BUILD_TESTS)
    include(cmake/project/Tests.cmake)
endif()
```

### 6.3 Apps.cmake (Entry Point)

```cmake
# ==============================================================================
# Apps.cmake – App-Container Pipeline
# ==============================================================================
#
# Module:       Apps.cmake
# Version:      0.1.0
# Part of:      CMake Architecture V2
#
# Description:
#   Entry point for App-Container processing. Discovers and creates
#   App-Containers defined in Solution.json "apps" array.
#
# Generated Targets per App:
#   - {AppName}.Core          : STATIC library with business logic
#   - {AppName}               : Executable (runner)
#   - {AppName}.UnitTests     : Unit tests (if configured)
#   - {AppName}.IntegrationTests : Integration tests (if configured)
#
# ==============================================================================

include_guard(GLOBAL)

message(STATUS "")
message(STATUS "[Apps] === App-Container Pipeline Start ===")

include(${CMAKE_CURRENT_LIST_DIR}/AppCollect.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/AppCreate.cmake)

# ------------------------------------------------------------------------------
# Collect Apps from Solution.json
# ------------------------------------------------------------------------------

_collect_apps()

get_property(_apps GLOBAL PROPERTY SOLUTION_APPS_LIST)
list(LENGTH _apps _app_count)

message(STATUS "[Apps] Processing ${_app_count} app(s)...")

# ------------------------------------------------------------------------------
# Process each App-Container
# ------------------------------------------------------------------------------

foreach(_app_json IN LISTS _apps)
    _create_app_container("${_app_json}")
endforeach()

message(STATUS "")
message(STATUS "[Apps] === App-Container Pipeline Complete ===")
```

### 6.4 AppCollect.cmake

```cmake
# ==============================================================================
# AppCollect.cmake – App-Container Discovery
# ==============================================================================
#
# Module:       AppCollect.cmake
# Version:      0.1.0
# Part of:      CMake Architecture V2
#
# Provides:
#   _collect_apps()
#   _parse_app_definition(APP_JSON ...)
#
# ==============================================================================

include_guard(GLOBAL)

# ==============================================================================
# _collect_apps - Discover apps from Solution.json
# ==============================================================================
function(_collect_apps)
    get_property(_solution_json GLOBAL PROPERTY SOLUTION_JSON)
    
    # Check if apps array exists
    _json_has_key("${_solution_json}" "apps" _has_apps)
    if(NOT _has_apps)
        dbg(${DBG_COMMON} "[Apps] No apps defined in Solution.json" ID APPS)
        return()
    endif()
    
    # Get apps array
    _json_get_array("${_solution_json}" "apps" _apps_array)
    _json_array_length("${_apps_array}" _count)
    
    # Store each app definition
    set(_app_list "")
    math(EXPR _last "${_count} - 1")
    
    foreach(_idx RANGE 0 ${_last})
        _json_get_array_element("${_apps_array}" ${_idx} _app_json)
        
        # Validate required fields
        _json_get_string("${_app_json}" "name" _name)
        if("${_name}" STREQUAL "")
            cmake_fatal("E401" "App at index ${_idx}: 'name' is required")
        endif()
        
        # Check if active (default: true)
        _json_get_bool_or_default("${_app_json}" "active" TRUE _active)
        if(NOT _active)
            dbg(${DBG_COMMON} "[Apps] Skipping inactive: ${_name}" ID APPS)
            continue()
        endif()
        
        # Check platform filter
        _check_platform_filter("${_app_json}" _platform_ok)
        if(NOT _platform_ok)
            dbg(${DBG_COMMON} "[Apps] Skipping (platform): ${_name}" ID APPS)
            continue()
        endif()
        
        # Store app JSON for later processing
        set_property(GLOBAL PROPERTY APP_${_name}_JSON "${_app_json}")
        list(APPEND _app_list "${_app_json}")
        
        message(STATUS "[Apps] --- Found: ${_name} ---")
    endforeach()
    
    set_property(GLOBAL PROPERTY SOLUTION_APPS_LIST "${_app_list}")
    
endfunction()

# ==============================================================================
# _get_app_path - Get base path for an app
# ==============================================================================
function(_get_app_path APP_JSON OUT_VAR)
    _json_get_string("${APP_JSON}" "name" _name)
    _json_get_string_or_default("${APP_JSON}" "path" "projects/apps/${_name}" _path)
    
    set(${OUT_VAR} "${CMAKE_SOURCE_DIR}/${_path}" PARENT_SCOPE)
endfunction()
```

### 6.5 AppCreate.cmake

```cmake
# ==============================================================================
# AppCreate.cmake – App-Container Target Creation
# ==============================================================================
#
# Module:       AppCreate.cmake
# Version:      0.1.0
# Part of:      CMake Architecture V2
#
# Provides:
#   _create_app_container(APP_JSON)
#   _create_app_core(APP_NAME APP_PATH APP_JSON)
#   _create_app_runner(APP_NAME APP_PATH APP_JSON CORE_TARGET)
#   _create_app_tests(APP_NAME APP_PATH APP_JSON CORE_TARGET)
#
# ==============================================================================

include_guard(GLOBAL)

# ==============================================================================
# _create_app_container - Main entry point for app creation
# ==============================================================================
function(_create_app_container APP_JSON)
    # --------------------------------------------------------------------------
    # Parse basic info
    # --------------------------------------------------------------------------
    
    _json_get_string("${APP_JSON}" "name" _name)
    _get_app_path("${APP_JSON}" _app_path)
    
    if(NOT EXISTS "${_app_path}")
        cmake_fatal("E402" "App '${_name}': Path does not exist: ${_app_path}")
    endif()
    
    message(STATUS "[Apps] --- Processing: ${_name} ---")
    
    # --------------------------------------------------------------------------
    # Step 1: Create Core Library
    # --------------------------------------------------------------------------
    
    _create_app_core("${_name}" "${_app_path}" "${APP_JSON}")
    set(_core_target "${_name}.Core")
    
    # --------------------------------------------------------------------------
    # Step 2: Create Runner Executable
    # --------------------------------------------------------------------------
    
    _create_app_runner("${_name}" "${_app_path}" "${APP_JSON}" "${_core_target}")
    
    # --------------------------------------------------------------------------
    # Step 3: Create Tests (if BUILD_TESTS)
    # --------------------------------------------------------------------------
    
    if(BUILD_TESTS)
        _create_app_tests("${_name}" "${_app_path}" "${APP_JSON}" "${_core_target}")
    endif()
    
endfunction()

# ==============================================================================
# _create_app_core - Create the Core STATIC library
# ==============================================================================
function(_create_app_core APP_NAME APP_PATH APP_JSON)
    set(_core_target "${APP_NAME}.Core")
    
    set(_include_dir "${APP_PATH}/include")
    set(_src_dir "${APP_PATH}/src")
    
    # --------------------------------------------------------------------------
    # Collect Sources
    # --------------------------------------------------------------------------
    
    # Headers from include/
    if(EXISTS "${_include_dir}")
        collect_sources(
            SOURCE_DIR "${_include_dir}"
            SOURCES_OUT _dummy
            HEADERS_OUT _headers
        )
    else()
        cmake_warn("W401" "App '${APP_NAME}': No include/ directory")
        set(_headers "")
    endif()
    
    # Sources from src/
    if(EXISTS "${_src_dir}")
        collect_sources(
            SOURCE_DIR "${_src_dir}"
            SOURCES_OUT _sources
            HEADERS_OUT _private_headers
        )
        list(APPEND _headers ${_private_headers})
    else()
        cmake_fatal("E403" "App '${APP_NAME}': No src/ directory")
    endif()
    
    if(NOT _sources)
        cmake_fatal("E404" "App '${APP_NAME}': No source files found in src/")
    endif()
    
    # --------------------------------------------------------------------------
    # Create Library
    # --------------------------------------------------------------------------
    
    add_library(${_core_target} STATIC ${_sources} ${_headers})
    
    # Include directories
    if(EXISTS "${_include_dir}")
        target_include_directories(${_core_target} PUBLIC "${_include_dir}")
    endif()
    target_include_directories(${_core_target} PRIVATE "${_src_dir}")
    
    # --------------------------------------------------------------------------
    # PCH (if configured)
    # --------------------------------------------------------------------------
    
    _json_get_object_or_default("${APP_JSON}" "pch" "{}" _pch_json)
    _json_get_bool_or_default("${_pch_json}" "enabled" FALSE _pch_enabled)
    
    if(_pch_enabled)
        _json_get_string_or_default("${_pch_json}" "header" "pch/pch.hpp" _pch_header)
        set(_pch_path "${APP_PATH}/${_pch_header}")
        
        if(EXISTS "${_pch_path}")
            target_precompile_headers(${_core_target} PRIVATE "${_pch_path}")
            dbg(${DBG_COMMON} "  PCH: ${_pch_header}" ID APPS)
        else()
            cmake_warn("W402" "App '${APP_NAME}': PCH enabled but ${_pch_header} not found")
        endif()
    endif()
    
    # --------------------------------------------------------------------------
    # Dependencies (internal libraries)
    # --------------------------------------------------------------------------
    
    _json_get_object_or_default("${APP_JSON}" "core" "{}" _core_json)
    _json_get_array_or_default("${_core_json}" "dependencies" "[]" _deps)
    _json_array_to_list("${_deps}" _dep_list)
    
    foreach(_dep IN LISTS _dep_list)
        if(TARGET ${_dep})
            target_link_libraries(${_core_target} PUBLIC ${_dep})
            dbg(${DBG_RARE} "    Dependency: ${_dep}" ID APPS)
        else()
            cmake_fatal("E405" "App '${APP_NAME}': Dependency '${_dep}' not found")
        endif()
    endforeach()
    
    # --------------------------------------------------------------------------
    # Externals
    # --------------------------------------------------------------------------
    
    _json_get_array_or_default("${_core_json}" "externals" "[]" _exts)
    _json_array_to_list("${_exts}" _ext_list)
    
    foreach(_ext IN LISTS _ext_list)
        apply_external_to_target("${_core_target}" "${_ext}" "{}")
        dbg(${DBG_RARE} "    External: ${_ext}" ID APPS)
    endforeach()
    
    # --------------------------------------------------------------------------
    # Compile Definitions
    # --------------------------------------------------------------------------
    
    _json_get_array_or_default("${_core_json}" "defines" "[]" _defines)
    _json_array_to_list("${_defines}" _def_list)
    
    if(_def_list)
        target_compile_definitions(${_core_target} PRIVATE ${_def_list})
    endif()
    
    message(STATUS "[Apps]   Created: ${_core_target} (STATIC)")
    
endfunction()

# ==============================================================================
# _create_app_runner - Create the Runner executable
# ==============================================================================
function(_create_app_runner APP_NAME APP_PATH APP_JSON CORE_TARGET)
    set(_main_dir "${APP_PATH}/main")
    
    if(NOT EXISTS "${_main_dir}")
        cmake_fatal("E406" "App '${APP_NAME}': No main/ directory")
    endif()
    
    # --------------------------------------------------------------------------
    # Collect Sources
    # --------------------------------------------------------------------------
    
    collect_sources(
        SOURCE_DIR "${_main_dir}"
        SOURCES_OUT _sources
        HEADERS_OUT _headers
    )
    
    if(NOT _sources)
        cmake_fatal("E407" "App '${APP_NAME}': No source files in main/")
    endif()
    
    # --------------------------------------------------------------------------
    # Create Executable
    # --------------------------------------------------------------------------
    
    add_executable(${APP_NAME} ${_sources} ${_headers})
    
    # Link against Core
    target_link_libraries(${APP_NAME} PRIVATE ${CORE_TARGET})
    
    # Include main directory for local headers
    target_include_directories(${APP_NAME} PRIVATE "${_main_dir}")
    
    # --------------------------------------------------------------------------
    # Executable Type (CONSOLE/WINDOW)
    # --------------------------------------------------------------------------
    
    _json_get_object_or_default("${APP_JSON}" "runner" "{}" _runner_json)
    _json_get_string_or_default("${_runner_json}" "type" "CONSOLE" _type)
    
    if("${_type}" STREQUAL "WINDOW")
        set_target_properties(${APP_NAME} PROPERTIES WIN32_EXECUTABLE TRUE)
        if(APPLE)
            set_target_properties(${APP_NAME} PROPERTIES MACOSX_BUNDLE TRUE)
        endif()
    endif()
    
    # --------------------------------------------------------------------------
    # Runner-specific Externals
    # --------------------------------------------------------------------------
    
    _json_get_array_or_default("${_runner_json}" "externals" "[]" _exts)
    _json_array_to_list("${_exts}" _ext_list)
    
    foreach(_ext IN LISTS _ext_list)
        apply_external_to_target("${APP_NAME}" "${_ext}" "{}")
        dbg(${DBG_RARE} "    Runner External: ${_ext}" ID APPS)
    endforeach()
    
    # --------------------------------------------------------------------------
    # Compile Definitions
    # --------------------------------------------------------------------------
    
    _json_get_array_or_default("${_runner_json}" "defines" "[]" _defines)
    _json_array_to_list("${_defines}" _def_list)
    
    if(_def_list)
        target_compile_definitions(${APP_NAME} PRIVATE ${_def_list})
    endif()
    
    # --------------------------------------------------------------------------
    # Output Directory
    # --------------------------------------------------------------------------
    
    set_target_properties(${APP_NAME} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/apps/${APP_NAME}/bin/$<CONFIG>"
    )
    
    message(STATUS "[Apps]   Created: ${APP_NAME} (Runner, ${_type})")
    
endfunction()

# ==============================================================================
# _create_app_tests - Create app-specific tests
# ==============================================================================
function(_create_app_tests APP_NAME APP_PATH APP_JSON CORE_TARGET)
    set(_tests_dir "${APP_PATH}/tests")
    
    if(NOT EXISTS "${_tests_dir}")
        dbg(${DBG_COMMON} "[Apps] No tests/ directory for ${APP_NAME}" ID APPS)
        return()
    endif()
    
    _json_get_object_or_default("${APP_JSON}" "tests" "{}" _tests_json)
    _json_get_string_or_default("${_tests_json}" "framework" "doctest" _framework)
    
    # --------------------------------------------------------------------------
    # Unit Tests
    # --------------------------------------------------------------------------
    
    _json_has_key("${_tests_json}" "unit" _has_unit)
    if(_has_unit)
        _json_get_object("${_tests_json}" "unit" _unit_json)
        _json_get_bool_or_default("${_unit_json}" "enabled" TRUE _enabled)
        
        if(_enabled AND EXISTS "${_tests_dir}/unit")
            _create_app_test_target(
                "${APP_NAME}"
                "${_tests_dir}/unit"
                "UnitTests"
                "${_unit_json}"
                "${_framework}"
                "${CORE_TARGET}"
            )
        endif()
    elseif(EXISTS "${_tests_dir}/unit")
        # Auto-create with defaults
        _create_app_test_target(
            "${APP_NAME}"
            "${_tests_dir}/unit"
            "UnitTests"
            "{}"
            "${_framework}"
            "${CORE_TARGET}"
        )
    endif()
    
    # --------------------------------------------------------------------------
    # Integration Tests
    # --------------------------------------------------------------------------
    
    _json_has_key("${_tests_json}" "integration" _has_int)
    if(_has_int)
        _json_get_object("${_tests_json}" "integration" _int_json)
        _json_get_bool_or_default("${_int_json}" "enabled" TRUE _enabled)
        
        if(_enabled AND EXISTS "${_tests_dir}/integration")
            _create_app_test_target(
                "${APP_NAME}"
                "${_tests_dir}/integration"
                "IntegrationTests"
                "${_int_json}"
                "${_framework}"
                "${CORE_TARGET}"
            )
        endif()
    elseif(EXISTS "${_tests_dir}/integration")
        # Auto-create with defaults
        _create_app_test_target(
            "${APP_NAME}"
            "${_tests_dir}/integration"
            "IntegrationTests"
            "{}"
            "${_framework}"
            "${CORE_TARGET}"
        )
    endif()
    
endfunction()

# ==============================================================================
# _create_app_test_target - Create a single test target
# ==============================================================================
function(_create_app_test_target APP_NAME TEST_DIR TEST_SUFFIX TEST_JSON FRAMEWORK CORE_TARGET)
    set(_test_target "${APP_NAME}.${TEST_SUFFIX}")
    
    # --------------------------------------------------------------------------
    # Collect Sources
    # --------------------------------------------------------------------------
    
    collect_sources(
        SOURCE_DIR "${TEST_DIR}"
        SOURCES_OUT _sources
        HEADERS_OUT _headers
    )
    
    if(NOT _sources)
        dbg(${DBG_COMMON} "[Apps] No sources in ${TEST_DIR}" ID APPS)
        return()
    endif()
    
    # --------------------------------------------------------------------------
    # Create Test Executable
    # --------------------------------------------------------------------------
    
    add_executable(${_test_target} ${_sources} ${_headers})
    
    # Link against Core
    target_link_libraries(${_test_target} PRIVATE ${CORE_TARGET})
    
    # Include test directory
    target_include_directories(${_test_target} PRIVATE "${TEST_DIR}")
    
    # --------------------------------------------------------------------------
    # Link Test Framework
    # --------------------------------------------------------------------------
    
    apply_external_to_target("${_test_target}" "${FRAMEWORK}" "{}")
    
    # --------------------------------------------------------------------------
    # Additional Externals
    # --------------------------------------------------------------------------
    
    _json_get_array_or_default("${TEST_JSON}" "externals" "[]" _exts)
    _json_array_to_list("${_exts}" _ext_list)
    
    foreach(_ext IN LISTS _ext_list)
        apply_external_to_target("${_test_target}" "${_ext}" "{}")
    endforeach()
    
    # --------------------------------------------------------------------------
    # CTest Registration
    # --------------------------------------------------------------------------
    
    add_test(NAME ${_test_target} COMMAND ${_test_target})
    
    # Timeout
    _json_get_number_or_default("${TEST_JSON}" "timeout" 30 _timeout)
    set_tests_properties(${_test_target} PROPERTIES TIMEOUT ${_timeout})
    
    # Labels
    _json_get_array_or_default("${TEST_JSON}" "labels" "[]" _labels)
    _json_array_to_list("${_labels}" _label_list)
    
    # Add app name as label
    list(APPEND _label_list "${APP_NAME}")
    
    if(_label_list)
        set_tests_properties(${_test_target} PROPERTIES LABELS "${_label_list}")
    endif()
    
    # --------------------------------------------------------------------------
    # Output Directory
    # --------------------------------------------------------------------------
    
    set_target_properties(${_test_target} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/apps/${APP_NAME}/tests/$<CONFIG>"
    )
    
    message(STATUS "[Apps]   Created: ${_test_target}")
    
endfunction()
```

---

## 7. Error Codes

### 7.1 App-Container Errors (E4xx)

| Code | Beschreibung |
|------|--------------|
| E401 | App definition: 'name' is required |
| E402 | App path does not exist |
| E403 | App has no src/ directory |
| E404 | App has no source files in src/ |
| E405 | App dependency not found |
| E406 | App has no main/ directory |
| E407 | App has no source files in main/ |

### 7.2 App-Container Warnings (W4xx)

| Code | Beschreibung |
|------|--------------|
| W401 | App has no include/ directory |
| W402 | PCH enabled but header not found |
| W403 | Tests directory exists but no sources found |

---

## 8. Build-Ausgabe Struktur

```
out/build/{preset}/
├── apps/
│   └── AudioPlayer/
│       ├── bin/
│       │   └── Debug/
│       │       └── AudioPlayer.exe
│       ├── lib/
│       │   └── Debug/
│       │       └── AudioPlayer.Core.lib
│       └── tests/
│           └── Debug/
│               ├── AudioPlayer.UnitTests.exe
│               └── AudioPlayer.IntegrationTests.exe
├── exec/                          # Legacy executables
│   └── LegacyTool/
│       └── bin/Debug/
└── lib/                           # Global libraries
```

---

## 9. Beispiel: Vollständiger App-Container

### 9.1 Solution.json Ausschnitt

```json
{
    "apps": [
        {
            "name": "AudioPlayer",
            "displayName": "Audio Player",
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
                "unit": {
                    "timeout": 30,
                    "labels": ["unit", "audio", "fast"]
                },
                "integration": {
                    "timeout": 120,
                    "labels": ["integration", "audio"],
                    "externals": ["bass"]
                }
            }
        }
    ]
}
```

### 9.2 Verzeichnisstruktur

```
projects/apps/AudioPlayer/
├── include/
│   └── AudioPlayer/
│       ├── Application.hpp
│       ├── AudioEngine.hpp
│       ├── Playlist.hpp
│       └── Track.hpp
├── src/
│   └── AudioPlayer/
│       ├── Application.cpp
│       ├── AudioEngine.cpp
│       ├── Playlist.cpp
│       └── Track.cpp
├── main/
│   └── main.cpp
├── pch/
│   ├── pch.hpp
│   └── pch.cpp
└── tests/
    ├── unit/
    │   ├── test_AudioEngine.cpp
    │   ├── test_Playlist.cpp
    │   └── test_Track.cpp
    └── integration/
        └── test_Application.cpp
```

### 9.3 main/main.cpp (Minimal)

```cpp
// Entry point only - all logic in AudioPlayer.Core

#include <AudioPlayer/Application.hpp>

int main(int argc, char* argv[]) {
    AudioPlayer::Application app;
    
    if (!app.initialize(argc, argv)) {
        return 1;
    }
    
    return app.run();
}
```

### 9.4 Generierte Targets

```
AudioPlayer.Core            - STATIC Library
AudioPlayer                 - WINDOW Executable
AudioPlayer.UnitTests       - Test Executable
AudioPlayer.IntegrationTests - Test Executable
```

### 9.5 CTest Ausführung

```bash
# Alle App-Tests
ctest -L AudioPlayer

# Nur Unit Tests
ctest -L "AudioPlayer" -L "unit"

# Nur Integration Tests  
ctest -R "IntegrationTests"
```

---

## 10. Migration: Legacy → App-Container

### 10.1 Schritt-für-Schritt

1. **Verzeichnis erstellen:**
   ```bash
   mkdir -p projects/apps/MyApp/{include/MyApp,src/MyApp,main,tests/unit}
   ```

2. **Code aufteilen:**
   - Business-Logik → `src/MyApp/`
   - Public Headers → `include/MyApp/`
   - `main()` → `main/main.cpp`

3. **Solution.json aktualisieren:**
   - App zu `apps[]` hinzufügen
   - Altes Executable aus `executables[]` entfernen

4. **Tests erstellen:**
   - Unit Tests in `tests/unit/`
   - Integration Tests in `tests/integration/`

### 10.2 Koexistenz

Legacy und App-Container können parallel existieren:

```json
{
    "apps": [
        { "name": "NewApp", ... }
    ],
    "executables": [
        { "name": "LegacyTool", ... }
    ]
}
```

---

## 11. Implementierungsplan

| Phase | Beschreibung | Abhängigkeiten |
|-------|--------------|----------------|
| 8.1 | `AppCollect.cmake` - Discovery & Parsing | Solution.cmake |
| 8.2 | `AppCreate.cmake` - Core Library | SourceCollect, Externals |
| 8.3 | `AppCreate.cmake` - Runner Executable | Core Library |
| 8.4 | `AppCreate.cmake` - App Tests | TestCreate patterns |
| 8.5 | Solution.json Schema Update | - |
| 8.6 | Build-System Tests | Alle Module |
| 8.7 | Dokumentation | Alle Module |

**Geschätzter Aufwand:** ~12-15 Stunden

---

## 12. Offene Entscheidungen

| Frage | Optionen | Empfehlung |
|-------|----------|------------|
| System-Tests in Apps? | Eigener Ordner `tests/system/` | Später bei Bedarf |
| Performance-Tests? | Eigener Ordner `tests/performance/` | Später bei Bedarf |
| Mehrere Runner? | `runners/gui/`, `runners/cli/` | V2 Feature |
| Shared Core Library? | `core.type: "SHARED"` | Nicht in V1 |
