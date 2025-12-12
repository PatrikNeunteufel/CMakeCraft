// ==============================================================================
// bench_algorithms.cpp – Performance Benchmarks (Catch2)
// ==============================================================================
//
// Test:        Performance_Benchmarks
// Framework:   Catch2
// Type:        performance
// Version:     1.0.0
// Date:        2025-12-12
//
// Description:
//   Performance benchmarks using Catch2's BENCHMARK feature.
//   Measures execution time of various algorithms.
//
// Note:
//   Benchmarks are slower to run. Use -DBUILD_TESTS=ON.
//   Run with: ctest -L benchmark -V
//
// ==============================================================================

#include <catch2/catch_all.hpp>

#include <vector>
#include <algorithm>
#include <numeric>
#include <random>
#include <string>
#include <cmath>

// ==============================================================================
// Algorithms to Benchmark
// ==============================================================================

namespace Algorithms {

// Sorting algorithms
void bubbleSort(std::vector<int>& arr) {
    for (size_t i = 0; i < arr.size(); ++i) {
        for (size_t j = 0; j < arr.size() - i - 1; ++j) {
            if (arr[j] > arr[j + 1]) {
                std::swap(arr[j], arr[j + 1]);
            }
        }
    }
}

void insertionSort(std::vector<int>& arr) {
    for (size_t i = 1; i < arr.size(); ++i) {
        int key = arr[i];
        int j = static_cast<int>(i) - 1;
        while (j >= 0 && arr[j] > key) {
            arr[j + 1] = arr[j];
            --j;
        }
        arr[j + 1] = key;
    }
}

// Search algorithms
int linearSearch(const std::vector<int>& arr, int target) {
    for (size_t i = 0; i < arr.size(); ++i) {
        if (arr[i] == target) return static_cast<int>(i);
    }
    return -1;
}

int binarySearch(const std::vector<int>& arr, int target) {
    int left = 0;
    int right = static_cast<int>(arr.size()) - 1;
    
    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (arr[mid] == target) return mid;
        if (arr[mid] < target) left = mid + 1;
        else right = mid - 1;
    }
    return -1;
}

// String operations
std::string concatenateLoop(const std::vector<std::string>& parts) {
    std::string result;
    for (const auto& part : parts) {
        result += part;
    }
    return result;
}

std::string concatenateReserve(const std::vector<std::string>& parts) {
    size_t totalLen = 0;
    for (const auto& part : parts) {
        totalLen += part.length();
    }
    
    std::string result;
    result.reserve(totalLen);
    for (const auto& part : parts) {
        result += part;
    }
    return result;
}

// Numeric operations
double sumIterative(const std::vector<double>& arr) {
    double sum = 0.0;
    for (const auto& val : arr) {
        sum += val;
    }
    return sum;
}

double sumAccumulate(const std::vector<double>& arr) {
    return std::accumulate(arr.begin(), arr.end(), 0.0);
}

} // namespace Algorithms

// ==============================================================================
// Helper: Generate Random Data
// ==============================================================================

std::vector<int> generateRandomInts(size_t count, int min = 0, int max = 10000) {
    std::vector<int> result(count);
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> dis(min, max);
    
    for (auto& val : result) {
        val = dis(gen);
    }
    return result;
}

std::vector<double> generateRandomDoubles(size_t count) {
    std::vector<double> result(count);
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<> dis(0.0, 1000.0);
    
    for (auto& val : result) {
        val = dis(gen);
    }
    return result;
}

std::vector<std::string> generateStrings(size_t count, size_t length = 10) {
    std::vector<std::string> result(count);
    for (auto& s : result) {
        s = std::string(length, 'x');
    }
    return result;
}

// ==============================================================================
// Sorting Benchmarks
// ==============================================================================

TEST_CASE("Sorting Algorithm Benchmarks", "[benchmark][sorting]") {
    const size_t SMALL_SIZE = 100;
    const size_t MEDIUM_SIZE = 1000;
    
    SECTION("Small arrays (100 elements)") {
        auto data = generateRandomInts(SMALL_SIZE);
        
        BENCHMARK("std::sort (small)") {
            auto copy = data;
            std::sort(copy.begin(), copy.end());
            return copy;
        };
        
        BENCHMARK("Bubble Sort (small)") {
            auto copy = data;
            Algorithms::bubbleSort(copy);
            return copy;
        };
        
        BENCHMARK("Insertion Sort (small)") {
            auto copy = data;
            Algorithms::insertionSort(copy);
            return copy;
        };
    }
    
    SECTION("Medium arrays (1000 elements)") {
        auto data = generateRandomInts(MEDIUM_SIZE);
        
        BENCHMARK("std::sort (medium)") {
            auto copy = data;
            std::sort(copy.begin(), copy.end());
            return copy;
        };
        
        // Note: O(n²) algorithms are slow for 1000 elements
        // We skip them here for reasonable test times
    }
}

// ==============================================================================
// Search Benchmarks
// ==============================================================================

TEST_CASE("Search Algorithm Benchmarks", "[benchmark][search]") {
    const size_t SIZE = 10000;
    auto data = generateRandomInts(SIZE);
    std::sort(data.begin(), data.end());  // Binary search needs sorted array
    
    int target = data[SIZE / 2];  // Search for middle element
    
    BENCHMARK("Linear Search") {
        return Algorithms::linearSearch(data, target);
    };
    
    BENCHMARK("Binary Search") {
        return Algorithms::binarySearch(data, target);
    };
    
    BENCHMARK("std::find") {
        auto it = std::find(data.begin(), data.end(), target);
        return (it != data.end()) ? std::distance(data.begin(), it) : -1;
    };
    
    BENCHMARK("std::binary_search") {
        return std::binary_search(data.begin(), data.end(), target);
    };
    
    BENCHMARK("std::lower_bound") {
        auto it = std::lower_bound(data.begin(), data.end(), target);
        return (it != data.end() && *it == target) ? std::distance(data.begin(), it) : -1;
    };
}

// ==============================================================================
// String Concatenation Benchmarks
// ==============================================================================

TEST_CASE("String Concatenation Benchmarks", "[benchmark][string]") {
    const size_t COUNT = 1000;
    auto strings = generateStrings(COUNT, 20);
    
    BENCHMARK("Loop concatenation") {
        return Algorithms::concatenateLoop(strings);
    };
    
    BENCHMARK("Reserve + concatenation") {
        return Algorithms::concatenateReserve(strings);
    };
}

// ==============================================================================
// Numeric Operation Benchmarks
// ==============================================================================

TEST_CASE("Numeric Sum Benchmarks", "[benchmark][numeric]") {
    const size_t SIZE = 100000;
    auto data = generateRandomDoubles(SIZE);
    
    BENCHMARK("Iterative sum") {
        return Algorithms::sumIterative(data);
    };
    
    BENCHMARK("std::accumulate") {
        return Algorithms::sumAccumulate(data);
    };
}

// ==============================================================================
// Container Benchmarks
// ==============================================================================

TEST_CASE("Vector vs Reserve Benchmarks", "[benchmark][container]") {
    const size_t SIZE = 10000;
    
    BENCHMARK("vector push_back (no reserve)") {
        std::vector<int> v;
        for (size_t i = 0; i < SIZE; ++i) {
            v.push_back(static_cast<int>(i));
        }
        return v;
    };
    
    BENCHMARK("vector push_back (with reserve)") {
        std::vector<int> v;
        v.reserve(SIZE);
        for (size_t i = 0; i < SIZE; ++i) {
            v.push_back(static_cast<int>(i));
        }
        return v;
    };
    
    BENCHMARK("vector emplace_back (with reserve)") {
        std::vector<int> v;
        v.reserve(SIZE);
        for (size_t i = 0; i < SIZE; ++i) {
            v.emplace_back(static_cast<int>(i));
        }
        return v;
    };
}
