# Core/Fetch.cmake — FetchContent Wrapper mit Caching

> **Version:** 1.1.0  
> **Date:** 2026-08-08  
> **Type:** ModuleDoc  
> **Status:** Aktiv  
> **Based on:** ModuleDoc v0.5, Doc v0.5  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [Fetch_cmake.md](Fetch_cmake.md)  
> **Module:** [cmake/externals/Core/Fetch.cmake](../../../cmake/externals/Core/Fetch.cmake)  
> **Module Version:** 1.1.0

---

## Table of Contents

1. [Overview](#1-übersicht)
2. [Dependencies](#2-abhängigkeiten)
3. [Configuration](#3-konfiguration)
4. [API-Reference](#4-api-referenz)
5. [Caching-Logik](#5-caching-logik)
6. [Git-Referenceen](#6-git-referenzen)
7. [Usagesbeispiele](#7-verwendungsbeispiele)
8. [Errorbehandlung](#8-fehlerbehandlung)
9. [See Also](#9-siehe-auch)
10. [Changelog](#10-changelog)

---

## 1. Overview

`Core/Fetch.cmake` ist ein Wrapper um CMakes `FetchContent`, der intelligentes Caching in einem zentralen `.externals/` Verzeichnis implementiert.

### Kernfunktionen

- **Preset-übergreifendes Caching** — Alle Build-Presets teilen dieselben Downloads
- **Offline-Modus** — Arbeiten ohne Netzwerkzugriff
- **Force-Fetch** — Erzwingen eines erneuten Downloads
- **Version-Checking** — Automatische Erkennung veralteter Caches

### Architecture

```
.externals/                     ← Zentrales Cache-Verzeichnis
├── spdlog/
├── glfw/
└── imgui/

build-windows-debug/            ← Build-Verzeichnis (Preset)
build-linux-release/            ← Anderes Preset, GLEICHER Cache
```

---

## 2. Dependencies

| Modul | Zweck |
|-------|-------|
| `FetchContent` | CMake Built-in für Downloads |
| `Errors.cmake` | Errorbehandlung |
| `Debug.cmake` | Debug-Ausgaben |
| `Json.cmake` | JSON-Parsing |

---

## 3. Configuration

### Cache-Variablen

| Variable | Default | Description |
|----------|---------|--------------|
| `EXTERNALS_FETCH_ROOT` | `${CMAKE_SOURCE_DIR}/.externals` | Cache-Verzeichnis |

### Optionen

| Option | Default | Description |
|--------|---------|--------------|
| `EXTERNALS_OFFLINE` | `OFF` | Nur Cache verwenden, kein Netzwerk |
| `EXTERNALS_FORCE_FETCH` | `OFF` | Alle Externals neu herunterladen |

---

## 4. API-Reference

### 4.1 _fetch_git_external()

```cmake
_fetch_git_external(EXT_NAME EXT_JSON)
```

| Parameters | Typ | Description |
|-----------|-----|--------------|
| `EXT_NAME` | String | Name des Externals |
| `EXT_JSON` | JSON | JSON-Definition mit `git`, `tag/branch/commit` |

**JSON-Felder:**

| Feld | Required | Description |
|------|---------|--------------|
| `git` | ✓ | Repository-URL |
| `tag` | ¹ | Git-Tag (z.B. "v1.12.0") |
| `branch` | ¹ | Git-Branch (z.B. "main") |
| `commit` | ¹ | Git-Commit-Hash |
| `shallow` | ✗ | Shallow Clone (default: true) |

¹ Genau eines von `tag`, `branch`, `commit` erforderlich.

---

### 4.2 _make_external_available()

```cmake
_make_external_available(EXT_NAME)
```

Macht ein deklariertes External verfügbar (Download falls nötig).

---

### 4.3 _is_external_populated()

```cmake
_is_external_populated(EXT_NAME OUT_VAR)
```

Prüft ob ein External verfügbar ist.

---

### 4.4 _get_external_source_dir()

```cmake
_get_external_source_dir(EXT_NAME OUT_VAR)
```

Gibt den Source-Pfad eines Externals zurück.

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

Without a `git` executable the question cannot be answered and the clone counts
as complete. That is harmless: without `git`, `_check_cached_version()` reports
a mismatch anyway, so the external gets fetched either way.

---

### 4.6 _purge_cache_dir()

```cmake
_purge_cache_dir(EXT_NAME CACHE_DIR)
```

> **Since:** module version 1.1.0

Removes `CACHE_DIR` completely and verifies it is gone. If the directory
survives, the function fails with **E219** — naming the path, the usual causes
(open file, path too long) and what to do.

Doing the removal here instead of leaving it to FetchContent is the whole
point: at this spot it is still known *which* external is affected and *why*
the directory has to go.

---

## 5. Caching-Logik

### Entscheidungsbaum

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

### Why "clone complete?" is a question of its own

`git clone` creates `.git` early and fills it afterwards. If it is interrupted —
network loss, Ctrl-C, a full disk — a `.git` without a checked-out commit stays
behind. The presence of `.git` therefore does **not** mean a usable clone lives
there.

Until v0.9.0 that distinction was missing, with two consequences:

1. The version comparison ran against debris and reported **"version mismatch"** —
   a diagnosis pointing in the wrong direction.
2. Cleaning up was left to FetchContent. When its removal failed, the message
   named neither the cause nor a way out.

Since v0.9.1, [`_is_complete_clone()`](#45-_is_complete_clone) checks whether a
`HEAD` resolves — which it does only once the clone got far enough. If the clone
is incomplete, [`_purge_cache_dir()`](#46-_purge_cache_dir) cleans up and, should
that fail, reports **E219** with cause and remedy.

**Deliberately unchanged:** for a *complete* clone with a differing version,
FetchContent still does the removal. Purging up front there would re-fetch
branch-pinned externals on every configure — `_check_cached_version()` reports
"mismatch" for branches by design.

---

## 6. Git-Referenceen

### Tag (empfohlen)

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

### Branch (nicht empfohlen)

```json
{
    "experimental": {
        "git": "https://github.com/example/lib.git",
        "branch": "develop"
    }
}
```

---

## 7. Usagesbeispiele

### Standard-Usage (via Handler)

```cmake
_fetch_git_external("spdlog" "${_ext_json}")
_make_external_available("spdlog")
```

### CI/CD Offline-Build

```bash
cmake -B build-ci -DEXTERNALS_OFFLINE=ON
```

---

## 8. Errorbehandlung

| Code | Error | Description |
|------|--------|--------------|
| E012 | Keine git URL | `git` Feld fehlt oder leer |
| E202 | Fetch fehlgeschlagen | FetchContent konnte External nicht laden |
| E215 | Keine Version | Kein tag/branch/commit angegeben |
| E218 | Offline without cache | External not cached (or only partially), OFFLINE=ON |
| E219 | Cache not removable | An unusable cache directory could not be removed |

| Code | Warning | Description |
|------|---------|-------------|
| W302 | Version differs | Offline mode uses the cache anyway |
| W303 | Incomplete clone | Debris of an aborted fetch — removed and fetched again |

---

## 9. See Also

- [Handler_cmake.md](Handler_cmake.md) — Fetched External Pipeline
- [HookLoader_cmake.md](../hooks/HookLoader_cmake.md) — Pre/PostFetch Hooks
- [Orchestrator_cmake.md](../Orchestrator_cmake.md) — Type Dispatcher

---

## 10. Changelog

| Version | Datum | Changes |
|---------|-------|------------|
| **1.1.0** | **2026-08-08** | **Module version 1.1.0: `_is_complete_clone()` and `_purge_cache_dir()` documented; decision tree extended by the completeness check; E219/W303 added** |
| 0.5.0 | 2025-12-15 | Dokumentation auf Blueprint v0.5.0 migriert |
