# Handler.cmake — Archive External Handler

> **Version:** 1.0.0  
> **Datum:** 2026-10-09  
> **Typ:** ModuleDoc  
> **Status:** Aktiv  
> **Basiert auf:** ModuleDoc v0.5  
> **Zielgruppe:** Build-System-Entwickler  
> **Sprache:** Deutsch  
> **English:** [Handler_cmake.md](../../../../../en/guide/module/externals/archive/Handler_cmake.md)  
> **Modul:** [cmake/externals/archive/Handler.cmake](../../../../../../cmake/externals/archive/Handler.cmake)  
> **Modul-Version:** 1.0.0

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [API-Referenz](#3-api-referenz)
4. [Verarbeitungsablauf](#4-verarbeitungsablauf)
5. [Verwendungsbeispiele](#5-verwendungsbeispiele)
6. [Fehlerbehandlung](#6-fehlerbehandlung)
7. [Debug-Ausgaben](#7-debug-ausgaben)
8. [Siehe auch](#8-siehe-auch)
9. [Changelog](#9-changelog)

---

## 1. Übersicht

`Handler.cmake` ist der Handler für **Archive Externals** — vorgebaute Pakete, die in einer festgelegten Version bezogen werden. Er übersetzt die Felder eines Externals aus der Solution.json in Aufrufe der eigenständigen Datei `CMakeCraftPackage.cmake`.

### Kernfunktionen

- **Plattform-Filter** — auf nicht genannten Plattformen fehlt das External
- **Beziehen** — `craft_package_fetch()` mit der Pin-Datei des Externals
- **Merken** — Paketwurzel als Global Property
- **Anwenden** — Include-Pfad, Define und Laufzeit-Kopien über `craft_package_deploy()`

Ein Archive External, das nicht bezogen werden kann, **fehlt**: W304 beim Configure, die Targets erhalten weder Include-Pfad noch Define noch Kopien.

### Architektur-Position

```
Orchestrator.cmake
       │
       ├── archive: true
       ▼
┌─────────────────────┐
│  archive/Handler    │  ← Dieser Handler
└─────────┬───────────┘
          │
          ▼
CMakeCraftPackage.cmake
(craft_package_fetch, craft_package_deploy)
```

---

## 2. Abhängigkeiten

### Benötigte Module

| Modul | Zweck |
|-------|-------|
| `Errors.cmake` | `cmake_fatal`, `cmake_warn` |
| `Debug.cmake` | `dbg` |
| `Json.cmake` | JSON-Parsing |

### Auto-geladene Module

| Modul | Bedingung |
|-------|-----------|
| `${CMAKECRAFT_ROOT}/CMakeCraftPackage.cmake` | Immer (beim Einbinden des Handlers) |

---

## 3. API-Referenz

### 3.1 _handle_archive_external()

Bezieht das Paket und merkt sich seine Wurzel.

```cmake
_handle_archive_external(EXT_NAME EXT_JSON)
```

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| `EXT_NAME` | String | Name des Externals; in Großbuchstaben das Präfix der Pin-Variablen und von `-D<NAME>_LOCAL_DIR` |
| `EXT_JSON` | JSON | JSON-Definition aus Solution.json |

**Pflichtfelder in JSON:**

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `archive` | bool | Muss `true` sein |
| `pin` | string | Pin-Datei, relativ zum Projekt-Root (Variablen: siehe [CMakeCraftPackage.md](../../CMakeCraftPackage.md)) |

**Optionale Felder:**

| Feld | Typ | Default | Beschreibung |
|------|-----|---------|--------------|
| `platforms` | array | `[]` (= alle) | `windows`, `linux`, `macos`, `unix`; auf jeder anderen Plattform fehlt das External |
| `include_dirs` | array | `[]` | Include-Verzeichnisse innerhalb des Pakets |
| `define` | string | "" | Compile-Definition `<define>=1` auf jedem Target |
| `runtime` | object | `{}` | `{ "files": [...], "dirs": [...] }` — wird neben jede ausführbare Datei kopiert, die das External nennt |

**Setzt:**

| Global Property | Beschreibung |
|-----------------|--------------|
| `ARCHIVE_EXTERNAL_<name>_ROOT` | Paketwurzel, oder `""` wenn das External fehlt |

---

### 3.2 _apply_archive_external_to_target()

Wendet ein Archive External auf ein CMake-Target an.

```cmake
_apply_archive_external_to_target(TARGET_NAME EXT_NAME EXT_JSON EXT_OPTIONS)
```

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| `TARGET_NAME` | String | CMake-Target |
| `EXT_NAME` | String | Name des Externals |
| `EXT_JSON` | JSON | JSON-Definition des Externals |
| `EXT_OPTIONS` | JSON | Optionen dieses Targets für das External (`external_options`) |

**Optionen je Target:**

| Option | Typ | Default | Beschreibung |
|--------|-----|---------|--------------|
| `runtime` | bool | `true` | `false` = keine Kopien, nur Include-Pfad und Define |

**Verhalten:**
1. Liest die Paketwurzel aus `ARCHIVE_EXTERNAL_<name>_ROOT`
2. Liest `include_dirs`, `define`, `runtime.files`, `runtime.dirs` aus der External-Definition
3. Ruft `craft_package_deploy()` auf — bei leerer Wurzel geschieht dort nichts

---

## 4. Verarbeitungsablauf

```
_handle_archive_external(EXT_NAME, EXT_JSON)
    │
    ├── 1. ARCHIVE_EXTERNAL_{name}_ROOT = ""
    │
    ├── 2. pin lesen (Pflicht) → E220 wenn fehlt
    │
    ├── 3. Plattform-Filter (nur wenn platforms angegeben)
    │   ├── windows → WIN32
    │   ├── linux   → CMAKE_SYSTEM_NAME ist "Linux"
    │   ├── macos   → APPLE
    │   ├── unix    → UNIX
    │   └── kein Treffer → Ende (Wurzel bleibt leer, keine Warnung)
    │
    ├── 4. craft_package_fetch()
    │   ├── NAME     = EXT_NAME
    │   └── PIN_FILE = ${CMAKE_SOURCE_DIR}/{pin}
    │       (Override → Cache → Download → Ausweichpfade)
    │
    ├── 5. ARCHIVE_EXTERNAL_{name}_ROOT = Ergebnis
    │
    └── 6. Ergebnis leer → W304
```

Da kein `CACHE_DIR` übergeben wird, liegt das entpackte Paket am Default-Ort von `craft_package_fetch()`: `<Verzeichnis der Pin-Datei>/.externals/<name>/<version>/`.

---

## 5. Verwendungsbeispiele

### Solution.json

```json
{
    "externals": {
        "toolkit": {
            "archive": true,
            "pin": "toolkit.pin",
            "platforms": ["windows"],
            "include_dirs": ["include"],
            "define": "TOOLKIT_VORHANDEN",
            "runtime": {
                "files": ["bin/toolkit.dll"],
                "dirs": ["tools"]
            }
        }
    }
}
```

### Target ohne Laufzeit-Kopien

```json
{
    "name": "MyTool",
    "externals": ["toolkit"],
    "external_options": {
        "toolkit": { "runtime": false }
    }
}
```

### Automatischer Ablauf

```cmake
# In Orchestrator.cmake - automatisch wenn archive: true
_handle_archive_external("toolkit" "${_ext_json}")

# In apply_external_to_target() - bei externals: ["toolkit"]
_apply_archive_external_to_target("MyApp" "toolkit" "${_ext_json}" "${EXT_OPTIONS}")
```

---

## 6. Fehlerbehandlung

### Fehler-Codes

| Code | Fehler | Beschreibung |
|------|--------|--------------|
| E220 | Pin-Feld fehlt | `pin` ist Pflichtfeld |

### Warnungen

| Code | Warnung | Beschreibung |
|------|---------|--------------|
| W304 | External nicht verfügbar | Paket konnte nicht bezogen werden — Targets bauen ohne es |

Vor W304 gibt `craft_package_fetch()` eine eigene Warnung mit den Gründen aus (siehe [CMakeCraftPackage.md](../../CMakeCraftPackage.md)).

### E220 Fehlermeldung

```
[E220] Archive external 'toolkit': 'pin' field is required.
  Example: { "archive": true, "pin": "toolkit.pin" }
```

---

## 7. Debug-Ausgaben

### Debug-ID: `EXTERNALS`

| Level | Ausgabe |
|-------|---------|
| `DBG_COMMON` | Archive external '{name}': not for this platform |
| `DBG_COMMON` | Archive external '{name}': {root} |

---

## 8. Siehe auch

- [CMakeCraftPackage.md](../../CMakeCraftPackage.md) — Pin-Datei, Bezug, Auslieferung
- [Orchestrator_cmake.md](../Orchestrator_cmake.md) — Dispatcht hierher
- [Validation.md](../../core/Validation.md) — `archive` als Source-Feld
- [Packages.md](../../project/Packages.md) — erzeugt Pakete, die hier bezogen werden können
- [Phase10_doc.md](../../buildSystemTest/Phase10_doc.md) — Phasentest

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.0.0** | **2026-10-09** | **Initial (CMakeCraft v0.10.0): External-Art `archive`, E220, W304** |
