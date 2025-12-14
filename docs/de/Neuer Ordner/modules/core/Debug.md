# Debug.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/core/Debug.cmake](../../../cmake/core/Debug.cmake)  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [Debug.md](../../en/modules/core/Debug.md)

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

Das `Debug.cmake` Modul implementiert ein **kontextbasiertes Debug-System** mit Zwei-Achsen-Filterung. Es ermöglicht granulare Kontrolle über Debug-Ausgaben ohne den Code mit `if(DEBUG)` zu übersäen.

### Features

- Zwei-Achsen-Filterung (SHOW × FREQ)
- Kontext-basierte Isolation
- ONCE-Flag für Schleifen-Warnungen
- CMake-Preset-Integration

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| CMake 3.19+ | System | Basis |

---

## 3. Konzept

### 3.1 Zwei-Achsen-Filterung

| Achse | Frage | Werte |
|-------|-------|-------|
| **SHOW** | Wie viel will ich sehen? | 1-5 (wenig → alles) |
| **FREQ** | Wie wichtig ist diese Message? | 1-5 (wichtig → Detail) |

**Filterregel:** Message erscheint wenn `FREQ <= SHOW`

### 3.2 Level-Konstanten

**SHOW-Level:**

| Konstante | Wert | Bedeutung |
|-----------|------|-----------|
| `DBG_SHOW_LITTLE` | 1 | Nur das Wichtigste |
| `DBG_SHOW_SOME` | 2 | Standard (Default) |
| `DBG_SHOW_MUCH` | 3 | Mehr Details |
| `DBG_SHOW_LOTS` | 4 | Viele Details |
| `DBG_SHOW_ALL` | 5 | Alles |

**FREQ-Level:**

| Konstante | Wert | Beispiel |
|-----------|------|----------|
| `DBG_OFTEN` | 1 | Modul-Start |
| `DBG_COMMON` | 2 | Gefundene Dateien |
| `DBG_NORMAL` | 3 | Zwischenschritte |
| `DBG_RARE` | 4 | Pfade, Variablen |
| `DBG_ULTRA_RARE` | 5 | Loop-Iterationen |

---

## 4. API-Referenz

### 4.1 dbg_init()

Initialisiert einen Debug-Kontext.

```cmake
dbg_init(
    ID <context_id>
    [LEVEL <show_level>]
    [SWITCH <ON|OFF>]
    [TAG <prefix>]
)
```

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `ID` | ✓ | Eindeutiger Kontext-Identifier |
| `LEVEL` | — | DBG_SHOW_* oder 1-5 (Default: DEBUG_DEFAULT_LEVEL) |
| `SWITCH` | — | ON/OFF (Default: ON) |
| `TAG` | — | Prefix in eckigen Klammern |

**Beispiel:**

```cmake
dbg_init(ID SOLUTION LEVEL ${DBG_SHOW_MUCH} TAG "Solution")
```

---

### 4.2 dbg()

Gibt eine Debug-Message aus (wenn Filter passt).

```cmake
dbg(<freq_level> "<message>"
    [ID <context_id>]
    [ONCE]
)
```

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `freq_level` | ✓ | DBG_* Wichtigkeit |
| `message` | ✓ | Auszugebende Nachricht |
| `ID` | — | Kontext-Referenz |
| `ONCE` | — | Pro Kontext nur einmal |

**Beispiel:**

```cmake
dbg(${DBG_OFTEN} "=== Module Start ===" ID MY_MODULE)
dbg(${DBG_COMMON} "Processing: ${_file}" ID MY_MODULE)
```

---

### 4.3 dbgspace()

Gibt eine Leerzeile aus.

```cmake
dbgspace([ID <context_id>])
```

---

### 4.4 enddbgblock()

Gibt eine Trennlinie aus.

```cmake
enddbgblock([ID <context_id>])
```

**Ausgabe:**
```
-- -------------------------------------------
```

---

### 4.5 setup_debug_from_args()

Helper für Funktionen mit optionalen Debug-Flags.

```cmake
setup_debug_from_args(<out_switch> <out_tag> <default_tag> [SHOW_DEBUG] [DEBUG_TAG <tag>])
```

**Beispiel:**

```cmake
function(my_function)
    cmake_parse_arguments(ARG "SHOW_DEBUG" "DEBUG_TAG" "" ${ARGN})
    setup_debug_from_args(_sw _tag "MY_FUNC" ${ARGN})
    
    dbg_init(ID MY_FUNC_DBG SWITCH ${_sw} TAG "${_tag}")
endfunction()
```

---

## 5. Verwendungsbeispiele

### 5.1 Modul mit Debug-Support

```cmake
set(_SHOW_MY_MODULE_DEBUG OFF)

dbg_init(
    ID MY_MODULE 
    LEVEL ${DBG_SHOW_MUCH} 
    SWITCH ${_SHOW_MY_MODULE_DEBUG} 
    TAG "MyModule"
)

dbg(${DBG_OFTEN} "=== MyModule Loading ===" ID MY_MODULE)

foreach(_item IN LISTS _items)
    dbg(${DBG_COMMON} "Processing: ${_item}" ID MY_MODULE)
endforeach()

enddbgblock(ID MY_MODULE)
```

### 5.2 Debug via Preset

```json
{
    "configurePresets": [
        {
            "name": "debug-verbose",
            "cacheVariables": {
                "DEBUG_MESSAGES": "ON",
                "DEBUG_DEFAULT_LEVEL": "5"
            }
        }
    ]
}
```

---

## 6. Fehlerbehandlung

Dieses Modul wirft keine Fehler. Bei ungültigen Parametern erfolgt keine Ausgabe.

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| Konsistente FREQ-Level verwenden | Alles mit DBG_OFTEN markieren |
| Aussagekräftige Tags | Kryptische Tags (D1, D2) |
| ONCE für Schleifen-Warnungen | Spam in Schleifen |
| Lokaler Switch zum schnellen Ein/Aus | Nur über CMake-Variable |

---

## 8. Siehe auch

- [Errors.cmake](Errors.md) — Für echte Fehler
- [Context.cmake](Context.md) — Context-Pattern

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.1 | 2025-12-05 | English translation |
| 0.1.0 | 2025-12-04 | Initial: Zwei-Achsen-Filterung, dbg_init/dbg API |
