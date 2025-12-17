// ==============================================================================
// Application.cpp - DemoPlayer Core Implementation
// ==============================================================================

#include "Application.hpp"
#include <iostream>

namespace DemoPlayer {

Application::Application()
    : m_initialized(false)
    , m_name("DemoPlayer")
    , m_version("0.5.0")
{
}

Application::~Application() = default;

bool Application::initialize(int argc, char* argv[]) {
    // Simple initialization - just mark as initialized
    // In a real app, this would parse arguments, load config, etc.
    
    (void)argc;  // Unused for now
    (void)argv;  // Unused for now
    
    m_initialized = true;
    return true;
}

int Application::run() {
    if (!m_initialized) {
        std::cerr << "Error: Application not initialized!" << std::endl;
        return 1;
    }
    
    std::cout << "=== " << m_name << " v" << m_version << " ===" << std::endl;
    std::cout << "App-Container Demo running successfully!" << std::endl;
    std::cout << "This demonstrates the Core/Runner separation." << std::endl;
    
    return 0;
}

std::string Application::getName() const {
    return m_name;
}

std::string Application::getVersion() const {
    return m_version;
}

bool Application::isInitialized() const {
    return m_initialized;
}

} // namespace DemoPlayer
