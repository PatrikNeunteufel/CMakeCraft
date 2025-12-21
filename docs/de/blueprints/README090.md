# Blueprints v0.5.0 — Übersicht

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Status:** In Entwicklung

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Hierarchie](#2-hierarchie)
3. [Dateien](#3-dateien)
4. [Änderungen gegenüber v0.1.0](#4-änderungen-gegenüber-v010)
5. [Migration](#5-migration)

---

## 1. Übersicht

Die Blueprint-Sammlung v0.5.0 definiert verbindliche Standards für:
- **Dokumentationen** aller Art
- **CMake-Module** (.cmake Dateien)
- **Code-Standards** (C++, C)

### Kernprinzipien v0.5.0

| Prinzip | Beschreibung |
|---------|--------------|
| **Vererbungshierarchie** | Blueprints bauen aufeinander auf |
| **Pflicht-Inhaltsverzeichnis** | Nummeriert mit funktionierenden Ankern |
| **Zielgruppe im Header** | Sofort klar, für wen das Dokument ist |
| **English-Link im Header** | Verweis auf englische Version |
| **Modul-Link** | ModuleDoc verlinkt auf das Modul |

---

## 2. Hierarchie

```
Blueprint.md                     ← Meta-Blueprint (Basisklasse)
    │
    ├── Doc.md                   ← Allgemeine Doku-Regeln
    │       │
    │       ├── ModuleDoc.md     ← CMake-Modul-Dokumentation
    │       ├── Guide.md         ← Benutzerhandbücher  
    │       ├── Reference.md     ← API/Schema-Referenzen
    │       ├── Concept.md       ← Architektur-Konzepte
    │       ├── Standard.md      ← Coding/Project Standards
    │       └── Tutorial.md      ← Step-by-Step Anleitungen
    │
    ├── CMake.md                 ← CMake-Scripts (.cmake)
    │
    └── Cpp.md                   ← C++/C Code-Dateien (.cpp, .hpp, .tpp)
```

### Vererbungsregeln

- **Erben:** Spezialisierte Blueprints übernehmen Parent-Regeln
- **Erweitern:** Zusätzliche Felder/Abschnitte möglich
- **Überschreiben:** Parent-Regeln können explizit geändert werden

---

## 3. Dateien

| Datei | Beschreibung |
|-------|--------------|
| [Blueprint.md](Blueprint.md) | Meta-Blueprint — wie man Blueprints schreibt |
| [Doc.md](Doc.md) | Allgemeine Regeln für alle Dokumentationen |
| [ModuleDoc.md](ModuleDoc.md) | CMake-Modul-Dokumentation mit API-Format |
| [Guide.md](Guide.md) | Benutzerhandbücher (How-To) |
| [Reference.md](Reference.md) | Nachschlagewerke (Schema, ErrorCodes) |
| [Concept.md](Concept.md) | Architektur-Konzepte (ADR) |
| [Standard.md](Standard.md) | Coding/Project Standards |
| [Tutorial.md](Tutorial.md) | Step-by-Step Anleitungen |
| [CMake.md](CMake.md) | Struktur für CMake-Scripts (.cmake) |
| [Cpp.md](Cpp.md) | Struktur für C++/C Code-Dateien (.cpp, .hpp, .tpp) |

> **Hinweis:** Keine Versionen im Dateinamen. Version steht nur im Header.  
> Archivierte Versionen: `Blueprint_v0_4_0.md` etc.

---

## 4. Änderungen gegenüber v0.1.0

### Neue Features

| Feature | Beschreibung |
|---------|--------------|
| **Keine Version im Dateinamen** | Aktuelle Dateien ohne Version, archivierte mit `_vX_Y_Z` |
| **Inhaltsverzeichnis (TOC)** | Pflicht für alle Dokumente, nummeriert, mit Anker-Links |
| **Zielgruppe** | Pflichtfeld im Header, detailliert in Übersicht |
| **English-Link** | Header-Feld verweist auf `/en/` Version |
| **Modul-Link** | ModuleDoc verlinkt direkt auf die .cmake Datei |
| **Vererbungshierarchie** | Klare Parent-Child-Beziehungen |
| **Anker-Konventionen** | Dokumentiert wie Anker funktionieren |

### Strukturelle Änderungen

| Vorher (v0.1.0) | Nachher (v0.5.0) |
|-----------------|------------------|
| `Documentation_Blueprint.md` | Aufgeteilt in `Blueprint.md` + `Doc.md` |
| `CMake_Blueprint.md` | Umbenannt zu `CMake.md` |
| 6 Doku-Typen in einem Dokument | Separate Blueprints pro Typ |

### Header-Änderungen

```markdown
# Vorher (v0.1.0)
> **Version:** 0.1.0  
> **Datum:** 2025-12-03  
> **Typ:** Blueprint

# Nachher (v0.5.0)  
> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Blueprint  
> **Status:** In Entwicklung  
> **Zielgruppe:** [Wer soll das lesen?]  
> **Sprache:** Deutsch  
> **English:** [Blueprint.md](../../en/blueprints/Blueprint.md)
```

### Dateinamen-Änderungen

```markdown
# Vorher (v0.1.0)
Blueprint_v0_5_0.md              ← Version im Dateinamen

# Nachher (v0.5.0)
Blueprint.md                     ← Keine Version (aktuell)
Blueprint_v0_4_0.md              ← Archivierte Version
```

---

## 5. Migration

### 5.1 Bestehende Dokumente anpassen

1. **Header erweitern:** `Sprache:` und `English:` hinzufügen
2. **Inhaltsverzeichnis:** Nach Header einfügen, nummeriert
3. **Kapitel nummerieren:** Alle H2-Überschriften
4. **Anker prüfen:** Alle TOC-Links testen

### 5.2 Checkliste

- [ ] Dateiname ohne Version (z.B. `Doc.md` statt `Doc_v0_5_0.md`)
- [ ] Header hat `Zielgruppe:` Feld
- [ ] Header hat `Sprache:` Feld
- [ ] Header hat `English:` Feld mit korrektem Pfad (ohne Version)
- [ ] Inhaltsverzeichnis vorhanden
- [ ] Inhaltsverzeichnis ist nummeriert
- [ ] Alle Anker funktionieren
- [ ] Kapitel sind nummeriert
- [ ] Zielgruppe in Übersicht detailliert (falls nötig)
- [ ] Alle Links ohne Version (außer zu archivierten Dokumenten)
- [ ] Changelog aktualisiert

### 5.3 Beispiel-Migration

```markdown
# Vorher
## Übersicht
## Installation
## Changelog

# Nachher
## Inhaltsverzeichnis
1. [Übersicht](#1-übersicht)
2. [Installation](#2-installation)
3. [Changelog](#3-changelog)

---

## 1. Übersicht
## 2. Installation  
## Changelog
```

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Initial v0.5.0: Keine Version im Dateinamen (nur Archiv), Vererbungshierarchie, TOC-Pflicht, Zielgruppe-Pflichtfeld, English-Link, Modul-Link, Cpp.md hinzugefügt** |
