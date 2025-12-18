# C++ Coding Standard — Stil-Richtlinien

> **Version:** 0.5.1  
> **Datum:** 2025-12-18  
> **Typ:** Standard  
> **Status:** Stabil  
> **Zielgruppe:** Alle C++ Entwickler  
> **Geltungsbereich:** Alle C++-Projekte (PC-Applikationen)  
> **Durchsetzung:** clang-format, clang-tidy, Code Review  
> **Sprache:** Deutsch  
> **English:** [Cpp_Coding_Standard.md](../../en/standards/Cpp_Coding_Standard.md)

---

## Inhaltsverzeichnis

1. [Zweck und Geltungsbereich](#1-zweck-und-geltungsbereich)
2. [Grundprinzipien](#2-grundprinzipien)
3. [Sprachversion und Features](#3-sprachversion-und-features)
4. [Datei-Header](#4-datei-header)
5. [Formatierung](#5-formatierung)
6. [Namenskonventionen](#6-namenskonventionen)
7. [Typen, Ownership und Lifetime](#7-typen-ownership-und-lifetime)
8. [Fehlerbehandlung](#8-fehlerbehandlung)
9. [Concurrency](#9-concurrency)
10. [Statische Analyse](#10-statische-analyse)
11. [Test-Code](#11-test-code)
12. [Verhältnis zu C (Embedded)](#12-verhältnis-zu-c-embedded)
13. [Legacy-Code und Ausnahmen](#13-legacy-code-und-ausnahmen)
14. [MISRA/CERT-Alignment](#14-misracert-alignment)
15. [Siehe auch](#15-siehe-auch)
16. [Changelog](#16-changelog)

---

## 1. Zweck und Geltungsbereich

Dieser Standard definiert **Coding-Konventionen für C++** im Unternehmen.

### Zielgruppe

Dieser Standard richtet sich an alle Entwickler, die C++ Code für PC-Applikationen schreiben. Er ist verbindlich für neue Projekte und empfohlen für bestehenden Code bei Refactoring.

### Anwendungsbereich

| Sprache | Fokus | Typische Projekte |
|---------|-------|-------------------|
| **C++** | PC-Applikationen | Tools, GUIs, Services, Test-Programme, Libraries |
| C | Embedded | Firmware, MCUs, sicherheitskritische Teile |

Dieser Standard wird ergänzt durch:
- **C_Coding_Standard** — Embedded-spezifisch
- **CMake_Standard** — Build-System
- **ClangFormat_Blueprint** — Formatierung
- **ClangTidy_Blueprint** — Statische Analyse

### Tool-Autorität

> Bei Konflikten zwischen Dokumentation und Tool-Konfiguration gelten `.clang-format` und `.clang-tidy` als **verbindliche Umsetzung**.

---

## 2. Grundprinzipien

1. **Lesbarkeit über Cleverness**
2. **Sicherheit und Korrektheit über vorzeitige Optimierung**
3. **Konsistenz über persönliche Präferenz**
4. **Automatisierte Tools über manuelle Stil-Diskussionen**

---

## 3. Sprachversion und Features

### 3.1 Standard-Version

| Projekt-Typ | C++ Standard |
|-------------|--------------|
| Neue Projekte | **C++20** (Default) |
| Legacy-Projekte | Dokumentiert im README |

### 3.2 Empfohlene Features

| Feature | Verwendung |
|---------|------------|
| `enum class` | Stark typisierte Enums |
| RAII | Alle Ressourcen |
| Lambdas | Wo Lokalität und Klarheit verbessert werden |
| `constexpr` / `consteval` | Compile-Zeit-Berechnungen |
| Standard-Container | `std::vector`, `std::map`, etc. |
| Smart Pointers | `std::unique_ptr`, `std::shared_ptr` |

### 3.3 Zu vermeiden

| Feature | Grund | Alternative |
|---------|-------|-------------|
| `new` / `delete` | Manuelles Memory-Management | Smart Pointers, Container |
| Raw owning Pointers | Ownership unklar | `std::unique_ptr` |
| Präprozessor-Makros | Fehleranfällig | `constexpr`, Templates |

### 3.4 Verboten (außer dokumentiert)

| Feature | Grund |
|---------|-------|
| `reinterpret_cast` für Type-Punning | Undefined Behavior |
| Abhängigkeit von UB | Nicht portabel |

---

## 4. Datei-Header

### 4.1 Standard-Header für C++ Dateien

Jede `.hpp` und `.cpp` Datei **muss** mit folgendem Doxygen-kompatiblen Header beginnen:

```cpp
/**
 ****************************************************************************************
 * @file   Filename.hpp
 * @brief  Short description
 *         Optional second line for context
 *
 * @author Author Name
 * @date   Month YYYY
 ****************************************************************************************
 */
```

### 4.2 Pflichtfelder

| Feld | Beschreibung |
|------|--------------|
| `@file` | Exakter Dateiname |
| `@brief` | Kurzbeschreibung (1-2 Zeilen) |
| `@author` | Hauptautor |
| `@date` | Erstellungsdatum (Monat Jahr) |

### 4.3 Optionale Felder

| Feld | Verwendung |
|------|------------|
| `@version` | Bei versionierten Komponenten |
| `@copyright` | Bei speziellen Lizenzen |
| `@see` | Verweise auf verwandte Dateien |

### 4.4 Beispiel

```cpp
/**
 ****************************************************************************************
 * @file   AudioEngine.hpp
 * @brief  Audio Engine Interface
 *         Provides high-level audio playback and management
 *
 * @author Patrik Neunteufel
 * @date   December 2025
 ****************************************************************************************
 */

#pragma once

#include <memory>
// ...
```

### 4.5 Sprache

- **Englisch** ist Pflicht für alle öffentlichen APIs und Templates
- Interne/projektspezifische Dateien können Deutsch verwenden, Englisch wird empfohlen

---

## 5. Formatierung

### 5.1 Autorität

- Alle Formatierung via `clang-format`
- Manuelle Abweichungen nicht erlaubt
- Bei Problemen: `.clang-format` anpassen, nicht umgehen

### 5.2 Übersicht (Details in `.clang-format`)

| Aspekt | Regel |
|--------|-------|
| Basis-Stil | LLVM mit Anpassungen |
| Einrückung | 4 Spaces |
| Tabs | Nie verwenden |
| Klammern | Allman-Stil (neue Zeile) |
| Include-Reihenfolge | PCH → System → Projekt |
| Arrays | Ein Element pro Zeile |

---

## 6. Namenskonventionen

### 6.1 Autorität

- Namensregeln via `clang-tidy` (`readability-identifier-naming`)
- Verstöße beheben, nicht unterdrücken

### 6.2 Übersicht

| Entität | Konvention | Beispiel |
|---------|------------|----------|
| Namespace | `lower_case` | `audio`, `core_utils` |
| Klasse/Struct/Enum | `CamelCase` | `LogManager`, `AudioBuffer` |
| Enum-Konstante | `CamelCase` | `LogLevelInfo` |
| Funktion/Methode | `camelBack` | `writeLog()`, `processData()` |
| Parameter | `camelBack` | `filePath`, `bufferSize` |
| Lokale Variable | `camelBack` | `currentIndex`, `tempValue` |
| Member-Variable | `m_` Prefix | `m_buffer`, `m_logger` |
| Globale Konstante | `UPPER_CASE` | `MAX_BUFFER_SIZE` |
| Globale Variable | `g_` Prefix | `g_logger` |
| Statische Variable | `s_` Prefix | `s_cache` |

---

## 7. Typen, Ownership und Lifetime

### 7.1 Fundamentale Typen

| Anforderung | Typ |
|-------------|-----|
| Größe wichtig | `std::int32_t`, `std::uint64_t` |
| Größen/Indizes | `std::size_t` |

### 7.2 Ownership-Modell

| Ownership | Mechanismus |
|-----------|-------------|
| Exklusiv | `std::unique_ptr` |
| Geteilt | `std::shared_ptr` (nur wenn nötig) |
| Nicht-besitzend | Raw Pointer oder Reference |

### 7.3 RAII

Alle Ressourcen werden durch RAII verwaltet:
- Dateien, Sockets, Handles
- Speicher
- Locks

```cpp
// ✅ RAII
{
    std::unique_ptr<Resource> res = createResource();
    // Automatic cleanup at scope end
}

// ❌ Manual
Resource* res = createResource();
// ... forgotten delete = leak
delete res;
```

---

## 8. Fehlerbehandlung

### 8.1 Exceptions (C++ PC)

Exceptions sind **erlaubt und erwartet**:

| Regel | Beschreibung |
|-------|--------------|
| Werfen | By Value |
| Fangen | By (const) Reference |
| Verwendung | Echte Ausnahmesituationen |
| Nicht verwenden für | Normalen Kontrollfluss |

### 8.2 Alternative Fehlerbehandlung

Für Low-Level-Code (I/O, OS-Interfaces):

| Mechanismus | Verwendung |
|-------------|------------|
| `std::error_code` | Erwartete Fehler |
| `std::optional<T>` | Optionale Rückgabe |
| `std::expected` (C++23) | Fehler oder Wert |

### 8.3 Logging

- Zentrales Logging-System verwenden (z.B. `LogManager`)
- Keine `std::cout` / `printf` in Produktionscode
- Exceptions an Grenzen loggen oder propagieren

---

## 9. Concurrency

### 9.1 Empfohlene Mechanismen

| Mechanismus | Verwendung |
|-------------|------------|
| `std::thread` / `std::jthread` | Thread-Erzeugung |
| `std::mutex` / `std::shared_mutex` | Synchronisation |
| `std::lock_guard` / `std::unique_lock` | RAII-Locking |
| `std::atomic<T>` | Atomare Operationen |

### 9.2 Richtlinien

- **Keine Data Races** — Shared Data immer schützen
- **Kurze kritische Sektionen** — Locks minimal halten
- **Thread-Safe Design bevorzugen** — Immutable Data, Message Passing

---

## 10. Statische Analyse

### 10.1 Default-Profil: Dev-Gentle

Aktivierte Check-Kategorien:
- `clang-analyzer-*` — Kritische Bugs
- `bugprone-*` — Logik-Fehler
- `performance-*` — Ineffizienzen
- `readability-*` — Lesbarkeit
- `modernize-*` — C++-Modernisierung

### 10.2 Umgang mit Warnungen

| Warnung | Anforderung |
|---------|-------------|
| `clang-analyzer-*`, `bugprone-*` | **Beheben** oder dokumentiert unterdrücken |
| Stil-Warnungen | Zeitnah beheben, nicht ignorieren |

### 10.3 Profile

| Profil | Kontext |
|--------|---------|
| Dev-Gentle | Tägliche Entwicklung |
| CI-Strict | Pull Requests |
| API-Gate | Öffentliche APIs |

---

## 11. Test-Code

- Test-Code folgt **demselben Standard**
- Test-spezifische Abkürzungen bleiben in Tests
- Verwendete Frameworks (GoogleTest, Catch2) respektieren Naming-Regeln

---

## 12. Verhältnis zu C (Embedded)

| Aspekt | C++ (PC) | C (Embedded) |
|--------|----------|--------------|
| Exceptions | Ja | Nein |
| Dynamic Allocation | Erlaubt | Vermeiden |
| Standard Library | Voll | Eingeschränkt |
| MISRA/CERT | Alignment | Strikte Einhaltung |

### Shared Components

Libraries für PC und Embedded müssen dokumentieren:
- Verwendete C++-Subset
- Embedded-Einschränkungen

---

## 13. Legacy-Code und Ausnahmen

### 13.1 Legacy-Code

- Bleibt temporär, wenn nicht compliant
- Neuer Code **immer** nach Standard
- Refactoring-Chancen nutzen

### 13.2 Intentionale Abweichungen

- Kommentar im Code
- Begründung dokumentieren
- Scope minimieren

---

## 14. MISRA/CERT-Alignment

Dieser Standard orientiert sich an:

| Richtlinie | Relevanz |
|------------|----------|
| MISRA C++ | Sicherheitskritischer Code |
| SEI CERT C++ | Defensive Programmierung |

### Umgesetzte Prinzipien

- Keine gefährlichen Casts
- Keine implizite Truncation
- Rückgabewerte prüfen
- Variablen initialisieren

---

## 15. Siehe auch

- [C_Coding_Standard.md](C_Coding_Standard.md) — Embedded C
- [CMake_Standard.md](CMake_Standard.md) — Build-System
- [ClangFormat_Blueprint.md](../blueprints/ClangFormat_Blueprint.md) — Formatierung
- [ClangTidy_Blueprint.md](../blueprints/ClangTidy_Blueprint.md) — Statische Analyse

---

## 16. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.1** | **2025-12-18** | **Neuer Abschnitt 4: Datei-Header mit Doxygen-Format, Pflichtfelder, Sprachregelung** |
| 0.5.0 | 2025-12-13 | Migration auf Blueprint v0.5: Neuer Header, Inhaltsverzeichnis, Encoding-Fix |
| 0.1.0 | 2025-12-05 | Initial: Namenskonventionen, Ownership, Exceptions, MISRA-Alignment |
