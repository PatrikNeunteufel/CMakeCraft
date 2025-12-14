# Externe Bibliotheken hinzufügen — Benutzerhandbuch

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Guide  
> **Status:** Stabil  
> **Zielgruppe:** C++ Entwickler  
> **Basiert auf:** Guide v0.5  
> **Sprache:** Deutsch  
> **English:** [Adding_Externals_UserGuide.md](../en/guides/Adding_Externals_UserGuide.md)

---

## Inhaltsverzeichnis

1. [Überblick](#1-überblick)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Schnellstart](#3-schnellstart)
4. [External analysieren](#4-external-analysieren)
5. [Solution.json konfigurieren](#5-solutionjson-konfigurieren)
6. [PreFetch Hook erstellen](#6-prefetch-hook-erstellen)
7. [PostFetch Hook erstellen](#7-postfetch-hook-erstellen)
8. [Stolpersteine und Lösungen](#8-stolpersteine-und-lösungen)
9. [Troubleshooting](#9-troubleshooting)
10. [Siehe auch](#10-siehe-auch)
11. [Changelog](#11-changelog)

---

## 1. Überblick

Dieses Handbuch erklärt Schritt für Schritt, wie neue externe Bibliotheken zum CMake Architecture V2 Build-System hinzugefügt werden.

### Ablauf

```
1. External analysieren
   └─ CMake Support? Tests/Examples? Abhängigkeiten?
2. Solution.json konfigurieren
   └─ externals Block erweitern
3. PreFetch Hook erstellen (falls nötig)
   └─ Tests/Examples deaktivieren
4. PostFetch Hook erstellen (falls nötig)
   └─ Target manuell erstellen
5. Executable konfigurieren
   └─ External in externals-Liste aufnehmen
6. Testen
   └─ Configure, Build, Link
```

---

## 2. Voraussetzungen

- [ ] CMake Architecture V2 Build-System
- [ ] Repository-URL des Externals
- [ ] Kenntnisse über CMake-Targets

---

## 3. Schnellstart

**Standard-External mit CMake Support:**

```json
{
    "externals": {
        "spdlog": {
            "git": "https://github.com/gabime/spdlog.git",
            "tag": "v1.14.1"
        }
    },
    "executables": [
        {
            "name": "MyApp",
            "externals": ["spdlog"]
        }
    ]
}
```

**External ohne CMake Support:**

```json
{
    "externals": {
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.91.6",
            "cmakeSupport": false
        }
    }
}
```

→ PostFetch Hook erforderlich!

---

## 4. External analysieren

### 4.1 CMake Support prüfen

**Prüfe im Repository:** Gibt es eine `CMakeLists.txt` im Root?

| Situation | cmakeSupport | Hook |
|-----------|--------------|------|
| CMakeLists.txt vorhanden | `true` (default) | PreFetch optional |
| Kein CMakeLists.txt | `false` | PostFetch **erforderlich** |
| Header-only Library | variiert | Je nach Integration |

### 4.2 Build-Optionen finden

**Suche in CMakeLists.txt nach:**
```cmake
option(BUILD_TESTS ...)
option(BUILD_EXAMPLES ...)
option(XXX_INSTALL ...)
```

### 4.3 Target-Namen identifizieren

**Suche nach:**
```cmake
add_library(target_name ...)
```

---

## 5. Solution.json konfigurieren

### 5.1 Felder-Referenz

| Feld | Pflicht | Beschreibung |
|------|---------|--------------|
| `git` | ✅ | Repository URL |
| `tag` | ✅* | Git Tag (empfohlen) |
| `branch` | ❌* | Git Branch |
| `commit` | ❌* | Commit Hash |
| `cmakeSupport` | ❌ | `false` wenn kein CMakeLists.txt |
| `hook` | ❌ | Hook-Wiederverwendung |

*Genau eines von `tag`, `branch`, `commit` erforderlich.

### 5.2 Mit Hook-Wiederverwendung

```json
"imgui_docking": {
    "git": "https://github.com/ocornut/imgui.git",
    "tag": "v1.91.6-docking",
    "cmakeSupport": false,
    "hook": "imgui"
}
```

---

## 6. PreFetch Hook erstellen

### 6.1 Wann benötigt?

- Tests/Examples/Benchmarks deaktivieren
- Install-Targets deaktivieren
- Spezielle Optionen setzen

### 6.2 Hook-Datei

**Pfad:** `cmake/externals/Hooks/PreFetch/{name}.cmake`

```cmake
# PreFetch/{name}.cmake
message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch: Setting options")

# Disable Tests
set({PREFIX}_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)

# Disable Examples
set({PREFIX}_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)

# Disable Install
set({PREFIX}_INSTALL OFF CACHE BOOL "" FORCE)

message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch complete")
```

**Wichtig:** `CACHE BOOL "" FORCE` überschreibt existierende Werte!

---

## 7. PostFetch Hook erstellen

### 7.1 Wann benötigt?

- `cmakeSupport: false`
- Zusätzliche Targets erforderlich
- Spezielle Konfiguration nach Fetch

### 7.2 Hook-Datei (Static Library)

**Pfad:** `cmake/externals/Hooks/PostFetch/{name}.cmake`

```cmake
# PostFetch/{name}.cmake
message(STATUS "[${HOOK_EXTERNAL_NAME}] Creating target from: ${HOOK_SOURCE_DIR}")

set(_sources
    "${HOOK_SOURCE_DIR}/src/file1.cpp"
    "${HOOK_SOURCE_DIR}/src/file2.cpp"
)

add_library(${HOOK_EXTERNAL_NAME} STATIC ${_sources})
target_include_directories(${HOOK_EXTERNAL_NAME} PUBLIC "${HOOK_SOURCE_DIR}/include")

# Suppress warnings
if(MSVC)
    target_compile_options(${HOOK_EXTERNAL_NAME} PRIVATE /W0)
else()
    target_compile_options(${HOOK_EXTERNAL_NAME} PRIVATE -w)
endif()

_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)
```

### 7.3 Hook-Datei (Header-only)

```cmake
add_library(${HOOK_EXTERNAL_NAME} INTERFACE)
target_include_directories(${HOOK_EXTERNAL_NAME} INTERFACE "${HOOK_SOURCE_DIR}/include")
_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)
```

### 7.4 Wichtige Regeln

- Immer `${HOOK_EXTERNAL_NAME}` verwenden
- Immer `_register_external_target()` aufrufen
- Warnings unterdrücken

---

## 8. Stolpersteine und Lösungen

### 8.1 Target not found

**Problem:** CMake findet Target nicht.

**Lösung:** PostFetch Hook mit `cmakeSupport: false` erstellen.

### 8.2 Undefined reference

**Problem:** Linker-Fehler.

**Lösung:** Target-Namen in CMakeLists.txt des Externals prüfen.

### 8.3 Tests werden gebaut

**Problem:** Build-Zeit zu lang.

**Lösung:** PreFetch Hook mit deaktivierten Tests.

---

## 9. Troubleshooting

### Checkliste

- [ ] Repository URL korrekt?
- [ ] Tag/Branch existiert?
- [ ] CMake Support korrekt gesetzt?
- [ ] Hook-Dateiname = External-Name?
- [ ] Target registriert?

### Häufige Fehler

| Fehler | Lösung |
|--------|--------|
| `Target not found` | PostFetch Hook fehlt |
| `Undefined reference` | Falscher Target-Name |
| `Tests werden gebaut` | PreFetch Hook fehlt |
| `CMake Error in External` | Options prüfen |

---

## 10. Siehe auch

- [Git_Externals_Reference](../reference/Git_Externals_Reference.md) — External-Übersicht
- [HookLoader.cmake](../modules/externals/HookLoader.md) — Hook-System
- [Externals UserGuide](Externals_UserGuide.md) — Verwendung von Externals

---

## 11. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf Guide v0.5 Blueprint** |
| 0.1.0 | 2025-12-10 | Initial: Komplette Anleitung |
