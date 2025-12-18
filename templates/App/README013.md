# App Template

> **Version:** 0.1.3  
> **Date:** 2025-12-18  
> **Type:** Template  
> **Status:** Active  
> **German:** [README_de.md](README_de.md)

---

CMake Architecture V2 - App-Container Template

## Overview

This template provides the standard structure for App-Containers in the CMake Architecture V2 build system. It separates the entry point (`main/`) from application logic (`include/`, `src/`) for maximum testability.

## Directory Structure

```
App/
├── README.md                      # This file (English)
├── README_de.md                   # German version
├── include/                       # Public headers
│   ├── Source.cmake
│   └── Application.hpp
├── src/                           # Implementation
│   ├── Source.cmake
│   └── Application.cpp
├── main/                          # Entry point (not testable)
│   ├── Source.cmake
│   └── main.cpp
├── pch/                           # Precompiled header
│   └── pch.h
└── tests/                         # Tests
    ├── unit/                      # Unit tests
    │   ├── Source.cmake
    │   ├── test_main.cpp          # doctest entry point
    │   └── Application_Tests.cpp
    ├── integration/               # Integration tests
    │   ├── Source.cmake
    │   ├── test_main.cpp          # doctest entry point
    │   └── Application_Integration_Tests.cpp
    └── performance/               # Performance tests
        ├── Source.cmake
        ├── test_main.cpp          # doctest entry point
        └── Application_Performance_Tests.cpp
```

## Architecture

| Directory | Responsibility | Testable |
|-----------|----------------|----------|
| `include/` + `src/` | All logic, UI, services | ✅ Yes |
| `main/` | Entry point only | ❌ No |
| `pch/` | Precompiled header | — |
| `tests/` | Test code | — |

## Usage

### 1. Copy Template

Copy this directory to your project:

```bash
cp -r projects/templates/App projects/apps/YourAppName
```

### 2. Configure Solution.json

#### Minimal Configuration (Unit Tests only)

```json
"apps": [
    {
        "name": "YourAppName",
        "displayName": "Your Application",
        "version": "0.1.0",
        
        "core": {
            "dependencies": [],
            "externals": []
        },

        "runner": {
            "type": "GUI",
            "externals": []
        },

        "pch": {
            "enabled": true
        },

        "tests": {
            "framework": "doctest",
            "unit": {
                "timeout": 30,
                "labels": ["unit", "app", "fast"]
            }
        }
    }
]
```

#### Full Configuration (All Test Types)

```json
"apps": [
    {
        "name": "YourAppName",
        "displayName": "Your Application",
        "version": "0.1.0",
        "description": "Application description",
        
        "core": {
            "dependencies": ["SomeLibrary"],
            "externals": ["bass", "qt6"]
        },

        "runner": {
            "type": "GUI",
            "externals": ["glad", "glfw"]
        },

        "pch": {
            "enabled": true,
            "header": "pch.h"
        },

        "tests": {
            "framework": "doctest",
            "unit": {
                "timeout": 30,
                "labels": ["unit", "app", "fast"]
            },
            "integration": {
                "timeout": 120,
                "labels": ["integration", "app", "slow"],
                "externals": ["bass"]
            },
            "performance": {
                "timeout": 300,
                "labels": ["performance", "app", "benchmark"]
            }
        },

        "platforms": ["windows", "linux", "macos"]
    }
]
```

### 3. Customize Application Class

Edit `src/Application.cpp`:
- Initialize your services in `init()`
- Implement your main loop in `run()`
- Clean up resources in `shutdown()`

### 4. Update Source.cmake Files

When adding new files, update the corresponding `Source.cmake`:

```cmake
set(_local_sources
    "${CMAKE_CURRENT_LIST_DIR}/Application.cpp"
    "${CMAKE_CURRENT_LIST_DIR}/YourNewFile.cpp"    # Add new files
)
```

### 5. main.cpp

The `main/main.cpp` should **not be modified**. It is generic and works for all app types (GUI/Console, all platforms).

## Test Types

### Unit Tests (`tests/unit/`)

- Fast, isolated tests
- No external dependencies
- Run on every build
- Timeout: typically 30 seconds

**Files:**
- `test_main.cpp` — doctest entry point (do not modify)
- `Application_Tests.cpp` — your test cases

### Integration Tests (`tests/integration/`)

- Test component interactions
- May use external resources (files, network, database)
- Longer timeouts allowed
- Can have additional externals

**Files:**
- `test_main.cpp` — doctest entry point (do not modify)
- `Application_Integration_Tests.cpp` — your test cases

**Solution.json:**
```json
"integration": {
    "timeout": 120,
    "labels": ["integration", "slow"],
    "externals": ["bass", "somedb"]
}
```

### Performance Tests (`tests/performance/`)

- Measure execution time and resource usage
- Compare against baseline/threshold values
- Run nightly (optional in regular CI)

**Files:**
- `test_main.cpp` — doctest entry point (do not modify)
- `Application_Performance_Tests.cpp` — your benchmarks

**Solution.json:**
```json
"performance": {
    "timeout": 300,
    "labels": ["performance", "benchmark", "nightly"]
}
```

## test_main.cpp

Each test directory contains a `test_main.cpp` that provides the doctest implementation:

```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest/doctest.h>
```

**Important:** Do not add this define to your test files! It must appear exactly **once** per test executable.

## PCH (Precompiled Header)

`pch/pch.h` contains frequently used, stable includes to reduce build times.

### PCH Scope

- **Core (`src/`)**: Uses PCH — add `#include "pch.h"` as first line
- **Runner (`main/`)**: Does NOT use PCH — no include needed
- **Tests**: Do NOT use PCH — no include needed

### Enabling/Disabling PCH

```json
"pch": {
    "enabled": true,    // or false to disable
    "header": "pch.h"   // optional, default is "pch.h"
}
```

If PCH is disabled, remove `#include "pch.h"` from all files in `src/`.

## Build Defines

The build system automatically sets:

| Define | Condition |
|--------|-----------|
| `APP_GUI` | `runner.type = "GUI"` (Windows only) |

## runner.type

| Type | Windows | Linux/macOS |
|------|---------|-------------|
| `GUI` | `WinMain` (no console window) | `main` |
| `CONSOLE` | `main` (with console) | `main` |

## See Also

- [Solution Schema](../../docs/de/references/Solution_Schema.md)
- [App Creation Guide](../../docs/de/userguides/App_Creation_Guide.md)
- [App Template Reference](../../docs/de/references/App_Template_Reference.md)
- [AppContainer Concept](../../docs/de/projects/buildsystem/concepts/AppContainer_Concept.md)

> English documentation is in progress.

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **0.1.3** | **2025-12-18** | **Added test_main.cpp for doctest, documented integration/performance test config** |
| 0.1.2 | 2025-12-18 | Added PCH include to main.cpp, documented PCH enable/disable behavior |
| 0.1.1 | 2025-12-18 | Added integration/performance test templates, synchronized EN/DE versions |
| 0.1.0 | 2025-12-17 | Initial template with correct structure |
