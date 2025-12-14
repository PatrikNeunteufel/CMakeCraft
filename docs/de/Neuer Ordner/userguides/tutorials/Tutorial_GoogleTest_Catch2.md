# Tutorial: GoogleTest und Catch2 hinzufügen

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Tutorial  
> **Status:** Stabil  
> **Zielgruppe:** C++ Entwickler  
> **Basiert auf:** Tutorial v0.5  
> **Sprache:** Deutsch  
> **English:** [Tutorial_GoogleTest_Catch2.md](../../en/guides/tutorials/Tutorial_GoogleTest_Catch2.md)

---

## Inhaltsverzeichnis

1. [Überblick](#1-überblick)
2. [Voraussetzungen](#2-voraussetzungen)
3. [GoogleTest](#3-googletest)
4. [Catch2](#4-catch2)
5. [Vergleich](#5-vergleich)
6. [Stolpersteine und Lösungen](#6-stolpersteine-und-lösungen)
7. [Troubleshooting](#7-troubleshooting)
8. [Siehe auch](#8-siehe-auch)
9. [Changelog](#9-changelog)

---

## 1. Überblick

Dieses Tutorial zeigt anhand von **GoogleTest** und **Catch2**, wie Test-Frameworks als Externals hinzugefügt werden.

| Framework | Repository | Targets | Komplexität |
|-----------|------------|---------|-------------|
| GoogleTest | google/googletest | `gtest`, `gtest_main`, `gmock` | Mittel |
| Catch2 | catchorg/Catch2 | `Catch2`, `Catch2WithMain` | Einfach |

---

## 2. Voraussetzungen

- [ ] CMake Architecture V2 Build-System
- [ ] Netzwerkverbindung für Git-Download
- [ ] Grundkenntnisse Unit Testing

---

## 3. GoogleTest

### 3.1 Solution.json

```json
{
    "externals": {
        "googletest": {
            "git": "https://github.com/google/googletest.git",
            "tag": "v1.14.0"
        }
    }
}
```

### 3.2 PreFetch Hook erstellen

**Datei:** `cmake/externals/Hooks/PreFetch/googletest.cmake`

```cmake
# PreFetch/googletest.cmake
message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch: Configuring GoogleTest")

# Enable Google Mock
set(BUILD_GMOCK ON CACHE BOOL "" FORCE)

# Disable installation
set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)

# Windows CRT Fix (WICHTIG!)
if(WIN32)
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
endif()

message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch complete")
```

**Windows-Besonderheit:** `gtest_force_shared_crt` muss `ON` sein, sonst Linker-Fehler!

### 3.3 Test konfigurieren

```json
{
    "tests": [
        {
            "name": "MyTests",
            "externals": ["googletest"],
            "framework": "gtest"
        }
    ]
}
```

### 3.4 Test schreiben

```cpp
#include <gtest/gtest.h>

TEST(ExampleTest, BasicAssertions) {
    EXPECT_STRNE("hello", "world");
    EXPECT_EQ(7 * 6, 42);
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
```

**Mit gtest_main (kein eigenes main()):**

```cpp
#include <gtest/gtest.h>

TEST(ExampleTest, BasicAssertions) {
    EXPECT_EQ(7 * 6, 42);
}
// Kein main() nötig!
```

### 3.5 Testen

```bash
cmake --preset windows-ninja-debug
cmake --build out/build/windows-ninja-debug --target MyTests
ctest --test-dir out/build/windows-ninja-debug --output-on-failure
```

---

## 4. Catch2

### 4.1 Solution.json

```json
{
    "externals": {
        "catch2": {
            "git": "https://github.com/catchorg/Catch2.git",
            "tag": "v3.5.2"
        }
    }
}
```

### 4.2 PreFetch Hook erstellen

**Datei:** `cmake/externals/Hooks/PreFetch/catch2.cmake`

```cmake
# PreFetch/catch2.cmake
message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch: Configuring Catch2")

# Disable tests and examples
set(CATCH_BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(CATCH_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(CATCH_INSTALL_DOCS OFF CACHE BOOL "" FORCE)

message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch complete")
```

### 4.3 Test konfigurieren

```json
{
    "tests": [
        {
            "name": "MyTests",
            "externals": ["catch2"],
            "framework": "catch2"
        }
    ]
}
```

### 4.4 Test schreiben

**Mit Catch2WithMain (empfohlen):**

```cpp
#include <catch2/catch_test_macros.hpp>

TEST_CASE("Factorials are computed", "[factorial]") {
    REQUIRE(1 == 1);
    REQUIRE(2 * 3 == 6);
}
// Kein main() nötig!
```

**BDD-Style:**

```cpp
#include <catch2/catch_test_macros.hpp>

SCENARIO("vectors can be sized", "[vector]") {
    GIVEN("A vector with some items") {
        std::vector<int> v(5);

        WHEN("the size is increased") {
            v.resize(10);

            THEN("the size changes") {
                REQUIRE(v.size() == 10);
            }
        }
    }
}
```

### 4.5 Benchmarks (Catch2 Feature)

```cpp
#include <catch2/catch_test_macros.hpp>
#include <catch2/benchmark/catch_benchmark.hpp>

TEST_CASE("Benchmarks") {
    BENCHMARK("Vector creation") {
        return std::vector<int>(1000);
    };
}
```

---

## 5. Vergleich

| Aspekt | GoogleTest | Catch2 |
|--------|------------|--------|
| **Syntax** | `TEST()`, `EXPECT_*` | `TEST_CASE()`, `REQUIRE()` |
| **Mocking** | ✅ GMock integriert | ❌ Extern |
| **BDD-Style** | ❌ | ✅ `SCENARIO`, `GIVEN` |
| **Sections** | ❌ | ✅ `SECTION()` |
| **Benchmarks** | ❌ | ✅ Integriert |
| **Windows CRT** | ⚠️ Hook nötig | ✅ Problemlos |

**Empfehlung:**
- **GoogleTest:** Wenn Mocking wichtig ist
- **Catch2:** Für einfachere Syntax und BDD-Style

---

## 6. Stolpersteine und Lösungen

### 6.1 LNK2038: RuntimeLibrary mismatch (GoogleTest)

**Problem:** Linker-Fehler auf Windows.

**Lösung:** `gtest_force_shared_crt ON` im PreFetch Hook.

### 6.2 Catch2 v3 ist nicht header-only

**Problem:** Unresolved symbols.

**Lösung:** Gegen `Catch2::Catch2WithMain` linken, nicht nur Header inkludieren.

---

## 7. Troubleshooting

### Checkliste

- [ ] External in Solution.json definiert?
- [ ] PreFetch Hook erstellt?
- [ ] Test in `tests` Array?
- [ ] Framework korrekt angegeben?

### Häufige Fehler

| Fehler | Lösung |
|--------|--------|
| `RuntimeLibrary mismatch` | PreFetch Hook mit CRT Fix |
| `gtest.h not found` | External definieren |
| `undefined reference` | Framework linken |

---

## 8. Siehe auch

- [Adding_Externals_UserGuide](../Adding_Externals_UserGuide.md) — Generische Anleitung
- [Testing_UserGuide](../Testing_UserGuide.md) — Test-System
- [GoogleTest Primer](https://google.github.io/googletest/primer.html)
- [Catch2 Tutorial](https://github.com/catchorg/Catch2/blob/devel/docs/tutorial.md)

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf Tutorial v0.5 Blueprint** |
| 0.1.0 | 2025-12-10 | Initial: GoogleTest + Catch2 Tutorial |
