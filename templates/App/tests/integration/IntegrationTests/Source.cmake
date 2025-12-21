# ==============================================================================
# Source.cmake for tests/integration/
# CMake Architecture V2 - App-Container Template
# ==============================================================================
#
# Integration Tests:
#   - Test component interactions
#   - May use external resources (files, network, database)
#   - Longer timeouts allowed
#
# ==============================================================================

set(_local_sources
    "${CMAKE_CURRENT_LIST_DIR}/test_main.cpp"
    "${CMAKE_CURRENT_LIST_DIR}/Application_Integration_Tests.cpp"
)

# Aggregate to test sources
list(APPEND ${TEST_TARGET_NAME}_SOURCES ${_local_sources})

unset(_local_sources)
