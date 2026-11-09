# Externals — External-Management-System

> **Version:** 1.0.1  
> **Datum:** 2026-11-09  
> **Sprache:** Deutsch  
> **English:** [README.md](../../../../en/guide/module/externals/README.md)

---

## Quick-Start

**Externe Libraries einbinden?**
1. [Orchestrator_cmake.md](Orchestrator_cmake.md) — Haupt-Entry verstehen
2. [../../userguides/Externals.md](../../userguides/Externals.md) — Praktische Anleitung
3. [../../userguides/Adding_Externals.md](../../userguides/Adding_Externals.md) — Neue External hinzufügen

**Git-basierte Library fetchen?**
1. [core/Fetch_cmake.md](core/Fetch_cmake.md) — FetchContent-Wrapper
2. [hooks/HookLoader_cmake.md](hooks/HookLoader_cmake.md) — Pre/Post-Fetch Hooks
3. [fetched/Handler_cmake.md](fetched/Handler_cmake.md) — Post-Fetch Verarbeitung

**Lokale Library einbinden?**
1. [locals/Attach_cmake.md](locals/Attach_cmake.md) — Local-Attach-System
2. [includes/](includes/bass/Bass_Include.md) — Include-Definitionen pro Library

**Vorgebautes Paket beziehen?**
1. [archive/Handler_cmake.md](archive/Handler_cmake.md) — External-Art `archive`
2. [../CMakeCraftPackage.md](../CMakeCraftPackage.md) — Pin-Datei, Bezug, Auslieferung

**Hook für Library schreiben?**
1. [hooks/HookLoader_cmake.md](hooks/HookLoader_cmake.md) — Hook-System verstehen
2. [hooks/prefetch/Glfw.md](hooks/prefetch/Glfw.md) — Beispiel: Pre-Fetch Hook
3. [hooks/postfetch/Imgui.md](hooks/postfetch/Imgui.md) — Beispiel: Post-Fetch Hook

**Target-Registry verstehen?**
1. [registry/Targets_cmake.md](registry/Targets_cmake.md) — Zentrale Target-Verwaltung

---

## Übersicht

Das External-Management-System handhabt alle externen Dependencies: lokale (`path`), Git-basierte (`git`, fetched), System- (`system`, find_package) und Archiv-Externals (`archive`, vorgebaute Pakete). Es nutzt ein zentralisiertes Registry-System und Hook-Mechanismen.

### Architektur

```
cmake/externals/
├── Orchestrator.cmake           ← Haupt-Entry, erkennt den Typ und verteilt
│
├── local/
│   └── Attach.cmake             ← Bindet lokale Libs ein ("path")
├── includes/                    ← Include.cmake je lokales External
│   ├── bass/Include.cmake
│   ├── doctest/Include.cmake
│   ├── glad/Include.cmake
│   └── lua54/Include.cmake
│
├── fetched/
│   └── Handler.cmake            ← Verarbeitet gefetchte Libs ("git")
├── core/
│   └── Fetch.cmake              ← Git FetchContent
├── hooks/                       ← Pre/Post-Fetch Hooks
│   ├── HookLoader.cmake
│   ├── prefetch/                ← catch2, glfw, googletest, qt-ads, qt-ads110 (.cmake)
│   └── postfetch/               ← imgui, qt-ads, qt-ads110, stb (.cmake)
├── registry/
│   └── Targets.cmake            ← Zentrale Target-Registry
│
├── system/                      ← System-Externals über find_package ("system": true)
│   ├── Handler.cmake
│   ├── PathResolver.cmake
│   └── packages/                ← Qt6.cmake, Boost.cmake
│
└── archive/
    └── Handler.cmake            ← Bezieht vorgebaute Pakete ("archive": true; CMakeCraftPackage.cmake)
```

---

## Dateien

| Datei | Beschreibung |
|-------|--------------|
| [Orchestrator_cmake.md](Orchestrator_cmake.md) | Haupt-Orchestrierung — koordiniert alle External-Operationen |

---

## Unterordner

| Ordner | Dateien | Beschreibung |
|--------|---------|--------------|
| [archive/](archive/Handler_cmake.md) | 1 | Handler für Archive Externals |
| [core/](core/Fetch_cmake.md) | 1 | Kern-Funktionen |
| [fetched/](fetched/Handler_cmake.md) | 1 | Handler für gefetchte Libraries |
| [hooks/](hooks/HookLoader_cmake.md) | 8 | Pre/Post-Fetch Hook-System |
| [includes/](includes/bass/Bass_Include.md) | 4 | Library-spezifische Includes |
| [locals/](locals/Attach_cmake.md) | 1 | Lokale Library-Integration (Code: `local/`) |
| [registry/](registry/Targets_cmake.md) | 1 | Target-Registry |
| [system/](system/README.md) | 5 | System-Externals (find_package) |

---

## Unterordner-Dateien (Direktzugriff)

### core/ — Kern-Funktionen

| Datei | Beschreibung |
|-------|--------------|
| [core/Fetch_cmake.md](core/Fetch_cmake.md) | Git FetchContent Wrapper mit Hook-Integration |

### fetched/ — Post-Fetch Handler

| Datei | Beschreibung |
|-------|--------------|
| [fetched/Handler_cmake.md](fetched/Handler_cmake.md) | Verarbeitet Libraries nach Git-Fetch |

### archive/ — Archive Externals

| Datei | Beschreibung |
|-------|--------------|
| [archive/Handler_cmake.md](archive/Handler_cmake.md) | Bezieht vorgebaute Pakete in festgelegter Version und wendet sie auf Targets an |

### locals/ — Lokale Libraries

| Datei | Beschreibung |
|-------|--------------|
| [locals/Attach_cmake.md](locals/Attach_cmake.md) | Bindet vorinstallierte Libraries an Targets |

### registry/ — Target-Registry

| Datei | Beschreibung |
|-------|--------------|
| [registry/Targets_cmake.md](registry/Targets_cmake.md) | Zentrale Verwaltung aller External-Targets |

### hooks/ — Hook-System

| Datei | Beschreibung |
|-------|--------------|
| [hooks/HookLoader_cmake.md](hooks/HookLoader_cmake.md) | Hook-Loader und Discovery |
| [hooks/prefetch/Catch2.md](hooks/prefetch/Catch2.md) | Catch2 Pre-Fetch Hook |
| [hooks/prefetch/Glfw.md](hooks/prefetch/Glfw.md) | GLFW Pre-Fetch Hook |
| [hooks/prefetch/Googletest.md](hooks/prefetch/Googletest.md) | GoogleTest Pre-Fetch Hook |
| [hooks/prefetch/Qt-Ads_PreFetch.md](hooks/prefetch/Qt-Ads_PreFetch.md) | Qt-ADS Pre-Fetch Hook |
| [hooks/postfetch/Imgui.md](hooks/postfetch/Imgui.md) | ImGui Post-Fetch Hook |
| [hooks/postfetch/Qt-Ads_PostFetch.md](hooks/postfetch/Qt-Ads_PostFetch.md) | Qt-ADS Post-Fetch Hook |
| [hooks/postfetch/Stb.md](hooks/postfetch/Stb.md) | stb Post-Fetch Hook |

### includes/ — Library-Includes

| Datei | Beschreibung |
|-------|--------------|
| [includes/bass/Bass_Include.md](includes/bass/Bass_Include.md) | BASS Audio Library + Plugins |
| [includes/doctest/Doctest_Include.md](includes/doctest/Doctest_Include.md) | doctest Testing Framework |
| [includes/glad/Glad_Include.md](includes/glad/Glad_Include.md) | GLAD OpenGL Loader |
| [includes/lua54/Lua54_Include.md](includes/lua54/Lua54_Include.md) | Lua 5.4 Scripting Engine |

### system/ — System-Externals

| Datei | Beschreibung |
|-------|--------------|
| [system/README.md](system/README.md) | Übersicht System-Externals |
| [system/Handler_cmake.md](system/Handler_cmake.md) | find_package-Handler |
| [system/PathResolver_cmake.md](system/PathResolver_cmake.md) | Suchpfade |
| [system/packages/Qt6_cmake.md](system/packages/Qt6_cmake.md) | Paket-Hook Qt6 |
| [system/packages/Boost_cmake.md](system/packages/Boost_cmake.md) | Paket-Hook Boost |

---

## External-Typen

| Typ | Quelle | Beispiele | Referenz |
|-----|--------|-----------|----------|
| **Git (fetched)** | Git Repository | GLFW, ImGui, doctest | [Git_Externals.md](../../references/externals/Git_Externals.md) |
| **Local** | Ordner im Projekt (`path`) | BASS, Lua, glad, doctest | [Local_Externals.md](../../references/externals/Local_Externals.md) |
| **System** | Installiertes Paket über find_package (`"system": true`) | Qt6, Boost | [system/Handler_cmake.md](system/Handler_cmake.md) |
| **Archive** | Vorgebautes Paket (Pin-Datei mit Version, URL, SHA256) | — | [archive/Handler_cmake.md](archive/Handler_cmake.md) |

---

## Siehe auch

- [../README.md](../README.md) — Modul-Übersicht
- [../../references/Externals.md](../../references/Externals.md) — Externals-Referenz
- [../../references/externals/](../../references/README.md) — External-Definitionen
- [../../userguides/Externals.md](../../userguides/Externals.md) — Externals User Guide

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **An den Code angeglichen: Architekturbaum nach `cmake/externals/` (`local/`, `system/`, `archive/`, Hook-Dateien klein, `includes/<name>/Include.cmake`); Ordnertabelle mit `archive/` und `system/`, 8 Hook-Dokumente; System-Externals als eigener Typ** |
| 1.0.0 | 2025-12-26 | Release 1 (aus newCMake übernommen, `2e00db7`) |
