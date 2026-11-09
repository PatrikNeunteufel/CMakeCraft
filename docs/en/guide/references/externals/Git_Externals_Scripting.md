# Git Externals — Scripting

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Git_Externals_Scripting.md](../../../../de/guide/references/externals/Git_Externals_Scripting.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [sol2](#2-sol2)
3. [pybind11](#3-pybind11)
4. [chaiscript](#4-chaiscript)
5. [Quick Reference](#5-quick-reference)
6. [See Also](#6-see-also)
7. [Changelog](#changelog)

---

## 1. Overview

This document describes Git scripting externals for the CMake Architecture build system.

| Library | Description | CMake | Hook |
|---------|-------------|-------|------|
| **sol2** | C++ Lua Bindings | ✅ | — |
| **pybind11** | C++ Python Bindings | ✅ | — |
| **chaiscript** | Embedded Scripting Language | ✅ | — |

---

## 2. sol2

### Quick Info

| Aspect | Value |
|--------|-------|
| **Repository** | https://github.com/ThePhD/sol2 |
| **Recommended Tag** | v3.3.1 |
| **CMake Support** | ✅ |
| **Hook** | — (not needed) |
| **Type** | Header-Only |

### Solution.json

```json
{
    "externals": {
        "lua54": { "path": "externals/lua54" },
        "sol2": {
            "git": "https://github.com/ThePhD/sol2.git",
            "tag": "v3.3.1"
        }
    }
}
```

> **Important:** sol2 requires a Lua implementation (lua54 as a Local External recommended)

### Usage Example

```cpp
#include <sol/sol.hpp>

int main() {
    sol::state lua;
    lua.open_libraries(sol::lib::base, sol::lib::math);
    
    // Variables
    lua["x"] = 10;
    int x = lua["x"];
    
    // Functions
    lua["add"] = [](int a, int b) { return a + b; };
    int result = lua["add"](2, 3);  // 5
    
    // Run script
    lua.script("print('Hello from Lua!')");
    
    return 0;
}
```

### Exporting Classes

```cpp
#include <sol/sol.hpp>

class Player {
public:
    std::string name;
    int health = 100;
    
    void damage(int amount) { health -= amount; }
    bool isAlive() const { return health > 0; }
};

int main() {
    sol::state lua;
    lua.open_libraries(sol::lib::base);
    
    // Register class
    lua.new_usertype<Player>("Player",
        "name", &Player::name,
        "health", &Player::health,
        "damage", &Player::damage,
        "isAlive", &Player::isAlive
    );
    
    // Use in Lua
    lua.script(R"(
        local p = Player.new()
        p.name = "Hero"
        p:damage(30)
        print(p.name .. " has " .. p.health .. " HP")
    )");
    
    return 0;
}
```

### Targets

| Target | Description |
|--------|-------------|
| `sol2::sol2` | Header-only interface |

---

## 3. pybind11

### Quick Info

| Aspect | Value |
|--------|-------|
| **Repository** | https://github.com/pybind/pybind11 |
| **Recommended Tag** | v2.12.0 |
| **CMake Support** | ✅ |
| **Hook** | — (not needed) |
| **Type** | Header-Only |

### Solution.json

```json
{
    "externals": {
        "pybind11": {
            "git": "https://github.com/pybind/pybind11.git",
            "tag": "v2.12.0"
        }
    }
}
```

> **Important:** Python development headers must be installed

### Usage Example (Creating a Python Module)

```cpp
#include <pybind11/pybind11.h>

int add(int a, int b) {
    return a + b;
}

PYBIND11_MODULE(example, m) {
    m.doc() = "Example module";
    m.def("add", &add, "Add two numbers");
}
```

### Exporting Classes

```cpp
#include <pybind11/pybind11.h>

namespace py = pybind11;

class Calculator {
public:
    int add(int a, int b) { return a + b; }
    int multiply(int a, int b) { return a * b; }
};

PYBIND11_MODULE(calculator, m) {
    py::class_<Calculator>(m, "Calculator")
        .def(py::init<>())
        .def("add", &Calculator::add)
        .def("multiply", &Calculator::multiply);
}
```

**Python:**

```python
import calculator
calc = calculator.Calculator()
print(calc.add(2, 3))       # 5
print(calc.multiply(4, 5))  # 20
```

### Targets

| Target | Description |
|--------|-------------|
| `pybind11::module` | For Python modules |
| `pybind11::embed` | For embedded Python |

---

## 4. chaiscript

### Quick Info

| Aspect | Value |
|--------|-------|
| **Repository** | https://github.com/ChaiScript/ChaiScript |
| **Recommended Tag** | v6.1.0 |
| **CMake Support** | ✅ |
| **Hook** | — (not needed) |
| **Type** | Header-Only |

### Solution.json

```json
{
    "externals": {
        "chaiscript": {
            "git": "https://github.com/ChaiScript/ChaiScript.git",
            "tag": "v6.1.0"
        }
    }
}
```

### Usage Example

```cpp
#include <chaiscript/chaiscript.hpp>

int main() {
    chaiscript::ChaiScript chai;
    
    // Variables
    chai.add(chaiscript::var(42), "x");
    
    // Functions
    chai.add(chaiscript::fun([](int a, int b) { return a + b; }), "add");
    
    // Run script
    chai.eval("print(add(2, 3))");
    
    // Retrieve value
    int result = chai.eval<int>("add(10, 20)");
    
    return 0;
}
```

### Exporting Classes

```cpp
#include <chaiscript/chaiscript.hpp>

class Player {
public:
    std::string name;
    int health = 100;
    
    void damage(int amount) { health -= amount; }
};

int main() {
    chaiscript::ChaiScript chai;
    
    // Register class
    chai.add(chaiscript::user_type<Player>(), "Player");
    chai.add(chaiscript::constructor<Player()>(), "Player");
    chai.add(chaiscript::fun(&Player::name), "name");
    chai.add(chaiscript::fun(&Player::health), "health");
    chai.add(chaiscript::fun(&Player::damage), "damage");
    
    // Use in ChaiScript
    chai.eval(R"(
        var p = Player()
        p.name = "Hero"
        p.damage(30)
        print("${p.name} has ${p.health} HP")
    )");
    
    return 0;
}
```

### Targets

| Target | Description |
|--------|-------------|
| `chaiscript` | Main library |

---

## 5. Quick Reference

| Library | Tag | CMake | Hook | Type | Language |
|---------|-----|-------|------|------|----------|
| sol2 | v3.3.1 | ✅ | — | Header-Only | Lua |
| pybind11 | v2.12.0 | ✅ | — | Header-Only | Python |
| chaiscript | v6.1.0 | ✅ | — | Header-Only | ChaiScript |

### Comparison

| Feature | sol2 | pybind11 | chaiscript |
|---------|------|----------|------------|
| **Target language** | Lua | Python | ChaiScript |
| **Runtime** | lua54 (Local) | Python interpreter | Built in |
| **Syntax** | Lua | Python | C++-like |
| **Footprint** | Small | Medium | Medium |
| **Use case** | Game scripting | Python integration | Embedded DSL |

### Comparison with the Local Alternative

| Feature | lua54 (Local) | sol2 (Git) |
|---------|---------------|------------|
| **Type** | Core engine | C++ bindings |
| **API** | C-style | Modern C++ |
| **Combination** | ✅ Use together | ✅ Use together |

---

## 6. See Also

- [Externals.md](../Externals.md) — Main overview of all externals
- [Git_Externals.md](Git_Externals.md) — Git Externals overview
- [Local_Externals_Scripting.md](Local_Externals_Scripting.md) — Local Scripting (lua54)

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.2 | 2025-12-15 | Own category Scripting (split out from Git_Externals_Core) |
