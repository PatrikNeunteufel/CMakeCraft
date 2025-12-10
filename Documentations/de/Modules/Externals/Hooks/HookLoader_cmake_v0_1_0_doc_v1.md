# HookLoader.cmake – Dokumentation

> **Version:** 0.1.0 (doc v1)  
> **Datum:** 2025-12-09  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/externals/Hooks/HookLoader.cmake  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Modules/Externals/HookLoader_cmake_v0_1_0.md)

---

## 1. Übersicht

Das `HookLoader.cmake` Modul lädt und führt PreFetch/PostFetch Hooks für Externals aus. Hooks ermöglichen die Anpassung von Externals ohne deren Quellcode zu ändern.

### Verantwortlichkeiten

- Hook-Dateien finden (Convention oder explizit)
- Hooks laden und ausführen
- Variablen für Hooks bereitstellen
- Hook-Anforderungen prüfen (cmakeSupport=false)

---

## 2. Abhängigkeiten

| Modul | Version | Verwendung |
|-------|---------|------------|
| Errors.cmake | 0.1+ | Fehlerbehandlung |
| Debug.cmake | 0.1+ | Debug-Ausgaben |

---

## 3. Konzept

### 3.1 Hook-Typen

| Typ | Zeitpunkt | Zweck |
|-----|-----------|-------|
| **PreFetch** | Vor Download | CMake-Optionen setzen |
| **PostFetch** | Nach Download | Targets erstellen |

### 3.2 Convention over Configuration

**Standard-Pfade:**
```
cmake/externals/Hooks/
├── PreFetch/
│   ├── glfw.cmake
│   └── spdlog.cmake
└── PostFetch/
    ├── imgui.cmake
    └── glad.cmake
```

**Namenskonvention:** `${EXTERNAL_NAME}.cmake`

### 3.3 Hook-Auflösungslogik

```
┌─────────────────────────────────────┐
│ Explizit in JSON definiert?         │
├─────────────────────────────────────┤
│ JA → Datei existiert?               │
│      JA → Laden                     │
│      NEIN → E216 (Fehler!)          │
├─────────────────────────────────────┤
│ NEIN → Convention-Pfad existiert?   │
│        JA → Laden                   │
│        NEIN → Kein Hook (OK)        │
└─────────────────────────────────────┘
```

**Wichtig:** Explizit definierte Hooks **müssen** existieren (Fehler). Convention-basierte Hooks sind optional (kein Fehler wenn nicht vorhanden).

---

## 4. API-Referenz

### 4.1 _load_prefetch_hook()

Lädt und führt einen PreFetch Hook aus.

```cmake
_load_prefetch_hook(NAME JSON_ELEMENT)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| NAME | String | External-Name |
| JSON_ELEMENT | JSON | JSON-Objekt mit optionalem "preFetchHook" |

**Bereitgestellte Variablen im Hook:**

| Variable | Beschreibung |
|----------|--------------|
| `HOOK_EXTERNAL_NAME` | Name des Externals |
| `HOOK_EXTERNAL_JSON` | Komplettes JSON-Element |

**Beispiel:**

```cmake
_load_prefetch_hook("glfw" "${_glfw_json}")
```

---

### 4.2 _load_postfetch_hook()

Lädt und führt einen PostFetch Hook aus.

```cmake
_load_postfetch_hook(NAME JSON_ELEMENT SOURCE_DIR)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| NAME | String | External-Name |
| JSON_ELEMENT | JSON | JSON-Objekt mit optionalem "postFetchHook" |
| SOURCE_DIR | Path | Pfad zum heruntergeladenen Source |

**Bereitgestellte Variablen im Hook:**

| Variable | Beschreibung |
|----------|--------------|
| `HOOK_EXTERNAL_NAME` | Name des Externals |
| `HOOK_EXTERNAL_JSON` | Komplettes JSON-Element |
| `HOOK_SOURCE_DIR` | Source-Verzeichnis |

**Beispiel:**

```cmake
_load_postfetch_hook("imgui" "${_imgui_json}" "${imgui_SOURCE_DIR}")
```

---

### 4.3 _check_hook_requirements()

Prüft ob ein PostFetch Hook erforderlich ist.

```cmake
_check_hook_requirements(NAME JSON_ELEMENT HOOK_LOADED OUT_ERROR)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| NAME | String | External-Name |
| JSON_ELEMENT | JSON | JSON-Objekt |
| HOOK_LOADED | Boolean | Wurde ein Hook geladen? |
| OUT_ERROR | Output | Fehlercode oder leer |

**Logik:**
- `cmakeSupport=false` + kein Hook → E217
- `cmakeSupport=true` oder Hook vorhanden → OK

---

## 5. Hook-Dateien erstellen

### 5.1 PreFetch Hook Template

```cmake
# cmake/externals/Hooks/PreFetch/${name}.cmake
# PreFetch Hook for ${name}
# Version: 0.1.0

# Verfügbare Variablen:
# - HOOK_EXTERNAL_NAME
# - HOOK_EXTERNAL_JSON

# CMake-Optionen für ${name} setzen
set(${NAME}_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(${NAME}_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(${NAME}_BUILD_DOCS OFF CACHE BOOL "" FORCE)

message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch hook applied")
```

### 5.2 PostFetch Hook Template

```cmake
# cmake/externals/Hooks/PostFetch/${name}.cmake
# PostFetch Hook for ${name}
# Version: 0.1.0

# Verfügbare Variablen:
# - HOOK_EXTERNAL_NAME
# - HOOK_EXTERNAL_JSON
# - HOOK_SOURCE_DIR

# Sources sammeln
set(_sources
    "${HOOK_SOURCE_DIR}/src/file1.cpp"
    "${HOOK_SOURCE_DIR}/src/file2.cpp"
)

# Library Target erstellen
add_library(${HOOK_EXTERNAL_NAME} STATIC ${_sources})

target_include_directories(${HOOK_EXTERNAL_NAME} PUBLIC
    "${HOOK_SOURCE_DIR}/include"
)

# Warnungen unterdrücken (externes Projekt)
if(MSVC)
    target_compile_options(${HOOK_EXTERNAL_NAME} PRIVATE /W0)
else()
    target_compile_options(${HOOK_EXTERNAL_NAME} PRIVATE -w)
endif()

# Target registrieren
_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)

message(STATUS "[${HOOK_EXTERNAL_NAME}] PostFetch hook complete")
```

---

## 6. Fehlerbehandlung

| Code | Kategorie | Beschreibung |
|------|-----------|--------------|
| E216 | EXTERNAL | Explizit definierter Hook nicht gefunden |
| E217 | EXTERNAL | PostFetch Hook erforderlich (cmakeSupport=false) aber nicht vorhanden |

### 6.1 Beispiel: E216

```json
{
    "externals": {
        "mylib": {
            "git": "https://...",
            "postFetchHook": "cmake/hooks/nonexistent.cmake"
        }
    }
}
```

**Fehler:**
```
CMake Error: [E216] PostFetch hook not found: cmake/hooks/nonexistent.cmake
```

### 6.2 Beispiel: E217

```json
{
    "externals": {
        "headeronly": {
            "git": "https://...",
            "cmakeSupport": false
        }
    }
}
```

Ohne `cmake/externals/Hooks/PostFetch/headeronly.cmake`:
```
CMake Error: [E217] PostFetch hook required for 'headeronly' (cmakeSupport=false)
```

---

## 7. Verwendungsbeispiele

### 7.1 GLFW mit PreFetch Hook

**cmake/externals/Hooks/PreFetch/glfw.cmake:**
```cmake
# Build-Optionen deaktivieren
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_INSTALL OFF CACHE BOOL "" FORCE)
```

**Solution.json:**
```json
{
    "externals": {
        "glfw": {
            "git": "https://github.com/glfw/glfw.git",
            "tag": "3.4"
        }
    }
}
```

Der Hook wird automatisch durch Convention geladen.

### 7.2 ImGui mit PostFetch Hook

**cmake/externals/Hooks/PostFetch/imgui.cmake:**
```cmake
# Target für ImGui erstellen (kein CMakeLists.txt)
set(_imgui_sources
    "${HOOK_SOURCE_DIR}/imgui.cpp"
    "${HOOK_SOURCE_DIR}/imgui_demo.cpp"
    "${HOOK_SOURCE_DIR}/imgui_draw.cpp"
    "${HOOK_SOURCE_DIR}/imgui_tables.cpp"
    "${HOOK_SOURCE_DIR}/imgui_widgets.cpp"
    "${HOOK_SOURCE_DIR}/backends/imgui_impl_glfw.cpp"
    "${HOOK_SOURCE_DIR}/backends/imgui_impl_opengl3.cpp"
)

add_library(imgui STATIC ${_imgui_sources})
# ... weitere Konfiguration
_register_external_target("imgui" "imgui" PRIMARY)
```

**Solution.json:**
```json
{
    "externals": {
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.90.1",
            "cmakeSupport": false
        }
    }
}
```

---

## 8. Best Practices

### 8.1 PreFetch Hooks

1. **CACHE BOOL "" FORCE** verwenden – Überschreibt alle bestehenden Werte
2. **Nur Build-Optionen** – Keine target_* Befehle (Targets existieren noch nicht)
3. **Dokumentation** – Kommentare warum welche Option gesetzt wird

### 8.2 PostFetch Hooks

1. **Warnungen unterdrücken** – Externer Code, nicht unser Problem
2. **_register_external_target()** – Immer aufrufen!
3. **PRIMARY Flag** – Für das Haupt-Target setzen
4. **PUBLIC Include-Dirs** – Damit Consumer die Headers finden

---

## 9. Debug-Ausgaben

```bash
cmake -B build -DDEBUG_EXTERNALS=ON
```

**Ausgabe:**
```
-- [HOOKLOADER] Looking for PreFetch hook: glfw
-- [HOOKLOADER]   Convention path: cmake/externals/Hooks/PreFetch/glfw.cmake
-- [HOOKLOADER]   Found, loading...
-- [glfw] PreFetch hook applied
-- [HOOKLOADER] Looking for PostFetch hook: imgui
-- [HOOKLOADER]   Convention path: cmake/externals/Hooks/PostFetch/imgui.cmake
-- [HOOKLOADER]   Found, loading...
-- [imgui] PostFetch hook complete
```

---

## 10. Siehe auch

- [Handler.cmake](Handler_cmake_v0_1_0_doc_v1.md) – Verwendet HookLoader
- [glfw PreFetch Hook](../../Hooks/glfw_PreFetch_v0_1_0_doc_v1.md) – Beispiel
- [imgui PostFetch Hook](../../Hooks/imgui_PostFetch_v0_2_0_doc_v1.md) – Beispiel
- [Targets.cmake](Targets_cmake_v0_1_0_doc_v1.md) – Target-Registrierung

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0 (doc v1)** | **2025-12-09** | **Initial: Convention-basierte Hooks, explizite Hooks, Variablen** |
