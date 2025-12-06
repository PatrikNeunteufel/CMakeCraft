# Json.cmake – Dokumentation

> **Version:** 0.1.1 (doc v1)  
> **Datum:** 2025-12-05  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/core/Json.cmake  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** master_concept v0.1, guidelines v0.1
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Modules/core/JSON_cmake_v0_1_0.md)

---

## 1. Übersicht

Das `Json.cmake` Modul stellt JSON-Hilfsfunktionen bereit, die CMake's native JSON-Unterstützung (ab 3.19) kapseln und vereinfachen. Es bietet typsichere Zugriffsfunktionen für Strings, Booleans, Arrays und verschachtelte Objekte.

---

## 2. Abhängigkeiten

| Modul | Version | Verwendung |
|-------|---------|------------|
| - | - | Keine Abhängigkeiten (Basis-Modul) |

**CMake-Voraussetzung:** CMake 3.19+ (native JSON-Unterstützung)

---

## 3. Konzept

### 3.1 CMake JSON-Besonderheiten

CMake's `string(JSON ...)` hat einige Eigenheiten die dieses Modul abstrahiert:

| Eigenheit | CMake-Verhalten | Json.cmake-Lösung |
|-----------|-----------------|-------------------|
| Boolean als String | `true` → `"true"` | Robuste Boolean-Erkennung |
| Fehlende Keys | Fehler | Leere Defaults |
| Typ-Checks | Komplex | Einfache Type-Funktionen |

### 3.2 Robuste Boolean-Erkennung

CMake's `string(JSON GET ...)` gibt für JSON `true`/`false` die Strings `"true"`/`"false"` zurück (lowercase). Die Funktion `_json_get_bool_from_key()` erkennt alle üblichen Varianten:

**TRUE-Werte:** `true`, `TRUE`, `1`, `ON`, `YES`  
**FALSE-Werte:** `false`, `FALSE`, `0`, `OFF`, `NO`, leer, Key fehlt

**Implementierung:**
```cmake
string(TOUPPER "${_value}" _value_upper)
if("${_value_upper}" STREQUAL "TRUE" OR 
   "${_value_upper}" STREQUAL "1" OR 
   "${_value_upper}" STREQUAL "ON" OR 
   "${_value_upper}" STREQUAL "YES")
    set(${OUT_VAR} TRUE PARENT_SCOPE)
else()
    set(${OUT_VAR} FALSE PARENT_SCOPE)
endif()
```

---

## 4. API-Referenz

### 4.1 _json_has_key()

Prüft ob ein Key im JSON-Objekt existiert.

```cmake
_json_has_key(JSON_STRING KEY OUT_VAR)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| JSON_STRING | String | JSON-Objekt als String |
| KEY | String | Zu prüfender Key |
| OUT_VAR | Output | TRUE wenn Key existiert |

**Beispiel:**
```cmake
_json_has_key("${_json}" "name" _has_name)
if(_has_name)
    message(STATUS "Key 'name' existiert")
endif()
```

---

### 4.2 _json_get_string()

Liest einen String-Wert. Gibt leeren String zurück wenn Key fehlt.

```cmake
_json_get_string(JSON_STRING KEY OUT_VAR)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| JSON_STRING | String | JSON-Objekt als String |
| KEY | String | Auszulesender Key |
| OUT_VAR | Output | Gelesener Wert oder "" |

**Beispiel:**
```cmake
_json_get_string("${_json}" "name" _name)
_json_get_string("${_json}" "description" _desc)
```

---

### 4.3 _json_get_string_or_default()

Liest String-Wert mit Fallback-Default.

```cmake
_json_get_string_or_default(JSON_STRING KEY DEFAULT OUT_VAR)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| JSON_STRING | String | JSON-Objekt als String |
| KEY | String | Auszulesender Key |
| DEFAULT | String | Fallback wenn Key fehlt oder leer |
| OUT_VAR | Output | Gelesener Wert oder Default |

**Beispiel:**
```cmake
_json_get_string_or_default("${_json}" "version" "1.0.0" _version)
_json_get_string_or_default("${_json}" "type" "CONSOLE" _type)
```

---

### 4.4 _json_get_bool_from_key()

Liest Boolean-Wert mit robuster Erkennung.

```cmake
_json_get_bool_from_key(JSON_STRING KEY OUT_VAR)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| JSON_STRING | String | JSON-Objekt als String |
| KEY | String | Auszulesender Key |
| OUT_VAR | Output | TRUE oder FALSE (CMake Boolean) |

**Erkannte TRUE-Werte:** `true`, `TRUE`, `1`, `ON`, `YES`  
**Erkannte FALSE-Werte:** `false`, `FALSE`, `0`, `OFF`, `NO`, leer, Key fehlt

**Beispiel:**
```cmake
_json_get_bool_from_key("${_json}" "skip" _skip)
_json_get_bool_from_key("${_json}" "pch.enabled" _pch_enabled)

if(_skip)
    message(STATUS "Überspringe Target")
endif()
```

---

### 4.5 _json_array_length()

Gibt die Länge eines JSON-Arrays zurück.

```cmake
_json_array_length(JSON_STRING KEY OUT_VAR)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| JSON_STRING | String | JSON-Objekt als String |
| KEY | String | Key des Arrays |
| OUT_VAR | Output | Anzahl der Elemente (0 wenn fehlt) |

**Beispiel:**
```cmake
_json_array_length("${_json}" "dependencies" _dep_count)
message(STATUS "${_dep_count} Dependencies")
```

---

### 4.6 _json_array_get()

Liest ein Element aus einem JSON-Array.

```cmake
_json_array_get(JSON_STRING KEY INDEX OUT_VAR)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| JSON_STRING | String | JSON-Objekt als String |
| KEY | String | Key des Arrays |
| INDEX | Integer | 0-basierter Index |
| OUT_VAR | Output | Element-Wert |

**Beispiel:**
```cmake
_json_array_length("${_json}" "externals" _count)

if(_count GREATER 0)
    math(EXPR _last "${_count} - 1")
    foreach(_idx RANGE 0 ${_last})
        _json_array_get("${_json}" "externals" ${_idx} _ext)
        message(STATUS "External: ${_ext}")
    endforeach()
endif()
```

---

### 4.7 _json_get_object()

Extrahiert ein verschachteltes JSON-Objekt als String.

```cmake
_json_get_object(JSON_STRING KEY OUT_VAR)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| JSON_STRING | String | JSON-Objekt als String |
| KEY | String | Key des verschachtelten Objekts |
| OUT_VAR | Output | JSON-String des verschachtelten Objekts |

**Beispiel:**
```cmake
_json_get_object("${_json}" "pch" _pch_obj)
_json_get_bool_from_key("${_pch_obj}" "enabled" _pch_enabled)
_json_get_string_or_default("${_pch_obj}" "header" "pch.h" _pch_header)
```

---

### 4.8 _json_get_object_or_empty()

Wie `_json_get_object`, gibt aber `{}` zurück wenn Key fehlt.

```cmake
_json_get_object_or_empty(JSON_STRING KEY OUT_VAR)
```

**Beispiel:**
```cmake
_json_get_object_or_empty("${_json}" "settings" _settings)
# _settings ist entweder das Objekt oder "{}"
```

---

### 4.9 _json_get_type()

Ermittelt den JSON-Typ eines Keys.

```cmake
_json_get_type(JSON_STRING KEY OUT_VAR)
```

**Rückgabewerte:** `NULL`, `BOOLEAN`, `NUMBER`, `STRING`, `ARRAY`, `OBJECT`

**Beispiel:**
```cmake
_json_get_type("${_json}" "externals" _type)
if("${_type}" STREQUAL "ARRAY")
    # Array-Verarbeitung
elseif("${_type}" STREQUAL "OBJECT")
    # Objekt-Verarbeitung
endif()
```

---

## 5. Verwendungsbeispiele

### 5.1 Executable aus JSON parsen

```cmake
set(_exe_json "{
    \"name\": \"MyApp\",
    \"version\": \"1.0.0\",
    \"type\": \"GUI\",
    \"skip\": false,
    \"pch\": {
        \"enabled\": true,
        \"header\": \"pch.h\"
    },
    \"dependencies\": [\"CoreLib\", \"AudioLib\"],
    \"externals\": [\"imgui\", \"glfw\"]
}")

# Pflichtfeld
_json_get_string("${_exe_json}" "name" _name)
if("${_name}" STREQUAL "")
    cmake_fatal("E001" "Pflichtfeld 'name' fehlt")
endif()

# Optionale Felder mit Defaults
_json_get_string_or_default("${_exe_json}" "version" "0.1.0" _version)
_json_get_string_or_default("${_exe_json}" "type" "CONSOLE" _type)

# Boolean
_json_get_bool_from_key("${_exe_json}" "skip" _skip)

# Verschachteltes Objekt
_json_get_object_or_empty("${_exe_json}" "pch" _pch_obj)
_json_get_bool_from_key("${_pch_obj}" "enabled" _pch_enabled)

# Array iterieren
set(_dependencies "")
_json_array_length("${_exe_json}" "dependencies" _dep_count)
if(_dep_count GREATER 0)
    math(EXPR _last "${_dep_count} - 1")
    foreach(_idx RANGE 0 ${_last})
        _json_array_get("${_exe_json}" "dependencies" ${_idx} _dep)
        list(APPEND _dependencies "${_dep}")
    endforeach()
endif()
```

### 5.2 Externals-Block parsen

```cmake
set(_externals_json "{
    \"imgui\": {
        \"git\": \"https://github.com/ocornut/imgui.git\",
        \"tag\": \"v1.90.1\"
    },
    \"bass\": {
        \"path\": \"externals/bass\"
    }
}")

# Prüfen ob External definiert ist
_json_has_key("${_externals_json}" "imgui" _has_imgui)
if(_has_imgui)
    _json_get_object("${_externals_json}" "imgui" _imgui_obj)
    _json_get_string("${_imgui_obj}" "git" _git_url)
    _json_get_string("${_imgui_obj}" "tag" _git_tag)
endif()
```

---

## 6. Fehlerbehandlung

Das Json.cmake Modul wirft keine eigenen Error Codes. Bei Fehlern (ungültiges JSON, fehlende Keys) werden leere Werte oder 0 zurückgegeben.

**Ungültiges JSON:**
```cmake
set(_invalid "not valid json")
_json_get_string("${_invalid}" "name" _name)
# _name = ""
```

**Fehlende Keys:**
```cmake
_json_get_string("${_json}" "nonexistent" _val)
# _val = ""

_json_array_length("${_json}" "nonexistent" _len)
# _len = 0
```

---

## 7. Best Practices

1. **Pflichtfelder explizit prüfen** – Nach `_json_get_string()` auf leeren String testen
2. **Defaults für optionale Felder** – `_json_get_string_or_default()` verwenden
3. **Booleans über `_json_get_bool_from_key()`** – Nicht manuell String-Vergleiche
4. **Array-Länge vor Iteration prüfen** – `_json_array_length()` vor der Schleife
5. **Verschachtelte Objekte extrahieren** – `_json_get_object()` für Unter-Strukturen

---

## 8. Bekannte Einschränkungen

- **Keine Nested Array Support:** Arrays von Arrays nicht direkt unterstützt
- **Keine JSON-Validierung:** Ungültiges JSON führt zu leeren Werten, nicht zu Fehlern
- **String-basiert:** Alle Werte werden als Strings zurückgegeben

---

## 9. Siehe auch

- [Context.cmake](Context_cmake_v0_1_0_doc_v1.md) – Speichert geparste JSON-Daten
- [Validation.cmake](Validation_cmake_v0_1_0_doc_v1.md) – Schema-Validierung
- [CMake_Blueprint](../Blueprints/CMake_Blueprint_v0_1_0.md) – Modul-Struktur

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.1** | **2025-12-05** | **English translation (Language Standards v0.1.1)** |
| **0.1.0 (doc v1)** | **2025-12-03** | **Initial (Clean Start): Robuste Boolean-Erkennung mit string(TOUPPER), vollständige API-Dokumentation** |
