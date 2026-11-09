# ClangFormat Blueprint – Code Formatting

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Blueprint  
> **Status:** In Development (Pre-Release)  
> **Scope:** All `.clang-format` configurations  
> **Related to:** Cpp_Coding_Standard v0.1, C_Coding_Standard v0.1  
> **Language:** English  
> **German:** [ClangFormat.md](../../../de/autorenwerk/blueprints/ClangFormat.md)

---

## 1. Purpose

This blueprint defines the **structure and maintenance** of the `.clang-format` configuration.

**What this document is:**
- Conceptual basis for formatting rules
- Definition of responsibilities and change processes
- Explanation of the intentions behind the rules

**What this document is not:**
- The technical configuration itself (→ `.clang-format` file)

---

## 2. Relationship to Other Standards

| Document | Defines |
|----------|-----------|
| **Cpp_Coding_Standard** | Style, language features, design rules |
| **C_Coding_Standard** | Style for embedded C |
| **`.clang-format`** | Technical implementation of the formatting |

### Conflict Resolution

> If the written documentation and `.clang-format` contradict each other, **`.clang-format`** is binding. The documentation is brought up to date; the tool is not circumvented.

---

## 3. Base Style and Philosophy

### 3.1 Fundamentals

| Aspect | Value |
|--------|------|
| Base style | `LLVM` with project-specific adjustments |
| Goals | Readability, stable diffs, minimal style discussions |

### 3.2 Responsibility

- The `.clang-format` file in the root directory is maintained centrally
- Project-specific overrides are to be avoided
- Changes follow the process in section 7

---

## 4. Formatting Guidelines (Concept)

> The exact values are defined in `.clang-format`. This section documents the **intention**.

### 4.1 Indentation and Whitespace

| Setting | Value | Rationale |
|-------------|------|------------|
| IndentWidth | 4 | Compromise between density and readability |
| TabWidth | 4 | Consistency |
| UseTab | Never | Avoids alignment problems |

### 4.2 Braces (Allman Style)

Opening braces go on a **new line** for:
- Functions
- Classes/structs
- Namespaces
- Control structures (`if`, `for`, `while`, `switch`)

**Example:**
```cpp
if (condition)
{
    doSomething();
}
else
{
    handleElse();
}
```

**Rationale:** Clear visual structure, easier diffing.

### 4.3 Line Length

| Setting | Value |
|-------------|------|
| ColumnLimit | 80 (or 120, depending on the project) |

**Rationale:** Avoids horizontal scrolling, better side-by-side diffs.

### 4.4 Include Sorting

**Order:**
1. Precompiled header (`pch/pch.h`) – if present
2. System headers (`<...>`)
3. Project headers (`"..."`)

**Setting:** `IncludeBlocks: Regroup`

**Rationale:** The PCH must come first; clear separation of system/project.

### 4.5 Arrays and Initializer Lists

**Style:** One element per line for multi-line arrays.

```cpp
int values[] =
{
    1,
    2,
    4,
    8,
};
```

**Rationale:** One changed element = one changed line in the diff.

---

## 5. Project-Specific Extensions

Allowed:
- `Language`-specific sections (C vs. C++)
- Embedded adjustments for toolchain restrictions

Requirements:
- Documentation in the project README
- No unjustified deviations from the global style

---

## 6. Tool Integration

### 6.1 Developer Workflow

1. Integrate `clang-format` into the IDE/editor
2. Format code **before** committing
3. Code reviews ignore formatting (delegated to the tool)

### 6.2 Automation

| Method | Description |
|---------|--------------|
| Pre-commit hook | Automatic formatting before commit |
| CI check | Validation in the build system |
| IDE integration | Format-on-save |

---

## 7. Change Management

### 7.1 When to Change?

Changes only if:
- The current rule demonstrably harms readability
- A new rule significantly improves consistency
- Tooling/the project requires an adjustment

### 7.2 Process

1. **Proposal:** Current behavior (before/after), motivation
2. **Review:** Architecture/tooling team
3. **Implementation:**
   - Update `.clang-format`
   - Formatting pass over the affected code
   - For a conceptual change: update the blueprint

---

## 8. Versioning

### 8.1 File Header

Every `.clang-format` file contains:

```yaml
# C/C++ Formatting Standard
# Version: 0.1.0
# Blueprint: docs/de/autorenwerk/blueprints/ClangFormat.md
# Date: 2025-12-05
```

### 8.2 Versioning Rules

| Change | Action |
|----------|--------|
| Conceptual (brace style, indentation) | Increment version, update blueprint |
| Technical/cosmetic | Version may stay |

---

## 9. See Also

- [Cpp_Coding_Standard](../standards/Cpp_Coding_Standard.md) – C++ style guidelines
- [C_Coding_Standard](../standards/C_Coding_Standard.md) – C style guidelines (embedded)
- [ClangTidy_Blueprint](ClangTidy.md) – Static analysis

---

## Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: header pattern § 8.1 points to today's path `docs/de/autorenwerk/blueprints/ClangFormat.md`** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.1.0 | 2025-12-05 | Initial: structure, philosophy, change process |
