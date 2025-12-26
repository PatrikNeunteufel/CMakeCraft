# cmake/externals/hooks/postfetch/qt-ads.cmake
# ==============================================
# PostFetch hook for Qt Advanced Docking System
#
# Version: 1.0.0
# Date:    2025-12-26
# Status:  Release
# Author:  CMake Architecture Team

include_guard(GLOBAL)

message(STATUS "[qt-ads] PostFetch: Registering target")

# Qt-ADS creates target 'qt6advanceddocking' (or 'qtadvanceddocking' for Qt5)
if(TARGET qt6advanceddocking)
    _register_external_target("${HOOK_EXTERNAL_NAME}" "qt6advanceddocking" PRIMARY)
    message(STATUS "[qt-ads] Registered: qt6advanceddocking")
elseif(TARGET qtadvanceddocking)
    _register_external_target("${HOOK_EXTERNAL_NAME}" "qtadvanceddocking" PRIMARY)
    message(STATUS "[qt-ads] Registered: qtadvanceddocking")
else()
    message(WARNING "[qt-ads] No target found (qt6advanceddocking or qtadvanceddocking)")
endif()

message(STATUS "[qt-ads] PostFetch complete")