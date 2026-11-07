# externals/calcext/Include.cmake - demo local header external (phase 11)
#
# Same pattern as a real header-only external with its own Include.cmake:
# one INTERFACE target with a SYSTEM include folder and a define, linked
# PRIVATE to the target. Provided by the Orchestrator: EXTERNAL_ROOT,
# EXECUTABLE_NAME.

if(NOT DEFINED EXTERNAL_ROOT)
    set(EXTERNAL_ROOT "${CMAKE_SOURCE_DIR}/externals/calcext")
endif()

if(NOT TARGET calcext)
    add_library(calcext INTERFACE)
    target_include_directories(calcext SYSTEM INTERFACE "${EXTERNAL_ROOT}")
    target_compile_definitions(calcext INTERFACE CALCEXT_NO_THREADS)
endif()

target_link_libraries(${EXECUTABLE_NAME} PRIVATE calcext)
