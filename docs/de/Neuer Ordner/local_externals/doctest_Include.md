# doctest Testing Framework – Include.cmake

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [externals/doctest/Include.cmake](../../../../externals/doctest/Include.cmake)  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [Include.md](../../../en/modules/externals/doctest/Include.md)

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

doctest ist ein **header-only** C++ Testing Framework. Die Integration erfordert nur das Hinzufügen des Include-Verzeichnisses – keine Libraries zum Linken.

### Features

- Header-only (schnelle Kompilierung)
- Minimale Konfiguration erforderlich
- Optionale Compile-Definitions für Anpassungen
- Subcases für strukturierte Tests

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| CMake 3.19+ | System | Für JSON-Verarbeitung |

**Keine** Library-Abhängigkeiten – doctest ist vollständig header-only.

---

## 3. Konzept

### 3.1 Header-Only Integration

doctest benötigt nur einen einzigen Header. Das Include.cmake fügt lediglich das Verzeichnis zum Include-Pfad hinzu.

### 3.2 Verzeichnisstruktur

```
externals/doctest/
├── Include.cmake     ← Dieses Modul
└── doctest.h         ← Single-Header Library
```

### 3.3 Compile-Definitions

Optional können Compile-Definitions gesetzt werden, um das Verhalten anzupassen:

```cmake
target_compile_definitions(${TARGET} PRIVATE
    DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
)
```

---

## 4. API-Referenz

### 4.1 Erwartete Variablen

| Variable | Pflicht | Beschreibung |
|----------|---------|--------------|
| `EXTERNAL_NAME` | ✓ | Name des Externals (`"doctest"`) |
| `EXTERNAL_ROOT` | ✓ | Pfad zum External-Verzeichnis |
| `EXTERNAL_OPTIONS` | — | JSON-String mit Options |
| `EXECUTABLE_NAME` | ✓ | Ziel-Target |

### 4.2 Verfügbare Options

| Option | Typ | Default | Beschreibung |
|--------|-----|---------|--------------|
| `DOCTEST_NO_SHORT_MACRO_NAMES` | bool | `false` | Lange Makronamen verwenden |
| `DOCTEST_CONFIG_SUPER_FAST_ASSERTS` | bool | `false` | Schnellere Asserts |
| `DOCTEST_CONFIG_DISABLE` | bool | `false` | doctest deaktivieren |

#### DOCTEST_NO_SHORT_MACRO_NAMES

Wenn aktiviert, müssen die langen Makronamen verwendet werden:

| Kurz (Standard) | Lang (mit Option) |
|-----------------|-------------------|
| `TEST_CASE` | `DOCTEST_TEST_CASE` |
| `CHECK` | `DOCTEST_CHECK` |
| `REQUIRE` | `DOCTEST_REQUIRE` |
| `SUBCASE` | `DOCTEST_SUBCASE` |

#### DOCTEST_CONFIG_SUPER_FAST_ASSERTS

Reduziert Debug-Informationen bei Fehlern für schnellere Kompilierung. **Nicht empfohlen** während der Entwicklung.

#### DOCTEST_CONFIG_DISABLE

Deaktiviert alle doctest-Makros komplett. Nützlich für Release-Builds.

### 4.3 Registrierte Targets

| Target | Typ | Beschreibung |
|--------|-----|--------------|
| `doctest` | INTERFACE | Header-only Target |

---

## 5. Verwendungsbeispiele

### 5.1 External definieren (Solution.json)

```json
{
    "externals": {
        "doctest": {
            "path": "externals/doctest"
        }
    }
}
```

### 5.2 In Test-Executable verwenden

```json
{
    "executables": [
        {
            "name": "MyTests",
            "externals": ["doctest"]
        }
    ]
}
```

### 5.3 Mit Options

```json
{
    "executables": [
        {
            "name": "MyTests",
            "externals": ["doctest"],
            "external_options": {
                "doctest": {
                    "DOCTEST_NO_SHORT_MACRO_NAMES": true
                }
            }
        }
    ]
}
```

---

## 6. Fehlerbehandlung

### Error Codes

| Code | Konstante | Beschreibung |
|------|-----------|--------------|
| E213 | `E_LOCAL_INCLUDE_NOT_FOUND` | Include.cmake nicht gefunden |

### Plattform-spezifische Warnungen

**Windows (MSVC):** Unterdrückte Warnungen: C4251, C4275

**GCC/Clang:** Unterdrückt: `-Wno-unknown-pragmas`

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| `DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN` für Test-Executables | `main()` manuell schreiben |
| Subcases für Setup/Teardown | Wiederholter Code in Tests |
| `DOCTEST_CONFIG_DISABLE` für Release | Tests in Release-Builds |

---

## 8. Siehe auch

- [doctest UserGuide](../../../guides/externals/doctest_UserGuide.md) — Benutzerhandbuch
- [Testing UserGuide](../../../guides/Testing_UserGuide.md) — Test-Framework Integration
- [doctest GitHub](https://github.com/doctest/doctest) — Offizielle Dokumentation

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.0 | 2025-12-08 | Initial: Blueprint-konform, Header-only Integration |
