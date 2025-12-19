// ==============================================================================
// test_Application_Integration.cpp - Integration Tests
// CMake Architecture V2 - App-Container Template
// ==============================================================================

#include <doctest/doctest.h>
#include "Application.hpp"

TEST_SUITE("Application Integration") {

    TEST_CASE("Full application lifecycle") {
        app::Application app;
        
        SUBCASE("Initialize -> Run -> Shutdown sequence") {
            CHECK(app.initialize());
            CHECK(app.run() == 0);
            app.shutdown();
        }
    }
    
    TEST_CASE("Multiple application instances") {
        app::Application app1;
        app::Application app2;
        
        CHECK(app1.initialize());
        CHECK(app2.initialize());
        
        app1.shutdown();
        app2.shutdown();
    }

}
