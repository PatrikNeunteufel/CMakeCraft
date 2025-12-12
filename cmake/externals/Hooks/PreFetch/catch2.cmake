# ==============================================================================
# PreFetch/catch2.cmake – Catch2 PreFetch Hook
# ==============================================================================
#
# Hook:         catch2.cmake
# Version:      0.2.0
# Date:         2025-12-12
# Part of:      CMake Architecture V2
#
# Description:
#   PreFetch hook for Catch2 v3.
#   Disables tests, examples, and installation.
#   Defines target mappings for auto-registration.
#
# Targets provided by Catch2:
#   - Catch2         : Catch2 without main()
#   - Catch2WithMain : Catch2 with main() (recommended)
#
# Note:
#   Catch2 v3 is NOT header-only anymore!
#   Use Catch2WithMain for simplest integration.
#
# Usage in Solution.json:
#   "catch2": {
#       "git": "https://github.com/catchorg/Catch2.git",
#       "tag": "v3.5.2"
#   }
#
# ==============================================================================

message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch: Configuring Catch2")

# ==============================================================================
# Target Mapping for Auto-Registration
# ==============================================================================
# Catch2 creates targets with different names than the external name.
# We tell the registry which targets to look for.

set_property(GLOBAL PROPERTY HOOK_KNOWN_TARGETS_${HOOK_EXTERNAL_NAME}
    "Catch2;Catch2WithMain"
)
set_property(GLOBAL PROPERTY HOOK_PRIMARY_TARGET_${HOOK_EXTERNAL_NAME}
    "Catch2WithMain"
)

# ==============================================================================
# Disable Tests and Examples
# ==============================================================================

# Disable Catch2's own tests
set(CATCH_BUILD_TESTING OFF CACHE BOOL "" FORCE)

# Disable examples
set(CATCH_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)

# Disable documentation installation
set(CATCH_INSTALL_DOCS OFF CACHE BOOL "" FORCE)

# Disable extras (helpers for CMake integration)
set(CATCH_INSTALL_EXTRAS OFF CACHE BOOL "" FORCE)

# ==============================================================================
# Build Configuration
# ==============================================================================

# Build as static library
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

message(STATUS "[${HOOK_EXTERNAL_NAME}] PreFetch complete")
message(STATUS "[${HOOK_EXTERNAL_NAME}]   Targets: Catch2, Catch2WithMain")
