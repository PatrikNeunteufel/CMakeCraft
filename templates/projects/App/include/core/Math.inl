// ==============================================================================
// Math.inl - Inline Math Functions
// CMake Architecture V2 - App-Container Template
// ==============================================================================
//
// This file contains inline implementations for performance-critical
// math functions. Include this file in headers that need these functions.
//
// Naming convention:
//   *.inl - Inline implementation file
//
// Usage in header:
//   #include "core/Math.inl"
//
// ==============================================================================

#pragma once

#include <cmath>
#include <algorithm>

namespace app::core::math {

// ==============================================================================
// Basic Math Operations
// ==============================================================================

/// Clamp value between min and max
template<typename T>
inline constexpr T clamp(T value, T min, T max) {
    return std::max(min, std::min(value, max));
}

/// Linear interpolation
template<typename T>
inline constexpr T lerp(T a, T b, float t) {
    return static_cast<T>(a + (b - a) * t);
}

/// Check if two floats are approximately equal
inline constexpr bool approxEqual(float a, float b, float epsilon = 1e-6f) {
    return std::abs(a - b) < epsilon;
}

// ==============================================================================
// Angle Conversions
// ==============================================================================

inline constexpr float PI = 3.14159265358979323846f;

/// Convert degrees to radians
inline constexpr float toRadians(float degrees) {
    return degrees * (PI / 180.0f);
}

/// Convert radians to degrees
inline constexpr float toDegrees(float radians) {
    return radians * (180.0f / PI);
}

// ==============================================================================
// Vector Operations (2D)
// ==============================================================================

struct Vec2 {
    float x = 0.0f;
    float y = 0.0f;
    
    inline constexpr Vec2 operator+(const Vec2& other) const {
        return {x + other.x, y + other.y};
    }
    
    inline constexpr Vec2 operator-(const Vec2& other) const {
        return {x - other.x, y - other.y};
    }
    
    inline constexpr Vec2 operator*(float scalar) const {
        return {x * scalar, y * scalar};
    }
    
    inline float length() const {
        return std::sqrt(x * x + y * y);
    }
    
    inline Vec2 normalized() const {
        float len = length();
        if (len > 0.0f) {
            return {x / len, y / len};
        }
        return {0.0f, 0.0f};
    }
};

/// Dot product of two vectors
inline constexpr float dot(const Vec2& a, const Vec2& b) {
    return a.x * b.x + a.y * b.y;
}

} // namespace app::core::math
