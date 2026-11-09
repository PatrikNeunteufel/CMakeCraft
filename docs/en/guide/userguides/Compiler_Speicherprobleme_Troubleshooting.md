# Compiler Memory Problems — Troubleshooting Guide

> **Version:** 1.0.0  
> **Date:** 2026-01-01  
> **Type:** Guide  
> **Status:** Stable  
> **Target Audience:** C++ developers  
> **Language:** English  
> **German:** [Compiler_Speicherprobleme_Troubleshooting.md](../../../de/guide/userguides/Compiler_Speicherprobleme_Troubleshooting.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Quick Start](#3-quick-start)
4. [Symptoms](#4-symptoms)
5. [Causes](#5-causes)
6. [Solutions](#6-solutions)
7. [Pitfalls and Solutions](#7-pitfalls-and-solutions)
8. [Troubleshooting](#8-troubleshooting)
9. [See Also](#9-see-also)
10. [Changelog](#10-changelog)

---

## 1. Overview

This guide describes how to diagnose and fix **compiler memory errors** that can occur while building C++/Qt projects.

### Features

- Diagnosis of out-of-memory (OOM) compiler crashes
- Solutions for Clang/MSVC compatibility problems
- Windows page file optimization
- Preventive measures for future builds

### Symptoms

These errors manifest as:

- Compiler crashes while parsing Qt headers
- "Out of Memory" messages during compilation
- Failed builds despite correct source code

---

## 2. Prerequisites

- [ ] Windows 10/11 as the development environment
- [ ] CMake 3.19+ installed
- [ ] Visual Studio 2022 with the C++ workload
- [ ] Administrator rights (for page file changes)
- [ ] At least 10 GB of free disk space on C:

---

## 3. Quick Start

**Problem:** The build fails with "LLVM error: out of memory".

**Fastest solution:** Switch from Clang to MSVC:

```bash
# From Clang...
cmake --preset windows-ninja-debug-clang

# ...switch to MSVC
cmake --preset windows-ninja-debug
cmake --build --preset windows-ninja-debug
```

**Visual Studio:** CMake > Change configuration > `windows-ninja-debug` (without `-clang`)

---

## 4. Symptoms

### 4.1 Typical Error Messages

The following error messages indicate compiler memory problems:

```
LLVM error: out of memory
Allocation failed
Die Auslagerungsdatei ist zu klein
IO failure on output stream: no space on device
Exception Code: 0xC000001D
```

### 4.2 Affected Files

The errors typically occur while parsing these headers:

| Category | Files |
|----------|-------|
| **Qt headers** | `qcompare.h`, `qtmetamacros.h`, `qchar.h`, `qnamespace.h` |
| **STL headers** | `vector`, `unordered_map`, `type_traits` |
| **Libraries** | Qt-ADS modules (`DockManager`, `DockWidget`, etc.) |

### 4.3 Build Log Example

```
[9/44] Building CXX object CMakeFiles/MyViz.Core.dir/.../PulsingVisualizer.cpp.obj
FAILED: CMakeFiles/MyViz.Core.dir/.../PulsingVisualizer.cpp.obj
...
LLVM error: out of memory
Allocation failed
```

---

## 5. Causes

### 5.1 Primary Causes

| Cause | Description | Severity |
|-------|-------------|----------|
| **Clang + MSVC incompatibility** | Clang 18+ has known problems with newer MSVC headers (14.40+). The template-heavy Qt 6.x headers amplify this problem. | High |
| **Parallel compilation** | By default, Ninja starts many parallel compiler processes. Each Clang process can need 2-4 GB of RAM. | Medium |
| **Insufficient paging** | The Windows page file is configured too small. The default is often only 2-4 GB, while build processes can need 16+ GB. | Medium |
| **Disk space** | Less than 10 GB of free space on C: can lead to "no space on device". | Low |

### 5.2 Known Problematic Combinations

| Clang | MSVC Headers | Qt | Status |
|-------|--------------|-----|--------|
| 18.x - 20.x | 14.40+ | 6.7+ | ⚠ Problematic |
| 20.1.8 | 14.50.35717 | 6.10.1 | ⚠ Known to fail |
| MSVC 19.x | 14.50+ | 6.10.1 | ✓ Stable |

---

## 6. Solutions

### 6.1 How Do I Switch from Clang to MSVC? (Recommended)

The most effective fix is switching from Clang to MSVC.

**Command line:**

```bash
# Before (Clang)
cmake --preset windows-ninja-debug-clang
cmake --build --preset windows-ninja-debug-clang

# After (MSVC)
cmake --preset windows-ninja-debug
cmake --build --preset windows-ninja-debug
```

**Visual Studio:**

1. Open CMake > Change configuration
2. Select `windows-ninja-debug` (without `-clang`)
3. Configure and rebuild

> **Note:** On Windows, MSVC is the most stable compiler for Qt projects.

### 6.2 How Do I Reduce the Parallel Jobs?

If you have to keep Clang:

```bash
# Only 2 parallel compilations (saves RAM)
cmake --build --preset windows-ninja-debug-clang -- -j2

# Single-threaded (slow but stable)
cmake --build --preset windows-ninja-debug-clang -- -j1
```

**Recommendation:** Start with `-j2` and increase step by step.

### 6.3 How Do I Increase the Windows Page File?

1. Press `Windows + Pause` → **System** → **Advanced system settings**
2. Select **Advanced** → **Performance** → **Settings**
3. Select **Advanced** → **Virtual memory** → **Change**
4. Disable **"Automatically manage paging file size for all drives"**
5. Select **Custom size**:
   - Initial size: `8192` MB
   - Maximum size: `16384` MB
6. Click **Set** → **OK**
7. **Restart required**

> **Note:** For large C++/Qt projects we recommend a page file of at least 16 GB.

### 6.4 How Do I Check the Disk Space?

**PowerShell:**

```powershell
# Check free space
Get-PSDrive C | Select-Object Used, Free

# Delete the build folder (if < 10 GB free)
Remove-Item -Recurse -Force .\out\build\
```

**Minimum requirement:** 10 GB of free space on C:

---

## 7. Pitfalls and Solutions

### 7.1 Build Does Not Work After Switching Presets

**Problem:** After switching from Clang to MSVC, strange errors appear.

**Cause:** The CMake cache still contains the Clang configuration.

**Solution:** Delete the build folder completely:

```bash
# Delete the old cache
Remove-Item -Recurse -Force .\out\build\windows-ninja-debug\

# Configure again
cmake --preset windows-ninja-debug
```

### 7.2 Error Returns After Increasing the Page File

**Problem:** The error occurs again despite the increased page file.

**Cause:** The restart was not performed.

**Solution:** Windows must be restarted after page file changes.

### 7.3 "no space on device" Despite Free Space

**Problem:** The disk shows 50 GB free, but the build reports "no space".

**Cause:** The page file and TEMP folder are on C:, the build project is on D:.

**Solution:** Check the space on **C:**, not on the project drive:

```powershell
Get-PSDrive C | Select-Object Used, Free
```

---

## 8. Troubleshooting

### 8.1 Diagnostic Checklist

- [ ] Check RAM usage during the build (Task Manager > Performance)
- [ ] Free disk space on C: > 10 GB?
- [ ] Check the Clang version (`clang --version`)
- [ ] Check the MSVC version (`cl.exe`)
- [ ] Check the Qt version (`qmake --version`)
- [ ] Check the page file size (system properties)

### 8.2 Common Errors and Solutions

| Error | Possible cause | Solution |
|-------|----------------|----------|
| `LLVM error: out of memory` | Clang + Qt incompatibility | Switch to MSVC |
| `Die Auslagerungsdatei ist zu klein` | Page file too small | Increase the page file to 16 GB |
| `no space on device` | Disk full | Free up space on C: |
| `Exception Code: 0xC000001D` | Compiler crash | Reduce parallel jobs (`-j2`) |
| Build hangs without an error | RAM exhausted | Check Task Manager, reduce jobs |

### 8.3 Diagnostic Commands

```powershell
# System info (search strings for a German-language Windows)
systeminfo | findstr /B /C:"Gesamter physischer Speicher" /C:"Verfügbarer physischer Speicher"

# Disk space
Get-PSDrive C, D | Select-Object Name, Used, Free

# Compiler versions
clang --version
cl.exe 2>&1 | Select-String "Version"

# Running compiler processes
Get-Process | Where-Object { $_.Name -match "clang|cl" }
```

---

## 9. See Also

- [CMake_Standard.md](../../autorenwerk/standards/CMake_Standard.md) — CMake coding standards
- [Cpp_Coding_Standard.md](../../autorenwerk/standards/Cpp_Coding_Standard.md) — C++ coding standards
- [Qt6 Integration Guide](Qt6_Integration.md) — Qt6 setup and configuration

### External Resources

- [Clang Compatibility Notes](https://clang.llvm.org/docs/MSVCCompatibility.html)
- [Qt Documentation](https://doc.qt.io/)
- [CMake Presets](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html)

---

## 10. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2026-01-01** | **Initial: diagnosis and solutions for Clang/MSVC OOM errors** |
