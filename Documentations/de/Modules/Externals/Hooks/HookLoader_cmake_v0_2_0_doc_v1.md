# HookLoader.cmake – Dokumentation

> **Version:** 0.2.0 (doc v1)  
> **Datum:** 2025-12-10  
> **Typ:** Modul-Doku  
> **Status:** Stabil  
> **Modul:** cmake/externals/Hooks/HookLoader.cmake  
> **Modul-Version:** 0.2.0  
> **Sprache:** Deutsch

---

## Übersicht

Das HookLoader-Modul lädt PreFetch- und PostFetch-Hooks für Externals. Es implementiert das "Convention over Configuration" Pattern und unterstützt Hook-Wiederverwendung.

### Hauptfunktionen

| Funktion | Beschreibung |
|----------|--------------|
| `_load_prefetch_hook()` | Lädt PreFetch Hook (vor Download) |
| `_load_postfetch_hook()` | Lädt PostFetch Hook (nach Download) |
| `_check_hook_requirements()` | Prüft ob PostFetch Hook erforderlich |
| `_get_hook_name()` | Ermittelt Hook-Namen (mit Override-Support) |

---

## Convention Paths

| Hook-Typ | Pfad |
|----------|------|
| PreFetch | `cmake/externals/Hooks/PreFetch/${name}.cmake` |
| PostFetch | `cmake/externals/Hooks/PostFetch/${name}.cmake` |

---

## Hook-Variablen

Diese Variablen stehen in Hooks zur Verfügung:

| Variable | Verfügbar in | Beschreibung |
|----------|--------------|--------------|
| `HOOK_EXTERNAL_NAME` | Pre + Post | Name des Externals (**für Target-Namen verwenden!**) |
| `HOOK_EXTERNAL_JSON` | Pre + Post | JSON-Definition des Externals |
| `HOOK_SOURCE_DIR` | Nur Post | Pfad zum Source-Verzeichnis |

---

## Hook-Wiederverwendung (`hook` Feld)

### Problem

Man möchte zwei Varianten desselben Externals (z.B. ImGui mit/ohne Docking), aber nicht den Hook duplizieren.

### Lösung

Das `hook` Feld in Solution.json erlaubt die Wiederverwendung:

```json
{
    "externals": {
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.91.6",
            "cmakeSupport": false
        },
        "imgui_docking": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.91.6-docking",
            "cmakeSupport": false,
            "hook": "imgui"
        }
    }
}
```

### Verhalten

| External | Hook-Datei | Target-Name |
|----------|------------|-------------|
| `imgui` | `PostFetch/imgui.cmake` | `imgui` |
| `imgui_docking` | `PostFetch/imgui.cmake` | `imgui_docking` |

Der Hook wird **zweimal** ausgeführt, aber mit unterschiedlichem `HOOK_EXTERNAL_NAME`:
1. `HOOK_EXTERNAL_NAME = "imgui"` → Target `imgui`
2. `HOOK_EXTERNAL_NAME = "imgui_docking"` → Target `imgui_docking`

---

## Automatischer Lock

### Funktionsweise

Der HookLoader setzt automatisch einen Lock pro External, um doppelte Ausführung zu verhindern:

```cmake
# Intern im HookLoader:
get_property(_done GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_POSTFETCH_DONE)
if(_done)
    return()  # Skip
endif()
# ... Hook ausführen ...
set_property(GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_POSTFETCH_DONE TRUE)
```

### Warum?

Wenn mehrere Executables dasselbe External verwenden:

```json
"executables": [
    { "name": "App1", "externals": ["imgui"] },
    { "name": "App2", "externals": ["imgui"] }
]
```

Der Hook läuft nur **einmal** - beim zweiten Mal ist das Target bereits vorhanden.

### Lock-Properties

| Property | Bedeutung |
|----------|-----------|
| `EXTERNAL_${name}_PREFETCH_DONE` | PreFetch Hook wurde ausgeführt |
| `EXTERNAL_${name}_POSTFETCH_DONE` | PostFetch Hook wurde ausgeführt |

---

## Best Practices für Hook-Autoren

### ✅ Dynamische Target-Namen verwenden

```cmake
# ✅ RICHTIG - dynamisch
add_library(${HOOK_EXTERNAL_NAME} STATIC ${sources})
target_include_directories(${HOOK_EXTERNAL_NAME} PUBLIC ${includes})
_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)

# ❌ FALSCH - hardcoded
add_library(imgui STATIC ${sources})
```

### ✅ HOOK_SOURCE_DIR verwenden

```cmake
# ✅ RICHTIG
set(_sources
    "${HOOK_SOURCE_DIR}/imgui.cpp"
    "${HOOK_SOURCE_DIR}/imgui_draw.cpp"
)

# ❌ FALSCH - FetchContent direkt abfragen
FetchContent_GetProperties(imgui)
set(_sources "${imgui_SOURCE_DIR}/imgui.cpp")
```

### ✅ Kein manueller Lock nötig

```cmake
# ❌ NICHT NÖTIG - HookLoader macht das automatisch
if(TARGET ${HOOK_EXTERNAL_NAME})
    return()
endif()
```

---

## API-Referenz

### _load_prefetch_hook

```cmake
_load_prefetch_hook(EXT_NAME EXT_JSON)
```

Lädt einen PreFetch Hook. Wird VOR `FetchContent_MakeAvailable()` aufgerufen.

**Typische Verwendung:** CMake-Optionen setzen bevor External konfiguriert wird.

**Beispiel-Hook (glfw.cmake):**

```cmake
# Deaktiviere GLFW Beispiele und Tests
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch: Options set")
```

### _load_postfetch_hook

```cmake
_load_postfetch_hook(EXT_NAME EXT_JSON)
```

Lädt einen PostFetch Hook. Wird NACH `FetchContent_MakeAvailable()` aufgerufen.

**Typische Verwendung:** Targets erstellen für Externals ohne CMakeLists.txt.

**Beispiel-Hook (imgui.cmake):**

```cmake
add_library(${HOOK_EXTERNAL_NAME} STATIC
    "${HOOK_SOURCE_DIR}/imgui.cpp"
    "${HOOK_SOURCE_DIR}/imgui_draw.cpp"
    # ...
)
target_include_directories(${HOOK_EXTERNAL_NAME} PUBLIC "${HOOK_SOURCE_DIR}")
_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)
```

### _check_hook_requirements

```cmake
_check_hook_requirements(EXT_NAME EXT_JSON OUT_NEEDS_POSTFETCH)
```

Prüft ob ein External einen PostFetch Hook benötigt (basierend auf `cmakeSupport: false`).

---

## Fehlerbehandlung

| Code | Beschreibung |
|------|--------------|
| E216 | Explizit angegebener Hook nicht gefunden |
| E217 | PostFetch Hook erforderlich aber keine Targets erstellt |

---

## Beispiel: Neuen Hook erstellen

### 1. Hook-Datei erstellen

```cmake
# cmake/externals/Hooks/PostFetch/mylib.cmake

message(STATUS "[${HOOK_EXTERNAL_NAME}] Creating target...")

add_library(${HOOK_EXTERNAL_NAME} STATIC
    "${HOOK_SOURCE_DIR}/src/mylib.cpp"
)

target_include_directories(${HOOK_EXTERNAL_NAME} PUBLIC
    "${HOOK_SOURCE_DIR}/include"
)

_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)

message(STATUS "[${HOOK_EXTERNAL_NAME}] Done")
```

### 2. Solution.json

```json
"mylib": {
    "git": "https://github.com/example/mylib.git",
    "tag": "v1.0.0",
    "cmakeSupport": false
}
```

### 3. Variante mit Hook-Wiederverwendung

```json
"mylib_dev": {
    "git": "https://github.com/example/mylib.git",
    "branch": "develop",
    "cmakeSupport": false,
    "hook": "mylib"
}
```

---

## Siehe auch

- [Externals Referenz](../../References/Externals_v0_2_1.md)
- [imgui PostFetch Hook](imgui_PostFetch_v0_3_0_doc_v1.md)
- [Solution_Schema](../../References/Solution_Schema_v0_1_2.md) – `hook` Feld

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.2.0 (doc v1)** | **2025-12-10** | **Hook-Wiederverwendung (`hook` Feld), automatischer Lock, Best Practices** |
| 0.1.0 (doc v1) | 2025-12-09 | Initial: Convention-basierte Hook-Suche |
