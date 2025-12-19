// test_Smoke.cpp - Smoke Tests (Quick Sanity Checks)
#include <doctest/doctest.h>
#include "Application.hpp"

TEST_SUITE("Smoke") {

    TEST_CASE("Application can be instantiated") {
        app::Application app;
        CHECK(true);  // Just verifies no crash on construction
    }
    
    TEST_CASE("Headers are includable") {
        // This test passes if compilation succeeds
        CHECK(true);
    }

}
