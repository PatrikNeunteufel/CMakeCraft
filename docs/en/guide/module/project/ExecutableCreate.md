# ExecutableCreate.cmake — Module Documentation

> **Version:** 1.0.1  
> **Date:** 2026-10-09  
> **Type:** ModuleDoc  
> **Status:** In Development (Pre-Release)  
> **Based on:** ModuleDoc v0.5, master_concept v0.5, guidelines v0.5  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [ExecutableCreate.md](../../../../de/guide/module/project/ExecutableCreate.md)  
> **Module:** [`cmake/project/ExecutableCreate.cmake`](../../../../../cmake/project/ExecutableCreate.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [API Reference](#3-api-reference)
4. [Processing](#4-processing)
5. [Platform-Specific Behavior](#5-platform-specific-behavior)
6. [Error Handling](#6-error-handling)
7. [See Also](#7-see-also)
8. [Changelog](#changelog)

---

## 1. Overview

The `ExecutableCreate.cmake` module **creates CMake targets** from a prepared context. It is responsible for the actual target creation with all configurations.

### Core Idea

The context contains all the data — Create builds a fully configured target from it.

### Responsibilities

| Area | Description |
|------|-------------|
| Target creation | add_executable() with the correct type |
| Source collection | GLOB or Source.cmake |
| Dependencies | Internal libraries, externals |
| Options | Defines, compile/link options |
| Standards | Warnings, CompilerOptions, OutputDirs |

---

## 2. Dependencies

| Module | Version | Usage |
|--------|---------|-------|
| Context.cmake | 0.5.0 | `ctx_get` |
| Errors.cmake | 0.5.0 | `cmake_fatal`, `cmake_warn` |
| Debug.cmake | 0.5.0 | `dbg` |
| OutputDirs.cmake | 0.5.0 | `setup_output_dirs` |
| Warnings.cmake | 0.5.0 | `apply_warnings` |
| CompilerOptions.cmake | 0.5.0 | `apply_compiler_options` |
| Orchestrator.cmake | 0.5.0 | `apply_external_to_target` |
| Json.cmake | 0.5.0 | `_json_has_key`, `_json_get_object` |

---

## 3. API Reference

### 3.1 _create_executable_target()

Creates a CMake executable target from the context.

```cmake
_create_executable_target(<CTX>)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `CTX` | String | ✓ | Context prefix (e.g. `EXE_0`) |

**Expected context keys:**

| Key | Usage |
|-----|-------|
| NAME | Target name |
| PATH | Source directory |
| TYPE | CONSOLE, GUI, CLI, etc. |
| VERSION | Target version |
| PCH_ENABLED | Precompiled headers |
| PCH_HEADER | PCH file name |
| DEPENDENCIES | Internal libraries |
| EXTERNALS | External dependencies |
| EXTERNAL_OPTIONS | Options per external |
| DEFINES | Preprocessor definitions; `{version}` is replaced by the VERSION of the target |
| COMPILE_OPTIONS | Compiler flags |
| LINK_OPTIONS | Linker flags |

**Example:**

```cmake
ctx_create(EXE_0)
_collect_executable("${_exe_json}" EXE_0)
_create_executable_target(EXE_0)
```

---

## 4. Processing

### 4.1 Flow

```
_create_executable_target(CTX)
    │
    ├── 1. Read context data
    │   └── Replace {version} in DEFINES with VERSION
    │
    ├── 2. Validate source directory
    │   └── E001 if it does not exist
    │
    ├── 3. Create target
    │   ├── GUI → WIN32/MACOSX_BUNDLE
    │   └── Others → standard executable
    │
    ├── 4. Collect sources (GLOB)
    │   └── W101 if no sources
    │
    ├── 5. Set include directories
    │   └── + pch/ if present
    │
    ├── 6. Enable PCH (if enabled)
    │   └── W101 if header not found
    │
    ├── 7. Link internal dependencies
    │   └── E101 if target does not exist
    │
    ├── 8. Apply externals
    │   ├── E010 if not defined
    │   └── apply_external_to_target()
    │
    ├── 9. Set defines/compile/link options
    │
    ├── 10. Apply standard modules
    │   ├── apply_warnings()
    │   ├── apply_compiler_options()
    │   └── setup_output_dirs()
    │
    └── 11. Platform-specific
        ├── Windows GUI: APP_WINDOWS_GUI
        └── macOS GUI: bundle properties
```

### 4.2 Source Collection

Currently via GLOB:
```cmake
file(GLOB_RECURSE _sources
    "${_src_dir}/*.cpp"
    "${_src_dir}/*.cxx"
    "${_src_dir}/*.cc"
    "${_src_dir}/*.c"
)
```

**Note:** For explicit control, Source.cmake can be used (depending on SOLUTION_SOURCE_MODE).

---

## 5. Platform-Specific Behavior

### 5.1 Windows GUI

```cmake
if(WIN32 AND TYPE == "GUI")
    add_executable(${name} WIN32)
    set_target_properties(${name} PROPERTIES WIN32_EXECUTABLE TRUE)
    target_compile_definitions(${name} PRIVATE APP_WINDOWS_GUI)
endif()
```

The define `APP_WINDOWS_GUI` enables WinMain as the entry point:

```cpp
#ifdef APP_WINDOWS_GUI
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int) {
    return main(__argc, __argv);
}
#else
int main(int argc, char* argv[]) { ... }
#endif
```

### 5.2 macOS GUI

```cmake
if(APPLE AND TYPE == "GUI")
    add_executable(${name} MACOSX_BUNDLE)
    set_target_properties(${name} PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_GUI_IDENTIFIER "com.project.${name}"
        MACOSX_BUNDLE_BUNDLE_NAME "${display_name}"
        MACOSX_BUNDLE_BUNDLE_VERSION "${version}"
    )
endif()
```

### 5.3 Linux/Unix

No special adjustments for the GUI type.

---

## 6. Error Handling

### 6.1 Fatal Errors

| Code | Condition | Solution |
|------|-----------|----------|
| E001 | Source path does not exist | Check/create the path |
| E010 | External not in the central definition | Add the external to Solution.json |
| E101 | Internal dependency does not exist | Define the library before the executable |

### 6.2 Warnings

| Code | Condition | Recommendation |
|------|-----------|----------------|
| W101 | No sources found | Add source files |
| W101 | PCH header not found | Create the header file |

---

## 7. See Also

- [Executables.cmake](Executables.md) — Calls _create_executable_target
- [ExecutableCollect.cmake](ExecutableCollect.md) — Fills the context
- [Orchestrator.cmake](../externals/Orchestrator_cmake.md) — apply_external_to_target
- [OutputDirs.cmake](../core/OutputDirs.md) — Output directories
- [CompilerOptions.cmake](../core/CompilerOptions.md) — Compiler options

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-10-09** | **CMakeCraft v0.10.0: `{version}` in DEFINES stands for the version of the target** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.1 | 2025-12-17 | collect_sources() integration, SourceCollect.cmake dependency |
| 0.5.0 | 2025-12-15 | Migration to Blueprint v0.5.0: new header with target audience/language/English link/module link, numbered table of contents with anchors, chapter numbering |
| 0.1.2 | 2025-12-09 | APP_WINDOWS_GUI define for Windows GUI |
| 0.1.1 | 2025-12-07 | Externals integration via apply_external_to_target() |
| 0.1.0 | 2025-12-05 | Initial (clean start): target creation from context |
