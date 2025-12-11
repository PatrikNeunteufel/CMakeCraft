# Externe Bibliotheken hinzufügen – Benutzerhandbuch

> **Version:** 0.1.0  
> **Datum:** 2025-12-10  
> **Typ:** Benutzer-Doku  
> **Status:** Stabil  
> **Sprache:** Deutsch

---

## Übersicht

Dieses Handbuch erklärt Schritt für Schritt, wie neue externe Bibliotheken zum CMake Architecture V2 Build-System hinzugefügt werden.

### Ablauf

```
┌─────────────────────────────────────────────────────────────┐
│ 1. External analysieren                                      │
│    └─ CMake Support? Tests/Examples? Abhängigkeiten?        │
├─────────────────────────────────────────────────────────────┤
│ 2. Solution.json konfigurieren                               │
│    └─ externals Block erweitern                             │
├─────────────────────────────────────────────────────────────┤
│ 3. PreFetch Hook erstellen (falls nötig)                    │
│    └─ Tests/Examples deaktivieren                           │
├─────────────────────────────────────────────────────────────┤
│ 4. PostFetch Hook erstellen (falls nötig)                   │
│    └─ Target manuell erstellen                              │
├─────────────────────────────────────────────────────────────┤
│ 5. Executable konfigurieren                                  │
│    └─ External in externals-Liste aufnehmen                 │
├─────────────────────────────────────────────────────────────┤
│ 6. Testen                                                    │
│    └─ Configure, Build, Link                                │
└─────────────────────────────────────────────────────────────┘
```

---

## Schritt 1: External analysieren

Bevor du ein External hinzufügst, beantworte folgende Fragen:

### 1.1 CMake Support prüfen

**Prüfe im Repository:**
- Gibt es eine `CMakeLists.txt` im Root?
- Wird `add_library()` oder `add_executable()` verwendet?

| Situation | cmakeSupport | Hook |
|-----------|--------------|------|
| CMakeLists.txt vorhanden | `true` (default) | PreFetch optional |
| Kein CMakeLists.txt | `false` | PostFetch **erforderlich** |
| Header-only Library | `true` oder `false` | Je nach CMake-Integration |

### 1.2 Build-Optionen finden

**Suche in CMakeLists.txt nach:**
```cmake
option(BUILD_TESTS ...)
option(BUILD_EXAMPLES ...)
option(BUILD_DOCS ...)
option(XXX_INSTALL ...)
```

Diese sollten im PreFetch Hook deaktiviert werden.

### 1.3 Target-Namen identifizieren

**Suche nach:**
```cmake
add_library(target_name ...)
```

Du brauchst den genauen Target-Namen für `target_link_libraries()`.

### 1.4 Abhängigkeiten prüfen

- Braucht das External andere Libraries?
- Sind diese bundled oder extern?

---

## Schritt 2: Solution.json konfigurieren

### 2.1 Basis-Konfiguration

**Füge zum `externals` Block hinzu:**

```json
{
    "externals": {
        "mein_external": {
            "git": "https://github.com/user/repo.git",
            "tag": "v1.0.0"
        }
    }
}
```

### 2.2 Felder-Referenz

| Feld | Pflicht | Beschreibung |
|------|---------|--------------|
| `git` | ✅ | Repository URL |
| `tag` | ✅* | Git Tag (empfohlen) |
| `branch` | ❌* | Git Branch (für bleeding edge) |
| `commit` | ❌* | Commit Hash (für exakte Version) |
| `cmakeSupport` | ❌ | `false` wenn kein CMakeLists.txt |
| `hook` | ❌ | Hook-Wiederverwendung |

*Genau eines von `tag`, `branch`, `commit` erforderlich.

### 2.3 Beispiele

**Standard (mit CMake Support):**
```json
"spdlog": {
    "git": "https://github.com/gabime/spdlog.git",
    "tag": "v1.14.1"
}
```

**Ohne CMake Support:**
```json
"imgui": {
    "git": "https://github.com/ocornut/imgui.git",
    "tag": "v1.91.6",
    "cmakeSupport": false
}
```

**Mit Hook-Wiederverwendung:**
```json
"imgui_docking": {
    "git": "https://github.com/ocornut/imgui.git",
    "tag": "v1.91.6-docking",
    "cmakeSupport": false,
    "hook": "imgui"
}
```

---

## Schritt 3: PreFetch Hook erstellen

### 3.1 Wann benötigt?

Ein PreFetch Hook ist sinnvoll wenn das External:
- Tests/Examples/Benchmarks baut (Build-Zeit!)
- Install-Targets erstellt (nicht nötig mit FetchContent)
- Dokumentation generiert
- Spezielle Optionen braucht

### 3.2 Hook-Datei erstellen

**Pfad:** `cmake/externals/Hooks/PreFetch/{name}.cmake`

**Template:**
```cmake
# ==============================================================================
# PreFetch/{name}.cmake – {Name} PreFetch Hook
# ==============================================================================
#
# Hook:         {name}.cmake
# Version:      0.1.0
# Date:         {DATUM}
# Part of:      CMake Architecture V2
#
# Description:
#   PreFetch hook for {Name}.
#   Disables tests, examples, and installation.
#
# ==============================================================================

message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch: Setting options")

# ==============================================================================
# Disable Tests
# ==============================================================================

set({PREFIX}_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set({PREFIX}_BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)

# ==============================================================================
# Disable Examples
# ==============================================================================

set({PREFIX}_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)

# ==============================================================================
# Disable Install
# ==============================================================================

set({PREFIX}_INSTALL OFF CACHE BOOL "" FORCE)

# ==============================================================================
# Disable Documentation
# ==============================================================================

set({PREFIX}_BUILD_DOCS OFF CACHE BOOL "" FORCE)

message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch complete")
```

### 3.3 Wichtige Hinweise

**CACHE BOOL "" FORCE:**
```cmake
set(OPTION OFF CACHE BOOL "" FORCE)
#                          ^^^^^ Wichtig! Überschreibt existierende Werte
```

**Dynamischer Name:**
```cmake
message(STATUS "[${HOOK_EXTERNAL_NAME}] ...")
#                ^^^^^^^^^^^^^^^^^^^^^ Verwende immer diese Variable
```

---

## Schritt 4: PostFetch Hook erstellen

### 4.1 Wann benötigt?

Ein PostFetch Hook ist **erforderlich** wenn:
- `cmakeSupport: false` (kein CMakeLists.txt)
- Zusätzliche Targets erstellt werden müssen
- Spezielle Konfiguration nach dem Fetch nötig ist

### 4.2 Hook-Datei erstellen

**Pfad:** `cmake/externals/Hooks/PostFetch/{name}.cmake`

**Template (für Library ohne CMake):**
```cmake
# ==============================================================================
# PostFetch/{name}.cmake – {Name} PostFetch Hook
# ==============================================================================
#
# Hook:         {name}.cmake
# Version:      0.1.0
# Date:         {DATUM}
# Part of:      CMake Architecture V2
#
# Description:
#   PostFetch hook for {Name}.
#   Creates the library target manually.
#
# Provided Variables:
#   HOOK_EXTERNAL_NAME - Name of the external (use for target names!)
#   HOOK_SOURCE_DIR    - Path to source directory
#
# ==============================================================================

message(STATUS "[${HOOK_EXTERNAL_NAME}] Creating target from: ${HOOK_SOURCE_DIR}")

# ==============================================================================
# Collect Source Files
# ==============================================================================

set(_sources
    "${HOOK_SOURCE_DIR}/src/file1.cpp"
    "${HOOK_SOURCE_DIR}/src/file2.cpp"
)

set(_includes
    "${HOOK_SOURCE_DIR}/include"
)

# ==============================================================================
# Create Library Target
# ==============================================================================

add_library(${HOOK_EXTERNAL_NAME} STATIC ${_sources})

target_include_directories(${HOOK_EXTERNAL_NAME} PUBLIC ${_includes})

# C++ Standard (falls nötig)
target_compile_features(${HOOK_EXTERNAL_NAME} PUBLIC cxx_std_17)

# Suppress warnings in external code
if(MSVC)
    target_compile_options(${HOOK_EXTERNAL_NAME} PRIVATE /W0)
else()
    target_compile_options(${HOOK_EXTERNAL_NAME} PRIVATE -w)
endif()

# ==============================================================================
# Register Target
# ==============================================================================

_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)

message(STATUS "[${HOOK_EXTERNAL_NAME}] Target created")
message(STATUS "[${HOOK_EXTERNAL_NAME}] PostFetch complete")
```

**Template (für Header-only Library):**
```cmake
# ==============================================================================
# PostFetch/{name}.cmake – {Name} PostFetch Hook (Header-only)
# ==============================================================================

message(STATUS "[${HOOK_EXTERNAL_NAME}] Creating INTERFACE target")

# ==============================================================================
# Create Interface Library
# ==============================================================================

add_library(${HOOK_EXTERNAL_NAME} INTERFACE)

target_include_directories(${HOOK_EXTERNAL_NAME} INTERFACE 
    "${HOOK_SOURCE_DIR}/include"
)

# ==============================================================================
# Register Target
# ==============================================================================

_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)

message(STATUS "[${HOOK_EXTERNAL_NAME}] INTERFACE target created")
```

### 4.3 Wichtige Regeln

**Immer `${HOOK_EXTERNAL_NAME}` verwenden:**
```cmake
# ✅ Richtig
add_library(${HOOK_EXTERNAL_NAME} STATIC ${sources})

# ❌ Falsch
add_library(mylib STATIC ${sources})
```

**Immer Target registrieren:**
```cmake
_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)
```

**Warnings unterdrücken:**
```cmake
if(MSVC)
    target_compile_options(${HOOK_EXTERNAL_NAME} PRIVATE /W0)
else()
    target_compile_options(${HOOK_EXTERNAL_NAME} PRIVATE -w)
endif()
```

---

## Schritt 5: Executable konfigurieren

**Füge das External zur Executable hinzu:**

```json
{
    "executables": [
        {
            "name": "MyApp",
            "externals": ["mein_external"]
        }
    ]
}
```

**Reihenfolge beachten:**

Wenn Externals voneinander abhängen, müssen sie in der richtigen Reihenfolge stehen:

```json
"externals": ["glad", "glfw", "imgui"]
#              ^^^^   ^^^^   ^^^^^
#              1.     2.     3. (braucht 1 und 2)
```

---

## Schritt 6: Testen

### 6.1 Konfigurieren

```bash
cmake --preset msvc-debug
```

**Erwartete Ausgabe:**
```
[mein_external] PreFetch: Setting options
[mein_external] PreFetch complete
...
[mein_external] Fetching from https://github.com/...
[mein_external] Fetched and configured successfully
```

### 6.2 Bauen

```bash
cmake --build build/msvc-debug --target MyApp
```

### 6.3 Fehlersuche

| Problem | Mögliche Ursache | Lösung |
|---------|------------------|--------|
| "Target not found" | PostFetch Hook fehlt | Hook erstellen mit `cmakeSupport: false` |
| "Undefined reference" | Falscher Target-Name | Target-Namen in Library prüfen |
| Tests werden gebaut | PreFetch Hook fehlt/falsch | Options prüfen |
| CMake Error in External | Falsche Options | CMakeLists.txt des Externals prüfen |

---

## Checkliste

### Neues External hinzufügen

- [ ] Repository URL und Tag identifiziert
- [ ] CMake Support geprüft
- [ ] Build-Optionen identifiziert
- [ ] Target-Name identifiziert
- [ ] Solution.json erweitert
- [ ] PreFetch Hook erstellt (falls nötig)
- [ ] PostFetch Hook erstellt (falls nötig)
- [ ] Executable konfiguriert
- [ ] Configure erfolgreich
- [ ] Build erfolgreich
- [ ] Linking erfolgreich

---

## Siehe auch

- [Git_Externals_Reference](../References/Git_Externals_Reference_v0_1_0.md) – Externe Bibliotheken Übersicht
- [Solution_Schema](../References/Solution_Schema_v0_1_2.md) – JSON Schema
- [HookLoader.cmake](../Modules/HookLoader_cmake_v0_2_0_doc_v1.md) – Hook-System

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-10** | **Initial: Komplette Anleitung mit Templates** |
