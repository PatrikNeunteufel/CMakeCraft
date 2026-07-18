# PostFetch/qt-ads.cmake — Qt-ADS PostFetch Hook

> **Version:** 2.0.0  
> **Datum:** 2025-12-30  
> **Typ:** ModuleDoc  
> **Status:** Aktiv  
> **Basiert auf:** ModuleDoc v0.5, Doc v0.5  
> **Zielgruppe:** Build-System-Entwickler  
> **Sprache:** Deutsch  
> **English:** [Qt-Ads_PostFetch.md](../../../../en/modules/externals/hooks/postfetch/Qt-Ads.md)  
> **Hook:** [cmake/externals/hooks/postfetch/qt-ads.cmake](../../../../../../cmake/externals/hooks/postfetch/qt-ads.cmake)  
> **Modul-Version:** 2.0.0

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Warum ein PostFetch Hook?](#2-warum-ein-postfetch-hook)
3. [Unterstützte Versionen](#3-unterstützte-versionen)
4. [Target-Erkennung](#4-target-erkennung)
5. [Erstellte Targets](#5-erstellte-targets)
6. [Debug-Ausgabe (v2.0.0)](#6-debug-ausgabe-v200)
7. [Solution.json Konfiguration](#7-solutionjson-konfiguration)
8. [Verwendung in Executables/Apps](#8-verwendung-in-executablesapps)
9. [Abhängigkeiten](#9-abhängigkeiten)
10. [Fehlerbehandlung](#10-fehlerbehandlung)
11. [Siehe auch](#11-siehe-auch)
12. [Changelog](#12-changelog)

---

## 1. Übersicht

Der `qt-ads.cmake` PostFetch Hook registriert das Qt Advanced Docking System Target in der External-Registry. Qt-ADS verwendet unterschiedliche Target-Namen je nach Version, die der Hook automatisch erkennt.

**Seit v1.1.0:** Der Hook registriert nur noch das Target. DLL-Kopier-Logik wurde entfernt, da qt-ads als **statische Library** gebaut wird (siehe PreFetch Hook).

**Neu in v2.0.0:** Unterstützung für Qt-ADS 4.4.x mit neuem Target-Naming und Debug-Ausgabe bei fehlendem Target.

---

## 2. Warum ein PostFetch Hook?

Qt-ADS erstellt Targets mit unterschiedlichen Namen je nach Version:

| Version | Target-Name |
|---------|-------------|
| 4.3.x (Qt6) | `qt6advanceddocking` |
| 4.4.x (Qt6) | `qtadvanceddocking-qt6` |
| Qt5 (legacy) | `qtadvanceddocking` oder `qtadvanceddocking-qt5` |

Das Build-System kann diese Targets ohne Hook nicht automatisch unter `qt-ads` finden.

**Ohne Hook:** `[E201] Fetched external 'qt-ads': No target in registry`

**Mit Hook:** Target wird korrekt registriert und kann verwendet werden.

---

## 3. Unterstützte Versionen

| Qt-ADS Version | Target-Name | Namespace-Alias |
|----------------|-------------|-----------------|
| **4.4.x** (Qt6) | `qtadvanceddocking-qt6` | `ads::qtadvanceddocking-qt6` |
| **4.3.x** (Qt6) | `qt6advanceddocking` | — |
| 4.x (Qt5) | `qtadvanceddocking-qt5` | — |
| Legacy | `qtadvanceddocking` | — |

### Breaking Change in 4.4.x

Qt-ADS 4.4.x hat das Target-Naming geändert:
- **Alt (4.3.x):** `qt6advanceddocking`
- **Neu (4.4.x):** `qtadvanceddocking-qt6` mit Namespace `ads::`

Der PostFetch Hook unterstützt beide Konventionen automatisch.

---

## 4. Target-Erkennung

Der Hook prüft alle möglichen Target-Namen in Prioritätsreihenfolge:

```cmake
# Qt-ADS 4.4.x (bevorzugt)
if(TARGET qtadvanceddocking-qt6)
    _register_external_target("${HOOK_EXTERNAL_NAME}" "qtadvanceddocking-qt6" PRIMARY)

# Qt-ADS 4.4.x Namespace-Alias
elseif(TARGET ads::qtadvanceddocking-qt6)
    _register_external_target("${HOOK_EXTERNAL_NAME}" "ads::qtadvanceddocking-qt6" PRIMARY)

# Qt-ADS 4.3.x (legacy)
elseif(TARGET qt6advanceddocking)
    _register_external_target("${HOOK_EXTERNAL_NAME}" "qt6advanceddocking" PRIMARY)

# Qt5 Fallback
elseif(TARGET qtadvanceddocking-qt5)
    _register_external_target("${HOOK_EXTERNAL_NAME}" "qtadvanceddocking-qt5" PRIMARY)

elseif(TARGET qtadvanceddocking)
    _register_external_target("${HOOK_EXTERNAL_NAME}" "qtadvanceddocking" PRIMARY)
endif()
```

Dadurch funktioniert der Hook mit allen Qt-ADS Versionen und Qt5/Qt6.

---

## 5. Erstellte Targets

| Target | Typ | Version | Beschreibung |
|--------|-----|---------|--------------|
| `qtadvanceddocking-qt6` | **STATIC** | 4.4.x | Qt6 Advanced Docking (neu) |
| `ads::qtadvanceddocking-qt6` | **ALIAS** | 4.4.x | Namespace-Alias |
| `qt6advanceddocking` | **STATIC** | 4.3.x | Qt6 Advanced Docking (legacy) |
| `qtadvanceddocking-qt5` | **STATIC** | 4.x | Qt5 Fallback |
| `qtadvanceddocking` | **STATIC** | legacy | Altes Naming |

**Hinweis:** Alle Targets werden als **STATIC** Library gebaut (konfiguriert im PreFetch Hook).

---

## 6. Debug-Ausgabe (v2.0.0)

Falls kein bekanntes Target gefunden wird, listet der Hook alle verfügbaren Targets zur Diagnose:

```cmake
if(NOT _target_found)
    message(WARNING "[qt-ads] No known target found!")
    message(STATUS "[qt-ads] Checking for targets containing 'ads' or 'docking'...")
    
    get_property(_all_targets DIRECTORY "${HOOK_SOURCE_DIR}" PROPERTY BUILDSYSTEM_TARGETS)
    foreach(_target IN LISTS _all_targets)
        string(TOLOWER "${_target}" _target_lower)
        if(_target_lower MATCHES "ads|docking|advanceddocking")
            message(STATUS "[qt-ads]   Found potential target: ${_target}")
        endif()
    endforeach()
endif()
```

Diese Ausgabe hilft bei der Diagnose neuer Qt-ADS Versionen mit möglicherweise geänderten Target-Namen.

---

## 7. Solution.json Konfiguration

### 7.1 Qt-ADS 4.3.x

```json
{
    "externals": {
        "Qt6": {
            "system": true,
            "package": "Qt6",
            "components": ["Core", "Widgets", "Gui"],
            "hints": ["${QT_ROOT}"]
        },
        "qt-ads": {
            "git": "https://github.com/githubuser0xFFFF/Qt-Advanced-Docking-System.git",
            "tag": "4.3.1"
        }
    }
}
```

### 7.2 Qt-ADS 4.4.x

```json
{
    "externals": {
        "Qt6": {
            "system": true,
            "package": "Qt6",
            "components": ["Core", "Widgets", "Gui", "GuiPrivate"],
            "hints": ["${QT_ROOT}"]
        },
        "qt-ads": {
            "git": "https://github.com/githubuser0xFFFF/Qt-Advanced-Docking-System.git",
            "tag": "4.4.0"
        }
    }
}
```

**Wichtig:** `GuiPrivate` muss in den Qt6-Components enthalten sein (siehe PreFetch Doku).

---

## 8. Verwendung in Executables/Apps

### 8.1 In Executable

```json
{
    "executables": [{
        "name": "MyDockingApp",
        "type": "GUI",
        "externals": ["Qt6", "qt-ads"]
    }]
}
```

### 8.2 In App-Container

```json
{
    "apps": [{
        "name": "MyVisualizer",
        "core": {
            "externals": ["Qt6", "qt-ads"]
        },
        "runner": {
            "type": "GUI",
            "externals": ["Qt6"]
        }
    }]
}
```

### 8.3 Im Code

Der registrierte Target-Name ist immer `qt-ads`, unabhängig vom tatsächlichen CMake-Target:

```cpp
// CMakeLists.txt oder Solution.json
// externals: ["qt-ads"]

// C++ Code
#include "DockManager.h"
// Funktioniert mit 4.3.x UND 4.4.x
```

---

## 9. Abhängigkeiten

| External | Typ | Beschreibung |
|----------|-----|--------------|
| `Qt6` | System | Qt6 Core, Widgets, Gui (muss vorher geladen sein) |
| `Qt6::GuiPrivate` | System | Nur für Qt-ADS 4.4.x (geladen im PreFetch) |

### Reihenfolge in Solution.json

Qt6 **muss vor** qt-ads in der alphabetischen Sortierung stehen:
- ✅ `Qt6` → `qt-ads` (Großbuchstabe Q vor Kleinbuchstabe q)
- ❌ `qt6` → `qt-ads` (beide mit kleinem q, falsche Reihenfolge)

---

## 10. Fehlerbehandlung

### 10.1 Kein Target gefunden

**Symptom:**
```
[qt-ads] No known target found!
[qt-ads] Expected one of: qtadvanceddocking-qt6, qt6advanceddocking, qtadvanceddocking
```

**Ursachen:**
1. Qt wurde nicht gefunden
2. Qt-ADS konnte nicht kompiliert werden
3. Neue Qt-ADS Version mit unbekanntem Target-Namen

**Lösung:**
1. Sicherstellen dass Qt6 vor qt-ads geladen wird
2. CMake-Output auf Kompilierungsfehler prüfen
3. Debug-Ausgabe für potentielle Targets prüfen

### 10.2 Qt-ADS 4.4.x schlägt fehl

**Symptom:**
```
CMake Error: Qt6::GuiPrivate not found
```

**Lösung:** PreFetch Hook prüfen oder auf 4.3.1 downgraden (siehe PreFetch Doku).

### 10.3 Erfolgreiche Registrierung

Bei korrekter Konfiguration:

```
-- [qt-ads] PostFetch: Registering target
-- [qt-ads] Registered: qtadvanceddocking-qt6 (v4.4.x, STATIC)
-- [qt-ads] PostFetch complete
```

oder für 4.3.x:

```
-- [qt-ads] PostFetch: Registering target
-- [qt-ads] Registered: qt6advanceddocking (v4.3.x, STATIC)
-- [qt-ads] PostFetch complete
```

---

## 11. Siehe auch

- [Qt-Ads_PreFetch.md](../prefetch/Qt-Ads.md) — PreFetch Hook (Build-Optionen, Qt6::GuiPrivate, **DLL-Problem-Lösung**)
- [HookLoader.md](../../hooks/HookLoader_cmake.md) — Hook-System
- [Targets.md](../../registry/Targets_cmake.md) — Target-Registrierung
- [Qt6.md](../../../../userguides/externals/Qt6.md) — Qt6 System External

---

## 12. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **2.0.0** | **2025-12-30** | **Neu: Support für Qt-ADS 4.4.x Target-Namen (`qtadvanceddocking-qt6`)** |
| | | **Neu: Support für `ads::` Namespace-Alias** |
| | | **Neu: Debug-Ausgabe bei fehlendem Target** |
| | | **Neu: Qt5-Fallback-Targets (`qtadvanceddocking-qt5`)** |
| 1.1.0 | 2025-12-27 | Entfernt: POST_LINK Hook für DLL-Kopie (nicht mehr nötig) |
| | | Aktualisiert: Dokumentation für statische Library |
| 1.0.0 | 2025-12-21 | Initial: PostFetch Hook für Qt-ADS Target-Registrierung |
