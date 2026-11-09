# Cpp — Standard for C++/C File Structure

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Blueprint  
> **Status:** In Development  
> **Based on:** Blueprint v0.5  
> **Target Audience:** C++ developers, build system developers  
> **Scope:** All .cpp, .hpp, .tpp, .h, .c files  
> **Language:** English  
> **German:** [Cpp.md](../../../de/autorenwerk/blueprints/Cpp.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Delimitation](#2-delimitation)
3. [File Types](#3-file-types)
4. [File Header](#4-file-header)
5. [Header File Structure (.hpp/.h)](#5-header-file-structure-hpph)
6. [Source File Structure (.cpp/.c)](#6-source-file-structure-cppc)
7. [Template File Structure (.tpp)](#7-template-file-structure-tpp)
8. [Include Order](#8-include-order)
9. [Class Layout](#9-class-layout)
10. [Documentation Comments](#10-documentation-comments)
11. [Examples](#11-examples)
12. [Review Checklist](#12-review-checklist)
13. [See Also](#13-see-also)
14. [Changelog](#changelog)

---

## 1. Overview

This blueprint defines the **formal structure** for C++/C code files. It specifies how files must be structured — independently of the coding style.

### Goals

- Uniform file headers with metadata
- Consistent file structure
- Predictable include order
- Clear class organization

### What This Blueprint Governs

| Area | Content |
|---------|--------|
| File header | Copyright, version, description |
| File structure | Order of the sections |
| Includes | Sorting, grouping |
| Class layout | Order of the members |

---

## 2. Delimitation

| Document | Governs |
|----------|--------|
| **Cpp Blueprint** (this one) | Formal structure, file header, layout |
| **Cpp_Coding_Standard** | Naming conventions, style, language features |
| **ClangFormat_Blueprint** | Automatic formatting |
| **ClangTidy_Blueprint** | Static analysis, warnings |

**Example:**
- Cpp Blueprint: "Every file starts with a header comment"
- Cpp_Coding_Standard: "Classes are named `PascalCase`"

---

## 3. File Types

### 3.1 Overview

| Extension | Type | Description |
|-----------|-----|--------------|
| `.hpp` | C++ header | Declarations, inline code |
| `.cpp` | C++ source | Implementations |
| `.tpp` | C++ template | Template implementations |
| `.h` | C header | Pure C declarations |
| `.c` | C source | Pure C implementations |

### 3.2 Which Extension When?

| Situation | Extension |
|-----------|-----------|
| C++ class declaration | `.hpp` |
| C++ implementation | `.cpp` |
| Template implementation (separated) | `.tpp` |
| C-compatible headers | `.h` |
| Embedded/C-only code | `.c` |

---

## 4. File Header

### 4.1 Required Header

Every code file starts with a header comment:

```cpp
/**
 * @file    [File name]
 * @brief   [Short description in one line]
 * 
 * @details [Optional more detailed description]
 * 
 * @version X.Y.Z
 * @date    YYYY-MM-DD
 * @author  [Name or team]
 * 
 * @copyright Copyright (c) YYYY [Company/project]
 * @license   [License, e.g. MIT, Proprietary]
 */
```

### 4.2 Header Fields

| Field | Required | Description |
|------|---------|--------------|
| `@file` | ✓ | File name (without path) |
| `@brief` | ✓ | One-line short description |
| `@details` | — | More detailed description |
| `@version` | ✓ | SemVer of the file/component |
| `@date` | ✓ | Last change (ISO 8601) |
| `@author` | ✓ | Author or team |
| `@copyright` | ✓ | Copyright notice |
| `@license` | — | License (if not project-wide) |

### 4.3 Example: Minimal Header

```cpp
/**
 * @file    AudioPlayer.hpp
 * @brief   High-level audio playback interface
 * 
 * @version 1.2.0
 * @date    2025-12-13
 * @author  Audio Team
 * 
 * @copyright Copyright (c) 2025 MyProject
 */
```

### 4.4 Example: Complete Header

```cpp
/**
 * @file    AudioPlayer.hpp
 * @brief   High-level audio playback interface
 * 
 * @details Provides a simple interface for audio playback using
 *          the BASS audio library. Supports streaming, 3D audio,
 *          and multiple output devices.
 * 
 *          Thread-safety: All public methods are thread-safe.
 * 
 * @version 1.2.0
 * @date    2025-12-13
 * @author  Audio Team
 * 
 * @copyright Copyright (c) 2025 MyProject
 * @license   MIT
 * 
 * @see     AudioEngine.hpp
 * @see     SoundBuffer.hpp
 */
```

---

## 5. Header File Structure (.hpp/.h)

### 5.1 Layout

```cpp
// ============================================================
// 1. File header (required)
// ============================================================
/**
 * @file    Example.hpp
 * @brief   ...
 */

// ============================================================
// 2. Include guard (required)
// ============================================================
#pragma once
// OR traditionally:
// #ifndef PROJECT_MODULE_EXAMPLE_HPP
// #define PROJECT_MODULE_EXAMPLE_HPP

// ============================================================
// 3. Includes (sorted according to section 8)
// ============================================================
#include <string>
#include <vector>

#include "CoreTypes.hpp"

// ============================================================
// 4. Forward declarations (where possible)
// ============================================================
namespace audio {
class SoundBuffer;
}

// ============================================================
// 5. Open namespace
// ============================================================
namespace project::module {

// ============================================================
// 6. Constants and type definitions
// ============================================================
constexpr int kDefaultBufferSize = 4096;

using SampleRate = uint32_t;

// ============================================================
// 7. Classes / structs / enums
// ============================================================
class Example
{
    // ... (see section 9)
};

// ============================================================
// 8. Inline / template implementations (short)
// ============================================================
inline int Example::get_id() const { return m_id; }

// ============================================================
// 9. Close namespace
// ============================================================
} // namespace project::module

// ============================================================
// 10. Include for template implementation (optional)
// ============================================================
#include "Example.tpp"

// ============================================================
// 11. End of include guard (if #ifndef is used)
// ============================================================
// #endif // PROJECT_MODULE_EXAMPLE_HPP
```

### 5.2 Include Guard

**Preferred:** `#pragma once`

```cpp
#pragma once
```

**Alternative:** traditional include guard

```cpp
#ifndef PROJECT_MODULE_CLASSNAME_HPP
#define PROJECT_MODULE_CLASSNAME_HPP

// ... content ...

#endif // PROJECT_MODULE_CLASSNAME_HPP
```

**Naming convention:** `PROJECT_MODULE_CLASSNAME_HPP` (UPPER_SNAKE_CASE)

---

## 6. Source File Structure (.cpp/.c)

### 6.1 Layout

```cpp
// ============================================================
// 1. File header (required)
// ============================================================
/**
 * @file    Example.cpp
 * @brief   Implementation of Example class
 */

// ============================================================
// 2. Precompiled header (if used)
// ============================================================
#include "pch/pch.hpp"

// ============================================================
// 3. Corresponding header (always first!)
// ============================================================
#include "Example.hpp"

// ============================================================
// 4. Further includes (sorted according to section 8)
// ============================================================
#include <algorithm>
#include <stdexcept>

#include "Logger.hpp"
#include "Utility.hpp"

// ============================================================
// 5. Anonymous namespace for local helpers
// ============================================================
namespace {

constexpr int kInternalConstant = 42;

bool validate_input(int value)
{
    return value > 0;
}

} // anonymous namespace

// ============================================================
// 6. Open namespace
// ============================================================
namespace project::module {

// ============================================================
// 7. Initialize static members
// ============================================================
int Example::s_instance_count = 0;

// ============================================================
// 8. Constructors / destructors
// ============================================================
Example::Example()
    : m_id(0)
    , m_name("default")
{
    ++s_instance_count;
}

Example::~Example()
{
    --s_instance_count;
}

// ============================================================
// 9. Public Methods
// ============================================================
void Example::initialize()
{
    // ...
}

// ============================================================
// 10. Protected Methods
// ============================================================

// ============================================================
// 11. Private Methods
// ============================================================
void Example::internal_helper()
{
    // ...
}

// ============================================================
// 12. Close namespace
// ============================================================
} // namespace project::module
```

### 6.2 Important Rule: Own Header First

The corresponding header **MUST** be the first include after the PCH:

```cpp
#include "pch/pch.hpp"    // PCH (if used)
#include "MyClass.hpp"    // ← Own header FIRST!
#include <vector>         // System header
#include "Other.hpp"      // Project header
```

**Rationale:** Ensures that the header compiles on its own.

---

## 7. Template File Structure (.tpp)

### 7.1 When to Use .tpp?

- Template implementations that are too long for the header
- Separation of declaration and implementation for templates

### 7.2 Layout

```cpp
// ============================================================
// 1. File header
// ============================================================
/**
 * @file    Container.tpp
 * @brief   Template implementations for Container<T>
 * 
 * @note    This file is included at the end of Container.hpp
 *          Do not include directly!
 */

// ============================================================
// 2. NO include guard (included by the header)
// ============================================================

// ============================================================
// 3. Template implementations
// ============================================================
namespace project {

template<typename T>
Container<T>::Container()
    : m_data()
{
}

template<typename T>
void Container<T>::add(const T& item)
{
    m_data.push_back(item);
}

template<typename T>
T Container<T>::get(size_t index) const
{
    if (index >= m_data.size())
    {
        throw std::out_of_range("Index out of bounds");
    }
    return m_data[index];
}

} // namespace project
```

### 7.3 Inclusion in the Header

At the end of the corresponding header:

```cpp
// Container.hpp
#pragma once

namespace project {

template<typename T>
class Container
{
public:
    Container();
    void add(const T& item);
    T get(size_t index) const;
    
private:
    std::vector<T> m_data;
};

} // namespace project

// Include the template implementation
#include "Container.tpp"
```

---

## 8. Include Order

### 8.1 Order

```cpp
// 1. Precompiled header (if used)
#include "pch/pch.hpp"

// 2. Corresponding header (only in .cpp)
#include "ThisFile.hpp"

// 3. C standard library
#include <cstdint>
#include <cstring>

// 4. C++ standard library
#include <algorithm>
#include <string>
#include <vector>

// 5. Third-party libraries
#include <bass.h>
#include <imgui.h>

// 6. Project headers (other modules)
#include "core/Logger.hpp"
#include "utils/StringUtils.hpp"

// 7. Project headers (same module)
#include "LocalHelper.hpp"
```

### 8.2 Rules

| Rule | Description |
|-------|--------------|
| Separate groups | Blank line between groups |
| Alphabetical | Within each group |
| Quotation marks | `"..."` for project headers |
| Angle brackets | `<...>` for system/third-party |

### 8.3 Example

```cpp
#include "pch/pch.hpp"

#include "AudioPlayer.hpp"

#include <cstdint>

#include <algorithm>
#include <memory>
#include <string>

#include <bass.h>

#include "core/Logger.hpp"
#include "core/Settings.hpp"

#include "SoundBuffer.hpp"
```

---

## 9. Class Layout

### 9.1 Order of the Sections

```cpp
class Example
{
    // ========================================
    // 1. Friend declarations
    // ========================================
    friend class ExampleFactory;

public:
    // ========================================
    // 2. Type definitions and nested types
    // ========================================
    using Callback = std::function<void(int)>;
    
    enum class State { Idle, Running, Stopped };
    
    struct Config
    {
        int buffer_size = 4096;
        bool verbose = false;
    };

    // ========================================
    // 3. Static constants
    // ========================================
    static constexpr int kMaxInstances = 10;

    // ========================================
    // 4. Constructors / destructor
    // ========================================
    Example();
    explicit Example(const Config& config);
    ~Example();
    
    // ========================================
    // 5. Copy/Move (Rule of Five)
    // ========================================
    Example(const Example& other);
    Example& operator=(const Example& other);
    Example(Example&& other) noexcept;
    Example& operator=(Example&& other) noexcept;

    // ========================================
    // 6. Static methods
    // ========================================
    static int get_instance_count();

    // ========================================
    // 7. Public methods
    // ========================================
    void initialize();
    void process();
    
    // ========================================
    // 8. Getters / setters
    // ========================================
    int get_id() const;
    void set_id(int id);
    
    const std::string& get_name() const;
    void set_name(const std::string& name);

    // ========================================
    // 9. Operators
    // ========================================
    bool operator==(const Example& other) const;

protected:
    // ========================================
    // 10. Protected methods
    // ========================================
    virtual void on_state_change(State new_state);

    // ========================================
    // 11. Protected members
    // ========================================
    State m_state = State::Idle;

private:
    // ========================================
    // 12. Private methods
    // ========================================
    void internal_update();
    bool validate_config(const Config& config);

    // ========================================
    // 13. Private members
    // ========================================
    int m_id;
    std::string m_name;
    Config m_config;
    
    // ========================================
    // 14. Static members
    // ========================================
    static int s_instance_count;
};
```

### 9.2 Visibility Order

1. `public:` — public interface first
2. `protected:` — for derived classes
3. `private:` — implementation details

**Rationale:** Readers are usually interested in the public API first.

---

## 10. Documentation Comments

### 10.1 Doxygen Format

```cpp
/**
 * @brief   Short description of the function
 * 
 * @details More detailed description, if needed.
 *          Can span multiple lines.
 * 
 * @param   name        Description of the parameter
 * @param   value       Another parameter
 * 
 * @return  What is returned
 * 
 * @throws  std::invalid_argument  If name is empty
 * @throws  std::runtime_error     On internal error
 * 
 * @note    Important note
 * @warning Warning about pitfalls
 * 
 * @see     related_function()
 * @since   1.2.0
 * 
 * @example
 * @code
 * Example ex;
 * ex.do_something("test", 42);
 * @endcode
 */
void do_something(const std::string& name, int value);
```

### 10.2 When to Document?

| Element | Documentation |
|---------|---------------|
| Public API | Required — complete |
| Protected methods | Recommended |
| Private methods | Optional — if complex |
| Trivial getters/setters | Not needed |

### 10.3 Inline Comments

```cpp
// Single-line comment for short explanations

/* 
 * Multi-line comment for
 * longer explanations in the code
 */

int value = 42;  // Trailing comment (use sparingly)
```

---

## 11. Examples

### 11.1 Complete Header (AudioPlayer.hpp)

```cpp
/**
 * @file    AudioPlayer.hpp
 * @brief   High-level audio playback interface
 * 
 * @version 1.2.0
 * @date    2025-12-13
 * @author  Audio Team
 * 
 * @copyright Copyright (c) 2025 MyProject
 */

#pragma once

#include <cstdint>

#include <functional>
#include <memory>
#include <string>

namespace audio {

class SoundBuffer;

/**
 * @brief   Audio player for sound playback
 * 
 * @details Provides high-level audio playback using BASS library.
 *          Supports streaming, 3D positioning, and effects.
 */
class AudioPlayer
{
public:
    using VolumeCallback = std::function<void(float)>;
    
    enum class State { Stopped, Playing, Paused };

    AudioPlayer();
    ~AudioPlayer();
    
    AudioPlayer(const AudioPlayer&) = delete;
    AudioPlayer& operator=(const AudioPlayer&) = delete;
    
    /**
     * @brief   Load audio file for playback
     * @param   filepath    Path to audio file
     * @return  true on success
     */
    bool load(const std::string& filepath);
    
    void play();
    void pause();
    void stop();
    
    State get_state() const;
    
    float get_volume() const;
    void set_volume(float volume);

private:
    struct Impl;
    std::unique_ptr<Impl> m_impl;
};

} // namespace audio
```

### 11.2 Complete Source (AudioPlayer.cpp)

```cpp
/**
 * @file    AudioPlayer.cpp
 * @brief   Implementation of AudioPlayer class
 * 
 * @version 1.2.0
 * @date    2025-12-13
 * @author  Audio Team
 * 
 * @copyright Copyright (c) 2025 MyProject
 */

#include "pch/pch.hpp"

#include "AudioPlayer.hpp"

#include <stdexcept>

#include <bass.h>

#include "core/Logger.hpp"

namespace {

bool is_valid_volume(float vol)
{
    return vol >= 0.0f && vol <= 1.0f;
}

} // anonymous namespace

namespace audio {

struct AudioPlayer::Impl
{
    HSTREAM stream = 0;
    State state = State::Stopped;
    float volume = 1.0f;
};

AudioPlayer::AudioPlayer()
    : m_impl(std::make_unique<Impl>())
{
}

AudioPlayer::~AudioPlayer()
{
    stop();
}

bool AudioPlayer::load(const std::string& filepath)
{
    // Implementation...
    return true;
}

void AudioPlayer::play()
{
    if (m_impl->stream != 0)
    {
        BASS_ChannelPlay(m_impl->stream, FALSE);
        m_impl->state = State::Playing;
    }
}

void AudioPlayer::pause()
{
    if (m_impl->state == State::Playing)
    {
        BASS_ChannelPause(m_impl->stream);
        m_impl->state = State::Paused;
    }
}

void AudioPlayer::stop()
{
    if (m_impl->stream != 0)
    {
        BASS_ChannelStop(m_impl->stream);
        m_impl->state = State::Stopped;
    }
}

AudioPlayer::State AudioPlayer::get_state() const
{
    return m_impl->state;
}

float AudioPlayer::get_volume() const
{
    return m_impl->volume;
}

void AudioPlayer::set_volume(float volume)
{
    if (!is_valid_volume(volume))
    {
        throw std::invalid_argument("Volume must be between 0.0 and 1.0");
    }
    m_impl->volume = volume;
}

} // namespace audio
```

---

## 12. Review Checklist

Check before committing a code file:

**File header:**
- [ ] Header comment present
- [ ] `@file`, `@brief`, `@version`, `@date`, `@author`, `@copyright` filled in
- [ ] Version current

**Structure:**
- [ ] Include guard present (`#pragma once` or `#ifndef`)
- [ ] Includes sorted by order (section 8)
- [ ] Own header first (in .cpp)
- [ ] Namespaces correctly opened/closed

**Classes:**
- [ ] Visibility order: public → protected → private
- [ ] Member order according to section 9
- [ ] Public API documented

**Code:**
- [ ] No includes in .tpp files
- [ ] Anonymous namespace for local helpers (in .cpp)

---

## 13. See Also

- [Cpp_Coding_Standard.md](../standards/Cpp_Coding_Standard.md) — Naming conventions, style
- [ClangFormat_Blueprint.md](ClangFormat.md) — Automatic formatting
- [CMake.md](CMake.md) — CMake file structure

---

## Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-13 | Initial: file header, file structure (hpp/cpp/tpp), include order, class layout, documentation comments |
