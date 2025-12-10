# Attach.cmake – Dokumentation

> **Version:** 0.1.0 (doc v1)  
> **Datum:** 2025-12-09  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/externals/Local/Attach.cmake  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Modules/Externals/Attach_cmake_v0_1_0.md)

---

## 1. Übersicht

Das `Attach.cmake` Modul ist der Handler für lokale (path-basierte) Externals. Es bindet vorhandene Bibliotheken aus dem Projekt-Verzeichnis ein.

### Verantwortlichkeiten

- Lokalen Pfad validieren
- Include.cmake finden und einbinden
- Best-Practice-Warnungen ausgeben
- External als registriert markieren

---

## 2. Abhängigkeiten

| Modul | Version | Verwendung |
|-------|---------|------------|
| Errors.cmake | 0.1+ | Fehlerbehandlung |
| Debug.cmake | 0.1+ | Debug-Ausgaben |
| Registry/Targets.cmake | 0.1+ | Target-Registrierung |

---

## 3. Konzept

### 3.1 Local vs. Fetched Externals

| Aspekt | Local | Fetched |
|--------|-------|---------|
| Quelle | Projekt-Verzeichnis | Git Repository |
| Download | Nein | Ja |
| Versionierung | Manuell | Automatisch (tag/branch) |
| Anwendungsfall | Binäre Libraries, Custom Code | Open Source Libraries |

### 3.2 Include.cmake Konvention

Jedes Local External benötigt eine `Include.cmake` Datei:

```
externals/
└── bass/
    ├── Include.cmake    ← Pflicht
    ├── include/
    │   └── bass.h
    └── lib/
        ├── bass.dll
        └── bass.lib
```

### 3.3 Verarbeitungsablauf

```
1. Pfad validieren (existiert?)
2. Include.cmake suchen
3. Best-Practice-Checks
4. Include.cmake einbinden
5. Als registriert markieren
```

---

## 4. API-Referenz

### 4.1 _attach_local_external()

Hauptfunktion für Local Externals.

```cmake
_attach_local_external(NAME JSON_ELEMENT)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| NAME | String | External-Name |
| JSON_ELEMENT | JSON | JSON-Objekt aus Solution.json |

**JSON-Felder:**

| Feld | Typ | Pflicht | Beschreibung |
|------|-----|---------|--------------|
| path | String | Ja | Relativer Pfad zum External |
| include | String | Nein | Alternative Include-Datei (statt Include.cmake) |

**Beispiel:**

```cmake
# Intern von Orchestrator aufgerufen
_attach_local_external("bass" "${_bass_json}")
```

---

### 4.2 _validate_include_cmake()

Prüft Include.cmake auf Best Practices.

```cmake
_validate_include_cmake(PATH NAME)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| PATH | String | Pfad zur Include.cmake |
| NAME | String | External-Name (für Meldungen) |

**Geprüfte Patterns:**

| Pattern | Warnung | Grund |
|---------|---------|-------|
| `add_executable` | W103 | Externals sollten keine Executables erstellen |
| `add_subdirectory.*test` | W104 | Test-Verzeichnisse sollten übersprungen werden |

---

### 4.3 is_external_registered()

Prüft ob ein External bereits registriert ist.

```cmake
is_external_registered(NAME OUT_VAR)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| NAME | String | External-Name |
| OUT_VAR | Output | Boolean (TRUE/FALSE) |

**Beispiel:**

```cmake
is_external_registered("bass" _registered)
if(_registered)
    message(STATUS "BASS already loaded")
endif()
```

---

## 5. Include.cmake erstellen

### 5.1 Minimales Template

```cmake
# externals/mylib/Include.cmake
# Local External: mylib
# Version: 0.1.0

# Verfügbare Variablen:
# - EXTERNAL_NAME (mylib)
# - EXTERNAL_PATH (absoluter Pfad)

add_library(${EXTERNAL_NAME} INTERFACE)

target_include_directories(${EXTERNAL_NAME} INTERFACE
    "${EXTERNAL_PATH}/include"
)

_register_external_target("${EXTERNAL_NAME}" "${EXTERNAL_NAME}" PRIMARY)
```

### 5.2 Imported Library (BASS Beispiel)

```cmake
# externals/bass/Include.cmake
# Version: 0.1.1

add_library(bass SHARED IMPORTED GLOBAL)

if(WIN32)
    set_target_properties(bass PROPERTIES
        IMPORTED_LOCATION "${EXTERNAL_PATH}/lib/x64/bass.dll"
        IMPORTED_IMPLIB "${EXTERNAL_PATH}/lib/x64/bass.lib"
    )
elseif(APPLE)
    set_target_properties(bass PROPERTIES
        IMPORTED_LOCATION "${EXTERNAL_PATH}/lib/libbass.dylib"
    )
else()
    set_target_properties(bass PROPERTIES
        IMPORTED_LOCATION "${EXTERNAL_PATH}/lib/libbass.so"
    )
endif()

target_include_directories(bass INTERFACE
    "${EXTERNAL_PATH}/include"
)

_register_external_target("bass" "bass" PRIMARY)
```

### 5.3 Static Library mit Sources (GLAD Beispiel)

```cmake
# externals/glad/Include.cmake
# Version: 0.1.0

set(_glad_sources
    "${EXTERNAL_PATH}/src/glad.c"
)

add_library(glad STATIC ${_glad_sources})

target_include_directories(glad PUBLIC
    "${EXTERNAL_PATH}/include"
)

# OpenGL linken
find_package(OpenGL REQUIRED)
target_link_libraries(glad PUBLIC OpenGL::GL)

# Warnungen unterdrücken
if(MSVC)
    target_compile_options(glad PRIVATE /W0)
else()
    target_compile_options(glad PRIVATE -w)
endif()

_register_external_target("glad" "glad" PRIMARY)
```

---

## 6. Fehlerbehandlung

| Code | Kategorie | Beschreibung |
|------|-----------|--------------|
| E001 | VALIDATION | Pfad existiert nicht |
| E213 | EXTERNAL | Include.cmake nicht gefunden |
| E214 | EXTERNAL | Include.cmake Syntax-Fehler |

### 6.1 Warnungen

| Code | Beschreibung |
|------|--------------|
| W103 | Include.cmake enthält add_executable |
| W104 | Include.cmake enthält add_subdirectory für tests |

---

## 7. Gespeicherte Properties

Nach erfolgreicher Registrierung:

| Property | Beschreibung |
|----------|--------------|
| `EXTERNAL_${NAME}_PATH` | Absoluter Pfad |
| `EXTERNAL_${NAME}_INCLUDE` | Pfad zur Include.cmake |
| `EXTERNAL_${NAME}_REGISTERED` | TRUE |

**Zugriff:**

```cmake
get_property(_path GLOBAL PROPERTY EXTERNAL_bass_PATH)
# _path = "/full/path/to/externals/bass"
```

---

## 8. Verwendungsbeispiele

### 8.1 Standard Local External

**Solution.json:**

```json
{
    "externals": {
        "bass": {
            "path": "externals/bass"
        }
    }
}
```

**Verzeichnisstruktur:**

```
externals/
└── bass/
    ├── Include.cmake
    ├── include/
    │   └── bass.h
    └── lib/
        └── x64/
            ├── bass.dll
            └── bass.lib
```

### 8.2 Alternative Include-Datei

**Solution.json:**

```json
{
    "externals": {
        "mylib": {
            "path": "vendor/mylib",
            "include": "vendor/mylib/cmake/Setup.cmake"
        }
    }
}
```

### 8.3 Mehrere Local Externals

**Solution.json:**

```json
{
    "externals": {
        "bass": {
            "path": "externals/bass"
        },
        "lua54": {
            "path": "externals/lua54"
        },
        "glad": {
            "path": "externals/glad"
        }
    }
}
```

---

## 9. Debug-Ausgaben

```bash
cmake -B build -DDEBUG_EXTERNALS=ON
```

**Ausgabe:**

```
-- [ATTACH] Processing local external: bass
-- [ATTACH]   Path: externals/bass
-- [ATTACH]   Include: externals/bass/Include.cmake
-- [ATTACH]   Validating Include.cmake...
-- [ATTACH]   Loading Include.cmake...
-- [bass] Creating IMPORTED SHARED library
-- [ATTACH]   Registered: bass
-- [ATTACH] Complete: bass
```

---

## 10. Best Practices

1. **Include.cmake klein halten** – Nur Target-Definition, keine Logik
2. **Plattform-Switches** – Für Multi-Platform Libraries (Win/Mac/Linux)
3. **Warnungen unterdrücken** – Für externen Code immer `/W0` oder `-w`
4. **GLOBAL für IMPORTED** – `IMPORTED GLOBAL` für Sichtbarkeit
5. **Registrierung nicht vergessen** – `_register_external_target()` aufrufen

---

## 11. Siehe auch

- [Orchestrator.cmake](Orchestrator_cmake_v0_2_0_doc_v1.md) – Koordination
- [Targets.cmake](Targets_cmake_v0_1_0_doc_v1.md) – Target-Registry
- [bass Include.cmake](../../externals/bass_Include_cmake_v0_1_1_doc_v1.md) – Beispiel
- [glad Include.cmake](../../externals/glad_Include_cmake_v0_1_0_doc_v1.md) – Beispiel

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0 (doc v1)** | **2025-12-09** | **Initial: Local Handler, Include.cmake Konvention, Best-Practice-Checks** |
