# App-Container Template

> **Version:** 0.1.3  
> **Datum:** 2025-12-18  
> **Typ:** Template  
> **Status:** Aktiv  
> **English:** [README.md](README.md)

---

CMake Architecture V2 - App-Container Template

## Übersicht

Dieses Template definiert die Standardstruktur für App-Container im CMake Architecture V2 Build-System. Es trennt den Entry Point (`main/`) von der Anwendungslogik (`include/`, `src/`) für maximale Testbarkeit.

## Verzeichnisstruktur

```
App/
├── README.md                      # Englische Version
├── README_de.md                   # Diese Datei (Deutsch)
├── include/                       # Öffentliche Header
│   ├── Source.cmake
│   └── Application.hpp
├── src/                           # Implementation
│   ├── Source.cmake
│   └── Application.cpp
├── main/                          # Entry Point (nicht testbar)
│   ├── Source.cmake
│   └── main.cpp
├── pch/                           # Precompiled Header
│   └── pch.h
└── tests/                         # Tests
    ├── unit/                      # Unit Tests
    │   ├── Source.cmake
    │   ├── test_main.cpp          # doctest Entry Point
    │   └── Application_Tests.cpp
    ├── integration/               # Integration Tests
    │   ├── Source.cmake
    │   ├── test_main.cpp          # doctest Entry Point
    │   └── Application_Integration_Tests.cpp
    └── performance/               # Performance Tests
        ├── Source.cmake
        ├── test_main.cpp          # doctest Entry Point
        └── Application_Performance_Tests.cpp
```

## Architektur

| Verzeichnis | Verantwortung | Testbar |
|-------------|---------------|---------|
| `include/` + `src/` | Gesamte Logik, UI, Services | ✅ Ja |
| `main/` | Nur Entry Point | ❌ Nein |
| `pch/` | Precompiled Header | — |
| `tests/` | Test-Code | — |

## Verwendung

### 1. Template kopieren

Kopiere dieses Verzeichnis in dein Projekt:

```bash
cp -r projects/templates/App projects/apps/MeineApp
```

### 2. Solution.json konfigurieren

#### Minimale Konfiguration (nur Unit Tests)

```json
"apps": [
    {
        "name": "MeineApp",
        "displayName": "Meine Anwendung",
        "version": "0.1.0",
        
        "core": {
            "dependencies": [],
            "externals": []
        },

        "runner": {
            "type": "GUI",
            "externals": []
        },

        "pch": {
            "enabled": true
        },

        "tests": {
            "framework": "doctest",
            "unit": {
                "timeout": 30,
                "labels": ["unit", "app", "fast"]
            }
        }
    }
]
```

#### Vollständige Konfiguration (alle Test-Typen)

```json
"apps": [
    {
        "name": "MeineApp",
        "displayName": "Meine Anwendung",
        "version": "0.1.0",
        "description": "Anwendungsbeschreibung",
        
        "core": {
            "dependencies": ["EineLibrary"],
            "externals": ["bass", "qt6"]
        },

        "runner": {
            "type": "GUI",
            "externals": ["glad", "glfw"]
        },

        "pch": {
            "enabled": true,
            "header": "pch.h"
        },

        "tests": {
            "framework": "doctest",
            "unit": {
                "timeout": 30,
                "labels": ["unit", "app", "fast"]
            },
            "integration": {
                "timeout": 120,
                "labels": ["integration", "app", "slow"],
                "externals": ["bass"]
            },
            "performance": {
                "timeout": 300,
                "labels": ["performance", "app", "benchmark"]
            }
        },

        "platforms": ["windows", "linux", "macos"]
    }
]
```

### 3. Application-Klasse anpassen

Bearbeite `src/Application.cpp`:
- Initialisiere Services in `init()`
- Implementiere die Hauptschleife in `run()`
- Räume Ressourcen in `shutdown()` auf

### 4. Source.cmake-Dateien aktualisieren

Bei neuen Dateien die entsprechende `Source.cmake` aktualisieren:

```cmake
set(_local_sources
    "${CMAKE_CURRENT_LIST_DIR}/Application.cpp"
    "${CMAKE_CURRENT_LIST_DIR}/NeueKlasse.cpp"    # Neue Dateien hinzufügen
)
```

### 5. main.cpp

Die `main/main.cpp` sollte **nicht geändert** werden. Sie ist generisch und funktioniert für alle App-Typen (GUI/Console, alle Plattformen).

## Test-Typen

### Unit Tests (`tests/unit/`)

- Schnelle, isolierte Tests
- Keine externen Abhängigkeiten
- Bei jedem Build ausführen
- Timeout: typisch 30 Sekunden

**Dateien:**
- `test_main.cpp` — doctest Entry Point (nicht ändern)
- `Application_Tests.cpp` — deine Testfälle

### Integration Tests (`tests/integration/`)

- Testen Komponenten-Interaktionen
- Können externe Ressourcen nutzen (Dateien, Netzwerk, Datenbank)
- Längere Timeouts erlaubt
- Können zusätzliche Externals haben

**Dateien:**
- `test_main.cpp` — doctest Entry Point (nicht ändern)
- `Application_Integration_Tests.cpp` — deine Testfälle

**Solution.json:**
```json
"integration": {
    "timeout": 120,
    "labels": ["integration", "slow"],
    "externals": ["bass", "somedb"]
}
```

### Performance Tests (`tests/performance/`)

- Messen Ausführungszeit und Ressourcenverbrauch
- Vergleich gegen Baseline/Schwellenwerte
- Nightly ausführen (optional in regulärer CI)

**Dateien:**
- `test_main.cpp` — doctest Entry Point (nicht ändern)
- `Application_Performance_Tests.cpp` — deine Benchmarks

**Solution.json:**
```json
"performance": {
    "timeout": 300,
    "labels": ["performance", "benchmark", "nightly"]
}
```

## test_main.cpp

Jedes Test-Verzeichnis enthält eine `test_main.cpp` die die doctest-Implementation bereitstellt:

```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest/doctest.h>
```

**Wichtig:** Dieses Define nicht in deine Test-Dateien einfügen! Es darf genau **einmal** pro Test-Executable erscheinen.

## PCH (Precompiled Header)

`pch/pch.h` enthält häufig verwendete, stabile Includes um Build-Zeiten zu reduzieren.

### PCH-Geltungsbereich

- **Core (`src/`)**: Verwendet PCH — `#include "pch.h"` als erste Zeile hinzufügen
- **Runner (`main/`)**: Verwendet PCH NICHT — kein Include nötig
- **Tests**: Verwenden PCH NICHT — kein Include nötig

### PCH aktivieren/deaktivieren

```json
"pch": {
    "enabled": true,    // oder false zum Deaktivieren
    "header": "pch.h"   // optional, Standard ist "pch.h"
}
```

Bei deaktiviertem PCH: `#include "pch.h"` aus allen Dateien in `src/` entfernen.

## Build-Defines

Das Build-System setzt automatisch:

| Define | Bedingung |
|--------|-----------|
| `APP_GUI` | `runner.type = "GUI"` (nur Windows) |

## runner.type

| Typ | Windows | Linux/macOS |
|-----|---------|-------------|
| `GUI` | `WinMain` (kein Console-Fenster) | `main` |
| `CONSOLE` | `main` (mit Console) | `main` |

## Siehe auch

- [Solution Schema](../../docs/de/references/Solution_Schema.md)
- [App Creation Guide](../../docs/de/userguides/App_Creation_Guide.md)
- [App Template Reference](../../docs/de/references/App_Template_Reference.md)
- [AppContainer Concept](../../docs/de/projects/buildsystem/concepts/AppContainer_Concept.md)

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.3** | **2025-12-18** | **test_main.cpp für doctest hinzugefügt, Integration/Performance Test-Konfiguration dokumentiert** |
| 0.1.2 | 2025-12-18 | PCH-Include in main.cpp hinzugefügt, PCH enable/disable Verhalten dokumentiert |
| 0.1.1 | 2025-12-18 | Integration/Performance Test-Templates hinzugefügt, EN/DE Versionen synchronisiert |
| 0.1.0 | 2025-12-17 | Initial: Template mit korrekter Struktur |
