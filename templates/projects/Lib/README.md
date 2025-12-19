# Library Template

Standalone Library Template for CMake Architecture V2.

## Structure

```
Lib/
├── include/           # Public headers
│   ├── Source.cmake
│   ├── MyLib.hpp
│   └── core/
│       ├── Source.cmake
│       └── Types.hpp
├── src/               # Implementation
│   ├── Source.cmake
│   ├── MyLib.cpp
│   └── core/
│       ├── Source.cmake
│       └── Impl.cpp
├── tests/unit/        # Unit tests
│   ├── Source.cmake
│   ├── test_main.cpp
│   └── test_MyLib.cpp
└── pch/
    └── pch.h
```

## Version
- Template Version: 0.6
