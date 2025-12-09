# OutputDirs.cmake – Dokumentation

> **Version:** 0.1.1 (doc v1)  
> **Datum:** 2025-12-05  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/core/OutputDirs.cmake  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Modules/core/OutputDirs_cmake_v0_1_0.md)

---

## 1. Übersicht

Das `OutputDirs.cmake` Modul konfiguriert **standardisierte Output-Verzeichnisse** für alle Targets. Es sorgt für eine einheitliche Struktur im Build-Verzeichnis.

**Kernidee:** Alle Binaries landen in `bin/`, alle Libraries in `lib/` – konsistent für alle Targets.

---

## 2. Abhängigkeiten

| Modul | Version | Verwendung |
|-------|---------|------------|
| - | - | Keine (Standalone-Modul) |

---

## 3. Konzept

### 3.1 Verzeichnisstruktur

```
build/
├── bin/                    # Executables, DLLs
│   ├── Debug/
│   ├── Release/
│   └── Testing/
└── lib/                    # Static/Shared Libraries
    ├── Debug/
    ├── Release/
    └── Testing/
```

### 3.2 Target-Properties

| Property | Verzeichnis | Inhalt |
|----------|-------------|--------|
| `RUNTIME_OUTPUT_DIRECTORY` | `bin/` | Executables, DLLs |
| `LIBRARY_OUTPUT_DIRECTORY` | `lib/` | Shared Libraries (.so) |
| `ARCHIVE_OUTPUT_DIRECTORY` | `lib/` | Static Libraries (.a, .lib) |

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
```

---

## 5. Verwendungsbeispiele

### 5.1 Einfache Anwendung

```cmake
add_executable(MyApp main.cpp)
setup_output_dirs(MyApp)
# → build/bin/MyApp.exe (bzw. build/bin/Debug/MyApp.exe)
```

### 5.2 In der Executable-Pipeline

```cmake
function(_create_executable_target CTX)
    ctx_get(${CTX} NAME _name)
    
    add_executable(${_name} ${_sources})
    setup_output_dirs(${_name})      # ← Output-Verzeichnisse
    apply_warnings(${_name})
    apply_compiler_options(${_name})
endfunction()
```

### 5.3 Für Libraries

```cmake
add_library(CoreLib STATIC ${SOURCES})
setup_output_dirs(CoreLib)
# → build/lib/libCoreLib.a
```

---

## 6. Plattform-Verhalten

### Windows (MSVC, Multi-Config)

```
build/
├── bin/
│   ├── Debug/MyApp.exe
│   └── Release/MyApp.exe
└── lib/
    ├── Debug/CoreLib.lib
    └── Release/CoreLib.lib
```

### Linux/macOS (Single-Config)

```
build/
├── bin/
│   └── MyApp
└── lib/
    └── libCoreLib.a
```

**Hinweis:** Bei Single-Config-Generatoren (Make, Ninja) werden Config-Unterordner nicht verwendet.

---

## 7. Anpassung

### 7.1 Per-Target Override

```cmake
add_executable(SpecialApp main.cpp)
setup_output_dirs(SpecialApp)

# Override für dieses Target
set_target_properties(SpecialApp PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/special"
)
```

### 7.2 Globale Anpassung

```cmake
# Vor include() oder in eigenem Modul
set(CUSTOM_BIN_DIR "${CMAKE_BINARY_DIR}/output/bin")
set(CUSTOM_LIB_DIR "${CMAKE_BINARY_DIR}/output/lib")

# setup_output_dirs() anpassen
```

---

## 8. Best Practices

### 8.1 Immer für alle Targets aufrufen

```cmake
# ✅ Gut - konsistente Struktur
add_executable(App1 ...)
setup_output_dirs(App1)

add_executable(App2 ...)
setup_output_dirs(App2)

add_library(Lib1 ...)
setup_output_dirs(Lib1)
```

### 8.2 Nach add_executable/add_library

```cmake
# ✅ Gut
add_executable(MyApp main.cpp)
setup_output_dirs(MyApp)

# ❌ Schlecht - Target existiert noch nicht
setup_output_dirs(MyApp)
add_executable(MyApp main.cpp)
```

### 8.3 In Pipeline-Funktionen integrieren

```cmake
function(_create_executable_target CTX)
    add_executable(${_name} ${_sources})
    setup_output_dirs(${_name})      # 1. Output
    apply_warnings(${_name})          # 2. Warnungen
    apply_compiler_options(${_name})  # 3. Compiler
endfunction()
```

---

## 9. Siehe auch

- [guidelines](../../Concepts/guidelines_v0_1_0.md) – Build-System Konventionen
- [Warnings.cmake](Warnings_cmake_v0_1_0_doc_v1.md) – Warning-Level
- [CompilerOptions.cmake](CompilerOptions_cmake_v0_1_0_doc_v1_1.md) – Compiler-Konfiguration

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.1** | **2025-12-05** | **English translation (Language Standards v0.1.1)** |
| **0.1.0 (doc v1)** | **2025-12-04** | **Initial (Clean Start): setup_output_dirs() für bin/ und lib/** |
