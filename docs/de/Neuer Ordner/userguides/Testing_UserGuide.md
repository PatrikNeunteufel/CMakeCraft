# Testing — Benutzerhandbuch

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Guide  
> **Status:** Stabil  
> **Zielgruppe:** C++ Entwickler  
> **Modul:** Tests.cmake, TestCollect.cmake, TestCreate.cmake  
> **Basiert auf:** Guide v0.5  
> **Sprache:** Deutsch  
> **English:** [Testing_UserGuide.md](../en/guides/Testing_UserGuide.md)

---

## Inhaltsverzeichnis

1. [Überblick](#1-überblick)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Schnellstart](#3-schnellstart)
4. [Test-Typen](#4-test-typen)
5. [Framework-Vergleich](#5-framework-vergleich)
6. [Konfiguration](#6-konfiguration)
7. [Tests schreiben](#7-tests-schreiben)
8. [Tests ausführen](#8-tests-ausführen)
9. [Stolpersteine und Lösungen](#9-stolpersteine-und-lösungen)
10. [Troubleshooting](#10-troubleshooting)
11. [Siehe auch](#11-siehe-auch)
12. [Changelog](#12-changelog)

---

## 1. Überblick

Das Test-System ermöglicht das Definieren und Ausführen von Tests für Projektcode.

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

---

## 2. Voraussetzungen

- [ ] CMake Architecture V2 Build-System
- [ ] Test-Framework (doctest, GoogleTest oder Catch2)
- [ ] `BUILD_TESTS=ON` beim CMake-Configure

---

## 3. Schnellstart

**1. Solution.json:**

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

**2. Test-Datei erstellen:**

```cpp
// projects/tests/unit/MyLib_Tests/src/test_main.cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.h>
#include "MyLib/Calculator.h"

TEST_CASE("Calculator add") {
    Calculator calc;
    CHECK(calc.add(2, 3) == 5);
}
```

**3. Build und Run:**

```bash
cmake --preset windows-ninja-debug -DBUILD_TESTS=ON
cmake --build out/build/windows-ninja-debug
ctest --test-dir out/build/windows-ninja-debug
```

---

## 4. Test-Typen

| Typ | Beschreibung | Dauer |
|-----|--------------|-------|
| `unit` | Einzelne Funktionen/Klassen | Schnell |
| `integration` | Komponenten-Zusammenspiel | Mittel |
| `system` | Gesamtsystem (End-to-End) | Langsam |
| `performance` | Benchmarks | Variabel |
| `smoke` | Basis-Funktionalität | Sehr schnell |

### Wann welchen Typ verwenden?

| Typ | Use Case |
|-----|----------|
| **unit** | Für jede Klasse/Funktion |
| **integration** | Nach Unit Tests, vor Release |
| **system** | CI/CD Pipeline, Release-Tests |
| **performance** | Regressions-Tracking |
| **smoke** | Schnelle Validierung nach Build |

---

## 5. Framework-Vergleich

### Feature-Matrix

| Feature | doctest | GoogleTest | Catch2 |
|---------|:-------:|:----------:|:------:|
| Kompilierzeit | ⭐⭐⭐ | ⭐ | ⭐⭐ |
| Header-only | ✅ | ❌ | ❌ |
| Mocking | ❌ | ✅ | ❌ |
| BDD-Style | ❌ | ❌ | ✅ |
| Benchmarks | ❌ | ❌ | ✅ |

### Entscheidungshilfe

```
Brauchst du Mocking?
├─ Ja → GoogleTest
└─ Nein
    ├─ BDD-Style gewünscht? → Catch2
    └─ Schnelle Kompilierung wichtig? → doctest
```

---

## 6. Konfiguration

### 6.1 Minimale Konfiguration

```json
"tests": [
    {
        "name": "MyLib_Tests"
    }
]
```

**Defaults:** `type: "unit"`, `framework: "doctest"`, `timeout: 60`

### 6.2 Vollständige Konfiguration

```json
"tests": [
    {
        "name": "CoreLib_UnitTests",
        "displayName": "CoreLib Unit Tests",
        "type": "unit",
        "framework": "doctest",
        "path": "projects/tests/unit/CoreLib_Tests/src",
        "dependencies": ["CoreLib"],
        "externals": ["doctest"],
        "timeout": 30,
        "labels": ["unit", "core", "fast"],
        "parallel": true
    }
]
```

### 6.3 Feld-Referenz

| Feld | Typ | Default | Beschreibung |
|------|-----|---------|--------------|
| `name` | string | **Pflicht** | Test-Target-Name |
| `type` | string | `"unit"` | Test-Typ |
| `framework` | string | `"doctest"` | Test-Framework |
| `dependencies` | string[] | `[]` | Interne Libraries |
| `externals` | string[] | `[]` | Externe Libraries |
| `timeout` | int | 60 | Timeout (Sekunden) |
| `labels` | string[] | `[type]` | CTest Labels |
| `parallel` | bool | true | Parallel ausführbar |

---

## 7. Tests schreiben

### 7.1 doctest

```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.h>

TEST_CASE("Calculator::add") {
    Calculator calc;
    
    SUBCASE("positive numbers") {
        CHECK(calc.add(2, 3) == 5);
    }
    
    SUBCASE("negative numbers") {
        CHECK(calc.add(-1, -1) == -2);
    }
}

TEST_CASE("Calculator::divide") {
    Calculator calc;
    CHECK_THROWS_AS(calc.divide(1, 0), std::domain_error);
}
```

### 7.2 GoogleTest

```cpp
#include <gtest/gtest.h>

class CalculatorTest : public ::testing::Test {
protected:
    Calculator calc;
};

TEST_F(CalculatorTest, AddPositive) {
    EXPECT_EQ(calc.add(2, 3), 5);
}

TEST_F(CalculatorTest, DivideByZeroThrows) {
    EXPECT_THROW(calc.divide(1, 0), std::domain_error);
}
```

### 7.3 Catch2 (BDD-Style)

```cpp
#define CATCH_CONFIG_MAIN
#include <catch2/catch_all.hpp>

SCENARIO("Calculator handles basic operations") {
    GIVEN("A calculator instance") {
        Calculator calc;
        
        WHEN("adding positive numbers") {
            auto result = calc.add(2, 3);
            
            THEN("the result is correct") {
                REQUIRE(result == 5);
            }
        }
    }
}
```

---

## 8. Tests ausführen

### Alle Tests

```bash
ctest --test-dir out/build/windows-ninja-debug
```

### Nach Label filtern

```bash
ctest -L unit         # Nur Unit Tests
ctest -L fast         # Nur schnelle Tests
ctest -LE slow        # Keine langsamen Tests
```

### Nach Name filtern

```bash
ctest -R CoreLib_Tests       # Bestimmter Test
ctest -R ".*Audio.*"         # Pattern
ctest -E ".*Benchmark.*"     # Ausschließen
```

### Parallel

```bash
ctest -j8                    # Mit 8 Jobs
ctest -j$(nproc)             # Alle CPUs (Linux)
```

### Verbose

```bash
ctest --output-on-failure    # Ausgabe bei Fehlern
ctest -V                     # Immer verbose
```

---

## 9. Stolpersteine und Lösungen

### 9.1 Tests werden nicht gefunden

**Problem:** `No tests were found!!!`

**Lösung:**
1. `BUILD_TESTS=ON` setzen
2. `tests` Array in Solution.json prüfen
3. Source-Pfad prüfen

### 9.2 Framework-Header nicht gefunden

**Problem:** `fatal error: 'doctest/doctest.h' file not found`

**Lösung:** External zu `externals` Array hinzufügen:

```json
"externals": ["doctest"]
```

### 9.3 Test-Timeout

**Problem:** `Test timeout after 60 sec`

**Lösung:** Timeout erhöhen:

```json
"timeout": 120
```

---

## 10. Troubleshooting

### Checkliste

- [ ] `BUILD_TESTS=ON` gesetzt?
- [ ] `tests` Array in Solution.json vorhanden?
- [ ] Framework als External definiert?
- [ ] `externals` im Test enthält Framework?

### Häufige Fehler

| Fehler | Lösung |
|--------|--------|
| `No tests found` | `BUILD_TESTS=ON` |
| `doctest.h not found` | External definieren |
| `Dependency not found` | Library in `libraries` prüfen |

---

## 11. Siehe auch

- [doctest UserGuide](externals/doctest_UserGuide.md) — doctest Framework
- [Tutorial GoogleTest/Catch2](Tutorials/Tutorial_GoogleTest_Catch2.md) — Framework-Tutorial
- [Solution_Schema](../reference/Solution_Schema.md) — JSON-Schema

---

## 12. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf Guide v0.5 Blueprint** |
| 0.1.0 | 2025-12-11 | Initial: Framework-Vergleich, Konfiguration |
