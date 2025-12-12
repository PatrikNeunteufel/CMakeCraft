# Testing – Benutzerhandbuch

> **Version:** 0.1.0  
> **Datum:** 2025-12-11  
> **Typ:** Benutzer-Doku  
> **Status:** Stabil  
> **Module:** Tests.cmake, TestCollect.cmake, TestCreate.cmake

---

## Inhaltsverzeichnis

1. [Überblick](#1-überblick)
2. [Schnellstart](#2-schnellstart)
3. [Test-Typen](#3-test-typen)
4. [Framework-Vergleich](#4-framework-vergleich)
5. [Projektstruktur](#5-projektstruktur)
6. [Solution.json Konfiguration](#6-solutionjson-konfiguration)
7. [Tests schreiben](#7-tests-schreiben)
8. [Tests ausführen](#8-tests-ausführen)
9. [Best Practices](#9-best-practices)
10. [Troubleshooting](#10-troubleshooting)

---

## 1. Überblick

Das Test-System ermöglicht das Definieren und Ausführen von Tests für Projektcode. Tests werden wie Executables und Libraries in `Solution.json` konfiguriert.

### Abgrenzung

| Test-Art | Zweck | Aktivierung |
|----------|-------|-------------|
| **Projekt-Tests** | Anwendungscode testen | `BUILD_TESTS=ON` |
| **Build-System-Tests** | CMake-Module testen | `RUN_BUILD_SYSTEM_TESTS=ON` |

Dieses Handbuch behandelt **Projekt-Tests**.

### Features

- Deklarative Konfiguration via Solution.json
- Mehrere Test-Frameworks (doctest, GoogleTest, Catch2)
- Test-Typen (Unit, Integration, Performance, etc.)
- CTest-Integration (Labels, Timeout, Parallel)
- Automatische Framework-Verlinkung

---

## 2. Schnellstart

### 2.1 Solution.json erweitern

```json
{
    "externals": {
        "doctest": {
            "path": "externals/doctest"
        }
    },
    "tests": [
        {
            "name": "MyLib_Tests",
            "type": "unit",
            "framework": "doctest",
            "dependencies": ["MyLib"],
            "externals": ["doctest"]
        }
    ]
}
```

### 2.2 Test-Datei erstellen

`projects/tests/unit/MyLib_Tests/src/test_main.cpp`:

```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest/doctest.h>
#include "MyLib/Calculator.h"

TEST_CASE("Calculator add") {
    Calculator calc;
    CHECK(calc.add(2, 3) == 5);
    CHECK(calc.add(-1, 1) == 0);
}
```

### 2.3 Build und Run

```bash
# Konfigurieren mit Tests
cmake --preset windows-ninja-debug -DBUILD_TESTS=ON

# Bauen
cmake --build out/build/windows-ninja-debug

# Tests ausführen
ctest --test-dir out/build/windows-ninja-debug
```

---

## 3. Test-Typen

| Typ | Beschreibung | Scope | Dauer |
|-----|--------------|-------|-------|
| `unit` | Einzelne Funktionen/Klassen | Isoliert | Schnell |
| `integration` | Komponenten-Zusammenspiel | Mehrere Module | Mittel |
| `system` | Gesamtsystem (End-to-End) | Vollständig | Langsam |
| `performance` | Benchmarks | Performance | Variabel |
| `smoke` | Basis-Funktionalität | Kritische Pfade | Sehr schnell |

### Empfehlungen

| Typ | Wann verwenden |
|-----|----------------|
| **unit** | Für jede Klasse/Funktion |
| **integration** | Nach Unit Tests, vor Release |
| **system** | CI/CD Pipeline, Release-Tests |
| **performance** | Regressions-Tracking, Optimierung |
| **smoke** | Schnelle Validierung nach Build |

---

## 4. Framework-Vergleich

### 4.1 Übersicht

| Framework | Stärken | Schwächen |
|-----------|---------|-----------|
| **doctest** | Schnellste Kompilierung, Header-only | Kein Mocking |
| **GoogleTest** | Mocking, Feature-reich | Langsame Kompilierung |
| **Catch2** | BDD-Style, Sections, Benchmarks | Größere Binaries |

### 4.2 Entscheidungsbaum

```
Brauchst du Mocking?
├─ Ja → GoogleTest
└─ Nein
    ├─ BDD-Style gewünscht?
    │   ├─ Ja → Catch2
    │   └─ Nein
    │       ├─ Schnelle Kompilierung wichtig?
    │       │   ├─ Ja → doctest
    │       │   └─ Nein → Catch2 oder doctest
    │       └─ Benchmarks integriert?
    │           ├─ Ja → Catch2
    │           └─ Nein → doctest
    └─ Parametrisierte Tests?
        ├─ Ja → GoogleTest
        └─ Nein → doctest oder Catch2
```

### 4.3 Feature-Matrix

| Feature | doctest | GoogleTest | Catch2 |
|---------|:-------:|:----------:|:------:|
| Kompilierzeit | ⭐⭐⭐ | ⭐ | ⭐⭐ |
| Header-only | ✅ | ❌ | ❌ |
| Mocking | ❌ | ✅ | ❌ |
| BDD-Style | ❌ | ❌ | ✅ |
| Sections | ❌ | ❌ | ✅ |
| Benchmarks | ❌ | ❌ | ✅ |
| Parametrisiert | ⭐ | ⭐⭐⭐ | ⭐⭐ |
| Death Tests | ❌ | ✅ | ❌ |
| Matchers | ⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| Test Discovery | ✅ | ✅ | ✅ |

### 4.4 Wann welches Framework?

#### doctest (Default) – Empfohlen für:

- Unit Tests
- CI/CD (schnelle Builds)
- Header-only Libraries
- Einfache Test-Suites

#### GoogleTest – Empfohlen für:

- Mocking benötigt
- Komplexe Test-Fixtures
- Parametrisierte Tests mit vielen Varianten
- Death Tests (Crash-Verhalten)
- Große Projekte mit vielen Entwicklern

#### Catch2 – Empfohlen für:

- BDD-Style (SCENARIO/GIVEN/WHEN/THEN)
- Komplexe Setup-Szenarien (Sections)
- Integrierte Benchmarks
- Lesbare Test-Ausgabe

---

## 5. Projektstruktur

### Empfohlene Struktur

```
projects/
├── demos/
│   ├── exec/
│   │   └── MyApp/
│   └── libs/
│       └── CoreLib/
│           ├── include/
│           │   └── CoreLib/
│           │       └── Calculator.h
│           └── src/
│               └── Calculator.cpp
└── tests/
    ├── unit/
    │   └── CoreLib_Tests/
    │       └── src/
    │           ├── test_main.cpp
    │           └── test_Calculator.cpp
    ├── integration/
    │   └── Pipeline_Tests/
    │       └── src/
    │           └── test_pipeline.cpp
    └── performance/
        └── Benchmarks/
            └── src/
                └── bench_sorting.cpp
```

### Path Convention

Wenn `path` nicht angegeben:

```
projects/tests/{type}/{name}/src
```

---

## 6. Solution.json Konfiguration

### 6.1 Minimale Konfiguration

```json
"tests": [
    {
        "name": "MyLib_Tests"
    }
]
```

**Defaults:**
- `type`: `"unit"`
- `framework`: `"doctest"`
- `path`: `projects/tests/unit/MyLib_Tests/src`
- `timeout`: 60
- `parallel`: true

### 6.2 Vollständige Konfiguration

```json
"tests": [
    {
        "name": "CoreLib_UnitTests",
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
        "parallel": true,
        "skip": false,
        "platforms": ["windows", "linux", "macos"],
        "defines": ["TEST_MODE"],
        "compile_options": ["-Wno-unused-variable"]
    }
]
```

### 6.3 Feld-Referenz

| Feld | Typ | Default | Beschreibung |
|------|-----|---------|--------------|
| `name` | string | **Pflicht** | Test-Target-Name |
| `displayName` | string | `name` | Anzeigename (IDE) |
| `type` | string | `"unit"` | Test-Typ |
| `framework` | string | `"doctest"` | Test-Framework |
| `path` | string | Convention | Source-Verzeichnis |
| `target` | string | - | Getestetes Target |
| `dependencies` | string[] | `[]` | Interne Libraries |
| `externals` | string[] | `[]` | Externe Libraries |
| `timeout` | int | 60 | Timeout (Sekunden) |
| `labels` | string[] | `[type]` | CTest Labels |
| `parallel` | bool | true | Parallel ausführbar |
| `skip` | bool | false | Überspringen |

---

## 7. Tests schreiben

### 7.1 doctest

**test_main.cpp:**
```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest/doctest.h>
```

**test_Calculator.cpp:**
```cpp
#include <doctest/doctest.h>
#include "CoreLib/Calculator.h"

TEST_CASE("Calculator::add") {
    Calculator calc;
    
    SUBCASE("positive numbers") {
        CHECK(calc.add(2, 3) == 5);
        CHECK(calc.add(100, 200) == 300);
    }
    
    SUBCASE("negative numbers") {
        CHECK(calc.add(-1, -1) == -2);
        CHECK(calc.add(-5, 3) == -2);
    }
    
    SUBCASE("zero") {
        CHECK(calc.add(0, 0) == 0);
        CHECK(calc.add(5, 0) == 5);
    }
}

TEST_CASE("Calculator::divide") {
    Calculator calc;
    
    CHECK(calc.divide(10, 2) == 5);
    CHECK_THROWS_AS(calc.divide(1, 0), std::domain_error);
}
```

### 7.2 GoogleTest

**test_main.cpp:**
```cpp
#include <gtest/gtest.h>

int main(int argc, char** argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
```

**test_Calculator.cpp:**
```cpp
#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "CoreLib/Calculator.h"

class CalculatorTest : public ::testing::Test {
protected:
    Calculator calc;
};

TEST_F(CalculatorTest, AddPositive) {
    EXPECT_EQ(calc.add(2, 3), 5);
    EXPECT_EQ(calc.add(100, 200), 300);
}

TEST_F(CalculatorTest, AddNegative) {
    EXPECT_EQ(calc.add(-1, -1), -2);
}

TEST_F(CalculatorTest, DivideByZeroThrows) {
    EXPECT_THROW(calc.divide(1, 0), std::domain_error);
}

// Parametrisierter Test
class AddTest : public ::testing::TestWithParam<std::tuple<int, int, int>> {};

TEST_P(AddTest, ReturnsCorrectSum) {
    auto [a, b, expected] = GetParam();
    Calculator calc;
    EXPECT_EQ(calc.add(a, b), expected);
}

INSTANTIATE_TEST_SUITE_P(
    Additions,
    AddTest,
    ::testing::Values(
        std::make_tuple(1, 1, 2),
        std::make_tuple(2, 3, 5),
        std::make_tuple(-1, 1, 0)
    )
);
```

### 7.3 Catch2 (BDD-Style)

**test_main.cpp:**
```cpp
#define CATCH_CONFIG_MAIN
#include <catch2/catch_all.hpp>
```

**test_Calculator.cpp:**
```cpp
#include <catch2/catch_all.hpp>
#include "CoreLib/Calculator.h"

SCENARIO("Calculator handles basic operations", "[calculator][unit]") {
    GIVEN("A calculator instance") {
        Calculator calc;
        
        WHEN("adding positive numbers") {
            auto result = calc.add(2, 3);
            
            THEN("the result is correct") {
                REQUIRE(result == 5);
            }
        }
        
        WHEN("adding negative numbers") {
            auto result = calc.add(-1, -1);
            
            THEN("the result is negative") {
                REQUIRE(result == -2);
            }
        }
        
        WHEN("dividing by zero") {
            THEN("an exception is thrown") {
                REQUIRE_THROWS_AS(calc.divide(1, 0), std::domain_error);
            }
        }
    }
}

// Benchmarks (Catch2)
TEST_CASE("Sorting Benchmark", "[benchmark]") {
    std::vector<int> data(1000);
    std::iota(data.begin(), data.end(), 0);
    
    BENCHMARK("std::sort random") {
        std::shuffle(data.begin(), data.end(), std::mt19937{});
        std::sort(data.begin(), data.end());
        return data;
    };
}
```

---

## 8. Tests ausführen

### 8.1 Alle Tests

```bash
ctest --test-dir out/build/windows-ninja-debug
```

### 8.2 Nach Label filtern

```bash
# Nur Unit Tests
ctest -L unit

# Nur schnelle Tests
ctest -L fast

# Keine langsamen Tests
ctest -LE slow

# Kombiniert
ctest -L unit -L fast
```

### 8.3 Nach Name filtern

```bash
# Bestimmter Test
ctest -R CoreLib_Tests

# Pattern
ctest -R ".*Audio.*"

# Ausschließen
ctest -E ".*Benchmark.*"
```

### 8.4 Parallel

```bash
# Mit 8 Jobs
ctest -j8

# Alle CPUs
ctest -j$(nproc)    # Linux
ctest -j%NUMBER_OF_PROCESSORS%  # Windows
```

### 8.5 Verbose

```bash
# Ausgabe bei Fehlern
ctest --output-on-failure

# Immer verbose
ctest -V

# Extra verbose
ctest -VV
```

### 8.6 Kombiniert

```bash
# Unit Tests, parallel, verbose bei Fehler
ctest -L unit -j8 --output-on-failure
```

---

## 9. Best Practices

### 9.1 Testbenennung

```cpp
// ❌ Schlecht
TEST_CASE("Test1") { }
TEST_CASE("It works") { }

// ✅ Gut
TEST_CASE("Calculator::add returns sum of two integers") { }
TEST_CASE("Parser throws on invalid input") { }
```

### 9.2 Test-Isolation

```cpp
// ❌ Schlecht - globaler State
static int counter = 0;
TEST_CASE("First") { counter++; }
TEST_CASE("Second") { CHECK(counter == 1); }  // Hängt von Reihenfolge ab

// ✅ Gut - jeder Test ist unabhängig
TEST_CASE("Counter increments") {
    Counter c;
    c.increment();
    CHECK(c.value() == 1);
}
```

### 9.3 Arrange-Act-Assert

```cpp
TEST_CASE("User::setEmail validates format") {
    // Arrange
    User user;
    
    // Act
    bool result = user.setEmail("invalid-email");
    
    // Assert
    CHECK(result == false);
    CHECK(user.email().empty());
}
```

### 9.4 Labels sinnvoll nutzen

```json
"labels": ["unit", "database", "slow"]
```

```bash
# CI: Schnelle Tests zuerst
ctest -L fast
ctest -LE fast  # Dann der Rest
```

### 9.5 Timeouts setzen

```json
// Schnelle Unit Tests
"timeout": 10

// Integration Tests
"timeout": 60

// Performance Tests
"timeout": 300
```

---

## 10. Troubleshooting

### Test nicht gefunden

```
No tests were found!!!
```

**Lösungen:**
1. `BUILD_TESTS=ON` setzen
2. `tests` Array in Solution.json prüfen
3. Source-Pfad prüfen

### Framework-Fehler

```
fatal error: 'doctest/doctest.h' file not found
```

**Lösung:** External zu `externals` Array hinzufügen:

```json
"externals": ["doctest"]
```

### Test-Timeout

```
Test timeout after 60 sec
```

**Lösung:** Timeout erhöhen:

```json
"timeout": 120
```

### Dependency-Fehler

```
[E101] Dependency 'CoreLib' for test 'CoreLib_Tests' does not exist
```

**Lösung:** Library zu `libraries` Array hinzufügen und `dependencies` korrekt setzen.

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-11** | **Initial: Framework-Vergleich, Konfiguration, Beispiele** |
