# Phase 5: Lokale Externals — Implementierung

## Übersicht

Phase 5 implementiert die Pipeline für lokale externe Abhängigkeiten.
Externals werden aus dem `externals/` Verzeichnis geladen via `Include.cmake`.

## Neue Dateien

### CMake Module

| Datei | Ziel | Beschreibung |
|-------|------|--------------|
| `Externals.cmake` | `cmake/project/` | Hauptschleife über Externals |
| `Orchestrator.cmake` | `cmake/externals/` | Typ-Dispatch (local/fetched) |
| `Attach.cmake` | `cmake/externals/Local/` | Handler für lokale Externals |

### BASS External

| Datei | Ziel | Beschreibung |
|-------|------|--------------|
| `Include.cmake` | `externals/bass/` | BASS Integration |
| `Include_cmake_v0_1_0_doc_v1.md` | `externals/bass/` | Dokumentation |

### Aktualisierte Module

| Datei | Ziel | Änderung |
|-------|------|----------|
| `ExecutableCreate.cmake` | `cmake/project/` | v0.1.1 - Externals via apply_external_to_target() |
| `CMakeLists.txt` | `./` | v0.1.2 - Externals.cmake eingebunden |

### Tests & Config

| Datei | Ziel |
|-------|------|
| `phase5.cmake` | `cmake/buildSystemTest/` |
| `Solution.json` | `./` |
| `main.cpp` | `projects/exec/MinimalConsole/src/` |

### Dokumentation

| Datei | Beschreibung |
|-------|--------------|
| `Externals_cmake_v0_1_0_doc_v1.md` | Externals.cmake Doku |
| `Orchestrator_cmake_v0_1_0_doc_v1.md` | Orchestrator.cmake Doku |

---

## Installation

### 1. Verzeichnisse erstellen

```bash
mkdir -p cmake/externals/Local
mkdir -p externals/bass
```

### 2. CMake Module kopieren

```bash
# Neue Module
cp cmake/project/Externals.cmake cmake/project/
cp cmake/externals/Orchestrator.cmake cmake/externals/
cp cmake/externals/Local/Attach.cmake cmake/externals/Local/

# Aktualisierte Module
cp cmake/project/ExecutableCreate.cmake cmake/project/  # ERSETZEN (v0.1.0 → v0.1.1)
cp CMakeLists.txt ./  # ERSETZEN (v0.1.1 → v0.1.2)
```

### 3. BASS External

```bash
# Include.cmake (neu)
cp externals/bass/Include.cmake externals/bass/

# WICHTIG: BASS Library muss bereits vorhanden sein!
# Struktur: externals/bass/bass24/win/c/bass.lib etc.
```

### 4. MinimalConsole aktualisieren

```bash
cp main.cpp projects/exec/MinimalConsole/src/
cp Solution.json ./
```

### 5. Tests

```bash
cp cmake/buildSystemTest/phase5.cmake cmake/buildSystemTest/
```

---

## Solution.json Änderungen

```json
{
    "externals": {
        "bass": {
            "path": "externals/bass"
        }
    },
    "executables": [
        {
            "name": "MinimalConsole",
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

---

## Wichtige Hinweise

### Reihenfolge in CMakeLists.txt

```cmake
# Phase 5: Externals (MUSS zuerst!)
include(cmake/project/Externals.cmake)

# Phase 4: Libraries
include(cmake/project/Libraries.cmake)

# Phase 3: Executables
include(cmake/project/Executables.cmake)
```

### BASS Library Voraussetzung

Die BASS Library muss bereits unter `externals/bass/` vorhanden sein:

```
externals/bass/
├── Include.cmake
├── bass24/
│   ├── win/
│   │   ├── c/
│   │   │   ├── bass.h
│   │   │   └── bass.lib
│   │   └── x64/
│   │       └── bass.dll
│   └── ...
├── bassflac24/  (für BASS_FLAC)
└── ...
```

### Musik-Datei

Die Demo erwartet eine MP3-Datei unter:
```
../../music/London Grammar - Californian Soil/02 Californian Soil.mp3
```
(Relativ zum Projekt-Root)

---

## Testen

```bash
# Konfigurieren
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=ON

# Bauen
cmake --build build

# Ausführen
./build/exec/MinimalConsole/bin/Debug/MinimalConsole
```

### Erwartete Ausgabe

```
-- [Externals] === Externals Pipeline Start ===
-- [Externals] Processing 1 external(s)...
-- [Externals] --- Processing: bass ---
-- [Externals]   Type: LOCAL
-- [Externals]   Registered: bass
-- [bass] Attaching to MinimalConsole
-- [bass]   bassflac: ENABLED
-- [bass] Integration complete
```

Bei Ausführung:
```
[INFO] === MinimalConsole v2.0.0 - BASS Audio Demo ===
[INFO] BASS Version: 2.4
[INFO] Loading: ../../music/London Grammar.../02 Californian Soil.mp3
[INFO] Format: 44100 Hz, 2 channels
[INFO] Duration: 03:45
[INFO] Starting playback...
```

---

## Erfolgskriterien

- [ ] Externals.cmake lädt ohne Fehler
- [ ] BASS External wird registriert
- [ ] BASS_FLAC Option wird verarbeitet
- [ ] MinimalConsole linkt gegen bass.lib
- [ ] bass.dll wird kopiert (Windows)
- [ ] Phase 5 Tests bestehen
- [ ] Audio-Playback funktioniert

---

## Nächste Schritte (Phase 6)

Phase 6: **Fetched Externals + Hooks**
- Core/Fetch.cmake (FetchContent Wrapper)
- Hooks/HookLoader.cmake
- Registry/Targets.cmake
- Git-basierte Externals (imgui, spdlog, etc.)
