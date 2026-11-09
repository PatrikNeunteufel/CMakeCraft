# glad/Include.cmake — GLAD OpenGL Loader Integration

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** ModuleDoc  
> **Status:** Active  
> **Based on:** ModuleDoc v0.5, Doc v0.5  
> **Target Audience:** Build System Developers, C++ Developers  
> **Language:** English  
> **German:** [Glad_Include.md](../../../../../../de/guide/module/externals/includes/glad/Glad_Include.md)  
> **Module:** [cmake/externals/includes/glad/Include.cmake](../../../../../../../cmake/externals/includes/glad/Include.cmake)  
> **Module Version:** 1.0.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [GLAD Configurator](#2-glad-configurator)
3. [Available Variables](#3-available-variables)
4. [Created Targets](#4-created-targets)
5. [Directory Structure](#5-directory-structure)
6. [Include.cmake Implementation](#6-includecmake-implementation)
7. [Advanced Configurations](#7-advanced-configurations)
8. [Usage Examples](#8-usage-examples)
9. [Integration with Other Externals](#9-integration-with-other-externals)
10. [Error Handling](#10-error-handling)
11. [See Also](#11-see-also)
12. [Changelog](#changelog)

---

## 1. Overview

`glad/Include.cmake` integrates the **GLAD OpenGL loader** into the build system as a local external.

### What Is GLAD?

GLAD is an **OpenGL loading library generator**. OpenGL functions are not directly available — they must be loaded at runtime. GLAD generates the code for this.

### Core Functions

| Function | Description |
|----------|-------------|
| OpenGL loading | Loads OpenGL function pointers at runtime |
| Multi-API | OpenGL, OpenGL ES, Vulkan, EGL, GLX, WGL |
| Version-specific | Only the functions needed for the chosen version |
| Extensions | Optional OpenGL extensions can be loaded |

### Target Creation

Creates a `STATIC` target `glad` that compiles the generated `glad.c`.

---

## 2. GLAD Configurator

GLAD has to be generated with the web configurator.

### 2.1 Standard Configuration (OpenGL 3.3 Core)

**Step-by-step guide:**

1. Open **https://glad.dav1d.de/**

2. Choose the following settings:

| Setting | Value | Explanation |
|---------|-------|-------------|
| **Language** | C/C++ | Generates C-compatible code |
| **Specification** | OpenGL | Standard desktop OpenGL |
| **API gl** | Version 3.3 | Minimum for modern features |
| **Profile** | Core | Without deprecated functions |
| **Generate a loader** | ✅ (enabled) | Loads functions automatically |

3. Click **GENERATE**

4. Download the **ZIP archive**

5. Unpack it to `externals/glad/`

### 2.2 Configurator Options in Detail

#### Language

| Option | Usage |
|--------|-------|
| **C/C++** | Standard for CMake projects |
| D | D language |
| Nim | Nim language |
| Pascal | Pascal/Delphi |

#### Specification

| Option | Description |
|--------|-------------|
| **OpenGL** | Desktop OpenGL (Windows, Linux, macOS) |
| OpenGL ES | Mobile/embedded (Android, iOS, WebGL) |
| Vulkan | Modern low-level API |
| EGL | Display/context management |
| GLX | X11 OpenGL extension |
| WGL | Windows OpenGL extension |

#### API gl Version

| Version | Features | Recommendation |
|---------|----------|----------------|
| 2.1 | Fixed function + shaders | Legacy support |
| **3.3** | Core profile, VAOs, UBOs | **Recommended** |
| 4.0 | Tessellation | Advanced |
| 4.3 | Compute shaders | Advanced |
| 4.5 | DSA, clip control | Modern |
| 4.6 | SPIR-V, anisotropic | Most recent |

#### Profile

| Option | Description |
|--------|-------------|
| **Core** | Modern API only, no deprecated functions |
| Compatibility | Old + new API (larger, slower) |

### 2.3 Optional Extensions

**Extensions** can be enabled in the configurator:

| Extension | Description | Use Case |
|-----------|-------------|----------|
| `GL_ARB_debug_output` | Debug callbacks | Debugging |
| `GL_ARB_texture_filter_anisotropic` | Anisotropic filtering | Better textures |
| `GL_ARB_clip_control` | Depth range control | Reverse-Z |
| `GL_ARB_direct_state_access` | DSA functions | Fewer binds |
| `GL_ARB_compute_shader` | Compute shaders | GPGPU |

**Example with extensions:**

1. In the configurator, select the desired ones under "Extensions"
2. Generate and download
3. Check in code:

```cpp
if (GLAD_GL_ARB_debug_output) {
    glDebugMessageCallback(debugCallback, nullptr);
}
```

---

## 3. Available Variables

These variables are provided by the orchestrator:

| Variable | Description |
|----------|-------------|
| `EXTERNAL_NAME` | `"glad"` |
| `EXTERNAL_ROOT` | Absolute path to `externals/glad` |
| `EXTERNAL_JSON` | JSON element from Solution.json |
| `EXTERNAL_OPTIONS` | Target-specific options (JSON) |

---

## 4. Created Targets

| Target | Type | Description |
|--------|------|-------------|
| `glad` | STATIC | Compiled GLAD library |

### Automatic Dependencies

```cmake
find_package(OpenGL REQUIRED)
target_link_libraries(glad PUBLIC OpenGL::GL)
```

---

## 5. Directory Structure

After unpacking the ZIP archive:

```
externals/glad/
├── include/
│   ├── glad/
│   │   └── glad.h          ← OpenGL function declarations
│   └── KHR/
│       └── khrplatform.h   ← Platform types
└── src/
    └── glad.c              ← Loader implementation
```

> **Note:** The Include.cmake lives in the convention path `cmake/externals/includes/glad/Include.cmake`, not in the external folder itself.

---

## 6. Include.cmake Implementation

### 6.1 Standard Implementation

```cmake
# cmake/externals/includes/glad/Include.cmake
# GLAD OpenGL Loader
# Version: 0.5.0

# Source files
set(_glad_sources
    "${EXTERNAL_ROOT}/src/glad.c"
)

# Create static library
add_library(glad STATIC ${_glad_sources})

# Include directories
target_include_directories(glad PUBLIC
    "${EXTERNAL_ROOT}/include"
)

# Link OpenGL
find_package(OpenGL REQUIRED)
target_link_libraries(glad PUBLIC OpenGL::GL)

# Suppress warnings for external code
if(MSVC)
    target_compile_options(glad PRIVATE /W0)
else()
    target_compile_options(glad PRIVATE -w)
endif()

# Register target
_register_external_target("glad" "glad" PRIMARY)
```

### 6.2 With OpenGL ES Support

If GLAD was generated for OpenGL ES:

```cmake
# For OpenGL ES (e.g. Android, Raspberry Pi)
if(OPENGL_ES)
    find_package(OpenGL REQUIRED COMPONENTS EGL GLES2)
    target_link_libraries(glad PUBLIC OpenGL::EGL OpenGL::GLES2)
else()
    find_package(OpenGL REQUIRED)
    target_link_libraries(glad PUBLIC OpenGL::GL)
endif()
```

---

## 7. Advanced Configurations

### 7.1 OpenGL 4.5 with Extensions

**Configurator settings:**
- API gl: **Version 4.5**
- Profile: **Core**
- Extensions: `GL_ARB_debug_output`, `GL_ARB_direct_state_access`

**Adapted Include.cmake (optional):**

```cmake
# cmake/externals/includes/glad/Include.cmake
# GLAD OpenGL 4.5 with extensions

add_library(glad STATIC "${EXTERNAL_ROOT}/src/glad.c")

target_include_directories(glad PUBLIC
    "${EXTERNAL_ROOT}/include"
)

find_package(OpenGL REQUIRED)
target_link_libraries(glad PUBLIC OpenGL::GL)

# Compile definition for the OpenGL version
target_compile_definitions(glad PUBLIC
    GLAD_GL_VERSION_4_5=1
)

if(MSVC)
    target_compile_options(glad PRIVATE /W0)
else()
    target_compile_options(glad PRIVATE -w)
endif()

_register_external_target("glad" "glad" PRIMARY)
```

### 7.2 OpenGL ES 3.0 (Mobile)

**Configurator settings:**
- Specification: **OpenGL ES**
- API gles2: **Version 3.0**

**Adapted Include.cmake:**

```cmake
# cmake/externals/includes/glad/Include.cmake
# GLAD OpenGL ES 3.0

add_library(glad STATIC "${EXTERNAL_ROOT}/src/glad.c")

target_include_directories(glad PUBLIC
    "${EXTERNAL_ROOT}/include"
)

# OpenGL ES libraries
if(ANDROID)
    target_link_libraries(glad PUBLIC EGL GLESv3)
elseif(EMSCRIPTEN)
    # WebGL - no explicit linking needed
else()
    find_package(OpenGL REQUIRED COMPONENTS EGL GLES3)
    target_link_libraries(glad PUBLIC OpenGL::EGL OpenGL::GLES3)
endif()

target_compile_options(glad PRIVATE -w)

_register_external_target("glad" "glad" PRIMARY)
```

### 7.3 Vulkan Loader

**Configurator settings:**
- Specification: **Vulkan**
- API vulkan: **Version 1.3**

**Adapted Include.cmake:**

```cmake
# cmake/externals/includes/glad/Include.cmake
# GLAD Vulkan Loader

add_library(glad STATIC "${EXTERNAL_ROOT}/src/glad_vulkan.c")

target_include_directories(glad PUBLIC
    "${EXTERNAL_ROOT}/include"
)

find_package(Vulkan REQUIRED)
target_link_libraries(glad PUBLIC Vulkan::Vulkan)

_register_external_target("glad" "glad" PRIMARY)
```

---

## 8. Usage Examples

### 8.1 Basic Usage with GLFW

**Solution.json:**

```json
{
    "externals": {
        "glad": { "path": "externals/glad" },
        "glfw": {
            "git": "https://github.com/glfw/glfw.git",
            "tag": "3.4"
        }
    },
    "executables": [
        {
            "name": "OpenGLApp",
            "type": "GUI",
            "externals": ["glad", "glfw"]
        }
    ]
}
```

**C++:**

```cpp
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <iostream>

int main() {
    // Initialize GLFW
    if (!glfwInit()) {
        std::cerr << "GLFW init failed" << std::endl;
        return -1;
    }

    // Request OpenGL 3.3 Core
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    // Create window
    GLFWwindow* window = glfwCreateWindow(800, 600, "OpenGL", nullptr, nullptr);
    if (!window) {
        std::cerr << "Window creation failed" << std::endl;
        glfwTerminate();
        return -1;
    }

    glfwMakeContextCurrent(window);

    // Load GLAD - MUST come after glfwMakeContextCurrent!
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        std::cerr << "GLAD init failed" << std::endl;
        return -1;
    }

    // Print OpenGL version
    std::cout << "OpenGL " << glGetString(GL_VERSION) << std::endl;
    std::cout << "Renderer: " << glGetString(GL_RENDERER) << std::endl;

    // Render loop
    while (!glfwWindowShouldClose(window)) {
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glfwTerminate();
    return 0;
}
```

### 8.2 With Debug Callback (GL_ARB_debug_output)

```cpp
#include <glad/glad.h>

void GLAPIENTRY debugCallback(
    GLenum source, GLenum type, GLuint id,
    GLenum severity, GLsizei length,
    const GLchar* message, const void* userParam)
{
    std::cerr << "[OpenGL] " << message << std::endl;
}

int main() {
    // ... GLFW/GLAD init ...

    // Enable debug callback (if the extension is available)
    if (GLAD_GL_ARB_debug_output) {
        glEnable(GL_DEBUG_OUTPUT);
        glDebugMessageCallback(debugCallback, nullptr);
        std::cout << "Debug output enabled" << std::endl;
    }

    // ... rest of the application ...
}
```

### 8.3 Extension Check

```cpp
#include <glad/glad.h>
#include <iostream>

void checkExtensions() {
    std::cout << "Extension Support:" << std::endl;
    
    std::cout << "  GL_ARB_debug_output: " 
              << (GLAD_GL_ARB_debug_output ? "yes" : "no") << std::endl;
    
    std::cout << "  GL_ARB_direct_state_access: " 
              << (GLAD_GL_ARB_direct_state_access ? "yes" : "no") << std::endl;
    
    std::cout << "  GL_ARB_texture_filter_anisotropic: " 
              << (GLAD_GL_ARB_texture_filter_anisotropic ? "yes" : "no") << std::endl;
}
```

---

## 9. Integration with Other Externals

### 9.1 Order in Solution.json

GLAD must be defined **before** externals that need it:

```json
"externals": {
    "glad": { "path": "externals/glad" },     // 1. First
    "glfw": { ... },                           // 2. Then GLFW
    "imgui": { ..., "cmakeSupport": false }    // 3. ImGui last
}
```

### 9.2 ImGui Integration

The ImGui PostFetch hook detects GLAD automatically:

```cmake
# In cmake/externals/hooks/postfetch/imgui.cmake
if(TARGET glad)
    target_link_libraries(imgui PUBLIC glad)
    target_compile_definitions(imgui PRIVATE IMGUI_IMPL_OPENGL_LOADER_GLAD)
    message(STATUS "[imgui] Linked: glad")
endif()
```

### 9.3 Typical GUI Combination

```json
{
    "externals": {
        "glad": { "path": "externals/glad" },
        "glfw": {
            "git": "https://github.com/glfw/glfw.git",
            "tag": "3.4"
        },
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.91.6",
            "cmakeSupport": false
        }
    },
    "executables": [
        {
            "name": "MyGuiApp",
            "type": "GUI",
            "externals": ["glad", "glfw", "imgui"]
        }
    ]
}
```

---

## 10. Error Handling

### 10.1 CMake Errors

| Code | Description | Solution |
|------|-------------|----------|
| E213 | Include.cmake not found | Check the path: `cmake/externals/includes/glad/` |
| E214 | External path does not exist | Create `externals/glad/` and unpack GLAD |
| — | OpenGL not found | Install the OpenGL development packages |

### 10.2 Runtime Errors

**"gladLoadGLLoader failed":**

```cpp
// Most common error: no active OpenGL context
glfwMakeContextCurrent(window);  // MUST come before gladLoadGLLoader!

if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
    // Error
}
```

**"Undefined reference to glXXX":**

- GLAD version too low for the function used
- Regenerate with a higher OpenGL version

**"Extension not available":**

```cpp
// Always check before use!
if (GLAD_GL_ARB_debug_output) {
    // Extension available
} else {
    // Fallback or disable the feature
}
```

### 10.3 Linux: OpenGL Packages

```bash
# Ubuntu/Debian
sudo apt install libgl1-mesa-dev

# Fedora
sudo dnf install mesa-libGL-devel

# Arch
sudo pacman -S mesa
```

---

## 11. See Also

- [Externals_Reference.md](../../../../references/Externals.md) — All externals
- [Externals_UserGuide.md](../../../../userguides/Externals.md) — GUI app guide
- [Imgui.md](../../hooks/postfetch/Imgui.md) — ImGui integration
- [Glfw.md](../../hooks/prefetch/Glfw.md) — GLFW configuration
- [GLAD Web Generator](https://glad.dav1d.de/) — Official configurator
- [GLAD GitHub](https://github.com/Dav1dde/glad) — Source code

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-15 | New document: Blueprint v0.5.0, configurator guide, extensions, OpenGL ES/Vulkan variants |
