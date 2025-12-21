# Implementierungsplan — Standard für Umsetzungspläne

> **Version:** 0.1.0  
> **Datum:** 2025-12-21  
> **Typ:** Blueprint  
> **Status:** In Entwicklung  
> **Basiert auf:** Doc v0.5, Blueprint v0.5  
> **Zielgruppe:** Dokumentations-Ersteller, Projektleiter  
> **Sprache:** Deutsch  
> **English:** [ImplementationPlan.md](../../en/blueprints/ImplementationPlan.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Geltungsbereich](#2-geltungsbereich)
3. [Header-Erweiterungen](#3-header-erweiterungen)
4. [Pflichtabschnitte](#4-pflichtabschnitte)
5. [Checklisten-Format](#5-checklisten-format)
6. [Schreibstil](#6-schreibstil)
7. [Beispiel: Vollständiger Implementierungsplan](#7-beispiel-vollständiger-implementierungsplan)
8. [Review-Checkliste](#8-review-checkliste)
9. [Siehe auch](#9-siehe-auch)
10. [Changelog](#10-changelog)

---

## 1. Übersicht

Dieser Blueprint definiert die **Struktur für Implementierungspläne**. Ein Implementierungsplan beschreibt, **wie** eine Phase oder ein Feature systematisch umgesetzt wird.

### Zielgruppe

- Entwickler, die eine Phase oder ein Feature implementieren
- Projektleiter, die den Fortschritt verfolgen

### Abgrenzung

| Dokumentations-Typ | Fragestellung | Beispiel |
|-------------------|---------------|----------|
| **Implementierungsplan** | "Was muss ich in welcher Reihenfolge tun?" | Phase 1 Umsetzung |
| **Concept** | "Wie soll die Architektur aussehen?" | MyVisualizer Konzept |
| **Guide** | "Wie konfiguriere ich X?" | Qt6 Integration |
| **Tutorial** | "Zeig mir Schritt für Schritt" | Erstes Projekt erstellen |

### Kernmerkmale

Ein Implementierungsplan:

- Zerlegt eine große Aufgabe in konkrete, abhakbare Schritte
- Definiert Akzeptanzkriterien für "fertig"
- Ermöglicht Fortschrittsverfolgung
- Ist praxisorientiert, nicht konzeptionell

---

## 2. Geltungsbereich

Dieser Blueprint gilt für Dokumente, die:

- Konkrete Umsetzungsschritte für Phasen oder Features beschreiben
- Checklisten für Aufgaben enthalten
- Im Ordner `docs/[lang]/projects/` oder projektspezifisch liegen

**Beispiele:**

- `MyVisualizer_Phase1_Implementierungsplan.md`
- `CMake_V2_Phase8_Implementierungsplan.md`
- `Feature_Docking_Implementierungsplan.md`

---

## 3. Header-Erweiterungen

### 3.1 Pflichtfelder

| Feld | Beschreibung |
|------|--------------|
| `Bezug:` | Referenziertes Konzept oder Spezifikation |

### 3.2 Optionale Zusatzfelder

| Feld | Beschreibung |
|------|--------------|
| `Phase:` | Wenn Teil einer größeren Phasenplanung |
| `Geschätzte Dauer:` | Zeitschätzung |
| `Abhängigkeiten:` | Voraussetzungen (vorherige Phasen, etc.) |

### 3.3 Vollständiger Header

```markdown
# [Projekt] — Implementierungsplan [Phase/Feature]

> **Version:** X.Y.Z  
> **Datum:** YYYY-MM-DD  
> **Typ:** Implementierungsplan  
> **Status:** [In Entwicklung | In Umsetzung | Abgeschlossen]  
> **Zielgruppe:** Entwickler  
> **Bezug:** [Konzept-Dokument]  
> **Phase:** X (optional)  
> **Geschätzte Dauer:** ~X Wochen (optional)  
> **Sprache:** Deutsch  
```

---

## 4. Pflichtabschnitte

Implementierungspläne verwenden diese Struktur:

```
## Übersichts-Checkliste

## 1. Übersicht
### 1.1 Phasenziel
### 1.2 Lieferumfang
### 1.3 Geschätzte Dauer

## 2. Voraussetzungen

## 3. Projektstruktur (optional)

## 4. Konfiguration (optional)

## 5. Implementierungsschritte
### Schritt N: [Titel]
#### Checkliste Schritt N

## 6. Dateien und Interfaces (optional)

## 7. Schnellreferenz (optional)

## 8. Akzeptanzkriterien
### 8.1 Funktionale Anforderungen
### 8.2 Nicht-funktionale Anforderungen

## 9. Nächste Schritte

## Changelog
```

### 4.1 Abschnitts-Details

| # | Abschnitt | Inhalt | Pflicht |
|---|-----------|--------|---------|
| — | Übersichts-Checkliste | Kompakter Überblick aller Aufgaben | ✅ |
| 1 | Übersicht | Ziel, Lieferumfang, Dauer | ✅ |
| 2 | Voraussetzungen | Externe Abhängigkeiten, Tools, Vorkenntnisse | ✅ |
| 3 | Projektstruktur | Verzeichnisbaum, Datei-Organisation | Optional |
| 4 | Konfiguration | Solution.json, CMake, etc. | Optional |
| 5 | Implementierungsschritte | Schritte mit Detail-Checklisten | ✅ |
| 6 | Dateien und Interfaces | Code-Skizzen, API-Definitionen | Optional |
| 7 | Schnellreferenz | Tägliche Checkliste, Kurzübersicht | Optional |
| 8 | Akzeptanzkriterien | Wann ist die Phase "fertig"? | ✅ |
| 9 | Nächste Schritte | Was kommt danach? Offene Punkte | ✅ |

---

## 5. Checklisten-Format

### 5.1 Markdown-Checkboxen

Verwende **immer** echte Markdown-Checkboxen:

```markdown
- [ ] Aufgabe offen
- [x] Aufgabe erledigt
```

**Niemals** Checkboxen in Code-Blöcken – diese werden nicht interaktiv gerendert.

### 5.2 Übersichts-Checkliste

Die Übersichts-Checkliste steht direkt nach dem Inhaltsverzeichnis und bietet einen kompakten Überblick:

```markdown
## Übersichts-Checkliste

### Schritt 1: [Titel]

- [ ] 1.1 Aufgabe A
- [ ] 1.2 Aufgabe B
- [ ] 1.3 Aufgabe C

### Schritt 2: [Titel]

- [ ] 2.1 Aufgabe A
- [ ] 2.2 Aufgabe B
```

### 5.3 Detail-Checklisten

Jeder Implementierungsschritt hat eine eigene Detail-Checkliste mit Unteraufgaben:

```markdown
### Schritt 1: Projektgerüst aufsetzen

**Ziel:** Build-System funktioniert, leeres Fenster erscheint

**Erwartetes Ergebnis:** [Konkrete Beschreibung]

#### Checkliste Schritt 1

**1.1 Solution.json**

- [ ] schemaVersion prüfen
- [ ] Externals konfigurieren
- [ ] Build testen

**1.2 Header erweitern**

- [ ] Qt-Header hinzufügen
- [ ] STL-Header hinzufügen
- [ ] Kompilierung testen
```

### 5.4 Fortschritts-Tabelle

Am Ende der Implementierungsschritte eine Fortschritts-Tabelle:

```markdown
### Gesamtfortschritt

| Schritt | Beschreibung | Unteraufgaben | Status |
|---------|--------------|---------------|--------|
| 1 | Projektgerüst | 7 | ⬜ |
| 2 | Interfaces | 6 | ⬜ |
| 3 | Implementation | 8 | ⬜ |
| **Σ** | **Gesamt** | **21** | **0%** |
```

**Status-Symbole:**

| Symbol | Bedeutung |
|--------|-----------|
| ⬜ | Offen |
| 🔄 | In Arbeit |
| ✅ | Erledigt |

### 5.5 Nummerierung

Aufgaben werden durchnummeriert im Format `Schritt.Unteraufgabe`:

- `1.1`, `1.2`, `1.3` für Schritt 1
- `2.1`, `2.2` für Schritt 2
- etc.

Dies ermöglicht eindeutige Referenzierung in Commit-Messages oder Diskussionen.

---

## 6. Schreibstil

### 6.1 Imperativ für Aufgaben

Checklisten-Einträge im Imperativ:

| ❌ Passiv/Beschreibend | ✅ Imperativ |
|----------------------|-------------|
| "Header sollte erstellt werden" | "Header erstellen" |
| "Tests werden geschrieben" | "Tests schreiben" |
| "Konfiguration ist anzupassen" | "Konfiguration anpassen" |

### 6.2 Konkret und messbar

Aufgaben müssen eindeutig abschließbar sein:

| ❌ Vage | ✅ Konkret |
|--------|-----------|
| "Code verbessern" | "Error Handling implementieren" |
| "Tests hinzufügen" | "Unit Test für loadFile() schreiben" |
| "Dokumentation" | "README.md mit Build-Anleitung aktualisieren" |

### 6.3 Abhängigkeiten explizit

Wenn Aufgaben aufeinander aufbauen, dies kennzeichnen:

```markdown
**3.4 BassAudioSource Implementation**

- [ ] loadFile(): BASS_StreamCreateFile()
- [ ] play(): BASS_ChannelPlay() *(benötigt loadFile)*
- [ ] getFFT(): BASS_ChannelGetData() *(benötigt play)*
```

---

## 7. Beispiel: Vollständiger Implementierungsplan

```markdown
# MyVisualizer — Implementierungsplan Phase 1

> **Version:** 0.1.0  
> **Datum:** 2025-12-21  
> **Typ:** Implementierungsplan  
> **Status:** In Entwicklung  
> **Zielgruppe:** Entwickler  
> **Bezug:** MyVisualizer Konzept v0.3.1  
> **Geschätzte Dauer:** ~1 Woche  
> **Sprache:** Deutsch  

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Implementierungsschritte](#3-implementierungsschritte)
4. [Akzeptanzkriterien](#4-akzeptanzkriterien)
5. [Nächste Schritte](#5-nächste-schritte)

---

## Übersichts-Checkliste

### Schritt 1: Projektgerüst

- [ ] 1.1 Solution.json konfiguriert
- [ ] 1.2 PCH erweitert
- [ ] 1.3 Build erfolgreich

### Schritt 2: PlayerEngine

- [ ] 2.1 Header erstellt
- [ ] 2.2 Implementation fertig
- [ ] 2.3 Unit Tests bestehen

### Fortschritt

| Schritt | Aufgaben | Status |
|---------|----------|--------|
| 1 | 3 | ⬜ |
| 2 | 3 | ⬜ |
| **Σ** | **6** | **0%** |

---

## 1. Übersicht

### 1.1 Phasenziel

**Phase 1: Basisfenster mit Audio-Playback**

Ziel ist ein funktionierender Audio-Player ohne Visualisierung.

### 1.2 Lieferumfang

| Komponente | Beschreibung | Priorität |
|------------|--------------|-----------|
| MainWindow | Qt6 Hauptfenster | P1 |
| PlayerEngine | BASS-Integration | P1 |

### 1.3 Geschätzte Dauer

~1 Woche

---

## 2. Voraussetzungen

| Voraussetzung | Version | Status |
|---------------|---------|--------|
| Qt6 | 6.5+ | - [ ] |
| CMake | 3.25+ | - [ ] |
| BASS | 2.4+ | - [ ] |

---

## 3. Implementierungsschritte

### Schritt 1: Projektgerüst aufsetzen

**Ziel:** Build funktioniert

**Erwartetes Ergebnis:** Leeres Fenster erscheint

#### Checkliste Schritt 1

**1.1 Solution.json**

- [ ] schemaVersion prüfen
- [ ] Externals konfigurieren
- [ ] App-Konfiguration hinzufügen

**1.2 PCH erweitern**

- [ ] Qt-Header hinzufügen
- [ ] Build testen

**1.3 Build & Test**

- [ ] CMake Configure erfolgreich
- [ ] Build ohne Fehler
- [ ] Anwendung startet

---

### Schritt 2: PlayerEngine

**Ziel:** Audio-Playback funktioniert

#### Checkliste Schritt 2

**2.1 Header erstellen**

- [ ] include/PlayerEngine.hpp anlegen
- [ ] Pimpl-Pattern anwenden

**2.2 Implementation**

- [ ] BASS_Init() im Konstruktor
- [ ] play(), pause(), stop()
- [ ] getFFT() für Visualisierung

**2.3 Tests**

- [ ] test_PlayerEngine.cpp anlegen
- [ ] Alle Tests bestehen

---

## 4. Akzeptanzkriterien

### 4.1 Funktionale Anforderungen

| # | Kriterium | Testmethode |
|---|-----------|-------------|
| A1 | Anwendung startet | Manuell |
| A2 | Audio-Datei abspielen | Unit Test |
| A3 | Play/Pause funktioniert | Manuell |

### 4.2 Nicht-funktionale Anforderungen

| # | Kriterium | Testmethode |
|---|-----------|-------------|
| N1 | Build ohne Warnings | CI |
| N2 | Alle Tests bestehen | CI |

---

## 5. Nächste Schritte

### 5.1 Nach Phase 1

Phase 2 baut auf Phase 1 auf:
- VisualizerWidget benötigt PlayerEngine::getFFT()

### 5.2 Offene Punkte

| # | Thema | Entscheidung nötig |
|---|-------|-------------------|
| 1 | Icon-Set | Welches Design? |

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| 0.1.0 | 2025-12-21 | Initial |
```

---

## 8. Review-Checkliste

Zusätzlich zur Doc.md Checkliste:

**Struktur:**

- [ ] Übersichts-Checkliste direkt nach Inhaltsverzeichnis
- [ ] Jeder Schritt hat Ziel und erwartetes Ergebnis
- [ ] Fortschritts-Tabelle vorhanden
- [ ] Akzeptanzkriterien definiert

**Checklisten:**

- [ ] Markdown-Checkboxen (nicht in Code-Blöcken)
- [ ] Nummerierung im Format `Schritt.Unteraufgabe`
- [ ] Aufgaben sind konkret und abschließbar
- [ ] Imperativ-Form verwendet

**Inhalt:**

- [ ] Bezug auf Konzept-Dokument vorhanden
- [ ] Voraussetzungen gelistet
- [ ] Nächste Schritte definiert
- [ ] Offene Punkte dokumentiert

**Praktikabilität:**

- [ ] Schritte sind in sinnvoller Reihenfolge
- [ ] Abhängigkeiten zwischen Aufgaben klar
- [ ] Geschätzte Dauer realistisch

---

## 9. Siehe auch

- [Doc.md](Doc.md) — Allgemeine Dokumentations-Regeln
- [Concept.md](Concept.md) — Für Architektur-Konzepte
- [Guide.md](Guide.md) — Für Benutzerhandbücher

---

## 10. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-21** | **Initial: Struktur, Checklisten-Format, Beispiel** |
