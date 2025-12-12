// ==============================================================================
// test_StringUtils.cpp – Unit Tests for StringUtils (GoogleTest)
// ==============================================================================
//
// Test:        StringUtils_UnitTests
// Framework:   GoogleTest
// Type:        unit
// Version:     1.0.0
// Date:        2025-12-12
//
// Description:
//   Unit tests demonstrating GoogleTest features:
//   - TEST, TEST_F (fixtures)
//   - EXPECT_*, ASSERT_*
//   - Parameterized tests
//   - Death tests
//   - Matchers (GMock)
//
// ==============================================================================

#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include <string>
#include <vector>
#include <algorithm>
#include <stdexcept>

// ==============================================================================
// Simple String Utilities (to test)
// ==============================================================================

namespace StringUtils {

std::string trim(const std::string& str) {
    size_t first = str.find_first_not_of(" \t\n\r");
    if (first == std::string::npos) return "";
    size_t last = str.find_last_not_of(" \t\n\r");
    return str.substr(first, last - first + 1);
}

std::vector<std::string> split(const std::string& str, char delimiter) {
    std::vector<std::string> result;
    size_t start = 0;
    size_t end = str.find(delimiter);
    
    while (end != std::string::npos) {
        result.push_back(str.substr(start, end - start));
        start = end + 1;
        end = str.find(delimiter, start);
    }
    result.push_back(str.substr(start));
    return result;
}

std::string toUpper(const std::string& str) {
    std::string result = str;
    std::transform(result.begin(), result.end(), result.begin(), ::toupper);
    return result;
}

std::string toLower(const std::string& str) {
    std::string result = str;
    std::transform(result.begin(), result.end(), result.begin(), ::tolower);
    return result;
}

} // namespace StringUtils

// ==============================================================================
// Basic Tests (TEST macro)
// ==============================================================================

TEST(StringUtilsTrimTest, RemovesLeadingSpaces) {
    EXPECT_EQ(StringUtils::trim("  hello"), "hello");
}

TEST(StringUtilsTrimTest, RemovesTrailingSpaces) {
    EXPECT_EQ(StringUtils::trim("hello  "), "hello");
}

TEST(StringUtilsTrimTest, RemovesBothSides) {
    EXPECT_EQ(StringUtils::trim("  hello  "), "hello");
}

TEST(StringUtilsTrimTest, HandlesEmptyString) {
    EXPECT_EQ(StringUtils::trim(""), "");
}

TEST(StringUtilsTrimTest, HandlesOnlySpaces) {
    EXPECT_EQ(StringUtils::trim("   "), "");
}

TEST(StringUtilsTrimTest, PreservesInternalSpaces) {
    EXPECT_EQ(StringUtils::trim("  hello world  "), "hello world");
}

// ==============================================================================
// Test Fixture (TEST_F macro)
// ==============================================================================

class StringUtilsSplitTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Setup code before each test
        testString = "a,b,c,d";
        delimiter = ',';
    }
    
    void TearDown() override {
        // Cleanup code after each test
    }
    
    std::string testString;
    char delimiter;
};

TEST_F(StringUtilsSplitTest, SplitsCorrectly) {
    auto result = StringUtils::split(testString, delimiter);
    
    ASSERT_EQ(result.size(), 4);
    EXPECT_EQ(result[0], "a");
    EXPECT_EQ(result[1], "b");
    EXPECT_EQ(result[2], "c");
    EXPECT_EQ(result[3], "d");
}

TEST_F(StringUtilsSplitTest, HandlesNoDelimiter) {
    auto result = StringUtils::split("hello", ',');
    
    ASSERT_EQ(result.size(), 1);
    EXPECT_EQ(result[0], "hello");
}

TEST_F(StringUtilsSplitTest, HandlesEmptyParts) {
    auto result = StringUtils::split("a,,c", ',');
    
    ASSERT_EQ(result.size(), 3);
    EXPECT_EQ(result[0], "a");
    EXPECT_EQ(result[1], "");
    EXPECT_EQ(result[2], "c");
}

// ==============================================================================
// Parameterized Tests
// ==============================================================================

class ToUpperTest : public ::testing::TestWithParam<std::pair<std::string, std::string>> {};

TEST_P(ToUpperTest, ConvertsCorrectly) {
    auto [input, expected] = GetParam();
    EXPECT_EQ(StringUtils::toUpper(input), expected);
}

INSTANTIATE_TEST_SUITE_P(
    StringUtilsTests,
    ToUpperTest,
    ::testing::Values(
        std::make_pair("hello", "HELLO"),
        std::make_pair("HELLO", "HELLO"),
        std::make_pair("HeLLo", "HELLO"),
        std::make_pair("", ""),
        std::make_pair("123", "123"),
        std::make_pair("hello world", "HELLO WORLD")
    )
);

// ==============================================================================
// Using GMock Matchers
// ==============================================================================

TEST(StringUtilsMatchersTest, SplitResultContainsElements) {
    auto result = StringUtils::split("apple,banana,cherry", ',');
    
    using ::testing::Contains;
    using ::testing::ElementsAre;
    using ::testing::SizeIs;
    
    EXPECT_THAT(result, SizeIs(3));
    EXPECT_THAT(result, Contains("banana"));
    EXPECT_THAT(result, ElementsAre("apple", "banana", "cherry"));
}

TEST(StringUtilsMatchersTest, TrimResultMatches) {
    using ::testing::StartsWith;
    using ::testing::EndsWith;
    using ::testing::HasSubstr;
    
    std::string result = StringUtils::trim("  hello world  ");
    
    EXPECT_THAT(result, StartsWith("hello"));
    EXPECT_THAT(result, EndsWith("world"));
    EXPECT_THAT(result, HasSubstr("lo wo"));
}

// ==============================================================================
// Main (using gtest_main, so this is optional)
// ==============================================================================

// If not using gtest_main, uncomment:
// int main(int argc, char** argv) {
//     ::testing::InitGoogleTest(&argc, argv);
//     return RUN_ALL_TESTS();
// }
