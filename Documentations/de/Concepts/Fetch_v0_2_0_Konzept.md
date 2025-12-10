# Fetch.cmake v0.2.0 – Konzept mit .externals/ Caching

> **Version:** 0.2.0 (Konzept)  
> **Datum:** 2025-12-09  
> **Status:** Entwurf  
> **Basiert auf:** Fetch.cmake v0.1.0

---

## 1. Problem-Analyse

Die aktuelle Implementierung (v0.1.0) hat folgende Nachteile:

| Problem | Auswirkung |
|---------|------------|
| Redundanter Download | Bei jedem Configure wird geprüft/gefetcht |
| Preset-Wechsel | Jedes Preset hat eigenes Build-Dir → separate Downloads |
| Offline-Fehler | Ohne Netzwerk schlägt Configure fehl, obwohl Source existiert |
| Platzverschwendung | Mehrfache Kopien bei verschiedenen Presets |
| Unklare Trennung | Lokale und gefetchte Externals vermischt |

---

## 2. Lösung: `.externals/` Convention

### 2.1 Verzeichnisstruktur

```
project_root/
├── .externals/                 ← Gefetchte Externals (gitignored, versteckt)
│   ├── glfw/
│   │   └── .git/
│   ├── imgui/
│   │   └── .git/
│   ├── spdlog/
│   │   └── .git/
│   └── .lockfile.json          ← Versions-Tracking
│
├── externals/                  ← Lokale Externals (im Repository)
│   ├── bass/
│   │   └── Include.cmake
│   ├── glad/
│   │   └── Include.cmake
│   ├── lua54/
│   │   └── Include.cmake
│   └── doctest/
│       └── Include.cmake
│
├── build/                      ← Build-Verzeichnisse (alle teilen .externals/)
│   ├── msvc-debug/
│   ├── msvc-release/
│   ├── clang-debug/
│   └── ninja-release/
│
├── Solution.json
└── .gitignore
```

### 2.2 Klare Trennung

| Verzeichnis | Inhalt | Git-Status | Quelle |
|-------------|--------|------------|--------|
| `externals/` | Lokale Externals | ✅ Committed | `path` in Solution.json |
| `.externals/` | Gefetchte Externals | ❌ Gitignored | `git` in Solution.json |

### 2.3 .gitignore

```gitignore
# Gefetchte Externals (werden bei Bedarf automatisch geladen)
/.externals/

# Build-Verzeichnisse
/build/
/out/

# IDE
/.vs/
/.idea/
*.user
```

---

## 3. Implementierung

### 3.1 Fetch.cmake v0.2.0

```cmake
# ==============================================================================
# Core/Fetch.cmake – FetchContent Wrapper with .externals/ Caching
# ==============================================================================
#
# Version:      0.2.0
# Date:         2025-12-09
#
# Changes from v0.1.0:
#   - Central .externals/ directory for all presets
#   - Skip fetch if already cached
#   - Lockfile support for version tracking
#   - Offline mode support
#   - Force fetch option
#
# ==============================================================================

include_guard(GLOBAL)
include(FetchContent)

# ==============================================================================
# Configuration
# ==============================================================================

# Central directory for fetched externals (relative to SOURCE_DIR)
set(EXTERNALS_FETCH_ROOT "${CMAKE_SOURCE_DIR}/.externals" CACHE PATH 
    "Directory for fetched externals")

# Lockfile path
set(EXTERNALS_LOCKFILE "${EXTERNALS_FETCH_ROOT}/.lockfile.json" CACHE PATH
    "Lockfile for tracking fetched versions")

# Options
option(EXTERNALS_OFFLINE "Use only cached externals, no network access" OFF)
option(EXTERNALS_FORCE_FETCH "Force re-fetch of all externals" OFF)

# ==============================================================================
# _fetch_git_external - Fetch a Git-based external with caching
# ==============================================================================
function(_fetch_git_external EXT_NAME EXT_JSON)
    
    # ==========================================================================
    # Extract Git URL and Version
    # ==========================================================================
    
    _json_get_string("${EXT_JSON}" "git" _git_url)
    
    if("${_git_url}" STREQUAL "")
        cmake_fatal("E012" "External '${EXT_NAME}': No 'git' URL specified")
    endif()
    
    # Get version reference
    _extract_git_ref("${EXT_JSON}" _git_ref _ref_type)
    
    # Target directory in .externals/
    set(_cache_dir "${EXTERNALS_FETCH_ROOT}/${EXT_NAME}")
    
    dbg(${DBG_COMMON} "[${EXT_NAME}] Git: ${_git_url}" ID EXTERNALS)
    dbg(${DBG_COMMON} "[${EXT_NAME}] ${_ref_type}: ${_git_ref}" ID EXTERNALS)
    dbg(${DBG_RARE} "[${EXT_NAME}] Cache: ${_cache_dir}" ID EXTERNALS)
    
    # ==========================================================================
    # CHECK 1: Force Fetch?
    # ==========================================================================
    
    if(EXTERNALS_FORCE_FETCH)
        dbg(${DBG_COMMON} "[${EXT_NAME}] Force fetch requested" ID EXTERNALS)
        set(_do_fetch TRUE)
        
    # ==========================================================================
    # CHECK 2: Already Cached?
    # ==========================================================================
    
    elseif(EXISTS "${_cache_dir}/.git")
        dbg(${DBG_COMMON} "[${EXT_NAME}] Found in cache" ID EXTERNALS)
        
        # Optional: Check if version matches
        _check_cached_version("${EXT_NAME}" "${_git_ref}" "${_ref_type}" "${_cache_dir}" _version_match)
        
        if(_version_match)
            dbg(${DBG_COMMON} "[${EXT_NAME}] Version OK, skipping fetch" ID EXTERNALS)
            message(STATUS "[${EXT_NAME}] Using cached version")
            set(_do_fetch FALSE)
        else()
            dbg(${DBG_COMMON} "[${EXT_NAME}] Version mismatch, will update" ID EXTERNALS)
            
            if(EXTERNALS_OFFLINE)
                cmake_warn("W302" "External '${EXT_NAME}': Version mismatch but offline mode - using cached")
                set(_do_fetch FALSE)
            else()
                set(_do_fetch TRUE)
            endif()
        endif()
        
    # ==========================================================================
    # CHECK 3: Offline Mode without Cache?
    # ==========================================================================
    
    elseif(EXTERNALS_OFFLINE)
        cmake_fatal("E218" "External '${EXT_NAME}': Not cached and offline mode enabled")
        
    # ==========================================================================
    # Not cached, need to fetch
    # ==========================================================================
    
    else()
        dbg(${DBG_COMMON} "[${EXT_NAME}] Not cached, will fetch" ID EXTERNALS)
        set(_do_fetch TRUE)
    endif()
    
    # ==========================================================================
    # Perform Fetch (if needed)
    # ==========================================================================
    
    if(_do_fetch)
        message(STATUS "[${EXT_NAME}] Fetching from ${_git_url}...")
        
        # Ensure .externals/ directory exists
        file(MAKE_DIRECTORY "${EXTERNALS_FETCH_ROOT}")
        
        # Build fetch arguments
        _build_fetch_args("${EXT_JSON}" "${_git_ref}" "${_ref_type}" _fetch_args)
        
        # Convert name to lowercase for FetchContent
        string(TOLOWER "${EXT_NAME}" _ext_lower)
        
        FetchContent_Declare(
            ${_ext_lower}
            GIT_REPOSITORY "${_git_url}"
            ${_fetch_args}
            SOURCE_DIR "${_cache_dir}"
        )
        
        # Mark as declared for MakeAvailable
        set_property(GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_DECLARED TRUE)
        set_property(GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_NEEDS_FETCH TRUE)
        
    else()
        # Use cached version directly
        set_property(GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_DECLARED TRUE)
        set_property(GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_NEEDS_FETCH FALSE)
    endif()
    
    # Store paths
    set_property(GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_SOURCE_DIR "${_cache_dir}")
    set_property(GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_JSON "${EXT_JSON}")
    
endfunction()

# ==============================================================================
# _make_external_available - Make external available (fetch if needed)
# ==============================================================================
function(_make_external_available EXT_NAME)
    string(TOLOWER "${EXT_NAME}" _ext_lower)
    
    get_property(_needs_fetch GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_NEEDS_FETCH)
    get_property(_cache_dir GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_SOURCE_DIR)
    
    if(_needs_fetch)
        dbg(${DBG_COMMON} "[${EXT_NAME}] Downloading..." ID EXTERNALS)
        
        set(FETCHCONTENT_QUIET ON)
        FetchContent_MakeAvailable(${_ext_lower})
        
        # Update lockfile
        _update_lockfile("${EXT_NAME}")
        
        message(STATUS "[${EXT_NAME}] Fetched successfully")
    else()
        dbg(${DBG_COMMON} "[${EXT_NAME}] Using cached: ${_cache_dir}" ID EXTERNALS)
    endif()
    
    # Verify populated
    if(EXISTS "${_cache_dir}/.git" OR EXISTS "${_cache_dir}/CMakeLists.txt")
        set_property(GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_POPULATED TRUE)
    else()
        cmake_fatal("E202" "External '${EXT_NAME}': Source directory invalid after fetch")
    endif()
    
endfunction()

# ==============================================================================
# Helper: Extract Git Reference
# ==============================================================================
function(_extract_git_ref EXT_JSON OUT_REF OUT_TYPE)
    _json_has_key("${EXT_JSON}" "tag" _has_tag)
    _json_has_key("${EXT_JSON}" "branch" _has_branch)
    _json_has_key("${EXT_JSON}" "commit" _has_commit)
    
    if(_has_tag)
        _json_get_string("${EXT_JSON}" "tag" _ref)
        set(${OUT_REF} "${_ref}" PARENT_SCOPE)
        set(${OUT_TYPE} "tag" PARENT_SCOPE)
    elseif(_has_branch)
        _json_get_string("${EXT_JSON}" "branch" _ref)
        set(${OUT_REF} "${_ref}" PARENT_SCOPE)
        set(${OUT_TYPE} "branch" PARENT_SCOPE)
    elseif(_has_commit)
        _json_get_string("${EXT_JSON}" "commit" _ref)
        set(${OUT_REF} "${_ref}" PARENT_SCOPE)
        set(${OUT_TYPE} "commit" PARENT_SCOPE)
    else()
        cmake_fatal("E215" "External: No tag/branch/commit specified")
    endif()
endfunction()

# ==============================================================================
# Helper: Check Cached Version
# ==============================================================================
function(_check_cached_version EXT_NAME EXPECTED_REF REF_TYPE CACHE_DIR OUT_MATCH)
    # For tags: check if current HEAD matches tag
    # For commits: check if HEAD matches commit
    # For branches: always consider as potentially outdated
    
    if("${REF_TYPE}" STREQUAL "branch")
        # Branches can change, consider outdated unless offline
        set(${OUT_MATCH} FALSE PARENT_SCOPE)
        return()
    endif()
    
    # Try to get current HEAD
    execute_process(
        COMMAND git rev-parse HEAD
        WORKING_DIRECTORY "${CACHE_DIR}"
        OUTPUT_VARIABLE _current_head
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
        RESULT_VARIABLE _git_result
    )
    
    if(NOT _git_result EQUAL 0)
        set(${OUT_MATCH} FALSE PARENT_SCOPE)
        return()
    endif()
    
    if("${REF_TYPE}" STREQUAL "commit")
        # Direct commit comparison
        string(SUBSTRING "${_current_head}" 0 7 _short_head)
        string(SUBSTRING "${EXPECTED_REF}" 0 7 _short_expected)
        
        if("${_short_head}" STREQUAL "${_short_expected}")
            set(${OUT_MATCH} TRUE PARENT_SCOPE)
        else()
            set(${OUT_MATCH} FALSE PARENT_SCOPE)
        endif()
        return()
    endif()
    
    if("${REF_TYPE}" STREQUAL "tag")
        # Check if tag exists and points to current HEAD
        execute_process(
            COMMAND git rev-parse "${EXPECTED_REF}^{}"
            WORKING_DIRECTORY "${CACHE_DIR}"
            OUTPUT_VARIABLE _tag_commit
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
            RESULT_VARIABLE _tag_result
        )
        
        if(_tag_result EQUAL 0 AND "${_tag_commit}" STREQUAL "${_current_head}")
            set(${OUT_MATCH} TRUE PARENT_SCOPE)
        else()
            set(${OUT_MATCH} FALSE PARENT_SCOPE)
        endif()
        return()
    endif()
    
    # Default: no match
    set(${OUT_MATCH} FALSE PARENT_SCOPE)
endfunction()

# ==============================================================================
# Helper: Build Fetch Arguments
# ==============================================================================
function(_build_fetch_args EXT_JSON GIT_REF REF_TYPE OUT_ARGS)
    set(_args "")
    
    # Git reference
    if("${REF_TYPE}" STREQUAL "branch")
        list(APPEND _args GIT_TAG "origin/${GIT_REF}")
    else()
        list(APPEND _args GIT_TAG "${GIT_REF}")
    endif()
    
    # Shallow clone (not for commits)
    if(NOT "${REF_TYPE}" STREQUAL "commit")
        _json_has_key("${EXT_JSON}" "shallow" _has_shallow)
        if(_has_shallow)
            _json_get_bool_from_key("${EXT_JSON}" "shallow" _shallow)
        else()
            set(_shallow TRUE)
        endif()
        
        if(_shallow)
            list(APPEND _args GIT_SHALLOW TRUE)
        endif()
    endif()
    
    # Progress
    list(APPEND _args GIT_PROGRESS TRUE)
    
    set(${OUT_ARGS} ${_args} PARENT_SCOPE)
endfunction()

# ==============================================================================
# Helper: Update Lockfile
# ==============================================================================
function(_update_lockfile EXT_NAME)
    get_property(_source_dir GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_SOURCE_DIR)
    get_property(_json GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_JSON)
    
    # Get current commit hash
    execute_process(
        COMMAND git rev-parse HEAD
        WORKING_DIRECTORY "${_source_dir}"
        OUTPUT_VARIABLE _commit_hash
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
    
    # Get timestamp
    string(TIMESTAMP _timestamp "%Y-%m-%dT%H:%M:%SZ" UTC)
    
    # Read existing lockfile or create new
    if(EXISTS "${EXTERNALS_LOCKFILE}")
        file(READ "${EXTERNALS_LOCKFILE}" _lockfile_content)
    else()
        set(_lockfile_content "{}")
    endif()
    
    # Update entry (simplified - real implementation would use proper JSON manipulation)
    # For now, just log
    dbg(${DBG_RARE} "[${EXT_NAME}] Lockfile: ${_commit_hash} @ ${_timestamp}" ID EXTERNALS)
    
endfunction()
```

### 3.2 Neue Error/Warning Codes

| Code | Typ | Beschreibung |
|------|-----|--------------|
| E218 | Error | External nicht gecached und Offline-Modus aktiv |
| W302 | Warning | Version-Mismatch aber Offline-Modus - nutze Cache |

### 3.3 Handler.cmake Anpassung

```cmake
# In Handler.cmake - SOURCE_DIR kommt jetzt aus .externals/
function(_handle_fetched_external EXT_NAME EXT_JSON)
    # ...
    
    # Source directory is now in .externals/
    get_property(_source_dir GLOBAL PROPERTY EXTERNAL_${EXT_NAME}_SOURCE_DIR)
    # _source_dir = "${CMAKE_SOURCE_DIR}/.externals/${EXT_NAME}"
    
    # ...
endfunction()
```

---

## 4. Verwendung

### 4.1 Normaler Workflow

```bash
# Erstes Configure - lädt Externals
$ cmake --preset msvc-debug
[glfw] Fetching from https://github.com/glfw/glfw.git...
[glfw] Fetched successfully
[imgui] Fetching from https://github.com/ocornut/imgui.git...
[imgui] Fetched successfully

# Zweites Configure - nutzt Cache
$ cmake --preset msvc-debug
[glfw] Using cached version
[imgui] Using cached version

# Anderes Preset - nutzt denselben Cache!
$ cmake --preset clang-release
[glfw] Using cached version
[imgui] Using cached version
```

### 4.2 Offline-Modus

```bash
# Offline arbeiten (z.B. im Zug)
$ cmake --preset msvc-debug -DEXTERNALS_OFFLINE=ON
[glfw] Using cached version
[imgui] Using cached version

# Offline ohne Cache → Fehler
$ cmake --preset msvc-debug -DEXTERNALS_OFFLINE=ON
[ERROR] [E218] External 'newlib': Not cached and offline mode enabled
```

### 4.3 Force Update

```bash
# Alle Externals neu laden (z.B. nach Tag-Update in Solution.json)
$ cmake --preset msvc-debug -DEXTERNALS_FORCE_FETCH=ON
[glfw] Force fetch requested
[glfw] Fetching from https://github.com/glfw/glfw.git...
[glfw] Fetched successfully
```

### 4.4 Clean

```bash
# Nur gefetchte Externals löschen
$ rm -rf .externals/

# Nächstes Configure lädt neu
$ cmake --preset msvc-debug
[glfw] Not cached, will fetch
[glfw] Fetching...
```

---

## 5. Solution.json (unverändert)

Die Solution.json bleibt unverändert - die `.externals/` Convention ist implizit:

```json
{
    "externals": {
        "bass": { "path": "externals/bass" },
        "glad": { "path": "externals/glad" },
        "glfw": { 
            "git": "https://github.com/glfw/glfw.git",
            "tag": "3.4"
        },
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.90.1",
            "cmakeSupport": false
        }
    }
}
```

**Convention:**
- `path` → Relativ zu Projekt-Root (typisch `externals/`)
- `git` → Automatisch in `.externals/${name}/`

---

## 6. Optional: externalsPolicy Erweiterung

Falls explizite Kontrolle gewünscht:

```json
{
    "externalsPolicy": {
        "fetchRoot": ".externals",
        "updatePolicy": "checkout",
        "lockfile": true
    }
}
```

| Feld | Default | Beschreibung |
|------|---------|--------------|
| `fetchRoot` | `.externals` | Verzeichnis für gefetchte Externals |
| `updatePolicy` | `checkout` | Fetch-Verhalten (siehe unten) |
| `lockfile` | `true` | Versions-Tracking aktivieren |

| updatePolicy | Verhalten |
|--------------|-----------|
| `checkout` | Fetch nur wenn nicht vorhanden (DEFAULT) |
| `always` | Immer neu fetchen |
| `never` | Nie fetchen, nur existierende nutzen |
| `update` | Fetch + git pull bei jedem Configure |

---

## 7. Vorteile der Lösung

| Aspekt | Vorher (v0.1.0) | Nachher (v0.2.0) |
|--------|-----------------|------------------|
| **Download** | Bei jedem Configure | Nur einmal |
| **Preset-Wechsel** | Neuer Download | Sofort (Cache) |
| **Offline** | Fehler | Funktioniert |
| **Speicher** | N × Kopien | 1 × Kopie |
| **Trennung** | Unklar | Klar (externals/ vs .externals/) |
| **Git-Status** | Manuell ignorieren | Automatisch versteckt |

---

## 8. Implementierungs-Plan

| Schritt | Datei | Änderung |
|---------|-------|----------|
| 1 | `Fetch.cmake` | v0.2.0 mit Caching-Logik |
| 2 | `Handler.cmake` | SOURCE_DIR Anpassung |
| 3 | `Errors.cmake` | E218, W302 hinzufügen |
| 4 | `.gitignore` | `/.externals/` hinzufügen |
| 5 | Dokumentation | Aktualisieren |

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.2.0** | **2025-12-09** | **Zentrales .externals/ Caching, Skip-if-exists, Offline-Modus, Force-Fetch** |
| 0.1.0 | 2025-12-09 | Initial: FetchContent Wrapper |
