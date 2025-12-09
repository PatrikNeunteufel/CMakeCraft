# Validation.cmake – Dokumentation

> **Version:** 0.1.1 (doc v1)  
> **Datum:** 2025-12-05  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/core/Validation.cmake  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** master_concept v0.1, guidelines v0.1, ErrorCodes v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Modules/core/Validate_cmake_v0_1_0.md)

---

## 1. Übersicht

Das `Validation.cmake` Modul stellt **Validierungsfunktionen** für Solution.json und External-Definitionen bereit. Es prüft Schema-Konformität, Pflichtfelder und Best Practices.

**Kernidee:** Früh validieren, aussagekräftige Fehlermeldungen mit standardisierten Codes.

---

## 2. Abhängigkeiten

| Modul | Version | Verwendung |
|-------|---------|------------|
| Errors.cmake | 0.1+ | `cmake_fatal()`, `cmake_warn()` |
| Json.cmake | 0.1+ | `_json_has_key()`, `_json_get_string()` |

---

## 3. Konzept

### 3.1 Validierungsebenen

| Ebene | Funktionen | Prüft |
|-------|------------|-------|
| **Schema** | `validate_solution_schema()` | Schema-Version |
| **Entity** | `validate_required_fields()` | Pflichtfelder |
| **External** | `validate_external_source()` | Source-Feld |
| **Local** | `validate_local_external()` | Include.cmake |
| **Fetched** | `validate_fetched_external()` | tag/branch/commit |
| **Best Practice** | `validate_local_external_include()` | IDE Clutter |

### 3.2 Fehlercode-Zuordnung

| Code | Funktion | Bedeutung |
|------|----------|-----------|
| `E001` | `validate_required_fields` | Pflichtfeld fehlt |
| `E012` | `validate_external_source` | Kein/Mehrere Source-Felder |
| `E213` | `validate_local_external` | Include.cmake nicht gefunden |
| `E215` | `validate_fetched_external` | Kein tag/branch/commit |
| `W001` | `validate_solution_schema` | Schema-Version Warnung |
| `W103` | `validate_local_external_include` | add_executable gefunden |
| `W104` | `validate_local_external_include` | Beispiel-Verzeichnisse |

---

## 4. API-Referenz

### 4.1 validate_external_source()

Prüft dass genau ein Source-Feld vorhanden ist.

```cmake
validate_external_source(<EXT_NAME> <EXT_JSON>)
```

**Erlaubte Source-Felder:** `path`, `git`, `vcpkg`, `conan`, `find_package`

**Beispiel:**

```cmake
# ✅ OK - genau ein Source-Feld
set(_json "{\"path\":\"externals/bass\"}")
validate_external_source("bass" "${_json}")

# ❌ E012 - kein Source-Feld
set(_json "{}")
validate_external_source("broken" "${_json}")

# ❌ E012 - mehrere Source-Felder
set(_json "{\"path\":\"x\",\"git\":\"y\"}")
validate_external_source("conflict" "${_json}")
```

---

### 4.2 validate_required_fields()

Prüft dass alle Pflichtfelder existieren.

```cmake
validate_required_fields(<JSON> <ENTITY_TYPE> <ENTITY_NAME> FIELDS <field1> [field2...])
```

**Beispiel:**

```cmake
validate_required_fields("${_exe_json}" "Executable" "MyApp" FIELDS name path)
# → E001 wenn name oder path fehlt
```

---

### 4.3 validate_fetched_external()

Prüft dass Fetched External eine Version hat.

```cmake
validate_fetched_external(<EXT_NAME> <EXT_JSON>)
```

**Prüft auf mindestens eines von:** `tag`, `branch`, `commit`

**Beispiel:**

```cmake
set(_json "{\"git\":\"https://github.com/glfw/glfw.git\",\"tag\":\"3.3.9\"}")
validate_fetched_external("glfw" "${_json}")  # ✅ OK

set(_json "{\"git\":\"https://github.com/glfw/glfw.git\"}")
validate_fetched_external("glfw" "${_json}")  # ❌ E215
```

---

### 4.4 validate_local_external()

Prüft dass Include.cmake existiert.

```cmake
validate_local_external(<EXT_NAME> <EXT_JSON>)
```

**Prüft:**
- Custom `include` Feld oder
- Convention: `${path}/Include.cmake`

**Beispiel:**

```cmake
set(_json "{\"path\":\"externals/bass\"}")
validate_local_external("bass" "${_json}")
# → Prüft: ${CMAKE_SOURCE_DIR}/externals/bass/Include.cmake
```

---

### 4.5 validate_solution_schema()

Prüft Schema-Version der Solution.json.

```cmake
validate_solution_schema(<SOLUTION_JSON>)
```

**Warnungen:**
- `W001` wenn `schemaVersion` fehlt
- `W001` wenn Version < 0.1

**Beispiel:**

```cmake
file(READ "Solution.json" _json)
validate_solution_schema("${_json}")
```

---

### 4.6 validate_local_external_include()

Best-Practice-Checks für Include.cmake.

```cmake
validate_local_external_include(<INCLUDE_FILE> <EXT_NAME>)
```

**Warnungen:**
- `W103` wenn `add_executable()` gefunden
- `W104` wenn `add_subdirectory(examples|tests|...)` gefunden

**Beispiel:**

```cmake
validate_local_external_include("${CMAKE_SOURCE_DIR}/externals/bass/Include.cmake" "bass")
```

---

## 5. Verwendungsbeispiele

### 5.1 Vollständige External-Validierung

```cmake
function(_validate_external EXT_NAME EXT_JSON)
    # 1. Source-Feld prüfen
    validate_external_source("${EXT_NAME}" "${EXT_JSON}")
    
    # 2. Typ-spezifische Validierung
    _json_has_key("${EXT_JSON}" "path" _is_local)
    _json_has_key("${EXT_JSON}" "git" _is_fetched)
    
    if(_is_local)
        validate_local_external("${EXT_NAME}" "${EXT_JSON}")
        
        # Best Practice Check
        _json_get_string("${EXT_JSON}" "path" _path)
        validate_local_external_include(
            "${CMAKE_SOURCE_DIR}/${_path}/Include.cmake" 
            "${EXT_NAME}"
        )
    elseif(_is_fetched)
        validate_fetched_external("${EXT_NAME}" "${EXT_JSON}")
    endif()
endfunction()
```

### 5.2 Solution-Level Validierung

```cmake
file(READ "${CMAKE_SOURCE_DIR}/Solution.json" _json)

# Schema prüfen
validate_solution_schema("${_json}")

# Root-Struktur prüfen
_json_has_key("${_json}" "solution" _has_solution)
if(NOT _has_solution)
    cmake_fatal("E001" "Solution.json: Pflichtfeld 'solution' fehlt")
endif()
```

---

## 6. Best Practices

### 6.1 Früh validieren

```cmake
# ✅ Gut - Validierung bevor Daten verwendet
validate_external_source("${_name}" "${_json}")
_json_get_string("${_json}" "path" _path)

# ❌ Schlecht - zu spät
_json_get_string("${_json}" "path" _path)
# ... Code ...
validate_external_source("${_name}" "${_json}")
```

### 6.2 Aussagekräftige Entity-Namen

```cmake
# ✅ Gut
validate_required_fields("${_json}" "Executable" "${_actual_name}" FIELDS path)

# ❌ Schlecht
validate_required_fields("${_json}" "Entity" "unknown" FIELDS path)
```

### 6.3 Best-Practice-Checks optional

```cmake
if(NOT SKIP_BEST_PRACTICE_CHECKS)
    validate_local_external_include("${_file}" "${_name}")
endif()
```

---

## 7. Siehe auch

- [ErrorCodes](../../References/ErrorCodes_v0_1_0.md) – Vollständige Fehlercode-Referenz
- [Errors.cmake](Errors_cmake_v0_1_0_doc_v1.md) – cmake_fatal, cmake_warn
- [Json.cmake](Json_cmake_v0_1_0_doc_v1.md) – JSON-Hilfsfunktionen

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.1** | **2025-12-05** | **English translation (Language Standards v0.1.1)** |
| **0.1.0 (doc v1)** | **2025-12-04** | **Initial (Clean Start): 6 Validierungsfunktionen, Schema 0.1 Kompatibilität** |
