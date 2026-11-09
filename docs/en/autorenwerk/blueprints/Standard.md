# Standard — Standard for Coding/Project Standards

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Blueprint  
> **Status:** In Development  
> **Based on:** Doc v0.5, Blueprint v0.5  
> **Target Audience:** Documentation authors  
> **Language:** English  
> **German:** [Standard.md](../../../de/autorenwerk/blueprints/Standard.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Scope](#2-scope)
3. [Header Extensions](#3-header-extensions)
4. [Required Sections](#4-required-sections)
5. [Rule Format](#5-rule-format)
6. [Example: Complete Standard](#6-example-complete-standard)
7. [Review Checklist](#7-review-checklist)
8. [See Also](#8-see-also)
9. [Changelog](#changelog)

---

## 1. Overview

This blueprint defines the **structure for coding and project standards**. Standards lay down binding rules for code style, naming conventions and workflows.

### Target Audience

- All developers in the team
- CI/CD systems (automated checks)
- Code review processes

### Delimitation

| Documentation type | Focus |
|-------------------|-------|
| **Standard** | "This is how code MUST be written" |
| **Guide** | "This is how you CAN achieve X" |
| **Concept** | "Why X was decided this way" |
| **Blueprint** | "This is how documentation MUST be written" |

---

## 2. Scope

This blueprint applies to:
- Coding standards (C++, C, CMake)
- Git workflows
- Review guidelines
- Project conventions

**Typical folder:** `docs/[lang]/autorenwerk/standards/`

**Examples:**
- `Cpp_Coding_Standard.md`
- `CMake_Standard.md`
- `Git_Standard.md`

---

## 3. Header Extensions

### 3.1 Additional Required Fields

| Field | Required | Description |
|------|---------|--------------|
| `Scope:` | ✓ | Which code/workflow is affected |
| `Enforcement:` | Optional | How is the standard enforced? |

### 3.2 Complete Header

```markdown
# [Name] — Standard

> **Version:** X.Y.Z  
> **Date:** YYYY-MM-DD  
> **Type:** Standard  
> **Status:** [In Development | Stable | Deprecated]  
> **Target Audience:** All developers  
> **Scope:** [C++ code | CMake scripts | Git workflow | ...]  
> **Enforcement:** [clang-format | clang-tidy | CI | Review | ...]  
> **Language:** English  
> **German:** [Name_Standard.md](../../../de/autorenwerk/standards/Name_Standard.md)
```

---

## 4. Required Sections

Standards use this structure:

```
## Table of Contents

## 1. Overview
## 2. Scope
## 3. [Thematic rule sections]
## 4. Exceptions
## 5. Tool Configuration
## 6. Migration
## 7. Checklist
## 8. See Also
## Changelog
```

### 4.1 Section Details

| # | Section | Content |
|---|-----------|--------|
| 1 | Overview | Why this standard? Goals |
| 2 | Scope | Which code, which files |
| 3 | Rules | The actual regulations |
| 4 | Exceptions | When may one deviate? |
| 5 | Tool configuration | clang-format, clang-tidy, etc. |
| 6 | Migration | Converting old code |
| 7 | Checklist | Quick check for reviews |
| 8 | See also | Related standards |

---

## 5. Rule Format

### 5.1 Rule Documentation

Each rule is documented like this:

````markdown
### 3.2 Naming Convention for Functions

**Rule:** Functions use `snake_case`.

**Obligation:** MUST

**Correct:**
```cpp
void calculate_checksum();
void parse_json_file();
```

**Wrong:**
```cpp
void CalculateChecksum();   // PascalCase
void calculateChecksum();   // camelCase
void CALCULATE_CHECKSUM();  // UPPER_CASE
```

**Rationale:**  
Consistency with the CMake API and C-style code.

**Exceptions:**  
None.

**Check:**  
clang-tidy check `readability-identifier-naming`
````

### 5.2 Obligation Levels

| Level | Meaning | Keyword |
|-------|-----------|---------|
| **MUST** | No exceptions | Required, Mandatory |
| **SHOULD** | Recommended, exceptions possible | Should, Recommended |
| **MAY** | Optional, as needed | May, Optional |
| **MUST NOT** | Forbidden | Must Not, Forbidden |

### 5.3 Rule Tables

For overviews, a compact table form:

```markdown
| Rule | Correct | Wrong | Obligation |
|-------|---------|--------|-----------------|
| Functions | `snake_case` | `camelCase` | MUST |
| Classes | `PascalCase` | `snake_case` | MUST |
| Constants | `kPascalCase` | `UPPER_CASE` | SHOULD |
```

---

## 6. Example: Complete Standard

````markdown
# C++ Coding Standard

> **Version:** 1.0.0  
> **Date:** 2025-12-13  
> **Type:** Standard  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Scope:** All C++ files (*.cpp, *.hpp, *.tpp)  
> **Enforcement:** clang-format, clang-tidy, code review  
> **Language:** English  
> **German:** [Cpp_Coding_Standard.md](../../../de/autorenwerk/standards/Cpp_Coding_Standard.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Scope](#2-scope)
3. [Naming Conventions](#3-naming-conventions)
4. [Formatting](#4-formatting)
5. [Language Features](#5-language-features)
6. [Exceptions](#6-exceptions)
7. [Tool Configuration](#7-tool-configuration)
8. [Checklist](#8-checklist)
9. [See Also](#9-see-also)
10. [Changelog](#changelog)

---

## 1. Overview

This standard defines binding rules for C++ code in the project.

### Goals

- Uniform code style
- Readability and maintainability
- Automatic checkability

---

## 2. Scope

| File type | Affected |
|----------|-----------|
| `*.cpp` | ✓ |
| `*.hpp` | ✓ |
| `*.tpp` | ✓ |
| `*.h` (C header) | Only if C++ code |

**Not affected:** third-party code in `externals/`

---

## 3. Naming Conventions

### 3.1 Overview

| Element | Style | Example |
|---------|------|----------|
| Namespaces | `snake_case` | `audio_engine` |
| Classes | `PascalCase` | `AudioPlayer` |
| Functions | `snake_case` | `play_sound()` |
| Variables | `snake_case` | `sample_rate` |
| Constants | `kPascalCase` | `kMaxVolume` |
| Macros | `UPPER_CASE` | `AUDIO_API` |
| Members | `m_snake_case` | `m_buffer_size` |

### 3.2 Classes and Structs

**Rule:** `PascalCase`

**Obligation:** MUST

**Correct:**
```cpp
class AudioPlayer {};
struct SoundBuffer {};
```

**Wrong:**
```cpp
class audio_player {};  // snake_case
class audioPlayer {};   // camelCase
```

---

## 4. Formatting

### 4.1 Indentation

**Rule:** 4 spaces, no tabs

**Obligation:** MUST

**Check:** clang-format `IndentWidth: 4`

### 4.2 Braces (Allman Style)

**Rule:** Opening brace on a new line

**Obligation:** MUST

**Correct:**
```cpp
if (condition)
{
    do_something();
}
```

**Wrong:**
```cpp
if (condition) {
    do_something();
}
```

---

## 5. Language Features

### 5.1 Use of auto

**Rule:** `auto` only for complex types

**Obligation:** SHOULD

**Correct:**
```cpp
auto it = container.begin();
auto ptr = std::make_unique<Widget>();
```

**Wrong:**
```cpp
auto i = 0;        // int is obvious
auto name = "str"; // const char* is obvious
```

---

## 6. Exceptions

| Situation | Permitted deviation |
|-----------|---------------------|
| Third-party integration | Keep their style |
| Performance-critical code | Documented optimizations |
| Legacy migration | Temporary, with TODO |

---

## 7. Tool Configuration

### clang-format

See: [.clang-format](../../.clang-format)

### clang-tidy

```yaml
Checks: >
  readability-identifier-naming,
  modernize-*,
  bugprone-*
```

---

## 8. Checklist

Check before code review:

- [ ] Naming conventions followed
- [ ] clang-format run
- [ ] No compiler warnings
- [ ] No clang-tidy errors
- [ ] Comments up to date

---

## 9. See Also

- [ClangFormat_Blueprint](../blueprints/ClangFormat.md)
- [ClangTidy_Blueprint](../blueprints/ClangTidy.md)
- [CMake_Standard](CMake_Standard.md)

---

## Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **0.1.0** | **2025-12-13** | **Initial** |
````

---

## 7. Review Checklist

In addition to the Doc.md checklist:

**Rules:**
- [ ] Every rule has an obligation level
- [ ] Correct/wrong examples for every rule
- [ ] Rationales given
- [ ] Exceptions documented

**Enforcement:**
- [ ] Tool configuration present or linked
- [ ] Automatic checking possible (where sensible)

**Practice:**
- [ ] Checklist for reviews present
- [ ] Migration notes (if legacy code exists)

---

## 8. See Also

- [Doc.md](Doc.md) — General documentation rules
- [ClangFormat.md](ClangFormat.md) — Formatting standard
- [ClangTidy.md](ClangTidy.md) — Static analysis

---

## Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: location `docs/[lang]/autorenwerk/standards/` (§ 2), file names without version, jump path `../../../de/`; example § 4.2 `do_something()` per its own `snake_case` rule (§ 3.1 of the example)** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.0 | 2025-12-13 | New: rule format with obligation levels, tool configuration, checklist |
| 0.1.0 | 2025-12-03 | Initial (part of Documentation_Blueprint) |
