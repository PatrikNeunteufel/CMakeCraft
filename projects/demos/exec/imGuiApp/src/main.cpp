// =============================================================================
// imGuiApp – ImGui + OpenGL Demo Application
// =============================================================================
//
// Application: imGuiApp
// Version:     0.2.0
// Date:        2025-12-10
// Part of:     CMake Architecture V2 (Phase 6 Demo)
//
// Description:
//   Demonstrates integration of fetched externals:
//   - Dear ImGui (UI) with Docking support
//   - GLAD (OpenGL Loader)
//   - GLFW (Window Management)
//
// Dependencies:
//   - BasicLogger (internal library)
//   - imgui (fetched external, docking branch)
//   - glad (local external)
//   - glfw (fetched external)
//
// Changes v0.2.0:
//   - Docking enabled
//   - Viewport support (multi-window)
//   - Improved documentation
//
// =============================================================================

#include <BasicLogger.h>

// GLAD must be included before GLFW
#include <glad/glad.h>
#include <GLFW/glfw3.h>

// ImGui
#include <imgui.h>
#include <imgui_impl_glfw.h>
#include <imgui_impl_opengl3.h>

#include <iostream>
#include <string>

#if defined(_WIN32) || defined(WIN32)
#include <windows.h>
#endif


// =============================================================================
// Configuration
// =============================================================================

namespace Config {
    constexpr int WINDOW_WIDTH = 1280;
    constexpr int WINDOW_HEIGHT = 720;
    constexpr const char* WINDOW_TITLE = "ImGui Demo - CMake Architecture V2";
    constexpr const char* LOG_FILE = "imgui.log";
    constexpr const char* GLSL_VERSION = "#version 330";
}

// =============================================================================
// Application State
// =============================================================================

struct AppState {
    bool showDemoWindow = true;
    bool showAboutWindow = true;
    bool showMetricsWindow = false;
    bool showStyleEditor = false;
    ImVec4 clearColor = ImVec4(0.1f, 0.1f, 0.12f, 1.0f);
    int frameCount = 0;
};

// =============================================================================
// Logger (global)
// =============================================================================

BasicLogger::Logger logger(Config::LOG_FILE);

// =============================================================================
// GLFW Error Callback
// =============================================================================

void glfwErrorCallback(int error, const char* description) {
    logger.error("GLFW Error " + std::to_string(error) + ": " + description);
}

// =============================================================================
// Initialize GLFW
// =============================================================================

GLFWwindow* initGLFW() {
    glfwSetErrorCallback(glfwErrorCallback);
    
    if (!glfwInit()) {
        logger.error("Failed to initialize GLFW");
        return nullptr;
    }
    logger.info("GLFW initialized");
    
    // OpenGL version hints
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    
#ifdef __APPLE__
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
#endif
    
    // Create window
    GLFWwindow* window = glfwCreateWindow(
        Config::WINDOW_WIDTH, 
        Config::WINDOW_HEIGHT, 
        Config::WINDOW_TITLE, 
        nullptr, 
        nullptr
    );
    
    if (!window) {
        logger.error("Failed to create GLFW window");
        glfwTerminate();
        return nullptr;
    }
    
    logger.info("Window created: " + std::to_string(Config::WINDOW_WIDTH) + 
                "x" + std::to_string(Config::WINDOW_HEIGHT));
    
    glfwMakeContextCurrent(window);
    glfwSwapInterval(1);  // Enable VSync
    
    return window;
}

// =============================================================================
// Initialize GLAD
// =============================================================================

bool initGLAD() {
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        logger.error("Failed to initialize GLAD");
        return false;
    }
    
    logger.info("GLAD initialized - OpenGL " +
                std::string(reinterpret_cast<const char*>(glGetString(GL_VERSION))));
    return true;
}

// =============================================================================
// Initialize ImGui
// =============================================================================

void initImGui(GLFWwindow* window) {
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    
    ImGuiIO& io = ImGui::GetIO();
    
    // -------------------------------------------------------------------------
    // Enable Features
    // -------------------------------------------------------------------------
    
    // Keyboard navigation
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
    
    // Gamepad navigation (optional)
    // io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;
    
    // Docking support (requires docking branch)
    io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;
    
    // Multi-viewport / platform windows (optional, experimental)
    // Allows ImGui windows to be dragged outside the main window
    io.ConfigFlags |= ImGuiConfigFlags_ViewportsEnable;
    
    // -------------------------------------------------------------------------
    // Docking Configuration
    // -------------------------------------------------------------------------
    
    // Allow docking over central node (main viewport)
    io.ConfigDockingWithShift = false;  // Dock without holding Shift
    io.ConfigDockingAlwaysTabBar = true; // Always show tab bar when docked
    
    // -------------------------------------------------------------------------
    // Style Configuration
    // -------------------------------------------------------------------------
    
    ImGui::StyleColorsDark();
    
    // When viewports are enabled, tweak WindowRounding/WindowBg so platform 
    // windows can look identical to regular ones.
    ImGuiStyle& style = ImGui::GetStyle();
    if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable) {
        style.WindowRounding = 0.0f;
        style.Colors[ImGuiCol_WindowBg].w = 1.0f;
    }
    
    // -------------------------------------------------------------------------
    // Platform/Renderer Backends
    // -------------------------------------------------------------------------
    
    ImGui_ImplGlfw_InitForOpenGL(window, true);
    ImGui_ImplOpenGL3_Init(Config::GLSL_VERSION);
    
    logger.info("ImGui initialized - Version " + std::string(IMGUI_VERSION));
    logger.info("  Docking: " + std::string(
        (io.ConfigFlags & ImGuiConfigFlags_DockingEnable) ? "Enabled" : "Disabled"));
    logger.info("  Viewports: " + std::string(
        (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable) ? "Enabled" : "Disabled"));
}

// =============================================================================
// Render UI
// =============================================================================

void renderUI(AppState& state) {
    ImGuiIO& io = ImGui::GetIO();
    
    // -------------------------------------------------------------------------
    // Dockspace over entire viewport (optional)
    // -------------------------------------------------------------------------
    
    // This creates a dockspace that covers the entire viewport, allowing
    // all windows to be docked into it.
    ImGui::DockSpaceOverViewport(0, ImGui::GetMainViewport());
    
    // -------------------------------------------------------------------------
    // Main Menu Bar
    // -------------------------------------------------------------------------
    
    if (ImGui::BeginMainMenuBar()) {
        if (ImGui::BeginMenu("File")) {
            if (ImGui::MenuItem("Exit", "Alt+F4")) {
                // Request close - will be handled in main loop
            }
            ImGui::EndMenu();
        }
        
        if (ImGui::BeginMenu("View")) {
            ImGui::MenuItem("Demo Window", nullptr, &state.showDemoWindow);
            ImGui::MenuItem("About", nullptr, &state.showAboutWindow);
            ImGui::Separator();
            ImGui::MenuItem("Metrics", nullptr, &state.showMetricsWindow);
            ImGui::MenuItem("Style Editor", nullptr, &state.showStyleEditor);
            ImGui::EndMenu();
        }
        
        if (ImGui::BeginMenu("Help")) {
            ImGui::Text("ImGui Demo - CMake Architecture V2");
            ImGui::Text("Phase 6: Fetched Externals");
            ImGui::EndMenu();
        }
        
        // Right-aligned FPS display
        ImGui::SetCursorPosX(ImGui::GetWindowWidth() - 120);
        ImGui::Text("FPS: %.1f", io.Framerate);
        
        ImGui::EndMainMenuBar();
    }
    
    // -------------------------------------------------------------------------
    // ImGui Demo Window
    // -------------------------------------------------------------------------
    
    if (state.showDemoWindow) {
        ImGui::ShowDemoWindow(&state.showDemoWindow);
    }
    
    // -------------------------------------------------------------------------
    // Metrics Window (debug)
    // -------------------------------------------------------------------------
    
    if (state.showMetricsWindow) {
        ImGui::ShowMetricsWindow(&state.showMetricsWindow);
    }
    
    // -------------------------------------------------------------------------
    // Style Editor
    // -------------------------------------------------------------------------
    
    if (state.showStyleEditor) {
        ImGui::Begin("Style Editor", &state.showStyleEditor);
        ImGui::ShowStyleEditor();
        ImGui::End();
    }
    
    // -------------------------------------------------------------------------
    // About Window
    // -------------------------------------------------------------------------
    
    if (state.showAboutWindow) {
        ImGui::Begin("About - CMake Architecture V2", &state.showAboutWindow);
        
        ImGui::Text("Phase 6: Fetched Externals Demo");
        ImGui::Separator();
        
        ImGui::Text("This application demonstrates:");
        ImGui::BulletText("Git-based external fetching");
        ImGui::BulletText("Hook system (PreFetch/PostFetch)");
        ImGui::BulletText("Target registry");
        ImGui::BulletText("ImGui integration with Docking");
        
        ImGui::Separator();
        
        ImGui::Text("Externals used:");
        ImGui::BulletText("imgui v1.91.6-docking (PostFetch hook)");
        ImGui::BulletText("glad (local external)");
        ImGui::BulletText("glfw 3.4 (fetched, PreFetch hook)");
        
        ImGui::Separator();
        
        // Features enabled
        ImGuiIO& io = ImGui::GetIO();
        ImGui::Text("Features:");
        ImGui::BulletText("Docking: %s", 
            (io.ConfigFlags & ImGuiConfigFlags_DockingEnable) ? "Yes" : "No");
        ImGui::BulletText("Viewports: %s", 
            (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable) ? "Yes" : "No");
        
        ImGui::Separator();
        
        ImGui::Text("Frame: %d", state.frameCount);
        ImGui::Text("FPS: %.1f", io.Framerate);
        
        ImGui::ColorEdit3("Background", (float*)&state.clearColor);
        
        if (ImGui::Button("Toggle Demo Window")) {
            state.showDemoWindow = !state.showDemoWindow;
        }
        
        ImGui::End();
    }
}

// =============================================================================
// Main Loop
// =============================================================================

void mainLoop(GLFWwindow* window, AppState& state) {
    logger.info("Entering main loop...");
    
    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();
        
        // Start ImGui frame
        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();
        
        // Render UI
        renderUI(state);
        
        // Rendering
        ImGui::Render();
        
        int displayW, displayH;
        glfwGetFramebufferSize(window, &displayW, &displayH);
        glViewport(0, 0, displayW, displayH);
        glClearColor(state.clearColor.x, state.clearColor.y, 
                     state.clearColor.z, state.clearColor.w);
        glClear(GL_COLOR_BUFFER_BIT);
        
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
        
        // Update and Render additional Platform Windows (Viewports)
        ImGuiIO& io = ImGui::GetIO();
        if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable) {
            GLFWwindow* backup_current_context = glfwGetCurrentContext();
            ImGui::UpdatePlatformWindows();
            ImGui::RenderPlatformWindowsDefault();
            glfwMakeContextCurrent(backup_current_context);
        }
        
        glfwSwapBuffers(window);
        state.frameCount++;
    }
}

// =============================================================================
// Cleanup
// =============================================================================

void cleanup(GLFWwindow* window) {
    logger.info("Shutting down...");
    
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();
    
    glfwDestroyWindow(window);
    glfwTerminate();
    
    logger.info("Application terminated successfully");
}

// =============================================================================
// Common Main Logic
// =============================================================================

int commonMain() {
    logger.setLevel(BasicLogger::Level::Debug);
    logger.setConsoleOutput(false);
    
    logger.info("=== imGuiApp v0.2.0 - Phase 6 Demo ===");
    
    // Initialize GLFW & Window
    GLFWwindow* window = initGLFW();
    if (!window) return 1;
    
    // Initialize GLAD
    if (!initGLAD()) {
        glfwDestroyWindow(window);
        glfwTerminate();
        return 1;
    }
    
    // Initialize ImGui
    initImGui(window);
    
    // Application state
    AppState state;
    
    // Run main loop
    mainLoop(window, state);
    
    // Cleanup
    cleanup(window);
    
    return 0;
}

// =============================================================================
// Platform-specific Entry Points
// =============================================================================

#if defined(APP_WINDOWS_GUI)
// Windows GUI: WinMain entry point (no console window)
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int) {
    return commonMain();
}
#else
// Console / Linux / macOS: standard main
int main(int /*argc*/, char* /*argv*/[]) {
    return commonMain();
}
#endif
