# ==============================================================================
# CMakeLists.txt – CMakeCraft repo (consumer no. 0 of its own build system)
# ==============================================================================
#
# The build system itself lives in CMakeCraft.cmake + cmake/ (relocatable).
# This file is exactly what a consuming project's CMakeLists.txt looks like —
# CMakeCraft "dogfoods" its own entry point against the demo Solution.json.
#
# Consumers: see docs/de/userguides/Neues_Projekt_Guide.md
#
# ==============================================================================

cmake_minimum_required(VERSION 3.25)

include("${CMAKE_CURRENT_LIST_DIR}/CMakeCraft.cmake")
