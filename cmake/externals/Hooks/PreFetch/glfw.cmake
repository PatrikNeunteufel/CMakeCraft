# ==============================================================================
# PreFetch/glfw.cmake – GLFW PreFetch Hook
# ==============================================================================
#
# Hook:         glfw.cmake
# Version:      0.1.0
# Date:         2025-12-09
# Part of:      CMake Architecture V2
#
# Description:
#   PreFetch hook for GLFW.
#   Disables examples, tests, and documentation.
#
# Based on:
#   - guidelines v0.1
#
# ==============================================================================

message(STATUS "[glfw] PreFetch hook: Setting options")

# ==============================================================================
# GLFW Configuration Options
# ==============================================================================

# Disable building examples
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)

# Disable building tests
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)

# Disable building documentation
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)

# Install is not needed when using FetchContent
set(GLFW_INSTALL OFF CACHE BOOL "" FORCE)

message(STATUS "[glfw] PreFetch hook complete")
