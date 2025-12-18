# C Coding Standard — Stil-Richtlinien für Embedded

> **Version:** 0.5.1  
> **Datum:** 2025-12-18  
> **Typ:** Standard  
> **Status:** Stabil  
> **Zielgruppe:** Embedded-Entwickler, Firmware-Entwickler  
> **Geltungsbereich:** Alle C-Projekte (Embedded, Firmware)  
> **Durchsetzung:** clang-tidy, MISRA-Checker, Code Review  
> **Sprache:** Deutsch  
> **English:** [C_Coding_Standard.md](../../en/standards/C_Coding_Standard.md)

---

## Inhaltsverzeichnis

1. [Zweck und Geltungsbereich](#1-zweck-und-geltungsbereich)
2. [Sprachversion und Compiler](#2-sprachversion-und-compiler)
3. [Grundprinzipien](#3-grundprinzipien)
4. [Datei-Header](#4-datei-header)
5. [Datei- und Modul-Organisation](#5-datei--und-modul-organisation)
6. [Namenskonventionen](#6-namenskonventionen)
7. [Typen und Daten](#7-typen-und-daten)
8. [Pointer und Speicher](#8-pointer-und-speicher)
9. [Kontrollfluss](#9-kontrollfluss)
10. [Fehlerbehandlung](#10-fehlerbehandlung)
11. [Concurrency und Interrupts](#11-concurrency-und-interrupts)
12. [Hardware-Zugriff](#12-hardware-zugriff)
13. [MISRA und CERT](#13-misra-und-cert)
14. [Tests und Statische Analyse](#14-tests-und-statische-analyse)
15. [Verhältnis zu C++ (PC)](#15-verhältnis-zu-c-pc)
16. [Legacy-Code und Ausnahmen](#16-legacy-code-und-ausnahmen)
17. [Siehe auch](#17-siehe-auch)
18. [Changelog](#18-changelog)

---

## 1. Zweck und Geltungsbereich

Dieser Standard definiert **Coding-Konventionen für C** im Unternehmen, mit Fokus auf **Embedded-Systeme und Firmware**.

### Zielgruppe

Dieser Standard richtet sich an Entwickler, die C Code für Embedded-Systeme, Firmware und sicherheitskritische Anwendungen schreiben. Er ist verbindlich für alle neuen Embedded-Projekte.

### Anwendungsbereich

| Sprache | Fokus | Typische Projekte |
|---------|-------|-------------------|
| C | Embedded | Firmware, MCUs, sicherheitskritische Teile, Real-Time |
| **C++** | PC-Applikationen | Tools, GUIs, Services |

### Alignment

Dieser Standard orientiert sich an:
- **MISRA C:2012** — Sicherheit, Robustheit, UB-Vermeidung
- **SEI CERT C** — Sichere, defensive C-Programmierung

---

## 2. Sprachversion und Compiler

### 2.1 Standard-Version

| Projekt-Typ | C Standard |
|-------------|------------|
| Neue Embedded-Projekte | **C99** (Minimum) |
| Mit Toolchain-Support | C11 erlaubt |

### 2.2 Compiler-Erweiterungen

Erlaubt **nur wenn**:
- Notwendig für Hardware-Zugriff/Performance/Memory-Layout
- Klar dokumentiert an Abstraktionsgrenze

### 2.3 Undefined Behavior

> Code darf **niemals** auf Undefined Behavior oder unspezifiziertem Verhalten basieren.

---

## 3. Grundprinzipien

1. **Determinismus und Vorhersagbarkeit** über maximale Performance
2. **Sicherheit und Robustheit** über clevere Konstrukte
3. **Einfachheit und Klarheit** über Over-Engineering
4. **Statisch analysierbar** — Code muss prüfbar sein

---

## 4. Datei-Header

### 4.1 Standard-Header für C Dateien

Jede `.h` und `.c` Datei **muss** mit folgendem Doxygen-kompatiblen Header beginnen:

```c
/**
 ****************************************************************************************
 * @file   filename.h
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
| `@note` | Wichtige Hinweise (z.B. Hardware-Abhängigkeiten) |

### 4.4 Beispiel

```c
/**
 ****************************************************************************************
 * @file   gpio_driver.h
 * @brief  GPIO Driver Interface
 *         Low-level GPIO control for STM32F4
 *
 * @author Patrik Neunteufel
 * @date   December 2025
 * @note   Hardware: STM32F407VG
 ****************************************************************************************
 */

#ifndef GPIO_DRIVER_H
#define GPIO_DRIVER_H

#include <stdint.h>
// ...
```

### 4.5 Sprache

- **Englisch** ist Pflicht für alle öffentlichen APIs und wiederverwendbare Module
- Projektspezifische interne Dateien können Deutsch verwenden

---

## 5. Datei- und Modul-Organisation

### 5.1 Dateistruktur

| Typ | Extension | Inhalt |
|-----|-----------|--------|
| Implementation | `.c` | Funktions-Implementierungen |
| Interface | `.h` | Deklarationen, Typen, Makros |

### 5.2 Modul-Design

- Jedes Modul hat **eine klare Verantwortung**
- Öffentliches Interface minimal halten
- Interne Details verstecken (`static` Funktionen)

### 5.3 Include Guards

```c
#ifndef MODULE_NAME_H
#define MODULE_NAME_H

// ... content ...

#endif /* MODULE_NAME_H */
```

Oder `#pragma once` (falls Projektrichtlinie).

---

## 6. Namenskonventionen

### 6.1 Übersicht

| Entität | Konvention | Beispiel |
|---------|------------|----------|
| Modul-Funktion | `modul_snake_case` | `timer_init()`, `gpio_set_pin()` |
| Lokale Variable | `snake_case` | `current_index`, `buffer_size` |
| Globale Variable | `g_` Prefix | `g_systemState` |
| Statische Variable | `s_` Prefix | `s_bufferIndex` |
| Konstante/Makro | `UPPER_CASE` | `MAX_BUFFER_SIZE`, `ADC_TIMEOUT` |
| Typ-Alias | `CamelCase` oder `snake_case` | `TimerHandle`, `gpio_pin_t` |

### 6.2 Modul-Prefix

Funktionen erhalten Modul-Prefix für Namensraum-Emulation:

```c
// Timer module
void timer_init(void);
void timer_start(TimerHandle handle);
void timer_stop(TimerHandle handle);

// GPIO module
void gpio_init(void);
void gpio_set_pin(uint8_t pin, bool state);
uint8_t gpio_read_pin(uint8_t pin);
```

---

## 7. Typen und Daten

### 7.1 Fixed-Width Types

Verwende `<stdint.h>` wo Größe wichtig ist:

| Typ | Verwendung |
|-----|------------|
| `uint8_t`, `int8_t` | Byte-Daten |
| `uint16_t`, `int16_t` | 16-Bit-Werte |
| `uint32_t`, `int32_t` | 32-Bit-Werte |
| `size_t` | Größen und Indizes |
| `bool` (C99) | Boolesche Werte |

### 7.2 Signed/Unsigned

- **Keine Mischung** ohne explizite Behandlung
- Truncation und Sign-Extension bewusst handhaben

---

## 8. Pointer und Speicher

### 8.1 Pointer-Regeln

| Regel | Beschreibung |
|-------|--------------|
| Keine Pointer-Arithmetik | Außer einfach, begrenzt, dokumentiert |
| Validierung | Pointer vor Dereference prüfen |
| `const`-Correctness | Dokumentiert Intent |

```c
// ✅ const-correct
void processData(const uint8_t* data, size_t length);

// ✅ Pointer to constant pointer
const char* const MESSAGE = "Hello";
```

### 8.2 Dynamische Allokation

| Regel | Embedded-Kontext |
|-------|------------------|
| **Zur Laufzeit vermeiden** | `malloc`/`free` nicht verwenden |
| Nur in Init-Phase | Falls unvermeidbar, dokumentieren |
| Fallback-Strategie | Dokumentieren was bei Fehlschlag passiert |

### 8.3 Ownership

- Jede dynamisch allokierte Ressource hat **einen klaren Owner**
- Ownership-Transfer **explizit** in Funktionsnamen/Dokumentation

---

## 9. Kontrollfluss

### 9.1 Strukturierter Code

Erlaubt:
- `if` / `else`
- `switch` / `case`
- `for` / `while` / `do-while`

### 9.2 goto

**Generell vermeiden.** Erlaubt nur für:
- Kontrolliertes Error-Handling mit Cleanup
- In einer einzigen Funktion

```c
int processFile(const char* path)
{
    FILE* file = NULL;
    int result = -1;
    
    file = fopen(path, "r");
    if (!file)
    {
        goto cleanup;
    }
    
    // ... processing ...
    
    result = 0;
    
cleanup:
    if (file)
    {
        fclose(file);
    }
    return result;
}
```

### 9.3 Funktionen

- **Eine klare Verantwortung** pro Funktion
- Nicht übermäßig lang (Richtwert: 50-100 Zeilen)

---

## 10. Fehlerbehandlung

### 10.1 Keine Exceptions

C verwendet **Return Codes** und **Out-Parameter**:

```c
typedef enum
{
    RESULT_OK = 0,
    RESULT_ERROR_INVALID_PARAM,
    RESULT_ERROR_TIMEOUT,
    RESULT_ERROR_HARDWARE
} Result;

Result sensor_read(uint16_t* outValue);
```

### 10.2 Rückgabewerte prüfen

**Jeder Rückgabewert muss:**
- Geprüft werden, oder
- Explizit mit Kommentar ignoriert werden

```c
// ✅ Checked
Result result = sensor_read(&value);
if (result != RESULT_OK)
{
    handleError(result);
}

// ✅ Explicitly ignored
(void)printf("Debug: %d\n", value);  // Return value irrelevant
```

### 10.3 Error-Code-Design

- Enumeriert und dokumentiert
- Eindeutige Codes pro Modul
- Mapping zu Logging/Diagnostik

---

## 11. Concurrency und Interrupts

### 11.1 Shared Data

Daten zwischen Interrupt und Main-Context:

| Anforderung | Mechanismus |
|-------------|-------------|
| `volatile` | Für Register und ISR-Flags |
| Atomare Operationen | Für Multi-Byte-Werte |
| Critical Sections | Interrupt-Disable wo nötig |

### 11.2 Richtlinien

- **Critical Sections minimal halten**
- **Race Conditions by Design vermeiden**
- **Keine Trial-and-Error-Synchronisation**

```c
// ✅ Atomic access
static volatile uint32_t s_tickCounter;

void SysTick_Handler(void)
{
    s_tickCounter++;
}

uint32_t getTicks(void)
{
    uint32_t ticks;
    __disable_irq();
    ticks = s_tickCounter;
    __enable_irq();
    return ticks;
}
```

---

## 12. Hardware-Zugriff

### 12.1 Register-Handling

| Regel | Beschreibung |
|-------|--------------|
| `volatile` | Für alle Hardware-Register |
| Kapselung | In dedizierten Modulen/Treibern |
| Keine Magic Addresses | Benannte Konstanten verwenden |

### 12.2 Register-Definition

```c
// ✅ Structured access
typedef struct
{
    volatile uint32_t CR;      // Control Register
    volatile uint32_t SR;      // Status Register
    volatile uint32_t DR;      // Data Register
} UART_TypeDef;

#define UART1 ((UART_TypeDef*)0x40011000UL)
```

### 12.3 Dokumentation

- Endianness dokumentieren
- Alignment-Anforderungen dokumentieren
- Memory-Mapped I/O kennzeichnen

---

## 13. MISRA und CERT

### 13.1 MISRA C:2012 Alignment

| Kategorie | Umsetzung |
|-----------|-----------|
| Typen | Fixed-Width, keine impliziten Konvertierungen |
| Kontrollfluss | Strukturiert, kein unreachable Code |
| Pointer | Validierung, begrenzte Arithmetik |
| UB-Vermeidung | Keine Abhängigkeit von undefiniertem Verhalten |

### 13.2 SEI CERT C Alignment

| Kategorie | Umsetzung |
|-----------|-----------|
| Input-Validierung | Alle externen Inputs prüfen |
| Integer-Handling | Overflow/Truncation bewusst handhaben |
| Buffer-Handling | Bounds prüfen |
| Ressourcen | Keine Leaks, klares Ownership |

### 13.3 Compliance-Dokumentation

Projekte mit MISRA/CERT-Anspruch dokumentieren:
- Anwendbare Regeln
- Begründete Abweichungen

---

## 14. Tests und Statische Analyse

### 14.1 Tests

| Test-Typ | Beschreibung |
|----------|--------------|
| Unit Tests | Wo praktikabel (PC-hosted) |
| Integration Tests | Auf Ziel-Hardware oder Simulation |

### 14.2 Statische Analyse

Empfohlene Tools:
- `clang-tidy` (PC-Build)
- Vendor-spezifische Checker
- MISRA-Checker

Warnungen mit Safety-Relevanz **müssen** behoben oder begründet werden.

---

## 15. Verhältnis zu C++ (PC)

### 15.1 Unterschiede

| Aspekt | C (Embedded) | C++ (PC) |
|--------|--------------|----------|
| Exceptions | Nein | Ja |
| Dynamic Allocation | Vermeiden | Erlaubt |
| Standard Library | Minimal | Voll |
| Abstraktion | Prozedural | OOP erlaubt |

### 15.2 Shared Components

Interfaces zwischen C und C++:

```c
// header.h
#ifdef __cplusplus
extern "C" {
#endif

void shared_function(int param);

#ifdef __cplusplus
}
#endif
```

---

## 16. Legacy-Code und Ausnahmen

### 16.1 Legacy-Code

- Temporär erlaubt wenn nicht compliant
- Neuer Code **immer** nach Standard
- Refactoring-Chancen nutzen

### 16.2 Intentionale Abweichungen

- Kommentar im Code
- Begründung dokumentieren
- Scope minimieren

---

## 17. Siehe auch

- [Cpp_Coding_Standard.md](Cpp_Coding_Standard.md) — C++ (PC)
- [CMake_Standard.md](CMake_Standard.md) — Build-System
- MISRA C:2012 Guidelines
- SEI CERT C Coding Standard

---

## 18. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.1** | **2025-12-18** | **Neuer Abschnitt 4: Datei-Header mit Doxygen-Format, Pflichtfelder, Sprachregelung** |
| 0.5.0 | 2025-12-13 | Migration auf Blueprint v0.5: Neuer Header, Inhaltsverzeichnis, Encoding-Fix |
| 0.1.0 | 2025-12-05 | Initial: Embedded-Fokus, MISRA/CERT-Alignment, Interrupt-Handling |
