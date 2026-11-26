# Solution.json — Cheatsheet

> **Version:** 1.1.0  
> **Date:** 2026-11-26  
> **For:** CMake Architecture  
> **Language:** English  
> **German:** [Solution_Cheatsheet.md](../../../de/guide/cheatsheets/Solution_Cheatsheet.md)

---

## Quick Start

```json
{
    "schemaVersion": "1.0",
    "solution": { "name": "MyProject", "version": "1.0.0" },
    "externals": { "doctest": { "path": "externals/doctest" } },
    "libraries": [{ "name": "CoreLib" }],
    "executables": [{ "name": "MyApp", "dependencies": ["CoreLib"] }]
}
```

---

## Root Structure

| Block | Required | Description |
|-------|----------|-------------|
| `schemaVersion` | ✅ | `"1.0"` |
| `solution` | ✅ | Name, version, description |
| `settings` | — | C++ standard, defaults |
| `externals` | — | External dependencies |
| `libraries` | — | Internal libraries |
| `executables` | — | Monolithic executables |
| `tests` | — | Standalone tests |
| `apps` | — | App containers (Core/Runner) |
| `packages` | — | Build packages: target `package_<name>` |
| `documentation` | — | Target `docs` for the API reference (Doxygen) |

---

## Externals

### Local (in the repo)

```json
"bass": { "path": "externals/bass" }
```

### Fetched (Git)

```json
"glfw": { 
    "git": "https://github.com/glfw/glfw.git", 
    "tag": "3.4" 
}
```

### With Hook

```json
"imgui": { 
    "git": "...", 
    "tag": "v1.91.6",
    "hook": "imgui"
}
```

---

## Executables

| Field | Required | Default | Description |
|-------|----------|---------|-------------|
| `name` | ✅ | — | Target name |
| `type` | — | `CONSOLE` | `CONSOLE` / `GUI` |
| `path` | — | `projects/exec/{name}` | Source path |
| `dependencies` | — | `[]` | Internal libraries |
| `externals` | — | `[]` | External dependencies |
| `skip` | — | `false` | Skip |

```json
{
    "name": "MyApp",
    "type": "GUI",
    "dependencies": ["CoreLib"],
    "externals": ["glfw", "glad"]
}
```

---

## Libraries

| Field | Required | Default | Description |
|-------|----------|---------|-------------|
| `name` | ✅ | — | Target name |
| `type` | — | `STATIC` | `STATIC` / `SHARED` / `INTERFACE` |
| `path` | — | `projects/libs/{name}` | Source path |

```json
{ "name": "CoreLib", "type": "STATIC" }
```

---

## Apps (Core/Runner)

```json
{
    "name": "MyVisualizer",
    "core": {
        "dependencies": ["CoreLib"],
        "externals": ["bass"]
    },
    "runner": {
        "type": "GUI",
        "externals": ["glfw", "glad"]
    },
    "pch": { "enabled": true },
    "tests": {
        "framework": "doctest",
        "targets": [
            { "name": "UnitTests", "type": "unit" }
        ]
    }
}
```

### Generated Targets

| Target | Type |
|--------|------|
| `{App}.Core` | STATIC library |
| `{App}` | Executable |
| `{App}.{TestName}` | Test executable |

---

## Tests

### Standalone (tests[])

```json
{
    "name": "CoreLib_Tests",
    "type": "unit",
    "framework": "doctest",
    "dependencies": ["CoreLib"],
    "timeout": 30,
    "labels": ["unit", "fast"]
}
```

### App Tests (apps[].tests.targets[])

```json
{
    "name": "UnitTests",
    "type": "unit",
    "skip": false,
    "timeout": 30,
    "parallel": true
}
```

### Test Type Defaults

| Type | Timeout | Parallel |
|------|---------|----------|
| `unit` | 30s | ✅ |
| `integration` | 120s | ✅ |
| `performance` | 300s | ❌ |
| `system` | 180s | ❌ |
| `smoke` | 10s | ✅ |

---

## Skip Feature

| Level | JSON | Effect |
|-------|------|--------|
| App | `"skip": true` | Entire app |
| All tests | `"tests": { "skip": true }` | All app tests |
| One test | `"targets": [{ "skip": true }]` | Single test |

📌 **Global skip takes precedence!**

---

## PCH (Precompiled Header)

```json
"pch": {
    "enabled": true,
    "header": "pch.h"
}
```

File location: `{app}/pch/pch.h`

---

## Documentation (Doxygen)

```json
"documentation": { "doxygen": { "doxyfile": "Doxyfile" } }
```

| Field | Default | Effect |
|-------|---------|--------|
| `doxyfile` | — (required) | The project's Doxyfile, relative to the root, passed unchanged |
| `target` | `docs` | Name of the build target |

- 🔧 `cmake --build <build> --target docs` — not part of `ALL`
- 📂 Doxygen runs in the project root; relative paths in the Doxyfile apply as with `doxygen Doxyfile`
- ⚠️ `WARN_AS_ERROR = YES` belongs in the Doxyfile — the target then fails on a warning
- Doxygen missing → W202, the target fails when built · Doxyfile missing → E107

---

## Directory Structure

```
projects/
├── apps/{AppName}/
│   ├── include/     → Core PUBLIC headers
│   ├── src/         → Core implementation
│   ├── main/        → Runner (main.cpp)
│   ├── pch/         → pch.h
│   └── tests/{type}/{TestName}/
├── exec/{ExeName}/
│   └── src/
├── libs/{LibName}/
│   ├── include/
│   └── src/
└── tests/{TestName}/
```

---

## Error Codes

| Code | Area | Meaning |
|------|------|---------|
| E0xx | JSON | Parsing errors |
| E1xx | Target | Creation errors |
| E2xx | External | External errors |
| E3xx | Test | Test errors |
| E4xx | App | App container errors |
| E5xx | System | System externals |
| W2xx | Tools | Missing tools (W202: Doxygen) |

---

## CMake Variables

| Variable | Default | Effect |
|----------|---------|--------|
| `BUILD_TESTS` | ON | Enable tests |
| `BUILD_ONLY` | `""` | Only specific targets |
| `EXTERNALS_OFFLINE` | OFF | No network |
| `EXTERNALS_FORCE_FETCH` | OFF | Ignore cache |

---

## Tips

- 💡 Define `externals` centrally → never inline in executables
- 💡 Use `apps[]` for testable applications
- 💡 `skip: true` for temporarily disabled tests
- 📌 Always specify the schema version!

---

## See Also

- [Solution_Schema.md](../references/Solution_Schema.md) — Complete reference
- [AppContainer_Concept.md](../../konzepte/abgeschlossen/AppContainer_Concept.md) — App concept
- [ErrorCodes.md](../references/ErrorCodes.md) — All error codes
