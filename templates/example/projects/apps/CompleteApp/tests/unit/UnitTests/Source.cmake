# ==============================================================================
# Source.cmake for tests/unit/UnitTests/
# CMake Architecture V2 - Source Collection (v0.6)
# ==============================================================================
# Location: projects/apps/CompleteApp/tests/unit/UnitTests/Source.cmake
# Target:   ${TARGET_NAME} (CompleteApp.UnitTests)
# ==============================================================================

dbg(${DBG_OFTEN}
    "${CMAKE_CURRENT_LIST_DIR}/Source.cmake
          =============================================\n" ID INCLUDE_MSG)

set(_local_sources
    # Test entry point (*.c, *.cpp, *.cxx, *.cc)
    "${CMAKE_CURRENT_LIST_DIR}/test_main.cpp"
    
    # Test files
    "${CMAKE_CURRENT_LIST_DIR}/test_Application.cpp"
    "${CMAKE_CURRENT_LIST_DIR}/test_Engine.cpp"
    "${CMAKE_CURRENT_LIST_DIR}/test_StringUtils.cpp"
)

set(_local_headers
    # Test utilities / fixtures (*.h, *.hpp)
    "${CMAKE_CURRENT_LIST_DIR}/TestFixtures.hpp"
    "${CMAKE_CURRENT_LIST_DIR}/MockObjects.hpp"
)

set(_local_templates
    # (usually no templates in tests - *.tpp)
)

set(_local_inlines
    # (usually no inlines in tests - *.inl)
)

set(_local_impl
    # (usually no impl in tests - *.impl)
)

dbg(${DBG_NORMAL} "[${TARGET_NAME}] Found sources  : ${_local_sources}" ID DEB_FOUND_MSG)
dbg(${DBG_NORMAL} "[${TARGET_NAME}] Found headers  : ${_local_headers}" ID DEB_FOUND_MSG)
dbg(${DBG_NORMAL} "[${TARGET_NAME}] Found templates: ${_local_templates}" ID DEB_FOUND_MSG)
dbg(${DBG_NORMAL} "[${TARGET_NAME}] Found inlines  : ${_local_inlines}" ID DEB_FOUND_MSG)
dbg(${DBG_NORMAL} "[${TARGET_NAME}] Found impl     : ${_local_impl}" ID DEB_FOUND_MSG)

list(APPEND ${TARGET_NAME}_SOURCES   ${_local_sources})
list(APPEND ${TARGET_NAME}_HEADERS   ${_local_headers})
list(APPEND ${TARGET_NAME}_TEMPLATES ${_local_templates})
list(APPEND ${TARGET_NAME}_INLINES   ${_local_inlines})
list(APPEND ${TARGET_NAME}_IMPL      ${_local_impl})

dbg(${DBG_NORMAL} "[${TARGET_NAME}] Aggregated SOURCES  : ${${TARGET_NAME}_SOURCES}" ID DEB_AGG)
dbg(${DBG_NORMAL} "[${TARGET_NAME}] Aggregated HEADERS  : ${${TARGET_NAME}_HEADERS}" ID DEB_AGG)
dbg(${DBG_NORMAL} "[${TARGET_NAME}] Aggregated TEMPLATES: ${${TARGET_NAME}_TEMPLATES}" ID DEB_AGG)
dbg(${DBG_NORMAL} "[${TARGET_NAME}] Aggregated INLINES  : ${${TARGET_NAME}_INLINES}" ID DEB_AGG)
dbg(${DBG_NORMAL} "[${TARGET_NAME}] Aggregated IMPL     : ${${TARGET_NAME}_IMPL}" ID DEB_AGG)

unset(_local_sources)
unset(_local_headers)
unset(_local_templates)
unset(_local_inlines)
unset(_local_impl)
