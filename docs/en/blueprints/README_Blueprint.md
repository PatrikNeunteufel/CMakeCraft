# README — Standard for Folder Navigation Documents

> **Version:** 0.1.0  
> **Date:** 2025-12-15  
> **Type:** Blueprint  
> **Status:** In Development  
> **Based on:** Doc v0.5.1, Blueprint v0.5  
> **Audience:** Documentation Authors  
> **Language:** English  
> **Deutsch:** [README_Blueprint.md](../../de/blueprints/README_Blueprint.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Scope](#2-scope)
3. [Filename Conventions](#3-filename-conventions)
4. [Header Structure](#4-header-structure)
5. [Content Structure](#5-content-structure)
6. [Quick-Start Section](#6-quick-start-section)
7. [File and Folder Descriptions](#7-file-and-folder-descriptions)
8. [Examples](#8-examples)
9. [Review Checklist](#9-review-checklist)
10. [See Also](#10-see-also)
11. [Changelog](#11-changelog)

---

## 1. Overview

This blueprint defines **binding rules for README.md files** that serve as navigation and orientation aids in each folder.

### Audience

- **Documentation authors** writing README files
- **New team members** navigating the project

### What This Blueprint Covers

| Area | Rules |
|------|-------|
| Filenames | Language suffixes, directory-dependent conventions |
| Header | Required fields, language links |
| Structure | Quick-start, file descriptions, folder links |
| Audience | Navigation for newcomers and experienced users |

### Purpose of README Files

| Aspect | Description |
|--------|-------------|
| **Primary** | Quick orientation within a folder |
| **Secondary** | Entry point for newcomers (Quick-Start) |
| **Tertiary** | Navigation to subfolders and related documents |

---

## 2. Scope

### 2.1 Where README Files Are Needed

Every folder with documentation or code **SHOULD** contain a README.md:

| Folder Type | README Required |
|-------------|-----------------|
| `docs/` | ✓ Required |
| `docs/de/`, `docs/en/` | ✓ Required |
| `docs/de/blueprints/` | ✓ Required |
| `docs/de/modules/core/` | ✓ Required |
| `cmake/` | ✓ Recommended |
| Project Root | ✓ Required (GitHub standard) |

### 2.2 Exceptions

No README required for:
- Very small folders with only 1-2 self-explanatory files
- Temporary or generated folders

---

## 3. Filename Conventions

### 3.1 Basic Principle

| Context | Filename | Language |
|---------|----------|----------|
| **Default** | `README.md` | English |
| **Other language** | `README_de.md`, `README_fr.md` | According to suffix |
| **In language directory** (`/de/`, `/en/`) | `README.md` | Directory language |

### 3.2 Examples

```
project/
├── README.md                    ← English (default)
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
    │   ├── blueprints/
    │   │   └── README.md        ← German (inherits from /de/)
    │   └── modules/
    │       └── README.md        ← German (inherits from /de/)
    │
    └── en/
        ├── README.md            ← English (in /en/ folder)
        └── blueprints/
            └── README.md        ← English (inherits from /en/)
```

### 3.3 Language Inheritance

READMEs in subfolders of `/de/` or `/en/` inherit the language:

| Path | Language | Reason |
|------|----------|--------|
| `docs/de/blueprints/README.md` | German | Subfolder of `/de/` |
| `docs/en/modules/README.md` | English | Subfolder of `/en/` |
| `cmake/README.md` | English | No language directory |
| `cmake/README_de.md` | German | Explicit suffix |

---

## 4. Header Structure

### 4.1 Simplified Header for READMEs

READMEs use a **simplified header** without Type/Status/Audience:

```markdown
# [Folder Name] — [Short Description]

> **Version:** X.Y.Z  
> **Date:** YYYY-MM-DD  
> **Language:** English  
> **Deutsch:** [README.md](path/to/german/version)
```

### 4.2 Header Fields

| Field | Required | Description |
|-------|----------|-------------|
| **Version** | ✓ | SemVer, synchronized with folder content |
| **Date** | ✓ | Last update |
| **Language** | ✓ | `Deutsch` or `English` |
| **Deutsch** | ✓ (non-DE only) | Link to German version |

### 4.3 Language Links

**For non-German READMEs** (outside `/de/`):

```markdown
> **Deutsch:** [README_de.md](./README_de.md)
```

**For German READMEs** (outside language directories):

```markdown
> **English:** [README.md](./README.md)
```

**In language directories** (`/de/`, `/en/`):

```markdown
# In /en/blueprints/README.md:
> **Deutsch:** [README.md](../../de/blueprints/README.md)

# In /de/blueprints/README.md:
> **English:** [README.md](../../en/blueprints/README.md)
```

---

## 5. Content Structure

### 5.1 Required Sections

Every README **MUST** contain these sections:

| # | Section | Content |
|---|---------|---------|
| 1 | Quick-Start | Entry point for newcomers |
| 2 | Overview | Purpose of the folder |
| 3 | Files | Description + links |
| 4 | Subfolders | If present, with links |

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
> **Deutsch:** [README_de.md](path/to/de/version)

---

## Quick-Start

[2-3 sentences: What is this folder for? Where to start?]

---

## Overview

[More detailed description of folder purpose]

---

## Files

| File | Description |
|------|-------------|
| [File1.md](File1.md) | Short description |
| [File2.md](File2.md) | Short description |

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

The Quick-Start is the **most important part** for new users. It answers:
- What do I find here?
- Where do I start?
- What are the most important files?

### 6.2 Structure

```markdown
## Quick-Start

**New here?** This folder contains [purpose].

Start with:
1. [Most_Important_File.md](Most_Important_File.md) — Understand basics
2. [Second_File.md](Second_File.md) — Practical application
```

### 6.3 Rules

| Rule | Description |
|------|-------------|
| **Brevity** | Maximum 5-7 lines |
| **Action-oriented** | Clear next steps |
| **Prioritized** | Most important first |
| **Linked** | Direct links to entry documents |

---

## 7. File and Folder Descriptions

### 7.1 File Table

All files in the folder are listed in a table:

```markdown
## Files

| File | Description |
|------|-------------|
| [Blueprint.md](Blueprint.md) | Meta-blueprint — how to write blueprints |
| [Doc.md](Doc.md) | General rules for all documentation |
| [CMake.md](CMake.md) | Structure for CMake scripts |
```

### 7.2 Folder Table

Subfolders are listed separately, with link to README:

```markdown
## Subfolders

| Folder | Description |
|--------|-------------|
| [core/](core/README.md) | Core modules (8 modules) |
| [externals/](externals/README.md) | External management |
| [project/](project/README.md) | Project pipeline |
```

### 7.3 Description Style

| Good | Bad |
|------|-----|
| "Core modules (Errors, Context)" | "Contains core modules" |
| "CMake module documentation" | "Documentation" |
| "Architecture concepts (ADR)" | "Concepts and stuff" |

---

## 8. Examples

### 8.1 Complete Example: blueprints/README.md

```markdown
# Blueprints — Templates and Standards

> **Version:** 0.5.0  
> **Date:** 2025-12-15  
> **Language:** English  
> **Deutsch:** [README.md](../../de/blueprints/README.md)

---

## Quick-Start

**Creating new documentation?** Blueprints are your templates.

Start with:
1. [Doc.md](Doc.md) — Basic rules for all documentation
2. Choose the right type: [Guide.md](Guide.md) for how-tos, [Reference.md](Reference.md) for lookups

---

## Overview

The blueprint collection defines binding standards for:
- **Documentation** of all types (Guide, Reference, Concept, etc.)
- **CMake modules** (.cmake files)
- **Code standards** (C++, C)

Blueprints follow an inheritance hierarchy: `Blueprint.md` → `Doc.md` → specialized types.

---

## Files

| File | Description |
|------|-------------|
| [Blueprint.md](Blueprint.md) | Meta-blueprint — how to write blueprints |
| [Doc.md](Doc.md) | General rules for all documentation |
| [ModuleDoc.md](ModuleDoc.md) | CMake module documentation |
| [Guide.md](Guide.md) | User guides (how-to) |
| [Reference.md](Reference.md) | Reference documentation (schema, API) |
```

---

## 9. Review Checklist

Before finalizing a README:

**Header:**
- [ ] Version and date current
- [ ] Language correctly specified
- [ ] Language link present (if applicable)
- [ ] Language link points to correct file

**Quick-Start:**
- [ ] Present and short (max. 7 lines)
- [ ] Clear next steps
- [ ] Links to most important documents

**Files/Folders:**
- [ ] All files listed
- [ ] All subfolders listed
- [ ] Links work
- [ ] Descriptions are meaningful

**Structure:**
- [ ] Horizontal separators before H2
- [ ] No section numbering (exception from Doc.md)

---

## 10. See Also

- [Doc.md](Doc.md) — General documentation rules
- [Blueprint.md](Blueprint.md) — Meta-blueprint
- [Structure.md](Structure.md) — Documentation structure

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **0.1.0** | **2025-12-15** | **Initial: Filename conventions, Quick-Start requirement, Simplified header, Language inheritance** |
