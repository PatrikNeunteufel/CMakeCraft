# Tutorial: GoogleTest und Catch2 hinzufügen

> **Version:** 0.1.0  
> **Datum:** 2025-12-10  
> **Typ:** Benutzer-Doku / Tutorial  
> **Status:** Stabil  
> **Voraussetzung:** [Adding_Externals_UserGuide](Adding_Externals_UserGuide_v0_1_0.md)

---

## Übersicht

Dieses Tutorial zeigt anhand von **GoogleTest** und **Catch2**, wie Test-Frameworks als Externals hinzugefügt werden.

| Framework | Repository | Targets | Komplexität |
|-----------|------------|---------|-------------|
| GoogleTest | google/googletest | `gtest`, `gtest_main`, `gmock`, `gmock_main` | Mittel |
| Catch2 | catchorg/Catch2 | `Catch2`, `Catch2WithMain` | Einfach |

---

# Teil 1: GoogleTest

## 1.1 Analyse

**Repository:** https://github.com/google/googletest

**CMakeLists.txt vorhanden:** ✅ Ja

**Wichtige Options (aus CMakeLists.txt):**
```cmake
option(BUILD_GMOCK "Builds the googlemock subproject" ON)
option(INSTALL_GTEST "Enable installation of googletest" ON)
option(gtest_force_shared_crt "Use shared (DLL) run-time lib even when Google Test is built as static lib." OFF)
```

**Targets:**
- `gtest` – Google Test ohne main()
- `gtest_main` – Google Test mit main()
- `gmock` – Google Mock ohne main()
- `gmock_main` – Google Mock mit main()

**Windows-Besonderheit:**
`gtest_force_shared_crt` muss `ON` sein, sonst gibt es Linker-Konflikte!

---

## 1.2 Solution.json

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

---

## 1.3 PreFetch Hook

**Datei:** `cmake/externals/Hooks/PreFetch/googletest.cmake`

```cmake
# ==============================================================================
# PreFetch/googletest.cmake – GoogleTest PreFetch Hook
# ==============================================================================
#
# Hook:         googletest.cmake
# Version:      0.1.0
# Date:         2025-12-10
# Part of:      CMake Architecture V2
#
# Description:
#   PreFetch hook for Google Test / Google Mock.
#   Configures build options and fixes Windows CRT issues.
#
# Targets provided by GoogleTest:
#   - gtest       : Google Test without main()
#   - gtest_main  : Google Test with main()
#   - gmock       : Google Mock without main()
#   - gmock_main  : Google Mock with main()
#
# ==============================================================================

message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch: Configuring GoogleTest")

# ==============================================================================
# Build Configuration
# ==============================================================================

# Enable Google Mock (includes Google Test)
set(BUILD_GMOCK ON CACHE BOOL "" FORCE)

# Disable installation (not needed with FetchContent)
set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)

# ==============================================================================
# Windows CRT Fix (WICHTIG!)
# ==============================================================================
#
# Ohne diese Option gibt es auf Windows Linker-Fehler wie:
#   "LNK2038: mismatch detected for 'RuntimeLibrary'"
#
# Grund: GoogleTest kompiliert standardmäßig mit statischer CRT (/MT),
# aber die meisten Projekte verwenden dynamische CRT (/MD).
#

if(WIN32)
    set(gtest_force_shared_crt ON CACHE BOOL 
        "Use shared (DLL) run-time lib even when Google Test is built as static lib." 
        FORCE
    )
    message(STATUS "[${HOOK_EXTERNAL_NAME}]   Windows: gtest_force_shared_crt=ON")
endif()

# ==============================================================================
# Optional: Hide targets in IDE folders
# ==============================================================================

set(gtest_hide_internal_symbols ON CACHE BOOL "" FORCE)

message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch complete")
message(STATUS "[${HOOK_EXTERNAL_NAME}]   Targets: gtest, gtest_main, gmock, gmock_main")
```

---

## 1.4 Test-Executable konfigurieren

**Solution.json:**

```json
{
    "tests": [
        {
            "name": "MyTests",
            "path": "projects/tests/MyTests/src",
            "externals": ["googletest"],
            "framework": "gtest"
        }
    ]
}
```

**Oder als normales Executable:**

```json
{
    "executables": [
        {
            "name": "MyTests",
            "path": "projects/tests/MyTests/src",
            "externals": ["googletest"]
        }
    ]
}
```

---

## 1.5 Beispiel-Testdatei

**Pfad:** `projects/tests/MyTests/src/main.cpp`

```cpp
#include <gtest/gtest.h>

// Ein einfacher Test
TEST(ExampleTest, BasicAssertions) {
    // Expect two strings not to be equal.
    EXPECT_STRNE("hello", "world");
    
    // Expect equality.
    EXPECT_EQ(7 * 6, 42);
}

// Noch ein Test
TEST(ExampleTest, BooleanTest) {
    EXPECT_TRUE(true);
    EXPECT_FALSE(false);
}

// Main wird von gtest_main bereitgestellt, ODER:
int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
```

**Mit gtest_main (kein eigenes main() nötig):**

```cpp
#include <gtest/gtest.h>

TEST(ExampleTest, BasicAssertions) {
    EXPECT_EQ(7 * 6, 42);
}

// Kein main() nötig wenn gegen gtest_main gelinkt wird!
```

---

## 1.6 CMake-Verknüpfung

Das Build-System verknüpft automatisch, aber intern passiert:

```cmake
# Mit eigenem main()
target_link_libraries(MyTests PRIVATE gtest)

# Ohne eigenes main() (gtest stellt main() bereit)
target_link_libraries(MyTests PRIVATE gtest_main)

# Mit Google Mock
target_link_libraries(MyTests PRIVATE gmock gmock_main)
```

---

## 1.7 Testen

```bash
# Konfigurieren
cmake --preset msvc-debug

# Bauen
cmake --build build/msvc-debug --target MyTests

# Ausführen
./build/msvc-debug/tests/MyTests/Debug/MyTests.exe

# Oder via CTest
cd build/msvc-debug
ctest -C Debug --output-on-failure
```

**Erwartete Ausgabe:**
```
[==========] Running 2 tests from 1 test suite.
[----------] Global test environment set-up.
[----------] 2 tests from ExampleTest
[ RUN      ] ExampleTest.BasicAssertions
[       OK ] ExampleTest.BasicAssertions (0 ms)
[ RUN      ] ExampleTest.BooleanTest
[       OK ] ExampleTest.BooleanTest (0 ms)
[----------] 2 tests from ExampleTest (0 ms total)

[----------] Global test environment tear-down
[==========] 2 tests from 1 test suite ran. (1 ms total)
[  PASSED  ] 2 tests.
```

---

# Teil 2: Catch2

## 2.1 Analyse

**Repository:** https://github.com/catchorg/Catch2

**CMakeLists.txt vorhanden:** ✅ Ja

**Wichtige Options:**
```cmake
option(CATCH_BUILD_TESTING "Build SelfTest project" ON)
option(CATCH_BUILD_EXAMPLES "Build documentation examples" OFF)
option(CATCH_INSTALL_DOCS "Install documentation alongside library" ON)
```

**Targets:**
- `Catch2` – Catch2 ohne main()
- `Catch2WithMain` – Catch2 mit main() (empfohlen)

**Hinweis:** Catch2 v3 ist nicht mehr header-only!

---

## 2.2 Solution.json

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

---

## 2.3 PreFetch Hook

**Datei:** `cmake/externals/Hooks/PreFetch/catch2.cmake`

```cmake
# ==============================================================================
# PreFetch/catch2.cmake – Catch2 PreFetch Hook
# ==============================================================================
#
# Hook:         catch2.cmake
# Version:      0.1.0
# Date:         2025-12-10
# Part of:      CMake Architecture V2
#
# Description:
#   PreFetch hook for Catch2 v3.
#   Disables tests, examples, and installation.
#
# Targets provided by Catch2:
#   - Catch2         : Catch2 without main()
#   - Catch2WithMain : Catch2 with main() (recommended)
#
# Note:
#   Catch2 v3 is NOT header-only anymore!
#   Use Catch2WithMain for simplest integration.
#
# ==============================================================================

message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch: Configuring Catch2")

# ==============================================================================
# Disable Tests and Examples
# ==============================================================================

# Disable Catch2's own tests
set(CATCH_BUILD_TESTING OFF CACHE BOOL "" FORCE)

# Disable examples
set(CATCH_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)

# Disable documentation installation
set(CATCH_INSTALL_DOCS OFF CACHE BOOL "" FORCE)

# Disable extras (helpers for CMake integration)
set(CATCH_INSTALL_EXTRAS OFF CACHE BOOL "" FORCE)

# ==============================================================================
# Build Configuration
# ==============================================================================

# Build as static library
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch complete")
message(STATUS "[${HOOK_EXTERNAL_NAME}]   Targets: Catch2, Catch2WithMain")
```

---

## 2.4 Test-Executable konfigurieren

**Solution.json:**

```json
{
    "tests": [
        {
            "name": "MyTests",
            "path": "projects/tests/MyTests/src",
            "externals": ["catch2"],
            "framework": "catch2"
        }
    ]
}
```

---

## 2.5 Beispiel-Testdatei

**Pfad:** `projects/tests/MyTests/src/main.cpp`

**Mit Catch2WithMain (empfohlen):**

```cpp
#include <catch2/catch_test_macros.hpp>

TEST_CASE("Factorials are computed", "[factorial]") {
    REQUIRE(1 == 1);
    REQUIRE(2 * 3 == 6);
    REQUIRE(3 * 4 * 5 == 60);
}

TEST_CASE("Vectors can be sized and resized", "[vector]") {
    std::vector<int> v(5);

    REQUIRE(v.size() == 5);
    REQUIRE(v.capacity() >= 5);

    SECTION("resizing bigger changes size and capacity") {
        v.resize(10);

        REQUIRE(v.size() == 10);
        REQUIRE(v.capacity() >= 10);
    }
    
    SECTION("resizing smaller changes size but not capacity") {
        v.resize(0);

        REQUIRE(v.size() == 0);
        REQUIRE(v.capacity() >= 5);
    }
}

// Kein main() nötig mit Catch2WithMain!
```

**Mit eigenem main():**

```cpp
#include <catch2/catch_session.hpp>
#include <catch2/catch_test_macros.hpp>

TEST_CASE("Simple test") {
    REQUIRE(1 + 1 == 2);
}

int main(int argc, char* argv[]) {
    return Catch::Session().run(argc, argv);
}
```

---

## 2.6 Catch2 v3 Features

**BDD-Style Tests:**

```cpp
#include <catch2/catch_test_macros.hpp>

SCENARIO("vectors can be sized and resized", "[vector]") {
    GIVEN("A vector with some items") {
        std::vector<int> v(5);

        REQUIRE(v.size() == 5);
        REQUIRE(v.capacity() >= 5);

        WHEN("the size is increased") {
            v.resize(10);

            THEN("the size and capacity change") {
                REQUIRE(v.size() == 10);
                REQUIRE(v.capacity() >= 10);
            }
        }
    }
}
```

**Matchers:**

```cpp
#include <catch2/catch_test_macros.hpp>
#include <catch2/matchers/catch_matchers_string.hpp>

using Catch::Matchers::ContainsSubstring;
using Catch::Matchers::StartsWith;

TEST_CASE("String matchers") {
    std::string str = "Hello, World!";
    
    REQUIRE_THAT(str, ContainsSubstring("World"));
    REQUIRE_THAT(str, StartsWith("Hello"));
}
```

**Benchmarks:**

```cpp
#include <catch2/catch_test_macros.hpp>
#include <catch2/benchmark/catch_benchmark.hpp>

TEST_CASE("Benchmarks") {
    BENCHMARK("Vector creation") {
        return std::vector<int>(1000);
    };
    
    BENCHMARK_ADVANCED("Vector with reserve")(Catch::Benchmark::Chronometer meter) {
        std::vector<int> v;
        meter.measure([&v] {
            v.reserve(1000);
            for (int i = 0; i < 1000; ++i) {
                v.push_back(i);
            }
        });
    };
}
```

---

## 2.7 CMake-Verknüpfung

```cmake
# Empfohlen: Mit automatischem main()
target_link_libraries(MyTests PRIVATE Catch2::Catch2WithMain)

# Oder: Mit eigenem main()
target_link_libraries(MyTests PRIVATE Catch2::Catch2)
```

---

## 2.8 Testen

```bash
# Konfigurieren
cmake --preset msvc-debug

# Bauen
cmake --build build/msvc-debug --target MyTests

# Ausführen
./build/msvc-debug/tests/MyTests/Debug/MyTests.exe

# Mit mehr Details
./MyTests.exe --success

# Bestimmte Tests
./MyTests.exe "[vector]"

# Als Liste
./MyTests.exe --list-tests
```

**Erwartete Ausgabe:**
```
===============================================================================
All tests passed (5 assertions in 2 test cases)
```

---

# Vergleich: GoogleTest vs Catch2

| Aspekt | GoogleTest | Catch2 |
|--------|------------|--------|
| **Syntax** | `TEST()`, `EXPECT_*`, `ASSERT_*` | `TEST_CASE()`, `REQUIRE()`, `CHECK()` |
| **Mocking** | ✅ Integriert (GMock) | ❌ Extern (z.B. Trompeloeil) |
| **BDD-Style** | ❌ Nein | ✅ `SCENARIO`, `GIVEN`, `WHEN`, `THEN` |
| **Sections** | ❌ Nein | ✅ `SECTION()` |
| **Matchers** | ✅ | ✅ |
| **Benchmarks** | ❌ (Google Benchmark separat) | ✅ Integriert |
| **Header-only** | ❌ | ❌ (v3) |
| **Windows CRT** | ⚠️ Braucht `gtest_force_shared_crt` | ✅ Problemlos |
| **Compile-Zeit** | Schneller | Langsamer |

**Empfehlung:**
- **GoogleTest** wenn Mocking wichtig ist
- **Catch2** für einfachere Syntax und BDD-Style

---

## Dateien-Übersicht

Nach dem Tutorial hast du:

```
cmake/externals/Hooks/PreFetch/
├── googletest.cmake    ← GoogleTest PreFetch Hook
└── catch2.cmake        ← Catch2 PreFetch Hook

projects/tests/MyTests/src/
└── main.cpp            ← Test-Datei

Solution.json           ← External + Test konfiguriert
```

---

## Siehe auch

- [Adding_Externals_UserGuide](Adding_Externals_UserGuide_v0_1_0.md) – Generische Anleitung
- [Git_Externals_Reference](../References/Git_Externals_Reference_v0_1_0.md) – Alle Externals
- [GoogleTest Primer](https://google.github.io/googletest/primer.html)
- [Catch2 Tutorial](https://github.com/catchorg/Catch2/blob/devel/docs/tutorial.md)

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-10** | **Initial: GoogleTest + Catch2 Tutorial mit PreFetch Hooks** |
