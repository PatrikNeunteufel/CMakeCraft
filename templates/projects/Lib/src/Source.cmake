# Source.cmake for src/ - Library Template
dbg(${DBG_OFTEN} "${CMAKE_CURRENT_LIST_DIR}/Source.cmake\n          =============================================\n" ID INCLUDE_MSG)

set(_local_sources "${CMAKE_CURRENT_LIST_DIR}/MyLib.cpp")
set(_local_headers)
set(_local_templates)
set(_local_inlines)
set(_local_impl)

dbg(${DBG_NORMAL} "[${TARGET_NAME}] Found sources  : ${_local_sources}" ID DEB_FOUND_MSG)

list(APPEND ${TARGET_NAME}_SOURCES   ${_local_sources})
list(APPEND ${TARGET_NAME}_HEADERS   ${_local_headers})
list(APPEND ${TARGET_NAME}_TEMPLATES ${_local_templates})
list(APPEND ${TARGET_NAME}_INLINES   ${_local_inlines})
list(APPEND ${TARGET_NAME}_IMPL      ${_local_impl})

dbg(${DBG_NORMAL} "[${TARGET_NAME}] Aggregated SOURCES  : ${${TARGET_NAME}_SOURCES}" ID DEB_AGG)

unset(_local_sources)
unset(_local_headers)
unset(_local_templates)
unset(_local_inlines)
unset(_local_impl)

dbg(${DBG_ULTRA_RARE} "[${TARGET_NAME}] Including subfolders:" ID INCLUDE_MSG)
include("${CMAKE_CURRENT_LIST_DIR}/core/Source.cmake")
