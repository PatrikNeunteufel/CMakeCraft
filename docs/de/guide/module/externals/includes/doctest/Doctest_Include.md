# doctest/Include.cmake — doctest Testing Framework Integration

> **Version:** 1.0.1  
> **Datum:** 2026-11-09  
> **Typ:** ModuleDoc  
> **Status:** Aktiv  
> **Basiert auf:** ModuleDoc v0.5, Doc v0.5  
> **Zielgruppe:** Build-System-Entwickler, C++ Entwickler  
> **Sprache:** Deutsch  
> **English:** [doctest_Include.md](../../../../../../en/guide/module/externals/includes/doctest/Doctest_Include.md)  
> **Modul:** [cmake/externals/includes/doctest/Include.cmake](../../../../../../../cmake/externals/includes/doctest/Include.cmake)  
> **Modul-Version:** 1.0.0

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Verfügbare Variablen](#2-verfügbare-variablen)
3. [Erstellte Targets](#3-erstellte-targets)
4. [Options](#4-options)
5. [Verwendungsbeispiele](#5-verwendungsbeispiele)
6. [Test-Patterns](#6-test-patterns)
7. [Verzeichnisstruktur](#7-verzeichnisstruktur)
8. [Fehlerbehandlung](#8-fehlerbehandlung)
9. [Siehe auch](#9-siehe-auch)
10. [Changelog](#changelog)

---

## 1. Übersicht

Die `doctest/Include.cmake` integriert das **doctest Testing Framework** als lokales External in das Build-System.

### Kernfunktionen

| Funktion | Beschreibung |
|----------|--------------|
| Header-Only | Nur ein Header, keine Library nötig |
| Schnell | Extrem schnelle Kompilierung |
| Lightweight | Minimaler Overhead |
| BDD-Style | Subcases für verschachtelte Tests |

### Einbindung

Legt **kein eigenes Target** an. Das Modul setzt am Target `EXECUTABLE_NAME` den Include-Pfad `externals/doctest/` (dort liegt `doctest.h` direkt) und je nach Options Compile-Defines und Warnungs-Schalter.

---

## 2. Verfügbare Variablen

Diese Variablen werden vom Orchestrator bereitgestellt:

| Variable | Beschreibung |
|----------|--------------|
| `EXTERNAL_NAME` | `"doctest"` |
| `EXTERNAL_ROOT` | Absoluter Pfad zu `externals/doctest` (`path` aus Solution.json) |
| `EXTERNAL_OPTIONS` | Target-spezifische Options (JSON) |
| `EXECUTABLE_NAME` | Target, an das doctest angehängt wird |

---

## 3. Erstellte Targets

| Target | Typ | Beschreibung |
|--------|-----|--------------|
| — | — | Kein eigenes Target; alles wird `PRIVATE` an `EXECUTABLE_NAME` gehängt |

### Include-Directories

```cmake
# doctest.h is in the root directory
target_include_directories(${EXECUTABLE_NAME} PRIVATE "${_doctest_root}")
```

`_doctest_root` ist `EXTERNAL_ROOT`. Im Code heißt es deshalb `#include <doctest.h>`.

Dazu: MSVC `/wd4251 /wd4275`, GCC/Clang `-Wno-unknown-pragmas`.

---

## 4. Options

Über `external_options` in Solution.json (je Target):

| Option | Typ | Default | Wirkung |
|--------|-----|---------|---------|
| `DOCTEST_NO_SHORT_MACRO_NAMES` | bool | `false` | Define `DOCTEST_CONFIG_NO_SHORT_MACRO_NAMES` |
| `DOCTEST_CONFIG_SUPER_FAST_ASSERTS` | bool | `false` | Define `DOCTEST_CONFIG_SUPER_FAST_ASSERTS` |
| `DOCTEST_CONFIG_DISABLE` | bool | `false` | Define `DOCTEST_CONFIG_DISABLE` |

### Compile-Time Konfiguration

Diese Defines können in C++ vor `#include <doctest.h>` gesetzt werden:

| Define | Beschreibung |
|--------|--------------|
| `DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN` | main() automatisch generieren |
| `DOCTEST_CONFIG_IMPLEMENT` | Nur Implementation, kein main() |
| `DOCTEST_CONFIG_DISABLE` | Tests komplett deaktivieren |
| `DOCTEST_CONFIG_NO_SHORT_MACRO_NAMES` | Nur `DOCTEST_*` Makros |

---

## 5. Verwendungsbeispiele

### 5.1 Einfacher Unit Test

**Solution.json:**

```json
{
    "externals": {
        "doctest": { "path": "externals/doctest" }
    },
    "tests": [
        {
            "name": "MyTests",
            "framework": "doctest",
            "externals": ["doctest"]
        }
    ]
}
```

**test_main.cpp:**

```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.h>

TEST_CASE("Math operations") {
    CHECK(1 + 1 == 2);
    CHECK(2 * 3 == 6);
    CHECK(10 / 2 == 5);
}
```

### 5.2 Subcases (BDD-Style)

```cpp
#include <doctest.h>
#include <string>

TEST_CASE("String operations") {
    std::string s = "Hello";
    
    SUBCASE("append") {
        s += " World";
        CHECK(s == "Hello World");
    }
    
    SUBCASE("length") {
        CHECK(s.length() == 5);
    }
    
    SUBCASE("clear") {
        s.clear();
        CHECK(s.empty());
    }
}
```

### 5.3 Test mit Fixtures

```cpp
#include <doctest.h>
#include <vector>

TEST_CASE("Vector tests") {
    std::vector<int> vec;
    
    REQUIRE(vec.empty());
    
    SUBCASE("push_back") {
        vec.push_back(1);
        vec.push_back(2);
        
        CHECK(vec.size() == 2);
        CHECK(vec[0] == 1);
        CHECK(vec[1] == 2);
    }
    
    SUBCASE("reserve") {
        vec.reserve(100);
        
        CHECK(vec.capacity() >= 100);
        CHECK(vec.empty());  // Size ist noch 0
    }
}
```

### 5.4 Eigene main() Funktion

```cpp
#define DOCTEST_CONFIG_IMPLEMENT
#include <doctest.h>

int main(int argc, char** argv) {
    doctest::Context context;
    
    // Defaults
    context.setOption("abort-after", 5);
    context.setOption("order-by", "name");
    
    // Kommandozeilen-Argumente
    context.applyCommandLine(argc, argv);
    
    int result = context.run();
    
    if (context.shouldExit()) {
        return result;
    }
    
    // Eigene Logik hier...
    
    return result;
}
```

### 5.5 Tests in Produktionscode deaktivieren

```cpp
// In Release-Builds: Tests komplett entfernen
#ifdef NDEBUG
    #define DOCTEST_CONFIG_DISABLE
#endif

#include <doctest.h>

// Diese Tests existieren nur in Debug-Builds
TEST_CASE("Debug-only test") {
    CHECK(1 == 1);
}
```

---

## 6. Test-Patterns

### 6.1 Assertions

| Assertion | Beschreibung |
|-----------|--------------|
| `CHECK(expr)` | Prüft, fährt bei Fehler fort |
| `REQUIRE(expr)` | Prüft, bricht bei Fehler ab |
| `CHECK_EQ(a, b)` | Gleichheit mit Details |
| `CHECK_NE(a, b)` | Ungleichheit |
| `CHECK_LT(a, b)` | Kleiner als |
| `CHECK_GT(a, b)` | Größer als |
| `CHECK_THROWS(expr)` | Exception erwartet |
| `CHECK_NOTHROW(expr)` | Keine Exception erwartet |

### 6.2 Test-Organisation

```cpp
TEST_SUITE("Math") {
    TEST_CASE("Addition") {
        CHECK(1 + 1 == 2);
    }
    
    TEST_CASE("Subtraction") {
        CHECK(5 - 3 == 2);
    }
}

TEST_SUITE("Strings") {
    TEST_CASE("Concatenation") {
        CHECK(std::string("a") + "b" == "ab");
    }
}
```

### 6.3 Parametrisierte Tests

```cpp
TEST_CASE_TEMPLATE("Type traits", T, int, float, double) {
    T value = T(42);
    CHECK(value == T(42));
}
```

---

## 7. Verzeichnisstruktur

```
externals/doctest/
└── doctest.h
```

> **Hinweis:** doctest besteht nur aus einem einzigen Header!

---

## 8. Fehlerbehandlung

| Code | Beschreibung |
|------|--------------|
| E213 | Include.cmake nicht gefunden |
| E214 | External-Pfad existiert nicht |

### Häufige Fehler

**"doctest.h not found":**
```cpp
// Falsch (das lokale External liefert keinen Unterordner doctest/):
#include <doctest/doctest.h>

// Richtig:
#include <doctest.h>
```

**"Undefined reference to main":**
```cpp
// Fehlt:
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.h>
```

---

## 9. Siehe auch

- [Testing_UserGuide.md](../../../../userguides/Testing.md) — Test-Anleitung
- [Solution_Schema.md](../../../../references/Solution_Schema.md) — tests Array
- [Attach_cmake.md](../../locals/Attach_cmake.md) — Local External Handler
- [doctest GitHub](https://github.com/doctest/doctest) — Offizielle Dokumentation

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **An den Code angeglichen: kein INTERFACE-Target, sondern Include-Pfad `externals/doctest/` am Target `EXECUTABLE_NAME`; `#include <doctest.h>` durchgehend (Widerspruch § 4/§ 8 aufgelöst, wie in den Demo-Projekten); Options aus `external_options`; Variablen und Verzeichnisstruktur wie im Code** |
| 1.0.0 | 2025-12-26 | Release 1 (aus newCMake übernommen, `2e00db7`) |
| 0.5.0 | 2025-12-15 | Migration auf Blueprint v0.5.0, Convention-Pfad `cmake/externals/includes/doctest/` |
| 0.1.0 | 2025-12-05 | Initial: Header-only INTERFACE Target |
