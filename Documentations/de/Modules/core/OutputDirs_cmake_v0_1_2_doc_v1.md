# OutputDirs.cmake – Dokumentation

> **Version:** 0.1.2 (doc v1)  
> **Datum:** 2025-12-07  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/core/OutputDirs.cmake  
> **Modul-Version:** 0.1.2  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch

---

## 1. Übersicht

Das `OutputDirs.cmake` Modul konfiguriert **standardisierte Output-Verzeichnisse** für alle Targets. Jedes Target erhält seinen eigenen isolierten Ordner im Build-Verzeichnis.

**Kernidee:** Jedes Target bekommt einen eigenen Unterordner mit `bin/` und `lib/` – saubere Trennung für Multi-Projekt-Builds.

**NEU in v0.1.2:** Target-isolierte Verzeichnisse statt gemeinsamer bin/lib Ordner.

---

## 2. Abhängigkeiten

| Modul | Version | Verwendung |
|-------|---------|------------|
| - | - | Keine (Standalone-Modul) |

---

## 3. Konzept

### 3.1 Verzeichnisstruktur (NEU in v0.1.2)

```
build/
├── MyApp/                      # Target-spezifischer Ordner
│   ├── bin/                    # Executables, DLLs
│   │   ├── Debug/
│   │   │   ├── MyApp.exe
│   │   │   └── required.dll
│   │   └── Release/
│   └── lib/                    # Import Libraries
│       ├── Debug/
│       └── Release/
├── OtherApp/                   # Weiteres Target
│   ├── bin/
│   │   └── Debug/
│   │       ├── OtherApp.exe
│   │       └── other.dll
│   └── lib/
└── CoreLib/                    # Library Target
    └── lib/
        └── Debug/
            └── CoreLib.lib
```

### 3.2 Vorteile der Target-Isolation

| Vorteil | Beschreibung |
|---------|--------------|
| **Übersichtlichkeit** | Sofort sichtbar welche Dateien zu welchem Target gehören |
| **DLL-Isolation** | Jedes Executable hat seine eigenen DLLs, keine Konflikte |
| **Einfaches Deployment** | Einen Ordner kopieren = komplettes Programm |
| **Parallele Versionen** | Verschiedene Executables können verschiedene DLL-Versionen nutzen |

### 3.3 Target-Properties

| Property | Verzeichnis | Inhalt |
|----------|-------------|--------|
| `RUNTIME_OUTPUT_DIRECTORY` | `${TARGET}/bin/` | Executables, DLLs |
| `LIBRARY_OUTPUT_DIRECTORY` | `${TARGET}/lib/` | Shared Libraries (.so) |
| `ARCHIVE_OUTPUT_DIRECTORY` | `${TARGET}/lib/` | Static Libraries (.a, .lib) |

---

## 4. API-Referenz

### setup_output_dirs()

Konfiguriert Output-Verzeichnisse für ein Target.

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
# → build/MyApp/bin/Debug/MyApp.exe
```

---

## 5. Verwendungsbeispiele

### 5.1 Einfache Anwendung

```cmake
add_executable(MyApp main.cpp)
setup_output_dirs(MyApp)
# → build/MyApp/bin/MyApp.exe
# → build/MyApp/bin/Debug/MyApp.exe (Multi-Config)
```

### 5.2 Mehrere Executables

```cmake
add_executable(Editor main_editor.cpp)
setup_output_dirs(Editor)
# → build/Editor/bin/Debug/Editor.exe

add_executable(Player main_player.cpp)
setup_output_dirs(Player)
# → build/Player/bin/Debug/Player.exe

add_executable(Server main_server.cpp)
setup_output_dirs(Server)
# → build/Server/bin/Debug/Server.exe
```

### 5.3 Libraries

```cmake
add_library(CoreLib STATIC ${SOURCES})
setup_output_dirs(CoreLib)
# → build/CoreLib/lib/Debug/CoreLib.lib

add_library(PluginLib SHARED ${SOURCES})
setup_output_dirs(PluginLib)
# → build/PluginLib/bin/Debug/PluginLib.dll (Windows)
# → build/PluginLib/lib/Debug/libPluginLib.so (Linux)
```

### 5.4 In der Pipeline

```cmake
function(_create_executable_target CTX)
    ctx_get(${CTX} NAME _name)
    
    add_executable(${_name} ${_sources})
    setup_output_dirs(${_name})      # ← Target-isolierte Verzeichnisse
    apply_warnings(${_name})
    apply_compiler_options(${_name})
endfunction()
```

---

## 6. Plattform-Verhalten

### Windows (MSVC, Multi-Config)

```
build/
├── MyApp/
│   ├── bin/
│   │   ├── Debug/
│   │   │   └── MyApp.exe
│   │   └── Release/
│   │       └── MyApp.exe
│   └── lib/
└── CoreLib/
    └── lib/
        ├── Debug/
        │   └── CoreLib.lib
        └── Release/
            └── CoreLib.lib
```

### Linux/macOS (Single-Config)

```
build/
├── MyApp/
│   └── bin/
│       └── MyApp
└── CoreLib/
    └── lib/
        └── libCoreLib.a
```

**Hinweis:** Bei Single-Config-Generatoren (Make, Ninja) werden Config-Unterordner nur verwendet wenn explizit konfiguriert.

---

## 7. Migration von v0.1.1

### Alte Struktur (v0.1.1)

```
build/
├── bin/
│   └── Debug/
│       ├── App1.exe
│       ├── App2.exe
│       └── shared.dll    # Konfliktpotential!
└── lib/
```

### Neue Struktur (v0.1.2)

```
build/
├── App1/
│   └── bin/Debug/
│       ├── App1.exe
│       └── shared_v1.dll
├── App2/
│   └── bin/Debug/
│       ├── App2.exe
│       └── shared_v2.dll   # Kein Konflikt!
```

### Anpassungen erforderlich

1. **Build-Scripte:** Pfade zu Executables anpassen
2. **CI/CD:** Artifact-Pfade aktualisieren
3. **Debugging:** Arbeitsverzeichnis in IDE anpassen

---

## 8. Best Practices

### 8.1 Immer für alle Targets aufrufen

```cmake
# ✅ Gut - konsistente Struktur
add_executable(App1 ...)
setup_output_dirs(App1)

add_executable(App2 ...)
setup_output_dirs(App2)
```

### 8.2 DLL-Kopieren für Dependencies

Wenn Executable A eine DLL von Library B braucht:

```cmake
# Nach dem Build DLL kopieren
add_custom_command(TARGET MyApp POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        $<TARGET_FILE:SharedLib>
        $<TARGET_FILE_DIR:MyApp>
)
```

### 8.3 Working Directory in IDE

Für Visual Studio / CLion das Working Directory setzen:

```cmake
set_target_properties(MyApp PROPERTIES
    VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/MyApp/bin/Debug"
)
```

---

## 9. Siehe auch

- [guidelines](../../Concepts/guidelines_v0_1_0.md) – Build-System Konventionen
- [Warnings.cmake](Warnings_cmake_v0_1_1_doc_v1.md) – Warning-Level
- [CompilerOptions.cmake](CompilerOptions_cmake_v0_1_1_doc_v1.md) – Compiler-Konfiguration

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.2** | **2025-12-07** | **Target-isolierte Verzeichnisse: Jedes Target bekommt eigenen Unterordner** |
| 0.1.1 | 2025-12-05 | English translation (Language Standards v0.1.1) |
| 0.1.0 | 2025-12-04 | Initial: setup_output_dirs() für bin/ und lib/ |
