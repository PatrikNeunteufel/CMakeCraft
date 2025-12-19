// ==============================================================================
// test_Application.cpp - Application Unit Tests
// CMake Architecture V2 - App-Container Template
// ==============================================================================

#include <doctest/doctest.h>
#include "Application.hpp"

TEST_SUITE("Application") {

    TEST_CASE("Application can be created") {
        app::Application app;
        // Just check it doesn't throw
        CHECK(true);
    }
    
    TEST_CASE("Application initializes successfully") {
        app::Application app;
        CHECK(app.initialize() == true);
        app.shutdown();
    }
    
    TEST_CASE("Application runs and returns 0") {
        app::Application app;
        REQUIRE(app.initialize());
        CHECK(app.run() == 0);
        app.shutdown();
    }

}
