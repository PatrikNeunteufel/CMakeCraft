# Documentation Blueprint – CMake Architecture V2

> **Version:** 0.1.0  
> **Datum:** 2025-12-03  
> **Typ:** Blueprint  
> **Status:** In Entwicklung (Pre-Release)  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Blueprints/Documentation_Blueprint_v0_1_0.md)

Dieses Dokument definiert die **verbindliche Struktur** für alle Dokumentationen im CMake Architecture V2 Projekt. Ziel ist 100% Konsistenz über alle Dokumente hinweg.

---

## 1. Dokumentations-Typen

Es gibt **sechs Haupttypen** von Dokumentationen:

| Typ | Zielgruppe | Fokus | Versionierung | Beispiele |
|-----|------------|-------|---------------|-----------|
| **Modul-Doku** | Build-System-Entwickler | Wie funktioniert das Modul intern? | Modul-gebunden (siehe 2.2) | Context.cmake, Json.cmake, SourceCollect.cmake |
| **Konzept-Doku** | Build-System-Entwickler | Architektur, Design-Entscheidungen | Eigenständig SemVer | master_concept, guidelines |
| **Referenz-Doku** | Build-System-Entwickler | Nachschlagewerk, Spezifikationen | Eigenständig SemVer | ErrorCodes, Solution_Schema, CMakePresets_Manual |
| **Benutzer-Doku** | C++ Entwickler (Endnutzer) | Wie nutze ich das System? | Eigenständig SemVer | UserManual, QuickStart, FAQ |
| **Unternehmens-Doku** | Alle Entwickler | Team-/Unternehmensweite Standards | Unabhängig | CodingStandards, ReviewGuidelines, GitWorkflow |
| **Blueprint** | Dokumentations-Ersteller | Standards für Dokumente/Code | Eigenständig SemVer | Documentation_Blueprint, CMake_Blueprint |

### 1.1 Typ-Beschreibungen

#### Modul-Dokumentation
Dokumentiert ein einzelnes CMake-Modul (.cmake Datei). Enthält API-Referenz, Konzept, Beispiele. Versionierung ist an das Modul gekoppelt.

#### Konzept-Dokumentation
Beschreibt übergreifende Architektur und Design-Entscheidungen. Nicht an einzelne Module gebunden.

#### Referenz-Dokumentation
Nachschlagewerke wie Error Codes, Schema-Definitionen, Preset-Übersichten. Wird bei Bedarf aktualisiert.

#### Benutzer-Dokumentation
Für Entwickler die das Build-System **nutzen**, nicht entwickeln. Fokus auf Solution.json und Presets. Keine CMake-Interna.

#### Unternehmens-Dokumentation
Standards die **unabhängig** vom CMake-Projekt gelten. Können in separatem Repository liegen.

#### Blueprint
Meta-Dokumentationen die **Standards definieren** für andere Dokumente oder Code. Selbst-referenzierend (dieser Blueprint beschreibt auch sich selbst).

### 1.2 Geplante Dokumente

> **Status-Legende:**  
> ✅ Vorhanden | 🔄 In Arbeit | ⬜ Ausstehend

#### Blueprints
| Dokument | Status | Beschreibung |
|----------|--------|--------------|
| Documentation_Blueprint | 🔄 | Dieses Dokument |
| CMake_Blueprint | 🔄 | Struktur für CMake-Module |

#### Konzept-Dokumentationen
| Dokument | Status | Beschreibung |
|----------|--------|--------------|
| master_concept | ⬜ | Architektur-Übersicht, Vision |
| guidelines | ⬜ | CMake Coding-Konventionen |
| implementation_plan | ⬜ | Phasen-basierter Implementierungsplan |

#### Referenz-Dokumentationen
| Dokument | Status | Beschreibung |
|----------|--------|--------------|
| ErrorCodes | ⬜ | Alle Fehlercodes mit Erklärungen |
| Solution_Schema | ⬜ | JSON-Schema für Solution.json |
| CMakePresets_Manual | ⬜ | Preset-Konfiguration und Verwendung |
| Externals | ⬜ | Verfügbare Externals und deren Options |

#### Modul-Dokumentationen
| Modul | Status | Beschreibung |
|-------|--------|--------------|
| Errors.cmake | ⬜ | Fehlerbehandlung |
| Debug.cmake | ⬜ | Debug-System |
| Context.cmake | ⬜ | Context-Objekt-Pattern |
| Json.cmake | ⬜ | JSON-Hilfsfunktionen |
| Validation.cmake | ⬜ | Schema-Validierung |
| SourceCollect.cmake | ⬜ | Source-Datei-Management |
| CompilerOptions.cmake | ⬜ | Compiler-Konfiguration |
| Warnings.cmake | ⬜ | Warning-Level |
| OutputDirs.cmake | ⬜ | Output-Verzeichnisse |

#### Benutzer-Dokumentationen
| Dokument | Status | Beschreibung |
|----------|--------|--------------|
| UserManual | ⬜ | Vollständige Benutzeranleitung |
| QuickStart | ⬜ | Schnelleinstieg |
| FAQ | ⬜ | Häufig gestellte Fragen |

#### Unternehmens-Dokumentationen
| Dokument | Status | Beschreibung |
|----------|--------|--------------|
| CodingStandards | ⬜ | C++ Coding-Konventionen |
| ReviewGuidelines | ⬜ | Code Review Richtlinien |
| GitWorkflow | ⬜ | Branch-Strategie, Commits, PRs |

---

## 2. Versionierung

### 2.1 Semantic Versioning (MAJOR.MINOR.PATCH)

Alle Dokumentationen verwenden Semantic Versioning:

| Teil | Bedeutung | Wann erhöhen? |
|------|-----------|---------------|
| **0.x.x** | Pre-Release | Noch nicht stabil/released |
| **MAJOR** | Breaking | Grundlegende Umstrukturierung, inkompatible Änderungen |
| **MINOR** | Feature | Neue Abschnitte, signifikante Ergänzungen |
| **PATCH** | Fix | Korrekturen, Klarstellungen, Tippfehler |

**Pre-Release Konvention:**
- `0.1.0` - Erste funktionsfähige Version
- `0.x.x` - In aktiver Entwicklung
- `1.0.0` - Erstes stabiles Release

### 2.2 Modul-Dokumentationen: 4-teilige Versionierung

Für Dokumentationen die zu einem CMake-Modul gehören:

```
[ModulName]_cmake_v[MAJOR]_[MINOR]_[PATCH]_doc_v[N].md
                    └─────────┬─────────┘     └─┬─┘
                        Modul-Version      Doku-Revision
```

| Teil | Beschreibung |
|------|--------------|
| `MAJOR.MINOR.PATCH` | Version des CMake-Moduls |
| `N` | Doku-Revision (1, 2, 3, ...) - nur Doku-Änderungen |

**Beispiele:**
```
Context_cmake_v0_1_0_doc_v1.md      # Modul 0.1.0, erste Doku
Context_cmake_v0_1_0_doc_v2.md      # Modul 0.1.0, Doku überarbeitet
Context_cmake_v0_1_1_doc_v1.md      # Modul 0.1.1 (Patch), neue Doku
Context_cmake_v0_2_0_doc_v1.md      # Modul 0.2.0 (Minor), neue Doku
```

**Wann Doku-Revision erhöhen:**
- Tippfehler korrigiert
- Beispiele hinzugefügt/verbessert
- Klarstellungen ohne Modul-Änderung

**Wann neue Modul-Version:**
- Modul-Code wurde geändert
- Neue API-Funktionen
- Behavior-Änderungen

### 2.3 Andere Dokumentations-Typen

Diese haben eigenständige SemVer-Versionierung:

| Typ | Format | Beispiele |
|-----|--------|-----------|
| Konzept-Doku | `[name]_v[X]_[Y]_[Z].md` | `master_concept_v0_1_0.md` |
| Referenz-Doku | `[Name]_v[X]_[Y]_[Z].md` | `ErrorCodes_v0_1_0.md` |
| Benutzer-Doku | `[Name]_v[X]_[Y]_[Z].md` | `UserManual_v0_1_0.md` |
| Unternehmens-Doku | `[Name]_v[X]_[Y].md` | `CodingStandards_v0_1.md` |
| Blueprint | `[Name]_Blueprint_v[X]_[Y]_[Z].md` | `Documentation_Blueprint_v0_1_0.md` |

---

## 3. Dateinamen-Konventionen

### 3.1 Allgemeine Regeln

| Regel | Richtig | Falsch |
|-------|---------|--------|
| Keine Leerzeichen | `Error_Codes` | `Error Codes` |
| Underscores als Trenner | `Error_Codes` | `ErrorCodes`, `Error-Codes` |
| Lowercase `v` vor Versionen | `v0_1_0` | `V0_1_0` |
| Underscores in Versionen | `v0_1_0` | `v0.1.0` |
| Punkte nur für Extension | `...v0_1_0.md` | `...v0.1.0.md` |

### 3.2 Dateinamen nach Typ

#### Blueprint
```
[Name]_Blueprint_v[X]_[Y]_[Z].md
```
Beispiele:
- `Documentation_Blueprint_v0_1_0.md`
- `CMake_Blueprint_v0_1_0.md`

#### Modul-Dokumentation
```
[ModulName]_cmake_v[X]_[Y]_[Z]_doc_v[N].md
```
Beispiele:
- `Context_cmake_v0_1_0_doc_v1.md`
- `Json_cmake_v0_1_0_doc_v1.md`
- `SourceCollect_cmake_v0_1_0_doc_v1.md`

#### Konzept-Dokumentation
```
[name]_v[X]_[Y]_[Z].md
```
Beispiele:
- `master_concept_v0_1_0.md`
- `guidelines_v0_1_0.md`
- `implementation_plan_v0_1_0.md`

#### Referenz-Dokumentation
```
[Name]_v[X]_[Y]_[Z].md
```
Beispiele:
- `ErrorCodes_v0_1_0.md`
- `Solution_Schema_v0_1_0.md`
- `CMakePresets_Manual_v0_1_0.md`

#### Benutzer-Dokumentation
```
[Name]_v[X]_[Y]_[Z].md
```
Beispiele:
- `UserManual_v0_1_0.md`
- `QuickStart_v0_1_0.md`
- `FAQ_v0_1_0.md`

#### Unternehmens-Dokumentation
```
[Name]_v[X]_[Y].md
```
Beispiele:
- `CodingStandards_v0_1.md`
- `ReviewGuidelines_v0_1.md`
- `GitWorkflow_v0_1.md`

---

## 4. Dokument-Struktur

### 4.1 Kopfbereich (Header)

#### Alle Dokumentationen (Pflichtfelder)

```markdown
# [Titel]

> **Version:** X.Y.Z  
> **Datum:** YYYY-MM-DD  
> **Typ:** [Blueprint | Modul-Doku | Konzept-Doku | Referenz-Doku | Benutzer-Doku | Unternehmens-Doku]  
> **Status:** [In Entwicklung | Stabil | Deprecated]  
> **Basiert auf:** [Abhängige Dokumente mit Versionen]
```

#### Zusätzlich für Modul-Dokumentationen

```markdown
# [ModulName].cmake – Dokumentation

> **Version:** X.Y.Z (doc vN)  
> **Datum:** YYYY-MM-DD  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung  
> **Modul:** cmake/[pfad]/[ModulName].cmake  
> **Modul-Version:** X.Y.Z  
> **Basiert auf:** master_concept v0.1, guidelines v0.1
```

### 4.2 Standardabschnitte nach Typ

#### Blueprint

```
1. Übersicht / Einleitung
2. [Thematische Abschnitte - das Regelwerk]
3. Beispiele / Templates
4. Review-Checkliste
5. Siehe auch
6. Changelog
```

#### Modul-Dokumentation

```
1. Übersicht
2. Abhängigkeiten
3. Konzept / Design
4. API-Referenz
5. Verwendungsbeispiele
6. Fehlerbehandlung / Error Codes
7. Best Practices
8. Bekannte Einschränkungen (optional)
9. Migration von früheren Versionen (wenn Breaking Changes)
10. Siehe auch
11. Changelog
```

#### Konzept-Dokumentation

```
1. Vision / Einleitung
2. Kernprinzipien
3. [Thematische Abschnitte]
4. Tests
5. Dokumentation (Meta-Referenzen)
6. Changelog
```

#### Referenz-Dokumentation

```
1. Übersicht / Einleitung
2. Konventionen
3. [Kategorisierte Einträge]
4. Schnellreferenz (Tabelle)
5. Verwendung in Code
6. Debugging
7. Siehe auch
8. Changelog
```

#### Benutzer-Dokumentation

```
1. Einführung / Übersicht
2. Voraussetzungen
3. Schnellstart
4. [Aufgabenorientierte Abschnitte]
   - "Wie füge ich ein Executable hinzu?"
   - "Wie konfiguriere ich Externals?"
5. Häufige Probleme / Troubleshooting
6. Referenz (Kurzübersicht)
7. Changelog
```

#### Unternehmens-Dokumentation

```
1. Zweck / Geltungsbereich
2. [Thematische Abschnitte]
3. Beispiele
4. Ausnahmen
5. Changelog
```

### 4.3 Changelog-Format

Der Changelog steht **immer am Ende** des Dokuments:

```markdown
---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **X.Y.Z** | **YYYY-MM-DD** | **[Aktuelle Änderung - fett]** |
| X.Y.Z-1 | YYYY-MM-DD | Vorherige Änderung |
| ... | ... | ... |
| 0.1.0 | YYYY-MM-DD | Initial |
```

**Regeln:**
- Neueste Version zuerst
- Aktuelle Version **fett** markiert
- Kurze, prägnante Beschreibungen
- Bei Breaking Changes: explizit mit ⚠️ kennzeichnen

---

## 5. Formatierungs-Regeln

### 5.1 Überschriften

```markdown
# Haupttitel (H1) – nur einmal pro Dokument

## Hauptabschnitt (H2)

### Unterabschnitt (H3)

#### Detail (H4) – sparsam verwenden
```

### 5.2 Tabellen

Immer mit Header-Zeile:

```markdown
| Spalte 1 | Spalte 2 | Beschreibung |
|----------|----------|--------------|
| Wert 1 | Wert 2 | Text |
```

### 5.3 Code-Blöcke

Mit Sprach-Annotation:

````markdown
```cmake
# CMake-Code
function(my_function)
endfunction()
```

```json
{
    "key": "value"
}
```

```bash
cmake -B build
```
````

### 5.4 Hervorhebungen

| Element | Verwendung |
|---------|------------|
| **Fett** | Wichtige Begriffe, Betonungen |
| `Code` | Variablen, Funktionsnamen, Dateipfade |
| *Kursiv* | Selten, für Zitate oder Fachbegriffe |
| ~~Durchgestrichen~~ | Deprecated |
| > Blockquote | Hinweise, Warnungen |

### 5.5 Hinweise und Warnungen

```markdown
> **Hinweis:** Allgemeine Information

> **Wichtig:** Kritische Information

> **Warnung:** Potenzielle Probleme

> **DEPRECATED seit vX.Y:** Veraltete Features, mit Migrations-Hinweis
```

### 5.6 Status-Icons

```markdown
✅ Erledigt / Vorhanden
🔄 In Arbeit
⬜ Ausstehend / Geplant
⚠️ Warnung / Breaking Change
❌ Fehler / Nicht unterstützt
```

---

## 6. Inhaltliche Regeln

### 6.1 Vollständigkeit

- **Alle** Features des Moduls dokumentieren
- **Alle** Parameter jeder Funktion beschreiben
- **Alle** Error Codes mit Beispielen

### 6.2 Konsistenz

- Gleiche Begriffe durchgehend verwenden
- Versionsnummern in Querverweisen aktuell halten
- Querverweise auf andere Dokumente mit Version

### 6.3 Deprecation

Wenn Features veraltet sind:

```markdown
### ~~alteFunktion()~~ [DEPRECATED seit v0.2]

> **DEPRECATED seit v0.2:** Verwende stattdessen `neueFunktion()`. 
> Wird in v1.0 entfernt.

[Ursprüngliche Dokumentation bleibt erhalten]
```

### 6.4 Breaking Changes

Bei Breaking Changes einen eigenen Abschnitt **vor** dem Konzept-Teil:

```markdown
---

## ⚠️ Breaking Changes in v0.2.0

### Von v0.1.x zu v0.2.0

| Vorher (v0.1.x) | Nachher (v0.2.0) | Migration |
|-----------------|------------------|-----------|
| `old_api()` | `new_api()` | Ersetzen |
| `PARENT_SCOPE` | `GLOBAL PROPERTY` | Automatisch |

---

## Konzept
...
```

---

## 7. Review-Checkliste

Vor Fertigstellung einer Dokumentation prüfen:

- [ ] Header vollständig (Version, Datum, Typ, Status, Basiert auf)
- [ ] Bei Modul-Doku: Modul-Pfad und Modul-Version angegeben
- [ ] Dateiname entspricht Konvention (siehe Abschnitt 3)
- [ ] Alle Pflichtabschnitte vorhanden (siehe Abschnitt 4.2)
- [ ] Reihenfolge der Abschnitte korrekt
- [ ] Changelog aktuell und am Ende
- [ ] Querverweise mit Versionen
- [ ] Code-Beispiele verifiziert
- [ ] Keine TODO/FIXME übrig
- [ ] Konsistente Terminologie
- [ ] Deprecated-Features korrekt markiert
- [ ] Breaking Changes dokumentiert (wenn vorhanden)

---

## 8. Siehe auch

- [CMake_Blueprint](CMake_Blueprint_v0_1_0.md) – Struktur für CMake-Module
- [guidelines](guidelines_v0_1_0.md) – CMake Coding-Konventionen

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-03** | **Initial: 6 Dokumentations-Typen, 4-teilige Versionierung für Modul-Dokus, Dateinamen-Konventionen, Pre-Release Start mit v0.x.x** |
