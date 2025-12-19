// ==============================================================================
// Application.cpp - Main Application Implementation
// CMake Architecture V2 - App-Container Template
// ==============================================================================

#include "Application.hpp"
#include "Application.impl"  // PIMPL implementation

namespace app {

Application::Application() : m_impl(std::make_unique<Impl>()) {
}

Application::~Application() = default;

bool Application::initialize() {
    return m_impl->initialize();
}

int Application::run() {
    return m_impl->run();
}

void Application::shutdown() {
    m_impl->shutdown();
}

} // namespace app
