# README — Standard für Ordner-Navigations-Dokumente

> **Version:** 0.1.0  
> **Datum:** 2025-12-15  
> **Typ:** Blueprint  
> **Status:** In Entwicklung  
> **Basiert auf:** Doc v0.5.1, Blueprint v0.5  
> **Zielgruppe:** Dokumentations-Ersteller  
> **Sprache:** Deutsch  
> **English:** [README_Blueprint.md](../../en/blueprints/README_Blueprint.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Geltungsbereich](#2-geltungsbereich)
3. [Dateinamen-Konventionen](#3-dateinamen-konventionen)
4. [Header-Struktur](#4-header-struktur)
5. [Inhaltliche Struktur](#5-inhaltliche-struktur)
6. [Quick-Start Abschnitt](#6-quick-start-abschnitt)
7. [Datei- und Ordner-Beschreibungen](#7-datei--und-ordner-beschreibungen)
8. [Beispiele](#8-beispiele)
9. [Review-Checkliste](#9-review-checkliste)
10. [Siehe auch](#10-siehe-auch)
11. [Changelog](#11-changelog)

---

## 1. Übersicht

Dieser Blueprint definiert **verbindliche Regeln für README.md Dateien**, die als Navigations- und Orientierungshilfe in jedem Ordner dienen.

### Zielgruppe

- **Dokumentations-Ersteller**, die README-Dateien verfassen
- **Neue Team-Mitglieder**, die sich im Projekt orientieren

### Was dieser Blueprint regelt

| Bereich | Regeln |
|---------|--------|
| Dateinamen | Sprach-Suffixe, Verzeichnis-abhängige Konventionen |
| Header | Pflichtfelder, Sprach-Links |
| Struktur | Quick-Start, Dateibeschreibungen, Ordner-Links |
| Zielgruppe | Navigation für Neulinge und erfahrene Nutzer |

### Zweck von README-Dateien

| Aspekt | Beschreibung |
|--------|--------------|
| **Primär** | Schnelle Orientierung im Ordner |
| **Sekundär** | Einstiegspunkt für Neulinge (Quick-Start) |
| **Tertiär** | Navigation zu Unterordnern und verwandten Dokumenten |

---

## 2. Geltungsbereich

### 2.1 Wo README-Dateien benötigt werden

Jeder Ordner mit Dokumentation oder Code **SOLLTE** eine README.md enthalten:

| Ordner-Typ | README erforderlich |
|------------|---------------------|
| `docs/` | ✓ Pflicht |
| `docs/de/`, `docs/en/` | ✓ Pflicht |
| `docs/de/blueprints/` | ✓ Pflicht |
| `docs/de/modules/core/` | ✓ Pflicht |
| `cmake/` | ✓ Empfohlen |
| Projekt-Root | ✓ Pflicht (GitHub-Standard) |

### 2.2 Ausnahmen

Keine README erforderlich für:
- Sehr kleine Ordner mit nur 1-2 selbsterklärenden Dateien
- Temporäre oder generierte Ordner

---

## 3. Dateinamen-Konventionen

### 3.1 Grundprinzip

| Kontext | Dateiname | Sprache |
|---------|-----------|---------|
| **Standard** | `README.md` | Englisch |
| **Andere Sprache** | `README_de.md`, `README_fr.md` | Entsprechend Suffix |
| **In Sprach-Verzeichnis** (`/de/`, `/en/`) | `README.md` | Sprache des Verzeichnisses |

### 3.2 Beispiele

```
project/
├── README.md                    ← Englisch (Standard)
├── README_de.md                 ← Deutsch (optional)
│
├── cmake/
│   ├── README.md                ← Englisch
│   └── README_de.md             ← Deutsch (optional)
│
└── docs/
    ├── README.md                ← Englisch (Übersicht)
    │
    ├── de/
    │   ├── README.md            ← Deutsch (im /de/ Ordner)
    │   ├── blueprints/
    │   │   └── README.md        ← Deutsch (erbt von /de/)
    │   └── modules/
    │       └── README.md        ← Deutsch (erbt von /de/)
    │
    └── en/
        ├── README.md            ← Englisch (im /en/ Ordner)
        └── blueprints/
            └── README.md        ← Englisch (erbt von /en/)
```

### 3.3 Sprach-Vererbung

READMEs in Unterordnern von `/de/` oder `/en/` erben die Sprache:

| Pfad | Sprache | Begründung |
|------|---------|------------|
| `docs/de/blueprints/README.md` | Deutsch | Unterordner von `/de/` |
| `docs/en/modules/README.md` | Englisch | Unterordner von `/en/` |
| `cmake/README.md` | Englisch | Kein Sprach-Verzeichnis |
| `cmake/README_de.md` | Deutsch | Expliziter Suffix |

---

## 4. Header-Struktur

### 4.1 Vereinfachter Header für READMEs

READMEs verwenden einen **vereinfachten Header** ohne Typ/Status/Zielgruppe:

```markdown
# [Ordnername] — [Kurzbeschreibung]

> **Version:** X.Y.Z  
> **Datum:** YYYY-MM-DD  
> **Sprache:** Deutsch  
> **English:** [README.md](pfad/zur/englischen/version)
```

### 4.2 Header-Felder

| Feld | Pflicht | Beschreibung |
|------|---------|--------------|
| **Version** | ✓ | SemVer, synchron mit Ordnerinhalt |
| **Datum** | ✓ | Letzte Aktualisierung |
| **Sprache** | ✓ | `Deutsch` oder `English` |
| **English** | ✓ (nur nicht-EN) | Link zur englischen Version |

### 4.3 Sprach-Links

**Für nicht-englische READMEs** (außerhalb von `/en/`):

```markdown
> **English:** [README.md](../../en/ordner/README.md)
```

**Für englische READMEs** (außerhalb von Sprach-Verzeichnissen):

```markdown
> **Deutsch:** [README_de.md](./README_de.md)
```

**In Sprach-Verzeichnissen** (`/de/`, `/en/`):

```markdown
# In /de/blueprints/README.md:
> **English:** [README.md](../../en/blueprints/README.md)

# In /en/blueprints/README.md:
> **Deutsch:** [README.md](../../de/blueprints/README.md)
```

---

## 5. Inhaltliche Struktur

### 5.1 Pflicht-Abschnitte

Jede README **MUSS** diese Abschnitte enthalten:

| # | Abschnitt | Inhalt |
|---|-----------|--------|
| 1 | Quick-Start | Einstieg für Neulinge |
| 2 | Übersicht | Zweck des Ordners |
| 3 | Dateien | Beschreibung + Links |
| 4 | Unterordner | Falls vorhanden, mit Links |

### 5.2 Optionale Abschnitte

| Abschnitt | Wann sinnvoll |
|-----------|---------------|
| Siehe auch | Verwandte Ordner/Dokumente |
| Changelog | Bei häufigen Struktur-Änderungen |

### 5.3 Struktur-Template

```markdown
# [Ordnername] — [Kurzbeschreibung]

> **Version:** X.Y.Z  
> **Datum:** YYYY-MM-DD  
> **Sprache:** Deutsch  
> **English:** [README.md](pfad/zur/en/version)

---

## Quick-Start

[2-3 Sätze: Wofür ist dieser Ordner? Wo anfangen?]

---

## Übersicht

[Detailliertere Beschreibung des Ordnerzwecks]

---

## Dateien

| Datei | Beschreibung |
|-------|--------------|
| [Datei1.md](Datei1.md) | Kurzbeschreibung |
| [Datei2.md](Datei2.md) | Kurzbeschreibung |

---

## Unterordner

| Ordner | Beschreibung |
|--------|--------------|
| [ordner1/](ordner1/README.md) | Kurzbeschreibung |
| [ordner2/](ordner2/README.md) | Kurzbeschreibung |
```

---

## 6. Quick-Start Abschnitt

### 6.1 Zweck

Der Quick-Start ist der **wichtigste Teil** für neue Nutzer. Er beantwortet:
- Was finde ich hier?
- Wo fange ich an?
- Was sind die wichtigsten Dateien?

### 6.2 Aufbau

```markdown
## Quick-Start

**Neu hier?** Dieser Ordner enthält [Zweck]. 

Starte mit:
1. [Wichtigste_Datei.md](Wichtigste_Datei.md) — Grundlagen verstehen
2. [Zweite_Datei.md](Zweite_Datei.md) — Praktische Anwendung
```

### 6.3 Regeln

| Regel | Beschreibung |
|-------|--------------|
| **Kürze** | Maximal 5-7 Zeilen |
| **Aktionsorientiert** | Klare nächste Schritte |
| **Priorisiert** | Wichtigstes zuerst |
| **Verlinkt** | Direkte Links zu Einstiegsdokumenten |

### 6.4 Beispiele nach Ordner-Typ

**Für Blueprints:**
```markdown
## Quick-Start

**Neue Dokumentation erstellen?** Hier findest du alle Vorlagen.

Starte mit:
1. [Doc.md](Doc.md) — Grundregeln für alle Dokumentationen
2. Dann den passenden Typ: [Guide.md](Guide.md), [Reference.md](Reference.md), etc.
```

**Für Module:**
```markdown
## Quick-Start

**Das Build-System verstehen?** Hier sind alle CMake-Module dokumentiert.

Starte mit:
1. [core/](core/README.md) — Kern-Module (Errors, Context, Debug)
2. [project/](project/README.md) — Projekt-Module (Executables, Libraries)
```

---

## 7. Datei- und Ordner-Beschreibungen

### 7.1 Datei-Tabelle

Alle Dateien im Ordner werden in einer Tabelle aufgelistet:

```markdown
## Dateien

| Datei | Beschreibung |
|-------|--------------|
| [Blueprint.md](Blueprint.md) | Meta-Blueprint — wie man Blueprints schreibt |
| [Doc.md](Doc.md) | Allgemeine Regeln für alle Dokumentationen |
| [CMake.md](CMake.md) | Struktur für CMake-Scripts |
```

### 7.2 Ordner-Tabelle

Unterordner werden separat aufgelistet, mit Link zur README:

```markdown
## Unterordner

| Ordner | Beschreibung |
|--------|--------------|
| [core/](core/README.md) | Kern-Module (8 Module) |
| [externals/](externals/README.md) | External-Management |
| [project/](project/README.md) | Projekt-Pipeline |
```

### 7.3 Beschreibungs-Stil

| Gut | Schlecht |
|-----|----------|
| "Kern-Module (Errors, Context)" | "Enthält core Module" |
| "CMake-Modul-Dokumentation" | "Dokumentation" |
| "Architektur-Konzepte (ADR)" | "Konzepte und so" |

### 7.4 Gruppierung bei vielen Dateien

Bei > 10 Dateien können diese gruppiert werden:

```markdown
## Dateien

### Kern-Blueprints

| Datei | Beschreibung |
|-------|--------------|
| [Blueprint.md](Blueprint.md) | Meta-Blueprint |
| [Doc.md](Doc.md) | Dokumentations-Grundlagen |

### Dokumentations-Typen

| Datei | Beschreibung |
|-------|--------------|
| [Guide.md](Guide.md) | Benutzerhandbücher |
| [Reference.md](Reference.md) | Nachschlagewerke |
```

---

## 8. Beispiele

### 8.1 Vollständiges Beispiel: blueprints/README.md

```markdown
# Blueprints — Vorlagen und Standards

> **Version:** 0.5.0  
> **Datum:** 2025-12-15  
> **Sprache:** Deutsch  
> **English:** [README.md](../../en/blueprints/README.md)

---

## Quick-Start

**Neue Dokumentation erstellen?** Blueprints sind deine Vorlagen.

Starte mit:
1. [Doc.md](Doc.md) — Grundregeln für alle Dokumentationen
2. Wähle den passenden Typ: [Guide.md](Guide.md) für Anleitungen, [Reference.md](Reference.md) für Nachschlagewerke

---

## Übersicht

Die Blueprint-Sammlung definiert verbindliche Standards für:
- **Dokumentationen** aller Art (Guide, Reference, Concept, etc.)
- **CMake-Module** (.cmake Dateien)
- **Code-Standards** (C++, C)

Blueprints folgen einer Vererbungshierarchie: `Blueprint.md` → `Doc.md` → spezialisierte Typen.

---

## Dateien

| Datei | Beschreibung |
|-------|--------------|
| [Blueprint.md](Blueprint.md) | Meta-Blueprint — wie man Blueprints schreibt |
| [Doc.md](Doc.md) | Allgemeine Regeln für alle Dokumentationen |
| [ModuleDoc.md](ModuleDoc.md) | CMake-Modul-Dokumentation |
| [Guide.md](Guide.md) | Benutzerhandbücher (How-To) |
| [Reference.md](Reference.md) | Nachschlagewerke (Schema, API) |
| [Concept.md](Concept.md) | Architektur-Konzepte (ADR) |
| [Standard.md](Standard.md) | Coding/Project Standards |
| [Tutorial.md](Tutorial.md) | Step-by-Step Anleitungen |
| [CMake.md](CMake.md) | Struktur für CMake-Scripts |
| [Cpp.md](Cpp.md) | Struktur für C++/C Code |
| [Structure.md](Structure.md) | Dokumentations-Struktur |
```

### 8.2 Beispiel: Ordner ohne Unterordner

```markdown
# Core — Kern-Module

> **Version:** 0.5.0  
> **Datum:** 2025-12-15  
> **Sprache:** Deutsch  
> **English:** [README.md](../../../en/modules/core/README.md)

---

## Quick-Start

**Das Build-System verstehen?** Die Kern-Module sind das Fundament.

Starte mit:
1. [Errors.md](Errors.md) — Fehlerbehandlung verstehen
2. [Context.md](Context.md) — Globaler State-Management

---

## Übersicht

Die 8 Kern-Module bilden das Fundament des CMake Build-Systems:
- Fehlerbehandlung und Debugging
- Konfiguration und Validierung
- Output-Verzeichnisse und Compiler-Optionen

---

## Dateien

| Datei | Beschreibung |
|-------|--------------|
| [Errors.md](Errors.md) | Zentralisierte Fehlermeldungen (E0xx) |
| [Debug.md](Debug.md) | Debug-Output-System |
| [Context.md](Context.md) | Globaler Build-Context |
| [Json.md](Json.md) | JSON-Parsing Utilities |
| [Validation.md](Validation.md) | Schema-Validierung |
| [OutputDirs.md](OutputDirs.md) | Output-Verzeichnis-Struktur |
| [Warnings.md](Warnings.md) | Compiler-Warnungen |
| [CompilerOptions.md](CompilerOptions.md) | Compiler-Optionen |
```

---

## 9. Review-Checkliste

Vor Fertigstellung einer README prüfen:

**Header:**
- [ ] Version und Datum aktuell
- [ ] Sprache korrekt angegeben
- [ ] English-Link vorhanden (bei nicht-EN)
- [ ] English-Link zeigt auf korrekte Datei

**Quick-Start:**
- [ ] Vorhanden und kurz (max. 7 Zeilen)
- [ ] Klare nächste Schritte
- [ ] Links zu wichtigsten Dokumenten

**Dateien/Ordner:**
- [ ] Alle Dateien aufgelistet
- [ ] Alle Unterordner aufgelistet
- [ ] Links funktionieren
- [ ] Beschreibungen aussagekräftig

**Struktur:**
- [ ] Horizontale Trenner vor H2
- [ ] Keine Nummerierung der Abschnitte (Ausnahme von Doc.md)

---

## 10. Siehe auch

- [Doc.md](Doc.md) — Allgemeine Dokumentations-Regeln
- [Blueprint.md](Blueprint.md) — Meta-Blueprint
- [Structure.md](Structure.md) — Dokumentations-Struktur

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-15** | **Initial: Dateinamen-Konventionen, Quick-Start-Pflicht, Vereinfachter Header, Sprach-Vererbung** |
