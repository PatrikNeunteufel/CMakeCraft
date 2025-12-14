# Concepts — CMake Architecture V2

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Status:** In Entwicklung

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Dokumente](#2-dokumente)
3. [Phasen-Status](#3-phasen-status)
4. [Siehe auch](#4-siehe-auch)

---

## 1. Übersicht

Concepts dokumentieren **Architektur-Entscheidungen und Design-Konzepte** für das CMake Architecture V2 Build-System.

### Zielgruppe

- Build-System-Entwickler
- Architekten
- Entwickler, die das System erweitern möchten

### Lebenszyklus

```
Concept (Entwurf)
    │
    ▼
Concept (In Review)
    │
    ▼
Implementation
    │
    ▼
Stabil (im master_concept integriert)
```

---

## 2. Dokumente

| Dokument | Beschreibung | Status |
|----------|--------------|--------|
| [master_concept.md](master_concept.md) | Zentrale Architektur-Referenz | Aktiv |
| [implementation_plan.md](implementation_plan.md) | Phasen-basierter Umsetzungsplan | Aktiv |
| [AppContainer.md](AppContainer.md) | Phase 8: Testbare App-Architektur | Entwurf |
| [System_Externals.md](System_Externals.md) | Phase 9: System-Bibliotheken | Entwurf |
| [future_enhancements.md](future_enhancements.md) | Sammlung geplanter Features | Aktiv |

---

## 3. Phasen-Status

| Phase | Beschreibung | Status |
|-------|--------------|--------|
| 1-5 | Foundation, Solution, Pipelines, Lokale Externals | ✅ Abgeschlossen |
| 6 | Fetched Externals + Hooks (Fetch v0.2) | ✅ Abgeschlossen |
| 7 | Test Pipeline (v0.1) | ✅ Abgeschlossen |
| 8 | App-Container | 🔄 In Planung |
| 9 | System Externals | 🔄 In Planung |
| 10+ | Siehe [future_enhancements.md](future_enhancements.md) | 📋 Gesammelt |

---

## 4. Siehe auch

- [../standards/guidelines.md](../standards/guidelines.md) — Projekt-Konventionen
- [../reports/](../reports/) — Entwicklungs-Journal, Reviews
- [../../blueprints/Concept.md](../../blueprints/Concept.md) — Blueprint für Concepts
