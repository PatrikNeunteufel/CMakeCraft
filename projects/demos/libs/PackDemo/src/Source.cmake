# Source.cmake
# CMake Architecture V2 - Source Collection (v0.6)
# Format: Direkte Zuweisung an ${TARGET_NAME}_* Variablen

set(${TARGET_NAME}_SOURCES
    "${CMAKE_CURRENT_LIST_DIR}/pack_demo.cpp"
)

set(${TARGET_NAME}_HEADERS
    "${CMAKE_CURRENT_LIST_DIR}/../include/pack_demo.h"
)
