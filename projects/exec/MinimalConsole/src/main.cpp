// =============================================================================
// MinimalConsole - BASS Audio Player Demo
// =============================================================================
//
// Version:     2.0.0
// Date:        2025-12-08
// Part of:     CMake Architecture V2
//
// Description:
//   Demonstrates BASS audio library integration with the CMake build system.
//   Plays an MP3 file using BASS with FLAC decoder plugin enabled.
//
// Dependencies:
//   - BasicLogger (internal library)
//   - bass (external, with BASS_FLAC option)
//
// =============================================================================

#include <BasicLogger.h>
#include <bass.h>

#include <iostream>
#include <string>
#include <thread>
#include <chrono>
#include <filesystem>

namespace fs = std::filesystem;

// =============================================================================
// Helper Functions
// =============================================================================

/// Get the path to the music file relative to executable location
std::string getMusicPath() {
    // Path relative to project root: ../../music/London Grammar - Californian Soil/02 Californian Soil.mp3
    // Since exe is in build/exec/MinimalConsole/bin/Debug/, we need to go up several levels
    
    // Try multiple potential paths
    std::vector<std::string> paths = {
        // Relative to project root (when running from project directory)
        //"E:/VisualStudio/Visuals_Project/music/London Grammar - Californian Soil/02 Californian Soil.mp3",
        "C:/Users/patri/source/repos/Visuals_Project/music/London Grammar - Californian Soil/02 Californian Soil.mp3",
        // Relative to build directory
        "../../../../../music/London Grammar - Californian Soil/02 Californian Soil.mp3",
        // Absolute fallback (adjust as needed)
        "music/London Grammar - Californian Soil/02 Californian Soil.mp3"
    };
    
    for (const auto& path : paths) {
        if (fs::exists(path)) {
            return path;
        }
    }
    
    // Return the most likely path even if not found (for error message)
    return paths[0];
}

/// Format time in MM:SS
std::string formatTime(double seconds) {
    int mins = static_cast<int>(seconds) / 60;
    int secs = static_cast<int>(seconds) % 60;
    
    char buffer[16];
    snprintf(buffer, sizeof(buffer), "%02d:%02d", mins, secs);
    return buffer;
}

/// Get BASS error description
const char* getBassError(int errorCode) {
    switch (errorCode) {
        case BASS_OK:             return "OK";
        case BASS_ERROR_MEM:      return "Memory error";
        case BASS_ERROR_FILEOPEN: return "Can't open file";
        case BASS_ERROR_DRIVER:   return "Can't find audio driver";
        case BASS_ERROR_HANDLE:   return "Invalid handle";
        case BASS_ERROR_FORMAT:   return "Unsupported format";
        case BASS_ERROR_POSITION: return "Invalid position";
        case BASS_ERROR_INIT:     return "BASS not initialized";
        case BASS_ERROR_START:    return "BASS_Start not called";
        //case BASS_ERROR_NOCD:     return "No CD in drive";
        case BASS_ERROR_NOCHAN:   return "Can't get free channel";
        case BASS_ERROR_ILLTYPE:  return "Illegal type";
        case BASS_ERROR_ILLPARAM: return "Illegal parameter";
        case BASS_ERROR_NO3D:     return "No 3D support";
        case BASS_ERROR_NOEAX:    return "No EAX support";
        case BASS_ERROR_DEVICE:   return "Illegal device";
        case BASS_ERROR_NOPLAY:   return "Not playing";
        case BASS_ERROR_FREQ:     return "Illegal sample rate";
        case BASS_ERROR_NOTFILE:  return "Not a file stream";
        case BASS_ERROR_NOHW:     return "No hardware support";
        case BASS_ERROR_EMPTY:    return "Empty";
        case BASS_ERROR_NONET:    return "No internet connection";
        case BASS_ERROR_CREATE:   return "Can't create file";
        case BASS_ERROR_NOFX:     return "Effects not available";
        //case BASS_ERROR_PLAYING:  return "Already playing";
        case BASS_ERROR_NOTAVAIL: return "Not available";
        case BASS_ERROR_DECODE:   return "Can't decode";
        case BASS_ERROR_DX:       return "DirectX error";
        case BASS_ERROR_TIMEOUT:  return "Timeout";
        case BASS_ERROR_FILEFORM: return "Unsupported file format";
        case BASS_ERROR_SPEAKER:  return "Unavailable speaker";
        case BASS_ERROR_VERSION:  return "Version mismatch";
        case BASS_ERROR_CODEC:    return "Codec not available";
        case BASS_ERROR_ENDED:    return "Ended";
        case BASS_ERROR_BUSY:     return "Device busy";
        case BASS_ERROR_UNKNOWN:
        default:                  return "Unknown error";
    }
}

// =============================================================================
// Main
// =============================================================================

int main() {
    // Initialize logger
    BasicLogger::Logger logger("minimal_console.log");
    logger.setLevel(BasicLogger::Level::Debug);
    logger.setConsoleOutput(false); 
    logger.info("=== MinimalConsole v2.0.0 - BASS Audio Demo ===");
    
    // -------------------------------------------------------------------------
    // Initialize BASS
    // -------------------------------------------------------------------------
    
    logger.info("Initializing BASS Audio Library...");
    
    // Check BASS version
    DWORD bassVersion = BASS_GetVersion();
    logger.info("BASS Version: " + std::to_string(HIWORD(bassVersion)) + "." + 
                std::to_string(LOWORD(bassVersion)));
    
    // Initialize BASS (-1 = default device, 44100 Hz)
    if (!BASS_Init(-1, 44100, 0, nullptr, nullptr)) {
        int error = BASS_ErrorGetCode();
        logger.error("BASS_Init failed: " + std::string(getBassError(error)));
        return 1;
    }
    
    logger.info("BASS initialized successfully");
    
    // -------------------------------------------------------------------------
    // Load and Play Music
    // -------------------------------------------------------------------------
    
    std::string musicPath = getMusicPath();
    logger.info("Loading: " + musicPath);
    
    // Check if file exists
    if (!fs::exists(musicPath)) {
        logger.error("Music file not found: " + musicPath);
        logger.info("Please ensure the music file exists at the specified path");
        BASS_Free();
        return 1;
    }
    
    // Create stream
    HSTREAM stream = BASS_StreamCreateFile(
        FALSE,                  // Not from memory
        musicPath.c_str(),      // File path
        0,                      // Offset
        0,                      // Length (0 = whole file)
        BASS_SAMPLE_FLOAT       // Use floating-point sample data
    );
    
    if (stream == 0) {
        int error = BASS_ErrorGetCode();
        logger.error("Failed to create stream: " + std::string(getBassError(error)));
        BASS_Free();
        return 1;
    }
    
    // Get stream info
    BASS_CHANNELINFO info;
    BASS_ChannelGetInfo(stream, &info);
    logger.info("Format: " + std::to_string(info.freq) + " Hz, " + 
                std::to_string(info.chans) + " channels");
    
    // Get duration
    QWORD lengthBytes = BASS_ChannelGetLength(stream, BASS_POS_BYTE);
    double lengthSeconds = BASS_ChannelBytes2Seconds(stream, lengthBytes);
    logger.info("Duration: " + formatTime(lengthSeconds));
    
    // Start playback
    logger.info("Starting playback...");
    if (!BASS_ChannelPlay(stream, FALSE)) {
        int error = BASS_ErrorGetCode();
        logger.error("Failed to play: " + std::string(getBassError(error)));
        BASS_StreamFree(stream);
        BASS_Free();
        return 1;
    }
    
    std::cout << "\n";
    std::cout << "+================================================================+\n";
    std::cout << "|  Now Playing: London Grammar - Californian Soil               |\n";
    std::cout << "+----------------------------------------------------------------+\n";
    std::cout << "|  Press Enter to stop playback...                              |\n";
    std::cout << "+================================================================+\n";
    std::cout << "\n";
    
    // -------------------------------------------------------------------------
    // Playback Progress Loop
    // -------------------------------------------------------------------------
    
    // Simple progress display (non-blocking would require platform-specific code)
    bool playing = true;
    auto lastUpdate = std::chrono::steady_clock::now();
    
    while (playing) {
        // Check if still playing
        DWORD state = BASS_ChannelIsActive(stream);
        if (state != BASS_ACTIVE_PLAYING) {
            playing = false;
            break;
        }
        
        // Update progress every second
        auto now = std::chrono::steady_clock::now();
        auto elapsed = std::chrono::duration_cast<std::chrono::milliseconds>(now - lastUpdate);
        
        if (elapsed.count() >= 1000) {
            QWORD posBytes = BASS_ChannelGetPosition(stream, BASS_POS_BYTE);
            double posSeconds = BASS_ChannelBytes2Seconds(stream, posBytes);
            
            std::cout << "\r  Progress: " << formatTime(posSeconds) 
                      << " / " << formatTime(lengthSeconds) << "  " << std::flush;
            
            lastUpdate = now;
        }
        
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        
        // Check for user input (simplified - just play for 10 seconds as demo)
        QWORD posBytes = BASS_ChannelGetPosition(stream, BASS_POS_BYTE);
        double posSeconds = BASS_ChannelBytes2Seconds(stream, posBytes);
        //if (posSeconds >= 10.0) {
        //    logger.info("Demo: Stopping after 10 seconds");
        //    playing = false;
        //}
    }
    
    std::cout << "\n\n";
    
    // -------------------------------------------------------------------------
    // Cleanup
    // -------------------------------------------------------------------------
    
    logger.info("Stopping playback...");
    BASS_ChannelStop(stream);
    BASS_StreamFree(stream);
    
    logger.info("Releasing BASS...");
    BASS_Free();
    
    logger.info("=== MinimalConsole finished ===");
    
    return 0;
}
