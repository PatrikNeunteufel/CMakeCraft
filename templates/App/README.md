# App-Container Template

> **Version:** 0.1.0  
> **Stand:** 2025-12-17  
> **Typ:** Template  
> **Status:** Aktiv

---

## Übersicht

Dieses Template definiert die Standardstruktur für App-Container im CMake Architecture V2 Build-System.

## Struktur

```
App/
├── include/                 # Header
│   ├── Source.cmake
│   └── Application.hpp
├── src/                     # Implementation
│   ├── Source.cmake
│   └── Application.cpp
├── main/                    # Entry Point
│   ├── Source.cmake
│   └── main.cpp             # Generisch, nicht ändern
├── pch/                     # Precompiled Header
│   └── pch.h
└── tests/
    └── unit/                # Unit Tests
        └── Application_Tests.cpp
```

## Verwendung

### 1. Neue App erstellen

```bash
cp -r projects/templates/App projects/apps/MeineApp
```

### 2. Solution.json eintragen

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

### 3. Application anpassen

- `include/Application.hpp` - Interface erweitern
- `src/Application.cpp` - Implementation anpassen
- `pch/pch.h` - Projektspezifische Includes hinzufügen
- `include/Source.cmake`, `src/Source.cmake` - Neue Dateien eintragen

### 4. main.cpp

Die `main/main.cpp` sollte **nicht geändert** werden. Sie ist generisch und funktioniert für alle App-Typen (GUI/Console, alle Plattformen).

## Architektur-Prinzipien

| Ordner | Verantwortung | Testbar |
|--------|---------------|---------|
| `include/` + `src/` | Gesamte Anwendungslogik | ✅ Ja |
| `main/` | Nur Entry Point | ❌ Nein |
| `tests/unit/` | Unit Tests | — |

### runner.type

| Typ | Windows | Linux/macOS |
|-----|---------|-------------|
| `GUI` | `WinMain` (kein Console-Fenster) | `main` |
| `CONSOLE` | `main` (mit Console) | `main` |

## Build-Defines

Das Build-System setzt automatisch:

| Define | Bedingung |
|--------|-----------|
| `APP_GUI` | `runner.type = "GUI"` |
| `APP_CONSOLE` | `runner.type = "CONSOLE"` |

## PCH (Precompiled Header)

`pch/pch.h` enthält häufig verwendete, stabile Includes:
- Standard Library (string, vector, memory, etc.)
- Framework-Header (Qt, OpenGL - auskommentiert)

Die `.h` Extension ist Standard für PCH, auch bei C++.

## Siehe auch

- [App Creation Guide](../../../docs/de/guides/App_Creation_Guide.md)
- [App Template Reference](../../../docs/de/references/App_Template_Reference.md)
- [Solution Schema](../../../docs/de/references/Solution_Schema.md)
