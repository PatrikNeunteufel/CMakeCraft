# Language Standard – Language Guidelines

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Standard  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Scope:** Code, documentation, Git, communication  
> **Enforcement:** Code review, CI (commit message linting)  
> **Language:** English  
> **German:** [Language_Standard.md](../../../de/autorenwerk/standards/Language_Standard.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Scope](#2-scope)
3. [Code Language](#3-code-language)
4. [Documentation Language](#4-documentation-language)
5. [Git and Repository](#5-git-and-repository)
6. [Error Messages and Logs](#6-error-messages-and-logs)
7. [Glossary and Consistency](#7-glossary-and-consistency)
8. [Exceptions](#8-exceptions)
9. [Checklist](#9-checklist)
10. [Migration](#10-migration)
11. [See Also](#11-see-also)
12. [Changelog](#changelog)

---

## 1. Overview

This standard defines **binding language guidelines** for all aspects of software development. The goal is consistency and international accessibility.

### Target Audience

All developers who write code, create documentation or work with Git. This standard is mandatory for all new projects and recommended when modernizing existing projects.

### Basic Principle

| Area | Language | Rationale |
|------|----------|-----------|
| **Code & technical matters** | English | International, industry standard |
| **Documentation (release)** | English (mandatory) | International accessibility |
| **Documentation (additional)** | Any (welcome) | Maximizes reach |
| **Git** | English | Part of the technical context |

### Multi-Language Philosophy

- **English is mandatory** for every publication (e.g. GitHub)
- **Further languages are welcome** – they maximize the reach
- The **primary language** may vary by team/developer (here: German)
- The primary language is **authoritative** (SSOT, see [Doku_Standard.md](Doku_Standard.md)); English is the
  complete translation for publication

---

## 2. Scope

### 2.1 Affected Artifacts

| Artifact | Language | Remark |
|----------|----------|--------|
| `.cmake` | English | CMake modules, presets |
| `.cpp`, `.hpp`, `.h`, `.c` | English | C/C++ code |
| `.py` | English | Python scripts |
| `.sh`, `.bat`, `.ps1` | English | Shell scripts |
| `.json` (technical) | English | CMakePresets.json, Solution.json |
| `.yaml`, `.yml` | English | CI/CD, configuration |
| `.md` (documentation) | Multilingual | English mandatory, others welcome |
| Git (commits, branches) | English | Technical context |

### 2.2 Not Affected

- UI texts with internationalization (i18n)
- Language packs and translation files
- Domain-specific technical terms without an English equivalent

---

## 3. Code Language

### 3.1 Basic Rule

**Rule:** All code artifacts are to be kept in English throughout.

**Obligation level:** MUST

### 3.2 Affected Elements

| Element | Language | Example |
|---------|----------|---------|
| Variable names | English | `_source_count`, `_has_path` |
| Function names | English | `collect_sources()`, `validate_external()` |
| Comments | English | `// Check if file exists` |
| Log output | English | `"Source.cmake not found"` |
| Error messages | English | `"Missing required field 'name'"` |
| Docstrings | English | Header comments, API documentation |

### 3.3 Examples

**Correct:**
```cmake
# Check if source file exists
function(validate_source_path SOURCE_DIR)
    if(NOT EXISTS "${SOURCE_DIR}")
        cmake_fatal("E104" "Source directory not found: ${SOURCE_DIR}")
    endif()
endfunction()
```

**Wrong:**
```cmake
# Prüfe ob Source-Datei existiert
function(pruefe_source_pfad QUELL_VERZEICHNIS)
    if(NOT EXISTS "${QUELL_VERZEICHNIS}")
        cmake_fatal("E104" "Quellverzeichnis nicht gefunden: ${QUELL_VERZEICHNIS}")
    endif()
endfunction()
```

---

## 4. Documentation Language

### 4.1 Multi-Language Model

| Language | Status | Description |
|----------|--------|-------------|
| **English** | Mandatory | Complete translation for publication, international accessibility |
| **Primary language** | Authoritative where present | Source of all translations (here German, SSOT) |
| **Further languages** | Welcome | Maximize reach, community contributions |

**Advantages of several languages:**
- Greater international reach
- Lower entry barrier for non-native English speakers
- The community can contribute translations

### 4.2 Folder Structure

```
docs/
├── de/                    ← German (primary language here, authoritative)
│   ├── guide/             ← module/, references/, userguides/, cheatsheets/
│   ├── konzepte/
│   └── autorenwerk/       ← blueprints/, standards/
│
├── en/                    ← English (MANDATORY for release, same tree)
│   ├── guide/
│   ├── konzepte/
│   └── autorenwerk/
│
├── fr/                    ← French (optional)
├── es/                    ← Spanish (optional)
├── zh/                    ← Chinese (optional)
└── ...                    ← Further languages welcome
```

### 4.3 File Names

**Rule:** A file has the **same name in every language folder** (same relative path, same name). The name may
come from the primary language (e.g. `Neues_Projekt_Guide.md`, `Glossar.md`); translations keep it unchanged.

**Obligation level:** MUST

**Rationale:** Enables simple mapping between language versions (the pre-commit hook and the header links
`English:`/`German:` rely on the same path).

**Correct:**
```
docs/de/guide/userguides/Qt6_Integration.md      ← German (authoritative)
docs/en/guide/userguides/Qt6_Integration.md      ← English
docs/de/guide/userguides/Neues_Projekt_Guide.md  ← German name, identical in en
docs/en/guide/userguides/Neues_Projekt_Guide.md
```

**Wrong:**
```
docs/de/guide/userguides/Qt6_Integration_Benutzerhandbuch.md
docs/en/guide/userguides/New_Project_Guide.md   ← different name than in de
```

### 4.4 Documentation Header

**English (en/) – mandatory:**
```markdown
# Module Name – Documentation

> **Version:** 1.0.0  
> **Language:** English  
> **German:** [Module_Name.md](../../../../de/guide/module/core/Module_Name.md)
```

**Primary language (here de/, authoritative):**
```markdown
# Modul-Name – Dokumentation

> **Version:** 1.0.0  
> **Sprache:** Deutsch  
> **English:** [Module_Name.md](../../../../en/guide/module/core/Module_Name.md)
```

### 4.5 Translation Rules

| Rule | Description |
|------|-------------|
| Primary language first | Changes happen first in the authoritative primary language (here `de/`) |
| Same commit | The English version is updated in the same commit (the pre-commit hook reports gaps) |
| Release | The English version is complete before a publication |
| Completeness | Translations are identical in content |
| Technical terms | Translate consistently (see glossary) |
| Code examples | Remain unchanged (already in English) |
| Versioning | All language versions have the same version number |
| Partial translations | Allowed – better than no translation |

### 4.6 Workflow for Translations

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│ Primary language│ ──▶ │     English     │ ──▶ │Further languages│
│(working version)│     │(release, mandatory)│  │   (optional)    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

**On publication (e.g. GitHub):**
1. The English version must be complete
2. The primary language may exist in parallel
3. Further languages are a bonus

---

## 5. Git and Repository

### 5.1 Commit Messages

**Rule:** Commit messages are to be written in English.

**Obligation level:** MUST

**Format:**
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Correct:**
```
feat(core): add SourceCollect.cmake module

- Implements three collection modes: explicit, glob, auto
- Adds collect_files() helper for controlled wildcards
- Includes C++20 module support (experimental)
```

**Wrong:**
```
feat(core): SourceCollect.cmake Modul hinzugefügt

- Implementiert drei Sammel-Modi: explicit, glob, auto
```

### 5.2 Branch Names

**Rule:** Branch names are to be kept in English.

**Obligation level:** MUST

| Type | Format | Example |
|------|--------|---------|
| Feature | `feature/<description>` | `feature/source-collect-module` |
| Bugfix | `fix/<description>` | `fix/context-scope-issue` |
| Release | `release/<version>` | `release/0.1.0` |
| Hotfix | `hotfix/<description>` | `hotfix/critical-path-error` |

### 5.3 Tags and Releases

**Rule:** Tags and release notes are in English.

**Obligation level:** MUST

```
v0.1.0
v0.1.0-rc.1
v0.1.0-beta.1
```

### 5.4 Pull/Merge Requests

| Element | Language | Obligation level |
|---------|----------|------------------|
| Title | English | MUST |
| Description | English | SHOULD |
| Comments | English or German | MAY |

---

## 6. Error Messages and Logs

### 6.1 User-Facing Messages

**Rule:** All messages that developers see are in English.

**Obligation level:** MUST

**Correct:**
```cmake
cmake_fatal("E001" "Executable 'MyApp': Required field 'name' missing")
cmake_warn("W110" "GLOB fallback active - explicit Source.cmake recommended")
```

**Wrong:**
```cmake
cmake_fatal("E001" "Executable 'MyApp': Pflichtfeld 'name' fehlt")
```

### 6.2 Debug Output

**Correct:**
```cmake
dbg(${DBG_COMMON} "Collecting sources for ${TARGET_NAME}" ID SOURCE_COLLECT)
dbg(${DBG_RARE} "  Found ${_count} source files" ID SOURCE_COLLECT)
```

**Wrong:**
```cmake
dbg(${DBG_COMMON} "Sammle Quellen für ${TARGET_NAME}" ID SOURCE_COLLECT)
```

### 6.3 ErrorCodes Documentation

The ErrorCodes reference is maintained **bilingually**:

| Code | English | Deutsch |
|------|---------|---------|
| E001 | Required field missing | Pflichtfeld fehlt |
| E104 | Source.cmake not found | Source.cmake nicht gefunden |

---

## 7. Glossary and Consistency

### 7.1 Untranslated Terms

These technical terms are **not translated**:

| Term | Context | Rationale |
|------|---------|-----------|
| Target | CMake | CMake technical term |
| Preset | CMake | CMake technical term |
| Context | Build system | Project-specific term |
| External | Build system | Project-specific term |
| Solution | Build system | Project-specific term |
| Hook | Build system | Established term |
| Pipeline | Build system | Established term |

### 7.2 Translation Glossary

| Deutsch | English | Context |
|---------|---------|---------|
| Ausführbare Datei | Executable | Target type |
| Bibliothek | Library | Target type |
| Abhängigkeit | Dependency | Build configuration |
| Pflichtfeld | Required field | Validation |
| Warnung | Warning | Error handling |
| Verzeichnis | Directory | File system |
| Geltungsbereich | Scope | Variables |
| Arbeitsbereich | Workspace | Development environment |

---

## 8. Exceptions

### 8.1 Permitted Deviations

| Situation | Permitted Language | Condition |
|-----------|--------------------|-----------|
| UI texts with i18n | Localized | Via the translation system |
| Domain-specific terms | Original | No English equivalent |
| Internal team discussion | German | PR comments, chat |
| Legacy code | German (temporary) | With a TODO for migration |

### 8.2 Documenting Deviations

Intentional deviations must be documented:

```cmake
# NOTE: German variable name retained for compatibility with legacy API
# TODO: Rename to english_name in v2.0.0
set(_deutscher_name "value")
```

---

## 9. Checklist

### 9.1 New Code File

- [ ] All variable names in English
- [ ] All function names in English
- [ ] All comments in English
- [ ] All log/error messages in English
- [ ] Header documentation in English

### 9.2 New Documentation

- [ ] Primary language version created (authoritative)
- [ ] English version created in the same commit (mandatory for release)
- [ ] Technical terms used consistently
- [ ] Code examples in English
- [ ] Language link present in the header (`English:` or `German:`)
- [ ] Same file name in all language folders

### 9.3 Git Commit

- [ ] Commit message in English
- [ ] Branch name in English
- [ ] Conventional commit format
- [ ] Meaningful description

### 9.4 Code Review

- [ ] No German variable/function names
- [ ] No German comments
- [ ] No German error messages
- [ ] Glossary terms used correctly

---

## 10. Migration

### 10.1 Prioritization

| Priority | Artifact | Effort |
|----------|----------|--------|
| **1 (High)** | CMake modules (.cmake) | Comments, error messages |
| **2 (Medium)** | ErrorCodes reference | Maintain bilingually |
| **3 (Normal)** | Concept documentation | Create English version |
| **4 (Low)** | Module documentation | Create English version |

### 10.2 Migration Workflow

1. **Audit:** Identify affected files
2. **Planning:** Estimate effort, prioritize
3. **Implementation:** Migrate step by step
4. **Review:** Check consistency
5. **Documentation:** Update changes

### 10.3 Legacy Marking

```cmake
# LEGACY: German comments - migration pending
# TODO(language): Translate to English before v1.0.0
```

---

## 11. See Also

- [Git_Standard.md](Git_Standard.md) – Git workflow and commit conventions
- [Cpp_Coding_Standard.md](Cpp_Coding_Standard.md) – C++ code style
- [CMake_Standard.md](CMake_Standard.md) – Build system conventions
- [Doc.md](../blueprints/Doc.md) – Documentation rules
- [Structure.md](../blueprints/Structure.md) – Folder structure

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.1 | 2026-11-09 | Aligned with `Doku_Standard` (decision S1 a): primary language authoritative, English in the same commit (§1, §4.1, §4.5, §9.2); same file names in all language folders, names from the primary language allowed (§4.3); folder tree and header examples on today's tree (§4.2, §4.4) |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| **0.5.0** | **2025-12-14** | **Migration to Blueprint v0.5: new header, table of contents with anchors, chapter numbering, multi-language model (English mandatory, further languages welcome), obligation levels, checklists extended** |
| 0.1.1 | 2025-12-04 | File structure: /de/ and /en/ subfolders instead of suffix variant |
| 0.1.0 | 2025-12-04 | Initial: code language, documentation language, Git, migration |
