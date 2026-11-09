# Erste Schritte – Benutzerhandbuch

> **Version:** 1.0.1  
> **Datum:** 2026-11-09  
> **Typ:** Guide  
> **Status:** Stabil  
> **Zielgruppe:** C++ Entwickler (Einsteiger und Fortgeschrittene)  
> **Sprache:** Deutsch  
> **English:** [Getting_Started_UserGuide.md](../../../en/guide/userguides/Getting_Started.md)

---

## Inhaltsverzeichnis

1. [Überblick](#1-überblick)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Schnellstart](#3-schnellstart)
4. [Projektstruktur verstehen](#4-projektstruktur-verstehen)
5. [Solution.json – Das Herzstück](#5-solutionjson--das-herzstück)
6. [Erstes Executable erstellen](#6-erstes-executable-erstellen)
7. [Erste Library erstellen](#7-erste-library-erstellen)
8. [Build-Befehle](#8-build-befehle)
9. [Externals verwenden](#9-externals-verwenden)
10. [Tests hinzufügen](#10-tests-hinzufügen)
11. [Workflow-Zusammenfassung](#11-workflow-zusammenfassung)
12. [Stolpersteine und Lösungen](#12-stolpersteine-und-lösungen)
13. [Troubleshooting](#13-troubleshooting)
14. [Nächste Schritte](#14-nächste-schritte)
15. [Siehe auch](#15-siehe-auch)

---

## 1. Überblick

Willkommen zum **CMake Architecture** Build-System! Dieses Handbuch führt dich durch alle Schritte, um dein erstes Projekt erfolgreich zu erstellen und zu bauen.

### Was ist CMake Architecture?

Ein **JSON-gesteuertes Build-System** für C++ Projekte, das:

- **Deklarativ** arbeitet – beschreibe WAS, nicht WIE
- **Multi-Projekt** unterstützt – mehrere Executables und Libraries in einer Solution
- **Externe Bibliotheken** automatisch verwaltet
- **Plattformübergreifend** funktioniert (Windows, Linux, macOS)
- **IDE-Integration** bietet (Visual Studio, CLion, VS Code)

### Das wichtigste Prinzip

> **Wenn es nicht in der Solution.json steht, existiert es nicht.**

Alles – Executables, Libraries, Tests, Externals – wird in `Solution.json` definiert. Das Build-System generiert daraus automatisch die CMake-Konfiguration.

### Was du am Ende dieses Guides haben wirst

- Ein funktionierendes Projekt mit Executable und Library
- Verständnis der Projektstruktur
- Wissen, wie du neue Module hinzufügst
- Grundlagen für Tests und Externals

---

## 2. Voraussetzungen

### Checkliste

- [ ] **CMake 3.26+** installiert
- [ ] **C++ Compiler:** MSVC 2022, GCC 11+, oder Clang 14+
- [ ] **Git** installiert
- [ ] **IDE** (empfohlen): Visual Studio 2022, CLion, oder VS Code mit CMake-Extension
- [ ] **Ninja** (empfohlen für schnellere Builds)

### Installation prüfen

```bash
# CMake Version
cmake --version
# Sollte 3.26 oder höher sein

# Compiler
cl /?          # Windows (MSVC)
g++ --version  # Linux (GCC)
clang++ --version  # macOS/Linux (Clang)

# Git
git --version

# Ninja (optional aber empfohlen)
ninja --version
```

### Empfohlene Versionen

| Tool | Minimum | Empfohlen |
|------|---------|-----------|
| CMake | 3.26 | 3.28+ |
| MSVC | 2019 | 2022 |
| GCC | 11 | 13+ |
| Clang | 14 | 17+ |
| Ninja | 1.10 | 1.11+ |

---

## 3. Schnellstart

### 3.1 Projekt anlegen

CMakeCraft liegt nicht im Projekt: Das Projekt trägt nur drei kleine Dateien, das Build-System
selbst wird beim ersten Konfigurieren in der gepinnten Version nach `.externals/cmakecraft/<version>/`
geholt. Die Vorlagen liegen in CMakeCraft unter [`templates/consumer/`](../../../../templates/consumer/):

```bash
mkdir MyProject && cd MyProject
git init

# aus einer CMakeCraft-Arbeitskopie, hier ../CMakeCraft
cp ../CMakeCraft/templates/consumer/CMakeCraftBootstrap.cmake .
cp ../CMakeCraft/templates/consumer/cmakecraft.pin .
cp ../CMakeCraft/templates/consumer/CMakeLists.txt .
cp ../CMakeCraft/CMakePresets.json .
```

- `CMakeCraftBootstrap.cmake` — unverändert übernehmen.
- `cmakecraft.pin` — die CMakeCraft-Version als Git-Tag, z. B. `set(CMAKECRAFT_VERSION "v0.14.1")`.
- `CMakeLists.txt` — nur den Namen in `project(<Name> LANGUAGES NONE)` anpassen. Die Zeile ist
  Pflicht (seit v0.13.0, sonst E005); Name und Version setzt CMakeCraft aus der Solution.json.

Die vollständige Einrichtung (`.gitignore`, Benutzer-Presets, erster Commit) beschreibt der
[Neues_Projekt_Guide](Neues_Projekt_Guide.md).

### 3.2 Solution.json erstellen

Erstelle `Solution.json` im Projekt-Root:

```json
{
    "schemaVersion": "1.0",
    "solution": {
        "name": "MyProject",
        "version": "1.0.0"
    },
    "settings": {
        "standards": {
            "cxx_standard": 20
        }
    },
    "executables": [
        {
            "name": "HelloWorld",
            "type": "CONSOLE"
        }
    ]
}
```

### 3.3 Source-Datei erstellen

Erstelle `projects/exec/HelloWorld/src/main.cpp` (Standardpfad eines Executables, §4.3):

```cpp
#include <iostream>

int main() {
    std::cout << "Hello, CMake Architecture!" << std::endl;
    return 0;
}
```

Daneben die Dateiliste `projects/exec/HelloWorld/src/Source.cmake` — die Quellen werden explizit
aufgeführt (Vorgabe `settings.sources.mode = "explicit"`, §6.6):

```cmake
list(APPEND ${TARGET_NAME}_SOURCES "${CMAKE_CURRENT_LIST_DIR}/main.cpp")
```

### 3.4 Bauen und Ausführen

```bash
# Konfigurieren (beim ersten Mal wird CMakeCraft gemäss cmakecraft.pin geholt)
cmake --preset windows-ninja-debug-msvc   # Windows (oder windows-ninja-debug-clang)
cmake --preset linux-gcc-debug            # Linux
cmake --preset macos-ninja-debug          # macOS

# Bauen
cmake --build out/build/windows-ninja-debug-msvc

# Ausführen
./out/build/windows-ninja-debug-msvc/exec/HelloWorld/bin/Debug/HelloWorld.exe   # Windows
./out/build/linux-gcc-debug/exec/HelloWorld/bin/Debug/HelloWorld                # Linux
```

**Geschafft!** Du hast dein erstes Projekt gebaut. 🎉

---

## 4. Projektstruktur verstehen

### 4.1 Standard-Verzeichnisstruktur

```
MyProject/
├── CMakeLists.txt              ← Dünnfassung (Vorlage templates/consumer/)
├── CMakeCraftBootstrap.cmake   ← holt CMakeCraft (unverändert aus der Vorlage)
├── cmakecraft.pin              ← CMakeCraft-Version (Git-Tag)
├── CMakePresets.json           ← Team-weite Build-Presets
├── CMakeUserPresets.json       ← Persönliche Presets (nicht committen!)
├── Solution.json               ← ZENTRALE KONFIGURATION
│
├── externals/                  ← Lokale externe Bibliotheken
│   ├── bass/
│   ├── doctest/
│   └── lua54/
│
├── projects/                   ← DEIN CODE
│   ├── exec/                   ← Executables
│   │   └── HelloWorld/
│   │       └── src/
│   │           ├── Source.cmake
│   │           └── main.cpp
│   ├── libs/                   ← Libraries
│   │   └── CoreLib/
│   │       ├── include/
│   │       │   └── CoreLib/
│   │       │       └── Calculator.h
│   │       └── src/
│   │           ├── Source.cmake
│   │           └── Calculator.cpp
│   └── tests/                  ← Test-Projekte
│       └── unit/
│           └── CoreLib_Tests/
│               └── src/
│
├── .externals/                 ← beim Konfigurieren geholt (nicht committen)
│   └── cmakecraft/<version>/   ← das Build-System selbst
│
└── out/                        ← Build-Ausgabe (generiert)
    └── build/
        └── windows-ninja-debug-msvc/
            └── exec/
                └── HelloWorld/
                    └── bin/
                        └── Debug/
                            └── HelloWorld.exe
```

### 4.2 Wichtige Dateien

| Datei | Zweck | Bearbeiten? |
|-------|-------|-------------|
| `Solution.json` | Projekt-Definition | ✅ JA |
| `CMakeLists.txt` | CMake-Einstiegspunkt (Dünnfassung aus `templates/consumer/`) | ⚠️ Nur den Namen in `project(<Name> LANGUAGES NONE)` — die Zeile ist Pflicht (seit v0.13.0, sonst E005) |
| `cmakecraft.pin` | CMakeCraft-Version (Git-Tag) und Bezugsquellen | ⚠️ Beim Versionswechsel |
| `CMakeCraftBootstrap.cmake` | Holt CMakeCraft nach `.externals/cmakecraft/<version>/` | ❌ Nein (unverändert übernehmen) |
| `CMakePresets.json` | Team-Presets | ⚠️ Selten |
| `CMakeUserPresets.json` | Persönliche Presets | ✅ JA |

### 4.3 Pfad-Konventionen

Das Build-System erwartet standardmäßig diese Pfade:

| Typ | Pfad-Muster |
|-----|-------------|
| Executable | `projects/exec/{name}/src/` |
| Library | `projects/libs/{name}/src/` (öffentliche Header: `projects/libs/{name}/include/`, falls vorhanden) |
| Test | `projects/tests/{type}/{name}/src/` |

Du kannst diese mit dem `path` Feld überschreiben (die Header einer Library mit `public_headers`).
Im Quellverzeichnis erwartet das Build-System eine `Source.cmake` mit der Dateiliste (§6.6).

---

## 5. Solution.json – Das Herzstück

### 5.1 Grundstruktur

```json
{
    "schemaVersion": "1.0",
    "solution": {
        "name": "MySolution",
        "version": "1.0.0"
    },
    "settings": { ... },
    "externals": { ... },
    "libraries": [ ... ],
    "executables": [ ... ],
    "apps": [ ... ],
    "tests": [ ... ]
}
```

### 5.2 Abschnitte erklärt

| Abschnitt | Zweck | Pflicht? |
|-----------|-------|----------|
| `schemaVersion` | Schema-Version (heute `1.0`; ein anderes Major bricht mit E003 ab) | ✅ Ja |
| `solution` | Projekt-Metadaten | ✅ Ja |
| `settings` | Globale Einstellungen | ❌ Optional |
| `externals` | Externe Bibliotheken | ❌ Optional |
| `libraries` | Interne Libraries | ❌ Optional |
| `executables` | Ausführbare Programme | ❌ Optional |
| `apps` | App-Container (Core-Lib + Runner + Tests), siehe [App_Creation_Guide](App_Creation_Guide.md) | ❌ Optional |
| `tests` | Test-Executables | ❌ Optional |

### 5.3 Settings-Abschnitt

```json
"settings": {
    "standards": {
        "cxx_standard": 20,
        "c_standard": 17
    },
    "defaults": {
        "library_type": "STATIC",
        "executable_type": "CONSOLE"
    },
    "sources": {
        "mode": "explicit"
    }
}
```

`sources.mode`: `explicit` (Vorgabe — `Source.cmake` ist Pflicht), `auto` (`Source.cmake`, wenn
sie Dateien einträgt, sonst alle Dateien des Verzeichnisses) oder `glob` (immer alle Dateien).
Die Ausgabeverzeichnisse sind fest (§4.1) und lassen sich in der Solution.json nicht einstellen.

### 5.4 Reihenfolge der Verarbeitung

```
1. settings      → Globale Einstellungen
2. externals     → Externe Bibliotheken laden
3. libraries     → Interne Libraries erstellen
4. executables   → Executables erstellen (können Libraries nutzen)
5. apps          → App-Container erstellen
6. packages      → Paket-Ziele anlegen
7. tests         → Tests erstellen (nur mit BUILD_TESTS=ON)
```

**Wichtig:** Die Abschnitte laufen in dieser Reihenfolge, gleich wo sie in der Datei stehen.
Innerhalb von `libraries` zählt dagegen die Reihenfolge der Einträge: Eine Library muss **nach**
den Libraries stehen, von denen sie abhängt (sonst E101).

---

## 6. Erstes Executable erstellen

### 6.1 Workflow

```
1. Solution.json Eintrag erstellen  ← IMMER ZUERST!
2. CMake konfigurieren
3. Dateien anlegen
4. Bauen und testen
```

### 6.2 Solution.json Eintrag

```json
{
    "executables": [
        {
            "name": "MyApp",
            "displayName": "My Application",
            "version": "1.0.0",
            "type": "CONSOLE"
        }
    ]
}
```

### 6.3 Executable-Typen

| Typ | Beschreibung | Windows-Subsystem |
|-----|--------------|-------------------|
| `CONSOLE` | Konsolen-Anwendung | CONSOLE |
| `GUI` | Grafische Anwendung (kein Konsolenfenster) | WINDOWS |

`CLI`, `HEADLESS` und `WORKER` werden wie `CONSOLE` gebaut.

### 6.4 Vollständige Konfiguration

```json
{
    "name": "MyApp",
    "displayName": "My Application",
    "version": "1.0.0",
    "type": "CONSOLE",
    "path": "projects/exec/MyApp/src",
    "dependencies": ["CoreLib", "UtilLib"],
    "externals": ["spdlog", "bass"],
    "defines": ["APP_VERSION=\"1.0.0\""],
    "compile_options": ["-Wall"]
}
```

### 6.5 Felder-Referenz

| Feld | Typ | Default | Beschreibung |
|------|-----|---------|--------------|
| `name` | string | **Pflicht** | Target-Name |
| `displayName` | string | `name` | Anzeigename |
| `version` | string | Version der Solution | Semantic Version |
| `type` | string | `"CONSOLE"` (oder `settings.defaults.executable_type`) | CONSOLE oder GUI |
| `path` | string | Convention | Source-Verzeichnis |
| `dependencies` | string[] | `[]` | Interne Libraries |
| `externals` | string[] | `[]` | Externe Libraries |

### 6.6 Source-Dateien

Erstelle die Source-Dateien im angegebenen Pfad:

**main.cpp:**
```cpp
#include <iostream>

int main(int argc, char* argv[]) {
    std::cout << "Hello from MyApp!" << std::endl;
    return 0;
}
```

**Source.cmake** (im selben Verzeichnis):
```cmake
list(APPEND ${TARGET_NAME}_SOURCES "${CMAKE_CURRENT_LIST_DIR}/main.cpp")
```

Die Quellen sind **explizit**: Jede neue Datei kommt in die `Source.cmake` (`list(APPEND …)`, nie
globben); fehlt die Datei, bricht das Konfigurieren mit E104 ab. Format und Vorlagen:
[templates/README.md](../../../../templates/README.md). Nur mit `settings.sources.mode` `auto` oder
`glob` sammelt das Build-System die Dateien des Verzeichnisses selbst.

---

## 7. Erste Library erstellen

### 7.1 Solution.json Eintrag

```json
{
    "libraries": [
        {
            "name": "CoreLib",
            "version": "1.0.0",
            "type": "STATIC"
        }
    ]
}
```

### 7.2 Library-Typen

| Typ | Beschreibung | Wann verwenden? |
|-----|--------------|-----------------|
| `STATIC` | Statisch gelinkt (.lib/.a) | Standard, einfachste Option |
| `SHARED` | Dynamisch gelinkt (.dll/.so) | Wenn mehrere Programme teilen |
| `INTERFACE` | Header-only | Keine .cpp Dateien |

### 7.3 Vollständige Konfiguration

```json
{
    "name": "CoreLib",
    "displayName": "Core Library",
    "version": "1.0.0",
    "type": "STATIC",
    "path": "projects/libs/CoreLib/src",
    "public_headers": "projects/libs/CoreLib/include",
    "dependencies": [],
    "externals": []
}
```

### 7.4 Verzeichnisstruktur

```
projects/libs/CoreLib/
├── include/
│   └── CoreLib/
│       └── Calculator.h
└── src/
    ├── Source.cmake
    └── Calculator.cpp
```

### 7.5 Header-Datei

**include/CoreLib/Calculator.h:**
```cpp
#pragma once

namespace CoreLib {

class Calculator {
public:
    int add(int a, int b) const;
    int subtract(int a, int b) const;
    int multiply(int a, int b) const;
    double divide(int a, int b) const;
};

} // namespace CoreLib
```

### 7.6 Implementation

**src/Calculator.cpp:**
```cpp
#include "CoreLib/Calculator.h"
#include <stdexcept>

namespace CoreLib {

int Calculator::add(int a, int b) const {
    return a + b;
}

int Calculator::subtract(int a, int b) const {
    return a - b;
}

int Calculator::multiply(int a, int b) const {
    return a * b;
}

double Calculator::divide(int a, int b) const {
    if (b == 0) {
        throw std::domain_error("Division by zero");
    }
    return static_cast<double>(a) / b;
}

} // namespace CoreLib
```

Dazu `src/Source.cmake`:
```cmake
list(APPEND ${TARGET_NAME}_SOURCES "${CMAKE_CURRENT_LIST_DIR}/Calculator.cpp")
```

### 7.7 Library in Executable verwenden

```json
{
    "executables": [
        {
            "name": "Calculator",
            "dependencies": ["CoreLib"]
        }
    ]
}
```

**main.cpp:**
```cpp
#include <iostream>
#include "CoreLib/Calculator.h"

int main() {
    CoreLib::Calculator calc;
    std::cout << "2 + 3 = " << calc.add(2, 3) << std::endl;
    return 0;
}
```

---

## 8. Build-Befehle

### 8.1 CMake Presets verwenden

```bash
# Verfügbare Presets anzeigen
cmake --list-presets

# Konfigurieren
cmake --preset windows-ninja-debug-msvc

# Bauen
cmake --build out/build/windows-ninja-debug-msvc

# Oder mit Preset
cmake --build --preset build-ninja-debug-msvc
```

### 8.2 Häufige Presets

| Preset | Plattform | Compiler | Build-Type |
|--------|-----------|----------|------------|
| `windows-ninja-debug-msvc` | Windows | MSVC | Debug |
| `windows-ninja-release-msvc` | Windows | MSVC | Release |
| `windows-ninja-debug-clang` | Windows | Clang | Debug |
| `windows-ninja-testing-msvc` | Windows | MSVC | Testing |
| `linux-gcc-debug` | Linux | GCC | Debug |
| `linux-clang-debug` | Linux | Clang | Debug |
| `macos-ninja-debug` | macOS | Clang | Debug |

Alle Presets: `cmake --list-presets` oder [CMakePresets.md](../references/CMakePresets.md).

### 8.3 Einzelnes Target bauen

```bash
# Nur bestimmtes Target
cmake --build out/build/windows-ninja-debug-msvc --target MyApp

# Nur ein Test-Target (Name wie in Solution.json)
cmake --build out/build/windows-ninja-debug-msvc --target CoreLib_Tests
```

### 8.4 Clean Build

```bash
# Cache löschen und neu konfigurieren
cmake --preset windows-ninja-debug-msvc --fresh

# Build-Verzeichnis löschen
rm -rf out/build/windows-ninja-debug-msvc
cmake --preset windows-ninja-debug-msvc
```

### 8.5 Parallel bauen

```bash
# Mit 8 Jobs
cmake --build out/build/windows-ninja-debug-msvc -j8

# Alle CPUs
cmake --build out/build/windows-ninja-debug-msvc -j
```

---

## 9. Externals verwenden

### 9.1 Lokales External

```json
{
    "externals": {
        "doctest": {
            "path": "externals/doctest"
        }
    },
    "executables": [
        {
            "name": "MyApp",
            "externals": ["doctest"]
        }
    ]
}
```

### 9.2 Git External

```json
{
    "externals": {
        "spdlog": {
            "git": "https://github.com/gabime/spdlog.git",
            "tag": "v1.12.0"
        }
    }
}
```

### 9.3 Verwendung im Code

```cpp
#include <spdlog/spdlog.h>

int main() {
    spdlog::info("Hello from spdlog!");
    return 0;
}
```

Mehr Details: → [Externals UserGuide](Externals.md)

---

## 10. Tests hinzufügen

### 10.1 Solution.json Eintrag

```json
{
    "externals": {
        "doctest": { "path": "externals/doctest" }
    },
    "tests": [
        {
            "name": "CoreLib_Tests",
            "type": "unit",
            "framework": "doctest",
            "dependencies": ["CoreLib"],
            "externals": ["doctest"]
        }
    ]
}
```

### 10.2 Test-Datei

**projects/tests/unit/CoreLib_Tests/src/test_main.cpp:**
```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest/doctest.h>
#include "CoreLib/Calculator.h"

TEST_CASE("Calculator::add") {
    CoreLib::Calculator calc;
    CHECK(calc.add(2, 3) == 5);
    CHECK(calc.add(-1, 1) == 0);
}
```

Dazu `src/Source.cmake` mit `list(APPEND ${TARGET_NAME}_SOURCES "${CMAKE_CURRENT_LIST_DIR}/test_main.cpp")`.

### 10.3 Tests ausführen

```bash
# Mit Tests bauen (die Ninja-Presets setzen BUILD_TESTS bereits auf ON)
cmake --preset windows-ninja-debug-msvc -DBUILD_TESTS=ON
cmake --build out/build/windows-ninja-debug-msvc

# Tests ausführen
ctest --test-dir out/build/windows-ninja-debug-msvc
```

Mehr Details: → [Testing UserGuide](Testing.md)

---

## 11. Workflow-Zusammenfassung

### Der goldene Workflow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Solution.json Eintrag erstellen       ← IMMER ZUERST!   │
│    └─ Name, Version, Typ definieren                        │
├─────────────────────────────────────────────────────────────┤
│ 2. CMake konfigurieren                                      │
│    └─ cmake --preset windows-ninja-debug-msvc              │
├─────────────────────────────────────────────────────────────┤
│ 3. Dateien anlegen                                          │
│    └─ main.cpp / Header / Source                           │
├─────────────────────────────────────────────────────────────┤
│ 4. Bauen                                                    │
│    └─ cmake --build out/build/windows-ninja-debug-msvc     │
├─────────────────────────────────────────────────────────────┤
│ 5. Testen                                                   │
│    └─ Programm ausführen / ctest                           │
└─────────────────────────────────────────────────────────────┘
```

### Checkliste: Neues Modul hinzufügen

- [ ] Solution.json Eintrag schreiben
- [ ] CMake konfigurieren / generieren
- [ ] Dateien anlegen (src/, include/) und in `Source.cmake` eintragen
- [ ] Bauen und Fehler beheben
- [ ] Dokumentation erstellen
- [ ] Changelog aktualisieren

### Reihenfolge bei Dependencies

```json
{
    "libraries": [
        { "name": "BaseLib" },           // 1. Keine Abhängigkeiten
        { "name": "MiddleLib", "dependencies": ["BaseLib"] },  // 2.
        { "name": "TopLib", "dependencies": ["MiddleLib"] }    // 3.
    ],
    "executables": [
        { "name": "App", "dependencies": ["TopLib"] }  // 4. Nutzt alles
    ]
}
```

---

## 12. Stolpersteine und Lösungen

### 12.1 "Target existiert nicht"

**Problem:**
```
[E101] Dependency 'MyLib' for 'MyApp' does not exist
```

**Ursache:** Library nicht in Solution.json definiert, Schreibfehler, oder eine Library steht im
`libraries`-Array vor der Library, von der sie abhängt.

**Lösung:**
1. Prüfe ob Library in `libraries` Array existiert
2. Prüfe Schreibweise (case-sensitive!)
3. Hängt eine Library von einer anderen ab: sie im `libraries`-Array **nach** ihrer Abhängigkeit eintragen

### 12.2 "Source-Dateien nicht gefunden"

**Problem:**
```
[E001] Executable 'MyApp': Source path does not exist: projects/exec/MyApp/src
[E104] Source.cmake not found: /path/to/MyProject/projects/exec/MyApp/src/Source.cmake
```

**Ursache:** Das Quellverzeichnis fehlt (E001), oder ihm fehlt die `Source.cmake` mit der
Dateiliste (E104, Vorgabe `sources.mode = "explicit"`). Trägt die `Source.cmake` keine
kompilierbare Datei ein, warnt das Build-System mit W101.

**Lösung:**
1. Verzeichnis erstellen: `mkdir -p projects/exec/MyApp/src`
2. main.cpp und `Source.cmake` anlegen (§6.6)
3. Oder expliziten `path` in Solution.json angeben

### 12.3 "Include-Pfad nicht gefunden"

**Problem:**
```
fatal error: 'CoreLib/Calculator.h' file not found
```

**Ursache:** Library nicht in `dependencies` aufgeführt.

**Lösung:**
```json
{
    "name": "MyApp",
    "dependencies": ["CoreLib"]  // ← Hinzufügen!
}
```

### 12.4 "CMake-Cache veraltet"

**Problem:** Änderungen in Solution.json werden nicht übernommen.

**Ursache:** CMake-Cache enthält alte Konfiguration.

**Lösung:**
```bash
# Cache neu generieren
cmake --preset windows-ninja-debug-msvc --fresh
```

### 12.5 "Preset nicht gefunden"

**Problem:**
```
CMake Error: Could not read presets: No such preset: "my-preset"
```

**Ursache:** Preset existiert nicht oder JSON-Syntaxfehler.

**Lösung:**
```bash
# Verfügbare Presets anzeigen
cmake --list-presets

# JSON-Syntax prüfen
cat CMakePresets.json | python -m json.tool
```

---

## 13. Troubleshooting

### Checkliste bei Build-Problemen

1. ☐ Solution.json Syntax korrekt? (JSON validieren)
2. ☐ Alle Dependencies definiert?
3. ☐ Pfade existieren?
4. ☐ CMake-Cache aktuell? (`--fresh`)
5. ☐ Compiler installiert und im PATH?
6. ☐ Preset existiert? (`--list-presets`)

### Häufige Fehler

| Fehler | Ursache | Lösung |
|--------|---------|--------|
| "[E101] Dependency … does not exist" | Dependency fehlt oder steht zu spät | Zu `libraries` hinzufügen, Reihenfolge prüfen |
| "[E104] Source.cmake not found" | Dateiliste fehlt | `Source.cmake` anlegen (§6.6) |
| "[W101] … No source files found" / "defines no compilable files" | Dateiliste leer | Dateien in `Source.cmake` eintragen |
| "file not found" | Include fehlt | `dependencies` prüfen |
| "undefined reference" | Linking-Fehler | `dependencies` oder `externals` |
| "Preset not found" | Tippfehler | `--list-presets` |

### Debug-Tipps

```bash
# Verbose CMake-Output
cmake --preset ... --debug-output

# Mehr Meldungen des Build-Systems (Stufe 1–5, Vorgabe 2; Bereiche mit eigener Stufe wie Externals bleiben bei 3)
cmake --preset ... -DDEBUG_DEFAULT_LEVEL=3

# CMake-Variablen anzeigen
cmake -LAH out/build/windows-ninja-debug-msvc

# Generierte Targets anzeigen
cmake --build out/build/... --target help
```

---

## 14. Nächste Schritte

### Du hast die Grundlagen gemeistert! Weiter geht's mit:

| Thema | Guide | Was du lernst |
|-------|-------|---------------|
| **Externe Bibliotheken** | [Externals UserGuide](Externals.md) | BASS, ImGui, spdlog einbinden |
| **Neue Externals hinzufügen** | [Adding_Externals UserGuide](Adding_Externals.md) | Eigene Hooks schreiben |
| **Testing** | [Testing UserGuide](Testing.md) | doctest, GoogleTest, Catch2 |
| **Qt6** | [Qt6_Integration UserGuide](Qt6_Integration.md) | Qt6 GUI-Anwendungen |
| **User Presets** | [CMakeUserPresets UserGuide](CMakeUserPresets.md) | Persönliche Build-Konfiguration |

### Fortgeschrittene Themen

- **Multi-Plattform-Builds** – Windows, Linux, macOS gleichzeitig
- **CI/CD-Integration** – GitHub Actions, GitLab CI
- **Code-Qualität** – clang-format, clang-tidy
- **Packaging** – Installer erstellen mit CPack

---

## 15. Siehe auch

- [Solution_Schema.md](../references/Solution_Schema.md) – Vollständige JSON-Schema-Referenz
- [Externals.md](../references/Externals.md) – Alle verfügbaren Externals
- [ErrorCodes.md](../references/ErrorCodes.md) – Fehlercodes und Lösungen
- [CMakePresets_Reference.md](../references/CMakePresets.md) – Preset-Referenz

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| 1.0.1 | 2026-11-09 | An den Code angeglichen: Bezug über `templates/consumer/` und `cmakecraft.pin` (§3.1, §4), `CMakeLists.txt` als Dünnfassung mit Pflichtzeile `project(<Name> LANGUAGES NONE)`, `schemaVersion` `1.0`, Standardpfade `projects/exec/…` und `projects/libs/…`, `Source.cmake` (explizite Quellen), Ausgabepfad `exec/<Name>/bin/<Config>/`, vorhandene Presets, Fehlermeldungen E001/E101/E104 statt `[E0401]`, `settings.output` und `all_tests` entfernt |
| 1.0.0 | 2025-12-26 | Release 1 (aus newCMake übernommen, `2e00db7`) |
| **0.5.0** | **2025-12-14** | **Initial: Umfassender Einstiegs-Guide für CMake Architecture** |
