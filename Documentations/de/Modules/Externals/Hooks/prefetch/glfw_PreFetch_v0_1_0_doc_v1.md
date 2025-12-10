# glfw.cmake PreFetch Hook – Dokumentation

> **Version:** 0.1.0 (doc v1)  
> **Datum:** 2025-12-09  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/externals/Hooks/PreFetch/glfw.cmake  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Hooks/glfw_PreFetch_v0_1_0.md)

---

## 1. Übersicht

Dieser PreFetch-Hook konfiguriert GLFW vor dem Download. Er deaktiviert unnötige Build-Komponenten um die Build-Zeit zu reduzieren.

---

## 2. Aufrufzeitpunkt

```
1. FetchContent_Declare()
2. >>> PreFetch Hook <<<    ← Hier
3. FetchContent_MakeAvailable()
4. PostFetch Hook (falls vorhanden)
```

---

## 3. Gesetzte Optionen

| Option | Wert | Beschreibung |
|--------|------|--------------|
| `GLFW_BUILD_EXAMPLES` | OFF | Beispielprogramme nicht bauen |
| `GLFW_BUILD_TESTS` | OFF | Tests nicht bauen |
| `GLFW_BUILD_DOCS` | OFF | Dokumentation nicht generieren |
| `GLFW_INSTALL` | OFF | Install-Targets nicht erstellen |

---

## 4. Implementierung

```cmake
# cmake/externals/Hooks/PreFetch/glfw.cmake
# PreFetch Hook for GLFW
# Version: 0.1.0

# Disable building examples, tests, docs
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_INSTALL OFF CACHE BOOL "" FORCE)

message(STATUS "[glfw] PreFetch hook: Build options configured")
```

---

## 5. Warum diese Optionen?

### Build-Zeit-Reduktion

| Komponente | Ohne Hook | Mit Hook |
|------------|-----------|----------|
| Examples | ~45 Dateien | 0 |
| Tests | ~20 Dateien | 0 |
| Docs | Doxygen-Lauf | Übersprungen |
| **Geschätzte Zeit** | ~45s | ~15s |

### GLFW_INSTALL OFF

Verhindert:
- CMake Install-Targets
- Installation in System-Verzeichnisse
- Unnötige `install()` Befehle

---

## 6. Solution.json

Der Hook wird automatisch durch Convention geladen:

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

Kein explizites `preFetchHook` Feld nötig – der Hook wird gefunden unter:
`cmake/externals/Hooks/PreFetch/glfw.cmake`

---

## 7. Verfügbare Variablen

Diese Variablen werden vom HookLoader bereitgestellt:

| Variable | Beschreibung |
|----------|--------------|
| `HOOK_EXTERNAL_NAME` | "glfw" |
| `HOOK_EXTERNAL_JSON` | Komplettes JSON-Element |

---

## 8. Weitere GLFW-Optionen

Diese können bei Bedarf im Hook hinzugefügt werden:

| Option | Default | Beschreibung |
|--------|---------|--------------|
| `GLFW_BUILD_WIN32` | ON | Windows-Support |
| `GLFW_BUILD_COCOA` | ON | macOS-Support |
| `GLFW_BUILD_X11` | ON | X11-Support (Linux) |
| `GLFW_BUILD_WAYLAND` | OFF | Wayland-Support (Linux) |
| `GLFW_USE_HYBRID_HPG` | OFF | Hybrid GPU bevorzugen |
| `GLFW_VULKAN_STATIC` | OFF | Vulkan statisch linken |

**Beispiel für Wayland-Support:**

```cmake
# In PreFetch Hook
set(GLFW_BUILD_WAYLAND ON CACHE BOOL "" FORCE)
```

---

## 9. Troubleshooting

### Hook wird nicht geladen

**Prüfen:**
1. Dateiname korrekt: `glfw.cmake` (case-sensitiv!)
2. Pfad korrekt: `cmake/externals/Hooks/PreFetch/`
3. Debug aktivieren: `-DDEBUG_EXTERNALS=ON`

### Optionen werden ignoriert

**Ursache:** CACHE bereits von vorherigem Configure befüllt.

**Lösung:** `FORCE` Flag verwenden (ist bereits im Template) oder Build-Verzeichnis löschen.

---

## 10. Siehe auch

- [HookLoader.cmake](../Modules/Externals/HookLoader_cmake_v0_1_0_doc_v1.md) – Hook-System
- [Handler.cmake](../Modules/Externals/Handler_cmake_v0_1_0_doc_v1.md) – Fetched Handler
- [imgui PostFetch Hook](imgui_PostFetch_v0_2_0_doc_v1.md) – PostFetch Beispiel
- https://www.glfw.org/docs/latest/build_guide.html – GLFW Build-Optionen

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0 (doc v1)** | **2025-12-09** | **Initial: Build-Optionen deaktivieren** |
