# Solution.json — Cheatsheet

> **Version:** 0.6.0  
> **Last Updated:** 2025-12-18  
> **For:** CMake Architecture V2  
> **Language:** English  
> **Deutsch:** [Solution_Cheatsheet.md](../../de/cheatsheets/Solution_Cheatsheet.md)

---

## Quick Start

```json
{
    "schemaVersion": "0.6",
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
| `schemaVersion` | ✅ | `"0.6"` |
| `solution` | ✅ | Name, Version, Description |
| `settings` | — | C++ Standard, Defaults |
| `externals` | — | External Dependencies |
| `libraries` | — | Internal Libraries |
| `executables` | — | Monolithic Executables |
| `tests` | — | Standalone Tests |
| `apps` | — | App-Container (Core/Runner) |

---

## Externals

### Local (in repo)

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
| `skip` | — | `false` | Skip building |

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
| `{App}.Core` | STATIC Library |
| `{App}` | Executable |
| `{App}.{TestName}` | Test Executable |

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

### App-Tests (apps[].tests.targets[])

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
| All Tests | `"tests": { "skip": true }` | All app tests |
| Single Test | `"targets": [{ "skip": true }]` | Individual test |

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

## Directory Structure

```
projects/
├── apps/{AppName}/
│   ├── include/     → Core PUBLIC Headers
│   ├── src/         → Core Implementation
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
| E4xx | App | App-Container errors |

---

## CMake Variables

| Variable | Default | Effect |
|----------|---------|--------|
| `BUILD_TESTS` | ON | Enable tests |
| `BUILD_ONLY` | `""` | Build specific targets only |
| `EXTERNALS_OFFLINE` | OFF | No network access |
| `EXTERNALS_FORCE_FETCH` | OFF | Ignore cache |

---

## Tips

- 💡 Define `externals` centrally → never inline in executables
- 💡 Use `apps[]` for testable applications
- 💡 `skip: true` for temporarily disabled tests
- 📌 Always specify schema version!

---

## See Also

- [Solution_Schema.md](../references/Solution_Schema.md) — Complete Reference
- [AppContainer_Concept.md](../projects/buildsystem/concepts/AppContainer_Concept.md) — App Concept
- [ErrorCodes.md](../references/ErrorCodes.md) — All Error Codes
