#include <doctest/doctest.h>
#include "MyLib.hpp"

TEST_CASE("compute adds two numbers") {
    CHECK(mylib::compute(2, 3) == 5);
    CHECK(mylib::compute(-1, 1) == 0);
}
