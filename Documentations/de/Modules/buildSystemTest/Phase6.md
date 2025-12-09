# Phase 6: Fetched Externals + Hook System — Implementierung

## Übersicht

Phase 6 implementiert die Pipeline für Git-basierte externe Abhängigkeiten mit vollständigem Hook-System.

## Neue Module

### cmake/externals/Core/

| Datei | Version | Beschreibung |
|-------|---------|--------------|
| `Fetch.cmake` | 0.1.0 | FetchContent Wrapper für Git Externals |

### cmake/externals/Hooks/

| Datei | Version | Beschreibung |
|-------|---------|--------------|
| `HookLoader.cmake` | 0.1.0 | PreFetch/PostFetch Hook System |

### cmake/externals/Fetched/

| Datei | Version | Beschreibung |
|-------|---------|--------------|
| `Handler.cmake` | 0.1.0 | Main Handler für Fetched Externals |

### cmake/externals/Registry/

| Datei | Version | Beschreibung |
|-------|---------|--------------|
| `Targets.cmake` | 0.1.0 | Target Registry für Externals |

### Aktualisierte Module

| Datei | Version | Änderung |
|-------|---------|----------|
| `Orchestrator.cmake` | 0.2.0 | Fetched Handler Integration |

### Hooks

| Datei | Typ | Beschreibung |
|-------|-----|--------------|
| `PreFetch/glfw.cmake` | PreFetch | Deaktiviert Examples/Tests |
| `PreFetch/glad.cmake` | PreFetch | Setzt OpenGL Profile |
| `PostFetch/imgui.cmake` | PostFetch | Erstellt imgui Target |
| `PostFetch/glad.cmake` | PostFetch | Registriert glad Target |

---

## Installation

### 1. Verzeichnisse erstellen

```bash
mkdir -p cmake/externals/Core
mkdir -p cmake/externals/Fetched
mkdir -p cmake/externals/Registry
mkdir -p cmake/externals/Hooks/PreFetch
mkdir -p cmake/externals/Hooks/PostFetch
mkdir -p projects/exec/imGuiApp/src
```

### 2. Neue Module kopieren

```bash
# Core
cp cmake/externals/Core/Fetch.cmake cmake/externals/Core/

# Fetched Handler
cp cmake/externals/Fetched/Handler.cmake cmake/externals/Fetched/

# Hooks
cp cmake/externals/Hooks/HookLoader.cmake cmake/externals/Hooks/

# Registry
cp cmake/externals/Registry/Targets.cmake cmake/externals/Registry/

# Orchestrator (ERSETZEN v0.1.0 → v0.2.0)
cp cmake/externals/Orchestrator.cmake cmake/externals/
```

### 3. Hook-Dateien kopieren

```bash
cp cmake/externals/Hooks/PreFetch/glfw.cmake cmake/externals/Hooks/PreFetch/
cp cmake/externals/Hooks/PreFetch/glad.cmake cmake/externals/Hooks/PreFetch/
cp cmake/externals/Hooks/PostFetch/imgui.cmake cmake/externals/Hooks/PostFetch/
cp cmake/externals/Hooks/PostFetch/glad.cmake cmake/externals/Hooks/PostFetch/
```

### 4. imGuiApp erstellen

```bash
cp projects/exec/imGuiApp/src/main.cpp projects/exec/imGuiApp/src/
```

### 5. Solution.json aktualisieren

```bash
cp Solution.json ./  # v0.3.0 → v0.4.0
```

### 6. Tests

```bash
cp cmake/buildSystemTest/phase6.cmake cmake/buildSystemTest/
```

---

## Solution.json Änderungen

```json
{
    "externals": {
        "bass": { "path": "externals/bass" },
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.91.6",
            "cmakeSupport": false
        },
        "glad": {
            "git": "https://github.com/Dav1dde/glad.git",
            "tag": "v2.0.8"
        },
        "glfw": {
            "git": "https://github.com/glfw/glfw.git",
            "tag": "3.4"
        }
    },
    "executables": [
        {
            "name": "imGuiApp",
            "version": "0.1.0",
            "type": "GUI",
            "externals": ["imgui", "glad", "glfw"]
        }
    ]
}
```

---

## Architektur

```
Solution.json
    │
    ▼
Externals.cmake ──► Orchestrator.cmake
    │                     │
    │                     ├──► Local? ──► Local/Attach.cmake
    │                     │
    │                     └──► Fetched? ──► Fetched/Handler.cmake
    │                                           │
    │                                           ├──► Core/Fetch.cmake
    │                                           │       └── FetchContent_Declare
    │                                           │
    │                                           ├──► Hooks/HookLoader.cmake
    │                                           │       ├── PreFetch Hook
    │                                           │       └── PostFetch Hook
    │                                           │
    │                                           └──► Registry/Targets.cmake
    │                                                   └── Target Registration
    │
    ▼
ExecutableCreate.cmake
    │
    └──► apply_external_to_target()
            │
            ├── Local: Include Include.cmake
            └── Fetched: _link_external_to_target()
```

---

## Hook System

### Convention over Configuration

| Situation | Verhalten |
|-----------|-----------|
| Kein Hook in JSON, kein Convention-Pfad | Kein Hook |
| Kein Hook in JSON, Convention-Pfad existiert | Auto-Load |
| Hook explizit in JSON, Datei existiert | Laden |
| Hook explizit in JSON, Datei fehlt | **Error E216** |

### Convention-Pfade

```
cmake/externals/Hooks/
├── PreFetch/
│   ├── glfw.cmake      ← cmake/externals/Hooks/PreFetch/${name}.cmake
│   └── glad.cmake
└── PostFetch/
    ├── imgui.cmake     ← cmake/externals/Hooks/PostFetch/${name}.cmake
    └── glad.cmake
```

### Hook-Variablen

| Variable | Beschreibung |
|----------|--------------|
| `HOOK_EXTERNAL_NAME` | Name des Externals |
| `HOOK_EXTERNAL_JSON` | JSON-Definition |
| `HOOK_SOURCE_DIR` | Source-Verzeichnis (nur PostFetch) |

---

## Testen

```bash
# Konfigurieren (erste Ausführung dauert wegen Git-Downloads)
cmake -B build -DRUN_BUILD_SYSTEM_TESTS=ON

# Bauen
cmake --build build

# Ausführen
./build/exec/imGuiApp/bin/Debug/imGuiApp
```

### Erwartete CMake-Ausgabe

```
-- [Externals] === Externals Pipeline Start ===
-- [Externals] Processing 6 external(s)...
-- [Externals] --- Processing: bass ---
-- [Externals]   Type: LOCAL
-- [Externals] --- Fetching: imgui ---
-- [imgui] Creating target from: .../imgui
-- [imgui] Target 'imgui' created
-- [imgui] PostFetch hook complete
-- [Externals] --- imgui: Ready ---
```

---

## Erfolgskriterien

- [ ] Core/Fetch.cmake lädt ohne Fehler
- [ ] Hooks/HookLoader.cmake funktioniert
- [ ] Registry/Targets.cmake registriert Targets
- [ ] imgui wird gefetcht und Target erstellt
- [ ] glad wird gefetcht
- [ ] glfw wird gefetcht
- [ ] imGuiApp linkt gegen alle Externals
- [ ] imGuiApp startet und zeigt ImGui-Fenster
- [ ] Phase 6 Tests bestehen

---

## Nächste Schritte (Phase 7)

Phase 7: **Tests & Polish**
- Tests.cmake
- CTest Integration
- Dokumentation finalisieren

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-09** | **Initial: Fetched Externals, Hook System, Target Registry** |
