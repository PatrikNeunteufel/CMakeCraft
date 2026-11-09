# Structure — Standard for Documentation Organization

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Blueprint  
> **Status:** In Development  
> **Based on:** Blueprint v0.5  
> **Target Audience:** Documentation Authors, Project Maintainers  
> **Language:** English  
> **German:** [Structure.md](../../../de/autorenwerk/blueprints/Structure.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Scope](#2-scope)
3. [Main Folder Structure](#3-main-folder-structure)
4. [Usage vs. Development](#4-usage-vs-development)
5. [Folder Definitions](#5-folder-definitions)
6. [Concepts and Reports](#6-concepts-and-reports)
7. [Decision Tree](#7-decision-tree)
8. [Examples](#8-examples)
9. [See Also](#9-see-also)



---

## 1. Overview

This blueprint defines **where documentation is stored**. It complements [Doc.md](Doc.md), which defines *how* documentation is written.

### Target Audience

- **Documentation authors:** Where do I put my document?
- **Project maintainers:** How do I organize the documentation?
- **New team members:** Where do I find which information?

### Core Principle

The structure separates three areas by **reader role** (entry point: [INDEX.md](../../../INDEX.md)):

| Area | Question | Target audience |
|------|----------|-----------------|
| **Usage** (`guide/`) | "How do I use the build system?" | Build system users |
| **Development** (`konzepte/`) | "How do I develop the build system further?" | Build system developers |
| **Author's toolkit** (`autorenwerk/`) | "How do I write code or docs — in any project?" | Authors of code and docs |

---

## 2. Scope

This blueprint applies to:

- Organization of the `docs/` folder structure
- Assignment of documentation types to folders
- Project-specific documentation

**Not covered:**

- Documentation content → see [Doc.md](Doc.md)
- File and folder naming conventions → see [Doc.md](Doc.md)

> **Note:** Folder names are always lowercase.  
> For details see [Doc.md § 8.8](Doc.md#88-folder-name-convention)

---

## 3. Main Folder Structure

```
docs/
├── INDEX.md                         # Entry point and map
├── README.md
├── report/                          # Session reports, findings lists (no language tree)
│
├── de/                              # German documentation (leading language)
│   ├── README.md
│   │
│   │   ─────────────────────────────────────────────────
│   │   USAGE - for users of the build system
│   │   ─────────────────────────────────────────────────
│   │
│   ├── guide/
│   │   ├── userguides/              # How-to guides, getting started (Getting_Started.md)
│   │   ├── references/              # Reference works (schema, error codes, glossary)
│   │   ├── cheatsheets/             # Quick references
│   │   └── module/                  # Documentation of the cmake/ modules
│   │
│   │   ─────────────────────────────────────────────────
│   │   DEVELOPMENT - for developers of the build system
│   │   ─────────────────────────────────────────────────
│   │
│   ├── konzepte/                    # Guidelines, active concepts
│   │   └── abgeschlossen/           # Implemented concepts (documents of their time)
│   │
│   │   ─────────────────────────────────────────────────
│   │   AUTHOR'S TOOLKIT - for authors, across projects
│   │   ─────────────────────────────────────────────────
│   │
│   └── autorenwerk/
│       ├── blueprints/              # Meta standards (templates)
│       └── standards/               # General coding standards
│
└── en/                              # English documentation
    └── [same structure, same file names]
```
> **Convention:** All folder names are lowercase.  
> See [Doc.md § 8.8](Doc.md#88-folder-name-convention)
---

## 4. Usage vs. Development

### 4.1 Distinction

| Aspect | Usage | Development |
|--------|------------|------------|
| **Target audience** | C++ developers who use the build system | Build system developers |
| **Question** | "How do I add an external?" | "How do I implement phase 8?" |
| **Stability** | Stable, public API | May change, internal |
| **Folders** | `guide/` (`userguides/`, `references/`, `cheatsheets/`, `module/`) | `konzepte/` |

`autorenwerk/` sits across both: blueprints and coding standards apply across projects and belong
neither to the usage nor to the development of the build system.

### 4.2 Scenarios

**Usage scenarios:**

```
"How do I configure Qt6?"
→ guide/userguides/Qt6_Integration.md

"What does error E0501 mean?"
→ guide/references/ErrorCodes.md

"Which fields does Solution.json have?"
→ guide/references/Solution_Schema.md

"How does Fetch.cmake work?"
→ guide/module/externals/core/Fetch_cmake.md
```

**Development scenarios:**

```
"How is the build system structured architecturally?"
→ konzepte/abgeschlossen/Master_Concept.md

"What are the conventions for CMake modules?"
→ konzepte/Guidelines.md

"What did we learn in the last session?"
→ docs/report/SESSION_REPORT_YYYY-MM-DD.md
```

---

## 5. Folder Definitions

### 5.1 autorenwerk/blueprints/

| Property | Value |
|-------------|------|
| **Content** | Meta standards for documentation types |
| **Target audience** | Documentation authors |
| **Examples** | Doc.md, CMake.md, Concept.md |

### 5.2 autorenwerk/standards/

| Property | Value |
|-------------|------|
| **Content** | General coding/project standards |
| **Target audience** | All developers |
| **Examples** | Cpp_Coding_Standard.md, Git_Standard.md, Doku_Standard.md |

**Important:** Only *general* standards that apply across projects live here. The conventions of the build system itself are in `konzepte/Guidelines.md`.

### 5.3 guide/module/

| Property | Value |
|-------------|------|
| **Content** | API documentation of the CMake modules |
| **Target audience** | Build system users and developers |
| **Type** | ModuleDoc |

**Substructure** (mirrors `cmake/`):

```
guide/module/
├── core/                    # Core modules
│   ├── Errors.md
│   ├── Debug.md
│   ├── Context.md
│   └── ...
├── project/                 # Project modules
│   ├── Solution.md
│   ├── Executables.md
│   └── Libraries.md
├── externals/               # External modules
│   ├── Orchestrator_cmake.md
│   ├── core/Fetch_cmake.md
│   ├── hooks/               # Hook documentation (prefetch/, postfetch/)
│   └── locals/              # Local externals
└── buildSystemTest/         # Phase tests
```

### 5.4 guide/references/

| Property | Value |
|-------------|------|
| **Content** | Reference works, schemas, lists |
| **Target audience** | All developers |
| **Type** | Reference |
| **Examples** | Solution_Schema.md, ErrorCodes.md, Glossar.md, Externals.md |

### 5.5 guide/userguides/

| Property | Value |
|-------------|------|
| **Content** | How-to guides for concrete tasks, getting started for new users |
| **Target audience** | Build system users, beginners |
| **Type** | Guide, Tutorial |
| **Examples** | Adding_Externals.md, Testing.md, Getting_Started.md |

Tutorials have no folder of their own; they live with the guides.

### 5.6 guide/cheatsheets/

| Property | Value |
|-------------|------|
| **Content** | One-page quick references |
| **Target audience** | Build system users |
| **Type** | Cheatsheet |
| **Examples** | Solution_Cheatsheet.md |

---

## 6. Concepts and Reports

### 6.1 Structure

```
docs/
├── de/konzepte/                 # Development of the build system
│   ├── Guidelines.md            # Conventions for build system code
│   ├── Future_Enhancements.md   # Collection of planned features
│   ├── Konzept_Versionierter_Bezug.md
│   └── abgeschlossen/           # Implemented concepts
│       ├── Master_Concept.md
│       ├── Implementation_Plan.md
│       ├── AppContainer_Concept.md
│       └── System_Externals_Concept.md
└── report/                      # Reports (no language tree)
    └── SESSION_REPORT_YYYY-MM-DD.md
```

### 6.2 konzepte/

| Property | Value |
|-------------|------|
| **Content** | Architecture decisions, design concepts |
| **Target audience** | Build system developers |
| **Type** | Concept |
| **Lifecycle** | Draft → review → implementation → `abgeschlossen/` |

**Special documents:**

| Document | Description |
|----------|--------------|
| `abgeschlossen/Master_Concept.md` | Overall architecture, all phases |
| `abgeschlossen/Implementation_Plan.md` | Detailed implementation plan |
| `Future_Enhancements.md` | Collection of planned features |

Completed concepts are documents of their time: they are not rewritten, but given a note on the
current state where needed.

### 6.3 konzepte/Guidelines.md

| Property | Value |
|-------------|------|
| **Content** | Project-specific conventions |
| **Target audience** | Build system developers |
| **Type** | Standard |

**Delimitation from `autorenwerk/standards/`:**

| Location | Content | Example |
|----------|---------|---------|
| `docs/de/autorenwerk/standards/` | General standards | "How do you write C++?" |
| `docs/de/konzepte/Guidelines.md` | Project-specific | "Naming conventions for CMake modules in the build system" |

### 6.4 report/

| Property | Value |
|-------------|------|
| **Content** | Session reports, findings lists, reviews |
| **Target audience** | Build system developers |
| **Type** | Report |

**Typical content:**

- `SESSION_REPORT_YYYY-MM-DD.md` — report of a working session
- `Doku_Befunde_YYYY-MM-DD.md` — findings list of a documentation review

`report/` sits next to `de/` and `en/` and is not translated.

---

## 7. Decision Tree

### 7.1 Where Does My Document Belong?

```
START: What am I documenting?
│
├─► "How do you write documentation?"
│   └─► autorenwerk/blueprints/
│
├─► "How do you write C++/CMake/Git in general?"
│   └─► autorenwerk/standards/
│
├─► "How does a CMake module work?"
│   └─► guide/module/
│
├─► "What does X mean? Schema/list/API?"
│   └─► guide/references/
│
├─► "How do I do X with the build system?"
│   └─► guide/userguides/
│
├─► "First steps for beginners?"
│   └─► guide/userguides/
│
├─► "One-page quick reference?"
│   └─► guide/cheatsheets/
│
└─► "Development of the build system itself?"
    │
    ├─► "Architecture/design decision?"
    │   └─► konzepte/
    │
    ├─► "Project-specific convention?"
    │   └─► konzepte/Guidelines.md
    │
    └─► "Session report/review/findings?"
        └─► docs/report/
```

### 7.2 Quick Reference

| I am documenting... | Folder |
|---------------------|--------|
| Meta standard for documentation types | `autorenwerk/blueprints/` |
| General coding standard | `autorenwerk/standards/` |
| CMake module API | `guide/module/` |
| Schema, error codes, glossary | `guide/references/` |
| How-to for users | `guide/userguides/` |
| Beginner tutorial | `guide/userguides/` |
| Quick reference | `guide/cheatsheets/` |
| Architecture concept | `konzepte/` |
| Build system conventions | `konzepte/Guidelines.md` |
| Session report | `docs/report/` |

---

## 8. Examples

### 8.1 Example: Documenting a New External Integration

**Question:** "I have integrated GLFW. Where do I document it?"

| Aspect | Folder | Document |
|--------|--------|----------|
| How do you use GLFW? | `guide/userguides/externals/` | `Glfw.md` |
| GLFW in the externals list | `guide/references/` | `Externals.md` (extend) |
| Hook documentation | `guide/module/externals/hooks/prefetch/` | `Glfw.md` |

### 8.2 Example: Implementing a New Phase

**Question:** "I am planning phase 8 (AppContainer). Where do I document it?"

| Aspect | Folder | Document |
|--------|--------|----------|
| Concept/design | `konzepte/` | `AppContainer_Concept.md` |
| Link in the master concept | `konzepte/abgeschlossen/` | `Master_Concept.md` (extend) |
| After implementation | `guide/module/project/` | `Apps.md` |
| User guide | `guide/userguides/` | `App_Creation_Guide.md` |

### 8.3 Example: Adding an Error Code

**Question:** "I have defined new error codes E250-E259. Where do I document them?"

| Aspect | Folder | Document |
|--------|--------|----------|
| Error code list | `guide/references/` | `ErrorCodes.md` (extend) |

---

## 9. See Also

- [Doc.md](Doc.md) — How do you write documentation?
- [Blueprint.md](Blueprint.md) — Meta blueprint
- [Concept.md](Concept.md) — Standard for architecture concepts
- [Doku_Standard.md](../standards/Doku_Standard.md) — Languages, versioning, filing rules

---

## Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: folder tree, scenarios, decision tree and examples switched to today's structure `guide/{userguides,references,cheatsheets,module}`, `konzepte/`, `autorenwerk/{blueprints,standards}`, `docs/report/`; §6 is now "Concepts and Reports"** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| **0.5.1** | **2025-12-15** | **Reference to the folder name convention (Doc.md § 8.8)** |
| **0.5.0** | **2025-12-13** | **Initial: folder structure, usage vs. development, decision tree** |
