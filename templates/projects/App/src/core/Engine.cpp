// ==============================================================================
// Engine.cpp - Core Engine Implementation
// CMake Architecture V2 - App-Container Template
// ==============================================================================

#include "core/Engine.hpp"
#include <iostream>

namespace app::core {

void Engine::update() {
    m_running = true;
    std::cout << "[Engine] Update tick" << std::endl;
}

} // namespace app::core
