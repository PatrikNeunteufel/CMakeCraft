// ==============================================================================
// test_Application.cpp - DemoPlayer Unit Tests
// ==============================================================================
//
// Tests the Application class from DemoPlayer.Core
// Uses doctest framework
//
// ==============================================================================

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.h>
#include "Application.hpp"

TEST_CASE("Application - Construction") {
    DemoPlayer::Application app;

    CHECK(app.isInitialized() == false);
    CHECK(app.getName() == "DemoPlayer");
    CHECK(app.getVersion() == "0.5.0");
}

TEST_CASE("Application - Initialization") {
    DemoPlayer::Application app;

    SUBCASE("Initialize with no arguments") {
        char* argv[] = { (char*)"DemoPlayer", nullptr };
        int argc = 1;

        bool result = app.initialize(argc, argv);

        CHECK(result == true);
        CHECK(app.isInitialized() == true);
    }
}

TEST_CASE("Application - Run") {
    DemoPlayer::Application app;

    SUBCASE("Run without initialization fails") {
        // Note: This would output to stderr, but we're testing the return code
        // In a real test, we might redirect stderr
        int result = app.run();
        CHECK(result == 1);
    }

    SUBCASE("Run after initialization succeeds") {
        char* argv[] = { (char*)"DemoPlayer", nullptr };
        app.initialize(1, argv);

        int result = app.run();
        CHECK(result == 0);
    }
}

TEST_CASE("Application - Getters") {
    DemoPlayer::Application app;

    CHECK(app.getName() == "DemoPlayer");
    CHECK(app.getVersion() == "0.5.0");
    CHECK_FALSE(app.getName().empty());
    CHECK_FALSE(app.getVersion().empty());
}