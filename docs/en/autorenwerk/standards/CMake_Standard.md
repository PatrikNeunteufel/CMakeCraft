# CMake Standard — Overarching Build System Guidelines

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Standard  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Scope:** All CMake-based projects  
> **Enforcement:** Code review, CI  
> **Language:** English  
> **German:** [CMake_Standard.md](../../../de/autorenwerk/standards/CMake_Standard.md)

---

## Table of Contents

1. [Purpose and Scope](#1-purpose-and-scope)
2. [CMake Version and Policies](#2-cmake-version-and-policies)
3. [Project Structure](#3-project-structure)
4. [Naming Conventions](#4-naming-conventions)
5. [External Dependencies](#5-external-dependencies)
6. [Error and Logging Behavior](#6-error-and-logging-behavior)
7. [Presets](#7-presets)
8. [Tests and Tools](#8-tests-and-tools)
9. [Compiler Options](#9-compiler-options)
10. [Legacy Projects](#10-legacy-projects)
11. [Relationship to Other Standards](#11-relationship-to-other-standards)
12. [Checklist for New Projects](#12-checklist-for-new-projects)
13. [See Also](#13-see-also)
14. [Changelog](#changelog)

---

## 1. Purpose and Scope

This standard defines **minimum requirements and conventions** for all CMake-based projects.

### Target Audience

All developers who use CMake for build configuration. This standard is mandatory for new projects and recommended when modernizing existing projects.

### Area of Application

| Project Type | Applies to |
|--------------|------------|
| Modular build system | Solution.json, CMake modules |
| Simple projects | Standalone CMakeLists.txt |
| Prototypes | Minimal setup |

### Relationship to CMake Architecture

This standard is **superordinate** to the modular build system:
- CMake Architecture (Solution.json) follows this standard
- Standalone projects also follow this standard
- The standard defines the "what", the modules the "how"

---

## 2. CMake Version and Policies

### 2.1 Minimum Version

```cmake
cmake_minimum_required(VERSION 3.24 FATAL_ERROR)
project(ProjectName LANGUAGES C CXX)
```

| Requirement | Value |
|-------------|-------|
| Minimum version | **3.24** (or newer) |
| Deviations | Justify in the README |

### 2.2 Policies

| Rule | Description |
|------|-------------|
| Set implicitly | `cmake_policy(VERSION <min-version>)` |
| Explicit override | Only with a justifying comment |

---

## 3. Project Structure

### 3.1 Minimum Structure

```
<ProjectRoot>/
├── CMakeLists.txt          # Root: project(), options, add_subdirectory()
├── src/                    # Source files
├── include/                # (Optional) Public headers
├── tests/                  # (Optional) Tests
├── cmake/                  # (Optional) CMake modules
└── docs/                   # (Optional) Documentation
```

### 3.2 Root CMakeLists.txt

Contains **only**:
- `cmake_minimum_required()`
- `project()`
- Global options (`option()`)
- `add_subdirectory()` calls

**No** detailed configuration in the root.

### 3.3 Modern CMake (Target-Based)

```cmake
# ✅ Modern CMake
add_library(MyLib)

target_sources(MyLib PRIVATE
    src/MyLib.cpp
)

target_include_directories(MyLib PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_compile_features(MyLib PUBLIC
    cxx_std_20
)
```

### 3.4 Forbidden (Except Legacy)

| Command | Problem | Alternative |
|---------|---------|-------------|
| `include_directories()` | Global | `target_include_directories()` |
| `add_definitions()` | Global | `target_compile_definitions()` |
| `link_libraries()` | Global | `target_link_libraries()` |

---

## 4. Naming Conventions

### 4.1 Targets

| Target Type | Convention | Example |
|-------------|------------|---------|
| Library | Clearly recognizable | `CoreLib`, `AudioEngine` |
| Executable | Clearly recognizable | `MyApp`, `AudioPlayer` |
| Test | Suffix/prefix | `CoreLibTests`, `test_Audio` |

### 4.2 Options and Cache Variables

| Type | Convention | Example |
|------|------------|---------|
| Project option | `PROJECT_FEATURE` | `MYAPP_ENABLE_TESTS` |
| Cache variable | `UPPER_CASE` | `BUILD_SHARED_LIBS` |
| Internal variable | `_lower_case` | `_source_files` |

```cmake
option(MYAPP_ENABLE_TESTS "Enable test targets" ON)
set(MYAPP_EXTERNALS_DIR "${CMAKE_SOURCE_DIR}/externals" 
    CACHE PATH "Externals root directory")
```

### 4.3 Functions and Macros

| Type | Convention | Example |
|------|------------|---------|
| Project function | `project_snake_case` | `myapp_add_executable()` |
| Generic function | `module_snake_case` | `ctx_create()`, `json_get()` |

---

## 5. External Dependencies

### 5.1 Recommended Approach

```cmake
# ✅ Modern CMake with imported targets
find_package(ZLIB REQUIRED)
target_link_libraries(MyApp PRIVATE ZLIB::ZLIB)

find_package(SDL2 REQUIRED)
target_link_libraries(MyApp PRIVATE SDL2::SDL2)
```

### 5.2 Package Managers

| Manager | Integration |
|---------|-------------|
| vcpkg | Via toolchain file |
| Conan | Via toolchain file |

Do **not** hard-wire them in the CMake code.

### 5.3 Forbidden Hard-Coded Paths

```cmake
# ❌ Forbidden
set(VCPKG_ROOT "C:/dev/vcpkg")

# ✅ Allowed (in CMakeUserPresets.json)
# "CMAKE_TOOLCHAIN_FILE": "C:/dev/vcpkg/scripts/buildsystems/vcpkg.cmake"
```

---

## 6. Error and Logging Behavior

### 6.1 Error Handling

| Function | Usage |
|----------|-------|
| `message(FATAL_ERROR ...)` | Abort the build |
| `message(WARNING ...)` | Suspicious configuration |
| `message(STATUS ...)` | Informational |

Recommended: a project wrapper for consistent error codes:

```cmake
function(proj_fatal CODE MESSAGE)
    message(FATAL_ERROR "[${CODE}] ${MESSAGE}")
endfunction()
```

### 6.2 Error Format

```
[E101] Dependency 'CoreLib' for 'MyApp' does not exist
 ^      ^                                ^
 Code   Description                      Context
```

### 6.3 TODO Markers

For unfinished tasks or problems to be fixed: use `TODO` in the comment.

```cmake
# TODO: Add support for cross-compilation
# TODO: Optimize find_package calls
# TODO: Remove deprecated function after migration
```

---

## 7. Presets

### 7.1 CMakePresets.json

**Recommended** for new projects:

```json
{
    "version": 6,
    "configurePresets": [
        {
            "name": "debug",
            "displayName": "Debug",
            "generator": "Ninja",
            "binaryDir": "${sourceDir}/build/debug",
            "cacheVariables": {
                "CMAKE_BUILD_TYPE": "Debug"
            }
        }
    ]
}
```

### 7.2 Minimum Presets

| Preset | Purpose |
|--------|---------|
| `debug` | Local development |
| `release` | Release build |
| (Optional) CI presets | Automation |

### 7.3 User Presets

| File | Content | Git |
|------|---------|-----|
| `CMakePresets.json` | Team presets | ✅ Commit |
| `CMakeUserPresets.json` | Local paths | ❌ Gitignore |
| `CMakeUserPresets.example.json` | Template | ✅ Commit |

---

## 8. Tests and Tools

### 8.1 CTest Integration

```cmake
include(CTest)
enable_testing()

add_executable(MyTests test_main.cpp)
add_test(NAME MyTests COMMAND MyTests)
```

### 8.2 Static Analysis

| Language | Tool | Integration |
|----------|------|-------------|
| C++ | clang-format | IDE, pre-commit |
| C++ | clang-tidy | `CMAKE_CXX_CLANG_TIDY` |
| C | clang-tidy | PC build, cross-check |

```cmake
# In a preset or toolchain
set(CMAKE_CXX_CLANG_TIDY "clang-tidy;--config-file=${CMAKE_SOURCE_DIR}/.clang-tidy")
```

---

## 9. Compiler Options

### 9.1 Per Target (Not Global)

```cmake
# ✅ Per target
target_compile_options(MyApp PRIVATE
    $<$<CXX_COMPILER_ID:MSVC>:/W4>
    $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:-Wall -Wextra>
)

# ❌ Global
add_compile_options(/W4)
```

### 9.2 Generator Expressions

For platform-specific options:

```cmake
target_compile_definitions(MyApp PRIVATE
    $<$<PLATFORM_ID:Windows>:WIN32_LEAN_AND_MEAN>
)
```

---

## 10. Legacy Projects

### 10.1 Migration

- Modernize step by step
- Document deviations in the README
- Goal: Modern CMake

### 10.2 Documentation

For permanent deviations:
- Document the reason
- Minimize the scope

---

## 11. Relationship to Other Standards

| Standard | Governs |
|----------|---------|
| **CMake_Standard** (this document) | Build system conventions |
| Cpp_Coding_Standard | C++ code style |
| C_Coding_Standard | C code style (embedded) |
| ClangFormat_Blueprint | Formatting |
| ClangTidy_Blueprint | Static analysis |

---

## 12. Checklist for New Projects

- [ ] `cmake_minimum_required(VERSION 3.24)`
- [ ] `project()` with correct `LANGUAGES`
- [ ] Target-based configuration
- [ ] No global `include_directories()`
- [ ] No hard-coded paths
- [ ] CMakePresets.json present
- [ ] CMakeUserPresets.example.json present
- [ ] CTest enabled (if there are tests)

---

## 13. See Also

- [CMake.md](../blueprints/CMake.md) — CMake module structure
- [Cpp_Coding_Standard.md](Cpp_Coding_Standard.md) — C++ style
- [C_Coding_Standard.md](C_Coding_Standard.md) — C style
- [CMakePresets References](../../guide/references/CMakePresets.md) — Presets documentation

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.6.0 | 2025-12-19 | New: TODO markers (6.3) |
| 0.5.0 | 2025-12-13 | Migration to Blueprint v0.5: new header, table of contents, encoding fix |
| 0.1.0 | 2025-12-05 | Initial: Modern CMake, presets, target-based, naming conventions |
