# Local Externals — GUI

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Local_Externals_GUI.md](../../../../de/guide/references/externals/Local_Externals_GUI.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [GLAD OpenGL Loader](#2-glad-opengl-loader)
3. [See Also](#3-see-also)
4. [Changelog](#changelog)

---

## 1. Overview

This document describes local GUI/graphics externals for the CMake Architecture build system.

| Library | Description | License |
|---------|-------------|---------|
| **glad** | OpenGL function loader (generated) | MIT / Public Domain |

---

## 2. GLAD OpenGL Loader

### Quick Info

| Aspect | Value |
|--------|-------|
| **Type** | 🔧 Generated |
| **Path** | `externals/glad` |
| **Include.cmake** | `cmake/externals/includes/glad/Include.cmake` |
| **Platforms** | All |
| **Generator** | [glad.dav1d.de](https://glad.dav1d.de/) |

### What Is GLAD?

GLAD is an **OpenGL loading library generator**. OpenGL functions are not directly available — they have to be loaded at runtime. GLAD generates the code for this.

### Generating GLAD

1. Open **https://glad.dav1d.de/**

2. Choose settings:

| Setting | Recommendation | Description |
|---------|----------------|-------------|
| **Language** | C/C++ | Standard for CMake |
| **Specification** | OpenGL | Desktop OpenGL |
| **API gl** | 3.3+ | Minimum for Core Profile |
| **Profile** | Core | Without deprecated functions |

3. Click **GENERATE**

4. Download the ZIP

5. Extract to `externals/glad/`

### Solution.json

```json
{
    "externals": {
        "glad": {
            "path": "externals/glad"
        }
    }
}
```

### Directory Structure

```
externals/glad/
├── include/
│   ├── glad/
│   │   └── glad.h
│   └── KHR/
│       └── khrplatform.h
└── src/
    └── glad.c
```

### Alternative Configurations

| Configuration | Specification | API | Use Case |
|---------------|---------------|-----|----------|
| **Standard** | OpenGL | gl 3.3 Core | Desktop apps, ImGui |
| **Modern** | OpenGL | gl 4.5 Core | Advanced features |
| **Mobile** | OpenGL ES | gles2 3.0 | Android, iOS, WebGL |
| **Vulkan** | Vulkan | vulkan 1.3 | Low-level API |

### Optional Extensions

Extensions can be enabled in the configurator:

| Extension | Description |
|-----------|-------------|
| `GL_ARB_debug_output` | Debug callbacks |
| `GL_ARB_direct_state_access` | DSA functions |
| `GL_ARB_texture_filter_anisotropic` | Better textures |

### Usage Example

```cpp
#include <glad/glad.h>
#include <GLFW/glfw3.h>

int main() {
    // Initialize GLFW
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    
    GLFWwindow* window = glfwCreateWindow(800, 600, "OpenGL", nullptr, nullptr);
    glfwMakeContextCurrent(window);
    
    // Load GLAD - MUST come after glfwMakeContextCurrent!
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        return -1;
    }
    
    // Use OpenGL
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

### Typical Combination (OpenGL + ImGui)

```json
{
    "externals": {
        "glad": { "path": "externals/glad" },
        "glfw": { "git": "https://github.com/glfw/glfw.git", "tag": "3.4" },
        "imgui": { "git": "https://github.com/ocornut/imgui.git", "tag": "v1.91.6", "cmakeSupport": false }
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

> **Order matters:** glad → glfw → imgui (imgui links automatically against glad and glfw)

### Comparison with Git Alternatives

| Feature | glad (Local) | glfw (Git) | imgui (Git) | SDL2 (Git) |
|---------|--------------|------------|-------------|------------|
| **Type** | OpenGL loader | Window/Input | GUI | Multimedia |
| **Generated** | ✅ | ❌ | ❌ | ❌ |
| **CMake Support** | — | ✅ | ❌ | ✅ |
| **Hook** | — | PreFetch | PostFetch 🔧 | PreFetch |

### Detail Documentation

→ [glad_Include.md](../../module/externals/includes/glad/Glad_Include.md)

---

## 3. See Also

- [Externals.md](../Externals.md) — Main overview of all externals
- [Local_Externals.md](Local_Externals.md) — Local Externals overview
- [Git_Externals_GUI.md](Git_Externals_GUI.md) — Git GUI externals (glfw, imgui, SDL2)
- [Externals_UserGuide.md](../../userguides/Externals.md) — GUI app guide

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.2 | 2025-12-15 | Own category GUI (parallel to Git) |
