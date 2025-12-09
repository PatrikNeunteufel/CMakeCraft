# ExecutableCreate.cmake – Modul-Dokumentation

> **Modul-Version:** 0.1.0  
> **Dokument-Version:** 0.1.0  
> **Datum:** 2025-12-05  
> **Pfad:** `cmake/project/ExecutableCreate.cmake`  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, Solution_Schema v0.1, guidelines v0.1  
> **Sprache:** Deutsch  

---

## 1. Übersicht

Das `ExecutableCreate.cmake` Modul erstellt ein CMake-Executable-Target aus einem vorbereiteten Context.

### Verantwortlichkeiten

- CMake `add_executable()` aufrufen
- Source-Dateien sammeln (GLOB)
- Include-Verzeichnisse setzen
- Precompiled Headers konfigurieren
- Dependencies linken
- Compiler/Linker-Optionen anwenden
- Standard-Module aufrufen
- Plattform-spezifische Properties setzen

---

## 2. Abhängigkeiten

```cmake
include(cmake/core/Context.cmake)
include(cmake/core/Errors.cmake)
include(cmake/core/Debug.cmake)
include(cmake/core/OutputDirs.cmake)
include(cmake/core/Warnings.cmake)
include(cmake/core/CompilerOptions.cmake)
```

---

## 3. Funktion

### _create_executable_target

```cmake
_create_executable_target(CTX)
```

| Parameter | Beschreibung |
|-----------|--------------|
| `CTX` | Context-Prefix mit gesammelten Daten |

---

## 4. Target-Erstellung

### 4.1 GUI vs. CONSOLE

| TYPE | Windows | macOS | Linux |
|------|---------|-------|-------|
| `GUI` | `WIN32` | `MACOSX_BUNDLE` | normal |
| andere | normal | normal | normal |

### 4.2 Source-Collection

```cmake
file(GLOB_RECURSE _sources
    "${_src_dir}/*.cpp"
    "${_src_dir}/*.cxx"
    "${_src_dir}/*.cc"
    "${_src_dir}/*.c"
)
```

### 4.3 Angewandte Module

- `apply_warnings()` – Compiler-Warnungen
- `apply_compiler_options()` – Compiler-Optionen
- `setup_output_dirs()` – Output-Verzeichnisse

---

## 5. Fehlerbehandlung

| Code | Beschreibung |
|------|--------------|
| E001 | Source-Pfad existiert nicht |
| E101 | Dependency existiert nicht |
| E010 | External nicht definiert |
| W101 | Keine Sources gefunden / PCH nicht gefunden |

---

## 6. Siehe auch

- [ExecutableCollect.cmake](ExecutableCollect_cmake_v0_1_0_doc_v0_1.md)
- [Executables.cmake](Executables_cmake_v0_1_0_doc_v0_1.md)

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-05** | **Clean Start** |
