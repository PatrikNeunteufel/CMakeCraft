# Dokumentation – CMake Architecture V2

> **Version:** 0.2.0  
> **Datum:** 2025-12-09  
> **Status:** In Entwicklung (Pre-Release)  
> **Sprache:** Deutsch  
> **English:** [English Version](../en/README.md)

Willkommen im Dokumentations-Verzeichnis des CMake Architecture V2 Projekts. Dieses README dient als **zentraler Einstiegspunkt** für alle Projektdokumentationen.

---

## Aktueller Stand

| Phase | Status | Beschreibung |
|-------|--------|--------------|
| Phase 1-3 | ✅ Abgeschlossen | Core-Module, Basis-Infrastruktur |
| Phase 4 | ✅ Abgeschlossen | Executable/Library Pipeline |
| Phase 5 | ✅ Abgeschlossen | Lokale Externals (BASS, Lua, doctest) |
| Phase 6 | ✅ Abgeschlossen | Git Externals (glfw, imgui), Hook-System |
| Phase 7+ | ⬜ Geplant | vcpkg, Tests, erweiterte Features |

---

## Ordnerstruktur

```
Documentations/
├── README.md                    ← Du bist hier
├── Blueprints/                  # Meta-Dokumentationen (Standards)
├── Concepts/                    # Architektur, Design, Planung
├── References/                  # Nachschlagewerke (ErrorCodes, Schema)
├── Standards/                   # Coding Standards (C++, CMake, Git)
├── Modules/                     # CMake-Modul-Dokumentationen
│   ├── core/                    # cmake/core/ Module
│   ├── project/                 # cmake/project/ Module
│   ├── Externals/               # cmake/externals/ Module
│   └── buildSystemTest/         # Build-System Tests
├── UserGuides/                  # Benutzer-Anleitungen
└── externals/                   # External-spezifische Dokumentationen
    ├── bass/
    ├── lua54/
    ├── doctest/
    └── glad/
```

---

## Dokumentations-Typen

| Typ | Ordner | Zielgruppe | Beschreibung |
|-----|--------|------------|--------------|
| **Blueprint** | `Blueprints/` | Doku-Ersteller | Standards für Dokumente und Code |
| **Konzept-Doku** | `Concepts/` | Build-System-Dev | Architektur, Design-Entscheidungen |
| **Referenz-Doku** | `References/` | Build-System-Dev | Nachschlagewerke, Spezifikationen |
| **Standard-Doku** | `Standards/` | Alle Entwickler | Coding Standards |
| **Modul-Doku** | `Modules/` | Build-System-Dev | CMake-Modul-Dokumentationen |
| **Benutzer-Doku** | `UserGuides/` | C++ Entwickler | Anleitungen zur Nutzung |

---

## Vorhandene Dokumente

### Blueprints/

| Dokument | Version | Beschreibung |
|----------|---------|--------------|
| [Documentation_Blueprint](Blueprints/Documentation_Blueprint_v0_1_0.md) | 0.1.0 | Struktur für alle Dokumentationen |
| [CMake_Blueprint](Blueprints/CMake_Blueprint_v0_1_0.md) | 0.1.0 | Struktur für CMake-Module |
| [ClangFormat_Blueprint](Blueprints/ClangFormat_Blueprint_v0_1_0.md) | 0.1.0 | .clang-format Standard |
| [ClangTidy_Blueprint](Blueprints/ClangTidy_Blueprint_v0_1_0.md) | 0.1.0 | .clang-tidy Standard |

### Concepts/

| Dokument | Version | Beschreibung |
|----------|---------|--------------|
| [master_concept](Concepts/master_concept_v0_1_0.md) | 0.1.0 | Architektur-Übersicht, Vision |
| [guidelines](Concepts/guidelines_v0_1_0.md) | 0.1.0 | CMake Coding-Konventionen |
| [implementation_plan](Concepts/implementation_plan_v0_1_0.md) | 0.1.0 | Phasen-basierter Plan |
| [Future_Enhancements](Concepts/Future_Enhancements_v0_1_0.md) | 0.1.0 | Geplante Features |
| [Fetch_v0_2_1_Konzept](Concepts/Fetch_v0_2_1_Konzept.md) | 0.1.0 | Konzept zur Verbesserung des Handling von gefetchten Externals. ✅ Abgeschlossen |


### References/

| Dokument | Version | Beschreibung |
|----------|---------|--------------|
| [ErrorCodes](References/ErrorCodes_v0_1_1.md) | 0.1.1 | Alle Fehlercodes (E001-E217, W001-W201) |
| [Solution_Schema](References/Solution_Schema_v0_1_2.md) | 0.1.2 | JSON-Schema für Solution.json |
| [Externals](References/Externals_v0_2_0.md) | 0.2.0 | Alle Externals (lokal + Git) |
| [CMakePresets_Manual](References/CMakePresets_Manual_v0_1_1.md) | 0.1.1 | Preset-Konzepte |
| [CMakePresets_Reference](References/CMakePresets_Reference_v0_1_0.md) | 0.1.0 | Team-Presets |
| [CMakeUserPresets_Reference](References/CMakeUserPresets_Reference_v0_1_0.md) | 0.1.0 | User-Presets |
| [Glossar](References/Glossar_v0_1_0.md) | 0.1.0 | Begriffsdefinitionen |
| [Git_Externals](References/Git_Externals_Reference_v0_1_0.md) |0.1.0| Git Externals Einbindung (vorhandene und zukünftige)|

### Standards/

| Dokument | Version | Beschreibung |
|----------|---------|--------------|
| [Language_Standards](Standards/Language_Standards_v0_1_1.md) | 0.1.1 | C/C++ Standards |
| [Cpp_Coding_Standard](Standards/Cpp_Coding_Standard_v0_1_0.md) | 0.1.0 | C++ Coding-Konventionen |
| [C_Coding_Standard](Standards/C_Coding_Standard_v0_1_0.md) | 0.1.0 | C Coding-Konventionen |
| [CMake_Standard](Standards/CMake_Standard_v0_1_0.md) | 0.1.0 | CMake Coding-Konventionen |
| [Git_Standard](Standards/Git_Standard_v0_1_0.md) | 0.1.0 | Git Workflow |

### Modules/core/

| Modul | Version | Beschreibung |
|-------|---------|--------------|
| [Errors.cmake](Modules/core/Errors_cmake_v0_1_1_doc_v1.md) | 0.1.1 | Fehlerbehandlung (E/W/ASSERT) |
| [Debug.cmake](Modules/core/Debug_cmake_v0_1_1_doc_v1.md) | 0.1.1 | Debug-System (Zwei-Achsen) |
| [Context.cmake](Modules/core/Context_cmake_v0_1_1_doc_v1.md) | 0.1.1 | Context-Objekt-Pattern |
| [Json.cmake](Modules/core/Json_cmake_v0_1_1_doc_v1.md) | 0.1.1 | JSON-Hilfsfunktionen |
| [Validation.cmake](Modules/core/Validation_cmake_v0_1_1_doc_v1.md) | 0.1.1 | Schema-Validierung |
| [SourceCollect.cmake](Modules/core/SourceCollect_cmake_v0_1_1_doc_v1.md) | 0.1.1 | Source-Datei-Management |
| [OutputDirs.cmake](Modules/core/OutputDirs_cmake_v0_1_3_doc_v1.md) | 0.1.3 | Output-Verzeichnisse |
| [Warnings.cmake](Modules/core/Warnings_cmake_v0_1_1_doc_v1.md) | 0.1.1 | Warning-Level |
| [CompilerOptions.cmake](Modules/core/CompilerOptions_cmake_v0_1_1_doc_v1.md) | 0.1.1 | Compiler-Konfiguration |

### Modules/project/

| Modul | Version | Beschreibung |
|-------|---------|--------------|
| [Solution.cmake](Modules/project/Solution_cmake_v0_1_1_doc_v0_1.md) | 0.1.1 | Solution.json laden |
| [Executables.cmake](Modules/project/Executables_cmake_v0_1_0_doc_v0_1.md) | 0.1.0 | Executable-Pipeline |
| [ExecutableCollect.cmake](Modules/project/ExecutableCollect_cmake_v0_1_0_doc_v0_1.md) | 0.1.0 | JSON → Context |
| [ExecutableCreate.cmake](Modules/project/ExecutableCreate_cmake_v0_1_2_doc_v1.md) | 0.1.2 | Target erstellen + APP_WINDOWS_GUI |
| [Libraries.cmake](Modules/project/Libraries_cmake_v0_1_0_doc_v0_1.md) | 0.1.0 | Library-Pipeline |
| [LibraryCollect.cmake](Modules/project/LibraryCollect_cmake_v0_1_0_doc_v0_1.md) | 0.1.0 | JSON → Context |
| [LibraryCreate.cmake](Modules/project/LibraryCreate_cmake_v0_1_0_doc_v0_1.md) | 0.1.0 | Library-Target erstellen |
| [Externals.cmake](Modules/project/Externals_cmake_v0_1_0_doc_v1.md) | 0.1.0 | External-Integration |

### Modules/Externals/

| Modul | Version | Beschreibung |
|-------|---------|--------------|
| [Orchestrator.cmake](Modules/Externals/Orchestrator_cmake_v0_2_0_doc_v1.md) | 0.2.0 | External-Dispatch (lokal/fetched) |
| [Attach.cmake](Modules/Externals/Attach_cmake_v0_1_0_doc_v1.md) | 0.1.0 | Lokale External-Behandlung |
| [Fetch.cmake](Modules/Externals/Fetch_cmake_v0_1_0_doc_v1.md) | 0.1.0 | FetchContent-Wrapper |
| [Handler.cmake](Modules/Externals/Handler_cmake_v0_1_0_doc_v1.md) | 0.1.0 | Fetched External Pipeline |
| [HookLoader.cmake](Modules/Externals/HookLoader_cmake_v0_1_0_doc_v1.md) | 0.1.0 | Hook-System |
| [Targets.cmake](Modules/Externals/Targets_cmake_v0_1_0_doc_v1.md) | 0.1.0 | Target-Registry |

### externals/ (Hook-Dokumentationen)

| Dokument | Version | Beschreibung |
|----------|---------|--------------|
| [bass/Include.cmake](externals/bass/Include_cmake_v0_1_1_doc_v1_.md) | 0.1.1 | BASS Audio Integration |
| [lua54/Include.cmake](externals/lua54/Include_cmake_v0_1_0_doc_v1.md) | 0.1.0 | Lua 5.4 Integration |
| [doctest/Include.cmake](externals/doctest/Include_cmake_v0_1_0_doc_v1.md) | 0.1.0 | doctest Framework |
| [glad/Include.cmake](externals/glad/Include_cmake_v0_1_0_doc_v1.md) | 0.1.0 | GLAD OpenGL Loader |
| glfw/PreFetch.cmake | 0.1.0 | GLFW Build-Optionen |
| imgui/PostFetch.cmake | 0.2.0 | ImGui Target-Erstellung |

### UserGuides/

| Dokument | Version | Beschreibung |
|----------|---------|--------------|
| [Externals_UserGuide](UserGuides/Externals_UserGuide_v0_2_0.md) | 0.2.0 | External-Verwendung (lokal + Git) |
| [CMakeUserPresets_Example](UserGuides/CMakeUserPresets_Example_v0_1_0.md) | 0.1.0 | Template für User-Presets |

---

## Schnellstart

### Für Build-System-Entwickler

1. **Blueprints lesen** – Verstehe die Standards:
   - [Documentation_Blueprint](Blueprints/Documentation_Blueprint_v0_1_0.md)
   - [CMake_Blueprint](Blueprints/CMake_Blueprint_v0_1_0.md)

2. **Konzepte verstehen** – Architektur und Design:
   - [master_concept](Concepts/master_concept_v0_1_0.md)
   - [guidelines](Concepts/guidelines_v0_1_0.md)

3. **Module nachschlagen** – Spezifische CMake-Module:
   - Core: `Modules/core/`
   - Project: `Modules/project/`
   - Externals: `Modules/Externals/`

### Für C++ Entwickler (Endnutzer)

1. **Externals_UserGuide** – [External-Bibliotheken verwenden](UserGuides/Externals_UserGuide_v0_2_0.md)
2. **CMakeUserPresets_Example** – [Template für eigene Presets](UserGuides/CMakeUserPresets_Example_v0_1_0.md)
3. **Solution_Schema** – [JSON-Format für Solution.json](References/Solution_Schema_v0_1_1.md)

### GUI-Anwendung erstellen (OpenGL/ImGui)

```json
{
    "externals": {
        "glad": { "path": "externals/glad" },
        "glfw": { "git": "https://github.com/glfw/glfw.git", "tag": "3.4" },
        "imgui": { "git": "https://github.com/ocornut/imgui.git", "tag": "v1.90.1", "cmakeSupport": false }
    },
    "executables": [
        { "name": "MyApp", "type": "GUI", "externals": ["glad", "glfw", "imgui"] }
    ]
}
```

Siehe [Externals_UserGuide](UserGuides/Externals_UserGuide_v0_2_0.md) für vollständige Anleitung.

---

## Versionierung

### Dateinamen-Konvention

| Typ | Format | Beispiel |
|-----|--------|----------|
| Blueprint | `[Name]_Blueprint_v[X]_[Y]_[Z].md` | `Documentation_Blueprint_v0_1_0.md` |
| Modul-Doku | `[Modul]_cmake_v[X]_[Y]_[Z]_doc_v[N].md` | `Context_cmake_v0_1_1_doc_v1.md` |
| Andere | `[Name]_v[X]_[Y]_[Z].md` | `ErrorCodes_v0_1_1.md` |

### Semantic Versioning

- **0.x.x** – Pre-Release, in Entwicklung
- **1.0.0** – Erstes stabiles Release
- **MAJOR** – Breaking Changes
- **MINOR** – Neue Features
- **PATCH** – Bugfixes, Korrekturen

---

## Status-Legende

| Symbol | Bedeutung |
|--------|-----------|
| ✅ | Vorhanden / Abgeschlossen |
| 🔄 | In Arbeit |
| ⬜ | Ausstehend / Geplant |
| ⚠️ | Deprecated / Warnung |

---

## Beitragen

Neue Dokumentationen erstellen:

1. Blueprint lesen: [Documentation_Blueprint](Blueprints/Documentation_Blueprint_v0_1_0.md)
2. Richtigen Ordner wählen (siehe Ordnerstruktur)
3. Dateinamen-Konvention beachten
4. **Blockquote-Header verwenden** (nicht Tabelle!)
5. Changelog am Ende (neueste Version fett)
6. Diese README aktualisieren

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.2.0** | **2025-12-09** | **Phase 6 komplett: Git Externals, Hook-System, alle Module dokumentiert, Standards-Ordner** |
| 0.1.5 | 2025-12-04 | SourceCollect.cmake; Collector-Namenskonvention |
| 0.1.4 | 2025-12-04 | Validation, OutputDirs; Modules/ Subfolder |
| 0.1.3 | 2025-12-04 | Errors.cmake, Warnings.cmake |
| 0.1.2 | 2025-12-04 | Debug.cmake, Core-Module |
| 0.1.1 | 2025-12-03 | Preset-Dokumentationen |
| 0.1.0 | 2025-12-03 | Initial: Ordnerstruktur |
