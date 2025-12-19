// test_E2E.cpp - End-to-End Tests
#include <doctest/doctest.h>
#include "Application.hpp"

TEST_SUITE("End-to-End") {
    TEST_CASE("Complete user workflow") {
        app::Application app;
        REQUIRE(app.initialize());
        CHECK(app.run() == 0);
        app.shutdown();
    }
}
