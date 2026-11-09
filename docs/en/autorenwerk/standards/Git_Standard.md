# Git Standard — Version Control Guidelines

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Standard  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Scope:** All Git repositories in the company  
> **Enforcement:** Pre-commit hooks, code review  
> **Language:** English  
> **German:** [Git_Standard.md](../../../de/autorenwerk/standards/Git_Standard.md)

---

## Table of Contents

1. [Purpose and Scope](#1-purpose-and-scope)
2. [Language Guidelines](#2-language-guidelines)
3. [Commit Message Format](#3-commit-message-format)
4. [Branch Strategy](#4-branch-strategy)
5. [Tags and Releases](#5-tags-and-releases)
6. [Release Notes](#6-release-notes)
7. [.gitignore Best Practices](#7-gitignore-best-practices)
8. [Git Configuration](#8-git-configuration)
9. [Merge Strategies](#9-merge-strategies)
10. [Checklist Before Commit](#10-checklist-before-commit)
11. [Checklist Before Release](#11-checklist-before-release)
12. [See Also](#12-see-also)
13. [Changelog](#changelog)

---

## 1. Purpose and Scope

This standard defines **conventions for Git version control**:

- Commit message format
- Branch strategy
- Tag/release conventions
- Language guidelines

### Target Audience

All developers who work with Git repositories. This standard is mandatory for all repositories in the company.

---

## 2. Language Guidelines

### 2.1 Overview

| Artifact | Language | Rationale |
|----------|----------|-----------|
| Commit messages | **English** | Technical code context |
| Branch names | **English** | Technical identifiers |
| Tag names | **English** | Technical identifiers |
| Release notes | **English** | For releases/publication |
| PR/MR title | **English** | Consistency with commits |
| PR/MR description | German or English | Team preference |

### 2.2 Rationale

- Git history is technical context (like code comments)
- Releases are potentially public → English
- Internal discussions may be in German

---

## 3. Commit Message Format

### 3.1 Structure

```
<type>(<scope>): <subject>

[body]

[footer]
```

### 3.2 Type (Mandatory)

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(audio): add volume control` |
| `fix` | Bug fix | `fix(parser): handle empty input` |
| `refactor` | Code restructuring (no functional change) | `refactor(core): extract helper class` |
| `perf` | Performance improvement | `perf(render): optimize draw calls` |
| `docs` | Documentation | `docs(readme): update install instructions` |
| `test` | Add/change tests | `test(api): add integration tests` |
| `build` | Build system, dependencies | `build(cmake): upgrade to CMake 3.24` |
| `ci` | CI/CD configuration | `ci(github): add clang-tidy workflow` |
| `style` | Formatting (no code change) | `style: apply clang-format` |
| `chore` | Maintenance, cleanup | `chore: remove deprecated files` |
| `revert` | Revert a commit | `revert: feat(audio): add volume control` |
| `wip` | Work in progress (local branches only) | `wip: experimental feature` |

### 3.3 Scope (Optional)

The scope describes the affected area:

| Scope Type | Examples |
|------------|----------|
| Module/component | `audio`, `renderer`, `parser` |
| Layer | `core`, `api`, `ui` |
| File/area | `cmake`, `config`, `tests` |

### 3.4 Subject (Mandatory)

| Rule | Description |
|------|-------------|
| Imperative | "add feature" not "added feature" |
| Lowercase | No capital letter at the beginning |
| No period | No `.` at the end |
| Max. 50 characters | Short and concise |

### 3.5 Body (Optional)

- Blank line after the subject
- Explains **what** and **why** (not how)
- Max. 72 characters per line
- May have several paragraphs

### 3.6 Footer (Optional)

| Footer | Usage |
|--------|-------|
| `Fixes #123` | Close an issue |
| `Closes #456` | Close an issue |
| `Refs #789` | Reference an issue |
| `BREAKING CHANGE:` | Document a breaking change |
| `Co-authored-by:` | Name a co-author |

### 3.7 Examples

**Minimal:**
```
fix(parser): handle null pointer in parse()
```

**With body:**
```
feat(audio): add real-time spectrum analyzer

Implement FFT-based spectrum analysis for audio visualization.
Uses FFTW library for efficient computation.

The analyzer supports configurable bin counts and window functions.
```

**With breaking change:**
```
refactor(api)!: change return type of process()

BREAKING CHANGE: process() now returns std::optional<Result>
instead of Result*. Callers must handle the optional.

Migration: Replace nullptr checks with has_value() checks.
```

**Bug fix with issue reference:**
```
fix(config): prevent crash on invalid JSON

Handle malformed JSON gracefully instead of throwing
unhandled exception.

Fixes #142
```

---

## 4. Branch Strategy

### 4.1 Branch Types

| Branch | Pattern | Long-lived | Description |
|--------|---------|------------|-------------|
| `main` | `main` | ✅ | Stable release state |
| `develop` | `develop` | ✅ | Development integration |
| Feature | `feature/<name>` | ❌ | New feature |
| Bugfix | `fix/<name>` | ❌ | Bug fix |
| Hotfix | `hotfix/<name>` | ❌ | Urgent fix for main |
| Release | `release/<version>` | ❌ | Release preparation |
| Experiment | `experiment/<name>` | ❌ | Experiments (do not merge) |

### 4.2 Branch Names

| Rule | Description |
|------|-------------|
| Lowercase | `feature/audio-player` not `Feature/Audio-Player` |
| Kebab case | `fix/null-pointer` not `fix/null_pointer` |
| Short and descriptive | `feature/export-pdf` not `feature/add-the-new-pdf-export-functionality` |
| Issue reference optional | `feature/123-audio-player` or `feature/audio-player` |

### 4.3 Workflow

```
main ─────────────────────────────●───────────────────●─── (releases)
                                  ↑                   ↑
develop ──●───●───●───●───●───●───●───●───●───●───●───●─── (integration)
          ↑       ↑   ↑       ↑
feature/a ●───●───┘   │       │
                      │       │
feature/b     ●───●───┘       │
                              │
fix/crash         ●───────────┘
```

### 4.4 Small Projects (Simplified)

For small projects without `develop`:

```
main ─────────────────────────────●───────────────────●───
          ↑       ↑   ↑       ↑
feature/a ●───●───┘   │       │
                      │       │
fix/bug       ●───────┘       │
                              │
feature/b         ●───────────┘
```

---

## 5. Tags and Releases

### 5.1 Tag Format

**Semantic Versioning (SemVer):**

```
v<MAJOR>.<MINOR>.<PATCH>[-<prerelease>]
```

| Part | Meaning | When to increment |
|------|---------|-------------------|
| MAJOR | Breaking changes | API break, incompatibility |
| MINOR | Features | New functionality (backward compatible) |
| PATCH | Fixes | Bug fixes (backward compatible) |

### 5.2 Prerelease Tags

| Suffix | Meaning | Example |
|--------|---------|---------|
| `-alpha.N` | Early development | `v1.0.0-alpha.1` |
| `-beta.N` | Feature complete, testing | `v1.0.0-beta.2` |
| `-rc.N` | Release candidate | `v1.0.0-rc.1` |

### 5.3 Example Version Sequence

```
v0.1.0          # First pre-release
v0.2.0          # New feature
v0.2.1          # Bug fix
v1.0.0-alpha.1  # Alpha for v1
v1.0.0-beta.1   # Beta
v1.0.0-rc.1     # Release candidate
v1.0.0          # First stable release
v1.0.1          # Bug fix
v1.1.0          # New feature
v2.0.0          # Breaking change
```

### 5.4 Creating a Tag

```bash
# Annotated tag (recommended)
git tag -a v1.0.0 -m "Release v1.0.0"

# With release notes
git tag -a v1.0.0 -m "Release v1.0.0

Features:
- Add audio spectrum analyzer
- Implement PDF export

Fixes:
- Fix crash on empty input (#142)
- Handle unicode filenames (#156)"

# Push tags
git push origin v1.0.0
```

### 5.5 When to Create Tags

| Situation | Create a tag? |
|-----------|---------------|
| Public release | ✅ Yes |
| Internal milestone | ✅ Optional (e.g. `v0.5.0-internal`) |
| Every merge to main | ❌ No |
| CI/CD deploy | ❌ No (use automatic build numbers) |

---

## 6. Release Notes

### 6.1 Structure

```markdown
# Release v1.2.0

**Release Date:** 2025-12-05

## Highlights

Brief summary of the most important changes.

## Features

- Add audio spectrum analyzer (#123)
- Implement PDF export functionality (#145)

## Fixes

- Fix crash on empty input (#142)
- Handle unicode filenames correctly (#156)

## Breaking Changes

- `process()` now returns `std::optional<Result>` instead of `Result*`

## Dependencies

- Upgrade spdlog to v1.12.0
- Add FFTW library for spectrum analysis
```

### 6.2 Changelog File

`CHANGELOG.md` in the repository root:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- New feature in development

## [1.2.0] - 2025-12-05

### Added
- Audio spectrum analyzer (#123)
- PDF export functionality (#145)

### Fixed
- Crash on empty input (#142)
- Unicode filename handling (#156)

### Changed
- `process()` return type (BREAKING)
```

---

## 7. .gitignore Best Practices

### 7.1 Mandatory Entries

```gitignore
# Build directories
build/
out/
cmake-build-*/

# IDE
.vs/
.vscode/
.idea/
*.user
*.suo

# CMake
CMakeUserPresets.json
CMakeCache.txt
CMakeFiles/

# Compiled
*.obj
*.o
*.exe
*.dll
*.so
*.dylib
*.lib
*.a

# Dependencies (if local)
.externals/
vcpkg_installed/

# backup files
*.bak
```

### 7.2 Optional (Project-Dependent)

```gitignore
# Logs
*.log
logs/

# Generated
generated/

# Local config
config.local.json
```

---

## 8. Git Configuration

### 8.1 Recommended Settings

```bash
# Global settings
git config --global core.autocrlf input    # Linux/macOS
git config --global core.autocrlf true     # Windows

git config --global pull.rebase true       # Rebase instead of merge on pull
git config --global init.defaultBranch main

# Optional: commit template
git config --global commit.template ~/.gitmessage
```

### 8.2 Commit Template (`~/.gitmessage`)

```
# <type>(<scope>): <subject>
#
# Types: feat, fix, refactor, perf, docs, test, build, ci, style, chore, revert
#
# Body: What and Why (not How)
#
# Footer: Fixes #123, BREAKING CHANGE:, Co-authored-by:
```

---

## 9. Merge Strategies

### 9.1 Feature → develop

| Strategy | When |
|----------|------|
| Squash merge | Many small commits → 1 clean commit |
| Rebase + merge | Clean history with linear commits |
| Merge commit | Keep feature branches traceable |

### 9.2 develop → main

| Strategy | When |
|----------|------|
| Merge commit | Release points traceable |
| Fast-forward | When develop is linear to main |

---

## 10. Checklist Before Commit

- [ ] Commit message follows the format (`type(scope): subject`)
- [ ] Subject in the imperative, max. 50 characters
- [ ] Code compiles without errors
- [ ] Tests pass
- [ ] No debug code/prints left behind
- [ ] No sensitive data (passwords, keys)
- [ ] Check .gitignore (no generated files)

---

## 11. Checklist Before Release

- [ ] All features for the release merged
- [ ] All tests green
- [ ] CHANGELOG.md updated
- [ ] Version updated in relevant files
- [ ] Release notes in English
- [ ] Annotated tag created (`git tag -a vX.Y.Z`)
- [ ] Tag pushed (`git push origin vX.Y.Z`)

---

## 12. See Also

- [CMake_Standard.md](CMake_Standard.md) — Build system
- [Language_Standards.md](Language_Standard.md) — Language guidelines
- [Conventional Commits](https://www.conventionalcommits.org/) — External specification
- [Semantic Versioning](https://semver.org/) — Versioning
- [Keep a Changelog](https://keepachangelog.com/) — Changelog format

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-13 | Migration to Blueprint v0.5: new header, table of contents, encoding fix |
| 0.1.0 | 2025-12-05 | Initial: commit format, branches, tags, release notes |
