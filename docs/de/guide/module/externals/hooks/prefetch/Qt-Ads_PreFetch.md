# PreFetch/qt-ads.cmake — Qt-ADS PreFetch Hook

> **Version:** 2.1.0  
> **Datum:** 2025-12-30  
> **Typ:** ModuleDoc  
> **Status:** Aktiv  
> **Basiert auf:** ModuleDoc v0.5, Doc v0.5  
> **Zielgruppe:** Build-System-Entwickler  
> **Sprache:** Deutsch  
> **English:** [Qt-Ads_PreFetch.md](../../../../en/modules/externals/hooks/prefetch/Qt-Ads.md)  
> **Hook:** [cmake/externals/hooks/prefetch/qt-ads.cmake](../../../../../../cmake/externals/hooks/prefetch/qt-ads.cmake)  
> **Modul-Version:** 2.1.0

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Warum ein PreFetch Hook?](#2-warum-ein-prefetch-hook)
3. [Unterstützte Versionen](#3-unterstützte-versionen)
4. [Gesetzte Optionen](#4-gesetzte-optionen)
5. [Qt6::GuiPrivate (v2.1.0)](#5-qt6guiprivate-v210)
6. [Das DLL-Problem und seine Lösung](#6-das-dll-problem-und-seine-lösung)
7. [Solution.json Konfiguration](#7-solutionjson-konfiguration)
8. [Abhängigkeiten](#8-abhängigkeiten)
9. [Fehlerbehandlung](#9-fehlerbehandlung)
10. [Siehe auch](#10-siehe-auch)
11. [Changelog](#11-changelog)

---

## 1. Übersicht

Der `qt-ads.cmake` PreFetch Hook konfiguriert das Qt Advanced Docking System vor dem Build. Die wichtigsten Funktionen sind:

1. **BUILD_STATIC=ON** — Baut qt-ads als statische Library (eliminiert DLL-Deployment-Probleme)
2. **Qt6::GuiPrivate laden** — Erforderlich für Qt-ADS 4.4.x (Breaking Change!)
3. **BUILD_EXAMPLES=OFF** — Keine Example-Targets
4. **ADS_INSTALL=OFF** — Keine Installation (FetchContent)

---

## 2. Warum ein PreFetch Hook?

**Ohne Hook:**
- Examples und Demo-Targets werden gebaut (10+ zusätzliche Targets)
- **Shared Library (DLL)** wird erzeugt → windeployqt-Fehler!
- Qt-ADS 4.4.x schlägt fehl wegen fehlendem Qt6::GuiPrivate

**Mit Hook:**
- Nur `qt6advanceddocking` bzw. `qtadvanceddocking-qt6` Target
- **Statische Library** (kein DLL-Deployment nötig)
- Qt6::GuiPrivate wird automatisch geladen
- windeployqt läuft fehlerfrei

---

## 3. Unterstützte Versionen

| Qt-ADS Version | Target-Name | Besonderheiten |
|----------------|-------------|----------------|
| **4.3.x** | `qt6advanceddocking` | Original-Konfiguration |
| **4.4.x** | `qtadvanceddocking-qt6` | **Breaking Change:** Benötigt Qt6::GuiPrivate! |

### Breaking Change in 4.4.x

Qt-ADS 4.4.x verwendet Qt Private APIs und hat daher:
- Anderen Target-Namen: `qtadvanceddocking-qt6` statt `qt6advanceddocking`
- Neue Abhängigkeit: `Qt6::GuiPrivate`
- Namespace-Alias: `ads::qtadvanceddocking-qt6`

---

## 4. Gesetzte Optionen

| Option | Wert | Beschreibung |
|--------|------|--------------|
| `BUILD_STATIC` | `ON` | **Statische Library** statt Shared (DLL) |
| `BUILD_EXAMPLES` | `OFF` | Keine Example-Programme |
| `ADS_INSTALL` | `OFF` | Keine Installation (FetchContent) |

### Wichtig: Korrekter Variablenname

Die Variable heißt **`BUILD_STATIC`**, nicht `ADS_BUILD_STATIC`!

```cmake
# RICHTIG:
set(BUILD_STATIC ON CACHE BOOL "Build qt-ads as static library" FORCE)

# FALSCH (funktioniert NICHT):
set(ADS_BUILD_STATIC ON CACHE BOOL "..." FORCE)
```

Siehe: [Qt-ADS CMakeLists.txt](https://github.com/githubuser0xFFFF/Qt-Advanced-Docking-System/blob/master/CMakeLists.txt)

---

## 5. Qt6::GuiPrivate (v2.1.0)

### 5.1 Warum benötigt?

Qt-ADS 4.4.x verwendet Qt Private APIs für erweiterte Docking-Features. Diese APIs sind in `Qt6::GuiPrivate` enthalten und müssen **vor** `FetchContent_MakeAvailable()` geladen werden.

### 5.2 Automatisches Laden

Der PreFetch Hook lädt Qt6::GuiPrivate automatisch:

```cmake
find_package(Qt6 QUIET COMPONENTS GuiPrivate)
if(TARGET Qt6::GuiPrivate)
    message(STATUS "[qt-ads]   Qt6::GuiPrivate: Found")
else()
    find_package(Qt6 REQUIRED COMPONENTS Gui)
    if(NOT TARGET Qt6::GuiPrivate)
        message(WARNING "[qt-ads] Qt6::GuiPrivate not available")
    endif()
endif()
```

### 5.3 Bei Fehler

Falls Qt6::GuiPrivate nicht verfügbar ist:

```
[qt-ads] Qt6::GuiPrivate not available - Qt-ADS 4.4.x may fail to configure
[qt-ads] Consider using Qt-ADS 4.3.1 or ensuring Qt6 private headers are installed
```

**Lösungen:**
1. Qt6 Private Headers installieren (Qt Installer → Additional Libraries)
2. Auf Qt-ADS 4.3.1 downgraden (tag: `4.3.1` in Solution.json)

---

## 6. Das DLL-Problem und seine Lösung

### 6.1 Das Problem

Wenn qt-ads als **Shared Library (DLL)** gebaut wird, tritt folgender Fehler auf:

```
Unable to find dependent libraries of C:\Qt\6.10.1\msvc2022_64\bin\qt6advanceddockingd.dll
Cannot open 'C:/Qt/6.10.1/msvc2022_64/bin/qt6advanceddockingd.dll': Das System kann die angegebene Datei nicht finden.
```

### 6.2 Ursache

1. **windeployqt** scannt die Executable nach DLL-Abhängigkeiten
2. Es findet die Abhängigkeit `qt6advanceddockingd.dll`
3. windeployqt sucht diese DLL im **Qt-bin-Verzeichnis** (`C:\Qt\...\bin\`)
4. Die DLL ist dort nicht vorhanden (sie wurde via FetchContent gebaut)
5. **windeployqt bricht ab** — auch die Qt-DLLs werden nicht kopiert!

### 6.3 Versuchte Lösungen (die NICHT funktionieren)

| Ansatz | Problem |
|--------|---------|
| DLL vor windeployqt kopieren | windeployqt sucht trotzdem im Qt-Verzeichnis |
| PATH erweitern | windeployqt ignoriert PATH für Dependency-Analyse |
| `--ignore-library-errors` Flag | Nicht in allen Qt-Versionen verfügbar |
| windeployqt-Fehler ignorieren | Qt-DLLs werden trotzdem nicht kopiert |

### 6.4 Die Lösung: Statische Library

Durch `BUILD_STATIC=ON` wird qt-ads als **statische Library** (`.lib`) gebaut:

| Aspekt | Shared (DLL) | Static (LIB) |
|--------|--------------|--------------|
| Output | `qt6advanceddockingd.dll` | `qt6advanceddockingd.lib` |
| Deployment | DLL muss kopiert werden | In Executable eingelinkt |
| windeployqt | ❌ Fehler | ✅ Kein Problem |
| Dateigröße EXE | Kleiner | Größer (~2-3 MB) |

**Vorteile der statischen Library:**
- ✅ Kein DLL-Kopieren nötig
- ✅ windeployqt läuft ohne Fehler
- ✅ Einfacheres Deployment (alles in einer EXE)
- ✅ Keine DLL-Hell-Probleme

---

## 7. Solution.json Konfiguration

### 7.1 Qt-ADS 4.3.x (stabil)

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

### 7.2 Qt-ADS 4.4.x (neueste Features)

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

**Wichtig:** `GuiPrivate` muss in den Qt6-Components enthalten sein, da Qt-ADS 4.4.x Qt Private APIs verwendet.

### 7.3 Wichtig: Reihenfolge

Qt6 muss **vor** qt-ads verarbeitet werden. Dies wird durch die alphabetische Sortierung sichergestellt:
- `Qt6` (Q=81 ASCII) → wird zuerst verarbeitet
- `qt-ads` (q=113 ASCII) → wird danach verarbeitet

---

## 8. Abhängigkeiten

| External | Typ | Beschreibung |
|----------|-----|--------------|
| `Qt6` | System | Qt6 Core, Widgets, Gui müssen vorher geladen sein |
| `Qt6::GuiPrivate` | System (optional) | Nur für Qt-ADS 4.4.x erforderlich |

---

## 9. Fehlerbehandlung

### 9.1 qt-ads wird trotzdem als DLL gebaut

**Symptom:**
```
[27/45] Linking CXX shared library x64\bin\qt6advanceddockingd.dll
```

**Ursache:** CMake Cache enthält noch alte Werte.

**Lösung:**
```cmd
rd /s /q .externals\qt-ads
rd /s /q out\build\<preset-name>
```

Dann CMake neu konfigurieren.

### 9.2 Qt-ADS 4.4.x konfiguriert nicht

**Symptom:**
```
CMake Error: Could not find a package configuration file provided by "Qt6" with any of the following names:
  Qt6GuiPrivate.cmake
```

**Ursache:** Qt6::GuiPrivate nicht installiert.

**Lösung:**
1. Qt Installer öffnen
2. Unter "Additional Libraries" die Private Headers aktivieren
3. ODER: Qt-ADS 4.3.1 verwenden (kein GuiPrivate nötig)

### 9.3 Prüfen im CMake-Output

Bei korrekter Konfiguration:

```
-- [qt-ads] PreFetch: Configuring build options
-- [qt-ads]   Qt6::GuiPrivate: Found
-- [qt-ads]   BUILD_STATIC: ON (static library)
-- [qt-ads]   BUILD_EXAMPLES: OFF
-- [qt-ads]   ADS_INSTALL: OFF
-- [qt-ads] PreFetch complete
```

---

## 10. Siehe auch

- [Qt-Ads_PostFetch.md](../postfetch/Qt-Ads.md) — PostFetch Hook (Target-Registrierung)
- [HookLoader.md](../../hooks/HookLoader_cmake.md) — Hook-System
- [Qt6.md](../../../../userguides/externals/Qt6.md) — Qt6 System External

---

## 11. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **2.1.0** | **2025-12-30** | **Neu: Qt6::GuiPrivate Support für Qt-ADS 4.4.x** |
| | | **Neu: ADS_INSTALL=OFF Option** |
| | | **Neu: Dokumentation für 4.3.x vs 4.4.x Breaking Changes** |
| 1.1.0 | 2025-12-27 | Fix: `BUILD_STATIC` statt `ADS_BUILD_STATIC` |
| | | Neu: Ausführliche Dokumentation des DLL-Problems |
| 1.0.0 | 2025-12-21 | Initial: PreFetch Hook für Qt-ADS |
