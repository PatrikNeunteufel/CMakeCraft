# Blueprint — Meta-Standard for Blueprints

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Blueprint  
> **Status:** In Development  
> **Target Audience:** Documentation Authors  
> **Language:** English  
> **German:** [Blueprint.md](../../../de/autorenwerk/blueprints/Blueprint.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Blueprint Hierarchy](#2-blueprint-hierarchy)
3. [Core Principles](#3-core-principles)
4. [Blueprint Structure](#4-blueprint-structure)
5. [Inheritance](#5-inheritance)
6. [Versioning](#6-versioning)
7. [Example: Creating a New Blueprint](#7-example-creating-a-new-blueprint)
8. [Review Checklist](#8-review-checklist)
9. [See Also](#9-see-also)
10. [Changelog](#10-changelogs)

---

## 1. Overview

This document is the **meta-blueprint** — it defines how blueprints themselves must be structured.

Blueprints are standards that:
- define structure and format for other documents or code
- ensure consistency across the entire project
- act as "base classes" for specialized standards

### What Is a Blueprint?

| Aspect | Description |
|--------|--------------|
| **Purpose** | Defines binding rules for documents or code |
| **Target audience** | Documentation authors, code authors |
| **Binding force** | Normative — deviations must be justified |
| **Self-reference** | This blueprint also describes itself |

---

## 2. Blueprint Hierarchy

The blueprints follow an inheritance hierarchy:

```
Blueprint.md                    ← Meta-blueprint (this document)
    │
    ├── Doc.md                  ← General documentation rules
    │       │
    │       ├── ModuleDoc.md    ← CMake module documentation
    │       ├── Guide.md        ← User guides
    │       ├── Reference.md    ← API/schema references
    │       ├── Concept.md      ← Architecture concepts
    │       ├── Standard.md     ← Coding/project standards
    │       └── Tutorial.md     ← Step-by-step tutorials
    
    ├── CMake.md                ← CMake scripts (.cmake)
    │
    └── Cpp.md                  ← C++/C code files (.cpp, .hpp, .tpp)
```

### Inheritance Rules

| Rule | Description |
|-------|--------------|
| **Inherit** | Specialized blueprints adopt rules from the parent |
| **Extend** | Additional rules can be added |
| **Override** | Parent rules can be explicitly overridden |
| **Document** | Deviations must be visible in the "Based on" header |

---

## 3. Core Principles

All blueprints follow these principles:

### 3.1 Consistency over Individuality

> A uniform structure makes documents quick to take in.

### 3.2 Convention over Configuration

> Default values and implicit conventions reduce boilerplate.

### 3.3 Explicit over Implicit

> In case of ambiguity, prefer an explicit statement.

### 3.4 Machine-Readable Where Possible

> Choose structures that tools can parse (YAML header, consistent headings).

---

## 4. Blueprint Structure

Every blueprint **MUST** contain these elements:

### 4.1 Header (Required)

```markdown
# [Name] — [Short description]

> **Version:** X.Y.Z  
> **Date:** YYYY-MM-DD  
> **Type:** Blueprint  
> **Status:** [In Development | Stable | Deprecated]  
> **Target Audience:** [Who should read this blueprint?]  
> **Language:** English  
> **German:** [FileName.md](../../../de/autorenwerk/blueprints/FileName.md)
```

### 4.2 Table of Contents (Required)

The header is always followed by a numbered table of contents with anchor links:

```markdown
---

## Table of Contents

1. [Overview](#1-overview)
2. [Topic A](#2-topic-a)
3. [Topic B](#3-topic-b)
...
```

### 4.3 Required Sections for Blueprints

| # | Section | Content |
|---|-----------|--------|
| 1 | Overview | Purpose, scope |
| 2-n | Topical sections | The actual rules |
| n+1 | Examples/templates | Concrete application |
| n+2 | Review checklist | Checkpoints before completion |
| n+3 | See also | Related documents |
| n+4 | Changelog | Version history (always at the end) |

### 4.4 Horizontal Separators

Every H2 section (`##`) is preceded by a horizontal separator:

```markdown
---

## New Section
```

---

## 5. Inheritance

### 5.1 "Based on" Statement

Specialized blueprints must reference their parent:

```markdown
> **Based on:** Doc v0.5, Blueprint v0.5
```

### 5.2 Overriding Rules

When a blueprint overrides a parent rule:

```markdown
### Overrides of Doc.md

| Rule | Parent value | This blueprint |
|-------|-------------|------------------|
| Header field X | Optional | Required |
```

### 5.3 Extending Structures

Additional required fields are documented:

```markdown
### Additional Header Fields

In addition to the fields from Doc.md:

| Field | Required | Description |
|------|---------|--------------|
| `Module:` | ✓ | Path to the documented module |
```

---

## 6. Versioning

### 6.1 Semantic Versioning

Blueprints use SemVer:

| Part | Meaning | When to increment? |
|------|-----------|---------------|
| **MAJOR** | Incompatible changes | Existing documents become invalid |
| **MINOR** | New rules | Backward compatible |
| **PATCH** | Corrections | Typos, clarifications |

### 6.2 Pre-Release Phase

During v0.x.x:
- Breaking changes allowed with a MINOR bump
- Fast iteration possible
- From v1.0.0: strict SemVer

### 6.3 File Naming Convention

```
[Name].md            ← the version is only in the header

Examples:
  Blueprint.md
  Doc.md
  ModuleDoc.md
```

No version number in the file name, no version copies — **Git is the history** (see [Doc.md § 8](Doc.md#8-file-name-conventions)).

---

## 7. Example: Creating a New Blueprint

### 7.1 Step by Step

1. **Choose the parent:** Which blueprint is being specialized?
2. **Create the header:** With a correct "Based on"
3. **Table of contents:** Numbered, with anchors
4. **Define the rules:** What stays the same, what is new, what is overridden?
5. **Examples:** At least one complete example
6. **Checklist:** Checkpoints for users
7. **Review:** Validate against the parent blueprint

### 7.2 Template for New Blueprints

```markdown
# [Name] — [Short description]

> **Version:** 1.0.0  
> **Date:** YYYY-MM-DD  
> **Type:** Blueprint  
> **Status:** In Development  
> **Based on:** [Parent] vX.Y  
> **Target Audience:** [Who should read this blueprint?]  
> **Language:** English  
> **German:** [Name.md](../../../de/autorenwerk/blueprints/Name.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Scope](#2-scope)
3. [Overrides of Parent.md](#3-overrides-of-parentmd)
4. [Additional Rules](#4-additional-rules)
5. [Examples](#5-examples)
6. [Review Checklist](#6-review-checklist)
7. [See Also](#7-see-also)
8. [Changelog](#changelog)

---

## 1. Overview

[Purpose and target audience — describe in more detail here]

---

## 2. Scope

[Which documents/code does this blueprint apply to?]

---

## 3. Overrides of Parent.md

| Rule | Parent value | This blueprint |
|-------|-------------|------------------|
| ... | ... | ... |

---

## 4. Additional Rules

[New rules here]

---

## 5. Examples

[Complete example]

---

## 6. Review Checklist

- [ ] Header complete
- [ ] Table of contents up to date
- [ ] Overrides documented
- [ ] Examples present
- [ ] Changelog up to date

---

## 7. See Also

- [Parent blueprint](Parent_vX_Y_Z.md)

---

## Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **0.1.0** | **YYYY-MM-DD** | **Initial** |
```

---

## 8. Review Checklist

Check before releasing a blueprint:

- [ ] Header complete (Version, Date, Type, Status, Target Audience, Language, English link)
- [ ] Target audience described in the header AND in the overview
- [ ] Table of contents numbered and linked
- [ ] Anchors work (lowercase, hyphens instead of spaces)
- [ ] All required sections present
- [ ] Examples/templates complete and tested
- [ ] Review checklist present
- [ ] "See also" with relevant cross-references
- [ ] Changelog at the end, current version in bold
- [ ] File name follows the convention
- [ ] With inheritance: "Based on" correct

---

## 9. See Also

- [Doc.md](Doc.md) — General documentation rules
- [CMake.md](CMake.md) — CMake file structure
- [Cpp.md](Cpp.md) — C++/C file structure
- [Strukture.md](Structure.md) — Folder structure

---

<a id="10-changelogs"></a>

## Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: file names without version (§ 6.3), jump path to the German version `../../../de/autorenwerk/blueprints/` (§ 4.1, § 7.2)** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.0 | 2025-12-13 | New: inheritance hierarchy, required table of contents with anchors, required target audience field, English link in the header, template for new blueprints |
| 0.1.0 | 2025-12-03 | Initial (as Documentation_Blueprint) |
