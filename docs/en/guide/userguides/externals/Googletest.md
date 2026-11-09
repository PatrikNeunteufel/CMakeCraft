# Google Test — UserGuide

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Guide  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Googletest.md](../../../../de/guide/userguides/externals/Googletest.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Solution.json Configuration](#2-solutionjson-configuration)
3. [C++ Usage](#3-c-usage)
4. [Assertions](#4-assertions)
5. [GMock (Mocking)](#5-gmock-mocking)
6. [Advanced Techniques](#6-advanced-techniques)
7. [Troubleshooting](#7-troubleshooting)
8. [Further Information](#8-further-information)
9. [Changelog](#changelog)

---

## 1. Overview

**Google Test** is Google's C++ testing framework, including GMock for mocking.

| Aspect | Value |
|--------|-------|
| **Type** | Git External |
| **Repository** | https://github.com/google/googletest |
| **Recommended Tag** | v1.14.0 |
| **License** | BSD-3-Clause |
| **Website** | [google.github.io/googletest](https://google.github.io/googletest/) |

### Why Google Test?

| Advantage | Description |
|-----------|-------------|
| 🎭 **GMock** | Integrated mocking framework |
| 🏢 **Industry standard** | Widely used |
| 📊 **XML Reports** | CI/CD integration |
| 🔧 **Feature-rich** | Fixtures, parameterization |

### Comparison with doctest

| Feature | googletest | doctest |
|---------|------------|---------|
| **Mocking** | ✅ GMock | ❌ |
| **Compile time** | 🐢 Slow | ⚡ Fast |
| **Header-Only** | ❌ | ✅ |
| **Footprint** | Large | Small |

---

## 2. Solution.json Configuration

### 2.1 Minimal

```json
{
    "externals": {
        "googletest": {
            "git": "https://github.com/google/googletest.git",
            "tag": "v1.14.0"
        }
    },
    "tests": [
        {
            "name": "UnitTests",
            "framework": "googletest",
            "externals": ["googletest"]
        }
    ]
}
```

### 2.2 With Library Tests

```json
{
    "externals": {
        "googletest": {
            "git": "https://github.com/google/googletest.git",
            "tag": "v1.14.0"
        }
    },
    "libraries": [
        {
            "name": "CoreLib",
            "type": "static"
        }
    ],
    "tests": [
        {
            "name": "CoreTests",
            "framework": "googletest",
            "externals": ["googletest"],
            "libraries": ["CoreLib"]
        }
    ]
}
```

### 2.3 PreFetch Hook

```cmake
# cmake/externals/hooks/prefetch/googletest.cmake
set(BUILD_GMOCK ON CACHE BOOL "" FORCE)
set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)

# Windows: Prevent CRT mismatch
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
```

### 2.4 Targets

| Target | Description |
|--------|-------------|
| `gtest` | Google Test core |
| `gtest_main` | With main() |
| `gmock` | Google Mock core |
| `gmock_main` | Mock with main() |

---

## 3. C++ Usage

### 3.1 Simple Test

```cpp
#include <gtest/gtest.h>

TEST(MathTest, Addition) {
    EXPECT_EQ(1 + 1, 2);
    EXPECT_EQ(2 + 3, 5);
}

TEST(MathTest, Subtraction) {
    EXPECT_EQ(5 - 3, 2);
    EXPECT_EQ(10 - 7, 3);
}

int main(int argc, char** argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
```

### 3.2 With gtest_main

```cpp
// No main() needed - provided by gtest_main
#include <gtest/gtest.h>

TEST(MyTest, Works) {
    EXPECT_TRUE(true);
}
```

### 3.3 Test Fixtures

```cpp
#include <gtest/gtest.h>
#include <vector>

class VectorTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Called before each TEST_F
        vec.push_back(1);
        vec.push_back(2);
        vec.push_back(3);
    }
    
    void TearDown() override {
        // Called after each TEST_F
        vec.clear();
    }
    
    std::vector<int> vec;
};

TEST_F(VectorTest, InitialSize) {
    EXPECT_EQ(vec.size(), 3);
}

TEST_F(VectorTest, PushBack) {
    vec.push_back(4);
    EXPECT_EQ(vec.size(), 4);
    EXPECT_EQ(vec.back(), 4);
}

TEST_F(VectorTest, PopBack) {
    vec.pop_back();
    EXPECT_EQ(vec.size(), 2);
}
```

### 3.4 Test Suites

```cpp
// All tests with the same prefix belong to the same suite
TEST(StringTest, Empty) {
    std::string s;
    EXPECT_TRUE(s.empty());
}

TEST(StringTest, Length) {
    std::string s = "hello";
    EXPECT_EQ(s.length(), 5);
}
```

---

## 4. Assertions

### 4.1 EXPECT vs ASSERT

| Type | On Failure | Use |
|------|------------|-----|
| `EXPECT_*` | Test continues | Default |
| `ASSERT_*` | Test aborts | When continuing makes no sense |

### 4.2 Boolean Assertions

```cpp
EXPECT_TRUE(condition);
EXPECT_FALSE(condition);

// With message
EXPECT_TRUE(result) << "Expected result to be true";
```

### 4.3 Comparisons

```cpp
EXPECT_EQ(a, b);   // a == b
EXPECT_NE(a, b);   // a != b
EXPECT_LT(a, b);   // a < b
EXPECT_LE(a, b);   // a <= b
EXPECT_GT(a, b);   // a > b
EXPECT_GE(a, b);   // a >= b
```

### 4.4 String Assertions

```cpp
EXPECT_STREQ(str1, str2);     // C strings equal
EXPECT_STRNE(str1, str2);     // C strings not equal
EXPECT_STRCASEEQ(str1, str2); // Case-insensitive equal
EXPECT_STRCASENE(str1, str2); // Case-insensitive not equal
```

### 4.5 Floating-Point

```cpp
EXPECT_FLOAT_EQ(a, b);     // float with ULP tolerance
EXPECT_DOUBLE_EQ(a, b);    // double with ULP tolerance
EXPECT_NEAR(a, b, 0.001);  // Absolute tolerance
```

### 4.6 Exception Assertions

```cpp
EXPECT_THROW(statement, exception_type);
EXPECT_ANY_THROW(statement);
EXPECT_NO_THROW(statement);

// Example
EXPECT_THROW(vec.at(100), std::out_of_range);
EXPECT_NO_THROW(vec.at(0));
```

### 4.7 Death Tests

```cpp
// Tests whether the program terminates
EXPECT_DEATH(abort(), "");
EXPECT_EXIT(exit(1), testing::ExitedWithCode(1), "");
```

---

## 5. GMock (Mocking)

### 5.1 Creating a Mock Class

```cpp
#include <gmock/gmock.h>

// Interface
class Database {
public:
    virtual ~Database() = default;
    virtual bool connect(const std::string& host) = 0;
    virtual std::string query(const std::string& sql) = 0;
    virtual void disconnect() = 0;
};

// Mock
class MockDatabase : public Database {
public:
    MOCK_METHOD(bool, connect, (const std::string& host), (override));
    MOCK_METHOD(std::string, query, (const std::string& sql), (override));
    MOCK_METHOD(void, disconnect, (), (override));
};
```

### 5.2 Expectations

```cpp
TEST(DatabaseTest, ConnectCalled) {
    MockDatabase db;
    
    // Expectation: connect is called with "localhost"
    EXPECT_CALL(db, connect("localhost"))
        .Times(1)
        .WillOnce(testing::Return(true));
    
    // Code under test
    bool result = db.connect("localhost");
    
    EXPECT_TRUE(result);
}
```

### 5.3 Actions

```cpp
using ::testing::Return;
using ::testing::ReturnRef;
using ::testing::Throw;
using ::testing::DoAll;
using ::testing::SetArgReferee;

EXPECT_CALL(mock, method())
    .WillOnce(Return(42))              // Return a value
    .WillOnce(Throw(std::runtime_error("error")))  // Exception
    .WillRepeatedly(Return(0));        // For all further calls
```

### 5.4 Matchers

```cpp
using ::testing::_;
using ::testing::Eq;
using ::testing::Ne;
using ::testing::Lt;
using ::testing::HasSubstr;
using ::testing::StartsWith;

EXPECT_CALL(mock, method(_))           // Any parameter
    .With(Eq(5))                       // Equal to 5
    .With(HasSubstr("test"))           // Contains "test"
    .With(StartsWith("hello"));        // Starts with "hello"
```

### 5.5 Complete Example

```cpp
#include <gtest/gtest.h>
#include <gmock/gmock.h>

class UserService {
public:
    UserService(Database* db) : db_(db) {}
    
    bool login(const std::string& user, const std::string& pass) {
        if (!db_->connect("auth-server")) {
            return false;
        }
        
        std::string result = db_->query(
            "SELECT * FROM users WHERE name='" + user + "'"
        );
        
        db_->disconnect();
        return result.find(pass) != std::string::npos;
    }
    
private:
    Database* db_;
};

TEST(UserServiceTest, LoginSuccess) {
    MockDatabase mockDb;
    UserService service(&mockDb);
    
    EXPECT_CALL(mockDb, connect("auth-server"))
        .WillOnce(testing::Return(true));
    
    EXPECT_CALL(mockDb, query(testing::HasSubstr("john")))
        .WillOnce(testing::Return("john:secret123"));
    
    EXPECT_CALL(mockDb, disconnect())
        .Times(1);
    
    EXPECT_TRUE(service.login("john", "secret123"));
}

TEST(UserServiceTest, LoginConnectionFailed) {
    MockDatabase mockDb;
    UserService service(&mockDb);
    
    EXPECT_CALL(mockDb, connect(testing::_))
        .WillOnce(testing::Return(false));
    
    EXPECT_FALSE(service.login("john", "secret"));
}
```

---

## 6. Advanced Techniques

### 6.1 Parameterized Tests

```cpp
class FibonacciTest : public ::testing::TestWithParam<std::pair<int, int>> {};

TEST_P(FibonacciTest, Compute) {
    auto [input, expected] = GetParam();
    EXPECT_EQ(fibonacci(input), expected);
}

INSTANTIATE_TEST_SUITE_P(
    FibonacciValues,
    FibonacciTest,
    ::testing::Values(
        std::make_pair(0, 0),
        std::make_pair(1, 1),
        std::make_pair(2, 1),
        std::make_pair(3, 2),
        std::make_pair(10, 55)
    )
);
```

### 6.2 Type-Parameterized Tests

```cpp
template <typename T>
class TypedTest : public ::testing::Test {};

using MyTypes = ::testing::Types<int, float, double>;
TYPED_TEST_SUITE(TypedTest, MyTypes);

TYPED_TEST(TypedTest, DefaultIsZero) {
    TypeParam value{};
    EXPECT_EQ(value, TypeParam{});
}
```

### 6.3 Test Filters

```bash
# Run only certain tests
./tests --gtest_filter=MathTest.*
./tests --gtest_filter=*Addition*
./tests --gtest_filter=-*Slow*  # Exclude

# Repeat
./tests --gtest_repeat=10

# Shuffle
./tests --gtest_shuffle
```

### 6.4 XML Output

```bash
./tests --gtest_output=xml:results.xml
```

### 6.5 Custom Main

```cpp
int main(int argc, char** argv) {
    testing::InitGoogleTest(&argc, argv);
    
    // Your own initialization
    MyApp::init();
    
    int result = RUN_ALL_TESTS();
    
    // Your own cleanup
    MyApp::shutdown();
    
    return result;
}
```

---

## 7. Troubleshooting

### 7.1 Link Errors on Windows

**Problem:** `LNK2038: mismatch detected for 'RuntimeLibrary'`

**Solution:** Set the PreFetch hook:
```cmake
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
```

### 7.2 "undefined reference to testing::..."

**Problem:** Google Test not linked

**Solution:** Link the target against `gtest` or `gtest_main`.

### 7.3 Tests Are Not Found

**Problem:** No tests executed

**Solution:** 
- Call `RUN_ALL_TESTS()`
- Link against `gtest_main` (instead of your own main)

### 7.4 GMock Warnings

**Problem:** "Uninteresting mock function call"

**Solution:** Use `NiceMock`:
```cpp
testing::NiceMock<MockDatabase> db;
```

---

## 8. Further Information

### Official Resources

| Resource | Link |
|----------|------|
| **GitHub** | [github.com/google/googletest](https://github.com/google/googletest) |
| **Documentation** | [google.github.io/googletest](https://google.github.io/googletest/) |
| **Primer** | [google.github.io/googletest/primer.html](https://google.github.io/googletest/primer.html) |
| **GMock** | [google.github.io/googletest/gmock_cook_book.html](https://google.github.io/googletest/gmock_cook_book.html) |

### See Also

- [Externals.md](../Externals.md) — Externals combinations
- [Git_Externals_Testing.md](../../references/externals/Git_Externals_Testing.md) — Reference
- [doctest.md](Doctest.md) — Lightweight alternative
- [catch2.md](Catch2.md) — BDD-style alternative

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.2 | 2025-12-15 | Initial: detailed UserGuide for Google Test |
