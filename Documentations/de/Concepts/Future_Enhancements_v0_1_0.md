# Future Enhancements – Geplante Erweiterungen

> **Version:** 0.1.0  
> **Datum:** 2025-12-10  
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

## 1. Externals

### 1.1 externalsPolicy (JSON-Konfiguration)

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel  
> **Wann relevant:** Wenn verschiedene Projekte unterschiedliche Fetch-Strategien benötigen

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
| `updatePolicy` | `checkout` | `checkout`, `always`, `never`, `update` |
| `lockfile` | `false` | `true`, `false` |

**updatePolicy Optionen:**

| Policy | Verhalten |
|--------|-----------|
| `checkout` | Fetch nur wenn nicht vorhanden (aktuelles Verhalten) |
| `always` | Immer neu fetchen |
| `never` | Nie fetchen, nur existierende nutzen |
| `update` | Fetch + git pull bei jedem Configure |

**Betroffene Dateien:**
- `cmake/externals/Core/Fetch.cmake`
- `cmake/project/Solution.cmake`
- `Solution_Schema` Dokumentation

---

### 1.2 Lockfile für Versions-Tracking

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🔵 Mittel  
> **Wann relevant:** Reproduzierbare Builds, Team-Entwicklung

**Beschreibung:**  
Automatisches Tracking welche Versionen (Commit-Hashes) tatsächlich verwendet werden.

**Format (.externals/.lockfile.json):**

```json
{
    "glfw": {
        "git": "https://github.com/glfw/glfw.git",
        "tag": "3.4",
        "commit": "7b6aead9fb88b3623e3b3725ebb42670cfe4c5f9",
        "fetched_at": "2025-12-10T10:30:00Z"
    },
    "imgui": {
        "git": "https://github.com/ocornut/imgui.git",
        "tag": "v1.90.1",
        "commit": "abc123...",
        "fetched_at": "2025-12-10T10:31:00Z"
    }
}
```

**Vorteile:**
- Exakte Reproduzierbarkeit
- Audit-Trail für Dependency-Updates
- Erkennung von unbeabsichtigten Änderungen

**Betroffene Dateien:**
- `cmake/externals/Core/Fetch.cmake` (Schreiben)
- Neues Modul: `cmake/externals/Core/Lockfile.cmake`

---

### 1.3 vcpkg Integration

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🟣 Komplex  
> **Wann relevant:** Nutzung von vcpkg-Paketen, große Dependency-Anzahl

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

**Implementierung:**
- Neuer Handler: `cmake/externals/Vcpkg/Handler.cmake`
- vcpkg.json Generierung oder Integration
- Toolchain-File Handling

**Betroffene Dateien:**
- `cmake/externals/Orchestrator.cmake` (Type-Dispatch)
- Neuer Ordner: `cmake/externals/Vcpkg/`

---

### 1.4 Conan Integration

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

### 1.5 System-Pakete (find_package)

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🔵 Mittel  
> **Wann relevant:** System-installierte Libraries nutzen (OpenSSL, Qt, etc.)

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
        "Qt6": {
            "system": true,
            "components": ["Core", "Widgets", "Gui"]
        }
    }
}
```

**Betroffene Dateien:**
- Neuer Handler: `cmake/externals/System/Handler.cmake`
- `cmake/externals/Orchestrator.cmake`

---

### 1.6 Submodule-Support

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

## 2. Build-System

### 2.1 Precompiled Headers (PCH)

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🔵 Mittel  
> **Wann relevant:** Große Projekte, lange Compile-Zeiten

**Beschreibung:**  
Automatische PCH-Generierung basierend auf häufig verwendeten Headers.

**Mögliche Syntax:**

```json
{
    "executables": [
        {
            "name": "MyApp",
            "pch": "src/pch.hpp"
        }
    ]
}
```

---

### 2.2 Unity Builds

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel  
> **Wann relevant:** Extreme Compile-Zeit-Optimierung

**Beschreibung:**  
CMake UNITY_BUILD Support für schnellere Builds.

---

### 2.3 Module Support (C++20)

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🟣 Komplex  
> **Wann relevant:** C++20 Module-Adoption

**Beschreibung:**  
Native Unterstützung für C++20 Modules (.ixx, .cppm).

---

### 2.4 Cross-Compilation Presets

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel  
> **Wann relevant:** Embedded, Mobile, andere Plattformen

**Beschreibung:**  
Vordefinierte Presets für Cross-Compilation (ARM, WebAssembly, etc.)

---

## 3. Tooling

### 3.1 clang-format Auto-Fix

> **Priorität:** 🔴 Hoch  
> **Komplexität:** ⚪ Einfach  
> **Wann relevant:** Automatische Code-Formatierung

**Beschreibung:**  
Build-Target für automatische Formatierung (nicht nur Check).

```bash
cmake --build . --target format-fix
```

---

### 3.2 clang-tidy Auto-Fix

> **Priorität:** 🟡 Mittel  
> **Komplexität:** ⚪ Einfach  
> **Wann relevant:** Automatische Code-Fixes

**Beschreibung:**  
Build-Target für automatische clang-tidy Fixes.

```bash
cmake --build . --target tidy-fix
```

---

### 3.3 Documentation Generation (Doxygen)

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🔵 Mittel  
> **Wann relevant:** API-Dokumentation

**Beschreibung:**  
Automatische Doxygen-Konfiguration und Build-Target.

```json
{
    "documentation": {
        "doxygen": true,
        "output": "docs/api"
    }
}
```

---

### 3.4 Code Coverage

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🔵 Mittel  
> **Wann relevant:** Test-Coverage-Reports

**Beschreibung:**  
Automatische Coverage-Instrumentierung und Report-Generierung.

---

## 4. Projekt-Struktur

### 4.1 Multi-Solution Support

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🟣 Komplex  
> **Wann relevant:** Monorepo mit mehreren unabhängigen Projekten

**Beschreibung:**  
Unterstützung für mehrere Solution.json in einem Repository.

---

### 4.2 Solution Templates

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel  
> **Wann relevant:** Schnelles Projekt-Setup

**Beschreibung:**  
Vordefinierte Templates für verschiedene Projekt-Typen (Console App, GUI App, Library, etc.)

---

### 4.3 Workspace-Support

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🟣 Komplex  
> **Wann relevant:** Mehrere Solutions die zusammenarbeiten

**Beschreibung:**  
Übergeordnete Workspace-Datei die mehrere Solutions orchestriert.

---

## 5. CI/CD

### 5.1 GitHub Actions Generator

> **Priorität:** 🟡 Mittel  
> **Komplexität:** 🔵 Mittel  
> **Wann relevant:** CI/CD Setup

**Beschreibung:**  
Automatische Generierung von GitHub Actions Workflows basierend auf Presets.

---

### 5.2 GitLab CI Generator

> **Priorität:** 🟢 Niedrig  
> **Komplexität:** 🔵 Mittel  
> **Wann relevant:** GitLab-basierte Projekte

---

## Notizen

_Platz für eigene Ideen und Notizen aus früheren Versionen_

---

---

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-10** | **Initial: externalsPolicy, Lockfile, vcpkg, Conan, System-Pakete, Tooling** |
