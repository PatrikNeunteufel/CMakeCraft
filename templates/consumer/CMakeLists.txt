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
# nicht. Targets, Tests und Externals entstehen aus Solution.json, ebenso Name
# und Version des Projekts. Die Zeile project(... LANGUAGES NONE) ist trotzdem
# Pflicht (seit CMakeCraft v0.13.0, sonst E005): Ohne sie setzt CMake ein
# eigenes project() VOR cmake_minimum_required() und richtet die Compiler nach
# alten Regeln ein (u. a. falsche CRT in der Konfiguration Testing).
#
# ==============================================================================

cmake_minimum_required(VERSION 3.26)
project(MeinProjekt LANGUAGES NONE)   # Name/Version kommen aus Solution.json

include("${CMAKE_CURRENT_LIST_DIR}/CMakeCraftBootstrap.cmake")
