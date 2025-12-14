# Targets.cmake — Dokumentation

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** ModuleDoc  
> **Status:** Stabil  
> **Zielgruppe:** Build-System-Entwickler  
> **Modul:** [cmake/externals/Registry/Targets.cmake](../../../cmake/externals/Registry/Targets.cmake)  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** ModuleDoc v0.5  
> **Sprache:** Deutsch  
> **English:** [Targets.md](../../en/modules/externals/registry/Targets.md)

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

Das `Targets.cmake` Modul verwaltet eine Registry aller External-Targets für konsistentes Linking.

### Features

- Target-Registrierung
- Target-Lookup nach External-Name
- Multi-Target Support pro External

---

## 2. Abhängigkeiten

| Abhängigkeit | Typ | Beschreibung |
|--------------|-----|--------------|
| CMake 3.19+ | System | GLOBAL PROPERTY |

---

## 3. Konzept

### 3.1 Registry-Struktur

```
EXTERNAL_TARGETS_bass = "bass"
EXTERNAL_TARGETS_imgui = "imgui;imgui_backend_glfw;imgui_backend_opengl3"
EXTERNAL_TARGETS_glfw = "glfw"
```

### 3.2 Lookup-Flow

```
Executable braucht "imgui"
    │
    └── get_external_targets("imgui")
        │
        └── Returns: "imgui;imgui_backend_glfw;imgui_backend_opengl3"
```

---

## 4. API-Referenz

### 4.1 register_external_targets()

Registriert Targets für ein External.

```cmake
register_external_targets(<EXT_NAME> <TARGETS...>)
```

---

### 4.2 get_external_targets()

Holt registrierte Targets.

```cmake
get_external_targets(<EXT_NAME> <OUT_VAR>)
```

---

### 4.3 has_external_targets()

Prüft ob External registriert ist.

```cmake
has_external_targets(<EXT_NAME> <OUT_VAR>)
```

---

## 5. Verwendungsbeispiele

### 5.1 Targets registrieren

```cmake
register_external_targets(imgui imgui imgui_backend_glfw imgui_backend_opengl3)
```

### 5.2 Targets abrufen

```cmake
get_external_targets(imgui _targets)
# _targets = "imgui;imgui_backend_glfw;imgui_backend_opengl3"
```

---

## 6. Fehlerbehandlung

| Code | Beschreibung |
|------|--------------|
| `E200` | External nicht in Registry |

---

## 7. Best Practices

| Do | Don't |
|----|-------|
| Alle Targets registrieren | Nur Haupt-Target |
| Registry für Lookup | Direkte Target-Namen |

---

## 8. Siehe auch

- [Orchestrator.cmake](../Orchestrator.md) — Verwendet Registry
- [Attach.cmake](../local/Attach.md) — Registriert lokale Targets
- [Fetch.cmake](../core/Fetch.md) — Registriert gefetchte Targets

---

## 9. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf ModuleDoc v0.5 Blueprint** |
| 0.1.0 | 2025-12-07 | Initial |
