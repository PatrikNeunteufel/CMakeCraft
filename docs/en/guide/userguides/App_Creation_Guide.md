# App Creation Guide

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Guide  
> **Status:** Draft  
> **Target Audience:** Developers  
> **Language:** English  
> **German:** [App_Creation_Guide.md](../../../de/guide/userguides/App_Creation_Guide.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Creating a New App](#3-creating-a-new-app)
4. [Configuring Solution.json](#4-configuring-solutionjson)
5. [Adapting the Application Class](#5-adapting-the-application-class)
6. [Maintaining Source.cmake](#6-maintaining-sourcecmake)
7. [Precompiled Header](#7-precompiled-header)
8. [GUI Application with Qt](#8-gui-application-with-qt)
9. [Console Application](#9-console-application)
10. [Writing Tests](#10-writing-tests)
11. [Best Practices](#11-best-practices)
12. [Troubleshooting](#12-troubleshooting)
13. [See Also](#13-see-also)
14. [Changelog](#14-changelog)

---

## 1. Overview

This guide describes how to create a new application with the app container concept of the CMake Architecture build system.

### App Container Architecture

```
MeineApp/
├── include/        # Headers (.hpp)
├── src/            # Implementation (.cpp)
├── main/           # Entry point (main.cpp)
├── pch/            # Precompiled header
└── tests/          # Tests, one folder per test: tests/<type>/<Name>/
```

| Folder | Responsibility | Externals | Testable |
|--------|----------------|-----------|----------|
| `include/` + `src/` | All logic, UI, services | Qt, BASS, etc. | ✅ Yes |
| `main/` | Entry point only | — | ❌ No |
| `pch/` | Precompiled header | — | — |
| `tests/<type>/<Name>/` | Tests (unit, integration, performance, …) | doctest | — |

### Why This Separation?

The separation makes the application logic fully testable without having to start the application. The main/ folder contains only the platform-specific entry point.

---

## 2. Prerequisites

- CMake Architecture build system set up
- Solution.json present
- Required externals defined in the `externals` block

---

## 3. Creating a New App

### 3.1 Copy the Template

```bash
cp -r ../CMakeCraft/templates/App projects/apps/MeineApp
```

The template is in CMakeCraft under [`templates/App/`](../../../../templates/App/), copied here from a
working copy next to the project.

### 3.2 Directory Structure

After copying:

```
projects/apps/MeineApp/
├── README.md
├── README_de.md
├── include/
│   ├── Source.cmake
│   └── Application.hpp
├── src/
│   ├── Source.cmake
│   └── Application.cpp
├── main/
│   ├── Source.cmake
│   └── main.cpp              # Do not change!
├── pch/
│   └── pch.h
└── tests/
    ├── unit/
    │   └── UnitTests/
    │       ├── Source.cmake
    │       ├── test_main.cpp
    │       └── Application_Tests.cpp
    ├── integration/
    │   └── IntegrationTests/
    │       └── …                 # like UnitTests
    └── performance/
        └── PerformanceTests/
            └── …
```

> **Important:** `main.cpp` should not be changed. It is generic and works for all app types.

---

## 4. Configuring Solution.json

### 4.1 Add an App Entry

```json
"apps": [
    {
        "name": "MeineApp",
        "displayName": "Meine Anwendung",
        "version": "0.1.0",
        "description": "Beschreibung der Anwendung",
        
        "core": {
            "dependencies": [],
            "externals": ["qt6", "bass"]
        },
        
        "runner": {
            "type": "GUI",
            "externals": []
        },
        
        "tests": {
            "framework": "doctest",
            "targets": [
                {
                    "name": "UnitTests",
                    "type": "unit",
                    "path": "tests/unit/UnitTests",
                    "timeout": 30,
                    "labels": ["unit", "app", "fast"]
                }
            ]
        },
        
        "platforms": ["windows", "linux", "macos"]
    }
]
```

### 4.2 Fields Explained

| Field | Description |
|-------|-------------|
| `name` | Technical name (target name) |
| `displayName` | Display name |
| `version` | Semantic version |
| `core.dependencies` | Internal libraries |
| `core.externals` | External libraries (Qt, BASS, etc.) |
| `runner.type` | `GUI` or `CONSOLE` |
| `runner.externals` | Externals for the runner only (rarely needed) |
| `tests.framework` | Test framework (doctest, googletest, catch2) |
| `tests.targets[]` | One entry per test executable: `name`, `type` (required), `path` (default `tests/<type>/<name>`), `timeout`, `labels`, … — target name `<App>.<name>`, e.g. `MeineApp.UnitTests` |

### 4.3 runner.type

| Type | Windows | Linux/macOS | Usage |
|------|---------|-------------|-------|
| `GUI` | `WinMain` | `main` | Qt, OpenGL, window apps |
| `CONSOLE` | `main` | `main` | CLI tools, servers |

With `GUI` on Windows, no console window is opened.

---

## 5. Adapting the Application Class

### 5.1 Extend the Header

`include/Application.hpp`:

```cpp
#pragma once

#include <memory>
#include <string>

// Forward Declarations
class QApplication;
class MainWindow;

class Application {
public:
    Application();
    ~Application();
    
    Application(const Application&) = delete;
    Application& operator=(const Application&) = delete;
    
    [[nodiscard]] bool init(int argc, char* argv[]);
    [[nodiscard]] int run();
    void shutdown();
    
    [[nodiscard]] const std::string& name() const noexcept;
    [[nodiscard]] const std::string& version() const noexcept;
    [[nodiscard]] bool isInitialized() const noexcept;
    [[nodiscard]] bool isRunning() const noexcept;

private:
    struct Impl;
    std::unique_ptr<Impl> m_impl;
    
    bool m_initialized{false};
    bool m_running{false};
};
```

---

## 6. Maintaining Source.cmake

Every folder with source code contains a `Source.cmake`. It has to be updated when new files are added:

### 6.1 Add New Headers

`include/Source.cmake`:

```cmake
set(_local_headers
    "${CMAKE_CURRENT_LIST_DIR}/Application.hpp"
    "${CMAKE_CURRENT_LIST_DIR}/MainWindow.hpp"      # NEW
    "${CMAKE_CURRENT_LIST_DIR}/AudioEngine.hpp"     # NEW
)
```

### 6.2 Add New Sources

`src/Source.cmake`:

```cmake
set(_local_sources
    "${CMAKE_CURRENT_LIST_DIR}/Application.cpp"
    "${CMAKE_CURRENT_LIST_DIR}/MainWindow.cpp"      # NEW
    "${CMAKE_CURRENT_LIST_DIR}/AudioEngine.cpp"     # NEW
)
```

### 6.3 Include Subfolders

For subfolders, at the end of `Source.cmake`:

```cmake
# Include subfolders recursively
include("${CMAKE_CURRENT_LIST_DIR}/audio/Source.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/ui/Source.cmake")
```

---

## 7. Precompiled Header

### 7.1 Purpose

`pch/pch.h` contains frequently used, stable includes to reduce build times.

### 7.2 Enable PCH in Solution.json

PCH must be enabled explicitly:

```json
"apps": [{
    "name": "MeineApp",
    "pch": {
        "enabled": true
    }
}]
```

**Implicit activation:** PCH is also enabled if only `header` or `path` is given (and `enabled` is not `false`):

```json
// Implicitly enabled by header
"pch": { "header": "stdafx.h" }

// Implicitly enabled by path
"pch": { "path": "common/pch" }
```

### 7.3 Search Path Priority

If no custom `path` is given, the build system searches in this order:

| Priority | Path | Example |
|----------|------|---------|
| 1 | `{app}/pch/{header}` | `projects/apps/MeineApp/pch/pch.h` |
| 2 | `{app}/src/{header}` | `projects/apps/MeineApp/src/pch.h` |
| 3 | `{app}/{header}` | `projects/apps/MeineApp/pch.h` |

With a custom `path` (relative to `projects/`):

```json
"pch": { "path": "common/pch", "header": "shared.h" }
// → projects/common/pch/shared.h
```

### 7.4 Adapt the Contents

```cpp
#pragma once

// Standard Library
#include <memory>
#include <string>
#include <vector>

// Qt (for GUI apps)
#include <QApplication>
#include <QMainWindow>
#include <QString>

// Audio (for audio apps)
#include <bass.h>
```

### 7.5 Note on the Extension

The `.h` extension is the standard for PCH, even in C++. Some compilers and tools do not process `.hpp` correctly as a PCH.

---

## 8. GUI Application with Qt

### 8.1 Application.cpp for Qt

```cpp
#include "Application.hpp"
#include "MainWindow.hpp"

#include <QApplication>

struct Application::Impl {
    std::string name{"MeineApp"};
    std::string version{"0.1.0"};
    
    std::unique_ptr<QApplication> qtApp;
    std::unique_ptr<MainWindow> mainWindow;
};

bool Application::init(int argc, char* argv[]) {
    if (m_initialized) return false;
    
    m_impl->qtApp = std::make_unique<QApplication>(argc, argv);
    m_impl->mainWindow = std::make_unique<MainWindow>();
    m_impl->mainWindow->show();
    
    m_initialized = true;
    return true;
}

int Application::run() {
    if (!m_initialized) return 1;
    m_running = true;
    return m_impl->qtApp->exec();
}

void Application::shutdown() {
    m_impl->mainWindow.reset();
    m_impl->qtApp.reset();
    m_initialized = false;
}
```

### 8.2 MainWindow with Docking

See [App Template Reference](../references/App_Template_Reference.md) for details on QDockWidget.

---

## 9. Console Application

### 9.1 Application.cpp for Console

```cpp
#include "Application.hpp"
#include <iostream>

struct Application::Impl {
    std::string name{"MeinTool"};
    std::string version{"0.1.0"};
    bool shouldRun{true};
};

bool Application::init(int argc, char* argv[]) {
    // Load configuration, start services
    m_initialized = true;
    return true;
}

int Application::run() {
    m_running = true;
    while (m_impl->shouldRun) {
        // Main logic
    }
    return 0;
}

void Application::shutdown() {
    m_impl->shouldRun = false;
    m_initialized = false;
}
```

---

## 10. Writing Tests

### 10.1 Test File

Each test lives in its own folder `tests/<type>/<Name>/` with `Source.cmake`, `test_main.cpp`
(doctest implementation and `main()`, exactly once per test executable) and the test files:

```cpp
// tests/unit/UnitTests/Application_Tests.cpp

#include <doctest.h>
#include "Application.hpp"

TEST_SUITE("Application") {
    
    TEST_CASE("Init Success") {
        Application app;
        char arg0[] = "TestApp";
        char* argv[] = {arg0, nullptr};
        
        CHECK(app.init(1, argv));
        CHECK(app.isInitialized());
    }
}
```

### 10.2 Testing Qt Widgets

Qt widgets can be tested without `QApplication::exec()`:

```cpp
#include <doctest.h>
#include <QApplication>
#include "MainWindow.hpp"

TEST_CASE("MainWindow Creation") {
    int argc = 0;
    char* argv[] = {nullptr};
    QApplication app(argc, argv);
    
    MainWindow window;
    CHECK(window.menuBar() != nullptr);
}
```

---

## 11. Best Practices

### 11.1 Separation of Concerns

- `include/` + `src/` contain all UI classes, services and logic
- `main/` contains only the generic main.cpp
- No business logic in main.cpp

### 11.2 Keep Source.cmake Up to Date

Update the corresponding `Source.cmake` for every new file.

### 11.3 Use PCH Sensibly

Only stable, frequently used headers in `pch.h`:
- ✅ Standard library
- ✅ Qt Core headers
- ❌ Your own headers (change often)

---

## 12. Troubleshooting

### Problem: Console Window with a GUI App (Windows)

**Solution:** Set `runner.type` to `"GUI"`.

### Problem: New Files Are Not Compiled

**Solution:** Update `Source.cmake` in the corresponding folder.

### Problem: PCH Is Not Used

**Solution:** Check whether `pch/pch.h` exists and is configured in CMake.

---

## 13. See Also

- [App Template Reference](../references/App_Template_Reference.md)
- [Solution Schema](../references/Solution_Schema.md)
- [AppContainer Concept](../../konzepte/abgeschlossen/AppContainer_Concept.md)

---

## 14. Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.1 | 2026-11-09 | Aligned with the code: template under `templates/App/` (CMakeCraft), test layout `tests/<type>/<Name>/` as in the template, `tests.targets[]` instead of `tests.unit` (`AppCollect.cmake`) |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| **0.1.1** | **2025-12-18** | **PCH activation via Solution.json documented, search path priority, implicit activation** |
| 0.1.0 | 2025-12-17 | Initial with correct structure (include/, src/, main/, pch/) |
