# Core/Fetch.cmake — FetchContent Wrapper with Caching

> **Version:** 1.1.0  
> **Date:** 2026-08-08  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5, Doc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [Fetch_cmake.md](../../../../../de/guide/module/externals/core/Fetch_cmake.md)  
> **Module:** [cmake/externals/Core/Fetch.cmake](../../../../../../cmake/externals/core/Fetch.cmake)  
> **Module Version:** 1.1.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Configuration](#3-configuration)
4. [API Reference](#4-api-reference)
5. [Caching Logic](#5-caching-logic)
6. [Git References](#6-git-references)
7. [Usage Examples](#7-usage-examples)
8. [Error Handling](#8-error-handling)
9. [See Also](#9-see-also)
10. [Changelog](#10-changelog)

---

## 1. Overview

`Core/Fetch.cmake` is a wrapper around CMake's `FetchContent` that implements intelligent caching in a central `.externals/` directory.

### Core Functions

- **Cross-preset caching** — All build presets share the same downloads
- **Offline mode** — Working without network access
- **Force fetch** — Forcing a fresh download
- **Version checking** — Automatic detection of outdated caches

### Architecture

```
.externals/                     ← Central cache directory
├── spdlog/
├── glfw/
└── imgui/

build-windows-debug/            ← Build directory (preset)
build-linux-release/            ← Other preset, SAME cache
```

---

## 2. Dependencies

| Module | Purpose |
|--------|---------|
| `FetchContent` | CMake built-in for downloads |
| `Errors.cmake` | Error handling |
| `Debug.cmake` | Debug output |
| `Json.cmake` | JSON parsing |

---

## 3. Configuration

### Cache Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `EXTERNALS_FETCH_ROOT` | `${CMAKE_SOURCE_DIR}/.externals` | Cache directory |

### Options

| Option | Default | Description |
|--------|---------|-------------|
| `EXTERNALS_OFFLINE` | `OFF` | Use the cache only, no network |
| `EXTERNALS_FORCE_FETCH` | `OFF` | Download all externals again |

---

## 4. API Reference

### 4.1 _fetch_git_external()

```cmake
_fetch_git_external(EXT_NAME EXT_JSON)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `EXT_NAME` | String | Name of the external |
| `EXT_JSON` | JSON | JSON definition with `git`, `tag/branch/commit` |

**JSON fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `git` | ✓ | Repository URL |
| `tag` | ¹ | Git tag (e.g. "v1.12.0") |
| `branch` | ¹ | Git branch (e.g. "main") |
| `commit` | ¹ | Git commit hash |
| `shallow` | ✗ | Shallow clone (default: true) |

¹ Exactly one of `tag`, `branch`, `commit` is required.

---

### 4.2 _make_external_available()

```cmake
_make_external_available(EXT_NAME)
```

Makes a declared external available (downloads it if necessary).

---

### 4.3 _is_external_populated()

```cmake
_is_external_populated(EXT_NAME OUT_VAR)
```

Checks whether an external is available.

---

### 4.4 _get_external_source_dir()

```cmake
_get_external_source_dir(EXT_NAME OUT_VAR)
```

Returns the source path of an external.

---

### 4.5 _is_complete_clone()

```cmake
_is_complete_clone(EXT_NAME CACHE_DIR OUT_OK)
```

> **Since:** module version 1.1.0

Decides whether `CACHE_DIR` holds a usable clone or only the debris of an
aborted fetch. The criterion is a resolvable `HEAD`
(`git rev-parse --verify --quiet HEAD`) — that exists only once the clone got
far enough to check something out.

Without an available `git` the question cannot be decided; the clone then counts
as complete. That is harmless: without `git`, `_check_cached_version()` reports
"mismatch" anyway, so the external gets fetched again either way.

---

### 4.6 _purge_cache_dir()

```cmake
_purge_cache_dir(EXT_NAME CACHE_DIR)
```

> **Since:** module version 1.1.0

Removes `CACHE_DIR` completely and verifies that it is actually gone. If the
directory survives, the function aborts with **E219** — naming the path, the
usual causes (open file, path too long) and what to do.

Doing the removal here instead of leaving it to FetchContent is the whole
point: at this spot it is still known *which* external is affected and *why*
the directory has to go.

---

## 5. Caching Logic

### Decision Tree

```
FORCE_FETCH=ON?  ──YES──► FETCH
       │
       NO
       ▼
.git present?   ──NO──► directory there? ──YES──► OFFLINE? ──YES──► E218 ERROR
       │                      │                      │
      YES                     NO                     NO
       │                      │                      ▼
       │                      ▼             W303 + REMOVE + FETCH
       │                 OFFLINE? ──YES──► E218 ERROR
       │                      │
       │                      NO
       │                      ▼
       │                    FETCH
       ▼
Clone complete? ──NO──► OFFLINE? ──YES──► E218 ERROR
       │                      │
      YES                     NO
       │                      ▼
       │              W303 + REMOVE + FETCH
       ▼
Version match? ──YES──► USE CACHE
       │
       NO
       ▼
OFFLINE? ──YES──► W302 + USE CACHE
    │
    NO
    ▼
  FETCH
```

### Why "Clone Complete?" Is a Question of Its Own

`git clone` creates `.git` early and fills it afterwards. If the operation is
interrupted — network gone, Ctrl-C, disk full — a `.git` without a checked-out
state stays behind. The existence of `.git` therefore does **not** mean that a
usable clone lives there.

Until v0.9.0 this distinction was missing, with two consequences:

1. The version comparison ran on debris and reported **"Version mismatch"** —
   a diagnosis pointing in the wrong direction.
2. Cleaning up was left to FetchContent. When its removal attempt failed, the
   message named neither the cause nor a way out.

Since v0.9.1, [`_is_complete_clone()`](#45-_is_complete_clone) checks whether a
`HEAD` can be resolved — which exists only once the clone got far enough. If it
is incomplete, [`_purge_cache_dir()`](#46-_purge_cache_dir) cleans up itself and,
on failure, reports **E219** with cause and remedy.

**Deliberately unchanged:** for a *complete* clone with a differing version,
FetchContent still does the removal. Removing it up front at this spot would
re-fetch branch-pinned externals on every configure — `_check_cached_version()`
always reports "mismatch" for branches.

---

## 6. Git References

### Tag (recommended)

```json
{
    "spdlog": {
        "git": "https://github.com/gabime/spdlog.git",
        "tag": "v1.12.0"
    }
}
```

### Commit

```json
{
    "imgui": {
        "git": "https://github.com/ocornut/imgui.git",
        "commit": "a1234567890abcdef"
    }
}
```

### Branch (not recommended)

```json
{
    "experimental": {
        "git": "https://github.com/example/lib.git",
        "branch": "develop"
    }
}
```

---

## 7. Usage Examples

### Standard Usage (via Handler)

```cmake
_fetch_git_external("spdlog" "${_ext_json}")
_make_external_available("spdlog")
```

### CI/CD Offline Build

```bash
cmake -B build-ci -DEXTERNALS_OFFLINE=ON
```

---

## 8. Error Handling

| Code | Error | Description |
|------|-------|-------------|
| E012 | No git URL | `git` field missing or empty |
| E202 | Fetch failed | FetchContent could not load the external |
| E215 | No version | No tag/branch/commit given |
| E218 | Offline without cache | External not cached (or only incompletely), OFFLINE=ON |
| E219 | Cache not removable | Unusable cache directory could not be removed |

| Code | Warning | Description |
|------|---------|-------------|
| W302 | Version differs | Offline mode uses the cache anyway |
| W303 | Incomplete clone | Remains of an aborted fetch — removed and fetched again |

---

## 9. See Also

- [Handler_cmake.md](../fetched/Handler_cmake.md) — Fetched external pipeline
- [HookLoader_cmake.md](../hooks/HookLoader_cmake.md) — Pre/PostFetch hooks
- [Orchestrator_cmake.md](../Orchestrator_cmake.md) — Type dispatcher

---

## 10. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.1.0** | **2026-08-08** | **Module version 1.1.0: `_is_complete_clone()` and `_purge_cache_dir()` documented; decision tree extended by the completeness check; E219/W303 added** |
| 0.5.0 | 2025-12-15 | Documentation migrated to Blueprint v0.5.0 |
