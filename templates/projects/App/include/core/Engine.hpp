#pragma once
// ==============================================================================
// Engine.hpp - Core Engine Header
// CMake Architecture V2 - App-Container Template
// ==============================================================================

namespace app::core {

/**
 * @brief Core engine class
 * 
 * Provides the main processing logic for the application.
 */
class Engine {
public:
    Engine() = default;
    ~Engine() = default;
    
    /// Process one frame/iteration
    void update();
    
    /// Check if engine is running
    bool isRunning() const { return m_running; }

private:
    bool m_running = false;
};

} // namespace app::core
