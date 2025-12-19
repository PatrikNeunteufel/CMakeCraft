#pragma once
// ==============================================================================
// StringUtils.hpp - String Utility Functions
// CMake Architecture V2 - App-Container Template
// ==============================================================================

#include <string>
#include <vector>

namespace app::utils {

/// Trim whitespace from both ends
std::string trim(const std::string& str);

/// Split string by delimiter
std::vector<std::string> split(const std::string& str, char delimiter);

/// Convert to lowercase
std::string toLower(const std::string& str);

/// Convert to uppercase
std::string toUpper(const std::string& str);

} // namespace app::utils
