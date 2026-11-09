# externals/system — System Externals Handler

> **Version:** 1.0.0  
> **Date:** 2025-12-20  
> **Type:** README  
> **Status:** Active  
> **Language:** English  
> **German:** [README.md](../../../../../de/guide/module/externals/system/README.md)  
> **Phase:** 9 (System Externals)

---

## Overview

The `externals/system/` directory contains modules for processing **system externals** — large, externally installed packages such as Qt6 or Boost that are found via `find_package()`.

---

## Directory Structure

```
cmake/externals/system/
├── Handler.cmake          # Main handler for system: true
├── PathResolver.cmake     # Multi-stage path resolution
└── packages/              # Package-specific hooks
    ├── Qt6.cmake          # Qt6: AUTOMOC, windeployqt
    └── Boost.cmake        # Boost: MSVC auto-link fix
```

---

## Modules

| Module | Description | Documentation |
|--------|-------------|---------------|
| **Handler.cmake** | find_package integration, hook system | [Handler_cmake.md](Handler_cmake.md) |
| **PathResolver.cmake** | ENV variables, hints, backup | [PathResolver_cmake.md](PathResolver_cmake.md) |
| **packages/Qt6.cmake** | Qt6-specific configuration | [packages/Qt6_cmake.md](packages/Qt6_cmake.md) |
| **packages/Boost.cmake** | Boost-specific configuration | [packages/Boost_cmake.md](packages/Boost_cmake.md) |

---

## How It Works

### 1. Detection

A system external is detected by `"system": true` in the JSON definition:

```json
"qt6": {
    "system": true,
    "package": "Qt6",
    "components": ["Core", "Widgets"]
}
```

### 2. Processing

```
Orchestrator.cmake
       │
       ├── system: true detected
       ▼
Handler.cmake
       │
       ├── Load package hook (if present)
       ├── Call PathResolver
       ├── Run find_package()
       └── Register as SYSTEM external
```

### 3. Application

```
*Create.cmake (Executable/Library/App)
       │
       ├── apply_external_to_target()
       ▼
Handler._apply_system_external_to_target()
       │
       ├── Link Package::Component targets
       └── Call the _Package_configure_target() hook
```

---

## Creating Your Own Package Hooks

### Adding a New Hook

```cmake
# cmake/externals/system/packages/MyPackage.cmake

include_guard(GLOBAL)

# Optional: standard paths
function(_get_MyPackage_standard_paths OUT_VAR)
    set(_paths
        "C:/MyPackage/1.0"
        "/opt/mypackage"
    )
    set(${OUT_VAR} "${_paths}" PARENT_SCOPE)
endfunction()

# Optional: after find_package
function(_MyPackage_post_find)
    # Post-processing
endfunction()

# Optional: target configuration
function(_MyPackage_configure_target TARGET_NAME)
    # Target-specific settings
endfunction()
```

### Using It in Solution.json

```json
"mypackage": {
    "system": true,
    "package": "MyPackage"
}
```

---

## Error Codes

| Code | Description |
|------|-------------|
| E502 | `package` field missing |
| E503 | `find_package()` failed |
| E504 | Package found, but not all components |
| E505 | No version matching `version` |
| W501 | Backup path used |

---

## See Also

- [Orchestrator_cmake.md](../Orchestrator_cmake.md) — Dispatches here
- [Solution_Schema.md](../../../references/Solution_Schema.md) — JSON schema (§5.4)
- [System_Externals_Concept.md](../../../../konzepte/abgeschlossen/System_Externals_Concept.md) — Concept document
