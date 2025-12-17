// ==============================================================================
// main.cpp - DemoPlayer Entry Point
// ==============================================================================
//
// This file contains ONLY the entry point.
// All business logic is in DemoPlayer.Core (Application class).
//
// This separation enables:
// - Unit testing of Application without main() conflicts
// - Clean dependency injection
// - Headless testing
//
// ==============================================================================

#include "Application.hpp"

int main(int argc, char* argv[]) {
    DemoPlayer::Application app;
    
    if (!app.initialize(argc, argv)) {
        return 1;
    }
    
    return app.run();
}
