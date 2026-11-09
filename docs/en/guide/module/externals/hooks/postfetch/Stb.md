# stb.cmake — Module Documentation

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** Stable  
> **Based on:** ModuleDoc v0.5, master_concept v0.1  
> **Target Audience:** Build System Developers  
> **Language:** English  
> **German:** [Stb.md](../../../../../../de/guide/module/externals/hooks/postfetch/Stb.md)  
> **Module:** [`cmake/externals/hooks/postfetch/stb.cmake`](../../../../../../../cmake/externals/hooks/postfetch/stb.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Concept](#3-concept)
4. [Hook Variables](#4-hook-variables)
5. [Created Targets](#5-created-targets)
6. [Usage Examples](#6-usage-examples)
7. [Available Headers](#7-available-headers)
8. [Best Practices](#8-best-practices)
9. [Limitations](#9-limitations)
10. [See Also](#10-see-also)
11. [Changelog](#11-changelog)

---

## 1. Overview

The `stb.cmake` PostFetch hook creates an INTERFACE target for Sean Barrett's **stb** header-only library. Since stb does not ship its own CMakeLists.txt, this hook takes over the target creation.

### Responsibilities

| Area | Description |
|------|-------------|
| Target creation | Creates the `stb` INTERFACE library |
| Include paths | Sets the include directory to the source root |
| Registration | Registers the target in the externals system |

### Short Description

```
stb = Single-file public domain libraries for C/C++
     ├── stb_image.h        → Image loading (PNG, JPG, BMP, TGA, GIF, HDR, PIC, PNM)
     ├── stb_image_write.h  → Image writing
     ├── stb_image_resize.h → Image resizing
     └── ... (20+ more headers)
```

---

## 2. Dependencies

| Module | Version | Usage |
|--------|---------|-------|
| HookLoader.cmake | 0.5.0+ | Provides the hook variables |
| Registry/Targets.cmake | — | `_register_external_target()` function |

---

## 3. Concept

### Why a PostFetch Hook?

stb is a collection of **header-only** libraries without a build system. The CMake Architecture, however, expects a target for every external. The PostFetch hook closes this gap:

```
FetchContent_Declare(stb ...)
    ↓
FetchContent_MakeAvailable(stb)
    ↓
[No CMakeLists.txt present!]
    ↓
PostFetch hook is executed
    ↓
Hook creates INTERFACE target
    ↓
Target is registered
```

### INTERFACE vs STATIC

Since stb is header-only, an `INTERFACE` target is used:

| Aspect | INTERFACE | STATIC |
|--------|-----------|--------|
| Compilation | None (headers only) | Own .lib/.a |
| Link type | Include propagation only | Full linkage |
| For stb | ✅ Correct | ❌ Unnecessary |

---

## 4. Hook Variables

These variables are provided by the HookLoader:

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `HOOK_EXTERNAL_NAME` | Name of the external | `stb` |
| `HOOK_SOURCE_DIR` | Path to the source directory | `${CMAKE_SOURCE_DIR}/.externals/stb` |
| `HOOK_EXTERNAL_JSON` | JSON definition (optional) | `{"git": "...", ...}` |

---

## 5. Created Targets

| Target | Type | Description |
|--------|------|-------------|
| `stb` | INTERFACE | Main target with include directory |

### Target Properties

```cmake
# Set automatically by the hook:
target_include_directories(stb INTERFACE "${HOOK_SOURCE_DIR}")
```

### Usage in Executables

```json
// Solution.json
{
    "externals": ["stb"]
}
```

```cmake
# Linked automatically:
target_link_libraries(MyTarget PRIVATE stb)
```

---

## 6. Usage Examples

### In C++ Code

```cpp
// stb_image - define the implementation in ONE .cpp file
#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>

// In other files include only the header
#include <stb_image.h>

// Load an image
int width, height, channels;
unsigned char* data = stbi_load("image.png", &width, &height, &channels, 0);
if (data) {
    // ... use ...
    stbi_image_free(data);
}
```

### Important: Implementation Macro

stb headers need a `#define *_IMPLEMENTATION` in **exactly one** .cpp file:

| Header | Macro |
|--------|-------|
| stb_image.h | `STB_IMAGE_IMPLEMENTATION` |
| stb_image_write.h | `STB_IMAGE_WRITE_IMPLEMENTATION` |
| stb_image_resize.h | `STB_IMAGE_RESIZE_IMPLEMENTATION` |

---

## 7. Available Headers

The most important stb headers:

| Header | Description | Use Case |
|--------|-------------|----------|
| `stb_image.h` | Image loading (PNG, JPG, BMP, etc.) | Texture loading |
| `stb_image_write.h` | Image writing | Screenshots |
| `stb_image_resize.h` | Image scaling | Mipmap generation |
| `stb_truetype.h` | TrueType font parsing | Text rendering |
| `stb_rect_pack.h` | Rectangle packing | Texture atlases |
| `stb_perlin.h` | Perlin noise | Procedural textures |

Complete list: https://github.com/nothings/stb

---

## 8. Best Practices

### ✅ Recommended

```cpp
// Implementation in a dedicated file (e.g. stb_impl.cpp)
#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include <stb_image.h>
#include <stb_image_write.h>
```

```cpp
// Other files: header only
#include <stb_image.h>  // No #define!
```

### ❌ Avoid

```cpp
// WRONG: implementation in a header file
// stb_wrapper.hpp
#define STB_IMAGE_IMPLEMENTATION  // ❌ Multiple inclusion!
#include <stb_image.h>
```

```cpp
// WRONG: implementation in several .cpp files
// file1.cpp
#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>

// file2.cpp
#define STB_IMAGE_IMPLEMENTATION  // ❌ Linker error!
#include <stb_image.h>
```

---

## 9. Limitations

| Limitation | Description |
|------------|-------------|
| No versioning | stb uses the `master` branch |
| Single implementation | `*_IMPLEMENTATION` may be defined only once |
| C-style API | No RAII, manual memory management |

---

## 10. See Also

| Document | Description |
|----------|-------------|
| [HookLoader.cmake](../HookLoader_cmake.md) | Hook system documentation |
| [Handler.cmake](../../fetched/Handler_cmake.md) | Fetched external handler |
| OpenGLTexture.cpp | Usage example |

### External Resources

- [stb GitHub Repository](https://github.com/nothings/stb)
- [stb_image Documentation](https://github.com/nothings/stb/blob/master/stb_image.h)

---

## 11. Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.1.0 | 2025-12-23 | Initial version for MyVisualizer Phase 2 |

---

*Documentation created according to Blueprint v0.5.0*
