# Warnings.cmake – Dokumentation

> **Version:** 0.1.1 (doc v1)  
> **Datum:** 2025-12-05  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/core/Warnings.cmake  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Modules/core/Warnings_cmake_v0_1_0.md)

---

## 1. Übersicht

Das `Warnings.cmake` Modul konfiguriert **compiler-spezifische Warning-Level** für Targets. Es aktiviert hohe Warnstufen um Code-Qualität zu fördern.

**Kernidee:** Einheitliche, hohe Warnstufen für alle Targets – konsistent über alle Compiler hinweg.

---

## 2. Abhängigkeiten

| Modul | Version | Verwendung |
|-------|---------|------------|
| - | - | Keine (Standalone-Modul) |

---

## 3. Konzept

### 3.1 Compiler-spezifische Flags

| Compiler | Flags | Beschreibung |
|----------|-------|--------------|
| MSVC | `/W4` | Hohe Warnstufe |
| GCC | `-Wall -Wextra -Wpedantic` | Standard + Extra + Pedantic |
| Clang | `-Wall -Wextra -Wpedantic` | Wie GCC |

### 3.2 Warning-Level (MSVC)

| Level | Bedeutung |
|-------|-----------|
| `/W0` | Keine Warnungen |
| `/W1` | Nur schwere |
| `/W2` | Signifikante |
| `/W3` | Produktions-Qualität |
| `/W4` | Informative (empfohlen) ✅ |
| `/Wall` | Alle (sehr viele!) |

### 3.3 Warning-Flags (GCC/Clang)

| Flag | Bedeutung |
|------|-----------|
| `-Wall` | "All" (wichtigste Warnungen) |
| `-Wextra` | Zusätzliche Warnungen |
| `-Wpedantic` | Strikte ISO-C++ Konformität |

---

## 4. API-Referenz

### apply_warnings()

Setzt Warning-Level für ein Target.

```cmake
apply_warnings(<TARGET_NAME>)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| TARGET_NAME | String | CMake Target |

**Beispiel:**

```cmake
add_executable(MyApp main.cpp)
apply_warnings(MyApp)
```

---

## 5. Verwendungsbeispiele

### 5.1 Einfache Anwendung

```cmake
add_executable(MyApp main.cpp)
apply_warnings(MyApp)
```

### 5.2 In der Executable-Pipeline

```cmake
function(_create_executable_target CTX)
    ctx_get(${CTX} NAME _name)
    
    add_executable(${_name} ${_sources})
    setup_output_dirs(${_name})
    apply_warnings(${_name})           # ← Warnungen
    apply_compiler_options(${_name})   # ← Weitere Optionen
endfunction()
```

### 5.3 Third-Party-Code ausschließen

```cmake
# Eigener Code mit Warnungen
add_library(MyLib ...)
apply_warnings(MyLib)

# Third-Party ohne strikte Warnungen
add_library(ThirdParty ...)
if(MSVC)
    target_compile_options(ThirdParty PRIVATE /W0)
else()
    target_compile_options(ThirdParty PRIVATE -w)
endif()
```

---

## 6. Erweiterungen

### 6.1 Zusätzliche Warnungen

```cmake
# Nach apply_warnings() weitere hinzufügen
apply_warnings(MyApp)

if(NOT MSVC)
    target_compile_options(MyApp PRIVATE
        -Wshadow           # Variable überdeckt andere
        -Wconversion       # Implizite Konvertierungen
        -Wnon-virtual-dtor # Nicht-virtuelle Destruktoren
    )
endif()
```

### 6.2 Spezifische Warnungen deaktivieren

```cmake
apply_warnings(LegacyApp)

if(MSVC)
    target_compile_options(LegacyApp PRIVATE 
        /wd4996  # Deprecated ignorieren
        /wd4100  # Unused parameter
    )
else()
    target_compile_options(LegacyApp PRIVATE 
        -Wno-unused-parameter
        -Wno-deprecated
    )
endif()
```

### 6.3 Warnings as Errors (CI)

```cmake
# In CompilerOptions.cmake oder separat
if(WARNINGS_AS_ERRORS)
    if(MSVC)
        target_compile_options(${TARGET} PRIVATE /WX)
    else()
        target_compile_options(${TARGET} PRIVATE -Werror)
    endif()
endif()
```

**Aktivierung:**
```bash
cmake -B build -DWARNINGS_AS_ERRORS=ON
```

---

## 7. Typische Warnungen

### C4996 (MSVC) - Deprecated

```cpp
// Warning
strcpy(dest, src);

// Fix
strcpy_s(dest, sizeof(dest), src);
```

### -Wunused-parameter

```cpp
// Warning
void foo(int x) { }

// Fix (C++17)
void foo([[maybe_unused]] int x) { }
```

### -Wshadow

```cpp
int x = 5;
void foo() {
    int x = 10;  // Warning: shadows outer 'x'
}
```

---

## 8. Best Practices

### 8.1 Immer hohe Warnstufen

```cmake
# ✅ Gut
apply_warnings(MyApp)

# ❌ Schlecht - keine Warnungen
```

### 8.2 Warnungen beheben, nicht unterdrücken

```cmake
# ✅ Gut - Code reparieren

# ❌ Schlecht - nur unterdrücken ohne Grund
target_compile_options(MyApp PRIVATE /wd4996)
```

### 8.3 CI mit Warnings as Errors

```yaml
# .github/workflows/ci.yml
- name: Configure
  run: cmake -B build -DWARNINGS_AS_ERRORS=ON
```

---

## 9. Beziehung zu CompilerOptions.cmake

| Modul | Verantwortung |
|-------|---------------|
| **Warnings.cmake** | Warning-Level (`/W4`, `-Wall`) |
| **CompilerOptions.cmake** | Alles andere (Conformance, RTTI, Clang-Tidy) |

**Reihenfolge:**
```cmake
apply_warnings(${_name})           # 1. Warnungen
apply_compiler_options(${_name})   # 2. Weitere Optionen
```

---

## 10. Siehe auch

- [CompilerOptions.cmake](CompilerOptions_cmake_v0_1_0_doc_v1_1.md) – Erweiterte Compiler-Konfiguration
- [guidelines](../Concepts/guidelines_v0_1_0.md) – Coding-Konventionen

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.1** | **2025-12-05** | **English translation (Language Standards v0.1.1)** |
| **0.1.0 (doc v1)** | **2025-12-04** | **Initial (Clean Start): apply_warnings() für MSVC/GCC/Clang** |
