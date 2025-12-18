# App-Container Template

> **Version:** 0.1.2  
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
    │   └── Application_Tests.cpp
    ├── integration/               # Integration Tests
    │   └── Application_Integration_Tests.cpp
    └── performance/               # Performance Tests
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

```json
"apps": [
    {
        "name": "MeineApp",
        "displayName": "Meine Anwendung",
        "version": "0.1.0",
        
        "core": {
            "dependencies": [],
            "externals": ["qt6", "bass"]
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

## PCH (Precompiled Header)

`pch/pch.h` enthält häufig verwendete, stabile Includes um Build-Zeiten zu reduzieren.

### PCH aktivieren

In Solution.json hinzufügen:

```json
"pch": {
    "enabled": true
}
```

### PCH deaktivieren

Wenn du **PCH deaktivierst** oder nicht verwendest, **musst du** die Zeile `#include "pch.h"` aus allen `.cpp` Dateien entfernen:

- `src/Application.cpp`
- `main/main.cpp`
- Alle Test-Dateien

Andernfalls schlägt die Kompilierung mit "file not found" Fehler fehl.

### Warum manuelles Include?

Das `#include "pch.h"` ist für **MSVC-Kompatibilität** erforderlich. Während GCC/Clang PCH automatisch via `-include` Flag injizieren können, erfordert MSVC ein explizites Include als erste Zeile in jeder Quelldatei.

### Gute Kandidaten für PCH

- Standard Library Header
- Framework Header (Qt, etc.)
- Stabile externe Library Header

### NICHT in PCH aufnehmen

- Projektspezifische Header (ändern sich oft)
- Header in aktiver Entwicklung

### Dateiendung

Die `.h` Extension ist Standard für PCH, auch bei C++. Einige Compiler/Tools verarbeiten `.hpp` nicht korrekt als PCH.

## Test-Typen

### Unit Tests (`tests/unit/`)

- Schnelle, isolierte Tests
- Keine externen Abhängigkeiten
- Bei jedem Build ausführen

### Integration Tests (`tests/integration/`)

- Testen Komponenten-Interaktionen
- Können externe Ressourcen nutzen
- Längere Timeouts erlaubt

### Performance Tests (`tests/performance/`)

- Messen Ausführungszeit
- Vergleich gegen Schwellenwerte
- Nightly ausführen (optional in CI)

## Build-Defines

Das Build-System setzt automatisch:

| Define | Bedingung |
|--------|-----------|
| `APP_GUI` | `runner.type = "GUI"` |
| `APP_CONSOLE` | `runner.type = "CONSOLE"` |

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
| **0.1.2** | **2025-12-18** | **PCH-Include in main.cpp hinzugefügt, PCH enable/disable Verhalten dokumentiert** |
| 0.1.1 | 2025-12-18 | Integration/Performance Test-Templates hinzugefügt, EN/DE Versionen synchronisiert |
| 0.1.0 | 2025-12-17 | Initial: Template mit korrekter Struktur |
