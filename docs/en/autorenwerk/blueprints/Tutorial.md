# Tutorial — Standard for Step-by-Step Instructions

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Blueprint  
> **Status:** In Development  
> **Based on:** Doc v0.5, Blueprint v0.5  
> **Target Audience:** Documentation Authors  
> **Language:** English  
> **German:** [Tutorial.md](../../../de/autorenwerk/blueprints/Tutorial.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Distinction from Guide](#2-distinction-from-guide)
3. [Header Extensions](#3-header-extensions)
4. [Required Sections](#4-required-sections)
5. [Writing Style](#5-writing-style)
6. [Code Examples](#6-code-examples)
7. [Structure Patterns](#7-structure-patterns)
8. [Example Tutorial](#8-example-tutorial)
9. [Review Checklist](#9-review-checklist)
10. [See Also](#10-see-also)
11. [Changelog](#changelog)

---

## 1. Overview

This blueprint defines the standard for **tutorials** — practical step-by-step instructions that guide the reader through a concrete project or task.

### Target Audience

- Documentation authors who write tutorials
- Anyone who wants to learn how good tutorials are structured

### What Is a Tutorial?

| Characteristic | Description |
|----------------|-------------|
| **Goal** | Concrete result at the end |
| **Method** | Learning by doing |
| **Structure** | Numbered steps |
| **Focus** | "Follow me and build X" |

---

## 2. Distinction from Guide

| Aspect | Tutorial | Guide |
|--------|----------|-------|
| **Structure** | Linear, step by step | Thematic, reference work |
| **Goal** | Build a concrete project | Understand concepts |
| **Reader** | Follows instructions | Looks for specific information |
| **Example** | "Create your first executable" | "How do I configure Qt6?" |
| **Result** | Working artifact | Knowledge/understanding |

**Rule of thumb:**
- **Tutorial:** "At the end you have built X"
- **Guide:** "This is how X works"

---

## 3. Header Extensions

### 3.1 Additional Fields

Tutorials extend the standard header with:

```markdown
> **Prerequisites:** [What must the reader know/have beforehand?]  
> **Time Required:** [Estimated duration, e.g. "~30 minutes"]  
> **Difficulty:** [Beginner | Intermediate | Expert]  
> **Result:** [What does the reader have at the end?]
```

### 3.2 Complete Header

```markdown
# [Title] — Tutorial

> **Version:** X.Y.Z  
> **Date:** YYYY-MM-DD  
> **Type:** Tutorial  
> **Status:** [In Development | Stable | Deprecated]  
> **Target Audience:** [Who should do this tutorial?]  
> **Prerequisites:** [Guide X read, tool Y installed]  
> **Time Required:** ~30 minutes  
> **Difficulty:** Beginner  
> **Result:** [Working X]  
> **Language:** English  
> **German:** [Title_Tutorial.md](../../../de/guide/userguides/Title_Tutorial.md)
```

### 3.3 Example

```markdown
# Adding GoogleTest and Catch2 — Tutorial

> **Version:** 1.0.0  
> **Date:** 2025-12-10  
> **Type:** Tutorial  
> **Status:** Stable  
> **Target Audience:** C++ Developers  
> **Prerequisites:** [Adding_Externals.md](Adding_Externals.md)  
> **Time Required:** ~45 minutes  
> **Difficulty:** Intermediate  
> **Result:** Working test executables with GoogleTest and Catch2  
> **Language:** English  
> **German:** [GoogleTest_Catch2_Tutorial.md](../../../de/guide/userguides/GoogleTest_Catch2_Tutorial.md)
```

---

## 4. Required Sections

### 4.1 Structure

```markdown
# [Title] — Tutorial

> [Header]

---

## Table of Contents
[Numbered with anchors]

---

## 1. Overview
[What is being built? Why? Preview of the end result]

---

## 2. Prerequisites
[Checklist: tools, knowledge, files]

---

## 3. Step 1: [First Action]
[Instructions + code + explanation]

---

## 4. Step 2: [Second Action]
[...]

---

## N. Step N: [Last Action]
[...]

---

## N+1. Testing the Result
[How is the result verified?]

---

## N+2. Summary
[What was learned? Next steps?]

---

## N+3. Troubleshooting
[Common problems and solutions]

---

## See Also
[Further documentation]

---

## Changelog
[Version history]
```

### 4.2 Required Sections in Detail

| Section | Required | Description |
|---------|----------|-------------|
| **Overview** | ✓ | What is being built, why, preview |
| **Prerequisites** | ✓ | Checklist before starting |
| **Steps** | ✓ | Numbered instructions |
| **Testing the Result** | ✓ | Verification of the end result |
| **Summary** | ✓ | What was learned |
| **Troubleshooting** | — | Common problems (recommended) |
| **Files Overview** | — | Final structure (recommended) |

---

## 5. Writing Style

### 5.1 Basic Rules

| Rule | Correct | Wrong |
|------|---------|-------|
| Imperative | "Create the file" | "The file should be created" |
| Direct | "Open `Solution.json`" | "One opens the file" |
| Concrete | "Add the following line:" | "Adjust configuration" |
| Short | "Save the file" | "Now you should save the file" |

### 5.2 Step Structure

Each step follows the pattern:

````markdown
## N. Step N: [Action Title]

[1-2 sentences: What is done and why]

**File:** `path/to/file.ext`

```code
[Code or configuration]
```

**Explanation:**
- `element1`: Description
- `element2`: Description

[Optional: note box for important information]
````

### 5.3 Note Boxes

```markdown
> **Note:** General information

> **Important:** Critical information

> **Warning:** Potential problems

> **Tip:** Optional improvement
```

### 5.4 Progress Indicators

Optional for longer tutorials:

```markdown
---
**Progress:** ████████░░ 80% — Step 4 of 5
---
```

---

## 6. Code Examples

### 6.1 Rules

| Rule | Description |
|------|-------------|
| **Complete** | No code without context |
| **Copyable** | Directly usable |
| **Commented** | Important lines explained |
| **Tested** | Must work! |

### 6.2 Code Block Format

````markdown
**File:** `cmake/externals/hooks/prefetch/googletest.cmake`

```cmake
# GoogleTest PreFetch Hook
# ========================

message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch: Configuring GoogleTest")

# Windows CRT Fix (IMPORTANT!)
if(WIN32)
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
endif()
```
````

### 6.3 Diff Representation

For changes to existing files:

````markdown
**Change in** `Solution.json`:

```diff
{
    "externals": {
+       "googletest": {
+           "git": "https://github.com/google/googletest.git",
+           "tag": "v1.14.0"
+       }
    }
}
```
````

### 6.4 Expected Output

````markdown
**Expected output:**

```
[==========] Running 2 tests from 1 test suite.
[----------] 2 tests from ExampleTest
[ RUN      ] ExampleTest.BasicAssertions
[       OK ] ExampleTest.BasicAssertions (0 ms)
[  PASSED  ] 2 tests.
```
````

---

## 7. Structure Patterns

### 7.1 Simple Tutorial (1 Part)

```markdown
# [Topic] — Tutorial

## 1. Overview
## 2. Prerequisites
## 3. Step 1: [...]
## 4. Step 2: [...]
## 5. Step 3: [...]
## 6. Testing the Result
## 7. Summary
```

### 7.2 Multi-Part Tutorial

Split complex topics into parts:

```markdown
# [Topic] — Tutorial

## Overview
## Prerequisites

---

# Part 1: [Subtitle]

## 1.1 [Step]
## 1.2 [Step]
## 1.3 Testing the Intermediate Result

---

# Part 2: [Subtitle]

## 2.1 [Step]
## 2.2 [Step]
## 2.3 Testing the Intermediate Result

---

# Summary

## Files Overview
## Comparison/Conclusion
## See Also
```

### 7.3 Comparison Tutorial

When several alternatives are shown (e.g. GoogleTest vs Catch2):

```markdown
# [Alternative A] and [Alternative B] — Tutorial

## Overview

| Aspect | Alternative A | Alternative B |
|--------|---------------|---------------|
| ... | ... | ... |

---

# Part 1: Alternative A
[Complete tutorial for A]

---

# Part 2: Alternative B
[Complete tutorial for B]

---

# Comparison
[Decision aid]
```

---

## 8. Example Tutorial

### 8.1 Prerequisites Section

```markdown
## 2. Prerequisites

Before you begin, make sure that:

**Tools:**
- [ ] CMake 3.19 or higher is installed
- [ ] C++ compiler (MSVC, GCC, or Clang)
- [ ] Git is installed

**Knowledge:**
- [ ] [Adding_Externals.md](Adding_Externals.md) read
- [ ] Basic knowledge of CMake

**Files:**
- [ ] Working CMake Architecture project
- [ ] `Solution.json` present
```

### 8.2 Step Section

````markdown
## 3. Step 1: Add External to Solution.json

Add GoogleTest as an external.

**File:** `Solution.json`

```json
{
    "externals": {
        "googletest": {
            "git": "https://github.com/google/googletest.git",
            "tag": "v1.14.0"
        }
    }
}
```

**Explanation:**
- `git`: Repository URL
- `tag`: Stable version (v1.14.0 is the current release)

> **Note:** Always use tags instead of branches for reproducible builds.
````

### 8.3 Files Overview

````markdown
## Files Overview

After completing the tutorial you have:

```
cmake/externals/hooks/prefetch/
├── googletest.cmake        ← GoogleTest PreFetch Hook
└── catch2.cmake            ← Catch2 PreFetch Hook

projects/tests/MyTests/src/
└── main.cpp                ← Test file

Solution.json               ← External + test configured
```
````

### 8.4 Troubleshooting Section

````markdown
## Troubleshooting

### Problem: Linker Error on Windows

**Symptom:**
```
LNK2038: mismatch detected for 'RuntimeLibrary'
```

**Cause:** GoogleTest uses the static CRT, the project the dynamic one.

**Solution:** Set `gtest_force_shared_crt` in the PreFetch hook:
```cmake
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
```

---

### Problem: Tests Are Not Found

**Symptom:** `ctest` finds no tests.

**Solution:** 
1. Check whether `enable_testing()` is in CMakeLists.txt
2. Check whether the test executable is registered correctly
````

---

## 9. Review Checklist

Check before publishing a tutorial:

**Header:**
- [ ] All required fields present
- [ ] Prerequisites complete
- [ ] Time required realistic
- [ ] Difficulty correct

**Content:**
- [ ] Overview explains goal and result
- [ ] Prerequisites as checklist
- [ ] Steps numbered and logical
- [ ] Each step has: action + code + explanation
- [ ] Result test present
- [ ] Summary with "What was learned"

**Code:**
- [ ] All code examples tested
- [ ] File paths given
- [ ] Expected outputs shown
- [ ] No syntax errors

**Quality:**
- [ ] Tutorial walked through from start to finish
- [ ] Tested on a fresh system (if possible)
- [ ] Troubleshooting for known problems

---

## 10. See Also

- [Doc.md](Doc.md) — General documentation rules
- [Guide.md](Guide.md) — For thematic guides
- GoogleTest_Catch2_Tutorial.md — Example tutorial

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: hook path `cmake/externals/hooks/prefetch/` (lowercase, as in the repo), tutorials live in `docs/[lang]/guide/userguides/` (jump path `../../../de/`), prerequisite `Adding_Externals.md`** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.5.0 | 2025-12-13 | Initial: distinction from Guide, header extensions, step structure, code examples, multi-part tutorials |
