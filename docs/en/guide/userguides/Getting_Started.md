# Getting Started – User Guide

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Guide  
> **Status:** Stable  
> **Target Audience:** C++ developers (beginners and advanced)  
> **Language:** English  
> **German:** [Getting_Started_UserGuide.md](../../../de/guide/userguides/Getting_Started.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Quick Start](#3-quick-start)
4. [Understanding the Project Structure](#4-understanding-the-project-structure)
5. [Solution.json – The Core](#5-solutionjson--the-core)
6. [Creating Your First Executable](#6-creating-your-first-executable)
7. [Creating Your First Library](#7-creating-your-first-library)
8. [Build Commands](#8-build-commands)
9. [Using Externals](#9-using-externals)
10. [Adding Tests](#10-adding-tests)
11. [Workflow Summary](#11-workflow-summary)
12. [Pitfalls and Solutions](#12-pitfalls-and-solutions)
13. [Troubleshooting](#13-troubleshooting)
14. [Next Steps](#14-next-steps)
15. [See Also](#15-see-also)

---

## 1. Overview

Welcome to the **CMake Architecture** build system! This guide walks you through all the steps to successfully create and build your first project.

### What Is CMake Architecture?

A **JSON-driven build system** for C++ projects that:

- Works **declaratively** – describe WHAT, not HOW
- Supports **multiple projects** – several executables and libraries in one solution
- Manages **external libraries** automatically
- Works **cross-platform** (Windows, Linux, macOS)
- Offers **IDE integration** (Visual Studio, CLion, VS Code)

### The Most Important Principle

> **If it is not in Solution.json, it does not exist.**

Everything – executables, libraries, tests, externals – is defined in `Solution.json`. The build system automatically generates the CMake configuration from it.

### What You Will Have at the End of This Guide

- A working project with an executable and a library
- An understanding of the project structure
- Knowledge of how to add new modules
- Basics for tests and externals

---

## 2. Prerequisites

### Checklist

- [ ] **CMake 3.26+** installed
- [ ] **C++ compiler:** MSVC 2022, GCC 11+, or Clang 14+
- [ ] **Git** installed
- [ ] **IDE** (recommended): Visual Studio 2022, CLion, or VS Code with the CMake extension
- [ ] **Ninja** (recommended for faster builds)

### Check the Installation

```bash
# CMake version
cmake --version
# Should be 3.26 or higher

# Compiler
cl /?          # Windows (MSVC)
g++ --version  # Linux (GCC)
clang++ --version  # macOS/Linux (Clang)

# Git
git --version

# Ninja (optional but recommended)
ninja --version
```

### Recommended Versions

| Tool | Minimum | Recommended |
|------|---------|-------------|
| CMake | 3.26 | 3.28+ |
| MSVC | 2019 | 2022 |
| GCC | 11 | 13+ |
| Clang | 14 | 17+ |
| Ninja | 1.10 | 1.11+ |

---

## 3. Quick Start

### 3.1 Create the Project

CMakeCraft does not live in the project: the project carries only three small files, and the build
system itself is fetched in the pinned version into `.externals/cmakecraft/<version>/` on the first
configure. The templates are in CMakeCraft under [`templates/consumer/`](../../../../templates/consumer/):

```bash
mkdir MyProject && cd MyProject
git init

# from a CMakeCraft working copy, here ../CMakeCraft
cp ../CMakeCraft/templates/consumer/CMakeCraftBootstrap.cmake .
cp ../CMakeCraft/templates/consumer/cmakecraft.pin .
cp ../CMakeCraft/templates/consumer/CMakeLists.txt .
cp ../CMakeCraft/CMakePresets.json .
```

- `CMakeCraftBootstrap.cmake` — take it over unchanged.
- `cmakecraft.pin` — the CMakeCraft version as a Git tag, e.g. `set(CMAKECRAFT_VERSION "v0.14.1")`.
- `CMakeLists.txt` — only adjust the name in `project(<Name> LANGUAGES NONE)`. The line is
  required (since v0.13.0, otherwise E005); CMakeCraft sets name and version from Solution.json.

The complete setup (`.gitignore`, user presets, first commit) is described in the
[New Project Guide](Neues_Projekt_Guide.md).

### 3.2 Create Solution.json

Create `Solution.json` in the project root:

```json
{
    "schemaVersion": "1.0",
    "solution": {
        "name": "MyProject",
        "version": "1.0.0"
    },
    "settings": {
        "standards": {
            "cxx_standard": 20
        }
    },
    "executables": [
        {
            "name": "HelloWorld",
            "type": "CONSOLE"
        }
    ]
}
```

### 3.3 Create the Source File

Create `projects/exec/HelloWorld/src/main.cpp` (default path of an executable, §4.3):

```cpp
#include <iostream>

int main() {
    std::cout << "Hello, CMake Architecture!" << std::endl;
    return 0;
}
```

Next to it, the file list `projects/exec/HelloWorld/src/Source.cmake` — sources are listed
explicitly (default `settings.sources.mode = "explicit"`, §6.6):

```cmake
list(APPEND ${TARGET_NAME}_SOURCES "${CMAKE_CURRENT_LIST_DIR}/main.cpp")
```

### 3.4 Build and Run

```bash
# Configure (the first time, CMakeCraft is fetched according to cmakecraft.pin)
cmake --preset windows-ninja-debug-msvc   # Windows (or windows-ninja-debug-clang)
cmake --preset linux-gcc-debug            # Linux
cmake --preset macos-ninja-debug          # macOS

# Build
cmake --build out/build/windows-ninja-debug-msvc

# Run
./out/build/windows-ninja-debug-msvc/exec/HelloWorld/bin/Debug/HelloWorld.exe   # Windows
./out/build/linux-gcc-debug/exec/HelloWorld/bin/Debug/HelloWorld                # Linux
```

**Done!** You have built your first project. 🎉

---

## 4. Understanding the Project Structure

### 4.1 Standard Directory Structure

```
MyProject/
├── CMakeLists.txt              ← Thin version (template templates/consumer/)
├── CMakeCraftBootstrap.cmake   ← fetches CMakeCraft (unchanged from the template)
├── cmakecraft.pin              ← CMakeCraft version (Git tag)
├── CMakePresets.json           ← Team-wide build presets
├── CMakeUserPresets.json       ← Personal presets (do not commit!)
├── Solution.json               ← CENTRAL CONFIGURATION
│
├── externals/                  ← Local external libraries
│   ├── bass/
│   ├── doctest/
│   └── lua54/
│
├── projects/                   ← YOUR CODE
│   ├── exec/                   ← Executables
│   │   └── HelloWorld/
│   │       └── src/
│   │           ├── Source.cmake
│   │           └── main.cpp
│   ├── libs/                   ← Libraries
│   │   └── CoreLib/
│   │       ├── include/
│   │       │   └── CoreLib/
│   │       │       └── Calculator.h
│   │       └── src/
│   │           ├── Source.cmake
│   │           └── Calculator.cpp
│   └── tests/                  ← Test projects
│       └── unit/
│           └── CoreLib_Tests/
│               └── src/
│
├── .externals/                 ← fetched during configure (do not commit)
│   └── cmakecraft/<version>/   ← the build system itself
│
└── out/                        ← Build output (generated)
    └── build/
        └── windows-ninja-debug-msvc/
            └── exec/
                └── HelloWorld/
                    └── bin/
                        └── Debug/
                            └── HelloWorld.exe
```

### 4.2 Important Files

| File | Purpose | Edit? |
|------|---------|-------|
| `Solution.json` | Project definition | ✅ YES |
| `CMakeLists.txt` | CMake entry point (thin version from `templates/consumer/`) | ⚠️ Only the name in `project(<Name> LANGUAGES NONE)` — the line is required (since v0.13.0, otherwise E005) |
| `cmakecraft.pin` | CMakeCraft version (Git tag) and sources | ⚠️ When changing the version |
| `CMakeCraftBootstrap.cmake` | Fetches CMakeCraft into `.externals/cmakecraft/<version>/` | ❌ No (take over unchanged) |
| `CMakePresets.json` | Team presets | ⚠️ Rarely |
| `CMakeUserPresets.json` | Personal presets | ✅ YES |

### 4.3 Path Conventions

By default, the build system expects these paths:

| Type | Path pattern |
|------|--------------|
| Executable | `projects/exec/{name}/src/` |
| Library | `projects/libs/{name}/src/` (public headers: `projects/libs/{name}/include/`, if present) |
| Test | `projects/tests/{type}/{name}/src/` |

You can override them with the `path` field (a library's headers with `public_headers`).
In the source directory the build system expects a `Source.cmake` with the file list (§6.6).

---

## 5. Solution.json – The Core

### 5.1 Basic Structure

```json
{
    "schemaVersion": "1.0",
    "solution": {
        "name": "MySolution",
        "version": "1.0.0"
    },
    "settings": { ... },
    "externals": { ... },
    "libraries": [ ... ],
    "executables": [ ... ],
    "apps": [ ... ],
    "tests": [ ... ]
}
```

### 5.2 Sections Explained

| Section | Purpose | Required? |
|---------|---------|-----------|
| `schemaVersion` | Schema version (currently `1.0`; a different major aborts with E003) | ✅ Yes |
| `solution` | Project metadata | ✅ Yes |
| `settings` | Global settings | ❌ Optional |
| `externals` | External libraries | ❌ Optional |
| `libraries` | Internal libraries | ❌ Optional |
| `executables` | Executable programs | ❌ Optional |
| `apps` | App containers (core lib + runner + tests), see [App_Creation_Guide](App_Creation_Guide.md) | ❌ Optional |
| `tests` | Test executables | ❌ Optional |

### 5.3 Settings Section

```json
"settings": {
    "standards": {
        "cxx_standard": 20,
        "c_standard": 17
    },
    "defaults": {
        "library_type": "STATIC",
        "executable_type": "CONSOLE"
    },
    "sources": {
        "mode": "explicit"
    }
}
```

`sources.mode`: `explicit` (default — `Source.cmake` is required), `auto` (`Source.cmake` if it
lists files, otherwise all files in the directory) or `glob` (always all files).
The output directories are fixed (§4.1) and cannot be set in Solution.json.

### 5.4 Processing Order

```
1. settings      → Global settings
2. externals     → Load external libraries
3. libraries     → Create internal libraries
4. executables   → Create executables (can use libraries)
5. apps          → Create app containers
6. packages      → Create package targets
7. tests         → Create tests (only with BUILD_TESTS=ON)
```

**Important:** The sections run in this order regardless of where they appear in the file.
Within `libraries`, however, the order of the entries matters: a library must come **after** the
libraries it depends on (otherwise E101).

---

## 6. Creating Your First Executable

### 6.1 Workflow

```
1. Create the Solution.json entry  ← ALWAYS FIRST!
2. Configure CMake
3. Create files
4. Build and test
```

### 6.2 Solution.json Entry

```json
{
    "executables": [
        {
            "name": "MyApp",
            "displayName": "My Application",
            "version": "1.0.0",
            "type": "CONSOLE"
        }
    ]
}
```

### 6.3 Executable Types

| Type | Description | Windows subsystem |
|------|-------------|-------------------|
| `CONSOLE` | Console application | CONSOLE |
| `GUI` | Graphical application (no console window) | WINDOWS |

`CLI`, `HEADLESS` and `WORKER` are built like `CONSOLE`.

### 6.4 Complete Configuration

```json
{
    "name": "MyApp",
    "displayName": "My Application",
    "version": "1.0.0",
    "type": "CONSOLE",
    "path": "projects/exec/MyApp/src",
    "dependencies": ["CoreLib", "UtilLib"],
    "externals": ["spdlog", "bass"],
    "defines": ["APP_VERSION=\"1.0.0\""],
    "compile_options": ["-Wall"]
}
```

### 6.5 Field Reference

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | string | **Required** | Target name |
| `displayName` | string | `name` | Display name |
| `version` | string | Solution version | Semantic version |
| `type` | string | `"CONSOLE"` (or `settings.defaults.executable_type`) | CONSOLE or GUI |
| `path` | string | Convention | Source directory |
| `dependencies` | string[] | `[]` | Internal libraries |
| `externals` | string[] | `[]` | External libraries |

### 6.6 Source Files

Create the source files in the given path:

**main.cpp:**
```cpp
#include <iostream>

int main(int argc, char* argv[]) {
    std::cout << "Hello from MyApp!" << std::endl;
    return 0;
}
```

**Source.cmake** (in the same directory):
```cmake
list(APPEND ${TARGET_NAME}_SOURCES "${CMAKE_CURRENT_LIST_DIR}/main.cpp")
```

Sources are **explicit**: every new file goes into `Source.cmake` (`list(APPEND …)`, never
glob); if the file is missing, configuring aborts with E104. Format and templates:
[templates/README.md](../../../../templates/README.md). Only with `settings.sources.mode` `auto` or
`glob` does the build system collect the files of the directory itself.

---

## 7. Creating Your First Library

### 7.1 Solution.json Entry

```json
{
    "libraries": [
        {
            "name": "CoreLib",
            "version": "1.0.0",
            "type": "STATIC"
        }
    ]
}
```

### 7.2 Library Types

| Type | Description | When to use? |
|------|-------------|--------------|
| `STATIC` | Statically linked (.lib/.a) | Default, simplest option |
| `SHARED` | Dynamically linked (.dll/.so) | When several programs share it |
| `INTERFACE` | Header-only | No .cpp files |

### 7.3 Complete Configuration

```json
{
    "name": "CoreLib",
    "displayName": "Core Library",
    "version": "1.0.0",
    "type": "STATIC",
    "path": "projects/libs/CoreLib/src",
    "public_headers": "projects/libs/CoreLib/include",
    "dependencies": [],
    "externals": []
}
```

### 7.4 Directory Structure

```
projects/libs/CoreLib/
├── include/
│   └── CoreLib/
│       └── Calculator.h
└── src/
    ├── Source.cmake
    └── Calculator.cpp
```

### 7.5 Header File

**include/CoreLib/Calculator.h:**
```cpp
#pragma once

namespace CoreLib {

class Calculator {
public:
    int add(int a, int b) const;
    int subtract(int a, int b) const;
    int multiply(int a, int b) const;
    double divide(int a, int b) const;
};

} // namespace CoreLib
```

### 7.6 Implementation

**src/Calculator.cpp:**
```cpp
#include "CoreLib/Calculator.h"
#include <stdexcept>

namespace CoreLib {

int Calculator::add(int a, int b) const {
    return a + b;
}

int Calculator::subtract(int a, int b) const {
    return a - b;
}

int Calculator::multiply(int a, int b) const {
    return a * b;
}

double Calculator::divide(int a, int b) const {
    if (b == 0) {
        throw std::domain_error("Division by zero");
    }
    return static_cast<double>(a) / b;
}

} // namespace CoreLib
```

Plus `src/Source.cmake`:
```cmake
list(APPEND ${TARGET_NAME}_SOURCES "${CMAKE_CURRENT_LIST_DIR}/Calculator.cpp")
```

### 7.7 Using the Library in an Executable

```json
{
    "executables": [
        {
            "name": "Calculator",
            "dependencies": ["CoreLib"]
        }
    ]
}
```

**main.cpp:**
```cpp
#include <iostream>
#include "CoreLib/Calculator.h"

int main() {
    CoreLib::Calculator calc;
    std::cout << "2 + 3 = " << calc.add(2, 3) << std::endl;
    return 0;
}
```

---

## 8. Build Commands

### 8.1 Using CMake Presets

```bash
# Show available presets
cmake --list-presets

# Configure
cmake --preset windows-ninja-debug-msvc

# Build
cmake --build out/build/windows-ninja-debug-msvc

# Or with a preset
cmake --build --preset build-ninja-debug-msvc
```

### 8.2 Common Presets

| Preset | Platform | Compiler | Build type |
|--------|----------|----------|------------|
| `windows-ninja-debug-msvc` | Windows | MSVC | Debug |
| `windows-ninja-release-msvc` | Windows | MSVC | Release |
| `windows-ninja-debug-clang` | Windows | Clang | Debug |
| `windows-ninja-testing-msvc` | Windows | MSVC | Testing |
| `linux-gcc-debug` | Linux | GCC | Debug |
| `linux-clang-debug` | Linux | Clang | Debug |
| `macos-ninja-debug` | macOS | Clang | Debug |

All presets: `cmake --list-presets` or [CMakePresets.md](../references/CMakePresets.md).

### 8.3 Building a Single Target

```bash
# Only a specific target
cmake --build out/build/windows-ninja-debug-msvc --target MyApp

# Only one test target (name as in Solution.json)
cmake --build out/build/windows-ninja-debug-msvc --target CoreLib_Tests
```

### 8.4 Clean Build

```bash
# Delete the cache and configure again
cmake --preset windows-ninja-debug-msvc --fresh

# Delete the build directory
rm -rf out/build/windows-ninja-debug-msvc
cmake --preset windows-ninja-debug-msvc
```

### 8.5 Building in Parallel

```bash
# With 8 jobs
cmake --build out/build/windows-ninja-debug-msvc -j8

# All CPUs
cmake --build out/build/windows-ninja-debug-msvc -j
```

---

## 9. Using Externals

### 9.1 Local External

```json
{
    "externals": {
        "doctest": {
            "path": "externals/doctest"
        }
    },
    "executables": [
        {
            "name": "MyApp",
            "externals": ["doctest"]
        }
    ]
}
```

### 9.2 Git External

```json
{
    "externals": {
        "spdlog": {
            "git": "https://github.com/gabime/spdlog.git",
            "tag": "v1.12.0"
        }
    }
}
```

### 9.3 Usage in Code

```cpp
#include <spdlog/spdlog.h>

int main() {
    spdlog::info("Hello from spdlog!");
    return 0;
}
```

More details: → [Externals UserGuide](Externals.md)

---

## 10. Adding Tests

### 10.1 Solution.json Entry

```json
{
    "externals": {
        "doctest": { "path": "externals/doctest" }
    },
    "tests": [
        {
            "name": "CoreLib_Tests",
            "type": "unit",
            "framework": "doctest",
            "dependencies": ["CoreLib"],
            "externals": ["doctest"]
        }
    ]
}
```

### 10.2 Test File

**projects/tests/unit/CoreLib_Tests/src/test_main.cpp:**
```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest/doctest.h>
#include "CoreLib/Calculator.h"

TEST_CASE("Calculator::add") {
    CoreLib::Calculator calc;
    CHECK(calc.add(2, 3) == 5);
    CHECK(calc.add(-1, 1) == 0);
}
```

Plus `src/Source.cmake` with `list(APPEND ${TARGET_NAME}_SOURCES "${CMAKE_CURRENT_LIST_DIR}/test_main.cpp")`.

### 10.3 Running Tests

```bash
# Build with tests (the Ninja presets already set BUILD_TESTS to ON)
cmake --preset windows-ninja-debug-msvc -DBUILD_TESTS=ON
cmake --build out/build/windows-ninja-debug-msvc

# Run tests
ctest --test-dir out/build/windows-ninja-debug-msvc
```

More details: → [Testing UserGuide](Testing.md)

---

## 11. Workflow Summary

### The Golden Workflow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Create the Solution.json entry        ← ALWAYS FIRST!   │
│    └─ Define name, version, type                           │
├─────────────────────────────────────────────────────────────┤
│ 2. Configure CMake                                          │
│    └─ cmake --preset windows-ninja-debug-msvc              │
├─────────────────────────────────────────────────────────────┤
│ 3. Create files                                             │
│    └─ main.cpp / header / source                           │
├─────────────────────────────────────────────────────────────┤
│ 4. Build                                                    │
│    └─ cmake --build out/build/windows-ninja-debug-msvc     │
├─────────────────────────────────────────────────────────────┤
│ 5. Test                                                     │
│    └─ Run the program / ctest                              │
└─────────────────────────────────────────────────────────────┘
```

### Checklist: Adding a New Module

- [ ] Write the Solution.json entry
- [ ] Configure / generate CMake
- [ ] Create files (src/, include/) and list them in `Source.cmake`
- [ ] Build and fix errors
- [ ] Write documentation
- [ ] Update the changelog

### Order with Dependencies

```json
{
    "libraries": [
        { "name": "BaseLib" },           // 1. No dependencies
        { "name": "MiddleLib", "dependencies": ["BaseLib"] },  // 2.
        { "name": "TopLib", "dependencies": ["MiddleLib"] }    // 3.
    ],
    "executables": [
        { "name": "App", "dependencies": ["TopLib"] }  // 4. Uses everything
    ]
}
```

---

## 12. Pitfalls and Solutions

### 12.1 "Target does not exist"

**Problem:**
```
[E101] Dependency 'MyLib' for 'MyApp' does not exist
```

**Cause:** Library not defined in Solution.json, a typo, or a library comes before the library it
depends on in the `libraries` array.

**Solution:**
1. Check whether the library exists in the `libraries` array
2. Check the spelling (case-sensitive!)
3. If a library depends on another one: list it **after** its dependency in the `libraries` array

### 12.2 "Source files not found"

**Problem:**
```
[E001] Executable 'MyApp': Source path does not exist: projects/exec/MyApp/src
[E104] Source.cmake not found: /path/to/MyProject/projects/exec/MyApp/src/Source.cmake
```

**Cause:** The source directory is missing (E001), or it lacks the `Source.cmake` with the file
list (E104, default `sources.mode = "explicit"`). If `Source.cmake` lists no compilable file, the
build system warns with W101.

**Solution:**
1. Create the directory: `mkdir -p projects/exec/MyApp/src`
2. Create main.cpp and `Source.cmake` (§6.6)
3. Or specify an explicit `path` in Solution.json

### 12.3 "Include path not found"

**Problem:**
```
fatal error: 'CoreLib/Calculator.h' file not found
```

**Cause:** Library not listed in `dependencies`.

**Solution:**
```json
{
    "name": "MyApp",
    "dependencies": ["CoreLib"]  // ← Add this!
}
```

### 12.4 "CMake cache outdated"

**Problem:** Changes in Solution.json are not applied.

**Cause:** The CMake cache contains an old configuration.

**Solution:**
```bash
# Regenerate the cache
cmake --preset windows-ninja-debug-msvc --fresh
```

### 12.5 "Preset not found"

**Problem:**
```
CMake Error: Could not read presets: No such preset: "my-preset"
```

**Cause:** The preset does not exist, or a JSON syntax error.

**Solution:**
```bash
# Show available presets
cmake --list-presets

# Check the JSON syntax
cat CMakePresets.json | python -m json.tool
```

---

## 13. Troubleshooting

### Checklist for Build Problems

1. ☐ Solution.json syntax correct? (validate JSON)
2. ☐ All dependencies defined?
3. ☐ Paths exist?
4. ☐ CMake cache up to date? (`--fresh`)
5. ☐ Compiler installed and in PATH?
6. ☐ Preset exists? (`--list-presets`)

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| "[E101] Dependency … does not exist" | Dependency missing or listed too late | Add to `libraries`, check the order |
| "[E104] Source.cmake not found" | File list missing | Create `Source.cmake` (§6.6) |
| "[W101] … No source files found" / "defines no compilable files" | File list empty | List the files in `Source.cmake` |
| "file not found" | Include missing | Check `dependencies` |
| "undefined reference" | Linking error | `dependencies` or `externals` |
| "Preset not found" | Typo | `--list-presets` |

### Debug Tips

```bash
# Verbose CMake output
cmake --preset ... --debug-output

# More build-system messages (level 1–5, default 2; areas with their own level such as Externals stay at 3)
cmake --preset ... -DDEBUG_DEFAULT_LEVEL=3

# Show CMake variables
cmake -LAH out/build/windows-ninja-debug-msvc

# Show generated targets
cmake --build out/build/... --target help
```

---

## 14. Next Steps

### You Have Mastered the Basics! Continue With:

| Topic | Guide | What you learn |
|-------|-------|----------------|
| **External libraries** | [Externals UserGuide](Externals.md) | Integrating BASS, ImGui, spdlog |
| **Adding new externals** | [Adding_Externals UserGuide](Adding_Externals.md) | Writing your own hooks |
| **Testing** | [Testing UserGuide](Testing.md) | doctest, GoogleTest, Catch2 |
| **Qt6** | [Qt6_Integration UserGuide](Qt6_Integration.md) | Qt6 GUI applications |
| **User presets** | [CMakeUserPresets UserGuide](CMakeUserPresets.md) | Personal build configuration |

### Advanced Topics

- **Multi-platform builds** – Windows, Linux, macOS at the same time
- **CI/CD integration** – GitHub Actions, GitLab CI
- **Code quality** – clang-format, clang-tidy
- **Packaging** – creating installers with CPack

---

## 15. See Also

- [Solution_Schema.md](../references/Solution_Schema.md) – Complete JSON schema reference
- [Externals.md](../references/Externals.md) – All available externals
- [ErrorCodes.md](../references/ErrorCodes.md) – Error codes and solutions
- [CMakePresets_Reference.md](../references/CMakePresets.md) – Preset reference

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.1 | 2026-11-09 | Aligned with the code: consumption via `templates/consumer/` and `cmakecraft.pin` (§3.1, §4), `CMakeLists.txt` as a thin version with the required line `project(<Name> LANGUAGES NONE)`, `schemaVersion` `1.0`, default paths `projects/exec/…` and `projects/libs/…`, `Source.cmake` (explicit sources), output path `exec/<Name>/bin/<Config>/`, existing presets, error messages E001/E101/E104 instead of `[E0401]`, `settings.output` and `all_tests` removed |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| **0.5.0** | **2025-12-14** | **Initial: comprehensive getting-started guide for CMake Architecture** |
