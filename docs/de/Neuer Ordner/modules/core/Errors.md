# Errors.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/core/Errors.cmake](../../../cmake/core/Errors.cmake)  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [Errors.md](../../en/modules/core/Errors.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [Konzept](#3-konzept)
4. [API-Referenz](#4-api-referenz)
5. [Verwendungsbeispiele](#5-verwendungsbeispiele)
6. [Fehlerbehandlung](#6-fehlerbehandlung)
7. [Best Practices](#7-best-practices)
8. [Siehe auch](#8-siehe-auch)
9. [Changelog](#9-changelog)

---

## 1. Übersicht

Das `Errors.cmake` Modul stellt ein **einheitliches Error-Handling** für das gesamte Build-System bereit. Es definiert standardisierte Funktionen für fatale Fehler, Warnungen und Assertions.

### Features

- Standardisierte Fehlercodes (E0xx, W0xx, etc.)
- Konsistente, nachvollziehbare Fehlermeldungen
- Assertions für interne Konsistenzprüfungen
- Pflichtfeld-Validierung für Context-Objekte

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| CMake 3.19+ | System | Basis |

**Hinweis:** Dies ist das Basis-Modul und muss als erstes geladen werden. `cmake_require_field()` benötigt `Context.cmake`, aber dieses wird erst nach Errors.cmake geladen.

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

**Beschreibung:**  
Gibt eine formatierte Fehlermeldung aus und beendet die CMake-Konfiguration.

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `CODE` | ✓ | Fehlercode (z.B. `E001`, `E012`) |
| `MESSAGE` | ✓ | Fehlerbeschreibung |

**Rückgabe:**  
Keine — Build wird abgebrochen.

**Beispiel:**

```cmake
cmake_fatal("E001" "Executable 'MyApp': Pflichtfeld 'name' fehlt")
cmake_fatal("E002" "Solution.json nicht gefunden")
cmake_fatal("E012" "External 'imgui': Kein Source-Feld angegeben")
```

**Ausgabe:**
```
CMake Error at cmake/core/Errors.cmake:19 (message):
  [E001] Executable 'MyApp': Pflichtfeld 'name' fehlt
```

---

### 4.2 cmake_warn()

Gibt eine Warnung aus, Build läuft weiter.

```cmake
cmake_warn(<CODE> <MESSAGE>)
```

**Beschreibung:**  
Gibt eine formatierte Warnung aus ohne den Build abzubrechen.

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `CODE` | ✓ | Warnungscode (z.B. `W001`, `W201`) |
| `MESSAGE` | ✓ | Warnungsbeschreibung |

**Rückgabe:**  
Keine — Build läuft weiter.

**Beispiel:**

```cmake
cmake_warn("W001" "Schema-Version ${_ver} < 0.1")
cmake_warn("W201" "ENABLE_CLANG_TIDY=ON but clang-tidy not found")
cmake_warn("W101" "PCH deaktiviert, Build könnte langsamer sein")
```

---

### 4.3 cmake_assert()

Prüft eine Bedingung und bricht bei Fehler ab.

```cmake
cmake_assert(<CONDITION> <MESSAGE>)
```

**Beschreibung:**  
Prüft die Bedingung mit `if(NOT ...)` und bricht bei false ab. Ist ein `macro()`, nicht `function()`, um Condition korrekt auszuwerten.

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `CONDITION` | ✓ | CMake-Ausdruck |
| `MESSAGE` | ✓ | Fehlerbeschreibung |

**Rückgabe:**  
Keine — bricht ab wenn Bedingung false.

**Beispiel:**

```cmake
cmake_assert(DEFINED _internal_var "Interner Fehler: _internal_var nicht gesetzt")
cmake_assert("${_type}" STREQUAL "CONSOLE" "Unerwarteter Typ: ${_type}")
cmake_assert(_count GREATER 0 "Count muss > 0 sein")
```

---

### 4.4 cmake_require_field()

Validiert, dass ein Feld in einem Context gesetzt ist.

```cmake
cmake_require_field(<CTX> <FIELD_NAME> <ENTITY_TYPE>)
```

**Beschreibung:**  
Prüft ob ein Feld im Context existiert und nicht leer ist.

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `CTX` | ✓ | Context-Prefix (z.B. `EXE_0`) |
| `FIELD_NAME` | ✓ | Zu prüfendes Feld |
| `ENTITY_TYPE` | ✓ | Typ für Fehlermeldung |

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

---

## 6. Fehlerbehandlung

Dieses Modul **definiert** das Error-Handling-System und wirft selbst keine spezifischen Fehler.

---

## 7. Best Practices

### 7.1 Immer Fehlercode verwenden

```cmake
# ✅ Gut
cmake_fatal("E012" "External 'foo': Kein Source-Feld")

# ❌ Schlecht
message(FATAL_ERROR "External 'foo': Kein Source-Feld")
```

### 7.2 Aussagekräftige Fehlermeldungen

```cmake
# ✅ Gut - enthält Kontext
cmake_fatal("E001" "Executable 'MyApp': Pflichtfeld 'path' fehlt")

# ❌ Schlecht - kein Kontext
cmake_fatal("E001" "Pflichtfeld fehlt")
```

### 7.3 Assertions nur für interne Checks

```cmake
# ✅ Für interne Konsistenz
cmake_assert(DEFINED _internal "Interner Fehler")

# ❌ Nicht für User-Fehler
cmake_assert(_user_input "...")  # → cmake_fatal verwenden!
```

### 7.4 Früh validieren

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

## 8. Siehe auch

- [ErrorCodes](../reference/ErrorCodes.md) — Vollständige Fehlercode-Referenz
- [Debug.cmake](Debug.md) — Debug-Ausgaben
- [Context.cmake](Context.md) — Context für cmake_require_field

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.1 | 2025-12-05 | English translation |
| 0.1.0 | 2025-12-04 | Initial: cmake_fatal, cmake_warn, cmake_assert, cmake_require_field |
