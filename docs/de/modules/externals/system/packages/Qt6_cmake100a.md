# Qt6.cmake — Qt6 Package Hook

> **Version:** 1.0.0  
> **Datum:** 2025-12-21  
> **Typ:** ModuleDoc  
> **Status:** Aktiv  
> **Basiert auf:** ModuleDoc v0.5  
> **Zielgruppe:** Build-System-Entwickler  
> **Sprache:** Deutsch  
> **English:** [Qt6_cmake.md](../../../../../en/modules/externals/system/packages/Qt6_cmake.md)  
> **Modul:** [cmake/externals/system/packages/Qt6.cmake](../../../../../../cmake/externals/system/packages/Qt6.cmake)  
> **Modul-Version:** 1.0.0  
> **Phase:** 9 (System Externals)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [API-Referenz](#2-api-referenz)
3. [Standard-Pfade](#3-standard-pfade)
4. [Target-Konfiguration](#4-target-konfiguration)
5. [Deployment](#5-deployment)
6. [Verwendungsbeispiele](#6-verwendungsbeispiele)
7. [Plattform-Unterschiede](#7-plattform-unterschiede)
8. [Siehe auch](#8-siehe-auch)
9. [Changelog](#9-changelog)

---

## 1. Übersicht

`Qt6.cmake` ist ein **Package-Hook** für Qt6 System Externals. Er wird automatisch von `system/Handler.cmake` geladen, wenn `package="Qt6"` in der External-Definition steht.

### Kernfunktionen

- **Standard-Pfade** — Plattform-spezifische Qt-Installationsorte
- **AUTOMOC/AUTOUIC/AUTORCC** — Automatisch für Qt-Targets aktiviert
- **Deployment** — windeployqt/macdeployqt Integration

### Architektur-Position

```
system/Handler.cmake
       │
       ├── package = "Qt6"
       ▼
┌─────────────────────┐
│  packages/Qt6.cmake │  ← Dieser Hook
└─────────────────────┘
       │
       ├── _get_Qt6_standard_paths()
       ├── _Qt6_post_find()
       └── _Qt6_configure_target()
```

---

## 2. API-Referenz

### 2.1 _get_Qt6_standard_paths()

Liefert plattform-spezifische Qt6-Installationspfade.

```cmake
_get_Qt6_standard_paths(OUT_VAR)
```

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| `OUT_VAR` | Var | Ausgabe: Liste von Pfaden |

**Aufruf:** Automatisch von `system/Handler.cmake` vor `find_package()`.

---

### 2.2 _Qt6_post_find()

Wird nach erfolgreichem `find_package(Qt6)` aufgerufen.

```cmake
_Qt6_post_find()
```

**Aktionen:**
- Speichert Qt-Prefix in `QT6_PREFIX` Global Property
- Ermittelt Pfad aus `Qt6::Core` Target Location

---

### 2.3 _Qt6_configure_target()

Konfiguriert ein CMake-Target für Qt6-Verwendung.

```cmake
_Qt6_configure_target(TARGET_NAME)
```

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| `TARGET_NAME` | String | CMake-Target |

**Aktionen:**
- Aktiviert AUTOMOC, AUTOUIC, AUTORCC
- Ruft `_Qt6_configure_deployment()` auf

---

### 2.4 _Qt6_configure_deployment()

Konfiguriert plattform-spezifisches Qt-Deployment.

```cmake
_Qt6_configure_deployment(TARGET_NAME)
```

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| `TARGET_NAME` | String | CMake-Target |

**Verhalten nach Target-Typ:**

| Target-Typ | Deployment |
|------------|------------|
| EXECUTABLE | Ja (windeployqt/macdeployqt) |
| SHARED_LIBRARY | Ja |
| STATIC_LIBRARY | **Nein** (übersprungen) |
| INTERFACE_LIBRARY | **Nein** (übersprungen) |
| OBJECT_LIBRARY | **Nein** (übersprungen) |

---

## 3. Standard-Pfade

### Windows

```cmake
"C:/Qt/6.10.1/msvc2022_64"
"C:/Qt/6.10.0/msvc2022_64"
"C:/Qt/6.9.0/msvc2022_64"
"C:/Qt/6.8.1/msvc2022_64"
"C:/Qt/6.8.0/msvc2022_64"
"C:/Qt/6.7.3/msvc2022_64"
# ... weitere Versionen
# Alternative Laufwerke: D:, E:, I:
```

### macOS

```cmake
"$ENV{HOME}/Qt/6.8.0/macos"
"$ENV{HOME}/Qt/6.7.0/macos"
"/opt/homebrew/opt/qt@6"    # Homebrew (ARM)
"/usr/local/opt/qt@6"       # Homebrew (Intel)
```

### Linux

```cmake
"$ENV{HOME}/Qt/6.8.0/gcc_64"
"$ENV{HOME}/Qt/6.7.0/gcc_64"
"/opt/Qt/6.8.0/gcc_64"
"/usr/lib/qt6"               # System-Paket
"/usr/lib/x86_64-linux-gnu/qt6"
```

---

## 4. Target-Konfiguration

Wenn `_Qt6_configure_target()` aufgerufen wird:

```cmake
set_target_properties(${TARGET_NAME} PROPERTIES
    AUTOMOC ON      # Meta-Object Compiler
    AUTOUIC ON      # UI-Compiler
    AUTORCC ON      # Resource Compiler
)
```

### Was AUTOMOC macht

- Findet `Q_OBJECT` Makros in Headern
- Generiert `moc_*.cpp` Dateien automatisch
- Keine manuelle `qt_wrap_cpp()` nötig

### Was AUTOUIC macht

- Kompiliert `.ui` Dateien zu `ui_*.h`
- Keine manuelle `qt_wrap_ui()` nötig

### Was AUTORCC macht

- Kompiliert `.qrc` Ressourcen-Dateien
- Keine manuelle `qt_add_resources()` nötig

---

## 5. Deployment

### Windows (windeployqt)

```cmake
add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
    COMMAND "${_WINDEPLOYQT}"
        --no-translations
        --no-system-d3d-compiler
        --no-opengl-sw
        "$<TARGET_FILE:${TARGET_NAME}>"
)
```

**Kopiert automatisch:**
- Qt6Core.dll, Qt6Widgets.dll, etc.
- platforms/qwindows.dll
- Weitere benötigte Plugins

### macOS (macdeployqt)

Nur für Bundle-Targets (`MACOSX_BUNDLE ON`):

```cmake
add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
    COMMAND "${_MACDEPLOYQT}"
        "$<TARGET_BUNDLE_DIR:${TARGET_NAME}>"
        -always-overwrite
)
```

**Konfiguriert außerdem:**
- `INSTALL_RPATH`: `@executable_path/../lib`
- `BUILD_RPATH`: Qt lib-Verzeichnis

### Linux (RPATH)

Kein Deployment-Tool, aber RPATH-Konfiguration:

```cmake
set_target_properties(${TARGET_NAME} PROPERTIES
    INSTALL_RPATH "$ORIGIN/../lib;${_qt_prefix}/lib"
    BUILD_RPATH "${_qt_prefix}/lib"
    INSTALL_RPATH_USE_LINK_PATH TRUE
)
```

---

## 6. Verwendungsbeispiele

### Solution.json

```json
{
    "externals": {
        "qt6": {
            "system": true,
            "package": "Qt6",
            "components": ["Core", "Widgets", "Gui", "OpenGL"],
            "hints": ["${QT_ROOT}"]
        }
    },
    "executables": [
        {
            "name": "MyQtApp",
            "type": "GUI",
            "externals": ["qt6"]
        }
    ]
}
```

### Empfohlene Umgebungsvariable

```bash
# Windows
set QT_ROOT=C:\Qt\6.8.0\msvc2022_64

# Linux/macOS
export QT_ROOT=$HOME/Qt/6.8.0/gcc_64
```

---

## 7. Plattform-Unterschiede

| Feature | Windows | macOS | Linux |
|---------|---------|-------|-------|
| Deployment-Tool | windeployqt | macdeployqt | — |
| RPATH | N/A | Ja | Ja |
| Bundle-Support | N/A | Ja | — |
| DLL-Kopie | Automatisch | Im Bundle | Manual/RPATH |

---

## 8. Siehe auch

- [Handler_cmake.md](../Handler_cmake.md) — Lädt diesen Hook
- [PathResolver_cmake.md](../PathResolver_cmake.md) — Pfad-Auflösung
- [Qt6_Integration.md](../../../../userguides/Qt6_Integration.md) — User Guide
- [Qt6 CMake Documentation](https://doc.qt.io/qt-6/cmake-manual.html) — Offizielle Docs

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.6.1** | **2025-12-21** | **Fix: Deployment für STATIC_LIBRARY überspringen (windeployqt nur für Executables/Shared)** |
| 0.6.0 | 2025-12-18 | Initial: Standard-Pfade, AUTOMOC/AUTOUIC/AUTORCC, Deployment |
