# Error Codes – CMake Architecture V2

> **Version:** 0.1.0  
> **Datum:** 2025-12-03  
> **Typ:** Referenz-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, Solution_Schema v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/References/ErrorCodes_v0_1_0.md)

Dieses Dokument enthält alle Fehlercodes des CMake Build-Systems mit Erklärungen und Lösungsvorschlägen.

---

## 1. Übersicht

Das Build-System verwendet einheitliche Fehlercodes für konsistente und verständliche Fehlermeldungen. Jeder Code besteht aus einem Präfix (E für Error, W für Warning) und einer dreistelligen Nummer.

---

## 2. Fehlercode-Konvention

| Bereich | Codes | Beschreibung |
|---------|-------|--------------|
| JSON/Parsing | `E0xx` | Fehlende Pflichtfelder, ungültiges JSON |
| Target-Erstellung | `E1xx` | Target existiert bereits, Abhängigkeit fehlt, Source.cmake fehlt |
| Externals | `E2xx` | Fetch fehlgeschlagen, Include.cmake fehlt, Hooks fehlen |
| Deprecation | `W0xx` | Veraltete Features/Syntax |
| Konfiguration/Validation | `W1xx` | Suboptimale Einstellungen, Schema-Validierung |
| Tools/Setup | `W2xx` | Fehlende Tools, Build-Umgebung |
| Assertions | `ASSERT` | Interne Fehler (sollten nicht auftreten) |

---

## 3. Fatal Errors (Build bricht ab)

### 3.1 E0xx – JSON/Parsing Errors

#### E001 – Pflichtfeld fehlt

**Beschreibung:** Ein erforderliches Feld in der Solution.json fehlt.

**Beispiel:**
```
[E001] Executable 'MyApp' hat kein 'name' Feld
```

**Lösung:**
```json
{
    "name": "MyApp",
    "path": "src/apps/myapp"
}
```

> **Hinweis:** `path` hat einen Default und ist daher NICHT Pflicht. Nur `name` ist Pflicht.

---

#### E002 – Solution.json nicht gefunden

**Beschreibung:** Die Solution.json Datei existiert nicht im Projekt-Root.

**Beispiel:**
```
[E002] Solution.json nicht gefunden: /path/to/project/Solution.json
```

**Lösung:**
- Stelle sicher, dass `Solution.json` im Projekt-Root liegt
- Prüfe Schreibweise (Groß-/Kleinschreibung)

---

#### E010 – External nicht in externals-Block definiert

**Beschreibung:** Ein Executable/Library referenziert ein External, das nicht im zentralen `externals`-Block definiert ist.

**Beispiel:**
```
[E010] External 'imgui' nicht in externals-Block definiert
```

**Lösung:**
```json
{
    "externals": {
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.90.1"
        }
    }
}
```

---

#### E012 – External-Source-Feld Fehler

**Beschreibung:** Ein External hat entweder kein Source-Feld (path/git/vcpkg/...) oder mehrere gleichzeitig.

**Beispiel:**
```
[E012] External 'mylib': Kein Source-Feld (path/git/vcpkg/...) angegeben
[E012] External 'mylib': Mehrere Source-Felder angegeben (nur eines erlaubt)
```

**Lösung:**
```json
{
    "externals": {
        "mylib": {
            "path": "externals/mylib"
        }
    }
}
```

> **Wichtig:** Genau EIN Source-Feld pro External (path, git, vcpkg, etc.)

---

### 3.2 E1xx – Target-Erstellung Errors

#### E101 – Abhängigkeit existiert nicht

**Beschreibung:** Ein Target referenziert eine interne Abhängigkeit (Library), die nicht existiert.

**Beispiel:**
```
[E101] Dependency 'CoreLib' für 'MyApp' existiert nicht
```

**Lösung:**

1. Library in Solution.json definieren:
```json
{
    "libraries": [
        {
            "name": "CoreLib",
            "path": "src/core"
        }
    ]
}
```

2. Oder Schreibfehler korrigieren in der Referenz.

---

#### E102 – Target existiert bereits

**Beschreibung:** Ein Target mit diesem Namen wurde bereits erstellt.

**Beispiel:**
```
[E102] Target 'MyApp' existiert bereits
```

**Lösung:**
- Stelle sicher, dass jeder Target-Name eindeutig ist
- Prüfe auf Duplikate in Solution.json
- Target-Namen müssen über Libraries, Executables UND Tests hinweg eindeutig sein

---

#### E103 – Zirkuläre Abhängigkeit

**Beschreibung:** Eine zirkuläre Abhängigkeit zwischen Targets wurde erkannt (A → B → C → A).

**Beispiel:**
```
[E103] Zirkuläre Abhängigkeit erkannt: CoreLib → AudioLib → CoreLib
```

**Lösung:**
- Abhängigkeiten umstrukturieren
- Gemeinsamen Code in separate Library extrahieren
- Interface-Library für gemeinsame Definitionen verwenden

---

#### E104 – Source.cmake nicht gefunden

**Beschreibung:** Der Source-Mode ist `explicit` und das Source-Verzeichnis enthält keine `Source.cmake` Datei.

**Beispiel:**
```
[E104] Executable 'MyApp': Source.cmake erforderlich aber nicht gefunden: projects/exec/MyApp/src/Source.cmake
```

**Kontext:**
- Source-Mode `explicit` (Default) erfordert explizite Dateilisten
- Mode kann in `settings.sources.mode` geändert werden

**Lösung 1: Source.cmake erstellen**
```cmake
# projects/exec/MyApp/src/Source.cmake

set(_local_sources
    "${CMAKE_CURRENT_LIST_DIR}/main.cpp"
    "${CMAKE_CURRENT_LIST_DIR}/app.cpp"
)

set(_local_headers
    "${CMAKE_CURRENT_LIST_DIR}/app.h"
)

set(_local_templates "")
set(_local_inlines "")
set(_local_impl "")
set(_local_modules "")
set(_local_includes "")

# Aggregation
list(APPEND ${TARGET_NAME}_SOURCES   ${_local_sources})
list(APPEND ${TARGET_NAME}_HEADERS   ${_local_headers})
list(APPEND ${TARGET_NAME}_TEMPLATES ${_local_templates})
list(APPEND ${TARGET_NAME}_INLINES   ${_local_inlines})
list(APPEND ${TARGET_NAME}_IMPL      ${_local_impl})
list(APPEND ${TARGET_NAME}_MODULES   ${_local_modules})
list(APPEND ${TARGET_NAME}_INCLUDES  ${_local_includes})
```

**Lösung 2: Source-Mode ändern**
```json
{
    "settings": {
        "sources": {
            "mode": "auto"
        }
    }
}
```

---

### 3.3 E2xx – Externals Errors

#### E201 – Fetched External: Kein Target in Registry

**Beschreibung:** Ein gefetchtes External wurde zwar geladen, aber es wurde kein CMake-Target gefunden.

**Beispiel:**
```
[E201] Fetched external 'mylib': Kein Target in Registry
```

**Lösung:**
1. Prüfe ob das External ein CMake-Projekt ist mit `add_library()` oder `add_executable()`
2. Erstelle ggf. einen PostFetch-Hook in `cmake/externals/Hooks/PostFetch/mylib.cmake`
3. Oder verwende lokales External mit eigenem Include.cmake

---

#### E202 – External Fetch fehlgeschlagen

**Beschreibung:** Das Klonen/Fetchen eines Git-Repositories ist fehlgeschlagen.

**Beispiel:**
```
[E202] Fetch failed for 'imgui': Repository nicht erreichbar
```

**Lösung:**
- Prüfe Netzwerkverbindung
- Prüfe URL in Solution.json
- Prüfe Git-Credentials (bei privaten Repos)
- Prüfe ob Tag/Branch existiert

---

#### E213 – Lokales External: Include.cmake nicht gefunden

**Beschreibung:** Ein lokales External hat keine Include.cmake Datei am erwarteten Ort.

**Beispiel:**
```
[E213] Local external 'bass': Include.cmake nicht gefunden unter externals/bass/Include.cmake
```

**Lösung:**
1. Datei erstellen: `externals/bass/Include.cmake`
2. Oder Override angeben:
```json
{
    "externals": {
        "bass": {
            "path": "externals/bass",
            "include": "externals/bass/cmake/Setup.cmake"
        }
    }
}
```

---

#### E214 – Lokales External: Pfad existiert nicht

**Beschreibung:** Der angegebene Pfad für ein lokales External existiert nicht.

**Beispiel:**
```
[E214] Local external 'mylib': Pfad existiert nicht: externals/mylib
```

**Lösung:**
- Prüfe Pfad in Solution.json
- Stelle sicher, dass das Verzeichnis existiert
- Prüfe Schreibweise

---

#### E215 – Fetched External: Kein tag/branch/commit

**Beschreibung:** Ein External mit `git` hat weder `tag`, `branch` noch `commit` angegeben.

**Beispiel:**
```
[E215] Fetched external 'imgui': Kein tag/branch/commit angegeben
```

**Lösung:**
```json
{
    "externals": {
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.90.1"
        }
    }
}
```

> **Hinweis:** Eines von `tag`, `branch` oder `commit` muss angegeben sein.

---

#### E216 – Explizit angegebener Hook nicht gefunden

**Beschreibung:** Ein in der Solution.json explizit angegebener Hook (preFetch oder postFetch) existiert nicht.

**Beispiel:**
```
[E216] External 'mylib': postFetch Hook nicht gefunden: cmake/hooks/mylib_post.cmake
```

**Lösung:**
- Hook-Datei am angegebenen Pfad erstellen
- Oder Hook-Angabe aus Solution.json entfernen (Convention-basierte Hooks sind optional)

---

## 4. Warnings (Build läuft weiter)

### 4.1 W0xx – Deprecation Warnings

#### W001 – Veraltetes Schema

**Beschreibung:** Die Solution.json verwendet ein veraltetes Schema.

**Beispiel:**
```
[W001] Solution.json: schemaVersion < 0.1, einige Features möglicherweise nicht verfügbar
```

**Lösung:** Schema-Version in Solution.json aktualisieren.

---

#### W002 – Veraltete Syntax/Feld

**Beschreibung:** Ein Feld oder Syntax wird in Zukunft entfernt.

**Beispiel:**
```
[W002] Deprecated: 'type' sollte explizit gesetzt werden
```

**Lösung:** Folge der Empfehlung in der Warning-Message.

---

### 4.2 W1xx – Konfiguration/Validation Warnings

#### W101 – Suboptimale Konfiguration

**Beschreibung:** Die Konfiguration ist gültig, aber nicht optimal.

**Beispiele:**
```
[W101] Executable 'MyApp': Keine Source-Dateien gefunden
[W101] Executable 'MyApp': PCH aktiviert aber 'pch.h' nicht gefunden
[W101] Source.cmake für 'MyApp' definiert keine Dateien
[W101] Include-Verzeichnis existiert nicht: /path/to/include
```

---

#### W102 – Optionales Feature fehlt

**Beschreibung:** Ein optionales Feature ist nicht konfiguriert.

---

#### W103 – Include.cmake erstellt Executables

**Beschreibung:** Eine Include.cmake eines Externals erstellt Executable-Targets (IDE Clutter).

**Beispiel:**
```
[W103] Local external 'bass': Include.cmake erstellt Executables
```

**Lösung:** Entferne `add_executable()` Aufrufe aus Include.cmake.

---

#### W104 – Include.cmake bindet Beispiele ein

**Beschreibung:** Eine Include.cmake bindet Beispiel- oder Test-Verzeichnisse ein.

**Beispiel:**
```
[W104] Local external 'mylib': Include.cmake bindet Beispiel-Verzeichnisse ein
```

**Lösung:** Entferne `add_subdirectory(examples)` etc. aus Include.cmake.

---

#### W105 – Version nicht SemVer-konform

**Beschreibung:** Eine Version entspricht nicht dem Semantic Versioning Format.

**Beispiel:**
```
[W105] Executable 'MyApp': Version 'v1.0' ist nicht SemVer-konform
```

**Korrektes Format:** `MAJOR.MINOR.PATCH` (z.B. `1.0.0`)

---

#### W106 – Target hat keine Version

**Beschreibung:** Ein Target hat keine Version angegeben.

**Beispiel:**
```
[W106] Executable 'MyApp': Keine Version angegeben
```

---

#### W107 – Target überschreibt globale Standards

**Beschreibung:** Ein Target überschreibt die globalen C/C++ Standards.

**Beispiel:**
```
[W107] Library 'LegacyLib': Überschreibt globale Standards (cxx_standard: 14 statt 20)
```

---

#### W108 – Mehrere Test-Frameworks ohne explizite Angabe

**Beschreibung:** Ein Test referenziert mehrere Test-Framework Externals ohne das `framework` Feld.

**Beispiel:**
```
[W108] Test 'MixedTests': Mehrere Test-Frameworks in externals (doctest, gtest) - 'framework' Feld empfohlen
```

---

#### W109 – C++20 Module verwendet

**Beschreibung:** Das Target verwendet C++20 Module Interface Units (.ixx, .cppm, .mpp), die noch experimentell sind.

**Beispiel:**
```
[W109] Target 'MyApp' verwendet C++20 Modules (.ixx) - EXPERIMENTELL und compiler-spezifisch!
```

**Hintergrund:**
- **MSVC:** Beste Unterstützung, verwendet `.ixx`
- **Clang:** Verwendet `.cppm`, noch Einschränkungen
- **GCC:** Begrenzte Unterstützung

**Empfehlung:** Für produktiven Code noch Header/Source verwenden.

---

#### W110 – GLOB-Fallback aktiv

**Beschreibung:** Keine Source.cmake gefunden, GLOB wird als Fallback verwendet.

**Beispiel:**
```
[W110] GLOB-Fallback aktiv für 'projects/exec/MyApp/src' - explizite Source.cmake empfohlen
```

**Hintergrund:**
- CMake erkennt neue/gelöschte Dateien **nicht automatisch**
- Manuelles Reconfigure nötig nach Dateiänderungen

**Empfehlung:** Source.cmake mit expliziten Dateilisten verwenden.

---

### 4.3 W2xx – Tools/Setup Warnings

#### W201 – Clang-Tidy nicht gefunden

**Beschreibung:** `ENABLE_CLANG_TIDY=ON` ist gesetzt, aber clang-tidy wurde nicht gefunden.

**Beispiel:**
```
[W201] Clang-Tidy aktiviert, aber nicht gefunden
```

**Lösung:**
- Clang-Tidy installieren
- Oder Feature deaktivieren: `-DENABLE_CLANG_TIDY=OFF`

---

## 5. Assertions (Interne Fehler)

### ASSERT – Interne Fehler

**Beschreibung:** Ein interner Fehler im Build-System. Sollte nicht auftreten.

**Beispiele:**
```
[ASSERT] Context muss 'name' enthalten
[ASSERT] collect_files: DIRECTORY nicht angegeben
```

**Lösung:**
- Dies ist ein Bug im Build-System
- Bitte Issue erstellen mit vollständiger Fehlermeldung

---

## 6. Schnellreferenz

### Fatal Errors (E)

| Code | Kurzbeschreibung |
|------|------------------|
| E001 | Pflichtfeld fehlt |
| E002 | Solution.json nicht gefunden |
| E010 | External nicht im externals-Block |
| E012 | External: kein/mehrere Source-Felder |
| E101 | Abhängigkeit existiert nicht |
| E102 | Target existiert bereits |
| E103 | Zirkuläre Abhängigkeit |
| E104 | Source.cmake nicht gefunden (mode=explicit) |
| E201 | Fetched External: kein Target in Registry |
| E202 | External Fetch fehlgeschlagen |
| E213 | Lokales External: Include.cmake fehlt |
| E214 | Lokales External: Pfad existiert nicht |
| E215 | Fetched External: kein tag/branch/commit |
| E216 | Explizit angegebener Hook fehlt |

### Warnings (W)

| Code | Kurzbeschreibung |
|------|------------------|
| W001 | Veraltetes Schema |
| W002 | Veraltete Syntax/Feld |
| W101 | Suboptimale Konfiguration |
| W102 | Optionales Feature fehlt |
| W103 | Include.cmake erstellt Executables |
| W104 | Include.cmake bindet Beispiel-Verzeichnisse ein |
| W105 | Version nicht SemVer-konform |
| W106 | Target hat keine Version |
| W107 | Target überschreibt globale Standards |
| W108 | Mehrere Test-Frameworks ohne explizite Angabe |
| W109 | C++20 Module verwendet (experimentell) |
| W110 | GLOB-Fallback aktiv |
| W201 | Clang-Tidy nicht gefunden |

---

## 7. Verwendung in Code

### Error ausgeben

```cmake
# Fataler Fehler (bricht ab)
cmake_fatal("E001" "Executable '${name}' hat kein 'name' Feld")

# Warnung (läuft weiter)
cmake_warn("W001" "Solution.json: schemaVersion < 0.1")

# Assertion (interne Prüfung)
cmake_assert(DEFINED _name "Context muss 'name' enthalten")
```

### Field Validation

```cmake
# Prüft ob Feld im Context existiert
cmake_require_field(EXE "name" "Executable")
```

---

## 8. Debugging

### Error-Ausgabe verstehen

```
[E101] Dependency 'CoreLib' für 'MyApp' existiert nicht
 ^      ^                                ^
 |      |                                |
 Code   Beschreibung                     Context
```

### Verbose-Modus

```bash
cmake --preset <preset> --trace-expand
cmake --preset <preset> --debug-output
```

### Debug-System aktivieren

```bash
cmake --preset <preset> -DDEBUG_CONTEXT=ON
cmake --preset <preset> -DDEBUG_MESSAGES=ON
```

---

## 9. Siehe auch

- [master_concept](../Concepts/master_concept_v0_1_0.md) – Architektur-Referenz
- [guidelines](../Concepts/guidelines_v0_1_0.md) – Coding-Konventionen
- [Solution_Schema](Solution_Schema_v0_1_0.md) – Vollständige Schema-Dokumentation
- `cmake/core/Errors.cmake` – Implementierung

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-03** | **Initial (Clean Start): Alle Codes aus v1.4 übernommen, E104/W109/W110 hinzugefügt, Blueprint-konformes Format** |
