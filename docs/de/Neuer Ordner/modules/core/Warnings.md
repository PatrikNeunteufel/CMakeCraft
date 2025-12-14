# Warnings.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/core/Warnings.cmake](../../../cmake/core/Warnings.cmake)  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [Warnings.md](../../en/modules/core/Warnings.md)

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

Das `Warnings.cmake` Modul konfiguriert Compiler-Warnungen mit abstrahierten Warning-Levels.

### Features

- Plattform-unabhängige Warning-Level
- MSVC/GCC/Clang Unterstützung
- Granulare Kontrolle über Warnungen

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| CMake 3.19+ | System | Basis |

---

## 3. Konzept

### 3.1 Warning-Level

| Level | MSVC | GCC/Clang | Beschreibung |
|-------|------|-----------|--------------|
| `0` | `/W0` | `-w` | Keine Warnungen |
| `1` | `/W1` | `-Wall` | Basis-Warnungen |
| `2` | `/W2` | `-Wall -Wextra` | Standard |
| `3` | `/W3` | `-Wall -Wextra -Wpedantic` | Strikt |
| `4` | `/W4` | `-Wall -Wextra -Wpedantic -Werror` | Alles + Fehler |

### 3.2 Warnings as Errors

| Setting | MSVC | GCC/Clang |
|---------|------|-----------|
| Aktiviert | `/WX` | `-Werror` |

---

## 4. API-Referenz

### 4.1 apply_warning_level()

Setzt Warning-Level für ein Target.

```cmake
apply_warning_level(<TARGET> <LEVEL>)
```

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `TARGET` | ✓ | Target-Name |
| `LEVEL` | ✓ | Warning-Level (0-4) |

---

### 4.2 enable_warnings_as_errors()

Aktiviert Warnungen als Fehler.

```cmake
enable_warnings_as_errors(<TARGET>)
```

---

## 5. Verwendungsbeispiele

### 5.1 Standard-Konfiguration

```cmake
add_executable(MyApp main.cpp)
apply_warning_level(MyApp 3)
```

### 5.2 Strikte Konfiguration

```cmake
add_executable(MyApp main.cpp)
apply_warning_level(MyApp 4)
enable_warnings_as_errors(MyApp)
```

---

## 6. Fehlerbehandlung

Dieses Modul wirft keine Fehler.

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| Level 3 für Produktion | Level 0 im Release |
| Warnings as Errors in CI | Warnungen ignorieren |
| Plattform-unabhängige Level verwenden | Direkte Compiler-Flags |

---

## 8. Siehe auch

- [CompilerOptions.cmake](CompilerOptions.md) — Compiler-Konfiguration
- [ExecutableCreate.cmake](../project/ExecutableCreate.md) — Wendet Warnings an

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.1 | 2025-12-05 | English translation |
| 0.1.0 | 2025-12-03 | Initial |
