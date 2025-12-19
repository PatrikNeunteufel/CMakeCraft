# Executable Template

Standalone Executable Template for CMake Architecture V2.

## Structure

```
Exec/
├── src/               # Source files
│   ├── Source.cmake
│   ├── main.cpp
│   └── core/          # Optional subfolder
│       └── Source.cmake
└── pch/
    └── pch.h
```

## Usage

1. Copy to `projects/exec/{ExecName}/` or `projects/demos/exec/{ExecName}/`
2. Update Source.cmake with your files
3. Configure in Solution.json

## Version
- Template Version: 0.6
