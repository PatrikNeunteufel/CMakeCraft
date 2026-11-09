# Open Clarifications — Build System Modules

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Clarification  
> **Status:** In progress  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [Offene_Abklaerungen_Core_Module.md](../../../de/konzepte/abgeschlossen/Offene_Abklaerungen_Core_Module.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Documentation Status](#2-documentation-status)
3. [Core Module Clarifications](#3-core-module-clarifications)
4. [Project Module Clarifications](#4-project-module-clarifications)
5. [Open Architecture Questions](#5-open-architecture-questions)
6. [Recommendations](#6-recommendations)
7. [Decision Matrix](#7-decision-matrix)
8. [Changelog](#8-changelog)

---

## 1. Overview

This document tracks **open clarification points** and the **documentation status** of all build system modules after the migration to Blueprint v0.5.0.

### Background

On 2025-12-15 all module documentation was migrated to Blueprint v0.5.0:
- New header with target audience, language, English link, module link
- Numbered table of contents with working anchors
- Chapter numbering
- Uniform module version 0.5.0

---

## 2. Documentation Status

### 2.1 Core Modules (9/9 documented) ✅

| Module | Doc version | CMake version | Debug | Errors | Status |
|-------|--------------|---------------|-------|--------|--------|
| CompilerOptions.cmake | 0.5.0 | 0.1.1 → 0.5.0 | ✅ | ✅ W201 | ✅ Done |
| Context.cmake | 0.5.0 | 0.1.1 → 0.5.0 | ❌ | ❌ | ⚪ To clarify |
| Debug.cmake | 0.5.0 | 0.1.1 → 0.5.0 | — | — | ✅ Done |
| Errors.cmake | 0.5.0 | 0.1.2 → 0.5.0 | — | — | ✅ Done |
| Json.cmake | 0.5.0 | 0.1.1 → 0.5.0 | ❌ | ❌ | ⚪ To clarify |
| OutputDirs.cmake | 0.5.0 | 0.1.3 → 0.5.0 | ❌ | ❌ | ⚪ To clarify |
| SourceCollect.cmake | 0.5.0 | 0.1.1 → 0.5.0 | ✅ | ✅ | ✅ Done |
| Validation.cmake | 0.5.0 | 0.1.1 → 0.5.0 | ❌ | ✅ | ✅ Done |
| Warnings.cmake | 0.5.0 | 0.1.1 → 0.5.0 | ❌ | ❌ | ⚪ To clarify |

### 2.2 Project Modules (11/11 documented) ✅

| Module | Doc version | CMake version | Debug | Errors | Status |
|-------|--------------|---------------|-------|--------|--------|
| Solution.cmake | 0.5.0 | 0.1.1 → 0.5.0 | ✅ | ✅ | ✅ Done |
| Executables.cmake | 0.5.0 | 0.1.0 → 0.5.0 | ✅ | ✅ | ✅ Done |
| ExecutableCollect.cmake | 0.5.0 | 0.1.0 → 0.5.0 | ✅ | ✅ | ✅ Done |
| ExecutableCreate.cmake | 0.5.0 | 0.1.2 → 0.5.0 | ✅ | ✅ | ✅ Done |
| Libraries.cmake | 0.5.0 | 0.1.0 → 0.5.0 | ✅ | ✅ | ✅ Done |
| LibraryCollect.cmake | 0.5.0 | 0.1.0 → 0.5.0 | ✅ | ❌ | ✅ Done |
| LibraryCreate.cmake | 0.5.0 | 0.1.0 → 0.5.0 | ✅ | ✅ | ✅ Done |
| Externals.cmake | 0.5.0 | 0.1.0 → 0.5.0 | ✅ | ❌ | ✅ Done |
| Tests.cmake | 0.5.0 | 0.1.0 → 0.5.0 | ❌¹ | ❌ | ✅ Done |
| TestCollect.cmake | 0.5.0 | 0.1.0 → 0.5.0 | ✅ | ❌ | ✅ Done |
| TestCreate.cmake | 0.5.0 | 0.1.0 → 0.5.0 | ✅ | ✅ | ✅ Done |

**Note:**
- ¹ Tests.cmake uses `message(STATUS ...)` instead of `dbg()` — consistency clarification needed

### 2.3 Externals Modules (8/8 documented) ✅

| Module | File name | Module version | Status |
|-------|-----------|---------------|--------|
| Orchestrator.cmake | Orchestrator_cmake.md | 0.5.0 | ✅ Done |
| Core/Fetch.cmake | Fetch_cmake.md | 0.5.0 | ✅ Done |
| Fetched/Handler.cmake | Handler_cmake.md | 0.5.0 | ✅ Done |
| Local/Attach.cmake | Attach_cmake.md | 0.5.0 | ✅ Done |
| Hooks/HookLoader.cmake | HookLoader_cmake.md | 0.5.0 | ✅ Done |
| Registry/Targets.cmake | Targets_cmake.md | 0.5.0 | ✅ Done |
| hooks/prefetch/glfw.cmake | glfw_PreFetch.md | 0.5.0 | ✅ Done |
| hooks/postfetch/imgui.cmake | imgui_PostFetch.md | 0.5.0 | ✅ Done |

### 2.4 Include.cmake Documentation (4/4 documented) ✅

| External | File name | Module version | Status |
|----------|-----------|---------------|--------|
| includes/bass/Include.cmake | bass_Include.md | 0.5.0 | ✅ Done |
| includes/lua54/Include.cmake | lua54_Include.md | 0.5.0 | ✅ Done |
| includes/doctest/Include.cmake | doctest_Include.md | 0.5.0 | ✅ Done |
| includes/glad/Include.cmake | glad_Include.md | 0.5.0 | ✅ Done |

### 2.5 Externals Reference (v0.5.2 - 8 categories in parallel) ✅

**Main overview:**

| Document | File name | Content | Status |
|----------|-----------|--------|--------|
| Externals | Externals.md | All externals by category | ✅ v0.5.2 |

**Overview documents:**

| Type | File name | Content | Status |
|-----|-----------|--------|--------|
| Local | Local_Externals.md | Overview of local externals | ✅ v0.5.2 |
| Git | Git_Externals.md | Overview of Git externals | ✅ v0.5.2 |

**Category documents (8 categories, in parallel):**

| Category | Local | Git | Status |
|-----------|-------|-----|--------|
| Testing | Local_Externals_Testing.md (doctest) | Git_Externals_Testing.md (googletest, catch2) | ✅ v0.5.2 |
| Scripting | Local_Externals_Scripting.md (lua54) | Git_Externals_Scripting.md (sol2, pybind11) | ✅ v0.5.2 |
| GUI | Local_Externals_GUI.md (glad) | Git_Externals_GUI.md (glfw, imgui) | ✅ v0.5.2 |
| Media | Local_Externals_Media.md (BASS) | Git_Externals_Media.md (miniaudio, stb) | ✅ v0.5.2 |
| Core | — | Git_Externals_Core.md (spdlog, fmt, abseil) | ✅ v0.5.2 |
| Data | — | Git_Externals_Data.md | ✅ (Project Knowledge) |
| Network | — | Git_Externals_Network.md | ✅ (Project Knowledge) |
| AI | — | Git_Externals_AI.md | ✅ (Project Knowledge) |

### 2.6 Progress

```
Core modules:     [█████████████████████] 9/9   (100%)
Project modules:  [█████████████████████] 11/11 (100%)
Externals mods:   [█████████████████████] 8/8   (100%)
Include.cmake:    [█████████████████████] 4/4   (100%)
Externals ref:    [█████████████████████] 13/13 (100%)
─────────────────────────────────────────────────────────
Total:            [█████████████████████] 45/45 (100%)
```

---

## 3. Core Module Clarifications

### 3.1 Context.cmake — Base Module Without Debug/Errors

**Current state:**
- Only the `DEBUG_CONTEXT` cache variable for `ctx_dump()`
- No `dbg()` output
- No parameter validation

**Design decision:** Context.cmake stays without a Debug/Errors dependency, because:
- It is used by Debug.cmake (indirect dependency)
- A true base module without circular dependencies
- Easier to test

**Potential improvements (optional):**

| Situation | Current handling | Alternative |
|-----------|---------------------|-------------|
| `ctx_create("")` | Silent execution | cmake_assert? |
| `ctx_get()` non-existent | Empty string | Warning? |

---

### 3.2 Json.cmake — Fault-Tolerant Design

**Current state:**
- No debug output
- No explicit error codes
- Errors are signaled by empty return values

**Design decision:** Json.cmake stays without Debug/Errors, because:
- Validation is done by the calling modules (Validation.cmake)
- The fault-tolerant design is intended (defaults instead of exceptions)
- CMake 3.19+ JSON errors are handled internally

---

### 3.3 OutputDirs.cmake — Minimalist Module

**Current state:**
- No debug output
- No error handling
- CMake errors are passed through

**Recommendation:** Optionally add `dbg()` for tracing:
```cmake
dbg(${DBG_ULTRA_RARE} "  Output: ${_target_base}/bin" ID OUTPUT_DIRS)
```

---

### 3.4 Warnings.cmake — Very Simple Module

**Current state:**
- No debug output
- No error handling
- 72 lines of code

**Recommendation:** Stays without Debug/Errors — too simple for the overhead.

---

### 3.5 Important Clarification: Errors.cmake vs Warnings.cmake

| Module | Purpose | Functions |
|-------|-------|------------|
| **Errors.cmake** | Build system errors/warnings | `cmake_fatal()`, `cmake_warn()`, `cmake_assert()` |
| **Warnings.cmake** | Compiler warnings | `apply_warnings()` → `-Wall`, `/W4` |

⚠️ **Naming confusion:** `cmake_warn()` is defined in **Errors.cmake**, not in Warnings.cmake!

---

## 4. Project Module Clarifications

### 4.1 Tests.cmake — Inconsistent Debug Usage

**Problem:** Tests.cmake uses `message(STATUS "[Tests] ...")` instead of `dbg()`:

```cmake
message(STATUS "[Tests] === Test Pipeline Start ===")
message(STATUS "[Tests] Processing ${_tests_count} test(s)...")
```

**Recommendation:** Migration to `dbg()` for consistency with Executables.cmake and Libraries.cmake:

```cmake
dbg_init(ID TESTS LEVEL ${DBG_SHOW_MUCH} SWITCH ON TAG "Tests")
dbg(${DBG_OFTEN} "=== Test Pipeline Start ===" ID TESTS)
```

---

### 4.2 LibraryCollect.cmake — No Errors Integration

**Current state:** Only `cmake_fatal("E001" ...)` for a missing name field.

**Status:** ✅ Sufficient — further validation is done in LibraryCreate.

---

### 4.3 Externals.cmake — Minimal Error Handling

**Current state:** Delegates to Orchestrator.cmake.

**Status:** ✅ Sufficient — the orchestrator takes over validation.

---

## 5. Open Architecture Questions

### A1: Update CMake Modules to v0.5.0

**Question:** Should the CMake modules themselves be updated to version 0.5.0?

**Status:** The documentation is already at v0.5.0, the CMake files still at 0.1.x.

**Recommendation:** Yes, with the following changes:
- Update the header (version, date, "Based on: v0.5")
- No functional changes needed

---

### A2: Document the Externals Modules

**Question:** When should the externals modules (Orchestrator, Fetch, etc.) be documented?

**Pending:**
- Orchestrator.cmake
- Fetch.cmake
- Fetched_Handler.cmake
- Local_Attach.cmake
- Registry_Targets.cmake
- HookLoader.cmake
- Pre/PostFetch hooks

---

### A3: Tests.cmake Debug Migration

**Question:** Should Tests.cmake be migrated from `message()` to `dbg()`?

**Pro:**
- Consistency with Executables.cmake, Libraries.cmake
- Controllable verbosity

**Contra:**
- Works currently
- Low effort

**Recommendation:** Migration in v0.5.0 or v0.6.0

---

## 6. Recommendations

### Immediately (v0.5.0)

| Action | Priority | Status |
|--------|-----------|--------|
| Core module documentation | High | ✅ Done |
| Project module documentation | High | ✅ Done |
| CMake module headers to v0.5.0 | Medium | 🔲 Pending |

### Short Term (v0.5.x)

| Action | Priority | Status |
|--------|-----------|--------|
| Document externals modules | High | 🔲 Pending |
| Tests.cmake → dbg() migration | Low | 🔲 Optional |
| Add dbg() to OutputDirs.cmake | Low | 🔲 Optional |

### Medium Term (v0.6.x)

| Action | Priority |
|--------|-----------|
| Guidelines update for base modules | Medium |
| Complete the error code documentation | Medium |
| English translations | Low |

---

## 7. Decision Matrix

### Core Modules

| Module | Doc v0.5.0 | Add debug? | Add errors? |
|-------|-------------|-------------------|-------------------|
| CompilerOptions.cmake | ✅ | 🟢 Present | 🟢 Present |
| Context.cmake | ✅ | 🔴 No (base) | 🔴 No (base) |
| Debug.cmake | ✅ | — | — |
| Errors.cmake | ✅ | — | — |
| Json.cmake | ✅ | 🔴 No (design) | 🔴 No (design) |
| OutputDirs.cmake | ✅ | 🟡 Optional | ⚪ Optional |
| SourceCollect.cmake | ✅ | 🟢 Present | 🟢 Present |
| Validation.cmake | ✅ | ⚪ Optional | 🟢 Present |
| Warnings.cmake | ✅ | ⚪ Optional | ⚪ Optional |

### Project Modules

| Module | Doc v0.5.0 | Debug | Errors | Action needed? |
|-------|-------------|-------|--------|---------------|
| Solution.cmake | ✅ | ✅ | ✅ | ❌ |
| Executables.cmake | ✅ | ✅ | ✅ | ❌ |
| ExecutableCollect.cmake | ✅ | ✅ | ✅ | ❌ |
| ExecutableCreate.cmake | ✅ | ✅ | ✅ | ❌ |
| Libraries.cmake | ✅ | ✅ | ✅ | ❌ |
| LibraryCollect.cmake | ✅ | ✅ | ❌ | ⚪ Optional |
| LibraryCreate.cmake | ✅ | ✅ | ✅ | ❌ |
| Externals.cmake | ✅ | ✅ | ❌ | ❌ |
| Tests.cmake | ✅ | ❌¹ | ❌ | 🟡 Migration |
| TestCollect.cmake | ✅ | ✅ | ❌ | ❌ |
| TestCreate.cmake | ✅ | ✅ | ✅ | ❌ |

**Legend:**
- ✅ Done / present
- 🟢 Already present
- 🟡 Recommended
- ⚪ Optional
- 🔴 Not recommended
- ❌ No action needed
- ¹ Uses message() instead of dbg()

---

## 8. Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-15 | Extended to all modules (core + project), documentation status tracking, progress display, updated decision matrix |
| 0.1.0 | 2025-12-15 | Initial: analysis of the core modules for debug/error consistency |
