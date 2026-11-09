# Debug.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** In development (pre-release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [Debug.md](../../../../de/guide/module/core/Debug.md)  
> **Module:** [`cmake/core/Debug.cmake`](../../../../../cmake/core/Debug.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Concept](#3-concept)
4. [Global Configuration](#4-global-configuration)
5. [API Reference](#5-api-reference)
6. [Usage Examples](#6-usage-examples)
7. [Output Examples](#7-output-examples)
8. [Best Practices](#8-best-practices)
9. [Internal Implementation](#9-internal-implementation)
10. [See Also](#10-see-also)
11. [Changelog](#changelog)

---

## 1. Overview

The `Debug.cmake` module implements a **context-based debug system** with two-axis filtering. It allows granular control over debug output without littering the code with `if(DEBUG)`.

### Core Idea

Every message has an importance (FREQ), every context has a visibility level (SHOW). A message appears if `FREQ <= SHOW`.

### Responsibilities

| Area | Description |
|------|-------------|
| Filtering | Two-axis system (SHOW × FREQ) |
| Contexts | Isolated debug areas per module |
| Control | Master switch, level override, ONCE flag |
| Structure | Tags, blank lines, separator lines |

### Used By

- CompilerOptions.cmake, Solution.cmake, Executables.cmake
- All modules that need debug output

---

## 2. Dependencies

| Module | Version | Usage |
|--------|---------|-------|
| — | — | None (base module, should be loaded early) |

**Design decision:** Debug.cmake is a base module without dependencies, since it is used by almost all other modules.

---

## 3. Concept

### 3.1 Two-Axis Filtering

| Axis | Question | Values |
|------|----------|--------|
| **SHOW** | How much do I want to see? | 1-5 (little → everything) |
| **FREQ** | How important is this message? | 1-5 (important → detail) |

**Filter rule:** A message appears if `FREQ <= SHOW`

### 3.2 SHOW Level Constants

| Constant | Value | Meaning |
|----------|-------|---------|
| `DBG_SHOW_LITTLE` | 1 | Only the most important |
| `DBG_SHOW_SOME` | 2 | Standard (default) |
| `DBG_SHOW_MUCH` | 3 | More details |
| `DBG_SHOW_LOTS` | 4 | Many details |
| `DBG_SHOW_ALL` | 5 | Everything |

### 3.3 FREQ Level Constants

| Constant | Value | Meaning | Example |
|----------|-------|---------|---------|
| `DBG_OFTEN` | 1 | Frequent, important | Module start, phase start |
| `DBG_COMMON` | 2 | Usual info | Files found, features |
| `DBG_NORMAL` | 3 | Standard | Intermediate steps |
| `DBG_RARE` | 4 | Rarely needed | Paths, variables |
| `DBG_ULTRA_RARE` | 5 | Deep debugging only | Loop iterations |

### 3.4 Example: Filtering

With `SHOW = DBG_SHOW_MUCH (3)`:

| FREQ level | Value | Appears? | Reason |
|------------|-------|----------|--------|
| `DBG_OFTEN` | 1 | ✅ | 1 <= 3 |
| `DBG_COMMON` | 2 | ✅ | 2 <= 3 |
| `DBG_NORMAL` | 3 | ✅ | 3 <= 3 |
| `DBG_RARE` | 4 | ❌ | 4 > 3 |
| `DBG_ULTRA_RARE` | 5 | ❌ | 5 > 3 |

---

## 4. Global Configuration

### 4.1 Cache Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `DEBUG_MESSAGES` | BOOL | ON | Master switch for all output |
| `DEBUG_DEFAULT_LEVEL` | INT | 2 | Default SHOW level for new contexts |

### 4.2 Activation

```bash
# Disable all debug output
cmake -B build -DDEBUG_MESSAGES=OFF

# See more details
cmake -B build -DDEBUG_DEFAULT_LEVEL=4

# See everything
cmake -B build -DDEBUG_DEFAULT_LEVEL=5
```

---

## 5. API Reference

### 5.1 dbg_init()

Initializes a debug context.

```cmake
dbg_init(
    ID <context_id>
    [LEVEL <show_level>]
    [SWITCH <ON|OFF>]
    [TAG <prefix>]
)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `ID` | String | ✓ | Unique context identifier |
| `LEVEL` | Int/constant | — | DBG_SHOW_* or 1-5 (default: DEBUG_DEFAULT_LEVEL) |
| `SWITCH` | BOOL | — | ON/OFF (default: ON) |
| `TAG` | String | — | Prefix in square brackets |

**Returns:** Nothing (stores as DIRECTORY PROPERTY)

**Example:**

```cmake
# Minimal
dbg_init(ID MY_MODULE)

# Complete
dbg_init(
    ID SOLUTION 
    LEVEL ${DBG_SHOW_MUCH} 
    SWITCH ON 
    TAG "Solution"
)

# Disabled (to switch off temporarily)
dbg_init(ID VERBOSE SWITCH OFF)
```

---

### 5.2 dbg()

Outputs a debug message (if the filter matches).

```cmake
dbg(<freq_level> "<message>"
    [ID <context_id>]
    [LEVEL <show_level>]
    [SWITCH <ON|OFF>]
    [TAG <extra_tag>]
    [ONCE]
)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `freq_level` | Int/constant | ✓ | DBG_* importance |
| `message` | String | ✓ | Message to output |
| `ID` | String | — | Context reference |
| `LEVEL` | Int | — | Override SHOW level |
| `SWITCH` | BOOL | — | Override switch |
| `TAG` | String | — | Additional tag |
| `ONCE` | Flag | — | Output only once per context |

**Returns:** Nothing (prints to stdout if the filter matches)

**Example:**

```cmake
# With context
dbg(${DBG_OFTEN} "=== Module Start ===" ID MY_MODULE)
dbg(${DBG_COMMON} "Processing: ${_file}" ID MY_MODULE)
dbg(${DBG_RARE} "Detail: ${_internal}" ID MY_MODULE)

# ONCE for warnings in loops
foreach(_item IN LISTS _items)
    dbg(${DBG_COMMON} "Deprecated feature used" ID MY_MODULE ONCE)
endforeach()

# Standalone (without context)
dbg(${DBG_NORMAL} "Standalone message")
```

---

### 5.3 dbgspace()

Outputs a blank line.

```cmake
dbgspace([ID <context_id>] [SWITCH <ON|OFF>])
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `ID` | String | — | Context for the switch check |
| `SWITCH` | BOOL | — | Override switch |

**Returns:** Nothing

**Example:**

```cmake
dbg(${DBG_OFTEN} "Section 1" ID MY_DBG)
dbgspace(ID MY_DBG)
dbg(${DBG_OFTEN} "Section 2" ID MY_DBG)
```

---

### 5.4 enddbgblock()

Outputs a separator line (visual structuring).

```cmake
enddbgblock([ID <context_id>] [SWITCH <ON|OFF>])
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `ID` | String | — | Context for the switch check |
| `SWITCH` | BOOL | — | Override switch |

**Returns:** Nothing

**Output:**
```
-- -------------------------------------------
```

**Example:**

```cmake
dbg(${DBG_OFTEN} "=== Module Start ===" ID MY_DBG)
dbg(${DBG_COMMON} "Processing..." ID MY_DBG)
enddbgblock(ID MY_DBG)
```

---

### 5.5 setup_debug_from_args()

Helper for functions with optional debug flags.

```cmake
setup_debug_from_args(<out_switch> <out_tag> <default_tag> [SHOW_DEBUG] [DEBUG_TAG <tag>])
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `out_switch` | Variable | ✓ | Output for the switch (ON/OFF) |
| `out_tag` | Variable | ✓ | Output for the tag |
| `default_tag` | String | ✓ | Default tag if none is given |
| `SHOW_DEBUG` | Flag | — | Enable debug |
| `DEBUG_TAG` | String | — | Optional tag |

**Returns:** Sets `out_switch` and `out_tag` via PARENT_SCOPE

**Example:**

```cmake
function(my_function)
    cmake_parse_arguments(ARG "SHOW_DEBUG" "DEBUG_TAG" "" ${ARGN})
    setup_debug_from_args(_sw _tag "MY_FUNC" ${ARGN})
    
    dbg_init(ID MY_FUNC_DBG LEVEL ${DBG_SHOW_MUCH} SWITCH ${_sw} TAG "${_tag}")
    dbg(${DBG_OFTEN} "Function started" ID MY_FUNC_DBG)
    # ...
    enddbgblock(ID MY_FUNC_DBG)
endfunction()

# Call
my_function()                                    # No debug
my_function(SHOW_DEBUG)                          # Debug with default tag
my_function(SHOW_DEBUG DEBUG_TAG "CustomTag")    # Debug with own tag
```

---

## 6. Usage Examples

### 6.1 Module with Debug Support

```cmake
# cmake/project/MyModule.cmake
include_guard(GLOBAL)

# Local switch for quick on/off
set(_SHOW_MY_MODULE_DEBUG OFF)

dbg_init(
    ID MY_MODULE 
    LEVEL ${DBG_SHOW_MUCH} 
    SWITCH ${_SHOW_MY_MODULE_DEBUG} 
    TAG "MyModule"
)

dbg(${DBG_OFTEN} "=== MyModule Loading ===" ID MY_MODULE)

foreach(_item IN LISTS _items)
    dbg(${DBG_COMMON} "Processing: ${_item}" ID MY_MODULE)
    dbg(${DBG_RARE} "  Detail: ${_internal}" ID MY_MODULE)
endforeach()

dbg(${DBG_OFTEN} "MyModule loaded successfully" ID MY_MODULE)
enddbgblock(ID MY_MODULE)
```

### 6.2 Function with Optional Debug

```cmake
function(apply_compiler_options TARGET_NAME)
    cmake_parse_arguments(ARG "SHOW_DEBUG" "DEBUG_TAG" "" ${ARGN})
    setup_debug_from_args(_sw _tag "CompilerOpts" ${ARGN})
    
    dbg_init(ID CO_DBG LEVEL ${DBG_SHOW_MUCH} SWITCH ${_sw} TAG "${_tag}")
    dbg(${DBG_OFTEN} "Applying to: ${TARGET_NAME}" ID CO_DBG)
    
    # ... implementation ...
    
    dbg(${DBG_OFTEN} "Done" ID CO_DBG)
    enddbgblock(ID CO_DBG)
endfunction()
```

### 6.3 Debug Level via Preset

```json
{
    "configurePresets": [
        {
            "name": "debug-verbose",
            "cacheVariables": {
                "DEBUG_MESSAGES": "ON",
                "DEBUG_DEFAULT_LEVEL": "5"
            }
        },
        {
            "name": "release-quiet",
            "cacheVariables": {
                "DEBUG_MESSAGES": "OFF"
            }
        }
    ]
}
```

---

## 7. Output Examples

### 7.1 Standard (SHOW_LEVEL = 2)

```
-- [Solution] Solution.json loaded
-- [Solution] MySolution v0.1.0
-- [Solution] Externals: 8
-- -------------------------------------------
```

### 7.2 Verbose (SHOW_LEVEL = 5)

```
-- [Solution] Solution.json loaded
-- [Solution] Schema-Version: 0.1
-- [Solution] MySolution v0.1.0
-- [Solution] Description: Multi-Project Solution
-- [Solution] Authors: Author Name
-- [Solution] C++ Standard: 20
-- [Solution] C Standard: 17
-- [Solution] Default Library Type: STATIC
-- [Solution] Externals: 8
-- [Solution] Executables: 3, Libraries: 0, Tests: 1
-- -------------------------------------------
```

---

## 8. Best Practices

### 8.1 Consistent FREQ Levels

```cmake
# ✅ Good - consistent importance
dbg(${DBG_OFTEN} "=== Module Start ===" ID MOD)    # Always visible
dbg(${DBG_COMMON} "Processing file X" ID MOD)       # Usual info
dbg(${DBG_RARE} "Internal: ${_var}" ID MOD)         # Only when needed

# ❌ Bad - everything equally important
dbg(${DBG_OFTEN} "Processing file X" ID MOD)
dbg(${DBG_OFTEN} "Internal: ${_var}" ID MOD)
```

### 8.2 Meaningful Tags

```cmake
# ✅ Good
dbg_init(ID SOLUTION TAG "Solution")
dbg_init(ID EXTERNALS TAG "Externals")

# ❌ Bad
dbg_init(ID DBG1 TAG "D1")
```

### 8.3 ONCE for Loop Warnings

```cmake
foreach(_ext IN LISTS _externals)
    # Appears only once, not on every iteration
    dbg(${DBG_COMMON} "Deprecated feature used" ID MY_DBG ONCE)
endforeach()
```

### 8.4 Local Switch for Quick Debugging

```cmake
# At the top of the module - quick to switch on/off
set(_SHOW_MODULE_DEBUG OFF)  # ← change here

dbg_init(ID MOD SWITCH ${_SHOW_MODULE_DEBUG} ...)
```

---

## 9. Internal Implementation

The module uses **DIRECTORY PROPERTY** for context storage:

| Property | Description |
|----------|-------------|
| `DBG_${ID}_LEVEL` | SHOW level |
| `DBG_${ID}_SWITCH` | ON/OFF |
| `DBG_${ID}_TAG` | Tag prefix |
| `DBG_${ID}_ONCE_GUARD` | List of ONCE messages already shown |

---

## 10. See Also

- [Errors.cmake](Errors.md) — for real errors (cmake_fatal, cmake_warn)
- [guidelines](../../../konzepte/Guidelines.md) — debug conventions
- [CMake.md](../../../autorenwerk/blueprints/CMake.md) — debug in modules

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0: new header with target audience/language/English link/module link, numbered table of contents with anchors, chapter numbering |
| 0.1.1 | 2025-12-05 | English translation (Language Standards v0.1.1) |
| 0.1.0 | 2025-12-04 | Initial (clean start): two-axis filtering, dbg_init/dbg/dbgspace/enddbgblock/setup_debug_from_args API |
