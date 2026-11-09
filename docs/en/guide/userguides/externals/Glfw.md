# GLFW — UserGuide

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Guide  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Glfw.md](../../../../de/guide/userguides/externals/Glfw.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Solution.json Configuration](#2-solutionjson-configuration)
3. [C++ Usage](#3-c-usage)
4. [Input Handling](#4-input-handling)
5. [Advanced Techniques](#5-advanced-techniques)
6. [With GLAD and ImGui](#6-with-glad-and-imgui)
7. [Troubleshooting](#7-troubleshooting)
8. [Further Information](#8-further-information)
9. [Changelog](#changelog)

---

## 1. Overview

**GLFW** is a cross-platform library for window creation, OpenGL contexts and input handling.

| Aspect | Value |
|--------|-------|
| **Type** | Git External |
| **Repository** | https://github.com/glfw/glfw |
| **Recommended Tag** | 3.4 |
| **License** | zlib/libpng |
| **Website** | [glfw.org](https://www.glfw.org/) |

### Why GLFW?

| Advantage | Description |
|-----------|-------------|
| 🪟 **Cross-Platform** | Windows, Linux, macOS |
| 🎮 **Input** | Keyboard, mouse, gamepad |
| 🖥️ **Multi-Monitor** | Fullscreen & windowed |
| ⚡ **Lightweight** | Minimal overhead |

---

## 2. Solution.json Configuration

### 2.1 Minimal

```json
{
    "externals": {
        "glfw": {
            "git": "https://github.com/glfw/glfw.git",
            "tag": "3.4"
        }
    },
    "executables": [
        {
            "name": "WindowApp",
            "type": "GUI",
            "externals": ["glfw"]
        }
    ]
}
```

### 2.2 With GLAD

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

### 2.3 PreFetch Hook

```cmake
# cmake/externals/hooks/prefetch/glfw.cmake
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GLFW_INSTALL OFF CACHE BOOL "" FORCE)
```

---

## 3. C++ Usage

### 3.1 Creating a Window

```cpp
#include <GLFW/glfw3.h>
#include <iostream>

int main() {
    // Initialize GLFW
    if (!glfwInit()) {
        std::cerr << "Failed to initialize GLFW" << std::endl;
        return -1;
    }
    
    // Create window
    GLFWwindow* window = glfwCreateWindow(800, 600, "GLFW Window", nullptr, nullptr);
    if (!window) {
        std::cerr << "Failed to create window" << std::endl;
        glfwTerminate();
        return -1;
    }
    
    // Activate OpenGL context
    glfwMakeContextCurrent(window);
    
    // Main loop
    while (!glfwWindowShouldClose(window)) {
        // Process events
        glfwPollEvents();
        
        // Swap buffers
        glfwSwapBuffers(window);
    }
    
    // Clean up
    glfwDestroyWindow(window);
    glfwTerminate();
    return 0;
}
```

### 3.2 Setting the OpenGL Version

```cpp
glfwInit();

// OpenGL 3.3 Core Profile
glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

// Required for macOS
#ifdef __APPLE__
glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
#endif

GLFWwindow* window = glfwCreateWindow(800, 600, "OpenGL 3.3", nullptr, nullptr);
```

### 3.3 Window Hints

| Hint | Description | Default |
|------|-------------|---------|
| `GLFW_RESIZABLE` | Resizable | `GLFW_TRUE` |
| `GLFW_VISIBLE` | Visible | `GLFW_TRUE` |
| `GLFW_DECORATED` | Title bar | `GLFW_TRUE` |
| `GLFW_FOCUSED` | Focused | `GLFW_TRUE` |
| `GLFW_MAXIMIZED` | Maximized | `GLFW_FALSE` |
| `GLFW_FLOATING` | Always on top | `GLFW_FALSE` |
| `GLFW_TRANSPARENT_FRAMEBUFFER` | Transparent | `GLFW_FALSE` |
| `GLFW_SAMPLES` | MSAA samples | 0 |

```cpp
glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);
glfwWindowHint(GLFW_SAMPLES, 4);  // 4x MSAA
glfwWindowHint(GLFW_TRANSPARENT_FRAMEBUFFER, GLFW_TRUE);
```

### 3.4 Fullscreen

```cpp
// Primary monitor
GLFWmonitor* monitor = glfwGetPrimaryMonitor();
const GLFWvidmode* mode = glfwGetVideoMode(monitor);

// Fullscreen window
GLFWwindow* window = glfwCreateWindow(
    mode->width, mode->height, 
    "Fullscreen", 
    monitor,        // Monitor for fullscreen
    nullptr
);

// Borderless fullscreen (windowed fullscreen)
glfwWindowHint(GLFW_DECORATED, GLFW_FALSE);
GLFWwindow* window = glfwCreateWindow(
    mode->width, mode->height,
    "Borderless",
    nullptr,        // No monitor = windowed
    nullptr
);
glfwSetWindowPos(window, 0, 0);
```

### 3.5 VSync

```cpp
glfwMakeContextCurrent(window);

// Enable VSync (1 = ON, 0 = OFF)
glfwSwapInterval(1);
```

---

## 4. Input Handling

### 4.1 Keyboard

```cpp
// Polling
while (!glfwWindowShouldClose(window)) {
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, true);
    }
    
    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS) {
        // W pressed
    }
    
    glfwPollEvents();
}

// Callback
void key_callback(GLFWwindow* window, int key, int scancode, int action, int mods) {
    if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, true);
    }
    
    if (key == GLFW_KEY_F11 && action == GLFW_PRESS) {
        // Toggle fullscreen
    }
    
    // Check modifiers
    if (mods & GLFW_MOD_CONTROL) {
        if (key == GLFW_KEY_S && action == GLFW_PRESS) {
            // Ctrl+S
        }
    }
}

glfwSetKeyCallback(window, key_callback);
```

### 4.2 Mouse

```cpp
// Position
double xpos, ypos;
glfwGetCursorPos(window, &xpos, &ypos);

// Buttons
if (glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_LEFT) == GLFW_PRESS) {
    // Left mouse button
}

// Callbacks
void cursor_position_callback(GLFWwindow* window, double xpos, double ypos) {
    // Mouse moved
}

void mouse_button_callback(GLFWwindow* window, int button, int action, int mods) {
    if (button == GLFW_MOUSE_BUTTON_RIGHT && action == GLFW_PRESS) {
        // Right click
    }
}

void scroll_callback(GLFWwindow* window, double xoffset, double yoffset) {
    // Scroll: yoffset > 0 = up
}

glfwSetCursorPosCallback(window, cursor_position_callback);
glfwSetMouseButtonCallback(window, mouse_button_callback);
glfwSetScrollCallback(window, scroll_callback);
```

### 4.3 Cursor Modes

```cpp
// Normal
glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_NORMAL);

// Hidden
glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_HIDDEN);

// Captured (for FPS games)
glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);

// Raw mouse input (if supported)
if (glfwRawMouseMotionSupported()) {
    glfwSetInputMode(window, GLFW_RAW_MOUSE_MOTION, GLFW_TRUE);
}
```

### 4.4 Gamepad

```cpp
// Gamepad connected?
if (glfwJoystickPresent(GLFW_JOYSTICK_1)) {
    // Name
    const char* name = glfwGetJoystickName(GLFW_JOYSTICK_1);
    
    // As gamepad?
    if (glfwJoystickIsGamepad(GLFW_JOYSTICK_1)) {
        GLFWgamepadstate state;
        if (glfwGetGamepadState(GLFW_JOYSTICK_1, &state)) {
            // Buttons
            if (state.buttons[GLFW_GAMEPAD_BUTTON_A]) {
                // A pressed
            }
            
            // Analog sticks (-1.0 to 1.0)
            float leftX = state.axes[GLFW_GAMEPAD_AXIS_LEFT_X];
            float leftY = state.axes[GLFW_GAMEPAD_AXIS_LEFT_Y];
            
            // Triggers (0.0 to 1.0)
            float leftTrigger = state.axes[GLFW_GAMEPAD_AXIS_LEFT_TRIGGER];
        }
    }
}
```

---

## 5. Advanced Techniques

### 5.1 Callbacks

```cpp
// Window size changed
void framebuffer_size_callback(GLFWwindow* window, int width, int height) {
    glViewport(0, 0, width, height);
}

// Window closed
void window_close_callback(GLFWwindow* window) {
    // Save?
}

// Error callback
void error_callback(int error, const char* description) {
    std::cerr << "GLFW Error " << error << ": " << description << std::endl;
}

// Register
glfwSetErrorCallback(error_callback);
glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
glfwSetWindowCloseCallback(window, window_close_callback);
```

### 5.2 User Pointer

```cpp
struct AppState {
    bool running = true;
    float cameraX = 0;
    float cameraY = 0;
};

AppState state;
glfwSetWindowUserPointer(window, &state);

// In a callback
void key_callback(GLFWwindow* window, int key, int scancode, int action, int mods) {
    AppState* state = static_cast<AppState*>(glfwGetWindowUserPointer(window));
    
    if (key == GLFW_KEY_LEFT) {
        state->cameraX -= 1.0f;
    }
}
```

### 5.3 Multi-Monitor

```cpp
// All monitors
int count;
GLFWmonitor** monitors = glfwGetMonitors(&count);

for (int i = 0; i < count; i++) {
    const char* name = glfwGetMonitorName(monitors[i]);
    const GLFWvidmode* mode = glfwGetVideoMode(monitors[i]);
    
    std::cout << "Monitor " << i << ": " << name 
              << " (" << mode->width << "x" << mode->height << ")" << std::endl;
}

// Window on the second monitor
GLFWwindow* window = glfwCreateWindow(800, 600, "Second Monitor", monitors[1], nullptr);
```

### 5.4 Clipboard

```cpp
// Text to clipboard
glfwSetClipboardString(window, "Hello, Clipboard!");

// Text from clipboard
const char* text = glfwGetClipboardString(window);
if (text) {
    std::cout << "Clipboard: " << text << std::endl;
}
```

### 5.5 Time

```cpp
double lastTime = glfwGetTime();

while (!glfwWindowShouldClose(window)) {
    double currentTime = glfwGetTime();
    double deltaTime = currentTime - lastTime;
    lastTime = currentTime;
    
    // Compute FPS
    static double fpsTime = 0;
    static int frames = 0;
    frames++;
    fpsTime += deltaTime;
    if (fpsTime >= 1.0) {
        std::cout << "FPS: " << frames << std::endl;
        frames = 0;
        fpsTime = 0;
    }
    
    // Movement with deltaTime
    float speed = 5.0f;
    position += velocity * speed * (float)deltaTime;
    
    glfwPollEvents();
    glfwSwapBuffers(window);
}
```

---

## 6. With GLAD and ImGui

### 6.1 Complete Example

```cpp
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <imgui.h>
#include <imgui_impl_glfw.h>
#include <imgui_impl_opengl3.h>

int main() {
    // GLFW setup
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    
    GLFWwindow* window = glfwCreateWindow(1280, 720, "App", nullptr, nullptr);
    glfwMakeContextCurrent(window);
    glfwSwapInterval(1);
    
    // GLAD setup
    gladLoadGLLoader((GLADloadproc)glfwGetProcAddress);
    
    // ImGui setup
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGui_ImplGlfw_InitForOpenGL(window, true);
    ImGui_ImplOpenGL3_Init("#version 330");
    
    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();
        
        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();
        
        ImGui::Begin("Demo");
        ImGui::Text("Hello!");
        ImGui::End();
        
        ImGui::Render();
        int w, h;
        glfwGetFramebufferSize(window, &w, &h);
        glViewport(0, 0, w, h);
        glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
        
        glfwSwapBuffers(window);
    }
    
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();
    glfwTerminate();
    return 0;
}
```

See [glad.md](Glad.md) and [imgui.md](Imgui.md) for more details.

---

## 7. Troubleshooting

### 7.1 "Failed to create window"

**Problem:** `glfwCreateWindow` returns nullptr

**Solutions:**
1. Call `glfwInit()`
2. Check the OpenGL version (not too high for the driver)
3. `glfwSetErrorCallback` for details

### 7.2 No OpenGL Functions

**Problem:** `glClear` etc. crash

**Solution:** Load GLAD after `glfwMakeContextCurrent`:
```cpp
glfwMakeContextCurrent(window);
gladLoadGLLoader((GLADloadproc)glfwGetProcAddress);  // Here!
```

### 7.3 macOS Black Window

**Problem:** Window stays black

**Solution:** Enable forward compat:
```cpp
glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
```

### 7.4 Input Does Not Work

**Problem:** Keyboard/mouse does not respond

**Solution:** Call `glfwPollEvents()`!

---

## 8. Further Information

### Official Resources

| Resource | Link |
|----------|------|
| **Website** | [glfw.org](https://www.glfw.org/) |
| **GitHub** | [github.com/glfw/glfw](https://github.com/glfw/glfw) |
| **Documentation** | [glfw.org/documentation](https://www.glfw.org/documentation.html) |
| **Input Guide** | [glfw.org/docs/latest/input_guide.html](https://www.glfw.org/docs/latest/input_guide.html) |

### See Also

- [Externals.md](../Externals.md) — Externals combinations
- [Git_Externals_GUI.md](../../references/externals/Git_Externals_GUI.md) — Reference
- [glad.md](Glad.md) — OpenGL loader
- [imgui.md](Imgui.md) — GUI framework

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.2 | 2025-12-15 | Initial: detailed UserGuide for GLFW |
