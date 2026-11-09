# Source.cmake — Standard for CMake Source File Lists

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Blueprint  
> **Status:** Stable  
> **Based on:** CMake Architecture  
> **Target Audience:** Developers  
> **Language:** English  
> **German:** [SourceCmake.md](../../../de/autorenwerk/blueprints/SourceCmake.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Scope](#2-scope)
3. [Mandatory Structure](#3-mandatory-structure)
4. [File Categories](#4-file-categories)
5. [Complete Template](#5-complete-template)
6. [Examples](#6-examples)
7. [Common Mistakes](#7-common-mistakes)
8. [Review Checklist](#8-review-checklist)
9. [See Also](#9-see-also)
10. [Changelog](#10-changelog)

---

## 1. Overview

This blueprint defines the **structure for Source.cmake files** in the CMake Architecture V2 build system. Source.cmake files collect source files recursively in directory trees.

### Purpose

- List the source files of a directory
- Categorize files by type (sources, headers, templates, etc.)
- Recursive aggregation into parent scopes
- Debug output for build diagnostics

### Core Principle

> **Every directory containing source files needs a Source.cmake.**

---

## 2. Scope

This blueprint applies to all Source.cmake files in:

- `projects/apps/[App]/include/` — header files
- `projects/apps/[App]/src/` — implementation files
- `projects/apps/[App]/main/` — entry point
- `projects/apps/[App]/tests/` — test files
- `projects/libs/[Lib]/include/` — library headers
- `projects/libs/[Lib]/src/` — library implementation

---

## 3. Mandatory Structure

Every Source.cmake **MUST** have this structure:

```
┌─────────────────────────────────────────────────────────────────────┐
│  1. Header comment with path                                        │
│  2. dbg() entry message                                             │
│  3. Define 5 local lists (_local_*)                                 │
│  4. dbg() for found files                                           │
│  5. list(APPEND) for aggregation                                    │
│  6. dbg() for aggregated files                                      │
│  7. unset() for cleanup                                             │
│  8. dbg() for subfolders                                            │
│  9. include() for subfolders (at the end!)                          │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.1 Header Comment

```cmake
# ==============================================================================
# Source.cmake for [relative/path]/
# CMake Architecture V2 - [ProjectName]
# ==============================================================================
```

### 3.2 Debug Entry

```cmake
dbg(DBG_OFTEN
    "${CMAKE_CURRENT_LIST_DIR}/Source.cmake
          =============================================\n" ID INCLUDE_MSG)
```

### 3.3 Five Local Lists

**ALL five lists MUST be defined**, even if empty:

```cmake
set(_local_sources
    # (sources - *.c; *.cpp)
)
set(_local_headers
    # (headers - *.h; *.hpp)
)
set(_local_templates
    # (templates - *.t; *.tpp)
)
set(_local_inlines
    # (inlines - *.inl)
)
set(_local_impl
    # (impl - *.impl)
)
```

### 3.4 Debug Output (Found)

```cmake
dbg(DBG_NORMAL "Found sources  : ${_local_sources}" ID DEB_FOUND_MSG)
dbg(DBG_NORMAL "Found headers  : ${_local_headers}" ID DEB_FOUND_MSG)
dbg(DBG_NORMAL "Found templates: ${_local_templates}" ID DEB_FOUND_MSG)
dbg(DBG_NORMAL "Found inlines  : ${_local_inlines}" ID DEB_FOUND_MSG)
dbg(DBG_NORMAL "Found impl     : ${_local_impl}" ID DEB_FOUND_MSG)
```

### 3.5 Aggregation

```cmake
list(APPEND ${EXECUTABLE_NAME}_PROJECT_SOURCES ${_local_sources})
list(APPEND ${EXECUTABLE_NAME}_PROJECT_HEADERS ${_local_headers})
list(APPEND ${EXECUTABLE_NAME}_PROJECT_TEMPLATES ${_local_templates})
list(APPEND ${EXECUTABLE_NAME}_PROJECT_INLINES ${_local_inlines})
list(APPEND ${EXECUTABLE_NAME}_PROJECT_IMPL ${_local_impl})
```

### 3.6 Debug Output (Aggregated)

```cmake
dbg(DBG_NORMAL "Aggregated sources  : ${${EXECUTABLE_NAME}_PROJECT_SOURCES}" ID DEB_AGG)
dbg(DBG_NORMAL "Aggregated headers  : ${${EXECUTABLE_NAME}_PROJECT_HEADERS}" ID DEB_AGG)
dbg(DBG_NORMAL "Aggregated templates: ${${EXECUTABLE_NAME}_PROJECT_TEMPLATES}" ID DEB_AGG)
dbg(DBG_NORMAL "Aggregated inlines  : ${${EXECUTABLE_NAME}_PROJECT_INLINES}" ID DEB_AGG)
dbg(DBG_NORMAL "Aggregated impl     : ${${EXECUTABLE_NAME}_PROJECT_IMPL}" ID DEB_AGG)
```

### 3.7 Cleanup

```cmake
unset(_local_sources)
unset(_local_headers)
unset(_local_templates)
unset(_local_inlines)
unset(_local_impl)
```

### 3.8 Subfolder Includes

```cmake
dbg(DBG_ULTRA_RARE "[FolderName] subfolders:" ID INCLUDE_MSG)
# Include subfolders recursively
include("${CMAKE_CURRENT_LIST_DIR}/Subfolder1/Source.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/Subfolder2/Source.cmake")
```

**IMPORTANT:** Subfolder includes are **ALWAYS at the end** of the file!

---

## 4. File Categories

| List | Extensions | Description |
|-------|---------------|--------------|
| `_local_sources` | `.c`, `.cpp`, `.cc`, `.cxx` | Compilable source files |
| `_local_headers` | `.h`, `.hpp`, `.hxx` | Header files |
| `_local_templates` | `.t`, `.tpp` | Template implementations |
| `_local_inlines` | `.inl` | Inline implementations |
| `_local_impl` | `.impl` | Implementation details |

### Assignment Rules

| File type | Correct list |
|----------|----------------|
| `MyClass.cpp` | `_local_sources` |
| `MyClass.hpp` | `_local_headers` |
| `MyClass.tpp` | `_local_templates` |
| `MyClass.inl` | `_local_inlines` |
| `Errors.tpp` | `_local_templates` |

---

## 5. Complete Template

```cmake
# ==============================================================================
# Source.cmake for [path]/
# CMake Architecture V2 - [ProjectName]
# ==============================================================================

dbg(DBG_OFTEN
    "${CMAKE_CURRENT_LIST_DIR}/Source.cmake
          =============================================\n" ID INCLUDE_MSG)

# Set local lists for this directory
set(_local_sources
    # (sources - *.c; *.cpp)
)
set(_local_headers
    # (headers - *.h; *.hpp)
    "${CMAKE_CURRENT_LIST_DIR}/MyHeader.hpp"
)
set(_local_templates
    # (templates - *.t; *.tpp)
)
set(_local_inlines
    # (inlines - *.inl)
)
set(_local_impl
    # (impl - *.impl)
)

dbg(DBG_NORMAL "Found sources  : ${_local_sources}" ID DEB_FOUND_MSG)
dbg(DBG_NORMAL "Found headers  : ${_local_headers}" ID DEB_FOUND_MSG)
dbg(DBG_NORMAL "Found templates: ${_local_templates}" ID DEB_FOUND_MSG)
dbg(DBG_NORMAL "Found inlines  : ${_local_inlines}" ID DEB_FOUND_MSG)
dbg(DBG_NORMAL "Found impl     : ${_local_impl}" ID DEB_FOUND_MSG)

# Aggregate to parent scope
list(APPEND ${EXECUTABLE_NAME}_PROJECT_SOURCES ${_local_sources})
list(APPEND ${EXECUTABLE_NAME}_PROJECT_HEADERS ${_local_headers})
list(APPEND ${EXECUTABLE_NAME}_PROJECT_TEMPLATES ${_local_templates})
list(APPEND ${EXECUTABLE_NAME}_PROJECT_INLINES ${_local_inlines})
list(APPEND ${EXECUTABLE_NAME}_PROJECT_IMPL ${_local_impl})

dbg(DBG_NORMAL "Aggregated sources  : ${${EXECUTABLE_NAME}_PROJECT_SOURCES}" ID DEB_AGG)
dbg(DBG_NORMAL "Aggregated headers  : ${${EXECUTABLE_NAME}_PROJECT_HEADERS}" ID DEB_AGG)
dbg(DBG_NORMAL "Aggregated templates: ${${EXECUTABLE_NAME}_PROJECT_TEMPLATES}" ID DEB_AGG)
dbg(DBG_NORMAL "Aggregated inlines  : ${${EXECUTABLE_NAME}_PROJECT_INLINES}" ID DEB_AGG)
dbg(DBG_NORMAL "Aggregated impl     : ${${EXECUTABLE_NAME}_PROJECT_IMPL}" ID DEB_AGG)

# Optional cleanup (cosmetic)
unset(_local_sources)
unset(_local_headers)
unset(_local_templates)
unset(_local_inlines)
unset(_local_impl)

dbg(DBG_ULTRA_RARE "[FolderName] subfolders:" ID INCLUDE_MSG)
# Include subfolders recursively
# include("${CMAKE_CURRENT_LIST_DIR}/Subfolder/Source.cmake")
```

---

## 6. Examples

### 6.1 Header Directory with Subfolders

```cmake
# ==============================================================================
# Source.cmake for include/Services/
# CMake Architecture V2 - LumiPulse
# ==============================================================================

dbg(DBG_OFTEN
    "${CMAKE_CURRENT_LIST_DIR}/Source.cmake
          =============================================\n" ID INCLUDE_MSG)

set(_local_sources
    # (no sources)
)
set(_local_headers
    "${CMAKE_CURRENT_LIST_DIR}/IEventBus.hpp"
    "${CMAKE_CURRENT_LIST_DIR}/EventBus.hpp"
    "${CMAKE_CURRENT_LIST_DIR}/ICommand.hpp"
)
set(_local_templates
    # (no templates)
)
set(_local_inlines
    # (no inlines)
)
set(_local_impl
    # (no impl)
)

# ... dbg, list(APPEND), unset ...

dbg(DBG_ULTRA_RARE "Services subfolders:" ID INCLUDE_MSG)
include("${CMAKE_CURRENT_LIST_DIR}/Events/Source.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/Commands/Source.cmake")
```

### 6.2 Test Directory

```cmake
# ==============================================================================
# Source.cmake for tests/unit/Core_UnitTests/
# CMake Architecture V2 - LumiPulse
# ==============================================================================

dbg(DBG_OFTEN
    "${CMAKE_CURRENT_LIST_DIR}/Source.cmake
          =============================================\n" ID INCLUDE_MSG)

set(_local_sources
    "${CMAKE_CURRENT_LIST_DIR}/test_main.cpp"
    "${CMAKE_CURRENT_LIST_DIR}/Types_Tests.cpp"
    "${CMAKE_CURRENT_LIST_DIR}/Result_Tests.cpp"
)
set(_local_headers
    # (no headers)
)
set(_local_templates
    # (no templates)
)
set(_local_inlines
    # (no inlines)
)
set(_local_impl
    # (no impl)
)

# ... dbg, list(APPEND), unset ...

dbg(DBG_ULTRA_RARE "Core_UnitTests subfolders:" ID INCLUDE_MSG)
# (no subfolders)
```

### 6.3 Empty Placeholder Directory

```cmake
# ==============================================================================
# Source.cmake for src/Core/
# CMake Architecture V2 - LumiPulse
# Note: Core is currently header-only. Placeholder for future .cpp files.
# ==============================================================================

dbg(DBG_OFTEN
    "${CMAKE_CURRENT_LIST_DIR}/Source.cmake
          =============================================\n" ID INCLUDE_MSG)

set(_local_sources
    # (no sources - Core is header-only)
)
set(_local_headers
    # (no headers)
)
set(_local_templates
    # (no templates)
)
set(_local_inlines
    # (no inlines)
)
set(_local_impl
    # (no impl)
)

# ... dbg, list(APPEND), unset ...

dbg(DBG_ULTRA_RARE "Core subfolders:" ID INCLUDE_MSG)
# (no subfolders)
```

---

## 7. Common Mistakes

### ❌ Wrong: Only One List

```cmake
# WRONG - missing lists
set(_local_headers
    "${CMAKE_CURRENT_LIST_DIR}/MyHeader.hpp"
)
```

### ✅ Correct: All Five Lists

```cmake
# CORRECT - all lists defined
set(_local_sources
    # (no sources)
)
set(_local_headers
    "${CMAKE_CURRENT_LIST_DIR}/MyHeader.hpp"
)
set(_local_templates
    # (no templates)
)
set(_local_inlines
    # (no inlines)
)
set(_local_impl
    # (no impl)
)
```

### ❌ Wrong: Subfolders at the Beginning

```cmake
# WRONG - subfolder include at the beginning
include("${CMAKE_CURRENT_LIST_DIR}/Events/Source.cmake")

set(_local_headers
    "${CMAKE_CURRENT_LIST_DIR}/EventBus.hpp"
)
```

### ✅ Correct: Subfolders at the End

```cmake
# CORRECT - subfolder include at the end
set(_local_headers
    "${CMAKE_CURRENT_LIST_DIR}/EventBus.hpp"
)
# ... rest ...

include("${CMAKE_CURRENT_LIST_DIR}/Events/Source.cmake")
```

### ❌ Wrong: Missing dbg() Calls

```cmake
# WRONG - no debug output
set(_local_headers
    "${CMAKE_CURRENT_LIST_DIR}/MyHeader.hpp"
)
list(APPEND ${EXECUTABLE_NAME}_PROJECT_HEADERS ${_local_headers})
```

### ❌ Wrong: .tpp in headers Instead of templates

```cmake
# WRONG
set(_local_headers
    "${CMAKE_CURRENT_LIST_DIR}/Errors.hpp"
    "${CMAKE_CURRENT_LIST_DIR}/Errors.tpp"  # WRONG!
)
```

### ✅ Correct: .tpp in templates

```cmake
# CORRECT
set(_local_headers
    "${CMAKE_CURRENT_LIST_DIR}/Errors.hpp"
)
set(_local_templates
    "${CMAKE_CURRENT_LIST_DIR}/Errors.tpp"  # CORRECT!
)
```

---

## 8. Review Checklist

**Structure:**

- [ ] Header comment with correct path
- [ ] dbg(DBG_OFTEN) entry message
- [ ] All 5 local lists defined
- [ ] dbg(DBG_NORMAL) for found files (5x)
- [ ] list(APPEND) for all 5 lists
- [ ] dbg(DBG_NORMAL) for aggregated files (5x)
- [ ] unset() for all 5 local lists
- [ ] dbg(DBG_ULTRA_RARE) for subfolders
- [ ] Subfolder includes at the end

**File assignment:**

- [ ] .cpp/.c in `_local_sources`
- [ ] .hpp/.h in `_local_headers`
- [ ] .tpp/.t in `_local_templates`
- [ ] .inl in `_local_inlines`
- [ ] .impl in `_local_impl`

**Paths:**

- [ ] All paths with `${CMAKE_CURRENT_LIST_DIR}/` prefix
- [ ] Subfolder includes exist

---

## 9. See Also

- [Doc.md](Doc.md) — General documentation rules
- CMake Architecture V2 documentation
- [ImplementationPlan.md](ImplementationPlan.md) — For implementation plans

---

## 10. Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.0** | **2025-12-26** | **Initial: complete template, examples, common mistakes** |
