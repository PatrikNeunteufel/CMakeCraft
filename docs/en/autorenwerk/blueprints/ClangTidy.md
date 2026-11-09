# ClangTidy Blueprint – Static Analysis

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Blueprint  
> **Status:** In Development (Pre-Release)  
> **Scope:** All `.clang-tidy` configurations  
> **Related to:** Cpp_Coding_Standard v0.1, C_Coding_Standard v0.1, ClangFormat_Blueprint v0.1  
> **Language:** English  
> **German:** [ClangTidy.md](../../../de/autorenwerk/blueprints/ClangTidy.md)

---

## 1. Purpose

This blueprint defines the **structure and maintenance** of the `.clang-tidy` configuration.

**What this document is:**
- Conceptual basis for static analysis
- Definition of the check categories and profiles
- Explanation of the naming conventions

**What this document is not:**
- The technical configuration itself (→ `.clang-tidy` file)

---

## 2. Relationship to Other Standards

| Document | Defines |
|----------|-----------|
| **Cpp_Coding_Standard** | Structural and language rules |
| **C_Coding_Standard** | Embedded-specific rules |
| **`.clang-tidy`** | Technical enforcement |

### Conflict Resolution

| Conflict type | Priority |
|-------------|-----------|
| Formatting | `.clang-format` wins |
| Naming/static rules | `.clang-tidy` wins |
| Architecture/functional | Written standard wins |

---

## 3. Philosophy and Strategy

### 3.1 Goals

- Detect bugs early
- Improve code clarity
- Responsible modernization (no style wars)
- Enforce naming consistency
- MISRA/CERT alignment where sensible

### 3.2 Profiles

| Profile | Purpose | Usage |
|--------|-------|------------|
| **Dev-Gentle** | Everyday development | Default |
| **Dev-Strict** | Stricter checks | Before merge |
| **CI-Strict** | Pull requests / merge gates | CI pipeline |
| **API-Gate** | Public libraries | Highest level |

**Current default profile:** `Dev-Gentle`

### 3.3 Responsibility

- `.clang-tidy` is maintained centrally by architecture/tooling
- Projects can propose changes
- No careless forks

---

## 4. Naming Conventions

Enforced via `readability-identifier-naming`.

### 4.1 C++ (PC Applications)

| Entity | Convention | Example |
|---------|------------|----------|
| Namespace | `lower_case` | `audio`, `core_utils` |
| Class/struct/enum | `CamelCase` | `LogManager`, `AudioBuffer` |
| Enum constant | `CamelCase` | `LogLevelInfo`, `ColorRed` |
| Function/method | `camelBack` | `writeLog()`, `openFile()` |
| Parameter | `camelBack` | `filePath`, `bufferSize` |
| Local variable | `camelBack` | `currentIndex`, `tempValue` |
| Member variable | `m_` prefix | `m_buffer`, `m_logger` |
| Global constant | `UPPER_CASE` | `MAX_BUFFER_SIZE` |
| Global variable | `g_` prefix | `g_logger` |
| Static internal variable | `s_` prefix | `s_cache` |
| Macro | `UPPER_CASE` | `DEBUG_LOG` |

### 4.2 C (Embedded)

| Entity | Convention | Example |
|---------|------------|----------|
| Module function | `modul_snake_case` | `timer_init()`, `gpio_set()` |
| Type alias | `CamelCase` or `snake_case` | `TimerHandle`, `gpio_pin_t` |
| Local variable | `snake_case` | `current_state` |
| Global variable | `g_` prefix | `g_systemState` |
| Static variable | `s_` prefix | `s_bufferIndex` |
| Constant/macro | `UPPER_CASE` | `ADC_TIMEOUT_TICKS` |

---

## 5. Check Categories

### 5.1 Enabled Check Groups

| Group | Purpose | Priority |
|--------|-------|-----------|
| `clang-analyzer-*` | UB, leaks, null deref | **Critical** |
| `bugprone-*` | Logic errors | **Critical** |
| `performance-*` | Inefficient patterns | High |
| `readability-*` | Readability, naming | Medium |
| `modernize-*` | C++ modernization | Medium |

### 5.2 Handling Warnings

| Check type | Requirement |
|-----------|-------------|
| `clang-analyzer-*`, `bugprone-*` | **Must be fixed** or suppressed with justification |
| `modernize-*` | Assess case by case, no obligation |
| `performance-*` | Enabled where clarity does not suffer |

### 5.3 Disabled Checks

The following checks are disabled in the Dev-Gentle profile (too much noise):

- `modernize-use-trailing-return-type` – A matter of style
- `modernize-use-auto` – Explicit types are often more readable
- `readability-implicit-bool-conversion` – Too strict
- `readability-identifier-naming` – Can optionally be enabled

---

## 6. Magic Numbers

### 6.1 Allowed Values

Tolerated automatically:
- `-1`, `0`, `1`, `2`
- All powers of two (for bit masks, alignment)

### 6.2 Recommendation

Domain values (e.g. `44100` Hz, `2.2` gamma) should be named as `constexpr` or `enum`:

```cpp
// ❌ Magic number
setSampleRate(44100);

// ✅ Named constant
constexpr int SAMPLE_RATE_CD = 44100;
setSampleRate(SAMPLE_RATE_CD);
```

---

## 7. Value Parameter Optimization

Certain types may be passed by value:

- `std::string_view`
- `std::span`
- `std::optional`

This matches modern C++ guidelines and avoids unnecessary indirection.

---

## 8. Change Management

### 8.1 When to Change?

Changes only if:
- A rule repeatedly causes justified suppressions
- A rule conflicts with platform/embedded constraints
- A new rule improves safety or clarity

### 8.2 Process

1. **Proposal:** Motivation, categories, example warnings
2. **Review:** Tooling/architecture approval
3. **Implementation:** Update `.clang-tidy` and the version tag
4. **Documentation:** For a conceptual change, update the blueprint

### 8.3 File Header

```yaml
# C/C++ clang-tidy configuration
# Version: 0.1.0
# Blueprint: docs/de/autorenwerk/blueprints/ClangTidy.md
# Profile: Dev-Gentle
# Date: 2025-12-05
```

---

## 9. Integration into CI and Development

| Context | Usage |
|---------|------------|
| IDE (on-save) | Optional, Dev-Gentle |
| Pre-commit | Optional |
| CI pipeline | Recommended, Dev-Strict or CI-Strict |

### Profiles via CLI

```bash
# Dev-Strict (warnings as errors for analyzer/bugprone)
clang-tidy -warnings-as-errors=clang-analyzer-*,bugprone-* ...

# API-Gate (all warnings as errors)
clang-tidy -warnings-as-errors=* ...
```

---

## 10. Third-Party Code

### Header Filter

```yaml
HeaderFilterRegex: '^(?!.*[/\\](external|third_party|deps)[/\\]).*'
```

### Sources

Third-party sources are excluded via CMake:

```cmake
# No clang-tidy for externals
set_target_properties(ThirdPartyLib PROPERTIES
    CXX_CLANG_TIDY ""
)
```

---

## 11. See Also

- [Cpp_Coding_Standard](../standards/Cpp_Coding_Standard.md) – C++ style guidelines
- [C_Coding_Standard](../standards/C_Coding_Standard.md) – C style guidelines
- [ClangFormat_Blueprint](ClangFormat.md) – Formatting

---

## Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: header pattern points to today's path `docs/de/autorenwerk/blueprints/ClangTidy.md`** |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| 0.1.0 | 2025-12-05 | Initial: profiles, check categories, naming conventions |
