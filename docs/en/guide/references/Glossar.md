# Glossary — Reference

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Glossar.md](../../../de/guide/references/Glossar.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Conventions](#2-conventions)
3. [Abbreviations](#3-abbreviations)
4. [CMake Terms](#4-cmake-terms)
5. [Project Terms](#5-project-terms)
6. [Build System Concepts](#6-build-system-concepts)
7. [Architecture Patterns](#7-architecture-patterns) ← **NEW**
8. [C++ Idioms](#8-c-idioms) ← **NEW**
9. [Types and Modes](#9-types-and-modes)
10. [Compilers and Flags](#10-compilers-and-flags)
11. [File Extensions](#11-file-extensions)
12. [Error Code Ranges](#12-error-code-ranges)
13. [Debug Levels](#13-debug-levels)
14. [Translation Reference](#14-translation-reference)
15. [See Also](#15-see-also)
16. [Changelog](#16-changelog)

---

## 1. Overview

This glossary defines all technical terms used in the documentation of the CMake Architecture build system. It serves as the central lookup reference for consistent terminology.

### Target Audience

- All developers on the project
- New team members during onboarding
- Documentation authors, for consistent terms

---

## 2. Conventions

### Notation

| Symbol | Meaning |
|--------|---------|
| **Bold** | Primary term |
| `Code` | Technical identifier |
| → | Reference to another entry |

### Language

Terms are explained in English in this edition (in German in the German edition). English technical terms are kept where they are common in practice (e.g. "Target", "External", "Hook", "EventBus").

---

## 3. Abbreviations

| Abbreviation | Spelled Out | Explanation |
|--------------|-------------|-------------|
| **API** | Application Programming Interface | Programming interface |
| **CI/CD** | Continuous Integration/Continuous Deployment | Automated build and deployment pipelines |
| **CLI** | Command Line Interface | Command line interface |
| **CRT** | C Runtime Library | Windows C runtime library |
| **DI** | Dependency Injection | Design pattern for decoupling |
| **DLL** | Dynamic Link Library | Dynamically loaded library (Windows) |
| **DSP** | Digital Signal Processing | Digital signal processing |
| **EMA** | Exponential Moving Average | Smoothing algorithm for time series |
| **FFT** | Fast Fourier Transform | Fast Fourier transform |
| **FPS** | Frames Per Second | Frames per second |
| **GUI** | Graphical User Interface | Graphical user interface |
| **i18n** | Internationalization | Internationalization (i + 18 letters + n) |
| **IDE** | Integrated Development Environment | Integrated development environment |
| **JSON** | JavaScript Object Notation | Data interchange format |
| **LOC** | Lines of Code | Lines of code (complexity metric) |
| **PCH** | Precompiled Header | Precompiled header file to speed up builds |
| **PIMPL** | Pointer to Implementation | Design pattern for encapsulation |
| **PR** | Pull Request | Request for code integration |
| **RAII** | Resource Acquisition Is Initialization | C++ idiom for automatic resource management |
| **RTTI** | Run-Time Type Information | Run-time type information in C++ |
| **SemVer** | Semantic Versioning | Semantic versioning (MAJOR.MINOR.PATCH) |
| **SO** | Shared Object | Dynamically loaded library (Linux) |
| **TDD** | Test-Driven Development | Test-driven development |

---

## 4. CMake Terms

| Term | Explanation |
|------|-------------|
| **Cache variable** | Persistent CMake variable, stored in CMakeCache.txt |
| **Configure** | First phase of the CMake build: project configuration |
| **FetchContent** | CMake module for downloading dependencies |
| **Generator** | Backend for the build system (Visual Studio, Ninja, Make) |
| **include_guard** | Prevents a CMake file from being loaded more than once |
| **Preset** | Predefined CMake configuration in CMakePresets.json |
| **Property** | CMake property (target, directory, global) |
| **Target** | Build unit in CMake (executable, library, custom) |
| **Toolchain** | Compiler + linker + tools for a platform |

---

## 5. Project Terms

These terms are **not translated** in our project:

| Term | Explanation |
|------|-------------|
| **Context** | Isolated namespace for build data (ctx_create, ctx_set, ctx_get) |
| **External** | External dependency/library in the build system |
| **Hook** | Callback mechanism for external processing (PreFetch, PostFetch) |
| **Pipeline** | Multi-stage processing (Collect → Create → Configure) |
| **Solution** | Central configuration file (Solution.json) |

---

## 6. Build System Concepts

| Term | Explanation |
|------|-------------|
| **Convention over Configuration** | Default behavior without explicit configuration |
| **Declarative** | Descriptive instead of imperative (what instead of how) |
| **Fail-fast** | Aborting early on errors |
| **Fetched External** | External that is downloaded from Git |
| **Local External** | External that lives in the repository |
| **Single Source of Truth** | One central place for information |

---

## 7. Architecture Patterns

> **New in v0.6.0** — General software architecture terms

### 7.1 Architecture Styles

| Term | Explanation |
|------|-------------|
| **Service architecture** | Architecture style with passive services that are controlled from outside. Services wrap domain logic and communicate via → EventBus. |
| **Agent architecture** | Architecture style with autonomous agents that have their own behavior and → state machine. Agents react to events on their own. |
| **Microservices** | Architecture style with independently deployable services that communicate over a network. |
| **Monolith** | Architecture style with a single, cohesive application. |

### 7.2 Communication Patterns

| Term | Explanation |
|------|-------------|
| **EventBus** | Central message broker for type-safe → publish/subscribe. Enables → loose coupling between modules. |
| **CommandBus** | Dispatcher for named actions (commands). Enables UI actions via string IDs. |
| **MessageQueue** | Asynchronous message queue between components. |
| **Publish/Subscribe** | Decoupling pattern: the publisher does not know the subscriber; both only know the → EventBus. |
| **Observer** | Pattern in which objects (observers) react to changes of a subject. More tightly coupled than → publish/subscribe. |
| **Request/Response** | Synchronous communication pattern: request → response. |

### 7.3 Event Concepts

| Term | Explanation |
|------|-------------|
| **Event** | Immutable data struct describing something that has happened. |
| **Command** | Named action that can be executed. Imperative (do something). |
| **Publisher** | Component that publishes events. |
| **Subscriber** | Component that receives events. |
| **Subscription** | Registration of a → subscriber for an event type. |
| **Handler** | Function that reacts to an event or command. |

### 7.4 Dependency Injection

| Term | Explanation |
|------|-------------|
| **Dependency Injection** | Design pattern: dependencies are passed in from outside instead of being created internally. |
| **ServiceContainer** | Container that holds all services and injects them on demand. Also: IoC container. |
| **IoC** | Inversion of Control. The principle behind → dependency injection. |
| **Singleton** | Lifetime: exactly one instance for the whole application. |
| **Scoped** | Lifetime: one instance per scope (e.g. request). |
| **Transient** | Lifetime: new instance on every retrieval. |

### 7.5 Design Principles

| Term | Explanation |
|------|-------------|
| **Loose coupling** | Modules do not know each other directly and communicate only via abstractions. Opposite: → tight coupling. |
| **Tight coupling** | Modules call each other directly. Hard to test, fragile. To be avoided. |
| **Interface-first design** | Define the interface first, then the implementation. Allows later replacement. |
| **Separation of Concerns** | Each module has exactly one responsibility. |
| **Single Responsibility** | A class should have only one reason to change. |
| **Open/Closed Principle** | Open for extension, closed for modification. |

### 7.6 State Management

| Term | Explanation |
|------|-------------|
| **State machine** | Finite-state automaton with defined states and transitions. |
| **Immutable** | Unchangeable after creation. Events should be immutable. |
| **Mutable** | Changeable. Opposite of → immutable. |

---

## 8. C++ Idioms

> **New in v0.6.0** — General C++ terms and idioms

| Term | Explanation |
|------|-------------|
| **RAII** | Resource Acquisition Is Initialization. Resources are acquired in the constructor and released in the destructor. |
| **PIMPL** | Pointer to Implementation. Encapsulation of the implementation behind a pointer. |
| **CRTP** | Curiously Recurring Template Pattern. A class inherits from a template with itself as the parameter. |
| **Type erasure** | Technique for hiding template types behind a non-template interface. |
| **StrongId** | Type-safe ID wrapper: `StrongId<T, Tag>`. Prevents mixing up different ID types at compile time. |
| **Tag dispatch** | Overload selection via empty tag types. |
| **SFINAE** | Substitution Failure Is Not An Error. Template metaprogramming. |
| **Copy-and-swap** | Idiom for an exception-safe assignment operator. |
| **Rule of Zero** | No user-defined destructor/copy/move if possible. |
| **Rule of Five** | If one of destructor/copy ctor/copy assignment/move ctor/move assignment is needed, then all five. |

---

## 9. Types and Modes

### 9.1 Executable Types

| Type | Usage |
|------|-------|
| **CONSOLE** | Command line application with stdout/stderr |
| **GUI** | Graphical application (Windows: WinMain) |
| **CLI** | Command line tool with argument parsing |
| **HEADLESS** | Server/service without a user interface |
| **WORKER** | Background process |

### 9.2 Library Types

| Type | Explanation |
|------|-------------|
| **STATIC** | Statically linked library (.a, .lib) |
| **SHARED** | Dynamically linked library (.so, .dll) |
| **INTERFACE** | Header-only library (no compilation) |

### 9.3 Test Types

| Type | Explanation | Typical Timeout |
|------|-------------|-----------------|
| **UNIT** | Isolated function/class tests | 30s |
| **INTEGRATION** | Interaction of several components | 120s |
| **SYSTEM** | End-to-end tests | 300s |
| **PERFORMANCE** | Performance and benchmark tests | 600s |

### 9.4 Source Modes

| Mode | Explanation |
|------|-------------|
| **explicit** | Source.cmake required (recommended) |
| **glob** | Automatic collection via wildcard |
| **auto** | Source.cmake if present, otherwise GLOB |

---

## 10. Compilers and Flags

### 10.1 Compilers

| Term | Explanation |
|------|-------------|
| **Clang** | LLVM-based C/C++ compiler |
| **Clang-CL** | Clang with an MSVC-compatible frontend (Windows) |
| **Clang-Format** | Code formatting tool |
| **Clang-Tidy** | Static analysis tool |
| **GCC** | GNU Compiler Collection |
| **MinGW** | Minimalist GNU for Windows |
| **MSVC** | Microsoft Visual C++ compiler |
| **Apple Clang** | Apple's variant of the Clang compiler |

### 10.2 MSVC Flags

| Flag | Explanation |
|------|-------------|
| `/EHsc` | Exception handling enabled |
| `/EHs-c-` | Exception handling disabled |
| `/GR-` | RTTI disabled |
| `/permissive-` | Strict standard conformance |
| `/W4` | High warning level |
| `/Zc:__cplusplus` | Correct __cplusplus macro value |
| `/Zc:preprocessor` | Standard-conforming preprocessor |

### 10.3 GCC/Clang Flags

| Flag | Explanation |
|------|-------------|
| `-fno-exceptions` | Exception handling disabled |
| `-fno-rtti` | RTTI disabled |
| `-Wall` | All important warnings |
| `-Wextra` | Additional warnings |
| `-Wpedantic` | Strict standard conformance |

---

## 11. File Extensions

| Extension | Usage |
|-----------|-------|
| `.cmake` | CMake module |
| `.cpp`, `.cxx`, `.cc`, `.c` | Compilable source files |
| `.h`, `.hpp`, `.hxx`, `.hh` | Header files |
| `.tpp`, `.txx`, `.ipp` | Template implementations |
| `.inl` | Inline implementations |
| `.impl` | PIMPL details |
| `.ixx`, `.cppm`, `.mpp` | C++20 module interface units |
| `.a`, `.lib` | Static libraries |
| `.so`, `.dll` | Dynamic libraries |
| `.vert`, `.frag`, `.glsl` | GLSL shader files |

---

## 12. Error Code Ranges

| Range | Description |
|-------|-------------|
| **E0xx** | JSON/parsing errors |
| **E1xx** | Target creation |
| **E2xx** | External processing |
| **E3xx** | Test pipeline |
| **E4xx** | App container pipeline |
| **E5xx** | System externals |
| **W0xx** | Deprecation warnings |
| **W1xx** | Configuration warnings |
| **W2xx** | Tool/setup warnings |
| **W3xx** | External caching warnings |
| **W4xx** | App container warnings |
| **W5xx** | System external warnings |

---

## 13. Debug Levels

### 13.1 Display Level (what we see)

| Level | Constant | Usage |
|-------|----------|-------|
| 1 | `DBG_SHOW_LITTLE` | Only the most important |
| 2 | `DBG_SHOW_SOME` | Standard (default) |
| 3 | `DBG_SHOW_MUCH` | More details |
| 4 | `DBG_SHOW_LOTS` | Many details |
| 5 | `DBG_SHOW_ALL` | Everything |

### 13.2 Message Level (how important the message is)

| Level | Constant | Message Importance |
|-------|----------|--------------------|
| 1 | `DBG_OFTEN` | Frequent, important (phase start) |
| 2 | `DBG_COMMON` | Common info (features) |
| 3 | `DBG_NORMAL` | Standard (intermediate steps) |
| 4 | `DBG_RARE` | Rare (paths, details) |
| 5 | `DBG_ULTRA_RARE` | Deep debugging |

---

## 14. Translation Reference

Consistent translations between German and English:

| German | English |
|--------|---------|
| Abhängigkeit | Dependency |
| Agent | Agent |
| Ausführbare Datei | Executable |
| Bibliothek | Library |
| Dienst / Service | Service |
| Enge Kopplung | Tight Coupling |
| Ereignis | Event |
| Konfiguration | Configuration |
| Lose Kopplung | Loose Coupling |
| Pflichtfeld | Required field |
| Verzeichnis | Directory |
| Warnung | Warning |
| Fehler | Error |
| Einstellung | Setting |
| Ziel | Target |
| Zustandsautomat | State Machine |

---

## 15. See Also

- [ErrorCodes.md](ErrorCodes.md) — Complete error code reference
- [Solution_Schema.md](Solution_Schema.md) — JSON schema reference
- [Cpp_Coding_Standard.md](../../autorenwerk/standards/Cpp_Coding_Standard.md) — Coding conventions

---

## 16. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.6.0 | 2025-12-24 | New sections: 7. Architecture Patterns (service/agent architecture, EventBus, CommandBus, publish/subscribe, dependency injection, design principles), 8. C++ Idioms (RAII, PIMPL, CRTP, type erasure, StrongId, Rule of Zero/Five). New abbreviations: DI, EMA, FFT, FPS, LOC, RAII, TDD. New file extensions: .vert, .frag, .glsl |
| 0.5.0 | 2025-12-14 | Blueprint v0.5.0 format: numbered TOC, reference header, complete error code ranges |
| 0.1.0 | 2025-12-05 | Initial: terms collected from all documentation |
