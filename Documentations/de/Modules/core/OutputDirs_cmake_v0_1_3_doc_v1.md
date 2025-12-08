# OutputDirs.cmake – Dokumentation

> **Version:** 0.1.3 (doc v1)  
> **Datum:** 2025-12-07  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/core/OutputDirs.cmake  
> **Modul-Version:** 0.1.3  
> **Basiert auf:** master_concept v0.1, guidelines v0.1
> **Sprache:** Deutsch

---

## 1. Übersicht

Das `OutputDirs.cmake` Modul konfiguriert **standardisierte Output-Verzeichnisse** für alle Targets. Jedes Target erhält seinen eigenen isolierten Ordner, getrennt nach Typ (exec/libs).

**Kernidee:** Automatische Erkennung des Target-Typs und Platzierung in `exec/` oder `libs/` Unterordner.

**NEU in v0.1.3:** 
- Target-isolierte Verzeichnisse statt gemeinsamer bin/lib Ordner
- Automatische Typ-Erkennung (EXECUTABLE vs LIBRARY)
- Trennung in `exec/` und `libs/` Ordner

---

## 2. Abhängigkeiten

| Modul | Version | Verwendung |
|-------|---------|------------|
| - | - | Keine (Standalone-Modul) |

---

## 3. Konzept

### 3.1 Verzeichnisstruktur (NEU in v0.1.2)

```
out/build/windows-ninja-debug-clang/
├── exec/                           # Alle Executables
│   ├── MyApp/
│   │   └── bin/Debug/
│   │       ├── MyApp.exe
│   │       └── required.dll
│   └── OtherApp/
│       └── bin/Debug/
│           └── OtherApp.exe
└── libs/                           # Alle Libraries
    ├── CoreLib/
    │   └── lib/Debug/
    │       └── CoreLib.lib
    └── PluginLib/
        └── lib/Debug/
            └── PluginLib.dll
```

### 3.2 Automatische Typ-Erkennung

| Target-Type | Kategorie | Pfad |
|-------------|-----------|------|
| `EXECUTABLE` | exec | `exec/${NAME}/bin/` |
| `STATIC_LIBRARY` | libs | `libs/${NAME}/lib/` |
| `SHARED_LIBRARY` | libs | `libs/${NAME}/lib/` |
| `MODULE_LIBRARY` | libs | `libs/${NAME}/lib/` |
| `OBJECT_LIBRARY` | libs | `libs/${NAME}/lib/` |
| `INTERFACE_LIBRARY` | libs | `libs/${NAME}/lib/` |

### 3.3 Vorteile

| Vorteil | Beschreibung |
|---------|--------------|
| **Spiegelt Source-Struktur** | `projects/exec/` → `build/exec/`, `projects/libs/` → `build/libs/` |
| **Übersichtlichkeit** | Sofort sichtbar was Executable und was Library ist |
| **DLL-Isolation** | Jedes Executable hat seine eigenen DLLs |
| **Einfaches Deployment** | Einen exec-Ordner kopieren = komplettes Programm |

---

## 4. API-Referenz

### setup_output_dirs()

Konfiguriert Output-Verzeichnisse für ein Target mit automatischer Typ-Erkennung.

```cmake
setup_output_dirs(<TARGET_NAME>)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| TARGET_NAME | String | CMake Target (muss existieren) |

**Beispiel:**

```cmake
add_executable(MyApp main.cpp)
setup_output_dirs(MyApp)
# → build/exec/MyApp/bin/Debug/MyApp.exe

add_library(CoreLib STATIC core.cpp)
setup_output_dirs(CoreLib)
# → build/libs/CoreLib/lib/Debug/CoreLib.lib
```

---

## 5. Verwendungsbeispiele

### 5.1 Executables

```cmake
add_executable(Editor main_editor.cpp)
setup_output_dirs(Editor)
# → build/exec/Editor/bin/Debug/Editor.exe

add_executable(Player main_player.cpp)
setup_output_dirs(Player)
# → build/exec/Player/bin/Debug/Player.exe
```

### 5.2 Libraries

```cmake
add_library(CoreLib STATIC ${SOURCES})
setup_output_dirs(CoreLib)
# → build/libs/CoreLib/lib/Debug/CoreLib.lib

add_library(PluginLib SHARED ${SOURCES})
setup_output_dirs(PluginLib)
# → build/libs/PluginLib/lib/Debug/PluginLib.dll
```

### 5.3 In der Pipeline

```cmake
# ExecutableCreate.cmake
function(_create_executable_target CTX)
    ctx_get(${CTX} NAME _name)
    add_executable(${_name} ${_sources})
    setup_output_dirs(${_name})  # → exec/${_name}/bin/
endfunction()

# LibraryCreate.cmake
function(_create_library_target CTX)
    ctx_get(${CTX} NAME _name)
    add_library(${_name} ${_type} ${_sources})
    setup_output_dirs(${_name})  # → libs/${_name}/lib/
endfunction()
```

---

## 6. Plattform-Verhalten

### Windows (Multi-Config)

```
build/
├── exec/
│   └── MyApp/
│       └── bin/
│           ├── Debug/MyApp.exe
│           └── Release/MyApp.exe
└── libs/
    └── CoreLib/
        └── lib/
            ├── Debug/CoreLib.lib
            └── Release/CoreLib.lib
```

### Linux/macOS (Single-Config)

```
build/
├── exec/
│   └── MyApp/
│       └── bin/
│           └── MyApp
└── libs/
    └── CoreLib/
        └── lib/
            └── libCoreLib.a
```

---

## 7. Migration von v0.1.1

### Alte Struktur (v0.1.1)

```
build/
├── bin/Debug/
│   ├── App1.exe
│   ├── App2.exe
│   └── shared.dll
└── lib/Debug/
    └── CoreLib.lib
```

### Neue Struktur (v0.1.2)

```
build/
├── exec/
│   ├── App1/
│   │   └── bin/Debug/App1.exe
│   └── App2/
│       └── bin/Debug/App2.exe
└── libs/
    └── CoreLib/
        └── lib/Debug/CoreLib.lib
```

### Anpassungen erforderlich

1. **Build-Scripte:** Pfade anpassen (`bin/` → `exec/${NAME}/bin/`)
2. **CI/CD:** Artifact-Pfade aktualisieren
3. **IDE:** Working Directory anpassen

---

## 8. Best Practices

### 8.1 DLL-Kopieren für Dependencies

```cmake
add_custom_command(TARGET MyApp POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        $<TARGET_FILE:SharedLib>
        $<TARGET_FILE_DIR:MyApp>
)
```

### 8.2 Working Directory in Visual Studio

```cmake
set_target_properties(MyApp PROPERTIES
    VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/exec/MyApp/bin/$<CONFIG>"
)
```

---

## 9. Siehe auch

- [guidelines](../../Concepts/guidelines_v0_1_0.md) – Build-System Konventionen
- [ExecutableCreate.cmake](../project/ExecutableCreate_cmake_v0_1_0_doc_v0_1.md)
- [LibraryCreate.cmake](../project/LibraryCreate_cmake_v0_1_0_doc_v0_1.md)

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.3** | **2025-12-07** | **Target-isolierte Verzeichnisse mit exec/libs Trennung, Auto-Detection** |
| 0.1.2 | 2025-12-07 | Target-isolierte Verzeichnisse (ohne exec/libs Trennung) |
| 0.1.1 | 2025-12-05 | English translation |
| 0.1.0 | 2025-12-04 | Initial: setup_output_dirs() für bin/ und lib/ |
