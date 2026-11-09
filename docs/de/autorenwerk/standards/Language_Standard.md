# Language Standard – Sprachrichtlinien

> **Version:** 1.0.1  
> **Datum:** 2026-11-09  
> **Typ:** Standard  
> **Status:** Stabil  
> **Zielgruppe:** Alle Entwickler  
> **Geltungsbereich:** Code, Dokumentation, Git, Kommunikation  
> **Durchsetzung:** Code Review, CI (Commit-Message-Linting)  
> **Sprache:** Deutsch  
> **English:** [Language_Standard.md](../../../en/autorenwerk/standards/Language_Standard.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Geltungsbereich](#2-geltungsbereich)
3. [Code-Sprache](#3-code-sprache)
4. [Dokumentations-Sprache](#4-dokumentations-sprache)
5. [Git und Repository](#5-git-und-repository)
6. [Fehlermeldungen und Logs](#6-fehlermeldungen-und-logs)
7. [Glossar und Konsistenz](#7-glossar-und-konsistenz)
8. [Ausnahmen](#8-ausnahmen)
9. [Checkliste](#9-checkliste)
10. [Migration](#10-migration)
11. [Siehe auch](#11-siehe-auch)
12. [Changelog](#changelog)

---

## 1. Übersicht

Dieser Standard definiert **verbindliche Sprachrichtlinien** für alle Aspekte der Softwareentwicklung. Ziel ist Konsistenz und internationale Zugänglichkeit.

### Zielgruppe

Alle Entwickler, die Code schreiben, Dokumentation erstellen oder mit Git arbeiten. Dieser Standard ist verbindlich für alle neuen Projekte und empfohlen bei Modernisierung bestehender Projekte.

### Grundprinzip

| Bereich | Sprache | Begründung |
|---------|---------|------------|
| **Code & Technisches** | Englisch | International, Industrie-Standard |
| **Dokumentation (Release)** | Englisch (Pflicht) | Internationale Zugänglichkeit |
| **Dokumentation (Zusätzlich)** | Beliebig (erwünscht) | Maximiert Reichweite |
| **Git** | Englisch | Teil des technischen Kontexts |

### Mehrsprachen-Philosophie

- **Englisch ist Pflicht** für jede Veröffentlichung (z.B. GitHub)
- **Weitere Sprachen sind erwünscht** – sie maximieren die Reichweite
- **Primärsprache** kann je nach Team/Entwickler variieren (hier: Deutsch)
- Die Primärsprache ist **maßgeblich** (SSOT, siehe [Doku_Standard.md](Doku_Standard.md)); Englisch ist die
  vollständige Übersetzung für die Veröffentlichung

---

## 2. Geltungsbereich

### 2.1 Betroffene Artefakte

| Artefakt | Sprache | Anmerkung |
|----------|---------|-----------|
| `.cmake` | Englisch | CMake-Module, Presets |
| `.cpp`, `.hpp`, `.h`, `.c` | Englisch | C/C++ Code |
| `.py` | Englisch | Python-Skripte |
| `.sh`, `.bat`, `.ps1` | Englisch | Shell-Skripte |
| `.json` (technisch) | Englisch | CMakePresets.json, Solution.json |
| `.yaml`, `.yml` | Englisch | CI/CD, Konfiguration |
| `.md` (Dokumentation) | Mehrsprachig | Englisch Pflicht, weitere erwünscht |
| Git (Commits, Branches) | Englisch | Technischer Kontext |

### 2.2 Nicht betroffen

- UI-Texte mit Internationalisierung (i18n)
- Language Packs und Übersetzungsdateien
- Domänen-spezifische Fachbegriffe ohne englisches Äquivalent

---

## 3. Code-Sprache

### 3.1 Grundregel

**Regel:** Alle Code-Artefakte sind durchgehend in Englisch zu halten.

**Verbindlichkeit:** MUSS

### 3.2 Betroffene Elemente

| Element | Sprache | Beispiel |
|---------|---------|----------|
| Variablennamen | Englisch | `_source_count`, `_has_path` |
| Funktionsnamen | Englisch | `collect_sources()`, `validate_external()` |
| Kommentare | Englisch | `// Check if file exists` |
| Log-Ausgaben | Englisch | `"Source.cmake not found"` |
| Fehlermeldungen | Englisch | `"Missing required field 'name'"` |
| Docstrings | Englisch | Header-Kommentare, API-Dokumentation |

### 3.3 Beispiele

**Richtig:**
```cmake
# Check if source file exists
function(validate_source_path SOURCE_DIR)
    if(NOT EXISTS "${SOURCE_DIR}")
        cmake_fatal("E104" "Source directory not found: ${SOURCE_DIR}")
    endif()
endfunction()
```

**Falsch:**
```cmake
# Prüfe ob Source-Datei existiert
function(pruefe_source_pfad QUELL_VERZEICHNIS)
    if(NOT EXISTS "${QUELL_VERZEICHNIS}")
        cmake_fatal("E104" "Quellverzeichnis nicht gefunden: ${QUELL_VERZEICHNIS}")
    endif()
endfunction()
```

---

## 4. Dokumentations-Sprache

### 4.1 Mehrsprachen-Modell

| Sprache | Status | Beschreibung |
|---------|--------|--------------|
| **Englisch** | Pflicht | Vollständige Übersetzung für die Veröffentlichung, internationale Zugänglichkeit |
| **Primärsprache** | Maßgeblich, wo vorhanden | Quelle aller Übersetzungen (hier Deutsch, SSOT) |
| **Weitere Sprachen** | Erwünscht | Maximiert Reichweite, Community-Beiträge |

**Vorteile mehrerer Sprachen:**
- Größere internationale Reichweite
- Niedrigere Einstiegshürde für Nicht-Englisch-Muttersprachler
- Community kann Übersetzungen beitragen

### 4.2 Ordnerstruktur

```
docs/
├── de/                    ← Deutsch (Primärsprache hier, maßgeblich)
│   ├── guide/             ← module/, references/, userguides/, cheatsheets/
│   ├── konzepte/
│   └── autorenwerk/       ← blueprints/, standards/
│
├── en/                    ← Englisch (PFLICHT für Release, gleicher Baum)
│   ├── guide/
│   ├── konzepte/
│   └── autorenwerk/
│
├── fr/                    ← Französisch (optional)
├── es/                    ← Spanisch (optional)
├── zh/                    ← Chinesisch (optional)
└── ...                    ← Weitere Sprachen willkommen
```

### 4.3 Dateinamen

**Regel:** Eine Datei heißt in **jedem Sprachordner gleich** (gleicher relativer Pfad, gleicher Name). Der Name
darf aus der Primärsprache stammen (z. B. `Neues_Projekt_Guide.md`, `Glossar.md`); die Übersetzungen übernehmen ihn
unverändert.

**Verbindlichkeit:** MUSS

**Begründung:** Ermöglicht einfaches Mapping zwischen Sprachversionen (der Pre-Commit-Hook und die Kopfverweise
`English:`/`German:` setzen den gleichen Pfad voraus).

**Richtig:**
```
docs/de/guide/userguides/Qt6_Integration.md      ← Deutsch (maßgeblich)
docs/en/guide/userguides/Qt6_Integration.md      ← Englisch
docs/de/guide/userguides/Neues_Projekt_Guide.md  ← deutscher Name, in en gleich
docs/en/guide/userguides/Neues_Projekt_Guide.md
```

**Falsch:**
```
docs/de/guide/userguides/Qt6_Integration_Benutzerhandbuch.md
docs/en/guide/userguides/New_Project_Guide.md   ← anderer Name als in de
```

### 4.4 Dokumentations-Header

**Englisch (en/) – Pflicht:**
```markdown
# Module Name – Documentation

> **Version:** 1.0.0  
> **Language:** English  
> **German:** [Module_Name.md](../../../../de/guide/module/core/Module_Name.md)
```

**Primärsprache (hier de/, maßgeblich):**
```markdown
# Modul-Name – Dokumentation

> **Version:** 1.0.0  
> **Sprache:** Deutsch  
> **English:** [Module_Name.md](../../../../en/guide/module/core/Module_Name.md)
```

### 4.5 Übersetzungs-Regeln

| Regel | Beschreibung |
|-------|--------------|
| Primärsprache zuerst | Änderungen passieren zuerst in der maßgeblichen Primärsprache (hier `de/`) |
| Gleicher Commit | Die englische Fassung wird im selben Commit nachgezogen (der Pre-Commit-Hook meldet Lücken) |
| Release | Vor einer Veröffentlichung ist die englische Fassung vollständig |
| Vollständigkeit | Übersetzungen sind inhaltlich identisch |
| Fachbegriffe | Konsistent übersetzen (siehe Glossar) |
| Code-Beispiele | Bleiben unverändert (sind bereits Englisch) |
| Versionierung | Alle Sprachversionen haben gleiche Versionsnummer |
| Teilübersetzungen | Erlaubt – besser als keine Übersetzung |

### 4.6 Workflow für Übersetzungen

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Primärsprache  │ ──▶ │    Englisch     │ ──▶ │ Weitere Sprachen│
│  (Arbeitsversion)│     │  (Release-Pflicht)│     │   (Optional)    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

**Bei Veröffentlichung (z.B. GitHub):**
1. Englische Version muss vollständig sein
2. Primärsprache kann parallel existieren
3. Weitere Sprachen sind Bonus

---

## 5. Git und Repository

### 5.1 Commit Messages

**Regel:** Commit Messages sind in Englisch zu verfassen.

**Verbindlichkeit:** MUSS

**Format:**
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Richtig:**
```
feat(core): add SourceCollect.cmake module

- Implements three collection modes: explicit, glob, auto
- Adds collect_files() helper for controlled wildcards
- Includes C++20 module support (experimental)
```

**Falsch:**
```
feat(core): SourceCollect.cmake Modul hinzugefügt

- Implementiert drei Sammel-Modi: explicit, glob, auto
```

### 5.2 Branch-Namen

**Regel:** Branch-Namen sind in Englisch zu halten.

**Verbindlichkeit:** MUSS

| Typ | Format | Beispiel |
|-----|--------|----------|
| Feature | `feature/<description>` | `feature/source-collect-module` |
| Bugfix | `fix/<description>` | `fix/context-scope-issue` |
| Release | `release/<version>` | `release/0.1.0` |
| Hotfix | `hotfix/<description>` | `hotfix/critical-path-error` |

### 5.3 Tags und Releases

**Regel:** Tags und Release-Notes sind in Englisch.

**Verbindlichkeit:** MUSS

```
v0.1.0
v0.1.0-rc.1
v0.1.0-beta.1
```

### 5.4 Pull/Merge Requests

| Element | Sprache | Verbindlichkeit |
|---------|---------|-----------------|
| Titel | Englisch | MUSS |
| Beschreibung | Englisch | SOLL |
| Kommentare | Englisch oder Deutsch | KANN |

---

## 6. Fehlermeldungen und Logs

### 6.1 User-Facing Messages

**Regel:** Alle Meldungen die Entwickler sehen sind in Englisch.

**Verbindlichkeit:** MUSS

**Richtig:**
```cmake
cmake_fatal("E001" "Executable 'MyApp': Required field 'name' missing")
cmake_warn("W110" "GLOB fallback active - explicit Source.cmake recommended")
```

**Falsch:**
```cmake
cmake_fatal("E001" "Executable 'MyApp': Pflichtfeld 'name' fehlt")
```

### 6.2 Debug-Ausgaben

**Richtig:**
```cmake
dbg(${DBG_COMMON} "Collecting sources for ${TARGET_NAME}" ID SOURCE_COLLECT)
dbg(${DBG_RARE} "  Found ${_count} source files" ID SOURCE_COLLECT)
```

**Falsch:**
```cmake
dbg(${DBG_COMMON} "Sammle Quellen für ${TARGET_NAME}" ID SOURCE_COLLECT)
```

### 6.3 ErrorCodes-Dokumentation

Die ErrorCodes-Referenz wird **zweisprachig** geführt:

| Code | English | Deutsch |
|------|---------|---------|
| E001 | Required field missing | Pflichtfeld fehlt |
| E104 | Source.cmake not found | Source.cmake nicht gefunden |

---

## 7. Glossar und Konsistenz

### 7.1 Nicht übersetzte Begriffe

Diese technischen Begriffe werden **nicht übersetzt**:

| Begriff | Kontext | Begründung |
|---------|---------|------------|
| Target | CMake | CMake-Fachbegriff |
| Preset | CMake | CMake-Fachbegriff |
| Context | Build-System | Projekt-spezifischer Begriff |
| External | Build-System | Projekt-spezifischer Begriff |
| Solution | Build-System | Projekt-spezifischer Begriff |
| Hook | Build-System | Etablierter Begriff |
| Pipeline | Build-System | Etablierter Begriff |

### 7.2 Übersetzungs-Glossar

| Deutsch | Englisch | Kontext |
|---------|----------|---------|
| Ausführbare Datei | Executable | Target-Typ |
| Bibliothek | Library | Target-Typ |
| Abhängigkeit | Dependency | Build-Konfiguration |
| Pflichtfeld | Required field | Validierung |
| Warnung | Warning | Fehlerbehandlung |
| Verzeichnis | Directory | Dateisystem |
| Geltungsbereich | Scope | Variablen |
| Arbeitsbereich | Workspace | Entwicklungsumgebung |

---

## 8. Ausnahmen

### 8.1 Erlaubte Abweichungen

| Situation | Erlaubte Sprache | Bedingung |
|-----------|------------------|-----------|
| UI-Texte mit i18n | Lokalisiert | Über Übersetzungssystem |
| Domänen-Fachbegriffe | Original | Kein englisches Äquivalent |
| Interne Team-Diskussion | Deutsch | PR-Kommentare, Chat |
| Legacy-Code | Deutsch (temporär) | Mit TODO zur Migration |

### 8.2 Dokumentation von Abweichungen

Intentionale Abweichungen müssen dokumentiert werden:

```cmake
# NOTE: German variable name retained for compatibility with legacy API
# TODO: Rename to english_name in v2.0.0
set(_deutscher_name "value")
```

---

## 9. Checkliste

### 9.1 Neue Code-Datei

- [ ] Alle Variablennamen in Englisch
- [ ] Alle Funktionsnamen in Englisch
- [ ] Alle Kommentare in Englisch
- [ ] Alle Log-/Fehlermeldungen in Englisch
- [ ] Header-Dokumentation in Englisch

### 9.2 Neue Dokumentation

- [ ] Primärsprache-Version erstellt (maßgeblich)
- [ ] Englische Version im selben Commit erstellt (Pflicht für Release)
- [ ] Fachbegriffe konsistent verwendet
- [ ] Code-Beispiele in Englisch
- [ ] Sprachverweis im Header vorhanden (`English:` bzw. `German:`)
- [ ] Dateiname in allen Sprachordnern gleich

### 9.3 Git Commit

- [ ] Commit Message in Englisch
- [ ] Branch-Name in Englisch
- [ ] Conventional Commit Format
- [ ] Aussagekräftige Beschreibung

### 9.4 Code Review

- [ ] Keine deutschen Variablen-/Funktionsnamen
- [ ] Keine deutschen Kommentare
- [ ] Keine deutschen Fehlermeldungen
- [ ] Glossar-Begriffe korrekt verwendet

---

## 10. Migration

### 10.1 Priorisierung

| Priorität | Artefakt | Aufwand |
|-----------|----------|---------|
| **1 (Hoch)** | CMake-Module (.cmake) | Kommentare, Fehlermeldungen |
| **2 (Mittel)** | ErrorCodes-Referenz | Zweisprachig führen |
| **3 (Normal)** | Konzept-Dokumentationen | Englische Version erstellen |
| **4 (Niedrig)** | Modul-Dokumentationen | Englische Version erstellen |

### 10.2 Migrations-Workflow

1. **Audit:** Betroffene Dateien identifizieren
2. **Planung:** Aufwand schätzen, priorisieren
3. **Umsetzung:** Schrittweise migrieren
4. **Review:** Konsistenz prüfen
5. **Dokumentation:** Änderungen nachführen

### 10.3 Legacy-Kennzeichnung

```cmake
# LEGACY: German comments - migration pending
# TODO(language): Translate to English before v1.0.0
```

---

## 11. Siehe auch

- [Git_Standard.md](Git_Standard.md) – Git-Workflow und Commit-Konventionen
- [Cpp_Coding_Standard.md](Cpp_Coding_Standard.md) – C++ Code-Stil
- [CMake_Standard.md](CMake_Standard.md) – Build-System-Konventionen
- [Doc.md](../blueprints/Doc.md) – Dokumentations-Regeln
- [Structure.md](../blueprints/Structure.md) – Ordnerstruktur

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| 1.0.1 | 2026-11-09 | An `Doku_Standard` angeglichen (Entscheid S1 a): Primärsprache maßgeblich, Englisch im selben Commit (§1, §4.1, §4.5, §9.2); Dateinamen in allen Sprachordnern gleich, Namen aus der Primärsprache zulässig (§4.3); Ordnerbaum und Kopfbeispiele auf den heutigen Baum (§4.2, §4.4) |
| 1.0.0 | 2025-12-26 | Release 1 (aus newCMake übernommen, `2e00db7`) |
| **0.5.0** | **2025-12-14** | **Migration auf Blueprint v0.5: Neuer Header, Inhaltsverzeichnis mit Ankern, Kapitel-Nummerierung, Mehrsprachen-Modell (Englisch Pflicht, weitere Sprachen erwünscht), Verbindlichkeits-Stufen, Checklisten erweitert** |
| 0.1.1 | 2025-12-04 | Dateistruktur: /de/ und /en/ Subfolder statt Suffix-Variante |
| 0.1.0 | 2025-12-04 | Initial: Code-Sprache, Dokumentations-Sprache, Git, Migration |
