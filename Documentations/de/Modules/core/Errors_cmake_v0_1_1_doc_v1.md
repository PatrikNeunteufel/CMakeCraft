# Errors.cmake – Dokumentation

> **Version:** 0.1.1 (doc v1)  
> **Datum:** 2025-12-05  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/core/Errors.cmake  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** master_concept v0.1, guidelines v0.1, ErrorCodes v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Modules/core/Errors_cmake_v0_1_0.md)

---

## 1. Übersicht

Das `Errors.cmake` Modul stellt ein **einheitliches Error-Handling** für das gesamte Build-System bereit. Es definiert standardisierte Funktionen für fatale Fehler, Warnungen und Assertions.

**Kernidee:** Alle Fehler verwenden standardisierte Codes (E0xx, W0xx, etc.) für konsistente, nachvollziehbare Fehlermeldungen.

---

## 2. Abhängigkeiten

| Modul | Version | Verwendung |
|-------|---------|------------|
| - | - | Keine (Basis-Modul, muss als erstes geladen werden) |

**Hinweis:** `cmake_require_field()` benötigt `Context.cmake`, aber dieses muss erst nach Errors.cmake geladen werden.

---

## 3. Konzept

### 3.1 Fehlercode-Kategorien

| Bereich | Codes | Beschreibung |
|---------|-------|--------------|
| JSON/Parsing | `E0xx` | Fehlende Pflichtfelder, ungültiges JSON |
| Target-Erstellung | `E1xx` | Target existiert, Abhängigkeit fehlt |
| Externals | `E2xx` | Fetch fehlgeschlagen, Include.cmake fehlt |
| Deprecation | `W0xx` | Veraltete Features/Syntax |
| Config/Validation | `W1xx` | Suboptimale Einstellungen |
| Tools/Setup | `W2xx` | Fehlende Tools |

### 3.2 Fehler vs. Warnung vs. Assertion

| Funktion | Verhalten | Verwendung |
|----------|-----------|------------|
| `cmake_fatal()` | Bricht Build ab | User-Fehler, fehlende Pflichtfelder |
| `cmake_warn()` | Build läuft weiter | Deprecated, suboptimale Config |
| `cmake_assert()` | Bricht ab wenn falsch | Interne Konsistenz-Checks |

---

## 4. API-Referenz

### 4.1 cmake_fatal()

Bricht den Build mit einem Fehlercode ab.

```cmake
cmake_fatal(<CODE> <MESSAGE>)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| CODE | String | Fehlercode (z.B. `E001`, `E012`) |
| MESSAGE | String | Fehlerbeschreibung |

**Ausgabe:**
```
CMake Error at cmake/core/Errors.cmake:19 (message):
  [E001] Executable 'MyApp': Pflichtfeld 'name' fehlt
```

**Beispiele:**

```cmake
# Pflichtfeld fehlt
cmake_fatal("E001" "Executable 'MyApp': Pflichtfeld 'name' fehlt")

# Solution.json nicht gefunden
cmake_fatal("E002" "Solution.json nicht gefunden: ${CMAKE_SOURCE_DIR}/Solution.json")

# External ohne Source
cmake_fatal("E012" "External 'imgui': Kein Source-Feld (path/git) angegeben")
```

---

### 4.2 cmake_warn()

Gibt eine Warnung aus, Build läuft weiter.

```cmake
cmake_warn(<CODE> <MESSAGE>)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| CODE | String | Warnungscode (z.B. `W001`, `W201`) |
| MESSAGE | String | Warnungsbeschreibung |

**Ausgabe:**
```
CMake Warning at cmake/core/Errors.cmake:24 (message):
  [W001] Schema-Version 1.1 < 1.2, einige Features nicht verfügbar
```

**Beispiele:**

```cmake
# Veraltete Schema-Version
cmake_warn("W001" "Schema-Version ${_ver} < 0.1")

# Clang-Tidy nicht gefunden
cmake_warn("W201" "ENABLE_CLANG_TIDY=ON but clang-tidy not found")

# Suboptimale Konfiguration
cmake_warn("W101" "PCH deaktiviert, Build könnte langsamer sein")
```

---

### 4.3 cmake_assert()

Prüft eine Bedingung und bricht bei Fehler ab.

```cmake
cmake_assert(<CONDITION> <MESSAGE>)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| CONDITION | CMake-Ausdruck | Wird mit `if(NOT ...)` geprüft |
| MESSAGE | String | Fehlerbeschreibung |

**Hinweis:** Ist ein `macro()`, nicht `function()`, um Condition korrekt auszuwerten.

**Beispiele:**

```cmake
# Variable muss definiert sein
cmake_assert(DEFINED _internal_var "Interner Fehler: _internal_var nicht gesetzt")

# String-Vergleich
cmake_assert("${_type}" STREQUAL "CONSOLE" "Unerwarteter Typ: ${_type}")

# Numerisch
cmake_assert(_count GREATER 0 "Count muss > 0 sein")
```

---

### 4.4 cmake_require_field()

Validiert, dass ein Feld in einem Context gesetzt ist.

```cmake
cmake_require_field(<CTX> <FIELD_NAME> <ENTITY_TYPE>)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| CTX | String | Context-Prefix (z.B. `EXE_0`) |
| FIELD_NAME | String | Zu prüfendes Feld |
| ENTITY_TYPE | String | Typ für Fehlermeldung |

**Abhängigkeit:** Benötigt `Context.cmake` (ctx_get).

**Beispiel:**

```cmake
ctx_create(EXE_0)
ctx_set(EXE_0 NAME "MyApp")
# ctx_set(EXE_0 PATH "...")  # Fehlt!

cmake_require_field(EXE_0 PATH "Executable")
# → [E001] Executable 'MyApp' hat kein 'PATH' Feld
```

---

## 5. Verwendungsbeispiele

### 5.1 Pflichtfeld-Validierung

```cmake
function(_collect_executable EXE_JSON CTX)
    _json_get_string("${EXE_JSON}" "name" _name)
    
    if("${_name}" STREQUAL "")
        cmake_fatal("E001" "Executable: Pflichtfeld 'name' fehlt")
    endif()
    
    ctx_set(${CTX} NAME "${_name}")
endfunction()
```

### 5.2 External-Validierung

```cmake
function(validate_external EXT_NAME EXT_JSON)
    _json_has_key("${EXT_JSON}" "path" _has_path)
    _json_has_key("${EXT_JSON}" "git" _has_git)
    
    if(NOT _has_path AND NOT _has_git)
        cmake_fatal("E012" "External '${EXT_NAME}': Kein Source-Feld")
    endif()
endfunction()
```

### 5.3 Schema-Version prüfen

```cmake
_json_get_string("${_json}" "schemaVersion" _version)

if(NOT "${_version}" VERSION_GREATER_EQUAL "0.1")
    cmake_warn("W001" "Schema-Version ${_version} < 0.1")
endif()
```

### 5.4 Interne Assertions

```cmake
function(_internal_process DATA)
    # Interne Konsistenz prüfen
    cmake_assert(DEFINED DATA "DATA muss übergeben werden")
    cmake_assert(NOT "${DATA}" STREQUAL "" "DATA darf nicht leer sein")
    
    # ... Verarbeitung ...
endfunction()
```

---

## 6. Best Practices

### 6.1 Immer Fehlercode verwenden

```cmake
# ✅ Gut
cmake_fatal("E012" "External 'foo': Kein Source-Feld")

# ❌ Schlecht
message(FATAL_ERROR "External 'foo': Kein Source-Feld")
```

### 6.2 Aussagekräftige Fehlermeldungen

```cmake
# ✅ Gut - enthält Kontext
cmake_fatal("E001" "Executable 'MyApp': Pflichtfeld 'path' fehlt")

# ❌ Schlecht - kein Kontext
cmake_fatal("E001" "Pflichtfeld fehlt")
```

### 6.3 Assertions nur für interne Checks

```cmake
# ✅ Für interne Konsistenz
cmake_assert(DEFINED _internal "Interner Fehler")

# ❌ Nicht für User-Fehler
cmake_assert(_user_input "...")  # → cmake_fatal verwenden!
```

### 6.4 Früh validieren

```cmake
function(process_target NAME PATH)
    # ✅ Validierung am Anfang
    if("${NAME}" STREQUAL "")
        cmake_fatal("E001" "NAME ist Pflicht")
    endif()
    
    # Dann erst Verarbeitung...
endfunction()
```

---

## 7. Siehe auch

- [ErrorCodes](../References/ErrorCodes_v0_1_0.md) – Vollständige Fehlercode-Referenz
- [Debug.cmake](Debug_cmake_v0_1_0_doc_v1.md) – Debug-Ausgaben (nicht für Fehler)
- [Context.cmake](Context_cmake_v0_1_0_doc_v1.md) – Context für cmake_require_field

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.1** | **2025-12-05** | **English translation (Language Standards v0.1.1)** |
| **0.1.0 (doc v1)** | **2025-12-04** | **Initial (Clean Start): cmake_fatal, cmake_warn, cmake_assert, cmake_require_field** |
