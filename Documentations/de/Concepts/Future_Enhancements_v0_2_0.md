# Future Enhancements – Geplante Erweiterungen

> **Version:** 0.2.0  
> **Datum:** 2025-12-12  
> **Typ:** Konzept-Doku  
> **Status:** Sammlung  
> **Sprache:** Deutsch

---

## Übersicht

Dieses Dokument sammelt mögliche zukünftige Erweiterungen für das CMake Architecture V2 Build-System. Die Einträge sind nach Bereich gruppiert und mit Priorität/Komplexität bewertet.

### Legende

| Priorität | Bedeutung |
|-----------|-----------|
| 🔴 Hoch | Wichtig für Produktivität/Usability |
| 🟡 Mittel | Nice-to-have, geplant |
| 🟢 Niedrig | Langfristig, bei Bedarf |

| Komplexität | Bedeutung |
|-------------|-----------|
| ⚪ Einfach | < 1 Tag Aufwand |
| 🔵 Mittel | 1-3 Tage Aufwand |
| 🟣 Komplex | > 3 Tage Aufwand |

---

## 1. App-Container (Phase 8)

### 1.1 App-Container Basisimplementierung

> **Priorität:** 🔴 Hoch  
> **Komplexität:** 🟣 Komplex  
> **Status:** Konzept fertig (v0.2.0)

**Beschreibung:**  
Testbare Anwendungsarchitektur durch Trennung von Business-Logik (Core Library) und Entry Point (Runner).

**Struktur:**
```
projects/apps/{AppName}/
├── include/{AppName}/      # PUBLIC Headers
├── src/{AppName}/          # Implementation
├── main/                   # Entry Point
├── pch/                    # Precompiled Header
└── tests/
    ├── unit/
    └── integration/
```

**Generierte Targets:**
- `{AppName}.Core` - STATIC Library
- `{AppName}` - Executable
- `{AppName}.UnitTests` - Test Executable
- `{AppName}.IntegrationTests` - Test Executable

**Solution.json:**
```json
{
    "apps": [{
        "name": "AudioPlayer",
        "core": {
            "dependencies": ["BasicLogger"],
            "externals": ["bass"]
        },
        "runner": {
            "type": "WINDOW",
            "externals": ["imgui"]
        },
        "tests": {
            "framework": "doctest"
        }
    }]
}
```

**Betroffene Dateien:**
- Neu: `cmake/project/Apps.cmake`
- Neu: `cmake/project/AppCollect.cmake`
- Neu: `cmake/project/AppCreate.cmake`
- Update: `Solution_Schema`

**Siehe:** `docs/concepts/AppContainer_Concept_v0_2_0.md`

---

### 1.2 Mehrere Runner pro App

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel  
> **Wann relevant:** CLI + GUI für dieselbe App

**Beschreibung:**  
Ein App-Container mit mehreren Entry Points (z.B. GUI und CLI).

**Mögliche Struktur:**
```
projects/apps/AudioPlayer/
├── core/...
└── runners/
    ├── gui/main.cpp       → AudioPlayer.Gui
    └── cli/main.cpp       → AudioPlayer.Cli
```

---

### 1.3 Shared Core Library Option

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel  
> **Wann relevant:** Plugin-Architekturen, DLL-basierte Apps

**Beschreibung:**  
Option für `core.type: "SHARED"` statt nur STATIC.

---

## 2. Externals

### 2.1 externalsPolicy (JSON-Konfiguration)

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel  
> **Wann relevant:** Verschiedene Projekte mit unterschiedlichen Fetch-Strategien

**Beschreibung:**  
Optionale Konfiguration in Solution.json für explizite Kontrolle über das Fetch-Verhalten.

**Mögliche Felder:**
```json
{
    "externalsPolicy": {
        "fetchRoot": ".externals",
        "updatePolicy": "checkout",
        "lockfile": true
    }
}
```

| Feld | Default | Optionen |
|------|---------|----------|
| `fetchRoot` | `.externals` | Beliebiger Pfad |
| `updatePolicy` | `checkout` | `checkout`, `always`, `never`, `update`, `locked` |
| `lockfile` | `false` | `true`, `false` |

**updatePolicy Optionen:**

| Policy | Verhalten |
|--------|-----------|
| `checkout` | Fetch nur wenn nicht vorhanden (aktuelles Verhalten) |
| `always` | Immer neu fetchen |
| `never` | Nie fetchen, nur existierende nutzen |
| `update` | Fetch + git pull bei jedem Configure |
| `locked` | Exakte Commits aus Lockfile verwenden |

---

### 2.2 Lockfile-System

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🟣 Komplex  
> **Wann relevant:** Reproduzierbare Builds, Team-Entwicklung, CI/CD

**Beschreibung:**  
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
            "resolved_commit": "7b6aead9fb88b3623e3b3725ebb42670cfe4c5f9",
            "fetched_at": "2025-12-10T10:30:00Z"
        },
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.91.6",
            "resolved_commit": "abc123def456...",
            "fetched_at": "2025-12-10T10:31:00Z"
        }
    }
}
```

**Geplante CLI-Befehle:**
```bash
cmake --lockfile-update     # Lockfile aktualisieren
cmake --lockfile-verify     # Lockfile gegen Solution.json prüfen
cmake --lockfile-freeze     # Alle auf resolved_commit fixieren
```

**Vorteile:**
- Exakte Reproduzierbarkeit
- Audit-Trail für Dependency-Updates
- Erkennung von unbeabsichtigten Änderungen
- CI/CD kann identische Builds garantieren

**Betroffene Dateien:**
- Neu: `cmake/externals/Core/Lockfile.cmake`
- Update: `cmake/externals/Core/Fetch.cmake`

---

### 2.3 vcpkg Integration

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🟣 Komplex  
> **Wann relevant:** Nutzung von vcpkg-Paketen

**Beschreibung:**  
Unterstützung für vcpkg als Alternative zu Git-Externals.

**Mögliche Syntax:**
```json
{
    "externals": {
        "fmt": {
            "vcpkg": "fmt",
            "version": "10.1.1"
        },
        "boost-asio": {
            "vcpkg": "boost-asio",
            "features": ["ssl"]
        }
    }
}
```

**Betroffene Dateien:**
- Neu: `cmake/externals/Vcpkg/Handler.cmake`
- Update: `cmake/externals/Orchestrator.cmake`

---

### 2.4 Conan Integration

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🟣 Komplex  
> **Wann relevant:** Conan als Package Manager bevorzugt

**Beschreibung:**  
Ähnlich wie vcpkg, aber für Conan Package Manager.

**Mögliche Syntax:**
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

### 2.5 System-Pakete (find_package)

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🔵 Mittel  
> **Status:** Teilweise implementiert (Qt6)

**Beschreibung:**  
Integration von system-installierten Paketen via CMakes find_package.

**Mögliche Syntax:**
```json
{
    "externals": {
        "OpenSSL": {
            "system": true,
            "required": true,
            "components": ["SSL", "Crypto"]
        },
        "Vulkan": {
            "system": true,
            "env_hint": "VULKAN_SDK"
        }
    }
}
```

**Betroffene Dateien:**
- Neu: `cmake/externals/System/Handler.cmake`
- Update: `cmake/externals/Orchestrator.cmake`

---

### 2.6 Submodule-Support

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** ⚪ Einfach  
> **Wann relevant:** Projekt verwendet Git Submodules

**Beschreibung:**  
Automatische Erkennung/Initialisierung von Git Submodules.

**Mögliche Syntax:**
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

**Beschreibung:**  
Zentrale Konfiguration der Output-Verzeichnisse.

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

**Beschreibung:**  
Zentrale Code-Qualitäts-Steuerung.

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

**Beschreibung:**  
CPack-Metadaten für Installer-Generierung.

```json
{
    "settings": {
        "packaging": {
            "vendor": "My Company",
            "contact": "support@example.com",
            "license": "MIT",
            "homepage": "https://example.com"
        }
    }
}
```

---

### 3.4 Platform-Requirements

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🟣 Komplex

**Beschreibung:**  
Minimum-Plattformversionen definieren.

```json
{
    "settings": {
        "platform": {
            "min_windows_version": "10.0.19041",
            "min_macos_version": "11.0",
            "min_glibc_version": "2.31"
        }
    }
}
```

---

## 4. Executable-Erweiterungen

### 4.1 Zusätzliche Executable-Types

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵-🟣 Variiert

| Type | Beschreibung | Komplexität |
|------|--------------|-------------|
| `TRAY` | System Tray App | 🔵 Mittel |
| `SERVICE` | OS Service/Daemon | 🟣 Komplex |
| `BENCHMARK` | Benchmark Runner | 🔵 Mittel |
| `BUNDLE` | macOS App Bundle | 🔵 Mittel |

---

### 4.2 Custom Entry Point

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** ⚪ Einfach

**Beschreibung:**  
Custom Entry-Point Funktion (WinMain, DllMain).

```json
{
    "executables": [{
        "name": "MyApp",
        "entrypoint": "WinMain"
    }]
}
```

---

### 4.3 Resources

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🔵 Mittel

**Beschreibung:**  
Win32 .rc Dateien, macOS .icns/Info.plist Integration.

```json
{
    "executables": [{
        "name": "MyApp",
        "resources": {
            "windows": "res/app.rc",
            "macos": {
                "icon": "res/app.icns",
                "plist": "res/Info.plist"
            }
        }
    }]
}
```

---

### 4.4 Visibility & Install

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🟣 Komplex

**Beschreibung:**  
Packaging/Export Steuerung für Targets.

```json
{
    "executables": [{
        "name": "MyApp",
        "visibility": "public",
        "install": {
            "destination": "bin",
            "component": "runtime"
        }
    }]
}
```

---

## 5. Test-Erweiterungen

### 5.1 Test Fixtures

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🟣 Komplex

**Beschreibung:**  
CTest Fixtures für Setup/Cleanup/Requires.

```json
{
    "tests": [{
        "name": "IntegrationTests",
        "fixtures": {
            "setup": "StartDatabase",
            "cleanup": "StopDatabase",
            "requires": ["DatabaseRunning"]
        }
    }]
}
```

---

### 5.2 Parameterized Tests

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel

**Beschreibung:**  
Tests mit verschiedenen Parametern ausführen.

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
> **Wann relevant:** Extreme Compile-Zeit-Optimierung

**Beschreibung:**  
CMake UNITY_BUILD Support für schnellere Builds.

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
> **Wann relevant:** C++20 Module-Adoption

**Beschreibung:**  
Native Unterstützung für C++20 Modules (.ixx, .cppm).

---

### 6.3 Cross-Compilation Presets

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel  
> **Wann relevant:** Embedded, Mobile, WebAssembly

**Beschreibung:**  
Vordefinierte Presets für Cross-Compilation.

---

## 7. Tooling

### 7.1 clang-format Auto-Fix

> **Priorität:** 🔴 Hoch  
> **Komplexität:** ⚪ Einfach  
> **Wann relevant:** Automatische Code-Formatierung

**Beschreibung:**  
Build-Target für automatische Formatierung (nicht nur Check).

```bash
cmake --build . --target format-fix
```

---

### 7.2 clang-tidy Auto-Fix

> **Priorität:** 🟡 Mittel  
> **Komplexität:** ⚪ Einfach

**Beschreibung:**  
Build-Target für automatische clang-tidy Fixes.

```bash
cmake --build . --target tidy-fix
```

---

### 7.3 Documentation Generation (Doxygen)

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🔵 Mittel

**Beschreibung:**  
Automatische Doxygen-Konfiguration und Build-Target.

```json
{
    "documentation": {
        "doxygen": {
            "enabled": true,
            "output": "docs/api",
            "exclude": ["tests/", "externals/"]
        }
    }
}
```

---

### 7.4 Code Coverage

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🔵 Mittel

**Beschreibung:**  
Automatische Coverage-Instrumentierung und Report-Generierung.

```bash
cmake --build . --target coverage
```

---

## 8. Projekt-Struktur

### 8.1 Multi-Solution Support

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🟣 Komplex  
> **Wann relevant:** Monorepo mit mehreren unabhängigen Projekten

**Beschreibung:**  
Unterstützung für mehrere Solution.json in einem Repository.

---

### 8.2 Solution Templates

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel

**Beschreibung:**  
Vordefinierte Templates für verschiedene Projekt-Typen.

```bash
cmake --init-solution --template console-app
cmake --init-solution --template gui-app
cmake --init-solution --template library
```

---

### 8.3 Workspace-Support

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🟣 Komplex

**Beschreibung:**  
Übergeordnete Workspace-Datei die mehrere Solutions orchestriert.

---

## 9. CI/CD

### 9.1 GitHub Actions Generator

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🔵 Mittel

**Beschreibung:**  
Automatische Generierung von GitHub Actions Workflows basierend auf Presets.

```bash
cmake --generate-ci github
```

---

### 9.2 GitLab CI Generator

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel

---

### 9.3 Azure DevOps Generator

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel

---

## 10. Offene Entscheidungen

| Thema | Status | Optionen | Tendenz |
|-------|--------|----------|---------|
| Git-Strategie für Lockfile | Offen | Committen vs. .gitignore | Committen |
| App-Container: Core Naming | Offen | `App.Core` vs `AppCore` | `App.Core` |
| Default Test Framework | Offen | doctest vs googletest | doctest |
| Externals Cache Location | Offen | `.externals` vs `_externals` | `.externals` |

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.2.0** | **2025-12-12** | **App-Container (Phase 8), Lockfile-Details, Settings-Erweiterungen, Executable-Erweiterungen, Test-Fixtures** |
| 0.1.0 | 2025-12-10 | Initial: externalsPolicy, Lockfile, vcpkg, Conan, System-Pakete, Tooling |
