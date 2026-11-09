# Makefile Standard — Style Guidelines

> **Version:** 1.0.0  
> **Date:** 2025-12-19  
> **Type:** Standard  
> **Status:** Stable  
> **Target Audience:** Build system developers  
> **Scope:** All Makefile-based build systems  
> **Enforcement:** Code review  
> **Language:** English  
> **German:** [Makefile_Standard.md](../../../de/autorenwerk/standards/Makefile_Standard.md)

---

## Table of Contents

1. [Purpose and Scope](#1-purpose-and-scope)
2. [Basic Principles](#2-basic-principles)
3. [File Organization](#3-file-organization)
4. [Formatting](#4-formatting)
5. [Naming Conventions](#5-naming-conventions)
6. [Variables](#6-variables)
7. [Targets and Rules](#7-targets-and-rules)
8. [Comments](#8-comments)
9. [Error Handling](#9-error-handling)
10. [Diagnostic Targets](#10-diagnostic-targets)
11. [Shell Commands](#11-shell-commands)
12. [Portability](#12-portability)
13. [See Also](#13-see-also)
14. [Changelog](#14-changelog)

---

## 1. Purpose and Scope

This standard defines **coding conventions for Makefiles** in the company.

### 1.1 Target Audience

Build system developers who write Makefiles for embedded or PC projects.

### 1.2 Area of Application

| Project Type | Applies to |
|--------------|------------|
| Embedded build systems | TMS320, Microchip, etc. |
| PC build systems | Standalone Makefiles |
| CMake projects | Not directly (see CMake_Standard) |

---

## 2. Basic Principles

1. **Transparency** — Every step should be traceable
2. **Fail-fast** — Detect errors early and report them clearly
3. **Modularity** — Reusable, independent modules
4. **Documentation** — Diagnostic targets for debugging

### 2.1 TODO Markers

For unfinished tasks: use `# TODO:` in the comment.

```makefile
# TODO: Add fallback for missing compiler
# TODO: Implement parallel build support
```

---

## 3. File Organization

### 3.1 File Names

| Type | Convention | Example |
|------|------------|---------|
| Main Makefile | `Makefile` | `Makefile` |
| Module | `<name>.mk` | `toolchain.mk`, `paths.mk` |
| Folder | `lowercase` | `common/`, `make/` |

### 3.2 Module Structure

```
make/
├── common/          /* Shared modules       */
│   ├── config.mk
│   ├── paths.mk
│   └── ...
└── <project>/       /* Project-specific     */
    ├── config.mk
    ├── sources.mk
    └── rules.mk
```

### 3.3 Include Order

The order of the includes is critical:

```makefile
# 1. Bootstrap/argument validation
include common/arguments.mk

# 2. Configuration
include common/config.mk
include common/paths.mk

# 3. Outputs
include common/outputs.mk

# 4. Toolchain
include common/toolchain.mk

# 5. Project-specific
include $(Project)/config.mk
include $(Project)/sources.mk
include $(Project)/rules.mk
```

---

## 4. Formatting

### 4.1 Overview

| Aspect | Rule |
|--------|------|
| Indentation in recipes | **Tab** (mandatory in Make) |
| Indentation outside | 2 spaces |
| Line length | 100 characters (soft limit) |
| Blank lines | Between sections |

### 4.2 Line Breaks

```makefile
# Break long lists with a backslash
SOURCES := \
    file1.c \
    file2.c \
    file3.c

# Break long commands
$(CC) \
    $(CFLAGS) \
    -o "$@" \
    "$<"
```

### 4.3 Alignment

```makefile
# Align equals signs
CC      := $(CG_TOOL_ROOT)/bin/cl2000
AR      := $(CG_TOOL_ROOT)/bin/ar2000
LD      := $(CG_TOOL_ROOT)/bin/lnk2000

# Align values
PROJECT     = MyProject
CONFIG      = Debug
OUTPUT_DIR  = $(BUILD_DIR)/out
```

---

## 5. Naming Conventions

### 5.1 Overview

| Entity | Convention | Example |
|--------|------------|---------|
| **Exported variable** | UPPER_CASE | `CG_TOOL_ROOT`, `CFLAGS` |
| **Local variable** | lower_case or UPPER_CASE | `_temp`, `LOCAL_VAR` |
| **Function (call)** | lower_case with _ | `_require_dir`, `normpath` |
| **Target** | lower-case with - | `all`, `clean`, `check-paths` |
| **Phony target** | lower-case with - | `check-all`, `print-%` |

### 5.2 Prefixes

| Prefix | Meaning | Example |
|--------|---------|---------|
| `_` | Internal/local variable | `_CG_CAND` |
| `check-` | Diagnostic target | `check-paths` |
| `print-` | Print a variable | `print-CFLAGS` |

### 5.3 Module Namespace

Variables from a module can be given a module prefix:

```makefile
# In paths.mk
PATHS_INCLUDE_DIRS := ...
PATHS_LIB_DIRS := ...

# Or export generically
INCLUDE_DIRS := ...
export INCLUDE_DIRS
```

---

## 6. Variables

### 6.1 Kinds of Expansion

| Kind | Syntax | Usage |
|------|--------|-------|
| **Immediate expansion** | `:=` | Paths, lists, constant values |
| **Deferred expansion** | `=` | Values that depend on later variables |
| **Conditional assignment** | `?=` | Defaults that can be overridden |
| **Append** | `+=` | Extend lists |

### 6.2 Best Practices

```makefile
# ✅ Immediate expansion for paths
OUT_DIR := $(ProjectDir)/Build/out

# ✅ Deferred expansion for dependent values
GLOBAL_LIB = $(OUT_DIR)/Global$(ABI_SUFFIX).lib

# ✅ Default with ?=
Config ?= Debug

# ✅ Override for argument normalization
override ProjectDir := $(call normpath,$(ProjectDir))

# ✅ Export for recursive calls
export CC CFLAGS LDFLAGS
```

### 6.3 Argument Validation

```makefile
# Pattern: Required argument
Project ?= Unknown
ifeq ($(Project),Unknown)
  $(error [FATAL] Argument Project was not provided!)
endif

# Pattern: Allowed values
ifneq ($(Config),Debug)
  ifneq ($(Config),Release)
    $(error [FATAL] Config must be Debug or Release)
  endif
endif
```

---

## 7. Targets and Rules

### 7.1 .PHONY

Declare all targets without file output as `.PHONY`:

```makefile
.PHONY: all clean check-all print-%
```

### 7.2 Standard Targets

| Target | Description |
|--------|-------------|
| `all` | Standard build (default) |
| `clean` | Delete build artifacts |
| `check-all` | All diagnostics |

### 7.3 Pattern Rules

```makefile
# Pattern rule for C files
$(OBJ_DIR)/%.obj: $(SRC_DIR)/%.c | $(OBJ_DIR)
	@echo [CC] $<
	@"$(CC)" $(CFLAGS) -o "$@" "$<"
```

### 7.4 Order-Only Prerequisites

```makefile
# | separates normal from order-only prerequisites
$(OUT_DIR)/app.out: $(OBJS) | $(OUT_DIR)
	@echo [LD] $@
	@"$(LD)" -o "$@" $(OBJS)

# Order-only: the directory is created but does not trigger a rebuild
$(OUT_DIR):
	@mkdir -p "$@"
```

---

## 8. Comments

### 8.1 File Header

```makefile
# <module>.mk - <short description>
# <optional details>
# !!!!!!!!!!!!!!!!!!!!!!!!! DON'T TOUCH WITHOUT ANY GOOD REASON !!!!!!!!!!!!!!!!!!!!!!
```

### 8.2 Section Header

```makefile
# ==== Section Name ===============================================================
# Optional description
```

### 8.3 Inline Comments

```makefile
CC := $(CG_TOOL_ROOT)/bin/cl2000  # TI C2000 compiler
```

### 8.4 Parsing Info

```makefile
$(info *** parsing <module>.mk ***)
$(info )
```

---

## 9. Error Handling

### 9.1 Fail-Fast

```makefile
# Missing variable
ifeq ($(REQUIRED_VAR),)
  $(error [FATAL] REQUIRED_VAR is not set)
endif

# Missing file/directory
_require_dir  = $(if $(wildcard $(1)/.),,$(error [FATAL] Missing directory: "$(1)" - $(2)))
_require_file = $(if $(wildcard $(1)),,$(error [FATAL] Missing file: "$(1)" - $(2)))

$(call _require_dir,$(TOOL_PATH),Toolchain not found)
```

### 9.2 Errors in Recipes

```makefile
# Error check after a command
$(OUT)/app.out: $(OBJS)
	@"$(LD)" -o "$@" $(OBJS)
	@[ -f "$@" ] || (echo "[FATAL] Link failed: $@"; exit 2)
```

### 9.3 Error Message Format

```
[FATAL] <description> - <context>
[WARN]  <description>
[INFO]  <description>
```

---

## 10. Diagnostic Targets

### 10.1 Check Target Pattern

```makefile
.PHONY: check-<aspect>

check-<aspect>:
	@echo "*** Check <Aspect> ***"
	@echo "**********************"
	@echo "VAR1= $(VAR1)"
	@echo "VAR2= $(VAR2)"
	@echo ""
```

### 10.2 Meta Target

```makefile
.PHONY: check-all

check-all: check-arguments check-paths check-outputs check-abi
	@echo "*** All checks completed ***"
```

### 10.3 Variable Inspection

```makefile
print-%:
	@echo '$*=$($*)'
```

---

## 11. Shell Commands

### 11.1 Suppressing Echo

```makefile
# @ suppresses echoing of the command
@echo [CC] $<
@$(CC) $(CFLAGS) -o "$@" "$<"
```

### 11.2 Multiple Commands

```makefile
# ; or && for chaining
target:
	@echo "Step 1"; echo "Step 2"
	@cd $(DIR) && $(MAKE)
```

### 11.3 Conditional Execution

```makefile
clean:
	@if [ -d "$(OUT_DIR)" ]; then rm -rf "$(OUT_DIR)"; fi
```

### 11.4 Shell Variable vs. Make Variable

```makefile
# $$ for a shell variable
target:
	@for f in *.c; do echo "$$f"; done
```

---

## 12. Portability

### 12.1 Path Normalization

```makefile
# Convert \ to / and resolve /..
fwd      = $(subst \,/,$(1))
normpath = $(strip $(call fwd,$(abspath $(call fwd,$(1)))))

override PATH_VAR := $(call normpath,$(PATH_VAR))
```

### 12.2 Shell Configuration

```makefile
# Set the shell explicitly for portability
SHELL := /bin/sh
.SHELLFLAGS := -c
```

### 12.3 Tool Paths

```makefile
# Tools via variables, not hard-coded
MKDIR := mkdir
RM    := rm

# Or derive from the toolchain
MKDIR := $(CYGWIN_PATH)/mkdir
RM    := $(CYGWIN_PATH)/rm
```

---

## 13. See Also

- [Makefile_Blueprint.md](../blueprints/Makefile.md) — Structure template
- [Makefile_Build_System_Concept.md](../../../../archive/docs/en/makefile_buildsystem/concepts/Makefile_Build_System_Concept.md) — Reference implementation
- [CMake_Standard.md](CMake_Standard.md) — CMake conventions

---

## 14. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-19** | **Initial: based on TMS320 build system best practices** |
