# phase5.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Path:** `cmake/buildSystemTest/phase5.cmake`  
> **Status:** Stable  
> **Language:** English  
> **German:** [Phase5_doc.md](../../../../de/guide/module/buildSystemTest/Phase5_doc.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Tests](#2-tests)
3. [Success Flag](#3-success-flag)
4. [See Also](#4-see-also)
5. [Changelog](#changelog)

---

## 1. Overview

**Phase 5** tests the **local externals pipeline** — registering and applying local external libraries.

| Aspect | Description |
|--------|-------------|
| **Purpose** | Local externals validation |
| **Debug ID** | `PHASE5_TEST` |
| **Dependencies** | Phase 1-4, Externals.cmake |

---

## 2. Tests

### 2.1 SOLUTION_EXTERNALS_JSON

Checks that the externals JSON property exists:

```cmake
get_property(_externals_json GLOBAL PROPERTY SOLUTION_EXTERNALS_JSON)
```

### 2.2 External Definition (bass)

Checks that `bass` is defined in the externals block:

```cmake
_json_has_key("${_externals_json}" "bass" _has_bass)
```

### 2.3 External Registration

Checks that `bass` was registered:

| Property | Description |
|----------|-------------|
| `EXTERNAL_bass_REGISTERED` | `TRUE` |
| `EXTERNAL_bass_PATH` | Path to the external |
| `EXTERNAL_bass_INCLUDE` | Include directory |

### 2.4 External in Target

Checks that `MinimalConsole` has linked the external library:

```cmake
get_target_property(_link_libs MinimalConsole LINK_LIBRARIES)
string(FIND "${_link_libs}" "bass" _bass_pos)
```

### 2.5 External Options

Checks the processing of `external_options` (e.g. `BASS_FLAC`):

```cmake
_json_get_object_or_empty("${_exe_json}" "external_options" _ext_opts)
_json_has_key("${_ext_opts}" "bass" _has_bass_opts)
```

---

## 3. Success Flag

```cmake
set(PHASE5_TEST_PASSED TRUE CACHE BOOL "Phase 5 Test passed" FORCE)
```

---

## 4. See Also

- [Externals.md](../project/Externals.md)
- [Orchestrator.md](../externals/Orchestrator_cmake.md)
- [Attach.md](../externals/locals/Attach_cmake.md)
- [Local_Externals.md](../../references/externals/Local_Externals.md)

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-15 | Blueprint v0.5.0 format |
| 0.1.0 | 2025-12-08 | Initial |
