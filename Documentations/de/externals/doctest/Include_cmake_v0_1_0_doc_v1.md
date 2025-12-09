# doctest Testing Framework – Include.cmake Dokumentation

> **Version:** 0.1.0 (doc v1)  
> **Datum:** 2025-12-08  
> **Typ:** External Include Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** externals/doctest/Include.cmake  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** CMake_Blueprint v0.1, Externals v0.1  
> **Sprache:** Deutsch

---

## 1. Übersicht

doctest ist ein **header-only** C++ Testing Framework. Die Integration erfordert
nur das Hinzufügen des Include-Verzeichnisses - keine Libraries zum Linken.

**Kernfunktionen:**
- Header-only (schnelle Kompilierung)
- Minimale Konfiguration erforderlich
- Optionale Compile-Definitions für Anpassungen

---

## 2. Verzeichnisstruktur

```
externals/doctest/
├── Include.cmake     ← Dieses Modul
└── doctest.h         ← Single-Header Library
```

---

## 3. Verfügbare Options

| Option | Typ | Beschreibung |
|--------|-----|--------------|
| `DOCTEST_NO_SHORT_MACRO_NAMES` | bool | Lange Makronamen verwenden |
| `DOCTEST_CONFIG_SUPER_FAST_ASSERTS` | bool | Schnellere Asserts (weniger Debug-Info) |
| `DOCTEST_CONFIG_DISABLE` | bool | doctest komplett deaktivieren |

### 3.1 DOCTEST_NO_SHORT_MACRO_NAMES

Wenn aktiviert, müssen die langen Makronamen verwendet werden:

| Kurz (Standard) | Lang (mit Option) |
|-----------------|-------------------|
| `TEST_CASE` | `DOCTEST_TEST_CASE` |
| `CHECK` | `DOCTEST_CHECK` |
| `REQUIRE` | `DOCTEST_REQUIRE` |
| `SUBCASE` | `DOCTEST_SUBCASE` |

Nützlich wenn Konflikte mit anderen Test-Frameworks bestehen.

### 3.2 DOCTEST_CONFIG_SUPER_FAST_ASSERTS

Reduziert Debug-Informationen bei Fehlern für schnellere Kompilierung.
Nicht empfohlen während der Entwicklung.

### 3.3 DOCTEST_CONFIG_DISABLE

Deaktiviert alle doctest-Makros komplett. Nützlich für Release-Builds
wo Test-Code entfernt werden soll.

---

## 4. Verwendung in Solution.json

### 4.1 External definieren

```json
{
    "externals": {
        "doctest": {
            "path": "externals/doctest"
        }
    }
}
```

### 4.2 In Test-Executable verwenden

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

### 4.3 Mit Options

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

---

## 5. C++ Verwendung

### 5.1 Einfacher Test

```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.h>

TEST_CASE("Addition") {
    CHECK(1 + 1 == 2);
    CHECK(2 + 2 == 4);
}
```

### 5.2 Mit eigenem main()

```cpp
#define DOCTEST_CONFIG_IMPLEMENT
#include <doctest.h>

int main(int argc, char** argv) {
    doctest::Context context;
    context.applyCommandLine(argc, argv);
    
    int res = context.run();
    
    if (context.shouldExit()) {
        return res;
    }
    
    // Eigener Code hier...
    
    return res;
}
```

### 5.3 Subcases

```cpp
TEST_CASE("Vector operations") {
    std::vector<int> vec;
    
    SUBCASE("push_back") {
        vec.push_back(1);
        CHECK(vec.size() == 1);
    }
    
    SUBCASE("clear") {
        vec.push_back(1);
        vec.clear();
        CHECK(vec.empty());
    }
}
```

---

## 6. Platform-Verhalten

### Windows (MSVC)

Unterdrückte Warnungen:
- `C4251`: class needs dll-interface
- `C4275`: non dll-interface class used as base

### GCC/Clang

Unterdrückte Warnungen:
- `-Wno-unknown-pragmas`

---

## 7. Siehe auch

- [Externals](../../References/Externals_v0_1_0.md) – Alle Externals
- [doctest GitHub](https://github.com/doctest/doctest) – Offizielle Dokumentation

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-08** | **Initial: Blueprint-konform, Header-only Integration** |
