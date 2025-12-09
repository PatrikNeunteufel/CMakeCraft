# Executables.cmake – Modul-Dokumentation

> **Modul-Version:** 0.1.0  
> **Dokument-Version:** 0.1.0  
> **Datum:** 2025-12-05  
> **Pfad:** `cmake/project/Executables.cmake`  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, Solution_Schema v0.1, guidelines v0.1  
> **Sprache:** Deutsch  

---

## 1. Übersicht

Das `Executables.cmake` Modul ist der Orchestrator der Executable-Pipeline. Es iteriert über alle Executables in Solution.json und erstellt die entsprechenden CMake-Targets.

### Verantwortlichkeiten

- Executables-Array aus Solution.json laden
- Über alle Executables iterieren
- Skip-Logik anwenden
- BUILD_ONLY Filter anwenden
- Plattform-Filter anwenden
- Sub-Module aufrufen (Collect, Create)

### Sub-Module

| Modul | Verantwortlichkeit |
|-------|-------------------|
| `ExecutableCollect.cmake` | Daten aus JSON in Context sammeln |
| `ExecutableCreate.cmake` | CMake-Target erstellen |

---

## 2. Abhängigkeiten

**Muss vorher geladen werden:**

```cmake
include(cmake/core/Errors.cmake)
include(cmake/core/Debug.cmake)
include(cmake/core/Json.cmake)
include(cmake/core/Context.cmake)
include(cmake/project/Solution.cmake)
```

**Wird automatisch geladen:**

```cmake
include(cmake/project/ExecutableCollect.cmake)
include(cmake/project/ExecutableCreate.cmake)
```

---

## 3. Filter-Logik

### 3.1 Skip-Flag

Executables mit `"skip": true` werden übersprungen:

```json
{
    "name": "SkippedApp",
    "skip": true
}
```

### 3.2 BUILD_ONLY Filter

Nur bestimmte Targets bauen:

```bash
cmake -B build -DBUILD_ONLY="MyApp;OtherApp"
```

Executables die nicht in der Liste sind werden übersprungen.

### 3.3 Plattform-Filter

Executables können auf bestimmte Plattformen eingeschränkt werden:

```json
{
    "name": "WindowsOnlyApp",
    "platforms": ["windows"]
}
```

| Platform-Wert | CMake-Bedingung |
|---------------|-----------------|
| `windows` | `WIN32` |
| `linux` | `CMAKE_SYSTEM_NAME STREQUAL "Linux"` |
| `macos` | `APPLE` |
| `unix` | `UNIX` |

---

## 4. Pipeline-Ablauf

```
Executables.cmake
       │
       ▼
┌─────────────────────────────────────┐
│ 1. Solution JSON laden              │
│ 2. executables Array prüfen         │
└─────────────────────────────────────┘
       │
       ▼ (für jedes Executable)
┌─────────────────────────────────────┐
│ 3. JSON extrahieren                 │
│ 4. Context erstellen                │
│ 5. _collect_executable() aufrufen   │
└─────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│ 6. Skip-Check                       │
│ 7. BUILD_ONLY-Check                 │
│ 8. Platform-Check                   │
│ 9. Target-Duplikat-Check            │
└─────────────────────────────────────┘
       │
       ▼ (wenn alle Checks bestanden)
┌─────────────────────────────────────┐
│ 10. _create_executable_target()     │
└─────────────────────────────────────┘
```

---

## 5. Debug-Ausgaben

### 5.1 Standard (SHOW_LEVEL = 2)

```
-- [Executables] === Executable Pipeline Start ===
-- [Executables] Processing 3 executable(s)...
-- [Executables] --- Processing: MyApp ---
-- [Executables]   Created: MyApp
-- [Executables] --- Processing: SkippedApp ---
-- [Executables]   SKIP: SkippedApp (skip=true in Solution.json)
-- [Executables] === Executable Pipeline Complete ===
```

### 5.2 Verbose (SHOW_LEVEL = 5)

```bash
cmake -B build -DDEBUG_DEFAULT_LEVEL=5
```

Zeigt zusätzlich:
- Gesammelte Context-Daten
- Source-Dateien
- Link-Informationen

---

## 6. Fehlerbehandlung

### E001: Name fehlt

```
[E001] Executable #0 has no 'name' field
```

**Lösung:** `name` Feld zum Executable hinzufügen.

### E102: Target existiert bereits

```
[E102] Target 'MyApp' already exists
```

**Lösung:** Eindeutige Namen verwenden.

---

## 7. Verwendung

Das Modul wird automatisch in CMakeLists.txt geladen:

```cmake
# Nach Solution.cmake
include(cmake/project/Executables.cmake)
```

### Keine manuelle Interaktion nötig

Das Modul:
- Lädt automatisch Sub-Module
- Verarbeitet alle Executables aus Solution.json
- Erstellt alle CMake-Targets

---

## 8. Siehe auch

- [ExecutableCollect.cmake](ExecutableCollect_cmake_v0_1_0_doc_v0_1.md) – Daten-Sammlung
- [ExecutableCreate.cmake](ExecutableCreate_cmake_v0_1_0_doc_v0_1.md) – Target-Erstellung
- [Solution_Schema](../References/Solution_Schema_v0_1_0.md) – Executable-Felder
- [Context.cmake](Context_cmake_v0_1_0_doc_v0_1.md) – Context-System

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-05** | **Clean Start: Englische Kommentare, v0.1 Schema** |
