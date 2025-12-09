# Orchestrator.cmake – Dokumentation

> **Version:** 0.1.0 (doc v1)  
> **Datum:** 2025-12-08  
> **Typ:** Modul-Doku  
> **Modul:** cmake/externals/Orchestrator.cmake  
> **Sprache:** Deutsch

---

## 1. Übersicht

Der Orchestrator ist der zentrale Dispatcher für externe Abhängigkeiten.

## 2. Typ-Erkennung

| JSON-Feld | Typ | Handler |
|-----------|-----|---------|
| `path` | LOCAL | Local/Attach.cmake |
| `git` | FETCHED | (Phase 6) |

## 3. API

### apply_external_to_target()

```cmake
apply_external_to_target(<TARGET> <EXT_NAME> <OPTIONS>)
```

Wendet ein External auf ein Target an.

## 4. Fehler

| Code | Beschreibung |
|------|--------------|
| E010 | External nicht definiert |
| E012 | Kein gültiges Source-Feld |
| E213 | Include.cmake nicht gefunden |

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-08** | **Initial** |
