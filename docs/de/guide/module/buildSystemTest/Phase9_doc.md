# phase9.cmake — Modul-Dokumentation

> **Version:** 1.1.0  
> **Datum:** 2026-11-09  
> **Typ:** ModuleDoc  
> **Pfad:** `cmake/buildSystemTest/phase9.cmake`  
> **Status:** Stabil  
> **Sprache:** Deutsch  
> **English:** [Phase9_doc.md](../../../../en/guide/module/buildSystemTest/Phase9_doc.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Tests](#2-tests)
3. [Erfolgs-Flag](#3-erfolgs-flag)
4. [Siehe auch](#4-siehe-auch)
5. [Changelog](#5-changelog)

---

## 1. Übersicht

**Phase 9** testet die **System Externals** — die Erkennung von `system: true`, die Felder `package`, `version`, `components`, `hints`, `backup` und `required`, die Typ-Priorität `system` → `git` → `path`, die Module Handler und PathResolver, die Package-Hooks, den Einstiegspunkt von Qt-GUI-Programmen und die Fehlercodes E503–E505 des System-Handlers.

| Aspekt | Beschreibung |
|--------|--------------|
| **Zweck** | System-External-Pipeline validieren |
| **Debug-ID** | `PHASE9_TEST` |
| **Abhängigkeiten** | system/Handler.cmake, system/PathResolver.cmake, system/packages/Qt6.cmake, Orchestrator.cmake, Errors.cmake; Test 12 zusätzlich Debug.cmake und Json.cmake in den verschachtelten Configures |
| **Bedingung** | Test 11 läuft nur unter Windows mit MSVC-ABI (`MSVC` oder `CMAKE_CXX_SIMULATE_ID` = `MSVC`); sonst wird er übersprungen |

Tests 1–10 **melden** nur (Debug-Ausgabe, teils Warnung über `cmake_warn`). Hart ab über `cmake_fatal("ASSERT" …)` brechen Test 11 und Test 12.

---

## 2. Tests

### 2.1 Test 1 — Erkennung des External-Typs

Liest `SOLUTION_EXTERNALS_JSON` (globale Property) und zählt die Externals je Typ: `system` (Feld `system` wahr), sonst `git` (Feld `git` gesetzt), sonst `path` (Feld `path` gesetzt). Meldet die drei Zahlen; kein Abbruch.

### 2.2 Test 2 — Felder eines System Externals

Am ersten System External:

| Feld | Pflicht | Verhalten |
|------|---------|-----------|
| `package` | ja | gemeldet; fehlt es, Warnung `W901` |
| `version` | nein | gemeldet |
| `components` | nein | Anzahl und erste Komponente gemeldet |
| `hints` | nein | Anzahl Pfade gemeldet |
| `backup` | nein | gemeldet |
| `required` | nein (Vorgabe `true`) | gemeldet |

### 2.3 Test 3 — Typ-Priorität

Gibt die Reihenfolge `system → git → path → E012` aus und prüft, dass kein External mehr als eines der Felder `system`, `git`, `path` trägt. Sonst Warnung `W902` mit der Anzahl der betroffenen Externals.

### 2.4 Test 4 — Targets der System Externals

Meldet, welche bekannten Targets existieren: `Qt6::Core`, `Qt6::Widgets`, `Qt6::Gui`, `Qt6::OpenGL`, `Boost::boost` oder `Boost::headers`, `opencv_core` oder `OpenCV::core`. Kein Abbruch, wenn keines da ist.

### 2.5 Test 5 — Module Handler und PathResolver

Meldet, ob `_handle_system_external()` und `_resolve_system_paths()` definiert sind, und gibt aus, wohin der Orchestrator verteilt (`system` → System/Handler.cmake, `git` → Core/Fetch.cmake, `path` → Local/Attach.cmake). Kein Abbruch.

### 2.6 Test 6 — Bereich der Fehlercodes

Gibt nur die Codes aus: Fehler `E502`–`E505`, Warnung `W501` (`phase9.cmake:282–294`; siehe ErrorCodes.md). Keine Prüfung — die Fehlercodes prüft Test 12.

### 2.7 Test 7 — Qt6 als System External

Meldet, ob `qt6` als System External definiert ist (mit `package` und Anzahl `components`), ob es noch den Umweg über `path` nimmt, und ob `find_package()` Qt6 gefunden hat (`Qt6_FOUND` oder `Qt6Core_FOUND`, dazu `Qt6_VERSION`, `Qt6_DIR`). Kein Abbruch.

### 2.8 Test 8 — Targets, die Qt6 nutzen

Zählt Executables und Bibliotheken, deren `LINK_LIBRARIES` ein `Qt6::`-Target enthält, und meldet die Zahl. Kein Abbruch.

### 2.9 Test 9 — Package-Hooks

Prüft, ob `${CMAKECRAFT_DIR}/externals/system/packages/` existiert, und meldet die gefundenen `*.cmake`-Hooks. Fehlt der Ordner, nur Meldung („optional“).

### 2.10 Test 10 — Stand der Umstellung `path` → `system`

Prüft für `qt6`, `boost`, `opencv` und `cuda`, ob sie noch `path` ohne `system` nutzen, und meldet die Anzahl, die auf `system` umgestellt werden könnte. Kein Abbruch.

### 2.11 Test 11 — Einstiegspunkt von Qt-GUI-Programmen

Neu mit CMakeCraft v0.14.1 (2026-11-09). Hintergrund: `Qt6EntryPoint.lib` definiert `WinMain` **und** `wWinMain`; ohne ausdrücklichen Einstiegspunkt warnt lld-link bei jedem Linken (siehe [Qt6_cmake.md §2.4](../externals/system/packages/Qt6_cmake.md#24-_qt6_configure_entry_point)).

Läuft nur unter Windows mit MSVC-ABI (`MSVC` oder `CMAKE_CXX_SIMULATE_ID` = `MSVC`). Für jede Executable in `BUILDSYSTEM_TARGETS` des Quellverzeichnisses:

| Fall | Erwartet | Bei Abweichung |
|------|----------|----------------|
| Exe linkt Qt6 (`LINK_LIBRARIES` enthält `Qt6::…`) | `LINK_OPTIONS` enthält `LINKER:/ENTRY:WinMainCRTStartup` | `cmake_fatal("ASSERT" …)` |
| | die Option hängt in einer Generator Expression an `TARGET_PROPERTY:<target>,WIN32_EXECUTABLE` | `cmake_fatal("ASSERT" …)` |
| | … und an `TARGET_PROPERTY:<target>,QT_NO_ENTRYPOINT` | `cmake_fatal("ASSERT" …)` |
| Exe ohne Qt6 | `LINK_OPTIONS` enthält `LINKER:/ENTRY:WinMainCRTStartup` **nicht** | `cmake_fatal("ASSERT" …)` |

Meldet die Zahl der geprüften Qt-Executables. Ob der Linker danach schweigt (lld-link ohne „found both wWinMain and WinMain“), zeigt erst das Bauen.

### 2.12 Test 12 — Fehlercodes der System Externals und vollständige Meldungen

Neu mit CMakeCraft v0.14.1 (2026-11-09; `phase9.cmake:498–609`). Arbeitet unter
`${CMAKE_BINARY_DIR}/phase9/`, das vorher geleert wird.

**(a) Meldungsteile.** Ein Skript ruft `cmake_warn("W999" "part one: path;git\n" "  part two\n" "  part three")`
über `cmake -P` auf. Fehlt in der Ausgabe einer der drei Teile — auch der mit Semikolon —, bricht der Test ab.

**(b) Fehlercodes des System-Handlers.** Ein nachgebautes Paket `FakePkg` 1.2.0 mit
`FakePkgConfig.cmake` und `FakePkgConfigVersion.cmake`; es kennt nur die Komponente `Core` und setzt
für jede andere `FakePkg_NOT_FOUND_MESSAGE`. Je Fall läuft ein verschachteltes Configure mit dem
Generator des Selbsttests (`-G`, dazu `-A` und `CMAKE_MAKE_PROGRAM`, wenn gesetzt), das
`Errors.cmake`, `Debug.cmake`, `Json.cmake` und `system/Handler.cmake` lädt und
`_handle_system_external("fake" …)` aufruft:

| Fall | Solution-Eintrag | Erwartet |
|------|------------------|----------|
| `ok` | `FakePkg`, `version` `1.0`, `components` `[Core]` | Configure gelingt |
| `comp` | `FakePkg`, `components` `[Core, Missing]` | scheitert; Ausgabe enthält `[E504]`, `Missing`, `Failed to find required FakePkg component` |
| `vers` | `FakePkg`, `version` `2.0`, `components` `[Core]` | scheitert; Ausgabe enthält `[E505]`, `'2.0'`, `(version 1.2.0)` |
| `none` | `NoSuchPkg` | scheitert; Ausgabe enthält `[E503]`, `Possible solutions`, `Install NoSuchPkg to a standard location` |

Jede Abweichung bricht über `cmake_fatal("ASSERT" …)` ab. Die Prüfung der letzten Lösungszeile
belegt zugleich, dass mehrteilige Meldungen vollständig ankommen.

### 2.13 Zusammenfassung

Sind System Externals definiert, aber keine ihrer Targets gefunden, folgt nur ein Hinweis (normal, wenn die Bibliotheken nicht installiert sind). Der Status bleibt `PASSED`.

---

## 3. Erfolgs-Flag

```cmake
set(PHASE9_TEST_PASSED TRUE CACHE BOOL "Phase 9 Test passed" FORCE)
```

Nur ein Abbruch in Test 11 oder Test 12 verhindert das Flag.

---

## 4. Siehe auch

- [system/Handler_cmake.md](../externals/system/Handler_cmake.md)
- [system/PathResolver_cmake.md](../externals/system/PathResolver_cmake.md)
- [system/packages/Qt6_cmake.md](../externals/system/packages/Qt6_cmake.md)
- [Orchestrator_cmake.md](../externals/Orchestrator_cmake.md)
- [ErrorCodes.md](../../references/ErrorCodes.md)
- [System_Externals_Concept.md](../../../konzepte/abgeschlossen/System_Externals_Concept.md)

---

## 5. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.1.0** | **2026-11-09** | **Erstfassung, aus dem Code `phase9.cmake` (Modul 1.1.0); Test 11 (§2.11) neu mit CMakeCraft v0.14.1 — Einstiegspunkt von Qt-GUI-Programmen; Test 6 nennt E502–E505 und W501 (E501/W502 entfallen); Test 12 (§2.12) neu — Meldungsteile von `cmake_warn` und E503/E504/E505 des System-Handlers mit dem nachgebauten Paket FakePkg** |
