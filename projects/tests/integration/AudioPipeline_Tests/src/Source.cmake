# Files direkt in projects/tests/integration/AudioPipeline_Tests/src/
dbg(DBG_OFTEN 
"projects/tests/integration/AudioPipeline_Tests/src/Source.cmake
          =============================================\n" ID INCLUDE_MSG)

# set local lists for this directory 
set(_local_sources
    # (sources - *.c; *.cpp)
    "${CMAKE_CURRENT_LIST_DIR}/main.cpp"
)
set(_local_headers
    # (no headers - *.h; *.hpp)
)
set(_local_templates
    # (no templates - *.t;*.tpp)
)
set(_local_inlines
    # (no inlines - *.inl)
)
set(_local_impl
    # (no impl - *.impl)
    # (impl files are used for special implementations, e.g. pimpl pattern)
)

dbg(DBG_NORMAL "Found sources  : ${_local_sources}" ID DEB_FOUND_MSG)
dbg(DBG_NORMAL "Found headers  : ${_local_headers}" ID DEB_FOUND_MSG)
dbg(DBG_NORMAL "Found templates: ${_local_templates}" ID DEB_FOUND_MSG)
dbg(DBG_NORMAL "Found inlines  : ${_local_inlines}" ID DEB_FOUND_MSG)
dbg(DBG_NORMAL "Found impl     : ${_local_impl}" ID DEB_FOUND_MSG)

# Nach oben aggregieren
list(APPEND ${EXECUTABLE_NAME}_PROJECT_SOURCES ${_local_sources})
list(APPEND ${EXECUTABLE_NAME}_PROJECT_HEADERS ${_local_headers})
list(APPEND ${EXECUTABLE_NAME}_PROJECT_TEMPLATES ${_local_templates})
list(APPEND ${EXECUTABLE_NAME}_PROJECT_INLINES ${_local_inlines})
list(APPEND ${EXECUTABLE_NAME}_PROJECT_IMPL ${_local_impl})

dbg(DBG_NORMAL "Aggregated sources  : ${${EXECUTABLE_NAME}_PROJECT_SOURCES}" ID DEB_AGG)
dbg(DBG_NORMAL "Aggregated headers  : ${${EXECUTABLE_NAME}_PROJECT_HEADERS}" ID DEB_AGG)
dbg(DBG_NORMAL "Aggregated templates: ${${EXECUTABLE_NAME}_PROJECT_TEMPLATES}" ID DEB_AGG)
dbg(DBG_NORMAL "Aggregated inlines  : ${${EXECUTABLE_NAME}_PROJECT_INLINES}" ID DEB_AGG)
dbg(DBG_NORMAL "Aggregated impl  : ${${EXECUTABLE_NAME}_PROJECT_IMPL}" ID DEB_AGG)

# optional aufräumen (rein kosmetisch)
unset(_local_sources)
unset(_local_headers)
unset(_local_templates)
unset(_local_inlines)

dbg(DBG_ULTRA_RARE "include subfolders:" ID INCLUDE_MSG)
# Subfolder rekursiv einbinden
# include("${CMAKE_CURRENT_LIST_DIR}/common/Source.cmake")
# include("${CMAKE_CURRENT_LIST_DIR}/core/Source.cmake")
# include("${CMAKE_CURRENT_LIST_DIR}/app/Source.cmake")
# include("${CMAKE_CURRENT_LIST_DIR}/audio/Source.cmake")
# include("${CMAKE_CURRENT_LIST_DIR}/core/Source.cmake")
# include("${CMAKE_CURRENT_LIST_DIR}/logger/Source.cmake")
# include("${CMAKE_CURRENT_LIST_DIR}/settings/Source.cmake")
# include("${CMAKE_CURRENT_LIST_DIR}/ui/Source.cmake")
# include("${CMAKE_CURRENT_LIST_DIR}/visuals/Source.cmake")