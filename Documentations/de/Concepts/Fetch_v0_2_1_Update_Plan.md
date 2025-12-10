# Fetch v0.2.0 – Zwischen-Update Plan

> **Update-Typ:** Feature-Update (Zwischen-Release)  
> **Ziel-Version:** 0.2.0  
> **Datum:** 2025-12-10  
> **Status:** ✅ Abgeschlossen  
> **Priorität:** Hoch (Usability)

---

## 1. Übersicht

Dieses Update verbessert das Caching-Verhalten für Git-basierte Externals, unabhängig von Phase 7.

| Aspekt | Details |
|--------|---------|
| **Scope** | Fetch.cmake, Handler.cmake, Errors.cmake |
| **Breaking Changes** | Nein |
| **Neue Abhängigkeiten** | Nein |
| **Rückwärtskompatibel** | Ja |

---

## 2. Änderungen

### 2.1 Betroffene Dateien

| Datei | Version | Änderung |
|-------|---------|----------|
| `cmake/externals/Core/Fetch.cmake` | 0.1.0 → **0.2.0** | Caching-Logik, .externals/ |
| `cmake/externals/Fetched/Handler.cmake` | 0.1.0 → **0.1.1** | SOURCE_DIR Anpassung |
| `cmake/core/Errors.cmake` | 0.1.1 → **0.1.2** | E218, W302 |
| `.gitignore` | - | `/.externals/` hinzufügen |

### 2.2 Neue Dateien

| Datei | Beschreibung |
|-------|--------------|
| `cmake/externals/Core/Lockfile.cmake` | Optional: Versions-Tracking |

### 2.3 Dokumentations-Updates

| Dokument | Version | Änderung |
|----------|---------|----------|
| `Fetch_cmake_doc` | v1 → **v2** | Neue Features dokumentieren |
| `Handler_cmake_doc` | v1 → **v1.1** | SOURCE_DIR Änderung |
| `ErrorCodes` | 0.1.1 → **0.1.2** | E218, W302 |
| `Externals` (Referenz) | 0.2.0 → **0.2.1** | .externals/ Convention |

---

## 3. Implementierungs-Schritte

### Schritt 1: Errors.cmake aktualisieren

```cmake
# Neue Codes in Errors.cmake v0.1.2

# E218 - Offline ohne Cache
# E2xx = Externals Errors

# W302 - Version Mismatch im Offline-Modus  
# W3xx = Externals Warnings (neu!)
```

### Schritt 2: Fetch.cmake v0.2.0

Kernänderungen:
1. `EXTERNALS_FETCH_ROOT` → `.externals/`
2. Cache-Prüfung vor Fetch
3. `EXTERNALS_OFFLINE` Option
4. `EXTERNALS_FORCE_FETCH` Option
5. Version-Matching für Tags/Commits

### Schritt 3: Handler.cmake v0.1.1

Anpassung:
- `_source_dir` kommt jetzt aus `.externals/`
- Keine funktionalen Änderungen nötig (nutzt bereits GLOBAL PROPERTY)

### Schritt 4: .gitignore

```gitignore
# Gefetchte Externals
/.externals/
```

### Schritt 5: Testen

| Test-Case | Erwartung |
|-----------|-----------|
| Erstes Configure | Download nach `.externals/` |
| Zweites Configure | "Using cached version" |
| Preset-Wechsel | Kein neuer Download |
| `EXTERNALS_OFFLINE=ON` (mit Cache) | Funktioniert |
| `EXTERNALS_OFFLINE=ON` (ohne Cache) | E218 Fehler |
| `EXTERNALS_FORCE_FETCH=ON` | Neuer Download |
| Tag-Änderung in Solution.json | Neuer Download |

### Schritt 6: Dokumentation

- Fetch.cmake Doku aktualisieren
- ErrorCodes aktualisieren
- Externals Referenz aktualisieren

---

## 4. Zeitschätzung

| Schritt | Aufwand |
|---------|---------|
| Errors.cmake | 10 min |
| Fetch.cmake | 45 min |
| Handler.cmake | 10 min |
| .gitignore | 2 min |
| Testen | 30 min |
| Dokumentation | 30 min |
| **Gesamt** | **~2 Stunden** |

---

## 5. Risiken

| Risiko | Mitigation |
|--------|------------|
| FetchContent verhält sich anders | Testen mit verschiedenen Externals |
| Git-Befehle schlagen fehl | Fallback auf "needs fetch" |
| Lockfile-Korruption | Lockfile ist optional, ignorieren bei Fehler |

---

## 6. Rollback-Plan

Falls Probleme auftreten:
1. `.externals/` löschen
2. Alte Fetch.cmake v0.1.0 wiederherstellen
3. Build-Verzeichnis löschen
4. Neu konfigurieren

---

## 7. Nach dem Update

### Benutzer-Aktion erforderlich

1. `.gitignore` um `/.externals/` erweitern
2. Optional: Alte Build-Verzeichnisse löschen (enthalten alte Externals-Kopien)

### Empfohlene Kommunikation

```
## Fetch.cmake v0.2.0 – Caching für Git Externals

Neu:
- Gefetchte Externals werden in `.externals/` gespeichert
- Alle Presets teilen sich den Cache → kein redundanter Download
- Offline-Modus: `-DEXTERNALS_OFFLINE=ON`
- Force-Update: `-DEXTERNALS_FORCE_FETCH=ON`

Aktion:
- `/.externals/` zu .gitignore hinzufügen
```

---

## 8. Abhängigkeiten zu Phase 7

Keine. Dieses Update ist vollständig unabhängig und kann sofort implementiert werden.

Phase 7 kann später auf dieser Basis aufbauen (z.B. vcpkg Integration, erweiterte Lockfile-Features).

---

## Changelog

| Version | Datum | Status |
|---------|-------|--------|
| **0.2.0** | **2025-12-10** | **✅ Abgeschlossen** |

## Wichtige Erkenntnis

`FetchContent_MakeAvailable()` muss **immer** aufgerufen werden, auch für gecachte Externals:
- **Download** wird übersprungen wenn Source existiert
- **Configure** (`add_subdirectory()`) ist immer nötig für Targets

## Vereinfachung

`externalsPolicy` wurde entfernt - die Convention ist implizit:
- `path` → `externals/` (lokal, committed)
- `git` → `.externals/` (gefetcht, gitignored)

CMake-Optionen reichen für Steuerung:
- `EXTERNALS_OFFLINE=ON`
- `EXTERNALS_FORCE_FETCH=ON`
