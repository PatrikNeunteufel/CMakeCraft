# Future Enhancements — Geplante Erweiterungen

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Concept  
> **Status:** Sammlung  
> **Zielgruppe:** Build-System-Entwickler, Architekten  
> **Sprache:** Deutsch  
> **English:** [future_enhancements.md](../../en/projects/buildsystem/concepts/future_enhancements.md)

Dieses Dokument sammelt mögliche **zukünftige Erweiterungen** für das CMake Architecture V2 Build-System. Die Einträge sind nach Bereich gruppiert und mit Priorität/Komplexität bewertet.

---

## Inhaltsverzeichnis

1. [Legende](#1-legende)
2. [Externals](#2-externals)
3. [Settings-Erweiterungen](#3-settings-erweiterungen)
4. [Executable-Erweiterungen](#4-executable-erweiterungen)
5. [Test-Erweiterungen](#5-test-erweiterungen)
6. [Build-System](#6-build-system)
7. [Tooling](#7-tooling)
8. [Projekt-Struktur](#8-projekt-struktur)
9. [CI/CD](#9-cicd)
10. [App-Container Erweiterungen](#10-app-container-erweiterungen)
11. [Offene Entscheidungen](#11-offene-entscheidungen)
12. [Siehe auch](#12-siehe-auch)


---

## 1. Legende

### Priorität

| Symbol | Bedeutung |
|--------|-----------|
| 🔴 Hoch | Wichtig für Produktivität/Usability |
| 🟡 Mittel | Nice-to-have, geplant |
| 🟢 Niedrig | Langfristig, bei Bedarf |

### Komplexität

| Symbol | Bedeutung |
|--------|-----------|
| ⚪ Einfach | < 1 Tag Aufwand |
| 🔵 Mittel | 1-3 Tage Aufwand |
| 🟣 Komplex | > 3 Tage Aufwand |

---

## 2. Externals

### 2.1 Lockfile-System

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🟣 Komplex

Automatisches Tracking welche Versionen (Commit-Hashes) tatsächlich verwendet werden.

**Format (externals.lock.json):**
```json
{
    "version": "1.0",
    "generated": "2025-12-10T10:30:00Z",
    "externals": {
        "glfw": {
            "git": "https://github.com/glfw/glfw.git",
            "tag": "3.4",
            "resolved_commit": "7b6aead9fb88b3623e3b3725ebb42670cfe4c5f9"
        }
    }
}
```

**Vorteile:**
- Exakte Reproduzierbarkeit
- Audit-Trail für Dependency-Updates
- CI/CD kann identische Builds garantieren

---

### 2.2 externalsPolicy

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel

Konfiguration des Fetch-Verhaltens:

```json
{
    "externalsPolicy": {
        "fetchRoot": ".externals",
        "updatePolicy": "checkout",
        "lockfile": true
    }
}
```

| Policy | Verhalten |
|--------|-----------|
| `checkout` | Fetch nur wenn nicht vorhanden (Default) |
| `always` | Immer neu fetchen |
| `never` | Nie fetchen, nur existierende nutzen |
| `locked` | Exakte Commits aus Lockfile |

---

### 2.3 vcpkg Integration

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🟣 Komplex

```json
{
    "externals": {
        "fmt": {
            "vcpkg": "fmt",
            "version": "10.1.1"
        }
    }
}
```

---

### 2.4 Conan Integration

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🟣 Komplex

```json
{
    "externals": {
        "spdlog": {
            "conan": "spdlog/1.12.0"
        }
    }
}
```

---

### 2.5 Submodule-Support

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** ⚪ Einfach

```json
{
    "externals": {
        "mylib": {
            "submodule": "libs/mylib"
        }
    }
}
```

---

## 3. Settings-Erweiterungen

### 3.1 Output-Konfiguration

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🔵 Mittel

```json
{
    "settings": {
        "output": {
            "bin_dir": "bin",
            "lib_dir": "lib",
            "archive_dir": "lib"
        }
    }
}
```

---

### 3.2 Quality-Einstellungen

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🔵 Mittel

```json
{
    "settings": {
        "quality": {
            "clang_tidy": true,
            "clang_format": true,
            "warnings_as_errors": false,
            "sanitizers": ["address", "undefined"]
        }
    }
}
```

---

### 3.3 Packaging-Metadaten

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** ⚪ Einfach

CPack-Metadaten für Installer-Generierung:

```json
{
    "settings": {
        "packaging": {
            "vendor": "My Company",
            "license": "MIT"
        }
    }
}
```

---

## 4. Executable-Erweiterungen

### 4.1 Zusätzliche Executable-Types

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵-🟣 Variiert

| Type | Beschreibung |
|------|--------------|
| `TRAY` | System Tray App |
| `SERVICE` | OS Service/Daemon |
| `BENCHMARK` | Benchmark Runner |
| `BUNDLE` | macOS App Bundle |

---

### 4.2 Resources

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🔵 Mittel

Win32 .rc Dateien, macOS .icns/Info.plist:

```json
{
    "executables": [{
        "name": "MyApp",
        "resources": {
            "windows": "res/app.rc",
            "macos": {
                "icon": "res/app.icns"
            }
        }
    }]
}
```

---

## 5. Test-Erweiterungen

### 5.1 Test Fixtures

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🟣 Komplex

CTest Fixtures für Setup/Cleanup:

```json
{
    "tests": [{
        "name": "IntegrationTests",
        "fixtures": {
            "setup": "StartDatabase",
            "cleanup": "StopDatabase"
        }
    }]
}
```

---

### 5.2 Parameterized Tests

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel

```json
{
    "tests": [{
        "name": "CrossPlatformTests",
        "parameters": {
            "backend": ["opengl", "vulkan", "d3d12"]
        }
    }]
}
```

---

## 6. Build-System

### 6.1 Unity Builds

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel

```json
{
    "settings": {
        "unity_build": {
            "enabled": true,
            "batch_size": 16
        }
    }
}
```

---

### 6.2 C++20 Modules

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🟣 Komplex

Native Unterstützung für C++20 Modules (.ixx, .cppm).

---

### 6.3 Cross-Compilation Presets

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel

Vordefinierte Presets für Embedded, Mobile, WebAssembly.

---

## 7. Tooling

### 7.1 clang-format Auto-Fix

> **Priorität:** 🔴 Hoch  
> **Komplexität:** ⚪ Einfach

```bash
cmake --build . --target format-fix
```

---

### 7.2 clang-tidy Auto-Fix

> **Priorität:** 🟡 Mittel  
> **Komplexität:** ⚪ Einfach

```bash
cmake --build . --target tidy-fix
```

---

### 7.3 Documentation Generation

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🔵 Mittel

Automatische Doxygen-Konfiguration:

```json
{
    "documentation": {
        "doxygen": {
            "enabled": true,
            "output": "docs/api"
        }
    }
}
```

---

### 7.4 Code Coverage

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🔵 Mittel

```bash
cmake --build . --target coverage
```

---

## 8. Projekt-Struktur

### 8.1 Multi-Solution Support

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🟣 Komplex

Mehrere Solution.json in einem Monorepo.

---

### 8.2 Solution Templates

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel

```bash
cmake --init-solution --template console-app
cmake --init-solution --template gui-app
```

---

## 9. CI/CD

### 9.1 GitHub Actions Generator

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🔵 Mittel

```bash
cmake --generate-ci github
```

---

### 9.2 GitLab CI Generator

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel

---

## 10. App-Container Erweiterungen

### 10.1 Mehrere Runner pro App

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel

```
projects/apps/AudioPlayer/
├── core/...
└── runners/
    ├── gui/main.cpp       → AudioPlayer.Gui
    └── cli/main.cpp       → AudioPlayer.Cli
```

---

### 10.2 Shared Core Library

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel

Option für `core.type: "SHARED"` statt nur STATIC.

---

### 10.3 Performance Tests

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel

Eigener Ordner `tests/performance/` für Benchmark-Tests.

---

## 11. Offene Entscheidungen

| Thema | Status | Optionen | Tendenz |
|-------|--------|----------|---------|
| Git-Strategie für Lockfile | Offen | Committen vs. .gitignore | Committen |
| App-Container: Core Naming | Offen | `App.Core` vs `AppCore` | `App.Core` |
| Default Test Framework | Offen | doctest vs googletest | doctest |
| Externals Cache Location | Offen | `.externals` vs `_externals` | `.externals` |

---

## 12. Siehe auch

- [master_concept.md](master_concept.md) — Gesamtarchitektur
- [implementation_plan.md](implementation_plan.md) — Phasen-Plan
- [AppContainer.md](AppContainer.md) — Phase 8 Detail
- [System_Externals.md](System_Externals.md) — Phase 9 Detail

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Neues Header-Format, Reorganisation, Dateiname ohne Version** |
| 0.2.0 | 2025-12-12 | App-Container, Lockfile-Details, Settings-Erweiterungen |
| 0.1.0 | 2025-12-10 | Initial |