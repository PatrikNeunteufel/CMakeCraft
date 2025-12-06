# cmake/core/OutputDirs.cmake
# ============================
# Standardized output directories for all targets
#
# Version: 0.1.1
# Date:    2025-12-05
# Status:  Development
# Author:  CMake Architecture V2 Team
#
# Dependencies:
#   - None (standalone module)
#
# Provides:
#   - setup_output_dirs(TARGET_NAME)
#
# Sets unified output directories:
#   - bin/  : Executables, DLLs
#   - lib/  : Static libraries, import libraries
#   - With Debug/Release/Testing subdirectories
#
# Used by:
#   - ExecutableCreate.cmake
#   - LibraryCreate.cmake

include_guard(GLOBAL)

# ============================================================================
# setup_output_dirs - Configure output directories for a target
# ============================================================================
#[[
    setup_output_dirs(TARGET_NAME)
    
    Configures standardized output directories for a target.
    Ensures uniform structure in the build directory.
    
    Parameters:
        TARGET_NAME - Mandatory: CMake target (must already exist)
    
    Properties set:
        RUNTIME_OUTPUT_DIRECTORY  - bin/     (Executables, DLLs)
        LIBRARY_OUTPUT_DIRECTORY  - lib/     (Shared libraries .so)
        ARCHIVE_OUTPUT_DIRECTORY  - lib/     (Static libraries .a, .lib)
    
    Each with config variants:
        *_DEBUG, *_RELEASE, *_TESTING
    
    Example:
        add_executable(MyApp main.cpp)
        setup_output_dirs(MyApp)
        # -> MyApp goes to build/bin/ (or build/bin/Debug/ etc.)
]]
function(setup_output_dirs TARGET_NAME)
    # Binaries (Executables, DLLs)
    set_target_properties(${TARGET_NAME} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
        RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/bin/Debug"
        RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/bin/Release"
        RUNTIME_OUTPUT_DIRECTORY_TESTING "${CMAKE_BINARY_DIR}/bin/Testing"
    )
    
    # Shared libraries (.so on Linux)
    set_target_properties(${TARGET_NAME} PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
        LIBRARY_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/lib/Debug"
        LIBRARY_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/lib/Release"
        LIBRARY_OUTPUT_DIRECTORY_TESTING "${CMAKE_BINARY_DIR}/lib/Testing"
    )
    
    # Archives (Static libraries .a, .lib)
    set_target_properties(${TARGET_NAME} PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
        ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/lib/Debug"
        ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/lib/Release"
        ARCHIVE_OUTPUT_DIRECTORY_TESTING "${CMAKE_BINARY_DIR}/lib/Testing"
    )
endfunction()
