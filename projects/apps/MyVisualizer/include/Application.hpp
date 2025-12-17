#pragma once
// ==============================================================================
// Application.hpp - DemoPlayer Core Application
// ==============================================================================
//
// Part of:     CMake Architecture V2 - Phase 8 Demo
// Description: Main application class demonstrating App-Container pattern
//
// ==============================================================================

#include <string>

namespace DemoPlayer {

/**
 * @brief Main application class
 * 
 * This class contains all business logic and is fully testable
 * because it's separated from the entry point (main()).
 */
class Application {
public:
    Application();
    ~Application();
    
    /**
     * @brief Initialize the application
     * @param argc Argument count from main()
     * @param argv Argument values from main()
     * @return true if initialization successful
     */
    bool initialize(int argc, char* argv[]);
    
    /**
     * @brief Run the main application loop
     * @return Exit code (0 = success)
     */
    int run();
    
    /**
     * @brief Get application name
     * @return Application name string
     */
    std::string getName() const;
    
    /**
     * @brief Get application version
     * @return Version string
     */
    std::string getVersion() const;
    
    /**
     * @brief Check if application is initialized
     * @return true if initialized
     */
    bool isInitialized() const;

private:
    bool m_initialized;
    std::string m_name;
    std::string m_version;
};

} // namespace DemoPlayer
