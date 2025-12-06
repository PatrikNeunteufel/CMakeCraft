# Dokumentation – CMake Architecture V2

> **Version:** 0.1.5  
> **Datum:** 2025-12-04  
> **Status:** In Entwicklung (Pre-Release)

Willkommen im Dokumentations-Verzeichnis des CMake Architecture V2 Projekts. Dieses README dient als **zentraler Einstiegspunkt** für alle Projektdokumentationen.

---

## Ordnerstruktur

```
Documentations/
├── README.md                    ← Du bist hier
├── Blueprints/                  # Meta-Dokumentationen (Standards)
├── Concepts/                    # Architektur, Design, Planung
├── References/                  # Nachschlagewerke (ErrorCodes, Schema)
├── Modules/                     # CMake-Modul-Dokumentationen
│   ├── core/                    # cmake/core/ Module
│   ├── project/                 # cmake/project/ Module (geplant)
│   └── externals/               # cmake/externals/ Module (geplant)
├── UserGuides/                  # Benutzer-Anleitungen
└── Enterprise/                  # Unternehmensweite Standards
```

---

## Dokumentations-Typen

| Typ | Ordner | Zielgruppe | Beschreibung |
|-----|--------|------------|--------------|
| **Blueprint** | `Blueprints/` | Doku-Ersteller | Standards für Dokumente und Code |
| **Konzept-Doku** | `Concepts/` | Build-System-Dev | Architektur, Design-Entscheidungen |
| **Referenz-Doku** | `References/` | Build-System-Dev | Nachschlagewerke, Spezifikationen |
| **Modul-Doku** | `Modules/` | Build-System-Dev | CMake-Modul-Dokumentationen |
| **Benutzer-Doku** | `UserGuides/` | C++ Entwickler | Anleitungen zur Nutzung |
| **Unternehmens-Doku** | `Enterprise/` | Alle Entwickler | Team-/Unternehmensstandards |

---

## Vorhandene Dokumente

### Blueprints/

Standards die definieren, wie Dokumentationen und Code strukturiert werden.

| Dokument | Version | Beschreibung |
|----------|---------|--------------|
| [Documentation_Blueprint](Blueprints/Documentation_Blueprint_v0_1_0.md) | 0.1.0 | Struktur für alle Dokumentationen |
| [CMake_Blueprint](Blueprints/CMake_Blueprint_v0_1_0.md) | 0.1.0 | Struktur für CMake-Module |

### Concepts/

| Dokument | Version | Status | Beschreibung |
|----------|---------|--------|--------------|
| [master_concept](Concepts/master_concept_v0_1_0.md) | 0.1.0 | ✅ Vorhanden | Architektur-Übersicht, Vision |
| [guidelines](Concepts/guidelines_v0_1_0.md) | 0.1.0 | ✅ Vorhanden | CMake Coding-Konventionen |
| [implementation_plan](Concepts/implementation_plan_v0_1_0.md) | 0.1.0 | ✅ Vorhanden | Phasen-basierter Plan |

### References/

| Dokument | Version | Status | Beschreibung |
|----------|---------|--------|--------------|
| [ErrorCodes](References/ErrorCodes_v0_1_0.md) | 0.1.0 | ✅ Vorhanden | Alle Fehlercodes mit Erklärungen |
| [Solution_Schema](References/Solution_Schema_v0_1_0.md) | 0.1.0 | ✅ Vorhanden | JSON-Schema für Solution.json |
| [CMakePresets_Manual](References/CMakePresets_Manual_v0_1_1.md) | 0.1.1 | ✅ Vorhanden | Preset-Konzepte und Best Practices |
| [CMakePresets_Reference](References/CMakePresets_Reference_v0_1_0.md) | 0.1.0 | ✅ Vorhanden | Alle Team-Presets im Detail |
| [CMakeUserPresets_Reference](References/CMakeUserPresets_Reference_v0_1_0.md) | 0.1.0 | ✅ Vorhanden | User-Presets Dokumentation |
| [Externals](References/Externals_v0_1_0.md) | 0.1.0 | ✅ Vorhanden | Verfügbare Externals |

### Modules/

CMake-Modul-Dokumentationen folgen dem Namensschema:  
`[ModulName]_cmake_v[X]_[Y]_[Z]_doc_v[N].md`

#### Modules/core/

| Modul | Version | Status | Beschreibung |
|-------|---------|--------|--------------|
| [Errors.cmake](Modules/core/Errors_cmake_v0_1_0_doc_v1.md) | 0.1.0 (doc v1) | ✅ Vorhanden | Fehlerbehandlung |
| [Debug.cmake](Modules/core/Debug_cmake_v0_1_0_doc_v1.md) | 0.1.0 (doc v1) | ✅ Vorhanden | Debug-System (Zwei-Achsen-Filterung) |
| [Context.cmake](Modules/core/Context_cmake_v0_1_0_doc_v1.md) | 0.1.0 (doc v1) | ✅ Vorhanden | Context-Objekt-Pattern |
| [Json.cmake](Modules/core/Json_cmake_v0_1_0_doc_v1.md) | 0.1.0 (doc v1) | ✅ Vorhanden | JSON-Hilfsfunktionen |
| [Validation.cmake](Modules/core/Validation_cmake_v0_1_0_doc_v1.md) | 0.1.0 (doc v1) | ✅ Vorhanden | Schema-Validierung |
| [SourceCollect.cmake](Modules/core/SourceCollect_cmake_v0_1_0_doc_v1.md) | 0.1.0 (doc v1) | ✅ Vorhanden | Source-Datei-Management |
| [OutputDirs.cmake](Modules/core/OutputDirs_cmake_v0_1_0_doc_v1.md) | 0.1.0 (doc v1) | ✅ Vorhanden | Output-Verzeichnisse |
| [Warnings.cmake](Modules/core/Warnings_cmake_v0_1_0_doc_v1.md) | 0.1.0 (doc v1) | ✅ Vorhanden | Warning-Level |
| [CompilerOptions.cmake](Modules/core/CompilerOptions_cmake_v0_1_0_doc_v1_1.md) | 0.1.0 (doc v1.1) | ✅ Vorhanden | Compiler-Konfiguration |

#### Modules/project/ (geplant)

| Modul | Version | Status | Beschreibung |
|-------|---------|--------|--------------|
| Solution.cmake | - | ⬜ Ausstehend | Solution.json laden |
| Executables.cmake | - | ⬜ Ausstehend | Executable-Pipeline |
| ExecutableCollector.cmake | - | ⬜ Ausstehend | JSON → Context für Executables |
| ExecutableCreate.cmake | - | ⬜ Ausstehend | Executable-Target erstellen |
| Libraries.cmake | - | ⬜ Ausstehend | Library-Pipeline |
| LibraryCollector.cmake | - | ⬜ Ausstehend | JSON → Context für Libraries |
| Tests.cmake | - | ⬜ Ausstehend | Test-Pipeline |
| TestCollector.cmake | - | ⬜ Ausstehend | JSON → Context für Tests |

#### Modules/externals/ (geplant)

| Modul | Version | Status | Beschreibung |
|-------|---------|--------|--------------|
| Orchestrator.cmake | - | ⬜ Ausstehend | External-Dispatch |
| Fetch.cmake | - | ⬜ Ausstehend | Git-Fetch |
| Registry.cmake | - | ⬜ Ausstehend | Target-Registry |
| HookLoader.cmake | - | ⬜ Ausstehend | Hook-System |

### UserGuides/

| Dokument | Version | Status | Beschreibung |
|----------|---------|--------|--------------|
| [CMakeUserPresets_Example](UserGuides/CMakeUserPresets_Example_v0_1_0.md) | 0.1.0 | ✅ Vorhanden | Template für User-Presets |
| UserManual | - | ⬜ Ausstehend | Vollständige Benutzeranleitung |
| QuickStart | - | ⬜ Ausstehend | Schnelleinstieg |
| FAQ | - | ⬜ Ausstehend | Häufig gestellte Fragen |

### Enterprise/

| Dokument | Version | Status | Beschreibung |
|----------|---------|--------|--------------|
| CodingStandards | - | ⬜ Ausstehend | C++ Coding-Konventionen |
| ReviewGuidelines | - | ⬜ Ausstehend | Code Review Richtlinien |
| GitWorkflow | - | ⬜ Ausstehend | Branch-Strategie, Commits |

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
   - Siehe `Modules/` Ordner

### Für C++ Entwickler (Endnutzer)

1. **CMakeUserPresets_Example** – [Template für eigene Presets](UserGuides/CMakeUserPresets_Example_v0_1_0.md)
2. **UserManual** – Vollständige Anleitung (ausstehend)
3. **QuickStart** – Schneller Einstieg (ausstehend)

---

## Versionierung

### Dateinamen-Konvention

| Typ | Format | Beispiel |
|-----|--------|----------|
| Blueprint | `[Name]_Blueprint_v[X]_[Y]_[Z].md` | `Documentation_Blueprint_v0_1_0.md` |
| Modul-Doku | `[Modul]_cmake_v[X]_[Y]_[Z]_doc_v[N].md` | `Context_cmake_v0_1_0_doc_v1.md` |
| Andere | `[Name]_v[X]_[Y]_[Z].md` | `ErrorCodes_v0_1_0.md` |

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
4. Review-Checkliste im Blueprint durchgehen
5. Diese README aktualisieren

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.5** | **2025-12-04** | **SourceCollect.cmake erstellt; Collector-Namenskonvention für project/ Module** |
| 0.1.4 | 2025-12-04 | Validation.cmake, OutputDirs.cmake hinzugefügt; Modules/ Subfolder-Struktur (core/, project/, externals/) |
| 0.1.3 | 2025-12-04 | Errors.cmake und Warnings.cmake hinzugefügt |
| 0.1.2 | 2025-12-04 | Debug.cmake hinzugefügt, Core-Module erstellt (Context, Json, CompilerOptions) |
| 0.1.1 | 2025-12-03 | Preset-Dokumentationen hinzugefügt, Schnellstart aktualisiert |
| 0.1.0 | 2025-12-03 | Initial: Ordnerstruktur, Dokumentations-Übersicht, Verlinkung zu Blueprints |
