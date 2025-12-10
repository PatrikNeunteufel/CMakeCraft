# Phase 6: Fetched Externals + Hook System — Implementierung

## Übersicht

Phase 6 implementiert die Pipeline für Git-basierte externe Abhängigkeiten mit vollständigem Hook-System.

**Wichtige Änderung:** GLAD wird als **lokales External** verwendet (nicht fetched), da GLAD v2.x ein Generator ist und vorgenerierte Quelldateien benötigt.

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

### Neue Lokale Externals

| Datei | Version | Beschreibung |
|-------|---------|--------------|
| `externals/glad/Include.cmake` | 0.1.0 | GLAD OpenGL Loader |

### Hooks

| Datei | Typ | Beschreibung |
|-------|-----|--------------|
| `PreFetch/glfw.cmake` | PreFetch | Deaktiviert Examples/Tests |
| `PostFetch/imgui.cmake` | PostFetch | Erstellt imgui Target |

---

## Installation

### 1. Verzeichnisse erstellen

```bash
mkdir -p cmake/externals/Core
mkdir -p cmake/externals/Fetched
mkdir -p cmake/externals/Registry
mkdir -p cmake/externals/Hooks/PreFetch
mkdir -p cmake/externals/Hooks/PostFetch
mkdir -p externals/glad/include/glad
mkdir -p externals/glad/include/KHR
mkdir -p externals/glad/src
mkdir -p projects/exec/imGuiApp/src
```

### 2. GLAD generieren (WICHTIG!)

Bevor das Projekt gebaut werden kann, müssen die GLAD-Quelldateien generiert werden:

**Option A: Web-Interface**
1. Besuche https://glad.dav1d.de/
2. Einstellungen:
   - Language: C/C++
   - Specification: OpenGL
   - Profile: Core
   - API gl: 3.3
   - Generate a loader: ✅
3. Download und entpacke nach `externals/glad/`

**Option B: Kommandozeile**
```bash
pip install glad
glad --api gl:core=3.3 --out-path externals/glad c
```

Ergebnis:
```
externals/glad/
├── include/
│   ├── glad/glad.h
│   └── KHR/khrplatform.h
└── src/glad.c
```

### 3. Neue Module kopieren

```bash
# Core
cp cmake/externals/Core/Fetch.cmake cmake/externals/Core/

# Fetched Handler
cp cmake/externals/Fetched/Handler.cmake cmake/externals/Fetched/

# Hooks
cp cmake/externals/Hooks/HookLoader.cmake cmake/externals/Hooks/
cp cmake/externals/Hooks/PreFetch/glfw.cmake cmake/externals/Hooks/PreFetch/
cp cmake/externals/Hooks/PostFetch/imgui.cmake cmake/externals/Hooks/PostFetch/

# Registry
cp cmake/externals/Registry/Targets.cmake cmake/externals/Registry/

# Orchestrator (ERSETZEN v0.1.0 → v0.2.0)
cp cmake/externals/Orchestrator.cmake cmake/externals/

# GLAD Local External
cp externals/glad/Include.cmake externals/glad/
```

### 4. imGuiApp erstellen

```bash
cp projects/exec/imGuiApp/src/main.cpp projects/exec/imGuiApp/src/
```

### 5. Solution.json aktualisieren

```bash
cp Solution.json ./  # v0.3.0 → v0.4.0
```

---

## Solution.json (v0.4.0)

```json
{
    "externals": {
        "bass": { "path": "externals/bass" },
        "glad": { "path": "externals/glad" },
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.91.6",
            "cmakeSupport": false
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
    │                     │                   └── Include.cmake
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
│   └── glfw.cmake      ← cmake/externals/Hooks/PreFetch/${name}.cmake
└── PostFetch/
    └── imgui.cmake     ← cmake/externals/Hooks/PostFetch/${name}.cmake
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
-- [Externals] --- Processing: glad ---
-- [Externals]   Type: LOCAL
-- [glad] Configuring for target: imGuiApp
-- [glad] Created library target 'glad'
-- [Externals] --- Processing: imgui ---
-- [Externals]   Type: FETCHED (git)
-- [Externals] --- Fetching: imgui ---
-- [imgui] Creating target from: .../imgui
-- [imgui] Target 'imgui' created
-- [Externals] --- imgui: Ready ---
-- [Externals] --- Processing: glfw ---
-- [glfw] PreFetch hook: Setting options
-- [Externals] --- glfw: Ready ---
```

---

## Erfolgskriterien

- [ ] Core/Fetch.cmake lädt ohne Fehler
- [ ] Hooks/HookLoader.cmake funktioniert
- [ ] Registry/Targets.cmake registriert Targets
- [ ] GLAD (lokal) wird korrekt eingebunden
- [ ] imgui wird gefetcht und Target erstellt
- [ ] glfw wird gefetcht (PreFetch Hook aktiv)
- [ ] imGuiApp linkt gegen alle Externals
- [ ] imGuiApp startet und zeigt ImGui-Fenster
- [ ] Phase 6 Tests bestehen

---

## Dokumentation

| Datei | Beschreibung |
|-------|--------------|
| `docs/Fetch_cmake_v0_1_0_doc_v1.md` | FetchContent Wrapper |
| `docs/HookLoader_cmake_v0_1_0_doc_v1.md` | Hook System |
| `docs/Handler_cmake_v0_1_0_doc_v1.md` | Fetched Handler |
| `docs/Targets_cmake_v0_1_0_doc_v1.md` | Target Registry |
| `docs/Orchestrator_cmake_v0_2_0_doc_v1.md` | Orchestrator Update |
| `docs/glad_Include_cmake_v0_1_0_doc_v1.md` | GLAD Local External |

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
| **0.1.1** | **2025-12-09** | **GLAD als lokales External (Generator-Problem)** |
