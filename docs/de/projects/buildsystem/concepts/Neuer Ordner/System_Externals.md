# System Externals — Konzept

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Concept  
> **Status:** Entwurf  
> **Zielgruppe:** Build-System-Entwickler  
> **Bezug:** Phase 9, cmake/externals/System/  
> **Sprache:** Deutsch  
> **English:** [System_Externals.md](../../en/projects/buildsystem/concepts/System_Externals.md)

---

## Inhaltsverzeichnis

1. [Einleitung](#1-einleitung)
2. [Problemstellung](#2-problemstellung)
3. [Lösungsansatz](#3-lösungsansatz)
4. [Pfad-Auflösung](#4-pfad-auflösung)
5. [Architektur](#5-architektur)
6. [Beispiele](#6-beispiele)
7. [Migration](#7-migration)
8. [Offene Punkte](#8-offene-punkte)
9. [Siehe auch](#9-siehe-auch)


---

## 1. Einleitung

Das System Externals Konzept ermöglicht die **Integration von system-installierten Bibliotheken** wie Qt6, Boost oder OpenCV.

### Ziele

- Klare Semantik für System-Bibliotheken
- Automatische Pfad-Auflösung
- Backup-Pfade mit Warnung
- Keine Pseudo-Ordner im Repository nötig

### Abgrenzung

| External-Typ | Erkennungsfeld | Speicherort |
|--------------|----------------|-------------|
| **Local** | `path` | `externals/` im Projekt |
| **Fetched** | `git` | `.externals/` (gecached) |
| **System** | `system` | System-Installation |

---

## 2. Problemstellung

### Aktuelle Situation

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

## 3. Lösungsansatz

### Neues `system` Feld

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

### Feld-Definitionen

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

### Typ-Erkennung

```
if "system" == true  → System External
else if "git" exists → Fetched External  
else if "path" exists → Local External
else → Error E012
```

---

## 4. Pfad-Auflösung

### Suchreihenfolge

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

### Plattform-spezifische Standard-Pfade

**Qt6:**
```cmake
# Windows
C:/Qt/{VERSION}/msvc2022_64
D:/Qt/{VERSION}/msvc2022_64

# Linux
~/Qt/{VERSION}/gcc_64
/opt/Qt/{VERSION}/gcc_64
/usr/lib/qt6

# macOS
~/Qt/{VERSION}/macos
/opt/homebrew/opt/qt@6
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

### Backup-Verhalten

Wenn der `backup` Pfad verwendet wird:

```cmake
message(WARNING 
    "[${name}] Primary installation not found!\n"
    "  Using backup location: ${backup_path}\n"
    "  Consider setting ${NAME}_ROOT environment variable."
)
```

---

## 5. Architektur

### Neue Dateien

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

### Orchestrator.cmake Erweiterung

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
        message(FATAL_ERROR "[E012] External '${EXT_NAME}': Invalid definition")
    endif()
endfunction()
```

### System/Handler.cmake

```cmake
function(_handle_system_external EXT_NAME EXT_JSON)
    message(STATUS "[${EXT_NAME}] Processing system external")
    
    # JSON parsen
    string(JSON _package GET "${EXT_JSON}" "package")
    string(JSON _version ERROR_VARIABLE _err GET "${EXT_JSON}" "version")
    string(JSON _components ERROR_VARIABLE _err GET "${EXT_JSON}" "components")
    
    # Pfad auflösen
    _resolve_system_path("${EXT_NAME}" "${_package}" ...)
    
    # find_package aufrufen
    if(_components)
        find_package(${_package} ${_version} REQUIRED COMPONENTS ${_components})
    else()
        find_package(${_package} ${_version} REQUIRED)
    endif()
    
    message(STATUS "[${EXT_NAME}] Found ${_package} ${${_package}_VERSION}")
endfunction()
```

---

## 6. Beispiele

### Qt6 (vollständig)

```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "version": ">=6.5.0",
    "components": ["Core", "Widgets", "Gui", "OpenGL"],
    "hints": [
        "${QT_ROOT}",
        "C:/Qt/6.7.0/msvc2022_64"
    ],
    "backup": "E:/Backup/Libs/Qt/6.7.0/msvc2022_64",
    "config": {
        "automoc": true,
        "autouic": true,
        "autorcc": true
    }
}
```

### Boost (minimal)

```json
"boost": {
    "system": true,
    "package": "Boost",
    "components": ["filesystem", "system", "thread"]
}
```

### OpenCV mit CUDA

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

### CUDA Toolkit

```json
"cuda": {
    "system": true,
    "package": "CUDAToolkit",
    "version": ">=11.0",
    "components": ["cudart", "cublas", "curand"]
}
```

---

## 7. Migration

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

## 8. Offene Punkte

### Zu klären

| Frage | Optionen | Tendenz |
|-------|----------|---------|
| Schema-Version | Erfordert Bump (0.2)? | Ja |
| Rückwärtskompatibilität | path + options weiter? | Deprecation Warning |
| Package-spezifische Configs | Wie strukturieren? | Separates `.cmake` |
| Validation | JSON Schema erweitern? | Ja |

### Nicht im Scope

- vcpkg/Conan Integration (separates Feature)
- Automatischer Download von System Externals
- Version-Locking für System Externals

---

## 9. Siehe auch

- [master_concept.md](master_concept.md) — Gesamtarchitektur
- [implementation_plan.md](implementation_plan.md) — Phasen-Plan
- [future_enhancements.md](future_enhancements.md) — vcpkg/Conan Integration
- [Externals.md](../../../reference/Externals.md) — External-Referenz

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Neues Header-Format, Dateiname ohne Version** |
| 0.1.0 | 2025-12-10 | Initial |