# ==============================================================================
# CMakeLists.txt – <MeinProjekt> (Konsument von CMakeCraft)
# ==============================================================================
#
# Das Build-System (CMakeCraft) liegt NICHT im Repo: Es wird beim Configure in
# der gepinnten Version (cmakecraft.pin) nach .externals/ geholt. Was gebaut
# wird, definiert ausschliesslich Solution.json.
#
#   Version wechseln:            cmakecraft.pin editieren
#   Build-System entwickeln:     -DCMAKECRAFT_LOCAL_DIR=../CMakeCraft
#   Doku:                        docs/de/guide/userguides/Neues_Projekt_Guide.md
#
# Mehr als diese Zeilen braucht die Top-Level-CMakeLists.txt eines Konsumenten
# nicht. project(), Targets, Tests und Externals entstehen aus Solution.json.
#
# ==============================================================================

cmake_minimum_required(VERSION 3.26)

include("${CMAKE_CURRENT_LIST_DIR}/CMakeCraftBootstrap.cmake")
