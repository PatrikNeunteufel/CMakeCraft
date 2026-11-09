# Doc — Standard for All Documentation

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Blueprint  
> **Status:** In Development  
> **Based on:** Blueprint v0.5  
> **Target Audience:** Documentation authors  
> **Language:** English  
> **German:** [Doc.md](../../../de/autorenwerk/blueprints/Doc.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Scope](#2-scope)
3. [Documentation Types](#3-documentation-types)
4. [Header Structure](#4-header-structure)
5. [Table of Contents](#5-table-of-contents)
6. [Chapter Numbering](#6-chapter-numbering)
7. [Anchor Conventions](#7-anchor-conventions)
8. [File Name Conventions](#8-file-name-conventions)
9. [Language and Translation](#9-language-and-translation)
10. [Formatting Rules](#10-formatting-rules)
11. [Changelog Format](#11-changelog-format)
12. [Review Checklist](#12-review-checklist)
13. [See Also](#13-see-also)
14. [Changelog](#changelog)

---

## 1. Overview

This blueprint defines **binding rules for all documentation** in the CMake Architecture project. It serves as the basis for specialized blueprints (ModuleDoc, Guide, Reference, etc.).

### Target Audience

- Everyone who creates or maintains documentation
- Specialized blueprints that inherit from this one

### What This Blueprint Governs

| Area | Rules |
|---------|--------|
| Header | Required fields, format, order |
| TOC | Numbering, anchors, placement |
| Language | German/English, folder structure |
| Format | Headings, tables, code blocks |

---

## 2. Scope

This blueprint applies to **all** Markdown documentation:

| Type | Examples | Specialized blueprint |
|-----|-----------|---------------------------|
| CMake modules | Context.cmake docs | ModuleDoc.md |
| User guides | Qt6 integration | Guide.md |
| References | Solution_Schema | Reference.md |
| Concepts | AppContainer | Concept.md |
| Standards | Cpp_Coding_Standard | Standard.md |
| Tutorials | CreateFirstApp | Tutorial.md |

---

## 3. Documentation Types

### 3.1 Overview

| Type | Target audience | Focus |
|-----|------------|-------|
| **ModuleDoc** | Build system developers | How does the module work? |
| **Guide** | C++ developers (end users) | How do I use the system? |
| **Reference** | All developers | Lookup, API |
| **Concept** | Build system developers | Architecture, design |
| **Standard** | All developers | Coding conventions |
| **Tutorial** | Beginners | Step-by-step instructions |

### 3.2 Which Type When?

```
"How do I configure Qt6?"            → Guide
"What does error E0501 mean?"        → Reference
"How does Context.cmake work?"       → ModuleDoc
"Why do we use GLOBAL PROPERTY?"     → Concept
"How do I name variables?"           → Standard
"Create your first executable"       → Tutorial
```

---

## 4. Header Structure

### 4.1 Base Header (All Documentation)

Every document **MUST** start with this header:

```markdown
# [Title]

> **Version:** X.Y.Z  
> **Date:** YYYY-MM-DD  
> **Type:** [ModuleDoc | Guide | Reference | Concept | Standard | Tutorial]  
> **Status:** [In Development | Stable | Deprecated]  
> **Target Audience:** [Who should read this document?]  
> **Language:** English  
> **German:** [FileName.md](../../../de/[area]/[folder]/FileName.md)
```

### 4.2 Header Fields

| Field | Required | Format | Example |
|------|---------|--------|----------|
| **Version** | ✓ | SemVer | `1.2.3` |
| **Date** | ✓ | ISO 8601 | `2025-12-13` |
| **Type** | ✓ | Predefined | `Guide` |
| **Status** | ✓ | Predefined | `Stable` |
| **Target Audience** | ✓ | Short description | `C++ developers` |
| **Language** | ✓ | Predefined | `English` |
| **German** (in German documents: **English**) | ✓ | Relative path | `../../../de/<area>/<folder>/<FileName>.md` (depth see § 4.5) |
| **Based on** | Optional | Name + version | `Doc v0.5` |

### 4.3 Target Audience — Values and Explanation

The target audience in the header is a **short form**. It can be described in more detail in the first section (Overview).

**Typical target audiences:**

| Short form | Description |
|----------|--------------|
| `Build system developers` | Develops/extends the CMake system itself |
| `C++ developers` | Uses the build system for their own projects |
| `All developers` | Both build system and C++ developers |
| `Documentation authors` | Writes/maintains documentation |
| `New team members` | Onboarding, getting started with the project |
| `Architects` | Technical decision makers |

### 4.4 Extended Header Fields

Specialized blueprints define additional fields:

| Blueprint | Additional fields |
|-----------|-------------------|
| ModuleDoc | `Module:`, `Module Version:` |
| Guide | `Module:` (optional) |
| Reference | — |
| Concept | — |
| Standard | `Scope:` |

### 4.5 English Link Format

In German documents, the link to the English version follows the pattern:

```markdown
> **English:** [FileName.md](../../../en/[area]/[folder]/FileName.md)
```

The path leads back via `docs/`: one `../` per folder level below `de/`, plus one for `de/` itself.

| Folder in German | Folder in English | Jump path |
|---------------------|---------------------|-----------|
| `de/konzepte/` | `en/konzepte/` | `../../en/` |
| `de/guide/userguides/` | `en/guide/userguides/` | `../../../en/` |
| `de/autorenwerk/blueprints/` | `en/autorenwerk/blueprints/` | `../../../en/` |
| `de/guide/module/core/` | `en/guide/module/core/` | `../../../../en/` |

**Important:** A file has the **same name** in both language folders; the name may be German (see [Language_Standard.md](../standards/Language_Standard.md) §4.3).

---

## 5. Table of Contents

### 5.1 Requirement

**Every document MUST have a table of contents.**

### 5.2 Placement

The table of contents comes **directly after the header**, separated by a horizontal rule:

```markdown
> **German:** [...]

---

## Table of Contents

1. [Overview](#1-overview)
2. [Installation](#2-installation)
...

---

## 1. Overview
```

### 5.3 Format

- Numbered list (1., 2., 3., ...)
- Each entry is a link to the anchor
- The heading is always `## Table of Contents` (not numbered)

### 5.4 Example

```markdown
## Table of Contents

1. [Overview](#1-overview)
2. [Installation](#2-installation)
   - [Windows](#21-windows)
   - [Linux](#22-linux)
3. [Configuration](#3-configuration)
4. [Troubleshooting](#4-troubleshooting)
5. [Changelog](#changelog)
```

---

## 6. Chapter Numbering

### 6.1 Scheme

All H2 headings (`##`) are numbered:

```markdown
## 1. Overview
## 2. Installation  
## 3. Configuration
```

### 6.2 Subsections

H3 headings (`###`) get nested numbering:

```markdown
## 2. Installation

### 2.1 Windows

### 2.2 Linux

#### 2.2.1 Ubuntu
```

### 6.3 Exceptions

**Not numbered** are:
- `## Table of Contents`
- `## Changelog`
- `## See Also`

---

## 7. Anchor Conventions

### 7.1 Automatic Anchors

GitHub/GitLab generate anchors automatically:

| Heading | Generated anchor |
|-------------|-------------------|
| `## 1. Overview` | `#1-overview` |
| `### 2.1 Windows` | `#21-windows` |
| `## Troubleshooting` | `#troubleshooting` |

### 7.2 Rules

1. **Lowercase:** Everything in lowercase
2. **Hyphens:** Spaces become `-`
3. **Umlauts:** Are preserved (ü, ä, ö)
4. **Special characters:** Periods and colons are removed
5. **Numbers:** Are preserved

### 7.3 Examples

| Heading | Anchor |
|-------------|-------|
| `## 1. Overview` | `#1-overview` |
| `### 2.1 Windows-Installation` | `#21-windows-installation` |
| `## What is Solution.json?` | `#what-is-solutionjson` |
| `## API-Reference` | `#api-reference` |

### 7.4 Testing

Test anchors before committing:
1. Render the Markdown locally (VS Code Preview)
2. Click the links in the table of contents
3. All links must work

---

## 8. File Name Conventions

### 8.1 Basic Principle: Version in the Header, Not in the File Name

> **Important:** Current documents have **no version in the file name**.  
> The version is only in the header. This way, links do not have to be adjusted on version updates.

| File kind | File name | Version |
|-----------|-----------|---------|
| **Current** | `Doc.md` | In the header: `> **Version:** 1.0.0` |
| **Earlier version** | — (no copy) | In the Git history |

### 8.2 General Rules

| Rule | Correct | Wrong |
|-------|---------|--------|
| Same name in all language folders | `de/…/Getting_Started.md` and `en/…/Getting_Started.md` | `de/…/Erste_Schritte.md` next to `en/…/Getting_Started.md` |
| No version (current) | `Doc.md` | `Doc_v0_5_0.md` |
| A compound term is written together, several terms are separated by an underscore | `ErrorCodes.md`, `Getting_Started.md` | `Error Codes.md` |
| No spaces | `ErrorCodes.md` | `Error Codes.md` |
| **Capital letter at the start** | `Context.md` | `context.md` |
| **CamelCase for compounds** | `Solution_Schema.md` | `solution_schema.md` |
| **Separate words with underscore** | `Getting_Started.md` | `GettingStarted.md` |

**File name summary:**

- First letter **capitalized**
- Words separated by **underscore** (`_`)
- Each word starts with a **capital letter** (Title_Case)
- Extension `.md` in lowercase

**Examples:**

| Type | Example |
|-----|----------|
| Blueprint | `Doc.md`, `CMake.md` |
| ModuleDoc | `Context.md`, `Errors.md` |
| Guide | `Qt6_Integration.md`, `Getting_Started.md` |
| Reference | `Solution_Schema.md`, `ErrorCodes.md` |
| Concept | `AppContainer_Concept.md` |

### 8.3 Current Files (Without Version)

| Type | Pattern | Example |
|-----|--------|----------|
| Blueprint | `[Name].md` | `Doc.md`, `CMake.md` |
| ModuleDoc | `[Module].md` | `Context.md`, `Errors.md` |
| Guide | `[Name].md` | `Qt6_Integration.md`, `Testing.md` |
| Reference | `[Name].md` | `Solution_Schema.md`, `ErrorCodes.md` |
| Concept | `[Name]_Concept.md` | `AppContainer_Concept.md` |
| Standard | `[Name]_Standard.md` | `Cpp_Coding_Standard.md` |

### 8.4 Earlier Versions (No Copies)

There are **no version copies** of a file — **Git is the history** (see [Doku_Standard.md § 5](../standards/Doku_Standard.md#5-filing-rules-short-form)). An earlier version is retrieved from Git:

```bash
git log --oneline -- docs/de/autorenwerk/blueprints/Doc.md   # find versions
git show <commit>:docs/de/autorenwerk/blueprints/Doc.md        # show a version
```

### 8.5 No Version in the File Name

| Rule | Correct | Wrong |
|-------|---------|--------|
| No version number | `Doc.md` | `Doc_v0_5_0.md` |
| No version number | `Context.md` | `Context_doc_v1.md` |
| No copy with a short tag | `Doc.md` | `Doc050.md` |

### 8.6 Workflow on Updates

1. Change the file in place, adjust **version + date** in the header, add a changelog entry.
2. Links remain unchanged, because the file name does not change.
3. The en version adopts the same version (see [Doku_Standard.md](../standards/Doku_Standard.md)).

### 8.7 Advantages

| Advantage | Description |
|---------|--------------|
| **Stable links** | URLs do not change on updates |
| **Easier maintenance** | No link updates in other documents |
| **Clear currency** | There is only one file — the current one |
| **Historical versions** | Available in the Git history when needed |

### 8.8 Folder Name Convention

Folder names are **always lowercase**.

| Rule | Correct | Wrong |
|-------|---------|--------|
| Lowercase | `module/` | `Module/` |
| Lowercase | `blueprints/` | `Blueprints/` |
| Lowercase | `hooks/prefetch/` | `Hooks/PreFetch/` |
| snake_case if needed | `user_guides/` | `UserGuides/` |

**Rationale:**

| Reason | Description |
|-------|--------------|
| **Cross-platform** | Linux is case-sensitive, Windows is not — lowercase avoids problems |
| **Consistency** | Uniform is easier to remember |
| **URLs** | Web URLs are typically lowercase |
| **Git** | No case conflicts on renames |

**Examples:**

```markdown
docs/
├── de/
│   ├── autorenwerk/
│   │   └── blueprints/    ✓ (not: Blueprints/)
│   └── guide/
│       ├── module/
│       │   ├── core/      ✓ (not: Core/)
│       │   └── externals/
│       └── references/
cmake/
└── externals/
    ├── includes/          ✓ (not: Includes/)
    └── hooks/
        ├── prefetch/      ✓ (not: PreFetch/)
        └── postfetch/     ✓ (not: PostFetch/)
```

### 8.9 Exception: Project Folders

**Project folders** follow the **target name**, not lowercase:

| Rule | Example | Rationale |
|-------|----------|------------|
| Folder name = target name | `projects/apps/DemoPlayer/` | Consistency between folder and CMake target |
| Folder name = target name | `projects/demos/exec/MinimalConsole/` | IDE navigation, mapping |
| Folder name = target name | `projects/demos/libs/BasicLogger/` | Clear 1:1 relationship |

**Affected paths:**
```
projects/
├── apps/
│   └── DemoPlayer/        ← Target: DemoPlayer, DemoPlayer.Core
├── demos/
│   ├── exec/
│   │   └── MinimalConsole/    ← Target: MinimalConsole
│   └── libs/
│       └── BasicLogger/       ← Target: BasicLogger
└── tests/
    └── unit/
        └── BasicLogger_Tests/ ← Target: BasicLogger_Tests
```

**Not affected** (still lowercase):

- `projects/` itself
- Type subfolders: `apps/`, `demos/`, `exec/`, `libs/`, `tests/`
- All system folders: `cmake/`, `docs/`, `externals/`

---

## 9. Language and Translation

### 9.1 Folder Structure

```
docs/
├── de/                    ← German documentation
│   ├── guide/
│   ├── konzepte/
│   └── autorenwerk/
│
└── en/                    ← English documentation
    ├── guide/
    ├── konzepte/
    └── autorenwerk/
```

### 9.2 Primary Language

- **German** is the primary language (the developers are German-speaking)
- English versions are translations

### 9.3 File Names

A file has the **same name** in both language folders. The name may be German (`Neues_Projekt_Guide.md`, `Glossar.md`); the English tree keeps it unchanged:

```
de/guide/userguides/Qt6_Integration.md   ← content in German
en/guide/userguides/Qt6_Integration.md   ← content in English
```

**Note:** No version in the file name (see section 8).

### 9.4 Cross-References

- Within the same language: relative path
- To the other language: back up to `docs/`, then `en/` or `de/` — for `de/guide/userguides/` that is `../../../en/` (depth see § 4.5)

---

## 10. Formatting Rules

### 10.1 Headings

```markdown
# Main title (H1) — only once per document

## Numbered section (H2)

### Subsection (H3)

#### Detail (H4) — use sparingly
```

### 10.2 Horizontal Rules

**Before every H2 section** (`##`):

```markdown
---

## 2. Installation
```

### 10.3 Tables

With header row and alignment:

```markdown
| Column 1 | Column 2 | Description |
|----------|----------|--------------|
| Value 1  | Value 2  | Text         |
```

### 10.4 Code Blocks

With language annotation:

````markdown
```cmake
function(my_function)
endfunction()
```

```json
{ "key": "value" }
```
````

### 10.5 Emphasis

| Element | Usage |
|---------|------------|
| **Bold** | Important terms |
| `Code` | Variables, functions, paths |
| *Italic* | Quotations, technical terms (rarely) |
| ~~Strikethrough~~ | Deprecated |
| > Blockquote | Notes, warnings |

### 10.6 Notes

```markdown
> **Note:** General information

> **Important:** Critical information  

> **Warning:** Potential problems

> **DEPRECATED since vX.Y:** With migration note
```

---

## 11. Changelog Format

### 11.1 Position

The changelog is **always at the end** of the document.

### 11.2 Format

```markdown
---

## Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **X.Y.Z** | **YYYY-MM-DD** | **Current change (bold)** |
| X.Y.Z-1 | YYYY-MM-DD | Previous change |
| 0.1.0 | YYYY-MM-DD | Initial |
```

### 11.3 Rules

- Newest version first
- Current version in **bold**
- Short, concise descriptions
- Mark breaking changes with ⚠️
- Every change is a new entry with a higher number; `Version` and `Date` in the header are those of the newest
  entry. If the change comes with a CMakeCraft version, the entry names it (`CMakeCraft v0.14.1: …`). The
  CMakeCraft version is not in the header. Rules: [Doku_Standard.md](../standards/Doku_Standard.md) §2

---

## 12. Review Checklist

Check before finishing a document:

**Header:**
- [ ] All required fields present
- [ ] Version and date current
- [ ] Type correct
- [ ] Target audience given
- [ ] Language link present and correct

**Table of contents:**
- [ ] Present and complete
- [ ] Numbering correct
- [ ] All anchors work

**Structure:**
- [ ] Chapters numbered (except TOC, Changelog, See Also)
- [ ] Horizontal rules before H2
- [ ] Changelog at the end

**Content:**
- [ ] Target audience detailed in the overview (if needed)
- [ ] Code examples tested
- [ ] No TODO/FIXME left
- [ ] Consistent terminology
- [ ] Cross-references with versions

**File:**
- [ ] File name follows the convention
- [ ] In the right folder

---

## 13. See Also

- [Blueprint.md](Blueprint.md) — Meta-blueprint
- [ModuleDoc.md](ModuleDoc.md) — CMake module documentation
- [Guide.md](Guide.md) — User guides
- [Reference.md](Reference.md) — API/schema references

---

## Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: jump path to the other language per today's depth (`../../../en/` for `de/<area>/<folder>/`, § 4.1, § 4.5, § 9.4); duplicate section 4.3 resolved (Extended Header Fields → 4.4, English Link Format → 4.5); no version copies anymore, Git is the history (§ 8.1, § 8.4–8.7); folder and file examples switched to `guide/`, `konzepte/`, `autorenwerk/` and `projects/demos/` (§ 8.2, § 8.3, § 8.8, § 8.9, § 9.1, § 9.3); same file names in both language folders, German names allowed (decision S1 a, § 4.5, § 8.2, § 9.3); rule for compound terms instead of "underscores as separators" (decision N1 a, § 8.2); § 11.3 version rules (decisions K1/K2 a)** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.2 | 2025-12-17 | Additional article on folder names for projects under § 8.9 |
| 0.5.1 | 2025-12-15 | Explicit file name convention (§ 8.2): Title_Case. New folder name convention (§ 8.8): always lowercase |
| 0.5.0 | 2025-12-13 | New: mandatory table of contents with anchors, target audience required field in the header, English link in the header, chapter numbering, anchor conventions |
| 0.1.0 | 2025-12-03 | Initial (as Documentation_Blueprint) |
