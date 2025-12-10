# Handler.cmake – Dokumentation

> **Version:** 0.1.0 (doc v1)  
> **Datum:** 2025-12-09  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/externals/Fetched/Handler.cmake  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Modules/Externals/Handler_cmake_v0_1_0.md)

---

## 1. Übersicht

Das `Handler.cmake` Modul ist der Haupthandler für Git-basierte (Fetched) Externals. Es orchestriert den kompletten Lebenszyklus vom Download bis zur Target-Registrierung.

### Verantwortlichkeiten

- Git-Externals deklarieren und laden
- PreFetch/PostFetch Hooks aufrufen
- Targets automatisch erkennen und registrieren
- CMake-Support-Flag verarbeiten

---

## 2. Abhängigkeiten

| Modul | Version | Verwendung |
|-------|---------|------------|
| Core/Fetch.cmake | 0.1+ | FetchContent-Wrapper |
| Hooks/HookLoader.cmake | 0.1+ | Hook-System |
| Registry/Targets.cmake | 0.1+ | Target-Registrierung |
| Errors.cmake | 0.1+ | Fehlerbehandlung |
| Debug.cmake | 0.1+ | Debug-Ausgaben |

---

## 3. Konzept

### 3.1 Verarbeitungs-Pipeline

```
┌─────────────────────────────────────────┐
│ 1. Declare (FetchContent_Declare)       │
├─────────────────────────────────────────┤
│ 2. PreFetch Hook (optional)             │
│    → CMake-Optionen setzen              │
├─────────────────────────────────────────┤
│ 3. MakeAvailable (Download & Configure) │
├─────────────────────────────────────────┤
│ 4. PostFetch Hook (optional)            │
│    → Targets erstellen                  │
├─────────────────────────────────────────┤
│ 5. Auto-Register (Target-Erkennung)     │
├─────────────────────────────────────────┤
│ 6. Validate (Target vorhanden?)         │
└─────────────────────────────────────────┘
```

### 3.2 cmakeSupport Flag

| Wert | Bedeutung | Hook-Anforderung |
|------|-----------|------------------|
| `true` (default) | External hat CMakeLists.txt | PostFetch optional |
| `false` | Kein CMakeLists.txt | PostFetch **PFLICHT** |

**Warum wichtig?**

Ohne CMakeLists.txt (wie bei ImGui) muss ein PostFetch-Hook die Targets manuell erstellen. Ohne Hook und ohne CMake-Support gibt es keine Targets.

---

## 4. API-Referenz

### 4.1 _handle_fetched_external()

Verarbeitet ein Fetched External komplett.

```cmake
_handle_fetched_external(NAME JSON_ELEMENT)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| NAME | String | External-Name |
| JSON_ELEMENT | JSON | JSON-Objekt aus Solution.json |

**JSON-Felder:**

| Feld | Typ | Pflicht | Beschreibung |
|------|-----|---------|--------------|
| git | String | ✅ | Git Repository URL |
| tag | String | ❌* | Git Tag |
| branch | String | ❌* | Git Branch |
| commit | String | ❌* | Git Commit Hash |
| cmakeSupport | Boolean | ❌ | Hat CMakeLists.txt (default: true) |
| preFetchHook | String | ❌ | Expliziter PreFetch Hook Pfad |
| postFetchHook | String | ❌ | Expliziter PostFetch Hook Pfad |

*Genau eines von tag, branch oder commit muss angegeben werden.

**Beispiel:**

```cmake
# Intern von Orchestrator aufgerufen
_handle_fetched_external("glfw" "${_glfw_json}")
```

---

## 5. Hook-Integration

### 5.1 PreFetch Hook

Wird **vor** `FetchContent_MakeAvailable()` aufgerufen.

**Typische Verwendung:**
- CMake-Optionen setzen (z.B. BUILD_EXAMPLES OFF)
- Compiler-Flags anpassen
- Feature-Toggles konfigurieren

**Beispiel (glfw):**
```cmake
# cmake/externals/Hooks/PreFetch/glfw.cmake
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
```

### 5.2 PostFetch Hook

Wird **nach** `FetchContent_MakeAvailable()` aufgerufen.

**Typische Verwendung:**
- Targets für Libraries ohne CMake erstellen
- Zusätzliche Targets (Alias, Interface) erstellen
- Include-Pfade anpassen

**Beispiel (imgui):**
```cmake
# cmake/externals/Hooks/PostFetch/imgui.cmake
add_library(imgui STATIC
    ${imgui_SOURCE_DIR}/imgui.cpp
    # ... weitere Sources
)
_register_external_target("imgui" "imgui" PRIMARY)
```

---

## 6. Auto-Registrierung

Nach dem Laden versucht der Handler automatisch Targets zu finden:

| Suchname | Beispiel |
|----------|----------|
| `${NAME}` | `glfw` |
| `${NAME}::${NAME}` | `glfw::glfw` |
| `${name}` (lowercase) | `glfw` |
| `${name}::${name}` | `glfw::glfw` |

Das erste gefundene Target wird als **PRIMARY** registriert.

---

## 7. Fehlerbehandlung

| Code | Kategorie | Beschreibung |
|------|-----------|--------------|
| E201 | EXTERNAL | Keine Targets nach Verarbeitung |
| E202 | EXTERNAL | Download fehlgeschlagen |
| E215 | EXTERNAL | Keine Versionsreferenz angegeben |
| E216 | EXTERNAL | Expliziter Hook nicht gefunden |

### 7.1 Beispiel: E201

```json
{
    "externals": {
        "headeronly": {
            "git": "https://...",
            "tag": "v1.0",
            "cmakeSupport": false
        }
    }
}
```

Ohne PostFetch-Hook → E201 (keine Targets erstellt)

---

## 8. Verwendungsbeispiele

### 8.1 External mit CMake-Support (GLFW)

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

- PreFetch Hook: Optional (cmake/externals/Hooks/PreFetch/glfw.cmake)
- PostFetch Hook: Nicht nötig (GLFW erstellt eigene Targets)

### 8.2 External ohne CMake-Support (ImGui)

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

- PreFetch Hook: Nicht nötig
- PostFetch Hook: **PFLICHT** (cmake/externals/Hooks/PostFetch/imgui.cmake)

### 8.3 External mit expliziten Hooks

```json
{
    "externals": {
        "mylib": {
            "git": "https://...",
            "tag": "v1.0",
            "preFetchHook": "cmake/hooks/mylib_setup.cmake",
            "postFetchHook": "cmake/hooks/mylib_targets.cmake"
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
-- [HANDLER] Processing fetched external: imgui
-- [HANDLER]   Git: https://github.com/ocornut/imgui.git
-- [HANDLER]   Tag: v1.90.1
-- [HANDLER]   CMake Support: OFF
-- [HANDLER]   Loading PostFetch hook...
-- [imgui] Creating target from: /build/_deps/imgui-src
-- [HANDLER]   Registered targets: imgui
-- [HANDLER] Complete: imgui
```

---

## 10. Siehe auch

- [Fetch.cmake](Fetch_cmake_v0_1_0_doc_v1.md) – FetchContent-Wrapper
- [HookLoader.cmake](HookLoader_cmake_v0_1_0_doc_v1.md) – Hook-System
- [Targets.cmake](Targets_cmake_v0_1_0_doc_v1.md) – Target-Registry
- [Orchestrator.cmake](Orchestrator_cmake_v0_2_0_doc_v1.md) – Koordination
- [imgui PostFetch Hook](../../Hooks/imgui_PostFetch_v0_2_0_doc_v1.md) – Beispiel

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0 (doc v1)** | **2025-12-09** | **Initial: Pipeline, Hook-Integration, Auto-Registrierung** |
