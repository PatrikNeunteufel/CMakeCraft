#pragma once
// ==============================================================================
// pch.h - Precompiled Header
// CMake Architecture V2 - App-Container Template
// ==============================================================================
//
// Include frequently used headers here to speed up compilation.
// These headers should be stable and rarely change.
//
// ==============================================================================

// Standard Library
#include <algorithm>
#include <chrono>
#include <functional>
#include <iostream>
#include <memory>
#include <string>
#include <vector>

// Platform-specific
#ifdef _WIN32
    #ifndef WIN32_LEAN_AND_MEAN
        #define WIN32_LEAN_AND_MEAN
    #endif
    #ifndef NOMINMAX
        #define NOMINMAX
    #endif
    // #include <windows.h>  // Uncomment if needed
#endif
