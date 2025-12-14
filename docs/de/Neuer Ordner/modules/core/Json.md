# Json.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/core/Json.cmake](../../../cmake/core/Json.cmake)  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [Json.md](../../en/modules/core/Json.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [Konzept](#3-konzept)
4. [API-Referenz](#4-api-referenz)
5. [Verwendungsbeispiele](#5-verwendungsbeispiele)
6. [Fehlerbehandlung](#6-fehlerbehandlung)
7. [Best Practices](#7-best-practices)
8. [Bekannte Einschränkungen](#8-bekannte-einschränkungen)
9. [Siehe auch](#9-siehe-auch)
10. [Changelog](#10-changelog)

---

## 1. Übersicht

Das `Json.cmake` Modul stellt JSON-Hilfsfunktionen bereit, die CMake's native JSON-Unterstützung (ab 3.19) kapseln und vereinfachen.

### Features

- Typsichere Zugriffsfunktionen
- Robuste Boolean-Erkennung
- Leere Defaults bei fehlenden Keys
- Array- und Object-Handling

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| CMake 3.19+ | System | Native JSON-Unterstützung |

---

## 3. Konzept

### 3.1 Robuste Boolean-Erkennung

**TRUE-Werte:** `true`, `TRUE`, `1`, `ON`, `YES`  
**FALSE-Werte:** `false`, `FALSE`, `0`, `OFF`, `NO`, leer, Key fehlt

---

## 4. API-Referenz

### 4.1 _json_has_key()

Prüft ob ein Key existiert.

```cmake
_json_has_key(JSON_STRING KEY OUT_VAR)
```

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `JSON_STRING` | ✓ | JSON-Objekt als String |
| `KEY` | ✓ | Zu prüfender Key |
| `OUT_VAR` | ✓ | TRUE wenn Key existiert |

---

### 4.2 _json_get_string()

Liest einen String-Wert.

```cmake
_json_get_string(JSON_STRING KEY OUT_VAR)
```

**Rückgabe:** Leerer String wenn Key fehlt.

---

### 4.3 _json_get_string_or_default()

Liest String mit Fallback-Default.

```cmake
_json_get_string_or_default(JSON_STRING KEY DEFAULT OUT_VAR)
```

---

### 4.4 _json_get_bool_from_key()

Liest Boolean mit robuster Erkennung.

```cmake
_json_get_bool_from_key(JSON_STRING KEY OUT_VAR)
```

**Rückgabe:** TRUE oder FALSE (CMake Boolean).

---

### 4.5 _json_array_length()

Gibt Array-Länge zurück.

```cmake
_json_array_length(JSON_STRING KEY OUT_VAR)
```

**Rückgabe:** 0 wenn Array fehlt.

---

### 4.6 _json_array_get()

Liest Array-Element.

```cmake
_json_array_get(JSON_STRING KEY INDEX OUT_VAR)
```

---

### 4.7 _json_get_object()

Extrahiert verschachteltes Objekt.

```cmake
_json_get_object(JSON_STRING KEY OUT_VAR)
```

---

### 4.8 _json_get_object_or_empty()

Extrahiert Objekt oder gibt `{}` zurück.

```cmake
_json_get_object_or_empty(JSON_STRING KEY OUT_VAR)
```

---

### 4.9 _json_get_type()

Ermittelt JSON-Typ.

```cmake
_json_get_type(JSON_STRING KEY OUT_VAR)
```

**Rückgabewerte:** `NULL`, `BOOLEAN`, `NUMBER`, `STRING`, `ARRAY`, `OBJECT`

---

## 5. Verwendungsbeispiele

### 5.1 Executable parsen

```cmake
_json_get_string("${_exe_json}" "name" _name)
_json_get_string_or_default("${_exe_json}" "version" "0.1.0" _version)
_json_get_bool_from_key("${_exe_json}" "skip" _skip)

# Array iterieren
_json_array_length("${_exe_json}" "dependencies" _dep_count)
if(_dep_count GREATER 0)
    math(EXPR _last "${_dep_count} - 1")
    foreach(_idx RANGE 0 ${_last})
        _json_array_get("${_exe_json}" "dependencies" ${_idx} _dep)
        list(APPEND _dependencies "${_dep}")
    endforeach()
endif()
```

---

## 6. Fehlerbehandlung

Bei Fehlern werden leere Werte oder 0 zurückgegeben, keine Exceptions.

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| Pflichtfelder explizit prüfen | Blind auf Werte vertrauen |
| `_json_get_string_or_default()` für Optionales | Manuelle if-else Defaults |
| `_json_get_bool_from_key()` für Booleans | String-Vergleiche für true/false |
| Array-Länge vor Iteration prüfen | Blind über Arrays iterieren |

---

## 8. Bekannte Einschränkungen

- Keine Nested Array Unterstützung
- Keine JSON-Validierung
- String-basierte Rückgaben

---

## 9. Siehe auch

- [Context.cmake](Context.md) — Speichert geparste JSON-Daten
- [Validation.cmake](Validation.md) — Schema-Validierung
- [Solution.cmake](../project/Solution.md) — Verwendet Json.cmake

---

## 10. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.1 | 2025-12-05 | English translation |
| 0.1.0 | 2025-12-03 | Initial: Robuste Boolean-Erkennung, vollständige API |
