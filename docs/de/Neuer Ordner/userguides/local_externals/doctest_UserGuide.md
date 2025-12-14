# doctest Testing Framework — Benutzerhandbuch

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Guide  
> **Status:** Stabil  
> **Zielgruppe:** C++ Entwickler  
> **Modul:** externals/doctest/Include.cmake v0.1.0  
> **Basiert auf:** Guide v0.5  
> **Sprache:** Deutsch  
> **English:** [doctest_UserGuide.md](../../en/guides/externals/doctest_UserGuide.md)

---

## Inhaltsverzeichnis

1. [Überblick](#1-überblick)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Schnellstart](#3-schnellstart)
4. [Tests schreiben](#4-tests-schreiben)
5. [Options konfigurieren](#5-options-konfigurieren)
6. [Fortgeschrittene Techniken](#6-fortgeschrittene-techniken)
7. [Stolpersteine und Lösungen](#7-stolpersteine-und-lösungen)
8. [Troubleshooting](#8-troubleshooting)
9. [Siehe auch](#9-siehe-auch)
10. [Changelog](#10-changelog)

---

## 1. Überblick

doctest ist ein leichtgewichtiges, header-only C++ Testing Framework. Es ist ideal für Unit-Tests in CMake Architecture V2 Projekten.

### Features

- Header-only (ein `#include` genügt)
- Extrem schnelle Kompilierung
- Subcases für strukturierte Tests
- Konfigurierbare Makronamen
- Release-Build Deaktivierung

---

## 2. Voraussetzungen

- [ ] CMake Architecture V2 Build-System
- [ ] `doctest.h` in `externals/doctest/` vorhanden

### Verzeichnisstruktur prüfen

```
externals/doctest/
├── Include.cmake
└── doctest.h
```

---

## 3. Schnellstart

**1. Solution.json – External definieren:**

```json
{
    "externals": {
        "doctest": {
            "path": "externals/doctest"
        }
    }
}
```

**2. Solution.json – Test-Executable erstellen:**

```json
{
    "executables": [
        {
            "name": "MyTests",
            "externals": ["doctest"]
        }
    ]
}
```

**3. C++ Test-Datei:**

```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.h>

TEST_CASE("Mein erster Test") {
    CHECK(1 + 1 == 2);
    CHECK(2 * 3 == 6);
}
```

**4. Build und Ausführen:**

```bash
cmake --preset windows-ninja-debug
cmake --build out/build/windows-ninja-debug --target MyTests
./out/build/windows-ninja-debug/exec/MyTests/bin/MyTests
```

---

## 4. Tests schreiben

### 4.1 Wie schreibe ich einen einfachen Test?

```cpp
TEST_CASE("Addition funktioniert") {
    CHECK(2 + 2 == 4);
    CHECK(-1 + 1 == 0);
}
```

### 4.2 CHECK vs REQUIRE

| Makro | Verhalten bei Fehlschlag |
|-------|--------------------------|
| `CHECK` | Test markiert als fehlgeschlagen, **fährt fort** |
| `REQUIRE` | Test markiert als fehlgeschlagen, **bricht ab** |

```cpp
TEST_CASE("Kritische Voraussetzungen") {
    int* ptr = get_pointer();
    REQUIRE(ptr != nullptr);  // Abbruch wenn nullptr
    CHECK(*ptr == 42);        // Nur ausgeführt wenn REQUIRE erfolgreich
}
```

### 4.3 Wie strukturiere ich Tests mit Subcases?

Subcases ermöglichen gemeinsames Setup mit verschiedenen Testpfaden:

```cpp
TEST_CASE("Vector Operationen") {
    std::vector<int> vec;
    vec.push_back(1);
    vec.push_back(2);
    
    SUBCASE("size() gibt korrekte Größe") {
        CHECK(vec.size() == 2);
    }
    
    SUBCASE("clear() leert den Vector") {
        vec.clear();
        CHECK(vec.empty());
    }
    
    SUBCASE("pop_back() entfernt letztes Element") {
        vec.pop_back();
        CHECK(vec.size() == 1);
        CHECK(vec[0] == 1);
    }
}
```

### 4.4 Wie teste ich Exceptions?

```cpp
TEST_CASE("Exception Handling") {
    CHECK_THROWS(throw std::runtime_error("error"));
    CHECK_THROWS_AS(throw std::runtime_error("error"), std::runtime_error);
    CHECK_NOTHROW(safe_function());
}
```

### 4.5 Wie teste ich Floating-Point Werte?

```cpp
TEST_CASE("Floating Point") {
    double result = calculate_pi();
    CHECK(result == doctest::Approx(3.14159).epsilon(0.0001));
}
```

---

## 5. Options konfigurieren

### 5.1 Wie vermeide ich Makro-Konflikte?

Wenn `TEST_CASE`, `CHECK` etc. mit anderem Code kollidieren:

```json
{
    "executables": [
        {
            "name": "MyTests",
            "externals": ["doctest"],
            "external_options": {
                "doctest": {
                    "DOCTEST_NO_SHORT_MACRO_NAMES": true
                }
            }
        }
    ]
}
```

Dann verwende die langen Namen:

```cpp
DOCTEST_TEST_CASE("Test mit langem Namen") {
    DOCTEST_CHECK(1 == 1);
    DOCTEST_REQUIRE(true);
}
```

### 5.2 Wie beschleunige ich die Kompilierung?

```json
"external_options": {
    "doctest": {
        "DOCTEST_CONFIG_SUPER_FAST_ASSERTS": true
    }
}
```

**Achtung:** Reduziert Debug-Informationen bei fehlgeschlagenen Tests.

### 5.3 Wie deaktiviere ich Tests für Release-Builds?

```json
"external_options": {
    "doctest": {
        "DOCTEST_CONFIG_DISABLE": true
    }
}
```

Alle Test-Makros werden zu No-Ops – der Test-Code wird nicht ausgeführt.

### 5.4 Options-Übersicht

| Option | Effekt |
|--------|--------|
| `DOCTEST_NO_SHORT_MACRO_NAMES` | Nur lange Makronamen (`DOCTEST_*`) |
| `DOCTEST_CONFIG_SUPER_FAST_ASSERTS` | Schnellere Kompilierung |
| `DOCTEST_CONFIG_DISABLE` | Deaktiviert alle Tests |

---

## 6. Fortgeschrittene Techniken

### 6.1 Eigenes main() verwenden

```cpp
#define DOCTEST_CONFIG_IMPLEMENT
#include <doctest.h>

int main(int argc, char** argv) {
    doctest::Context context;
    context.applyCommandLine(argc, argv);
    
    // Eigene Konfiguration
    context.setOption("no-breaks", true);
    
    int result = context.run();
    
    if (context.shouldExit()) {
        return result;
    }
    
    // Eigener Code nach Tests...
    
    return result;
}
```

### 6.2 Test-Fixtures

```cpp
struct DatabaseFixture {
    Database db;
    
    DatabaseFixture() {
        db.connect("test_db");
    }
    
    ~DatabaseFixture() {
        db.disconnect();
    }
};

TEST_CASE_FIXTURE(DatabaseFixture, "Database Query") {
    auto result = db.query("SELECT * FROM users");
    CHECK(result.size() > 0);
}
```

### 6.3 Parametrisierte Tests

```cpp
TEST_CASE_TEMPLATE("Numeric Types", T, int, long, float, double) {
    T value = static_cast<T>(42);
    CHECK(value == static_cast<T>(42));
}
```

### 6.4 Test-Filter (Kommandozeile)

```bash
# Nur Tests mit "Vector" im Namen
./MyTests --test-case="*Vector*"

# Alle außer "slow" Tests
./MyTests --test-case-exclude="*slow*"

# Verbose Output
./MyTests --success
```

---

## 7. Stolpersteine und Lösungen

### 7.1 Mehrere main() Definitionen

**Problem:**
```
multiple definition of `main'
```

**Ursache:** `DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN` in mehreren Dateien.

**Lösung:** Nur in **einer** Datei `_WITH_MAIN` verwenden:

```cpp
// test_main.cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.h>

// test_vector.cpp
#include <doctest.h>  // OHNE _WITH_MAIN

TEST_CASE("Vector Test") { ... }
```

### 7.2 Tests werden nicht gefunden

**Problem:** Test-Executable läuft durch, findet aber 0 Tests.

**Ursache:** Linker entfernt ungenutzte Test-Funktionen.

**Lösung:** Alle Test-Dateien zum Executable hinzufügen (nicht als Library).

---

## 8. Troubleshooting

### Checkliste

- [ ] `doctest` in Solution.json unter `externals` definiert?
- [ ] Executable verwendet `"externals": ["doctest"]`?
- [ ] Genau eine Datei mit `DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN`?
- [ ] Alle Test-Dateien zum Executable gelinkt?

### Häufige Fehler

| Fehler | Lösung |
|--------|--------|
| `doctest.h not found` | Pfad in Solution.json prüfen |
| `multiple definition of main` | Nur eine Datei mit `_WITH_MAIN` |
| `0 test cases` | Test-Dateien linken |

---

## 9. Siehe auch

- [doctest Include.cmake](../../modules/externals/doctest/Include.md) — Technische Dokumentation
- [Testing UserGuide](../Testing_UserGuide.md) — Allgemeine Test-Integration
- [doctest GitHub](https://github.com/doctest/doctest) — Offizielle Dokumentation

---

## 10. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Neu: Vollständiges Benutzerhandbuch mit Options, Fixtures, Parametrierung** |
