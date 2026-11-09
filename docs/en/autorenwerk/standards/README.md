# Standards v0.7.0 — Overview

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Status:** Stable  
> **Language:** English  
> **German:** [README.md](../../../de/autorenwerk/standards/README.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Files](#2-files)
3. [Relationships](#3-relationships)
4. [Application](#4-application)
5. [See Also](#5-see-also)

---

## 1. Overview

Standards define **binding conventions** for development and collaboration. They describe the "what" and "why", while blueprints govern the "how" of documentation.

### Target Audience

All developers in the company.

### Enforcement

| Mechanism | Description |
|-----------|-------------|
| **Automatic** | clang-format, clang-tidy, pre-commit hooks |
| **Manual** | Code review, PR checklists |
| **CI/CD** | Build pipeline checks |

---

## 2. Files

| File | Target Audience | Scope |
|------|-----------------|-------|
| [Language_Standard.md](Language_Standard.md)|All developers|Global|
| [CMake_Standard.md](CMake_Standard.md) | All developers | Build system |
| [Git_Standard.md](Git_Standard.md) | All developers | Version control |
| [Cpp_Coding_Standard.md](Cpp_Coding_Standard.md) | C++ developers | PC applications |
| [C_Coding_Standard.md](C_Coding_Standard.md) | Embedded developers | Firmware, MCUs |

> **Note:** No versions in file names. The version appears only in the header.  
> Archived versions: `Cpp_Coding_Standard_v0_1_0.md` etc.

---

## 3. Relationships

```
Standards (conventions)               Blueprints (documentation)
=======================               ==========================

Language_Standard   ◄──────────────── Standard.md (Blueprint)
CMake_Standard      ◄──────────────── Standard.md (Blueprint)
Git_Standard        ◄──────────────── Standard.md (Blueprint)
Cpp_Coding_Standard ◄──────────────── Standard.md (Blueprint)
C_Coding_Standard   ◄──────────────── Standard.md (Blueprint)
        │
        │ references
        ▼
ClangFormat_Blueprint ─────────────► .clang-format (tool config)
ClangTidy_Blueprint   ─────────────► .clang-tidy (tool config)
```

### Hierarchy

| Level | Document | Governs |
|-------|----------|---------|
| Meta | Standard.md (Blueprint) | How standards are written |
| Standard | *_Standard.md | What is to be done |
| Tool config | .clang-format, .clang-tidy | Automatic enforcement |

---

## 4. Application

### 4.1 For Developers

| Situation | Relevant Standard |
|-----------|-------------------|
| Writing new C++ code | Cpp_Coding_Standard |
| Developing embedded firmware | C_Coding_Standard |
| Creating CMakeLists.txt | CMake_Standard |
| Creating a commit | Git_Standard |

### 4.2 For New Projects

1. Read **CMake_Standard** → set up the project structure
2. Read **Git_Standard** → set up the repository
3. Read **Cpp/C_Coding_Standard** → know the code style
4. Copy the tool configs (`.clang-format`, `.clang-tidy`)

### 4.3 Quick Reference

| Topic | Standard | Section |
|-------|----------|---------|
| Naming conventions (C++) | Cpp_Coding_Standard | §7 |
| Naming conventions (C) | C_Coding_Standard | §7 |
| Class structure (C++) | Cpp_Coding_Standard | §8 |
| Struct layout (C) | C_Coding_Standard | §8 |
| Commit message format | Git_Standard | §3 |
| Branch strategy | Git_Standard | §4 |
| CMake target names | CMake_Standard | §4 |
| RAII | Cpp_Coding_Standard | §9.3 |
| Error handling (C) | C_Coding_Standard | §12 |

---

## 5. See Also

- [blueprints/Standard.md](../blueprints/Standard.md) — Blueprint for standards
- [blueprints/README.md](../blueprints/Blueprint.md) — Blueprint overview
- [ClangFormat_Blueprint.md](../blueprints/ClangFormat.md) — Formatting
- [ClangTidy_Blueprint.md](../blueprints/ClangTidy.md) — Static analysis

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.7.0 | 2025-12-19 | Unification of C/C++: PascalCase file names for both, prefix p for all pointers |
| 0.6.0 | 2025-12-19 | Consolidation: Cpp_Coding_Standard and C_Coding_Standard extended with class/struct layout, file naming conventions, extended prefixes, include order |
| 0.5.0 | 2025-12-13 | Initial: migration of all standards to the v0.5.0 format |
