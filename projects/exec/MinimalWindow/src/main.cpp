// projects/exec/MinimalWindow/src/main.cpp
// ==========================================
// Minimal Window application demonstrating BasicLogger
//
// Version: 0.1.1
// Date:    2025-12-09

#include <windows.h>
#include <iostream>
#include <cstdio>

#include "BasicLogger.h"   // Neuer Logger-Header

// Menu command IDs
enum : UINT {
    ID_FILE_EXIT = 1001,
    ID_ACTION_ONE = 2001,
    ID_ACTION_TWO = 2002,
    ID_HELP_ABOUT = 3001
};

// Simple Window Procedure (Wide)
LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    switch (uMsg)
    {
    case WM_COMMAND:
    {
        const UINT id = LOWORD(wParam);
        switch (id)
        {
        case ID_FILE_EXIT:
            BasicLogger::logInfo("Menu: File -> Exit");
            PostMessage(hwnd, WM_CLOSE, 0, 0);
            return 0;

        case ID_ACTION_ONE:
            BasicLogger::logInfo("Menu: Action -> Action One");
            return 0;

        case ID_ACTION_TWO:
            BasicLogger::logInfo("Menu: Action -> Action Two");
            return 0;

        case ID_HELP_ABOUT:
            BasicLogger::logInfo("Menu: Help -> About");
            MessageBoxW(hwnd,
                L"MinimalWindow\nwith BasicLogger console",
                L"About",
                MB_OK | MB_ICONINFORMATION);
            return 0;
        }
        break;
    }

    case WM_CLOSE:
        BasicLogger::logInfo("WM_CLOSE received");
        DestroyWindow(hwnd);
        return 0;

    case WM_DESTROY:
        BasicLogger::logInfo("Window closed (WM_DESTROY)");
        PostQuitMessage(0);
        return 0;

    default:
        break;
    }

    return DefWindowProcW(hwnd, uMsg, wParam, lParam);
}

// Creates a separate console for logging
void CreateLoggingConsole()
{
    AllocConsole();
    SetConsoleOutputCP(CP_UTF8); // UTF-8-Ausgabe in der Konsole

    FILE* fp;
    freopen_s(&fp, "CONOUT$", "w", stdout);
    freopen_s(&fp, "CONOUT$", "w", stderr);
    freopen_s(&fp, "CONIN$", "r", stdin);

    // Ab hier ist stdout/stderr mit der neuen Konsole verbunden
    BasicLogger::logInfo("Console initialized (UTF-8)");
}

// Create a simple menu
HMENU CreateMainMenu()
{
    HMENU hMenuBar = CreateMenu();
    HMENU hMenuFile = CreateMenu();
    HMENU hMenuAct = CreateMenu();
    HMENU hMenuHelp = CreateMenu();

    // File menu
    AppendMenuW(hMenuFile, MF_STRING, ID_FILE_EXIT, L"&Exit");

    // Action menu
    AppendMenuW(hMenuAct, MF_STRING, ID_ACTION_ONE, L"Action &One");
    AppendMenuW(hMenuAct, MF_STRING, ID_ACTION_TWO, L"Action &Two");

    // Help menu
    AppendMenuW(hMenuHelp, MF_STRING, ID_HELP_ABOUT, L"&About");

    // Add to menu bar
    AppendMenuW(hMenuBar, MF_POPUP, (UINT_PTR)hMenuFile, L"&File");
    AppendMenuW(hMenuBar, MF_POPUP, (UINT_PTR)hMenuAct, L"&Action");
    AppendMenuW(hMenuBar, MF_POPUP, (UINT_PTR)hMenuHelp, L"&Help");

    return hMenuBar;
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE, LPSTR, int nCmdShow)
{
    // Konsole für Ausgabe erstellen
    CreateLoggingConsole();

    // BasicLogger konfigurieren
    BasicLogger::setLogLevel(BasicLogger::Level::Debug);
    // Optional: Logfile aktivieren, falls gewünscht
    // BasicLogger::setLogFile("MinimalWindow.log");

    BasicLogger::logInfo("WinMain started...");

    const wchar_t CLASS_NAME[] = L"MinimalWindowClass";

    // Window Class (Wide)
    WNDCLASSW wc{};
    wc.lpfnWndProc = WindowProc;
    wc.hInstance = hInstance;
    wc.lpszClassName = CLASS_NAME;
    wc.hCursor = LoadCursor(nullptr, IDC_ARROW);
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);

    if (!RegisterClassW(&wc))
    {
        BasicLogger::logError("RegisterClassW failed");
        BasicLogger::logInfo("Press Enter to exit...");
        std::cin.get();
        return 1;
    }

    HMENU hMenu = CreateMainMenu();

    // Create Window (Wide)
    HWND hwnd = CreateWindowExW(
        0,
        CLASS_NAME,
        L"MinimalWindow mit BasicLogger-Konsole",
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT, CW_USEDEFAULT, 800, 500,
        nullptr,
        hMenu,
        hInstance,
        nullptr
    );

    if (!hwnd)
    {
        BasicLogger::logError("CreateWindowExW failed");
        BasicLogger::logInfo("Press Enter to exit...");
        std::cin.get();
        return 1;
    }

    ShowWindow(hwnd, nCmdShow);
    UpdateWindow(hwnd);

    // Message Loop (Wide)
    MSG msg{};
    while (GetMessageW(&msg, nullptr, 0, 0) > 0)
    {
        TranslateMessage(&msg);
        DispatchMessageW(&msg);
    }

    {
        std::ostringstream oss;
        oss << "Message loop ended, wParam = " << msg.wParam;
        BasicLogger::logInfo(oss.str());
    }

    BasicLogger::logInfo("Application will now exit. Press Enter to close this console...");
    std::cin.get();

    // Kein FreeConsole(), damit bis zum Exit alles sichtbar bleibt
    return static_cast<int>(msg.wParam);
}
