# README — Standard for Folder Navigation Documents

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Blueprint  
> **Status:** In Development  
> **Based on:** Doc v0.5.1, Blueprint v0.5  
> **Target Audience:** Documentation Authors  
> **Language:** English  
> **German:** [README_Blueprint.md](../../../de/autorenwerk/blueprints/README_Blueprint.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Scope](#2-scope)
3. [File Naming Conventions](#3-file-naming-conventions)
4. [Header Structure](#4-header-structure)
5. [Content Structure](#5-content-structure)
6. [Quick-Start Section](#6-quick-start-section)
7. [File and Folder Descriptions](#7-file-and-folder-descriptions)
8. [Examples](#8-examples)
9. [Review Checklist](#9-review-checklist)
10. [See Also](#10-see-also)
11. [Changelog](#changelog)

---

## 1. Overview

This blueprint defines **binding rules for README.md files**, which serve as a navigation and orientation aid in every folder.

### Target Audience

- **Documentation authors** who write README files
- **New team members** who are finding their way around the project

### What This Blueprint Covers

| Area | Rules |
|------|-------|
| File names | Language suffixes, directory-dependent conventions |
| Header | Required fields, language links |
| Structure | Quick-start, file descriptions, folder links |
| Target audience | Navigation for newcomers and experienced users |

### Purpose of README Files

| Aspect | Description |
|--------|-------------|
| **Primary** | Quick orientation within the folder |
| **Secondary** | Entry point for newcomers (quick-start) |
| **Tertiary** | Navigation to subfolders and related documents |

---

## 2. Scope

### 2.1 Where README Files Are Needed

Every folder containing documentation or code **SHOULD** contain a README.md:

| Folder Type | README Required |
|-------------|-----------------|
| `docs/` | ✓ Required |
| `docs/de/`, `docs/en/` | ✓ Required |
| `docs/de/autorenwerk/blueprints/` | ✓ Required |
| `docs/de/guide/module/core/` | ✓ Required |
| `cmake/` | ✓ Recommended |
| Project root | ✓ Required (GitHub standard) |

### 2.2 Exceptions

No README required for:
- Very small folders with only 1-2 self-explanatory files
- Temporary or generated folders

For folders with only one file, that file can be linked from the **parent README**.

---

## 3. File Naming Conventions

### 3.1 Basic Principle

| Context | File Name | Language |
|---------|-----------|----------|
| **Standard** | `README.md` | English |
| **Other language** | `README_de.md`, `README_fr.md` | According to suffix |
| **In language directory** (`/de/`, `/en/`) | `README.md` | Language of the directory |

### 3.2 Examples

```
project/
├── README.md                    ← English (standard)
├── README_de.md                 ← German (optional)
│
├── cmake/
│   ├── README.md                ← English
│   └── README_de.md             ← German (optional)
│
└── docs/
    ├── README.md                ← English (overview)
    │
    ├── de/
    │   ├── README.md            ← German (in /de/ folder)
    │   ├── autorenwerk/blueprints/
    │   │   └── README.md        ← German (inherits from /de/)
    │   └── guide/module/
    │       └── README.md        ← German (inherits from /de/)
    │
    └── en/
        ├── README.md            ← English (in /en/ folder)
        └── autorenwerk/blueprints/
            └── README.md        ← English (inherits from /en/)
```

### 3.3 Language Inheritance

READMEs in subfolders of `/de/` or `/en/` inherit the language:

| Path | Language | Reason |
|------|----------|--------|
| `docs/de/autorenwerk/blueprints/README.md` | German | Subfolder of `/de/` |
| `docs/en/guide/module/README.md` | English | Subfolder of `/en/` |
| `cmake/README.md` | English | No language directory |
| `cmake/README_de.md` | German | Explicit suffix |

---

## 4. Header Structure

### 4.1 Simplified Header for READMEs

READMEs use a **simplified header** without type/status/target audience:

```markdown
# [Folder Name] — [Short Description]

> **Version:** X.Y.Z  
> **Date:** YYYY-MM-DD  
> **Language:** English  
> **German:** [README.md](path/to/german/version)
```

### 4.2 Header Fields

| Field | Required | Description |
|-------|----------|-------------|
| **Version** | ✓ | SemVer, in sync with folder content |
| **Date** | ✓ | Last update |
| **Language** | ✓ | `German` or `English` |
| **English** | ✓ (non-EN only) | Link to the English version |

### 4.3 Language Links

**For non-English READMEs** (outside of `/en/`):

```markdown
> **English:** [README.md](../../../en/[area]/[folder]/README.md)
```

**For English READMEs** (outside of language directories):

```markdown
> **German:** [README_de.md](README_de.md)
```

---

## 5. Content Structure

### 5.1 Required Sections

Every README **MUST** contain these sections:

| # | Section | Content |
|---|---------|---------|
| 1 | Quick-Start | Entry point for newcomers (several paths possible) |
| 2 | Overview | Purpose of the folder |
| 3 | Files | **All** files described + linked |
| 4 | Subfolders | If present, with links to their READMEs |

### 5.2 Optional Sections

| Section | When Useful |
|---------|-------------|
| See Also | Related folders/documents |
| Changelog | For frequent structural changes |

### 5.3 Structure Template

```markdown
# [Folder Name] — [Short Description]

> **Version:** X.Y.Z  
> **Date:** YYYY-MM-DD  
> **Language:** English  
> **German:** [README.md](path/to/de/version)

---

## Quick-Start

**[Target audience 1]?**
1. [Document1.md](Document1.md) — Description
2. [Document2.md](Document2.md) — Description

**[Target audience 2]?**
1. [Document3.md](Document3.md) — Description

---

## Overview

[More detailed description of the folder's purpose]

---

## Files

| File | Description |
|------|-------------|
| [File1.md](File1.md) | Short description |
| [File2.md](File2.md) | Short description |
| ... | ... |

---

## Subfolders

| Folder | Description |
|--------|-------------|
| [folder1/](folder1/README.md) | Short description |
| [folder2/](folder2/README.md) | Short description |
```

---

## 6. Quick-Start Section

### 6.1 Purpose

The quick-start is the **most important part** for new users. It answers:
- What do I find here?
- Where do I start?
- Which are the most important files for **my** situation?

### 6.2 Multiple Entry Paths

The quick-start should address **different target audiences**:

```markdown
## Quick-Start

**New to the project?**
1. [Getting_Started.md](guide/userguides/Getting_Started.md) — First steps
2. [Glossar.md](guide/references/Glossar.md) — Clarify terms

**Developing the build system?**
1. [Master_Concept.md](konzepte/abgeschlossen/Master_Concept.md) — Understand the architecture
2. [Errors.md](guide/module/core/Errors.md) — Error handling

**Integrating an external library?**
1. [Externals.md](guide/references/Externals.md) — Overview
2. [Adding_Externals.md](guide/userguides/Adding_Externals.md) — Step by step
```

### 6.3 Rules

| Rule | Description |
|------|-------------|
| **Multiple paths** | Address different target audiences |
| **Prioritized** | Most important first per path |
| **Linked** | Direct links to documents |
| **Short description** | What does one learn there? |

### 6.4 Linking Across Folder Boundaries

The quick-start may and should also link documents from **other folders** if they are relevant for getting started:

```markdown
## Quick-Start

**Using a testing framework?**
1. [Doctest.md](Doctest.md) — This directory
2. [../../references/externals/Git_Externals_Testing.md](../../references/externals/Git_Externals_Testing.md) — All test frameworks
3. [../Testing.md](../Testing.md) — Writing tests
```

---

## 7. File and Folder Descriptions

### 7.1 Complete File List

**All** files in the folder must be listed:

```markdown
## Files

| File | Description |
|------|-------------|
| [Blueprint.md](Blueprint.md) | Meta-blueprint — how to write blueprints |
| [Doc.md](Doc.md) | General rules for all documentation |
| [CMake.md](CMake.md) | Structure for CMake scripts |
| [Concept.md](Concept.md) | Architecture concepts (ADR) |
| [Cpp.md](Cpp.md) | C++/C code structure |
| [Guide.md](Guide.md) | User guides (how-to) |
| [ModuleDoc.md](ModuleDoc.md) | CMake module documentation |
| [README_Blueprint.md](README_Blueprint.md) | This document |
| [Reference.md](Reference.md) | Reference works |
| [Standard.md](Standard.md) | Coding/project standards |
| [Structure.md](Structure.md) | Documentation structure |
| [Tutorial.md](Tutorial.md) | Step-by-step instructions |
```

### 7.2 Subfolders with Single Files

For subfolders with only **one file**, that file can be linked directly from the parent README:

```markdown
## Subfolders

| Folder | Content |
|--------|---------|
| [core/](core/README.md) | [Fetch_cmake.md](core/Fetch_cmake.md) — Git FetchContent |
| [fetched/](fetched/README.md) | [Handler_cmake.md](fetched/Handler_cmake.md) — Post-fetch handler |
```

Or as an extended table:

```markdown
## Subfolders and Their Files

### core/
| File | Description |
|------|-------------|
| [Fetch_cmake.md](core/Fetch_cmake.md) | Git FetchContent wrapper |

### fetched/
| File | Description |
|------|-------------|
| [Handler_cmake.md](fetched/Handler_cmake.md) | Post-fetch handler |
```

### 7.3 Grouping for Many Files

With > 10 files, these should be grouped by topic:

```markdown
## Files

### Core Blueprints

| File | Description |
|------|-------------|
| [Blueprint.md](Blueprint.md) | Meta-blueprint |
| [Doc.md](Doc.md) | Documentation fundamentals |

### Documentation Types

| File | Description |
|------|-------------|
| [Guide.md](Guide.md) | User guides |
| [Reference.md](Reference.md) | Reference works |
| [Tutorial.md](Tutorial.md) | Instructions |
| ... | ... |
```

---

## 8. Examples

### 8.1 Complete Example: guide/module/externals/README.md

```markdown
# Externals — External Management System

> **Version:** 1.0.0  
> **Date:** 2025-12-15  
> **Language:** English  
> **German:** [README.md](../../../../de/guide/module/externals/README.md)

---

## Quick-Start

**Integrating external libraries?**
1. [Orchestrator_cmake.md](Orchestrator_cmake.md) — Understand the main entry
2. [../../userguides/Externals.md](../../userguides/Externals.md) — Practical guide

**Fetching a Git-based library?**
1. [core/Fetch_cmake.md](core/Fetch_cmake.md) — FetchContent wrapper
2. [hooks/HookLoader_cmake.md](hooks/HookLoader_cmake.md) — Pre/post-fetch hooks

**Integrating a local library?**
1. [locals/Attach_cmake.md](locals/Attach_cmake.md) — Local attach system
2. [includes/](includes/README.md) — Include definitions

---

## Overview

The external management system handles all external dependencies.

---

## Files

| File | Description |
|------|-------------|
| [Orchestrator_cmake.md](Orchestrator_cmake.md) | Main orchestration of the external system |

---

## Subfolders

| Folder | Files | Description |
|--------|-------|-------------|
| [core/](core/README.md) | 1 | [Fetch_cmake.md](core/Fetch_cmake.md) — Git FetchContent |
| [fetched/](fetched/README.md) | 1 | [Handler_cmake.md](fetched/Handler_cmake.md) — Post-fetch handler |
| [hooks/](hooks/README.md) | 3+ | Hook system (pre/post-fetch) |
| [includes/](includes/README.md) | 4+ | Library-specific includes |
| [locals/](locals/README.md) | 1 | [Attach_cmake.md](locals/Attach_cmake.md) — Local libraries |
| [registry/](registry/README.md) | 1 | [Targets_cmake.md](registry/Targets_cmake.md) — Target registry |
```

---

## 9. Review Checklist

Check before finalizing a README:

**Header:**
- [ ] Version and date current
- [ ] Language stated correctly
- [ ] English link present (for non-EN)

**Quick-Start:**
- [ ] Multiple entry paths for different target audiences
- [ ] Links to the most important documents
- [ ] Relevant documents from other folders also linked

**Files:**
- [ ] **All** files in the folder listed
- [ ] Each file has a meaningful description
- [ ] Links work

**Subfolders:**
- [ ] All subfolders listed
- [ ] For folders with single files: files linked directly
- [ ] Link to the subfolder's README

**Structure:**
- [ ] Horizontal separators before H2
- [ ] No numbering of sections

---

## 10. See Also

- [Doc.md](Doc.md) — General documentation rules
- [Blueprint.md](Blueprint.md) — Meta-blueprint
- [Structure.md](Structure.md) — Documentation structure

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: folders `autorenwerk/blueprints/`, `guide/module/` instead of `blueprints/`, `modules/` (§ 2.1, § 3.2, § 3.3, § 8.1); language links per today's depth (§ 4.3, § 8.1); example references relative to the location of the example README (§ 6.2: `docs/de/`, § 6.4: `guide/userguides/externals/`, § 7.2 and § 8.1: `guide/module/externals/`)** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.1.0 | 2025-12-15 | Initial: file naming conventions, quick-start with multiple paths, complete file lists, subfolder integration |
