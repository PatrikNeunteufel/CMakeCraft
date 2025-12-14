# Glossar — Referenz

> **Version:** 0.5.0  
> **Datum:** 2025-12-14  
> **Typ:** Reference  
> **Status:** Stabil  
> **Zielgruppe:** Alle Entwickler  
> **Sprache:** Deutsch  
> **English:** [Glossar.md](../../en/reference/Glossar.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Konventionen](#2-konventionen)
3. [Abkürzungen](#3-abkürzungen)
4. [CMake-Begriffe](#4-cmake-begriffe)
5. [Projekt-Begriffe](#5-projekt-begriffe)
6. [Build-System Konzepte](#6-build-system-konzepte)
7. [Typen und Modi](#7-typen-und-modi)
8. [Compiler und Flags](#8-compiler-und-flags)
9. [Datei-Extensions](#9-datei-extensions)
10. [Fehlercode-Bereiche](#10-fehlercode-bereiche)
11. [Debug-Level](#11-debug-level)
12. [Übersetzungs-Referenz](#12-übersetzungs-referenz)
13. [Siehe auch](#13-siehe-auch)
14. [Changelog](#14-changelog)

---

## 1. Übersicht

Dieses Glossar definiert alle Fachbegriffe, die in der Dokumentation des CMake Architecture V2 Build-Systems verwendet werden. Es dient als zentrale Nachschlagereferenz für konsistente Terminologie.

### Zielgruppe

- Alle Entwickler im Projekt
- Neue Teammitglieder zur Einarbeitung
- Dokumentations-Autoren für einheitliche Begriffe

---

## 2. Konventionen

### Notation

| Symbol | Bedeutung |
|--------|-----------|
| **Fett** | Primärer Begriff |
| `Code` | Technischer Bezeichner |
| → | Verweis auf anderen Eintrag |

### Sprache

Begriffe werden auf Deutsch erklärt. Englische Fachbegriffe werden beibehalten, wenn sie in der Praxis üblich sind (z.B. "Target", "External", "Hook").

---

## 3. Abkürzungen

| Abkürzung | Ausgeschrieben | Erklärung |
|-----------|----------------|-----------|
| **API** | Application Programming Interface | Programmierschnittstelle |
| **CI/CD** | Continuous Integration/Continuous Deployment | Automatisierte Build- und Deployment-Pipelines |
| **CLI** | Command Line Interface | Kommandozeilen-Schnittstelle |
| **CRT** | C Runtime Library | Windows C-Laufzeitbibliothek |
| **DLL** | Dynamic Link Library | Dynamisch geladene Bibliothek (Windows) |
| **DSP** | Digital Signal Processing | Digitale Signalverarbeitung |
| **GUI** | Graphical User Interface | Grafische Benutzeroberfläche |
| **i18n** | Internationalization | Internationalisierung (i + 18 Buchstaben + n) |
| **IDE** | Integrated Development Environment | Integrierte Entwicklungsumgebung |
| **JSON** | JavaScript Object Notation | Datenaustauschformat |
| **PCH** | Precompiled Header | Vorkompilierte Header-Datei zur Build-Beschleunigung |
| **PIMPL** | Pointer to Implementation | Entwurfsmuster zur Kapselung |
| **PR** | Pull Request | Anfrage zur Code-Integration |
| **RTTI** | Run-Time Type Information | Laufzeit-Typinformationen in C++ |
| **SemVer** | Semantic Versioning | Semantische Versionierung (MAJOR.MINOR.PATCH) |
| **SO** | Shared Object | Dynamisch geladene Bibliothek (Linux) |

---

## 4. CMake-Begriffe

| Begriff | Erklärung |
|---------|-----------|
| **Cache-Variable** | Persistente CMake-Variable, gespeichert in CMakeCache.txt |
| **Configure** | Erste Phase des CMake-Builds: Projektkonfiguration |
| **FetchContent** | CMake-Modul zum Herunterladen von Abhängigkeiten |
| **Generator** | Backend für Build-System (Visual Studio, Ninja, Make) |
| **include_guard** | Verhindert mehrfaches Laden einer CMake-Datei |
| **Preset** | Vordefinierte CMake-Konfiguration in CMakePresets.json |
| **Property** | CMake-Eigenschaft (Target, Directory, Global) |
| **Target** | Build-Einheit in CMake (Executable, Library, Custom) |
| **Toolchain** | Compiler + Linker + Tools für eine Plattform |

---

## 5. Projekt-Begriffe

Diese Begriffe werden in unserem Projekt **nicht übersetzt**:

| Begriff | Erklärung |
|---------|-----------|
| **Context** | Isolierter Namensraum für Build-Daten (ctx_create, ctx_set, ctx_get) |
| **External** | Externe Abhängigkeit/Bibliothek im Build-System |
| **Hook** | Callback-Mechanismus für External-Verarbeitung (PreFetch, PostFetch) |
| **Pipeline** | Mehrstufiger Verarbeitungsprozess (Collect → Create → Configure) |
| **Solution** | Zentrale Konfigurationsdatei (Solution.json) |

---

## 6. Build-System Konzepte

| Begriff | Erklärung |
|---------|-----------|
| **Convention over Configuration** | Standard-Verhalten ohne explizite Konfiguration |
| **Deklarativ** | Beschreibend statt imperativ (Was statt Wie) |
| **Fail-fast** | Frühzeitiges Abbrechen bei Fehlern |
| **Fetched External** | External, das aus Git heruntergeladen wird |
| **Local External** | External, das im Repository liegt |
| **Single Source of Truth** | Eine zentrale Stelle für Informationen |

---

## 7. Typen und Modi

### 7.1 Executable-Typen

| Typ | Verwendung |
|-----|------------|
| **CONSOLE** | Kommandozeilen-Anwendung mit stdout/stderr |
| **GUI** | Grafische Anwendung (Windows: WinMain) |
| **CLI** | Kommandozeilen-Tool mit Argument-Parsing |
| **HEADLESS** | Server/Dienst ohne Benutzeroberfläche |
| **WORKER** | Hintergrund-Prozess |

### 7.2 Library-Typen

| Typ | Erklärung |
|-----|-----------|
| **STATIC** | Statisch gelinkte Bibliothek (.a, .lib) |
| **SHARED** | Dynamisch gelinkte Bibliothek (.so, .dll) |
| **INTERFACE** | Header-only Bibliothek (keine Kompilierung) |

### 7.3 Test-Typen

| Typ | Erklärung | Typischer Timeout |
|-----|-----------|-------------------|
| **UNIT** | Isolierte Funktions-/Klassen-Tests | 30s |
| **INTEGRATION** | Zusammenspiel mehrerer Komponenten | 120s |
| **SYSTEM** | Ende-zu-Ende Tests | 300s |
| **PERFORMANCE** | Leistungs- und Benchmark-Tests | 600s |

### 7.4 Source-Modi

| Modus | Erklärung |
|-------|-----------|
| **explicit** | Source.cmake erforderlich (empfohlen) |
| **glob** | Automatisches Sammeln per Wildcard |
| **auto** | Source.cmake wenn vorhanden, sonst GLOB |

---

## 8. Compiler und Flags

### 8.1 Compiler

| Begriff | Erklärung |
|---------|-----------|
| **Clang** | LLVM-basierter C/C++ Compiler |
| **Clang-CL** | Clang mit MSVC-kompatiblem Frontend (Windows) |
| **Clang-Format** | Code-Formatierungs-Tool |
| **Clang-Tidy** | Statisches Analyse-Tool |
| **GCC** | GNU Compiler Collection |
| **MinGW** | Minimalist GNU for Windows |
| **MSVC** | Microsoft Visual C++ Compiler |
| **Apple Clang** | Apples Variante des Clang-Compilers |

### 8.2 MSVC-Flags

| Flag | Erklärung |
|------|-----------|
| `/EHsc` | Exception Handling aktiviert |
| `/EHs-c-` | Exception Handling deaktiviert |
| `/GR-` | RTTI deaktiviert |
| `/permissive-` | Strikte Standard-Konformität |
| `/W4` | Hohe Warnstufe |
| `/Zc:__cplusplus` | Korrekter __cplusplus Makro-Wert |
| `/Zc:preprocessor` | Standard-konformer Präprozessor |

### 8.3 GCC/Clang-Flags

| Flag | Erklärung |
|------|-----------|
| `-fno-exceptions` | Exception Handling deaktiviert |
| `-fno-rtti` | RTTI deaktiviert |
| `-Wall` | Alle wichtigen Warnungen |
| `-Wextra` | Zusätzliche Warnungen |
| `-Wpedantic` | Strikte Standard-Konformität |

---

## 9. Datei-Extensions

| Extension | Verwendung |
|-----------|------------|
| `.cmake` | CMake-Modul |
| `.cpp`, `.cxx`, `.cc`, `.c` | Kompilierbare Source-Dateien |
| `.h`, `.hpp`, `.hxx`, `.hh` | Header-Dateien |
| `.tpp`, `.txx`, `.ipp` | Template-Implementierungen |
| `.inl` | Inline-Implementierungen |
| `.impl` | PIMPL-Details |
| `.ixx`, `.cppm`, `.mpp` | C++20 Module Interface Units |
| `.a`, `.lib` | Statische Bibliotheken |
| `.so`, `.dll` | Dynamische Bibliotheken |

---

## 10. Fehlercode-Bereiche

| Bereich | Beschreibung |
|---------|--------------|
| **E0xx** | JSON/Parsing-Fehler |
| **E1xx** | Target-Erstellung |
| **E2xx** | External-Verarbeitung |
| **E3xx** | Test-Pipeline |
| **E4xx** | App-Container-Pipeline |
| **E5xx** | System Externals |
| **W0xx** | Deprecation-Warnungen |
| **W1xx** | Konfigurations-Warnungen |
| **W2xx** | Tool/Setup-Warnungen |
| **W3xx** | External-Caching-Warnungen |
| **W4xx** | App-Container-Warnungen |
| **W5xx** | System External-Warnungen |

---

## 11. Debug-Level

### 11.1 Anzeige-Level (was sehen wir)

| Level | Konstante | Verwendung |
|-------|-----------|------------|
| 1 | `DBG_SHOW_LITTLE` | Nur das Wichtigste |
| 2 | `DBG_SHOW_SOME` | Standard (Default) |
| 3 | `DBG_SHOW_MUCH` | Mehr Details |
| 4 | `DBG_SHOW_LOTS` | Viele Details |
| 5 | `DBG_SHOW_ALL` | Alles |

### 11.2 Message-Level (wie wichtig ist die Nachricht)

| Level | Konstante | Message-Wichtigkeit |
|-------|-----------|---------------------|
| 1 | `DBG_OFTEN` | Häufig, wichtig (Phasen-Start) |
| 2 | `DBG_COMMON` | Übliche Info (Features) |
| 3 | `DBG_NORMAL` | Standard (Zwischenschritte) |
| 4 | `DBG_RARE` | Selten (Pfade, Details) |
| 5 | `DBG_ULTRA_RARE` | Tiefes Debugging |

---

## 12. Übersetzungs-Referenz

Konsistente Übersetzungen zwischen Deutsch und Englisch:

| Deutsch | Englisch |
|---------|----------|
| Abhängigkeit | Dependency |
| Ausführbare Datei | Executable |
| Bibliothek | Library |
| Pflichtfeld | Required field |
| Verzeichnis | Directory |
| Warnung | Warning |
| Fehler | Error |
| Konfiguration | Configuration |
| Einstellung | Setting |
| Ziel | Target |

---

## 13. Siehe auch

- [ErrorCodes.md](ErrorCodes.md) — Vollständige Fehlercode-Referenz
- [Solution_Schema.md](Solution_Schema.md) — JSON-Schema Referenz
- [Cpp_Coding_Standard.md](../standards/Cpp_Coding_Standard.md) — Coding-Konventionen

---

## 14. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-14** | **Blueprint v0.5.0 Format: Nummeriertes TOC, Reference-Header, vollständige Fehlercode-Bereiche (E0xx-E5xx, W0xx-W5xx inkl. E4xx/W4xx AppContainer)** |
| 0.1.0 | 2025-12-05 | Initial: Begriffe aus allen Dokumentationen gesammelt |
