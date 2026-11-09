# Dear ImGui — UserGuide

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Guide  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Imgui.md](../../../../de/guide/userguides/externals/Imgui.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Solution.json Configuration](#2-solutionjson-configuration)
3. [C++ Usage](#3-c-usage)
4. [Widgets](#4-widgets)
5. [Layouts](#5-layouts)
6. [Styling](#6-styling)
7. [Advanced Techniques](#7-advanced-techniques)
8. [Troubleshooting](#8-troubleshooting)
9. [Further Information](#9-further-information)
10. [Changelog](#changelog)

---

## 1. Overview

**Dear ImGui** is an immediate mode GUI framework for C++.

| Aspect | Value |
|--------|-------|
| **Type** | Git External (no CMake support) |
| **Repository** | https://github.com/ocornut/imgui |
| **Recommended Tag** | v1.91.6 |
| **License** | MIT |
| **Website** | [github.com/ocornut/imgui](https://github.com/ocornut/imgui) |

### Why ImGui?

| Advantage | Description |
|-----------|-------------|
| ⚡ **Immediate Mode** | No widget objects to manage |
| 🎨 **Flexible** | Fully customizable |
| 🛠️ **Tool-Ready** | Ideal for debug UIs |
| 📦 **Lightweight** | Minimal dependencies |

### Immediate Mode vs Retained Mode

```cpp
// Retained Mode (Qt, etc.)
Button* btn = new Button("Click me");
btn->onClick = []() { /* ... */ };
layout->addWidget(btn);

// Immediate Mode (ImGui)
if (ImGui::Button("Click me")) {
    // Executed immediately when clicked
}
```

---

## 2. Solution.json Configuration

### 2.1 With GLAD and GLFW

```json
{
    "externals": {
        "glad": { "path": "externals/glad" },
        "glfw": { "git": "https://github.com/glfw/glfw.git", "tag": "3.4" },
        "imgui": { 
            "git": "https://github.com/ocornut/imgui.git", 
            "tag": "v1.91.6",
            "cmakeSupport": false
        }
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

### 2.2 Docking Branch

```json
{
    "externals": {
        "imgui": { 
            "git": "https://github.com/ocornut/imgui.git", 
            "tag": "v1.91.6-docking",
            "cmakeSupport": false
        }
    }
}
```

### 2.3 PostFetch Hook

```cmake
# cmake/externals/hooks/postfetch/imgui.cmake

# Collect sources
set(_imgui_sources
    "${HOOK_SOURCE_DIR}/imgui.cpp"
    "${HOOK_SOURCE_DIR}/imgui_draw.cpp"
    "${HOOK_SOURCE_DIR}/imgui_tables.cpp"
    "${HOOK_SOURCE_DIR}/imgui_widgets.cpp"
    "${HOOK_SOURCE_DIR}/imgui_demo.cpp"
    "${HOOK_SOURCE_DIR}/backends/imgui_impl_glfw.cpp"
    "${HOOK_SOURCE_DIR}/backends/imgui_impl_opengl3.cpp"
)

# Create library
add_library(${HOOK_EXTERNAL_NAME} STATIC ${_imgui_sources})

target_include_directories(${HOOK_EXTERNAL_NAME} PUBLIC
    "${HOOK_SOURCE_DIR}"
    "${HOOK_SOURCE_DIR}/backends"
)

# Dependencies
target_link_libraries(${HOOK_EXTERNAL_NAME} PUBLIC glfw glad)

_register_external_target("${HOOK_EXTERNAL_NAME}" "${HOOK_EXTERNAL_NAME}" PRIMARY)
```

---

## 3. C++ Usage

### 3.1 Setup

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
    
    GLFWwindow* window = glfwCreateWindow(1280, 720, "ImGui App", nullptr, nullptr);
    glfwMakeContextCurrent(window);
    glfwSwapInterval(1);
    
    // GLAD
    gladLoadGLLoader((GLADloadproc)glfwGetProcAddress);
    
    // ImGui context
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;
    
    // Style
    ImGui::StyleColorsDark();
    
    // Platform/renderer backends
    ImGui_ImplGlfw_InitForOpenGL(window, true);
    ImGui_ImplOpenGL3_Init("#version 330");
    
    // Main loop
    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();
        
        // Start ImGui frame
        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();
        
        // UI code here
        ImGui::ShowDemoWindow();
        
        // Render
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
    glfwTerminate();
    
    return 0;
}
```

### 3.2 Simple Window

```cpp
ImGui::Begin("My Window");
ImGui::Text("Hello, World!");
ImGui::End();
```

### 3.3 Window with Options

```cpp
bool open = true;
ImGuiWindowFlags flags = ImGuiWindowFlags_MenuBar | ImGuiWindowFlags_NoCollapse;

if (ImGui::Begin("Settings", &open, flags)) {
    ImGui::Text("Content here");
}
ImGui::End();

// open == false when X is clicked
```

---

## 4. Widgets

### 4.1 Text

```cpp
ImGui::Text("Simple text");
ImGui::TextColored(ImVec4(1, 0, 0, 1), "Red text");
ImGui::TextDisabled("Disabled text");
ImGui::TextWrapped("Long text that will wrap...");
ImGui::BulletText("Bullet point");

// Formatted
ImGui::Text("Value: %d", 42);
ImGui::Text("Float: %.2f", 3.14159f);
```

### 4.2 Buttons

```cpp
if (ImGui::Button("Click me")) {
    // Button was clicked
}

if (ImGui::Button("Sized", ImVec2(100, 50))) {
    // Button with a fixed size
}

ImGui::SmallButton("Small");

// Toggle button
static bool toggled = false;
if (ImGui::Button(toggled ? "ON" : "OFF")) {
    toggled = !toggled;
}

// Arrow buttons
ImGui::ArrowButton("left", ImGuiDir_Left);
ImGui::SameLine();
ImGui::ArrowButton("right", ImGuiDir_Right);
```

### 4.3 Checkbox & Radio

```cpp
static bool checked = false;
ImGui::Checkbox("Enable feature", &checked);

static int radio = 0;
ImGui::RadioButton("Option A", &radio, 0);
ImGui::RadioButton("Option B", &radio, 1);
ImGui::RadioButton("Option C", &radio, 2);
```

### 4.4 Input

```cpp
// Text input
static char text[128] = "Hello";
ImGui::InputText("Name", text, sizeof(text));

static char multiline[1024] = "";
ImGui::InputTextMultiline("Description", multiline, sizeof(multiline));

// Numbers
static int intVal = 0;
ImGui::InputInt("Integer", &intVal);

static float floatVal = 0.0f;
ImGui::InputFloat("Float", &floatVal, 0.1f, 1.0f, "%.3f");

static float vec3[3] = {0, 0, 0};
ImGui::InputFloat3("Position", vec3);
```

### 4.5 Slider & Drag

```cpp
static int intSlider = 50;
ImGui::SliderInt("Volume", &intSlider, 0, 100);

static float floatSlider = 0.5f;
ImGui::SliderFloat("Alpha", &floatSlider, 0.0f, 1.0f);

static float angle = 0.0f;
ImGui::SliderAngle("Rotation", &angle);

// Drag (unbounded)
static float dragVal = 0.0f;
ImGui::DragFloat("Speed", &dragVal, 0.1f);

// With range
ImGui::DragFloat("Clamped", &dragVal, 0.1f, 0.0f, 100.0f);
```

### 4.6 Color Picker

```cpp
static float color3[3] = {1.0f, 0.0f, 0.0f};
ImGui::ColorEdit3("Color", color3);

static float color4[4] = {1.0f, 0.0f, 0.0f, 1.0f};
ImGui::ColorEdit4("Color with Alpha", color4);

ImGui::ColorPicker4("Picker", color4);
```

### 4.7 Combo & ListBox

```cpp
// Combo
static int currentItem = 0;
const char* items[] = {"Apple", "Banana", "Cherry"};
ImGui::Combo("Fruit", &currentItem, items, IM_ARRAYSIZE(items));

// ListBox
static int listItem = 0;
ImGui::ListBox("List", &listItem, items, IM_ARRAYSIZE(items), 4);
```

### 4.8 Trees & Collapsing Headers

```cpp
if (ImGui::TreeNode("Options")) {
    ImGui::Text("Option 1");
    ImGui::Text("Option 2");
    
    if (ImGui::TreeNode("Nested")) {
        ImGui::Text("Nested content");
        ImGui::TreePop();
    }
    
    ImGui::TreePop();
}

if (ImGui::CollapsingHeader("Advanced")) {
    ImGui::Text("Advanced settings");
}
```

### 4.9 Tables

```cpp
if (ImGui::BeginTable("MyTable", 3)) {
    ImGui::TableSetupColumn("Name");
    ImGui::TableSetupColumn("Value");
    ImGui::TableSetupColumn("Action");
    ImGui::TableHeadersRow();
    
    for (int i = 0; i < 5; i++) {
        ImGui::TableNextRow();
        ImGui::TableSetColumnIndex(0);
        ImGui::Text("Item %d", i);
        ImGui::TableSetColumnIndex(1);
        ImGui::Text("%d", i * 10);
        ImGui::TableSetColumnIndex(2);
        ImGui::SmallButton("Edit");
    }
    
    ImGui::EndTable();
}
```

---

## 5. Layouts

### 5.1 SameLine

```cpp
ImGui::Button("Button 1");
ImGui::SameLine();
ImGui::Button("Button 2");
ImGui::SameLine();
ImGui::Button("Button 3");
```

### 5.2 Spacing & Separator

```cpp
ImGui::Text("Section 1");
ImGui::Separator();
ImGui::Text("Section 2");

ImGui::Spacing();  // Vertical spacing
ImGui::Dummy(ImVec2(0, 20));  // Larger spacing
```

### 5.3 Groups

```cpp
ImGui::BeginGroup();
ImGui::Text("Group 1");
ImGui::Button("Button");
ImGui::EndGroup();

ImGui::SameLine();

ImGui::BeginGroup();
ImGui::Text("Group 2");
ImGui::Button("Button");
ImGui::EndGroup();
```

### 5.4 Columns (Legacy)

```cpp
ImGui::Columns(3, "mycolumns");
ImGui::Separator();

ImGui::Text("Column 1"); ImGui::NextColumn();
ImGui::Text("Column 2"); ImGui::NextColumn();
ImGui::Text("Column 3"); ImGui::NextColumn();

ImGui::Separator();
ImGui::Columns(1);
```

### 5.5 Child Windows

```cpp
ImGui::BeginChild("Scrolling", ImVec2(0, 150), true);
for (int i = 0; i < 100; i++) {
    ImGui::Text("Line %d", i);
}
ImGui::EndChild();
```

---

## 6. Styling

### 6.1 Built-in Styles

```cpp
ImGui::StyleColorsDark();   // Default
ImGui::StyleColorsLight();
ImGui::StyleColorsClassic();
```

### 6.2 Custom Colors

```cpp
ImGuiStyle& style = ImGui::GetStyle();

style.Colors[ImGuiCol_WindowBg] = ImVec4(0.1f, 0.1f, 0.1f, 1.0f);
style.Colors[ImGuiCol_Button] = ImVec4(0.2f, 0.4f, 0.8f, 1.0f);
style.Colors[ImGuiCol_ButtonHovered] = ImVec4(0.3f, 0.5f, 0.9f, 1.0f);
style.Colors[ImGuiCol_ButtonActive] = ImVec4(0.1f, 0.3f, 0.7f, 1.0f);
```

### 6.3 Custom Sizing

```cpp
ImGuiStyle& style = ImGui::GetStyle();

style.WindowRounding = 5.0f;
style.FrameRounding = 3.0f;
style.FramePadding = ImVec2(5, 5);
style.ItemSpacing = ImVec2(8, 4);
style.ScrollbarSize = 15.0f;
```

### 6.4 Push/Pop Style

```cpp
ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(1, 0, 0, 1));
ImGui::Button("Red Button");
ImGui::PopStyleColor();

ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(10, 10));
ImGui::Button("Padded Button");
ImGui::PopStyleVar();
```

### 6.5 Fonts

```cpp
ImGuiIO& io = ImGui::GetIO();

// Replace the default font
io.Fonts->AddFontFromFileTTF("Roboto-Regular.ttf", 16.0f);

// Additional fonts
ImFont* boldFont = io.Fonts->AddFontFromFileTTF("Roboto-Bold.ttf", 16.0f);

// Use a font
ImGui::PushFont(boldFont);
ImGui::Text("Bold text");
ImGui::PopFont();
```

---

## 7. Advanced Techniques

### 7.1 Menus

```cpp
if (ImGui::BeginMainMenuBar()) {
    if (ImGui::BeginMenu("File")) {
        if (ImGui::MenuItem("New", "Ctrl+N")) { /* ... */ }
        if (ImGui::MenuItem("Open", "Ctrl+O")) { /* ... */ }
        ImGui::Separator();
        if (ImGui::MenuItem("Exit")) { /* ... */ }
        ImGui::EndMenu();
    }
    if (ImGui::BeginMenu("Edit")) {
        if (ImGui::MenuItem("Undo", "Ctrl+Z")) { /* ... */ }
        if (ImGui::MenuItem("Redo", "Ctrl+Y")) { /* ... */ }
        ImGui::EndMenu();
    }
    ImGui::EndMainMenuBar();
}
```

### 7.2 Popups & Modals

```cpp
// Popup
if (ImGui::Button("Open Popup")) {
    ImGui::OpenPopup("MyPopup");
}

if (ImGui::BeginPopup("MyPopup")) {
    ImGui::Text("Popup content");
    if (ImGui::Button("Close")) {
        ImGui::CloseCurrentPopup();
    }
    ImGui::EndPopup();
}

// Modal
if (ImGui::Button("Open Modal")) {
    ImGui::OpenPopup("Modal");
}

if (ImGui::BeginPopupModal("Modal", nullptr, ImGuiWindowFlags_AlwaysAutoResize)) {
    ImGui::Text("Are you sure?");
    if (ImGui::Button("Yes")) {
        ImGui::CloseCurrentPopup();
    }
    ImGui::SameLine();
    if (ImGui::Button("No")) {
        ImGui::CloseCurrentPopup();
    }
    ImGui::EndPopup();
}
```

### 7.3 Drag & Drop

```cpp
// Source
if (ImGui::Button("Drag me")) {
    if (ImGui::BeginDragDropSource()) {
        int data = 42;
        ImGui::SetDragDropPayload("MY_TYPE", &data, sizeof(data));
        ImGui::Text("Dragging...");
        ImGui::EndDragDropSource();
    }
}

// Target
ImGui::Button("Drop here");
if (ImGui::BeginDragDropTarget()) {
    if (const ImGuiPayload* payload = ImGui::AcceptDragDropPayload("MY_TYPE")) {
        int data = *(int*)payload->Data;
        // Handle drop
    }
    ImGui::EndDragDropTarget();
}
```

### 7.4 Docking (Docking Branch)

```cpp
ImGuiIO& io = ImGui::GetIO();
io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;

// In the render loop
ImGui::DockSpaceOverViewport(ImGui::GetMainViewport());
```

### 7.5 Plots (with ImPlot)

```cpp
// Requires the ImPlot addon
#include <implot.h>

ImPlot::CreateContext();

if (ImPlot::BeginPlot("My Plot")) {
    float x[] = {1, 2, 3, 4, 5};
    float y[] = {1, 4, 9, 16, 25};
    ImPlot::PlotLine("y = x²", x, y, 5);
    ImPlot::EndPlot();
}

ImPlot::DestroyContext();
```

---

## 8. Troubleshooting

### 8.1 "imgui.h not found"

**Problem:** Header not found

**Solution:** Check the PostFetch hook, set include paths.

### 8.2 Black Window

**Problem:** ImGui is not rendered

**Solution:** Check the render order:
```cpp
ImGui_ImplOpenGL3_NewFrame();  // 1. First
ImGui_ImplGlfw_NewFrame();
ImGui::NewFrame();
// UI code                      // 2. Then UI
ImGui::Render();               // 3. Then render
ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());  // 4. Last
```

### 8.3 Input Does Not Work

**Problem:** Clicks are not detected

**Solution:** `ImGui_ImplGlfw_InitForOpenGL(window, true)` — second parameter `true`!

### 8.4 Fonts Not Loaded

**Problem:** Fonts do not appear

**Solution:** Load the font before the first frame:
```cpp
io.Fonts->AddFontFromFileTTF("font.ttf", 16.0f);
// ONLY THEN start the main loop
```

---

## 9. Further Information

### Official Resources

| Resource | Link |
|----------|------|
| **GitHub** | [github.com/ocornut/imgui](https://github.com/ocornut/imgui) |
| **Wiki** | [github.com/ocornut/imgui/wiki](https://github.com/ocornut/imgui/wiki) |
| **Demo** | `ImGui::ShowDemoWindow()` in code |
| **FAQ** | [github.com/ocornut/imgui/blob/master/docs/FAQ.md](https://github.com/ocornut/imgui/blob/master/docs/FAQ.md) |

### Addons

| Addon | Description | Link |
|-------|-------------|------|
| **ImPlot** | Plotting | [github.com/epezent/implot](https://github.com/epezent/implot) |
| **ImGuizmo** | 3D gizmos | [github.com/CedricGuillemet/ImGuizmo](https://github.com/CedricGuillemet/ImGuizmo) |
| **ImGuiFileDialog** | File dialogs | [github.com/aiekick/ImGuiFileDialog](https://github.com/aiekick/ImGuiFileDialog) |

### See Also

- [Externals.md](../Externals.md) — Externals combinations
- [Git_Externals_GUI.md](../../references/externals/Git_Externals_GUI.md) — Reference
- [glad.md](Glad.md) — OpenGL loader
- [glfw.md](Glfw.md) — Window & Input

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.2 | 2025-12-15 | Initial: detailed UserGuide for Dear ImGui |
