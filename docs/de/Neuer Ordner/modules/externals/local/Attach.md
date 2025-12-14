# Attach.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/externals/Local/Attach.cmake](../../../cmake/externals/Local/Attach.cmake)  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [Attach.md](../../en/modules/externals/local/Attach.md)

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

Das `Attach.cmake` Modul bindet lokale Externals über Include.cmake-Dateien ein.

### Features

- Include.cmake Laden
- Variable Injection für Options
- Target-Registrierung

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| Targets.cmake | Modul | Target-Registrierung |
| Validation.cmake | Modul | Include.cmake Validierung |

---

## 3. Konzept

### 3.1 Lokale External-Struktur

```
externals/bass/
├── Include.cmake     ← Pflicht!
├── lib/
│   └── bass.lib
└── include/
    └── bass.h
```

### 3.2 Attach-Pipeline

```
1. Include.cmake lokalisieren
2. Options-Variablen injizieren
3. Include.cmake ausführen
4. Targets registrieren
```

---

## 4. API-Referenz

### 4.1 attach_local_external()

Bindet ein lokales External ein.

```cmake
attach_local_external(<EXT_NAME> <EXT_PATH> [OPTIONS_JSON])
```

**Parameter:**

| Parameter | Pflicht | Beschreibung |
|-----------|---------|--------------|
| `EXT_NAME` | ✓ | External-Name |
| `EXT_PATH` | ✓ | Pfad zum External-Verzeichnis |
| `OPTIONS_JSON` | — | Options aus external_options |

---

## 5. Verwendungsbeispiele

### 5.1 Einfaches Attachment

```cmake
attach_local_external("bass" "externals/bass")
```

### 5.2 Mit Options

```cmake
attach_local_external("bass" "externals/bass" "${_options_json}")
```

---

## 6. Fehlerbehandlung

| Code | Beschreibung |
|------|--------------|
| `E213` | Include.cmake nicht gefunden |
| `E214` | Include.cmake fehlerhaft |

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| Include.cmake für jedes External | CMakeLists.txt in Externals |
| Options über external_options | Hardcoded Konfiguration |

---

## 8. Siehe auch

- [Targets.cmake](../registry/Targets.md) — Target-Registry
- [Include.cmake Blueprint](../../blueprints/ModuleDoc.md) — Include.cmake Standard
- [BASS Include.cmake](bass/Include.md) — Beispiel

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.0 | 2025-12-08 | Initial |
