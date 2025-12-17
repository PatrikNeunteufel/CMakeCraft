/**
 ****************************************************************************************
 * @file   $FILENAME
 * @brief  $BRIEF$END
 *
 * @author Patrik Neunteufel
 * @date   $MONTHNAME_EN $YEAR
  ****************************************************************************************
 */

// =============================================================================
// Precompiled Header
// CMake Architecture V2 - App-Container Template
// =============================================================================
//
// Dieser Header enthält häufig verwendete, stabile Includes.
// Er wird als Precompiled Header kompiliert um Build-Zeiten zu reduzieren.
//
// Hinweis: .h Extension ist Standard für PCH (auch bei C++), 
// da einige Compiler/Tools .hpp nicht korrekt verarbeiten.
//
// =============================================================================

#pragma once

// =============================================================================
// Standard Library
// =============================================================================
#include <algorithm>
#include <array>
#include <chrono>
#include <cstddef>
#include <cstdint>
#include <functional>
#include <iostream>
#include <map>
#include <memory>
#include <optional>
#include <string>
#include <string_view>
#include <unordered_map>
#include <utility>
#include <vector>

// =============================================================================
// Projektspezifisch erweitern (Beispiele auskommentiert):
// =============================================================================

// Qt (bei GUI-Apps)
// #include <QApplication>
// #include <QMainWindow>
// #include <QString>
// #include <QWidget>

// OpenGL (bei Visualizer-Apps)
// #include <glad/glad.h>
// #include <GLFW/glfw3.h>

// Audio (bei Audio-Apps)
// #include <bass.h>
