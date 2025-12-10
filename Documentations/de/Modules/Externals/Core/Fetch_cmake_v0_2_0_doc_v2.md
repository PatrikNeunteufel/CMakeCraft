# Fetch.cmake – Dokumentation

> **Version:** 0.2.0 (doc v2)  
> **Datum:** 2025-12-10  
> **Typ:** Modul-Doku  
> **Status:** Stabil  
> **Modul:** cmake/externals/Core/Fetch.cmake  
> **Modul-Version:** 0.2.0  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Modules/Externals/Fetch_cmake_v0_2_0_doc_v2.md)

---

## Übersicht

Das Fetch-Modul ist ein Wrapper um CMakes FetchContent für Git-basierte Externals. Ab Version 0.2.0 verwendet es ein zentrales `.externals/`-Verzeichnis, das von allen Build-Presets gemeinsam genutzt wird.

### Convention

| Feld in Solution.json | Speicherort | Git-Status |
|-----------------------|-------------|------------|
| `path` | `externals/` | ✅ Committed |
| `git` | `.externals/` | ❌ Gitignored |

Diese Convention ist implizit - keine zusätzliche Konfiguration nötig.

### Hauptfunktionen

| Funktion | Beschreibung |
|----------|--------------|
| `_fetch_git_external()` | Deklariert Git-External mit Cache-Prüfung |
| `_make_external_available()` | Konfiguriert External (Download nur wenn nötig) |
| `_is_external_populated()` | Prüft ob External verfügbar |
| `_get_external_source_dir()` | Gibt Source-Verzeichnis zurück |

---

## Cache-Verzeichnis

### Struktur

```
project_root/
├── .externals/              ← Gefetchte Externals (gitignored)
│   ├── glfw/
│   │   └── .git/
│   ├── imgui/
│   │   └── .git/
│   └── spdlog/
│       └── .git/
├── externals/               ← Lokale Externals (committed)
│   ├── bass/
│   └── glad/
└── build/                   ← Build-Verzeichnisse
    ├── msvc-debug/          ← Alle nutzen .externals/
    └── clang-release/
```

### Vorteile

| Aspekt | Vorher (v0.1.0) | Nachher (v0.2.0) |
|--------|-----------------|------------------|
| Download | Bei jedem Configure | Nur einmal |
| Preset-Wechsel | Neuer Download | Sofort (Cache) |
| Offline | Fehler | Funktioniert |
| Speicher | N × Kopien | 1 × Kopie |

---

## CMake-Optionen

| Variable | Default | Beschreibung |
|----------|---------|--------------|
| `EXTERNALS_FETCH_ROOT` | `.externals` | Verzeichnis für gefetchte Externals |
| `EXTERNALS_OFFLINE` | `OFF` | Nur Cache verwenden, kein Netzwerk |
| `EXTERNALS_FORCE_FETCH` | `OFF` | Cache ignorieren, neu laden |

### Verwendung

```bash
# Normal (nutzt Cache wenn vorhanden)
cmake --preset msvc-debug

# Offline-Modus (nur Cache)
cmake --preset msvc-debug -DEXTERNALS_OFFLINE=ON

# Force Re-Fetch
cmake --preset msvc-debug -DEXTERNALS_FORCE_FETCH=ON
```

---

## Funktionsweise

### Download vs. Configure

`FetchContent_MakeAvailable()` führt zwei Schritte aus:

1. **Download** - Lädt Source von Git herunter
2. **Configure** - Ruft `add_subdirectory()` auf, erstellt Targets

Bei gecachten Externals wird nur Schritt 1 übersprungen. Schritt 2 (Configure) ist **immer** nötig, damit die Targets erstellt werden.

```
Erstes Configure:    Download ✓  →  Configure ✓  →  Targets erstellt
Folgende Configures: (cached)   →  Configure ✓  →  Targets erstellt
```

### Entscheidungslogik

```
┌─────────────────────────────────────────┐
│ _fetch_git_external() aufgerufen        │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│ EXTERNALS_FORCE_FETCH=ON?               │
├─────────────────┬───────────────────────┤
│ Ja              │ Nein                  │
│ → Download      │ ↓                     │
└─────────────────┴───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│ .externals/${name}/.git existiert?      │
├─────────────────┬───────────────────────┤
│ Ja              │ Nein                  │
│ → Version prüfen│ → Check Offline       │
└─────────────────┴───────────────────────┘
                  │
    ┌─────────────┴─────────────┐
    ▼                           ▼
┌───────────────┐       ┌───────────────────┐
│ Version OK    │       │ EXTERNALS_OFFLINE │
│ → Skip        │       │ = ON?             │
└───────────────┘       ├─────────┬─────────┤
                        │ Ja      │ Nein    │
                        │ → E218  │ → Fetch │
                        └─────────┴─────────┘
```

---

## API-Referenz

### _fetch_git_external

```cmake
_fetch_git_external(EXT_NAME EXT_JSON)
```

Deklariert ein Git-basiertes External. Prüft zuerst den Cache in `.externals/`.

**Parameter:**
- `EXT_NAME` - Name des Externals
- `EXT_JSON` - JSON-Definition mit git, tag/branch/commit

**JSON-Felder:**
- `git` - Repository-URL (Pflicht)
- `tag` - Git-Tag
- `branch` - Git-Branch
- `commit` - Commit-Hash
- `shallow` - Shallow Clone (Default: true für tag/branch)

**Beispiel:**

```cmake
_fetch_git_external("spdlog" "{\"git\":\"https://github.com/gabime/spdlog.git\",\"tag\":\"v1.12.0\"}")
```

### _make_external_available

```cmake
_make_external_available(EXT_NAME)
```

Macht ein deklariertes External verfügbar. Ruft immer `FetchContent_MakeAvailable()` auf - Download wird bei Cache übersprungen, aber Configure ist immer nötig für Targets.

**Parameter:**
- `EXT_NAME` - Name des Externals

**Beispiel:**

```cmake
_make_external_available("spdlog")
```

### _is_external_populated

```cmake
_is_external_populated(EXT_NAME OUT_VAR)
```

Prüft ob ein External erfolgreich geladen/gecached wurde.

**Parameter:**
- `EXT_NAME` - Name des Externals
- `OUT_VAR` - Output-Variable (TRUE/FALSE)

### _get_external_source_dir

```cmake
_get_external_source_dir(EXT_NAME OUT_VAR)
```

Gibt das Source-Verzeichnis zurück (in `.externals/`).

**Parameter:**
- `EXT_NAME` - Name des Externals
- `OUT_VAR` - Output-Variable für Pfad

---

## Versions-Prüfung

### Tag

Bei Tags wird geprüft ob der aktuelle HEAD dem Tag entspricht:

```bash
git rev-parse "${TAG}^{}" == git rev-parse HEAD
```

### Commit

Bei Commits werden die ersten 7 Zeichen verglichen:

```bash
HEAD[0:7] == EXPECTED[0:7]
```

### Branch

Branches werden immer als "potentiell veraltet" betrachtet (könnten neue Commits haben), außer im Offline-Modus.

---

## Fehlerbehandlung

| Code | Beschreibung | Lösung |
|------|--------------|--------|
| E012 | Keine git URL | `git` Feld in Solution.json hinzufügen |
| E215 | Kein tag/branch/commit | Eines der Felder angeben |
| E218 | Offline ohne Cache | Cache aufbauen oder Offline deaktivieren |
| E202 | Fetch/Configure fehlgeschlagen | Netzwerk/URL prüfen |
| W302 | Version-Mismatch (Offline) | Cache aktualisieren wenn online |

---

## Abhängigkeiten

**Benötigt:**
- `cmake/core/Errors.cmake` (v0.1.2+)
- `cmake/core/Debug.cmake`
- `cmake/core/Json.cmake`

**Wird verwendet von:**
- `cmake/externals/Fetched/Handler.cmake`

---

## Beispiel-Workflow

```bash
# 1. Erstes Configure - Download + Configure
$ cmake --preset msvc-debug
[glfw] Fetching from https://github.com/glfw/glfw.git (tag: 3.4)...
[glfw] Fetched and configured successfully
[imgui] Fetching from https://github.com/ocornut/imgui.git (tag: v1.90.1)...
[imgui] Fetched and configured successfully

# 2. Zweites Configure - nur Configure (kein Download)
$ cmake --preset msvc-debug
[glfw] Using cached version (cached)
[glfw] Configured from cache
[imgui] Using cached version (cached)
[imgui] Configured from cache

# 3. Anderes Preset - selber Cache!
$ cmake --preset clang-release
[glfw] Using cached version (cached)
[glfw] Configured from cache

# 4. Offline arbeiten
$ cmake --preset msvc-debug -DEXTERNALS_OFFLINE=ON
[glfw] Using cached version (cached)
[glfw] Configured from cache

# 5. Tag geändert in Solution.json
$ cmake --preset msvc-debug
[glfw] Using cached version (cached)
[imgui] Fetching from https://... (tag: v1.91.0)...  # Neue Version!

# 6. Cache löschen und neu laden
$ rm -rf .externals/
$ cmake --preset msvc-debug
[glfw] Fetching...
[imgui] Fetching...
```

---

## .gitignore

Füge zu `.gitignore` hinzu:

```gitignore
# Gefetchte Externals
/.externals/
```

---

## Siehe auch

- [Handler.cmake](Handler_cmake_v0_1_1_doc_v1.md) – Verwendet Fetch.cmake
- [Externals Referenz](../../References/Externals_v0_2_1.md) – Verfügbare Externals
- [ErrorCodes](../../References/ErrorCodes_v0_1_2.md) – E218, W302

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.2.0 (doc v2)** | **2025-12-10** | **Korrektur: FetchContent_MakeAvailable immer aufrufen, externalsPolicy entfernt** |
| 0.2.0 (doc v1) | 2025-12-09 | Zentrales .externals/ Caching, Offline-Modus, Force-Fetch |
| 0.1.0 (doc v1) | 2025-12-09 | Initial: FetchContent Wrapper |
