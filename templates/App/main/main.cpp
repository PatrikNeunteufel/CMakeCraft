// =============================================================================
// Generic Application Entry Point
// CMake Architecture V2 - App-Container Template
// =============================================================================
//
// Diese main.cpp ist für alle App-Container identisch.
// Die gesamte Anwendungslogik liegt in Application (src/).
//
// Build-System setzt automatisch:
//   - APP_GUI    : Bei runner.type = "GUI" (Windows: WinMain)
//   - APP_CONSOLE: Bei runner.type = "CONSOLE"
//
// =============================================================================

#include "Application.hpp"

#if defined(_WIN32)
    #include <Windows.h>
#endif

// =============================================================================
// Common Entry Point
// =============================================================================
namespace {

int commonMain(int argc, char* argv[]) {
    Application app;
    
    // Initialisierung (Qt, Audio, Config, etc.)
    if (!app.init(argc, argv)) {
        return 1;
    }
    
    // Hauptschleife (Qt: exec(), Console: eigene Loop)
    int result = app.run();
    
    // Aufräumen
    app.shutdown();
    
    return result;
}

} // namespace

// =============================================================================
// Platform-specific Entry Points
// =============================================================================

#if defined(_WIN32) && defined(APP_GUI)

// Windows GUI: WinMain entry point (kein Console-Fenster)
int WINAPI WinMain(
    [[maybe_unused]] HINSTANCE hInstance,
    [[maybe_unused]] HINSTANCE hPrevInstance,
    [[maybe_unused]] LPSTR lpCmdLine,
    [[maybe_unused]] int nCmdShow
) {
    return commonMain(__argc, __argv);
}

#else

// Console / Linux / macOS: Standard main
int main(int argc, char* argv[]) {
    return commonMain(argc, argv);
}

#endif
