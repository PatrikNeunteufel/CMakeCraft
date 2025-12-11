# System Externals – Konzept

> **Version:** 0.1.0  
> **Datum:** 2025-12-10  
> **Typ:** Konzept-Doku  
> **Status:** Entwurf  
> **Ziel-Release:** Phase 7 oder Post-Release

---

## 1. Problemstellung

### Aktuelle Situation

Das Build-System unterstützt zwei External-Typen:

| Typ | Erkennungsmerkmal | Speicherort |
|-----|-------------------|-------------|
| **Local** | `path` Feld | `externals/` im Projekt |
| **Fetched** | `git` Feld | `.externals/` (gecached) |

### Problem

Große Bibliotheken wie **Qt6**, **Boost**, **OpenCV**, **CUDA** sind:
- Zu groß für `externals/` (Qt6 > 5 GB)
- Oft bereits installiert (System, Installer)
- Auf verschiedenen Pfaden je nach Installationsart
- Manchmal auf externen Laufwerken (Backup, USB)

### Aktueller Workaround

```json
"qt6": {
    "path": "externals/qt6",      // ← Pseudo-Pfad
    "options": {
        "hint": "${QT_ROOT}"      // ← Eigentlicher Pfad
    }
}
```

**Nachteile:**
- Semantisch unklar (`path` zeigt nicht auf echte Dateien)
- `externals/qt6/` Ordner muss existieren (nur für Include.cmake)
- Keine standardisierte Pfad-Suche

---

## 2. Lösung: System External Type

### 2.1 Neues `system` Feld

```json
"externals": {
    "qt6": {
        "system": true,
        "package": "Qt6",
        "version": ">=6.5.0",
        "components": ["Core", "Widgets", "Gui"],
        "hints": [
            "${QT_ROOT}",
            "C:/Qt/6.7.0/msvc2022_64"
        ],
        "backup": "E:/Backup/Libs/Qt/6.7.0/msvc2022_64"
    }
}
```

### 2.2 Feld-Definitionen

| Feld | Typ | Pflicht | Beschreibung |
|------|-----|---------|--------------|
| `system` | `bool` | ✅ | Kennzeichnet System External |
| `package` | `string` | ✅ | find_package Name |
| `version` | `string` | ❌ | Version Constraint |
| `components` | `string[]` | ❌ | Package-Komponenten |
| `hints` | `string[]` | ❌ | Suchpfade (Priorität) |
| `backup` | `string` | ❌ | Backup-Pfad (Warnung) |
| `required` | `bool` | ❌ | Default: true |
| `config` | `object` | ❌ | Package-spezifische Config |

### 2.3 Typ-Erkennung

```
if "system" == true  → System External
else if "git" exists → Fetched External  
else if "path" exists → Local External
else → Error
```

---

## 3. Pfad-Auflösung

### 3.1 Suchreihenfolge

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Umgebungsvariablen                                        │
│    └─ ${PACKAGE}_ROOT, ${PACKAGE}_DIR, ${PACKAGE}_HOME      │
├─────────────────────────────────────────────────────────────┤
│ 2. CMAKE_PREFIX_PATH                                         │
├─────────────────────────────────────────────────────────────┤
│ 3. hints[] aus Solution.json (in Reihenfolge)               │
├─────────────────────────────────────────────────────────────┤
│ 4. Standard-Pfade (plattformspezifisch)                     │
├─────────────────────────────────────────────────────────────┤
│ 5. backup Pfad                                               │
│    └─ ⚠️ WARNING: "Using backup location"                   │
├─────────────────────────────────────────────────────────────┤
│ 6. Fehler wenn nichts gefunden                              │
│    └─ ❌ FATAL_ERROR mit Hilfetext                          │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Plattform-spezifische Standard-Pfade

**Qt6:**
```cmake
# Windows
C:/Qt/{VERSION}/msvc2022_64
D:/Qt/{VERSION}/msvc2022_64

# Linux
~/Qt/{VERSION}/gcc_64
/opt/Qt/{VERSION}/gcc_64
/usr/lib/qt6
/usr/lib/x86_64-linux-gnu/qt6

# macOS
~/Qt/{VERSION}/macos
/opt/homebrew/opt/qt@6
/usr/local/opt/qt@6
```

**Boost:**
```cmake
# Windows
C:/local/boost_{VERSION}
C:/Boost

# Linux
/usr/include/boost
/usr/local/include/boost

# macOS
/opt/homebrew/include/boost
```

### 3.3 Backup-Verhalten

Wenn der `backup` Pfad verwendet wird:

```cmake
message(WARNING 
    "[${name}] Primary installation not found!\n"
    "  Using backup location: ${backup_path}\n"
    "  Consider setting ${NAME}_ROOT environment variable."
)
```

---

## 4. Implementierung

### 4.1 Neue Dateien

```
cmake/externals/
├── System/
│   ├── Handler.cmake       # System External Handler
│   ├── PathResolver.cmake  # Pfad-Auflösung
│   └── Packages/
│       ├── Qt6.cmake       # Qt6-spezifische Logik
│       ├── Boost.cmake     # Boost-spezifische Logik
│       └── OpenCV.cmake    # OpenCV-spezifische Logik
└── Orchestrator.cmake      # Erweitert um system Type
```

### 4.2 Orchestrator.cmake Erweiterung

```cmake
function(_process_external EXT_NAME EXT_JSON)
    # Typ-Erkennung
    string(JSON _system ERROR_VARIABLE _err GET "${EXT_JSON}" "system")
    string(JSON _git ERROR_VARIABLE _err2 GET "${EXT_JSON}" "git")
    string(JSON _path ERROR_VARIABLE _err3 GET "${EXT_JSON}" "path")
    
    if(_system)
        # System External
        include(cmake/externals/System/Handler.cmake)
        _handle_system_external("${EXT_NAME}" "${EXT_JSON}")
    elseif(NOT _err2)
        # Fetched External
        _handle_fetched_external("${EXT_NAME}" "${EXT_JSON}")
    elseif(NOT _err3)
        # Local External
        _handle_local_external("${EXT_NAME}" "${EXT_JSON}")
    else()
        message(FATAL_ERROR "[E010] External '${EXT_NAME}': Invalid definition")
    endif()
endfunction()
```

### 4.3 System/Handler.cmake

```cmake
# ==============================================================================
# System/Handler.cmake – System External Handler
# ==============================================================================

include_guard(GLOBAL)
include(cmake/externals/System/PathResolver.cmake)

function(_handle_system_external EXT_NAME EXT_JSON)
    message(STATUS "[${EXT_NAME}] Processing system external")
    
    # JSON parsen
    string(JSON _package GET "${EXT_JSON}" "package")
    string(JSON _version ERROR_VARIABLE _err GET "${EXT_JSON}" "version")
    string(JSON _components ERROR_VARIABLE _err GET "${EXT_JSON}" "components")
    string(JSON _hints ERROR_VARIABLE _err GET "${EXT_JSON}" "hints")
    string(JSON _backup ERROR_VARIABLE _err GET "${EXT_JSON}" "backup")
    
    # Pfad auflösen
    _resolve_system_path("${EXT_NAME}" "${_package}" "${_hints}" "${_backup}" _resolved_path _is_backup)
    
    if(_is_backup)
        message(WARNING 
            "[${EXT_NAME}] Using backup location: ${_resolved_path}\n"
            "  Consider setting ${_package}_ROOT or installing properly."
        )
    endif()
    
    # CMAKE_PREFIX_PATH erweitern
    list(PREPEND CMAKE_PREFIX_PATH "${_resolved_path}")
    set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}" PARENT_SCOPE)
    
    # find_package aufrufen
    if(_components)
        find_package(${_package} ${_version} REQUIRED COMPONENTS ${_components})
    else()
        find_package(${_package} ${_version} REQUIRED)
    endif()
    
    # Package-spezifische Konfiguration
    set(_package_config "${CMAKE_CURRENT_LIST_DIR}/Packages/${_package}.cmake")
    if(EXISTS "${_package_config}")
        include("${_package_config}")
    endif()
    
    message(STATUS "[${EXT_NAME}] Found ${_package} ${${_package}_VERSION}")
endfunction()
```

### 4.4 System/PathResolver.cmake

```cmake
# ==============================================================================
# System/PathResolver.cmake – Path Resolution for System Externals
# ==============================================================================

include_guard(GLOBAL)

# Standard-Pfade je Package
set(_SYSTEM_PATHS_Qt6_WINDOWS
    "C:/Qt/6.8.0/msvc2022_64"
    "C:/Qt/6.7.0/msvc2022_64"
    "C:/Qt/6.6.0/msvc2022_64"
    "D:/Qt/6.7.0/msvc2022_64"
)

set(_SYSTEM_PATHS_Qt6_LINUX
    "$ENV{HOME}/Qt/6.8.0/gcc_64"
    "$ENV{HOME}/Qt/6.7.0/gcc_64"
    "/opt/Qt/6.7.0/gcc_64"
    "/usr/lib/qt6"
)

set(_SYSTEM_PATHS_Qt6_APPLE
    "$ENV{HOME}/Qt/6.8.0/macos"
    "$ENV{HOME}/Qt/6.7.0/macos"
    "/opt/homebrew/opt/qt@6"
)

function(_resolve_system_path EXT_NAME PACKAGE HINTS BACKUP OUT_PATH OUT_IS_BACKUP)
    set(_found FALSE)
    set(_result_path "")
    set(_is_backup FALSE)
    
    # 1. Umgebungsvariablen
    foreach(_var ${PACKAGE}_ROOT ${PACKAGE}_DIR ${PACKAGE}_HOME)
        if(DEFINED ENV{${_var}})
            set(_candidate "$ENV{${_var}}")
            if(_is_valid_package_path("${_candidate}" "${PACKAGE}"))
                set(_found TRUE)
                set(_result_path "${_candidate}")
                message(STATUS "[${EXT_NAME}]   Found via ${_var}: ${_candidate}")
                break()
            endif()
        endif()
    endforeach()
    
    # 2. hints aus Solution.json
    if(NOT _found AND HINTS)
        string(JSON _hints_count LENGTH "${HINTS}")
        if(_hints_count GREATER 0)
            math(EXPR _last "${_hints_count} - 1")
            foreach(_idx RANGE 0 ${_last})
                string(JSON _hint GET "${HINTS}" ${_idx})
                # Umgebungsvariablen expandieren
                string(CONFIGURE "${_hint}" _hint_expanded)
                if(_is_valid_package_path("${_hint_expanded}" "${PACKAGE}"))
                    set(_found TRUE)
                    set(_result_path "${_hint_expanded}")
                    message(STATUS "[${EXT_NAME}]   Found via hint: ${_hint_expanded}")
                    break()
                endif()
            endforeach()
        endif()
    endif()
    
    # 3. Standard-Pfade
    if(NOT _found)
        if(WIN32)
            set(_std_paths ${_SYSTEM_PATHS_${PACKAGE}_WINDOWS})
        elseif(APPLE)
            set(_std_paths ${_SYSTEM_PATHS_${PACKAGE}_APPLE})
        else()
            set(_std_paths ${_SYSTEM_PATHS_${PACKAGE}_LINUX})
        endif()
        
        foreach(_path IN LISTS _std_paths)
            if(_is_valid_package_path("${_path}" "${PACKAGE}"))
                set(_found TRUE)
                set(_result_path "${_path}")
                message(STATUS "[${EXT_NAME}]   Found at standard path: ${_path}")
                break()
            endif()
        endforeach()
    endif()
    
    # 4. Backup
    if(NOT _found AND BACKUP)
        string(CONFIGURE "${BACKUP}" _backup_expanded)
        if(_is_valid_package_path("${_backup_expanded}" "${PACKAGE}"))
            set(_found TRUE)
            set(_result_path "${_backup_expanded}")
            set(_is_backup TRUE)
        endif()
    endif()
    
    # Ergebnis
    if(_found)
        set(${OUT_PATH} "${_result_path}" PARENT_SCOPE)
        set(${OUT_IS_BACKUP} ${_is_backup} PARENT_SCOPE)
    else()
        message(FATAL_ERROR
            "[${EXT_NAME}] ${PACKAGE} not found!\n"
            "  \n"
            "  Set one of these environment variables:\n"
            "    ${PACKAGE}_ROOT\n"
            "    ${PACKAGE}_DIR\n"
            "  \n"
            "  Or add 'hints' in Solution.json:\n"
            "    \"hints\": [\"C:/Path/To/${PACKAGE}\"]\n"
        )
    endif()
endfunction()

function(_is_valid_package_path PATH PACKAGE)
    if(NOT EXISTS "${PATH}")
        return(FALSE)
    endif()
    
    # Package-spezifische Validierung
    if(PACKAGE STREQUAL "Qt6")
        if(EXISTS "${PATH}/lib/cmake/Qt6" OR EXISTS "${PATH}/lib/cmake/Qt6Core")
            return(TRUE)
        endif()
    elseif(PACKAGE STREQUAL "Boost")
        if(EXISTS "${PATH}/include/boost" OR EXISTS "${PATH}/boost")
            return(TRUE)
        endif()
    else()
        # Generic: lib/cmake/${PACKAGE} oder include/${PACKAGE}
        if(EXISTS "${PATH}/lib/cmake/${PACKAGE}" OR EXISTS "${PATH}/include")
            return(TRUE)
        endif()
    endif()
    
    return(FALSE)
endfunction()
```

---

## 5. Beispiele

### 5.1 Qt6 (vollständig)

```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "version": ">=6.5.0",
    "components": ["Core", "Widgets", "Gui", "OpenGL"],
    "hints": [
        "${QT_ROOT}",
        "C:/Qt/6.7.0/msvc2022_64",
        "D:/Development/Qt/6.7.0"
    ],
    "backup": "E:/Backup/Libs/Qt/6.7.0/msvc2022_64",
    "config": {
        "automoc": true,
        "autouic": true,
        "autorcc": true
    }
}
```

### 5.2 Boost (minimal)

```json
"boost": {
    "system": true,
    "package": "Boost",
    "components": ["filesystem", "system", "thread"]
}
```

### 5.3 OpenCV mit CUDA

```json
"opencv": {
    "system": true,
    "package": "OpenCV",
    "version": ">=4.5.0",
    "hints": ["${OPENCV_DIR}"],
    "config": {
        "with_cuda": true
    }
}
```

### 5.4 CUDA Toolkit

```json
"cuda": {
    "system": true,
    "package": "CUDAToolkit",
    "version": ">=11.0",
    "components": ["cudart", "cublas", "curand"]
}
```

---

## 6. Migration

### Von Workaround zu system

**Vorher (aktuell):**
```json
"qt6": {
    "path": "externals/qt6",
    "options": {
        "hint": "${QT_ROOT}",
        "components": ["Core", "Widgets"]
    }
}
```

**Nachher (Ziel):**
```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "components": ["Core", "Widgets"],
    "hints": ["${QT_ROOT}"]
}
```

### Vorteile

| Aspekt | Workaround | system |
|--------|------------|--------|
| Semantik | Unklar | Klar |
| Ordner nötig | `externals/qt6/` | Nein |
| Include.cmake | Manuell | Optional/Standard |
| Backup-Support | Manuell | Integriert |
| Version-Check | Manuell | Integriert |
| Standard-Pfade | In Include.cmake | Zentral |

---

## 7. Offene Punkte

### Zu klären

1. **Schema-Version:** Erfordert schemaVersion Bump (0.2)?
2. **Rückwärtskompatibilität:** path + options weiter unterstützen?
3. **Package-spezifische Configs:** Wie strukturieren?
4. **Validation:** JSON Schema für system Externals?

### Nicht im Scope

- vcpkg/Conan Integration (separates Feature)
- Automatischer Download von System Externals
- Version-Locking für System Externals

---

## 8. Roadmap

| Phase | Beschreibung |
|-------|--------------|
| **Jetzt** | Workaround mit path + options + backup |
| **Phase 7** | system Feld implementieren |
| **Post-Release** | Package-spezifische Configs, vcpkg Integration |

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-10** | **Initial: Konzept für System Externals** |
