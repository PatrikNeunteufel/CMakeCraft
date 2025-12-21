# ==============================================================================
# Source.cmake for tests/unit/
# CMake Architecture V2 - App-Container Template
# ==============================================================================
#
# Unit Tests:
#   - Fast, isolated tests
#   - No external dependencies
#   - Run on every build
#
# ==============================================================================

set(_local_sources
    "${CMAKE_CURRENT_LIST_DIR}/test_main.cpp"
    "${CMAKE_CURRENT_LIST_DIR}/Application_Tests.cpp"
)

# Aggregate to test sources
list(APPEND ${TEST_TARGET_NAME}_SOURCES ${_local_sources})

unset(_local_sources)
