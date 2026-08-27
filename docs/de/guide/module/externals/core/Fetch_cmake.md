# Core/Fetch.cmake — FetchContent Wrapper mit Caching

> **Version:** 1.1.0  
> **Datum:** 2026-08-08  
> **Typ:** ModuleDoc  
> **Status:** Aktiv  
> **Basiert auf:** ModuleDoc v0.5, Doc v0.5  
> **Zielgruppe:** Build-System-Entwickler  
> **Sprache:** Deutsch  
> **English:** [Fetch_cmake.md](Fetch_cmake.md)  
> **Modul:** [cmake/externals/Core/Fetch.cmake](../../../cmake/externals/Core/Fetch.cmake)  
> **Modul-Version:** 1.1.0

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [Konfiguration](#3-konfiguration)
4. [API-Referenz](#4-api-referenz)
5. [Caching-Logik](#5-caching-logik)
6. [Git-Referenzen](#6-git-referenzen)
7. [Verwendungsbeispiele](#7-verwendungsbeispiele)
8. [Fehlerbehandlung](#8-fehlerbehandlung)
9. [Siehe auch](#9-siehe-auch)
10. [Changelog](#10-changelog)

---

## 1. Übersicht

`Core/Fetch.cmake` ist ein Wrapper um CMakes `FetchContent`, der intelligentes Caching in einem zentralen `.externals/` Verzeichnis implementiert.

### Kernfunktionen

- **Preset-übergreifendes Caching** — Alle Build-Presets teilen dieselben Downloads
- **Offline-Modus** — Arbeiten ohne Netzwerkzugriff
- **Force-Fetch** — Erzwingen eines erneuten Downloads
- **Version-Checking** — Automatische Erkennung veralteter Caches

### Architektur

```
.externals/                     ← Zentrales Cache-Verzeichnis
├── spdlog/
├── glfw/
└── imgui/

build-windows-debug/            ← Build-Verzeichnis (Preset)
build-linux-release/            ← Anderes Preset, GLEICHER Cache
```

---

## 2. Abhängigkeiten

| Modul | Zweck |
|-------|-------|
| `FetchContent` | CMake Built-in für Downloads |
| `Errors.cmake` | Fehlerbehandlung |
| `Debug.cmake` | Debug-Ausgaben |
| `Json.cmake` | JSON-Parsing |

---

## 3. Konfiguration

### Cache-Variablen

| Variable | Default | Beschreibung |
|----------|---------|--------------|
| `EXTERNALS_FETCH_ROOT` | `${CMAKE_SOURCE_DIR}/.externals` | Cache-Verzeichnis |

### Optionen

| Option | Default | Beschreibung |
|--------|---------|--------------|
| `EXTERNALS_OFFLINE` | `OFF` | Nur Cache verwenden, kein Netzwerk |
| `EXTERNALS_FORCE_FETCH` | `OFF` | Alle Externals neu herunterladen |

---

## 4. API-Referenz

### 4.1 _fetch_git_external()

```cmake
_fetch_git_external(EXT_NAME EXT_JSON)
```

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| `EXT_NAME` | String | Name des Externals |
| `EXT_JSON` | JSON | JSON-Definition mit `git`, `tag/branch/commit` |

**JSON-Felder:**

| Feld | Pflicht | Beschreibung |
|------|---------|--------------|
| `git` | ✓ | Repository-URL |
| `tag` | ¹ | Git-Tag (z.B. "v1.12.0") |
| `branch` | ¹ | Git-Branch (z.B. "main") |
| `commit` | ¹ | Git-Commit-Hash |
| `shallow` | ✗ | Shallow Clone (default: true) |

¹ Genau eines von `tag`, `branch`, `commit` erforderlich.

---

### 4.2 _make_external_available()

```cmake
_make_external_available(EXT_NAME)
```

Macht ein deklariertes External verfügbar (Download falls nötig).

---

### 4.3 _is_external_populated()

```cmake
_is_external_populated(EXT_NAME OUT_VAR)
```

Prüft ob ein External verfügbar ist.

---

### 4.4 _get_external_source_dir()

```cmake
_get_external_source_dir(EXT_NAME OUT_VAR)
```

Gibt den Source-Pfad eines Externals zurück.

---

### 4.5 _is_complete_clone()

```cmake
_is_complete_clone(EXT_NAME CACHE_DIR OUT_OK)
```

> **Seit:** Modul-Version 1.1.0

Entscheidet, ob `CACHE_DIR` einen benutzbaren Klon enthält oder nur die
Überreste eines abgebrochenen Fetches. Kriterium ist ein auflösbarer `HEAD`
(`git rev-parse --verify --quiet HEAD`) — den gibt es erst, wenn der Klon weit
genug kam, um etwas auszuchecken.

Ohne verfügbares `git` ist die Frage nicht entscheidbar; der Klon gilt dann als
vollständig. Das ist unkritisch: `_check_cached_version()` meldet ohne `git`
ohnehin „mismatch", das External wird also so oder so neu geholt.

---

### 4.6 _purge_cache_dir()

```cmake
_purge_cache_dir(EXT_NAME CACHE_DIR)
```

> **Seit:** Modul-Version 1.1.0

Entfernt `CACHE_DIR` vollständig und prüft nach, ob es tatsächlich weg ist.
Überlebt das Verzeichnis, bricht die Funktion mit **E219** ab — mit Pfad,
üblichen Ursachen (offene Datei, zu langer Pfad) und Handlungsanweisung.

Das Löschen hier statt in FetchContent zu lassen ist der ganze Zweck: An dieser
Stelle ist noch bekannt, *welches* External betroffen ist und *warum* das
Verzeichnis weg muss.

---

## 5. Caching-Logik

### Entscheidungsbaum

```
FORCE_FETCH=ON?  ──YES──► FETCH
       │
       NO
       ▼
.git vorhanden? ──NO──► Verzeichnis da? ──YES──► OFFLINE? ──YES──► E218 ERROR
       │                      │                     │
      YES                     NO                    NO
       │                      │                     ▼
       │                      ▼            W303 + LOESCHEN + FETCH
       │                 OFFLINE? ──YES──► E218 ERROR
       │                      │
       │                      NO
       │                      ▼
       │                    FETCH
       ▼
Klon vollstaendig? ──NO──► OFFLINE? ──YES──► E218 ERROR
       │                      │
      YES                     NO
       │                      ▼
       │             W303 + LOESCHEN + FETCH
       ▼
Version match? ──YES──► USE CACHE
       │
       NO
       ▼
OFFLINE? ──YES──► W302 + USE CACHE
    │
    NO
    ▼
  FETCH
```

### Warum „Klon vollständig?" eine eigene Frage ist

`git clone` legt `.git` früh an und füllt es danach. Bricht der Vorgang ab —
Netz weg, Strg-C, Platte voll —, bleibt ein `.git` ohne ausgecheckten Stand
liegen. Die Existenz von `.git` bedeutet also **nicht**, dass dort ein
benutzbarer Klon liegt.

Bis v0.9.0 fehlte diese Unterscheidung, mit zwei Folgen:

1. Der Versionsvergleich lief auf Schutt und meldete **„Version mismatch"** —
   eine Diagnose, die in die falsche Richtung zeigt.
2. Das Aufräumen blieb FetchContent überlassen. Scheiterte dessen Löschversuch,
   nannte die Meldung weder die Ursache noch einen Ausweg.

Seit v0.9.1 prüft [`_is_complete_clone()`](#45-_is_complete_clone), ob sich ein
`HEAD` auflösen lässt — den gibt es erst, wenn der Klon weit genug kam. Ist er
unvollständig, räumt [`_purge_cache_dir()`](#46-_purge_cache_dir) selbst auf und
meldet im Fehlerfall **E219** mit Ursache und Abhilfe.

**Bewusst unverändert:** Bei einem *vollständigen* Klon mit abweichender Version
löscht weiterhin FetchContent. Ein Vorab-Löschen an dieser Stelle würde
branch-gepinnte Externals bei jedem Configure neu holen — `_check_cached_version()`
meldet für Branches grundsätzlich „mismatch".

---

## 6. Git-Referenzen

### Tag (empfohlen)

```json
{
    "spdlog": {
        "git": "https://github.com/gabime/spdlog.git",
        "tag": "v1.12.0"
    }
}
```

### Commit

```json
{
    "imgui": {
        "git": "https://github.com/ocornut/imgui.git",
        "commit": "a1234567890abcdef"
    }
}
```

### Branch (nicht empfohlen)

```json
{
    "experimental": {
        "git": "https://github.com/example/lib.git",
        "branch": "develop"
    }
}
```

---

## 7. Verwendungsbeispiele

### Standard-Verwendung (via Handler)

```cmake
_fetch_git_external("spdlog" "${_ext_json}")
_make_external_available("spdlog")
```

### CI/CD Offline-Build

```bash
cmake -B build-ci -DEXTERNALS_OFFLINE=ON
```

---

## 8. Fehlerbehandlung

| Code | Fehler | Beschreibung |
|------|--------|--------------|
| E012 | Keine git URL | `git` Feld fehlt oder leer |
| E202 | Fetch fehlgeschlagen | FetchContent konnte External nicht laden |
| E215 | Keine Version | Kein tag/branch/commit angegeben |
| E218 | Offline ohne Cache | External nicht gecacht (oder nur unvollständig), OFFLINE=ON |
| E219 | Cache nicht löschbar | Unbrauchbares Cache-Verzeichnis liess sich nicht entfernen |

| Code | Warnung | Beschreibung |
|------|---------|--------------|
| W302 | Version weicht ab | Offline-Modus verwendet den Cache trotzdem |
| W303 | Unvollständiger Klon | Rest eines abgebrochenen Fetches — entfernt und neu geholt |

---

## 9. Siehe auch

- [Handler_cmake.md](Handler_cmake.md) — Fetched External Pipeline
- [HookLoader_cmake.md](../hooks/HookLoader_cmake.md) — Pre/PostFetch Hooks
- [Orchestrator_cmake.md](../Orchestrator_cmake.md) — Type Dispatcher

---

## 10. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.1.0** | **2026-08-08** | **Modul-Version 1.1.0: `_is_complete_clone()` und `_purge_cache_dir()` dokumentiert; Entscheidungsbaum um die Vollständigkeitsprüfung erweitert; E219/W303 ergänzt** |
| 0.5.0 | 2025-12-15 | Dokumentation auf Blueprint v0.5.0 migriert |
