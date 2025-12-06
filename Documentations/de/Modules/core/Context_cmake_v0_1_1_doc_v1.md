# Context.cmake – Dokumentation

> **Version:** 0.1.1 (doc v1)  
> **Datum:** 2025-12-05  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/core/Context.cmake  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** master_concept v0.1, guidelines v0.1
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Modules/core/Context_cmake_v0_1_0.md)

---

## 1. Übersicht

Das `Context.cmake` Modul implementiert ein **Context-Objekt-Pattern** für isolierte Namensräume. Es ermöglicht die saubere Verwaltung von Target-Daten während der CMake-Konfiguration ohne globale Variablen.

**Kernidee:** Statt globaler Variablen nutzt jede Executable/Library einen eigenen Namensraum mit eindeutigem Präfix.

---

## 2. Abhängigkeiten

| Modul | Version | Verwendung |
|-------|---------|------------|
| Errors.cmake | 0.1+ | `cmake_fatal()`, `cmake_assert()` |
| Debug.cmake | 0.1+ | `dbg()` für Debug-Ausgaben |

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
ctx_set(EXE_0 PATH "src/app1")

ctx_create(EXE_1)
ctx_set(EXE_1 NAME "App2")
ctx_set(EXE_1 PATH "src/app2")

# Beide existieren parallel
ctx_get(EXE_0 NAME _name)  # "App1"
ctx_get(EXE_1 NAME _name)  # "App2"
```

### 3.2 GLOBAL PROPERTY Implementierung

Der Context verwendet **GLOBAL PROPERTY** für die Speicherung, nicht `PARENT_SCOPE`. Dies hat wichtige Vorteile:

| Methode | Scope-Propagierung | Problem |
|---------|-------------------|---------|
| `PARENT_SCOPE` | Eine Ebene nach oben | Verschachtelte Funktionen verlieren Werte |
| `GLOBAL PROPERTY` | Überall verfügbar | ✅ Funktioniert über alle Scopes |

**Beispiel des Problems mit PARENT_SCOPE:**
```cmake
function(outer)
    function(inner)
        set(VAR "value" PARENT_SCOPE)  # Geht nur zu outer()
    endfunction()
    inner()
    # VAR ist hier gesetzt
endfunction()
outer()
# VAR ist hier NICHT gesetzt!
```

**Mit GLOBAL PROPERTY:**
```cmake
function(outer)
    function(inner)
        set_property(GLOBAL PROPERTY MY_VAR "value")
    endfunction()
    inner()
endfunction()
outer()
get_property(_val GLOBAL PROPERTY MY_VAR)  # "value" ✅
```

### 3.3 Context-Prefixe Konvention

| Prefix | Verwendung |
|--------|------------|
| `EXE_` | Executables (`EXE_0`, `EXE_1`, `EXE_MyApp`) |
| `LIB_` | Libraries (`LIB_0`, `LIB_CoreLib`) |
| `TEST_` | Tests (`TEST_0`, `TEST_UnitTests`) |

---

## 4. API-Referenz

### 4.1 ctx_create()

Erstellt einen neuen Context mit dem gegebenen Prefix.

```cmake
ctx_create(PREFIX)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| PREFIX | String | Eindeutiger Namensraum-Prefix |

**Beispiel:**
```cmake
ctx_create(EXE_MyApp)
ctx_create(LIB_CoreLib)
ctx_create(TEST_UnitTests)
```

**Intern:** Initialisiert die Key-Liste `${PREFIX}_KEYS` als leere GLOBAL PROPERTY.

---

### 4.2 ctx_set()

Setzt einen Wert im Context.

```cmake
ctx_set(PREFIX KEY VALUE)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| PREFIX | String | Context-Prefix |
| KEY | String | Schlüssel (UPPER_SNAKE_CASE) |
| VALUE | String/List | Zu speichernder Wert |

**Beispiel:**
```cmake
ctx_set(EXE_MyApp NAME "MyApp")
ctx_set(EXE_MyApp VERSION "1.0.0")
ctx_set(EXE_MyApp TYPE "GUI")
ctx_set(EXE_MyApp DEPENDENCIES "CoreLib;AudioLib")
```

**Intern:** Speichert als `set_property(GLOBAL PROPERTY ${PREFIX}_${KEY} "${VALUE}")`.

---

### 4.3 ctx_get()

Liest einen Wert aus dem Context.

```cmake
ctx_get(PREFIX KEY OUT_VAR)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| PREFIX | String | Context-Prefix |
| KEY | String | Schlüssel |
| OUT_VAR | Output | Variable für den Wert |

**Beispiel:**
```cmake
ctx_get(EXE_MyApp NAME _name)
ctx_get(EXE_MyApp VERSION _version)
ctx_get(EXE_MyApp DEPENDENCIES _deps)

message(STATUS "Name: ${_name}")        # MyApp
message(STATUS "Version: ${_version}")  # 1.0.0
message(STATUS "Deps: ${_deps}")        # CoreLib;AudioLib
```

**Rückgabe:** Leerer String wenn Key nicht existiert.

---

### 4.4 ctx_dump()

Debug-Ausgabe aller Keys im Context. Nur aktiv wenn `DEBUG_CONTEXT=ON`.

```cmake
ctx_dump(PREFIX)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| PREFIX | String | Context-Prefix |

**Beispiel:**
```cmake
ctx_dump(EXE_MyApp)
```

**Ausgabe:**
```
-- === Context Dump: EXE_MyApp ===
--   NAME = MyApp
--   VERSION = 1.0.0
--   TYPE = GUI
--   DEPENDENCIES = CoreLib;AudioLib
-- === End Context: EXE_MyApp ===
```

**Aktivierung:**
```bash
cmake -B build -DDEBUG_CONTEXT=ON
```

---

## 5. Verwendungsbeispiele

### 5.1 Executable-Pipeline

```cmake
# In ExecutableCollect.cmake
function(_collect_executable EXE_JSON CTX)
    # JSON-Daten extrahieren
    _json_get_string("${EXE_JSON}" "name" _name)
    _json_get_string("${EXE_JSON}" "path" _path)
    _json_get_bool_from_key("${EXE_JSON}" "skip" _skip)
    
    # In Context speichern
    ctx_set(${CTX} NAME "${_name}")
    ctx_set(${CTX} PATH "${_path}")
    ctx_set(${CTX} SKIP "${_skip}")
endfunction()

# In Executables.cmake
foreach(_idx RANGE 0 ${_exe_count})
    ctx_create(EXE_${_idx})
    _collect_executable("${_exe_json}" EXE_${_idx})
    
    # Werte sind sofort verfügbar (dank GLOBAL PROPERTY)
    ctx_get(EXE_${_idx} NAME _name)
    ctx_get(EXE_${_idx} SKIP _skip)
    
    if(_skip)
        continue()
    endif()
    
    _create_executable_target(EXE_${_idx})
endforeach()
```

### 5.2 Standard Context Keys für Executables

| Key | Typ | Beschreibung |
|-----|-----|--------------|
| `NAME` | String | Target-Name |
| `DISPLAY_NAME` | String | Anzeigename |
| `DESCRIPTION` | String | Beschreibung |
| `VERSION` | String | Version (SemVer) |
| `PATH` | String | Source-Verzeichnis (relativ) |
| `TYPE` | String | GUI, CONSOLE, CLI, HEADLESS, WORKER |
| `SKIP` | Boolean | true = überspringen |
| `PCH_ENABLED` | Boolean | Precompiled Header aktiviert |
| `PCH_HEADER` | String | PCH Header-Datei |
| `DEPENDENCIES` | List | Interne Dependencies |
| `EXTERNALS` | List | Externe Dependencies |
| `DEFINES` | List | Preprocessor-Definitionen |
| `COMPILE_OPTIONS` | List | Compiler-Optionen |
| `LINK_OPTIONS` | List | Linker-Optionen |
| `PLATFORMS` | List | Zielplattformen |

### 5.3 Standard Context Keys für Libraries

| Key | Typ | Beschreibung |
|-----|-----|--------------|
| `NAME` | String | Target-Name |
| `TYPE` | String | STATIC, SHARED, INTERFACE, OBJECT |
| `PUBLIC_HEADERS` | List | Öffentliche Header |
| `PRIVATE_HEADERS` | List | Private Header |
| `ALIAS` | String | Namespace-Alias (z.B. `MyProject::Core`) |
| ... | ... | (wie Executable) |

---

## 6. Fehlerbehandlung

Das Context-Modul selbst wirft keine spezifischen Error Codes. Fehler werden über Assertions behandelt:

```cmake
cmake_assert(DEFINED PREFIX "ctx_set: PREFIX muss angegeben sein")
cmake_assert(DEFINED KEY "ctx_set: KEY muss angegeben sein")
```

---

## 7. Best Practices

1. **Einheitliche Prefixe verwenden** – `EXE_`, `LIB_`, `TEST_`
2. **Keys in UPPERCASE** – `NAME`, `VERSION`, `TYPE`
3. **Listen als Semikolon-getrennt** – `"A;B;C"`
4. **Immer ctx_create() zuerst** – Initialisiert die Key-Liste
5. **DEBUG_CONTEXT für Fehlersuche** – Zeigt alle gesetzten Werte

### Design-Entscheidung: Minimale API

| Funktion | Status | Begründung |
|----------|--------|------------|
| `ctx_create` | ✅ | Grundfunktion |
| `ctx_set` | ✅ | Grundfunktion |
| `ctx_get` | ✅ | Grundfunktion |
| `ctx_dump` | ✅ | Debug-only, sehr nützlich |
| `ctx_has` | ❌ | `ctx_get` + `if(DEFINED)` reicht |
| `ctx_append` | ❌ | `ctx_get` + `list(APPEND)` + `ctx_set` explizit |

---

## 8. Bekannte Einschränkungen

- **Keine Typisierung:** Alle Werte sind Strings
- **Kein Löschen:** Keys können nicht entfernt werden (nicht nötig)
- **Globaler Namespace:** Prefixe müssen eindeutig sein

---

## 9. Debugging

### Wert ist leer

**Problem:** `ctx_get()` gibt leeren String zurück.

**Mögliche Ursachen:**
1. `ctx_set()` wurde nie aufgerufen
2. Falscher PREFIX oder KEY
3. Tippfehler in Key-Name

**Lösung:**
```cmake
set(DEBUG_CONTEXT ON)
ctx_dump(EXE_MyApp)
```

### Werte werden nicht propagiert

**Problem:** Werte sind in aufrufender Funktion nicht verfügbar.

**Ursache:** Altes Modul mit PARENT_SCOPE statt GLOBAL PROPERTY.

**Lösung:** Modul auf v0.1.0 aktualisieren.

---

## 10. Siehe auch

- [Errors.cmake](Errors_cmake_v0_1_0_doc_v1.md) – Fehlerbehandlung
- [Debug.cmake](Debug_cmake_v0_1_0_doc_v1.md) – Debug-System
- [guidelines](../Concepts/guidelines_v0_1_0.md) – Coding-Konventionen
- [CMake_Blueprint](../Blueprints/CMake_Blueprint_v0_1_0.md) – Modul-Struktur

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.1** | **2025-12-05** | **English translation (Language Standards v0.1.1)** |
| **0.1.0 (doc v1)** | **2025-12-03** | **Initial (Clean Start): GLOBAL PROPERTY statt PARENT_SCOPE, ctx_create/set/get/dump API, Standard Keys dokumentiert** |
