# ==============================================================================
# Source.cmake for tests/performance/
# CMake Architecture V2 - App-Container Template
# ==============================================================================
#
# Performance Tests:
#   - Measure execution time and resource usage
#   - Compare against baseline/threshold values
#   - Typically run nightly (optional in regular CI)
#
# ==============================================================================

set(_local_sources
    "${CMAKE_CURRENT_LIST_DIR}/test_main.cpp"
    "${CMAKE_CURRENT_LIST_DIR}/Application_Performance_Tests.cpp"
)

# Aggregate to test sources
list(APPEND ${TEST_TARGET_NAME}_SOURCES ${_local_sources})

unset(_local_sources)
