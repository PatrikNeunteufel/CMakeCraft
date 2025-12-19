// ==============================================================================
// main.cpp - Application Entry Point (Runner)
// CMake Architecture V2 - App-Container Template
// ==============================================================================
//
// This is the minimal Runner that instantiates and runs the Application.
// All business logic lives in the Core library (Application class).
//
// ==============================================================================

#include "Application.hpp"

int main([[maybe_unused]] int argc, [[maybe_unused]] char* argv[]) {
    app::Application application;
    
    if (!application.initialize()) {
        return 1;
    }
    
    int result = application.run();
    
    application.shutdown();
    
    return result;
}
