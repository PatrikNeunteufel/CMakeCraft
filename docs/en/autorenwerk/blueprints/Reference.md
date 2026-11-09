# Reference — Standard for API/Schema References

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Blueprint  
> **Status:** In Development  
> **Based on:** Doc v0.5, Blueprint v0.5  
> **Target Audience:** Documentation authors  
> **Language:** English  
> **German:** [Reference.md](../../../de/autorenwerk/blueprints/Reference.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Scope](#2-scope)
3. [Header Structure](#3-header-structure)
4. [Required Sections](#4-required-sections)
5. [Entry Format](#5-entry-format)
6. [Quick Reference Tables](#6-quick-reference-tables)
7. [Example: Complete Reference](#7-example-complete-reference)
8. [Review Checklist](#8-review-checklist)
9. [See Also](#9-see-also)
10. [Changelog](#changelog)

---

## 1. Overview

This blueprint defines the **structure for reference documentation**. References are lookup works that provide complete, structured information on a topic.

### Target Audience

- All developers who want to look something up quickly
- Focus on completeness and quick retrieval

### Delimitation

| Documentation type | Question |
|-------------------|---------------|
| **Reference** | "What does X mean?" "Which options are there?" |
| **Guide** | "How do I do X?" |
| **ModuleDoc** | "How does module X work internally?" |

---

## 2. Scope

This blueprint applies to:
- Schema documentation (`Solution_Schema`, `CMakePresets`)
- Error code references
- Glossaries
- API overviews (not modules — use ModuleDoc for those)

**Typical folder:** `docs/[lang]/guide/references/`

---

## 3. Header Structure

### 3.1 Standard Header

```markdown
# [Name] — Reference

> **Version:** X.Y.Z  
> **Date:** YYYY-MM-DD  
> **Type:** Reference  
> **Status:** [In Development | Stable | Deprecated]  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Name.md](../../../de/guide/references/Name.md)
```

### 3.2 No Additional Required Fields

Reference uses the standard header from Doc.md.

---

## 4. Required Sections

References use this structure:

```
## Table of Contents

## 1. Overview
## 2. Conventions
## 3. [Categorized Entries]
## 4. Quick Reference
## 5. Usage in Code
## 6. See Also
## Changelog
```

### 4.1 Section Details

| # | Section | Content |
|---|-----------|--------|
| 1 | Overview | What is documented? Purpose |
| 2 | Conventions | Notation, legend, abbreviations |
| 3 | Entries | Categorized, complete listing |
| 4 | Quick reference | Compact table of all entries |
| 5 | Usage | Code examples for typical use |
| 6 | See also | Related documents |

---

## 5. Entry Format

### 5.1 For Schema Fields

````markdown
### 3.1 `fieldname`

| Aspect | Value |
|--------|------|
| **Type** | `string` / `number` / `boolean` / `object` / `array` |
| **Required** | ✓ / — |
| **Default** | `"value"` / — |
| **Since** | v0.1.0 |

**Description:**  
What this field does.

**Valid values:**
- `"option1"` — Description
- `"option2"` — Description

**Example:**
```json
"fieldname": "option1"
```

**Notes:**
- Additional information
````

### 5.2 For Error Codes

```markdown
### E0501 — Executable not found

| Aspect | Value |
|--------|------|
| **Category** | Executable Pipeline |
| **Severity** | FATAL_ERROR |
| **Since** | v0.1.0 |

**Message:**
```
[Executables] ERROR E0501: Executable 'MyApp' not found
```

**Cause:**  
The executable declared in Solution.json does not exist at the given path.

**Solution:**
1. Check the path in Solution.json
2. Check the file structure
3. Adjust the `path` field if necessary

**Related errors:**
- [E0502](#e0502) — Executable type invalid
```

### 5.3 For Glossary Entries

````markdown
### Context

**Definition:**  
An isolated namespace for collecting data during CMake processing.

**Usage:**
```cmake
ctx_create(EXE_MyApp)
ctx_set(EXE_MyApp NAME "MyApp")
```

**See also:** [Context.cmake](../module/core/Context.md)
````

---

## 6. Quick Reference Tables

### 6.1 Purpose

At the end of the main part, a compact overview of all entries.

### 6.2 Format for Schema

```markdown
## 4. Quick Reference

| Field | Type | Required | Default | Description |
|------|-----|---------|---------|--------------|
| `name` | string | ✓ | — | Unique name |
| `version` | string | — | `"0.1.0"` | SemVer version |
| `type` | string | — | `"CONSOLE"` | CONSOLE / GUI |
```

### 6.3 Format for Error Codes

```markdown
## 4. Quick Reference

| Code | Category | Description |
|------|-----------|--------------|
| E0101 | Core | JSON file not found |
| E0102 | Core | JSON parse error |
| E0501 | Executable | Executable not found |
| E0502 | Executable | Invalid type |
```

---

## 7. Example: Complete Reference

```markdown
# ErrorCodes — Reference

> **Version:** 1.0.0  
> **Date:** 2025-12-13  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [ErrorCodes.md](../../../de/guide/references/ErrorCodes.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Conventions](#2-conventions)
3. [Error Codes by Category](#3-error-codes-by-category)
4. [Quick Reference](#4-quick-reference)
5. [Usage in Code](#5-usage-in-code)
6. [See Also](#6-see-also)
7. [Changelog](#changelog)

---

## 1. Overview

This reference documents all error codes of the CMake Architecture 
build system.

### Error Code Format

```
E[KK][NN]

K = category (2 digits)
N = number (2 digits)
```

---

## 2. Conventions

### Categories

| Prefix | Category | Description |
|--------|-----------|--------------|
| E01xx | Core | Basic errors |
| E05xx | Executable | Executable pipeline |
| E06xx | Library | Library pipeline |
| E20xx | External | Externals processing |

### Severities

| Symbol | Meaning |
|--------|-----------|
| ⛔ FATAL | Build aborts |
| ⚠️ WARNING | Build continues |
| ℹ️ INFO | Information only |

---

## 3. Error Codes by Category

### 3.1 Core (E01xx)

#### E0101 — JSON file not found

| Aspect | Value |
|--------|------|
| **Severity** | ⛔ FATAL |
| **Since** | v0.1.0 |

**Message:**
```
[Core] ERROR E0101: Solution.json not found at: ${path}
````

**Solution:** Check the path, create the file.

---

### 3.2 Executable (E05xx)

#### E0501 — Executable not found

[...]

---

## 4. Quick Reference

| Code | Severity | Category | Description |
|------|---------|-----------|--------------|
| E0101 | ⛔ | Core | JSON not found |
| E0102 | ⛔ | Core | JSON parse error |
| E0501 | ⛔ | Executable | Executable not found |

---

## 5. Usage in Code

```cmake
include("${CMAKECRAFT_DIR}/core/Errors.cmake")

# Raise an error
cmake_fatal(E0101 "Solution.json not found")

# Raise a warning  
cmake_warn(W0201 "Deprecated option used")
```

---

## 6. See Also

- [Errors.cmake](../module/core/Errors.md)
- [Debug.cmake](../module/core/Debug.md)

---

## Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **0.1.1** | **2025-12-13** | **E20xx category added** |
| 0.1.0 | 2025-12-03 | Initial |
````

---

## 8. Review Checklist

In addition to the Doc.md checklist:

**Completeness:**
- [ ] All entries documented
- [ ] No missing categories
- [ ] Quick reference complete

**Format:**
- [ ] Uniform entry format
- [ ] Conventions/legend present
- [ ] Usage examples

**Navigation:**
- [ ] Sensible categorization
- [ ] Quick reference table present
- [ ] Cross-references work

---

## 9. See Also

- [Doc.md](Doc.md) — General documentation rules
- [ModuleDoc.md](ModuleDoc.md) — For module documentation
- [Guide.md](Guide.md) — For guides

---

## Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: location `docs/[lang]/guide/references/` (§ 2), jump path `../../../de/`, example references to `../module/core/*.md` without version in the file name, module inclusion via `${CMAKECRAFT_DIR}` (`CMakeCraft.cmake`:133, :149)** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.0 | 2025-12-13 | New: entry formats for schema/error codes/glossary, quick reference tables |
| 0.1.0 | 2025-12-03 | Initial (part of Documentation_Blueprint) |
