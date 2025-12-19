# App Template

App-Container Template for CMake Architecture V2.

## Structure

```
App/
├── include/                 # Public headers (exposed via Core library)
│   ├── Source.cmake
│   ├── Application.hpp      # Main public API
│   └── core/                # Subfolder with headers
│       ├── Source.cmake
│       ├── Engine.hpp
│       ├── Container.hpp
│       ├── Container.tpp    # Template implementation
│       └── Math.inl         # Inline implementation
├── src/                     # Implementation (Core library)
│   ├── Source.cmake
│   ├── Application.cpp
│   ├── Application.impl     # PIMPL implementation
│   ├── core/               # Subfolder
│   │   ├── Source.cmake
│   │   └── Engine.cpp
│   └── utils/              # Another subfolder
│       ├── Source.cmake
│       ├── StringUtils.hpp
│       └── StringUtils.cpp
├── main/                   # Entry point (Runner executable)
│   ├── Source.cmake
│   └── main.cpp
├── pch/                    # Precompiled headers
│   └── pch.h
└── tests/                  # All test types
    ├── unit/               # timeout: 30s, label: unit
    ├── integration/        # timeout: 120s, label: integration
    ├── performance/        # timeout: 300s, label: performance
    ├── system/             # timeout: 600s, label: system, e2e
    ├── smoke/              # timeout: 60s, label: smoke
    └── benchmark/          # timeout: 600s, label: benchmark
```

## Source.cmake Format (v0.6)

All Source.cmake files use `${TARGET_NAME}_*` variables with `list(APPEND ...)`:

```cmake
set(_local_sources
    "${CMAKE_CURRENT_LIST_DIR}/MyFile.cpp"
)

list(APPEND ${TARGET_NAME}_SOURCES ${_local_sources})
```

## Supported File Types

| Extension | Variable      | Description                  |
|-----------|---------------|------------------------------|
| .cpp, .c  | `_SOURCES`    | Compilable source files      |
| .hpp, .h  | `_HEADERS`    | Header files                 |
| .tpp, .ipp| `_TEMPLATES`  | Template implementations     |
| .inl      | `_INLINES`    | Inline implementations       |
| .impl     | `_IMPL`       | PIMPL/detail implementations |

## Test Types and Defaults

| Type        | Timeout | Label(s)         |
|-------------|---------|------------------|
| unit        | 30s     | unit             |
| integration | 120s    | integration      |
| performance | 300s    | performance      |
| system      | 600s    | system, e2e      |
| smoke       | 60s     | smoke            |
| benchmark   | 600s    | benchmark        |

## Usage

1. Copy this template to `projects/apps/{YourAppName}/`
2. Rename files and update namespaces
3. Add your implementation
4. Configure in `Solution.json`

## Version

- Template Version: 0.6
- CMake Architecture: V2
- Date: 2025-12-18
