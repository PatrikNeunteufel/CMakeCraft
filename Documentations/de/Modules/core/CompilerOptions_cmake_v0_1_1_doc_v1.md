# CompilerOptions.cmake – Dokumentation

> **Version:** 0.1.1 (doc v1)  
> **Datum:** 2025-12-05  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/core/CompilerOptions.cmake  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** master_concept v0.1, guidelines v0.1
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Modules/core/CompilerOptions_cmake_v0_1_0.md)

---

## 1. Übersicht

Das `CompilerOptions.cmake` Modul konfiguriert compiler-spezifische Optionen für Targets. Es unterstützt präzise Compiler-Erkennung und Per-Target Overrides.

---

## 2. Abhängigkeiten

| Modul | Version | Verwendung |
|-------|---------|------------|
| - | - | Keine (Basis-Modul) |

---

## 3. Konzept

### 3.1 Präzise Compiler-Erkennung

```cmake
if(MSVC)                                    # Windows MSVC
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU") # GCC
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    if(APPLE)                               # Apple Clang
    elseif(WIN32)                           # Clang-CL
    else()                                  # Linux Clang
    endif()
endif()
```

### 3.2 Per-Target Override Flags

| Flag | Funktion |
|------|----------|
| `SKIP_STRICT_CONFORMANCE` | MSVC `/permissive-` überspringen |
| `SKIP_NOMINMAX` | `NOMINMAX` nicht definieren |
| `FORCE_EXCEPTIONS` | Exceptions aktiviert lassen |
| `FORCE_RTTI` | RTTI aktiviert lassen |
| `SKIP_CLANG_TIDY` | Clang-Tidy überspringen |

---

## 4. API-Referenz

### apply_compiler_options()

```cmake
apply_compiler_options(TARGET_NAME [FLAGS...])
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| TARGET_NAME | String | CMake Target |
| SKIP_STRICT_CONFORMANCE | Flag | MSVC strict mode überspringen |
| SKIP_NOMINMAX | Flag | min/max Makros erlauben |
| FORCE_EXCEPTIONS | Flag | Exceptions erzwingen |
| FORCE_RTTI | Flag | RTTI erzwingen |
| SKIP_CLANG_TIDY | Flag | Clang-Tidy überspringen |
| SHOW_DEBUG | Flag | Debug-Ausgaben |
| DEBUG_TAG | String | Tag für Debug-Ausgaben |

---

## 5. Verwendungsbeispiele

### Basis-Verwendung

```cmake
apply_compiler_options(MyTarget)
```

**Resultat (MSVC):**
- `/permissive-`
- `/Zc:preprocessor`
- `/Zc:__cplusplus`
- `NOMINMAX`

### Legacy-Code

```cmake
# Strikte Konformität würde Legacy-Code brechen
apply_compiler_options(LegacyApp SKIP_STRICT_CONFORMANCE)
```

### Win32 API

```cmake
# Win32 API nutzt min/max Makros
apply_compiler_options(Win32App SKIP_NOMINMAX)
```

### Externe Library mit Exceptions

```cmake
# Globales NO_EXCEPTIONS=ON, aber diese Library braucht Exceptions
apply_compiler_options(ThirdPartyLib FORCE_EXCEPTIONS)
```

### Tests ohne Clang-Tidy

```cmake
# Clang-Tidy würde Tests langsamer machen
apply_compiler_options(SlowTests SKIP_CLANG_TIDY)
```

### Kombiniert

```cmake
apply_compiler_options(SpecialApp
    SKIP_STRICT_CONFORMANCE
    FORCE_EXCEPTIONS
    SKIP_CLANG_TIDY
)
```

---

## 6. Cache-Variablen

### Globale Optionen

| Variable | Typ | Default | Beschreibung |
|----------|-----|---------|--------------|
| `ENABLE_STRICT_CONFORMANCE` | BOOL | ON | MSVC `/permissive-` |
| `NO_EXCEPTIONS` | BOOL | OFF | `-fno-exceptions` global |
| `NO_RTTI` | BOOL | OFF | `-fno-rtti` global |

### Code-Qualität

| Variable | Typ | Default | Beschreibung |
|----------|-----|---------|--------------|
| `ENABLE_CLANG_TIDY` | BOOL | OFF | Clang-Tidy aktivieren |
| `CLANG_TIDY_STRICT` | BOOL | OFF | Warnings = Errors |

---

## 7. Plattform-Details

### Windows

| Compiler | Erkannt als | Optionen |
|----------|-------------|----------|
| MSVC | `MSVC` | `/permissive-`, `/Zc:*`, `NOMINMAX` |
| MinGW GCC | `GNU` | GCC-Standard |
| Clang-CL | `Clang` + `WIN32` | Wie MSVC |

### Linux

| Compiler | Erkannt als | Optionen |
|----------|-------------|----------|
| GCC | `GNU` | GCC-Standard |
| Clang | `Clang` | Clang-Standard |

### macOS

| Compiler | Erkannt als | Optionen |
|----------|-------------|----------|
| Apple Clang | `Clang` + `APPLE` | Apple-spezifisch |
| Homebrew GCC | `GNU` + `APPLE` | GCC-Standard |

---

## 8. Best Practices

1. **Default = Strict** – Nur bei Bedarf überspringen
2. **Globale Defaults via Cache** – `-DNO_EXCEPTIONS=ON`
3. **Lokale Overrides sparsam** – Nur wo nötig
4. **Clang-Tidy nur für Quality-Checks** – Zu langsam für tägliche Builds

---

## 9. Performance-Impact

### Clang-Tidy

| Konfiguration | Build-Zeit | Faktor |
|---------------|------------|--------|
| Ohne | 1:00 min | 1.0x |
| Mit | 3:30 min | 3.5x |

### NO_EXCEPTIONS/NO_RTTI

| Konfiguration | Binary Size | Performance |
|---------------|-------------|-------------|
| Standard | 2.4 MB | Baseline |
| NO_EXCEPTIONS | 2.1 MB (-12%) | +2% |
| NO_RTTI | 2.3 MB (-4%) | +1% |
| Beide | 2.0 MB (-17%) | +3% |

---

## 10. Siehe auch

- [guidelines](../Concepts/guidelines_v0_1_0.md) – Konventionen
- [CMakePresets_Manual](../References/CMakePresets_Manual_v0_1_0.md) – Presets
- [Warnings.cmake](Warnings_cmake_v0_1_0_doc_v1.md) – Warning-Level

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.1** | **2025-12-05** | **English translation (Language Standards v0.1.1)** |
| **0.1.0 (doc v1)** | **2025-12-03** | **Initial (Clean Start): Inhalte aus v2.0 übernommen, Blueprint-Format, Per-Target Overrides** |
