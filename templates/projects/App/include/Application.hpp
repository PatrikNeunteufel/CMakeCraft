#pragma once
// ==============================================================================
// Application.hpp - Main Application Header
// CMake Architecture V2 - App-Container Template
// ==============================================================================

#include "core/Engine.hpp"

namespace app {

/**
 * @brief Main application class
 * 
 * This class serves as the entry point for the application logic.
 * The Runner (main.cpp) instantiates and runs this class.
 */
class Application {
public:
    Application();
    ~Application();
    
    /// Initialize the application
    bool initialize();
    
    /// Run the main loop
    int run();
    
    /// Shutdown and cleanup
    void shutdown();

private:
    class Impl;  // PIMPL idiom
    std::unique_ptr<Impl> m_impl;
};

} // namespace app
