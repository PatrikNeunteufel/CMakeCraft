# SourceCollect.cmake – Dokumentation

> **Version:** 0.1.1 (doc v1)  
> **Datum:** 2025-12-05  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/core/SourceCollect.cmake  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** master_concept v0.1, guidelines v0.1
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Modules/core/SourceCollect_cmake_v0_1_0.md)

---

## 1. Übersicht

Das `SourceCollect.cmake` Modul verwaltet die Sammlung von Source-Dateien für Executables und Libraries. Es unterstützt drei Modi:

| Mode | Beschreibung |
|------|--------------|
| `explicit` | Source.cmake erforderlich (Default, empfohlen) |
| `glob` | Automatisches Sammeln per Wildcard |
| `auto` | Source.cmake wenn vorhanden, sonst GLOB-Fallback |

---

## 2. Abhängigkeiten

| Modul | Version | Verwendung |
|-------|---------|------------|
| Errors.cmake | 0.1+ | `cmake_fatal()`, `cmake_warn()` |
| Debug.cmake | 0.1+ | `dbg()`, Debug-Ausgaben |
| Context.cmake | 0.1+ | `ctx_get()` für Settings |

---

## 3. Konzept

### 3.1 Warum explizite Source-Listen?

**GLOB Nachteile:**
- CMake erkennt neue/gelöschte Dateien **nicht automatisch**
- Manuelles Reconfigure nötig nach Dateiänderungen
- Kann versehentlich Test-/Beispieldateien inkludieren
- CMake selbst warnt: *"We do not recommend using GLOB to collect source files"*

**Explizite Listen Vorteile:**
- Volle Kontrolle über inkludierte Dateien
- CMake erkennt Änderungen an Source.cmake
- Keine versehentlichen Includes
- Bessere IDE-Integration

### 3.2 Datei-Kategorien

| Kategorie | Extensions | Kompiliert? | Beschreibung |
|-----------|------------|-------------|--------------|
| SOURCES | `.cpp`, `.cxx`, `.cc`, `.c` | ✅ Ja | Kompilierbare Implementierungen |
| HEADERS | `.h`, `.hpp`, `.hxx`, `.hh` | ❌ Nein | Deklarationen, IDE-sichtbar |
| TEMPLATES | `.tpp`, `.txx`, `.ipp` | ❌ Nein | Template-Implementierungen |
| INLINES | `.inl` | ❌ Nein | Inline-Funktions-Implementierungen |
| IMPL | `.impl` | ❌ Nein | PIMPL-Detail-Implementierungen |
| MODULES | `.ixx`, `.cppm`, `.mpp` | ⚠️ Speziell | C++20 Module Interface Units |

### 3.3 C++20 Modules (EXPERIMENTAL)

> **Warnung:** C++20 Modules sind noch experimentell und compiler-spezifisch!

| Compiler | Extension | Status |
|----------|-----------|--------|
| **MSVC** | `.ixx` | Beste Unterstützung |
| **Clang** | `.cppm` | Noch Einschränkungen |
| **GCC** | `.mpp` | Begrenzte Unterstützung |

Module werden mit **Warning W109** markiert wenn verwendet.

### 3.4 Source-Modi

Konfiguration in `Solution.json`:

```json
{
    "settings": {
        "sources": {
            "mode": "explicit"
        }
    }
}
```

| Mode | Verhalten | Error/Warning |
|------|-----------|---------------|
| `explicit` | Source.cmake **erforderlich** | **E104** wenn fehlt |
| `glob` | Immer GLOB verwenden, Source.cmake ignoriert | W110 |
| `auto` | Source.cmake wenn vorhanden, sonst GLOB-Fallback | W110 bei Fallback |

---

## 4. API-Referenz

### 4.1 _collect_sources_from_cmake()

Lädt Source.cmake und sammelt alle Dateien.

```cmake
_collect_sources_from_cmake(
    TARGET_NAME    # Name des Targets
    SOURCE_DIR     # Verzeichnis mit Source.cmake
    OUT_SOURCES    # Output: Kompilierbare Dateien
    OUT_HEADERS    # Output: Header-Dateien
    OUT_EXTRAS     # Output: Templates/Inlines/Impl
    OUT_MODULES    # Output: C++20 Module Units
    OUT_INCLUDES   # Output: Include-Pfade
)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| TARGET_NAME | String | Name des Targets (für Variable-Prefix) |
| SOURCE_DIR | Path | Verzeichnis mit Source.cmake |
| OUT_SOURCES | Output | Liste kompilierbarer Dateien |
| OUT_HEADERS | Output | Liste Header-Dateien |
| OUT_EXTRAS | Output | Templates, Inlines, Impl zusammengefasst |
| OUT_MODULES | Output | C++20 Module Interface Units |
| OUT_INCLUDES | Output | Zusätzliche Include-Pfade |

**Fehler:**
- E104 – Source.cmake nicht gefunden

**Warnings:**
- W101 – Source.cmake definiert keine Dateien
- W109 – C++20 Module verwendet

---

### 4.2 _collect_sources_glob()

GLOB-basierte Sammlung (Fallback).

```cmake
_collect_sources_glob(
    SOURCE_DIR     # Verzeichnis zum Durchsuchen
    OUT_SOURCES    # Output: Kompilierbare Dateien
    OUT_HEADERS    # Output: Header-Dateien
    OUT_EXTRAS     # Output: Templates/Inlines/Impl
    OUT_MODULES    # Output: C++20 Module Units
)
```

**Warnings:**
- W110 – GLOB-Fallback aktiv
- W109 – C++20 Module gefunden

---

### 4.3 _apply_sources_to_target()

Wendet gesammelte Dateien auf CMake Target an.

```cmake
_apply_sources_to_target(
    TARGET_NAME    # CMake Target
    SOURCES        # Kompilierbare Dateien
    HEADERS        # Header-Dateien
    EXTRAS         # Templates/Inlines/Impl
    MODULES        # C++20 Module Units
    INCLUDES       # Zusätzliche Include-Pfade
    SOURCE_DIR     # Basis-Verzeichnis
)
```

**Automatisch hinzugefügte Include-Pfade:**
1. `SOURCE_DIR` – immer
2. `SOURCE_DIR/pch/` – wenn vorhanden

---

### 4.4 _get_source_mode()

Ermittelt Source-Mode aus Solution Settings.

```cmake
_get_source_mode(OUT_VAR)
# Gibt "explicit", "glob" oder "auto" zurück
```

---

### 4.5 collect_files()

Helper für kontrollierte Wildcards in Source.cmake.

```cmake
collect_files(OUT_VAR
    DIRECTORY "path/to/dir"
    EXTENSIONS ext1 ext2 ...
    [EXCLUDE pattern1 pattern2 ...]
)
```

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| DIRECTORY | ✅ | Verzeichnis zum Durchsuchen |
| EXTENSIONS | ✅ | Liste der Extensions ohne Punkt |
| EXCLUDE | ❌ | Regex-Patterns zum Ausschließen |

**Beispiel:**
```cmake
collect_files(_generated
    DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/generated"
    EXTENSIONS cpp c
    EXCLUDE "*_test.cpp" "test_*.cpp" "*_mock.cpp"
)
list(APPEND _local_sources ${_generated})
```

---

## 5. Verwendungsbeispiele

### 5.1 Minimale Source.cmake

```cmake
# src/Source.cmake

set(_local_sources
    "${CMAKE_CURRENT_LIST_DIR}/main.cpp"
)

set(_local_headers "")
set(_local_templates "")
set(_local_inlines "")
set(_local_impl "")
set(_local_modules "")
set(_local_includes "")

# Aggregation
list(APPEND ${TARGET_NAME}_SOURCES   ${_local_sources})
list(APPEND ${TARGET_NAME}_HEADERS   ${_local_headers})
list(APPEND ${TARGET_NAME}_TEMPLATES ${_local_templates})
list(APPEND ${TARGET_NAME}_INLINES   ${_local_inlines})
list(APPEND ${TARGET_NAME}_IMPL      ${_local_impl})
list(APPEND ${TARGET_NAME}_MODULES   ${_local_modules})
list(APPEND ${TARGET_NAME}_INCLUDES  ${_local_includes})
```

### 5.2 Vollständiges Beispiel mit Unterverzeichnissen

```cmake
# src/Source.cmake

set(_local_sources
    "${CMAKE_CURRENT_LIST_DIR}/main.cpp"
    "${CMAKE_CURRENT_LIST_DIR}/application.cpp"
)

set(_local_headers
    "${CMAKE_CURRENT_LIST_DIR}/application.h"
    "${CMAKE_CURRENT_LIST_DIR}/config.h"
)

set(_local_templates
    "${CMAKE_CURRENT_LIST_DIR}/container.tpp"
)

set(_local_inlines
    "${CMAKE_CURRENT_LIST_DIR}/math_utils.inl"
)

set(_local_impl "")
set(_local_modules "")

set(_local_includes
    "${CMAKE_CURRENT_LIST_DIR}/include"
)

# Aggregation
list(APPEND ${TARGET_NAME}_SOURCES   ${_local_sources})
list(APPEND ${TARGET_NAME}_HEADERS   ${_local_headers})
list(APPEND ${TARGET_NAME}_TEMPLATES ${_local_templates})
list(APPEND ${TARGET_NAME}_INLINES   ${_local_inlines})
list(APPEND ${TARGET_NAME}_IMPL      ${_local_impl})
list(APPEND ${TARGET_NAME}_MODULES   ${_local_modules})
list(APPEND ${TARGET_NAME}_INCLUDES  ${_local_includes})

# Unterverzeichnisse einbinden
include("${CMAKE_CURRENT_LIST_DIR}/core/Source.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/ui/Source.cmake")
```

### 5.3 Mit collect_files() für generierte Dateien

```cmake
# src/Source.cmake

set(_local_sources
    "${CMAKE_CURRENT_LIST_DIR}/main.cpp"
)

# Generierte Dateien per Wildcard, aber Tests ausschließen
collect_files(_generated
    DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/generated"
    EXTENSIONS cpp c
    EXCLUDE "*_test.cpp" "test_*.cpp"
)
list(APPEND _local_sources ${_generated})

set(_local_headers "")
# ... Rest wie oben
```

---

## 6. Fehlerbehandlung

| Code | Beschreibung | Auslöser |
|------|--------------|----------|
| **E104** | Source.cmake nicht gefunden | mode=explicit, keine Source.cmake |
| **W101** | Suboptimale Konfiguration | Source.cmake leer, Include-Pfad fehlt |
| **W109** | C++20 Module verwendet | .ixx/.cppm/.mpp Dateien gefunden |
| **W110** | GLOB-Fallback aktiv | mode=auto, keine Source.cmake |

---

## 7. Best Practices

1. **Explizite Listen bevorzugen** – Jede Datei bewusst auflisten
2. **GLOB nur für generierte Dateien** – Mit `collect_files()` und Excludes
3. **Hierarchische Struktur** – Jedes Unterverzeichnis hat eigene Source.cmake
4. **C++20 Modules vermeiden** – Noch nicht stabil genug für Produktion
5. **Keine Tests in Source.cmake** – Tests haben eigene Struktur

### Empfohlene Verzeichnisstruktur

```
projects/exec/MyApp/src/
├── Source.cmake           ← Hauptverzeichnis
├── main.cpp
├── application.cpp
├── application.h
├── pch/
│   └── pch.h              ← Automatisch als Include
├── include/
│   └── types.h            ← Kein eigenes Source.cmake nötig
├── core/
│   ├── Source.cmake       ← Sub-Source.cmake
│   ├── engine.cpp
│   └── engine.h
└── ui/
    ├── Source.cmake
    ├── window.cpp
    └── window.h
```

---

## 8. Bekannte Einschränkungen

- **C++20 Modules:** Compiler-Support noch unvollständig
- **GLOB:** CMake erkennt Dateiänderungen nicht automatisch
- **Include-Pfade:** Nur für Compiler, nicht für IDE-Navigation

---

## 9. Siehe auch

- [Context.cmake](Context_cmake_v0_1_0_doc_v1.md) – Context-Pattern
- [Json.cmake](Json_cmake_v0_1_0_doc_v1.md) – JSON-Parsing
- [ErrorCodes](../References/ErrorCodes_v0_1_0.md) – E104, W109, W110
- [CMake_Blueprint](../Blueprints/CMake_Blueprint_v0_1_0.md) – Modul-Struktur

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.1** | **2025-12-05** | **English translation (Language Standards v0.1.1)** |
| **0.1.0 (doc v1)** | **2025-12-03** | **Initial (Clean Start): Drei Source-Modi, Datei-Kategorien, collect_files() Helper, C++20 Module Support (experimentell)** |
