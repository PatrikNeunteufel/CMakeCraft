# Handler.cmake — System External Handler

> **Version:** 1.0.1  
> **Datum:** 2026-11-09  
> **Typ:** ModuleDoc  
> **Status:** Aktiv  
> **Basiert auf:** ModuleDoc v0.5  
> **Zielgruppe:** Build-System-Entwickler  
> **Sprache:** Deutsch  
> **English:** [Handler_cmake.md](../../../../../en/guide/module/externals/system/Handler_cmake.md)  
> **Modul:** [cmake/externals/system/Handler.cmake](../../../../../../cmake/externals/system/Handler.cmake)  
> **Modul-Version:** 1.0.0  
> **Phase:** 9 (System Externals)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [API-Referenz](#3-api-referenz)
4. [Verarbeitungsablauf](#4-verarbeitungsablauf)
5. [Package-Hooks](#5-package-hooks)
6. [Verwendungsbeispiele](#6-verwendungsbeispiele)
7. [Fehlerbehandlung](#7-fehlerbehandlung)
8. [Debug-Ausgaben](#8-debug-ausgaben)
9. [Siehe auch](#9-siehe-auch)
10. [Changelog](#10-changelog)

---

## 1. Übersicht

`Handler.cmake` ist der zentrale Handler für **System Externals** — große, extern installierte Pakete wie Qt6 oder Boost, die über `find_package()` gefunden werden.

### Kernfunktionen

- **Pfad-Auflösung** — Mehrstufige Suche nach Installationspfaden
- **find_package()** — CMake-native Paketsuche mit Komponenten-Support
- **Package-Hooks** — Paketspezifische Konfiguration (Qt6, Boost)
- **Registrierung** — Speichert Ergebnis für spätere Verwendung

### Architektur-Position

```
Orchestrator.cmake
       │
       ├── system: true
       ▼
┌─────────────────────┐
│  system/Handler     │  ← Dieser Handler
└─────────┬───────────┘
          │
    ┌─────┴─────┐
    ▼           ▼
PathResolver  Package-Hooks
              (Qt6, Boost)
```

---

## 2. Abhängigkeiten

### Benötigte Module

| Modul | Zweck |
|-------|-------|
| `Errors.cmake` | `cmake_fatal`, `cmake_warn` |
| `Debug.cmake` | `dbg` |
| `Json.cmake` | JSON-Parsing |
| `PathResolver.cmake` | Pfad-Auflösung |

### Auto-geladene Module

| Modul | Bedingung |
|-------|-----------|
| `packages/Qt6.cmake` | Wenn `package="Qt6"` |
| `packages/Boost.cmake` | Wenn `package="Boost"` |

---

## 3. API-Referenz

### 3.1 _handle_system_external()

Hauptfunktion zur Verarbeitung eines System Externals.

```cmake
_handle_system_external(EXT_NAME EXT_JSON)
```

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| `EXT_NAME` | String | Name des Externals (z.B. "qt6") |
| `EXT_JSON` | JSON | JSON-Definition aus Solution.json |

**Pflichtfelder in JSON:**

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `system` | bool | Muss `true` sein |
| `package` | string | Name für find_package() |

**Optionale Felder:**

| Feld | Typ | Default | Beschreibung |
|------|-----|---------|--------------|
| `version` | string | — | Mindestversion für `find_package()` (z. B. `"6.5"`, keine `>=`-Operatoren) |
| `components` | array | `[]` | Paket-Komponenten |
| `hints` | array | `[]` | Zusätzliche Suchpfade |
| `backup` | string | — | Fallback-Pfad (mit Warnung) |
| `required` | bool | `true` | Bei `false` kein Fehler, wenn das Paket fehlt |

`find_package()` läuft immer **ohne** `REQUIRED` (`Handler.cmake:270`, `:273`): mit `REQUIRED`
bräche CMake mit seiner eigenen Meldung ab, bevor CMakeCraft die Ursache benennen kann. CMakes
Diagnose erscheint ohne `REQUIRED` weiterhin, als Warnung. Ist das Paket nicht gefunden und das
External `required`, ruft der Handler `_system_external_not_found()` auf (`Handler.cmake:290`);
sonst meldet er nur `[<name>] <Paket> not found (optional)` (`:293`).

---

### 3.2 _apply_system_external_to_target()

Verknüpft ein System External mit einem CMake-Target.

```cmake
_apply_system_external_to_target(TARGET_NAME EXT_NAME EXT_OPTIONS)
```

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| `TARGET_NAME` | String | CMake-Target |
| `EXT_NAME` | String | Name des Externals |
| `EXT_OPTIONS` | JSON | Options (aktuell ungenutzt) |

**Verhalten:**
1. Holt registrierten Package-Namen und Komponenten
2. Linkt `Package::Component` Targets
3. Ruft `_Package_configure_target()` Hook auf (falls definiert)

Ist das External nicht registriert, folgt E503 `System external '<name>' not properly registered`
(`Handler.cmake:331`).

---

### 3.3 _system_external_not_found()

Benennt die Ursache, wenn `find_package()` ein `required` External nicht gefunden hat, und bricht
mit E503, E504 oder E505 ab (`Handler.cmake:52–133`).

```cmake
_system_external_not_found(EXT_NAME PACKAGE VERSION COMPONENTS)
```

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| `EXT_NAME` | String | Name des Externals |
| `PACKAGE` | String | Paketname aus `package` |
| `VERSION` | String | `version` aus Solution.json, oder leer |
| `COMPONENTS` | Liste | `components` aus Solution.json, oder leer |

Sie liest die Variablen, die `find_package()` im Aufrufer hinterlässt: `<Paket>_DIR`,
`<Paket>_CONSIDERED_CONFIGS`, `<Paket>_CONSIDERED_VERSIONS` und `<Paket>_NOT_FOUND_MESSAGE`
(`Handler.cmake:53–56`).

| Lage nach `find_package()` | Ergebnis | Zeile |
|-----------------------------|----------|-------|
| `<Paket>_DIR` gesetzt (Konfiguration angenommen), `components` gesetzt | E504 mit dem Grund des Pakets | `:91` |
| `<Paket>_DIR` gesetzt, keine `components` | E503 mit dem Grund des Pakets | `:101` |
| Konfigurationen betrachtet, keine angenommen, `version` gesetzt | E505 mit jeder betrachteten Datei und ihrer Version | `:109` |
| Konfigurationen betrachtet, keine angenommen, keine `version` | E503 mit denselben Zeilen `Considered:` | `:120` |
| nichts betrachtet | E503 (Paket nicht gefunden) | `:128` |

Alle E503-Fassungen enden mit denselben Lösungszeilen (`Handler.cmake:73–86`).

---

## 4. Verarbeitungsablauf

```
_handle_system_external(EXT_NAME, EXT_JSON)
    │
    ├── 1. JSON parsen
    │   ├── package (Pflicht) → E502 wenn fehlt
    │   ├── version, components, hints, backup
    │   └── required (default: true)
    │
    ├── 2. Package-Hook laden (falls vorhanden)
    │   └── packages/{package}.cmake
    │       └── _get_{package}_standard_paths() aufrufen
    │
    ├── 3. Pfad auflösen via PathResolver
    │   ├── ENV-Variablen
    │   ├── hints[]
    │   ├── Standard-Pfade
    │   └── backup (mit W501 Warnung)
    │
    ├── 4. CMAKE_PREFIX_PATH erweitern
    │
    ├── 5. find_package() aufrufen
    │   ├── Mit COMPONENTS wenn angegeben
    │   └── Nie mit REQUIRED (CMakes Diagnose erscheint als Warnung)
    │
    ├── 6. Ergebnis prüfen
    │   ├── Gefunden → Post-Find Hook aufrufen
    │   ├── Nicht gefunden, required → _system_external_not_found()
    │   │                              → E503 / E504 / E505
    │   └── Nicht gefunden, required=false → Statusmeldung, weiter
    │
    └── 7. Registrieren
        ├── EXTERNAL_{name}_TYPE = "SYSTEM"
        ├── EXTERNAL_{name}_PACKAGE
        ├── EXTERNAL_{name}_COMPONENTS
        └── EXTERNAL_{name}_REGISTERED = TRUE
```

---

## 5. Package-Hooks

Package-Hooks ermöglichen paketspezifische Konfiguration.

### Hook-Pfad

```
cmake/externals/system/packages/{Package}.cmake
```

### Verfügbare Hook-Funktionen

| Funktion | Aufrufzeitpunkt | Zweck |
|----------|-----------------|-------|
| `_get_{Package}_standard_paths()` | Vor find_package | Standard-Installationspfade |
| `_{Package}_post_find()` | Nach find_package | Post-Processing |
| `_{Package}_configure_target()` | Bei apply_external | Target-Konfiguration |

### Beispiel: Qt6-Hook

```cmake
# packages/Qt6.cmake

function(_get_Qt6_standard_paths OUT_VAR)
    set(_paths "C:/Qt/6.8.0/msvc2022_64" ...)
    set(${OUT_VAR} "${_paths}" PARENT_SCOPE)
endfunction()

function(_Qt6_configure_target TARGET_NAME)
    set_target_properties(${TARGET_NAME} PROPERTIES
        AUTOMOC ON
        AUTOUIC ON
        AUTORCC ON
    )
endfunction()
```

---

## 6. Verwendungsbeispiele

### Solution.json

```json
{
    "externals": {
        "qt6": {
            "system": true,
            "package": "Qt6",
            "components": ["Core", "Widgets", "Gui"],
            "hints": ["${QT_ROOT}"],
            "backup": "C:/Qt/6.8.0/msvc2022_64"
        },
        "boost": {
            "system": true,
            "package": "Boost",
            "components": ["filesystem", "system"],
            "required": false
        }
    }
}
```

### Automatischer Ablauf

```cmake
# In Orchestrator.cmake - automatisch wenn system: true
_handle_system_external("qt6" "${_ext_json}")

# In ExecutableCreate.cmake - bei externals: ["qt6"]
_apply_system_external_to_target("MyApp" "qt6" "{}")
```

---

## 7. Fehlerbehandlung

### Fehler-Codes

| Code | Fehler | Beschreibung |
|------|--------|--------------|
| E502 | Package-Feld fehlt | `package` ist Pflichtfeld (`Handler.cmake:180`) |
| E503 | find_package fehlgeschlagen | Paket nicht gefunden oder keine Konfiguration angenommen (bei required=true; `:101`, `:120`, `:128`); External beim Verlinken nicht registriert (`:331`) |
| E504 | Komponente fehlt | Paket gefunden, aber nicht mit allen Komponenten aus `components` (`:91`) |
| E505 | Version nicht erfüllt | `version` gesetzt, nur Konfigurationen mit unpassender Version betrachtet (`:109`) |

### Warnungen

| Code | Warnung | Beschreibung |
|------|---------|--------------|
| W501 | Backup verwendet | Fallback-Pfad statt ENV/hints |

### E503 Fehlermeldung

Paket nicht gefunden (`Handler.cmake:128`):

```
[E503] System external 'qt6': find_package(Qt6) failed.

  Possible solutions:
    1. Set Qt6_ROOT environment variable
    2. Add 'hints' in Solution.json
    3. Install Qt6 to a standard location

  Example Solution.json:
    "qt6": {
      "system": true,
      "package": "Qt6",
      "hints": ["C:/Path/To/Qt6"]
    }
```

### E504 Fehlermeldung

```
[E504] System external 'qt6': Qt6 was found (<Qt6_DIR>), but not with all requested components: Core, Widgets, Charts
  Reason given by the package: <Qt6_NOT_FOUND_MESSAGE>

  Possible solutions:
    1. Install the missing component(s) for this Qt6 installation
    2. Remove components the project does not use from 'components' in Solution.json
```

Die Meldung nennt alle angeforderten Komponenten; welche fehlt, sagt der Grund des Pakets.

### E505 Fehlermeldung

```
[E505] System external 'qt6': no Qt6 with a version compatible to the requested '6.9' was found.
  Considered:
    C:/Qt/6.8.0/msvc2022_64/lib/cmake/Qt6/Qt6Config.cmake (version 6.8.0)

  Possible solutions:
    1. Install a compatible Qt6 version and point Qt6_ROOT or 'hints' to it
    2. Adjust 'version' in Solution.json
```

---

## 8. Debug-Ausgaben

### Debug-ID: `EXTERNALS`

| Level | Ausgabe |
|-------|---------|
| `DBG_COMMON` | Processing system external |
| `DBG_RARE` | Package, Components, Hints |
| `DBG_RARE` | find_package() Aufruf |
| `DBG_ULTRA_RARE` | CMAKE_PREFIX_PATH |

### Aktivierung

```bash
cmake -DDEBUG_CATEGORIES="EXTERNALS" ..
```

---

## 9. Siehe auch

- [PathResolver_cmake.md](PathResolver_cmake.md) — Pfad-Auflösung
- [packages/Qt6_cmake.md](packages/Qt6_cmake.md) — Qt6-spezifische Hooks
- [packages/Boost_cmake.md](packages/Boost_cmake.md) — Boost-spezifische Hooks
- [Orchestrator_cmake.md](../Orchestrator_cmake.md) — Dispatcht hierher
- [Solution_Schema.md](../../../references/Solution_Schema.md) — JSON-Schema (§5.4)

---

## 10. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **Modul 1.1.0 (CMakeCraft v0.14.1): `find_package()` ohne `REQUIRED`; neue Funktion `_system_external_not_found()` (§3.3) benennt E503, E504 oder E505; Ablauf §4 und Fehlertabelle §7 angepasst, Meldungen von E504 und E505** |
| 1.0.0 | 2025-12-26 | Release 1 (aus newCMake übernommen, `2e00db7`) |
| **0.6.0** | **2025-12-18** | **Initial: Phase 9 System Externals, find_package Integration, Package-Hooks** |
