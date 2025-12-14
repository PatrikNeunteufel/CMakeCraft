# Glossar — Referenz

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Reference  
> **Status:** In Entwicklung  
> **Zielgruppe:** Alle Entwickler  
> **Sprache:** Deutsch  
> **English:** [Glossar.md](../../en/reference/Glossar.md)

Dieses Glossar definiert alle Fachbegriffe, die in der Dokumentation des CMake Architecture V2 Build-Systems verwendet werden.

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Konventionen](#2-konventionen)
3. [Abkürzungen](#3-abkürzungen)
4. [CMake-Begriffe](#4-cmake-begriffe)
5. [Projekt-Begriffe](#5-projekt-begriffe)
6. [Build-Konzepte](#6-build-konzepte)
7. [Typen](#7-typen)
8. [Compiler](#8-compiler)
9. [Datei-Extensions](#9-datei-extensions)
10. [Schnellreferenz](#10-schnellreferenz)
11. [Siehe auch](#11-siehe-auch)

---

## 1. Übersicht

Dieses Glossar enthält alle Fachbegriffe des CMake Architecture V2 Build-Systems. Die Begriffe sind nach Kategorien gruppiert.

### Nicht übersetzte Begriffe

Diese Begriffe werden in unserem Projekt **nicht übersetzt**:
- Context, External, Hook, Pipeline, Solution

---

## 2. Konventionen

### Deutsch ↔ Englisch

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

## 3. Abkürzungen

| Abkürzung | Ausgeschrieben | Erklärung |
|-----------|----------------|-----------|
| **API** | Application Programming Interface | Programmierschnittstelle |
| **CI/CD** | Continuous Integration/Deployment | Automatisierte Pipelines |
| **CLI** | Command Line Interface | Kommandozeile |
| **CRT** | C Runtime Library | Windows C-Laufzeitbibliothek |
| **DLL** | Dynamic Link Library | Dynamische Bibliothek (Windows) |
| **DSP** | Digital Signal Processing | Digitale Signalverarbeitung |
| **GUI** | Graphical User Interface | Grafische Oberfläche |
| **i18n** | Internationalization | Internationalisierung |
| **IDE** | Integrated Development Environment | Entwicklungsumgebung |
| **JSON** | JavaScript Object Notation | Datenaustauschformat |
| **PCH** | Precompiled Header | Vorkompilierte Header |
| **PIMPL** | Pointer to Implementation | Entwurfsmuster |
| **PR** | Pull Request | Code-Integration |
| **RTTI** | Run-Time Type Information | Laufzeit-Typinfo |
| **SemVer** | Semantic Versioning | MAJOR.MINOR.PATCH |
| **SO** | Shared Object | Dynamische Bibliothek (Linux) |

---

## 4. CMake-Begriffe

### Cache-Variable

Persistente CMake-Variable, gespeichert in CMakeCache.txt.

```cmake
set(MY_VAR "value" CACHE STRING "Description")
```

---

### Configure

Erste Phase des CMake-Builds: Projektkonfiguration.

```bash
cmake -B build --preset windows-vs-x64-debug
```

---

### FetchContent

CMake-Modul zum Herunterladen von Abhängigkeiten.

```cmake
include(FetchContent)
FetchContent_Declare(...)
FetchContent_MakeAvailable(...)
```

---

### Generator

Backend für Build-System: Visual Studio, Ninja, Make.

---

### include_guard

Verhindert mehrfaches Laden einer CMake-Datei.

```cmake
include_guard(GLOBAL)
```

---

### Preset

Vordefinierte CMake-Konfiguration in CMakePresets.json.

---

### Property

CMake-Eigenschaft (Target, Directory, Global).

---

### Target

Build-Einheit in CMake (Executable, Library, Custom).

---

### Toolchain

Compiler + Linker + Tools für eine Plattform.

---

## 5. Projekt-Begriffe

### Context

Isolierter Namensraum für Build-Daten.

```cmake
ctx_create(EXE_MyApp)
ctx_set(EXE_MyApp NAME "MyApp")
ctx_get(EXE_MyApp NAME _name)
```

**Siehe auch:** [Context.cmake](../modules/core/Context.md)

---

### External

Externe Abhängigkeit/Bibliothek im Build-System. Typen: Local, Fetched, System.

---

### Hook

Callback-Mechanismus für External-Verarbeitung.

| Typ | Zeitpunkt |
|-----|-----------|
| PreFetch | Vor dem Fetch |
| PostFetch | Nach dem Fetch |

---

### Pipeline

Mehrstufiger Verarbeitungsprozess.

```
Collect → Validate → Create → Configure
```

---

### Solution

Zentrale Konfigurationsdatei (Solution.json).

---

### App-Container

Testbare Anwendungsarchitektur mit Core Library + Runner.

---

## 6. Build-Konzepte

### Convention over Configuration

Standard-Verhalten ohne explizite Konfiguration.

---

### Deklarativ

Beschreibend statt imperativ (Was statt Wie).

---

### Fail-fast

Frühzeitiges Abbrechen bei Fehlern.

---

### Fetched External

External, das aus Git heruntergeladen wird.

---

### Local External

External, das im Repository liegt.

---

### System External

External, das system-installiert ist (Qt6, Boost).

---

### Single Source of Truth

Eine zentrale Stelle für Informationen.

---

## 7. Typen

### Executable-Typen

| Typ | Verwendung |
|-----|------------|
| **CONSOLE** | Kommandozeilen-Anwendung |
| **GUI** | Grafische Anwendung |
| **CLI** | Kommandozeilen-Tool |
| **HEADLESS** | Server/Dienst |
| **WORKER** | Hintergrund-Prozess |

---

### Library-Typen

| Typ | Erklärung |
|-----|-----------|
| **STATIC** | Statisch gelinkte Bibliothek (.a, .lib) |
| **SHARED** | Dynamisch gelinkte Bibliothek (.so, .dll) |
| **INTERFACE** | Header-only Bibliothek |

---

### Test-Typen

| Typ | Erklärung | Timeout |
|-----|-----------|---------|
| **UNIT** | Isolierte Tests | 30s |
| **INTEGRATION** | Komponenten-Tests | 120s |
| **SYSTEM** | End-to-End Tests | 300s |
| **PERFORMANCE** | Benchmark-Tests | 600s |

---

### Source-Modi

| Modus | Erklärung |
|-------|-----------|
| **explicit** | Source.cmake erforderlich |
| **glob** | Automatisches Sammeln |
| **auto** | Source.cmake wenn vorhanden, sonst GLOB |

---

## 8. Compiler

### Compiler-Typen

| Begriff | Erklärung |
|---------|-----------|
| **Clang** | LLVM-basierter C/C++ Compiler |
| **Clang-CL** | Clang mit MSVC-Frontend (Windows) |
| **GCC** | GNU Compiler Collection |
| **MinGW** | Minimalist GNU for Windows |
| **MSVC** | Microsoft Visual C++ |
| **Apple Clang** | Apples Clang-Variante |

---

### MSVC Flags

| Flag | Erklärung |
|------|-----------|
| `/EHsc` | Exception Handling aktiviert |
| `/EHs-c-` | Exception Handling deaktiviert |
| `/GR-` | RTTI deaktiviert |
| `/permissive-` | Strikte Konformität |
| `/W4` | Hohe Warnstufe |
| `/Zc:__cplusplus` | Korrekter __cplusplus Wert |
| `/Zc:preprocessor` | Standard-Präprozessor |

---

### GCC/Clang Flags

| Flag | Erklärung |
|------|-----------|
| `-fno-exceptions` | Exception Handling deaktiviert |
| `-fno-rtti` | RTTI deaktiviert |
| `-Wall` | Alle wichtigen Warnungen |
| `-Wextra` | Zusätzliche Warnungen |
| `-Wpedantic` | Strikte Konformität |

---

## 9. Datei-Extensions

| Extension | Verwendung |
|-----------|------------|
| `.cmake` | CMake-Modul |
| `.cpp`, `.cxx`, `.cc`, `.c` | Source-Dateien |
| `.h`, `.hpp`, `.hxx`, `.hh` | Header-Dateien |
| `.tpp`, `.txx`, `.ipp` | Template-Implementierungen |
| `.inl` | Inline-Implementierungen |
| `.impl` | PIMPL-Details |
| `.ixx`, `.cppm`, `.mpp` | C++20 Module Interface Units |
| `.a`, `.lib` | Statische Bibliotheken |
| `.so`, `.dll` | Dynamische Bibliotheken |

---

## 10. Schnellreferenz

### Fehlercode-Bereiche

| Bereich | Beschreibung |
|---------|--------------|
| **E0xx** | JSON/Parsing-Fehler |
| **E1xx** | Target-Erstellung |
| **E2xx** | External-Verarbeitung |
| **E3xx** | Test-Fehler |
| **E4xx** | App-Container |
| **W0xx** | Deprecation-Warnungen |
| **W1xx** | Konfigurations-Warnungen |
| **W2xx** | Tool/Setup-Warnungen |
| **W4xx** | App-Container-Warnungen |

---

### Debug-Level

| Level | Konstante | Verwendung |
|-------|-----------|------------|
| 1 | `DBG_SHOW_LITTLE` | Nur das Wichtigste |
| 2 | `DBG_SHOW_SOME` | Standard |
| 3 | `DBG_SHOW_MUCH` | Mehr Details |
| 4 | `DBG_SHOW_LOTS` | Viele Details |
| 5 | `DBG_SHOW_ALL` | Alles |

| Level | Konstante | Message-Wichtigkeit |
|-------|-----------|---------------------|
| 1 | `DBG_OFTEN` | Phasen-Start |
| 2 | `DBG_COMMON` | Features |
| 3 | `DBG_NORMAL` | Zwischenschritte |
| 4 | `DBG_RARE` | Details |
| 5 | `DBG_ULTRA_RARE` | Tiefes Debugging |

---

## 11. Siehe auch

- [ErrorCodes.md](ErrorCodes.md) — Fehlercode-Referenz
- [Language_Standards.md](../standards/Language_Standards.md) — Sprachrichtlinien
- [guidelines.md](../projects/buildsystem/standards/guidelines.md) — Konventionen

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Reference Blueprint v0.5.0 Format, App-Container Begriffe** |
| 0.1.0 | 2025-12-05 | Initial |
