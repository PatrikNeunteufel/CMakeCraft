# System Externals — Concept

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Concept  
> **Status:** Implemented ✅  
> **Phase:** 9 (completed)  
> **Target Audience:** Build System Developers, Architects  
> **Language:** English  
> **German:** [System_Externals_Concept.md](../../../de/konzepte/abgeschlossen/System_Externals_Concept.md)

---

## Table of Contents

1. [Problem Statement](#1-problem-statement)
2. [Solution: System External Type](#2-solution-system-external-type)
3. [Type Detection](#3-type-detection)
4. [Path Resolution](#4-path-resolution)
5. [Implementation](#5-implementation)
6. [Examples](#6-examples)
7. [Error Codes](#7-error-codes)
8. [Migration](#8-migration)
9. [Open Points](#9-open-points)
10. [See Also](#10-see-also)
11. [Changelog](#11-changelog)

---

## 1. Problem Statement

### 1.1 Current External Types

The build system supports two external types:

| Type | Detection field | Storage location | Example |
|-----|----------------|-------------|----------|
| **Local** | `path` | `externals/` in the repo | bass, glad, doctest |
| **Fetched** | `git` | `.externals/` (cached) | glfw, imgui, spdlog |

### 1.2 The Problem with Large Libraries

Libraries such as **Qt6**, **Boost**, **OpenCV**, **CUDA** do not fit into this scheme:

| Problem | Description |
|---------|--------------|
| **Too large** | Qt6 > 5 GB — not practicable for `externals/` |
| **Already installed** | Often already present on the system |
| **Different paths** | Every developer has Qt installed somewhere else |
| **External drives** | Sometimes on D:/, E:/, USB, NAS |

### 1.3 Current Workaround

```json
"qt6": {
    "path": "externals/qt6",
    "options": {
        "hint": "${QT_ROOT}"
    }
}
```

**Disadvantages:**

- ❌ `path` does not point to real files (semantically wrong)
- ❌ The folder `externals/qt6/` must exist (only for Include.cmake)
- ❌ The path search must be implemented manually in Include.cmake

---

## 2. Solution: System External Type

### 2.1 New External Type

A **system external** is a library that:
- Is already installed on the system
- Is found via CMake's `find_package()`
- Is not downloaded or copied into the repo

### 2.2 JSON Syntax

```json
"externals": {
    "qt6": {
        "system": true,
        "package": "Qt6",
        "components": ["Core", "Widgets", "Gui"]
    }
}
```

### 2.3 All Fields

| Field | Type | Required | Default | Description |
|------|-----|---------|---------|--------------|
| `system` | bool | ✅ | — | Must be `true` |
| `package` | string | ✅ | — | Name for `find_package()` |
| `version` | string | — | — | Version constraint (e.g. `">=6.5.0"`) |
| `components` | string[] | — | `[]` | Package components |
| `hints` | string[] | — | `[]` | Additional search paths |
| `backup` | string | — | — | Emergency path (with warning) |
| `required` | bool | — | `true` | Error if not found |

**Important:** `system` and `package` are required **only together**. If `system: true` is set, `package` must also be specified.

---

## 3. Type Detection

### 3.1 The Three External Types

The build system detects the type from the **first detection field present**:

```
┌─────────────────────────────────────────────────────────────────┐
│                    External definition                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │   Has "system": true ?        │
              └───────────────────────────────┘
                     │                │
                    Yes               No
                     │                │
                     ▼                ▼
            ┌─────────────┐  ┌───────────────────────────┐
            │   SYSTEM    │  │   Has "git" field?        │
            │   External  │  └───────────────────────────┘
            └─────────────┘         │                │
                                   Yes               No
                                    │                │
                                    ▼                ▼
                           ┌─────────────┐  ┌───────────────────────────┐
                           │   FETCHED   │  │   Has "path" field?       │
                           │   External  │  └───────────────────────────┘
                           └─────────────┘         │                │
                                                  Yes               No
                                                   │                │
                                                   ▼                ▼
                                          ┌─────────────┐  ┌─────────────┐
                                          │    LOCAL    │  │   ERROR     │
                                          │   External  │  │   E012      │
                                          └─────────────┘  └─────────────┘
```

### 3.2 Required Fields per Type

| Type | Required fields | Example |
|-----|---------------|----------|
| **Local** | `path` | `"bass": { "path": "externals/bass" }` |
| **Fetched** | `git` + version* | `"glfw": { "git": "...", "tag": "3.4" }` |
| **System** | `system` + `package` | `"qt6": { "system": true, "package": "Qt6" }` |

*Version = `tag`, `branch` or `commit`

### 3.3 Mutual Exclusion

An external can have **only one type**:

```json
// ❌ WRONG: several type fields
"bad": {
    "system": true,
    "path": "externals/bad"    // Conflict!
}

// ✅ CORRECT: exactly one type
"qt6": {
    "system": true,
    "package": "Qt6"
}
```

---

## 4. Path Resolution

### 4.1 The Problem: Where Is Qt Installed?

Different developers have Qt in different locations:

| Developer | Qt installation |
|------------|-----------------|
| Alice | `C:/Qt/6.7.0/msvc2022_64` |
| Bob | `D:/Tools/Qt/6.7.0/msvc2022_64` |
| Charlie | `E:/Libs/Qt/6.7.0/msvc2022_64` |
| CI server | `/opt/Qt/6.7.0/gcc_64` |

CMake's `find_package(Qt6)` only searches in standard locations. If Qt is installed somewhere else, it finds nothing.

### 4.2 Solution: Multi-Stage Search

The system searches in this order:

```
┌─────────────────────────────────────────────────────────────────┐
│ STAGE 1: Environment variables (set by the developer)           │
│          $QT_ROOT, $QT_DIR, $QT_HOME                            │
│          → Every developer sets their own variable              │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 2: CMAKE_PREFIX_PATH                                      │
│          → If set in CMake presets or on the command line       │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 3: hints[] from Solution.json                             │
│          → The project specifies known paths                    │
│          → Helpful for a team with similar setups               │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 4: Standard paths (platform-specific)                     │
│          → C:/Qt/..., /opt/Qt/..., ~/Qt/...                     │
│          → Typical installation locations                       │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 5: backup path (with warning)                             │
│          → Emergency solution, e.g. external drive              │
│          → Shows warning: "Please install properly"             │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 6: Error                                                  │
│          → Clear error message with suggested solutions         │
└─────────────────────────────────────────────────────────────────┘
```

### 4.3 When Do I Need What?

| Situation | Recommended solution |
|-----------|-------------------|
| **Just me** | Set an environment variable (`QT_ROOT`) |
| **Team with similar setups** | `hints[]` in Solution.json |
| **CI/CD** | Environment variable in the CI system |
| **Emergency (external drive)** | `backup` path |

### 4.4 Example: Complete Configuration

```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "components": ["Core", "Widgets"],
    "hints": [
        "${QT_ROOT}",                        // 1. Environment variable
        "C:/Qt/6.7.0/msvc2022_64",          // 2. Windows standard
        "D:/Tools/Qt/6.7.0/msvc2022_64"     // 3. Alternative
    ],
    "backup": "E:/Backup/Qt/6.7.0/msvc2022_64"  // 4. Emergency
}
```

**What happens:**

1. **Alice** has set `QT_ROOT=C:/Qt/6.7.0/msvc2022_64` → Found ✅
2. **Bob** has no QT_ROOT, but Qt in `D:/Tools/...` → Found via hint ✅
3. **Charlie** has Qt only on E:/ → Found via backup ⚠️ (with warning)
4. **Dave** has no Qt → Clear error with help text ❌

### 4.5 Minimal Configuration

For simple cases this is enough:

```json
"boost": {
    "system": true,
    "package": "Boost",
    "components": ["filesystem", "system"]
}
```

→ Searches only via environment variable and standard paths

---

## 5. Implementation

### 5.1 Architecture Overview

#### Before (Workaround with a Local External)

```
Solution.json                    cmake/externals/
     │                                │
     ▼                                ▼
"qt6": {                         includes/qt6/Include.cmake
    "path": "externals/qt6"  ───────────────────────────────┐
}                                                            │
     │                                                       │
     ▼                                                       ▼
Orchestrator.cmake              Does EVERYTHING:
     │                          - Path resolution (ENV, hints, backup)
     ▼                          - find_package(Qt6)
local/Attach.cmake              - Standard paths (C:/Qt/...)
     │                          - AUTOMOC/AUTOUIC/AUTORCC
     ▼                          - windeployqt/macdeployqt
❌ Checks whether externals/qt6/ - Target creation
   exists (pointless!)
```

**Problems:**
- An empty folder `externals/qt6/` must exist
- Every Include.cmake reimplements path resolution
- No uniform error handling
- Semantically wrong (`path` points to nothing)

#### After (System External)

```
Solution.json                    cmake/externals/
     │                                │
     ▼                                ▼
"qt6": {                         system/
    "system": true,              ├── Handler.cmake ◄────────────────┐
    "package": "Qt6",            │   (generic)                      │
    "components": [...]          │   - Parse JSON                   │
}                                │   - Call PathResolver            │
     │                           │   - find_package()               │
     ▼                           │   - Load package hook            │
Orchestrator.cmake               │                                  │
     │                           ├── PathResolver.cmake             │
     ▼                           │   (generic)                      │
system/Handler.cmake ────────────┤   - Check ENV variables          │
                                 │   - Search hints[]               │
                                 │   - Standard paths               │
                                 │   - backup with warning          │
                                 │                                  │
                                 └── packages/                      │
                                     └── Qt6.cmake ◄────────────────┘
                                         (Qt-specific)
                                         - Standard paths for Qt
                                         - AUTOMOC/AUTOUIC/AUTORCC
                                         - windeployqt/macdeployqt
```

**Advantages:**
- No empty folder needed
- Path resolution implemented once, used everywhere
- Uniform error codes (E5xx, W5xx)
- Semantically correct (`system: true`)
- Package-specific logic optional and isolated

### 5.2 New Files

```
cmake/externals/
├── system/
│   ├── Handler.cmake       # Generic system external handler
│   ├── PathResolver.cmake  # Generic path resolution
│   └── packages/           # Package-specific hooks (optional)
│       ├── Qt6.cmake       # AUTOMOC, windeployqt, Qt paths
│       ├── Boost.cmake     # Boost-specific logic
│       └── OpenCV.cmake    # OpenCV-specific logic
├── includes/               # REMAINS for local externals
│   ├── bass/Include.cmake  # Unchanged
│   ├── glad/Include.cmake  # Unchanged
│   └── qt6/Include.cmake   # → DEPRECATED (migration to system)
└── Orchestrator.cmake      # Extended by the system type
```

### 5.3 What Becomes Generic vs. Package-Specific?

| Function | Generic (Handler/PathResolver) | Package hook |
|----------|----------------------------------|--------------|
| Parse JSON | ✅ | — |
| Check environment variables | ✅ `${PACKAGE}_ROOT` | — |
| Search hints[] | ✅ | — |
| Standard paths | ⚠️ Base list | ✅ Extended list |
| backup with warning | ✅ | — |
| Call find_package() | ✅ | — |
| Error handling (E5xx) | ✅ | — |
| AUTOMOC/AUTOUIC/AUTORCC | — | ✅ Qt6.cmake |
| windeployqt/macdeployqt | — | ✅ Qt6.cmake |
| Boost namespace handling | — | ✅ Boost.cmake |
| OpenCV CUDA config | — | ✅ OpenCV.cmake |

### 5.4 Package Hook Mechanism

> **Code today (2026-11-09):** The concept code in §5.4–5.6 loads modules via `${CMAKE_SOURCE_DIR}/cmake/…` and `include(cmake/…)`. Since v0.7.0 all module paths go through `${CMAKECRAFT_DIR}` (`CMakeCraft.cmake:133`), e.g. `${CMAKECRAFT_DIR}/externals/system/packages/${_package}.cmake` (`cmake/externals/system/Handler.cmake:210`) and `include("${CMAKECRAFT_DIR}/externals/system/Handler.cmake")` (`cmake/externals/Orchestrator.cmake:48`).

Package hooks are **optional**. They are loaded automatically if present:

```cmake
# In Handler.cmake
function(_handle_system_external EXT_NAME EXT_JSON)
    # ... generic logic ...
    
    # Load package hook (if present)
    set(_package_hook "${CMAKE_SOURCE_DIR}/cmake/externals/system/packages/${_package}.cmake")
    if(EXISTS "${_package_hook}")
        dbg(${DBG_RARE} "[${EXT_NAME}] Loading package hook: ${_package}.cmake" ID EXTERNALS)
        include("${_package_hook}")
    endif()
endfunction()
```

#### Example: Qt6.cmake Package Hook

```cmake
# cmake/externals/system/packages/Qt6.cmake
# Called after find_package(Qt6)

# Qt-specific standard paths (extends PathResolver)
function(_get_qt6_standard_paths OUT_VAR)
    set(_paths "")
    if(WIN32)
        list(APPEND _paths
            "C:/Qt/6.8.0/msvc2022_64"
            "C:/Qt/6.7.0/msvc2022_64"
            "D:/Qt/6.8.0/msvc2022_64"
        )
    elseif(APPLE)
        list(APPEND _paths
            "$ENV{HOME}/Qt/6.8.0/macos"
            "/opt/homebrew/opt/qt@6"
        )
    else()
        list(APPEND _paths
            "$ENV{HOME}/Qt/6.8.0/gcc_64"
            "/opt/Qt/6.8.0/gcc_64"
        )
    endif()
    set(${OUT_VAR} "${_paths}" PARENT_SCOPE)
endfunction()

# Enable AUTOMOC/AUTOUIC/AUTORCC for a target
function(_qt6_configure_target TARGET_NAME)
    if(TARGET ${TARGET_NAME})
        set_target_properties(${TARGET_NAME} PROPERTIES
            AUTOMOC ON
            AUTOUIC ON
            AUTORCC ON
        )
    endif()
endfunction()

# Configure deployment
function(_qt6_configure_deployment TARGET_NAME)
    if(WIN32)
        find_program(_WINDEPLOYQT windeployqt HINTS "${Qt6_DIR}/../../../bin")
        if(_WINDEPLOYQT)
            add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
                COMMAND "${_WINDEPLOYQT}" --no-translations "$<TARGET_FILE:${TARGET_NAME}>"
                COMMENT "[qt6] Running windeployqt..."
            )
        endif()
    endif()
endfunction()
```

### 5.5 Orchestrator.cmake Extension

```cmake
# cmake/externals/Orchestrator.cmake (extended)

include_guard(GLOBAL)

include(cmake/externals/local/Attach.cmake)
include(cmake/externals/fetched/Handler.cmake)
include(cmake/externals/system/Handler.cmake)  # NEW

function(_orchestrate_external EXT_NAME EXT_JSON)
    
    # Validate: Exactly one source field
    validate_external_source("${EXT_NAME}" "${EXT_JSON}")
    
    # Detect Type (order: system → git → path)
    _json_get_bool_or_default("${EXT_JSON}" "system" FALSE _is_system)
    _json_has_key("${EXT_JSON}" "git" _is_fetched)
    _json_has_key("${EXT_JSON}" "path" _is_local)
    
    # Dispatch
    if(_is_system)
        dbg(${DBG_RARE} "  Type: SYSTEM" ID EXTERNALS)
        _handle_system_external("${EXT_NAME}" "${EXT_JSON}")
        
    elseif(_is_fetched)
        dbg(${DBG_RARE} "  Type: FETCHED (git)" ID EXTERNALS)
        _handle_fetched_external("${EXT_NAME}" "${EXT_JSON}")
        
    elseif(_is_local)
        dbg(${DBG_RARE} "  Type: LOCAL" ID EXTERNALS)
        _attach_local_external("${EXT_NAME}" "${EXT_JSON}")
        
    else()
        cmake_fatal("E012" 
            "External '${EXT_NAME}': Kein gültiger Typ.\n"
            "  Benötigt eines von:\n"
            "    - 'system: true' + 'package' (System External)\n"
            "    - 'git' + 'tag/branch/commit' (Fetched External)\n"
            "    - 'path' (Local External)"
        )
    endif()
    
endfunction()
```

> **Code today (2026-11-09):** The E012 message today reads `External '${EXT_NAME}': No valid source field (system/git/path/archive)` (`cmake/externals/Orchestrator.cmake:115`); the orchestrator also knows the type `archive`.

### 5.6 system/Handler.cmake

```cmake
# cmake/externals/system/Handler.cmake
# =====================================
# System External Handler - finds system-installed packages

include_guard(GLOBAL)
include(cmake/externals/system/PathResolver.cmake)

function(_handle_system_external EXT_NAME EXT_JSON)
    dbg(${DBG_COMMON} "[${EXT_NAME}] Processing system external" ID EXTERNALS)
    
    # =========================================================================
    # Required field: package
    # =========================================================================
    
    _json_get_string("${EXT_JSON}" "package" _package)
    if("${_package}" STREQUAL "")
        cmake_fatal("E502" "System external '${EXT_NAME}': 'package' field is required")
    endif()
    
    # =========================================================================
    # Optional fields
    # =========================================================================
    
    _json_get_string("${EXT_JSON}" "version" _version)
    _json_get_array_as_list("${EXT_JSON}" "components" _components)
    _json_get_array_as_list("${EXT_JSON}" "hints" _hints)
    _json_get_string("${EXT_JSON}" "backup" _backup)
    _json_get_bool_or_default("${EXT_JSON}" "required" TRUE _required)
    
    # =========================================================================
    # Load package hook for standard paths (if present)
    # =========================================================================
    
    set(_package_hook "${CMAKE_SOURCE_DIR}/cmake/externals/system/packages/${_package}.cmake")
    set(_additional_paths "")
    
    if(EXISTS "${_package_hook}")
        include("${_package_hook}")
        # The hook can define _get_${_package}_standard_paths()
        if(COMMAND _get_${_package}_standard_paths)
            cmake_language(CALL _get_${_package}_standard_paths _additional_paths)
        endif()
    endif()
    
    # =========================================================================
    # Resolve path
    # =========================================================================
    
    _resolve_system_path(
        "${EXT_NAME}" 
        "${_package}" 
        "${_hints}" 
        "${_additional_paths}"
        "${_backup}" 
        _resolved_path 
        _used_backup
    )
    
    # Warning when the backup is used
    if(_used_backup)
        cmake_warn("W501" 
            "[${EXT_NAME}] Using backup location: ${_resolved_path}\n"
            "  Consider setting ${_package}_ROOT environment variable."
        )
    endif()
    
    # =========================================================================
    # Extend CMAKE_PREFIX_PATH
    # =========================================================================
    
    if(NOT "${_resolved_path}" STREQUAL "")
        list(PREPEND CMAKE_PREFIX_PATH "${_resolved_path}")
        set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}" PARENT_SCOPE)
    endif()
    
    # =========================================================================
    # Call find_package
    # =========================================================================
    
    if(_required)
        set(_req_flag REQUIRED)
    else()
        set(_req_flag "")
    endif()
    
    if(_components)
        find_package(${_package} ${_version} ${_req_flag} COMPONENTS ${_components})
    else()
        find_package(${_package} ${_version} ${_req_flag})
    endif()
    
    # Check success
    if(${_package}_FOUND)
        dbg(${DBG_COMMON} "[${EXT_NAME}] Found ${_package} ${${_package}_VERSION}" ID EXTERNALS)
        
        # Call the package hook for post-setup (AUTOMOC etc.)
        if(COMMAND _${_package}_post_find)
            cmake_language(CALL _${_package}_post_find)
        endif()
        
    elseif(_required)
        cmake_fatal("E503" "System external '${EXT_NAME}': find_package(${_package}) failed")
    else()
        dbg(${DBG_COMMON} "[${EXT_NAME}] ${_package} not found (optional)" ID EXTERNALS)
    endif()
    
    # =========================================================================
    # Register as system external
    # =========================================================================
    
    set_property(GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_TYPE "SYSTEM")
    set_property(GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_PACKAGE "${_package}")
    set_property(GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_REGISTERED TRUE)
    
endfunction()
```

### 5.7 system/PathResolver.cmake

```cmake
# cmake/externals/system/PathResolver.cmake
# ==========================================
# Generic path resolution for system externals

include_guard(GLOBAL)

function(_resolve_system_path EXT_NAME PACKAGE HINTS ADDITIONAL_PATHS BACKUP OUT_PATH OUT_IS_BACKUP)
    set(_found FALSE)
    set(_result_path "")
    set(_is_backup FALSE)
    
    # =========================================================================
    # Stage 1: Environment variables
    # =========================================================================
    
    foreach(_var_suffix ROOT DIR HOME)
        set(_var_name "${PACKAGE}_${_var_suffix}")
        if(DEFINED ENV{${_var_name}})
            set(_candidate "$ENV{${_var_name}}")
            if(EXISTS "${_candidate}")
                set(_found TRUE)
                set(_result_path "${_candidate}")
                dbg(${DBG_RARE} "[${EXT_NAME}] Found via ${_var_name}: ${_candidate}" ID EXTERNALS)
                break()
            endif()
        endif()
    endforeach()
    
    # =========================================================================
    # Stage 2: hints[] from Solution.json
    # =========================================================================
    
    if(NOT _found AND HINTS)
        foreach(_hint IN LISTS HINTS)
            # Expand environment variables
            string(CONFIGURE "${_hint}" _hint_expanded @ONLY)
            if(EXISTS "${_hint_expanded}")
                set(_found TRUE)
                set(_result_path "${_hint_expanded}")
                dbg(${DBG_RARE} "[${EXT_NAME}] Found via hint: ${_hint_expanded}" ID EXTERNALS)
                break()
            endif()
        endforeach()
    endif()
    
    # =========================================================================
    # Stage 3: Package-specific standard paths
    # =========================================================================
    
    if(NOT _found AND ADDITIONAL_PATHS)
        foreach(_path IN LISTS ADDITIONAL_PATHS)
            if(EXISTS "${_path}")
                set(_found TRUE)
                set(_result_path "${_path}")
                dbg(${DBG_RARE} "[${EXT_NAME}] Found at standard path: ${_path}" ID EXTERNALS)
                break()
            endif()
        endforeach()
    endif()
    
    # =========================================================================
    # Stage 4: Backup (with warning)
    # =========================================================================
    
    if(NOT _found AND NOT "${BACKUP}" STREQUAL "")
        string(CONFIGURE "${BACKUP}" _backup_expanded @ONLY)
        if(EXISTS "${_backup_expanded}")
            set(_found TRUE)
            set(_result_path "${_backup_expanded}")
            set(_is_backup TRUE)
        endif()
    endif()
    
    # =========================================================================
    # Result
    # =========================================================================
    
    if(_found)
        set(${OUT_PATH} "${_result_path}" PARENT_SCOPE)
        set(${OUT_IS_BACKUP} ${_is_backup} PARENT_SCOPE)
    else()
        # No fatal error here - find_package() will report it later
        # This allows find_package() to use its own search logic
        set(${OUT_PATH} "" PARENT_SCOPE)
        set(${OUT_IS_BACKUP} FALSE PARENT_SCOPE)
        dbg(${DBG_RARE} "[${EXT_NAME}] No path found, relying on find_package()" ID EXTERNALS)
    endif()
    
endfunction()
```

### 5.8 Validation.cmake Extension

The existing validation must be extended:

```cmake
# cmake/core/Validation.cmake

# Extend the list of source fields
function(validate_external_source EXT_NAME EXT_JSON)
    # EXTENDED: "system" added
    set(_source_fields "path;git;system;vcpkg;conan;find_package")
    set(_found_count 0)
    set(_found_fields "")
    
    foreach(_field IN LISTS _source_fields)
        _json_has_key("${EXT_JSON}" "${_field}" _has)
        if(_has)
            math(EXPR _found_count "${_found_count} + 1")
            list(APPEND _found_fields "${_field}")
        endif()
    endforeach()
    
    if(_found_count EQUAL 0)
        cmake_fatal("E012" 
            "External '${EXT_NAME}': No source field specified.\n"
            "  Required: one of 'system', 'git', or 'path'"
        )
    elseif(_found_count GREATER 1)
        cmake_fatal("E012" 
            "External '${EXT_NAME}': Multiple source fields specified: ${_found_fields}\n"
            "  Only one source field is allowed."
        )
    endif()
    
    # System external: additional validation
    _json_has_key("${EXT_JSON}" "system" _has_system)
    if(_has_system)
        _json_get_bool_or_default("${EXT_JSON}" "system" FALSE _is_system)
        if(_is_system)
            _json_has_key("${EXT_JSON}" "package" _has_package)
            if(NOT _has_package)
                cmake_fatal("E502" 
                    "System external '${EXT_NAME}': 'package' field is required.\n"
                    "  Example: { \"system\": true, \"package\": \"Qt6\" }"
                )
            endif()
        endif()
    endif()
endfunction()
```

---

## 6. Examples

### 6.1 Qt6 (Complete)

```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "version": ">=6.5.0",
    "components": ["Core", "Widgets", "Gui", "OpenGL"],
    "hints": [
        "${QT_ROOT}",
        "C:/Qt/6.7.0/msvc2022_64"
    ],
    "backup": "E:/Backup/Qt/6.7.0/msvc2022_64"
}
```

### 6.2 Boost (Minimal)

```json
"boost": {
    "system": true,
    "package": "Boost",
    "components": ["filesystem", "system", "thread"]
}
```

### 6.3 OpenCV

```json
"opencv": {
    "system": true,
    "package": "OpenCV",
    "version": ">=4.5.0",
    "hints": ["${OPENCV_DIR}"]
}
```

### 6.4 Optional (Not Required)

```json
"cuda": {
    "system": true,
    "package": "CUDAToolkit",
    "required": false
}
```

→ No error if not found; code can check with `if(CUDAToolkit_FOUND)`

---

## 7. Error Codes

### 7.1 System External Errors (E5xx)

| Code | Description |
|------|--------------|
| E501 | System external not found (no valid path) |
| E502 | System external: 'package' field is required |
| E503 | System external: find_package() failed |
| E504 | System external: required component not found |
| E505 | System external: version constraint not satisfied |

### 7.2 System External Warnings (W5xx)

| Code | Description |
|------|--------------|
| W501 | Using backup location for system external |
| W502 | System external version mismatch (using found version) |

> **Code today (2026-11-09, CMakeCraft v0.14.1):** Raised are E502 (`cmake/core/Validation.cmake:94`, `cmake/externals/system/Handler.cmake:180`), E503 (`Handler.cmake:101`, `:120`, `:128`, `:331`), E504 (`:91`), E505 (`:109`) and W501 (`:245`). `find_package()` runs without `REQUIRED` (`:270`, `:273`); the cause of a failure is named by `_system_external_not_found()`. E501 and W502 are dropped. The self-test checks E503–E505 (`cmake/buildSystemTest/phase9.cmake:498–609`).

---

## 8. Migration

### 8.1 Overview: What Happens to Existing Files?

| File | Status after Phase 9 | Action |
|-------|---------------------|--------|
| `cmake/externals/includes/qt6/Include.cmake` | ⚠️ DEPRECATED | Migrate to `system` |
| `cmake/externals/includes/bass/Include.cmake` | ✅ Unchanged | Remains (real local external) |
| `cmake/externals/includes/glad/Include.cmake` | ✅ Unchanged | Remains (real local external) |
| `externals/qt6/` (empty folder) | ❌ Delete | No longer needed |
| `externals/bass/` (with files) | ✅ Unchanged | Remains (real local external) |

### 8.2 Decision Aid: Local vs. System External

```
                        Is the library in the repository?
                                    │
                    ┌───────────────┴───────────────┐
                    │                               │
                   Yes                              No
                    │                               │
                    ▼                               ▼
            ┌───────────────┐               Is it found with find_package()?
            │    LOCAL      │                       │
            │   External    │           ┌───────────┴───────────────┐
            │               │           │                           │
            │ "path": "..." │          Yes                          No
            └───────────────┘           │                           │
                                        ▼                           ▼
                                ┌───────────────┐           ┌───────────────┐
                                │    SYSTEM     │           │    FETCHED    │
                                │   External    │           │   External    │
                                │               │           │               │
                                │ "system":true │           │ "git": "..."  │
                                └───────────────┘           └───────────────┘
```

### 8.3 Migration: Qt6 (Workaround → System External)

#### Step 1: Change Solution.json

**Before (workaround):**
```json
"qt6": {
    "path": "externals/qt6",
    "options": {
        "hint": "${QT_ROOT}",
        "components": ["Core", "Widgets"]
    }
}
```

**After (system external):**
```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "components": ["Core", "Widgets"],
    "hints": ["${QT_ROOT}"]
}
```

#### Step 2: Delete the Empty Folder

```bash
# The folder was only needed for the workaround
rm -rf externals/qt6/
```

#### Step 3: Include.cmake (Optionally Keep)

The old `cmake/externals/includes/qt6/Include.cmake` is **no longer called**.

Instead, the package hook is loaded (if present):
`cmake/externals/system/packages/Qt6.cmake`

**Option A:** Delete Include.cmake, use the package hook (recommended)
**Option B:** Rename/move Include.cmake to the package hook

### 8.4 Comparison: Before vs. After

| Aspect | Workaround (path) | System external |
|--------|-------------------|-----------------|
| **Semantics** | ❌ `path` points to an empty folder | ✅ `system: true` is clear |
| **Folder needed** | ❌ `externals/qt6/` (empty) | ✅ No |
| **Path resolution** | ❌ In every Include.cmake | ✅ Once in PathResolver.cmake |
| **Error handling** | ❌ Individual | ✅ Uniform (E5xx) |
| **Backup support** | ❌ Implemented manually | ✅ Integrated with W501 |
| **Version check** | ❌ Implemented manually | ✅ Integrated |
| **Package hook** | ❌ Everything in Include.cmake | ✅ Only Qt-specific things |

### 8.5 Backward Compatibility

The **local external** functionality is fully preserved:

```json
// Continues to work for real local externals
"bass": {
    "path": "externals/bass"
}
```

Only the **workaround** (path to an empty/unused folder) becomes obsolete.

### 8.6 Deprecation Warning (Optional)

In Phase 9 a warning could be added:

```cmake
# In local/Attach.cmake
function(_attach_local_external EXT_NAME EXT_JSON)
    # ... existing code ...
    
    # Deprecation warning for known system libraries
    set(_known_system_libs "qt6;boost;opencv;cuda")
    if("${EXT_NAME}" IN_LIST _known_system_libs)
        cmake_warn("W105" 
            "External '${EXT_NAME}' is defined as local but is typically a system library.\n"
            "  Consider migrating to: \"${EXT_NAME}\": { \"system\": true, \"package\": \"...\" }"
        )
    endif()
endfunction()
```

---

## 9. Open Points

### 9.1 Decided

| Question | Decision |
|-------|--------------|
| Type detection? | `system` → `git` → `path` → error |
| Required fields? | `system: true` requires `package` |
| Backward compatible? | ✅ Yes, old externals work |

### 9.2 Not in Scope

- vcpkg/Conan integration (separate feature)
- Automatic download of system externals
- Hybrid externals (system with fetched fallback) — possibly later

---

## 10. See Also

- [Master_Concept.md](Master_Concept.md) — Architecture overview
- [Implementation_Plan.md](Implementation_Plan.md) — Phase plan
- [Solution_Schema.md](../../guide/references/Solution_Schema.md) — JSON schema

---

## 11. Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: "Code today" notes on §5.4–5.6 (`${CMAKECRAFT_DIR}`), §5.5 (E012 message) and §7 (E5xx/W5xx raised), updated to CMakeCraft v0.14.1 (E502–E505 and W501 raised, E501/W502 dropped, `find_package` without `REQUIRED`; line numbers)** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.7.0 | 2025-12-18 | Phase 9 completed: implementation verified, Qt6 tested successfully, debug messages switched to dbg(), documentation finalized |
| 0.6.0 | 2025-12-18 | Comprehensive revision: Section 5 completely new (architecture before/after, package hook mechanism, complete Handler/PathResolver code), Section 8 migration extended (Include.cmake deprecation, decision aid diagram), type detection clarified (Section 3), required-field logic corrected |
| 0.5.0 | 2025-12-14 | Blueprint v0.5.0 format, error codes E5xx/W5xx |
| 0.1.0 | 2025-12-10 | Initial: concept for system externals |
