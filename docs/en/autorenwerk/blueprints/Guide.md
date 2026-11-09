# Guide — Standard for User Guides

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Blueprint  
> **Status:** In Development  
> **Based on:** Doc v0.5, Blueprint v0.5  
> **Target Audience:** Documentation authors  
> **Language:** English  
> **German:** [Guide.md](../../../de/autorenwerk/blueprints/Guide.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Scope](#2-scope)
3. [Header Extensions](#3-header-extensions)
4. [Required Sections](#4-required-sections)
5. [Writing Style](#5-writing-style)
6. [Example: Complete Guide](#6-example-complete-guide)
7. [Review Checklist](#7-review-checklist)
8. [See Also](#8-see-also)
9. [Changelog](#changelog)

---

## 1. Overview

This blueprint defines the **structure for user guides**. Guides are task-oriented documentation that explains **how** something is done.

### Target Audience

- C++ developers who **use** the build system (not develop it)
- Focus on practical application, not internal details

### Delimitation

| Documentation type | Question | Example |
|-------------------|---------------|----------|
| **Guide** | "How do I configure X?" | Qt6 integration |
| **Tutorial** | "Show me step by step" | Creating a first project |
| **Reference** | "What does Y mean?" | Solution_Schema |
| **ModuleDoc** | "How does Z work internally?" | Context.cmake |

---

## 2. Scope

This blueprint applies to all documentation that:
- Is practical instructions for end users
- Lives in the folder `docs/[lang]/guide/userguides/`
- Has a "how-to" character

**Examples:**
- `Qt6_Integration.md`
- `Testing.md`
- `Adding_Externals.md`

---

## 3. Header Extensions

### 3.1 Optional Additional Fields

| Field | Required | Description |
|------|---------|--------------|
| `Module:` | Optional | If the guide concerns a specific module |

### 3.2 Complete Header

```markdown
# [Topic] — User Guide

> **Version:** X.Y.Z  
> **Date:** YYYY-MM-DD  
> **Type:** Guide  
> **Status:** [In Development | Stable | Deprecated]  
> **Target Audience:** C++ developers  
> **Module:** externals/qt6/Include.cmake v0.6.0 (optional)  
> **Language:** English  
> **German:** [Topic.md](../../../de/guide/userguides/Topic.md)
```

---

## 4. Required Sections

Guides use this structure:

```
## Table of Contents

## 1. Overview
## 2. Prerequisites
## 3. Quick Start
## 4. [Task-Oriented Sections]
## 5. Pitfalls and Solutions
## 6. Troubleshooting
## 7. See Also
## Changelog
```

### 4.1 Section Details

| # | Section | Content |
|---|-----------|--------|
| 1 | Overview | What does this guide enable? Feature list |
| 2 | Prerequisites | What must be installed/configured? |
| 3 | Quick Start | Minimal working example |
| 4 | Tasks | "How do I add X?", "How do I configure Y?" |
| 5 | Pitfalls | Common errors with explanation and solution |
| 6 | Troubleshooting | Checklist, table of common errors |
| 7 | See Also | Related guides, references |

### 4.2 Task-Oriented Sections

The main part consists of task-oriented sections:

```markdown
## 4. Configuration

### 4.1 Minimal Configuration

[How do you do the minimum?]

### 4.2 With Extended Options

[How do you enable feature X?]

### 4.3 Platform-Specific

[Differences Windows/Linux/macOS]
```

---

## 5. Writing Style

### 5.1 Active and Direct

| ❌ Passive | ✅ Active |
|----------|---------|
| "It is recommended..." | "We recommend..." |
| "The file should be created" | "Create the file" |
| "It can be configured" | "Configure X like this:" |

### 5.2 Task-Oriented

Headings as questions or tasks:

| ❌ Abstract | ✅ Task-oriented |
|------------|----------------------|
| "Configuration" | "How do I configure Qt6?" |
| "External dependencies" | "How do I add an external?" |
| "Build process" | "How do I build the project?" |

### 5.3 Concrete with Examples

Every instruction contains:
1. **What:** Short explanation
2. **How:** Code example or command
3. **Why:** Optional explanation for non-obvious steps

````markdown
### 4.2 With Path Hint

If `QT_ROOT` is not set, specify the path directly:

```json
"qt6": {
    "path": "externals/qt6",
    "options": {
        "hint": "C:/Qt/6.10.1/msvc2022_64"
    }
}
```

The `hint` is only used if no environment variable was found.
````

### 5.4 Visual Structuring

- **Checklists** for prerequisites and troubleshooting
- **Tables** for comparisons and options
- **Code blocks** for all commands and configurations
- **Note boxes** for warnings and tips

---

## 6. Example: Complete Guide

````markdown
# Qt6 Integration — User Guide

> **Version:** 1.0.0  
> **Date:** 2025-12-13  
> **Type:** Guide  
> **Status:** Stable  
> **Target Audience:** C++ developers  
> **Module:** externals/qt6/Include.cmake v0.6.0  
> **Language:** English  
> **German:** [Qt6_Integration.md](../../../de/guide/userguides/Qt6_Integration.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Quick Start](#3-quick-start)
4. [Configuration](#4-configuration)
5. [Pitfalls and Solutions](#5-pitfalls-and-solutions)
6. [Troubleshooting](#6-troubleshooting)
7. [See Also](#7-see-also)
8. [Changelog](#changelog)

---

## 1. Overview

The Qt6 integration enables the use of Qt6 in CMake Architecture projects.

### Features

- Flexible path detection
- Automatic DLL deployment (Windows)
- RPATH configuration (Linux/macOS)
- Component selection

---

## 2. Prerequisites

- [ ] Qt6 installed (6.5+)
- [ ] CMake 3.24+
- [ ] Compiler: MSVC 2022 / GCC / Clang

---

## 3. Quick Start

**1. Solution.json:**
```json
"externals": {
    "qt6": {
        "path": "externals/qt6",
        "options": { "hint": "${QT_ROOT}" }
    }
}
```

**2. Build:**
```bash
cmake --preset windows-ninja-debug
cmake --build out/build/windows-ninja-debug
```

---

## 4. Configuration

### 4.1 Minimal Configuration

[...]

### 4.2 With Components

[...]

---

## 5. Pitfalls and Solutions

### 5.1 Qt Headers Are Not Found

**Problem:** `fatal error: 'QApplication' file not found`

**Cause:** Include.cmake version < 0.3.0

**Solution:** Update Include.cmake.

---

## 6. Troubleshooting

### Checklist

- [ ] Qt installed?
- [ ] Environment variable set?
- [ ] CMake cache deleted?

### Common Errors

| Error | Solution |
|--------|--------|
| `Qt6 not found` | Check the environment variable |
| DLLs missing | Include.cmake v0.5.0+ |

---

## 7. See Also

- [Solution_Schema](../references/Solution_Schema.md)
- [Adding_Externals](Adding_Externals.md)

---

## Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **0.2.0** | **2025-12-13** | **Pitfalls, troubleshooting extended** |
| 0.1.0 | 2025-12-10 | Initial |
````

---

## 7. Review Checklist

In addition to the Doc.md checklist:

**Structure:**
- [ ] Quick start present (minimal working example)
- [ ] Prerequisites as a checklist
- [ ] Troubleshooting section present

**Content:**
- [ ] Task-oriented headings
- [ ] Every instruction has a code example
- [ ] Pitfalls documented
- [ ] All platforms considered (if relevant)

**Style:**
- [ ] Active writing style
- [ ] Direct instructions
- [ ] No unnecessary internals

---

## 8. See Also

- [Doc.md](Doc.md) — General documentation rules
- [Tutorial.md](Tutorial.md) — For step-by-step instructions
- [Reference.md](Reference.md) — For reference works

---

## Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: location `docs/[lang]/guide/userguides/` (§ 2), file names without `_UserGuide` and without version (§ 2, § 3.2, example), jump path `../../../de/`** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.0 | 2025-12-13 | New: writing style rules, task-oriented structure, complete example |
| 0.1.0 | 2025-12-03 | Initial (part of Documentation_Blueprint) |
