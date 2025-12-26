# cmake/externals/hooks/prefetch/qt-ads.cmake
# ============================================
# PreFetch hook for Qt Advanced Docking System
#
# Version: 1.0.0
# Date:    2025-12-26
# Status:  Release
# Author:  CMake Architecture Team

include_guard(GLOBAL)

message(STATUS "[qt-ads] PreFetch: Configuring Qt-ADS")

set(ADS_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(ADS_BUILD_STATIC ON CACHE BOOL "" FORCE)

message(STATUS "[qt-ads] PreFetch complete")