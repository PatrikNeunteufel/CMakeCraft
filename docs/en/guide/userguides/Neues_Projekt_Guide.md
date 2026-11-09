# New Project with CMakeCraft — Operating Instructions

> **Version:** 1.4.2
> **Date:** 2026-11-09
> **Type:** Guide
> **Status:** Draft
> **Target Audience:** Developers who set up a new, standalone project repo based on CMakeCraft
> **Language:** English
> **German:** [Neues_Projekt_Guide.md](../../../de/guide/userguides/Neues_Projekt_Guide.md)

---

## Table of Contents

1. [Overview & Division of Roles](#1-overview--division-of-roles)
2. [Prerequisites](#2-prerequisites)
3. [Creating a New Project — Step by Step](#3-creating-a-new-project--step-by-step)
4. [Externals & Proprietary Libraries (BASS & Co.)](#4-externals--proprietary-libraries-bass--co)
5. [Extending or Correcting CMakeCraft](#5-extending-or-correcting-cmakecraft)
6. [What Is Versioned Where?](#6-what-is-versioned-where)
7. [Troubleshooting](#7-troubleshooting)
8. [See Also](#8-see-also)

---

## 1. Overview & Division of Roles

CMakeCraft is the **toolbox**, your project is the **workpiece**. This leads to the most
important rule of this guide:

> **The project (e.g. LumiViz) is versioned in its own repo.
> CMakeCraft is versioned separately in its own repo and is the
> single source of truth (SSOT) for all `cmake/` modules.
> The project carries only the version (`cmakecraft.pin`); the build system is fetched
> in that version during configure.**

| Role | Repo | Contains | Changes through |
|---|---|---|---|
| **Build system** | `CMakeCraft/` | `cmake/` (core, project, externals, buildSystemTest), `templates/`, build system docs | Build system development (own commits/tags) |
| **Project** | e.g. `LumiViz/` | `Solution.json`, `projects/`, `externals/`, presets, app docs — **plus `CMakeCraftBootstrap.cmake` and `cmakecraft.pin`** | Project development; build system only via a pin change (§5) |

> **Consumption (since v0.7.0, 2026-07-18):** **bootstrap fetch** — the project only commits
> `CMakeCraftBootstrap.cmake` + `cmakecraft.pin` (version); the build system is fetched into
> `.externals/cmakecraft/<version>/` during configure. The former snapshot procedure (a `cmake/`
> copy in the project) is thereby replaced (concept: `docs/de/konzepte/Konzept_Versionierter_Bezug.md`).

---

## 2. Prerequisites

- **CMake ≥ 3.26**, a C++20 compiler (MSVC, Clang), **Ninja** and/or Visual Studio 2022+
- **Git**
- Optional, depending on the project: **Qt6** (path for `QT_ROOT`), further SDKs
- A local **CMakeCraft working copy** (this repo)

---

## 3. Creating a New Project — Step by Step

### Step 1: Project Folder and Git Repo

```bash
mkdir MeinProjekt && cd MeinProjekt
git init
```

### Step 2: Take Over the Bootstrap Files (NO cmake/ Snapshot Anymore)

The three bootstrap files (`CMakeCraftBootstrap.cmake`, `cmakecraft.pin`, `CMakeLists.txt`) are
provided as templates in CMakeCraft under [`templates/consumer/`](../../../../templates/consumer/) —
copy them from there into the project root. The other mandatory files in the table come from the
CMakeCraft root or are created for the project:

| File | Purpose | Required? |
|---|---|---|
| `CMakeCraftBootstrap.cmake` | fetches CMakeCraft in the pinned version into `.externals/` — take over **unchanged** | ✅ |
| `cmakecraft.pin` | **the** version specification (tag) + sources (GitHub URL, local fallbacks) | ✅ |
| `CMakeLists.txt` | thin version (see below) | ✅ |
| `CMakePresets.json` | project presets (copy from CMakeCraft) | ✅ |
| `.gitignore`, `.gitattributes` | including the deliberate externals rules (§4!) | ✅ |
| `clang-format`, `clang-tidy` | code conventions | recommended |
| `templates/` + `templates/Solution.json` | templates for apps/Source.cmake/Solution | recommended |

The complete top-level `CMakeLists.txt` of a consumer:

```cmake
cmake_minimum_required(VERSION 3.26)
project(MeinProjekt LANGUAGES NONE)   # name/version come from Solution.json
include("${CMAKE_CURRENT_LIST_DIR}/CMakeCraftBootstrap.cmake")
```

The line `project(... LANGUAGES NONE)` is mandatory (since v0.13.0, otherwise E005). Without it,
CMake inserts its own `project()` **before** `cmake_minimum_required()` and sets up the compilers
under old rules: `CMAKE_MSVC_RUNTIME_LIBRARY` does not take effect, and the `Testing`
configuration builds with the static CRT. Name and version are still set by CMakeCraft from
Solution.json. Anyone adding the line to an existing project configures once with `--fresh`.

### Step 3: Pin the Version

Enter the desired CMakeCraft version (Git tag) in `cmakecraft.pin` — this is the
**only** place where the build system version is stated:

```cmake
set(CMAKECRAFT_VERSION "v0.14.1")
set(CMAKECRAFT_GIT_URL "https://github.com/PatrikNeunteufel/CMakeCraft.git")
set(CMAKECRAFT_FALLBACK_PATHS "../CMakeCraft")
```

For **build system development** against a working copy (without clone/tag):
configure with `-DCMAKECRAFT_LOCAL_DIR=../CMakeCraft`.

### Step 4: Create User Presets (Local, Do Not Commit)

`CMakeUserPresets.json` contains **machine-specific** paths (e.g. `QT_ROOT`) and therefore
does not belong in the repo — commit a `CMakeUserPresets.example.json` as a template instead:

```jsonc
// CMakeUserPresets.json (local)
{
  "version": 6,
  "configurePresets": [
    {
      "name": "user-paths", "hidden": true,
      "environment": { "QT_ROOT": "C:/Qt/6.10.1/msvc2022_64" }
    }
  ]
}
```

Details: [CMakeUserPresets.md](CMakeUserPresets.md)

### Step 5: Set Up Solution.json

Solution.json is the core — **what is not in it does not exist**. Minimal:

```jsonc
{
  "schemaVersion": "1.0",
  "solution": { "name": "MeinProjekt", "version": "0.1.0" },
  "settings": {
    "standards": { "cxx_standard": 20 },
    "sources": { "mode": "explicit" }
  },
  "externals": { },
  "libraries": [ ],
  "executables": [ ],
  "apps": [ ]
}
```

Under MSVC, every target compiles its files with 8 parallel compilers (`/MP8`, since
v0.12.0) — without any entry. A different number or `0` (off) goes into
`"settings": { "msvc": { "parallel_compile": 16 } }` and applies to the whole solution
([Solution_Schema.md §4.4](../references/Solution_Schema.md#44-msvc)).

Reference of all fields: [Solution_Schema.md](../references/Solution_Schema.md) ·
Cheatsheet: [Solution_Cheatsheet.md](../cheatsheets/Solution_Cheatsheet.md)

### Step 6: First App / First Executable

- **App container** (core lib + runner + tests + PCH): [App_Creation_Guide.md](App_Creation_Guide.md)
  — the starting point is a copy of `templates/App/` to `projects/apps/<Name>/`.
- **Simple executable / library**: [Getting_Started.md](Getting_Started.md), sections 6–7.
- **Source lists are explicit**: enter every new file in the corresponding `Source.cmake`
  (`list(APPEND …)`, never glob) — for the format see [templates/README.md](../../../../templates/README.md).

### Step 7: Configure and Build

```bash
cmake --preset windows-vs-x64-debug_dynamic   # or: windows-ninja-debug-msvc / windows-ninja-release-clang
cmake --build --preset build-vs-x64-Debug   # matching: build-ninja-debug-msvc / build-ninja-release-clang
```

During the first configure, Git externals (if declared) are fetched into `.externals/` —
this needs a network connection once. Build outputs end up under `out/`.

### Step 8: First Commit

```bash
git add .
git commit -m "chore: project setup with CMakeCraft <version> (cmakecraft.pin)"
```

Checklist of what must **not** be contained in the first commit: `out/`, `.externals/`,
`CMakeUserPresets.json`, proprietary binaries (§4). The copied `.gitignore` takes care of this —
**do not loosen it** (§4).

---

## 4. Externals & Proprietary Libraries (BASS & Co.)

### 4.1 The Four Externals Sources

| Source | Declaration in Solution.json | Example |
|---|---|---|
| **local** | `"path": "externals/<name>"` — lives in the project repo | doctest, bass (SDK structure), glad, lua54 |
| **fetched** | `"git": "<url>", "tag": "…"` — fetched into `.externals/` during configure | qt-ads, googletest |
| **system** | `"system": true, "package": "…"` — via find_package | Qt6, onnxruntime |
| **archive** | `"archive": true, "pin": "<name>.pin"` — finished package in a pinned version, fetched into `.externals/<name>/<version>/` during configure (since v0.10.0) | sichttest |

How to integrate: [Adding_Externals.md](Adding_Externals.md) · [Externals.md](Externals.md) ·
Building and obtaining packages: [Packages.md](../references/Packages.md)

### 4.2 Proprietary Binaries: Deliberately NOT in the Repo

For libraries that require a license (namely **BASS**, un4seen) the following applies:

- **Tracked:** the SDK *structure* (headers, example sources, docs) under `externals/bass/`.
- **Deliberately untracked:** all *binaries* — import libs (`win/c/x64/*.lib`), DLLs (`win/x64/`),
  Linux libs (`linux/libs/`), example EXEs (`bin/`). The .gitignore rules `x64/`, `x86/`,
  `[Bb]in/` keep them out. **This is intentional (license) — never "repair" it via `!externals/**`
  and never commit them.**

**Consequence:** A fresh clone/checkout only builds once the binaries have been obtained locally.
The typical error looks like this:

```
…/externals/bass/bass24/win/c/x64/bass.lib', needed by '…', missing and no known rule to make it
```

### 4.3 Obtaining Binaries When Needed

**Variant A — copy from an existing working copy** (takes over exactly the
ignored files in the correct structure):

```bash
cd <funktionierende-Arbeitskopie>
git ls-files -o -i --exclude-standard -z -- externals \
  | tar --null -cf - -T - | (cd <neues-Projekt> && tar -xf -)
```

**Variant B — download from un4seen.com:** download the ZIP for each required add-on and unpack
it into the existing SDK structure. What goes where and which packages a project needs
is described in the `externals/bass/SETUP.md` of the respective project
(template: [LumiViz/externals/bass/SETUP.md](../../../../../LumiViz/externals/bass/SETUP.md)).

**Rules for new projects with BASS:**
1. Take over the SDK structure from an existing project or from un4seen and commit it
   (without binaries — the .gitignore takes care of that).
2. Copy/adapt `externals/bass/SETUP.md` as well and **commit** it, so that every
   fresh checkout explains itself.
3. Obtain the binaries locally via variant A or B.
4. Declare it in Solution.json, e.g. `"bass": { "path": "externals/bass" }` and in the
   app block `"external_options": { "bass": { "BASS_FLAC": true } }`.

---

## 5. Extending or Correcting CMakeCraft

Sooner or later a project needs something that CMakeCraft cannot do (yet) — a new
external include, a fetch hook, a fix in a core module. **The reflex "I'll quickly change
the cmake/ file in the project" is the beginning of divergence** — this is exactly how
project and template states drifted apart in the past. Therefore:

### 5.1 Standard Path (Extension/Correction)

```
Change CMakeCraft → test against the project → commit + tag → bump the pin
```

1. **Change it in the CMakeCraft working copy** (the only permissible place — the project no
   longer contains any build system code).
2. **Test:**
   ```bash
   # Self-test of the build system (in the CMakeCraft repo):
   cmake --preset craft-selftest
   # build the requesting project DIRECTLY against the working copy (no clone/tag needed):
   cmake --preset <projekt-preset> -DCMAKECRAFT_LOCAL_DIR=../CMakeCraft
   ```
3. **Commit in CMakeCraft and set a tag** (e.g. `v0.7.1`) — consumers pin tags.
4. **Bump the pin in the project:** enter the new version in `cmakecraft.pin`,
   clear `CMAKECRAFT_LOCAL_DIR` again (delete the cache variable or set it to ""),
   configure checks the fresh clone. Commit:
   ```
   chore(buildsystem): CMakeCraft v0.7.1 — <was die Version bringt>
   ```

### 5.2 Emergency Path (Fix Comes Up in the Middle of Project Work)

1. Make the fix in the CMakeCraft **working copy** and continue working in the project immediately
   with `-DCMAKECRAFT_LOCAL_DIR=../CMakeCraft` — no waiting for a tag/release.
2. As soon as the fix is done: commit in CMakeCraft, set a tag, bump the pin (§5.1 steps 3–4).
3. **Never** commit/finish with a permanently set `CMAKECRAFT_LOCAL_DIR` — the override
   is a working state, not a project state (it deliberately lives only in the CMake cache, never in the repo).
   Temporarily, the pin may also point to a **branch** (`CMAKECRAFT_VERSION "master"`),
   but must be set back to a tag before project releases.

### 5.3 What Goes Where?

| Change | Location |
|---|---|
| New target, new app, **declaring** an external, options | **Project** (Solution.json, projects/) |
| New external **include** (`cmake/externals/includes/<name>/`), pre-/post-fetch **hook**, new **error code**, fix in core/project modules, new template variant | **CMakeCraft** (then tag + pin change, §5.1) |
| Project-specific presets | **Project** (the project's `CMakePresets.json` / user presets locally) |
| Build system docs | **CMakeCraft** (`docs/`) |
| App docs | **Project** |

Rule of thumb: **Could a second project benefit from it → CMakeCraft.**

---

## 6. What Is Versioned Where?

| Artifact | Project repo | CMakeCraft repo | local only |
|---|---|---|---|
| Solution.json, projects/, app docs | ✅ | | |
| `CMakeCraftBootstrap.cmake` + `cmakecraft.pin` (version) | ✅ | (template in `templates/consumer/`) | |
| `cmake/` (build system modules) | ❌ (fetched into `.externals/cmakecraft/<version>/`) | ✅ (SSOT) | |
| templates/, build system docs | (copy optional) | ✅ | |
| externals/ SDK structures + SETUP.md | ✅ | | |
| **Proprietary binaries (bass.lib, DLLs, …)** | ❌ never | ❌ never | ✅ |
| CMakeUserPresets.json (local paths) | ❌ (only .example) | ❌ | ✅ |
| out/, .externals/, .vs/ | ❌ | ❌ | ✅ |

Recommendation: for both repos a **hosted remote** (e.g. GitHub) in addition to local
copies/USB — clones from USB sticks have lost files before.

---

## 7. Troubleshooting

| Symptom | Cause | Solution |
|---|---|---|
| `…/externals/bass/…/x64/bass.lib … missing and no known rule to make it` | Proprietary binaries are deliberately untracked (§4.2) | Obtain them as in §4.3 / SETUP.md |
| Configure error `E002 Solution.json not found` | Solution.json missing/wrong location | Create Solution.json in the project root (§3.5) |
| `E010 External not defined` | A target references an external that is missing from the `externals` block | Extend Solution.json; [ErrorCodes.md](../references/ErrorCodes.md) |
| qt-ads/Git external missing | `.externals/` not fetched yet (the first configure needs a network) | Repeat configure with a network connection |
| Qt not found | `QT_ROOT` not set | `CMakeUserPresets.json` (§3.4) |
| New file is not built | not entered in `Source.cmake` | Add `list(APPEND …)` (§3.6) |
| Linker: `undefined symbol … staticMetaObject / qt_metacall / signals` | AUTOMOC did not run — `cmake/externals/system/packages/Qt6.cmake` is missing from the obtained CMakeCraft version (historically: the VS rule `**/packages/*` had swallowed it) | Raise the pin to a version that contains the file (§5.1 step 4); then configure with `--fresh` |
| `[Bootstrap] … konnte aus keiner Quelle geholt werden` | no network + no cache + no local fallback | Restore the network, point `CMAKECRAFT_FALLBACK_PATHS` to a local checkout, or `-DCMAKECRAFT_LOCAL_DIR=<pfad>` |
| `[E005] /path/to/MyProject/CMakeLists.txt has no project() line. Add 'project(<Name> LANGUAGES NONE)' directly after cmake_minimum_required() - name and version still come from Solution.json. Then configure with --fresh.` | The required line `project(<Name> LANGUAGES NONE)` is missing from the thin version (required since v0.13.0) | Add the line after `cmake_minimum_required()` (§3 step 2), then configure with `--fresh` |
| Build system behaves "old" despite a new pin | `.externals/cmakecraft/<version>/` is a cache per version; the same tag is never fetched again | Never move tags! New state = new tag. If necessary, delete `.externals/cmakecraft/` |
| Build system behaves differently than expected | forgotten `CMAKECRAFT_LOCAL_DIR` override in the cache | Check the configure output (`[Bootstrap] … LOKAL-OVERRIDE`); clear the variable |
| CLI: `Could not read presets` / VS only shows x64 debug default configurations | The preset file violates the schema. Caution: **preset JSONs do NOT tolerate comments** — `/* */` breaks the CLI, `"$comment"` would need schema v10 (CMake ≥ 3.31), but Visual Studio only supports v2–v9 and silently falls back to default configurations with v10 | Document presets via `displayName`/`description`, keep schema version 6. The comment convention `"_comment"` applies only to **non-preset JSONs** (e.g. Solution.json). After the repair: reload the folder in VS |

More: [Getting_Started.md](Getting_Started.md) sections 12–13 · debug output via
`-DDEBUG_MESSAGES=ON -DDEBUG_DEFAULT_LEVEL=3`

---

## 8. See Also

- [Getting_Started.md](Getting_Started.md) — Basics, first executable/library
- [App_Creation_Guide.md](App_Creation_Guide.md) — App container (core/runner/tests/PCH)
- [Adding_Externals.md](Adding_Externals.md) · [Externals.md](Externals.md) — Integrating externals
- [CMakeUserPresets.md](CMakeUserPresets.md) — User presets
- [Solution_Schema.md](../references/Solution_Schema.md) — Schema reference
- [Testing.md](Testing.md) — Tests with doctest
- `externals/bass/SETUP.md` (in the respective project) — obtaining the BASS binaries

---

## Changelog

- **1.4.2** (2026-11-09): Aligned with the code: remnants of the snapshot procedure switched to consumption via `cmakecraft.pin` (§1, §5.3, §6, step 8, troubleshooting Qt6/AUTOMOC), "three mandatory files" corrected against the table (step 2), troubleshooting row `No project() command is present` replaced by E005; `QT_ROOT` as `environment` instead of `cacheVariables` (the resolver reads environment variables only, `PathResolver.cmake:108-116`), existing preset names (step 7)
- **1.4.1** (2026-11-09): Pin example v0.14.1 (explicit entry point for Qt GUI programs under Windows)
- **1.4.0** (2026-11-07): Pin example v0.14.0 (`compile_options` per library, source package of a library)
- **1.3.0** (2026-10-24): Pin example v0.13.0, mandatory line `project(<Name> LANGUAGES NONE)` (step 2)
- **1.2.0** (2026-10-23): Pin example v0.12.0, parallel compilation under MSVC (`settings.msvc`, step 5)
- **1.1.0** (2026-10-09): CMake 3.26, pin example v0.10.0, fourth externals source `archive` (§4.1)
- **1.0.0** (2026-07-17): First version — project setup, obtaining libs, sync workflow (SSOT CMakeCraft)
