# Structure — Standard für Dokumentations-Organisation

> **Version:** 1.0.1  
> **Datum:** 2026-11-09  
> **Typ:** Blueprint  
> **Status:** In Entwicklung  
> **Basiert auf:** Blueprint v0.5  
> **Zielgruppe:** Dokumentations-Ersteller, Projekt-Maintainer  
> **Sprache:** Deutsch  
> **English:** [Structure.md](../../../en/autorenwerk/blueprints/Structure.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Geltungsbereich](#2-geltungsbereich)
3. [Haupt-Ordnerstruktur](#3-haupt-ordnerstruktur)
4. [Verwendung vs. Erstellung](#4-verwendung-vs-erstellung)
5. [Ordner-Definitionen](#5-ordner-definitionen)
6. [Konzepte und Berichte](#6-konzepte-und-berichte)
7. [Entscheidungsbaum](#7-entscheidungsbaum)
8. [Beispiele](#8-beispiele)
9. [Siehe auch](#9-siehe-auch)



---

## 1. Übersicht

Dieser Blueprint definiert **wo Dokumentationen abgelegt werden**. Er ergänzt [Doc.md](Doc.md), welcher definiert *wie* Dokumentationen geschrieben werden.

### Zielgruppe

- **Dokumentations-Ersteller:** Wo lege ich mein Dokument ab?
- **Projekt-Maintainer:** Wie organisiere ich die Dokumentation?
- **Neue Team-Mitglieder:** Wo finde ich welche Information?

### Kernprinzip

Die Struktur trennt nach **Leserrolle** drei Bereiche (Einstieg: [INDEX.md](../../../INDEX.md)):

| Bereich | Frage | Zielgruppe |
|---------|-------|------------|
| **Verwendung** (`guide/`) | "Wie nutze ich das Build-System?" | Build-System-Benutzer |
| **Erstellung** (`konzepte/`) | "Wie entwickle ich das Build-System weiter?" | Build-System-Entwickler |
| **Autorenwerk** (`autorenwerk/`) | "Wie schreibe ich Code oder Doku — in jedem Projekt?" | Autoren von Code und Doku |

---

## 2. Geltungsbereich

Dieser Blueprint gilt für:

- Organisation der `docs/` Ordnerstruktur
- Zuordnung von Dokumentationstypen zu Ordnern
- Projektspezifische Dokumentation

**Nicht abgedeckt:**

- Dokumentations-Inhalt → siehe [Doc.md](Doc.md)
- Datei- und Ordnernamen-Konventionen → siehe [Doc.md](Doc.md)

> **Hinweis:** Ordnernamen werden immer kleingeschrieben.  
> Details siehe [Doc.md § 8.8](Doc.md#88-ordnernamen-konvention)

---

## 3. Haupt-Ordnerstruktur

```
docs/
├── INDEX.md                         # Einstieg und Landkarte
├── README.md
├── report/                          # Session-Reports, Befundlisten (ohne Sprachbaum)
│
├── de/                              # Deutsche Dokumentation (Führungssprache)
│   ├── README.md
│   │
│   │   ─────────────────────────────────────────────────
│   │   VERWENDUNG - Für Benutzer des Build-Systems
│   │   ─────────────────────────────────────────────────
│   │
│   ├── guide/
│   │   ├── userguides/              # How-To Anleitungen, Einstieg (Getting_Started.md)
│   │   ├── references/              # Nachschlagewerke (Schema, Fehlercodes, Glossar)
│   │   ├── cheatsheets/             # Kurzreferenzen
│   │   └── module/                  # Doku der cmake/-Module
│   │
│   │   ─────────────────────────────────────────────────
│   │   ERSTELLUNG - Für Entwickler des Build-Systems
│   │   ─────────────────────────────────────────────────
│   │
│   ├── konzepte/                    # Guidelines, aktive Konzepte
│   │   └── abgeschlossen/           # Umgesetzte Konzepte (Zeitdokumente)
│   │
│   │   ─────────────────────────────────────────────────
│   │   AUTORENWERK - Für Autoren, projektübergreifend
│   │   ─────────────────────────────────────────────────
│   │
│   └── autorenwerk/
│       ├── blueprints/              # Meta-Standards (Vorlagen)
│       └── standards/               # Allgemeine Coding Standards
│
└── en/                              # Englische Dokumentation
    └── [gleiche Struktur, gleiche Dateinamen]
```
> **Konvention:** Alle Ordnernamen sind kleingeschrieben.  
> Siehe [Doc.md § 8.8](Doc.md#88-ordnernamen-konvention)
---

## 4. Verwendung vs. Erstellung

### 4.1 Unterscheidung

| Aspekt | Verwendung | Erstellung |
|--------|------------|------------|
| **Zielgruppe** | C++ Entwickler, die das Build-System nutzen | Build-System-Entwickler |
| **Frage** | "Wie füge ich ein External hinzu?" | "Wie implementiere ich Phase 8?" |
| **Stabilität** | Stabil, öffentliche API | Kann sich ändern, intern |
| **Ordner** | `guide/` (`userguides/`, `references/`, `cheatsheets/`, `module/`) | `konzepte/` |

Quer dazu liegt `autorenwerk/`: Blueprints und Coding-Standards gelten projektübergreifend und
gehören weder zur Verwendung noch zur Erstellung des Build-Systems.

### 4.2 Szenarien

**Verwendungs-Szenarien:**

```
"Wie konfiguriere ich Qt6?"
→ guide/userguides/Qt6_Integration.md

"Was bedeutet Error E0501?"
→ guide/references/ErrorCodes.md

"Welche Felder hat Solution.json?"
→ guide/references/Solution_Schema.md

"Wie funktioniert Fetch.cmake?"
→ guide/module/externals/core/Fetch_cmake.md
```

**Erstellungs-Szenarien:**

```
"Wie ist das Build-System architektonisch aufgebaut?"
→ konzepte/abgeschlossen/Master_Concept.md

"Was sind die Konventionen für CMake-Module?"
→ konzepte/Guidelines.md

"Was haben wir in der letzten Sitzung gelernt?"
→ docs/report/SESSION_REPORT_JJJJ-MM-TT.md
```

---

## 5. Ordner-Definitionen

### 5.1 autorenwerk/blueprints/

| Eigenschaft | Wert |
|-------------|------|
| **Inhalt** | Meta-Standards für Dokumentationstypen |
| **Zielgruppe** | Dokumentations-Ersteller |
| **Beispiele** | Doc.md, CMake.md, Concept.md |

### 5.2 autorenwerk/standards/

| Eigenschaft | Wert |
|-------------|------|
| **Inhalt** | Allgemeine Coding/Project Standards |
| **Zielgruppe** | Alle Entwickler |
| **Beispiele** | Cpp_Coding_Standard.md, Git_Standard.md, Doku_Standard.md |

**Wichtig:** Hier liegen nur *allgemeine* Standards, die projektübergreifend gelten. Die Konventionen des Build-Systems selbst stehen in `konzepte/Guidelines.md`.

### 5.3 guide/module/

| Eigenschaft | Wert |
|-------------|------|
| **Inhalt** | API-Dokumentation der CMake-Module |
| **Zielgruppe** | Build-System-Benutzer und -Entwickler |
| **Typ** | ModuleDoc |

**Unterstruktur** (spiegelt `cmake/`):

```
guide/module/
├── core/                    # Kern-Module
│   ├── Errors.md
│   ├── Debug.md
│   ├── Context.md
│   └── ...
├── project/                 # Projekt-Module
│   ├── Solution.md
│   ├── Executables.md
│   └── Libraries.md
├── externals/               # External-Module
│   ├── Orchestrator_cmake.md
│   ├── core/Fetch_cmake.md
│   ├── hooks/               # Hook-Dokumentation (prefetch/, postfetch/)
│   └── locals/              # Lokale Externals
└── buildSystemTest/         # Phasentests
```

### 5.4 guide/references/

| Eigenschaft | Wert |
|-------------|------|
| **Inhalt** | Nachschlagewerke, Schemas, Listen |
| **Zielgruppe** | Alle Entwickler |
| **Typ** | Reference |
| **Beispiele** | Solution_Schema.md, ErrorCodes.md, Glossar.md, Externals.md |

### 5.5 guide/userguides/

| Eigenschaft | Wert |
|-------------|------|
| **Inhalt** | How-To Anleitungen für konkrete Aufgaben, Einstieg für neue Benutzer |
| **Zielgruppe** | Build-System-Benutzer, Einsteiger |
| **Typ** | Guide, Tutorial |
| **Beispiele** | Adding_Externals.md, Testing.md, Getting_Started.md |

Tutorials haben keinen eigenen Ordner; sie liegen bei den Anleitungen.

### 5.6 guide/cheatsheets/

| Eigenschaft | Wert |
|-------------|------|
| **Inhalt** | Kurzreferenzen auf einer Seite |
| **Zielgruppe** | Build-System-Benutzer |
| **Typ** | Cheatsheet |
| **Beispiele** | Solution_Cheatsheet.md |

---

## 6. Konzepte und Berichte

### 6.1 Struktur

```
docs/
├── de/konzepte/                 # Entwicklung des Build-Systems
│   ├── Guidelines.md            # Konventionen für Build-System-Code
│   ├── Future_Enhancements.md   # Sammlung geplanter Features
│   ├── Konzept_Versionierter_Bezug.md
│   └── abgeschlossen/           # Umgesetzte Konzepte
│       ├── Master_Concept.md
│       ├── Implementation_Plan.md
│       ├── AppContainer_Concept.md
│       └── System_Externals_Concept.md
└── report/                      # Berichte (ohne Sprachbaum)
    └── SESSION_REPORT_JJJJ-MM-TT.md
```

### 6.2 konzepte/

| Eigenschaft | Wert |
|-------------|------|
| **Inhalt** | Architektur-Entscheidungen, Design-Konzepte |
| **Zielgruppe** | Build-System-Entwickler |
| **Typ** | Concept |
| **Lebenszyklus** | Entwurf → Review → Implementierung → `abgeschlossen/` |

**Besondere Dokumente:**

| Dokument | Beschreibung |
|----------|--------------|
| `abgeschlossen/Master_Concept.md` | Gesamtarchitektur, alle Phasen |
| `abgeschlossen/Implementation_Plan.md` | Detaillierter Umsetzungsplan |
| `Future_Enhancements.md` | Sammlung geplanter Features |

Abgeschlossene Konzepte sind Zeitdokumente: Sie werden nicht umgeschrieben, sondern bei Bedarf
mit einem Hinweis auf den heutigen Stand versehen.

### 6.3 konzepte/Guidelines.md

| Eigenschaft | Wert |
|-------------|------|
| **Inhalt** | Projektspezifische Konventionen |
| **Zielgruppe** | Build-System-Entwickler |
| **Typ** | Standard |

**Abgrenzung zu `autorenwerk/standards/`:**

| Ort | Inhalt | Beispiel |
|-----|--------|----------|
| `docs/de/autorenwerk/standards/` | Allgemeine Standards | "Wie schreibt man C++?" |
| `docs/de/konzepte/Guidelines.md` | Projektspezifisch | "Namenskonventionen für CMake-Module im Build-System" |

### 6.4 report/

| Eigenschaft | Wert |
|-------------|------|
| **Inhalt** | Session-Reports, Befundlisten, Reviews |
| **Zielgruppe** | Build-System-Entwickler |
| **Typ** | Report |

**Typische Inhalte:**

- `SESSION_REPORT_JJJJ-MM-TT.md` — Bericht einer Arbeitssitzung
- `Doku_Befunde_JJJJ-MM-TT.md` — Befundliste einer Doku-Prüfung

`report/` liegt neben `de/` und `en/` und wird nicht übersetzt.

---

## 7. Entscheidungsbaum

### 7.1 Wo gehört mein Dokument hin?

```
START: Was dokumentiere ich?
│
├─► "Wie schreibt man Dokumentation?"
│   └─► autorenwerk/blueprints/
│
├─► "Wie schreibt man generell C++/CMake/Git?"
│   └─► autorenwerk/standards/
│
├─► "Wie funktioniert ein CMake-Modul?"
│   └─► guide/module/
│
├─► "Was bedeutet X? Schema/Liste/API?"
│   └─► guide/references/
│
├─► "Wie mache ich X mit dem Build-System?"
│   └─► guide/userguides/
│
├─► "Erste Schritte für Einsteiger?"
│   └─► guide/userguides/
│
├─► "Kurzreferenz auf einer Seite?"
│   └─► guide/cheatsheets/
│
└─► "Entwicklung des Build-Systems selbst?"
    │
    ├─► "Architektur/Design-Entscheidung?"
    │   └─► konzepte/
    │
    ├─► "Projektspezifische Konvention?"
    │   └─► konzepte/Guidelines.md
    │
    └─► "Session-Report/Review/Befunde?"
        └─► docs/report/
```

### 7.2 Kurzreferenz

| Ich dokumentiere... | Ordner |
|---------------------|--------|
| Meta-Standard für Doku-Typen | `autorenwerk/blueprints/` |
| Allgemeiner Coding Standard | `autorenwerk/standards/` |
| CMake-Modul API | `guide/module/` |
| Schema, Fehlercodes, Glossar | `guide/references/` |
| How-To für Benutzer | `guide/userguides/` |
| Einsteiger-Tutorial | `guide/userguides/` |
| Kurzreferenz | `guide/cheatsheets/` |
| Architektur-Konzept | `konzepte/` |
| Build-System Konventionen | `konzepte/Guidelines.md` |
| Session-Report | `docs/report/` |

---

## 8. Beispiele

### 8.1 Beispiel: Neue External-Integration dokumentieren

**Frage:** "Ich habe GLFW integriert. Wo dokumentiere ich das?"

| Aspekt | Ordner | Dokument |
|--------|--------|----------|
| Wie nutzt man GLFW? | `guide/userguides/externals/` | `Glfw.md` |
| GLFW in Externals-Liste | `guide/references/` | `Externals.md` (erweitern) |
| Hook-Dokumentation | `guide/module/externals/hooks/prefetch/` | `Glfw.md` |

### 8.2 Beispiel: Neue Phase implementieren

**Frage:** "Ich plane Phase 8 (AppContainer). Wo dokumentiere ich das?"

| Aspekt | Ordner | Dokument |
|--------|--------|----------|
| Konzept/Design | `konzepte/` | `AppContainer_Concept.md` |
| Im Master Concept verlinken | `konzepte/abgeschlossen/` | `Master_Concept.md` (erweitern) |
| Nach Implementierung | `guide/module/project/` | `Apps.md` |
| Benutzer-Anleitung | `guide/userguides/` | `App_Creation_Guide.md` |

### 8.3 Beispiel: Fehlercode hinzufügen

**Frage:** "Ich habe neue Fehlercodes E250-E259 definiert. Wo dokumentiere ich das?"

| Aspekt | Ordner | Dokument |
|--------|--------|----------|
| Fehlercodes-Liste | `guide/references/` | `ErrorCodes.md` (erweitern) |

---

## 9. Siehe auch

- [Doc.md](Doc.md) — Wie schreibt man Dokumentationen?
- [Blueprint.md](Blueprint.md) — Meta-Blueprint
- [Concept.md](Concept.md) — Standard für Architektur-Konzepte
- [Doku_Standard.md](../standards/Doku_Standard.md) — Sprachen, Versionierung, Ablage-Regeln

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **An den Code angeglichen: Ordnerbaum, Szenarien, Entscheidungsbaum und Beispiele auf die heutige Struktur `guide/{userguides,references,cheatsheets,module}`, `konzepte/`, `autorenwerk/{blueprints,standards}`, `docs/report/` umgestellt; §6 heißt „Konzepte und Berichte“** |
| 1.0.0 | 2025-12-26 | Release 1 (aus newCMake übernommen, `2e00db7`) |
| **0.5.1** | **2025-12-15** | **Verweis auf Ordnernamen-Konvention (Doc.md § 8.8)** |
| **0.5.0** | **2025-12-13** | **Initial: Ordnerstruktur, Verwendung vs. Erstellung, Entscheidungsbaum** |
