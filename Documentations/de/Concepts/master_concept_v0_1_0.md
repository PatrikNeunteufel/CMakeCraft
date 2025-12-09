# Master Concept – CMake Architecture V2

> **Version:** 0.1.0  
> **Datum:** 2025-12-03  
> **Typ:** Konzept-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Concepts/master_concept_v0_1_0.md)

Dieses Dokument dient als **zentrale Referenz** für das CMake Build-System. Es definiert die Struktur, Prinzipien und das technische Fundament.

---

## 1. Vision

Ein modulares, stabiles und plattformübergreifendes CMake-System, das große Multi-Executable-Projekte verwalten kann, JSON-gesteuert ist und minimalen globalen Zustand besitzt.

### Kernprinzipien

- **Deklarativ über JSON** – Imperativ nur wo nötig
- **Kein globaler State** – Alles über Context-Objekte
- **Testbar auf jeder Ebene** – Unit, Integration, End-to-End
- **Fail-fast** – Klare Fehlermeldungen
- **Single Source of Truth** – Für External-Versionen
- **Convention over Configuration** – Für optionale Features

---

## 2. Projektstruktur

Die CMake-Infrastruktur ist in klar getrennte Verantwortungsbereiche aufgeteilt.

```
CMakeLists.txt                         # Top-Level: Module laden
Solution.json                          # JSON-Definition aller Targets
CMakePresets.json                      # Build-Presets

cmake/
  core/                                # Grundbausteine
    Errors.cmake                       # Error-Handling
    Debug.cmake                        # Debug-System
    Context.cmake                      # Context-Objekt-Pattern
    Json.cmake                         # JSON-Helferfunktionen
    Validation.cmake                   # Schema-Validierung
    SourceCollect.cmake                # Source-Datei-Management
    OutputDirs.cmake                   # Zielordner
    Warnings.cmake                     # Warnlevel
    CompilerOptions.cmake              # Compiler-Optionen

  externals/                           # External-System
    Orchestrator.cmake                 # High-Level Workflow
    Core/                              # Für fetched Externals
      Fetch.cmake
      Hash.cmake
      Policies.cmake
    Hooks/                             # Hook-System
      HookLoader.cmake
      PreFetch/
      PostFetch/
    Local/                             # Für lokale Externals
      Attach.cmake
    Registry/                          # Target-Verwaltung
      Targets.cmake
      Linking.cmake

  project/                             # Pipelines
    Solution.cmake                     # Solution.json laden
    Executables.cmake                  # Executable-Pipeline
    ExecutableCollect.cmake
    ExecutableCreate.cmake
    Libraries.cmake                    # Library-Pipeline
    LibraryCollect.cmake
    LibraryCreate.cmake
    Tests.cmake                        # Test-Pipeline
    Dependencies.cmake                 # Interne Abhängigkeiten

externals/                             # Lokale Externals im Repo
  bass/
    Include.cmake
  lua/
    Include.cmake
  doctest/
    Include.cmake
```

---

## 3. Solution.json Schema

Die Solution.json ist das Herzstück der deklarativen Konfiguration.

**Aktuelle Schema-Version:** `0.1`

### Root-Level Struktur

```json
{
    "schemaVersion": "0.1",
    "solution": { },
    "settings": { },
    "externalsPolicy": { },
    "externals": { },
    "libraries": [ ],
    "executables": [ ],
    "tests": [ ]
}
```

| Block | Pflicht | Beschreibung |
|-------|---------|--------------|
| `schemaVersion` | ✅ | Version des JSON-Schemas |
| `solution` | ✅ | Metadaten (Name, Version, Autoren) |
| `settings` | ❌ | Globale Build-Einstellungen |
| `externalsPolicy` | ❌ | Cache-Verzeichnis, Update-Strategie |
| `externals` | ❌ | Zentrale External-Definitionen |
| `libraries` | ❌ | Interne Libraries |
| `executables` | ❌ | Ausführbare Programme |
| `tests` | ❌ | Test-Targets |

### Zentraler Externals-Block

**Alle External-Definitionen werden zentral definiert.** Executables referenzieren nur über Namen.

| Problem (dezentral) | Lösung (zentral) |
|---------------------|------------------|
| Version-Drift | Eine Version für alle |
| Update-Aufwand | Eine Stelle ändern |
| Inkonsistente Flags | Einheitliche Konfiguration |

---

## 4. External-Typen

Der Typ wird automatisch über das vorhandene Feld erkannt:

| Erkennungsfeld | Typ | Status |
|----------------|-----|--------|
| `path` | **local** | ✅ Implementiert |
| `git` | **fetched** | ✅ Implementiert |
| `vcpkg` | **vcpkg** | ⬜ Geplant |
| `conan` | **conan** | ⬜ Geplant |
| `find_package` | **system** | ⬜ Geplant |

**Validierung:** Genau eines dieser Felder muss vorhanden sein (Error E012).

### Lokale Externals

Liegen bereits im Repository.

```json
"externals": {
    "bass": { "path": "externals/bass" },
    "lua": { "path": "externals/lua" }
}
```

**Convention:** Jedes lokale External muss eine `Include.cmake` haben.

### Fetched Externals

Werden aus Git geklont.

```json
"externals": {
    "spdlog": {
        "git": "https://github.com/gabime/spdlog.git",
        "tag": "v1.12.0"
    }
}
```

| Feld | Pflicht | Beschreibung |
|------|---------|--------------|
| `git` | ✅ | Repository URL |
| `tag` | ❌* | Git-Tag |
| `branch` | ❌* | Git-Branch |
| `commit` | ❌* | Commit-Hash |
| `hooks` | ❌ | Pre/PostFetch Hooks |

*Genau eines von `tag`, `branch`, `commit` erforderlich (Error E215).

---

## 5. Hook-System

Für Externals die spezielle Behandlung benötigen.

### Convention over Configuration

| Situation | Verhalten |
|-----------|-----------|
| Keine Hooks angegeben, kein Convention-Pfad | Kein Hook |
| Keine Hooks angegeben, Convention-Pfad existiert | Auto-Load |
| Hooks explizit angegeben, Datei existiert | Laden |
| Hooks explizit angegeben, Datei fehlt | **Error E216** |

**Convention-Pfade:**
- PreFetch: `cmake/externals/Hooks/PreFetch/${name}.cmake`
- PostFetch: `cmake/externals/Hooks/PostFetch/${name}.cmake`

---

## 6. Context-Objekt Pattern

Statt globaler Variablen nutzt jedes Target einen eigenen Namensraum.

```cmake
ctx_create(EXE_MyApp)
ctx_set(EXE_MyApp NAME "MyApp")
ctx_set(EXE_MyApp PATH "src/app")
ctx_get(EXE_MyApp NAME _name)
```

**Vorteile:**
- Isolierte Namensräume
- Parallele Verarbeitung möglich
- Kein State-Leaking

---

## 7. Source-Management

Drei Modi für Source-Dateien:

| Mode | Beschreibung |
|------|--------------|
| `explicit` | Source.cmake erforderlich (Default) |
| `glob` | Automatisches Sammeln |
| `auto` | Source.cmake wenn vorhanden, sonst GLOB |

**Empfehlung:** `explicit` für maximale Kontrolle.

---

## 8. Error-Handling

Einheitliches System über `Errors.cmake`:

```cmake
cmake_fatal("E001" "Beschreibung")   # Bricht ab
cmake_warn("W001" "Beschreibung")    # Läuft weiter
cmake_assert(CONDITION "Message")    # Interne Prüfung
```

**Fehlercode-Bereiche:**
- E0xx: JSON/Parsing
- E1xx: Target-Erstellung
- E2xx: Externals
- W0xx: Deprecation
- W1xx: Konfiguration
- W2xx: Tools/Setup

---

## 9. Pipelines

### Executable-Pipeline

1. **Collect:** JSON → Context
2. **Validate:** Pflichtfelder, Abhängigkeiten
3. **Create:** CMake-Target erstellen
4. **Configure:** PCH, Sources, Externals, Options

### Library-Pipeline

Analog zu Executables, zusätzlich:
- PUBLIC/PRIVATE Headers
- STATIC/SHARED/INTERFACE Typen

### Test-Pipeline

- CTest-Integration
- Framework-Erkennung (doctest, gtest, catch2)
- Labels und Timeout-Konfiguration

---

## 10. Cache-Variablen

| Variable | Default | Beschreibung |
|----------|---------|--------------|
| `BUILD_TESTS` | ON | Tests aktivieren |
| `BUILD_ONLY` | "" | Nur bestimmte Targets |
| `ENABLE_CLANG_TIDY` | OFF | Code-Qualitätschecks |
| `ENABLE_STRICT_CONFORMANCE` | ON | MSVC strict mode |
| `NO_EXCEPTIONS` | OFF | Exceptions deaktivieren |
| `NO_RTTI` | OFF | RTTI deaktivieren |

---

## 11. Tests

| Test | Beschreibung |
|------|--------------|
| `test_context.cmake` | Context-API |
| `test_json_helpers.cmake` | JSON-Parsing |
| `test_errors.cmake` | Error-Handling |
| `test_validation.cmake` | Schema-Validierung |
| `test_simple_executable.cmake` | Minimales Projekt |
| `test_externals_pipeline.cmake` | Fetch + Registry |
| `test_local_externals.cmake` | Lokale Externals |
| `test_hooks.cmake` | Hook-System |

---

## 12. Dokumentation

| Dokument | Beschreibung |
|----------|--------------|
| **Solution_Schema** | JSON-Schema-Dokumentation |
| **ErrorCodes** | Alle Fehlercodes |
| **guidelines** | Coding-Konventionen |
| **implementation_plan** | Phasen-basierter Plan |

---

## 13. Offene Punkte

- [ ] vcpkg/Conan Integration
- [ ] Parallelisierung des External-Fetchings
- [ ] IDE-Integration (VSCode, CLion)
- [ ] Export-Mechanismus für Libraries
- [ ] Lockfile-System für reproduzierbare Builds

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-03** | **Initial (Clean Start): Struktur aus v1.7 übernommen, Blueprint-Format, Source-Management dokumentiert** |
