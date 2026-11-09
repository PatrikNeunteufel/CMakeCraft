# Solution Schema — Reference

> **Version:** 1.0.7  
> **Solution Schema Version:** 1.0  
> **Date:** 2026-11-09  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Solution_Schema.md](../../../de/guide/references/Solution_Schema.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Conventions](#2-conventions)
3. [solution Block](#3-solution-block)
4. [settings Block](#4-settings-block)
5. [externals Block](#5-externals-block)
6. [executables Array](#6-executables-array)
7. [libraries Array](#7-libraries-array)
8. [tests Array](#8-tests-array)
9. [apps Array](#9-apps-array)
10. [Quick Reference](#10-quick-reference)
11. [Complete Example](#11-complete-example)
12. [Error Codes](#12-error-codes)
13. [See Also](#13-see-also)
14. [Changelog](#14-changelog)

---

## 1. Overview

This reference describes the complete schema of Solution.json for the CMake Architecture build system. Solution.json is the heart of the declarative configuration.

### Root-Level Structure

```json
{
    "schemaVersion": "1.0",
    "solution": { },
    "settings": { },
    "externalsPolicy": { },
    "externals": { },
    "libraries": [ ],
    "executables": [ ],
    "tests": [ ],
    "apps": [ ],
    "packages": [ ]
}
```

### Block Overview

| Block | Required | Description |
|-------|----------|-------------|
| `schemaVersion` | ✅ | Version of the JSON schema (MAJOR.MINOR only) |
| `solution` | ✅ | Metadata (name, version, authors) |
| `settings` | – | Global build settings |
| `externalsPolicy` | – | External behavior |
| `externals` | – | Central external definitions |
| `libraries` | – | Internal libraries |
| `executables` | – | Executable programs |
| `tests` | – | Test targets |
| `apps` | – | App containers (Core/Runner separation) |
| `packages` | – | Build packages: target `package_<name>` (see [Packages.md](Packages.md)) |

---

## 2. Conventions

### Symbols

| Symbol | Meaning |
|--------|---------|
| ✅ | Required field |
| – | Optional / default |

### Path Conventions

All paths are relative to `CMAKE_SOURCE_DIR` (project root).

### Environment Variables

Syntax: `${VAR_NAME}` is expanded to `$ENV{VAR_NAME}`.

```json
"hint": "${QT_ROOT}"        // → C:/Qt/6.10.1/msvc2022_64
"hint": "${HOME}/Qt/6.10.1" // → /home/user/Qt/6.10.1
```

---

## 3. solution Block

```json
"solution": {
    "name": "MySolution",
    "version": "1.0.0",
    "description": "Beschreibung",
    "authors": ["Name"]
}
```

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `name` | ✅ | string | Project name (→ PROJECT_NAME) |
| `version` | ✅ | string | Semantic version (MAJOR.MINOR.PATCH) |
| `description` | – | string | Description for IDEs/documentation |
| `authors` | – | string[] | List of authors |

---

## 4. settings Block

```json
"settings": {
    "standards": {
        "cxx_standard": 20,
        "cxx_standard_required": true,
        "cxx_extensions": false
    },
    "defaults": {
        "library_type": "STATIC",
        "executable_type": "CONSOLE"
    },
    "sources": {
        "mode": "auto"
    },
    "msvc": {
        "parallel_compile": 8
    }
}
```

### 4.1 standards

| Field | Default | Description |
|-------|---------|-------------|
| `cxx_standard` | 20 | C++ standard (11, 14, 17, 20, 23) |
| `cxx_standard_required` | true | Enforce the standard |
| `cxx_extensions` | false | Compiler extensions |

### 4.2 defaults

| Field | Default | Description |
|-------|---------|-------------|
| `library_type` | `"STATIC"` | Default library type |
| `executable_type` | `"CONSOLE"` | Default executable type |

### 4.3 sources

| Field | Default | Description |
|-------|---------|-------------|
| `mode` | `"auto"` | Source collection (explicit, glob, auto) |

### 4.4 msvc

Settings seen only by the MSVC compiler (`cl.exe`) — clang-cl, Clang and GCC are not affected.
Since CMakeCraft v0.12.0.

| Field | Default | Description |
|-------|---------|-------------|
| `parallel_compile` | 8 | Number of parallel compiler processes per target (`/MP<n>`). `0` or `1` = off. Integer ≥ 0, otherwise E004 |

`parallel_compile` applies to every target CMakeCraft creates: libraries, executables, apps
(Core, Runner and `tests.targets[]`) and tests. There is no per-target field. `/MP` takes effect
under the Visual Studio generators: otherwise MSBuild compiles the files of a target one after
another on a single core. Ninja starts its own compiler per file anyway.
If a target cannot handle `/MP` (`#import`, `/Gm`), `"parallel_compile": 0` switches it off for
the solution.

---

## 5. externals Block

The central place for all external definitions.

### 5.1 External Types

| Type | Identifying Feature | Description |
|------|---------------------|-------------|
| **Local** | `path` field | Precompiled libraries in `externals/` |
| **Fetched** | `git` field | Cloned via Git |
| **System** | `system: true` | Large external installations (Qt6, Boost) via find_package() |
| **Archive** | `archive: true` | Prebuilt package in a pinned version (archive with checksum) |

> **Type priority:** `system` → `git` → `path` → `archive`

### 5.2 Local Externals
```json
"externals": {
    "bass": {
        "path": "externals/bass"
    }
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `path` | ✅ | Path relative to CMAKE_SOURCE_DIR |
| `include` | — | Path to the Include.cmake (optional) |

#### Include.cmake Convention

**Default path (convention over configuration):**

```markdown
cmake/externals/includes/{name}/Include.cmake
```
Where `{name}` is the external key (e.g. `bass`, `lua54`).

**Examples:**

| External | Convention Path |
|----------|-----------------|
| `"bass": {...}` | `cmake/externals/includes/bass/Include.cmake` |
| `"lua54": {...}` | `cmake/externals/includes/lua54/Include.cmake` |
| `"doctest": {...}` | `cmake/externals/includes/doctest/Include.cmake` |

**Custom include (optional):**

Use only when the default has to be overridden:
```json
"externals": {
    "mylib": {
        "path": "externals/mylib",
        "include": "cmake/custom/mylib_special.cmake"
    }
}
```

> **Recommendation:** Always use the convention. Use the `include` field only for special cases.

### 5.3 Fetched Externals

```json
"externals": {
    "spdlog": {
        "git": "https://github.com/gabime/spdlog.git",
        "tag": "v1.12.0",
        "shallow": true,
        "cmakeSupport": true
    }
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `git` | ✅ | Repository URL |
| `tag` | – | Git tag or branch |
| `commit` | – | Specific commit hash |
| `shallow` | – | Shallow clone (default: true) |
| `cmakeSupport` | – | Has a CMakeLists.txt (default: true) |
| `hooks.preFetch` | – | Path to the PreFetch hook (object `hooks`, relative to CMAKE_SOURCE_DIR) |
| `hooks.postFetch` | – | Path to the PostFetch hook (object `hooks`, relative to CMAKE_SOURCE_DIR) |
| `hook` | – | Hook reuse |

### 5.4 System Externals (Phase 9)

For large, externally installed libraries such as Qt6, Boost, OpenCV.

**No local copy needed** – uses `find_package()` directly.

```json
"externals": {
    "qt6": {
        "system": true,
        "package": "Qt6",
        "version": "6.5.0",
        "components": ["Core", "Widgets", "Gui", "OpenGL"],
        "hints": ["${QT_ROOT}", "C:/Qt/6.10.1/msvc2022_64"],
        "backup": "E:/Backup/Qt/6.10.1/msvc2022_64",
        "required": true
    }
}
```

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `system` | ✅ | boolean | Must be `true` |
| `package` | ✅ | string | Name for find_package() (e.g. "Qt6", "Boost") |
| `version` | – | string | Minimum version, passed unchanged to find_package() (e.g. "6.5.0"; no comparison operator) |
| `components` | – | string[] | find_package() COMPONENTS |
| `hints` | – | string[] | Additional search paths |
| `backup` | – | string | Fallback path (triggers W501) |
| `required` | – | boolean | Package must be found, otherwise E503/E504/E505 (default: true); `find_package()` always runs without `REQUIRED` |

#### Path Resolution (Order)

1. **Environment variables:** `Qt6_ROOT`, `QT_ROOT`, `Qt6_DIR`, etc.
2. **hints[]** from Solution.json (with `${VAR}` expansion)
3. **Standard paths** from the package hook (platform-specific)
4. **backup** path (with W501 warning)
5. **find_package() default** (CMake's own search)

#### Package Hooks

Optional platform-specific configuration in:
```
cmake/externals/system/packages/{Package}.cmake
```

Predefined hooks:
- `Qt6.cmake` – standard installation paths, AUTOMOC/AUTOUIC/AUTORCC, windeployqt
- `Boost.cmake` – standard paths, disabling MSVC auto-linking

#### Migration from Local to System

**Before (workaround with an empty folder):**
```json
"qt6": {
    "path": "externals/qt6",
    "options": { "hint": "${QT_ROOT}" }
}
```

**After (no local folder needed):**
```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "hints": ["${QT_ROOT}"]
}
```

### 5.5 cmakeSupport Flag

| Value | Meaning | Hook Requirement |
|-------|---------|------------------|
| `true` (default) | External has a CMakeLists.txt | PostFetch optional |
| `false` | No CMakeLists.txt | PostFetch **REQUIRED** |

### 5.6 hook Field (Hook Reuse)

```json
"externals": {
    "imgui": {
        "git": "https://github.com/ocornut/imgui.git",
        "tag": "v1.91.6",
        "cmakeSupport": false
    },
    "imgui_docking": {
        "git": "https://github.com/ocornut/imgui.git",
        "tag": "v1.91.6-docking",
        "cmakeSupport": false,
        "hook": "imgui"
    }
}
```

| External | Hook File | `HOOK_EXTERNAL_NAME` | Target |
|----------|-----------|----------------------|--------|
| `imgui` | `imgui.cmake` | `"imgui"` | `imgui` |
| `imgui_docking` | `imgui.cmake` | `"imgui_docking"` | `imgui_docking` |

---

### 5.7 Common Fields (All Types)

These fields work for local, fetched and system externals:

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `skip` | bool | `false` | Skip the external (do not load it) |

#### skip (Disable an External)

With `skip: true` an external can be prepared without loading it:

```json
"externals": {
    "bass": {
        "path": "externals/bass"
    },
    "future_feature": {
        "git": "https://github.com/example/future.git",
        "tag": "v1.0.0",
        "skip": true
    },
    "optional_qt": {
        "system": true,
        "package": "Qt6",
        "components": ["Core", "Widgets"],
        "skip": true
    }
}
```

**Behavior:**
- The external is not loaded (no FetchContent, no find_package, no include)
- It is still validated in the externals block
- **FATAL ERROR (E013)** if a skipped external is used by a target

**Use cases:**
- Preparing externals for later features
- Temporarily disabling optional dependencies
- Platform-specific externals (manually or via preset)

---

### 5.8 Archive Externals (since v0.10.0)

A prebuilt package (headers, runtime files, tools) in a pinned version. Nothing is linked:
targets get an include path, a define and — for executables — the runtime files next to the
executable.

```json
"externals": {
    "sichttest": {
        "archive": true,
        "pin": "sichttest.pin",
        "platforms": ["windows"],
        "include_dirs": ["include"],
        "define": "SICHTTEST_VORHANDEN",
        "runtime": { "files": ["bin/SichttestSteuerung1.dll"], "dirs": ["sichttest"] }
    }
}
```

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `archive` | ✅ | boolean | Must be `true` |
| `pin` | ✅ | string | Pin file (version, address, checksum, fallback paths) |
| `platforms` | – | string[] | Platform filter; elsewhere the external is absent without a warning |
| `include_dirs` | – | string[] | Include folders inside the package |
| `define` | – | string | Define `<name>=1` on the target |
| `runtime` | – | object | `files` and `dirs` copied next to each executable (on every build, via the target `<executable>_deploy_<external>`) |

Can be switched off per target: `"external_options": { "sichttest": { "runtime": false } }`.
If the package cannot be obtained, W304 is issued and the targets build without it.

Pin file, order of sources and the `packages` block for building packages:
[Packages.md](Packages.md).

---

## 6. executables Array

```json
"executables": [
    {
        "name": "MyApp",
        "displayName": "My Application",
        "version": "1.0.0",
        "type": "GUI",
        "path": "projects/apps/MyApp/src",
        "skip": false,
        "dependencies": ["CoreLib"],
        "externals": ["qt6", "spdlog"],
        "external_options": {
            "bass": { "BASS_FLAC": true }
        }
    }
]
```

### 6.1 Required Fields

| Field | Description |
|-------|-------------|
| `name` | Unique target name |

### 6.2 Optional Fields

| Field | Default | Description |
|-------|---------|-------------|
| `displayName` | `name` | Display name |
| `version` | solution version | Executable version |
| `type` | `CONSOLE` | `CONSOLE`, `GUI`, `WORKER` |
| `path` | `projects/exec/{name}/src` | Source directory |
| `skip` | `false` | Skip the build |
| `pch` | – | Precompiled headers config (see [§ 6.5](#65-pch-object-precompiled-headers)) |
| `dependencies` | `[]` | Internal libraries |
| `externals` | `[]` | External references |
| `external_options` | `{}` | Per-external options |
| `platforms` | `[]` (all) | Platform filter |
| `defines` | `[]` | Preprocessor definitions; `{version}` is replaced by the version of the target |
| `compile_options` | `[]` | Compiler flags |
| `link_options` | `[]` | Linker flags |

### 6.3 type Values

| Type | Windows | macOS | Linux |
|------|---------|-------|-------|
| `CONSOLE` | Normal | Normal | Normal |
| `GUI` | WIN32 | MACOSX_BUNDLE | Normal |
| `WORKER` | Normal | Normal | Normal |

### 6.4 external_options

Per-target options for externals:

```json
"external_options": {
    "bass": {
        "BASS_FLAC": true,
        "BASS_FX": true
    }
}
```

### 6.5 pch Object (Precompiled Headers)

```json
"pch": {
    "enabled": true,
    "header": "stdafx.h",
    "path": "common/pch"
}
```

| Field | Default | Description |
|-------|---------|-------------|
| `enabled` | `false` | Enable PCH |
| `header` | `pch.h` | Name of the PCH file |
| `path` | – | Custom path (relative to `projects/`) |

**Activation (implicit):**

PCH is enabled automatically if:
- `enabled: true` is set explicitly, OR
- `header` is given and `enabled` is not `false`, OR
- `path` is given and `enabled` is not `false`

**Search path priority** (if `path` is not given):

| Priority | Path |
|----------|------|
| 1 | `{target-path}/pch/{header}` |
| 2 | `{target-path}/src/{header}` |
| 3 | `{target-path}/{header}` |

If `path` is given: `projects/{path}/{header}`

---

## 7. libraries Array

```json
"libraries": [
    {
        "name": "CoreLib",
        "version": "1.0.0",
        "type": "STATIC",
        "path": "projects/libs/CoreLib/src",
        "public_headers": "projects/libs/CoreLib/include",
        "dependencies": ["UtilsLib"],
        "externals": ["bass"],
        "external_options": {
            "bass": {
                "BASS_FLAC": true
            }
        }
    }
]
```

| Field | Default | Description |
|-------|---------|-------------|
| `name` | ✅ required | Target name |
| `version` | solution version | Library version |
| `type` | settings default | `STATIC`, `SHARED`, `INTERFACE` |
| `path` | convention | Source directory |
| `public_headers` | – | Public include directory |
| `output_name` | target name | File name without extension (since v0.10.0) |
| `defines` | `[]` | Preprocessor definitions; `{version}` is replaced by the version of the target (since v0.10.0) |
| `compile_options` | `[]` | Compiler flags of this library (PRIVATE), `STATIC`/`SHARED` only; for `INTERFACE` error E105 (since v0.14.0) |
| `platform` | – (all) | Platform filter: `windows`, `linux`, `macos`, `unix` |
| `dependencies` | `[]` | Other libraries (dependencies) |
| `externals` | `[]` | External dependencies |
| `external_options` | `{}` | Per-external options |
| `pch` | – | Precompiled headers config (see [§ 6.5](#65-pch-object-precompiled-headers)) |

### compile_options (since v0.14.0)

The flags apply **PRIVATE** to the compilation of the library, not to its users. They come
**after** the CMakeCraft defaults (warnings, `apply_compiler_options`), so that a flag of the
library overrides a default — with MSVC the later `/fp:` wins. Generator expressions pass
through as for the app tests (§9.8); this is how flags per compiler are written:

```json
"compile_options": [
    "$<$<CXX_COMPILER_ID:MSVC>:/fp:precise>",
    "$<$<CXX_COMPILER_ID:Clang,AppleClang,GNU>:-ffp-contract=off>",
    "$<$<CXX_COMPILER_ID:Clang,AppleClang,GNU>:-fno-fast-math>"
]
```

An `INTERFACE` library has no compilation of its own; `compile_options` there is a
configuration error (**E105**), not silently skipped. A source package of the library
([Packages.md](Packages.md) §2.5) writes the flags verbatim into its `CMakeLists.txt`.

---

## 8. tests Array

### 8.1 Basic Structure

```json
"tests": [
    {
        "name": "CoreLib_UnitTests",
        "displayName": "CoreLib Unit Tests",
        "type": "unit",
        "framework": "doctest",
        "dependencies": ["CoreLib"],
        "externals": ["doctest"],
        "timeout": 30,
        "labels": ["unit", "core", "fast"],
        "parallel": true
    }
]
```

### 8.2 Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Unique test target name |

### 8.3 Optional Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `displayName` | string | `name` | Display name |
| `version` | string | solution version | Test version |
| `type` | string | `"unit"` | Test type |
| `framework` | string | `"doctest"` | Test framework |
| `path` | string | convention | Source directory |
| `target` | string | – | Target under test (for coverage) |
| `dependencies` | string[] | `[]` | Internal libraries |
| `externals` | string[] | `[]` | External libraries |
| `external_options` | object | `{}` | Per-external options |
| `timeout` | int | 60 | Timeout in seconds |
| `labels` | string[] | `[type]` | CTest labels |
| `parallel` | bool | true | Can run in parallel |
| `skip` | bool | false | Skip the test |
| `source_from` | string | – | Take over sources from an executable |
| `exclude_sources` | string[] | `[]` | Sources to exclude |

### 8.4 Test Types

| Type | Description | Recommended Labels |
|------|-------------|--------------------|
| `unit` | Test individual functions/classes | `fast`, `isolated` |
| `integration` | Interaction of components | `slow`, `database` |
| `system` | Whole system (end-to-end) | `e2e`, `slow` |
| `performance` | Benchmarks, performance tests | `benchmark`, `slow` |
| `smoke` | Fast basic tests | `fast`, `critical` |

### 8.5 Supported Frameworks

| Framework | External Name | Description |
|-----------|---------------|-------------|
| `doctest` | `doctest` | Fast, header-only, ideal for unit tests |
| `googletest` | `googletest` | Feature-rich, mocking (GMock) |
| `catch2` | `catch2` | BDD style, sections, benchmarks |

### 8.6 source_from (Testing Executable Sources)

For tests that test modules of an executable (without its main):

```json
"tests": [
    {
        "name": "MyApp_ModuleY_Tests",
        "type": "unit",
        "framework": "doctest",
        "source_from": "MyApp",
        "exclude_sources": ["main.cpp"],
        "externals": ["doctest"]
    }
]
```

### 8.7 CTest Integration

```bash
# Run all tests
ctest --test-dir build

# Filter by label
ctest -L unit        # unit tests only
ctest -L fast        # fast tests only
ctest -LE slow       # no slow tests

# Run in parallel
ctest -j8            # 8 parallel jobs
```

---
## 9. apps Array

The `apps` array defines app containers with Core/Runner separation for maximum testability.

### 9.1 Basic Structure

```json
"apps": [
    {
        "name": "MyVisualizer",
        "displayName": "My Visualizer",
        "version": "1.0.0",
        "description": "Audio visualization application",
        "skip": false,
        
        "core": {
            "dependencies": ["CoreLib"],
            "externals": ["bass"],
            "external_options": {
                "bass": { "BASS_FLAC": true }
            }
        },
        
        "runner": {
            "type": "GUI",
            "externals": ["glad", "glfw"],
            "external_options": {
                "glad": { "GLAD_DEBUG": true }
            }
        },
        
        "pch": {
            "enabled": true,
            "header": "pch.h"
        },
        
        "tests": {
            "skip": false,
            "framework": "doctest",
            "targets": [
                {
                    "name": "UnitTests",
                    "type": "unit",
                    "skip": false,
                    "path": "tests/unit/UnitTests",
                    "timeout": 30,
                    "labels": ["unit", "fast"],
                    "parallel": true
                }
            ]
        },
        
        "platforms": ["windows", "linux", "macos"]
    }
]
```

### 9.2 Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Unique app name (prefix for all targets) |

### 9.3 Optional Fields (Root)

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `displayName` | string | `name` | Display name |
| `version` | string | solution version | App version |
| `description` | string | `""` | Description |
| `skip` | bool | `false` | Skip the entire app |
| `path` | string | `projects/apps/{name}` | Path to the app directory |
| `core` | object | `{}` | Core library configuration |
| `runner` | object | `{}` | Runner executable configuration |
| `pch` | object | `{}` | Precompiled header configuration |
| `tests` | object | `{}` | Test configuration |
| `platforms` | string[] | `[]` | Platform filter |

### 9.4 core Object

Configures the core library (`{AppName}.Core`).

```json
"core": {
    "dependencies": ["CoreLib", "UtilsLib"],
    "externals": ["bass", "lua54"],
    "external_options": {
        "bass": {
            "BASS_FLAC": true
        }
    }
}
```

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `dependencies` | string[] | `[]` | Internal libraries (from `libraries[]`) |
| `externals` | string[] | `[]` | External dependencies |
| `external_options` | object | `{}` | Per-external options |

### 9.5 runner Object

Configures the runner executable (`{AppName}`).

```json
"runner": {
    "type": "GUI",
    "externals": ["glad", "glfw"],
    "external_options": {
        "glad": {
            "GLAD_DEBUG": true
        }
    }
}
```

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `type` | string | `"CONSOLE"` | Executable type (`GUI` / `CONSOLE`) |
| `externals` | string[] | `[]` | Runner-specific externals |
| `external_options` | object | `{}` | Per-external options |

**runner.type:**

| Type | Windows | Linux/macOS |
|------|---------|-------------|
| `GUI` | `WinMain` (no console window) | `main` |
| `CONSOLE` | `main` (with console) | `main` |

### 9.6 pch Object

Configures the precompiled header.

```json
"pch": {
    "enabled": true,
    "header": "pch.h"
}
```

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `enabled` | bool | `false` | Enable PCH |
| `header` | string | `"pch.h"` | PCH header file name |

**PCH scope:**
- Core (`src/`): uses the PCH when enabled
- Runner (`main/`): does NOT use the PCH
- Tests: do NOT use the PCH

### 9.7 tests Object

Configures app tests with a flexible targets[] array.

```json
"tests": {
    "skip": false,
    "framework": "doctest",
    "targets": [ ... ]
}
```

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `skip` | bool | `false` | **Skip all tests of this app** |
| `framework` | string | — | Default framework for all tests |
| `targets` | array | `[]` | Test target definitions |

### 9.8 tests.targets[] Object

Each element defines a test target.

```json
{
    "name": "UnitTests",
    "type": "unit",
    "skip": false,
    "path": "tests/unit/UnitTests",
    "framework": "doctest",
    "timeout": 30,
    "labels": ["unit", "fast"],
    "dependencies": ["CoreLib"],
    "externals": ["bass"],
    "external_options": {
        "bass": { "BASS_MIX": true }
    },
    "parallel": true
}
```

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | string | ✅ | — | Target name (→ `{AppName}.{name}`) |
| `type` | string | ✅ | — | Test type |
| `skip` | bool | — | `false` | **Skip this test** |
| `path` | string | — | `tests/{type}/{name}` | Path relative to the app directory |
| `framework` | string | — | `tests.framework` | Test framework |
| `timeout` | number | — | type-dependent | CTest timeout (seconds) |
| `labels` | string[] | — | type-dependent | CTest labels |
| `dependencies` | string[] | — | `[]` | Internal libraries (linked directly, in addition to `{AppName}.Core`) |
| `externals` | string[] | — | `[]` | Additional externals |
| `external_options` | object | — | `{}` | Per-external options for the entries in `externals` |
| `compile_options` | string[] | — | `[]` | Compiler flags for this test target only (PRIVATE) |
| `parallel` | bool | — | type-dependent | Parallel execution |

`external_options` only affects externals listed in `externals` of the same test target.
The test framework (`framework`) is always applied without options — an entry such as
`external_options.doctest` has no effect.

`compile_options` applies to every compiler the project builds with. A flag that only one of
them understands goes into a generator expression:

```json
"compile_options": [ "$<$<CXX_COMPILER_ID:MSVC>:/bigobj>" ]
```

### 9.9 Test Types and Defaults

| Type | Default Timeout | Default Parallel | Default Labels |
|------|-----------------|------------------|----------------|
| `unit` | 30s | true | `["unit", "fast"]` |
| `integration` | 120s | true | `["integration"]` |
| `performance` | 300s | false | `["performance", "benchmark"]` |
| `system` | 180s | false | `["system", "e2e", "slow"]` |
| `smoke` | 10s | true | `["smoke", "critical", "fast"]` |
| `fuzz` | 60s | false | `["fuzz", "security"]` |
| `security` | 120s | false | `["security"]` |
| `ui` | 180s | false | `["ui", "slow"]` |
| `api` | 60s | true | `["api", "integration"]` |
| *(unknown)* | 60s | true | `["{type}"]` |

### 9.10 Skip Logic

| `tests.skip` | `targets[].skip` | Result |
|--------------|------------------|--------|
| `true` | any | Test skipped |
| `false`/missing | `true` | Test skipped |
| `false`/missing | `false`/missing | Test is created |

**Global skip takes precedence** — if `tests.skip: true`, all tests are skipped.

### 9.11 Generated Targets

The following CMake targets are created for each app:

| Target | Type | Description |
|--------|------|-------------|
| `{AppName}.Core` | STATIC library | Business logic (include/ + src/) |
| `{AppName}` | Executable | Entry point (main/) |
| `{AppName}.{TestName}` | Executable | Test (for each target in tests.targets[]) |

**Example:**

```
MyVisualizer.Core              ← STATIC library
MyVisualizer                   ← GUI executable
MyVisualizer.UnitTests         ← test executable
MyVisualizer.IntegrationTests  ← test executable
```

### 9.12 Folder Structure

```
projects/apps/{AppName}/
├── include/                    # Public headers → {AppName}.Core
│   ├── Source.cmake
│   └── *.hpp
├── src/                        # Implementation → {AppName}.Core
│   ├── Source.cmake
│   └── *.cpp
├── main/                       # Entry point → {AppName}
│   ├── Source.cmake
│   └── main.cpp
├── pch/                        # Precompiled header
│   └── pch.h
└── tests/
    └── {type}/
        └── {TestName}/         # → {AppName}.{TestName}
            ├── Source.cmake
            ├── test_main.cpp
            └── test_*.cpp
```

### 9.13 Complete Example

```json
{
    "apps": [
        {
            "name": "MyVisualizer",
            "displayName": "My Visualizer",
            "version": "0.1.0",
            
            "core": {
                "externals": ["bass"]
            },
            
            "runner": {
                "type": "GUI",
                "externals": ["glad", "glfw"]
            },
            
            "pch": {
                "enabled": true
            },
            
            "tests": {
                "framework": "doctest",
                "targets": [
                    {
                        "name": "UnitTests",
                        "type": "unit",
                        "path": "tests/unit/UnitTests"
                    },
                    {
                        "name": "IntegrationTests",
                        "type": "integration",
                        "path": "tests/integration/IntegrationTests",
                        "externals": ["bass"]
                    },
                    {
                        "name": "Benchmarks",
                        "type": "performance",
                        "skip": true
                    }
                ]
            }
        },
        {
            "name": "DemoPlayer",
            "tests": {
                "skip": true,
                "framework": "doctest",
                "targets": [
                    { "name": "UnitTests", "type": "unit" }
                ]
            }
        }
    ]
}
```

---

## 10. Quick Reference

### 10.1 Required Fields

| Block | Field |
|-------|-------|
| Root | `schemaVersion` |
| solution | `name`, `version` |
| executables[] | `name` |
| libraries[] | `name` |
| tests[] | `name` |
| apps[] | `name` |
| apps[].tests.targets[] | `name`, `type` |
| externals (local) | `path` (include optional) |
| externals (fetched) | `git`, (tag\|branch\|commit) |
| externals (system) | `system: true`, `package` |
| externals (archive) | `archive: true`, `pin` |
| packages[] | `name`, `contents` or `library` |


### 10.2 Defaults

| Setting | Default Value |
|---------|---------------|
| C++ standard | 20 |
| Library type | STATIC |
| Executable type | CONSOLE |
| Source mode | auto |
| Test framework | doctest |
| Test timeout | 60s |
| App runner.type | CONSOLE |
| App PCH | disabled |
| App tests.skip | false |

---

## 11. Complete Example

```json
{
    "schemaVersion": "1.0",
    "solution": {
        "name": "MyProject",
        "version": "1.0.0",
        "description": "Example project with Qt6 and Tests"
    },
    "settings": {
        "standards": { "cxx_standard": 20 },
        "defaults": {
            "library_type": "STATIC",
            "executable_type": "CONSOLE"
        },
        "sources": { "mode": "auto" }
    },
    "externals": {
        "bass": { "path": "externals/bass" },
        "doctest": { "path": "externals/doctest" },
        "glfw": {
            "git": "https://github.com/glfw/glfw.git",
            "tag": "3.4"
        },
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.91.6",
            "cmakeSupport": false
        },
        "qt6": {
            "system": true,
            "package": "Qt6",
            "components": ["Core", "Widgets", "Gui"],
            "hints": ["${QT_ROOT}"]
        }
    },
    "libraries": [
        {
            "name": "CoreLib",
            "version": "1.0.0",
            "type": "STATIC",
            "path": "projects/libs/CoreLib/src",
            "public_headers": "projects/libs/CoreLib/include"
        }
    ],
    "executables": [
        {
            "name": "ConsoleApp",
            "type": "CONSOLE",
            "dependencies": ["CoreLib"],
            "externals": ["bass"],
            "external_options": {
                "bass": { "BASS_FLAC": true }
            }
        },
        {
            "name": "QtApp",
            "type": "GUI",
            "externals": ["qt6"]
        }
    ],
    "tests": [
        {
            "name": "CoreLib_UnitTests",
            "type": "unit",
            "framework": "doctest",
            "dependencies": ["CoreLib"],
            "externals": ["doctest"],
            "labels": ["unit", "core", "fast"],
            "timeout": 30
        }
    ]
}
```
> **Note:** Local externals need **no** `include` field — the convention `cmake/externals/includes/{name}/Include.cmake` is used automatically.

---


## 12. Error Codes

### 12.1 External-Related Errors

| Code | Description |
|------|-------------|
| E010 | External not defined in the externals block |
| E012 | External has neither a path, git nor system field |
| E213 | Include.cmake for local external not found |
| E214 | Local external path does not exist |
| E216 | Explicitly specified hook not found |
| E217 | PostFetch hook required (cmakeSupport: false) — currently not raised, reported as E201 |
| E218 | Not cached and offline mode enabled |
| E220 | Archive external: `pin` field missing |
| **E502** | **System external: `package` field missing** |
| **E503** | **System external: find_package() failed** |
| **E504** | **System external: package found, but not all components from `components`** |
| **E505** | **System external: no version matching `version` found** |

### 12.2 Test-Related Errors (standalone tests[])

| Code | Description |
|------|-------------|
| E301 | Unknown test framework |
| E302 | source_from executable does not exist |
| E303 | Test source directory not found |

### 12.3 App Container Errors (apps[])

| Code | Description |
|------|-------------|
| E401 | App: `name` is a required field |
| E402 | App path does not exist |
| E403 | App has no `src/` directory |
| E404 | App has no source files in `src/` |
| E405 | App dependency not found |
| E406 | App has no `main/` directory |
| E407 | App has no source files in `main/` |

### 12.4 App Test Errors (apps[].tests.targets[])

| Code | Description |
|------|-------------|
| E101 | Test dependency (internal library) does not exist |
| E301 | No framework specified (neither global nor per target) |
| E302 | Unknown test framework |
| E303 | Test target: `name` missing |
| E304 | Test target: `type` missing |
| E305 | Test path does not exist |
| E306 | No source files in the test path |

### 12.5 Warnings

| Code | Area | Description |
|------|------|-------------|
| W112 | Packages | Package names a target that does not exist — `package_<name>` is not created |
| W302 | Externals | Version differs, offline mode uses the cache |
| W304 | Externals | Archive external not available — targets build without it |
| W401 | App container | App has no `include/` directory |
| W402 | App container | PCH enabled but header not found |
| W402 | App tests | Test of a serial type has `parallel: true` set |
| W403 | App container | Tests directory exists but no sources |
| **W501** | **System externals** | **Backup path used (not recommended)** |

**Note on W402:** The code W402 is used in two contexts:
- For PCH: warning if `pch.enabled: true` but `pch/{header}` is not found
- For tests: warning if `parallel: true` is set for types such as `performance`, `system`, `fuzz`, `security`, `ui`

---

## 13. See Also

- [Packages.md](Packages.md) — Building and consuming packages
- [Externals.md](Externals.md) — External libraries reference
- [ErrorCodes.md](ErrorCodes.md) — Complete error code reference
- [CMakePresets Reference](CMakePresets.md) — Build presets
- [App Tests Targets Concept](../../konzepte/abgeschlossen/App_Tests_Targets_Concept.md) — Concept for flexible app tests

---

## 14. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.7** | **2026-11-09** | **Aligned with the code: `schemaVersion` in the complete example §11 is `"1.0"` (`cmake/project/Solution.cmake:50`); CMakeCraft v0.14.1: `required` without `find_package(… REQUIRED)`, E504/E505 in §12.1, E217 as not raised** |
| **1.0.6** | **2026-11-07** | **CMakeCraft v0.14.0: `compile_options` for libraries[] (§7, E105 for INTERFACE); source package of a library in the `packages` block (`library` instead of `contents`, [Packages.md](Packages.md) §2.5, E106)** |
| **1.0.5** | **2026-10-23** | **CMakeCraft v0.12.0: block `settings.msvc` with `parallel_compile` (§4.4, default 8), E004** |
| **1.0.4** | **2026-10-09** | **CMakeCraft v0.11.0: `compile_options` for apps[].tests.targets[] (§9.8); runtime files of an archive external are copied by a target of its own on every build (§5.8)** |
| **1.0.3** | **2026-10-09** | **CMakeCraft v0.10.0: block `packages`, archive externals (§5.8), `output_name` and `defines` for libraries[], `{version}` in `defines`. Corrected: hook paths are called `hooks.preFetch`/`hooks.postFetch` (§5.3), `version` of a system external is a minimum version without operator (§5.4), error table §12.1 (E216–E220) and W302 aligned with the code** |
| **1.0.2** | **2026-10-05** | **Fix: `external_options` for apps[].tests.targets[] (§9.8) is applied — previously the test target got every external with empty options. Existing entries thus take effect for the first time. The test framework stays without options** |
| 1.0.1 | 2026-07-20 | New: `dependencies` for apps[].tests.targets[] (§9.8) — internal libraries are linked directly to the test target (E101 for an unknown dependency). Previously the key was ignored |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.7.2 | 2025-12-20 | New: `skip` for externals (§5.7) - prepare externals without loading them. E013 when skipped externals are used |
| 0.7.1 | 2025-12-20 | Consistent external_options: added for libraries[], apps.core, apps.runner (was missing). Now uniform like executables[] and tests[] |
| 0.7.0 | 2025-12-18 | Phase 9: system externals with `system: true` syntax, find_package() integration, package hooks (Qt6, Boost), error codes E502/E503/W501, path resolution with ENV variables |
| 0.6.0 | 2025-12-18 | New: apps[] array with Core/Runner separation, tests.targets[] flexible test configuration, skip feature (tests.skip, targets[].skip), app container error codes (E4xx, W4xx) |
| 0.5.2 | 2025-12-18 | PCH object fully documented (§ 6.5): implicit activation, search path priority, pch added for libraries |
| 0.5.1 | 2025-12-15 | Include.cmake convention documented (§ 5.2), include field optional, hook paths lower case |
| 0.5.0 | 2025-12-14 | Blueprint v0.5.0 format: numbered TOC, reference header, quick reference, change blocks integrated into the changelog |
| 0.1.4 | 2025-12-12 | tests array documented: types, frameworks, source_from, CTest |
| 0.1.3 | 2025-12-11 | System externals: options field (hint, backup, components) |
| 0.1.2 | 2025-12-10 | Hook reuse (hook field) |
| 0.1.1 | 2025-12-09 | Git externals (git, tag, cmakeSupport) |
| 0.1.0 | 2025-12-05 | Initial schema |
