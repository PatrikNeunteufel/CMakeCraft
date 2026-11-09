# C Coding Standard — Style Guidelines for Embedded

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Standard  
> **Status:** Stable  
> **Target Audience:** Embedded developers, firmware developers  
> **Scope:** All C projects (embedded, firmware)  
> **Enforcement:** clang-tidy, MISRA checker, code review  
> **Language:** English  
> **German:** [C_Coding_Standard.md](../../../de/autorenwerk/standards/C_Coding_Standard.md)

---

## Table of Contents

1. [Purpose and Scope](#1-purpose-and-scope)
2. [Language Version and Compiler](#2-language-version-and-compiler)
3. [Basic Principles](#3-basic-principles)
4. [File Header](#4-file-header)
5. [File and Module Organization](#5-file-and-module-organization)
6. [Formatting](#6-formatting)
7. [Naming Conventions](#7-naming-conventions)
8. [Struct Layout](#8-struct-layout)
9. [Types and Data](#9-types-and-data)
10. [Pointers and Memory](#10-pointers-and-memory)
11. [Control Flow](#11-control-flow)
12. [Error Handling](#12-error-handling)
13. [Concurrency and Interrupts](#13-concurrency-and-interrupts)
14. [Hardware Access](#14-hardware-access)
15. [Documentation](#15-documentation)
16. [MISRA and CERT](#16-misra-and-cert)
17. [Tests and Static Analysis](#17-tests-and-static-analysis)
18. [Relationship to C++ (PC)](#18-relationship-to-c-pc)
19. [Legacy Code and Exceptions](#19-legacy-code-and-exceptions)
20. [See Also](#20-see-also)
21. [Changelog](#21-changelog)

---

## 1. Purpose and Scope

This standard defines **coding conventions for C** in the company, with a focus on **embedded systems and firmware**.

### Target Audience

This standard is aimed at developers who write C code for embedded systems, firmware and safety-critical applications. It is mandatory for all new embedded projects.

### Area of Application

| Language | Focus | Typical Projects |
|----------|-------|------------------|
| C | Embedded | Firmware, MCUs, safety-critical parts, real-time |
| **C++** | PC applications | Tools, GUIs, services |

### Alignment

This standard is oriented towards:
- **MISRA C:2012** — safety, robustness, UB avoidance
- **SEI CERT C** — secure, defensive C programming

---

## 2. Language Version and Compiler

### 2.1 Standard Version

| Project Type | C Standard |
|--------------|------------|
| New embedded projects | **C99** (minimum) |
| With toolchain support | C11 allowed |

### 2.2 Compiler Extensions

Allowed **only if**:
- Necessary for hardware access/performance/memory layout
- Clearly documented at an abstraction boundary

### 2.3 Undefined Behavior

> Code must **never** rely on undefined behavior or unspecified behavior.

---

## 3. Basic Principles

1. **Determinism and predictability** over maximum performance
2. **Safety and robustness** over clever constructs
3. **Simplicity and clarity** over over-engineering
4. **Statically analyzable** — code must be checkable

---

## 4. File Header

### 4.1 Standard Header for C Files

Every `.h` and `.c` file **must** begin with the following Doxygen-compatible header:

```c
/**
 ****************************************************************************************
 * @file   filename.h
 * @brief  Short description
 *         Optional second line for context
 *
 * @author Author Name
 * @date   Month YYYY
 ****************************************************************************************
 */
```

### 4.2 Mandatory Fields

| Field | Description |
|-------|-------------|
| `@file` | Exact file name |
| `@brief` | Short description (1-2 lines) |
| `@author` | Main author |
| `@date` | Creation date (month year) |

### 4.3 Optional Fields

| Field | Usage |
|-------|-------|
| `@version` | For versioned components |
| `@copyright` | For special licenses |
| `@see` | References to related files |
| `@note` | Important notes (e.g. hardware dependencies) |

### 4.4 Example

```c
/**
 ****************************************************************************************
 * @file   gpio_driver.h
 * @brief  GPIO Driver Interface
 *         Low-level GPIO control for TMS320F28P65x
 *
 * @author Patrik Neunteufel
 * @date   December 2025
 * @note   Hardware: TMS320F28P650DK
 ****************************************************************************************
 */

#ifndef GPIO_DRIVER_H
#define GPIO_DRIVER_H

#include <stdint.h>
// ...
```

### 4.5 Language

- **English** is mandatory for all public APIs and reusable modules
- Project-specific internal files may use German

---

## 5. File and Module Organization

### 5.1 File Names

| Rule | Example |
|------|---------|
| **PascalCase** | `GpioDriver.h`, `TimerConfig.c` |
| **Same as module/main type** | Module `Timer` → `Timer.h`, `Timer.c` |
| **Module prefix if needed** | `EpwmRegs.h`, `AdcHal.c` |

### 5.2 File Extensions

| Extension | Usage |
|-----------|-------|
| `.h` | C header |
| `.c` | C implementation |

### 5.3 Folder Names

| Rule | Example |
|------|---------|
| **lowercase** | `source/`, `include/`, `drivers/` |
| **snake_case** | `hal_layer/`, `device_support/` |

### 5.4 Include Guards

```c
#ifndef MODULE_NAME_H
#define MODULE_NAME_H

// ... content ...

#endif /* MODULE_NAME_H */
```

Or `#pragma once` (if project guideline and toolchain support allow it).

### 5.5 Include Order

```c
// 1. Associated header
#include "Timer.h"

// 2. Standard headers
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

// 3. Platform/vendor headers
#include "device.h"
#include "F28x_Project.h"

// 4. Project headers
#include "hal/Gpio.h"
#include "config/BoardConfig.h"
```

---

## 6. Formatting

### 6.1 Authority

- Formatting via `clang-format` (where available)
- For embedded toolchains without clang-format: manual compliance

### 6.2 Overview

| Aspect | Rule |
|--------|------|
| Indentation | 4 spaces |
| Tabs | Never use |
| Braces | **Allman style** (new line) |
| Line length | 80-100 characters |
| Pointers | Left-aligned (`int* ptr`) |

### 6.3 Brace Style (Allman)

```c
// Functions
void function(void)
{
    // ...
}

// Structs
typedef struct
{
    uint32_t value;
    uint16_t flags;
} DataPacket;

// Control structures
if (condition)
{
    // ...
}
else
{
    // ...
}

// Loops
for (int i = 0; i < count; ++i)
{
    // ...
}
```

### 6.4 Spaces

```c
// After commas
function(a, b, c);

// Around operators
x = a + b * c;

// Before parentheses in control structures
if (condition)
while (running)
for (i = 0; i < n; i++)

// No spaces inside parentheses
function(a);      // ✅
function( a );    // ❌
```

---

## 7. Naming Conventions

### 7.1 Overview

| Entity | Convention | Example |
|--------|------------|---------|
| Module function | `module_snake_case` | `timer_init()`, `gpio_set_pin()` |
| Local variable | `snake_case` | `current_index`, `buffer_size` |
| Global variable | `g_` + `snake_case` | `g_system_state` |
| Static variable | `s_` + `snake_case` | `s_buffer_index` |
| Constant/macro | `UPPER_CASE` | `MAX_BUFFER_SIZE`, `ADC_TIMEOUT` |
| Type alias | `PascalCase` or `_t` suffix | `TimerHandle`, `gpio_pin_t` |
| Struct member | `snake_case` | `data_length`, `is_valid` |

### 7.2 Module Prefix

Functions receive a module prefix to emulate namespaces:

```c
// Timer module
void timer_init(void);
void timer_start(TimerHandle handle);
void timer_stop(TimerHandle handle);

// GPIO module
void gpio_init(void);
void gpio_set_pin(uint8_t pin, bool state);
uint8_t gpio_read_pin(uint8_t pin);

// EPWM module
void epwm_configure(uint16_t period);
void epwm_set_duty(uint16_t cmpa, uint16_t cmpb);
```

### 7.3 Prefixes

| Prefix | Meaning | Example |
|--------|---------|---------|
| `g_` | Global variable | `g_system_ticks` |
| `s_` | Static variable (file scope) | `s_initialized` |
| `p` | Pointer | `pBuffer`, `pConfig` |
| `m_` | Member (in struct contexts, optional) | `m_state` |
| — | Local variable / parameter | `count`, `index`, `value` |

### 7.4 Register Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Register struct | `UPPER_CASE` + `_REGS` | `EPWM_REGS` |
| Bit field | `snake_case` or vendor style | `TBCTL.bit.CTRMODE` |
| Register address | `UPPER_CASE` + `_BASE` | `EPWM1_BASE` |

---

## 8. Struct Layout

### 8.1 Order of Elements

```c
/**
 * @brief Configuration structure for Timer module
 */
typedef struct
{
    /* ═══════════════════════════════════════════════════════════════ */
    /* Configuration Parameters                                        */
    /* ═══════════════════════════════════════════════════════════════ */
    uint32_t period;            /**< Timer period in ticks */
    uint16_t prescaler;         /**< Clock prescaler value */
    uint8_t  mode;              /**< Operating mode */

    /* ═══════════════════════════════════════════════════════════════ */
    /* State Variables                                                 */
    /* ═══════════════════════════════════════════════════════════════ */
    volatile uint32_t counter;  /**< Current counter value */
    volatile bool     running;  /**< Timer running flag */

    /* ═══════════════════════════════════════════════════════════════ */
    /* Callbacks                                                       */
    /* ═══════════════════════════════════════════════════════════════ */
    void (*callback)(void);     /**< Overflow callback function */
} TimerConfig;
```

### 8.2 Alignment and Padding

```c
// ✅ Good: larger types first (minimizes padding)
typedef struct
{
    uint32_t timestamp;     // 4 bytes
    uint16_t id;            // 2 bytes
    uint8_t  flags;         // 1 byte
    uint8_t  reserved;      // 1 byte (explicit padding)
} Message;  // Total: 8 bytes, no hidden padding

// ❌ Bad: inefficient layout
typedef struct
{
    uint8_t  flags;         // 1 byte + 3 padding
    uint32_t timestamp;     // 4 bytes
    uint8_t  id;            // 1 byte + 3 padding
} BadMessage;  // Total: 12 bytes with hidden padding
```

### 8.3 Best Practices

- **Documentation** for every member (Doxygen `/**< */`)
- **Explicit padding** instead of implicit compiler padding
- **`volatile`** for data shared with ISRs
- **`const`** for immutable configuration

### 8.4 Bitfield Abbreviations

For bitfield unions, use the following abbreviations for the union members:

| Abbreviation | Type | Bits |
|--------------|------|------|
| `b` | bit (struct) | variable |
| `c` | char | 8 |
| `s` | short | 16 |
| `l` | long | 32 |
| `f` | float | 32 |
| `d` | double | 64 |
| `ll` | long long | 64 |

```c
// Register with bitfield access
typedef union
{
    struct
    {
        uint16_t enable   : 1;   /**< Bit 0: Enable flag */
        uint16_t mode     : 2;   /**< Bit 1-2: Operating mode */
        uint16_t reserved : 13;  /**< Bit 3-15: Reserved */
    } b;                         /**< Bitfield access */
    uint16_t s;                  /**< 16-bit access */
} ControlReg;

// 32-bit register
typedef union
{
    struct
    {
        uint32_t counter : 24;   /**< Bit 0-23: Counter value */
        uint32_t status  : 8;    /**< Bit 24-31: Status flags */
    } b;                         /**< Bitfield access */
    uint32_t l;                  /**< 32-bit access */
} TimerReg;

// Usage
ControlReg ctrl;
ctrl.s = 0;              // Clear the whole register
ctrl.b.enable = 1;       // Set a single bit
ctrl.b.mode = 2;         // Set a bit field
```

### 8.5 Union Basics

Unions allow several interpretations of the same memory area.

| Application | Description |
|-------------|-------------|
| Register access | Bitfield + whole-word access (see §8.4) |
| Type punning | Caution: can be UB, prefer `memcpy` |
| Variant data | Different types in the same memory |
| Protocol parsing | Header + body overlays |

```c
// ✅ Good: union for register access
typedef union
{
    struct
    {
        uint16_t enable : 1;
        uint16_t mode   : 3;
        uint16_t rsvd   : 12;
    } b;
    uint16_t s;
} ConfigReg;

// ✅ Good: union for variant data with a tag
typedef struct
{
    uint8_t type;           // Tag: which type is active
    union
    {
        int32_t  intValue;
        float    floatValue;
        uint8_t  bytes[4];
    } data;
} Variant;

// ⚠️ Caution: type punning via union
// Technically UB in C (except for char), but often tolerated
union FloatBits
{
    float f;
    uint32_t bits;
};
// Safer: use memcpy
```

**Best practices:**
- Always use with a tag field if the type is variable
- For registers: bitfield + whole-word member
- Document explicitly which member is active
- Size validation with `static_assert` or `_Static_assert`

---

## 9. Types and Data

### 9.1 Fixed-Width Types

Use `<stdint.h>` where size matters:

| Type | Usage |
|------|-------|
| `uint8_t`, `int8_t` | Byte data |
| `uint16_t`, `int16_t` | 16-bit values |
| `uint32_t`, `int32_t` | 32-bit values |
| `size_t` | Sizes and indices |
| `bool` (C99) | Boolean values |

### 9.2 Signed/Unsigned

- **No mixing** without explicit handling
- Handle truncation and sign extension deliberately

---

## 10. Pointers and Memory

### 10.1 Pointer Rules

| Rule | Description |
|------|-------------|
| No wild pointer arithmetic | Except simple, bounded, documented |
| Validation | Check pointers before dereferencing |
| `const` correctness | Documents intent |

```c
// ✅ const-correct
void processData(const uint8_t* data, size_t length);

// ✅ Pointer to constant pointer
const char* const MESSAGE = "Hello";
```

### 10.2 Dynamic Allocation

| Rule | Embedded Context |
|------|------------------|
| **Avoid at runtime** | Do not use `malloc`/`free` |
| Only in the init phase | If unavoidable, document it |
| Fallback strategy | Document what happens on failure |

### 10.3 Ownership

- Every dynamically allocated resource has **one clear owner**
- Ownership transfer is **explicit** in function names/documentation

---

## 11. Control Flow

### 11.1 Structured Code

Allowed:
- `if` / `else`
- `switch` / `case`
- `for` / `while` / `do-while`

### 11.2 goto

**Avoid in general.** Allowed only for:
- Controlled error handling with cleanup
- Within a single function

```c
int processFile(const char* path)
{
    FILE* file = NULL;
    int result = -1;
    
    file = fopen(path, "r");
    if (!file)
    {
        goto cleanup;
    }
    
    // ... processing ...
    
    result = 0;
    
cleanup:
    if (file)
    {
        fclose(file);
    }
    return result;
}
```

### 11.3 Functions

- **One clear responsibility** per function
- Not excessively long (guideline: 50-100 lines)

### 11.4 Multiple Conditions

With several conditions: **put each condition in parentheses** for clarity and MISRA conformance.

```c
// ✅ Correct: each condition in parentheses
if ((value > MIN_VALUE) && (value < MAX_VALUE))
{
    // ...
}

if ((condition1) && (condition2) || (condition3))
{
    // ...
}

// ❌ Wrong: no parentheses
if (value > MIN_VALUE && value < MAX_VALUE)
{
    // ...
}
```

### 11.5 Division — Check the Divisor

Division by 0 can lead to undefined behavior or a processor crash. **Always check the divisor.**

```c
// ✅ Safe: validate the divisor
if (divisor == 0)
{
    divisor = 1;  // Default value or error handling
}
result = value / divisor;

// Alternatively: explicit error handling
if (divisor == 0)
{
    return RESULT_ERROR_DIVISION_BY_ZERO;
}
result = value / divisor;
```

---

## 12. Error Handling

### 12.1 No Exceptions

C uses **return codes** and **out parameters**:

```c
typedef enum
{
    RESULT_OK = 0,
    RESULT_ERROR_INVALID_PARAM,
    RESULT_ERROR_TIMEOUT,
    RESULT_ERROR_HARDWARE
} Result;

Result sensor_read(uint16_t* outValue);
```

### 12.2 Checking Return Values

**Every return value must:**
- Be checked, or
- Be ignored explicitly with a comment

```c
// ✅ Checked
Result result = sensor_read(&value);
if (result != RESULT_OK)
{
    handleError(result);
}

// ✅ Explicitly ignored
(void)printf("Debug: %d\n", value);  // Return value irrelevant
```

### 12.3 Error Code Design

- Enumerated and documented
- Unique codes per module
- Mapping to logging/diagnostics

---

## 13. Concurrency and Interrupts

### 13.1 Shared Data

Data shared between interrupt and main context:

| Requirement | Mechanism |
|-------------|-----------|
| `volatile` | For registers and ISR flags |
| Atomic operations | For multi-byte values |
| Critical sections | Disable interrupts where necessary |

### 13.2 Guidelines

- **Keep critical sections minimal**
- **Avoid race conditions by design**
- **No trial-and-error synchronization**

```c
// ✅ Atomic access
static volatile uint32_t s_tick_counter;

void SysTick_Handler(void)
{
    s_tick_counter++;
}

uint32_t getTicks(void)
{
    uint32_t ticks;
    __disable_irq();
    ticks = s_tick_counter;
    __enable_irq();
    return ticks;
}
```

---

## 14. Hardware Access

### 14.1 Register Handling

| Rule | Description |
|------|-------------|
| `volatile` | For all hardware registers |
| Encapsulation | In dedicated modules/drivers |
| No magic addresses | Use named constants |

### 14.2 Register Definition

```c
// ✅ Structured access
typedef struct
{
    volatile uint32_t CR;      // Control Register
    volatile uint32_t SR;      // Status Register
    volatile uint32_t DR;      // Data Register
} UART_TypeDef;

#define UART1 ((UART_TypeDef*)0x40011000UL)
```

### 14.3 Documentation

- Document endianness
- Document alignment requirements
- Mark memory-mapped I/O

---

## 15. Documentation

### 15.1 TODO Markers

For unfinished tasks, ideas or problems to be fixed: use `TODO` in the comment.

```c
// TODO: Implement timeout handling
// TODO: Optimize buffer allocation
// TODO: Add error recovery for communication failure
```

IDEs can detect and list TODO markers automatically (e.g. MPLAB-X: Window → Action Items, VS Code: Todo Tree extension).

### 15.2 Code Comments

| Comment Type | Usage |
|--------------|-------|
| `//` | Short inline comments, temporary notes |
| `/* */` | Multi-line comments, section headers |
| `/** */` | Doxygen documentation |

### 15.3 Function Documentation

Document public functions with Doxygen:

```c
/**
 * @brief  Initialize the timer module
 * @param  config Pointer to configuration structure
 * @return RESULT_OK on success, error code otherwise
 * @note   Must be called before any other timer function
 */
Result timer_init(const TimerConfig* config);
```

| Tag | Usage |
|-----|-------|
| `@brief` | Short description (mandatory) |
| `@param` | Parameter description |
| `@return` | Return value |
| `@note` | Important notes |
| `@warning` | Warnings, limitations |
| `@see` | Related functions |

### 15.4 Language

| Context | Language |
|---------|----------|
| Public APIs | **English** (mandatory) |
| Reusable modules | **English** (mandatory) |
| Project-internal files | German allowed |
| Commit messages | English recommended |

---

## 16. MISRA and CERT

### 16.1 MISRA C:2012 Alignment

| Category | Implementation |
|----------|----------------|
| Types | Fixed width, no implicit conversions |
| Control flow | Structured, no unreachable code |
| Pointers | Validation, limited arithmetic |
| UB avoidance | No dependency on undefined behavior |

### 16.2 SEI CERT C Alignment

| Category | Implementation |
|----------|----------------|
| Input validation | Check all external inputs |
| Integer handling | Handle overflow/truncation deliberately |
| Buffer handling | Check bounds |
| Resources | No leaks, clear ownership |

### 16.3 Compliance Documentation

Projects with a MISRA/CERT claim document:
- Applicable rules
- Justified deviations

---

## 17. Tests and Static Analysis

### 17.1 Tests

| Test Type | Description |
|-----------|-------------|
| Unit tests | Where practicable (PC-hosted) |
| Integration tests | On target hardware or in simulation |

### 17.2 Static Analysis

Recommended tools:
- `clang-tidy` (PC build)
- Vendor-specific checkers
- MISRA checker

Warnings with safety relevance **must** be fixed or justified.

---

## 18. Relationship to C++ (PC)

### 18.1 Differences

| Aspect | C (Embedded) | C++ (PC) |
|--------|--------------|----------|
| Exceptions | No | Yes |
| Dynamic allocation | Avoid | Allowed |
| Standard library | Minimal | Full |
| Abstraction | Procedural | OOP allowed |

### 18.2 Shared Components

Interfaces between C and C++:

```c
// header.h
#ifdef __cplusplus
extern "C" {
#endif

void shared_function(int param);

#ifdef __cplusplus
}
#endif
```

---

## 19. Legacy Code and Exceptions

### 19.1 Legacy Code

- Temporarily allowed if not compliant
- New code **always** according to the standard
- Use refactoring opportunities

### 19.2 Intentional Deviations

- Comment in the code
- Document the justification
- Minimize the scope

---

## 20. See Also

- [Cpp_Coding_Standard.md](Cpp_Coding_Standard.md) — C++ (PC)
- [CMake_Standard.md](CMake_Standard.md) — Build system
- [Git_Standard.md](Git_Standard.md) — Version control
- MISRA C:2012 Guidelines
- SEI CERT C Coding Standard

---

## 21. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: examples follow the document's own rules — includes `Timer.h`, `hal/Gpio.h`, `config/BoardConfig.h` (§5.5 per §5.1 PascalCase), `g_`/`s_` variables in `snake_case` (§7.1, §7.3, §13); changelog 0.8.0: TODO markers are in §15.1 today** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.10.0 | 2025-12-19 | New: union basics (8.5) with best practices and examples |
| 0.9.0 | 2025-12-19 | New: bitfield abbreviations (8.4), chapter Documentation (15) with TODO, code comments, function documentation |
| 0.8.0 | 2025-12-19 | New: TODO markers (3.1, in §15.1 since 0.9.0), multiple conditions in parentheses (11.4), check division by 0 (11.5) |
| 0.7.0 | 2025-12-19 | Unification: file names in PascalCase (like C++), prefix table simplified |
| 0.6.0 | 2025-12-19 | Consolidation: new section 8 struct layout, file naming conventions (5.1), include order (5.5), register conventions (7.4), extended prefix table (7.3) |
| 0.5.1 | 2025-12-18 | New section 4: file header with Doxygen format, mandatory fields, language rule |
| 0.5.0 | 2025-12-13 | Migration to Blueprint v0.5: new header, table of contents, encoding fix |
| 0.1.0 | 2025-12-05 | Initial: embedded focus, MISRA/CERT alignment, interrupt handling |
