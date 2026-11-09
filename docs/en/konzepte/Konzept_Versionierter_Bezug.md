# Concept: Versioned CMakeCraft Consumption for Consumer Projects

> **Version:** 1.0.1
> **Date:** 2026-11-09
> **Type:** Concept
> **Status:** Draft — decision pending
> **Based on:** LumiViz restructuring plan Phase 1; Neues_Projekt_Guide.md §5 (today's manual sync)
> **Language:** English
> **German:** [Konzept_Versionierter_Bezug.md](../../de/konzepte/Konzept_Versionierter_Bezug.md)

---

## 1. Goal

Consumer projects (LumiViz, future ones) should **no longer carry the build system as a copied
snapshot**, but **obtain it in versioned form**: the project only declares *which CMakeCraft
version* it wants; divergence becomes technically impossible instead of merely forbidden.

## 2. In-Depth Analysis: Current Coupling (Measurement of 2026-07-18)

Examined: all path assumptions in `cmake/**` and `CMakeLists.txt` (state a98ff3a).

| Coupling | Occurrences | Assessment |
|---|---|---|
| `${CMAKE_SOURCE_DIR}/cmake/…` (location of the build system) | **6**: HookLoader.cmake:39/40, Orchestrator.cmake:238, local/Attach.cmake:86, system/Handler.cmake:99, phase9.cmake:395 | **the only real location coupling** — must be switched to a variable |
| `include(cmake/…)` in CMakeLists.txt | ~24 lines (9 core, 6 project, 9 buildSystemTest) | moves into an entry point inside CMakeCraft |
| `${CMAKE_SOURCE_DIR}/Solution.json`, `projects/`, `externals/`, `.externals/`, `.clang-*` | ~41 | **correctly project-related** — remains unchanged |

**Conclusion:** Only 6 paths + 1 include block are location-bound. The build system is almost
relocatable already; what is needed is a variable `CMAKECRAFT_DIR` + an entry point.

## 3. Step A (Prerequisite, Independent of the Option): Make CMakeCraft Relocatable

1. **Entry point `CMakeCraft.cmake`** in the CMakeCraft root:
   - sets `CMAKECRAFT_ROOT = ${CMAKE_CURRENT_LIST_DIR}` and `CMAKECRAFT_DIR = ${CMAKE_CURRENT_LIST_DIR}/cmake`
     (self-locating; `CMAKECRAFT_DIR` points to the module tree, `CMakeCraft.cmake:132–133`),
   - takes over all of today's includes from the top-level CMakeLists (core → Solution → project()
     → Externals/Libraries/Executables/Apps/Tests → optionally buildSystemTest),
   - the consumer calls one function/one include — the order stays encapsulated internally.
2. Switch the **6 hard paths** from `${CMAKE_SOURCE_DIR}/cmake/…` to `${CMAKECRAFT_DIR}/…`.
3. CMakeCraft's **own CMakeLists.txt uses the entry point** (dogfooding: CMakeCraft is itself
   consumer no. 0, `CMAKECRAFT_DIR = <root>/cmake`).
4. Verification: `craft-selftest` green; demo solution builds.
5. **Tag `v0.7.0`** = first relocatable version.

Project-related paths (`Solution.json`, `projects/`, `externals/`, `.externals/`) deliberately
stay at `CMAKE_SOURCE_DIR` — that is the contract "project supplies the solution, CMakeCraft builds".

## 4. Consumption Options (Decision)

### Option B — Bootstrap Fetch (Recommendation) 🏆

Only two small things are committed in the project:
- `cmakecraft.pin` (or similar): `v0.7.0` + repo URL(s)
- `bootstrap.cmake` (~40 lines, stable): checks `.externals/cmakecraft/<version>`; if missing →
  `git clone --depth 1 --branch <tag>` from GitHub (fallback: local path, e.g. sibling
  checkout `../CMakeCraft`); then `include(…/CMakeCraft.cmake)`.

> **Code today (2026-11-09):** Option B is implemented (since v0.7.0). The bootstrap file is called `CMakeCraftBootstrap.cmake` (`templates/consumer/`, about 120 lines); `cmakecraft.pin` sets `CMAKECRAFT_VERSION`, `CMAKECRAFT_GIT_URL` and `CMAKECRAFT_FALLBACK_PATHS`. Order of sources (`templates/consumer/CMakeCraftBootstrap.cmake:14–20`): `-DCMAKECRAFT_LOCAL_DIR=<path>` (working copy used directly, no clone) → cache `.externals/cmakecraft/<version>/` → `git clone --depth 1 --branch <version>` from `CMAKECRAFT_GIT_URL` → the same clone from the fallback paths (local repos, default `../CMakeCraft`).

| Pro | Contra |
|---|---|
| exactly the philosophy of its own Git externals (tag pin → `.externals/`) | first configure needs network **or** the local fallback |
| no submodule handling (transparent to VS, no `--recurse`, no detached HEAD) | the bootstrap file is a mini snapshot (keep it small!) |
| version change = change 1 line in `cmakecraft.pin` | |
| several projects share the same mechanism | |

### Option A — Git Submodule

`git submodule add <url> cmakecraft/` in the project; CMakeLists includes
`cmakecraft/CMakeCraft.cmake`.

| Pro | Contra |
|---|---|
| pin via gitlink (no mechanism of its own) | submodule friction: `clone --recurse-submodules`, forgotten `submodule update`, detached-HEAD confusion |
| offline after cloning | VS submodule support is rudimentary |
| | history shows only hashes, no meaningful version |

### Option C — Status Quo Formalized (Interim Solution, Already Running)

Mirror sync + `BUILDSYSTEM_VERSION.md` + Guide §5. No effort, but divergence remains humanly
possible. Remains the defined **rollback state**.

## 5. Step B: LumiViz Migration (with Option B)

1. Branch `phase1-buildsystem-bezug` in LumiViz.
2. Add `bootstrap.cmake` + `cmakecraft.pin` (= `v0.7.0`); CMakeLists.txt →
   thin version (~15 lines: cmake_minimum_required, options, bootstrap include).
3. **Delete** the `cmake/` folder (git rm) — from then on it comes from `.externals/cmakecraft/`.
4. Delete `BUILDSYSTEM_VERSION.md` (replaced by `cmakecraft.pin`);
   rewrite Guide §5: "sync" = tag bump in the pin (+ emergency path: pin to branch/commit).
5. `templates/`, `clang-format/-tidy`, presets remain project copies (as in Guide §6).

> **Code today (2026-11-09):** The thin version of the template (`templates/consumer/CMakeLists.txt`) has three commands: `cmake_minimum_required(VERSION 3.26)`, `project(<Name> LANGUAGES NONE)` (required since v0.13.0, otherwise E005) and `include("${CMAKE_CURRENT_LIST_DIR}/CMakeCraftBootstrap.cmake")`.

## 6. Verification (Acceptance Criteria)

- CMakeCraft: `craft-selftest` green (CLI) · demo solution builds (VS).
- LumiViz: configure+build **VS IDE and CLI**, MyViz starts · second configure **offline**
  (cache fallback takes effect) · fallback "no network + no cache" yields an understandable
  error message with instructions.
- `git status` of both repos clean; a fresh LumiViz clone into an empty directory builds
  (BASS binaries provided according to SETUP.md).

## 7. Rollback

The migration runs on a branch; `master` keeps the working snapshot state (Option C).
Rollback = discard the branch. After the merge: rollback = revert commit; the old state is
fully in the history.

## 8. Effort Estimate

| Step | Scope |
|---|---|
| A: entry point + 6 paths + dogfooding + selftest | ~2–3 h of focused work |
| B: bootstrap + LumiViz thin version + docs | ~1–2 h |
| Verification of both repos (both ways) | ~1 h |

## 9. Follow-Up Topics (Not Part of This Concept)

- Bass PreFetch hook (automatic binaries download from un4seen)
- `CMakeUserPresets.json` → `.example` pattern (currently committed with local paths)
- Build system docs move LumiViz→CMakeCraft (Phase 2)

## 10. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: `CMAKECRAFT_DIR` in §3 step 1 (module tree `<root>/cmake`, the root is `CMAKECRAFT_ROOT`); "Code today" notes on the implemented bootstrap (§4, §5)** |
| 1.0.0 | 2026-07-18 | First version (`290b104`) |
