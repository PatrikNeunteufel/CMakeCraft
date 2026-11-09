# Qt6 Integration – User Guide

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Guide  
> **Status:** Stable  
> **Target Audience:** C++ developers  
> **Module:** cmake/externals/system/packages/Qt6.cmake v1.1.0 (handler: cmake/externals/system/Handler.cmake)  
> **Language:** English  
> **German:** [Qt6_Integration_UserGuide.md](../../../de/guide/userguides/Qt6_Integration.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Quick Start](#3-quick-start)
4. [Installing Qt6](#4-installing-qt6)
5. [Configuration](#5-configuration)
6. [Environment Variables](#6-environment-variables)
7. [Example Project](#7-example-project)
8. [Platform-Specific Notes](#8-platform-specific-notes)
9. [Available Components](#9-available-components)
10. [Pitfalls and Solutions](#10-pitfalls-and-solutions)
11. [Troubleshooting](#11-troubleshooting)
12. [See Also](#12-see-also)

---

## 1. Overview

The Qt6 integration enables the use of Qt6 in CMake Architecture projects.

### Features

- Flexible path detection (environment variables, hints, standard paths)
- Backup paths (USB stick, network drive)
- AUTOMOC, AUTOUIC and AUTORCC for every target that uses Qt6
- Explicit entry point for Windows GUI programs (MSVC and Clang)
- Automatic DLL deployment (Windows, windeployqt)
- RPATH configuration (Linux/macOS)
- Component selection

**Important:** Qt6 is a **system external** – it is installed outside the project.
In Solution.json it is declared with `"system": true` and `"package": "Qt6"`; the rest is done by
the handler `cmake/externals/system/Handler.cmake` (`find_package`) and the package hook
`cmake/externals/system/packages/Qt6.cmake`. No `externals/qt6/` folder is needed in the project.

### Supported Platforms

| Platform | Compiler | Deployment |
|----------|----------|------------|
| Windows | MSVC 2022, Clang | windeployqt (automatic, if found) |
| Linux | GCC, Clang | RPATH (automatic) |
| macOS | Apple Clang | macdeployqt (automatic for bundles, if found) |

---

## 2. Prerequisites

### Checklist

- [ ] **Qt6 installed** (version 6.5 or higher recommended)
- [ ] **CMake 3.26+** (minimum version of CMakeCraft)
- [ ] **Compiler:** MSVC 2022, GCC 11+, or Clang 14+
- [ ] **CMake Architecture** set up ([New Project Guide](Neues_Projekt_Guide.md))

### Recommended Versions

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| Qt6 | 6.2 | 6.7+ |
| CMake | 3.26 | 3.28+ |
| CMakeCraft | – | v0.14.1+ (entry point for Windows GUI programs) |

---

## 3. Quick Start

### 3.1 Minimal Solution.json

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

`package` is required (if it is missing, configuring aborts with E502). `components` should list
every Qt module in use: `Qt6::<Component>` is linked for each component.

### 3.2 Build

```bash
# Configure
cmake --preset windows-ninja-debug-msvc

# Build
cmake --build out/build/windows-ninja-debug-msvc

# Run
./out/build/windows-ninja-debug-msvc/exec/MyQtApp/bin/Debug/MyQtApp.exe
```

---

## 4. Installing Qt6

### 4.1 Qt Online Installer (Recommended)

**Download:** https://www.qt.io/download-qt-installer

**Installation steps:**

1. Download and start the Qt Maintenance Tool
2. Create a Qt account (free for open source)
3. Select the installation:
   - Qt → Qt 6.x.x → Desktop
   - Windows: MSVC 2022 64-bit
   - Linux: GCC 64-bit
   - macOS: macOS
4. Optional: Additional Libraries (OpenGL, Network, etc.)
5. Developer and Designer Tools → CMake, Ninja (optional)

**Typical installation paths:**

| Platform | Path |
|----------|------|
| Windows | `C:\Qt\6.10.1\msvc2022_64` |
| Linux | `~/Qt/6.10.1/gcc_64` |
| macOS | `~/Qt/6.10.1/macos` |

### 4.2 System Packages (Linux)

**Ubuntu/Debian:**
```bash
# Basic development
sudo apt install qt6-base-dev qt6-tools-dev

# Additional modules
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

# Determine the path
brew --prefix qt@6
# Result: /opt/homebrew/opt/qt@6 (Apple Silicon)
#         /usr/local/opt/qt@6 (Intel)
```

**Set the environment variable:**
```bash
echo 'export QT_ROOT="$(brew --prefix qt@6)"' >> ~/.zshrc
source ~/.zshrc
```

### 4.4 Manual Installation

1. **Download:** https://download.qt.io/archive/qt/
2. Select the desired version (e.g. 6.7.0)
3. Select the matching architecture:
   - Windows: `qt-everywhere-src-6.7.0.zip` or the online installer
   - Linux: `qt-everywhere-src-6.7.0.tar.xz`
4. Unpack to the desired path
5. Set the path as an environment variable

---

## 5. Configuration

### 5.1 Path Resolution (Priority)

The handler (`cmake/externals/system/PathResolver.cmake`) searches for Qt6 in the following order:

```
1. Environment variables Qt6ROOT, Qt6DIR, Qt6HOME, Qt6_ROOT, Qt6_DIR, Qt6_HOME,
   then QtROOT, QtDIR, QtHOME, Qt_ROOT, Qt_DIR, Qt_HOME   ← Highest priority
2. hints[] from Solution.json (${VAR} = environment variable)
3. Standard paths from packages/Qt6.cmake (e.g. C:/Qt/6.10.1/msvc2022_64)
4. backup from Solution.json                                ← With WARNING (W501)
5. find_package(Qt6)'s own search (CMAKE_PREFIX_PATH etc.)
```

The first path that exists is prepended to `CMAKE_PREFIX_PATH`; then
`find_package(Qt6 [version] COMPONENTS …)` follows — without `REQUIRED`: if CMake does not find
Qt, CMakeCraft names the cause itself (E503, E504, E505; §10.5, §11).

**Case sensitivity:** On Windows, environment variable names are case-insensitive — `QT_ROOT` is
found there as `Qt_ROOT`. On Linux and macOS they are not: there `QT_ROOT` only takes effect
through a hint `"${QT_ROOT}"` (which is why all examples in this guide include it).

### 5.2 Fields

| Field | Required? | Meaning |
|-------|-----------|---------|
| `system` | ✅ | `true` — makes the external a system external |
| `package` | ✅ | Name for `find_package()`, here `"Qt6"` (otherwise E502) |
| `components` | recommended | Qt modules; `Qt6::<Component>` is linked for each entry |
| `hints` | – | List of additional search paths; `${VAR}` is replaced by the environment variable |
| `backup` | – | Fallback path, only if everything else fails (W501) |
| `version` | – | Minimum version, passed to `find_package()`, e.g. `"6.5"` |
| `required` | – | Default `true`; `false` makes Qt6 optional |

### 5.3 With a Path Hint

```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "components": ["Core", "Gui", "Widgets"],
    "hints": ["C:/Qt/6.10.1/msvc2022_64"]
}
```

### 5.4 With an Environment Variable in the Hint

```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "components": ["Core", "Gui", "Widgets"],
    "hints": ["${QT_ROOT}"]
}
```

### 5.5 With a Backup Path

For portable installations (USB stick, network drive):

```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "components": ["Core", "Gui", "Widgets"],
    "hints": ["${QT_ROOT}"],
    "backup": "E:/Backup/Qt/6.10.1/msvc2022_64"
}
```

**Behavior:**
- The backup is ONLY used if all other paths fail
- A **WARNING** appears (not an error)
- The build continues

**Warning output:**
```
[W501] [qt6] Using backup location: E:/Backup/Qt/6.10.1/msvc2022_64
```

### 5.6 With Component Selection

```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "components": ["Core", "Widgets", "Gui", "OpenGL", "Network"],
    "hints": ["${QT_ROOT}"]
}
```

**Without `components`** the handler only calls `find_package(Qt6)` and links `Qt6::Qt6` or `Qt6`
if such a target exists — the Qt package provides none. So list every module in use in
`components`.

### 5.7 Complete Example

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

## 6. Environment Variables

### 6.1 QT_ROOT (Recommended)

**Windows (permanent – system variable):**
```cmd
setx QT_ROOT "C:\Qt\6.10.1\msvc2022_64"
```
→ Open a new terminal!

**Windows (temporary – current session):**
```cmd
set QT_ROOT=C:\Qt\6.10.1\msvc2022_64
```

**Linux/macOS (.bashrc or .zshrc):**
```bash
export QT_ROOT="$HOME/Qt/6.10.1/gcc_64"
```
→ Run `source ~/.bashrc`! On Linux/macOS, `QT_ROOT` only takes effect through the hint `"${QT_ROOT}"` (§5.1).

### 6.2 Alternative: Qt6_ROOT

```bash
export Qt6_ROOT="/opt/Qt/6.10.1/gcc_64"
```

The handler finds `Qt6_ROOT` on every platform without a hint (§5.1).

### 6.3 Visual Studio and Environment Variables

**Problem:** Visual Studio does NOT automatically inherit system environment variables that were set after VS was started.

**Symptom:** CMake does not find Qt, although `echo %QT_ROOT%` shows the correct path.

**Solutions:**

#### Option A: Restart Visual Studio (after setx)

After `setx QT_ROOT "..."`, Visual Studio must be restarted **completely**.

#### Option B: CMakeUserPresets.json (Recommended)

Create `CMakeUserPresets.json` in the project root:

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

**Important:** Add `CMakeUserPresets.json` to `.gitignore` (user-specific)!
`QT_ROOT` belongs under `environment`, not under `cacheVariables`: the handler reads environment
variables, not cache variables.

#### Option C: hints in Solution.json

```json
"hints": ["C:/Qt/6.10.1/msvc2022_64"]
```

---

## 7. Example Project

### 7.1 Project Structure

```
MyProject/
├── CMakeLists.txt
├── CMakeCraftBootstrap.cmake
├── cmakecraft.pin
├── CMakePresets.json
├── CMakeUserPresets.json          ← User-specific (do not commit)
├── Solution.json
└── projects/
    └── demos/
        └── exec/
            └── QtMarkdownViewer/
                └── src/
                    ├── Source.cmake
                    └── main.cpp
```

Qt6 itself needs no file in the project: it lives outside, and the package hook comes with CMakeCraft.

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

// IMPORTANT: MOC include at the end of the file!
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

### 7.4 Build Commands

```bash
# Configure
cmake --preset windows-ninja-debug-clang-qt

# Build
cmake --build out/build/windows-ninja-debug-clang-qt

# Run
./out/build/windows-ninja-debug-clang-qt/exec/QtMarkdownViewer/bin/Debug/QtMarkdownViewer.exe
```

---

## 8. Platform-Specific Notes

### 8.1 Windows

**DLL deployment:**
- `windeployqt` runs after every build of the target and copies the required DLLs next to the .exe
  (options `--no-translations --no-system-d3d-compiler --no-opengl-sw`)
- If `windeployqt` is not found (`<Qt>/bin`), the step is skipped without a warning
- Debug DLLs end with `d` (e.g. `Qt6Cored.dll`)
- Release DLLs have no suffix (e.g. `Qt6Core.dll`)

**Entry point (since v0.14.1):** GUI programs (`"type": "GUI"`) get the linker switch
`/ENTRY:WinMainCRTStartup` under MSVC and Clang (MSVC ABI). `Qt6EntryPoint.lib` defines `WinMain`
and `wWinMain`; without this choice lld-link warns on every link. MinGW is not affected.
Details: [Qt6_cmake.md §2.4](../module/externals/system/packages/Qt6_cmake.md#24-_qt6_configure_entry_point).

**Add the Qt directory to PATH (alternative to windeployqt):**
```cmd
set PATH=%QT_ROOT%\bin;%PATH%
```

**Compiler compatibility:**
- Qt for MSVC 2022 → MSVC or Clang (with MSVC target)
- Qt for MinGW → MinGW only

### 8.2 Linux

**RPATH:**
- Configured automatically in `packages/Qt6.cmake`
- `BUILD_RPATH` points to `<Qt>/lib`, `INSTALL_RPATH` to `$ORIGIN/../lib` and `<Qt>/lib`
- No `LD_LIBRARY_PATH` needed

**System Qt vs installer Qt:**
```bash
# System Qt
qmake6 --version  # /usr/bin/qmake6

# Installer Qt
~/Qt/6.10.1/gcc_64/bin/qmake --version
```

**Create an AppImage (optional):**
```bash
# Install linuxdeployqt
# https://github.com/probonopd/linuxdeployqt
linuxdeployqt MyApp -appimage
```

### 8.3 macOS

**Bundle vs executable:**
- GUI apps should be built as a bundle
- `type: "GUI"` in Solution.json sets `MACOSX_BUNDLE`

**macdeployqt:**
- Runs automatically after the build for bundles, if it is found (`<Qt>/bin`)
```bash
# Run manually
~/Qt/6.10.1/macos/bin/macdeployqt MyApp.app
```

**Code signing (for distribution):**
```bash
codesign --deep --force --sign "Developer ID" MyApp.app
```

---

## 9. Available Components

### Base Modules

| Component | Description | Typical usage |
|-----------|-------------|---------------|
| **Core** | Base classes, containers, IO | Always needed |
| **Gui** | GUI base, fonts, images | Desktop/mobile apps |
| **Widgets** | Desktop widgets | Desktop applications |

### Extended Modules

| Component | Description |
|-----------|-------------|
| **OpenGL** | OpenGL integration |
| **Network** | HTTP, TCP, UDP |
| **Sql** | Database abstraction |
| **Xml** | XML parser |
| **Concurrent** | Threading utilities |
| **PrintSupport** | Printing functions |

### QML/Quick

| Component | Description |
|-----------|-------------|
| **Qml** | QML engine |
| **Quick** | Qt Quick (QML UI) |
| **QuickControls2** | Modern UI components |

### Multimedia

| Component | Description |
|-----------|-------------|
| **Multimedia** | Audio/video |
| **MultimediaWidgets** | Media player widgets |

### Special

| Component | Description |
|-----------|-------------|
| **WebEngine** | Chromium browser |
| **WebChannel** | Web integration |
| **Charts** | Charts |
| **3D** | 3D rendering |
| **Svg** | SVG support |
| **Pdf** | PDF rendering |

---

## 10. Pitfalls and Solutions

### 10.1 AUTOMOC Does Not Work

**Problem:**
```
fatal error: 'main.moc' file not found
```

**Cause:** Setting `CMAKE_AUTOMOC ON` globally only affects targets created **afterwards** — by then the build system's targets already exist.

**Solution:** Do not set anything yourself. The package hook turns on `AUTOMOC`, `AUTOUIC` and
`AUTORCC` for every target that uses the external `qt6` (`_Qt6_configure_target()`). If the error
occurs: is `"qt6"` in the target's `externals`, and does the external have `"package": "Qt6"`? Only
then is `packages/Qt6.cmake` loaded.

### 10.2 Qt Headers Are Not Found

**Problem:**
```
fatal error: 'QApplication' file not found
```

**Cause:** The component is missing from `components`. Only `Qt6::<Component>` is linked for each
component listed there; `QApplication` comes from `Widgets`.

**Solution:** Add the component:
```json
"components": ["Core", "Gui", "Widgets"]
```

### 10.3 DLLs Missing at Runtime (Windows)

**Problem:**
```
Die Ausführung des Codes kann nicht fortgesetzt werden, da Qt6Cored.dll nicht gefunden wurde.
```

**Cause:** Qt DLLs must be in the same directory as the .exe or in PATH.

**Solution:** `windeployqt` copies the DLLs after every build of the target (§8.1). If they are
still missing, `windeployqt` was not found: is it under `<Qt>/bin` of the installation found?
Stopgap: put Qt's `bin` on PATH (§8.1).

### 10.4 Debug/Release DLLs Are Mixed Up (Multi-Config)

**Problem:** With Visual Studio (multi-config generator), the DLLs come from the wrong configuration.

**Background:** With multi-config generators, `CMAKE_BUILD_TYPE` is **empty** at configure time;
the configuration is only chosen at build time.

**Solution:** Already solved in the build system: `windeployqt` runs as a post-build step on
`$<TARGET_FILE:…>`, i.e. on the file just built, and chooses the matching DLLs itself. If mixed
DLLs still appear, empty the configuration's output directory and rebuild.

### 10.5 Qt Is Not Found Despite Being Installed

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

CMake's own diagnostics appear as a warning; the abort is reported by E503
(`cmake/externals/system/Handler.cmake:128`). If CMake finds Qt but not every module from
`components`, E504 follows instead; if `version` is set and no Qt version found matches, E505
(§11).

**Cause:** None of the sources from §5.1 leads to a Qt installation — environment variable not
set (or spelled differently on Linux/macOS), no hint, or Visual Studio does not inherit the
variable.

**Diagnosis:**
```bash
# Windows
echo %QT_ROOT%
dir "%QT_ROOT%\lib\cmake\Qt6"

# Linux/macOS
echo $QT_ROOT
ls "$QT_ROOT/lib/cmake/Qt6"

# Log the find_package search
cmake --preset ... --debug-find-pkg=Qt6
```

**Possible causes and solutions:**

| Cause | Solution |
|-------|----------|
| Environment variable not set | `setx QT_ROOT "..."` |
| Linux/macOS: `QT_ROOT` without a hint | Add the hint `"${QT_ROOT}"` or set `Qt6_ROOT` (§5.1) |
| VS does not inherit the variable | Use CMakeUserPresets.json |
| Wrong path/version | Check the path |
| Damaged installation | Reinstall Qt |
| Wrong compiler kit | MSVC Qt for MSVC, GCC Qt for GCC |

---

## 11. Troubleshooting

### Checklist for Problems

1. ☐ Qt installed?
2. ☐ Correct path? (`dir %QT_ROOT%\lib\cmake\Qt6`)
3. ☐ Environment variable set?
4. ☐ VS restarted after `setx`?
5. ☐ External declared with `"system": true` and `"package": "Qt6"`?
6. ☐ CMake cache deleted? (`cmake --fresh`)
7. ☐ Correct components in `components`?

### Common Errors

| Error | Solution |
|-------|----------|
| `[E503] System external 'qt6': find_package(Qt6) failed.` (preceded by the warning `Could not find a package configuration file provided by "Qt6"`) | Check the environment variable/`hints` (§5.1, §10.5) |
| `[E504] System external 'qt6': Qt6 was found (…), but not with all requested components: …` | The line `Reason given by the package` says which module is missing; install the module (Qt Maintenance Tool) or remove it from `components` |
| `[E505] System external 'qt6': no Qt6 with a version compatible to the requested '…' was found.` | `Considered:` lists the versions found; install a suitable Qt version and point `QT_ROOT`/`hints` to it, or adjust `version` |
| `[E502] System external 'qt6': 'package' field is required.` | Add `"package": "Qt6"` |
| `QApplication file not found` | Add `Widgets` to `components` |
| `main.moc file not found` | `qt6` in the target's `externals`, `package` set (§10.1) |
| `Qt6Cored.dll not found` | `windeployqt` under `<Qt>/bin`? Rebuild |
| `undefined reference to QApplication` | Add "Widgets" to components |

### Enable Debug Output

During configure, the handler reports what it found:
```
[Externals] [qt6] Found Qt6 6.10.1
```

The `find_package` search in detail:
```bash
cmake --preset ... --debug-find-pkg=Qt6
```

---

## 12. See Also

- [Solution_Schema.md](../references/Solution_Schema.md) – JSON schema reference
- [Externals.md](../references/Externals.md) – Externals reference
- [Qt6_cmake.md](../module/externals/system/packages/Qt6_cmake.md) – Module documentation of the package hook
- [externals/Qt6.md](externals/Qt6.md) – Qt6 as an external (quick reference)
- [Adding_Externals Uuserguide](Adding_Externals.md) – Adding new externals
- [CMakeUserPresets_Reference.md](../references/CMakeUserPresets.md) – User presets configuration

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.1 | 2026-11-09 | Aligned with the code: Qt6 as a system external (`"system": true`, `"package": "Qt6"`, `components`, `hints`, `backup`) instead of a local `externals/qt6/Include.cmake`; path resolution per `PathResolver.cmake`, field table, AUTOMOC/entry point/windeployqt from `packages/Qt6.cmake`, messages W501/E502, pitfalls and troubleshooting without Include.cmake versions, presets and output paths; CMakeCraft v0.14.1: `find_package` without `REQUIRED` (§5.1), failure case §10.5 with E503, E503/E504/E505 in §11 |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| **0.5.0** | **2025-12-14** | **Blueprint v0.5.0 conformance: prerequisites, pitfalls/troubleshooting separated, see also** |
| 0.2.0 | 2025-12-11 | Comprehensive revision: pitfalls, detailed installation, VS workarounds, platform support |
| 0.1.0 | 2025-12-10 | Initial |
