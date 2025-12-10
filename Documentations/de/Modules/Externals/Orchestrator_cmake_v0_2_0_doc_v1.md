# Orchestrator.cmake – Dokumentation

> **Version:** 0.2.0 (doc v1)  
> **Datum:** 2025-12-09  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/externals/Orchestrator.cmake  
> **Modul-Version:** 0.2.0  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Modules/Externals/Orchestrator_cmake_v0_2_0.md)

---

## 1. Übersicht

Das `Orchestrator.cmake` Modul ist der zentrale Einstiegspunkt für das External-System. Es koordiniert die Verarbeitung aller Externals aus `Solution.json` und delegiert an spezialisierte Handler.

### Verantwortlichkeiten

- Externals aus Solution.json lesen
- External-Typ erkennen (Local vs. Fetched)
- An entsprechenden Handler delegieren
- Options für Targets bereitstellen
- Öffentliche API für External-Linking

---

## 2. Abhängigkeiten

| Modul | Version | Verwendung |
|-------|---------|------------|
| Json.cmake | 0.1+ | JSON-Parsing |
| Errors.cmake | 0.1+ | Fehlerbehandlung |
| Debug.cmake | 0.1+ | Debug-Ausgaben |
| Local/Attach.cmake | 0.1+ | Local Externals |
| Fetched/Handler.cmake | 0.1+ | Git Externals |
| Registry/Targets.cmake | 0.1+ | Target-Registry |

---

## 3. Konzept

### 3.1 External-Typen

| Typ | Erkennung | Handler |
|-----|-----------|---------|
| **Local** | `"path"` vorhanden | `Local/Attach.cmake` |
| **Fetched** | `"git"` vorhanden | `Fetched/Handler.cmake` |

### 3.2 Verarbeitungsablauf

```
Solution.json (externals Block)
    ↓
Orchestrator.cmake
    ├── Typ erkennen
    ├── Local? → Attach.cmake
    └── Fetched? → Handler.cmake
            ↓
    Target-Registry
            ↓
    apply_external_to_target()
```

### 3.3 Zwei-Phasen-Verarbeitung

| Phase | Zeitpunkt | Aktion |
|-------|-----------|--------|
| **1. Setup** | CMake-Konfiguration | Alle Externals verarbeiten, Targets erstellen |
| **2. Apply** | Target-Erstellung | Externals an Targets linken |

---

## 4. API-Referenz

### 4.1 _orchestrate_external()

Verarbeitet ein einzelnes External.

```cmake
_orchestrate_external(NAME JSON_ELEMENT)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| NAME | String | External-Name (Key aus Solution.json) |
| JSON_ELEMENT | JSON | JSON-Objekt mit External-Definition |

**Beispiel:**

```cmake
# Intern von Externals.cmake aufgerufen
_orchestrate_external("bass" "${_bass_json}")
_orchestrate_external("imgui" "${_imgui_json}")
```

---

### 4.2 _get_external_options_for_target()

Holt Options-Overrides für ein Target.

```cmake
_get_external_options_for_target(TARGET_NAME EXTERNAL_NAME OUT_OPTIONS)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| TARGET_NAME | String | Name des Targets |
| EXTERNAL_NAME | String | Name des Externals |
| OUT_OPTIONS | Output | Variable für Options-JSON |

**Rückgabe:** JSON-Objekt mit Options oder leer.

---

### 4.3 apply_external_to_target()

**Öffentliche API** – Linkt ein External an ein Target.

```cmake
apply_external_to_target(TARGET_NAME EXTERNAL_NAME)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| TARGET_NAME | String | Ziel-Target |
| EXTERNAL_NAME | String | External-Name |

**Beispiel:**

```cmake
# In ExecutableCreate.cmake
foreach(_ext IN LISTS _externals)
    apply_external_to_target(${_target_name} ${_ext})
endforeach()
```

**Ablauf:**
1. Prüfen ob External registriert
2. Target-spezifische Options laden
3. Primäres Target aus Registry holen
4. `target_link_libraries()` aufrufen

---

## 5. External-Lebenszyklus

### 5.1 Local External

```
1. _orchestrate_external("bass", {...})
2. → _attach_local_external()
3.   → Include.cmake einbinden
4.   → Target erstellen/registrieren
5. apply_external_to_target("MyApp", "bass")
6. → target_link_libraries(MyApp bass)
```

### 5.2 Fetched External

```
1. _orchestrate_external("imgui", {...})
2. → _handle_fetched_external()
3.   → FetchContent_Declare()
4.   → PreFetch Hook (optional)
5.   → FetchContent_MakeAvailable()
6.   → PostFetch Hook (optional)
7.   → Target registrieren
8. apply_external_to_target("MyApp", "imgui")
9. → target_link_libraries(MyApp imgui)
```

---

## 6. Include.cmake Variablen

Für Local Externals stellt der Orchestrator diese Variablen bereit:

| Variable | Beschreibung |
|----------|--------------|
| `EXTERNAL_NAME` | Name des Externals |
| `EXTERNAL_PATH` | Absoluter Pfad zum External |
| `EXTERNAL_JSON` | JSON-Element mit Definition |

**Beispiel in Include.cmake:**

```cmake
# externals/bass/Include.cmake
message(STATUS "Loading ${EXTERNAL_NAME} from ${EXTERNAL_PATH}")

add_library(bass STATIC IMPORTED GLOBAL)
set_target_properties(bass PROPERTIES
    IMPORTED_LOCATION "${EXTERNAL_PATH}/lib/bass.lib"
)
```

---

## 7. Fehlerbehandlung

| Code | Kategorie | Beschreibung |
|------|-----------|--------------|
| E010 | DEPENDENCY | External nicht in Solution.json |
| E201 | EXTERNAL | External hat keine Targets |
| E211 | EXTERNAL | Weder path noch git angegeben |

---

## 8. Verwendungsbeispiele

### 8.1 Local External (BASS)

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

### 8.2 Fetched External (spdlog)

**Solution.json:**
```json
{
    "externals": {
        "spdlog": {
            "git": "https://github.com/gabime/spdlog.git",
            "tag": "v1.12.0"
        }
    }
}
```

### 8.3 Gemischte Externals (GUI App)

**Solution.json:**
```json
{
    "externals": {
        "glad": {
            "path": "externals/glad"
        },
        "glfw": {
            "git": "https://github.com/glfw/glfw.git",
            "tag": "3.4"
        },
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.90.1",
            "cmakeSupport": false
        }
    },
    "executables": [
        {
            "name": "MyGuiApp",
            "path": "src/MyGuiApp",
            "type": "GUI",
            "externals": ["glad", "glfw", "imgui"]
        }
    ]
}
```

---

## 9. Debug-Ausgaben

```bash
cmake -B build -DDEBUG_EXTERNALS=ON
```

**Ausgabe:**
```
-- [EXTERNALS] Processing: bass
-- [EXTERNALS]   Type: Local
-- [EXTERNALS]   Path: externals/bass
-- [EXTERNALS] Processing: imgui
-- [EXTERNALS]   Type: Fetched
-- [EXTERNALS]   Git: https://github.com/ocornut/imgui.git
-- [EXTERNALS]   Tag: v1.90.1
```

---

## 10. Siehe auch

- [Attach.cmake](Attach_cmake_v0_1_0_doc_v1.md) – Local Handler
- [Handler.cmake](Handler_cmake_v0_1_0_doc_v1.md) – Fetched Handler
- [Targets.cmake](Targets_cmake_v0_1_0_doc_v1.md) – Target-Registry
- [HookLoader.cmake](HookLoader_cmake_v0_1_0_doc_v1.md) – Hook-System
- [Solution_Schema](../../References/Solution_Schema_v0_1_0.md) – JSON-Schema

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.2.0 (doc v1)** | **2025-12-09** | **Fetched/Handler.cmake Integration, vollständige Git-External-Unterstützung, Registry-Integration** |
| 0.1.0 | 2025-12-06 | Initial: Local Externals, Typ-Erkennung |
