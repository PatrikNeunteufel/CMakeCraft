# ErrorCodes — Reference

> **Version:** 1.6.1  
> **Date:** 2026-11-09  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [ErrorCodes.md](../../../de/guide/references/ErrorCodes.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Conventions](#2-conventions)
3. [Fatal Errors (E)](#3-fatal-errors-e)
4. [Warnings (W)](#4-warnings-w)
5. [Quick Reference](#5-quick-reference)
6. [Usage in Code](#6-usage-in-code)
7. [See Also](#7-see-also)
8. [Changelog](#8-changelog)

---

## 1. Overview

This reference documents all error codes of the CMake Architecture build system with explanations and suggested fixes.

### Error Code Format

```
[E|W][K][NN]

E = Error (build aborts)
W = Warning (build continues)
K = Category (1 digit)
NN = Number (2 digits)
```

### Target Audience

- Developers troubleshooting a build
- Build system developers, for consistent error messages

---

## 2. Conventions

### 2.1 Error Code Ranges

| Range | Codes | Description |
|-------|-------|-------------|
| JSON/parsing | `E0xx` | Missing required fields, invalid JSON |
| Target creation | `E1xx` | Target already exists, dependency missing |
| Externals | `E2xx` | Fetch failed, Include.cmake missing |
| Tests | `E3xx` | Framework, source errors |
| App container | `E4xx` | App structure, directories |
| System externals | `E5xx` | find_package, components |
| Deprecation | `W0xx` | Outdated features/syntax |
| Configuration | `W1xx` | Suboptimal settings |
| Tools/setup | `W2xx` | Missing tools |
| External caching | `W3xx` | Offline mode, hook reuse |
| App container | `W4xx` | Optional directories |
| System external warnings | `W5xx` | Backup usage |
| Phase tests | `W6xx`–`W9xx` | Warnings of the self-tests (only with `RUN_BUILD_SYSTEM_TESTS=ON`) |

### 2.2 Severity Levels

| Symbol | Type | Meaning |
|--------|------|---------|
| ⛔ | FATAL_ERROR | Build aborts |
| ⚠️ | WARNING | Build continues |

---

## 3. Fatal Errors (E)

### 3.1 E0xx — JSON/Parsing Errors

#### E001 — Required field missing

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.0 |

**Message** (examples):
```
[E001] Executable has no 'name' field
[E001] Executable 'MyApp': Required field 'name' missing
[E001] Solution.json: 'solution.name' missing
```

Depending on the location, the text names the object (`Executable`, `Library`, `Test`, `Package`, `Local external` …)
and the missing or empty field.

**Fix:**
```json
{
    "name": "MyApp",
    "path": "src/apps/myapp"
}
```

---

#### E002 — Solution.json not found

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.0 |

**Message:**
```
[E002] Solution.json not found: <path>/Solution.json
[E002] Solution.json: 'schemaVersion' missing or invalid JSON
[E002] Solution.json: 'schemaVersion' has invalid format '1' (expected: MAJOR.MINOR)
```

**Fix:**
- Make sure `Solution.json` is located in the project root
- Give `schemaVersion` as `"MAJOR.MINOR"` (currently `"1.0"`)
- Check the spelling (upper/lower case)

---

#### E003 — Schema version incompatible

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.6.0 |

**Message:**
```
[E003] Solution.json: schemaVersion 0.6 incompatible (expected major: 1, current: 1.0)
[E003] Invalid library type 'OBJECT' for 'MyLib'. Valid: STATIC, SHARED, INTERFACE
```

**Cause:** The major version of the schema in Solution.json does not match the version supported by the build
system (currently `1.0`, `cmake/project/Solution.cmake:50`). The same code also reports an invalid library type
(`LibraryCollect.cmake:105`).

**Fix:**
- Set `schemaVersion` in Solution.json to a compatible version (e.g. `"1.0"`)
- Or update the build system if a newer schema version is needed

---

#### E004 — Invalid value in the settings block

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.12.0 |

**Message:**
```
[E004] Solution.json: settings.msvc.parallel_compile must be a non-negative integer, got 'viele'
```

**Cause:** A field in the `settings` block has a value CMakeCraft cannot use.

**Fix:**
- Give `settings.msvc.parallel_compile` as an integer ≥ 0 (`0` or `1` = off), see
  [Solution_Schema.md §4.4](Solution_Schema.md#44-msvc)

---

#### E005 — Top-level CMakeLists.txt without project()

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.13.0 |

**Message:**
```
[E005] .../CMakeLists.txt has no project() line. Add 'project(<Name> LANGUAGES NONE)' directly after cmake_minimum_required() ...
```

**Cause:** Without an explicit `project()` in the top-level `CMakeLists.txt`, CMake inserts its
own `project(Project)` on line 1, **before** `cmake_minimum_required()`. The compilers are then
set up under the old rules: `CMAKE_MSVC_RUNTIME_LIBRARY` has no effect, and the configuration
`Testing` builds with the static CRT (`/MT`).

**Fix:**
```cmake
cmake_minimum_required(VERSION 3.26)
project(MeinProjekt LANGUAGES NONE)   # name/version come from Solution.json
include("${CMAKE_CURRENT_LIST_DIR}/CMakeCraftBootstrap.cmake")
```
Then configure once with `--fresh` — otherwise the cache still holds the old flags.

---

#### E010 — External not defined in the externals block

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.0 |

**Message:**
```
[E010] External 'imgui' not defined in externals block
[E010] Test framework 'doctest' not defined in externals block
```

**Fix:**
```json
{
    "externals": {
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.90.1"
        }
    }
}
```

---

#### E012 — External source field error

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.0 |

**Message:**
```
[E012] External 'mylib': No source field specified.
  Required: one of 'system', 'git', 'path', or 'archive'
  ...
[E012] External 'mylib': Multiple source fields specified: path;git
  Only one source field is allowed.
```

**Fix:** Exactly ONE source field per external: `system`, `git`, `path` or `archive`
(`Validation.cmake:58`; `vcpkg`, `conan`, `find_package` pass the check but end in the orchestrator with
`[E012] External 'mylib': No valid source field (system/git/path/archive)`).

---

#### E013 — Skipped external used

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.7.1 |

**Message:**
```
[E013] External 'future_lib' is skipped but used by target 'MyApp'. Remove from externals list or set skip: false
```

**Cause:** An external with `skip: true` is referenced by a target.

**Fix:** 
- Remove the external from the target's `externals` list, OR
- Set `skip: false` (or remove `skip`) in the external block

---

### 3.2 E1xx — Target Creation Errors

#### E101 — Dependency does not exist

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.0 |

**Fix:** Define the library in Solution.json or correct the typo.

---

#### E102 — Target already exists

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.0 |

**Fix:** Target names must be unique across libraries, executables AND tests.

---

#### E103 — Circular dependency

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.0 |

> Currently not raised (as of 2026-11-09). The case is not reported: CMakeCraft does
> not detect circular dependencies between targets (`cmake/core/Errors.cmake:97`).

**Description:** A circular dependency between targets was detected (A → B → C → A).

**Fix:** Extract shared code into a separate library.

---

#### E104 — Source.cmake not found

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.0 |

**Description:** The source mode is `explicit` and the source directory contains no `Source.cmake` file.

**Fix:** Create Source.cmake or change the mode to `auto`.

---

#### E105 — compile_options on an INTERFACE library

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.14.0 |

**Description:** A library with `"type": "INTERFACE"` carries `compile_options`. A header
library has no compilation of its own; the flag would have no effect anywhere.

**Fix:** Move the computation into `.cpp` files of a `STATIC` library and set the flags
there — or remove `compile_options`.

---

#### E106 — Source package cannot be expressed

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.14.0 |

**Description:** An entry `{ "library": … }` in the `packages` block names a library that
cannot be described in plain CMake: it is not `STATIC`, has C++20 modules, a file or an include
folder lies outside `path` and `public_headers`, or an external is not local (system, fetched,
archive) or brings more than a header-only `INTERFACE` target with include folders in its own
folder, defines, compile options and compile features. The message names the library and, where
applicable, the external.

**Fix:** Rearrange the library or the external so that it fits, or do not build a source
package (binary package with `contents`). See [Packages.md](Packages.md) §2.5.

---

### 3.3 E2xx — Externals Errors

#### E201 — Fetched external: no target in registry

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.0 |

**Message:**
```
[E201] Fetched external 'mylib': No target in registry. PostFetch hook required?
[E201] Fetched external 'mylib': No CMake support, PostFetch hook required but no targets created
```

The second message appears with `cmakeSupport: false` when no target is registered after the PostFetch hook
(`cmake/externals/fetched/Handler.cmake:118`).

**Fix:**
1. Check whether the external is a CMake project
2. Create a PostFetch hook if needed
3. Or use a local external with its own Include.cmake

---

#### E202 — External fetch failed

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.0 |

**Fix:**
- Check the network connection
- Check the URL in Solution.json
- Does the tag/branch exist?

---

#### E203 — Target of an external not found

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | — |

**Message:**
```
[E203] Target 'glfw' for external 'glfw' not found
```

**Description:** The main target registered for an external does not exist when linking
(`cmake/externals/registry/Targets.cmake:263`).

**Fix:** Check the hook or Include.cmake that creates and registers the target.

---

#### E213 — Local external: Include.cmake not found

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.0 |

**Fix:** Create the file: `externals/${name}/Include.cmake`

---

#### E214 — Local external: path does not exist

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.0 |

**Fix:** Check the path in Solution.json.

---

#### E215 — Fetched external: no tag/branch/commit

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.0 |

**Fix:** Specify one of `tag`, `branch` or `commit`.

---

#### E216 — Explicitly specified hook not found

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.0 |

**Fix:** Create the hook file or remove the hook entry.

---

#### E217 — PostFetch hook required but not present

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.1 |

**Message:**
```
[E217] External 'imgui': PostFetch hook required (cmakeSupport=false) but not found
```

> Currently not raised (as of 2026-11-09). The case is reported as E201:
> `Fetched external '<name>': No CMake support, PostFetch hook required but no targets created`
> (`cmake/externals/fetched/Handler.cmake:118`).

**Fix:**
1. Create a PostFetch hook: `cmake/externals/hooks/postfetch/${name}.cmake`
2. Or set `cmakeSupport: true` (if the external does have a CMakeLists.txt after all)

---

#### E218 — Not cached and offline mode enabled

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.2 |

**Message:**
```
[E218] External 'glfw': Not cached and offline mode enabled
```

**Description:** `EXTERNALS_OFFLINE` forbids fetching, but there is nothing usable under
`.externals/<name>/`. Since v0.9.1 the message also covers the case where something is
there but it is not a complete clone.

**Fix:**
1. Configure once with a network connection and without `EXTERNALS_OFFLINE`
2. Or take over a populated `.externals/` from another working copy

---

#### E219 — Cache directory cannot be removed

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.9.1 |

**Message:**
```
[E219] External 'glfw': Could not remove the cache directory
    .../.externals/glfw
  It is left over from an aborted fetch and has to go before the external can be fetched again.
  ...
```

**Description:** An unusable cache directory has to go before a new clone can be made —
but deleting it failed. The build system can do nothing more at this point.

**Fix:**
1. Close programs that keep something open in the directory (editor, Explorer window,
   terminal that `cd`'d there, virus scanner)
2. Delete `.externals/<name>/` by hand
3. Configure again

If it persists, the **path is usually too long**: the project path plus the directory
depth of the third-party project exceeds the limit of the toolchain on Windows. Then move
the project to a shorter path or enable long paths in Windows and Git
(`git config --global core.longpaths true`).

---

#### E220 — Archive external: field `pin` missing

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.10.0 |

**Message:**
```
[E220] Archive external 'sichttest': 'pin' field is required.
  Example: { "archive": true, "pin": "sichttest.pin" }
```

**Description:** An external with `"archive": true` names no pin file. Version, address and
checksum live only there.

**Fix:** Create a pin file and name it with `"pin"` — see [Packages.md](Packages.md) §4.

---

### 3.4 E3xx — Test Errors

#### E301 — Unknown test framework

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.4 |

**Message:**
```
[E301] Test 'MyTests': Unknown framework 'boost'. Valid: doctest;googletest;catch2
[E301] App 'MyApp': No framework specified for test 'UnitTests'. Set tests.framework or targets[].framework
```

**Fix:** Valid frameworks: `doctest`, `googletest`, `catch2`

---

#### E302 — source_from executable does not exist

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.4 |

**Message:**
```
[E302] source_from: Executable 'MyApp' not found
```

For apps, the same code reports an unknown framework of a test target:
`[E302] App 'MyApp': Unknown framework 'boost' for test 'UnitTests'. Valid: doctest;googletest;catch2`
(`AppCreate.cmake:630`).

**Fix:** Check the executable name in `source_from`.

---

#### E303 — Test source directory not found

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.4 |

**Message:**
```
[E303] Test 'MyTests': Source path does not exist: <path>
```

For apps, the same code reports a test target without `name`:
`[E303] App 'MyApp': Test target [0] missing required 'name' field` (`AppCollect.cmake:351`).

**Fix:** Check the path in Solution.json or create the directory.

---

#### E304 — App test target without type

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | — |

**Message:**
```
[E304] App 'MyApp': Test target 'UnitTests' missing required 'type' field
```

**Fix:** Give `type` in the entry of `apps[].tests.targets[]` (`unit`, `integration`, …).

---

#### E305 — Path of an app test target does not exist

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | — |

**Message:**
```
[E305] App 'MyApp': Test 'UnitTests' path does not exist: <path>
```

**Fix:** Create the folder or correct `path` (default: `tests/{type}/{name}`).

---

### 3.5 E4xx — App Container Errors

#### E400 — App definition without name (collect phase)

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.2.0 (Phase 8) |

**Message:**
```
[E400] App definition missing required 'name' field
```

**Description:** Check while reading an app (`AppCollect.cmake:183`). In the normal flow E401 reports the
same error first.

**Fix:** Add the `name` field to the app definition.

---

#### E401 — App: name is a required field

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.2.0 (Phase 8) |

**Message:**
```
[E401] App #0 has no 'name' field
```

**Fix:** Add the `name` field to the app definition.

---

#### E402 — App path does not exist

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.2.0 (Phase 8) |

**Fix:** Check the path or create the directory.

---

#### E403 — App has no src/ directory

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.2.0 (Phase 8) |

**Fix:** Create a `src/` directory in the app container.

---

#### E404 — App has no source files in src/

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.2.0 (Phase 8) |

**Fix:** Add source files (.cpp) to `src/`.

---

#### E405 — App dependency not found

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.2.0 (Phase 8) |

**Fix:** Define the dependency in Solution.json.

---

#### E406 — App has no main/ directory

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.2.0 (Phase 8) |

**Fix:** Create a `main/` directory for the entry point.

---

#### E407 — App has no source files in main/

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.2.0 (Phase 8) |

**Fix:** Add an entry point file (main.cpp) to `main/`.

---

### 3.6 E5xx — System External Errors

The system handler calls `find_package()` **without** `REQUIRED`
(`cmake/externals/system/Handler.cmake:270`, `:273`). If `<Package>_FOUND` stays false and the
external is `required` (default), `_system_external_not_found()` names the cause as E503, E504
or E505 (`Handler.cmake:290`). CMake's own diagnostics appear before it as a warning. If the
external is `"required": false`, there is no error, only `[<name>] <Package> not found (optional)`
(`Handler.cmake:293`).

#### E502 — package field missing

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.2.0 |

**Message** (`cmake/core/Validation.cmake:94`, `cmake/externals/system/Handler.cmake:180`):
```
[E502] System external 'qt6': 'package' field is required.
  Example: { "system": true, "package": "Qt6" }
```

**Fix:** Specify the `package` field for system externals.

---

#### E503 — find_package failed

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.2.0 |

**Message** when CMake finds no configuration file of the package (`Handler.cmake:128`):
```
[E503] System external 'qt6': find_package(Qt6) failed.

  Possible solutions:
    1. Set Qt6_ROOT environment variable
    2. Add 'hints' in Solution.json
    3. Install Qt6 to a standard location

  Example Solution.json:
    "qt6": {
      "system": true,
      "package": "Qt6",
      "hints": ["C:/Path/To/Qt6"]
    }
```

Two further variants with the same solution lines:

- Configuration files found, but none accepted and no `version` set
  (`Handler.cmake:120`): `find_package(Qt6) failed - no configuration file was accepted.`,
  followed by `Considered:` with one line `<file> (version <version>)` each.
- Configuration accepted, but the package reports itself as not found, without `components`
  being set (`Handler.cmake:101`): additionally
  `Reason given by the package: <Package>_NOT_FOUND_MESSAGE`.

An external that is not registered when it is linked reports
`[E503] System external '<name>' not properly registered` (`Handler.cmake:331`).

**Fix:** Install the package or give its location via `<Package>_ROOT`, `hints` in
Solution.json or `CMAKE_PREFIX_PATH`.

---

#### E504 — Component not found

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.2.0 (raised since v0.14.1) |

**Message** (`Handler.cmake:91`):
```
[E504] System external 'qt6': Qt6 was found (<Qt6_DIR>), but not with all requested components: Core, Widgets, Charts
  Reason given by the package: <Qt6_NOT_FOUND_MESSAGE>

  Possible solutions:
    1. Install the missing component(s) for this Qt6 installation
    2. Remove components the project does not use from 'components' in Solution.json
```

**Description:** The package configuration was accepted (`<Package>_DIR` set), but at least
one of the components in `components` is missing. The message names all requested components;
which one is missing is stated in the package's reason (`<Package>_NOT_FOUND_MESSAGE`).

**Fix:** Install the missing component for this installation or remove it from `components`.

---

#### E505 — Version not satisfied

| Aspect | Value |
|--------|-------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.2.0 (raised since v0.14.1) |

**Message** (`Handler.cmake:109`):
```
[E505] System external 'qt6': no Qt6 with a version compatible to the requested '6.9' was found.
  Considered:
    C:/Qt/6.8.0/msvc2022_64/lib/cmake/Qt6/Qt6Config.cmake (version 6.8.0)

  Possible solutions:
    1. Install a compatible Qt6 version and point Qt6_ROOT or 'hints' to it
    2. Adjust 'version' in Solution.json
```

**Description:** `version` is set, and CMake only considered configuration files with an
unsuitable version. Without `version` the same case is E503.

**Fix:** Install a suitable version and point `<Package>_ROOT` or `hints` to it, or adjust
`version` in Solution.json.

---

## 4. Warnings (W)

### 4.1 W0xx — Deprecation Warnings

#### W001 — Outdated schema

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | v0.1.0 |

> Currently not raised (as of 2026-11-09). The case is reported as E002, E003, W101 or W102
> (`cmake/project/Solution.cmake:82`, `:94`, `:102`, `:107`, `:109`). W001 only appears in
> `validate_solution_schema()` (`cmake/core/Validation.cmake:221`, `:227`), which nothing calls.

**Description:** The Solution.json uses an outdated schema.

---

#### W002 — Outdated syntax/field

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | v0.1.0 |

> Currently not raised (as of 2026-11-09). The case is not reported: no module checks
> for outdated fields.

**Description:** A field or syntax will be removed in the future.

---

### 4.2 W1xx — Configuration/Validation Warnings

#### W101 — Schema version too low

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | v0.6.0 |

**Message:**
```
[W101] Solution.json: schemaVersion <MAJOR.MINOR> < 1.0, some features may not be available
```

**Description:** The Solution.json uses an older minor version of the schema. Newer features of the build system
may not be available. With today's `1.0` (minor 0) this message cannot occur.

**Further triggers:** The code also uses W101 for other notices, among them:
`Invalid source.mode '<mode>', using 'explicit'` (`SourceCollect.cmake:75`),
`Source.cmake for '<target>' defines no compilable files` (`SourceCollect.cmake:417`),
`Executable|Library '<name>': No source files found in <path>`, `Test '<name>': No source files found`,
`Executable|Library '<name>': PCH enabled but '<header>' not found in pch/, src/, or root`,
`External '<name>' not ready when applying to <target>` and `External '<name>': No target to link`.

**Fix:** Update `schemaVersion` in Solution.json to the current version.

---

#### W102 — Schema version too high

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | v0.6.0 |

**Message:**
```
[W102] Solution.json: schemaVersion 1.1 > 1.0, some features may not work correctly
```

**Description:** The Solution.json uses a newer schema version than the build system supports. Some features may not work correctly.

**Fix:** Update the build system or lower `schemaVersion`.

---

#### W103 — Include.cmake creates executables

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | v0.1.0 |

**Description:** An external's Include.cmake creates executable targets (IDE clutter).

---

#### W104 — Include.cmake includes examples

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | v0.1.0 |

**Description:** An Include.cmake includes example or test directories.

---

#### W105 — Version not SemVer-compliant

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | v0.1.0 |

> Currently not raised (as of 2026-11-09). The case is not reported: no module checks
> the version format. W106–W108 are never raised either (`cmake/core/Errors.cmake:180–183`).

**Correct format:** `MAJOR.MINOR.PATCH` (e.g. `1.0.0`)

---

#### W109 — C++20 modules used

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | v0.1.0 |

**Description:** The target uses C++20 module interface units, which are still experimental.

---

#### W110 — GLOB fallback active

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | v0.1.0 |

**Description:** No Source.cmake found, GLOB is used as a fallback.

---

#### W111 — Source.cmake present but empty

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | — |

**Message:**
```
[W111] Source.cmake exists but defines no files: <path>/Source.cmake
```

**Description:** In source mode `auto` there is a `Source.cmake` that lists no files; the build system falls
back to GLOB (`SourceCollect.cmake:435`).

---

#### W112 — Package names a target that does not exist

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | v0.10.0 |

**Description:** An entry in `packages[].contents` (`headers_of`, `binary_of`,
`output_dir_of`) names a target that does not exist in this configure — skipped, hidden by
`BUILD_ONLY`, or for another platform. The target `package_<name>` is then not created.

**Fix:** If the name is correct, there is nothing to do. Otherwise correct the name in `Solution.json`.

---

### 4.3 W2xx — Tools/Setup Warnings

#### W201 — Clang-Tidy not found

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | v0.1.0 |

**Description:** `ENABLE_CLANG_TIDY=ON` is set, but clang-tidy was not found.

---

### 4.4 W3xx — External Caching Warnings

#### W301 — External used from cache (offline mode)

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | v0.1.2 |

> Currently not raised (as of 2026-11-09). The case is not reported: a matching cache
> is used silently (`cmake/externals/core/Fetch.cmake:143–146`); if the version differs, W302
> follows (`Fetch.cmake:151`).

**Description:** Offline mode active, the cached external is used.

---

#### W302 — Version differs, offline mode uses the cache

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | v0.1.2 |

**Message:**
```
[W302] External 'glfw': Version mismatch but offline mode - using cached
```

**Description:** The cached version does not match the tag/branch/commit given in
`Solution.json`. Because `EXTERNALS_OFFLINE` is set, it is used anyway instead of aborting
the build.

**Fix:** Configure without offline mode so that the right version is fetched.

---

#### W303 — Incomplete clone in the cache

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | v0.9.1 |

**Message:**
```
[W303] External 'glfw': Incomplete clone in cache (leftover of an aborted fetch) - removing and fetching again: .../.externals/glfw
[W303] External 'glfw': Cache directory is not a git clone - removing and fetching again: .../.externals/glfw
```

**Description:** `.externals/<name>/` contained the remains of an aborted clone — a `.git`
without a checked-out state. `git clone` creates `.git` early and fills it afterwards; if the
operation aborts (network gone, Ctrl-C, disk full), exactly that is left behind.

CMakeCraft detects this, deletes the directory and fetches again. **There is nothing to
do** — the warning only says why a download happens at this point although something
seemed to be in the cache.

Before v0.9.1 this state was reported as "Version mismatch", which pointed in the wrong
direction.

**Fix:** none. If the warning appears on *every* configure, the clone aborts
reproducibly — then check the network connection or the disk space.

---

#### W304 — Archive external not available

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | v0.10.0 |

**Message:**
```
[W304] Archive external 'sichttest' is not available - targets build without it
```

**Description:** The package could not be obtained from any source (cache empty, no network,
no match in the fallback paths, checksum or version does not match). Immediately before it
there is a `[CraftPackage]` warning that names every source tried, with the reason.

The build continues: targets that name the external get neither include path nor define nor
runtime files.

**Fix:** Restore the network, put the archive into a fallback path, or set
`-D<NAME>_LOCAL_DIR=<unpacked package>` — see [Packages.md](Packages.md) §3.4.

---

### 4.5 W4xx — App Container Warnings

#### W401 — App has no include/ directory

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | v0.2.0 (Phase 8) |

**Description:** The app container directory has no `include/` for public headers.

**Further trigger:** `[W401] App '<name>': tests.targets is empty` (`AppCollect.cmake:338`).

---

#### W402 — PCH enabled but header not found

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | v0.2.0 (Phase 8) |

**Description:** The precompiled header is enabled, but the specified header file does not exist.

**Further trigger:** a test target with `parallel: true` whose type usually runs serially
(`[W402] App '<name>': Test '<test>' (type '<type>') has parallel=true. …`, `AppCollect.cmake:435`).

---

#### W403 — Tests directory exists but no sources

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | v0.2.0 (Phase 8) |

**Description:** A `tests/` directory exists in the app container but contains no test files.

**Messages:**
```
[W403] App 'MyApp': tests.targets configured but no tests/ directory
[W403] Test 'MyApp.UnitTests': No source files found
```

---

### 4.6 W5xx — System External Warnings

#### W501 — Backup path used

| Aspect | Value |
|--------|-------|
| **Severity** | ⚠️ WARNING |
| **Since** | v0.2.0 |

**Message** (`cmake/externals/system/Handler.cmake:245`):
```
[W501] [qt6] Using backup location: C:/Qt/6.8.0/msvc2022_64
  Consider setting Qt6_ROOT environment variable.
```

**Description:** Primary path not found, the backup path is used.

---

### 4.7 W6xx–W9xx — Phase Test Warnings

Only in the self-test (`RUN_BUILD_SYSTEM_TESTS=ON`, preset `craft-selftest`); files under
`cmake/buildSystemTest/`. They indicate that a check step could not run, or not completely.

| Code | File | Message | Meaning |
|------|------|---------|---------|
| W601 | `phase6.cmake:36`, `:213` | `GLFW target not found - may not be used by any executable` / `Phase 6: could not create the test repository - clone detection not verified` | Git external test: target `glfw` missing, or the test repository for clone detection could not be created |
| W602 | `phase6.cmake:117` | `SOLUTION_EXTERNALS_JSON not set` | externals block not loaded, check skipped |
| W701 | `phase7.cmake:77` | `SOLUTION_JSON not available` | Solution.json not loaded, phase 7 skipped |
| W801 | `phase8.cmake:75` | `SOLUTION_JSON not available` | Solution.json not loaded, phase 8 (app container) skipped |
| W802 | `phase8.cmake:253` | `Core library should be STATIC, found: <type>` | `<App>.Core` is not a STATIC library |
| W803 | `phase8.cmake:289` | `Runner does not link against Core` | The app executable does not link `<App>.Core` |
| W901 | `phase9.cmake:121` | `System external '<name>' missing 'package' field` | System external without `package` |
| W902 | `phase9.cmake:217` | `<n> external(s) have conflicting type fields` | Externals with more than one of `system`, `git`, `path` |
| W999 | `phase1.cmake:120`, `phase3.cmake:68`, `:235` | `Test warning (expected, can be ignored)` and others | Probe warning of phase 1 (expected); phase 3: no executables defined or no targets created |

---

## 5. Quick Reference

### 5.1 Fatal Errors (E)

| Code | Category | Description |
|------|----------|-------------|
| E001 | JSON | Required field missing |
| E002 | JSON | Solution.json not found |
| E003 | JSON | Schema version incompatible (major) |
| E004 | JSON | Invalid value in the settings block |
| E005 | Setup | Top-level CMakeLists.txt without project() |
| E010 | JSON | External not in the externals block |
| E012 | JSON | No/multiple source fields |
| E013 | External | Skipped external used |
| E101 | Target | Dependency does not exist |
| E102 | Target | Target already exists |
| E103 | Target | Circular dependency (currently not raised) |
| E104 | Target | Source.cmake not found (mode=explicit) |
| E105 | Target | compile_options on an INTERFACE library |
| E106 | Target | Source package cannot be expressed in plain CMake |
| E201 | External | Fetched external: no target in registry |
| E202 | External | External fetch failed |
| E203 | External | Target of an external not found |
| E213 | External | Local external: Include.cmake missing |
| E214 | External | Local external: path does not exist |
| E215 | External | Fetched external: no tag/branch/commit |
| E216 | External | Explicitly specified hook missing |
| E217 | External | PostFetch hook required (cmakeSupport=false; currently not raised, reported as E201) |
| E218 | External | Not cached and offline mode enabled |
| E219 | External | Cache directory cannot be removed |
| E220 | External | Archive external: field `pin` missing |
| E301 | Test | Unknown test framework |
| E302 | Test | source_from executable does not exist |
| E303 | Test | Test source directory not found |
| E304 | Test | App test target without type |
| E305 | Test | Path of an app test target does not exist |
| E400 | AppContainer | App definition without name (collect phase) |
| E401 | AppContainer | name is a required field |
| E402 | AppContainer | App path does not exist |
| E403 | AppContainer | No src/ directory |
| E404 | AppContainer | No sources in src/ |
| E405 | AppContainer | Dependency not found |
| E406 | AppContainer | No main/ directory |
| E407 | AppContainer | No sources in main/ |
| E502 | System | package field missing |
| E503 | System | find_package failed |
| E504 | System | Component not found |
| E505 | System | Version not satisfied |

### 5.2 Warnings (W)

| Code | Category | Description |
|------|----------|-------------|
| W001 | Deprecation | Outdated schema (currently not raised) |
| W002 | Deprecation | Outdated syntax/field (currently not raised) |
| W101 | Config | Schema version too low |
| W102 | Config | Schema version too high |
| W103 | Config | Include.cmake creates executables |
| W104 | Config | Include.cmake includes example directories |
| W105 | Config | Version not SemVer-compliant (currently not raised) |
| W109 | Config | C++20 modules used (experimental) |
| W110 | Config | GLOB fallback active |
| W111 | Config | Source.cmake present but empty |
| W112 | Config | Package names a target that does not exist |
| W201 | Tools | Clang-Tidy not found |
| W301 | Caching | External from cache (offline mode; currently not raised) |
| W302 | Caching | Version differs, offline mode uses the cache |
| W303 | Caching | Incomplete clone in the cache — removed and fetched again |
| W304 | Externals | Archive external not available — targets build without it |
| W401 | AppContainer | No include/ directory |
| W402 | AppContainer | PCH header not found |
| W403 | AppContainer | Tests directory without sources |
| W501 | System | Backup path used |
| W601–W999 | Phase tests | Warnings of the self-tests, see §4.7 |

---

## 6. Usage in Code

```cmake
include("${CMAKECRAFT_DIR}/core/Errors.cmake")

# Raise an error (build aborts)
cmake_fatal("E002" "Solution.json not found: ${_solution_file}")

# Multi-part message: all parts after CODE are joined without separator,
# also parts with a semicolon (since Errors.cmake 1.1.0, CMakeCraft v0.14.1)
cmake_fatal("E012"
    "External '${EXT_NAME}': Multiple source fields specified: ${_found_fields}\n"
    "  Only one source field is allowed.")

# Raise a warning (build continues)
cmake_warn("W201" "ENABLE_CLANG_TIDY=ON but clang-tidy not found for target '${TARGET_NAME}'")

# Assertion (should never occur)
cmake_assert(condition "Internal error: invalid state")
```

---

## 7. See Also

- [Errors.cmake](../module/core/Errors.md) — Error module documentation
- [Debug.cmake](../module/core/Debug.md) — Debug system
- [Solution_Schema.md](Solution_Schema.md) — JSON schema reference

---

## 8. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.6.1** | **2026-11-09** | **Aligned with the code: messages of E001, E002, E003, E010, E012, E201, E301–E303, E401, W101, W102, W303, W403 verbatim; E003 with schema `1.0` (`cmake/project/Solution.cmake:50`); further triggers of E003, E302, E303, W101, W401, W402; E203, E304, E305, E400, W111 and the phase test warnings W601–W999 (§4.7) added; E217 hook path in lower case; §6 with three-digit codes. CMakeCraft v0.14.1: E501 and W502 dropped; E503 with the three variants from `system/Handler.cmake`, E504 and E505 raised and with message; messages of E502 and W501; E103, E217, W001, W002, W105 (W106–W108) and W301 marked as currently not raised; §6 with a multi-part message** |
| **1.6.0** | **2026-11-07** | **E105 (compile_options on an INTERFACE library) and E106 (source package cannot be expressed) added, CMakeCraft v0.14.0** |
| 1.5.0 | 2026-10-24 | **E005 added (top-level CMakeLists.txt without project(), CMakeCraft v0.13.0)** |
| 1.4.0 | 2026-10-23 | E004 added (invalid value in the settings block, CMakeCraft v0.12.0) |
| **1.3.0** | **2026-10-09** | **E220, W112 and W304 added (packages and archive externals, CMakeCraft v0.10.0)** |
| 1.2.0 | 2026-08-08 | E219 and W303 (incomplete clone in the cache) added; E218 documented retroactively; W302 description corrected to match the code (until then it described "hook reuse") |
| 1.1.0 | 2025-12-28 | E003 (schema major incompatible), W101/W102 (schema minor warnings) added |
| 1.0.0 | 2025-12-14 | Blueprint v0.5.0 format: numbered TOC, E3xx (tests), E4xx/W4xx (AppContainer), E5xx/W5xx (system externals), W3xx (caching) |
| 0.1.1 | 2025-12-09 | E217 added (PostFetch hook required for cmakeSupport=false) |
| 0.1.0 | 2025-12-03 | Initial (clean start): all codes from v1.4 |
