# CMake User Presets – User Guide

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Guide  
> **Status:** Stable  
> **Target Audience:** C++ developers  
> **Language:** English  
> **German:** [CMakeUserPresets_UserGuide.md](../../../de/guide/userguides/CMakeUserPresets.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Quick Start](#3-quick-start)
4. [Basics](#4-basics)
5. [Configure Presets](#5-configure-presets)
6. [Build Presets](#6-build-presets)
7. [Test Presets](#7-test-presets)
8. [Workflow Presets](#8-workflow-presets)
9. [Practical Scenarios](#9-practical-scenarios)
10. [Best Practices](#10-best-practices)
11. [Pitfalls and Solutions](#11-pitfalls-and-solutions)
12. [Troubleshooting](#12-troubleshooting)
13. [See Also](#13-see-also)

---

## 1. Overview

This guide explains how to configure your personal build environment with `CMakeUserPresets.json`.

### What Are User Presets?

| File | Purpose | Git |
|------|---------|-----|
| `CMakePresets.json` | Team-wide standards | ✅ Commit |
| `CMakeUserPresets.json` | **Personal** adjustments | ❌ In .gitignore |

### When to Use User Presets?

- **Local paths** – vcpkg, Qt, SDK installations
- **Performance** – adjust the number of build jobs
- **Experiments** – test new features without changing team presets
- **Environment variables** – Qt paths, toolchain configuration
- **Your own combinations** – combine team presets

### Advantages

- No conflicts with the team configuration
- Personal optimizations
- Fast switching between configurations
- IDE integration (Visual Studio, CLion, VS Code)

---

## 2. Prerequisites

### Checklist

- [ ] **CMake 3.21+** (for presets v4+)
- [ ] **CMakePresets.json** present (team presets)
- [ ] **CMakeUserPresets.json listed in .gitignore**
- [ ] **IDE** with preset support (optional)

### Check .gitignore

```bash
# Check whether it is listed
grep CMakeUserPresets .gitignore

# If not, add it
echo "CMakeUserPresets.json" >> .gitignore
```

### Check the CMake Version

```bash
cmake --version
# Minimum: 3.21 for presets v4
# Recommended: 3.25+ for presets v6
```

---

## 3. Quick Start

### 3.1 Create the File

Create `CMakeUserPresets.json` in the project root:

```json
{
    "version": 6,
    "configurePresets": [
        {
            "name": "my-debug",
            "displayName": "Mein Debug Build",
            "inherits": "windows-ninja-debug-msvc",
            "cacheVariables": {
                "BUILD_TESTS": "ON"
            }
        }
    ]
}
```

### 3.2 Use the Preset

```bash
# Show available presets
cmake --list-presets

# Use your preset
cmake --preset my-debug

# Build
cmake --build out/build/my-debug
```

### 3.3 Use in an IDE

**Visual Studio 2022:**
- Open the project folder
- Select the preset from the dropdown (toolbar)

**CLion:**
- Settings → Build → CMake
- Enable "Load CMake presets"

**VS Code:**
- Install the CMake Tools extension
- Cmd+Shift+P → "CMake: Select Configure Preset"

---

## 4. Basics

### 4.1 File Structure

```json
{
    "version": 6,
    "vendor": {
        "user-presets": {
            "version": "0.1.0",
            "author": "Dein Name",
            "lastModified": "2025-12-14"
        }
    },
    "configurePresets": [],
    "buildPresets": [],
    "testPresets": [],
    "packagePresets": [],
    "workflowPresets": []
}
```

### 4.2 Version

| Version | CMake | Features |
|---------|-------|----------|
| 4 | 3.21+ | Basic presets |
| 5 | 3.24+ | Package presets |
| 6 | 3.25+ | Workflow presets, include |

**Recommendation:** Use version 6.

### 4.3 Inheritance (inherits)

```json
{
    "name": "my-preset",
    "inherits": ["windows-ninja-debug-msvc", "with-vcpkg"],
    "cacheVariables": {
        "MY_OPTION": "ON"
    }
}
```

- Inherits all settings from the parent
- Your own values override parent values
- Multiple parents possible (array)

### 4.4 Hidden Presets

```json
{
    "name": "my-base",
    "hidden": true,
    "cacheVariables": {
        "VCPKG_ROOT": "C:/Dev/vcpkg"
    }
}
```

- Not visible in `--list-presets`
- Intended only for inheritance
- Ideal for path definitions

---

## 5. Configure Presets

### 5.1 Basic Structure

```json
{
    "configurePresets": [
        {
            "name": "my-config",
            "displayName": "Meine Konfiguration",
            "description": "Debug mit meinen Einstellungen",
            "inherits": "windows-ninja-debug-msvc",
            "generator": "Ninja",
            "binaryDir": "${sourceDir}/out/build/${presetName}",
            "cacheVariables": {
                "CMAKE_BUILD_TYPE": "Debug",
                "BUILD_TESTS": "ON"
            },
            "environment": {
                "QT_ROOT": "C:/Qt/6.7.0/msvc2022_64"
            }
        }
    ]
}
```

### 5.2 Important Fields

| Field | Description |
|-------|-------------|
| `name` | Unique identifier (for the CLI) |
| `displayName` | Display name (for the IDE) |
| `inherits` | Parent preset(s) |
| `generator` | CMake generator |
| `binaryDir` | Build directory |
| `cacheVariables` | CMake cache variables |
| `environment` | Environment variables |

### 5.3 Setting Environment Variables

```json
{
    "name": "with-qt",
    "hidden": true,
    "environment": {
        "QT_ROOT": "C:/Qt/6.7.0/msvc2022_64",
        "PATH": "$env{QT_ROOT}/bin;$env{PATH}"
    }
}
```

**Variable references:**
- `$env{VAR}` – environment variable
- `$penv{VAR}` – parent environment variable
- `${sourceDir}` – project root
- `${presetName}` – preset name

### 5.4 Conditions

```json
{
    "name": "windows-only",
    "condition": {
        "type": "equals",
        "lhs": "${hostSystemName}",
        "rhs": "Windows"
    }
}
```

---

## 6. Build Presets

### 6.1 Basic Structure

```json
{
    "buildPresets": [
        {
            "name": "my-build",
            "displayName": "Schneller Build",
            "configurePreset": "my-config",
            "configuration": "Debug",
            "jobs": 16,
            "targets": ["MyApp", "CoreLib"]
        }
    ]
}
```

### 6.2 Important Fields

| Field | Description |
|-------|-------------|
| `configurePreset` | Associated configure preset |
| `configuration` | Debug/Release (multi-config) |
| `jobs` | Number of parallel jobs |
| `targets` | Build only specific targets |
| `cleanFirst` | Clean before build |

### 6.3 Examples

**Fast build:**
```json
{
    "name": "fast",
    "configurePreset": "my-config",
    "jobs": 32
}
```

**Specific targets only:**
```json
{
    "name": "app-only",
    "configurePreset": "my-config",
    "targets": ["MyApp"]
}
```

**Clean build:**
```json
{
    "name": "clean-build",
    "configurePreset": "my-config",
    "cleanFirst": true
}
```

---

## 7. Test Presets

### 7.1 Basic Structure

```json
{
    "testPresets": [
        {
            "name": "my-tests",
            "displayName": "Meine Tests",
            "configurePreset": "my-config",
            "configuration": "Debug",
            "output": {
                "outputOnFailure": true,
                "verbosity": "verbose"
            },
            "filter": {
                "include": {
                    "label": "unit"
                }
            }
        }
    ]
}
```

### 7.2 Filter

```json
{
    "filter": {
        "include": {
            "label": "unit",
            "name": "CoreLib.*"
        },
        "exclude": {
            "label": "slow"
        }
    }
}
```

### 7.3 Execution

```json
{
    "execution": {
        "jobs": 8,
        "timeout": 120,
        "stopOnFailure": false
    }
}
```

---

## 8. Workflow Presets

### 8.1 Basic Structure

Workflow presets combine configure → build → test → package:

```json
{
    "workflowPresets": [
        {
            "name": "full-cycle",
            "displayName": "Kompletter Build-Zyklus",
            "steps": [
                { "type": "configure", "name": "my-config" },
                { "type": "build", "name": "my-build" },
                { "type": "test", "name": "my-tests" }
            ]
        }
    ]
}
```

### 8.2 Usage

```bash
cmake --workflow --preset full-cycle
```

### 8.3 Release Workflow

```json
{
    "name": "release",
    "displayName": "Release Build",
    "steps": [
        { "type": "configure", "name": "release-config" },
        { "type": "build", "name": "release-build" },
        { "type": "test", "name": "all-tests" },
        { "type": "package", "name": "installer" }
    ]
}
```

---

## 9. Practical Scenarios

### 9.1 Qt6 Environment

```json
{
    "version": 6,
    "configurePresets": [
        {
            "name": "qt-env",
            "hidden": true,
            "environment": {
                "QT_ROOT": "C:/Qt/6.7.0/msvc2022_64"
            }
        },
        {
            "name": "my-qt-debug",
            "displayName": "Debug mit Qt6",
            "inherits": ["windows-ninja-debug-msvc", "qt-env"]
        },
        {
            "name": "my-qt-release",
            "displayName": "Release mit Qt6",
            "inherits": ["windows-ninja-release-msvc", "qt-env"]
        }
    ]
}
```

### 9.2 vcpkg Integration

```json
{
    "version": 6,
    "configurePresets": [
        {
            "name": "with-vcpkg",
            "hidden": true,
            "cacheVariables": {
                "CMAKE_TOOLCHAIN_FILE": "C:/Dev/vcpkg/scripts/buildsystems/vcpkg.cmake",
                "VCPKG_TARGET_TRIPLET": "x64-windows"
            }
        },
        {
            "name": "my-debug-vcpkg",
            "displayName": "Debug + vcpkg",
            "inherits": ["windows-ninja-debug-msvc", "with-vcpkg"]
        }
    ]
}
```

### 9.3 Fast Development

```json
{
    "version": 6,
    "configurePresets": [
        {
            "name": "dev-fast",
            "displayName": "Schnelle Entwicklung",
            "inherits": "windows-ninja-debug-msvc",
            "cacheVariables": {
                "BUILD_TESTS": "OFF",
                "BUILD_ONLY": "MyApp"
            }
        }
    ],
    "buildPresets": [
        {
            "name": "dev-build",
            "configurePreset": "dev-fast",
            "jobs": 16
        }
    ]
}
```

### 9.4 Sanitizer Builds (Linux/macOS)

```json
{
    "version": 6,
    "configurePresets": [
        {
            "name": "with-asan",
            "displayName": "AddressSanitizer",
            "inherits": "linux-gcc-debug",
            "cacheVariables": {
                "CMAKE_CXX_FLAGS": "-fsanitize=address -fno-omit-frame-pointer",
                "CMAKE_EXE_LINKER_FLAGS": "-fsanitize=address"
            }
        },
        {
            "name": "with-ubsan",
            "displayName": "UndefinedBehaviorSanitizer",
            "inherits": "linux-gcc-debug",
            "cacheVariables": {
                "CMAKE_CXX_FLAGS": "-fsanitize=undefined",
                "CMAKE_EXE_LINKER_FLAGS": "-fsanitize=undefined"
            }
        }
    ]
}
```

### 9.5 Complete Example

```json
{
    "version": 6,
    "vendor": {
        "user-presets": {
            "version": "0.1.0",
            "author": "Max Mustermann",
            "lastModified": "2025-12-14",
            "description": "Persönliche Entwicklungs-Presets"
        }
    },

    "configurePresets": [
        {
            "name": "qt-env",
            "hidden": true,
            "environment": {
                "QT_ROOT": "C:/Qt/6.7.0/msvc2022_64"
            }
        },
        {
            "name": "vcpkg-env",
            "hidden": true,
            "cacheVariables": {
                "CMAKE_TOOLCHAIN_FILE": "C:/Dev/vcpkg/scripts/buildsystems/vcpkg.cmake"
            }
        },
        {
            "name": "my-dev",
            "displayName": "Meine Entwicklungsumgebung",
            "description": "Debug mit Qt und vcpkg",
            "inherits": ["windows-ninja-debug-msvc", "qt-env", "vcpkg-env"],
            "cacheVariables": {
                "BUILD_TESTS": "ON"
            }
        },
        {
            "name": "my-release",
            "displayName": "Mein Release Build",
            "inherits": ["windows-ninja-release-msvc", "qt-env", "vcpkg-env"]
        }
    ],

    "buildPresets": [
        {
            "name": "dev-fast",
            "displayName": "Schneller Dev-Build",
            "configurePreset": "my-dev",
            "jobs": 16
        },
        {
            "name": "release-full",
            "displayName": "Vollständiger Release",
            "configurePreset": "my-release",
            "jobs": 8
        }
    ],

    "testPresets": [
        {
            "name": "unit-only",
            "displayName": "Nur Unit Tests",
            "configurePreset": "my-dev",
            "output": { "outputOnFailure": true },
            "filter": {
                "include": { "label": "unit" }
            }
        }
    ],

    "workflowPresets": [
        {
            "name": "dev-cycle",
            "displayName": "Entwicklungs-Zyklus",
            "steps": [
                { "type": "configure", "name": "my-dev" },
                { "type": "build", "name": "dev-fast" },
                { "type": "test", "name": "unit-only" }
            ]
        }
    ]
}
```

---

## 10. Best Practices

### ✅ Do's

- **Maintain the vendor block** – keep version and date up to date
- **Meaningful names** – `displayName` for the IDE display
- **Hidden presets** – for reusable building blocks
- **Inherit from team presets** – do not copy!
- **Clean up regularly** – remove unused presets

### ❌ Don'ts

- **No absolute paths** without `hidden: true`
- **Do not override team presets** – use your own names
- **No sensitive data** – passwords, API keys
- **Do not commit** – must be in .gitignore!
- **No complex logic** – use CMake modules for that

### Naming Conventions

```
my-*          → Personal presets
with-*        → Feature building blocks (hidden)
dev-*         → Development presets
test-*        → Test configurations
```

---

## 11. Pitfalls and Solutions

### 11.1 Preset Not Visible

**Problem:** The preset does not appear in `--list-presets`.

**Cause:** `hidden: true` set or a JSON error.

**Solution:**
```bash
# All presets (including hidden)
cmake --list-presets=all

# Validate JSON
cat CMakeUserPresets.json | python -m json.tool
```

### 11.2 Inheritance Does Not Work

**Problem:** Settings from the parent are not applied.

**Cause:** Usually the order: if several parents provide the same field, the value of the
**first** entry in `inherits` applies; a field in the preset itself overrides all parents. The form,
on the other hand, is not an error — `inherits` may be a string (one parent) or an array
(CMake documentation `cmake-presets(7)`, field `inherits`).

**Solution:**
```json
// Both valid and equivalent
"inherits": "windows-ninja-debug-msvc"
"inherits": ["windows-ninja-debug-msvc"]

// For identical fields the earlier parent wins: here qt-env before with-vcpkg
"inherits": ["windows-ninja-debug-msvc", "qt-env", "with-vcpkg"]
```

If a value has no effect, move the parent that should set it further forward, or set the field in
the preset itself.

### 11.3 Environment Variable Not Set

**Problem:** `$env{QT_ROOT}` is empty.

**Cause:** Variable in the wrong section or not defined.

**Solution:**
```json
{
    "name": "with-qt",
    "hidden": true,
    "environment": {
        "QT_ROOT": "C:/Qt/6.7.0/msvc2022_64"
    }
},
{
    "name": "my-debug",
    "inherits": ["windows-ninja-debug-msvc", "with-qt"]
    // QT_ROOT is now available
}
```

### 11.4 Paths with Backslashes

**Problem:** Windows paths with `\` do not work.

**Cause:** The backslash is the JSON escape character.

**Solution:**
```json
// ❌ Wrong
"QT_ROOT": "C:\Qt\6.7.0"

// ✅ Correct (forward slashes)
"QT_ROOT": "C:/Qt/6.7.0"

// ✅ Alternative (escaped)
"QT_ROOT": "C:\\Qt\\6.7.0"
```

### 11.5 Incompatible Preset Version

**Problem:** `CMake Error: Preset version X requires CMake Y`.

**Cause:** CMake version too old for the preset version.

**Solution:**
1. Update CMake, or
2. Reduce the preset version:
```json
{
    "version": 4  // Instead of 6
}
```

---

## 12. Troubleshooting

### Checklist for Problems

1. ☐ JSON syntax correct? (`python -m json.tool`)
2. ☐ Preset name unique?
3. ☐ `inherits` order correct (first parent wins)?
4. ☐ Parent preset exists?
5. ☐ CMake version sufficient?
6. ☐ Paths correct (forward slashes)?
7. ☐ Listed in .gitignore?

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| "No such preset" | Typo / hidden | Check the name |
| "Invalid JSON" | Syntax error | Validate JSON |
| "Preset requires CMake X" | Version too old | Update CMake |
| "Cannot find inherited preset" | Parent missing | Check `inherits` |
| Env variable empty | Wrong section | Set in `environment` |

### Debug Commands

```bash
# Show all presets
cmake --list-presets=all

# Preset details
cmake --preset my-debug --debug-output

# Validate JSON
python -m json.tool < CMakeUserPresets.json

# Show the effective configuration
cmake -LAH out/build/my-debug
```

---

## 13. See Also

- [CMakePresets_Reference.md](../references/CMakePresets.md) – Team presets reference
- [CMakeUserPresets_Reference.md](../references/CMakeUserPresets.md) – User presets reference
- [Qt6_Integration_UserGuide.md](Qt6_Integration.md) – Configuring the Qt6 environment
- [Getting_Started_UserGuide.md](Getting_Started.md) – Project basics

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.1 | 2026-11-09 | Aligned with the code: §11.2 — `inherits` as a string is valid (CMake documentation `cmake-presets(7)`); the cause is the order of the parents; checklist §12 accordingly; base presets switched to existing names (`windows-ninja-debug-msvc`, `windows-ninja-release-msvc`, `linux-gcc-debug`) |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| **0.5.0** | **2025-12-14** | **Blueprint v0.5.0 conformance: extended with workflow presets, practical scenarios, pitfalls/troubleshooting** |
| 0.1.0 | 2025-12-03 | Initial: templates, example scenarios, best practices |
