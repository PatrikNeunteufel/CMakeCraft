# Targets.cmake – Dokumentation

> **Version:** 0.1.0 (doc v1)  
> **Datum:** 2025-12-09  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/externals/Registry/Targets.cmake  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Modules/Externals/Targets_cmake_v0_1_0.md)

---

## 1. Übersicht

Das `Targets.cmake` Modul verwaltet die Target-Registry für Externals. Es ermöglicht die Registrierung, Abfrage und Verknüpfung von External-Targets.

### Verantwortlichkeiten

- Targets für Externals registrieren
- Primäres Target pro External festlegen
- Automatische Target-Erkennung
- Targets an Consumer-Targets linken
- Registry-Status abfragen

---

## 2. Abhängigkeiten

| Modul | Version | Verwendung |
|-------|---------|------------|
| Errors.cmake | 0.1+ | Fehlerbehandlung |
| Debug.cmake | 0.1+ | Debug-Ausgaben |

---

## 3. Konzept

### 3.1 Warum eine Registry?

**Problem ohne Registry:**
```cmake
# Verschiedene Externals erstellen verschiedene Targets
# glfw → "glfw" oder "glfw::glfw"?
# spdlog → "spdlog" oder "spdlog::spdlog"?
# Manuelle Suche nötig
```

**Lösung mit Registry:**
```cmake
# Alle Targets einheitlich registriert
_get_external_primary_target("glfw" _target)  # → "glfw"
target_link_libraries(MyApp ${_target})
```

### 3.2 Globale Properties

| Property | Beschreibung |
|----------|--------------|
| `EXTERNAL_REGISTRY_ALL` | Liste aller registrierten External-Namen |
| `EXTERNAL_${NAME}_TARGETS` | Liste aller Targets für ein External |
| `EXTERNAL_${NAME}_PRIMARY_TARGET` | Primäres (Haupt-) Target |

### 3.3 PRIMARY-Konzept

Ein External kann mehrere Targets haben (z.B. Library + Alias). Das **PRIMARY**-Target ist das Haupt-Target das beim Linken verwendet wird.

```
imgui External:
├── imgui (PRIMARY) ← Dieses wird gelinkt
├── imgui::imgui    (Alias)
└── imgui_backends  (Optional)
```

---

## 4. API-Referenz

### 4.1 _register_external_target()

Registriert ein Target für ein External.

```cmake
_register_external_target(EXTERNAL_NAME TARGET_NAME [PRIMARY])
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| EXTERNAL_NAME | String | Name des Externals |
| TARGET_NAME | String | CMake Target-Name |
| PRIMARY | Flag | Optional: Markiert als Haupt-Target |

**Beispiel:**

```cmake
# In PostFetch Hook
add_library(imgui STATIC ${_sources})
_register_external_target("imgui" "imgui" PRIMARY)

# Alias auch registrieren
add_library(imgui::imgui ALIAS imgui)
_register_external_target("imgui" "imgui::imgui")
```

---

### 4.2 _auto_register_external_targets()

Versucht automatisch Targets zu finden und zu registrieren.

```cmake
_auto_register_external_targets(NAME)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| NAME | String | External-Name |

**Suchstrategie:**

| Reihenfolge | Suchname | Beispiel für "glfw" |
|-------------|----------|---------------------|
| 1 | `${NAME}` | `glfw` |
| 2 | `${NAME}::${NAME}` | `glfw::glfw` |
| 3 | `${name}` (lowercase) | `glfw` |
| 4 | `${name}::${name}` | `glfw::glfw` |

Das erste gefundene Target wird als PRIMARY registriert.

**Beispiel:**

```cmake
# Nach FetchContent_MakeAvailable
_auto_register_external_targets("GLFW")
# Findet "glfw" Target, registriert als PRIMARY
```

---

### 4.3 _get_external_targets()

Gibt alle registrierten Targets eines Externals zurück.

```cmake
_get_external_targets(NAME OUT_VAR)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| NAME | String | External-Name |
| OUT_VAR | Output | Liste der Targets |

**Beispiel:**

```cmake
_get_external_targets("imgui" _targets)
# _targets = "imgui;imgui::imgui"
```

---

### 4.4 _get_external_primary_target()

Gibt das primäre Target eines Externals zurück.

```cmake
_get_external_primary_target(NAME OUT_VAR)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| NAME | String | External-Name |
| OUT_VAR | Output | Primäres Target |

**Beispiel:**

```cmake
_get_external_primary_target("glfw" _target)
# _target = "glfw"
target_link_libraries(MyApp ${_target})
```

---

### 4.5 _has_external_target()

Prüft ob ein External Targets registriert hat.

```cmake
_has_external_target(NAME OUT_VAR)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| NAME | String | External-Name |
| OUT_VAR | Output | Boolean (TRUE/FALSE) |

**Beispiel:**

```cmake
_has_external_target("glfw" _has_target)
if(_has_target)
    message(STATUS "GLFW targets registered")
endif()
```

---

### 4.6 _validate_external_targets()

Validiert dass ein External mindestens ein Target hat.

```cmake
_validate_external_targets(NAME)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| NAME | String | External-Name |

**Verhalten:**
- Keine Targets → E201 (Fatal Error)
- Targets vorhanden → OK

**Beispiel:**

```cmake
# Am Ende der External-Verarbeitung
_validate_external_targets("imgui")  # Fehler wenn keine Targets
```

---

### 4.7 _link_external_to_target()

Linkt das primäre External-Target an ein Consumer-Target.

```cmake
_link_external_to_target(TARGET_NAME EXTERNAL_NAME [SCOPE])
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| TARGET_NAME | String | Consumer-Target |
| EXTERNAL_NAME | String | External-Name |
| SCOPE | Optional | PUBLIC, PRIVATE, INTERFACE (default: PUBLIC) |

**Beispiel:**

```cmake
_link_external_to_target("MyApp" "glfw")
# Äquivalent zu: target_link_libraries(MyApp PUBLIC glfw)

_link_external_to_target("MyLib" "spdlog" PRIVATE)
# Äquivalent zu: target_link_libraries(MyLib PRIVATE spdlog)
```

---

### 4.8 _print_registry_summary()

Gibt eine Debug-Zusammenfassung der Registry aus.

```cmake
_print_registry_summary()
```

**Ausgabe:**

```
-- === External Registry Summary ===
-- bass:
--   Targets: bass
--   Primary: bass
-- glfw:
--   Targets: glfw;glfw::glfw
--   Primary: glfw
-- imgui:
--   Targets: imgui
--   Primary: imgui
-- === End Registry Summary ===
```

---

## 5. Fehlerbehandlung

| Code | Kategorie | Beschreibung |
|------|-----------|--------------|
| E201 | EXTERNAL | External hat keine registrierten Targets |
| E010 | DEPENDENCY | External nicht in Registry gefunden |

---

## 6. Verwendungsbeispiele

### 6.1 In einem PostFetch Hook

```cmake
# cmake/externals/Hooks/PostFetch/mylib.cmake

add_library(mylib STATIC ${_sources})
add_library(mylib::mylib ALIAS mylib)

# Beide registrieren, mylib als PRIMARY
_register_external_target("mylib" "mylib" PRIMARY)
_register_external_target("mylib" "mylib::mylib")
```

### 6.2 In ExecutableCreate.cmake

```cmake
# Externals aus Context lesen
ctx_get(${CTX} EXTERNALS _externals)

# Alle Externals linken
foreach(_ext IN LISTS _externals)
    _link_external_to_target(${_target_name} ${_ext})
endforeach()
```

### 6.3 Automatische Registrierung

```cmake
# In Handler.cmake nach MakeAvailable
FetchContent_MakeAvailable(glfw)

# Versuche automatisch Targets zu finden
_auto_register_external_targets("glfw")

# Prüfen ob erfolgreich
_validate_external_targets("glfw")
```

---

## 7. Internes

### 7.1 Property-Struktur

```cmake
# Nach Registrierung von imgui:
get_property(_all GLOBAL PROPERTY EXTERNAL_REGISTRY_ALL)
# _all = "bass;glfw;imgui"

get_property(_targets GLOBAL PROPERTY EXTERNAL_imgui_TARGETS)
# _targets = "imgui"

get_property(_primary GLOBAL PROPERTY EXTERNAL_imgui_PRIMARY_TARGET)
# _primary = "imgui"
```

### 7.2 Case-Sensitivity

External-Namen werden **case-insensitiv** behandelt für die Suche, aber **case-sensitiv** gespeichert:

```cmake
_register_external_target("GLFW" "glfw" PRIMARY)
_get_external_primary_target("glfw" _target)  # Funktioniert
_get_external_primary_target("GLFW" _target)  # Funktioniert auch
```

---

## 8. Best Practices

1. **PRIMARY immer setzen** – Genau ein Target als PRIMARY markieren
2. **Auto-Register nutzen** – Für Externals mit CMake-Support
3. **Explizit registrieren** – In PostFetch Hooks immer explizit
4. **Validate aufrufen** – Am Ende der External-Verarbeitung

---

## 9. Debug-Ausgaben

```bash
cmake -B build -DDEBUG_EXTERNALS=ON
```

Am Ende der Konfiguration:

```cmake
_print_registry_summary()
```

---

## 10. Siehe auch

- [Handler.cmake](Handler_cmake_v0_1_0_doc_v1.md) – Verwendet Registry
- [Orchestrator.cmake](Orchestrator_cmake_v0_2_0_doc_v1.md) – Koordination
- [HookLoader.cmake](HookLoader_cmake_v0_1_0_doc_v1.md) – Hook-System

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0 (doc v1)** | **2025-12-09** | **Initial: Registry-System, PRIMARY-Konzept, Auto-Registrierung** |
