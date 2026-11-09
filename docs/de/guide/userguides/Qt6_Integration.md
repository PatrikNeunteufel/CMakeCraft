# Qt6 Integration – Benutzerhandbuch

> **Version:** 1.0.1  
> **Datum:** 2026-11-09  
> **Typ:** Guide  
> **Status:** Stabil  
> **Zielgruppe:** C++ Entwickler  
> **Modul:** cmake/externals/system/packages/Qt6.cmake v1.1.0 (Handler: cmake/externals/system/Handler.cmake)  
> **Sprache:** Deutsch  
> **English:** [Qt6_Integration_UserGuide.md](../../../en/guide/userguides/Qt6_Integration.md)

---

## Inhaltsverzeichnis

1. [Überblick](#1-überblick)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Schnellstart](#3-schnellstart)
4. [Installation von Qt6](#4-installation-von-qt6)
5. [Konfiguration](#5-konfiguration)
6. [Umgebungsvariablen](#6-umgebungsvariablen)
7. [Beispielprojekt](#7-beispielprojekt)
8. [Plattform-spezifische Hinweise](#8-plattform-spezifische-hinweise)
9. [Verfügbare Komponenten](#9-verfügbare-komponenten)
10. [Stolpersteine und Lösungen](#10-stolpersteine-und-lösungen)
11. [Troubleshooting](#11-troubleshooting)
12. [Siehe auch](#12-siehe-auch)

---

## 1. Überblick

Die Qt6-Integration ermöglicht die Verwendung von Qt6 in CMake Architecture Projekten.

### Features

- Flexible Pfad-Erkennung (Umgebungsvariablen, Hints, Standard-Pfade)
- Backup-Pfade (USB-Stick, Netzlaufwerk)
- AUTOMOC, AUTOUIC und AUTORCC für jedes Ziel, das Qt6 nutzt
- Ausdrücklicher Einstiegspunkt für Windows-GUI-Programme (MSVC und Clang)
- Automatisches DLL-Deployment (Windows, windeployqt)
- RPATH-Konfiguration (Linux/macOS)
- Komponentenauswahl

**Wichtig:** Qt6 ist ein **System External** – die Installation erfolgt außerhalb des Projekts.
In der Solution.json steht es mit `"system": true` und `"package": "Qt6"`; den Rest erledigen der
Handler `cmake/externals/system/Handler.cmake` (`find_package`) und der Paket-Hook
`cmake/externals/system/packages/Qt6.cmake`. Ein Ordner `externals/qt6/` im Projekt ist nicht nötig.

### Unterstützte Plattformen

| Plattform | Compiler | Deployment |
|-----------|----------|------------|
| Windows | MSVC 2022, Clang | windeployqt (automatisch, wenn gefunden) |
| Linux | GCC, Clang | RPATH (automatisch) |
| macOS | Apple Clang | macdeployqt (automatisch für Bundles, wenn gefunden) |

---

## 2. Voraussetzungen

### Checkliste

- [ ] **Qt6 installiert** (Version 6.5 oder höher empfohlen)
- [ ] **CMake 3.26+** (Mindestversion von CMakeCraft)
- [ ] **Compiler:** MSVC 2022, GCC 11+, oder Clang 14+
- [ ] **CMake Architecture** eingerichtet ([Neues_Projekt_Guide](Neues_Projekt_Guide.md))

### Empfohlene Versionen

| Komponente | Minimum | Empfohlen |
|------------|---------|-----------|
| Qt6 | 6.2 | 6.7+ |
| CMake | 3.26 | 3.28+ |
| CMakeCraft | – | v0.14.1+ (Einstiegspunkt für Windows-GUI-Programme) |

---

## 3. Schnellstart

### 3.1 Minimale Solution.json

```json
{
    "externals": {
        "qt6": {
            "system": true,
            "package": "Qt6",
            "components": ["Core", "Gui", "Widgets"],
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

`package` ist Pflicht (fehlt es, bricht das Konfigurieren mit E502 ab). `components` sollte jedes
genutzte Qt-Modul nennen: Gelinkt wird je Komponente `Qt6::<Komponente>`.

### 3.2 Build

```bash
# Konfigurieren
cmake --preset windows-ninja-debug-msvc

# Bauen
cmake --build out/build/windows-ninja-debug-msvc

# Ausführen
./out/build/windows-ninja-debug-msvc/exec/MyQtApp/bin/Debug/MyQtApp.exe
```

---

## 4. Installation von Qt6

### 4.1 Qt Online Installer (Empfohlen)

**Download:** https://www.qt.io/download-qt-installer

**Installationsschritte:**

1. Qt Maintenance Tool herunterladen und starten
2. Qt Account erstellen (kostenlos für Open Source)
3. Installation auswählen:
   - Qt → Qt 6.x.x → Desktop
   - Windows: MSVC 2022 64-bit
   - Linux: GCC 64-bit
   - macOS: macOS
4. Optional: Additional Libraries (OpenGL, Network, etc.)
5. Developer and Designer Tools → CMake, Ninja (optional)

**Typische Installationspfade:**

| Plattform | Pfad |
|-----------|------|
| Windows | `C:\Qt\6.10.1\msvc2022_64` |
| Linux | `~/Qt/6.10.1/gcc_64` |
| macOS | `~/Qt/6.10.1/macos` |

### 4.2 System-Pakete (Linux)

**Ubuntu/Debian:**
```bash
# Basis-Entwicklung
sudo apt install qt6-base-dev qt6-tools-dev

# Zusätzliche Module
sudo apt install qt6-multimedia-dev     # Multimedia
sudo apt install qt6-webengine-dev      # WebEngine
sudo apt install qt6-declarative-dev    # QML/Quick
```

**Arch Linux:**
```bash
sudo pacman -S qt6-base qt6-tools
sudo pacman -S qt6-multimedia qt6-webengine  # Optional
```

**Fedora:**
```bash
sudo dnf install qt6-qtbase-devel qt6-qttools-devel
```

**openSUSE:**
```bash
sudo zypper install qt6-base-devel qt6-tools-devel
```

### 4.3 Homebrew (macOS)

```bash
# Installation
brew install qt@6

# Pfad ermitteln
brew --prefix qt@6
# Ergebnis: /opt/homebrew/opt/qt@6 (Apple Silicon)
#           /usr/local/opt/qt@6 (Intel)
```

**Umgebungsvariable setzen:**
```bash
echo 'export QT_ROOT="$(brew --prefix qt@6)"' >> ~/.zshrc
source ~/.zshrc
```

### 4.4 Manuelle Installation

1. **Download:** https://download.qt.io/archive/qt/
2. Gewünschte Version wählen (z.B. 6.7.0)
3. Passende Architektur wählen:
   - Windows: `qt-everywhere-src-6.7.0.zip` oder Online Installer
   - Linux: `qt-everywhere-src-6.7.0.tar.xz`
4. Entpacken nach gewünschtem Pfad
5. Pfad als Umgebungsvariable setzen

---

## 5. Konfiguration

### 5.1 Pfad-Auflösung (Priorität)

Der Handler (`cmake/externals/system/PathResolver.cmake`) sucht Qt6 in folgender Reihenfolge:

```
1. Umgebungsvariablen Qt6ROOT, Qt6DIR, Qt6HOME, Qt6_ROOT, Qt6_DIR, Qt6_HOME,
   dann QtROOT, QtDIR, QtHOME, Qt_ROOT, Qt_DIR, Qt_HOME   ← Höchste Priorität
2. hints[] aus Solution.json (${VAR} = Umgebungsvariable)
3. Standard-Pfade aus packages/Qt6.cmake (z. B. C:/Qt/6.10.1/msvc2022_64)
4. backup aus Solution.json                                 ← Mit WARNING (W501)
5. Suche von find_package(Qt6) selbst (CMAKE_PREFIX_PATH usw.)
```

Der erste Pfad, der existiert, wird `CMAKE_PREFIX_PATH` vorangestellt; danach folgt
`find_package(Qt6 [version] COMPONENTS …)` — ohne `REQUIRED`: Findet CMake Qt nicht, benennt
CMakeCraft die Ursache selbst (E503, E504, E505; §10.5, §11).

**Gross-/Kleinschreibung:** Unter Windows unterscheiden Umgebungsvariablen sie nicht —
`QT_ROOT` wird dort als `Qt_ROOT` gefunden. Unter Linux und macOS schon: Dort greift `QT_ROOT`
nur über einen Hint `"${QT_ROOT}"` (darum steht er in allen Beispielen dieses Guides).

### 5.2 Felder

| Feld | Pflicht? | Bedeutung |
|------|----------|-----------|
| `system` | ✅ | `true` — macht das External zum System External |
| `package` | ✅ | Name für `find_package()`, hier `"Qt6"` (sonst E502) |
| `components` | empfohlen | Qt-Module; je Eintrag wird `Qt6::<Komponente>` gelinkt |
| `hints` | – | Liste zusätzlicher Suchpfade; `${VAR}` wird durch die Umgebungsvariable ersetzt |
| `backup` | – | Ausweichpfad, nur wenn alles andere fehlschlägt (W501) |
| `version` | – | Mindestversion, an `find_package()` übergeben, z. B. `"6.5"` |
| `required` | – | Vorgabe `true`; `false` macht Qt6 optional |

### 5.3 Mit Pfad-Hint

```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "components": ["Core", "Gui", "Widgets"],
    "hints": ["C:/Qt/6.10.1/msvc2022_64"]
}
```

### 5.4 Mit Umgebungsvariable im Hint

```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "components": ["Core", "Gui", "Widgets"],
    "hints": ["${QT_ROOT}"]
}
```

### 5.5 Mit Backup-Pfad

Für portable Installationen (USB-Stick, Netzlaufwerk):

```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "components": ["Core", "Gui", "Widgets"],
    "hints": ["${QT_ROOT}"],
    "backup": "E:/Backup/Qt/6.10.1/msvc2022_64"
}
```

**Verhalten:**
- Backup wird NUR verwendet wenn alle anderen Pfade fehlschlagen
- Es erscheint eine **WARNING** (kein Fehler)
- Build läuft weiter

**Warning-Ausgabe:**
```
[W501] [qt6] Using backup location: E:/Backup/Qt/6.10.1/msvc2022_64
```

### 5.6 Mit Komponenten-Auswahl

```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "components": ["Core", "Widgets", "Gui", "OpenGL", "Network"],
    "hints": ["${QT_ROOT}"]
}
```

**Ohne `components`** sucht der Handler nur `find_package(Qt6)` und linkt `Qt6::Qt6` bzw. `Qt6`,
falls es ein solches Ziel gibt — das Qt-Paket stellt keines bereit. Darum jedes genutzte Modul
in `components` aufführen.

### 5.7 Vollständiges Beispiel

```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "version": "6.5",
    "components": ["Core", "Widgets", "Gui", "OpenGL"],
    "hints": ["${QT_ROOT}"],
    "backup": "E:/Backup/Qt/6.10.1/msvc2022_64"
}
```

---

## 6. Umgebungsvariablen

### 6.1 QT_ROOT (Empfohlen)

**Windows (dauerhaft – Systemvariable):**
```cmd
setx QT_ROOT "C:\Qt\6.10.1\msvc2022_64"
```
→ Neues Terminal öffnen!

**Windows (temporär – aktuelle Session):**
```cmd
set QT_ROOT=C:\Qt\6.10.1\msvc2022_64
```

**Linux/macOS (.bashrc oder .zshrc):**
```bash
export QT_ROOT="$HOME/Qt/6.10.1/gcc_64"
```
→ `source ~/.bashrc` ausführen! Unter Linux/macOS wirkt `QT_ROOT` nur über den Hint `"${QT_ROOT}"` (§5.1).

### 6.2 Alternative: Qt6_ROOT

```bash
export Qt6_ROOT="/opt/Qt/6.10.1/gcc_64"
```

`Qt6_ROOT` findet der Handler auf jeder Plattform ohne Hint (§5.1).

### 6.3 Visual Studio und Umgebungsvariablen

**Problem:** Visual Studio erbt NICHT automatisch System-Umgebungsvariablen, die nach dem Start von VS gesetzt wurden.

**Symptom:** CMake findet Qt nicht, obwohl `echo %QT_ROOT%` den korrekten Pfad zeigt.

**Lösungen:**

#### Option A: Visual Studio neu starten (nach setx)

Nach `setx QT_ROOT "..."` muss Visual Studio **komplett** neu gestartet werden.

#### Option B: CMakeUserPresets.json (Empfohlen)

Erstelle `CMakeUserPresets.json` im Projekt-Root:

```json
{
    "version": 6,
    "configurePresets": [
        {
            "name": "qt-env",
            "hidden": true,
            "description": "Qt6 Environment",
            "environment": {
                "QT_ROOT": "C:/Qt/6.10.1/msvc2022_64"
            }
        },
        {
            "name": "windows-ninja-debug-clang-qt",
            "displayName": "Windows Debug (Clang + Qt)",
            "inherits": ["windows-ninja-debug-clang", "qt-env"]
        },
        {
            "name": "windows-ninja-release-clang-qt",
            "displayName": "Windows Release (Clang + Qt)",
            "inherits": ["windows-ninja-release-clang", "qt-env"]
        },
        {
            "name": "windows-ninja-debug-msvc-qt",
            "displayName": "Windows Debug (MSVC + Qt)",
            "inherits": ["windows-ninja-debug-msvc", "qt-env"]
        }
    ]
}
```

**Wichtig:** `CMakeUserPresets.json` in `.gitignore` aufnehmen (benutzerspezifisch)!
`QT_ROOT` gehört unter `environment`, nicht unter `cacheVariables`: Der Handler liest
Umgebungsvariablen, keine Cache-Variablen.

#### Option C: hints in Solution.json

```json
"hints": ["C:/Qt/6.10.1/msvc2022_64"]
```

---

## 7. Beispielprojekt

### 7.1 Projektstruktur

```
MyProject/
├── CMakeLists.txt
├── CMakeCraftBootstrap.cmake
├── cmakecraft.pin
├── CMakePresets.json
├── CMakeUserPresets.json          ← Benutzerspezifisch (nicht committen)
├── Solution.json
└── projects/
    └── demos/
        └── exec/
            └── QtMarkdownViewer/
                └── src/
                    ├── Source.cmake
                    └── main.cpp
```

Qt6 selbst braucht im Projekt keine Datei: Es liegt außerhalb, der Paket-Hook kommt mit CMakeCraft.

### 7.2 main.cpp

```cpp
#include <QApplication>
#include <QMainWindow>
#include <QLabel>
#include <QVBoxLayout>

class MainWindow : public QMainWindow {
    Q_OBJECT
public:
    explicit MainWindow(QWidget* parent = nullptr)
        : QMainWindow(parent)
    {
        auto* central = new QWidget(this);
        auto* layout = new QVBoxLayout(central);
        
        auto* label = new QLabel("Hello Qt6!", this);
        label->setAlignment(Qt::AlignCenter);
        layout->addWidget(label);
        
        setCentralWidget(central);
        setWindowTitle("Qt6 Demo");
        resize(400, 300);
    }
};

int main(int argc, char* argv[])
{
    QApplication app(argc, argv);
    MainWindow window;
    window.show();
    return app.exec();
}

// WICHTIG: MOC-Include am Ende der Datei!
#include "main.moc"
```

### 7.3 Solution.json

```json
{
    "schemaVersion": "1.0",
    "solution": {
        "name": "QtDemo",
        "version": "1.0.0"
    },
    "settings": {
        "standards": {
            "cxx_standard": 20
        }
    },
    "externals": {
        "qt6": {
            "system": true,
            "package": "Qt6",
            "components": ["Core", "Widgets", "Gui"],
            "hints": ["${QT_ROOT}"]
        }
    },
    "executables": [
        {
            "name": "QtMarkdownViewer",
            "displayName": "Markdown Viewer",
            "version": "1.0.0",
            "type": "GUI",
            "path": "projects/demos/exec/QtMarkdownViewer/src",
            "externals": ["qt6"]
        }
    ]
}
```

### 7.4 Build-Befehle

```bash
# Konfigurieren
cmake --preset windows-ninja-debug-clang-qt

# Bauen
cmake --build out/build/windows-ninja-debug-clang-qt

# Ausführen
./out/build/windows-ninja-debug-clang-qt/exec/QtMarkdownViewer/bin/Debug/QtMarkdownViewer.exe
```

---

## 8. Plattform-spezifische Hinweise

### 8.1 Windows

**DLL-Deployment:**
- `windeployqt` läuft nach jedem Bau des Ziels und kopiert die benötigten DLLs neben die .exe
  (Optionen `--no-translations --no-system-d3d-compiler --no-opengl-sw`)
- Wird `windeployqt` nicht gefunden (`<Qt>/bin`), entfällt der Schritt ohne Warnung
- Debug-DLLs enden auf `d` (z.B. `Qt6Cored.dll`)
- Release-DLLs ohne Suffix (z.B. `Qt6Core.dll`)

**Einstiegspunkt (seit v0.14.1):** GUI-Programme (`"type": "GUI"`) bekommen unter MSVC und Clang
(MSVC-ABI) den Linker-Schalter `/ENTRY:WinMainCRTStartup`. `Qt6EntryPoint.lib` definiert `WinMain`
und `wWinMain`; ohne diese Wahl warnt lld-link bei jedem Linken. MinGW bleibt unberührt.
Einzelheiten: [Qt6_cmake.md §2.4](../module/externals/system/packages/Qt6_cmake.md#24-_qt6_configure_entry_point).

**Qt-Verzeichnis zum PATH hinzufügen (Alternative zu windeployqt):**
```cmd
set PATH=%QT_ROOT%\bin;%PATH%
```

**Compiler-Kompatibilität:**
- Qt für MSVC 2022 → MSVC oder Clang (mit MSVC-Target)
- Qt für MinGW → Nur MinGW

### 8.2 Linux

**RPATH:**
- Automatisch konfiguriert in `packages/Qt6.cmake`
- `BUILD_RPATH` zeigt auf `<Qt>/lib`, `INSTALL_RPATH` auf `$ORIGIN/../lib` und `<Qt>/lib`
- Kein `LD_LIBRARY_PATH` nötig

**System-Qt vs Installer-Qt:**
```bash
# System-Qt
qmake6 --version  # /usr/bin/qmake6

# Installer-Qt
~/Qt/6.10.1/gcc_64/bin/qmake --version
```

**AppImage erstellen (optional):**
```bash
# linuxdeployqt installieren
# https://github.com/probonopd/linuxdeployqt
linuxdeployqt MyApp -appimage
```

### 8.3 macOS

**Bundle vs Executable:**
- GUI-Apps sollten als Bundle gebaut werden
- `type: "GUI"` in Solution.json setzt `MACOSX_BUNDLE`

**macdeployqt:**
- Läuft für Bundles automatisch nach dem Bau, wenn es gefunden wird (`<Qt>/bin`)
```bash
# Manuell ausführen
~/Qt/6.10.1/macos/bin/macdeployqt MyApp.app
```

**Code Signing (für Distribution):**
```bash
codesign --deep --force --sign "Developer ID" MyApp.app
```

---

## 9. Verfügbare Komponenten

### Basis-Module

| Komponente | Beschreibung | Typische Verwendung |
|------------|--------------|---------------------|
| **Core** | Basisklassen, Container, IO | Immer benötigt |
| **Gui** | GUI-Basis, Fonts, Images | Desktop-/Mobile-Apps |
| **Widgets** | Desktop-Widgets | Desktop-Anwendungen |

### Erweiterte Module

| Komponente | Beschreibung |
|------------|--------------|
| **OpenGL** | OpenGL-Integration |
| **Network** | HTTP, TCP, UDP |
| **Sql** | Datenbank-Abstraktion |
| **Xml** | XML-Parser |
| **Concurrent** | Threading-Utilities |
| **PrintSupport** | Druckfunktionen |

### QML/Quick

| Komponente | Beschreibung |
|------------|--------------|
| **Qml** | QML-Engine |
| **Quick** | Qt Quick (QML-UI) |
| **QuickControls2** | Moderne UI-Komponenten |

### Multimedia

| Komponente | Beschreibung |
|------------|--------------|
| **Multimedia** | Audio/Video |
| **MultimediaWidgets** | Media-Player-Widgets |

### Spezial

| Komponente | Beschreibung |
|------------|--------------|
| **WebEngine** | Chromium-Browser |
| **WebChannel** | Web-Integration |
| **Charts** | Diagramme |
| **3D** | 3D-Rendering |
| **Svg** | SVG-Support |
| **Pdf** | PDF-Rendering |

---

## 10. Stolpersteine und Lösungen

### 10.1 AUTOMOC funktioniert nicht

**Problem:**
```
fatal error: 'main.moc' file not found
```

**Ursache:** `CMAKE_AUTOMOC ON` global zu setzen wirkt nur auf Targets, die **danach** erstellt werden — die Targets des Build-Systems sind dann schon angelegt.

**Lösung:** Nichts selbst setzen. Der Paket-Hook schaltet `AUTOMOC`, `AUTOUIC` und `AUTORCC` auf
jedem Ziel ein, das das External `qt6` nutzt (`_Qt6_configure_target()`). Tritt der Fehler auf:
Steht `"qt6"` in den `externals` des Ziels, und hat das External `"package": "Qt6"`? Nur dann wird
`packages/Qt6.cmake` geladen.

### 10.2 Qt-Header werden nicht gefunden

**Problem:**
```
fatal error: 'QApplication' file not found
```

**Ursache:** Die Komponente fehlt in `components`. Gelinkt wird nur `Qt6::<Komponente>` für jede
dort genannte Komponente; `QApplication` kommt aus `Widgets`.

**Lösung:** Komponente ergänzen:
```json
"components": ["Core", "Gui", "Widgets"]
```

### 10.3 DLLs fehlen zur Laufzeit (Windows)

**Problem:**
```
Die Ausführung des Codes kann nicht fortgesetzt werden, da Qt6Cored.dll nicht gefunden wurde.
```

**Ursache:** Qt-DLLs müssen im selben Verzeichnis wie die .exe liegen oder im PATH sein.

**Lösung:** `windeployqt` kopiert die DLLs nach jedem Bau des Ziels (§8.1). Fehlen sie trotzdem,
wurde `windeployqt` nicht gefunden: Liegt es unter `<Qt>/bin` der gefundenen Installation?
Notbehelf: Qt-`bin` in den PATH (§8.1).

### 10.4 Debug/Release DLLs werden verwechselt (Multi-Config)

**Problem:** Bei Visual Studio (Multi-Config-Generator) stammen die DLLs aus der falschen Konfiguration.

**Hintergrund:** `CMAKE_BUILD_TYPE` ist bei Multi-Config-Generatoren zur Configure-Zeit **leer**;
die Konfiguration wird erst beim Build gewählt.

**Lösung:** Im Build-System bereits gelöst: `windeployqt` läuft als Post-Build-Schritt auf
`$<TARGET_FILE:…>`, also auf der gerade gebauten Datei, und wählt die passenden DLLs selbst.
Treten trotzdem gemischte DLLs auf, das Ausgabeverzeichnis der Konfiguration leeren und neu bauen.

### 10.5 Qt wird trotz Installation nicht gefunden

**Problem:**
```
CMake Warning at …/externals/system/Handler.cmake:… (find_package):
  … Could not find a package configuration file provided by "Qt6" …
CMake Error at …/core/Errors.cmake:… (message):
  [E503] System external 'qt6': find_package(Qt6) failed.
  …
  Possible solutions:
    1. Set Qt6_ROOT environment variable
    …
```

CMakes eigene Diagnose erscheint als Warnung, den Abbruch meldet E503
(`cmake/externals/system/Handler.cmake:128`). Findet CMake Qt, aber nicht jedes Modul aus
`components`, kommt stattdessen E504; ist `version` gesetzt und passt keine gefundene Qt-Version,
E505 (§11).

**Ursache:** Keine der Quellen aus §5.1 führt zu einer Qt-Installation — Umgebungsvariable nicht
gesetzt (oder unter Linux/macOS in anderer Schreibweise), kein Hint, oder Visual Studio erbt die
Variable nicht.

**Diagnose:**
```bash
# Windows
echo %QT_ROOT%
dir "%QT_ROOT%\lib\cmake\Qt6"

# Linux/macOS
echo $QT_ROOT
ls "$QT_ROOT/lib/cmake/Qt6"

# Suche von find_package mitschreiben
cmake --preset ... --debug-find-pkg=Qt6
```

**Mögliche Ursachen und Lösungen:**

| Ursache | Lösung |
|---------|--------|
| Umgebungsvariable nicht gesetzt | `setx QT_ROOT "..."` |
| Linux/macOS: `QT_ROOT` ohne Hint | Hint `"${QT_ROOT}"` ergänzen oder `Qt6_ROOT` setzen (§5.1) |
| VS erbt Variable nicht | CMakeUserPresets.json verwenden |
| Falscher Pfad/Version | Pfad überprüfen |
| Beschädigte Installation | Qt neu installieren |
| Falsches Compiler-Kit | MSVC-Qt für MSVC, GCC-Qt für GCC |

---

## 11. Troubleshooting

### Checkliste bei Problemen

1. ☐ Qt installiert?
2. ☐ Richtiger Pfad? (`dir %QT_ROOT%\lib\cmake\Qt6`)
3. ☐ Umgebungsvariable gesetzt?
4. ☐ VS neu gestartet nach `setx`?
5. ☐ External mit `"system": true` und `"package": "Qt6"` deklariert?
6. ☐ CMake-Cache gelöscht? (`cmake --fresh`)
7. ☐ Richtige Komponenten in `components`?

### Häufige Fehler

| Fehler | Lösung |
|--------|--------|
| `[E503] System external 'qt6': find_package(Qt6) failed.` (davor die Warnung `Could not find a package configuration file provided by "Qt6"`) | Umgebungsvariable/`hints` prüfen (§5.1, §10.5) |
| `[E504] System external 'qt6': Qt6 was found (…), but not with all requested components: …` | Welches Modul fehlt, sagt die Zeile `Reason given by the package`; Modul nachinstallieren (Qt Maintenance Tool) oder aus `components` streichen |
| `[E505] System external 'qt6': no Qt6 with a version compatible to the requested '…' was found.` | Unter `Considered:` stehen die gefundenen Versionen; passende Qt-Version installieren und über `QT_ROOT`/`hints` angeben, oder `version` anpassen |
| `[E502] System external 'qt6': 'package' field is required.` | `"package": "Qt6"` ergänzen |
| `QApplication file not found` | `Widgets` in `components` aufnehmen |
| `main.moc file not found` | `qt6` in den `externals` des Ziels, `package` gesetzt (§10.1) |
| `Qt6Cored.dll not found` | `windeployqt` unter `<Qt>/bin`? Neu bauen |
| `undefined reference to QApplication` | "Widgets" in components hinzufügen |

### Debug-Ausgabe aktivieren

Beim Konfigurieren meldet der Handler den Fund:
```
[Externals] [qt6] Found Qt6 6.10.1
```

Suche von `find_package` im Einzelnen:
```bash
cmake --preset ... --debug-find-pkg=Qt6
```

---

## 12. Siehe auch

- [Solution_Schema.md](../references/Solution_Schema.md) – JSON-Schema Referenz
- [Externals.md](../references/Externals.md) – Externals Referenz
- [Qt6_cmake.md](../module/externals/system/packages/Qt6_cmake.md) – Modul-Doku des Paket-Hooks
- [externals/Qt6.md](externals/Qt6.md) – Qt6 als External (Kurzreferenz)
- [Adding_Externals Uuserguide](Adding_Externals.md) – Neue Externals hinzufügen
- [CMakeUserPresets_Reference.md](../references/CMakeUserPresets.md) – User Presets Konfiguration

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| 1.0.1 | 2026-11-09 | An den Code angeglichen: Qt6 als System External (`"system": true`, `"package": "Qt6"`, `components`, `hints`, `backup`) statt lokalem `externals/qt6/Include.cmake`; Pfad-Auflösung nach `PathResolver.cmake`, Felder-Tabelle, AUTOMOC/Einstiegspunkt/windeployqt aus `packages/Qt6.cmake`, Meldungen W501/E502, Stolpersteine und Troubleshooting ohne Include.cmake-Versionen, Presets und Ausgabepfade; CMakeCraft v0.14.1: `find_package` ohne `REQUIRED` (§5.1), Fehlerfall §10.5 mit E503, E503/E504/E505 in §11 |
| 1.0.0 | 2025-12-26 | Release 1 (aus newCMake übernommen, `2e00db7`) |
| **0.5.0** | **2025-12-14** | **Blueprint v0.5.0 Konformität: Voraussetzungen, Stolpersteine/Troubleshooting getrennt, Siehe auch** |
| 0.2.0 | 2025-12-11 | Umfassende Überarbeitung: Stolpersteine, detaillierte Installation, VS-Workarounds, Plattform-Support |
| 0.1.0 | 2025-12-10 | Initial |
