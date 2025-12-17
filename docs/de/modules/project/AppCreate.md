# AppCreate.cmake — Dokumentation

> **Version:** 0.5.1  
> **Datum:** 2025-12-17  
> **Typ:** ModuleDoc  
> **Status:** In Entwicklung  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/project/AppCreate.cmake](../../../../cmake/project/AppCreate.cmake)  
> **Modul-Version:** 0.5.1  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [AppCreate.md](../../../en/modules/project/AppCreate.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [Konzept](#3-konzept)
4. [API-Referenz](#4-api-referenz)
   - 4.1 [_create_app_core()](#41-_create_app_core)
   - 4.2 [_create_app_runner()](#42-_create_app_runner)
   - 4.3 [_create_app_tests()](#43-_create_app_tests)
   - 4.4 [_create_app_test_target()](#44-_create_app_test_target)
5. [Verzeichnisstruktur](#5-verzeichnisstruktur)
6. [Verwendungsbeispiele](#6-verwendungsbeispiele)
7. [Fehlerbehandlung](#7-fehlerbehandlung)
8. [Best Practices](#8-best-practices)
9. [Siehe auch](#9-siehe-auch)
10. [Changelog](#10-changelog)

---

## 1. Übersicht

Das `AppCreate`-Modul ist verantwortlich für die **Erstellung aller CMake-Targets** eines App-Containers. Es enthält drei Hauptfunktionen, die jeweils einen Teil des App-Containers erstellen.

### Zweck

- Erstellung der Core Library (`{AppName}.Core`)
- Erstellung des Runner Executable (`{AppName}`)
- Erstellung der Test Executables (`{AppName}.*Tests`)

### Generierte Targets

| Funktion | Target | Typ | Beschreibung |
|----------|--------|-----|--------------|
| `_create_app_core()` | `{AppName}.Core` | STATIC Library | Business-Logik |
| `_create_app_runner()` | `{AppName}` | Executable | Entry-Point mit main() |
| `_create_app_tests()` | `{AppName}.UnitTests` | Executable | Unit Tests |
| `_create_app_tests()` | `{AppName}.IntegrationTests` | Executable | Integration Tests |

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| CMake 3.19+ | System | JSON-Funktionen, FILE_SET |
| `Context.cmake` | Modul | Context-Daten lesen |
| `Errors.cmake` | Modul | Fehlerbehandlung |
| `Debug.cmake` | Modul | Debug-Ausgabe |
| `OutputDirs.cmake` | Modul | Ausgabeverzeichnisse |
| `Warnings.cmake` | Modul | Warning-Konfiguration |
| `CompilerOptions.cmake` | Modul | Compiler-Einstellungen |
| `Orchestrator.cmake` | Modul | External-Integration |

---

## 3. Konzept

### 3.1 Target-Hierarchie

```
{AppName}.Core (STATIC Library)
       │
       │ PUBLIC link
       │
       ├──────────────────┬────────────────────┐
       │                  │                    │
       ▼                  ▼                    ▼
{AppName}          {AppName}.UnitTests  {AppName}.IntegrationTests
(Executable)       (Test Executable)    (Test Executable)
```

### 3.2 Dependency-Propagation

| Link-Typ | Von → Zu | Bedeutung |
|----------|----------|-----------|
| PUBLIC | Core.Dependencies → Core | Transitiv zu Runner/Tests |
| PUBLIC | Core.Externals → Core | Transitiv zu Runner/Tests |
| PRIVATE | Runner.Externals → Runner | Nur für Runner |
| PRIVATE | Integration.Externals → Integration | Nur für Integration Tests |

### 3.3 Warum STATIC Library?

- **Testbarkeit:** Tests können gegen Core linken ohne main()-Konflikt
- **Compilation:** Einmalige Kompilierung, mehrfache Nutzung
- **Isolation:** Core enthält keine Entry-Point-Logik

---

## 4. API-Referenz

### 4.1 _create_app_core()

```cmake
_create_app_core(CTX)
```

**Beschreibung:**  
Erstellt die `{AppName}.Core` STATIC Library mit allen Business-Logik-Sources.

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `CTX` | ✓ | Context-Prefix (z.B. `APP_0`) |

**Erwartete Context-Keys:**

| Key | Verwendung |
|-----|------------|
| `NAME` | Target-Name Basis |
| `PATH` | Basis-Verzeichnis |
| `VERSION` | Target-Version |
| `PCH_ENABLED` | Precompiled Headers aktivieren |
| `PCH_HEADER` | PCH Header-Pfad |
| `CORE_DEPENDENCIES` | Interne Libraries |
| `CORE_EXTERNALS` | Externe Dependencies |

**Erwartete Verzeichnisse:**

```
{PATH}/
├── include/    ← PUBLIC Headers (optional, W401 wenn fehlt)
└── src/        ← Implementation (Pflicht, E403 wenn fehlt)
```

**Generiertes Target:**
- `{AppName}.Core` — STATIC Library

**Fehler:**
- `E402` — Pfad existiert nicht
- `E403` — Kein src/ Verzeichnis
- `E404` — Keine Sources in src/
- `E405` — Dependency nicht gefunden
- `E010` — External nicht definiert
- `W401` — Kein include/ Verzeichnis
- `W402` — PCH Header nicht gefunden

---

### 4.2 _create_app_runner()

```cmake
_create_app_runner(CTX)
```

**Beschreibung:**  
Erstellt das `{AppName}` Executable mit dem Entry-Point (main()).

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `CTX` | ✓ | Context-Prefix (z.B. `APP_0`) |

**Erwartete Context-Keys:**

| Key | Verwendung |
|-----|------------|
| `NAME` | Target-Name |
| `PATH` | Basis-Verzeichnis |
| `VERSION` | Target-Version |
| `DISPLAY_NAME` | Anzeigename (macOS Bundle) |
| `RUNNER_TYPE` | CONSOLE oder WINDOW/GUI |
| `RUNNER_EXTERNALS` | Runner-spezifische Externals |

**Erwartete Verzeichnisse:**

```
{PATH}/
└── main/    ← Entry-Point (Pflicht, E406 wenn fehlt)
```

**Generiertes Target:**
- `{AppName}` — Executable (WIN32/MACOSX_BUNDLE für GUI)

**Fehler:**
- `E406` — Kein main/ Verzeichnis
- `E407` — Keine Sources in main/
- `E010` — External nicht definiert

---

### 4.3 _create_app_tests()

```cmake
_create_app_tests(CTX)
```

**Beschreibung:**  
Erstellt Test Executables basierend auf der Tests-Konfiguration im Context.

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `CTX` | ✓ | Context-Prefix (z.B. `APP_0`) |

**Erwartete Context-Keys:**

| Key | Verwendung |
|-----|------------|
| `NAME` | App-Name für Target-Prefix |
| `PATH` | Basis-Verzeichnis |
| `TESTS_FRAMEWORK` | doctest, googletest, catch2 |
| `TESTS_UNIT_ENABLED` | Unit Tests erstellen |
| `TESTS_UNIT_TIMEOUT` | CTest Timeout |
| `TESTS_UNIT_LABELS` | CTest Labels |
| `TESTS_INTEGRATION_ENABLED` | Integration Tests erstellen |
| `TESTS_INTEGRATION_TIMEOUT` | CTest Timeout |
| `TESTS_INTEGRATION_LABELS` | CTest Labels |
| `TESTS_INTEGRATION_EXTERNALS` | Zusätzliche Externals |

**Erwartete Verzeichnisse:**

```
{PATH}/
└── tests/
    ├── unit/        ← Unit Test Sources
    └── integration/ ← Integration Test Sources
```

**Generierte Targets:**
- `{AppName}.UnitTests` — wenn `TESTS_UNIT_ENABLED`
- `{AppName}.IntegrationTests` — wenn `TESTS_INTEGRATION_ENABLED`

**Fehler:**
- `E301` — Unbekanntes Framework
- `E010` — Framework/External nicht definiert
- `W403` — Tests aktiviert aber Verzeichnis fehlt/leer

---

### 4.4 _create_app_test_target()

```cmake
_create_app_test_target(TARGET_NAME SRC_DIR CORE_TARGET FRAMEWORK TIMEOUT LABELS EXTRA_EXTERNALS APP_NAME)
```

**Beschreibung:**  
Interne Hilfsfunktion zur Erstellung eines einzelnen Test-Targets.

**Parameter:**

| Parameter | Beschreibung |
|-----------|--------------|
| `TARGET_NAME` | Name des Test-Targets |
| `SRC_DIR` | Verzeichnis mit Test-Sources |
| `CORE_TARGET` | Core Library zum Linken |
| `FRAMEWORK` | Test-Framework |
| `TIMEOUT` | CTest Timeout in Sekunden |
| `LABELS` | CTest Labels (Liste) |
| `EXTRA_EXTERNALS` | Zusätzliche Externals |
| `APP_NAME` | App-Name für IDE-Folder |

---

## 5. Verzeichnisstruktur

### 5.1 Vollständige App-Struktur

```
projects/apps/{AppName}/
├── include/                 ← PUBLIC Headers (Core)
│   ├── Application.hpp
│   └── Module.hpp
├── src/                     ← Implementation (Core)
│   ├── Application.cpp
│   └── Module.cpp
├── main/                    ← Entry Point (Runner)
│   └── main.cpp
├── pch/                     ← Precompiled Headers (optional)
│   ├── pch.hpp
│   └── pch.cpp
└── tests/                   ← Tests
    ├── unit/
    │   └── test_Module.cpp
    └── integration/
        └── test_Application.cpp
```

### 5.2 Minimale App-Struktur

```
projects/apps/{AppName}/
├── src/
│   └── Logic.cpp
└── main/
    └── main.cpp
```

---

## 6. Verwendungsbeispiele

### 6.1 Core Library verwenden

```cpp
// main/main.cpp
#include <Application.hpp>  // Aus include/ der Core Library

int main(int argc, char* argv[]) {
    MyApp::Application app;
    return app.run(argc, argv);
}
```

### 6.2 Unit Test schreiben

```cpp
// tests/unit/test_Module.cpp
#include <doctest/doctest.h>
#include <Module.hpp>  // Aus include/ der Core Library

TEST_CASE("Module functionality") {
    MyApp::Module mod;
    CHECK(mod.initialize() == true);
}
```

### 6.3 CTest ausführen

```bash
# Alle App-Tests
ctest -L AudioPlayer

# Nur Unit Tests
ctest -R "UnitTests"

# Mit Timeout-Override
ctest --timeout 60
```

---

## 7. Fehlerbehandlung

### 7.1 Core-Fehler (E4xx)

| Code | Funktion | Bedingung |
|------|----------|-----------|
| `E402` | `_create_app_core` | Pfad existiert nicht |
| `E403` | `_create_app_core` | Kein src/ Verzeichnis |
| `E404` | `_create_app_core` | Keine Sources in src/ |
| `E405` | `_create_app_core` | Dependency nicht gefunden |
| `E406` | `_create_app_runner` | Kein main/ Verzeichnis |
| `E407` | `_create_app_runner` | Keine Sources in main/ |

### 7.2 Allgemeine Fehler

| Code | Bedingung |
|------|-----------|
| `E010` | External nicht in externals-Block definiert |
| `E301` | Unbekanntes Test-Framework |

### 7.3 Warnungen (W4xx)

| Code | Funktion | Bedingung |
|------|----------|-----------|
| `W401` | `_create_app_core` | Kein include/ Verzeichnis |
| `W402` | `_create_app_core` | PCH Header nicht gefunden |
| `W403` | `_create_app_tests` | Tests aktiviert aber keine Sources |

---

## 8. Best Practices

### 8.1 Do's

| Empfehlung | Begründung |
|------------|------------|
| Headers in include/, Implementation in src/ | Klare PUBLIC/PRIVATE Trennung |
| main.cpp minimal halten | Logik gehört in Core |
| Framework in externals definieren | Zentrale Verwaltung |
| Labels für Tests setzen | Einfaches Filtern |

### 8.2 Don'ts

| Vermeiden | Grund |
|-----------|-------|
| Business-Logik in main/ | Nicht testbar |
| Tests ohne Framework-External | E010 Fehler |
| Große main.cpp | Verletzt App-Container-Prinzip |

### 8.3 Beispiel: Gute vs. Schlechte Struktur

**Gut:**
```cpp
// main/main.cpp (minimal)
#include <Application.hpp>
int main() { return MyApp::run(); }

// src/Application.cpp (testbar)
namespace MyApp {
    int run() { /* Business Logic */ }
}
```

**Schlecht:**
```cpp
// main/main.cpp (zu viel Logik)
int main() {
    // 500 Zeilen Business-Logik...
}
```

---

## 9. Siehe auch

- [Apps.cmake](Apps.md) — Orchestrator
- [AppCollect.cmake](AppCollect.md) — JSON-Parsing
- [ExecutableCreate.cmake](ExecutableCreate.md) — Ähnliches Pattern
- [TestCreate.cmake](TestCreate.md) — Test-Pattern
- [AppContainer_Concept.md](../../projects/buildsystem/concepts/AppContainer_Concept.md) — Konzept
- [ErrorCodes.md](../../references/ErrorCodes.md) — E4xx, W4xx Codes

---

## 10. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.1** | **2025-12-17** | **collect_sources() Integration, SourceCollect.cmake Dependency** |
| 0.5.0 | 2025-12-17 | Initial: Phase 8 App-Container Target-Erstellung, Core/Runner/Tests Funktionen, FILE_SET für Public Headers, IDE Folder-Organisation |
