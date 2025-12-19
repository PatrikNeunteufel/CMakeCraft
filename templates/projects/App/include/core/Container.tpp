// ==============================================================================
// Container.tpp - Template Implementation
// CMake Architecture V2 - App-Container Template
// ==============================================================================
//
// This file contains the template implementations for Container<T>.
// It is included at the end of Container.hpp.
//
// Naming conventions for template implementations:
//   *.tpp  - Template implementation (most common)
//   *.ipp  - Implementation (alternative)
//   *.txx  - Template extension (less common)
//
// ==============================================================================

#pragma once

namespace app::core {

template<typename T>
void Container<T>::add(const T& item) {
    m_items.push_back(item);
}

template<typename T>
bool Container<T>::remove(const T& item) {
    auto it = std::find(m_items.begin(), m_items.end(), item);
    if (it != m_items.end()) {
        m_items.erase(it);
        return true;
    }
    return false;
}

template<typename T>
T* Container<T>::find(const T& item) {
    auto it = std::find(m_items.begin(), m_items.end(), item);
    if (it != m_items.end()) {
        return &(*it);
    }
    return nullptr;
}

} // namespace app::core
