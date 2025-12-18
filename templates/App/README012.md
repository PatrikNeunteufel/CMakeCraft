# App Template

> **Version:** 0.1.2  
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
    │   └── Application_Tests.cpp
    ├── integration/               # Integration tests
    │   └── Application_Integration_Tests.cpp
    └── performance/               # Performance tests
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

```json
"apps": [
    {
        "name": "YourAppName",
        "displayName": "Your Application",
        "version": "0.1.0",
        
        "core": {
            "dependencies": [],
            "externals": ["qt6", "bass"]
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

## PCH (Precompiled Header)

`pch/pch.h` contains frequently used, stable includes to reduce build times.

### Enabling PCH

Add to Solution.json:

```json
"pch": {
    "enabled": true
}
```

### Disabling PCH

If you **disable PCH** or don't use it, you **must remove** the `#include "pch.h"` line from all `.cpp` files:

- `src/Application.cpp`
- `main/main.cpp`
- All test files

Otherwise compilation will fail with "file not found" error.

### Why manual include?

The `#include "pch.h"` is required for **MSVC compatibility**. While GCC/Clang can inject PCH automatically via `-include` flag, MSVC requires explicit include as the first line in each source file.

### Good candidates for PCH

- Standard Library headers
- Framework headers (Qt, etc.)
- Stable external library headers

### Do NOT include in PCH

- Project-specific headers (change frequently)
- Headers under active development

### File Extension

The `.h` extension is standard for PCH, even for C++. Some compilers/tools don't process `.hpp` correctly as PCH.

## Test Types

### Unit Tests (`tests/unit/`)

- Fast, isolated tests
- No external dependencies
- Run on every build

### Integration Tests (`tests/integration/`)

- Test component interactions
- May use external resources
- Longer timeouts allowed

### Performance Tests (`tests/performance/`)

- Measure execution time
- Compare against thresholds
- Run nightly (optional in CI)

## Build Defines

The build system automatically sets:

| Define | Condition |
|--------|-----------|
| `APP_GUI` | `runner.type = "GUI"` |
| `APP_CONSOLE` | `runner.type = "CONSOLE"` |

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
| **0.1.2** | **2025-12-18** | **Added PCH include to main.cpp, documented PCH enable/disable behavior** |
| 0.1.1 | 2025-12-18 | Added integration/performance test templates, synchronized EN/DE versions |
| 0.1.0 | 2025-12-17 | Initial template with correct structure |
