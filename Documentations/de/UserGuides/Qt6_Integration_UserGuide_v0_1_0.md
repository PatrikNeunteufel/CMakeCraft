# Qt6 Integration – Benutzerhandbuch

> **Version:** 0.1.0  
> **Datum:** 2025-12-10  
> **Typ:** Benutzer-Doku  
> **Status:** Stabil

---

## Übersicht

Qt6 ist zu groß für das `externals/` Verzeichnis und wird daher als **System External** behandelt. Die Integration unterstützt verschiedene Installationsmethoden:

| Methode | Beschreibung | Empfohlen für |
|---------|--------------|---------------|
| **Qt Installer** | Offizieller Qt Maintenance Tool | Windows, macOS |
| **System-Pakete** | apt, pacman, brew | Linux, macOS |
| **Manuell entpackt** | Zip/tar.xz Download | Alle Plattformen |
| **vcpkg** | Microsoft Package Manager | Cross-platform |

---

## Schnellstart

### 1. Solution.json konfigurieren

```json
{
    "externals": {
        "qt6": {
            "path": "externals/qt6"
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

### 2. Qt-Pfad setzen

**Option A: Umgebungsvariable (empfohlen)**
```bash
# Windows (PowerShell)
$env:QT_ROOT = "C:\Qt\6.7.0\msvc2022_64"

# Windows (CMD)
set QT_ROOT=C:\Qt\6.7.0\msvc2022_64

# Linux/macOS
export QT_ROOT=~/Qt/6.7.0/gcc_64
```

**Option B: In Solution.json**
```json
"qt6": {
    "path": "externals/qt6",
    "options": {
        "hint": "C:/Qt/6.7.0/msvc2022_64"
    }
}
```

### 3. Bauen

```bash
cmake --preset msvc-debug
cmake --build build/msvc-debug
```

---

## Installationsmethoden

### Methode 1: Qt Online Installer (Empfohlen)

**Download:** https://www.qt.io/download-qt-installer

**Typische Pfade nach Installation:**

| Plattform | Pfad |
|-----------|------|
| Windows | `C:\Qt\6.7.0\msvc2022_64` |
| macOS | `~/Qt/6.7.0/macos` |
| Linux | `~/Qt/6.7.0/gcc_64` |

**Empfohlene Komponenten:**
- Qt 6.x.x → MSVC 2022 64-bit (Windows)
- Qt 6.x.x → Desktop gcc 64-bit (Linux)
- Qt 6.x.x → macOS (macOS)
- Optional: Qt Creator, Qt Design Studio

---

### Methode 2: System-Pakete

**Ubuntu/Debian:**
```bash
sudo apt install qt6-base-dev qt6-tools-dev libgl1-mesa-dev
```

**Arch Linux:**
```bash
sudo pacman -S qt6-base qt6-tools
```

**macOS (Homebrew):**
```bash
brew install qt@6
```

**Pfade bei System-Installation:**

| Distro | Pfad |
|--------|------|
| Ubuntu/Debian | `/usr/lib/x86_64-linux-gnu/qt6` |
| Arch | `/usr/lib/qt6` |
| macOS Homebrew | `/opt/homebrew/opt/qt@6` |

---

### Methode 3: Manuell entpackt (Zip/tar.xz)

Für Offline-Umgebungen oder wenn der Installer nicht verfügbar ist.

**1. Download**

Von https://download.qt.io/official_releases/qt/:
- Windows: `qt-everywhere-src-6.7.0.zip`
- Linux/macOS: `qt-everywhere-src-6.7.0.tar.xz`

Oder vorkompilierte Binaries (falls verfügbar).

**2. Entpacken**

```bash
# Windows (PowerShell)
Expand-Archive qt-everywhere-src-6.7.0.zip -DestinationPath D:\Libs\Qt

# Linux/macOS
tar -xf qt-everywhere-src-6.7.0.tar.xz -C ~/Libs/Qt
```

**3. Pfad konfigurieren**

```bash
# Windows
set QT_ROOT=D:\Libs\Qt\6.7.0\msvc2022_64

# Linux
export QT_ROOT=~/Libs/Qt/6.7.0/gcc_64
```

---

### Methode 4: vcpkg

```bash
# Qt6 Base installieren
vcpkg install qt6-base:x64-windows

# Weitere Module
vcpkg install qt6-widgets:x64-windows qt6-gui:x64-windows
```

**Integration:**
```json
"qt6": {
    "path": "externals/qt6",
    "options": {
        "hint": "${VCPKG_ROOT}/installed/x64-windows"
    }
}
```

---

## Konfigurationsoptionen

### Komponenten auswählen

```json
"qt6": {
    "path": "externals/qt6",
    "options": {
        "components": ["Core", "Widgets", "Gui", "OpenGL", "Network"]
    }
}
```

**Verfügbare Komponenten:**

| Komponente | Beschreibung |
|------------|--------------|
| `Core` | Grundfunktionen (immer benötigt) |
| `Gui` | GUI-Grundlagen |
| `Widgets` | Desktop Widgets |
| `OpenGL` | OpenGL Integration |
| `Network` | Netzwerk |
| `Sql` | Datenbank |
| `Xml` | XML Parsing |
| `Concurrent` | Threading |
| `Quick` | QML |
| `Qml` | QML Engine |
| `WebEngine` | Chromium-basiert |
| `Multimedia` | Audio/Video |
| `3D` | 3D Rendering |

### Pfad-Hint

```json
"qt6": {
    "path": "externals/qt6",
    "options": {
        "hint": "D:/Libs/Qt/6.7.0/msvc2022_64"
    }
}
```

**Mit Umgebungsvariable:**
```json
"hint": "${QT_ROOT}"
```

### Backup-Pfad

Für Fälle wo die primäre Installation nicht verfügbar ist (USB-Stick, Netzlaufwerk):

```json
"qt6": {
    "path": "externals/qt6",
    "options": {
        "hint": "${QT_ROOT}",
        "backup": "E:/Backup/Qt/6.7.0/msvc2022_64"
    }
}
```

**Verhalten:**
- Backup wird nur verwendet wenn primäre Pfade nicht gefunden
- Es wird eine **WARNING** ausgegeben (nicht FATAL_ERROR)
- Die Warning enthält Hinweise zur korrekten Installation

**Typische Backup-Szenarien:**
- USB-Stick mit portabler Qt-Installation
- Netzlaufwerk im Firmen-Netz
- Geteiltes Laufwerk im Team

**Beispiel-Warning:**
```
CMake Warning at externals/qt6/Include.cmake:
  [qt6] Primary Qt6 installation not found!
    Using BACKUP location: E:/Backup/Qt/6.7.0/msvc2022_64
    
    This may be slower (USB/network drive) and is not recommended for production.
    
    To fix, set one of:
      - Environment variable QT_ROOT
      - Environment variable QT6_DIR
      - Install Qt6 to a standard location
```

---

## Pfad-Auflösung

Die Qt6-Integration sucht in folgender Reihenfolge:

1. **`QT_ROOT`** Umgebungsvariable
2. **`QT6_DIR`** Umgebungsvariable
3. **`CMAKE_PREFIX_PATH`**
4. **`hint`** aus Solution.json
5. **Standard-Pfade** (automatische Erkennung)
6. **`backup`** aus Solution.json ⚠️ (mit WARNING)

### Standard-Pfade

**Windows:**
```
C:/Qt/6.8.0/msvc2022_64
C:/Qt/6.7.0/msvc2022_64
D:/Qt/6.7.0/msvc2022_64
```

**Linux:**
```
~/Qt/6.8.0/gcc_64
/opt/Qt/6.7.0/gcc_64
/usr/lib/qt6
```

**macOS:**
```
~/Qt/6.8.0/macos
/opt/homebrew/opt/qt@6
/usr/local/opt/qt@6
```

---

## Beispiel-Projekt

### Solution.json

```json
{
    "schemaVersion": "0.1",
    "solution": {
        "name": "QtDemo",
        "version": "1.0.0"
    },
    "settings": {
        "standards": {
            "cxx_standard": 17
        }
    },
    "externals": {
        "qt6": {
            "path": "externals/qt6",
            "options": {
                "components": ["Core", "Widgets", "Gui"]
            }
        }
    },
    "executables": [
        {
            "name": "QtApp",
            "path": "projects/exec/QtApp/src",
            "type": "GUI",
            "externals": ["qt6"]
        }
    ]
}
```

### main.cpp

```cpp
#include <QApplication>
#include <QMainWindow>
#include <QPushButton>
#include <QVBoxLayout>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    
    QMainWindow window;
    window.setWindowTitle("Qt6 Demo");
    window.resize(400, 300);
    
    QWidget *central = new QWidget(&window);
    QVBoxLayout *layout = new QVBoxLayout(central);
    
    QPushButton *button = new QPushButton("Click Me!", central);
    QObject::connect(button, &QPushButton::clicked, []() {
        qDebug() << "Button clicked!";
    });
    
    layout->addWidget(button);
    window.setCentralWidget(central);
    
    window.show();
    return app.exec();
}
```

### Mit UI-Datei

**mainwindow.ui** (Qt Designer):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<ui version="4.0">
 <class>MainWindow</class>
 <widget class="QMainWindow" name="MainWindow">
  <widget class="QWidget" name="centralwidget">
   <widget class="QPushButton" name="pushButton">
    <property name="text">
     <string>Hello Qt6!</string>
    </property>
   </widget>
  </widget>
 </widget>
</ui>
```

**mainwindow.h:**
```cpp
#pragma once
#include <QMainWindow>
#include "ui_mainwindow.h"

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);

private:
    Ui::MainWindow ui;
};
```

**mainwindow.cpp:**
```cpp
#include "mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    ui.setupUi(this);
    
    connect(ui.pushButton, &QPushButton::clicked, this, []() {
        qDebug() << "Button clicked!";
    });
}
```

---

## Automatische Features

Die Qt6-Integration aktiviert automatisch:

| Feature | Beschreibung |
|---------|--------------|
| **AUTOMOC** | Automatische MOC-Generierung für Q_OBJECT |
| **AUTOUIC** | Automatische UI-Datei Kompilierung |
| **AUTORCC** | Automatische Resource-Kompilierung |

---

## Targets

### Registrierte Targets

| Target | Beschreibung |
|--------|--------------|
| `qt6::all` | Convenience Target (alle Komponenten) |
| `Qt6::Core` | Core Modul |
| `Qt6::Gui` | GUI Modul |
| `Qt6::Widgets` | Widgets Modul |
| ... | Weitere je nach Komponenten |

### Verwendung

```cmake
# Automatisch via Build-System (empfohlen)
# externals: ["qt6"] in Solution.json

# Oder manuell in CMakeLists.txt:
target_link_libraries(MyApp PRIVATE Qt6::Widgets Qt6::Core)
```

---

## Troubleshooting

### Qt6 nicht gefunden

```
[qt6] Qt6 not found!
```

**Lösung:**
1. QT_ROOT Umgebungsvariable setzen
2. Oder `hint` in Solution.json angeben
3. Prüfen ob Pfad existiert und `lib/cmake/Qt6` enthält

### MOC Fehler

```
undefined reference to 'vtable for MyClass'
```

**Lösung:**
1. `Q_OBJECT` Makro in Header prüfen
2. Header muss in Source-Liste sein (für AUTOMOC)
3. Rebuild (CMake Cache löschen)

### DLL nicht gefunden (Windows)

```
The application was unable to start correctly (0xc000007b)
```

**Lösung:**
1. Qt bin-Verzeichnis zu PATH hinzufügen:
   ```
   set PATH=%QT_ROOT%\bin;%PATH%
   ```
2. Oder: windeployqt verwenden:
   ```
   %QT_ROOT%\bin\windeployqt.exe MyApp.exe
   ```

### Linker-Fehler bei Release/Debug Mismatch

**Lösung:**
Qt Debug- und Release-Bibliotheken nicht mischen. Passenden Build-Typ verwenden.

---

## CMakeUserPresets.json Beispiel

Für dauerhafte Qt-Konfiguration:

```json
{
    "version": 6,
    "configurePresets": [
        {
            "name": "qt-paths",
            "hidden": true,
            "environment": {
                "QT_ROOT": "C:/Qt/6.7.0/msvc2022_64"
            }
        },
        {
            "name": "msvc-debug-qt",
            "inherits": ["msvc-debug", "qt-paths"]
        },
        {
            "name": "msvc-release-qt",
            "inherits": ["msvc-release", "qt-paths"]
        }
    ]
}
```

---

## Vergleich: Qt-Konfigurationsmethoden

| Methode | Vorteile | Nachteile |
|---------|----------|-----------|
| **QT_ROOT Env** | Flexibel, CI-freundlich | Muss gesetzt werden |
| **hint in JSON** | Projektspezifisch | Hardcoded Pfad |
| **CMakeUserPresets** | Benutzerspezifisch | Zusätzliche Datei |
| **System-Pakete** | Automatisch gefunden | Weniger Kontrolle |
| **CMAKE_PREFIX_PATH** | Standard CMake | Global |

**Empfehlung:**
- **Entwicklung:** `QT_ROOT` Umgebungsvariable
- **CI/CD:** `QT_ROOT` in Pipeline-Config
- **Team:** `CMakeUserPresets.json` (nicht in Git!)

---

## Siehe auch

- [Adding_Externals_UserGuide](Adding_Externals_UserGuide_v0_1_0.md)
- [Solution_Schema](../References/Solution_Schema_v0_1_2.md)
- [Qt6 Documentation](https://doc.qt.io/qt-6/)

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-10** | **Initial: Flexible Qt6 Integration** |
