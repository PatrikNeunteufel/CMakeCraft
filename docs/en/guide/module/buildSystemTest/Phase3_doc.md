# phase3.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Path:** `cmake/buildSystemTest/phase3.cmake`  
> **Status:** Stable  
> **Language:** English  
> **German:** [Phase3_doc.md](../../../../de/guide/module/buildSystemTest/Phase3_doc.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Tests](#2-tests)
3. [Success Flag](#3-success-flag)
4. [See Also](#4-see-also)
5. [Changelog](#changelog)

---

## 1. Overview

**Phase 3** tests the **executable pipeline** — the creation of executable targets.

| Aspect | Description |
|--------|-------------|
| **Purpose** | Executable pipeline validation |
| **Debug ID** | `PHASE3_TEST` |
| **Dependencies** | Phase 1-2, Executables.cmake |

---

## 2. Tests

### 2.1 Pipeline Modules Loaded

| Function | Checks |
|----------|--------|
| `_collect_executable` | ExecutableCollect.cmake loaded |
| `_create_executable_target` | ExecutableCreate.cmake loaded |

### 2.2 Executables from Solution.json

| Check | Description |
|-------|-------------|
| `executables` array | Present in Solution.json |
| Count | Is counted and printed |
| Active vs. skipped | The skip flag is checked |

### 2.3 Context with Test Data

Tests `_collect_executable` with synthetic JSON:

```cmake
set(_test_exe_json "{
    \"name\": \"TestExe\",
    \"displayName\": \"Test Executable\",
    \"version\": \"1.0.0\",
    \"path\": \"test/path\",
    \"type\": \"CONSOLE\",
    \"skip\": false,
    \"pch\": { \"enabled\": true, \"header\": \"pch.h\" }
}")
```

| Field | Expected |
|-------|----------|
| `NAME` | TestExe |
| `DISPLAY_NAME` | Test Executable |
| `VERSION` | 1.0.0 |
| `TYPE` | CONSOLE |
| `SKIP` | FALSE |
| `PCH_ENABLED` | TRUE |

### 2.4 Default Values

Tests the minimal JSON `{"name": "MinimalExe"}`:

| Field | Default |
|-------|---------|
| `PATH` | `projects/exec/MinimalExe/src` |
| `TYPE` | `SOLUTION_DEFAULT_EXECUTABLE_TYPE` or CONSOLE |

### 2.5 Targets Created

Checks that a CMake target exists for every active executable:

```cmake
if(TARGET ${_exe_name})
    # OK
endif()
```

---

## 3. Success Flag

```cmake
set(PHASE3_TEST_PASSED TRUE CACHE BOOL "Phase 3 Test passed" FORCE)
```

---

## 4. See Also

- [Executables.md](../project/Executables.md)
- [ExecutableCollect.md](../project/ExecutableCollect.md)
- [ExecutableCreate.md](../project/ExecutableCreate.md)

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-15 | Blueprint v0.5.0 format |
| 0.1.0 | 2025-12-05 | Initial |
