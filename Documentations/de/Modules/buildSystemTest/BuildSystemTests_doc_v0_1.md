# Build System Tests – Dokumentation

> **Version:** 0.1.0  
> **Datum:** 2025-12-05  
> **Pfad:** `cmake/buildSystemTest/`  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, guidelines v0.1

---

## 1. Übersicht

Die Build-System-Tests validieren die korrekte Funktionsweise der CMake-Module während der Configure-Phase. Sie sind **keine Unit-Tests für C++ Code**, sondern Tests für das Build-System selbst.

### Zweck

- Verifizierung der Core-Module (Phase 1)
- Verifizierung der Solution-Verarbeitung (Phase 2)
- Verifizierung der Pipelines (Phase 3+)
- Frühe Fehlererkennung bei Modul-Änderungen

---

## 2. Aktivierung

### 2.1 Standard (aktiviert)

```bash
cmake -B build
# Tests laufen automatisch
```

### 2.2 Deaktivieren

```bash
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=OFF
```

### 2.3 Spezifische Phase testen

```bash
cmake -B build -DTEST_PHASE=2
```

### 2.4 Mehrere Phasen

```bash
cmake -B build -DTEST_PHASE="1;3"
```

---

## 3. Verfügbare Tests

### 3.1 Phase 1: Core-Module

**Datei:** `cmake/buildSystemTest/phase1.cmake`

| Test | Beschreibung |
|------|--------------|
| Context API | `ctx_create`, `ctx_set`, `ctx_get` |
| JSON Helpers | `_json_has_key`, `_json_get_string`, etc. |
| Debug System | `dbg_init`, `dbg`, `dbgspace`, `enddbgblock` |
| Warning System | `cmake_warn` (non-fatal) |

### 3.2 Phase 2: Solution-Konfiguration

**Datei:** `cmake/buildSystemTest/phase2.cmake`

| Test | Beschreibung |
|------|--------------|
| Solution Properties | NAME, VERSION, DESCRIPTION, AUTHORS |
| Settings Properties | CXX_STANDARD, DEFAULT_LIBRARY_TYPE, SOURCE_MODE |
| CMake Variables | CMAKE_CXX_STANDARD, CMAKE_CXX_EXTENSIONS |
| Externals Policy | CACHE_ROOT, SOURCE_ROOT, UPDATE_POLICY |
| Externals JSON | JSON-Block verfügbar und nicht leer |
| project() Kompatibilität | PROJECT_NAME == SOLUTION_NAME |

### 3.3 Phase 3: Executable-Pipeline

**Datei:** `cmake/buildSystemTest/phase3.cmake`

| Test | Beschreibung |
|------|--------------|
| Module geladen | `_collect_executable`, `_create_executable_target` |
| Executable-Definitionen | executables-Array in Solution.json |
| Context-Sammlung | Alle Felder korrekt extrahiert |
| Default-Werte | PATH, TYPE automatisch gesetzt |
| Target-Erstellung | CMake-Targets wurden erstellt |

---

## 4. Test-Struktur

### 4.1 Datei-Layout

```cmake
# cmake/buildSystemTest/phaseN.cmake

include_guard(GLOBAL)

# Debug-Context initialisieren
dbg_init(ID PHASEN_TEST LEVEL ${DBG_SHOW_ALL} SWITCH ON TAG "PhaseN")
dbg(${DBG_OFTEN} "=== Phase N Test Start ===" ID PHASEN_TEST)

# Test 1
dbg(${DBG_COMMON} "Testing Feature X..." ID PHASEN_TEST)
# ... Assertions ...
dbg(${DBG_COMMON} "  Feature X works" ID PHASEN_TEST)

# Test 2
dbg(${DBG_COMMON} "Testing Feature Y..." ID PHASEN_TEST)
# ... Assertions ...
dbg(${DBG_COMMON} "  Feature Y works" ID PHASEN_TEST)

# Ergebnis
dbgspace(ID PHASEN_TEST)
dbg(${DBG_OFTEN} "=== Phase N Test PASSED ===" ID PHASEN_TEST)
enddbgblock(ID PHASEN_TEST)

# Erfolgs-Flag
set(PHASEN_TEST_PASSED TRUE CACHE BOOL "Phase N Test passed" FORCE)
```

### 4.2 Assertions

Bei fehlgeschlagenen Tests wird `cmake_fatal()` aufgerufen:

```cmake
if(NOT "${_actual}" STREQUAL "${_expected}")
    cmake_fatal("ASSERT" "Expected '${_expected}', got '${_actual}'")
endif()
```

---

## 5. Ausgabe

### 5.1 Erfolgreiche Tests

```
-- [Phase1] === Phase 1 Test Start ===
-- [Phase1] Testing Context API...
-- [Phase1]   Context API works
-- [Phase1] Testing JSON Helpers...
-- [Phase1]   JSON Helpers work
-- [Phase1] Testing Debug System...
-- [Phase1]   Debug System works
-- [Phase1] Testing Warning System...
-- [W999] Test warning (expected, can be ignored)
-- [Phase1]   Warning System works
-- 
-- [Phase1] === Phase 1 Test PASSED ===
-- -------------------------------------------
```

### 5.2 Fehlgeschlagene Tests

```
-- [Phase2] Testing Solution Properties...
CMake Error: [ASSERT] SOLUTION_NAME not set
-- Configuring incomplete, errors occurred!
```

---

## 6. Erfolgs-Flags

Nach jedem erfolgreichen Test wird ein Cache-Flag gesetzt:

| Phase | Flag |
|-------|------|
| 1 | `PHASE1_TEST_PASSED` |
| 2 | `PHASE2_TEST_PASSED` |
| 3 | `PHASE3_TEST_PASSED` |

Diese können in anderen Modulen geprüft werden:

```cmake
if(NOT PHASE1_TEST_PASSED)
    message(WARNING "Phase 1 tests did not pass")
endif()
```

---

## 7. Neue Tests hinzufügen

### 7.1 Neue Phase

1. `cmake/buildSystemTest/phaseN.cmake` erstellen
2. In `CMakeLists.txt` registrieren:

```cmake
if("${TEST_PHASE}" STREQUAL "" OR "N" IN_LIST TEST_PHASE)
    dbgspace(ID BUILD_TEST)
    include(cmake/buildSystemTest/phaseN.cmake)
endif()
```

### 7.2 Test zu bestehender Phase hinzufügen

```cmake
# In phaseN.cmake

dbg(${DBG_COMMON} "Testing New Feature..." ID PHASEN_TEST)

# Durchführung
_some_function(...)

# Assertion
if(NOT _condition)
    cmake_fatal("ASSERT" "New Feature failed: expected X, got Y")
endif()

dbg(${DBG_COMMON} "  New Feature works" ID PHASEN_TEST)
```

---

## 8. Best Practices

### 8.1 Aussagekräftige Assertions

```cmake
# ❌ Schlecht
if(NOT _result)
    cmake_fatal("ASSERT" "Test failed")
endif()

# ✅ Gut
if(NOT "${_result}" STREQUAL "expected_value")
    cmake_fatal("ASSERT" "Context NAME mismatch: expected 'expected_value', got '${_result}'")
endif()
```

### 8.2 Warnings für nicht-kritische Probleme

```cmake
# Kritisch → Fatal
if("${_required_value}" STREQUAL "")
    cmake_fatal("ASSERT" "Required value not set")
endif()

# Nicht kritisch → Warn
if(_count EQUAL 0)
    cmake_warn("W999" "No items found (optional)")
endif()
```

### 8.3 Tests isolieren

Tests sollten keine globalen Variablen verschmutzen:

```cmake
# Test-spezifische Variablen
set(_test_json "{...}")
ctx_create(TEST_CTX)

# Nach dem Test nicht aufräumen nötig (lokaler Scope)
```

---

## 9. Siehe auch

- [CMakeLists.txt](CMakeLists_doc_v0_1.md) – Integration
- [Debug.cmake](Modules/Debug_cmake_v0_1_0_doc_v0_1.md) – Debug-System
- [Errors.cmake](Modules/Errors_cmake_v0_1_0_doc_v0_1.md) – Fehlerbehandlung

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-05** | **Initial: Phase 1-3 Tests, Englische Kommentare** |
