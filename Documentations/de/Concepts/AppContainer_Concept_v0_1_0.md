# App-Container Architektur-Konzept

**Version:** 0.1.0  
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
│  │                    AppCore (Library)                 │   │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐             │   │
│  │  │ Module A│  │ Module B│  │ Module C│   ...       │   │
│  │  └─────────┘  └─────────┘  └─────────┘             │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│            ┌──────────────┼──────────────┐                 │
│            ▼              ▼              ▼                 │
│     ┌───────────┐  ┌───────────┐  ┌───────────┐           │
│     │ main.cpp  │  │ Unit Tests│  │ Int. Tests│           │
│     │ (Runner)  │  │           │  │           │           │
│     └───────────┘  └───────────┘  └───────────┘           │
│            │                                                │
│            ▼                                                │
│     ┌───────────┐                                          │
│     │ Executable│                                          │
│     └───────────┘                                          │
└─────────────────────────────────────────────────────────────┘
```

### 1.3 Kompatibilität

| Modus | Beschreibung | Testbarkeit |
|-------|--------------|-------------|
| **Legacy** | Monolithisches Executable (aktuell) | Nur über `source_from` |
| **App-Container** | Getrennte Core-Library + Runner | Volle Testbarkeit |

**Legacy bleibt vollständig unterstützt** - bestehende Projekte funktionieren weiterhin.

---

## 2. Struktur

### 2.1 Verzeichnisstruktur

```
projects/
├── apps/                           # App-Container
│   └── MyApp/
│       ├── app.json                # App-Container Konfiguration
│       ├── core/                   # AppCore Library
│       │   ├── include/
│       │   │   └── MyApp/
│       │   │       ├── Application.hpp
│       │   │       ├── ModuleA.hpp
│       │   │       └── ModuleB.hpp
│       │   └── src/
│       │       ├── Application.cpp
│       │       ├── ModuleA.cpp
│       │       └── ModuleB.cpp
│       ├── runner/                 # Executable Entry Point
│       │   └── main.cpp
│       └── tests/                  # App-spezifische Tests
│           ├── unit/
│           │   ├── test_ModuleA.cpp
│           │   └── test_ModuleB.cpp
│           └── integration/
│               └── test_Application.cpp
│
├── exec/                           # Legacy Executables (unverändert)
│   └── MinimalConsole/
│       └── src/
│           └── main.cpp
│
└── tests/                          # Globale Tests (unverändert)
    └── unit/
        └── BasicLogger_Tests/
```

### 2.2 app.json Struktur

```json
{
    "name": "MyApp",
    "displayName": "My Application",
    "version": "1.0.0",
    "description": "A testable application",
    
    "core": {
        "type": "STATIC",
        "include": "core/include",
        "src": "core/src",
        "dependencies": ["BasicLogger"],
        "externals": ["spdlog", "nlohmann_json"]
    },
    
    "runner": {
        "type": "WINDOW",
        "src": "runner",
        "externals": ["glfw", "imgui"]
    },
    
    "tests": {
        "framework": "doctest",
        "unit": {
            "path": "tests/unit",
            "timeout": 30
        },
        "integration": {
            "path": "tests/integration",
            "timeout": 120
        }
    },
    
    "platforms": ["windows", "linux", "macos"]
}
```

### 2.3 Generierte Targets

Aus einem App-Container `MyApp` werden folgende CMake-Targets generiert:

| Target | Typ | Beschreibung |
|--------|-----|--------------|
| `MyApp.Core` | STATIC/SHARED Library | Gesamte Business-Logik |
| `MyApp` | Executable | Runner + Core |
| `MyApp.UnitTests` | Test Executable | Unit Tests gegen Core |
| `MyApp.IntegrationTests` | Test Executable | Integration Tests |

---

## 3. Solution.json Integration

### 3.1 Neue `apps` Sektion

```json
{
    "solution": {
        "name": "MySolution",
        "version": "1.0.0"
    },
    
    "apps": [
        "MyApp",
        "AnotherApp"
    ],
    
    "executables": [
        {
            "name": "LegacyTool",
            "path": "projects/exec/LegacyTool/src"
        }
    ],
    
    "libraries": [...],
    "externals": {...},
    "tests": [...]
}
```

### 3.2 Verarbeitungsreihenfolge

```
1. Externals Pipeline      (unverändert)
2. Libraries Pipeline      (unverändert)
3. Apps Pipeline           (NEU - App-Container)
   3.1 AppCore Libraries
   3.2 App Runners
   3.3 App Tests
4. Executables Pipeline    (Legacy, unverändert)
5. Tests Pipeline          (Globale Tests, unverändert)
```

---

## 4. CMake Module

### 4.1 Neue Module

```
cmake/
├── project/
│   ├── Apps.cmake              # Apps Pipeline Entry Point
│   ├── AppCollect.cmake        # App-Container Discovery
│   ├── AppCreate.cmake         # App-Container Creation
│   └── AppTestCreate.cmake     # App-interne Tests
```

### 4.2 Apps.cmake (Entry Point)

```cmake
# ==============================================================================
# Apps.cmake – App-Container Pipeline
# ==============================================================================

include_guard(GLOBAL)

include(${CMAKE_CURRENT_LIST_DIR}/AppCollect.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/AppCreate.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/AppTestCreate.cmake)

# Collect apps from Solution.json
collect_apps()

# Process each app
get_property(_apps GLOBAL PROPERTY SOLUTION_APPS)
foreach(_app IN LISTS _apps)
    create_app_container("${_app}")
endforeach()

message(STATUS "")
message(STATUS "[Apps] === App-Container Pipeline Complete ===")
```

### 4.3 AppCreate.cmake (Kernlogik)

```cmake
function(create_app_container APP_NAME)
    set(_app_dir "${CMAKE_SOURCE_DIR}/projects/apps/${APP_NAME}")
    set(_app_json "${_app_dir}/app.json")
    
    if(NOT EXISTS "${_app_json}")
        cmake_fatal("E401" "App '${APP_NAME}': app.json not found")
    endif()
    
    # Parse app.json
    file(READ "${_app_json}" _json)
    
    # =========================================================================
    # Step 1: Create Core Library
    # =========================================================================
    
    _json_get_string("${_json}" "name" _name)
    set(_core_target "${_name}.Core")
    
    _json_get_object("${_json}" "core" _core_json)
    _json_get_string_or_default("${_core_json}" "type" "STATIC" _core_type)
    _json_get_string("${_core_json}" "src" _core_src)
    _json_get_string("${_core_json}" "include" _core_include)
    
    # Collect sources
    collect_sources(
        SOURCE_DIR "${_app_dir}/${_core_src}"
        SOURCES_OUT _core_sources
        HEADERS_OUT _core_headers
    )
    
    # Create library
    add_library(${_core_target} ${_core_type} ${_core_sources} ${_core_headers})
    
    target_include_directories(${_core_target}
        PUBLIC "${_app_dir}/${_core_include}"
        PRIVATE "${_app_dir}/${_core_src}"
    )
    
    # Apply dependencies and externals
    _apply_app_dependencies("${_core_target}" "${_core_json}")
    
    message(STATUS "[Apps]   Created: ${_core_target} (${_core_type})")
    
    # =========================================================================
    # Step 2: Create Runner Executable
    # =========================================================================
    
    _json_get_object("${_json}" "runner" _runner_json)
    _json_get_string("${_runner_json}" "src" _runner_src)
    _json_get_string_or_default("${_runner_json}" "type" "CONSOLE" _runner_type)
    
    collect_sources(
        SOURCE_DIR "${_app_dir}/${_runner_src}"
        SOURCES_OUT _runner_sources
        HEADERS_OUT _runner_headers
    )
    
    add_executable(${_name} ${_runner_sources} ${_runner_headers})
    
    # Link against Core
    target_link_libraries(${_name} PRIVATE ${_core_target})
    
    # Apply runner-specific externals
    _apply_app_dependencies("${_name}" "${_runner_json}")
    
    # Set executable type (CONSOLE/WINDOW)
    _set_executable_type("${_name}" "${_runner_type}")
    
    message(STATUS "[Apps]   Created: ${_name} (Runner)")
    
    # =========================================================================
    # Step 3: Create App Tests (if BUILD_TESTS)
    # =========================================================================
    
    if(BUILD_TESTS)
        _create_app_tests("${APP_NAME}" "${_app_dir}" "${_json}" "${_core_target}")
    endif()
    
endfunction()
```

---

## 5. App-Container Tests

### 5.1 Automatische Test-Erkennung

Tests innerhalb eines App-Containers werden automatisch erkannt:

```
MyApp/tests/
├── unit/              → MyApp.UnitTests
│   ├── test_*.cpp
│   └── *_test.cpp
└── integration/       → MyApp.IntegrationTests
    └── test_*.cpp
```

### 5.2 Test-Konfiguration in app.json

```json
{
    "tests": {
        "framework": "doctest",
        "unit": {
            "path": "tests/unit",
            "timeout": 30,
            "labels": ["unit", "fast"],
            "externals": []
        },
        "integration": {
            "path": "tests/integration",
            "timeout": 120,
            "labels": ["integration"],
            "externals": ["sqlite"]
        }
    }
}
```

### 5.3 Automatisches Linking

App-Tests linken automatisch gegen `AppName.Core`:

```cmake
# Automatisch generiert für MyApp.UnitTests:
target_link_libraries(MyApp.UnitTests PRIVATE
    MyApp.Core          # App Core Library
    doctest             # Test Framework
)
```

---

## 6. Migration: Legacy → App-Container

### 6.1 Schritt-für-Schritt Migration

```
1. Erstelle apps/MyApp/ Verzeichnis
2. Verschiebe Business-Logik nach core/
3. Erstelle app.json
4. Reduziere runner/main.cpp auf Einstiegspunkt
5. Erstelle Tests in tests/
6. Füge "MyApp" zu Solution.json apps[] hinzu
7. Entferne altes Executable aus executables[]
```

### 6.2 Migrations-Beispiel

**Vorher (Legacy):**
```
projects/exec/MyApp/src/
├── main.cpp           # 500 Zeilen mit allem
├── Application.cpp
├── Application.hpp
├── Module.cpp
└── Module.hpp
```

**Nachher (App-Container):**
```
projects/apps/MyApp/
├── app.json
├── core/
│   ├── include/MyApp/
│   │   ├── Application.hpp
│   │   └── Module.hpp
│   └── src/
│       ├── Application.cpp
│       └── Module.cpp
├── runner/
│   └── main.cpp       # 20 Zeilen - nur Entry Point
└── tests/
    └── unit/
        ├── test_Application.cpp
        └── test_Module.cpp
```

---

## 7. Vorteile

| Aspekt | Legacy | App-Container |
|--------|--------|---------------|
| **Testbarkeit** | Schwierig | Vollständig |
| **Modularität** | Monolithisch | Klar getrennt |
| **Wiederverwendung** | Copy/Paste | Library-Link |
| **Build-Zeit (inkr.)** | Alles neu | Nur geänderte Module |
| **IDE-Integration** | Flach | Strukturiert |

---

## 8. Offene Fragen

1. **Namenskonvention für Core-Library:** `MyApp.Core` vs `MyAppCore` vs `libMyApp`?

2. **Verschachtelung:** Sollen App-Container andere App-Container als Dependencies haben können?

3. **Shared Libraries:** Soll `core.type: "SHARED"` unterstützt werden (DLL/SO)?

4. **Header-Only Option:** Soll Core auch `INTERFACE` (Header-Only) unterstützen?

5. **Test-Aggregation:** Soll es ein `MyApp.AllTests` Target geben, das alle App-Tests zusammenfasst?

---

## 9. Implementierungsplan

| Phase | Beschreibung | Aufwand |
|-------|--------------|---------|
| 8.1 | `AppCollect.cmake` - App-Discovery | 2h |
| 8.2 | `AppCreate.cmake` - Core + Runner | 4h |
| 8.3 | `AppTestCreate.cmake` - App-Tests | 3h |
| 8.4 | Solution.json Integration | 2h |
| 8.5 | Dokumentation | 2h |
| 8.6 | Build-System Tests | 2h |

**Geschätzter Gesamtaufwand:** ~15 Stunden

---

## 10. Beispiel: Vollständiger App-Container

### 10.1 app.json

```json
{
    "name": "AudioPlayer",
    "displayName": "Audio Player Application",
    "version": "2.0.0",
    
    "core": {
        "type": "STATIC",
        "include": "core/include",
        "src": "core/src",
        "dependencies": ["BasicLogger"],
        "externals": ["bass"]
    },
    
    "runner": {
        "type": "WINDOW",
        "src": "runner",
        "externals": ["imgui_docking", "glad", "glfw"]
    },
    
    "tests": {
        "framework": "doctest",
        "unit": {
            "path": "tests/unit",
            "timeout": 30
        },
        "integration": {
            "path": "tests/integration",
            "timeout": 60,
            "externals": ["bass"]
        }
    }
}
```

### 10.2 Generierte Targets

```
AudioPlayer.Core          - STATIC Library (Business Logic)
AudioPlayer               - Executable (GUI Runner)
AudioPlayer.UnitTests     - Test Executable
AudioPlayer.IntegrationTests - Test Executable
```

### 10.3 Dependencies

```
AudioPlayer.UnitTests
    └── AudioPlayer.Core
        ├── BasicLogger
        ├── bass
        └── doctest

AudioPlayer
    └── AudioPlayer.Core
        ├── BasicLogger
        └── bass
    └── imgui_docking
        └── glfw
    └── glad
        └── OpenGL
```
