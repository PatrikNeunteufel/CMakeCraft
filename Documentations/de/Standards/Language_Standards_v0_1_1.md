# Language Standards – Sprachrichtlinien

> **Version:** 0.1.1  
> **Datum:** 2025-12-04  
> **Typ:** Unternehmens-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Geltungsbereich:** Alle Projekte, Code, Dokumentation, Git
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Standards/Language_Standards_v0_1_1.md)

---

## 1. Übersicht

Dieses Dokument definiert **verbindliche Sprachrichtlinien** für alle Aspekte der Softwareentwicklung. Ziel ist Konsistenz und internationale Zugänglichkeit.

**Grundprinzip:**
- **Code & Technisches:** Englisch (international, Standard)
- **Dokumentation:** Deutsch als Arbeitssprache, Englisch als Release-Sprache

---

## 2. Code-Sprache

### 2.1 Grundregel

> **Alle Code-Artefakte sind durchgehend in Englisch zu halten.**

Dies betrifft:

| Bereich | Beispiele | Sprache |
|---------|-----------|---------|
| **Variablennamen** | `_source_count`, `_has_path` | 🇬🇧 Englisch |
| **Funktionsnamen** | `collect_sources()`, `validate_external()` | 🇬🇧 Englisch |
| **Kommentare** | `// Check if file exists` | 🇬🇧 Englisch |
| **Log-Ausgaben** | `"Source.cmake not found"` | 🇬🇧 Englisch |
| **Fehlermeldungen** | `"Missing required field 'name'"` | 🇬🇧 Englisch |
| **Dokumentation im Code** | Docstrings, Header-Kommentare | 🇬🇧 Englisch |

### 2.2 Geltende Dateitypen

| Dateityp | Sprache | Anmerkung |
|----------|---------|-----------|
| `.cmake` | 🇬🇧 Englisch | CMake-Module, Presets |
| `.cpp`, `.h` | 🇬🇧 Englisch | C++ Code |
| `.py` | 🇬🇧 Englisch | Python-Skripte |
| `.sh`, `.bat`, `.ps1` | 🇬🇧 Englisch | Shell-Skripte |
| `.json` (technisch) | 🇬🇧 Englisch | CMakePresets.json, Solution.json |
| `.yaml`, `.yml` | 🇬🇧 Englisch | CI/CD, Konfiguration |

### 2.3 Ausnahmen

| Ausnahme | Erlaubt | Beispiel |
|----------|---------|----------|
| **UI-Texte mit i18n** | Lokalisierte Strings | `tr("Datei öffnen")` |
| **Language Packs** | Übersetzungsdateien | `de.json`, `fr.po` |
| **Domänen-spezifische Begriffe** | Wenn kein englisches Äquivalent | Fachbegriffe |

### 2.4 Beispiele

**✅ Korrekt:**
```cmake
# Check if source file exists
function(validate_source_path SOURCE_DIR)
    if(NOT EXISTS "${SOURCE_DIR}")
        cmake_fatal("E104" "Source directory not found: ${SOURCE_DIR}")
    endif()
endfunction()
```

**❌ Falsch:**
```cmake
# Prüfe ob Source-Datei existiert
function(pruefe_source_pfad QUELL_VERZEICHNIS)
    if(NOT EXISTS "${QUELL_VERZEICHNIS}")
        cmake_fatal("E104" "Quellverzeichnis nicht gefunden: ${QUELL_VERZEICHNIS}")
    endif()
endfunction()
```

---

## 3. Dokumentations-Sprache

### 3.1 Zwei-Sprachen-Modell

| Phase | Sprache | Zweck |
|-------|---------|-------|
| **Entwicklung** | 🇩🇪 Deutsch | Arbeitssprache im Team |
| **Release** | 🇬🇧 Englisch | Primäre öffentliche Version |

### 3.2 Workflow

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Entwurf (DE)   │ ──▶ │  Review (DE)    │ ──▶ │ Übersetzung (EN)│
│                 │     │                 │     │                 │
│ Arbeitsversion  │     │ Team-Feedback   │     │ Release-Version │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### 3.3 Dateistruktur

```
Documentations/
├── README.md                    # Zweisprachig, verweist auf beide
├── de/                          # Deutsche Arbeitsversionen
│   ├── README.md                # Deutsche Übersicht
│   ├── Blueprints/
│   ├── Concepts/
│   ├── References/
│   ├── Modules/
│   │   ├── core/
│   │   ├── project/
│   │   └── externals/
│   ├── UserGuides/
│   └── Enterprise/
└── en/                          # Englische Release-Versionen
    ├── README.md                # English overview
    ├── Blueprints/
    ├── Concepts/
    ├── References/
    ├── Modules/
    │   ├── core/
    │   ├── project/
    │   └── externals/
    ├── UserGuides/
    └── Enterprise/
```

**Root README.md:**
```markdown
# Documentation / Dokumentation

| 🇬🇧 English | 🇩🇪 Deutsch |
|-------------|-------------|
| [Documentation](en/README.md) | [Dokumentation](de/README.md) |

> **Note:** English is the primary release language.  
> **Hinweis:** Englisch ist die primäre Release-Sprache.
```

**Vorteile dieser Struktur:**
- Symmetrisch und selbsterklärend
- Einfach weitere Sprachen hinzufügbar (`/fr/`, `/es/`)
- Git-Diff zeigt klar welche Sprache geändert wurde
- CI kann prüfen ob EN-Version aktuell ist

### 3.4 Übersetzungs-Regeln

| Regel | Beschreibung |
|-------|--------------|
| **Vollständigkeit** | Englische Version muss inhaltlich identisch sein |
| **Aktualität** | Bei Änderungen beide Versionen aktualisieren |
| **Fachbegriffe** | Technische Begriffe konsistent übersetzen |
| **Code-Beispiele** | Bleiben unverändert (sind bereits Englisch) |
| **Versionierung** | Beide Versionen haben gleiche Versionsnummer |

### 3.5 Dokumentations-Header

**Deutsch (de/):**
```markdown
# Modul-Name – Dokumentation

> **Version:** 0.1.0 (doc v1)  
> **Sprache:** Deutsch (Arbeitsversion)  
> **Englisch:** [English Version](../../en/Modules/core/Modul_Name_v0_1_0.md)
```

**Englisch (en/):**
```markdown
# Module Name – Documentation

> **Version:** 0.1.0 (doc v1)  
> **Language:** English (Release)  
> **Deutsch:** [German Version](../../de/Modules/core/Modul_Name_v0_1_0.md)
```

---

## 4. Git & Repository

### 4.1 Commit Messages

> **Commit Messages sind in Englisch zu verfassen.**

**Format:**
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Beispiele:**

✅ Korrekt:
```
feat(core): add SourceCollect.cmake module

- Implements three collection modes: explicit, glob, auto
- Adds collect_files() helper for controlled wildcards
- Includes C++20 module support (experimental)
```

❌ Falsch:
```
feat(core): SourceCollect.cmake Modul hinzugefügt

- Implementiert drei Sammel-Modi: explicit, glob, auto
```

### 4.2 Branch-Namen

| Typ | Format | Beispiel |
|-----|--------|----------|
| Feature | `feature/<description>` | `feature/source-collect-module` |
| Bugfix | `fix/<description>` | `fix/context-scope-issue` |
| Release | `release/<version>` | `release/0.1.0` |
| Hotfix | `hotfix/<description>` | `hotfix/critical-path-error` |

### 4.3 Tags

```
v0.1.0
v0.1.0-rc.1
v0.1.0-beta.1
```

### 4.4 Pull Requests / Merge Requests

| Element | Sprache |
|---------|---------|
| Titel | 🇬🇧 Englisch |
| Beschreibung | 🇬🇧 Englisch |
| Kommentare | 🇬🇧 Englisch (bevorzugt) oder 🇩🇪 Deutsch im Team |

---

## 5. Fehlermeldungen & Logs

### 5.1 User-Facing Messages

> **Alle Meldungen die Entwickler sehen sind in Englisch.**

```cmake
# ✅ Korrekt
cmake_fatal("E001" "Executable 'MyApp': Required field 'name' missing")
cmake_warn("W110" "GLOB fallback active - explicit Source.cmake recommended")

# ❌ Falsch  
cmake_fatal("E001" "Executable 'MyApp': Pflichtfeld 'name' fehlt")
```

### 5.2 Debug-Ausgaben

```cmake
# ✅ Korrekt
dbg(${DBG_COMMON} "Collecting sources for ${TARGET_NAME}" ID SOURCE_COLLECT)
dbg(${DBG_RARE} "  Found ${_count} source files" ID SOURCE_COLLECT)

# ❌ Falsch
dbg(${DBG_COMMON} "Sammle Quellen für ${TARGET_NAME}" ID SOURCE_COLLECT)
```

### 5.3 Fehlercodes-Dokumentation

Die ErrorCodes-Referenz wird zweisprachig geführt:

| Code | English | Deutsch |
|------|---------|---------|
| E001 | Required field missing | Pflichtfeld fehlt |
| E104 | Source.cmake not found | Source.cmake nicht gefunden |

---

## 6. Glossar & Konsistenz

### 6.1 Technische Begriffe

Einige Begriffe werden **nicht übersetzt**:

| Begriff | Verwendung | Begründung |
|---------|------------|------------|
| Target | CMake Target | CMake-Fachbegriff |
| Preset | CMake Preset | CMake-Fachbegriff |
| Context | Context-Pattern | Projekt-spezifischer Begriff |
| External | Externe Abhängigkeit | Projekt-spezifischer Begriff |
| Solution | Solution.json | Projekt-spezifischer Begriff |

### 6.2 Übersetzungs-Glossar

| Deutsch | Englisch | Kontext |
|---------|----------|---------|
| Ausführbare Datei | Executable | Target-Typ |
| Bibliothek | Library | Target-Typ |
| Abhängigkeit | Dependency | Build-Konfiguration |
| Pflichtfeld | Required field | Validierung |
| Warnung | Warning | Fehlerbehandlung |
| Verzeichnis | Directory | Dateisystem |

---

## 7. Checkliste

### 7.1 Neue Code-Datei

- [ ] Alle Variablennamen in Englisch
- [ ] Alle Funktionsnamen in Englisch
- [ ] Alle Kommentare in Englisch
- [ ] Alle Log-/Fehlermeldungen in Englisch
- [ ] Header-Dokumentation in Englisch

### 7.2 Neue Dokumentation

- [ ] Deutsche Arbeitsversion erstellt
- [ ] Fachbegriffe konsistent verwendet
- [ ] Code-Beispiele in Englisch
- [ ] Vor Release: Englische Übersetzung erstellen

### 7.3 Git Commit

- [ ] Commit Message in Englisch
- [ ] Branch-Name in Englisch
- [ ] Aussagekräftige Beschreibung

---

## 8. Migration bestehender Artefakte

### 8.1 Priorisierung

| Priorität | Artefakt | Aufwand |
|-----------|----------|---------|
| **1 (Hoch)** | CMake-Module (.cmake) | Kommentare, Fehlermeldungen |
| **2 (Mittel)** | ErrorCodes-Referenz | Zweisprachig führen |
| **3 (Normal)** | Konzept-Dokumentationen | Englische Version erstellen |
| **4 (Niedrig)** | Modul-Dokumentationen | Englische Version erstellen |

### 8.2 Migrations-Workflow

1. **Audit:** Betroffene Dateien identifizieren
2. **Planung:** Aufwand schätzen, priorisieren
3. **Umsetzung:** Schrittweise migrieren
4. **Review:** Konsistenz prüfen
5. **Dokumentation:** Änderungen nachführen

---

## 9. Siehe auch

- [Documentation_Blueprint](../Blueprints/Documentation_Blueprint_v0_1_0.md) – Dokumentations-Struktur
- [CMake_Blueprint](../Blueprints/CMake_Blueprint_v0_1_0.md) – CMake-Modul-Struktur
- [guidelines](../Concepts/guidelines_v0_1_0.md) – CMake Coding-Konventionen

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.1** | **2025-12-04** | **Dateistruktur: /de/ und /en/ Subfolder statt Suffix-Variante** |
| 0.1.0 | 2025-12-04 | Initial: Code-Sprache, Dokumentations-Sprache, Git, Migration |
