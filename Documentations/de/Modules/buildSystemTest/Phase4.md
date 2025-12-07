# Phase 4: Library Pipeline — Implementierung

## Übersicht

Phase 4 implementiert die Library-Pipeline, analog zur Executable-Pipeline aus Phase 3.

## Neue Dateien

### CMake Module (cmake/project/)

| Datei | Beschreibung |
|-------|--------------|
| `Libraries.cmake` | Hauptschleife über alle Libraries |
| `LibraryCollect.cmake` | JSON → Context Extraktion |
| `LibraryCreate.cmake` | Target-Erstellung |

### Test Library

| Datei | Ziel |
|-------|------|
| `BasicLogger.h` | `projects/libs/BasicLogger/include/BasicLogger.h` |

### Aktualisierte Dateien (v0.1.0 → v0.1.1)

| Datei | Änderung |
|-------|----------|
| `Solution.cmake` | SOLUTION_LIBRARIES_JSON + SOLUTION_EXECUTABLES_JSON hinzugefügt |
| `CMakeLists.txt` | Libraries.cmake eingebunden, Phase 4 Tests aktiviert |
| `main.cpp` | MinimalConsole verwendet jetzt BasicLogger |
| `Solution.json` | BasicLogger Library + Dependency hinzugefügt |

### Tests

| Datei | Ziel |
|-------|------|
| `phase4.cmake` | `cmake/buildSystemTest/phase4.cmake` |

### Dokumentation

| Datei | Beschreibung |
|-------|--------------|
| `Solution_cmake_v0_1_1_doc_v0_1.md` | Solution.cmake Doku (aktualisiert) |
| `CMakeLists_doc_v0_1_1.md` | CMakeLists.txt Doku (aktualisiert) |
| `Libraries_cmake_v0_1_0_doc_v0_1.md` | Libraries.cmake Doku (neu) |
| `LibraryCollect_cmake_v0_1_0_doc_v0_1.md` | LibraryCollect.cmake Doku (neu) |
| `LibraryCreate_cmake_v0_1_0_doc_v0_1.md` | LibraryCreate.cmake Doku (neu) |

---

## Installation

### 1. Verzeichnisse erstellen

```bash
mkdir -p projects/libs/BasicLogger/include
mkdir -p cmake/project
```

### 2. Dateien kopieren/ersetzen

```bash
# CMake Module (NEU)
cp Libraries.cmake cmake/project/
cp LibraryCollect.cmake cmake/project/
cp LibraryCreate.cmake cmake/project/

# Solution.cmake (ERSETZEN - v0.1.1)
cp Solution.cmake cmake/project/

# CMakeLists.txt (ERSETZEN - v0.1.1)
cp CMakeLists.txt ./

# BasicLogger
cp BasicLogger.h projects/libs/BasicLogger/include/

# MinimalConsole aktualisieren
cp main.cpp projects/exec/MinimalConsole/src/

# Tests
cp phase4.cmake cmake/buildSystemTest/
```

### 3. Solution.json aktualisieren

Die mitgelieferte `Solution.json` ist ein Beispiel. Für dein Projekt:

**Libraries hinzufügen:**
```json
"libraries": [
    {
        "name": "BasicLogger",
        "version": "1.0.0",
        "type": "INTERFACE",
        "public_headers": "projects/libs/BasicLogger/include"
    }
]
```

**MinimalConsole Dependency hinzufügen:**
```json
"executables": [
    {
        "name": "MinimalConsole",
        "dependencies": ["BasicLogger"]
    }
]
```

**Wichtig:** Libraries MÜSSEN vor Executables geladen werden (in CMakeLists.txt bereits korrekt)

### 5. Phase 4 Tests in CMakeLists.txt registrieren

```cmake
if("${TEST_PHASE}" STREQUAL "" OR "4" IN_LIST TEST_PHASE)
    dbgspace(ID BUILD_TEST)
    include(cmake/buildSystemTest/phase4.cmake)
endif()
```

---

## Solution.json Änderungen

### Libraries hinzufügen

```json
"libraries": [
    {
        "name": "BasicLogger",
        "version": "1.0.0",
        "type": "INTERFACE",
        "public_headers": "projects/libs/BasicLogger/include"
    }
]
```

### MinimalConsole aktualisieren

```json
"executables": [
    {
        "name": "MinimalConsole",
        "version": "1.1.0",
        "type": "CONSOLE",
        "path": "projects/exec/MinimalConsole/src",
        "dependencies": ["BasicLogger"]
    }
]
```

---

## Testen

```bash
# Konfigurieren mit Tests
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=ON

# Bauen
cmake --build build

# Ausführen
./build/bin/MinimalConsole
```

### Erwartete Ausgabe

```
[2025-12-07 12:34:56] [INFO] MinimalConsole started
[2025-12-07 12:34:56] [DEBUG] Debug mode enabled
Hello World from MinimalConsole!
[2025-12-07 12:34:56] [INFO] Processing complete
[2025-12-07 12:34:56] [WARN] This is a test warning
[2025-12-07 12:34:56] [INFO] Using global logger
[2025-12-07 12:34:56] [INFO] MinimalConsole finished
```

Plus eine `minimal_console.log` Datei mit denselben Einträgen.

---

## Erfolgskriterien

- [ ] Libraries.cmake lädt ohne Fehler
- [ ] BasicLogger Target wird erstellt (INTERFACE)
- [ ] MinimalConsole linkt gegen BasicLogger
- [ ] Phase 4 Tests bestehen
- [ ] MinimalConsole läuft und loggt

---

## Nächste Schritte (Phase 5)

Phase 5: **Lokale Externals**
- Orchestrator.cmake
- Local/Attach.cmake
- BASS laden
