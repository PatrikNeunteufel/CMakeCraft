# cmake/core/Configurations.cmake
# ===============================
# Build configurations beyond the CMake defaults (Debug, Release, ...)
#
# Version: 1.0.0
# Date:    2026-10-24
# Status:  Release
# Author:  CMake Architecture Team
#
# Dependencies:
#   - Debug.cmake (dbg)
#
# Provides:
#   - craft_setup_testing_configuration()
#
# Testing:
#   Optimized, with asserts and debug info - RelWithDebInfo without NDEBUG.
#   CMake gives a custom configuration no default flags, so without this
#   module Testing compiled unoptimized (cl /Od, -O0). The MSVC runtime comes
#   from CMAKE_MSVC_RUNTIME_LIBRARY like for every configuration (default: /MD
#   outside Debug).
#
# Used by:
#   - CMakeCraft.cmake (once, after project())

include_guard(GLOBAL)

# ============================================================================
# craft_setup_testing_configuration - flags of the Testing configuration
# ============================================================================
#[[
    craft_setup_testing_configuration()

    Sets CMAKE_<LANG>_FLAGS_TESTING and the linker flags of Testing.
    A value that is already set is kept (override per project or -D);
    only empty values are filled.

        MSVC, clang-cl:  /O2 /Ob1 /Zi    Linker: /DEBUG /INCREMENTAL:NO
        GCC, Clang:      -O2 -g          Linker: (none)

    Must run after project() has enabled C and CXX.
]]
function(craft_setup_testing_configuration)
    if(MSVC)
        set(_compile "/O2 /Ob1 /Zi")
        set(_link "/DEBUG /INCREMENTAL:NO")
    else()
        set(_compile "-O2 -g")
        set(_link "")
    endif()

    foreach(_lang C CXX)
        if("${CMAKE_${_lang}_FLAGS_TESTING}" STREQUAL "")
            set(CMAKE_${_lang}_FLAGS_TESTING "${_compile}" CACHE STRING
                "Flags used by the ${_lang} compiler during Testing builds (CMakeCraft)." FORCE)
        endif()
    endforeach()

    foreach(_kind EXE SHARED MODULE)
        if("${CMAKE_${_kind}_LINKER_FLAGS_TESTING}" STREQUAL "" AND NOT "${_link}" STREQUAL "")
            set(CMAKE_${_kind}_LINKER_FLAGS_TESTING "${_link}" CACHE STRING
                "Flags used by the linker during Testing builds (CMakeCraft)." FORCE)
        endif()
    endforeach()

    dbg(${DBG_COMMON} "Testing configuration: ${CMAKE_CXX_FLAGS_TESTING}" ID CMAKE_MAIN)
endfunction()
