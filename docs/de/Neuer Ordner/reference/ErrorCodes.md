# ErrorCodes — Referenz

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Reference  
> **Status:** In Entwicklung  
> **Zielgruppe:** Alle Entwickler  
> **Sprache:** Deutsch  
> **English:** [ErrorCodes.md](../../en/reference/ErrorCodes.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Konventionen](#2-konventionen)
3. [Fatal Errors (E)](#3-fatal-errors-e)
4. [Warnings (W)](#4-warnings-w)
5. [Schnellreferenz](#5-schnellreferenz)
6. [Verwendung in Code](#6-verwendung-in-code)
7. [Siehe auch](#7-siehe-auch)

---

## 1. Übersicht

Das Build-System verwendet einheitliche Fehlercodes für konsistente und verständliche Fehlermeldungen. Jeder Code besteht aus einem Präfix (E für Error, W für Warning) und einer dreistelligen Nummer.

### Meldungsformat

```
[E101] Dependency 'CoreLib' für 'MyApp' existiert nicht
 ^      ^                                ^
 |      |                                |
 Code   Beschreibung                     Context
```

---

## 2. Konventionen

### Kategorien

| Bereich | Codes | Beschreibung |
|---------|-------|--------------|
| JSON/Parsing | `E0xx` | Fehlende Pflichtfelder, ungültiges JSON |
| Target-Erstellung | `E1xx` | Target existiert bereits, Abhängigkeit fehlt |
| Externals | `E2xx` | Fetch fehlgeschlagen, Include.cmake fehlt |
| Tests | `E3xx` | Test-Framework, source_from Fehler |
| App-Container | `E4xx` | App-Definition, Verzeichnisse |
| Deprecation | `W0xx` | Veraltete Features/Syntax |
| Konfiguration | `W1xx` | Suboptimale Einstellungen |
| Tools/Setup | `W2xx` | Fehlende Tools |
| App-Container | `W4xx` | App-Warnungen |

### Schweregrade

| Symbol | Bedeutung |
|--------|-----------|
| ⛔ FATAL | Build bricht ab |
| ⚠️ WARNING | Build läuft weiter |

---

## 3. Fatal Errors (E)

### 3.1 E0xx — JSON/Parsing

#### E001 — Pflichtfeld fehlt

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Meldung:**
```
[E001] Executable 'MyApp' hat kein 'name' Feld
```

**Lösung:** Pflichtfeld in Solution.json hinzufügen.

---

#### E002 — Solution.json nicht gefunden

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Lösung:** `Solution.json` im Projekt-Root erstellen oder Schreibweise prüfen.

---

#### E010 — External nicht in externals-Block definiert

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Meldung:**
```
[E010] External 'imgui' nicht in externals-Block definiert
```

**Lösung:** External im zentralen `externals`-Block der Solution.json definieren.

---

#### E012 — External-Source-Feld Fehler

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Meldung:**
```
[E012] External 'mylib': Kein Source-Feld (path/git) angegeben
[E012] External 'mylib': Mehrere Source-Felder angegeben
```

**Lösung:** Genau EIN Source-Feld pro External (path ODER git).

---

### 3.2 E1xx — Target-Erstellung

#### E101 — Abhängigkeit existiert nicht

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Lösung:** Library in Solution.json definieren oder Schreibfehler korrigieren.

---

#### E102 — Target existiert bereits

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Lösung:** Target-Namen müssen über Libraries, Executables UND Tests hinweg eindeutig sein.

---

#### E103 — Zirkuläre Abhängigkeit

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Lösung:** Gemeinsamen Code in separate Library extrahieren.

---

#### E104 — Source.cmake nicht gefunden

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Lösung:** Source.cmake erstellen oder Mode auf `auto` ändern.

---

### 3.3 E2xx — Externals

#### E201 — Fetched External: Kein Target in Registry

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.2.0 |

**Lösung:** PostFetch-Hook erstellen oder lokales External mit Include.cmake verwenden.

---

#### E202 — External Fetch fehlgeschlagen

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.2.0 |

**Lösung:** Netzwerkverbindung, URL und Tag/Branch prüfen.

---

#### E213 — Lokales External: Include.cmake nicht gefunden

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Lösung:** Datei erstellen: `externals/${name}/Include.cmake`

---

#### E214 — Lokales External: Pfad existiert nicht

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.0 |

**Lösung:** Pfad in Solution.json prüfen.

---

#### E215 — Fetched External: Kein tag/branch/commit

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.2.0 |

**Lösung:** Eines von `tag`, `branch` oder `commit` angeben.

---

#### E216 — Explizit angegebener Hook nicht gefunden

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.2.0 |

**Lösung:** Hook-Datei erstellen oder Hook-Angabe entfernen.

---

#### E217 — PostFetch Hook erforderlich aber nicht vorhanden

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.2.0 |

**Meldung:**
```
[E217] External 'imgui': PostFetch hook required (cmakeSupport=false)
```

**Lösung:** PostFetch Hook erstellen oder `cmakeSupport: true` setzen.

---

### 3.4 E3xx — Tests

#### E301 — Unbekanntes Test-Framework

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.4 |

**Lösung:** Gültiges Framework angeben: `doctest`, `googletest`, `catch2`.

---

#### E302 — source_from Executable existiert nicht

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.1.4 |

**Lösung:** Executable-Name in `source_from` prüfen.

---

### 3.5 E4xx — App-Container (Phase 8)

#### E401 — App definition: 'name' is required

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.5.0 |

---

#### E402 — App path does not exist

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.5.0 |

---

#### E403 — App has no src/ directory

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.5.0 |

---

#### E404 — App has no source files in src/

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.5.0 |

---

#### E405 — App dependency not found

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.5.0 |

---

#### E406 — App has no main/ directory

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.5.0 |

---

#### E407 — App has no source files in main/

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⛔ FATAL |
| **Seit** | v0.5.0 |

---

## 4. Warnings (W)

### 4.1 W0xx — Deprecation

#### W001 — Veraltetes Schema

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.1.0 |

---

#### W002 — Veraltete Syntax/Feld

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.1.0 |

---

### 4.2 W1xx — Konfiguration

#### W101 — Suboptimale Konfiguration

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.1.0 |

**Beispiele:** Keine Source-Dateien gefunden, PCH aktiviert aber Header nicht gefunden.

---

#### W103 — Include.cmake erstellt Executables

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.1.0 |

**Problem:** IDE Clutter durch unerwünschte Targets.

---

#### W104 — Include.cmake bindet Beispiele ein

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.1.0 |

---

#### W105 — Version nicht SemVer-konform

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.1.0 |

**Korrektes Format:** `MAJOR.MINOR.PATCH` (z.B. `1.0.0`)

---

#### W109 — C++20 Module verwendet

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.1.0 |

---

#### W110 — GLOB-Fallback aktiv

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.1.0 |

---

### 4.3 W2xx — Tools/Setup

#### W201 — Clang-Tidy nicht gefunden

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.1.0 |

---

### 4.4 W4xx — App-Container (Phase 8)

#### W401 — App has no include/ directory

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.5.0 |

---

#### W402 — PCH enabled but header not found

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.5.0 |

---

#### W403 — Tests directory exists but no sources found

| Aspekt | Wert |
|--------|------|
| **Schweregrad** | ⚠️ WARNING |
| **Seit** | v0.5.0 |

---

## 5. Schnellreferenz

### Fatal Errors (E)

| Code | Kategorie | Beschreibung |
|------|-----------|--------------|
| E001 | JSON | Pflichtfeld fehlt |
| E002 | JSON | Solution.json nicht gefunden |
| E010 | JSON | External nicht im externals-Block |
| E012 | JSON | Kein/mehrere Source-Felder |
| E101 | Target | Abhängigkeit existiert nicht |
| E102 | Target | Target existiert bereits |
| E103 | Target | Zirkuläre Abhängigkeit |
| E104 | Target | Source.cmake nicht gefunden |
| E201 | External | Kein Target in Registry |
| E202 | External | Fetch fehlgeschlagen |
| E213 | External | Include.cmake fehlt |
| E214 | External | Pfad existiert nicht |
| E215 | External | Kein tag/branch/commit |
| E216 | External | Hook nicht gefunden |
| E217 | External | PostFetch Hook erforderlich |
| E301 | Test | Unbekanntes Framework |
| E302 | Test | source_from Executable fehlt |
| E401-E407 | App | App-Container Fehler |

### Warnings (W)

| Code | Kategorie | Beschreibung |
|------|-----------|--------------|
| W001 | Deprecation | Veraltetes Schema |
| W002 | Deprecation | Veraltete Syntax |
| W101 | Config | Suboptimale Konfiguration |
| W103 | Config | Include.cmake erstellt Executables |
| W104 | Config | Include.cmake bindet Beispiele ein |
| W105 | Config | Version nicht SemVer |
| W109 | Config | C++20 Module (experimentell) |
| W110 | Config | GLOB-Fallback aktiv |
| W201 | Tools | Clang-Tidy nicht gefunden |
| W401-W403 | App | App-Container Warnungen |

---

## 6. Verwendung in Code

```cmake
include(cmake/core/Errors.cmake)

# Fatal Error auslösen
cmake_fatal("E001" "Executable '${name}' hat kein 'name' Feld")

# Warnung auslösen
cmake_warn("W101" "Keine Source-Dateien gefunden in ${path}")

# Assertion (interne Prüfung)
cmake_assert(DEFINED _variable "Variable muss definiert sein")
```

---

## 7. Siehe auch

- [Errors.cmake](../modules/core/Errors.md) — Error-Handling Modul
- [Debug.cmake](../modules/core/Debug.md) — Debug-System
- [master_concept.md](../projects/buildsystem/concepts/master_concept.md) — Architektur

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Reference Blueprint v0.5.0 Format, E3xx Tests, E4xx/W4xx App-Container** |
| 0.1.1 | 2025-12-09 | E217 hinzugefügt |
| 0.1.0 | 2025-12-03 | Initial |
