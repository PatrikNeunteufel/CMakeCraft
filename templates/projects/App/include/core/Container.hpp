#pragma once
// ==============================================================================
// Container.hpp - Generic Container Template
// CMake Architecture V2 - App-Container Template
// ==============================================================================
// 
// This demonstrates the use of .tpp files for template implementations.
// The implementation is in Container.tpp which is included at the end.
//
// ==============================================================================

#include <vector>
#include <algorithm>

namespace app::core {

/**
 * @brief Generic container with common operations
 * 
 * @tparam T Element type
 * 
 * Example usage:
 * @code
 * Container<int> numbers;
 * numbers.add(42);
 * numbers.add(17);
 * auto found = numbers.find(42);
 * @endcode
 */
template<typename T>
class Container {
public:
    /// Add an element
    void add(const T& item);
    
    /// Remove an element
    bool remove(const T& item);
    
    /// Find an element (returns nullptr if not found)
    T* find(const T& item);
    
    /// Get element count
    size_t size() const { return m_items.size(); }
    
    /// Check if empty
    bool empty() const { return m_items.empty(); }
    
    /// Clear all elements
    void clear() { m_items.clear(); }

private:
    std::vector<T> m_items;
};

} // namespace app::core

// Include template implementation
#include "Container.tpp"
