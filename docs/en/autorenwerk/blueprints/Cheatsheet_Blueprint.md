# Blueprint: Cheatsheet

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Blueprint  
> **Status:** Stable  
> **Target Audience:** Documentation authors  
> **Language:** English  
> **German:** [Cheatsheet_Blueprint.md](../../../de/autorenwerk/blueprints/Cheatsheet_Blueprint.md)

---

## 1. Overview

This blueprint defines the format for **cheatsheets** — compact quick references for frequently needed information.

### 1.1 Properties

| Property | Value |
|-------------|------|
| Target length | 1-2 pages (printed) |
| Primary format | Tables, code snippets |
| Running text | Minimal |
| Target audience | Developers with basic knowledge |

### 1.2 When to Use a Cheatsheet?

| Situation | Cheatsheet? | Alternative |
|-----------|-------------|-------------|
| Quick reference for commands | ✅ Yes | — |
| Short API overview | ✅ Yes | — |
| Syntax reference | ✅ Yes | — |
| Explaining a concept | ❌ No | Concept |
| Step-by-step instructions | ❌ No | UserGuide |
| Complete specification | ❌ No | Reference |

---

## 2. Template

### 2.1 Header

```markdown
# {Topic} — Cheatsheet

> **Version:** X.Y.Z  
> **Last Updated:** YYYY-MM-DD  
> **For:** {Product/Tool} vX.Y  
> **Language:** English  
> **German:** [{Topic}_Cheatsheet.md](path/to/german)

---
```

### 2.2 Structure

````markdown
## Quick Start

{2-3 lines: most important info right away}

---

## {Category 1}

| {Column A} | {Column B} | {Column C} |
|------------|------------|------------|
| ... | ... | ... |

---

## {Category 2}

### {Subcategory}

```{language}
{code snippet}
```

---

## Tips & Tricks

- **Tip 1:** ...
- **Tip 2:** ...

---

## See Also

- [Link 1](path) — Description
- [Link 2](path) — Description
````

---

## 3. Formatting Rules

### 3.1 Tables

Tables are the main element of a cheatsheet.

| Rule | Example |
|-------|----------|
| Short cells | `name` instead of `The name of the element` |
| Code in backticks | `cmake_fatal()` |
| No sentences | Keywords |
| Max 4-5 columns | Readability |

**Good:**

| Command | Effect |
|--------|---------|
| `git add .` | Stage all changes |
| `git commit -m "msg"` | Create commit |

**Bad:**

| Command | Description of what this command does |
|--------|--------------------------------------|
| `git add .` | This command adds all changed files to the staging area |

### 3.2 Code Snippets

- **Keep them short** (max 5-10 lines)
- **Comments** only where necessary
- **Syntax highlighting** always specified

```cmake
# Good: short and concise
cmake_fatal("E001" "Description")
cmake_warn("W001" "Description")
```

```cmake
# Bad: too verbose for a cheatsheet
# This function is used to raise a fatal error
# Parameter 1: The error code in the format EXXX
# Parameter 2: The description of the error
function(cmake_fatal ERROR_CODE DESCRIPTION)
    message(FATAL_ERROR "[${ERROR_CODE}] ${DESCRIPTION}")
endfunction()
```

### 3.3 Categories

- **Group logically** (not alphabetically)
- **Most important first**
- **Max 6-8 categories**
- **Horizontal rules** (`---`) between categories

### 3.4 Visual Markers

| Marker | Usage |
|--------|------------|
| ✅ | Recommended, success |
| ❌ | Not recommended, error |
| ⚠️ | Warning, caution |
| 💡 | Tip |
| 📌 | Important/remember |
| → | Result, leads to |

---

## 4. Example: Complete Cheatsheet

````markdown
# Git — Cheatsheet

> **Version:** 1.0.0  
> **Last Updated:** 2025-12-18  
> **For:** Git 2.x  

---

## Quick Start

```bash
git clone <url>      # Clone repository
git add . && git commit -m "msg" && git push   # Push changes
```

---

## Basic Commands

| Command | Effect |
|--------|---------|
| `git init` | New repository |
| `git clone <url>` | Clone repository |
| `git status` | Show status |
| `git log --oneline` | Compact history |

---

## Changes

| Command | Effect |
|--------|---------|
| `git add <file>` | Stage file |
| `git add .` | Stage everything |
| `git commit -m "msg"` | Commit |
| `git commit --amend` | Amend last commit |

---

## Branches

| Command | Effect |
|--------|---------|
| `git branch` | List branches |
| `git branch <name>` | Create branch |
| `git checkout <name>` | Switch branch |
| `git checkout -b <name>` | Create + switch |
| `git merge <branch>` | Merge branch |

---

## Remote

| Command | Effect |
|--------|---------|
| `git push` | Upload changes |
| `git pull` | Fetch + merge changes |
| `git fetch` | Fetch changes (without merge) |

---

## Undo

| Situation | Command |
|-----------|--------|
| Discard unstaged changes | `git checkout -- <file>` |
| Staged → unstaged | `git reset HEAD <file>` |
| Undo last commit | `git reset --soft HEAD~1` |
| ⚠️ Delete commit | `git reset --hard HEAD~1` |

---

## Tips

- 💡 `git stash` → Save changes temporarily
- 💡 `git diff --staged` → Show staged changes
- 📌 Always run `git stash` before `--hard`!

---

## See Also

- [Git Documentation](https://git-scm.com/doc)
- [Pro Git Book](https://git-scm.com/book)
````

---

## 5. Anti-Patterns

### 5.1 Too Much Text

❌ **Bad:**

```markdown
## Introduction

Git is a distributed version control system developed by 
Linus Torvalds. It enables several developers to collaborate 
on a project and to track all changes...
```

✅ **Good:**

```markdown
## Quick Start

`git clone` → `git add` → `git commit` → `git push`
```

### 5.2 Too Many Details

❌ **Bad:**

| Flag | Long form | Description | Default | Since version |
|------|----------|--------------|---------|--------------|
| `-m` | `--message` | Commit message | — | 1.0 |

✅ **Good:**

| Command | Effect |
|--------|---------|
| `git commit -m "msg"` | Commit with message |

### 5.3 Alphabetical Sorting

❌ **Bad:** `add`, `branch`, `checkout`, `clone`, `commit`...

✅ **Good:** By workflow: `clone` → `add` → `commit` → `push`

---

## 6. Checklist

Check before publishing:

- [ ] Fits on 1-2 pages (printed)?
- [ ] Most important first?
- [ ] Tables instead of running text?
- [ ] Code snippets short (< 10 lines)?
- [ ] Categories grouped logically?
- [ ] No explanations, only facts?
- [ ] Visual markers used sparingly?
- [ ] See-also links present?

---

## 7. See Also

- [Concept.md](Concept.md) — For explanations
- [Reference.md](Reference.md) — For complete specifications
- [Guide.md](Guide.md) — For step-by-step instructions

---

## 8. Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.1.0 | 2025-12-18 | Initial: Cheatsheet blueprint created |
