# MinimalWindow – Referenz

> **Version:** 0.1.1  
> **Datum:** 2025-12-09  
> **Typ:** Referenz-Doku  
> **Status:** In Entwicklung

---

## 1. Einstiegspunkte

### `int WINAPI WinMain(...)`

| Zweck | Erstellt Loggerkonsole, registriert Fensterklasse, erstellt Fenster, führt MessageLoop aus |
|------|------------------------------------------------------------------------------------------------|

Signatur:
```cpp
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE, LPSTR, int nCmdShow);
```

Parameter:
| Name | Bedeutung |
|------|----------|
| hInstance | Instanzhandle |
| nCmdShow | Window-Show-Option |

Rückgabe: `msg.wParam`, resultierend aus `PostQuitMessage()`.

---

## 2. Zentrale Funktionen

### `LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)`

| Verarbeitung | Beschreibung |
|-------------|-------------|
| WM_COMMAND | Menüdialogeingaben|
| WM_CLOSE | Log „WM_CLOSE" + DestroyWindow|
| WM_DESTROY | Log + PostQuitMessage(0)|

Return: 0 für abgefangene Nachrichten, sonst `DefWindowProcW(...)`.

---

### `void CreateLoggingConsole()`

| Aufgabe | Erstellt neue Konsole und leitet stdout/stderr um |
|--------|----------------------------------------------------|

Zusätzlich: UTF‑8 Ausgabe per `SetConsoleOutputCP(CP_UTF8)`.

---

### `HMENU CreateMainMenu()`

| Aufgabe | Erzeugt Menüleiste |
|--------|---------------------|

| Menü | Elemente |
|------|----------|
| File | Exit |
| Action | One, Two |
| Help | About |

Rückgabe: `HMENU` zur Verwendung in `CreateWindowExW`.

---

## 3. Menü-IDs

```cpp
enum : UINT {
    ID_FILE_EXIT  = 1001,
    ID_ACTION_ONE = 2001,
    ID_ACTION_TWO = 2002,
    ID_HELP_ABOUT = 3001
};
```

| ID | Menü | Aktion |
|----|------|-------|
|1001| File | Exit|
|2001| Action | Action One (Log)|
|2002| Action | Action Two (Log)|
|3001| Help | About (MessageBox + Log)|

---

## 4. Loggerintegration

Verwendete Funktionen:
- `BasicLogger::logInfo(...)`
- `BasicLogger::logError(...)`
- `BasicLogger::setLogLevel(...)`

Standardverhalten: Ausgabe in Konsole. LogFile optional.

---

## 5. MessageLoop

```cpp
MSG msg{};
while (GetMessageW(&msg, nullptr, 0, 0) > 0)
{
    TranslateMessage(&msg);
    DispatchMessageW(&msg);
}
```

- Beendet bei: `WM_DESTROY` → `PostQuitMessage(0)`

---

## 6. Exitverhalten

- LogInfo „Application will now exit...“
- `std::cin.get();` wartet auf Enter

Rückgabe: `(int)msg.wParam`

---

## 7. Siehe auch

- `Doku_MinimalWindow_v0_1_1`
- `UserGuide_MinimalWindow_v0_1_1`

---

## 8. Changelog

| Version | Änderungen |
|--------|------------|
|0.1.1 | Erste Referenz erstellt |

