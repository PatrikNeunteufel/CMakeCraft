# Future Enhancements — Planned Extensions

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Concept  
> **Status:** Collection  
> **Target Audience:** Build System Developers, Architects  
> **Language:** English  
> **German:** [Future_Enhancements.md](../../de/konzepte/Future_Enhancements.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [App Container Extensions](#2-app-container-extensions)
3. [Externals Extensions](#3-externals-extensions)
4. [Settings Extensions](#4-settings-extensions)
5. [Executable Extensions](#5-executable-extensions)
6. [Test Extensions](#6-test-extensions)
7. [Build System](#7-build-system)
8. [Tooling](#8-tooling)
9. [Project Structure](#9-project-structure)
10. [CI/CD](#10-cicd)
11. [Open Decisions](#11-open-decisions)
12. [See Also](#12-see-also)
13. [Changelog](#13-changelog)

---

## 1. Overview

This document collects possible **future extensions** for the CMake Architecture build system. The entries are grouped by area and rated by priority/complexity.

> **Note:** Features already decided on with their own concept document are not listed here. See [Section 12 (See Also)](#12-see-also) for finished concepts.

### 1.1 Legend

| Priority | Meaning |
|-----------|-----------|
| 🔴 High | Important for productivity/usability |
| 🟡 Medium | Nice-to-have, planned |
| 🟢 Low | Long-term, as needed |

| Complexity | Meaning |
|-------------|-----------|
| ⚪ Simple | < 1 day of effort |
| 🔵 Medium | 1-3 days of effort |
| 🟣 Complex | > 3 days of effort |

---

## 2. App Container Extensions

> **Base concept:** See [AppContainer_Concept.md](abgeschlossen/AppContainer_Concept.md)

### 2.1 Multiple Runners per App

> **Priority:** 🟢 Low  
> **Complexity:** 🔵 Medium  
> **When relevant:** CLI + GUI for the same app

**Description:**  
An app container with multiple entry points (e.g. GUI and CLI).

**Possible structure:**
```
projects/apps/AudioPlayer/
├── core/...
└── runners/
    ├── gui/main.cpp       → AudioPlayer.Gui
    └── cli/main.cpp       → AudioPlayer.Cli
```

---

### 2.2 Shared Core Library Option

> **Priority:** 🟢 Low  
> **Complexity:** 🔵 Medium  
> **When relevant:** Plugin architectures, DLL-based apps

**Description:**  
Option for `core.type: "SHARED"` instead of only STATIC.

---

## 3. Externals Extensions

> **Base concept:** See [System_Externals_Concept.md](abgeschlossen/System_Externals_Concept.md) for system packages

### 3.1 externalsPolicy (JSON Configuration)

> **Priority:** 🟢 Low  
> **Complexity:** 🔵 Medium  
> **When relevant:** Different projects with different fetch strategies

**Description:**  
Optional configuration in Solution.json for explicit control over the fetch behavior.

**Possible fields:**
```json
{
    "externalsPolicy": {
        "fetchRoot": ".externals",
        "updatePolicy": "checkout",
        "lockfile": true
    }
}
```

| Field | Default | Options |
|------|---------|----------|
| `fetchRoot` | `.externals` | Any path |
| `updatePolicy` | `checkout` | `checkout`, `always`, `never`, `update`, `locked` |
| `lockfile` | `false` | `true`, `false` |

**updatePolicy options:**

| Policy | Behavior |
|--------|-----------|
| `checkout` | Fetch only if not present (current behavior) |
| `always` | Always fetch anew |
| `never` | Never fetch, only use existing ones |
| `update` | Fetch + git pull on every configure |
| `locked` | Use exact commits from the lockfile |

---

### 3.2 Lockfile System

> **Priority:** 🟡 Medium  
> **Complexity:** 🟣 Complex  
> **When relevant:** Reproducible builds, team development, CI/CD

**Description:**  
Automatic tracking of which versions (commit hashes) are actually used.

**Format (externals.lock.json):**
```json
{
    "version": "1.0",
    "generated": "2025-12-10T10:30:00Z",
    "externals": {
        "glfw": {
            "git": "https://github.com/glfw/glfw.git",
            "tag": "3.4",
            "resolved_commit": "7b6aead9fb88b3623e3b3725ebb42670cfe4c5f9",
            "fetched_at": "2025-12-10T10:30:00Z"
        }
    }
}
```

**Planned CLI commands:**
```bash
cmake --lockfile-update     # Update the lockfile
cmake --lockfile-verify     # Check the lockfile against Solution.json
cmake --lockfile-freeze     # Pin all to resolved_commit
```

**Advantages:**
- Exact reproducibility
- Audit trail for dependency updates
- Detection of unintended changes
- CI/CD can guarantee identical builds

---

### 3.3 vcpkg Integration

> **Priority:** 🟡 Medium  
> **Complexity:** 🟣 Complex  
> **When relevant:** Use of vcpkg packages

**Description:**  
Support for vcpkg as an alternative to Git externals.

**Possible syntax:**
```json
{
    "externals": {
        "fmt": {
            "vcpkg": "fmt",
            "version": "10.1.1"
        },
        "boost-asio": {
            "vcpkg": "boost-asio",
            "features": ["ssl"]
        }
    }
}
```

---

### 3.4 Conan Integration

> **Priority:** 🟢 Low  
> **Complexity:** 🟣 Complex  
> **When relevant:** Conan preferred as package manager

**Description:**  
Similar to vcpkg, but for the Conan package manager.

**Possible syntax:**
```json
{
    "externals": {
        "spdlog": {
            "conan": "spdlog/1.12.0"
        }
    }
}
```

---

### 3.5 Submodule Support

> **Priority:** 🟢 Low  
> **Complexity:** ⚪ Simple  
> **When relevant:** Project uses Git submodules

**Description:**  
Automatic detection/initialization of Git submodules.

**Possible syntax:**
```json
{
    "externals": {
        "mylib": {
            "submodule": "libs/mylib"
        }
    }
}
```

---

## 4. Settings Extensions

### 4.1 Output Configuration

> **Priority:** 🟡 Medium  
> **Complexity:** 🔵 Medium

**Description:**  
Central configuration of the output directories.

```json
{
    "settings": {
        "output": {
            "bin_dir": "bin",
            "lib_dir": "lib",
            "archive_dir": "lib"
        }
    }
}
```

---

### 4.2 Quality Settings

> **Priority:** 🟡 Medium  
> **Complexity:** 🔵 Medium

**Description:**  
Central code quality control.

```json
{
    "settings": {
        "quality": {
            "clang_tidy": true,
            "clang_format": true,
            "warnings_as_errors": false,
            "sanitizers": ["address", "undefined"]
        }
    }
}
```

---

### 4.3 Packaging Metadata

> **Priority:** 🟢 Low  
> **Complexity:** ⚪ Simple

**Description:**  
CPack metadata for installer generation.

```json
{
    "settings": {
        "packaging": {
            "vendor": "My Company",
            "contact": "support@example.com",
            "license": "MIT",
            "homepage": "https://example.com"
        }
    }
}
```

---

### 4.4 Platform Requirements

> **Priority:** 🟢 Low  
> **Complexity:** 🟣 Complex

**Description:**  
Define minimum platform versions.

```json
{
    "settings": {
        "platform": {
            "min_windows_version": "10.0.19041",
            "min_macos_version": "11.0",
            "min_glibc_version": "2.31"
        }
    }
}
```

---

## 5. Executable Extensions

### 5.1 Additional Executable Types

> **Priority:** 🟢 Low  
> **Complexity:** 🔵-🟣 Varies

| Type | Description | Complexity |
|------|--------------|-------------|
| `TRAY` | System tray app | 🔵 Medium |
| `SERVICE` | OS service/daemon | 🟣 Complex |
| `BENCHMARK` | Benchmark runner | 🔵 Medium |
| `BUNDLE` | macOS app bundle | 🔵 Medium |

---

### 5.2 Custom Entry Point

> **Priority:** 🟢 Low  
> **Complexity:** ⚪ Simple

**Description:**  
Custom entry point function (WinMain, DllMain).

```json
{
    "executables": [{
        "name": "MyApp",
        "entrypoint": "WinMain"
    }]
}
```

---

### 5.3 Resources

> **Priority:** 🟡 Medium  
> **Complexity:** 🔵 Medium

**Description:**  
Win32 .rc files, macOS .icns/Info.plist integration.

```json
{
    "executables": [{
        "name": "MyApp",
        "resources": {
            "windows": "res/app.rc",
            "macos": {
                "icon": "res/app.icns",
                "plist": "res/Info.plist"
            }
        }
    }]
}
```

---

### 5.4 Visibility & Install

> **Priority:** 🟢 Low  
> **Complexity:** 🟣 Complex

**Description:**  
Packaging/export control for targets.

```json
{
    "executables": [{
        "name": "MyApp",
        "visibility": "public",
        "install": {
            "destination": "bin",
            "component": "runtime"
        }
    }]
}
```

---

## 6. Test Extensions

### 6.1 Test Fixtures

> **Priority:** 🟡 Medium  
> **Complexity:** 🟣 Complex

**Description:**  
CTest fixtures for setup/cleanup/requires.

```json
{
    "tests": [{
        "name": "IntegrationTests",
        "fixtures": {
            "setup": "StartDatabase",
            "cleanup": "StopDatabase",
            "requires": ["DatabaseRunning"]
        }
    }]
}
```

---

### 6.2 Parameterized Tests

> **Priority:** 🟢 Low  
> **Complexity:** 🔵 Medium

**Description:**  
Run tests with different parameters.

```json
{
    "tests": [{
        "name": "CrossPlatformTests",
        "parameters": {
            "backend": ["opengl", "vulkan", "d3d12"]
        }
    }]
}
```

---

## 7. Build System

### 7.1 Unity Builds

> **Priority:** 🟢 Low  
> **Complexity:** 🔵 Medium  
> **When relevant:** Extreme compile time optimization

**Description:**  
CMake UNITY_BUILD support for faster builds.

```json
{
    "settings": {
        "unity_build": {
            "enabled": true,
            "batch_size": 16
        }
    }
}
```

---

### 7.2 C++20 Modules

> **Priority:** 🟡 Medium  
> **Complexity:** 🟣 Complex  
> **When relevant:** C++20 module adoption

**Description:**  
Native support for C++20 modules (.ixx, .cppm).

---

### 7.3 Cross-Compilation Presets

> **Priority:** 🟢 Low  
> **Complexity:** 🔵 Medium  
> **When relevant:** Embedded, mobile, WebAssembly

**Description:**  
Predefined presets for cross-compilation.

---

## 8. Tooling

### 8.1 clang-format Auto-Fix

> **Priority:** 🔴 High  
> **Complexity:** ⚪ Simple  
> **When relevant:** Automatic code formatting

**Description:**  
Build target for automatic formatting (not just checking).

```bash
cmake --build . --target format-fix
```

---

### 8.2 clang-tidy Auto-Fix

> **Priority:** 🟡 Medium  
> **Complexity:** ⚪ Simple

**Description:**  
Build target for automatic clang-tidy fixes.

```bash
cmake --build . --target tidy-fix
```

---

### 8.3 Documentation Generation (Doxygen)

> **Priority:** 🟡 Medium  
> **Complexity:** 🔵 Medium

**Description:**  
Automatic Doxygen configuration and build target.

```json
{
    "documentation": {
        "doxygen": {
            "enabled": true,
            "output": "docs/api",
            "exclude": ["tests/", "externals/"]
        }
    }
}
```

---

### 8.4 Code Coverage

> **Priority:** 🟡 Medium  
> **Complexity:** 🔵 Medium

**Description:**  
Automatic coverage instrumentation and report generation.

```bash
cmake --build . --target coverage
```

---

## 9. Project Structure

### 9.1 Multi-Solution Support

> **Priority:** 🟢 Low  
> **Complexity:** 🟣 Complex  
> **When relevant:** Monorepo with several independent projects

**Description:**  
Support for multiple Solution.json files in one repository.

---

### 9.2 Solution Templates

> **Priority:** 🟢 Low  
> **Complexity:** 🔵 Medium

**Description:**  
Predefined templates for different project types.

```bash
cmake --init-solution --template console-app
cmake --init-solution --template gui-app
cmake --init-solution --template library
```

---

### 9.3 Workspace Support

> **Priority:** 🟢 Low  
> **Complexity:** 🟣 Complex

**Description:**  
A higher-level workspace file that orchestrates several solutions.

---

## 10. CI/CD

### 10.1 GitHub Actions Generator

> **Priority:** 🟡 Medium  
> **Complexity:** 🔵 Medium

**Description:**  
Automatic generation of GitHub Actions workflows based on presets.

```bash
cmake --generate-ci github
```

---

### 10.2 GitLab CI Generator

> **Priority:** 🟢 Low  
> **Complexity:** 🔵 Medium

---

### 10.3 Azure DevOps Generator

> **Priority:** 🟢 Low  
> **Complexity:** 🔵 Medium

---

## 11. Open Decisions

| Topic | Status | Options | Tendency |
|-------|--------|----------|---------|
| Git strategy for the lockfile | Open | Commit vs. .gitignore | Commit |
| Default test framework | Open | doctest vs googletest | doctest |

---

## 12. See Also

**Finished concepts (not in this document):**
- [AppContainer_Concept.md](abgeschlossen/AppContainer_Concept.md) — Phase 8: Testable app architecture
- [System_Externals_Concept.md](abgeschlossen/System_Externals_Concept.md) — Phase 9: System packages (Qt6, Boost, etc.)


**Architecture:**
- [Master_Concept.md](abgeschlossen/Master_Concept.md) — Architecture overview
- [Implementation_Plan.md](abgeschlossen/Implementation_Plan.md) — Phases 1-7

---

## 13. Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-14 | Blueprint v0.5.0 (Concept), concepts already decided on removed (app container base, system externals base), reference to separate concept documents |
| 0.2.0 | 2025-12-12 | App container (Phase 8), lockfile details, settings extensions |
| 0.1.0 | 2025-12-10 | Initial: externalsPolicy, lockfile, vcpkg, Conan, tooling |
