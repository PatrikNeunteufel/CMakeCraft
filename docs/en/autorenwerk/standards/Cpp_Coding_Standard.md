# C++ Coding Standard — Style Guidelines

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Standard  
> **Status:** Stable  
> **Target Audience:** All C++ developers  
> **Scope:** All C++ projects (PC applications, tools, drivers)  
> **Enforcement:** clang-format, clang-tidy, code review  
> **Language:** English  
> **German:** [Cpp_Coding_Standard.md](../../../de/autorenwerk/standards/Cpp_Coding_Standard.md)

---

## Table of Contents

1. [Purpose and Scope](#1-purpose-and-scope)
2. [Language Version and Features](#2-language-version-and-features)
3. [Basic Principles](#3-basic-principles)
4. [File Header](#4-file-header)
5. [File and Module Organization](#5-file-and-module-organization)
6. [Formatting](#6-formatting)
7. [Naming Conventions](#7-naming-conventions)
8. [Classes and Structures](#8-classes-and-structures)
9. [Types, Ownership and Lifetime](#9-types-ownership-and-lifetime)
10. [Error Handling](#10-error-handling)
11. [Concurrency](#11-concurrency)
12. [Hardware Access (Optional)](#12-hardware-access-optional)
13. [Static Analysis](#13-static-analysis)
14. [Test Code](#14-test-code)
15. [Documentation](#15-documentation)
16. [Relationship to C (Embedded)](#16-relationship-to-c-embedded)
17. [Legacy Code and Exceptions](#17-legacy-code-and-exceptions)
18. [MISRA/CERT Alignment](#18-misracert-alignment)
19. [See Also](#19-see-also)
20. [Changelog](#20-changelog)

---

## 1. Purpose and Scope

This standard defines **coding conventions for C++** in the company.

### Target Audience

This standard is aimed at all developers who write C++ code for PC applications. It is mandatory for new projects and recommended for existing code during refactoring.

### Area of Application

| Language | Focus | Typical Projects |
|----------|-------|------------------|
| **C++** | PC applications | Tools, GUIs, services, test programs, libraries |
| C | Embedded | Firmware, MCUs, safety-critical parts |

This standard is complemented by:
- **C_Coding_Standard** — embedded-specific
- **CMake_Standard** — build system
- **ClangFormat_Blueprint** — formatting
- **ClangTidy_Blueprint** — static analysis

### Tool Authority

> In case of conflicts between documentation and tool configuration, `.clang-format` and `.clang-tidy` are the **binding implementation**.

---

## 2. Language Version and Features

### 2.1 Standard Version

| Project Type | C++ Standard |
|--------------|--------------|
| New projects | **C++20** (default) |
| Legacy projects | Documented in the README |

### 2.2 Recommended Features

| Feature | Usage |
|---------|-------|
| `enum class` | Strongly typed enums |
| RAII | All resources |
| Smart pointers | Ownership management |
| `std::string_view` | Non-owning string reference |
| `std::optional` | Optional values |
| `constexpr` | Compile-time computations |
| Concepts (C++20) | Template constraints |

### 2.3 Features to Avoid

| Feature | Alternative |
|---------|-------------|
| Direct `new`/`delete` | `std::make_unique`, `std::make_shared` |
| C-style casts | `static_cast`, `dynamic_cast`, etc. |
| `#define` for constants | `constexpr`, `const` |
| Raw arrays | `std::array`, `std::vector` |

---

## 3. Basic Principles

1. **Readability over cleverness**
2. **Safety and correctness over premature optimization**
3. **Consistency over personal preference**
4. **Automated tools over manual style discussions**

---

## 4. File Header

### 4.1 Standard Header for C++ Files

Every `.hpp` and `.cpp` file **must** begin with the following Doxygen-compatible header:

```cpp
/**
 ****************************************************************************************
 * @file   Filename.hpp
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

### 4.4 Example

```cpp
/**
 ****************************************************************************************
 * @file   AudioEngine.hpp
 * @brief  Audio Engine Interface
 *         Provides high-level audio playback and management
 *
 * @author Patrik Neunteufel
 * @date   December 2025
 ****************************************************************************************
 */

#pragma once

#include <memory>
// ...
```

### 4.5 Language

- **English** is mandatory for all public APIs and templates
- Internal/project-specific files may use German; English is recommended

---

## 5. File and Module Organization

### 5.1 File Names

| Rule | Example |
|------|---------|
| **PascalCase** | `FileManager.hpp`, `DataProcessor.cpp` |
| **Same as the class** | Class `Logger` → `Logger.hpp` |
| **DLL exception** | Suffix `Class`: `LoggerClass.hpp` |
| **PIMPL** | Suffix `Impl`: `LoggerImpl.hpp` |
| **Interface** | Prefix `I`: `ILogger.hpp` |

### 5.2 File Extensions

| Extension | Usage |
|-----------|-------|
| `.hpp` | C++ header |
| `.cpp` | C++ implementation |
| `.tpp` | Template implementation |
| `.inl` | Inline definitions |
| `.h` | C header (or C-compatible C++ header) |
| `.c` | C implementation |

### 5.3 Folder Names

| Rule | Example |
|------|---------|
| **lowercase** | `source/`, `include/`, `tests/` |
| **snake_case if needed** | `user_data/` |

### 5.4 Header Guards

```cpp
// Pragma once (preferred)
#pragma once

// Or classic
#ifndef PROJECT_MODULE_HEADER_HPP
#define PROJECT_MODULE_HEADER_HPP
// ...
#endif
```

### 5.5 Include Order

```cpp
// 1. Precompiled header (if present)
#include "pch/pch.h"

// 2. Associated header
#include "MyClass.hpp"

// 3. System headers
#include <string>
#include <vector>
#include <memory>

// 4. Project headers
#include "utils/Logger.hpp"
#include "core/Config.hpp"
```

> **Note:** clang-format sorts includes automatically according to `.clang-format`.

---

## 6. Formatting

### 6.1 Authority

- All formatting via `clang-format`
- Manual deviations are not allowed
- In case of problems: adjust `.clang-format`, do not bypass it

### 6.2 Overview (Details in `.clang-format`)

| Aspect | Rule |
|--------|------|
| Base style | LLVM with adjustments |
| Indentation | 4 spaces |
| Tabs | Never use |
| Braces | **Allman style** (new line) |
| Line length | 80 characters |
| Pointers | Left-aligned (`int* ptr`) |

### 6.3 Brace Style (Allman)

```cpp
// Functions
void function()
{
    // ...
}

// Classes
class Example
{
public:
    void method();
};

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

```cpp
// After commas
function(a, b, c);

// Around operators
x = a + b * c;

// Before parentheses
if (condition)
while (running)
for (auto& item : items)

// No spaces inside parentheses
function(a);      // ✅
function( a );    // ❌
```

---

## 7. Naming Conventions

### 7.1 Authority

- Naming rules via `clang-tidy` (`readability-identifier-naming`)
- Fix violations, do not suppress them

### 7.2 Overview

| Entity | Convention | Example |
|--------|------------|---------|
| Namespace | `lower_case` | `audio`, `core_utils` |
| Class/struct | `PascalCase` | `LogManager`, `AudioBuffer` |
| Interface | `I` + `PascalCase` | `ILogger`, `ISerializable` |
| Enum | `PascalCase` | `LogLevel` |
| Enum constant | `PascalCase` | `LogLevel::Info`, `LogLevel::Error` |
| Function/method | `camelCase` | `writeLog()`, `processData()` |
| Parameter | `camelCase` | `filePath`, `bufferSize` |
| Local variable | `camelCase` | `currentIndex`, `tempValue` |
| Member variable | `m_` prefix | `m_buffer`, `m_logger` |
| Global constant | `UPPER_CASE` | `MAX_BUFFER_SIZE` |
| Global variable | `g_` prefix | `g_logger` |
| Static variable | `s_` prefix | `s_cache` |
| Template parameter | `T` + `PascalCase` | `TValue`, `TContainer` |
| Macros | `UPPER_CASE` | `DEBUG_LOG(...)` |

### 7.3 Prefixes

| Prefix | Meaning | Example |
|--------|---------|---------|
| `m_` | Member variable | `m_name`, `m_count` |
| `s_` | Static variable | `s_instance` |
| `g_` | Global variable | `g_config` (avoid!) |
| `p` | Pointer (local or parameter) | `pBuffer`, `pConfig` |
| `m_p` | Member pointer | `m_pImpl`, `m_pData` |
| `s_p` | Static pointer | `s_pInstance` |
| — | Local variable / parameter | `count`, `name`, `value` |
| — | Smart pointer member | `m_data` (unique_ptr is not a "raw" pointer) |

### 7.4 Special Cases

| Element | Convention | Example |
|---------|------------|---------|
| **PIMPL class** | `Impl` | `class ExampleImpl;` |
| **Factory methods** | `create...` | `createInstance()` |
| **Getter** | `get...` or noun | `getName()` or `name()` |
| **Setter** | `set...` | `setName()` |
| **Boolean getter** | `is...`, `has...`, `can...` | `isActive()`, `hasData()` |

---

## 8. Classes and Structures

### 8.1 When struct vs. class

| Use | For | Example |
|-----|-----|---------|
| `struct` | POD types, DTOs, aggregates without invariants | `struct Point { int x; int y; };` |
| `class` | Types with invariants, encapsulation, methods | `class FileManager { ... };` |

**Rule of thumb:** If all members are public and there are no invariants to protect → `struct`.

```cpp
// ✅ struct: pure data container
struct ConfigData
{
    std::string name;
    int timeout;
    bool enabled;
};

// ✅ class: encapsulation and invariants
class Connection
{
public:
    explicit Connection(const std::string& host);
    void send(std::span<const std::byte> data);
private:
    Socket m_socket;
    bool m_connected;
};
```


### 8.2 Class Layout

#### Order of Sections

```cpp
class ClassName
{
/* ═══════════════════════════════════════════════════════════════ */
/* Members                                                          */
/* ═══════════════════════════════════════════════════════════════ */
public:     /* Public members (rare) */
protected:  /* Protected members */
private:    /* Private members */

/* ═══════════════════════════════════════════════════════════════ */
/* Constructors / Destructors                                       */
/* ═══════════════════════════════════════════════════════════════ */
public:     /* Public constructors */
protected:  /* Protected constructors (for base classes) */
private:    /* Private constructors (singleton, factory) */

/* ═══════════════════════════════════════════════════════════════ */
/* Methods                                                          */
/* ═══════════════════════════════════════════════════════════════ */
public:     /* Public methods */
protected:  /* Protected methods */
private:    /* Private methods */
};
```

#### Example

```cpp
class FileManager
{
/* Members */
private:
    std::string m_basePath;
    std::vector<FileHandle> m_openFiles;
    static size_t s_instanceCount;

/* Constructors / Destructors */
public:
    explicit FileManager(const std::string& basePath);
    ~FileManager();
    
    FileManager(const FileManager&) = delete;
    FileManager& operator=(const FileManager&) = delete;
    
    FileManager(FileManager&&) noexcept;
    FileManager& operator=(FileManager&&) noexcept;

/* Methods */
public:
    bool openFile(const std::string& name);
    void closeAll();
    
    [[nodiscard]] size_t openFileCount() const;
    [[nodiscard]] bool isFileOpen(const std::string& name) const;

private:
    void validatePath(const std::string& path);
};
```

### 8.3 Struct Layout

Structs follow the same layout rules as in C:

```cpp
// ✅ Good: larger types first (minimizes padding)
struct Message
{
    std::uint64_t timestamp;    // 8 bytes
    std::uint32_t id;           // 4 bytes
    std::uint16_t flags;        // 2 bytes
    std::uint8_t  priority;     // 1 byte
    std::uint8_t  reserved;     // 1 byte (explicit padding)
};  // Total: 16 bytes, no hidden padding
```

**C++20:** `[[no_unique_address]]` for empty members (e.g. allocators).

### 8.4 Union and std::variant

| Use | For | Note |
|-----|-----|------|
| `std::variant` | Type-safe alternative | **Preferred** |
| `union` | Low level, hardware interop, C compatibility | With caution |

```cpp
// ✅ Preferred: std::variant (type-safe)
using Value = std::variant<int, double, std::string>;

Value v = 42;
if (auto* pInt = std::get_if<int>(&v))
{
    // Safe usage
}

// ⚠️ Only if needed: union (for hardware interop)
union RegisterValue
{
    struct
    {
        std::uint16_t low;
        std::uint16_t high;
    } parts;
    std::uint32_t full;
};
```

### 8.5 Bitfields (for Hardware-Related Tools)

For protocol parsers, hardware interop or C API compatibility:

| Abbreviation | Type | Bits |
|--------------|------|------|
| `b` | bit (struct) | variable |
| `c` | char | 8 |
| `s` | short | 16 |
| `l` | long | 32 |
| `ll` | long long | 64 |

```cpp
// Register definition for a hardware tool
union ControlRegister
{
    struct
    {
        std::uint16_t enable   : 1;   // Bit 0
        std::uint16_t mode     : 2;   // Bit 1-2
        std::uint16_t reserved : 13;  // Bit 3-15
    } b;                              // Bitfield access
    std::uint16_t s;                  // 16-bit access
};
```

> **Note:** Bitfield layout is implementation-defined. For portable protocols, bit masks and shifts are the better choice.

### 8.6 Best Practices

```cpp
// [[nodiscard]] for important return values
[[nodiscard]] bool validate();
[[nodiscard]] std::optional<Result> process();

// explicit for single-parameter constructors
class Value
{
public:
    explicit Value(int v);  // Prevents implicit conversion
};

// const-correctness
class Example
{
public:
    [[nodiscard]] int getValue() const;
    [[nodiscard]] const std::string& getName() const;
};
```

---

## 9. Types, Ownership and Lifetime

### 9.1 Fundamental Types

| Requirement | Type |
|-------------|------|
| Size matters | `std::int32_t`, `std::uint64_t` |
| Sizes/indices | `std::size_t` |

### 9.2 Ownership Model

| Ownership | Mechanism | Usage |
|-----------|-----------|-------|
| Exclusive | `std::unique_ptr` | **Default for heap objects** |
| Shared | `std::shared_ptr` | Only when real shared ownership is needed |
| Non-owning | Raw pointer, reference, `std::span` | Temporary references |

### 9.3 Smart Pointers vs. Raw Pointers

**Smart pointers (preferred):**

```cpp
// ✅ Ownership clear, automatic cleanup
auto pResource = std::make_unique<Resource>();
auto pShared = std::make_shared<Config>();
```

**Raw pointers (allowed for non-owning):**

```cpp
// ✅ Non-owning reference (ownership lies elsewhere)
void processData(const Data* pData);

// ✅ Optional parameter (nullptr = not set)
void configure(const Config* pOptionalConfig = nullptr);

// ✅ C API interop
extern "C" void legacyFunction(void* pUserData);

// ❌ Forbidden: owning raw pointer
Resource* pRes = new Resource();  // Who deletes this?
```

**Prefix rule:** Mark raw pointers with the `p` prefix.

| Type | Prefix | Example |
|------|--------|---------|
| Raw pointer (local) | `p` | `pBuffer`, `pConfig` |
| Raw pointer (member) | `m_p` | `m_pImpl`, `m_pData` |
| Smart pointer (member) | `m_` | `m_resource` (no `p`, since not "raw") |

### 9.4 RAII

All resources are managed through RAII:
- Files, sockets, handles
- Memory
- Locks

```cpp
// ✅ RAII
{
    std::unique_ptr<Resource> res = createResource();
    // Automatic cleanup at scope end
}

// ❌ Manual
Resource* res = createResource();
// ... forgotten delete = leak
delete res;
```
---

## 10. Error Handling

### 10.1 Exceptions (C++ PC)

Exceptions are **allowed and expected**:

| Rule | Description |
|------|-------------|
| Throw | By value |
| Catch | By (const) reference |
| Usage | Genuine exceptional situations |
| Do not use for | Normal control flow |

### 10.2 Alternative Error Handling

For low-level code (I/O, OS interfaces):

| Mechanism | Usage |
|-----------|-------|
| `std::error_code` | Expected errors |
| `std::optional<T>` | Optional return |
| `std::expected` (C++23) | Error or value |

### 10.3 Logging

- Use the central logging system (e.g. `LogManager`)
- No `std::cout` / `printf` in production code
- Log or propagate exceptions at boundaries

### 10.4 Multiple Conditions

With several conditions: **put each condition in parentheses** for clarity.

```cpp
// ✅ Correct: each condition in parentheses
if ((value > minValue) && (value < maxValue))
{
    // ...
}

if ((condition1) && (condition2) || (condition3))
{
    // ...
}

// ❌ Wrong: no parentheses
if (value > minValue && value < maxValue)
{
    // ...
}
```

### 10.5 Division — Check the Divisor

Division by 0 leads to undefined behavior. **Validate the divisor** or throw an exception.

```cpp
// ✅ With exception
if (divisor == 0)
{
    throw std::invalid_argument("Division by zero");
}
double result = value / divisor;

// ✅ With optional
std::optional<double> safeDivide(double value, double divisor)
{
    if (divisor == 0.0)
    {
        return std::nullopt;
    }
    return value / divisor;
}
```

---

## 11. Concurrency

### 11.1 Recommended Mechanisms

| Mechanism | Usage |
|-----------|-------|
| `std::thread` / `std::jthread` | Thread creation |
| `std::mutex` / `std::shared_mutex` | Synchronization |
| `std::lock_guard` / `std::unique_lock` | RAII locking |
| `std::atomic<T>` | Atomic operations |

### 11.2 Guidelines

- **No data races** — always protect shared data
- **Short critical sections** — keep locks minimal
- **Prefer thread-safe design** — immutable data, message passing

---

## 12. Hardware Access (Optional)

> **Scope:** Driver development, hardware-related PC tools, system programming

### 12.1 Use Cases

| Context | Examples |
|---------|----------|
| Windows drivers | WDK (Windows Driver Kit) |
| Linux kernel | Kernel modules |
| Hardware tools | Protocol analyzers, debug tools |
| Memory-mapped I/O | Via OS-specific APIs |

### 12.2 Register Access

For hardware tools that need register definitions:

```cpp
// Memory-mapped I/O (via OS API)
volatile std::uint32_t* pRegister = 
    reinterpret_cast<volatile std::uint32_t*>(mappedAddress);

// Read/write
std::uint32_t value = *pRegister;
*pRegister = newValue;
```

> **Important:** Use `volatile` for hardware registers. Access only via OS APIs (no direct addresses in user mode).

### 12.3 Interrupt Handling

On PC systems, interrupts are typically not handled directly:

| Platform | Mechanism |
|----------|-----------|
| Windows user mode | Events, callbacks |
| Windows kernel mode | ISR via WDK |
| Linux user mode | Signals, epoll |
| Linux kernel mode | IRQ handler |

For most C++ PC applications, events/callbacks are the right pattern.

---

## 13. Static Analysis

### 13.1 Default Profile: Dev-Gentle

Enabled check categories:
- `clang-analyzer-*` — critical bugs
- `bugprone-*` — logic errors
- `performance-*` — inefficiencies
- `readability-*` — readability
- `modernize-*` — C++ modernization

### 13.2 Handling Warnings

| Warning | Requirement |
|---------|-------------|
| `clang-analyzer-*`, `bugprone-*` | **Fix** or suppress with documentation |
| Style warnings | Fix promptly, do not ignore |

### 13.3 Profiles

| Profile | Context |
|---------|---------|
| Dev-Gentle | Daily development |
| CI-Strict | Pull requests |
| API-Gate | Public APIs |

---

## 14. Test Code

- Test code follows **the same standard**
- Test-specific abbreviations stay in tests
- The frameworks used (GoogleTest, Catch2) respect the naming rules

---

## 15. Documentation

### 15.1 TODO Markers

For unfinished tasks, ideas or problems to be fixed: use `TODO` in the comment.

```cpp
// TODO: Implement timeout handling
// TODO: Optimize buffer allocation
// TODO: Add error recovery for communication failure
```

IDEs can detect and list TODO markers automatically (e.g. VS Code: Todo Tree extension, Visual Studio: Task List).

### 15.2 Code Comments

| Comment Type | Usage |
|--------------|-------|
| `//` | Short inline comments, temporary notes |
| `/* */` | Multi-line comments, section headers |
| `///` or `/** */` | Doxygen documentation |

### 15.3 Function and Class Documentation

Document public APIs with Doxygen:

```cpp
/**
 * @brief  Process incoming data packets
 * @param  data Span of bytes to process
 * @param  config Optional processing configuration
 * @return Number of processed bytes, or error code
 * @throws std::invalid_argument if data is empty
 * @note   Thread-safe
 */
[[nodiscard]] std::expected<size_t, Error> 
processPackets(std::span<const std::byte> data,
               const Config* pConfig = nullptr);
```

| Tag | Usage |
|-----|-------|
| `@brief` | Short description (mandatory for public API) |
| `@param` | Parameter description |
| `@return` | Return value |
| `@throws` | Thrown exceptions |
| `@note` | Important notes |
| `@warning` | Warnings, limitations |
| `@see` | Related functions/classes |

### 15.4 Language

| Context | Language |
|---------|----------|
| Public APIs | **English** (mandatory) |
| Libraries | **English** (mandatory) |
| Internal tools | German allowed |
| Commit messages | English recommended |

---

## 16. Relationship to C (Embedded)

| Aspect | C++ (PC) | C (Embedded) |
|--------|----------|--------------|
| Exceptions | Yes | No |
| Dynamic allocation | Allowed | Avoid |
| Standard library | Full | Restricted |
| MISRA/CERT | Alignment | Strict compliance |

### 16.1 Shared Components

Libraries for PC and embedded must document:
- The C++ subset used
- Embedded restrictions

---

## 17. Legacy Code and Exceptions

### 17.1 Legacy Code

- Remains temporarily if not compliant
- New code **always** according to the standard
- Use refactoring opportunities

### 17.2 Intentional Deviations

- Comment in the code
- Document the justification
- Minimize the scope

---

## 18. MISRA/CERT Alignment

This standard is oriented towards:

| Guideline | Relevance |
|-----------|-----------|
| MISRA C++ | Safety-critical code |
| SEI CERT C++ | Defensive programming |

### Implemented Principles

- No dangerous casts
- No implicit truncation
- Check return values
- Initialize variables

---

## 19. See Also

- [C_Coding_Standard.md](C_Coding_Standard.md) — Embedded C
- [CMake_Standard.md](CMake_Standard.md) — Build system
- [Git_Standard.md](Git_Standard.md) — Version control
- [ClangFormat_Blueprint.md](../blueprints/ClangFormat.md) — Formatting
- [ClangTidy_Blueprint.md](../blueprints/ClangTidy.md) — Static analysis

---

## 20. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: §8.6 example `std::optional<Result>` (was garbled `std::optional<r>`); changelog 0.8.0: TODO markers are in §15.1 today** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.9.0 | 2025-12-19 | New: §8 extended (struct, union, bitfields), §9 raw pointer rules, §12 hardware access, §15 documentation; §2↔§3 swapped |
| 0.8.0 | 2025-12-19 | New: TODO markers (2.1, in §15.1 since 0.9.0), multiple conditions in parentheses (10.4), check division by 0 (10.5) |
| 0.7.0 | 2025-12-19 | Unification: prefix table clarified (p for all pointers) |
| 0.6.0 | 2025-12-19 | Consolidation: new section 8 class structure, extended prefix table (7.3), file naming conventions (5.1), interface prefix I, include order (5.5), nodiscard/explicit best practices (8.3) |
| 0.5.1 | 2025-12-18 | New section 4: file header with Doxygen format, mandatory fields, language rule |
| 0.5.0 | 2025-12-13 | Migration to Blueprint v0.5: new header, table of contents, encoding fix |
| 0.1.0 | 2025-12-05 | Initial: naming conventions, ownership, exceptions, MISRA alignment |
