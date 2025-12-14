# Context.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/core/Context.cmake](../../../cmake/core/Context.cmake)  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [Context.md](../../en/modules/core/Context.md)

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

Das `Context.cmake` Modul implementiert ein **Context-Objekt-Pattern** für isolierte Namensräume. Es ermöglicht die saubere Verwaltung von Target-Daten während der CMake-Konfiguration ohne globale Variablen.

### Features

- Isolierte Namespaces pro Executable/Library/Test
- Zuverlässige Propagation über Funktionsebenen (GLOBAL PROPERTY)
- Debug-Dump für Diagnose

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| CMake 3.19+ | System | Für `include_guard(GLOBAL)` |
| Errors.cmake | Modul | `cmake_assert()` |
| Debug.cmake | Modul | `dbg()` für Debug-Ausgaben |

---

## 3. Konzept

### 3.1 Warum Context-Objekte?

**Problem mit globalen Variablen:**
```cmake
# Schlecht: Globale Variablen
set(EXE_NAME "App1")
set(EXE_PATH "src/app1")
# ... später überschrieben ...
set(EXE_NAME "App2")  # App1-Daten verloren!
```

**Lösung mit Context:**
```cmake
# Gut: Isolierte Namensräume
ctx_create(EXE_0)
ctx_set(EXE_0 NAME "App1")

ctx_create(EXE_1)
ctx_set(EXE_1 NAME "App2")

# Beide existieren parallel
ctx_get(EXE_0 NAME _name)  # "App1"
ctx_get(EXE_1 NAME _name)  # "App2"
```

### 3.2 GLOBAL PROPERTY Implementierung

| Methode | Scope-Propagierung | Problem |
|---------|-------------------|---------|
| `PARENT_SCOPE` | Eine Ebene nach oben | Verschachtelte Funktionen verlieren Werte |
| `GLOBAL PROPERTY` | Überall verfügbar | ✅ Funktioniert über alle Scopes |

### 3.3 Context-Prefixe Konvention

| Prefix | Verwendung |
|--------|------------|
| `EXE_` | Executables (`EXE_0`, `EXE_MyApp`) |
| `LIB_` | Libraries (`LIB_0`, `LIB_CoreLib`) |
| `TEST_` | Tests (`TEST_0`, `TEST_UnitTests`) |

---

## 4. API-Referenz

### 4.1 ctx_create()

Erstellt einen neuen Context mit dem gegebenen Prefix.

```cmake
ctx_create(PREFIX)
```

**Beschreibung:**  
Initialisiert einen neuen Namensraum für Daten.

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `PREFIX` | ✓ | Eindeutiger Namensraum-Prefix |

**Rückgabe:**  
Keine — initialisiert die Key-Liste als GLOBAL PROPERTY.

**Beispiel:**

```cmake
ctx_create(EXE_MyApp)
ctx_create(LIB_CoreLib)
ctx_create(TEST_UnitTests)
```

---

### 4.2 ctx_set()

Setzt einen Wert im Context.

```cmake
ctx_set(PREFIX KEY VALUE)
```

**Beschreibung:**  
Speichert einen Wert unter dem angegebenen Schlüssel.

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `PREFIX` | ✓ | Context-Prefix |
| `KEY` | ✓ | Schlüssel (UPPER_SNAKE_CASE empfohlen) |
| `VALUE` | ✓ | Wert (String oder `;`-getrennte Liste) |

**Rückgabe:**  
Keine — Wert wird als GLOBAL PROPERTY gespeichert.

**Beispiel:**

```cmake
ctx_set(EXE_MyApp NAME "MyApp")
ctx_set(EXE_MyApp VERSION "1.0.0")
ctx_set(EXE_MyApp EXTERNALS "bass;imgui;glfw")
```

---

### 4.3 ctx_get()

Liest einen Wert aus dem Context.

```cmake
ctx_get(PREFIX KEY OUT_VAR)
```

**Beschreibung:**  
Holt einen Wert aus dem Context in eine Variable.

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `PREFIX` | ✓ | Context-Prefix |
| `KEY` | ✓ | Schlüssel |
| `OUT_VAR` | ✓ | Variable für den Wert |

**Rückgabe:**  
Wert in `OUT_VAR`, leerer String wenn Key nicht existiert.

**Beispiel:**

```cmake
ctx_get(EXE_MyApp NAME _name)
ctx_get(EXE_MyApp VERSION _version)
message(STATUS "Name: ${_name}")  # MyApp
```

---

### 4.4 ctx_dump()

Debug-Ausgabe aller Keys im Context.

```cmake
ctx_dump(PREFIX)
```

**Beschreibung:**  
Gibt alle gesetzten Werte im Context aus. Nur aktiv wenn `DEBUG_CONTEXT=ON`.

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `PREFIX` | ✓ | Context-Prefix |

**Aktivierung:**
```bash
cmake -B build -DDEBUG_CONTEXT=ON
```

**Beispiel:**

```cmake
ctx_dump(EXE_MyApp)
```

**Ausgabe:**
```
-- === Context Dump: EXE_MyApp ===
--   NAME = MyApp
--   VERSION = 1.0.0
-- === End Context: EXE_MyApp ===
```

---

## 5. Verwendungsbeispiele

### 5.1 Executable-Pipeline

```cmake
# In ExecutableCollect.cmake
function(_collect_executable EXE_JSON CTX)
    _json_get_string("${EXE_JSON}" "name" _name)
    _json_get_string("${EXE_JSON}" "path" _path)
    
    ctx_set(${CTX} NAME "${_name}")
    ctx_set(${CTX} PATH "${_path}")
endfunction()

# In Executables.cmake
foreach(_idx RANGE 0 ${_exe_count})
    ctx_create(EXE_${_idx})
    _collect_executable("${_exe_json}" EXE_${_idx})
    
    ctx_get(EXE_${_idx} NAME _name)
    _create_executable_target(EXE_${_idx})
endforeach()
```

### 5.2 Standard Context Keys

| Key | Typ | Beschreibung |
|-----|-----|--------------|
| `NAME` | String | Target-Name |
| `VERSION` | String | Version (SemVer) |
| `PATH` | String | Source-Verzeichnis |
| `TYPE` | String | GUI, CONSOLE, STATIC, etc. |
| `SKIP` | Boolean | true = überspringen |
| `DEPENDENCIES` | List | Interne Dependencies |
| `EXTERNALS` | List | Externe Dependencies |

---

## 6. Fehlerbehandlung

Das Context-Modul wirft keine spezifischen Error Codes. Fehler werden über Assertions behandelt:

```cmake
cmake_assert(DEFINED PREFIX "ctx_set: PREFIX muss angegeben sein")
cmake_assert(DEFINED KEY "ctx_set: KEY muss angegeben sein")
```

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| `ctx_create()` vor erstem `ctx_set()` | Ohne Create direkt setzen |
| UPPER_SNAKE_CASE für Keys | lowercase-keys |
| Eindeutige Prefixes (EXE_, LIB_, TEST_) | Generische Prefixes |
| Listen als "A;B;C" | Listen als "A B C" |

---

## 8. Bekannte Einschränkungen

- **Keine Typisierung:** Alle Werte sind Strings
- **Kein Löschen:** Keys können nicht entfernt werden
- **Globaler Namespace:** Prefixe müssen eindeutig sein

---

## 9. Siehe auch

- [Errors.cmake](Errors.md) — Fehlerbehandlung
- [Debug.cmake](Debug.md) — Debug-System
- [ExecutableCollect.cmake](../project/ExecutableCollect.md) — Verwendet Context

---

## 10. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.1 | 2025-12-05 | English translation |
| 0.1.0 | 2025-12-03 | Initial: GLOBAL PROPERTY, ctx_create/set/get/dump |
