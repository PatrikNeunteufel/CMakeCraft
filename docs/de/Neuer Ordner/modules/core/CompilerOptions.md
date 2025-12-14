# CompilerOptions.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/core/CompilerOptions.cmake](../../../cmake/core/CompilerOptions.cmake)  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [CompilerOptions.md](../../en/modules/core/CompilerOptions.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [Konzept](#3-konzept)
4. [API-Referenz](#4-api-referenz)
5. [Verwendungsbeispiele](#5-verwendungsbeispiele)
6. [Fehlerbehandlung](#6-fehlerbehandlung)
7. [Best Practices](#7-best-practices)
8. [Siehe auch](#8-siehe-auch)
9. [Changelog](#9-changelog)

---

## 1. Übersicht

Das `CompilerOptions.cmake` Modul konfiguriert Compiler-Optionen für Targets mit plattform-unabhängiger Abstraktion.

### Features

- C/C++ Standard-Konfiguration
- Debug/Release Optimierungen
- MSVC/GCC/Clang Unterstützung

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| CMake 3.19+ | System | Basis |
| Debug.cmake | Modul | Optional für Debug-Ausgaben |

---

## 3. Konzept

### 3.1 Compiler-Erkennung

| Compiler | CMake-Variable |
|----------|----------------|
| MSVC | `MSVC` |
| GCC | `CMAKE_CXX_COMPILER_ID STREQUAL "GNU"` |
| Clang | `CMAKE_CXX_COMPILER_ID STREQUAL "Clang"` |
| AppleClang | `CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang"` |

### 3.2 Standard-Konfiguration

| Option | MSVC | GCC/Clang |
|--------|------|-----------|
| C++20 | `/std:c++20` | `-std=c++20` |
| C17 | `/std:c17` | `-std=c17` |

---

## 4. API-Referenz

### 4.1 apply_compiler_options()

Wendet Compiler-Optionen auf ein Target an.

```cmake
apply_compiler_options(<TARGET>)
```

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `TARGET` | ✓ | Target-Name |

---

### 4.2 set_language_standards()

Setzt C/C++ Standards.

```cmake
set_language_standards(<TARGET> [CXX_STANDARD <ver>] [C_STANDARD <ver>])
```

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `TARGET` | ✓ | Target-Name |
| `CXX_STANDARD` | — | C++ Standard (11, 14, 17, 20, 23) |
| `C_STANDARD` | — | C Standard (99, 11, 17, 23) |

---

## 5. Verwendungsbeispiele

### 5.1 Standard-Konfiguration

```cmake
add_executable(MyApp main.cpp)
apply_compiler_options(MyApp)
```

### 5.2 Spezifische Standards

```cmake
add_executable(MyApp main.cpp)
set_language_standards(MyApp CXX_STANDARD 20 C_STANDARD 17)
```

---

## 6. Fehlerbehandlung

Dieses Modul wirft keine Fehler.

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| Plattform-unabhängige Funktionen nutzen | Direkte Compiler-Flags |
| Standards aus Solution.json | Hardcoded Standards |

---

## 8. Siehe auch

- [Warnings.cmake](Warnings.md) — Warning-Konfiguration
- [ExecutableCreate.cmake](../project/ExecutableCreate.md) — Verwendet CompilerOptions

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.1 | 2025-12-05 | English translation |
| 0.1.0 | 2025-12-03 | Initial |
