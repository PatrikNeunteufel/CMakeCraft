# GLAD — UserGuide

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Guide  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Glad.md](../../../../de/guide/userguides/externals/Glad.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Generating GLAD](#2-generating-glad)
3. [Solution.json Configuration](#3-solutionjson-configuration)
4. [C++ Usage](#4-c-usage)
5. [Combining with GLFW](#5-combining-with-glfw)
6. [Combining with ImGui](#6-combining-with-imgui)
7. [Troubleshooting](#7-troubleshooting)
8. [Further Information](#8-further-information)
9. [Changelog](#changelog)

---

## 1. Overview

**GLAD** is an OpenGL loading library generator. OpenGL functions are not directly available at runtime — they have to be loaded dynamically. GLAD generates the code for this.

| Aspect | Value |
|--------|-------|
| **Type** | Local External (generated) |
| **Path** | `externals/glad` |
| **License** | MIT / Public Domain |
| **Generator** | [glad.dav1d.de](https://glad.dav1d.de/) |

### Why GLAD?

| Advantage | Description |
|-----------|-------------|
| 🎯 **Configurable** | Only the required OpenGL version |
| 🔧 **Generated** | No build system needed |
| 📦 **Standalone** | No dependencies |
| ✅ **Modern** | Supports Core Profile |

---

## 2. Generating GLAD

### 2.1 Web Configurator

1. Open **https://glad.dav1d.de/**

2. Choose settings:

| Setting | Recommendation | Description |
|---------|----------------|-------------|
| **Language** | C/C++ | Standard for CMake |
| **Specification** | OpenGL | Desktop OpenGL |
| **API gl** | 3.3 or higher | Minimum for Core Profile |
| **Profile** | Core | Without deprecated functions |
| **Generate a loader** | ✅ | Generate loader code |

3. Click **GENERATE**

4. Download the ZIP

5. Extract to `externals/glad/`

### 2.2 Standard Configurations

| Configuration | API | Profile | Use Case |
|---------------|-----|---------|----------|
| **Standard** | gl 3.3 | Core | Desktop apps, ImGui |
| **Modern** | gl 4.5 | Core | Compute shaders, DSA |
| **Compat** | gl 3.3 | Compatibility | Legacy code |
| **Mobile** | gles2 3.0 | — | Android, iOS, WebGL |
| **Vulkan** | vulkan 1.3 | — | Vulkan instead of OpenGL |

### 2.3 Optional Extensions

Extensions can be enabled in the configurator:

| Extension | Description |
|-----------|-------------|
| `GL_ARB_debug_output` | Debug callbacks |
| `GL_ARB_direct_state_access` | DSA functions (4.5) |
| `GL_ARB_texture_filter_anisotropic` | Anisotropic filtering |
| `GL_ARB_compute_shader` | Compute shaders |

### 2.4 Directory Structure

After extracting:

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

---

## 3. Solution.json Configuration

### 3.1 Minimal

```json
{
    "externals": {
        "glad": {
            "path": "externals/glad"
        }
    },
    "executables": [
        {
            "name": "OpenGLApp",
            "type": "GUI",
            "externals": ["glad"]
        }
    ]
}
```

### 3.2 With GLFW

```json
{
    "externals": {
        "glad": { "path": "externals/glad" },
        "glfw": { "git": "https://github.com/glfw/glfw.git", "tag": "3.4" }
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

### 3.3 Complete GUI Application

```json
{
    "externals": {
        "glad": { "path": "externals/glad" },
        "glfw": { "git": "https://github.com/glfw/glfw.git", "tag": "3.4" },
        "imgui": { "git": "https://github.com/ocornut/imgui.git", "tag": "v1.91.6", "cmakeSupport": false }
    },
    "executables": [
        {
            "name": "GuiApp",
            "type": "GUI",
            "externals": ["glad", "glfw", "imgui"]
        }
    ]
}
```

---

## 4. C++ Usage

### 4.1 Basics (GLAD Only)

```cpp
#include <glad/glad.h>
#include <iostream>

// Note: GLAD does not work on its own without GLFW!
// An OpenGL context must exist before gladLoadGL() is called.
```

### 4.2 Minimal Example with GLFW

```cpp
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <iostream>

int main() {
    // 1. Initialize GLFW
    if (!glfwInit()) {
        std::cerr << "Failed to initialize GLFW" << std::endl;
        return -1;
    }
    
    // 2. Set OpenGL version
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    
#ifdef __APPLE__
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
#endif
    
    // 3. Create window
    GLFWwindow* window = glfwCreateWindow(800, 600, "OpenGL", nullptr, nullptr);
    if (!window) {
        std::cerr << "Failed to create window" << std::endl;
        glfwTerminate();
        return -1;
    }
    
    // 4. Activate context
    glfwMakeContextCurrent(window);
    
    // 5. Load GLAD - MUST come AFTER glfwMakeContextCurrent!
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        std::cerr << "Failed to initialize GLAD" << std::endl;
        return -1;
    }
    
    // 6. Print OpenGL info
    std::cout << "OpenGL Version: " << glGetString(GL_VERSION) << std::endl;
    std::cout << "GLSL Version: " << glGetString(GL_SHADING_LANGUAGE_VERSION) << std::endl;
    std::cout << "Vendor: " << glGetString(GL_VENDOR) << std::endl;
    std::cout << "Renderer: " << glGetString(GL_RENDERER) << std::endl;
    
    // 7. Set viewport
    glViewport(0, 0, 800, 600);
    
    // 8. Main loop
    while (!glfwWindowShouldClose(window)) {
        // Clear
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        
        // Swap & Poll
        glfwSwapBuffers(window);
        glfwPollEvents();
    }
    
    // 9. Cleanup
    glfwTerminate();
    return 0;
}
```

### 4.3 Rendering a Triangle

```cpp
#include <glad/glad.h>
#include <GLFW/glfw3.h>

const char* vertexShaderSource = R"(
#version 330 core
layout (location = 0) in vec3 aPos;
void main() {
    gl_Position = vec4(aPos, 1.0);
}
)";

const char* fragmentShaderSource = R"(
#version 330 core
out vec4 FragColor;
void main() {
    FragColor = vec4(1.0, 0.5, 0.2, 1.0);
}
)";

int main() {
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    
    GLFWwindow* window = glfwCreateWindow(800, 600, "Triangle", nullptr, nullptr);
    glfwMakeContextCurrent(window);
    gladLoadGLLoader((GLADloadproc)glfwGetProcAddress);
    
    // Compile shaders
    unsigned int vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &vertexShaderSource, nullptr);
    glCompileShader(vertexShader);
    
    unsigned int fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentShaderSource, nullptr);
    glCompileShader(fragmentShader);
    
    unsigned int shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);
    
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    // Vertex data
    float vertices[] = {
        -0.5f, -0.5f, 0.0f,
         0.5f, -0.5f, 0.0f,
         0.0f,  0.5f, 0.0f
    };
    
    unsigned int VAO, VBO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    
    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
    
    // Main loop
    while (!glfwWindowShouldClose(window)) {
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        
        glUseProgram(shaderProgram);
        glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 3);
        
        glfwSwapBuffers(window);
        glfwPollEvents();
    }
    
    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    glDeleteProgram(shaderProgram);
    
    glfwTerminate();
    return 0;
}
```

---

## 5. Combining with GLFW

### 5.1 Order

```
1. glfwInit()
2. glfwCreateWindow()
3. glfwMakeContextCurrent()    ← OpenGL context created
4. gladLoadGLLoader()          ← GLAD loads OpenGL functions
5. Use OpenGL code
```

> **IMPORTANT:** `gladLoadGLLoader()` MUST be called after `glfwMakeContextCurrent()`!

### 5.2 Resize Callback

```cpp
void framebuffer_size_callback(GLFWwindow* window, int width, int height) {
    glViewport(0, 0, width, height);
}

int main() {
    // ... create window ...
    glfwMakeContextCurrent(window);
    gladLoadGLLoader((GLADloadproc)glfwGetProcAddress);
    
    // Register callback
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    
    // ...
}
```

See [glfw.md](Glfw.md) for more details on GLFW.

---

## 6. Combining with ImGui

### 6.1 Order

```
1. glfwInit()
2. glfwCreateWindow()
3. glfwMakeContextCurrent()
4. gladLoadGLLoader()          ← GLAD first
5. ImGui::CreateContext()      ← ImGui afterwards
6. ImGui_ImplGlfw_InitForOpenGL()
7. ImGui_ImplOpenGL3_Init()
```

### 6.2 Example

```cpp
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <imgui.h>
#include <imgui_impl_glfw.h>
#include <imgui_impl_opengl3.h>

int main() {
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    
    GLFWwindow* window = glfwCreateWindow(1280, 720, "ImGui App", nullptr, nullptr);
    glfwMakeContextCurrent(window);
    glfwSwapInterval(1);  // VSync
    
    // Load GLAD
    gladLoadGLLoader((GLADloadproc)glfwGetProcAddress);
    
    // ImGui setup
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
    
    ImGui::StyleColorsDark();
    
    ImGui_ImplGlfw_InitForOpenGL(window, true);
    ImGui_ImplOpenGL3_Init("#version 330");
    
    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();
        
        // Start ImGui frame
        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();
        
        // ImGui widgets
        ImGui::Begin("Hello");
        ImGui::Text("Hello, World!");
        if (ImGui::Button("Click me")) {
            // ...
        }
        ImGui::End();
        
        // Rendering
        ImGui::Render();
        int display_w, display_h;
        glfwGetFramebufferSize(window, &display_w, &display_h);
        glViewport(0, 0, display_w, display_h);
        glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
        
        glfwSwapBuffers(window);
    }
    
    // Cleanup
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();
    
    glfwDestroyWindow(window);
    glfwTerminate();
    
    return 0;
}
```

See [imgui.md](Imgui.md) for more details on ImGui.

---

## 7. Troubleshooting

### 7.1 "undefined reference to gl..."

**Problem:** OpenGL functions not found

**Causes & solutions:**

1. **GLAD not loaded:**
   ```cpp
   // WRONG
   glClear(GL_COLOR_BUFFER_BIT);  // Crash!
   
   // RIGHT
   gladLoadGLLoader((GLADloadproc)glfwGetProcAddress);
   glClear(GL_COLOR_BUFFER_BIT);  // OK
   ```

2. **No OpenGL context:**
   ```cpp
   // WRONG
   gladLoadGLLoader(...);  // No context!
   
   // RIGHT
   glfwMakeContextCurrent(window);
   gladLoadGLLoader(...);
   ```

### 7.2 "glad.h not found"

**Problem:** Header not found

**Solution:** Check the directory structure:
```
externals/glad/include/glad/glad.h  ← Must exist
```

### 7.3 GLAD Returns false

**Problem:** `gladLoadGLLoader()` returns 0

**Solutions:**
1. OpenGL context does not exist
2. Driver does not support the requested version
3. On macOS: enable forward compat:
   ```cpp
   glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
   ```

### 7.4 Functions Missing

**Problem:** Certain OpenGL functions not available

**Solution:** Regenerate GLAD with a higher version or enable extensions.

---

## 8. Further Information

### Official Resources

| Resource | Link |
|----------|------|
| **GLAD Generator** | [glad.dav1d.de](https://glad.dav1d.de/) |
| **GitHub** | [github.com/Dav1dde/glad](https://github.com/Dav1dde/glad) |
| **OpenGL Registry** | [khronos.org/registry/OpenGL](https://www.khronos.org/registry/OpenGL/) |
| **LearnOpenGL** | [learnopengl.com](https://learnopengl.com/) |

### See Also

- [Externals.md](../Externals.md) — Externals combinations
- [Local_Externals_GUI.md](../../references/externals/Local_Externals_GUI.md) — Reference
- [glfw.md](Glfw.md) — Window & Input
- [imgui.md](Imgui.md) — Immediate Mode GUI

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.2 | 2025-12-15 | Initial: detailed UserGuide for GLAD |
