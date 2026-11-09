# ModuleDoc — Standard for CMake Module Documentation

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Blueprint  
> **Status:** In Development  
> **Based on:** Doc v0.5, Blueprint v0.5  
> **Target Audience:** Documentation Authors, Build System Developers  
> **Language:** English  
> **German:** [ModuleDoc.md](../../../de/autorenwerk/blueprints/ModuleDoc.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Scope](#2-scope)
3. [Header Extensions](#3-header-extensions)
4. [Mandatory Sections](#4-mandatory-sections)
5. [API Reference Format](#5-api-reference-format)
6. [Version Coupling](#6-version-coupling)
7. [Example: Complete ModuleDoc](#7-example-complete-moduledoc)
8. [Review Checklist](#8-review-checklist)
9. [See Also](#9-see-also)
10. [Changelog](#changelog)

---

## 1. Overview

This blueprint defines the **structure for CMake module documentation**. It extends the general Doc blueprint with module-specific requirements.

### Target Audience

- Build system developers
- People who want to understand or extend CMake modules

### What Is Documented?

| Element | Example |
|---------|----------|
| Core modules | `Errors.cmake`, `Context.cmake`, `Json.cmake` |
| Project modules | `Executables.cmake`, `Libraries.cmake` |
| Externals modules | `Orchestrator.cmake`, `Fetch.cmake` |
| Include files | `externals/*/Include.cmake` |

---

## 2. Scope

This blueprint applies to all documentation that:
- Describes a single CMake module (`.cmake` file)
- Lives in the folder `docs/[lang]/guide/module/`

**Not affected:**
- CMakeLists.txt (→ Reference)
- CMakePresets.json (→ Reference)
- Conceptual architecture documents (→ Concept)

---

## 3. Header Extensions

### 3.1 Additional Mandatory Fields

In addition to the fields from Doc.md:

| Field | Mandatory | Description |
|------|---------|--------------|
| `Module:` | ✓ | Relative path to the module |
| `Module Version:` | ✓ | Version of the documented module |

### 3.2 Complete Header

```markdown
# [ModuleName].cmake — Documentation

> **Version:** X.Y.Z (doc vN)  
> **Date:** YYYY-MM-DD  
> **Type:** ModuleDoc  
> **Status:** [In Development | Stable | Deprecated]  
> **Target Audience:** Build System Developers  
> **Module:** cmake/[path]/[ModuleName].cmake  
> **Module Version:** X.Y.Z  
> **Based on:** ModuleDoc v0.5  
> **Language:** English  
> **German:** [ModuleName.md](../../../../de/guide/module/[path]/ModuleName.md)
```

### 3.3 Module Link

The `Module:` field can also be formatted as a link:

```markdown
> **Module:** [cmake/core/Context.cmake](../../../../../cmake/core/Context.cmake)
```

### 3.4 Versioning Explained

The documentation version follows the scheme:

```
X.Y.Z (doc vN)
│ │ │      │
│ │ │      └── Documentation revision (documentation changes only)
│ │ └── PATCH of the module version
│ └── MINOR of the module version  
└── MAJOR of the module version
```

**Example:**
- Module `Context.cmake` is version 0.1.1
- The documentation was revised twice without a module change
- → Documentation version: `0.1.1 (doc v2)`

---

## 4. Mandatory Sections

ModuleDoc uses this structure:

```
## Table of Contents

## 1. Overview
## 2. Dependencies
## 3. Concept / Design
## 4. API Reference
## 5. Usage Examples
## 6. Error Handling / Error Codes
## 7. Best Practices
## 8. Known Limitations (optional)
## 9. Migration (if breaking changes)
## 10. See Also
## Changelog
```

### 4.1 Section Details

| # | Section | Content |
|---|-----------|--------|
| 1 | Overview | Short description, purpose, what the module solves |
| 2 | Dependencies | `include()` dependencies, CMake version |
| 3 | Concept | Design decisions, architecture |
| 4 | API Reference | All functions/macros with parameters |
| 5 | Examples | Concrete use cases |
| 6 | Error Codes | All errors the module can raise |
| 7 | Best Practices | Recommendations, dos and don'ts |
| 8 | Limitations | Known limitations (optional) |
| 9 | Migration | On breaking changes (optional) |
| 10 | See Also | Related modules/documents |

---

## 5. API Reference Format

### 5.1 Function Documentation

Every function/macro is documented like this:

````markdown
### 4.1 function_name()

```cmake
function_name(PARAM1 PARAM2 [OPTIONAL_PARAM])
```

**Description:**  
What the function does.

**Parameters:**

| Parameter | Mandatory | Description |
|-----------|---------|--------------|
| `PARAM1` | ✓ | Description |
| `PARAM2` | ✓ | Description |
| `OPTIONAL_PARAM` | — | Description (default: `...`) |

**Returns:**  
What is returned (variable, PARENT_SCOPE, etc.)

**Example:**

```cmake
function_name("value1" "value2")
```

**Errors:**  
- `E0xxx` if a condition is not met
````

### 5.2 Example: ctx_set()

````markdown
### 4.2 ctx_set()

```cmake
ctx_set(PREFIX KEY VALUE)
```

**Description:**  
Stores a value in the context under the given key.
Uses GLOBAL PROPERTY for reliable propagation.

**Parameters:**

| Parameter | Mandatory | Description |
|-----------|---------|--------------|
| `PREFIX` | ✓ | Context namespace (e.g. `EXE_MyApp`) |
| `KEY` | ✓ | Key (UPPER_SNAKE_CASE recommended) |
| `VALUE` | ✓ | Value (string or `;`-separated list) |

**Returns:**  
No direct return. The value is stored as a GLOBAL PROPERTY.

**Example:**

```cmake
ctx_set(EXE_MyApp NAME "MyApp")
ctx_set(EXE_MyApp VERSION "1.0.0")
ctx_set(EXE_MyApp EXTERNALS "bass;imgui;glfw")
```

**Errors:**  
None — empty values are allowed.
````

---

## 6. Version Coupling

### 6.1 When to Update the Documentation?

| Module change | Documentation action |
|----------------|----------------------|
| New function | Add documentation, doc vN+1 |
| Parameters changed | Update documentation, doc vN+1 |
| Bugfix (same API) | Check documentation, optionally doc vN+1 |
| Breaking change | Migration section, doc vN+1 |

### 6.2 File Names

Current documentation has **no version in the file name**:

```
cmake/core/Context.cmake          ← module (version in header: 0.1.1)
docs/de/guide/module/core/Context.md   ← documentation (version in header)
```

### 6.3 On a Module Version Bump

1. Do not create a copy of the old documentation — earlier versions are in the Git history
2. Update `Context.md` with the new version
3. Links remain unchanged

---

## 7. Example: Complete ModuleDoc

```markdown
# Context.cmake — Documentation

> **Version:** 1.0.0 (doc v2)  
> **Date:** 2025-12-13  
> **Type:** ModuleDoc  
> **Status:** Stable  
> **Target Audience:** Build System Developers  
> **Module:** [cmake/core/Context.cmake](../../../../../cmake/core/Context.cmake)  
> **Module Version:** 1.0.0  
> **Based on:** ModuleDoc v0.5  
> **Language:** English  
> **German:** [Context.md](../../../../de/guide/module/core/Context.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Concept](#3-concept)
4. [API Reference](#4-api-reference)
5. [Usage Examples](#5-usage-examples)
6. [Error Handling](#6-error-handling)
7. [Best Practices](#7-best-practices)
8. [See Also](#8-see-also)
9. [Changelog](#changelog)

---

## 1. Overview

The Context module implements a **context object pattern** for CMake.
It provides isolated namespaces for collecting data during
pipeline processing.

### Features

- Isolated namespaces per executable/library/test
- Reliable propagation across function levels
- Debug dump for diagnostics

---

## 2. Dependencies

| Dependency | Type | Description |
|--------------|-----|--------------|
| CMake 3.19+ | System | For `include_guard(GLOBAL)` |

**No** other modules as dependencies.

---

## 3. Concept

### 3.1 Why Context?

CMake variables have function scope. With nested calls,
values get lost. GLOBAL PROPERTY solves this problem.

### 3.2 Architecture

```
ctx_create(EXE_MyApp)
    │
    ├── ctx_set(EXE_MyApp, NAME, "MyApp")
    │       └── GLOBAL PROPERTY: EXE_MyApp_NAME = "MyApp"
    │
    └── ctx_get(EXE_MyApp, NAME, _var)
            └── _var = "MyApp"
````

---

## 4. API Reference

### 4.1 ctx_create()

[... as described in section 5.1 ...]

### 4.2 ctx_set()

[... as described in section 5.2 ...]

---

## 5. Usage Examples

### 5.1 Collecting Executable Data

```cmake
ctx_create(EXE_MyApp)
ctx_set(EXE_MyApp NAME "MyApp")
ctx_set(EXE_MyApp VERSION "1.0.0")
ctx_set(EXE_MyApp TYPE "GUI")
ctx_dump(EXE_MyApp)  # debug output
```

---

## 6. Error Handling

This module raises no errors of its own.

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| `ctx_create()` before the first `ctx_set()` | Set directly without create |
| UPPER_SNAKE_CASE for keys | lowercase keys |
| Unique prefixes (EXE_, LIB_, TEST_) | Generic prefixes |

---

## 8. See Also

- [Errors.cmake](Errors.md) — Error handling
- [ExecutableCollect.cmake](../project/ExecutableCollect.md) — Uses Context

---

## Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **0.1.1 (doc v2)** | **2025-12-13** | **Format updated to ModuleDoc v0.5** |
| 0.1.1 (doc v1) | 2025-12-05 | Initial for module v0.1.1 |
````

---

## 8. Review Checklist

In addition to the Doc.md checklist:

**Header:**
- [ ] `Module:` field present with correct path
- [ ] `Module Version:` field present
- [ ] Link to the module works

**Content:**
- [ ] All functions of the module documented
- [ ] All parameters of each function described
- [ ] Return values documented
- [ ] Errors/error codes listed
- [ ] At least one example per function

**Coupling:**
- [ ] File name corresponds to module version
- [ ] doc vN correct

---

## 9. See Also

- [Doc.md](Doc.md) — General documentation rules
- [CMake.md](CMake.md) — Standard for CMake scripts
- [Context.md](../../guide/module/core/Context.md) — Example documentation

---

## Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: location `docs/[lang]/guide/module/` (§ 2, § 6.2), jump and module paths per today's depth (§ 3.2, § 3.3, § 7), no archive copies anymore (§ 6.3), example references without versions in the file name (§ 7)** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.0 | 2025-12-13 | New: module link in the header, API reference format, version coupling, complete example |
| 0.1.0 | 2025-12-03 | Initial (part of Documentation_Blueprint) |
