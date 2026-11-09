# App Template Reference

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Reference  
> **Status:** Draft  
> **Target Audience:** Developers  
> **Language:** English  
> **German:** [App_Template_Reference.md](../../../de/guide/references/App_Template_Reference.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Directory Structure](#2-directory-structure)
3. [main.cpp](#3-maincpp)
4. [Application Interface](#4-application-interface)
5. [Source.cmake](#5-sourcecmake)
6. [Precompiled Header](#6-precompiled-header)
7. [Build Defines](#7-build-defines)
8. [CMake Integration](#8-cmake-integration)
9. [See Also](#9-see-also)
10. [Changelog](#10-changelog)

---

## 1. Overview

The app template defines the standard structure for app containers in the CMake Architecture build system. It separates the entry point (main/) from the application logic (include/, src/) for maximum testability.

### Path

```
templates/App/
```

---

## 2. Directory Structure

```
App/
├── README.md                      # Quick guide (English)
├── README_de.md                   # Quick guide (German)
├── include/                       # Headers
│   ├── Source.cmake
│   └── Application.hpp
├── src/                           # Implementation
│   ├── Source.cmake
│   └── Application.cpp
├── main/                          # Entry point
│   ├── Source.cmake
│   └── main.cpp                   # Generic, do not modify
├── pch/                           # Precompiled header
│   └── pch.h
└── tests/                         # Tests: tests/<type>/<Name>/
    ├── unit/UnitTests/            # Unit tests
    │   ├── Source.cmake
    │   ├── test_main.cpp
    │   └── Application_Tests.cpp
    ├── integration/IntegrationTests/   # Integration tests
    │   ├── Source.cmake
    │   ├── test_main.cpp
    │   └── Application_Integration_Tests.cpp
    └── performance/PerformanceTests/   # Performance tests
        ├── Source.cmake
        ├── test_main.cpp
        └── Application_Performance_Tests.cpp
```

### Components

| Directory | Description | Testable |
|-----------|-------------|----------|
| `include/` | Header files (.hpp) | ✅ |
| `src/` | Implementation (.cpp) | ✅ |
| `main/` | Entry point (main.cpp) | ❌ |
| `pch/` | Precompiled header | — |
| `tests/<type>/<Name>/` | One folder per test target with `Source.cmake`, `test_main.cpp` and the tests. Default for `apps[].tests.targets[].path` is `tests/{type}/{name}` (`AppCollect.cmake:373`) | — |

---

## 3. main.cpp

### Path

```
main/main.cpp
```

### Content

```cpp
#include "Application.hpp"

#if defined(_WIN32)
    #include <Windows.h>
#endif

namespace {

int commonMain(int argc, char* argv[]) {
    Application app;
    
    if (!app.init(argc, argv)) {
        return 1;
    }
    
    int result = app.run();
    app.shutdown();
    
    return result;
}

} // namespace

#if defined(_WIN32) && defined(APP_WINDOWS_GUI)

int WINAPI WinMain(
    [[maybe_unused]] HINSTANCE hInstance,
    [[maybe_unused]] HINSTANCE hPrevInstance,
    [[maybe_unused]] LPSTR lpCmdLine,
    [[maybe_unused]] int nCmdShow
) {
    return commonMain(__argc, __argv);
}

#else

int main(int argc, char* argv[]) {
    return commonMain(argc, argv);
}

#endif
```

### Properties

| Property | Value |
|----------|-------|
| Modifiable | ❌ No |
| Platform-specific | ✅ Yes (via preprocessor) |
| Dependencies | Only `Application.hpp` |

---

## 4. Application Interface

### Path

```
include/Application.hpp
```

### Required Interface

```cpp
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
};
```

### Lifecycle Methods

| Method | Description | Return |
|--------|-------------|--------|
| `init()` | Initialization (Qt, audio, config) | `true` on success |
| `run()` | Main loop (`QApplication::exec()`) | Exit code |
| `shutdown()` | Release resources | — |

### Call Order

```
main() → Application() → init() → run() → shutdown() → ~Application()
```

---

## 5. Source.cmake

Every folder containing source code has a `Source.cmake` for explicit file registration.

### Structure

```cmake
# Source.cmake for {folder}/
dbg(DBG_OFTEN "${CMAKE_CURRENT_LIST_DIR}/Source.cmake..." ID INCLUDE_MSG)

set(_local_sources
    # "${CMAKE_CURRENT_LIST_DIR}/File.cpp"
)
set(_local_headers
    # "${CMAKE_CURRENT_LIST_DIR}/File.hpp"
)
set(_local_templates
    # "${CMAKE_CURRENT_LIST_DIR}/File.tpp"
)
set(_local_inlines
    # "${CMAKE_CURRENT_LIST_DIR}/File.inl"
)
set(_local_impl
    # "${CMAKE_CURRENT_LIST_DIR}/File.impl"
)

# Aggregation
list(APPEND ${EXECUTABLE_NAME}_PROJECT_SOURCES ${_local_sources})
list(APPEND ${EXECUTABLE_NAME}_PROJECT_HEADERS ${_local_headers})
# ...

# Cleanup
unset(_local_sources)
# ...

# Subfolder (optional)
# include("${CMAKE_CURRENT_LIST_DIR}/subfolder/Source.cmake")
```

### File Types

| Variable | Extensions | Description |
|----------|------------|-------------|
| `_local_sources` | .c, .cpp | Compilable sources |
| `_local_headers` | .h, .hpp | Header files |
| `_local_templates` | .t, .tpp | Template implementations |
| `_local_inlines` | .inl | Inline implementations |
| `_local_impl` | .impl | Pimpl implementations |

---

## 6. Precompiled Header

### Path

```
pch/pch.h
```

### Purpose

Frequently used, stable includes to reduce build time.

### Content

```cpp
#pragma once

// Standard Library
#include <memory>
#include <string>
#include <vector>
// ...

// Framework (project-specific)
// #include <QApplication>
// #include <bass.h>
```

### Extension

The `.h` extension is standard for PCH, even for C++. Some compilers/tools do not handle `.hpp` correctly.

### Search Path Priority

If PCH is enabled and no custom `path` is given:

| Priority | Path |
|----------|------|
| 1 | `{app-path}/pch/{header}` |
| 2 | `{app-path}/src/{header}` |
| 3 | `{app-path}/{header}` |

With a custom `path`: `projects/{path}/{header}`

### Best Practices

| Include | Suitable for PCH |
|---------|------------------|
| Standard library | ✅ Yes |
| Qt/framework headers | ✅ Yes |
| Own headers | ❌ No (change often) |

---

## 7. Build Defines

The build system sets automatically:

| Define | Condition | Description |
|--------|-----------|-------------|
| `APP_WINDOWS_GUI` | Windows and `runner.type = "GUI"` or `"WINDOW"` | `main.cpp` uses `WinMain` (`AppCreate.cmake:385`) |

For `CONSOLE` the build system sets no define; `main.cpp` then uses `main`.

### Platform Behavior

| runner.type | Windows | Linux | macOS |
|-------------|---------|-------|-------|
| `GUI`/`WINDOW` | `WinMain` (no console, `add_executable(... WIN32 ...)`) | `main` | `main` (`MACOSX_BUNDLE`) |
| `CONSOLE` | `main` (with console) | `main` | `main` |

---

## 8. CMake Integration

### Generated Targets

For an app `MyApp` the build system creates (`cmake/project/AppCreate.cmake`):

| Target | Kind | Content |
|--------|------|---------|
| `MyApp.Core` | `STATIC` library | `include/` (PUBLIC), `src/`, PCH from `pch/` (include path PUBLIC), dependencies PUBLIC, `core.externals` |
| `MyApp` | Executable | `main/`, links `MyApp.Core` (PRIVATE), `runner.externals`; no PCH |
| `MyApp.<TestName>` | Executable per test target | Sources from `tests/<type>/<Name>/`, links `MyApp.Core` |

```cmake
# Simplified
add_library(MyApp.Core STATIC)
target_include_directories(MyApp.Core PUBLIC include pch)
target_precompile_headers(MyApp.Core PRIVATE pch/pch.h)

add_executable(MyApp WIN32 ...)        # WIN32 only on Windows for GUI/WINDOW
target_compile_definitions(MyApp PRIVATE APP_WINDOWS_GUI)   # likewise
target_link_libraries(MyApp PRIVATE MyApp.Core)
```

---

## 9. See Also

- [App Creation Guide](../userguides/App_Creation_Guide.md) — Step-by-step guide
- [Solution Schema](Solution_Schema.md) — apps array documentation
- [AppContainer Concept](../../konzepte/abgeschlossen/AppContainer_Concept.md) — Architecture concept

---

## 10. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: template under `templates/App/`; test layout `tests/<type>/<Name>/` as in the template; define `APP_WINDOWS_GUI` instead of `APP_GUI`/`APP_CONSOLE` (`AppCreate.cmake:385`); §8 with the targets `MyApp.Core`, `MyApp`, `MyApp.<TestName>`** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.1.1 | 2025-12-18 | PCH search path priority documented |
| 0.1.0 | 2025-12-17 | Initial with correct structure (include/, src/, main/, pch/) |
