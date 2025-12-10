# Fetch.cmake – Dokumentation

> **Version:** 0.1.0 (doc v1)  
> **Datum:** 2025-12-09  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/externals/Core/Fetch.cmake  
> **Modul-Version:** 0.1.0  
> **Basiert auf:** master_concept v0.1, guidelines v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Modules/Externals/Fetch_cmake_v0_1_0.md)

---

## 1. Übersicht

Das `Fetch.cmake` Modul ist ein Wrapper um CMakes `FetchContent`. Es vereinfacht das Deklarieren und Laden von Git-basierten Externals.

### Verantwortlichkeiten

- FetchContent_Declare() kapseln
- Git-Repository-Parameter validieren
- Shallow Clone optimieren
- Status-Abfragen bereitstellen

---

## 2. Abhängigkeiten

| Modul | Version | Verwendung |
|-------|---------|------------|
| FetchContent | CMake 3.11+ | Built-in CMake Modul |
| Errors.cmake | 0.1+ | Fehlerbehandlung |
| Debug.cmake | 0.1+ | Debug-Ausgaben |

---

## 3. Konzept

### 3.1 FetchContent Workflow

```
1. FetchContent_Declare()  → Repository definieren
2. FetchContent_MakeAvailable() → Download + Configure
3. Zugriff auf ${name}_SOURCE_DIR
```

### 3.2 Shallow Clone Strategie

| Versionsreferenz | Shallow Clone | Begründung |
|------------------|---------------|------------|
| `tag` | ✅ Ja | Tag ist stabil, nur ein Commit nötig |
| `branch` | ✅ Ja | Branch-HEAD reicht |
| `commit` | ❌ Nein | Volle Historie für Commit-Hash nötig |

---

## 4. API-Referenz

### 4.1 _fetch_git_external()

Deklariert ein Git-External für FetchContent.

```cmake
_fetch_git_external(NAME GIT_URL [TAG tag] [BRANCH branch] [COMMIT commit])
```

**Parameter:**

| Parameter | Typ | Pflicht | Beschreibung |
|-----------|-----|---------|--------------|
| NAME | String | ✅ | External-Name |
| GIT_URL | String | ✅ | Git Repository URL |
| TAG | String | ❌* | Git Tag (z.B. "v1.0.0") |
| BRANCH | String | ❌* | Git Branch (z.B. "main") |
| COMMIT | String | ❌* | Git Commit Hash |

*Genau **eines** von TAG, BRANCH oder COMMIT muss angegeben werden.

**Beispiel:**

```cmake
_fetch_git_external(glfw 
    "https://github.com/glfw/glfw.git"
    TAG "3.4"
)

_fetch_git_external(spdlog
    "https://github.com/gabime/spdlog.git"
    BRANCH "v1.x"
)

_fetch_git_external(json
    "https://github.com/nlohmann/json.git"
    COMMIT "bc889afb4c5bf1c0d8ee29ef35eaaf4c8bef8a5d"
)
```

---

### 4.2 _make_external_available()

Lädt das External (Download + CMake Configure).

```cmake
_make_external_available(NAME)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| NAME | String | External-Name (wie bei _fetch_git_external) |

**Beispiel:**

```cmake
_fetch_git_external(glfw "https://..." TAG "3.4")
_make_external_available(glfw)

# Jetzt existiert ${glfw_SOURCE_DIR}
```

---

### 4.3 _is_external_populated()

Prüft ob ein External bereits geladen wurde.

```cmake
_is_external_populated(NAME OUT_VAR)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| NAME | String | External-Name |
| OUT_VAR | Output | Boolean-Ergebnis |

**Beispiel:**

```cmake
_is_external_populated(glfw _populated)
if(_populated)
    message(STATUS "GLFW already downloaded")
endif()
```

---

### 4.4 _get_external_source_dir()

Gibt das Source-Verzeichnis eines geladenen Externals zurück.

```cmake
_get_external_source_dir(NAME OUT_VAR)
```

**Parameter:**

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| NAME | String | External-Name |
| OUT_VAR | Output | Pfad zum Source-Verzeichnis |

**Beispiel:**

```cmake
_get_external_source_dir(imgui _src_dir)
# _src_dir = /path/to/build/_deps/imgui-src
```

---

## 5. Fehlerbehandlung

| Code | Kategorie | Beschreibung |
|------|-----------|--------------|
| E012 | VALIDATION | Mehr als eine Versionsreferenz angegeben |
| E202 | EXTERNAL | Download fehlgeschlagen |
| E215 | EXTERNAL | Keine Versionsreferenz (tag/branch/commit) |

### 5.1 Beispiel: E012

```cmake
# FALSCH: Sowohl TAG als auch BRANCH
_fetch_git_external(lib "https://..." TAG "v1.0" BRANCH "main")
```

**Fehlermeldung:**
```
CMake Error: [E012] Multiple version references for 'lib'. 
Specify exactly one of: tag, branch, commit
```

---

## 6. Verwendungsbeispiele

### 6.1 Standard Tag-basiert

```cmake
_fetch_git_external(glfw
    "https://github.com/glfw/glfw.git"
    TAG "3.4"
)
_make_external_available(glfw)
# Target 'glfw' ist verfügbar
```

### 6.2 Branch für Bleeding-Edge

```cmake
_fetch_git_external(imgui
    "https://github.com/ocornut/imgui.git"
    BRANCH "docking"
)
_make_external_available(imgui)
```

### 6.3 Spezifischer Commit

```cmake
_fetch_git_external(mylib
    "https://github.com/user/mylib.git"
    COMMIT "abc123def456"
)
_make_external_available(mylib)
```

---

## 7. Internes

### 7.1 Generierte FetchContent_Declare

```cmake
# _fetch_git_external(glfw "https://..." TAG "3.4")
# generiert:

FetchContent_Declare(glfw
    GIT_REPOSITORY "https://github.com/glfw/glfw.git"
    GIT_TAG "3.4"
    GIT_SHALLOW ON
)
```

### 7.2 Shallow Clone Deaktivierung

Bei Commit-Hash wird Shallow Clone deaktiviert:

```cmake
# _fetch_git_external(lib "https://..." COMMIT "abc123")
# generiert:

FetchContent_Declare(lib
    GIT_REPOSITORY "https://..."
    GIT_TAG "abc123"
    GIT_SHALLOW OFF  # Volle Historie nötig
)
```

---

## 8. Best Practices

1. **Tags bevorzugen** – Stabil und reproduzierbar
2. **Keine Master/Main Branches** – Ändern sich ständig
3. **Commit nur wenn nötig** – Langsamer wegen voller Historie
4. **Semantic Versioning Tags** – z.B. "v1.2.3"

---

## 9. Bekannte Einschränkungen

- Keine Submodule-Unterstützung
- Keine LFS-Unterstützung
- Keine Authentifizierung für private Repos (in dieser Version)

---

## 10. Siehe auch

- [Handler.cmake](Handler_cmake_v0_1_0_doc_v1.md) – Verwendet Fetch.cmake
- [Orchestrator.cmake](Orchestrator_cmake_v0_2_0_doc_v1.md) – Koordination
- [CMake FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html) – CMake Doku

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0 (doc v1)** | **2025-12-09** | **Initial: FetchContent-Wrapper, Git-Validierung, Shallow Clone** |
