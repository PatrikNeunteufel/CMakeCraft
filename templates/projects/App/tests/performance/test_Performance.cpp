// ==============================================================================
// test_Performance.cpp - Performance Tests
// CMake Architecture V2 - App-Container Template
// ==============================================================================

#include <doctest/doctest.h>
#include <chrono>
#include "Application.hpp"

TEST_SUITE("Performance") {

    TEST_CASE("Application initialization time") {
        auto start = std::chrono::high_resolution_clock::now();
        
        app::Application app;
        app.initialize();
        
        auto end = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
        
        MESSAGE("Initialization took: " << duration.count() << "ms");
        CHECK(duration.count() < 1000);  // Should initialize in under 1 second
        
        app.shutdown();
    }

}
