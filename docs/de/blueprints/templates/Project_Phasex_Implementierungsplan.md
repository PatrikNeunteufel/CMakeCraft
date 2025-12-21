# MyVisualizer — Implementierungsplan Phase 1

> **Version:** 0.1.0  
> **Datum:** 2025-12-21  
> **Typ:** Guide  
> **Status:** In Entwicklung  
> **Zielgruppe:** Entwickler  
> **Bezug:** MyVisualizer Konzept v0.3.1, CMake Architecture V2  
> **Sprache:** Deutsch  

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Projektstruktur](#3-projektstruktur)
4. [Solution.json](#4-solutionjson)
5. [Implementierungsschritte](#5-implementierungsschritte)
6. [Dateien und Interfaces](#6-dateien-und-interfaces)
7. [Schnellreferenz: Tägliche Checkliste](#schnellreferenz-tägliche-checkliste)
8. [Akzeptanzkriterien](#8-akzeptanzkriterien)
9. [Nächste Schritte](#9-nächste-schritte)

---

## Übersichts-Checkliste

### Schritt 1: Projektgerüst

- [ ] 1.1 Solution.json konfiguriert
- [ ] 1.2 PCH mit Qt-Headern erweitert
- [ ] 1.3 Application.hpp/cpp für Qt angepasst
- [ ] 1.4 MainWindow mit Menüleiste erstellt
- [ ] 1.5 Source.cmake Dateien aktualisiert
- [ ] 1.6 Build erfolgreich, Fenster erscheint

### Schritt 2: Input-Interfaces

- [ ] 2.1 Verzeichnisstruktur input/ angelegt
- [ ] 2.2 IInputSource definiert
- [ ] 2.3 IAudioSource definiert
- [ ] 2.4 IVideoSource Stub erstellt
- [ ] 2.5 ICameraSource Stub erstellt
- [ ] 2.6 Build erfolgreich

### Schritt 3: PlayerEngine

- [ ] 3.1 PlayerEngine Header erstellt
- [ ] 3.2 BassAudioSource Header erstellt
- [ ] 3.3 PlayerEngine Implementation (BASS_Init/Free)
- [ ] 3.4 BassAudioSource Implementation (Play/Pause/Stop/Seek/FFT)
- [ ] 3.5 FFT-Konfiguration implementiert
- [ ] 3.6 Unit Tests geschrieben
- [ ] 3.7 Alle Tests bestehen

### Schritt 4: PlayerPanel

- [ ] 4.1 Verzeichnisstruktur panels/ angelegt
- [ ] 4.2 PlayerPanel Header erstellt
- [ ] 4.3 PlayerPanel Implementation (Buttons, Slider, Labels)
- [ ] 4.4 Styling angewendet
- [ ] 4.5 Icons erstellt/hinzugefügt
- [ ] 4.6 resources.qrc angelegt
- [ ] 4.7 Signale verbunden
- [ ] 4.8 Zeit-Formatierung implementiert
- [ ] 4.9 Panel funktioniert in MainWindow

### Schritt 5: PlaylistPanel

- [ ] 5.1 PlaylistModel implementiert
- [ ] 5.2 PlaylistPanel Header erstellt
- [ ] 5.3 PlaylistPanel Implementation
- [ ] 5.4 Drag & Drop funktioniert
- [ ] 5.5 Kontextmenü implementiert
- [ ] 5.6 Doppelklick löst Play aus
- [ ] 5.7 Metadaten-Extraktion (optional)
- [ ] 5.8 Panel funktioniert in MainWindow

### Schritt 6: Integration

- [ ] 6.1 MainWindow mit allen Panels
- [ ] 6.2 Signal/Slot Verbindungen komplett
- [ ] 6.3 Menü-Aktionen implementiert
- [ ] 6.4 Timer für Position-Update
- [ ] 6.5 Keyboard Shortcuts
- [ ] 6.6 Integration Tests geschrieben
- [ ] 6.7 Manuelle Tests durchgeführt
- [ ] 6.8 Code Review Checkliste erfüllt
- [ ] 6.9 Dokumentation aktualisiert

### Fortschritt

| Schritt | Aufgaben | Erledigt | Status |
|---------|----------|----------|--------|
| 1. Projektgerüst | 6 | 0 | ⬜ Offen |
| 2. Input-Interfaces | 6 | 0 | ⬜ Offen |
| 3. PlayerEngine | 7 | 0 | ⬜ Offen |
| 4. PlayerPanel | 9 | 0 | ⬜ Offen |
| 5. PlaylistPanel | 8 | 0 | ⬜ Offen |
| 6. Integration | 9 | 0 | ⬜ Offen |
| **Gesamt** | **45** | **0** | **0%** |

---

## 1. Übersicht

### 1.1 Phasenziel

**Phase 1: Basisfenster mit Audio-Playback**

Ziel ist ein funktionierender Audio-Player ohne Visualisierung. Die Architektur wird so angelegt, dass zukünftige Erweiterungen (Video, Kamera, KI) nahtlos integrierbar sind.

### 1.2 Lieferumfang

| Komponente | Beschreibung | Priorität |
|------------|--------------|-----------|
| Qt6 MainWindow | Grundfenster mit Menüleiste | P1 |
| PlayerPanel | Play/Pause/Stop, Seek, Volume | P1 |
| PlaylistPanel | Dateiliste, Drag&Drop | P1 |
| PlayerEngine | BASS-Integration | P1 |
| IInputSource | Basis-Interface für alle Input-Typen | P1 |
| IAudioSource | Audio-spezifisches Interface | P1 |
| IVideoSource | Interface-Stub für Phase 12 | P2 |
| ICameraSource | Interface-Stub für Phase 12 | P2 |

### 1.3 Geschätzte Dauer

~1 Woche

---

## 2. Voraussetzungen

### 2.1 Externals (Phase 1)

| External | Typ | Zweck |
|----------|-----|-------|
| Qt6 | System | UI Framework |
| qt-ads | Git | Docking (vorbereitet für Phase 5) |
| bass | Local | Audio-Playback, FFT |
| glad | Local | OpenGL Loader |
| glm | Git | Vektor/Matrix-Mathematik |
| doctest | Local | Unit Tests |

### 2.2 Entwicklungsumgebung

- CMake 3.25+
- Qt6 6.5+ installiert (`QT_ROOT` gesetzt)
- C++20 Compiler (MSVC 2022, Clang 16+, GCC 13+)
- CMake Architecture V2 Build-System

---

## 3. Projektstruktur

### 3.1 Verzeichnisstruktur nach CMake V2 Konvention

```
projects/apps/MyVisualizer/
├── include/
│   ├── Application.hpp          # Hauptanwendung (Template vorhanden)
│   ├── MainWindow.hpp            # Qt MainWindow
│   ├── PlayerEngine.hpp          # BASS-Wrapper
│   ├── input/
│   │   ├── IInputSource.hpp      # Basis-Interface
│   │   ├── IAudioSource.hpp      # Audio-Interface
│   │   ├── IVideoSource.hpp      # Stub für Phase 12
│   │   └── ICameraSource.hpp     # Stub für Phase 12
│   ├── panels/
│   │   ├── PlayerPanel.hpp       # Player-Steuerung
│   │   └── PlaylistPanel.hpp     # Playlist-Widget
│   └── Source.cmake
│
├── src/
│   ├── Application.cpp           # Template erweitern
│   ├── MainWindow.cpp
│   ├── PlayerEngine.cpp
│   ├── input/
│   │   └── BassAudioSource.cpp   # BASS-Implementation
│   ├── panels/
│   │   ├── PlayerPanel.cpp
│   │   └── PlaylistPanel.cpp
│   └── Source.cmake
│
├── main/
│   ├── main.cpp                  # Template vorhanden
│   └── Source.cmake
│
├── pch/
│   └── pch.h                     # Qt + STL Headers
│
├── tests/
│   ├── unit/
│   │   ├── test_PlayerEngine.cpp
│   │   └── test_Playlist.cpp
│   ├── integration/
│   │   └── test_AudioPlayback.cpp
│   └── performance/
│       └── (Phase 1 leer)
│
├── resources/
│   ├── icons/
│   │   ├── play.svg
│   │   ├── pause.svg
│   │   ├── stop.svg
│   │   └── ...
│   └── resources.qrc
│
└── README.md
```

### 3.2 Namespace-Konvention

```cpp
namespace myvis {
    namespace input { /* IInputSource, IAudioSource, ... */ }
    namespace audio { /* PlayerEngine, BassAudioSource */ }
    namespace ui { /* MainWindow, Panels */ }
}
```

---

## 4. Solution.json

### 4.1 Korrigierte Konfiguration

**Wichtige Korrekturen aus dem letzten Chat:**

1. `Qt6` statt `qt6` (alphabetische Sortierung vor `qt-ads`)
2. Keine `options` im externals-Objekt (gehört zum Target)
3. Test-Frameworks sind aktiv für Phase 1

```json
{
    "schemaVersion": "0.6",
    "solution": {
        "name": "Visualizer2026",
        "version": "0.1.0",
        "description": "Modular Audio/Video Visualizer with Qt6, OpenGL",
        "authors": ["Patrik Neunteufel"]
    },
    "settings": {
        "standards": {
            "cxx_standard": 20,
            "cxx_standard_required": true,
            "cxx_extensions": false
        },
        "defaults": {
            "library_type": "STATIC",
            "executable_type": "GUI"
        },
        "sources": {
            "mode": "auto"
        }
    },
    "externals": {
        "Qt6": {
            "system": true,
            "package": "Qt6",
            "components": ["Core", "Widgets", "Gui", "OpenGL", "OpenGLWidgets"],
            "hints": ["${QT_ROOT}"]
        },
        "bass": {
            "path": "externals/bass"
        },
        "doctest": {
            "path": "externals/doctest"
        },
        "glad": {
            "path": "externals/glad"
        },
        "glm": {
            "git": "https://github.com/g-truc/glm.git",
            "tag": "1.0.1"
        },
        "qt-ads": {
            "git": "https://github.com/githubuser0xFFFF/Qt-Advanced-Docking-System.git",
            "tag": "4.3.1"
        }
    },
    "libraries": [],
    "executables": [],
    "apps": [
        {
            "name": "MyVisualizer",
            "displayName": "My Visualizer",
            "version": "0.1.0",
            "path": "projects/apps/MyVisualizer",
            "core": {
                "externals": ["bass", "Qt6", "qt-ads", "glad", "glm"]
            },
            "runner": {
                "type": "GUI",
                "externals": ["Qt6"]
            },
            "pch": {
                "enabled": true
            },
            "tests": {
                "framework": "doctest",
                "targets": [
                    {
                        "name": "UnitTests",
                        "type": "unit"
                    }
                ]
            }
        }
    ],
    "tests": []
}
```

---

## 5. Implementierungsschritte

### Schritt 1: Projektgerüst aufsetzen

**Ziel:** Build-System funktioniert, leeres Fenster erscheint

**Erwartetes Ergebnis:** Leeres Qt-Fenster mit Menüleiste (File → Exit, Help → About)

#### Checkliste Schritt 1

**1.1 Solution.json**

- [ ] schemaVersion auf aktuelle Version prüfen
- [ ] Externals alphabetisch sortiert (Qt6 vor qt-ads)
- [ ] App-Konfiguration korrekt
- [ ] Build mit CMake testen: `cmake --preset <preset>`

**1.2 PCH erweitern**

- [ ] pch/pch.h mit Qt-Headern erweitern
- [ ] STL-Header hinzufügen
- [ ] GLM-Header hinzufügen
- [ ] Kompilierung testen

**1.3 Application.hpp/cpp erweitern**

- [ ] QApplication* in Impl-Struct
- [ ] MainWindow* in Impl-Struct
- [ ] init(): QApplication erstellen
- [ ] init(): MainWindow erstellen und show()
- [ ] run(): return qtApp->exec()
- [ ] shutdown(): Cleanup

**1.4 MainWindow Grundgerüst**

- [ ] include/MainWindow.hpp anlegen
- [ ] src/MainWindow.cpp anlegen
- [ ] Konstruktor: setWindowTitle, resize, setCentralWidget
- [ ] setupMenuBar(): File-Menü (Open, Exit)
- [ ] setupMenuBar(): Help-Menü (About)
- [ ] Slots: onExit(), onAbout()

**1.5 Source.cmake Dateien**

- [ ] include/Source.cmake aktualisieren
- [ ] src/Source.cmake aktualisieren
- [ ] Neue Dateien registriert

**1.6 Build & Test**

- [ ] CMake Configure erfolgreich
- [ ] CMake Build ohne Fehler
- [ ] CMake Build ohne Warnings
- [ ] Anwendung startet
- [ ] Fenster erscheint
- [ ] Menü funktioniert
- [ ] Exit beendet Anwendung

---

### Schritt 2: Input-Interfaces definieren

**Ziel:** Zukunftssichere Abstraktionen für alle Input-Typen

**Design-Prinzip:** Interfaces jetzt vollständig definieren, Stubs werfen `std::runtime_error("Not implemented")`.

#### Checkliste Schritt 2

**2.1 Verzeichnisstruktur**

- [ ] include/input/ Verzeichnis anlegen
- [ ] src/input/ Verzeichnis anlegen

**2.2 IInputSource (Basis-Interface)**

- [ ] include/input/IInputSource.hpp anlegen
- [ ] InputType enum definieren (Audio, Video, Camera, Screen, AI)
- [ ] Virtuelle Methoden: type(), name()
- [ ] Virtuelle Methoden: isAvailable(), isActive()
- [ ] Virtuelle Methoden: activate(), deactivate()
- [ ] Optionale Methoden: hasDuration(), duration(), position()
- [ ] Doxygen-Dokumentation

**2.3 IAudioSource**

- [ ] include/input/IAudioSource.hpp anlegen
- [ ] AudioInfo struct definieren
- [ ] Erbt von IInputSource
- [ ] Methoden: loadFile(), play(), pause(), stop()
- [ ] Methoden: seek(), setVolume(), volume()
- [ ] Methoden: isPlaying(), isPaused()
- [ ] Methoden: getFFT(), getWaveform()
- [ ] Doxygen-Dokumentation

**2.4 IVideoSource (Stub für Phase 12)**

- [ ] include/input/IVideoSource.hpp anlegen
- [ ] VideoInfo struct definieren
- [ ] Erbt von IInputSource
- [ ] Stub-Methoden mit notImplemented()
- [ ] Kommentar: "Phase 12 Implementation"

**2.5 ICameraSource (Stub für Phase 12)**

- [ ] include/input/ICameraSource.hpp anlegen
- [ ] CameraInfo struct definieren
- [ ] Erbt von IInputSource
- [ ] Stub-Methoden mit notImplemented()
- [ ] Kommentar: "Phase 12 Implementation"

**2.6 Source.cmake aktualisieren**

- [ ] Neue Header in include/Source.cmake
- [ ] Build testen

---

### Schritt 3: PlayerEngine implementieren

**Ziel:** BASS-Integration für Audio-Playback

#### Checkliste Schritt 3

**3.1 PlayerEngine Header**

- [ ] include/PlayerEngine.hpp anlegen
- [ ] Singleton oder Instanz-basiert? → Instanz
- [ ] Pimpl-Pattern für BASS-Details
- [ ] Signale für Status-Änderungen (Qt oder Callback)
- [ ] Doxygen-Dokumentation

**3.2 BassAudioSource Header**

- [ ] include/input/BassAudioSource.hpp anlegen
- [ ] Implementiert IAudioSource
- [ ] BASS-spezifische Member im Pimpl

**3.3 PlayerEngine Implementation**

- [ ] src/PlayerEngine.cpp anlegen
- [ ] BASS_Init() im Konstruktor
- [ ] BASS_Free() im Destruktor
- [ ] Error Handling für BASS-Fehler

**3.4 BassAudioSource Implementation**

- [ ] src/input/BassAudioSource.cpp anlegen
- [ ] loadFile(): BASS_StreamCreateFile()
- [ ] play(): BASS_ChannelPlay()
- [ ] pause(): BASS_ChannelPause()
- [ ] stop(): BASS_ChannelStop() + seek(0)
- [ ] seek(): BASS_ChannelSetPosition()
- [ ] setVolume(): BASS_ChannelSetAttribute()
- [ ] getFFT(): BASS_ChannelGetData(BASS_DATA_FFT)
- [ ] getWaveform(): BASS_ChannelGetData()
- [ ] duration(): BASS_ChannelBytes2Seconds()
- [ ] position(): BASS_ChannelGetPosition()

**3.5 FFT-Konfiguration**

- [ ] FFT-Größe konfigurierbar (512, 1024, 2048, 4096)
- [ ] FFT-Buffer allokiert
- [ ] Windowing-Funktion (Hann, optional)

**3.6 Unit Tests**

- [ ] tests/unit/test_PlayerEngine.cpp anlegen
- [ ] Test: Engine initialisiert korrekt
- [ ] Test: Datei laden (gültig)
- [ ] Test: Datei laden (ungültig) → Fehler
- [ ] Test: Play/Pause/Stop Zustandsübergänge
- [ ] Test: Seek innerhalb Duration
- [ ] Test: Seek außerhalb Duration → Clamp
- [ ] Test: Volume 0.0 - 1.0
- [ ] Test: FFT-Daten nicht leer nach Play

**3.7 Build & Test**

- [ ] Kompiliert ohne Fehler
- [ ] Kompiliert ohne Warnings
- [ ] Unit Tests bestehen

---

### Schritt 4: PlayerPanel UI

**Ziel:** Steuerelemente für Playback

#### Checkliste Schritt 4

**4.1 Verzeichnisstruktur**

- [ ] include/panels/ Verzeichnis anlegen
- [ ] src/panels/ Verzeichnis anlegen

**4.2 PlayerPanel Header**

- [ ] include/panels/PlayerPanel.hpp anlegen
- [ ] Q_OBJECT Makro
- [ ] Signals: playRequested(), pauseRequested(), stopRequested()
- [ ] Signals: seekRequested(ms), volumeChanged(float)
- [ ] Slots: onPlaybackStateChanged(), onPositionChanged()
- [ ] Slots: onDurationChanged()

**4.3 PlayerPanel Implementation**

- [ ] src/panels/PlayerPanel.cpp anlegen
- [ ] Layout: QHBoxLayout für Buttons
- [ ] Layout: QVBoxLayout für Gesamt
- [ ] Play/Pause QPushButton (Toggle-Icon)
- [ ] Stop QPushButton
- [ ] Seek QSlider (horizontal)
- [ ] Position QLabel ("00:00 / 00:00")
- [ ] Volume QSlider (horizontal, kleiner)
- [ ] Volume Icon/Label

**4.4 Styling**

- [ ] Buttons: setIconSize()
- [ ] Slider: setRange(), setTickInterval()
- [ ] Tooltips für alle Elemente

**4.5 Icons**

- [ ] resources/icons/ Verzeichnis anlegen
- [ ] play.svg (oder .png)
- [ ] pause.svg
- [ ] stop.svg
- [ ] volume.svg (optional: volume-mute, volume-low, volume-high)

**4.6 Qt Resource File**

- [ ] resources/resources.qrc anlegen
- [ ] Icons registrieren
- [ ] In CMake einbinden (qt_add_resources)

**4.7 Signale verbinden**

- [ ] Button clicked → Signal emit
- [ ] Slider valueChanged → Signal emit
- [ ] Slots für externe Updates

**4.8 Zeit-Formatierung**

- [ ] Helper: formatTime(ms) → "MM:SS"
- [ ] Bei Duration > 1h: "HH:MM:SS"

**4.9 Build & Test**

- [ ] Kompiliert ohne Fehler
- [ ] Panel erscheint in MainWindow
- [ ] Buttons reagieren
- [ ] Slider bewegt sich

---

### Schritt 5: PlaylistPanel UI

**Ziel:** Dateiverwaltung mit Drag&Drop

#### Checkliste Schritt 5

**5.1 PlaylistModel**

- [ ] include/PlaylistModel.hpp anlegen
- [ ] Erbt von QAbstractListModel
- [ ] Struct PlaylistItem { path, title, duration, artist }
- [ ] rowCount(), data(), roleNames()
- [ ] addItem(), removeItem(), clear()
- [ ] moveItem() für Drag&Drop Reorder

**5.2 PlaylistPanel Header**

- [ ] include/panels/PlaylistPanel.hpp anlegen
- [ ] Q_OBJECT Makro
- [ ] Signals: itemDoubleClicked(index), itemsAdded()
- [ ] Slots: onAddFiles(), onRemoveSelected(), onClear()

**5.3 PlaylistPanel Implementation**

- [ ] src/panels/PlaylistPanel.cpp anlegen
- [ ] QListView mit PlaylistModel
- [ ] setAcceptDrops(true)
- [ ] setDragEnabled(true)
- [ ] setDefaultDropAction(Qt::MoveAction)

**5.4 Drag & Drop**

- [ ] dragEnterEvent(): Accept audio files
- [ ] dropEvent(): Dateien zur Playlist hinzufügen
- [ ] Supported MIME types: audio/*, application/octet-stream
- [ ] Filter: .mp3, .flac, .wav, .ogg, .m4a, .aac

**5.5 Kontextmenü**

- [ ] contextMenuEvent() überschreiben
- [ ] Aktion: "Entfernen"
- [ ] Aktion: "Playlist leeren"
- [ ] Aktion: "Im Explorer öffnen" (optional)

**5.6 Doppelklick**

- [ ] doubleClicked Signal verbinden
- [ ] itemDoubleClicked(index) emittieren

**5.7 Metadaten (optional, kann später)**

- [ ] BASS_TAG_OGG, BASS_TAG_ID3V2 für Titel/Artist
- [ ] Duration aus BASS_ChannelGetLength()
- [ ] Async laden für große Playlists

**5.8 Build & Test**

- [ ] Kompiliert ohne Fehler
- [ ] Panel erscheint in MainWindow
- [ ] Drag&Drop funktioniert
- [ ] Doppelklick löst Signal aus
- [ ] Kontextmenü erscheint

---

### Schritt 6: Integration und Tests

**Ziel:** Alles zusammenführen, Tests schreiben

#### Checkliste Schritt 6

**6.1 MainWindow Integration**

- [ ] PlayerPanel als Member
- [ ] PlaylistPanel als Member
- [ ] PlayerEngine als Member (oder Singleton)
- [ ] Layout: Splitter oder Docking vorbereiten

**6.2 Signal/Slot Verbindungen**

- [ ] PlaylistPanel::itemDoubleClicked → PlayerEngine::loadFile + play
- [ ] PlayerPanel::playRequested → PlayerEngine::play
- [ ] PlayerPanel::pauseRequested → PlayerEngine::pause
- [ ] PlayerPanel::stopRequested → PlayerEngine::stop
- [ ] PlayerPanel::seekRequested → PlayerEngine::seek
- [ ] PlayerPanel::volumeChanged → PlayerEngine::setVolume
- [ ] PlayerEngine::positionChanged → PlayerPanel::onPositionChanged
- [ ] PlayerEngine::stateChanged → PlayerPanel::onPlaybackStateChanged

**6.3 Menü-Aktionen**

- [ ] File → Open File: QFileDialog → PlaylistPanel::addItem
- [ ] File → Open Folder: QFileDialog::getExistingDirectory
- [ ] File → Exit: QApplication::quit()
- [ ] Help → About: QMessageBox mit Version

**6.4 Timer für Position-Update**

- [ ] QTimer mit 100ms Intervall
- [ ] Positionsabfrage und UI-Update
- [ ] Timer starten bei Play, stoppen bei Stop

**6.5 Keyboard Shortcuts**

- [ ] Space: Play/Pause Toggle
- [ ] Ctrl+O: Open File
- [ ] Ctrl+Q: Exit (optional)

**6.6 Integration Tests**

- [ ] tests/integration/test_AudioPlayback.cpp anlegen
- [ ] Test: Datei laden und abspielen
- [ ] Test: Playback pausieren und fortsetzen
- [ ] Test: Seek während Playback
- [ ] Test: Volume ändern
- [ ] Test: Mehrere Dateien nacheinander

**6.7 Manuelle Tests**

- [ ] Verschiedene Audio-Formate testen (MP3, FLAC, WAV, OGG)
- [ ] Große Dateien (>1h) testen
- [ ] Korrupte Dateien testen → Fehlermeldung
- [ ] Drag&Drop von mehreren Dateien
- [ ] Drag&Drop von Ordnern

**6.8 Code Review Checkliste**

- [ ] Keine Memory Leaks (Smart Pointers überall)
- [ ] Keine raw new/delete
- [ ] Alle Signale disconnected bei Destruktor?
- [ ] Error Handling konsistent
- [ ] Logging für Debug-Builds

**6.9 Dokumentation**

- [ ] README.md aktualisieren
- [ ] Build-Anleitung
- [ ] Bekannte Einschränkungen

---

### Phase 1 Gesamtfortschritt

| Schritt | Beschreibung | Unteraufgaben | Status |
|---------|--------------|---------------|--------|
| 1 | Projektgerüst | 7 | ⬜ |
| 2 | Input-Interfaces | 6 | ⬜ |
| 3 | PlayerEngine | 7 | ⬜ |
| 4 | PlayerPanel | 9 | ⬜ |
| 5 | PlaylistPanel | 8 | ⬜ |
| 6 | Integration | 9 | ⬜ |
| **Σ** | **Gesamt** | **46** | **0%** |

---

## 6. Dateien und Interfaces

### 6.1 IInputSource (Basis-Interface)

```cpp
// include/input/IInputSource.hpp
#pragma once

#include <string>
#include <chrono>

namespace myvis::input {

enum class InputType {
    Audio,
    Video,
    Camera,
    Screen,
    AI
};

class IInputSource {
public:
    virtual ~IInputSource() = default;
    
    // Identifikation
    [[nodiscard]] virtual InputType type() const noexcept = 0;
    [[nodiscard]] virtual std::string name() const = 0;
    
    // Lifecycle
    [[nodiscard]] virtual bool isAvailable() const noexcept = 0;
    [[nodiscard]] virtual bool isActive() const noexcept = 0;
    virtual bool activate() = 0;
    virtual void deactivate() = 0;
    
    // Timing (optional, nicht alle Sources haben Duration)
    [[nodiscard]] virtual bool hasDuration() const noexcept { return false; }
    [[nodiscard]] virtual std::chrono::milliseconds duration() const { return {}; }
    [[nodiscard]] virtual std::chrono::milliseconds position() const { return {}; }
};

} // namespace myvis::input
```

### 6.2 IAudioSource

```cpp
// include/input/IAudioSource.hpp
#pragma once

#include "IInputSource.hpp"
#include <span>
#include <filesystem>

namespace myvis::input {

struct AudioInfo {
    int sampleRate{44100};
    int channels{2};
    int bitDepth{16};
    std::chrono::milliseconds duration{};
};

class IAudioSource : public IInputSource {
public:
    [[nodiscard]] InputType type() const noexcept override { return InputType::Audio; }
    
    // Audio-spezifisch
    [[nodiscard]] virtual AudioInfo info() const = 0;
    
    // Playback
    virtual bool loadFile(const std::filesystem::path& path) = 0;
    virtual bool play() = 0;
    virtual bool pause() = 0;
    virtual bool stop() = 0;
    virtual bool seek(std::chrono::milliseconds position) = 0;
    virtual void setVolume(float level) = 0;  // 0.0 - 1.0
    [[nodiscard]] virtual float volume() const noexcept = 0;
    [[nodiscard]] virtual bool isPlaying() const noexcept = 0;
    [[nodiscard]] virtual bool isPaused() const noexcept = 0;
    
    // FFT-Daten (für Visualisierung)
    [[nodiscard]] virtual std::span<const float> getFFT() const = 0;
    [[nodiscard]] virtual std::span<const float> getWaveform() const = 0;
    
    // Convenience
    [[nodiscard]] bool hasDuration() const noexcept override { return true; }
};

} // namespace myvis::input
```

### 6.3 IVideoSource (Stub)

```cpp
// include/input/IVideoSource.hpp
#pragma once

#include "IInputSource.hpp"
#include <stdexcept>

namespace myvis::input {

struct VideoInfo {
    int width{0};
    int height{0};
    float fps{0.0f};
    std::chrono::milliseconds duration{};
};

class IVideoSource : public IInputSource {
public:
    [[nodiscard]] InputType type() const noexcept override { return InputType::Video; }
    
    [[nodiscard]] virtual VideoInfo info() const = 0;
    [[nodiscard]] virtual uint32_t textureId() const = 0;  // OpenGL Texture
    
    // Phase 12 Implementation
    // Stub-Methoden werfen Exception
protected:
    [[noreturn]] static void notImplemented() {
        throw std::runtime_error("VideoSource not implemented (Phase 12)");
    }
};

} // namespace myvis::input
```

### 6.4 MainWindow Grundgerüst

```cpp
// include/MainWindow.hpp
#pragma once

#include <QMainWindow>
#include <memory>

namespace myvis::ui {

class PlayerPanel;
class PlaylistPanel;

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    explicit MainWindow(QWidget* parent = nullptr);
    ~MainWindow() override;

private slots:
    void onOpenFile();
    void onOpenFolder();
    void onExit();
    void onAbout();

private:
    void setupMenuBar();
    void setupPanels();
    void setupConnections();

    std::unique_ptr<PlayerPanel> m_playerPanel;
    std::unique_ptr<PlaylistPanel> m_playlistPanel;
};

} // namespace myvis::ui
```

### 6.5 PCH Erweiterung

```cpp
// pch/pch.h
#pragma once

// ============================================================================
// Standard Library
// ============================================================================
#include <algorithm>
#include <chrono>
#include <filesystem>
#include <functional>
#include <memory>
#include <optional>
#include <span>
#include <string>
#include <string_view>
#include <vector>

// ============================================================================
// Qt (Phase 1)
// ============================================================================
#include <QApplication>
#include <QMainWindow>
#include <QWidget>
#include <QMenuBar>
#include <QMenu>
#include <QAction>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QPushButton>
#include <QSlider>
#include <QLabel>
#include <QListView>
#include <QFileDialog>
#include <QMessageBox>
#include <QDragEnterEvent>
#include <QDropEvent>
#include <QMimeData>
#include <QUrl>

// ============================================================================
// GLM
// ============================================================================
#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>
```

---

---

## Schnellreferenz: Tägliche Checkliste

### Vor dem Arbeiten

- [ ] Git Pull (falls Teamarbeit)
- [ ] Aktuellen Schritt identifiziert
- [ ] Offene Aufgaben aus Checkliste gelesen

### Während der Arbeit

- [ ] Build nach jeder größeren Änderung
- [ ] Keine neuen Warnings eingeführt
- [ ] Tests laufen durch
- [ ] Aufgaben in Checkliste abhaken

### Nach dem Arbeiten

- [ ] Alle Änderungen kompilieren
- [ ] Unit Tests bestehen
- [ ] Git Commit mit aussagekräftiger Message
- [ ] Fortschritt in Gesamtübersicht aktualisiert
- [ ] Nächste Aufgaben identifiziert

### Notizen

_Hier Platz für tägliche Notizen..._

---

## 8. Akzeptanzkriterien

### 8.1 Funktionale Anforderungen

| # | Kriterium | Testmethode |
|---|-----------|-------------|
| A1 | Anwendung startet ohne Fehler | Manuell |
| A2 | Menü File → Open File öffnet Dateidialog | Manuell |
| A3 | Audio-Datei kann geladen werden | Unit Test |
| A4 | Play/Pause funktioniert | Manuell |
| A5 | Stop setzt Position auf 0 | Unit Test |
| A6 | Seek-Slider ändert Position | Manuell |
| A7 | Volume-Slider ändert Lautstärke | Manuell |
| A8 | Drag&Drop von Dateien in Playlist | Manuell |
| A9 | Doppelklick in Playlist startet Playback | Manuell |
| A10 | FFT-Daten sind abrufbar (für Phase 2) | Unit Test |

### 8.2 Nicht-funktionale Anforderungen

| # | Kriterium | Testmethode |
|---|-----------|-------------|
| N1 | Build ohne Warnings (W4/Wall) | CI |
| N2 | Alle Unit Tests bestehen | CI |
| N3 | Keine Memory Leaks | Valgrind/ASAN |
| N4 | Code folgt Naming-Konventionen | Code Review |
| N5 | Interfaces sind dokumentiert | Code Review |

---

## 9. Nächste Schritte

### 9.1 Nach Phase 1

Phase 2 baut direkt auf Phase 1 auf:

| Komponente | Abhängigkeit von Phase 1 |
|------------|-------------------------|
| VisualizerWidget | MainWindow |
| ShaderManager | — |
| VisualizerContext | IAudioSource::getFFT() |

### 9.2 Offene Punkte

| # | Thema | Entscheidung nötig |
|---|-------|-------------------|
| 1 | Icon-Set | Welches Design? (Fluent, Material, Custom) |
| 2 | Qt-ADS | Bereits in Phase 1 integrieren oder Phase 5? |
| 3 | Error Handling | Eigene Exception-Hierarchie oder std::expected? |

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| 0.1.0 | 2025-12-21 | Initial: Phase 1 Implementierungsplan |
