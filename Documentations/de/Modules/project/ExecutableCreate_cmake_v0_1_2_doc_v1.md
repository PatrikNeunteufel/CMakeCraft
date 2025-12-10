# ExecutableCreate.cmake – Dokumentation

> **Version:** 0.1.2 (doc v1)  
> **Datum:** 2025-12-09  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/project/ExecutableCreate.cmake  
> **Modul-Version:** 0.1.2  
> **Basiert auf:** master_concept v0.1, guidelines v0.1, Solution_Schema v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Modules/project/ExecutableCreate_cmake_v0_1_2.md)

---

## 1. Übersicht

Das `ExecutableCreate.cmake` Modul erstellt ein CMake-Executable-Target aus einem vorbereiteten Context. Es bildet den letzten Schritt der Executable-Pipeline nach `ExecutableCollect.cmake`.

### Verantwortlichkeiten

- CMake `add_executable()` aufrufen
- Source-Dateien sammeln (über SourceCollect)
- Include-Verzeichnisse setzen
- Precompiled Headers konfigurieren
- Dependencies linken (intern + extern)
- Compiler/Linker-Optionen anwenden
- Standard-Module aufrufen (Warnings, OutputDirs)
- Plattform-spezifische Properties setzen
- **NEU v0.1.2:** APP_WINDOWS_GUI Define für Windows GUI-Anwendungen

---

## 2. Abhängigkeiten

| Modul | Version | Verwendung |
|-------|---------|------------|
| Context.cmake | 0.1+ | Context lesen |
| Errors.cmake | 0.1+ | `cmake_fatal()`, Fehlermeldungen |
| Debug.cmake | 0.1+ | `dbg()` Debug-Ausgaben |
| SourceCollect.cmake | 0.1+ | Source-Dateien sammeln |
| OutputDirs.cmake | 0.1+ | Output-Verzeichnisse |
| Warnings.cmake | 0.1+ | Compiler-Warnungen |
| CompilerOptions.cmake | 0.1+ | Compiler-Optionen |
| Externals/Orchestrator.cmake | 0.2+ | External-Linking |

---

## 3. Konzept

### 3.1 Pipeline-Position

```
Solution.json
    ↓
Executables.cmake (Iteration)
    ↓
ExecutableCollect.cmake (JSON → Context)
    ↓
>>> ExecutableCreate.cmake (Context → Target) <<<
```

### 3.2 Verarbeitungsschritte

| Schritt | Beschreibung |
|---------|--------------|
| 1 | Context lesen (NAME, PATH, TYPE, etc.) |
| 2 | Source-Pfad validieren |
| 3 | Source-Dateien sammeln |
| 4 | Target erstellen (add_executable) |
| 5 | Include-Directories setzen |
| 6 | Interne Dependencies linken |
| 7 | Externe Dependencies linken |
| 8 | Compiler/Linker-Optionen anwenden |
| 9 | Precompiled Headers konfigurieren |
| 10 | Windows GUI spezifisch (APP_WINDOWS_GUI) |

---

## 4. API-Referenz

### 4.1 _create_executable_target()

Erstellt das Executable-Target aus dem Context.

```cmake
_create_executable_target(CTX)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| CTX | String | Context-Prefix mit gesammelten Daten |

**Gelesene Context-Keys:**

| Key | Typ | Beschreibung |
|-----|-----|--------------|
| NAME | String | Target-Name |
| PATH | String | Source-Verzeichnis (relativ) |
| TYPE | String | GUI, CONSOLE, CLI, HEADLESS, WORKER |
| DEPENDENCIES | List | Interne Dependencies |
| EXTERNALS | List | Externe Dependencies |
| PCH_ENABLED | Boolean | Precompiled Header aktiviert |
| PCH_HEADER | String | PCH Header-Datei |
| DEFINES | List | Preprocessor-Definitionen |
| COMPILE_OPTIONS | List | Compiler-Optionen |
| LINK_OPTIONS | List | Linker-Optionen |

**Beispiel:**

```cmake
# Context wurde von ExecutableCollect vorbereitet
ctx_get(EXE_0 NAME _name)  # "MyApp"

# Target erstellen
_create_executable_target(EXE_0)

# Ergebnis: CMake Target "MyApp" existiert
```

---

## 5. Target-Erstellung

### 5.1 GUI vs. CONSOLE

| TYPE | Windows | macOS | Linux |
|------|---------|-------|-------|
| `GUI` | `WIN32` | `MACOSX_BUNDLE` | normal |
| andere | normal | normal | normal |

```cmake
if(_type STREQUAL "GUI")
    if(WIN32)
        add_executable(${_name} WIN32 ${_sources})
    elseif(APPLE)
        add_executable(${_name} MACOSX_BUNDLE ${_sources})
    else()
        add_executable(${_name} ${_sources})
    endif()
else()
    add_executable(${_name} ${_sources})
endif()
```

### 5.2 APP_WINDOWS_GUI Define (NEU in v0.1.2)

Für Windows GUI-Anwendungen wird automatisch `APP_WINDOWS_GUI` definiert:

```cmake
if(_type STREQUAL "GUI" AND WIN32)
    target_compile_definitions(${_name} PRIVATE APP_WINDOWS_GUI)
endif()
```

**Verwendung im Code:**

```cpp
#ifdef APP_WINDOWS_GUI
// Windows GUI Entry Point
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
                   LPSTR lpCmdLine, int nCmdShow)
{
    return main(__argc, __argv);
}
#endif

int main(int argc, char* argv[])
{
    // Normale Anwendungslogik
    return 0;
}
```

**Warum nötig?**

Windows GUI-Anwendungen (mit `WIN32` Flag) erwarten `WinMain` statt `main`. Ohne diesen Entry Point gibt es Linker-Fehler:
```
LNK2019: unresolved external symbol WinMain
```

Das `APP_WINDOWS_GUI` Define ermöglicht bedingten Code ohne manuelle Präprozessor-Logik.

### 5.3 Source-Collection

Sources werden über `SourceCollect.cmake` gesammelt:

```cmake
collect_sources(
    DIRECTORY "${_src_dir}"
    RECURSE
    OUTPUT _sources
)
```

### 5.4 Angewandte Module

| Modul | Funktion | Beschreibung |
|-------|----------|--------------|
| Warnings.cmake | `apply_warnings()` | Compiler-Warnungen |
| CompilerOptions.cmake | `apply_compiler_options()` | Compiler-Optionen |
| OutputDirs.cmake | `setup_output_dirs()` | Output-Verzeichnisse |

---

## 6. Fehlerbehandlung

### 6.1 Error Codes

| Code | Kategorie | Beschreibung |
|------|-----------|--------------|
| E001 | VALIDATION | Source-Pfad existiert nicht |
| E010 | DEPENDENCY | External nicht in Solution.json definiert |
| E101 | DEPENDENCY | Interne Dependency existiert nicht |

### 6.2 Warnungen

| Code | Beschreibung |
|------|--------------|
| W101 | Keine Source-Dateien gefunden |
| W101 | PCH Header nicht gefunden (wenn PCH aktiviert) |

### 6.3 Beispiele

**E001 – Source-Pfad fehlt:**
```
CMake Error at cmake/project/ExecutableCreate.cmake:XX (message):
  [E001] Source path does not exist: src/MissingApp
```

**E101 – Dependency fehlt:**
```
CMake Error at cmake/project/ExecutableCreate.cmake:XX (message):
  [E101] Dependency target does not exist: NonExistentLib
```

---

## 7. Verwendungsbeispiele

### 7.1 Minimale Executable

**Solution.json:**
```json
{
    "executables": [
        {
            "name": "HelloWorld",
            "path": "src/HelloWorld"
        }
    ]
}
```

### 7.2 GUI-Anwendung mit Dependencies

**Solution.json:**
```json
{
    "executables": [
        {
            "name": "MyGuiApp",
            "path": "src/MyGuiApp",
            "type": "GUI",
            "dependencies": ["CoreLib"],
            "externals": ["imgui", "glfw", "glad"]
        }
    ]
}
```

**main.cpp:**
```cpp
#include "imgui.h"
#include "imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"
#include <GLFW/glfw3.h>

#ifdef APP_WINDOWS_GUI
#include <Windows.h>
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
    return main(__argc, __argv);
}
#endif

int main(int argc, char* argv[])
{
    // GLFW + ImGui initialisieren...
    return 0;
}
```

### 7.3 Console-Anwendung mit PCH

**Solution.json:**
```json
{
    "executables": [
        {
            "name": "DataProcessor",
            "path": "src/DataProcessor",
            "type": "CONSOLE",
            "pch": {
                "enabled": true,
                "header": "pch/pch.h"
            },
            "externals": ["lua54"]
        }
    ]
}
```

---

## 8. Best Practices

1. **Type korrekt setzen** – `GUI` nur für echte Windows-Anwendungen mit Fenster
2. **APP_WINDOWS_GUI nutzen** – Vermeidet Linker-Fehler auf Windows
3. **Dependencies sortieren** – Interne vor externen
4. **PCH sinnvoll einsetzen** – Nur bei vielen Headers mit langen Compile-Zeiten

---

## 9. Bekannte Einschränkungen

- **GLOB_RECURSE:** Neue Dateien erfordern CMake-Regenerierung
- **PCH:** Nur ein PCH pro Target möglich
- **macOS Bundle:** Weitere Bundle-Konfiguration nicht automatisiert

---

## 10. Siehe auch

- [ExecutableCollect.cmake](ExecutableCollect_cmake_v0_1_0_doc_v0_1.md) – JSON-Parsing
- [Executables.cmake](Executables_cmake_v0_1_0_doc_v0_1.md) – Pipeline-Koordination
- [SourceCollect.cmake](../core/SourceCollect_cmake_v0_1_1_doc_v1.md) – Source-Sammlung
- [OutputDirs.cmake](../core/OutputDirs_cmake_v0_1_3_doc_v1.md) – Output-Verzeichnisse
- [Orchestrator.cmake](../Externals/Orchestrator_cmake_v0_2_0_doc_v1.md) – External-Linking

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.2 (doc v1)** | **2025-12-09** | **APP_WINDOWS_GUI Define für Windows GUI-Executables, ermöglicht WinMain Entry Point Pattern** |
| 0.1.1 | 2025-12-07 | Bugfix: External-Linking über Orchestrator |
| 0.1.0 | 2025-12-05 | Initial: Clean Start, Target-Erstellung, Dependencies |
