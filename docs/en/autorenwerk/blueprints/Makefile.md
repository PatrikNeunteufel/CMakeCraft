# Makefile Blueprint

> **Version:** 1.0.0  
> **Date:** 2025-12-19  
> **Type:** Blueprint  
> **Status:** Stable  
> **Target Audience:** Build system developers  
> **Language:** English  
> **German:** [Makefile.md](../../../de/autorenwerk/blueprints/Makefile.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [File Structure](#2-file-structure)
3. [Module Template](#3-module-template)
4. [Main Makefile Template](#4-main-makefile-template)
5. [Diagnostic Target Template](#5-diagnostic-target-template)
6. [Best Practices](#6-best-practices)
7. [Anti-Patterns](#7-anti-patterns)
8. [See Also](#8-see-also)
9. [Changelog](#9-changelog)

---

## 1. Overview

This blueprint defines the structure and conventions for modular Makefiles. It is based on the TMS320F28P65x build system and is applicable to similar embedded projects.

### 1.1 Goals

- **Modularity** — Reusable, independent modules
- **Transparency** — Clear diagnostic options
- **Robustness** — Fail-fast on configuration errors
- **Maintainability** — Uniform structure and conventions

---

## 2. File Structure

### 2.1 Recommended Directory Structure

```
Build/
├── <Project1>_Build/          /* Entry point project 1          */
│   └── Makefile
├── <Project2>_Build/          /* Entry point project 2          */
│   └── Makefile
└── make/
    ├── common/                /* Shared modules                 */
    │   ├── bootstrap.mk       /* Base functions                 */
    │   ├── arguments.mk       /* Argument validation            */
    │   ├── config.mk          /* Global configuration           */
    │   ├── paths.mk           /* Path definitions               */
    │   ├── outputs.mk         /* Output directories             */
    │   ├── toolchain.mk       /* Compiler configuration         */
    │   └── diagnostics.mk     /* Diagnostic targets             */
    ├── <Project1>/            /* Project-specific               */
    │   ├── config.mk
    │   ├── sources.mk
    │   └── rules.mk
    └── <Project2>/
        ├── config.mk
        ├── sources.mk
        └── rules.mk
```

### 2.2 Module Categories

| Category | Responsibility | Examples |
|-----------|-------------------|-----------|
| **Bootstrap** | Base functions, argument checks | `bootstrap.mk`, `arguments.mk` |
| **Configuration** | Paths, toolchain, ABI | `config.mk`, `paths.mk`, `toolchain.mk` |
| **Outputs** | Directories, artifacts | `outputs.mk` |
| **Rules** | Compile/link rules | `rules.mk` |
| **Diagnostics** | Debug/check targets | `diagnostics.mk` |

---

## 3. Module Template

### 3.1 Basic Structure

```makefile
# <module_name>.mk - <short description>
# <optional details>
# !!!!!!!!!!!!!!!!!!!!!!!!! DON'T TOUCH WITHOUT ANY GOOD REASON !!!!!!!!!!!!!!!!!!!!!!
$(info *** parsing <module_name>.mk ***)
$(info )

# ==== <Section 1> ================================================================
# <Description of the section>

VARIABLE1 := value1
VARIABLE2 := value2

# ==== <Section 2> ================================================================

# ... further definitions ...

# Export for subsequent modules/recursive calls
export VARIABLE1 VARIABLE2

# ==== Diagnostic target ==========================================================
.PHONY: check-<module>

check-<module>:
	@echo "*** Check <Module> ***"
	@echo "**********************"
	@echo "VARIABLE1= $(VARIABLE1)"
	@echo "VARIABLE2= $(VARIABLE2)"
	@echo ""
```

### 3.2 Helper Functions

```makefile
# Path normalization (\ to /, resolve /..)
fwd      = $(subst \,/,$(1))
normpath = $(strip $(call fwd,$(abspath $(call fwd,$(1)))))

# Existence checks
_require_dir  = $(if $(wildcard $(1)/.),,$(error [FATAL] Missing directory: "$(1)" - $(2)))
_require_file = $(if $(wildcard $(1)),,$(error [FATAL] Missing file: "$(1)" - $(2)))
```

---

## 4. Main Makefile Template

```makefile
# Makefile for <Project>
# ######################

# Bootstrap (if not using common/bootstrap.mk)
fwd      = $(subst \,/,$(1))
normpath = $(strip $(call fwd,$(abspath $(call fwd,$(1)))))

# ==== Argument validation ========================================================
ProjectDir ?= Unknown
ifeq ($(ProjectDir),Unknown)
  $(error [FATAL] Argument ProjectDir was not provided!)
endif
override ProjectDir := $(call normpath,$(ProjectDir))

# ==== Include common modules (order is critical!) ================================
include ${ProjectDir}/Build/make/common/arguments.mk
include ${ProjectDir}/Build/make/common/config.mk
include ${ProjectDir}/Build/make/common/paths.mk
include $(ProjectDir)/Build/make/common/outputs.mk
include $(ProjectDir)/Build/make/common/toolchain.mk
include ${ProjectDir}/Build/make/common/diagnostics.mk

# ==== Include project-specific modules ===========================================
include ${ProjectDir}/Build/make/<Project>/config.mk
include ${ProjectDir}/Build/make/<Project>/sources.mk
include ${ProjectDir}/Build/make/<Project>/rules.mk
```

---

## 5. Diagnostic Target Template

### 5.1 Single Check Target

```makefile
.PHONY: check-<aspect>

check-<aspect>:
	@echo "*** Check <Aspect> ***"
	@echo "**********************"
	@echo "VAR1= $(VAR1)"
	@echo "VAR2= $(VAR2)"
	@echo ""
```

### 5.2 Meta Target (check-all)

```makefile
# diagnostics.mk
.PHONY: check-all

check-all: check-arguments check-paths check-outputs check-abi check-rules
	@echo "*** All checks completed ***"
```

### 5.3 Ad-hoc Variable Inspection

```makefile
# In rules.mk or diagnostics.mk
print-%:
	@echo '$*=$($*)'
```

---

## 6. Best Practices

### 6.1 Variables

| Rule | Example |
|-------|----------|
| **UPPER_CASE** for exported variables | `CG_TOOL_ROOT`, `CFLAGS` |
| **Immediate expansion (`:=`)** for paths | `OUT_DIR := $(ProjectDir)/out` |
| **Deferred expansion (`=`)** for dependent values | `GLOBAL_LIB = $(OUT_DIR)/lib.a` |
| **Override** for argument normalization | `override ProjectDir := $(call normpath,...)` |

### 6.2 Comments

```makefile
# ==== Section Header (4 = signs, 80 chars total) =================================
# A single line explains the purpose

# Multi-line explanation for complex logic:
# - Point 1
# - Point 2
```

### 6.3 Error Handling

```makefile
# Fail-fast pattern
ifeq ($(REQUIRED_VAR),)
  $(error [FATAL] REQUIRED_VAR is empty or not set)
endif

# Validation with context
$(call _require_dir,$(TOOL_PATH),Toolchain not found - check TI_BASE)
```

### 6.4 Shell Commands

```makefile
# Always with @ for clean output
@echo [CC] $<

# With SHELL for portability
@$(SHELL) -c 'if [ -d "$(DIR)" ]; then rm -rf "$(DIR)"; fi'

# Error check after a command
@[ -f "$@" ] || (echo "[FATAL] Compilation failed"; exit 2)
```

---

## 7. Anti-Patterns

### 7.1 Avoid

| Anti-pattern | Problem | Better |
|--------------|---------|--------|
| Hardcoded paths | Not portable | Arguments or derived paths |
| Inconsistent tabs vs. spaces | Make requires tabs in recipes | Consistently tabs in recipes |
| Global variables without export | Recursive calls fail | `export VAR` |
| Missing `.PHONY` | Conflicts with files of the same name | Always declare |
| No diagnostic targets | Debugging made harder | `check-*` targets |

### 7.2 Examples

```makefile
# ❌ Bad: hardcoded path
CC := D:/TI/CCS1281/ccs/tools/compiler/bin/cl2000

# ✅ Good: derived path
CC := $(CG_TOOL_ROOT)/bin/cl2000

# ❌ Bad: no error check
$(CC) $(CFLAGS) -o $@ $<

# ✅ Good: with error check
@"$(CC)" $(CFLAGS) -o "$@" "$<"
@[ -f "$@" ] || (echo "[FATAL] Compilation failed: $<"; exit 2)
```

---

## 8. See Also

- [Makefile_Standard.md](../standards/Makefile_Standard.md) — Coding conventions
- [Makefile_Build_System_Concept.md](../../../../archive/docs/de/makefile_buildsystem/concepts/Makefile_Build_System_Concept.md) — Reference implementation

---

## 9. Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.0** | **2025-12-19** | **Initial: based on the TMS320 build system** |
