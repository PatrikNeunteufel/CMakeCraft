# Test-Pipeline – Konzept

> **Version:** 0.1.0  
> **Datum:** 2025-12-11  
> **Typ:** Konzept-Doku  
> **Status:** Entwurf  
> **Phase:** 7

---

## 1. Überblick

Die Test-Pipeline ermöglicht das Definieren und Ausführen von Tests für Projektcode (Module, Libraries). Tests werden in `Solution.json` deklariert und folgen dem gleichen Pattern wie Executables und Libraries.

### Abgrenzung

| Test-Art | Zweck | Ort | Aktivierung |
|----------|-------|-----|-------------|
| **Build-System-Tests** | CMake-Module testen | `cmake/buildSystemTest/` | `RUN_BUILD_SYSTEM_TESTS=ON` |
| **Projekt-Tests** | Anwendungscode testen | `projects/tests/` | `BUILD_TESTS=ON` |

Dieses Konzept beschreibt die **Projekt-Tests**.

---

## 2. Projektstruktur

```
projects/
├── demos/
│   ├── exec/
│   │   └── MyApp/
│   └── libs/
│       └── CoreLib/
└── tests/
    ├── unit/
    │   ├── CoreLib_Tests/
    │   │   └── src/
    │   │       ├── test_main.cpp
    │   │       ├── test_StringUtils.cpp
    │   │       └── test_MathUtils.cpp
    │   └── AudioEngine_Tests/
    │       └── src/
    │           └── test_AudioBuffer.cpp
    ├── integration/
    │   └── AudioPipeline_Tests/
    │       └── src/
    │           └── test_full_pipeline.cpp
    └── performance/
        └── Benchmarks/
            └── src/
                └── bench_sorting.cpp
```

---

## 3. Solution.json Schema

### 3.1 tests Array

```json
{
    "tests": [
        {
            "name": "CoreLib_Tests",
            "displayName": "CoreLib Unit Tests",
            "version": "1.0.0",
            "type": "unit",
            "framework": "doctest",
            "path": "projects/tests/unit/CoreLib_Tests/src",
            "target": "CoreLib",
            "dependencies": ["CoreLib"],
            "externals": ["doctest"],
            "timeout": 30,
            "labels": ["unit", "core", "fast"],
            "parallel": true
        }
    ]
}
```

### 3.2 Feld-Definitionen

#### Pflichtfelder

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `name` | string | Eindeutiger Test-Target-Name |

#### Optionale Felder

| Feld | Typ | Default | Beschreibung |
|------|-----|---------|--------------|
| `displayName` | string | `name` | Anzeigename |
| `version` | string | Solution-Version | Test-Version |
| `type` | string | `"unit"` | Test-Typ (siehe 3.3) |
| `framework` | string | `"doctest"` | Test-Framework (siehe 3.4) |
| `path` | string | Convention | Source-Verzeichnis |
| `target` | string | - | Zu testendes Target (für Coverage) |
| `dependencies` | string[] | `[]` | Interne Libraries |
| `externals` | string[] | `[]` | Externe Libraries |
| `timeout` | int | 60 | Timeout in Sekunden |
| `labels` | string[] | `[type]` | CTest Labels |
| `parallel` | bool | true | Parallel ausführbar |
| `skip` | bool | false | Test überspringen |
| `platforms` | string[] | alle | Plattform-Filter |

### 3.3 Test-Typen

| Typ | Beschreibung | Typische Labels |
|-----|--------------|-----------------|
| `unit` | Einzelne Funktionen/Klassen | `fast`, `isolated` |
| `integration` | Komponenten-Zusammenspiel | `slow`, `database` |
| `system` | Gesamtsystem | `e2e`, `slow` |
| `performance` | Benchmarks | `benchmark`, `slow` |
| `smoke` | Schnelle Basis-Tests | `fast`, `critical` |

### 3.4 Unterstützte Frameworks

| Framework | Beschreibung | Empfohlen für |
|-----------|--------------|---------------|
| `doctest` | Schnell, Header-only | Unit Tests, CI |
| `googletest` | Feature-reich, Mocking | Große Projekte, Mocking |
| `catch2` | BDD-Style, Sections | Lesbare Tests, BDD |

---

## 4. Path Convention

Wenn `path` nicht angegeben:

```
projects/tests/{type}/{name}/src
```

**Beispiele:**

| name | type | Resultat |
|------|------|----------|
| `CoreLib_Tests` | `unit` | `projects/tests/unit/CoreLib_Tests/src` |
| `AudioPipeline_Tests` | `integration` | `projects/tests/integration/AudioPipeline_Tests/src` |
| `Benchmarks` | `performance` | `projects/tests/performance/Benchmarks/src` |

---

## 5. Framework-Integration

### 5.1 doctest (Default)

**Vorteile:**
- Extrem schnelle Kompilierung
- Header-only
- Keine externe Abhängigkeit (lokales External)
- Gute IDE-Integration

**main.cpp:**
```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest/doctest.h>
```

**Test-Datei:**
```cpp
#include <doctest/doctest.h>
#include "CoreLib/StringUtils.h"

TEST_CASE("StringUtils::trim") {
    CHECK(StringUtils::trim("  hello  ") == "hello");
    CHECK(StringUtils::trim("") == "");
}

TEST_CASE("StringUtils::split") {
    auto parts = StringUtils::split("a,b,c", ',');
    REQUIRE(parts.size() == 3);
    CHECK(parts[0] == "a");
}
```

### 5.2 GoogleTest

**Vorteile:**
- Mocking (GMock)
- Parametrisierte Tests
- Death Tests
- Typed Tests

**Wann verwenden:**
- Mocking benötigt
- Komplexe Test-Fixtures
- Parametrisierte Tests

**main.cpp:**
```cpp
#include <gtest/gtest.h>

int main(int argc, char** argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
```

**Test-Datei:**
```cpp
#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "CoreLib/Database.h"

class MockDatabase : public IDatabase {
public:
    MOCK_METHOD(bool, connect, (), (override));
    MOCK_METHOD(Result, query, (const std::string&), (override));
};

TEST(DatabaseTest, ConnectRetry) {
    MockDatabase db;
    EXPECT_CALL(db, connect())
        .WillOnce(testing::Return(false))
        .WillOnce(testing::Return(true));
    
    EXPECT_TRUE(db.connectWithRetry(2));
}
```

### 5.3 Catch2

**Vorteile:**
- BDD-Style (SCENARIO/GIVEN/WHEN/THEN)
- Sections (Test-Teile wiederverwenden)
- Integrierte Benchmarks
- Sehr lesbare Syntax

**Wann verwenden:**
- BDD gewünscht
- Komplexe Setup-Szenarien
- Integrierte Benchmarks

**main.cpp:**
```cpp
#define CATCH_CONFIG_MAIN
#include <catch2/catch_all.hpp>
```

**Test-Datei:**
```cpp
#include <catch2/catch_all.hpp>
#include "CoreLib/Calculator.h"

SCENARIO("Calculator handles basic operations", "[calculator][unit]") {
    GIVEN("A calculator instance") {
        Calculator calc;
        
        WHEN("adding two numbers") {
            auto result = calc.add(2, 3);
            
            THEN("the result is correct") {
                REQUIRE(result == 5);
            }
        }
        
        WHEN("dividing by zero") {
            THEN("an exception is thrown") {
                REQUIRE_THROWS_AS(calc.divide(1, 0), std::domain_error);
            }
        }
    }
}
```

---

## 6. CMake-Module

### 6.1 Modul-Übersicht

| Modul | Beschreibung |
|-------|--------------|
| `Tests.cmake` | Hauptschleife über tests Array |
| `TestCollect.cmake` | JSON → Context |
| `TestCreate.cmake` | Test-Target erstellen |
| `TestFrameworks.cmake` | Framework-spezifische Konfiguration |

### 6.2 Pipeline

```
1. Tests.cmake: tests Array iterieren
2. BUILD_TESTS prüfen
3. TestCollect: JSON parsen, Context erstellen
4. Platform-Filter prüfen
5. skip prüfen
6. TestCreate: Target erstellen
   a. add_executable()
   b. Framework-External linken
   c. Dependencies linken
   d. CTest registrieren
   e. Labels setzen
   f. Timeout konfigurieren
```

### 6.3 CTest-Integration

```cmake
# In TestCreate.cmake

# Test zu CTest hinzufügen
add_test(
    NAME ${_name}
    COMMAND ${_name}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

# Timeout setzen
set_tests_properties(${_name} PROPERTIES
    TIMEOUT ${_timeout}
)

# Labels setzen
set_tests_properties(${_name} PROPERTIES
    LABELS "${_labels}"
)

# Parallele Ausführung
if(NOT _parallel)
    set_tests_properties(${_name} PROPERTIES
        RUN_SERIAL TRUE
    )
endif()
```

---

## 7. Ausführung

### 7.1 Alle Tests

```bash
# Konfigurieren mit Tests
cmake --preset windows-ninja-debug -DBUILD_TESTS=ON

# Bauen
cmake --build out/build/windows-ninja-debug

# Tests ausführen
ctest --test-dir out/build/windows-ninja-debug
```

### 7.2 Gefiltert nach Label

```bash
# Nur Unit Tests
ctest -L unit

# Nur schnelle Tests
ctest -L fast

# Keine langsamen Tests
ctest -LE slow
```

### 7.3 Gefiltert nach Name

```bash
# Bestimmter Test
ctest -R CoreLib_Tests

# Pattern
ctest -R ".*Audio.*"
```

### 7.4 Parallel

```bash
# Mit 8 Jobs
ctest -j8

# Alle CPUs
ctest -j$(nproc)
```

### 7.5 Verbose

```bash
# Ausgabe bei Fehlern
ctest --output-on-failure

# Immer verbose
ctest -V
```

---

## 8. Beispiel Solution.json

```json
{
    "schemaVersion": "0.1",
    "solution": {
        "name": "MyProject",
        "version": "1.0.0"
    },
    "externals": {
        "doctest": {
            "path": "externals/doctest"
        },
        "googletest": {
            "git": "https://github.com/google/googletest.git",
            "tag": "v1.14.0"
        },
        "catch2": {
            "git": "https://github.com/catchorg/Catch2.git",
            "tag": "v3.5.2"
        }
    },
    "libraries": [
        {
            "name": "CoreLib",
            "type": "STATIC",
            "path": "projects/libs/CoreLib/src",
            "public_headers": "projects/libs/CoreLib/include"
        },
        {
            "name": "AudioEngine",
            "type": "STATIC",
            "path": "projects/libs/AudioEngine/src",
            "public_headers": "projects/libs/AudioEngine/include",
            "dependencies": ["CoreLib"]
        }
    ],
    "executables": [
        {
            "name": "MyApp",
            "type": "GUI",
            "path": "projects/apps/MyApp/src",
            "dependencies": ["CoreLib", "AudioEngine"]
        }
    ],
    "tests": [
        {
            "name": "CoreLib_UnitTests",
            "displayName": "CoreLib Unit Tests",
            "type": "unit",
            "framework": "doctest",
            "path": "projects/tests/unit/CoreLib_Tests/src",
            "dependencies": ["CoreLib"],
            "externals": ["doctest"],
            "labels": ["unit", "core", "fast"],
            "timeout": 30
        },
        {
            "name": "AudioEngine_UnitTests",
            "displayName": "AudioEngine Unit Tests",
            "type": "unit",
            "framework": "googletest",
            "path": "projects/tests/unit/AudioEngine_Tests/src",
            "dependencies": ["AudioEngine"],
            "externals": ["googletest"],
            "labels": ["unit", "audio", "fast"],
            "timeout": 60
        },
        {
            "name": "AudioPipeline_IntegrationTests",
            "displayName": "Audio Pipeline Integration",
            "type": "integration",
            "framework": "catch2",
            "path": "projects/tests/integration/AudioPipeline_Tests/src",
            "dependencies": ["CoreLib", "AudioEngine"],
            "externals": ["catch2", "bass"],
            "external_options": {
                "bass": { "BASS_FLAC": true }
            },
            "labels": ["integration", "audio", "slow"],
            "timeout": 120,
            "parallel": false
        },
        {
            "name": "Performance_Benchmarks",
            "displayName": "Performance Benchmarks",
            "type": "performance",
            "framework": "catch2",
            "path": "projects/tests/performance/Benchmarks/src",
            "dependencies": ["CoreLib"],
            "externals": ["catch2"],
            "labels": ["benchmark", "slow"],
            "timeout": 300,
            "parallel": false
        }
    ]
}
```

---

## 9. Framework-Empfehlungen

### Wann welches Framework?

| Szenario | Empfehlung | Begründung |
|----------|------------|------------|
| **Schnelle Unit Tests** | doctest | Schnellste Kompilierung |
| **CI/CD Pipeline** | doctest | Minimale Abhängigkeiten |
| **Mocking benötigt** | GoogleTest | GMock integriert |
| **Parametrisierte Tests** | GoogleTest | Beste Unterstützung |
| **BDD-Style gewünscht** | Catch2 | SCENARIO/GIVEN/WHEN/THEN |
| **Integrierte Benchmarks** | Catch2 | BENCHMARK Makro |
| **Komplexe Fixtures** | GoogleTest | SetUp/TearDown Klassen |
| **Header-only gewünscht** | doctest | Kein Linken nötig |

### Framework-Feature-Matrix

| Feature | doctest | GoogleTest | Catch2 |
|---------|---------|------------|--------|
| Kompilierzeit | ⭐⭐⭐ | ⭐ | ⭐⭐ |
| Header-only | ✅ | ❌ | ❌ (v3) |
| Mocking | ❌ | ✅ (GMock) | ❌ |
| BDD-Style | ❌ | ❌ | ✅ |
| Sections | ❌ | ❌ | ✅ |
| Benchmarks | ❌ | ❌ | ✅ |
| Parametrisiert | ⭐ | ⭐⭐⭐ | ⭐⭐ |
| Death Tests | ❌ | ✅ | ❌ |
| Matchers | ⭐ | ⭐⭐⭐ | ⭐⭐⭐ |

---

## 10. Nächste Schritte

### Phase 7 Implementation

1. **Solution Schema erweitern** (tests Array)
2. **Tests.cmake** - Hauptmodul
3. **TestCollect.cmake** - JSON → Context
4. **TestCreate.cmake** - Target erstellen
5. **TestFrameworks.cmake** - Framework-spezifisch
6. **PreFetch Hooks** - GoogleTest, Catch2 (bereits erstellt)
7. **UserGuide** - Framework-Vergleich, Best Practices
8. **Beispiel-Tests** - CoreLib_Tests als Template

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-11** | **Initial: Konzept für Test-Pipeline** |
