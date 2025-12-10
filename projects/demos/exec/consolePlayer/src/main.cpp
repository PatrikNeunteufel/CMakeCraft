/**
 ****************************************************************************************
 * @file   main.cpp
 * @brief  BASS console player with DX8 reverb + BASS_FX time-stretch (tempo/pitch).
 *         - Console UI (no MessageBox): clear screen on each change, show title/menu/status.
 *         - Hotkeys:
 *             [Left]/[Right] : previous/next track
 *             [+] / [-]:      tempo ±5%
 *             F1/F2 :         SEQUENCE_MS  +10 / -10
 *             F3/F4 :         OVERLAP_MS   +5  / -5
 *             F5/F6 :         SEEKWINDOW   +10 / -10
 *             F7    :         QUICKALGO toggle (0/1)
 *             F8    :         Toggle DX8 Reverb ON/OFF
 *             ESC   :         Stop & exit
 *         - Tempo starts at 0% (normal).
 *
 * Build notes:
 *   - Requires bass.lib (+ bass.dll at runtime).
 *   - For tempo features: also bass_fx.lib (+ bass_fx.dll at runtime).
 *   - Windows console; DX8 effects available on Windows only.
 *
 * Author: Patrik Neunteufel
 * Date:   August 2025
 ****************************************************************************************
 */
#include "pch.h"

#ifdef _WIN32
#include <windows.h> // console, keys, sleep, window placement
#endif

#include <cstdio>
#include <cwchar>
#include <iostream>
#include <string>
#include <vector>

#include "bass.h"
#include "bass_fx.h" // link with bass_fx.lib for tempo

#pragma comment(lib, "bass.lib")
#pragma comment(lib, "bass_fx.lib")

/* ============================= User configuration =================================== */

// Base folder once (keeps track list tidy)
//static const wchar_t* kMusicRoot = L"..\\..\\..\\..\\..\\..\\..\\music\\";
//static const wchar_t* kMusicRoot = L"E:\\VisualStudio\\Visuals_Project\\music\\";
static const wchar_t* kMusicRoot = L"C:/Users/patri/source/repos/Visuals_Project/music/";

// Track list (UTF-16). Add/remove as you like.
static const wchar_t* kTracks[] = {
    L"London Grammar - Californian Soil\\06 How Does It Feel.mp3",
    L"London Grammar - Californian Soil\\05 Lord Its a Feeling.mp3",
    L"London Grammar - Californian Soil\\02 Californian Soil.mp3",
    L"London Grammar - Californian Soil\\11 I Need the Night.mp3",
    L"London Grammar - Californian Soil\\12 America.mp3",
    L"London Grammar - Discography [FLAC] [PMEDIA]\\(2013) - London Grammar - "
    L"If You Wait [24Bit-44.1kHz]\\01. Hey Now.flac",
    L"London Grammar - Discography [FLAC] [PMEDIA]\\(2013) - London Grammar - "
    L"If You Wait [24Bit-44.1kHz]\\04. Wasting My Young Years.flac",
    L"London Grammar - Discography [FLAC] [PMEDIA]\\(2013) - London Grammar - "
    L"If You Wait [24Bit-44.1kHz]\\06. Strong.flac",
    L"London Grammar - Discography [FLAC] [PMEDIA]\\(2013) - London Grammar - "
    L"If You Wait [24Bit-44.1kHz]\\07. Nightcall.flac",
    L"London Grammar - Discography [FLAC] [PMEDIA]\\(2013) - London Grammar - "
    L"If You Wait [24Bit-44.1kHz]\\11. If You Wait.flac",
    L"London Grammar - Truth Is a Beautiful Thing (Deluxe) (2017)\\"
    L"01 - Rooting For You.mp3",
    L"London Grammar - Truth Is a Beautiful Thing (Deluxe) (2017)\\"
    L"02 - Big Picture.mp3",
    L"London Grammar - Truth Is a Beautiful Thing (Deluxe) (2017)\\"
    L"04 - Oh Woman Oh Man.mp3",
    L"London Grammar - Truth Is a Beautiful Thing (Deluxe) (2017)\\"
    L"07 - Non Believer.mp3",
    L"London Grammar - Truth Is a Beautiful Thing (Deluxe) (2017)\\"
    L"11 - Truth Is A Beautiful Thing.mp3"
};
static constexpr int kTrackCount =
    static_cast<int> (sizeof (kTracks) / sizeof (kTracks[0]));

// Global defaults
static const bool kUseTempoDefault      = true; // tempo pipeline enabled
static const float kTempoPercentDefault = 0.0f; // start NORMAL (0%)
static const DWORD kTempoAlgoFlagsDefault = BASS_FX_TEMPO_ALGO_LINEAR; // linear ~less CPU

// Global buffering: helps against dropouts at strong tempo changes
static const DWORD kUpdatePeriodMs = 20;  // 20–30 ms is a good range
static const DWORD kBufferMs       = 900; // 800–1200 ms headroom

/* ============================= Utilities / Console UI =============================== */

static void OutputDbg (const wchar_t* s)
{
#ifdef _WIN32
    OutputDebugStringW (s);
    OutputDebugStringW (L"\n");
#else
    (void)s;
#endif
}

// Clear entire console buffer and set cursor to (0,0)
static void ClearConsole ()
{
#ifdef _WIN32
    HANDLE hOut = GetStdHandle (STD_OUTPUT_HANDLE);
    if (hOut == INVALID_HANDLE_VALUE)
        return;

    CONSOLE_SCREEN_BUFFER_INFO csbi{};
    if (!GetConsoleScreenBufferInfo (hOut, &csbi))
        return;

    const DWORD cells = csbi.dwSize.X * csbi.dwSize.Y;
    DWORD written     = 0;
    FillConsoleOutputCharacterW (hOut, L' ', cells, { 0, 0 }, &written);
    FillConsoleOutputAttribute (hOut, csbi.wAttributes, cells, { 0, 0 }, &written);
    SetConsoleCursorPosition (hOut, { 0, 0 });
#else
    // Fallback: ANSI clear
    std::wcout << L"\x1b[2J\x1b[H";
#endif
}

static void PrintTitle ()
{
    std::wcout
        << L"===================== BASS CONSOLE PLAYER =====================\n"
        << L"DX8 Reverb (Windows) + BASS_FX Tempo (optional)\n"
        << L"---------------------------------------------------------------\n";
}

static void PrintMenu (bool useTempo)
{
    std::wcout << L"[Left]/[Right]  : Prev/Next Track\n";
    if (useTempo)
    {
        std::wcout << L"[+] / [-]:       Tempo ±5%\n"
                   << L"F1/F2           : SEQUENCE ±10 ms\n"
                   << L"F3/F4           : OVERLAP  ±5 ms\n"
                   << L"F5/F6           : SEEKWIN  ±10 ms\n"
                   << L"F7              : QUICKALGO toggle\n";
    }
    std::wcout
        << L"F8              : Reverb ON/OFF\n"
        << L"ESC             : Exit\n"
        << L"---------------------------------------------------------------\n";
}

static std::wstring JoinPath (const wchar_t* a, const wchar_t* b)
{
    std::wstring s (a);
    s += b;
    return s;
}

/* ============================= BASS helpers ========================================= */

static void ShowBassError (const wchar_t* caption)
{
    const int code = BASS_ErrorGetCode ();
    wchar_t buf[256];
    wsprintfW (buf, L"%s\nBASS error code: %d", caption, code);
    OutputDbg (buf);
    std::wcout << buf << std::endl;
}

static void CheckVersionMismatch ()
{
    const DWORD v   = BASS_GetVersion ();
    const DWORD vfx = BASS_FX_GetVersion ();
    if ((v >> 16) != (vfx >> 16))
        OutputDbg (L"[BASS] Warning: Major version mismatch between BASS and "
                   L"BASS_FX.");
}

// Apply or remove DX8 Reverb on a channel
static void ApplyDx8Reverb (HCHANNEL chan, bool enable, HFX& fxHandle)
{
#ifdef _WIN32
    if (enable && !fxHandle)
    {
        fxHandle = BASS_ChannelSetFX (chan, BASS_FX_DX8_REVERB, 0);
        if (!fxHandle)
        {
            OutputDbg (L"[BASS] DX8 Reverb not available; continuing dry.");
            return;
        }
        BASS_DX8_REVERB p{};
        if (BASS_FXGetParameters (fxHandle, &p))
        {
            p.fInGain          = 0.0f;   // dB
            p.fReverbMix       = -10.0f; // dB
            p.fReverbTime      = 1.8f;   // seconds
            p.fHighFreqRTRatio = 0.6f;   // 0..1
            BASS_FXSetParameters (fxHandle, &p);
        }
    }
    else if (!enable && fxHandle)
    {
        BASS_ChannelRemoveFX (chan, fxHandle);
        fxHandle = 0;
    }
#else
    (void)chan;
    (void)enable;
    (void)fxHandle;
#endif
}

static float Clampf (float v, float lo, float hi)
{
    return (v < lo) ? lo : ((v > hi) ? hi : v);
}

static void PrintTempoState (HSTREAM stream)
{
    float tempo = 0, seq = 0, ovl = 0, seek = 0, quick = 0, freq = 0;
    BASS_ChannelGetAttribute (stream, BASS_ATTRIB_TEMPO, &tempo);
    BASS_ChannelGetAttribute (stream, BASS_ATTRIB_TEMPO_OPTION_SEQUENCE_MS, &seq);
    BASS_ChannelGetAttribute (stream, BASS_ATTRIB_TEMPO_OPTION_OVERLAP_MS, &ovl);
    BASS_ChannelGetAttribute (stream, BASS_ATTRIB_TEMPO_OPTION_SEEKWINDOW_MS, &seek);
    BASS_ChannelGetAttribute (stream, BASS_ATTRIB_TEMPO_OPTION_USE_QUICKALGO, &quick);
    BASS_ChannelGetAttribute (stream, BASS_ATTRIB_TEMPO_FREQ, &freq);

    std::wcout << L"Tempo: " << tempo << L"% | Seq: " << seq << L" ms | Ovl: "
               << ovl << L" ms | Seek: " << seek << L" ms | Quick: "
               << (quick > 0.5f ? L"ON" : L"OFF") << L" | ProcFreq: " << freq << L" Hz\n";
}

static void SetInitialTempoTuning (HSTREAM stream, float tempoPercent)
{
    BASS_ChannelSetAttribute (stream, BASS_ATTRIB_TEMPO, tempoPercent);
    BASS_ChannelSetAttribute (stream, BASS_ATTRIB_TEMPO_OPTION_SEQUENCE_MS, 82.0f);
    BASS_ChannelSetAttribute (stream, BASS_ATTRIB_TEMPO_OPTION_OVERLAP_MS, 12.0f);
    BASS_ChannelSetAttribute (stream, BASS_ATTRIB_TEMPO_OPTION_SEEKWINDOW_MS, 82.0f);
    BASS_ChannelSetAttribute (stream, BASS_ATTRIB_TEMPO_OPTION_USE_QUICKALGO, 1.0f);
}

/* Create a playable stream */
static HSTREAM
CreatePlayableStream (const std::wstring& fullPath, bool useTempo, float tempoPercent, DWORD tempoAlgoFlags, HSTREAM& outSrc)
{
    outSrc = 0;

    if (useTempo)
    {
        outSrc = BASS_StreamCreateFile (FALSE, fullPath.c_str (), 0, 0, BASS_UNICODE | BASS_STREAM_DECODE);
        if (!outSrc)
        {
            ShowBassError (L"Create decoding source failed");
            return 0;
        }

        HSTREAM tempo = BASS_FX_TempoCreate (outSrc, BASS_FX_FREESOURCE | tempoAlgoFlags);
        if (!tempo)
        {
            ShowBassError (L"Create tempo stream failed; falling back to plain "
                           L"stream");
            BASS_StreamFree (outSrc);
            outSrc = 0;

            HSTREAM plain =
                BASS_StreamCreateFile (FALSE, fullPath.c_str (), 0, 0, BASS_UNICODE);
            if (!plain)
                ShowBassError (L"Create plain stream (fallback) failed");
            return plain;
        }

        SetInitialTempoTuning (tempo, tempoPercent);
        return tempo;
    }
    else
    {
        HSTREAM s = BASS_StreamCreateFile (FALSE, fullPath.c_str (), 0, 0, BASS_UNICODE);
        if (!s)
            ShowBassError (L"Create plain stream failed");
        return s;
    }
}

/* ============================= Player state ========================================== */

struct PlayerState
{
    int trackIndex       = 0;
    bool useTempo        = kUseTempoDefault;
    float tempoPercent   = kTempoPercentDefault;
    DWORD tempoAlgoFlags = kTempoAlgoFlagsDefault;
    bool reverbOn        = true;

    HSTREAM stream    = 0;
    HSTREAM srcDecode = 0;
    HFX reverbFx      = 0;
};

static void StopAndFree (PlayerState& ps)
{
    if (ps.stream)
    {
        BASS_ChannelStop (ps.stream);
        BASS_StreamFree (ps.stream);
        ps.stream = 0;
    }
    ps.srcDecode = 0;
    ps.reverbFx  = 0;
}

static bool StartTrack (PlayerState& ps)
{
    const std::wstring fullPath = JoinPath (kMusicRoot, kTracks[ps.trackIndex]);
    StopAndFree (ps);

    ps.stream =
        CreatePlayableStream (fullPath, ps.useTempo, ps.tempoPercent, ps.tempoAlgoFlags, ps.srcDecode);
    if (!ps.stream)
        return false;

    ApplyDx8Reverb (ps.stream, ps.reverbOn, ps.reverbFx);

    if (!BASS_ChannelPlay (ps.stream, FALSE))
    {
        ShowBassError (L"Failed to start playback");
        StopAndFree (ps);
        return false;
    }
    return true;
}

/* ============================= Console UI Rendering ================================== */

static void RenderUI (const PlayerState& ps, const wchar_t* lastAction)
{
    ClearConsole ();
    PrintTitle ();
    PrintMenu (ps.useTempo);

    std::wcout << L"Track: [" << (ps.trackIndex + 1) << L"/" << kTrackCount
               << L"] " << kTracks[ps.trackIndex] << L"\n"
               << L"Reverb: " << (ps.reverbOn ? L"ON" : L"OFF") << L"\n";

    if (ps.useTempo)
    {
        PrintTempoState (ps.stream);
    }

    std::wcout << L"\nLast action: " << (lastAction ? lastAction : L"(none)") << L"\n";
}

/* ============================= Helper: robust console active ========================= */

#ifdef _WIN32
static bool IsWindowOfCurrentProcess (HWND hWnd)
{
    if (!hWnd)
        return false;
    DWORD pid = 0;
    GetWindowThreadProcessId (hWnd, &pid);
    return pid == GetCurrentProcessId ();
}

static bool IsConsoleActiveTolerant ()
{
    HWND hConsole    = GetConsoleWindow ();
    HWND hForeground = GetForegroundWindow ();

    if (!hConsole)
        return true;

    if (hConsole == hForeground)
        return true;

    if (IsWindowOfCurrentProcess (hForeground))
        return true;

    WINDOWPLACEMENT wp{};
    wp.length = sizeof (wp);
    if (GetWindowPlacement (hConsole, &wp))
    {
        if (wp.showCmd != SW_SHOWMINIMIZED)
            return true;
    }

    return false;
}
#endif

/* ============================= Run loop (hotkeys) ==================================== */

static void RunLoop (PlayerState& ps)
{
#ifdef _WIN32
    auto wasPressed = [] (int vk) -> bool
    {
        return (GetAsyncKeyState (vk) & 0x0001) != 0;
    };
    const wchar_t* last = L"started";

    RenderUI (ps, last);

    bool prevConsoleActive = true;

    for (;;)
    {
        const bool consoleActive = IsConsoleActiveTolerant ();

        if (consoleActive != prevConsoleActive)
        {
            last = consoleActive ? L"console ACTIVE (tolerant)" : L"console INACTIVE (tolerant)";
            RenderUI (ps, last);
            prevConsoleActive = consoleActive;
        }

        if (consoleActive)
        {
            if (wasPressed (VK_ESCAPE))
                break;

            bool changed = false;

            const bool kLeft  = wasPressed (VK_LEFT);
            const bool kRight = wasPressed (VK_RIGHT);
            const bool kPlus = (wasPressed (VK_OEM_PLUS) || wasPressed (VK_ADD));
            const bool kMinus = (wasPressed (VK_OEM_MINUS) || wasPressed (VK_SUBTRACT));
            const bool kF1 = wasPressed (VK_F1);
            const bool kF2 = wasPressed (VK_F2);
            const bool kF3 = wasPressed (VK_F3);
            const bool kF4 = wasPressed (VK_F4);
            const bool kF5 = wasPressed (VK_F5);
            const bool kF6 = wasPressed (VK_F6);
            const bool kF7 = wasPressed (VK_F7);
            const bool kF8 = wasPressed (VK_F8);

            if (kLeft)
            {
                ps.trackIndex = (ps.trackIndex - 1 + kTrackCount) % kTrackCount;
                StartTrack (ps);
                last    = L"prev track";
                changed = true;
            }
            if (kRight)
            {
                ps.trackIndex = (ps.trackIndex + 1) % kTrackCount;
                StartTrack (ps);
                last    = L"next track";
                changed = true;
            }

            if (ps.useTempo)
            {
                float v = 0.0f;

                if (kPlus)
                {
                    BASS_ChannelGetAttribute (ps.stream, BASS_ATTRIB_TEMPO, &v);
                    v = Clampf (v + 5.0f, -95.0f, 95.0f);
                    BASS_ChannelSetAttribute (ps.stream, BASS_ATTRIB_TEMPO, v);
                    ps.tempoPercent = v;
                    last            = L"tempo +5%";
                    changed         = true;
                }
                else if (kMinus)
                {
                    BASS_ChannelGetAttribute (ps.stream, BASS_ATTRIB_TEMPO, &v);
                    v = Clampf (v - 5.0f, -95.0f, 95.0f);
                    BASS_ChannelSetAttribute (ps.stream, BASS_ATTRIB_TEMPO, v);
                    ps.tempoPercent = v;
                    last            = L"tempo -5%";
                    changed         = true;
                }

                if (kF1)
                {
                    BASS_ChannelGetAttribute (ps.stream, BASS_ATTRIB_TEMPO_OPTION_SEQUENCE_MS, &v);
                    v = Clampf (v + 10.0f, 1.0f, 500.0f);
                    BASS_ChannelSetAttribute (ps.stream, BASS_ATTRIB_TEMPO_OPTION_SEQUENCE_MS, v);
                    last    = L"sequence +10 ms";
                    changed = true;
                }
                else if (kF2)
                {
                    BASS_ChannelGetAttribute (ps.stream, BASS_ATTRIB_TEMPO_OPTION_SEQUENCE_MS, &v);
                    v = Clampf (v - 10.0f, 1.0f, 500.0f);
                    BASS_ChannelSetAttribute (ps.stream, BASS_ATTRIB_TEMPO_OPTION_SEQUENCE_MS, v);
                    last    = L"sequence -10 ms";
                    changed = true;
                }

                if (kF3)
                {
                    BASS_ChannelGetAttribute (ps.stream, BASS_ATTRIB_TEMPO_OPTION_OVERLAP_MS, &v);
                    v = Clampf (v + 5.0f, 1.0f, 200.0f);
                    BASS_ChannelSetAttribute (ps.stream, BASS_ATTRIB_TEMPO_OPTION_OVERLAP_MS, v);
                    last    = L"overlap +5 ms";
                    changed = true;
                }
                else if (kF4)
                {
                    BASS_ChannelGetAttribute (ps.stream, BASS_ATTRIB_TEMPO_OPTION_OVERLAP_MS, &v);
                    v = Clampf (v - 5.0f, 1.0f, 200.0f);
                    BASS_ChannelSetAttribute (ps.stream, BASS_ATTRIB_TEMPO_OPTION_OVERLAP_MS, v);
                    last    = L"overlap -5 ms";
                    changed = true;
                }

                if (kF5)
                {
                    BASS_ChannelGetAttribute (ps.stream, BASS_ATTRIB_TEMPO_OPTION_SEEKWINDOW_MS, &v);
                    v = Clampf (v + 10.0f, 0.0f, 500.0f);
                    BASS_ChannelSetAttribute (ps.stream, BASS_ATTRIB_TEMPO_OPTION_SEEKWINDOW_MS, v);
                    last    = L"seekwindow +10 ms";
                    changed = true;
                }
                else if (kF6)
                {
                    BASS_ChannelGetAttribute (ps.stream, BASS_ATTRIB_TEMPO_OPTION_SEEKWINDOW_MS, &v);
                    v = Clampf (v - 10.0f, 0.0f, 500.0f);
                    BASS_ChannelSetAttribute (ps.stream, BASS_ATTRIB_TEMPO_OPTION_SEEKWINDOW_MS, v);
                    last    = L"seekwindow -10 ms";
                    changed = true;
                }

                if (kF7)
                {
                    BASS_ChannelGetAttribute (ps.stream, BASS_ATTRIB_TEMPO_OPTION_USE_QUICKALGO, &v);
                    v = (v > 0.5f) ? 0.0f : 1.0f;
                    BASS_ChannelSetAttribute (ps.stream, BASS_ATTRIB_TEMPO_OPTION_USE_QUICKALGO, v);
                    last    = (v > 0.5f) ? L"quickalgo OFF" : L"quickalgo ON";
                    changed = true;
                }
            }

            if (kF8)
            {
                ps.reverbOn = !ps.reverbOn;
                ApplyDx8Reverb (ps.stream, ps.reverbOn, ps.reverbFx);
                last    = ps.reverbOn ? L"reverb ON" : L"reverb OFF";
                changed = true;
            }

            if (changed)
            {
                RenderUI (ps, last);
            }
        }
        else
        {
            if (GetAsyncKeyState (VK_ESCAPE) & 0x0001)
                break;
        }

        Sleep (10);
    }
#else
    (void)ps;
#endif
}

/* ============================= Program entry ========================================= */

int commonMain ()
{
    BASS_SetConfig (BASS_CONFIG_UPDATEPERIOD, kUpdatePeriodMs);
    BASS_SetConfig (BASS_CONFIG_BUFFER, kBufferMs);

    if (!BASS_Init (-1, 44100, 0, nullptr, nullptr))
    {
        ShowBassError (L"Failed to init BASS");
        return 1;
    }

    CheckVersionMismatch ();

    PlayerState ps{};
    ps.trackIndex     = 0;
    ps.useTempo       = kUseTempoDefault;
    ps.tempoPercent   = kTempoPercentDefault;
    ps.tempoAlgoFlags = kTempoAlgoFlagsDefault;
    ps.reverbOn       = true;

    if (!StartTrack (ps))
    {
        BASS_Free ();
        return 2;
    }

    RenderUI (ps, L"started");
    RunLoop (ps);

    StopAndFree (ps);
    BASS_Free ();
    return 0;
}

#if defined(APP_WINDOWS_GUI)
int WINAPI WinMain (HINSTANCE, HINSTANCE, LPSTR, int)
{
    return commonMain ();
}
#else
int main (int /*argc*/, char* /*argv*/[])
{
    std::wcout << L"BASS console player starting..." << std::endl;
    return commonMain ();
}
#endif
