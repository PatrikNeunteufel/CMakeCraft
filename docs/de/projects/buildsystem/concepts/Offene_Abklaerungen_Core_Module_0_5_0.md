# Offene Abklärungen — Core-Module Debug/Error-Konsistenz

> **Version:** 0.1.0  
> **Datum:** 2025-12-15  
> **Typ:** Abklärung  
> **Status:** Offen  
> **Zielgruppe:** Build-System-Entwickler  
> **Sprache:** Deutsch

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Kontext](#2-kontext)
3. [Betroffene Module](#3-betroffene-module)
4. [Abklärungspunkte](#4-abklärungspunkte)
5. [Empfehlungen](#5-empfehlungen)
6. [Entscheidungsmatrix](#6-entscheidungsmatrix)
7. [Changelog](#7-changelog)

---

## 1. Übersicht

Dieses Dokument listet **offene Abklärungspunkte** bezüglich der konsistenten Verwendung von `Debug.cmake` und `Errors.cmake` in den Core-Modulen.

### Hintergrund

Laut Master-Concept gilt:
- **"Fail-fast"** — Klare Fehlermeldungen
- **Debug.cmake** ist für generelle Ausgaben vorgesehen, um Fehler zu identifizieren

Mehrere Core-Module verwenden jedoch weder Debug- noch Error-Funktionen.

---

## 2. Kontext

### Aktuelle Modul-Versionen (Stand: 2025-12-15)

| Modul | Version | Bemerkung |
|-------|---------|-----------|
| CompilerOptions.cmake | 0.1.1 | |
| Context.cmake | 0.1.1 | |
| Debug.cmake | 0.1.1 | |
| Errors.cmake | **0.1.2** | Neuer als andere Core-Module |
| Json.cmake | 0.1.1 | |
| OutputDirs.cmake | **0.1.3** | Neuer als andere Core-Module |
| SourceCollect.cmake | 0.1.1 | |
| Validation.cmake | 0.1.1 | |
| Warnings.cmake | 0.1.1 | |

### Aktuelle Verwendung in Core-Modulen

| Modul | message() | dbg() | cmake_warn/fatal | ErrorCodes |
|-------|-----------|-------|------------------|------------|
| CompilerOptions.cmake | 4 | 34 | 2 (W201) | ✅ |
| Context.cmake | 5¹ | 0 | 0 | ❌ |
| Debug.cmake | 5 | 7 | 0 | — |
| Errors.cmake | 2 | 0 | 23 (selbst) | — |
| Json.cmake | 3² | 0 | 0 | ❌ |
| OutputDirs.cmake | 0 | 0 | 0 | ❌ |
| SourceCollect.cmake | 0 | 9 | 9 | ✅ |
| Validation.cmake | 0 | 0 | 10 | ✅ |
| Warnings.cmake | 0 | 0 | 0 | ❌ |

**Anmerkungen:**
- ¹ Context.cmake: 5x message() — alle in `ctx_dump()` (eigene Debug-Funktion)
- ² Json.cmake: 3x message() — alle nur in Docstring-Beispielen, keine echten Aufrufe

### Potenzielle Ersetzungen (message → dbg)

| Modul | message() | Ersetzbar durch dbg()? | Anmerkung |
|-------|-----------|------------------------|-----------|
| CompilerOptions.cmake | 4 | ⚪ Prüfen | STATUS-Meldungen für Clang-Tidy |
| Context.cmake | 5 | 🔴 Nein | ctx_dump() ist eigene Debug-Funktion |
| Debug.cmake | 5 | 🔴 Nein | Ist das Debug-System selbst |
| Errors.cmake | 2 | 🔴 Nein | FATAL_ERROR/WARNING müssen message() sein |
| Json.cmake | 3 | — | Nur in Docstrings (Beispiele) |

**CompilerOptions.cmake message()-Aufrufe (Zeilen 228, 235, 244, 294):**
```cmake
message(STATUS "[${TARGET_NAME}] Clang-Tidy enabled")
message(STATUS "[${TARGET_NAME}] Clang-Tidy enabled (without .clang-tidy)")
message(STATUS "[${TARGET_NAME}] Clang-Tidy STRICT mode")
message(STATUS "[${TARGET_NAME}] Clang-Format check target (Phase 7 - not yet implemented)")
```

**Abklärung:** Diese sind User-sichtbare Status-Meldungen. Sollen sie:
- a) Immer sichtbar bleiben (aktuell)
- b) Nur bei Debug-Mode via dbg() ausgegeben werden
- c) Kombiniert: dbg() + einmalige Zusammenfassung am Ende

### Referenz-Module (mit vollständiger Implementierung)

- **CompilerOptions.cmake** — Verwendet dbg() für Plattform-Erkennung, cmake_warn(W201) für fehlende Tools
- **SourceCollect.cmake** — Verwendet dbg() für Source-Sammlung, cmake_warn(W110) für GLOB-Fallback

### Wichtige Klarstellung: Errors.cmake vs Warnings.cmake

| Modul | Zweck | Funktionen |
|-------|-------|------------|
| **Errors.cmake** | Build-System Fehler/Warnungen | `cmake_fatal()`, `cmake_warn()`, `cmake_assert()` |
| **Warnings.cmake** | Compiler-Warnungen | `apply_warnings()` → `-Wall`, `/W4` |

⚠️ **Namensverwirrung:** `cmake_warn()` ist in **Errors.cmake** definiert, nicht in Warnings.cmake!

Errors.cmake hat **keine Abhängigkeit** zu Warnings.cmake — es sind völlig unabhängige Module mit unterschiedlichem Zweck.

---

## 3. Betroffene Module

### 3.1 Context.cmake

**Aktueller Zustand:**
- Nur `DEBUG_CONTEXT` Cache-Variable für `ctx_dump()`
- Keine `dbg()` Ausgaben
- Keine Parameter-Validierung

**Potenzielle Verbesserungen:**

| Situation | Mögliche Aktion |
|-----------|-----------------|
| `ctx_create("")` (leerer PREFIX) | cmake_assert oder cmake_fatal? |
| `ctx_set(PREFIX "" VALUE)` (leerer KEY) | cmake_assert oder ignorieren? |
| `ctx_get()` auf nicht-existenten Context | Warnung oder stille "" Rückgabe? |
| Allgemeines Tracing | dbg() für alle Operationen? |

**Frage:** Soll Context.cmake als echtes Basis-Modul ohne Abhängigkeiten bleiben, oder Debug/Errors integrieren?

---

### 3.2 Json.cmake

**Aktueller Zustand:**
- Keine Debug-Ausgaben
- Keine expliziten Fehler-Codes

**Potenzielle Verbesserungen:**

| Situation | Mögliche Aktion |
|-----------|-----------------|
| JSON Parse-Fehler | E0xx Code definieren? |
| Key nicht gefunden | Warnung oder stille Rückgabe? |
| Typ-Mismatch (String erwartet, Array gefunden) | E0xx oder W1xx? |

**Hinweis:** E002 (Solution.json nicht gefunden) ist in Validation.cmake, nicht Json.cmake.

---

### 3.3 OutputDirs.cmake

**Aktueller Zustand:**
- Keine Debug-Ausgaben
- Keine Fehlerbehandlung

**Potenzielle Verbesserungen:**

| Situation | Mögliche Aktion |
|-----------|-----------------|
| Target existiert nicht | cmake_fatal oder CMake-Fehler durchreichen? |
| Verzeichnis-Erstellung | dbg() für Pfad-Ausgabe? |

---

### 3.4 Warnings.cmake

**Aktueller Zustand:**
- Keine Debug-Ausgaben
- Keine Fehlerbehandlung

**Potenzielle Verbesserungen:**

| Situation | Mögliche Aktion |
|-----------|-----------------|
| Target existiert nicht | cmake_fatal? |
| Unbekannter Compiler | Warnung W1xx? |
| Flags angewendet | dbg() für Tracing? |

**Hinweis:** Warnings.cmake ist sehr kurz (2.5K) und simpel — Debug könnte Overkill sein.

---

## 4. Abklärungspunkte

### A1: Basis-Module Philosophie

**Frage:** Sollen die "untersten" Module (Context, Json) wirklich ohne Debug/Errors bleiben?

**Pro (ohne):**
- Keine zirkulären Abhängigkeiten möglich
- Einfacher zu testen
- Context wird von Debug verwendet (indirekt)

**Contra (mit):**
- Inkonsistent mit "Fail-fast" Prinzip
- Fehlersuche schwieriger
- Andere Module haben bereits Debug integriert

---

### A2: Error-Code-Reservierung

**Frage:** Sollen Error-Codes für Context/Json/OutputDirs/Warnings reserviert werden?

**Mögliche Zuordnung:**

| Modul | Reservierter Bereich | Beispiele |
|-------|---------------------|-----------|
| Context.cmake | E0Cxx oder W0Cxx? | E0C01: Leerer PREFIX |
| Json.cmake | E00xx (erweitern) | E003: JSON Parse-Fehler |
| OutputDirs.cmake | E0Oxx oder W0Oxx? | W0O1: Verzeichnis existiert |
| Warnings.cmake | W0Wxx? | W0W1: Unbekannter Compiler |

**Alternative:** Keine neuen Codes, bestehende Kategorien nutzen.

---

### A3: Debug-Level für Basis-Module

**Frage:** Wenn Debug integriert wird, welches Level?

| Level | Verwendung |
|-------|------------|
| `DBG_OFTEN` | Immer bei aktivem Debug |
| `DBG_NORMAL` | Standard-Operationen |
| `DBG_RARE` | Selten benötigte Details |
| `DBG_ULTRA_RARE` | Nur für tiefes Debugging |

**Empfehlung:** `DBG_RARE` oder `DBG_ULTRA_RARE` für Basis-Module, um Noise zu reduzieren.

---

## 5. Empfehlungen

### Kurzfristig (v0.5.x)

1. **Context.cmake:** Bleibt ohne Debug/Errors (echtes Basis-Modul)
2. **Json.cmake:** Bleibt ohne (Fehler werden von aufrufenden Modulen behandelt)
3. **OutputDirs.cmake:** dbg() für Pfad-Ausgaben hinzufügen (Tracing)
4. **Warnings.cmake:** dbg() für angewendete Flags hinzufügen (Tracing)
5. **CompilerOptions.cmake:** Entscheidung zu message() vs dbg() für Clang-Tidy Status

### ToDo-Liste für dbg()-Integration

| Modul | Aktion | Priorität |
|-------|--------|-----------|
| OutputDirs.cmake | dbg() für `RUNTIME_OUTPUT_DIRECTORY` etc. | Niedrig |
| Warnings.cmake | dbg() für angewendete Flags `/W4`, `-Wall` | Niedrig |
| CompilerOptions.cmake | Entscheidung: message() → dbg() für Clang-Tidy? | Mittel |

### Mittelfristig (v0.6.x)

1. **Dokumentation:** Explizit dokumentieren, warum diese Module keine Debug/Errors verwenden
2. **guidelines.md:** Abschnitt für "Basis-Module ohne Abhängigkeiten" hinzufügen

### Langfristig (v1.0)

1. **Entscheidung:** Finale Architektur-Entscheidung treffen und dokumentieren
2. **Error-Codes:** Falls gewünscht, neue Bereiche definieren

---

## 6. Entscheidungsmatrix

| Modul | Debug hinzufügen? | Errors hinzufügen? | Priorität |
|-------|-------------------|-------------------|-----------|
| Context.cmake | ⚪ Abklären | ⚪ Abklären | Mittel |
| Json.cmake | ⚪ Abklären | ⚪ Abklären | Niedrig |
| OutputDirs.cmake | 🟡 Empfohlen | ⚪ Optional | Niedrig |
| Warnings.cmake | ⚪ Optional | ⚪ Optional | Niedrig |

**Legende:**
- ⚪ Offen / Abklären
- 🟡 Empfohlen
- 🟢 Bereits vorhanden
- 🔴 Nicht empfohlen

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-15** | **Initial: Analyse der Core-Module auf Debug/Error-Konsistenz** |
