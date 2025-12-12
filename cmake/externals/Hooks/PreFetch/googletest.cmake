# ==============================================================================
# PreFetch/googletest.cmake – GoogleTest PreFetch Hook
# ==============================================================================
#
# Hook:         googletest.cmake
# Version:      0.2.1
# Date:         2025-12-12
# Part of:      CMake Architecture V2
#
# Description:
#   PreFetch hook for Google Test / Google Mock.
#   Configures build options and fixes Windows CRT issues.
#   Defines target mappings for auto-registration.
#
# Targets provided by GoogleTest:
#   - gtest       : Google Test without main()
#   - gtest_main  : Google Test with main()
#   - gmock       : Google Mock without main()
#   - gmock_main  : Google Mock with main()
#
# Include paths (automatically added by targets):
#   - googletest/include  (for <gtest/gtest.h>)
#   - googlemock/include  (for <gmock/gmock.h>)
#
# Usage in Solution.json:
#   "googletest": {
#       "git": "https://github.com/google/googletest.git",
#       "tag": "v1.14.0"
#   }
#
# ==============================================================================

message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch: Configuring GoogleTest")

# ==============================================================================
# Target Mapping for Auto-Registration
# ==============================================================================
# GoogleTest creates targets with different names than the external name.
# We tell the registry which targets to look for.
#
# Note: When using gtest_main, GMock includes are automatically available
# because gtest_main links gmock internally.

set_property(GLOBAL PROPERTY HOOK_KNOWN_TARGETS_${HOOK_EXTERNAL_NAME}
    "gtest;gtest_main;gmock;gmock_main"
)
# Use gmock_main as primary - includes both gtest AND gmock
set_property(GLOBAL PROPERTY HOOK_PRIMARY_TARGET_${HOOK_EXTERNAL_NAME}
    "gmock_main"
)

# ==============================================================================
# Build Configuration
# ==============================================================================

# Enable Google Mock (includes Google Test)
set(BUILD_GMOCK ON CACHE BOOL "" FORCE)

# Disable installation (not needed with FetchContent)
set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)

# ==============================================================================
# Windows CRT Fix (WICHTIG!)
# ==============================================================================
#
# Ohne diese Option gibt es auf Windows Linker-Fehler wie:
#   "LNK2038: mismatch detected for 'RuntimeLibrary'"
#
# Grund: GoogleTest kompiliert standardmäßig mit statischer CRT (/MT),
# aber die meisten Projekte verwenden dynamische CRT (/MD).
#

if(WIN32)
    set(gtest_force_shared_crt ON CACHE BOOL 
        "Use shared (DLL) run-time lib even when Google Test is built as static lib." 
        FORCE
    )
    message(STATUS "[${HOOK_EXTERNAL_NAME}]   Windows: gtest_force_shared_crt=ON")
endif()

# ==============================================================================
# Optional: Hide internal symbols
# ==============================================================================

set(gtest_hide_internal_symbols ON CACHE BOOL "" FORCE)

message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch complete")
message(STATUS "[${HOOK_EXTERNAL_NAME}]   Targets: gtest, gtest_main, gmock, gmock_main")
