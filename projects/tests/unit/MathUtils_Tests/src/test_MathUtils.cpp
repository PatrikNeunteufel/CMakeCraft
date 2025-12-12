// ==============================================================================
// test_MathUtils.cpp – Unit Tests for MathUtils (Catch2)
// ==============================================================================
//
// Test:        MathUtils_UnitTests
// Framework:   Catch2
// Type:        unit
// Version:     1.0.0
// Date:        2025-12-12
//
// Description:
//   Unit tests demonstrating Catch2 features:
//   - TEST_CASE, SECTION
//   - REQUIRE, CHECK
//   - SCENARIO (BDD-style)
//   - Matchers
//   - Generators
//
// ==============================================================================

#include <catch2/catch_all.hpp>
#include <cmath>
#include <vector>
#include <limits>

// ==============================================================================
// Simple Math Utilities (to test)
// ==============================================================================

namespace MathUtils {

int factorial(int n) {
    if (n < 0) throw std::invalid_argument("Negative input");
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}

double clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
}

bool isEven(int n) {
    return n % 2 == 0;
}

double lerp(double a, double b, double t) {
    return a + t * (b - a);
}

std::vector<int> range(int start, int end) {
    std::vector<int> result;
    for (int i = start; i < end; ++i) {
        result.push_back(i);
    }
    return result;
}

} // namespace MathUtils

// ==============================================================================
// Basic Tests with SECTION
// ==============================================================================

TEST_CASE("Factorial calculation", "[math][factorial]") {
    SECTION("factorial of 0 is 1") {
        REQUIRE(MathUtils::factorial(0) == 1);
    }
    
    SECTION("factorial of 1 is 1") {
        REQUIRE(MathUtils::factorial(1) == 1);
    }
    
    SECTION("factorial of positive numbers") {
        CHECK(MathUtils::factorial(2) == 2);
        CHECK(MathUtils::factorial(3) == 6);
        CHECK(MathUtils::factorial(4) == 24);
        CHECK(MathUtils::factorial(5) == 120);
        CHECK(MathUtils::factorial(10) == 3628800);
    }
    
    SECTION("factorial of negative throws") {
        REQUIRE_THROWS_AS(MathUtils::factorial(-1), std::invalid_argument);
        REQUIRE_THROWS_WITH(MathUtils::factorial(-5), "Negative input");
    }
}

TEST_CASE("Clamp function", "[math][clamp]") {
    SECTION("value within range") {
        CHECK(MathUtils::clamp(5.0, 0.0, 10.0) == 5.0);
        CHECK(MathUtils::clamp(0.5, 0.0, 1.0) == 0.5);
    }
    
    SECTION("value below minimum") {
        CHECK(MathUtils::clamp(-5.0, 0.0, 10.0) == 0.0);
        CHECK(MathUtils::clamp(-100.0, -50.0, 50.0) == -50.0);
    }
    
    SECTION("value above maximum") {
        CHECK(MathUtils::clamp(15.0, 0.0, 10.0) == 10.0);
        CHECK(MathUtils::clamp(1000.0, 0.0, 100.0) == 100.0);
    }
    
    SECTION("edge cases") {
        CHECK(MathUtils::clamp(0.0, 0.0, 10.0) == 0.0);
        CHECK(MathUtils::clamp(10.0, 0.0, 10.0) == 10.0);
    }
}

// ==============================================================================
// BDD-Style Tests (SCENARIO/GIVEN/WHEN/THEN)
// ==============================================================================

SCENARIO("Linear interpolation", "[math][lerp]") {
    GIVEN("two values and interpolation factor") {
        double a = 0.0;
        double b = 100.0;
        
        WHEN("t is 0") {
            double result = MathUtils::lerp(a, b, 0.0);
            
            THEN("result equals first value") {
                REQUIRE(result == a);
            }
        }
        
        WHEN("t is 1") {
            double result = MathUtils::lerp(a, b, 1.0);
            
            THEN("result equals second value") {
                REQUIRE(result == b);
            }
        }
        
        WHEN("t is 0.5") {
            double result = MathUtils::lerp(a, b, 0.5);
            
            THEN("result is midpoint") {
                REQUIRE(result == 50.0);
            }
        }
        
        WHEN("t is 0.25") {
            double result = MathUtils::lerp(a, b, 0.25);
            
            THEN("result is 25% between values") {
                REQUIRE(result == 25.0);
            }
        }
    }
}

SCENARIO("Range generation", "[math][range]") {
    GIVEN("a start and end value") {
        WHEN("generating range 0 to 5") {
            auto result = MathUtils::range(0, 5);
            
            THEN("result has 5 elements") {
                REQUIRE(result.size() == 5);
            }
            
            THEN("elements are sequential") {
                REQUIRE(result == std::vector<int>{0, 1, 2, 3, 4});
            }
        }
        
        WHEN("start equals end") {
            auto result = MathUtils::range(5, 5);
            
            THEN("result is empty") {
                REQUIRE(result.empty());
            }
        }
    }
}

// ==============================================================================
// Using Matchers
// ==============================================================================

TEST_CASE("isEven function", "[math][even]") {
    using Catch::Matchers::Equals;
    
    SECTION("even numbers") {
        CHECK(MathUtils::isEven(0));
        CHECK(MathUtils::isEven(2));
        CHECK(MathUtils::isEven(-2));
        CHECK(MathUtils::isEven(100));
    }
    
    SECTION("odd numbers") {
        CHECK_FALSE(MathUtils::isEven(1));
        CHECK_FALSE(MathUtils::isEven(-1));
        CHECK_FALSE(MathUtils::isEven(99));
    }
}

TEST_CASE("Range with matchers", "[math][range][matchers]") {
    using Catch::Matchers::SizeIs;
    using Catch::Matchers::Contains;
    using Catch::Matchers::AllMatch;
    
    auto result = MathUtils::range(1, 6);
    
    CHECK_THAT(result, SizeIs(5));
    CHECK_THAT(result, Contains(3));
    CHECK_THAT(result, AllMatch(Catch::Matchers::Predicate<int>(
        [](int i) { return i >= 1 && i < 6; },
        "is in range [1, 6)"
    )));
}

// ==============================================================================
// Generators (Data-Driven Tests)
// ==============================================================================

TEST_CASE("Factorial with generators", "[math][factorial][generator]") {
    auto [n, expected] = GENERATE(table<int, int>({
        {0, 1},
        {1, 1},
        {2, 2},
        {3, 6},
        {4, 24},
        {5, 120}
    }));
    
    CAPTURE(n);
    REQUIRE(MathUtils::factorial(n) == expected);
}

TEST_CASE("Clamp with generated values", "[math][clamp][generator]") {
    double value = GENERATE(take(10, random(-100.0, 100.0)));
    double min = 0.0;
    double max = 50.0;
    
    CAPTURE(value);
    
    double result = MathUtils::clamp(value, min, max);
    
    CHECK(result >= min);
    CHECK(result <= max);
}

// ==============================================================================
// Floating Point Comparisons
// ==============================================================================

TEST_CASE("Floating point lerp", "[math][lerp][float]") {
    using Catch::Matchers::WithinAbs;
    using Catch::Matchers::WithinRel;
    
    double result = MathUtils::lerp(0.0, 1.0, 0.3333);
    
    // Absolute tolerance
    CHECK_THAT(result, WithinAbs(0.3333, 0.0001));
    
    // Relative tolerance
    CHECK_THAT(result, WithinRel(0.3333, 0.01));
}
