// bench_Application.cpp - Application Benchmarks
#include <doctest/doctest.h>
#include <chrono>
#include "Application.hpp"

TEST_SUITE("Benchmarks") {

    TEST_CASE("Application lifecycle benchmark") {
        constexpr int iterations = 100;
        
        auto start = std::chrono::high_resolution_clock::now();
        
        for (int i = 0; i < iterations; ++i) {
            app::Application app;
            app.initialize();
            app.shutdown();
        }
        
        auto end = std::chrono::high_resolution_clock::now();
        auto total = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
        auto average = total.count() / iterations;
        
        MESSAGE("Average lifecycle time: " << average << " µs");
        MESSAGE("Total for " << iterations << " iterations: " << total.count() << " µs");
        
        CHECK(average < 10000);  // Should complete in under 10ms per iteration
    }

}
