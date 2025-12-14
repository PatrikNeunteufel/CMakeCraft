# Qt6 Integration — Benutzerhandbuch

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Guide  
> **Status:** Stabil  
> **Zielgruppe:** C++ Entwickler  
> **Modul:** externals/qt6/Include.cmake v0.6.0  
> **Basiert auf:** Guide v0.5  
> **Sprache:** Deutsch  
> **English:** [Qt6_Integration_UserGuide.md](../en/guides/Qt6_Integration_UserGuide.md)

---

## Inhaltsverzeichnis

1. [Überblick](#1-überblick)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Schnellstart](#3-schnellstart)
4. [Qt6 installieren](#4-qt6-installieren)
5. [Konfiguration](#5-konfiguration)
6. [Umgebungsvariablen](#6-umgebungsvariablen)
7. [Verfügbare Komponenten](#7-verfügbare-komponenten)
8. [Stolpersteine und Lösungen](#8-stolpersteine-und-lösungen)
9. [Troubleshooting](#9-troubleshooting)
10. [Siehe auch](#10-siehe-auch)
11. [Changelog](#11-changelog)

---

## 1. Überblick

Die Qt6-Integration ermöglicht die Verwendung von Qt6 in CMake Architecture V2 Projekten.

### Features

- Flexible Pfad-Erkennung (Umgebungsvariablen, Hints, Auto-Detection)
- Backup-Pfade (USB-Stick, Netzlaufwerk)
- Automatisches DLL-Deployment (Windows)
- RPATH-Konfiguration (Linux/macOS)
- Komponentenauswahl

**Wichtig:** Qt6 ist ein **System External** – die Installation erfolgt außerhalb des Projekts.

### Unterstützte Plattformen

| Plattform | Compiler | Deployment |
|-----------|----------|------------|
| Windows | MSVC 2022, Clang | windeployqt (automatisch) |
| Linux | GCC, Clang | RPATH (automatisch) |
| macOS | Apple Clang | macdeployqt (für Bundles) |

---

## 2. Voraussetzungen

- [ ] CMake Architecture V2 Build-System
- [ ] Qt6 installiert (6.5+)
- [ ] CMake 3.24+
- [ ] Compiler: MSVC 2022 / GCC / Clang

---

## 3. Schnellstart

**1. Solution.json:**

```json
{
    "externals": {
        "qt6": {
            "path": "externals/qt6",
            "options": {
                "hint": "${QT_ROOT}",
                "components": ["Core", "Widgets", "Gui"]
            }
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

**2. C++ Code:**

```cpp
#include <QApplication>
#include <QLabel>

int main(int argc, char* argv[]) {
    QApplication app(argc, argv);
    
    QLabel label("Hello Qt6!");
    label.show();
    
    return app.exec();
}

#include "main.moc"  // WICHTIG am Ende!
```

**3. Build:**

```bash
cmake --preset windows-ninja-debug
cmake --build out/build/windows-ninja-debug
```

---

## 4. Qt6 installieren

### 4.1 Qt Online Installer (Empfohlen)

**Download:** https://www.qt.io/download-qt-installer

1. Qt Maintenance Tool herunterladen und starten
2. Qt Account erstellen (kostenlos für Open Source)
3. Installation wählen: Qt → Qt 6.x.x → Desktop
4. Compiler wählen: MSVC 2022 64-bit (Windows) / GCC 64-bit (Linux)

**Typische Pfade:**

| Plattform | Pfad |
|-----------|------|
| Windows | `C:\Qt\6.10.1\msvc2022_64` |
| Linux | `~/Qt/6.10.1/gcc_64` |
| macOS | `~/Qt/6.10.1/macos` |

### 4.2 System-Pakete (Linux)

```bash
# Ubuntu/Debian
sudo apt install qt6-base-dev qt6-tools-dev

# Arch Linux
sudo pacman -S qt6-base qt6-tools

# Fedora
sudo dnf install qt6-qtbase-devel qt6-qttools-devel
```

### 4.3 Homebrew (macOS)

```bash
brew install qt@6
echo 'export QT_ROOT="$(brew --prefix qt@6)"' >> ~/.zshrc
source ~/.zshrc
```

---

## 5. Konfiguration

### 5.1 Pfad-Auflösung (Priorität)

```
1. QT_ROOT Umgebungsvariable        ← Höchste Priorität
2. QT6_DIR Umgebungsvariable
3. CMAKE_PREFIX_PATH
4. hint aus Solution.json options
5. Standard-Pfade (Auto-Detection)
6. backup aus Solution.json options ← Mit WARNING
```

### 5.2 Minimale Konfiguration

```json
"externals": {
    "qt6": {
        "path": "externals/qt6"
    }
}
```

**Voraussetzung:** `QT_ROOT` oder `QT6_DIR` muss gesetzt sein.

### 5.3 Mit Pfad-Hint

```json
"qt6": {
    "path": "externals/qt6",
    "options": {
        "hint": "C:/Qt/6.10.1/msvc2022_64"
    }
}
```

### 5.4 Mit Backup-Pfad

```json
"qt6": {
    "path": "externals/qt6",
    "options": {
        "hint": "${QT_ROOT}",
        "backup": "E:/Backup/Qt/6.10.1/msvc2022_64"
    }
}
```

### 5.5 Mit Komponenten-Auswahl

```json
"options": {
    "hint": "${QT_ROOT}",
    "components": ["Core", "Widgets", "Gui", "OpenGL", "Network"]
}
```

**Standard-Komponenten:** Core, Gui, Widgets

---

## 6. Umgebungsvariablen

### Windows (dauerhaft)

```cmd
setx QT_ROOT "C:\Qt\6.10.1\msvc2022_64"
```

→ **Neues Terminal und Visual Studio neu starten!**

### Linux/macOS

```bash
export QT_ROOT="$HOME/Qt/6.10.1/gcc_64"
# In ~/.bashrc oder ~/.zshrc eintragen
```

### Visual Studio Workaround

VS erbt nicht automatisch Umgebungsvariablen. Erstelle `CMakeUserPresets.json`:

```json
{
    "version": 6,
    "configurePresets": [
        {
            "name": "qt-env",
            "hidden": true,
            "environment": {
                "QT_ROOT": "C:/Qt/6.10.1/msvc2022_64"
            }
        },
        {
            "name": "windows-ninja-debug-qt",
            "inherits": ["windows-ninja-debug", "qt-env"]
        }
    ]
}
```

---

## 7. Verfügbare Komponenten

### Basis-Module

| Komponente | Beschreibung |
|------------|--------------|
| **Core** | Basisklassen, Container, IO |
| **Gui** | GUI-Basis, Fonts, Images |
| **Widgets** | Desktop-Widgets |

### Erweiterte Module

| Komponente | Beschreibung |
|------------|--------------|
| **OpenGL** | OpenGL-Integration |
| **Network** | HTTP, TCP, UDP |
| **Sql** | Datenbank-Abstraktion |
| **Concurrent** | Threading-Utilities |
| **PrintSupport** | Druckfunktionen |

### QML/Quick

| Komponente | Beschreibung |
|------------|--------------|
| **Qml** | QML-Engine |
| **Quick** | Qt Quick (QML-UI) |
| **QuickControls2** | Moderne UI-Komponenten |

### Multimedia & Spezial

| Komponente | Beschreibung |
|------------|--------------|
| **Multimedia** | Audio/Video |
| **WebEngine** | Chromium-Browser |
| **Charts** | Diagramme |
| **Svg** | SVG-Support |

---

## 8. Stolpersteine und Lösungen

### 8.1 main.moc nicht gefunden

**Problem:** `fatal error: 'main.moc' file not found`

**Lösung:** AUTOMOC wird automatisch gesetzt (Include.cmake v0.4.0+). `#include "main.moc"` am Ende der .cpp-Datei hinzufügen.

### 8.2 Qt-Header nicht gefunden

**Problem:** `fatal error: 'QApplication' file not found`

**Lösung:** Include.cmake v0.3.0+ verwenden.

### 8.3 DLLs fehlen zur Laufzeit

**Problem:** `Qt6Cored.dll not found`

**Lösung:** Include.cmake v0.5.0+ verwenden – windeployqt wird automatisch ausgeführt.

### 8.4 Qt trotz Installation nicht gefunden

**Problem:** `[qt6] Qt6 not found!`

**Diagnose:**
```bash
# Windows
echo %QT_ROOT%
dir "%QT_ROOT%\lib\cmake\Qt6"

# Linux/macOS
echo $QT_ROOT
ls "$QT_ROOT/lib/cmake/Qt6"
```

**Lösungen:** Umgebungsvariable setzen, VS neu starten, CMakeUserPresets.json verwenden.

---

## 9. Troubleshooting

### Checkliste

- [ ] Qt6 installiert?
- [ ] Richtiger Pfad? (`dir %QT_ROOT%\lib\cmake\Qt6`)
- [ ] Umgebungsvariable gesetzt?
- [ ] VS neu gestartet nach `setx`?
- [ ] Include.cmake aktuell (v0.6.0)?
- [ ] CMake-Cache gelöscht? (`cmake --fresh`)

### Häufige Fehler

| Fehler | Lösung |
|--------|--------|
| `Qt6 not found` | Umgebungsvariable/hint prüfen |
| `QApplication not found` | Include.cmake v0.3.0+ |
| `main.moc not found` | Include.cmake v0.4.0+ |
| `Qt6Cored.dll not found` | Include.cmake v0.5.0+ |

---

## 10. Siehe auch

- [Externals Reference](../reference/Externals.md) — Alle Externals
- [Solution_Schema](../reference/Solution_Schema.md) — JSON-Schema
- [CMakeUserPresets Example](CMakeUserPresets_Example.md) — Preset-Beispiele

---

## 11. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf Guide v0.5 Blueprint, strukturierte Abschnitte** |
| 0.2.0 | 2025-12-11 | Umfassende Überarbeitung: Stolpersteine, VS-Workarounds |
| 0.1.0 | 2025-12-10 | Initial |
