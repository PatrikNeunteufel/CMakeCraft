# Adding External Libraries – User Guide

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Guide  
> **Status:** Stable  
> **Target Audience:** Build system developers, C++ developers  
> **Language:** English  
> **German:** [Adding_Externals_UserGuide.md](../../../de/guide/userguides/Adding_Externals.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Quick Start](#3-quick-start)
4. [Analyzing the External](#4-analyzing-the-external)
5. [Configuring Solution.json](#5-configuring-solutionjson)
6. [Creating a PreFetch Hook](#6-creating-a-prefetch-hook)
7. [Creating a PostFetch Hook](#7-creating-a-postfetch-hook)
8. [Configuring the Executable](#8-configuring-the-executable)
9. [Testing](#9-testing)
10. [Pitfalls and Solutions](#10-pitfalls-and-solutions)
11. [Troubleshooting](#11-troubleshooting)
12. [See Also](#12-see-also)

---

## 1. Overview

This guide explains step by step how to add new external libraries to the CMake Architecture build system.

### Target Audience

- **Primary:** Build system developers who extend the external system
- **Secondary:** C++ developers who want to integrate new libraries

### Workflow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Analyze the external                                      │
│    └─ CMake support? Tests/examples? Dependencies?          │
├─────────────────────────────────────────────────────────────┤
│ 2. Configure Solution.json                                   │
│    └─ Extend the externals block                            │
├─────────────────────────────────────────────────────────────┤
│ 3. Create PreFetch hook (if needed)                         │
│    └─ Disable tests/examples                                │
├─────────────────────────────────────────────────────────────┤
│ 4. Create PostFetch hook (if needed)                        │
│    └─ Create target manually                                │
├─────────────────────────────────────────────────────────────┤
│ 5. Configure the executable                                  │
│    └─ Add external to the externals list                    │
├─────────────────────────────────────────────────────────────┤
│ 6. Test                                                      │
│    └─ Configure, build, link                                │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Prerequisites

### Checklist

- [ ] **CMake Architecture** set up and working
- [ ] **Git** installed (for Git externals)
- [ ] **Knowledge:** CMake basics (add_library, target_link_libraries)
- [ ] **Access:** the external's repository (for analysis)

### Recommended Knowledge

| Topic | Why needed |
|-------|------------|
| CMake targets | For PostFetch hooks |
| FetchContent | Understanding the download mechanism |
| CMake cache | For PreFetch hooks |
| Solution.json schema | Correct configuration |

---

## 3. Quick Start

### Simplest Scenario: Git External with CMake Support

```json
{
    "externals": {
        "spdlog": {
            "git": "https://github.com/gabime/spdlog.git",
            "tag": "v1.14.1"
        }
    },
    "executables": [
        {
            "name": "MyApp",
            "externals": ["spdlog"]
        }
    ]
}
```

Done! No hook is needed if the external:
- Has a `CMakeLists.txt`
- Creates standard targets
- Does not build interfering tests/examples

---

## 4. Analyzing the External

Before you add an external, answer the following questions:

### 4.1 Check CMake Support

**Check in the repository:**
- Is there a `CMakeLists.txt` in the root?
- Is `add_library()` or `add_executable()` used?

| Situation | cmakeSupport | Hook |
|-----------|--------------|------|
| CMakeLists.txt present | `true` (default) | PreFetch optional |
| No CMakeLists.txt | `false` | PostFetch **required** |
| Header-only library | `true` or `false` | Depending on CMake integration |

### 4.2 Find Build Options

**Search CMakeLists.txt for:**
```cmake
option(BUILD_TESTS ...)
option(BUILD_EXAMPLES ...)
option(BUILD_DOCS ...)
option(XXX_INSTALL ...)
```

These should be disabled in the PreFetch hook.

### 4.3 Identify Target Names

**Search for:**
```cmake
add_library(target_name ...)
```

You need the exact target name for `target_link_libraries()`.

### 4.4 Check Dependencies

- Does the external need other libraries?
- Are they bundled or external?

---

## 5. Configuring Solution.json

### 5.1 Basic Configuration

**Add to the `externals` block:**

```json
{
    "externals": {
        "mein_external": {
            "git": "https://github.com/user/repo.git",
            "tag": "v1.0.0"
        }
    }
}
```

### 5.2 Field Reference

| Field | Required | Description |
|-------|----------|-------------|
| `git` | ✅ | Repository URL |
| `tag` | ✅* | Git tag (recommended) |
| `branch` | ❌* | Git branch (for bleeding edge) |
| `commit` | ❌* | Commit hash (for an exact version) |
| `cmakeSupport` | ❌ | `false` if there is no CMakeLists.txt |
| `hook` | ❌ | Hook reuse |

*Exactly one of `tag`, `branch`, `commit` is required.

### 5.3 Examples

**Standard (with CMake support):**
```json
"spdlog": {
    "git": "https://github.com/gabime/spdlog.git",
    "tag": "v1.14.1"
}
```

**Without CMake support:**
```json
"imgui": {
    "git": "https://github.com/ocornut/imgui.git",
    "tag": "v1.91.6",
    "cmakeSupport": false
}
```

**With hook reuse:**
```json
"imgui_docking": {
    "git": "https://github.com/ocornut/imgui.git",
    "tag": "v1.91.6-docking",
    "cmakeSupport": false,
    "hook": "imgui"
}
```

---

## 6. Creating a PreFetch Hook

### 6.1 When Is It Needed?

A PreFetch hook is useful if the external:
- Builds tests/examples/benchmarks (build time!)
- Creates install targets (not needed with FetchContent)
- Generates documentation
- Needs special options

### 6.2 Create the Hook File

**Path:** `cmake/externals/hooks/prefetch/{name}.cmake` (in the CMakeCraft repo; `{name}` = external key in Solution.json or value of the `hook` field)

**Template:**
```cmake
# ==============================================================================
# prefetch/{name}.cmake – {Name} PreFetch Hook
# ==============================================================================
#
# Hook:         {name}.cmake
# Version:      0.1.0
# Date:         {DATUM}
# Part of:      CMake Architecture
#
# Description:
#   PreFetch hook for {Name}.
#   Disables tests, examples, and installation.
#
# ==============================================================================

message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch: Setting options")

# ==============================================================================
# Disable Tests
# ==============================================================================

set({PREFIX}_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set({PREFIX}_BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)

# ==============================================================================
# Disable Examples
# ==============================================================================

set({PREFIX}_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)

# ==============================================================================
# Disable Install
# ==============================================================================

set({PREFIX}_INSTALL OFF CACHE BOOL "" FORCE)

# ==============================================================================
# Disable Documentation
# ==============================================================================

set({PREFIX}_BUILD_DOCS OFF CACHE BOOL "" FORCE)

message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch complete")
```

### 6.3 Important Notes

**CACHE BOOL "" FORCE:**
```cmake
set(OPTION OFF CACHE BOOL "" FORCE)
#                          ^^^^^ Important! Overwrites existing values
```

**Dynamic name:**
```cmake
message(STATUS "[${HOOK_EXTERNAL_NAME}] ...")
#                ^^^^^^^^^^^^^^^^^^^^^ Always use this variable
```

---

## 7. Creating a PostFetch Hook

### 7.1 When Is It Needed?

A PostFetch hook is **required** if:
- `cmakeSupport: false` (no CMakeLists.txt)
- Additional targets have to be created
- Special configuration is needed after the fetch

### 7.2 Create the Hook File

**Path:** `cmake/externals/hooks/postfetch/{name}.cmake` (in the CMakeCraft repo; `{name}` = external key in Solution.json or value of the `hook` field)

**Template (for a library without CMake):**
```cmake
# ==============================================================================
# postfetch/{name}.cmake – {Name} PostFetch Hook
# ==============================================================================
#
# Hook:         {name}.cmake
# Version:      0.1.0
# Date:         {DATUM}
# Part of:      CMake Architecture
#
# Description:
#   PostFetch hook for {Name}.
#   Creates the library target manually.
#
# Provided Variables:
#   HOOK_EXTERNAL_NAME - Name of the external (use for target names!)
#   HOOK_SOURCE_DIR    - Path to source directory
#
# ==============================================================================

message(STATUS "[${HOOK_EXTERNAL_NAME}] Creating target from: ${HOOK_SOURCE_DIR}")

# ==============================================================================
# Collect Source Files
# ==============================================================================

set(_sources
    "${HOOK_SOURCE_DIR}/src/file1.cpp"
    "${HOOK_SOURCE_DIR}/src/file2.cpp"
)

set(_includes
    "${HOOK_SOURCE_DIR}/include"
)

# ==============================================================================
# Create Library Target
# ==============================================================================

add_library(${HOOK_EXTERNAL_NAME} STATIC ${_sources})

target_include_directories(${HOOK_EXTERNAL_NAME} PUBLIC ${_includes})

# C++ standard (if needed)
target_compile_features(${HOOK_EXTERNAL_NAME} PUBLIC cxx_std_17)

# Suppress warnings in external code
if(MSVC)
    target_compile_options(${HOOK_EXTERNAL_NAME} PRIVATE /W0)
else()
    target_compile_options(${HOOK_EXTERNAL_NAME} PRIVATE -w)
endif()

# ==============================================================================
# Register Target
# ==============================================================================

_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)

message(STATUS "[${HOOK_EXTERNAL_NAME}] Target created")
message(STATUS "[${HOOK_EXTERNAL_NAME}] PostFetch complete")
```

**Template (for a header-only library):**
```cmake
# ==============================================================================
# postfetch/{name}.cmake – {Name} PostFetch Hook (Header-only)
# ==============================================================================

message(STATUS "[${HOOK_EXTERNAL_NAME}] Creating INTERFACE target")

# ==============================================================================
# Create Interface Library
# ==============================================================================

add_library(${HOOK_EXTERNAL_NAME} INTERFACE)

target_include_directories(${HOOK_EXTERNAL_NAME} INTERFACE 
    "${HOOK_SOURCE_DIR}/include"
)

# ==============================================================================
# Register Target
# ==============================================================================

_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)

message(STATUS "[${HOOK_EXTERNAL_NAME}] INTERFACE target created")
```

### 7.3 Important Rules

**Always use `${HOOK_EXTERNAL_NAME}`:**
```cmake
# ✅ Correct
add_library(${HOOK_EXTERNAL_NAME} STATIC ${sources})

# ❌ Wrong
add_library(mylib STATIC ${sources})
```

**Always register the target:**
```cmake
_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)
```

**Suppress warnings:**
```cmake
if(MSVC)
    target_compile_options(${HOOK_EXTERNAL_NAME} PRIVATE /W0)
else()
    target_compile_options(${HOOK_EXTERNAL_NAME} PRIVATE -w)
endif()
```

---

## 8. Configuring the Executable

**Add the external to the executable:**

```json
{
    "executables": [
        {
            "name": "MyApp",
            "externals": ["mein_external"]
        }
    ]
}
```

**Mind the order:**

If externals depend on each other, they must be listed in the correct order:

```json
"externals": ["glad", "glfw", "imgui"]
#              ^^^^   ^^^^   ^^^^^
#              1.     2.     3. (needs 1 and 2)
```

---

## 9. Testing

### 9.1 Configure

```bash
cmake --preset msvc-debug
```

**Expected output:**
```
[mein_external] PreFetch: Setting options
[mein_external] PreFetch complete
...
[mein_external] Fetching from https://github.com/...
[mein_external] Fetched and configured successfully
```

### 9.2 Build

```bash
cmake --build build/msvc-debug --target MyApp
```

### 9.3 Verification

**Checklist after a successful build:**

- [ ] Configure without errors
- [ ] Build without errors
- [ ] Executable starts
- [ ] External functionality available

---

## 10. Pitfalls and Solutions

### 10.1 "Target not found"

**Problem:** CMake cannot find the external target.

**Cause:** PostFetch hook missing or target not registered.

**Solution:**
1. With `cmakeSupport: false` → create a PostFetch hook
2. Do not forget `_register_external_target()`
3. Check the target names

### 10.2 "Undefined reference"

**Problem:** The linker cannot find symbols.

**Cause:** Wrong target name or missing source files.

**Solution:**
1. Check the target names in the external's CMakeLists.txt
2. List all source files in the PostFetch hook
3. Check the library type (STATIC vs SHARED vs INTERFACE)

### 10.3 Tests Are Built Anyway

**Problem:** The external builds tests even though they are disabled.

**Cause:** Wrong cache variable or FORCE missing.

**Solution:**
```cmake
# ❌ Without FORCE - ignored if already set
set(BUILD_TESTS OFF CACHE BOOL "")

# ✅ With FORCE - always overwrites
set(BUILD_TESTS OFF CACHE BOOL "" FORCE)
```

### 10.4 CMake Error in the External

**Problem:** Error in the external's CMakeLists.txt.

**Cause:** Missing dependency or incompatible CMake version.

**Solution:**
1. Analyze the external's CMakeLists.txt
2. Check for missing find_package() calls
3. Check the minimum CMake version

### 10.5 Hook Is Not Executed

**Problem:** The hook file exists but is not loaded.

**Cause:** Wrong file name or path.

**Solution:**
1. The file name must be exactly `{external_name}.cmake` (external key) or match the value of the `hook` field
2. Path: `cmake/externals/hooks/prefetch/` or `cmake/externals/hooks/postfetch/` in the CMakeCraft repo
   — or explicitly `"hooks": { "preFetch": "<path>", "postFetch": "<path>" }` (relative to the
   project root; if the file is missing, E216)
3. Mind upper/lower case (all lowercase)

---

## 11. Troubleshooting

### Checklist for a New External

- [ ] Repository URL and tag identified
- [ ] CMake support checked
- [ ] Build options identified
- [ ] Target name identified
- [ ] Solution.json extended
- [ ] PreFetch hook created (if needed)
- [ ] PostFetch hook created (if needed)
- [ ] Executable configured
- [ ] Configure successful
- [ ] Build successful
- [ ] Linking successful

### Common Errors

| Problem | Possible cause | Solution |
|---------|----------------|----------|
| "Target not found" | PostFetch hook missing | Create hook with `cmakeSupport: false` |
| "Undefined reference" | Wrong target name | Check target names in the library |
| Tests are built | PreFetch hook missing/wrong | Set options with FORCE |
| CMake error in external | Wrong options | Check the external's CMakeLists.txt |
| Hook not executed | Wrong path/name | Check file name and path |

### Debug Tips

```bash
# Verbose CMake output
cmake --preset ... --debug-output

# Check hook execution: every loaded hook reports itself in the configure output, e.g.
#   [Externals]     PreFetch hook (convention): glfw.cmake
#   [Externals]     PostFetch hook (explicit): <path>
# If the line is missing, no hook was loaded for the external.

# FetchContent details
cmake --preset ... --log-level=DEBUG
```

---

## 12. See Also

- [Git_Externals_Reference.md](../references/externals/Git_Externals.md) – External libraries overview
- [Solution_Schema.md](../references/Solution_Schema.md) – JSON schema
- [Externals.md](../references/Externals.md) – Externals reference
- [Externals_UserGuide.md](Externals.md) – Using externals

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.1 | 2026-11-09 | Aligned with the code: hook paths `cmake/externals/hooks/prefetch/` and `…/postfetch/` in lowercase, file name = external key or `hook`, explicit `hooks` paths (E216); `-DHOOKS_DEBUG=ON` (does not exist) replaced by the HookLoader's configure messages |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| **0.5.0** | **2025-12-14** | **Blueprint v0.5.0 conformance: numbered TOC, prerequisites, pitfalls/troubleshooting separated, see also** |
| 0.1.0 | 2025-12-10 | Initial: complete guide with templates |
