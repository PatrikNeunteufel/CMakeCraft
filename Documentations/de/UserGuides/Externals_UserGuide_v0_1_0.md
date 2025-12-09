# Externals UserGuide – CMake Architecture V2

> **Version:** 0.1.0  
> **Datum:** 2025-12-09  
> **Typ:** Benutzer-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Sprache:** Deutsch

Dieser Guide erklärt, wie externe Bibliotheken in Projekten verwendet werden.

---

## 1. Schnellstart

### 1.1 External zum Projekt hinzufügen

**Schritt 1:** External in Solution.json definieren

```json
{
    "externals": {
        "bass": { "path": "externals/bass" }
    }
}
```

**Schritt 2:** In Executable verwenden

```json
{
    "executables": [
        {
            "name": "MyApp",
            "externals": ["bass"]
        }
    ]
}
```

**Schritt 3:** In C++ einbinden

```cpp
#include <bass.h>

int main() {
    BASS_Init(-1, 44100, 0, nullptr, nullptr);
    // ...
    BASS_Free();
}
```

Das war's! CMake kümmert sich um:
- Include-Pfade
- Library-Linking
- DLL-Kopieren (Windows)

---

## 2. BASS Audio Library

### 2.1 Grundlegende Audio-Wiedergabe

**Solution.json:**
```json
{
    "externals": {
        "bass": { "path": "externals/bass" }
    },
    "executables": [
        {
            "name": "SimplePlayer",
            "externals": ["bass"]
        }
    ]
}
```

**main.cpp:**
```cpp
#include <bass.h>
#include <iostream>

int main() {
    // BASS initialisieren
    if (!BASS_Init(-1, 44100, 0, nullptr, nullptr)) {
        std::cerr << "BASS_Init failed!" << std::endl;
        return 1;
    }
    
    // Stream aus Datei erstellen
    HSTREAM stream = BASS_StreamCreateFile(
        FALSE,          // Nicht aus Speicher
        "music.mp3",    // Datei
        0, 0,           // Offset, Länge
        0               // Flags
    );
    
    if (stream == 0) {
        std::cerr << "Could not load file!" << std::endl;
        BASS_Free();
        return 1;
    }
    
    // Abspielen
    BASS_ChannelPlay(stream, FALSE);
    
    std::cout << "Playing... Press Enter to stop." << std::endl;
    std::cin.get();
    
    // Aufräumen
    BASS_StreamFree(stream);
    BASS_Free();
    
    return 0;
}
```

### 2.2 FLAC-Dateien abspielen

Um FLAC-Dateien abzuspielen, aktiviere das FLAC-Plugin:

**Solution.json:**
```json
{
    "executables": [
        {
            "name": "FlacPlayer",
            "externals": ["bass"],
            "external_options": {
                "bass": {
                    "BASS_FLAC": true
                }
            }
        }
    ]
}
```

**main.cpp:**
```cpp
#include <bass.h>
#include <bassflac.h>  // Jetzt verfügbar!

// FLAC wird automatisch erkannt
HSTREAM stream = BASS_StreamCreateFile(FALSE, "music.flac", 0, 0, 0);
```

### 2.3 Audio-Effekte mit BASS_FX

**Solution.json:**
```json
{
    "external_options": {
        "bass": {
            "BASS_FX": true
        }
    }
}
```

**main.cpp:**
```cpp
#include <bass.h>
#include <bass_fx.h>

// Original-Stream laden
HSTREAM original = BASS_StreamCreateFile(FALSE, "music.mp3", 0, 0, BASS_STREAM_DECODE);

// Tempo-Stream erstellen (ermöglicht Tempo/Pitch-Änderung)
HSTREAM tempoStream = BASS_FX_TempoCreate(original, BASS_FX_FREESOURCE);

// Tempo ändern: -20% langsamer
BASS_ChannelSetAttribute(tempoStream, BASS_ATTRIB_TEMPO, -20.0f);

// Pitch ändern: 3 Halbtöne höher
BASS_ChannelSetAttribute(tempoStream, BASS_ATTRIB_TEMPO_PITCH, 3.0f);

BASS_ChannelPlay(tempoStream, FALSE);
```

### 2.4 Multi-Track Mixing mit BASS_MIX

**Solution.json:**
```json
{
    "external_options": {
        "bass": {
            "BASS_MIX": true
        }
    }
}
```

**main.cpp:**
```cpp
#include <bass.h>
#include <bassmix.h>

// Mixer erstellen
HSTREAM mixer = BASS_Mixer_StreamCreate(44100, 2, BASS_SAMPLE_FLOAT);

// Tracks laden (als Decode-Streams)
HSTREAM track1 = BASS_StreamCreateFile(FALSE, "drums.wav", 0, 0, BASS_STREAM_DECODE);
HSTREAM track2 = BASS_StreamCreateFile(FALSE, "bass.wav", 0, 0, BASS_STREAM_DECODE);
HSTREAM track3 = BASS_StreamCreateFile(FALSE, "vocals.wav", 0, 0, BASS_STREAM_DECODE);

// Tracks zum Mixer hinzufügen
BASS_Mixer_StreamAddChannel(mixer, track1, 0);
BASS_Mixer_StreamAddChannel(mixer, track2, 0);
BASS_Mixer_StreamAddChannel(mixer, track3, 0);

// Lautstärke einzelner Tracks anpassen
BASS_ChannelSetAttribute(track3, BASS_ATTRIB_VOL, 0.8f);  // Vocals leiser

// Mixer abspielen
BASS_ChannelPlay(mixer, FALSE);
```

---

## 3. Lua 5.4 Scripting

### 3.1 Lua einbetten

**Solution.json:**
```json
{
    "externals": {
        "lua54": { "path": "externals/lua54" }
    },
    "executables": [
        {
            "name": "ScriptHost",
            "externals": ["lua54"]
        }
    ]
}
```

**main.cpp:**
```cpp
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <iostream>

int main() {
    // Lua-State erstellen
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);  // Standardbibliotheken laden
    
    // Lua-Code ausführen
    if (luaL_dostring(L, "print('Hello from Lua!')") != LUA_OK) {
        std::cerr << "Lua error: " << lua_tostring(L, -1) << std::endl;
        lua_pop(L, 1);
    }
    
    // Aufräumen
    lua_close(L);
    return 0;
}
```

### 3.2 Lua-Skript aus Datei laden

**config.lua:**
```lua
-- Spielkonfiguration
config = {
    window = {
        width = 1920,
        height = 1080,
        fullscreen = false
    },
    audio = {
        volume = 0.8,
        music_enabled = true
    }
}
```

**main.cpp:**
```cpp
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

struct Config {
    int width, height;
    bool fullscreen;
    float volume;
};

Config loadConfig(const char* filename) {
    Config cfg = {};
    
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    
    if (luaL_dofile(L, filename) == LUA_OK) {
        lua_getglobal(L, "config");
        
        lua_getfield(L, -1, "window");
        lua_getfield(L, -1, "width");
        cfg.width = lua_tointeger(L, -1);
        lua_pop(L, 1);
        
        lua_getfield(L, -1, "height");
        cfg.height = lua_tointeger(L, -1);
        lua_pop(L, 1);
        
        lua_getfield(L, -1, "fullscreen");
        cfg.fullscreen = lua_toboolean(L, -1);
        lua_pop(L, 2);  // fullscreen + window table
        
        lua_getfield(L, -1, "audio");
        lua_getfield(L, -1, "volume");
        cfg.volume = lua_tonumber(L, -1);
        lua_pop(L, 3);  // volume + audio table + config table
    }
    
    lua_close(L);
    return cfg;
}

int main() {
    Config cfg = loadConfig("config.lua");
    printf("Window: %dx%d, Volume: %.1f\n", cfg.width, cfg.height, cfg.volume);
    return 0;
}
```

### 3.3 C++-Funktionen für Lua bereitstellen

**main.cpp:**
```cpp
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <cmath>

// C-Funktion die von Lua aufgerufen werden kann
int lua_calculate_distance(lua_State* L) {
    double x1 = luaL_checknumber(L, 1);
    double y1 = luaL_checknumber(L, 2);
    double x2 = luaL_checknumber(L, 3);
    double y2 = luaL_checknumber(L, 4);
    
    double distance = std::sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
    
    lua_pushnumber(L, distance);
    return 1;  // Anzahl Rückgabewerte
}

int main() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    
    // Funktion registrieren
    lua_register(L, "distance", lua_calculate_distance);
    
    // In Lua verwenden
    luaL_dostring(L, R"(
        local d = distance(0, 0, 3, 4)
        print("Distance: " .. d)  -- Ausgabe: Distance: 5.0
    )");
    
    lua_close(L);
    return 0;
}
```

---

## 4. doctest Testing

### 4.1 Einfache Tests schreiben

**Solution.json:**
```json
{
    "externals": {
        "doctest": { "path": "externals/doctest" }
    },
    "executables": [
        {
            "name": "MyTests",
            "externals": ["doctest"]
        }
    ]
}
```

**test_main.cpp:**
```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.h>

TEST_CASE("Addition") {
    CHECK(1 + 1 == 2);
    CHECK(2 + 2 == 4);
}

TEST_CASE("String operations") {
    std::string s = "Hello";
    
    SUBCASE("append") {
        s += " World";
        CHECK(s == "Hello World");
    }
    
    SUBCASE("length") {
        CHECK(s.length() == 5);
    }
}
```

### 4.2 Eigene Klassen testen

**math_utils.h:**
```cpp
#pragma once

class Calculator {
public:
    int add(int a, int b) { return a + b; }
    int multiply(int a, int b) { return a * b; }
    double divide(double a, double b) {
        if (b == 0) throw std::invalid_argument("Division by zero");
        return a / b;
    }
};
```

**test_calculator.cpp:**
```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.h>
#include "math_utils.h"

TEST_CASE("Calculator") {
    Calculator calc;
    
    SUBCASE("add") {
        CHECK(calc.add(2, 3) == 5);
        CHECK(calc.add(-1, 1) == 0);
    }
    
    SUBCASE("multiply") {
        CHECK(calc.multiply(3, 4) == 12);
        CHECK(calc.multiply(0, 100) == 0);
    }
    
    SUBCASE("divide") {
        CHECK(calc.divide(10, 2) == doctest::Approx(5.0));
        CHECK_THROWS_AS(calc.divide(1, 0), std::invalid_argument);
    }
}
```

### 4.3 Tests mit eigenem main()

Wenn du vor/nach Tests eigenen Code ausführen willst:

```cpp
#define DOCTEST_CONFIG_IMPLEMENT
#include <doctest.h>

int main(int argc, char** argv) {
    // Setup
    std::cout << "Initializing test environment..." << std::endl;
    
    doctest::Context context;
    context.applyCommandLine(argc, argv);
    
    int res = context.run();
    
    // Cleanup
    std::cout << "Cleaning up..." << std::endl;
    
    if (context.shouldExit()) {
        return res;
    }
    
    return res;
}

TEST_CASE("My test") {
    CHECK(true);
}
```

---

## 5. Mehrere Externals kombinieren

### Beispiel: Audio-Player mit Lua-Scripting und Tests

**Solution.json:**
```json
{
    "externals": {
        "bass": { "path": "externals/bass" },
        "lua54": { "path": "externals/lua54" },
        "doctest": { "path": "externals/doctest" }
    },
    "executables": [
        {
            "name": "AudioPlayer",
            "externals": ["bass", "lua54"],
            "external_options": {
                "bass": {
                    "BASS_FLAC": true,
                    "BASS_FX": true
                }
            }
        },
        {
            "name": "AudioPlayerTests",
            "externals": ["doctest"],
            "dependencies": ["AudioPlayerLib"]
        }
    ],
    "libraries": [
        {
            "name": "AudioPlayerLib",
            "type": "STATIC",
            "externals": ["bass", "lua54"]
        }
    ]
}
```

---

## 6. Tipps & Best Practices

### 6.1 Externals zentral definieren

Definiere alle Externals einmal im `externals`-Block und referenziere sie nur per Name:

```json
{
    "externals": {
        "bass": { "path": "externals/bass" },
        "lua54": { "path": "externals/lua54" }
    },
    "executables": [
        { "name": "App1", "externals": ["bass"] },
        { "name": "App2", "externals": ["bass", "lua54"] }
    ]
}
```

### 6.2 Options nur wo nötig

Aktiviere nur die Plugins die du brauchst:

```json
// ❌ Schlecht: Alles aktivieren
"external_options": {
    "bass": {
        "BASS_FLAC": true,
        "BASS_OPUS": true,
        "BASS_DSD": true,
        "BASS_WV": true,
        "BASS_FX": true,
        "BASS_MIX": true
        // ... etc
    }
}

// ✅ Gut: Nur was gebraucht wird
"external_options": {
    "bass": {
        "BASS_FLAC": true
    }
}
```

### 6.3 Fehlermeldungen verstehen

| Fehler | Bedeutung | Lösung |
|--------|-----------|--------|
| `Include.cmake not found` | External nicht installiert | Prüfe Pfad in Solution.json |
| `DLL not found` | DLL fehlt im Output | Neu bauen, DLL wird kopiert |
| `Header not found` | Option nicht aktiviert | Option in external_options setzen |

---

## 7. Siehe auch

- [Externals Reference](../References/Externals_v0_1_1.md) – Vollständige Options-Referenz
- [BASS Website](https://www.un4seen.com/) – BASS Dokumentation
- [Lua Manual](https://www.lua.org/manual/5.4/) – Lua Referenz
- [doctest GitHub](https://github.com/doctest/doctest) – doctest Dokumentation

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-09** | **Initial: Guides für BASS, Lua, doctest** |
