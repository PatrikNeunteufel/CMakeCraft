# Building and Consuming Packages — Reference

> **Version:** 1.0.0  
> **Date:** 2026-10-09  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Packages.md](../../../de/guide/references/Packages.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Building: the `packages` block](#2-building-the-packages-block)
3. [Consuming: external kind `archive`](#3-consuming-external-kind-archive)
4. [The pin file](#4-the-pin-file)
5. [Without CMakeCraft: `CMakeCraftPackage.cmake`](#5-without-cmakecraft-cmakecraftpackagecmake)
6. [Library fields: `output_name`, `defines`](#6-library-fields-output_name-defines)
7. [Errors and warnings](#7-errors-and-warnings)
8. [See also](#8-see-also)
9. [Changelog](#9-changelog)

---

## 1. Overview

Since v0.10.0 a project can produce a **prebuilt package** (headers, built files, whole output
folders), and another project can consume it in a **pinned version**.

| Side | Means | Result |
|------|-------|--------|
| Building | `packages` block in `Solution.json` | target `package_<name>` writes a folder, a `.zip` and a `.zip.sha256` to `<project>/out/package/` |
| Consuming | external with `"archive": true` and a pin file | include path, define and runtime files on every target naming the external |
| Consuming without CMakeCraft | include `CMakeCraftPackage.cmake` directly | the same logic as two functions |

None of this is active by itself. A project without `packages` and without an archive external
behaves as before. **CMake 3.26** is required.

Uploading a package (for instance as a release) is not part of the build system.

---

## 2. Building: the `packages` block

```json
"packages": [
    {
        "name": "sichttest",
        "archive": "sichttest-v{version}-win64",
        "config": "Release",
        "contents": [
            { "to": "include",   "headers_of": "SichttestSteuerung",
              "files": ["sichttest_steuerung.h", "sichttest_steuerung.hpp"] },
            { "to": "bin",       "binary_of": "SichttestSteuerung" },
            { "to": "sichttest", "output_dir_of": "Sichttest", "exclude": ["*.pdb", "*.ilk"] }
        ],
        "version_file": "packaging/VERSION.in"
    }
]
```

### 2.1 Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `name` | ✅ | string | Package name; the target is called `package_<name>` |
| `contents` | ✅ | array | What goes into the package (§2.2) |
| `archive` | – | string | Name of folder and archive; `{version}` is the solution version. Default: `<name>-v{version}` |
| `config` | – | string | The only configuration the package may be built from (e.g. `"Release"`). Not given: any |
| `version_file` | – | string | Template relative to the project; `@VERSION@` is replaced by the solution version, the result is the file `VERSION` in the package |

### 2.2 Entries of `contents`

Each entry names the destination folder inside the package with `to` and **exactly one** source:

| Source | Value | What is copied |
|--------|-------|----------------|
| `headers_of` | name of a library | its `public_headers` folder; with `files` only the files listed |
| `binary_of` | name of a target | the built file of the target (for a DLL the `.dll`), under its `output_name` |
| `output_dir_of` | name of a target | the output folder of the target **with all subfolders** — including what `windeployqt` puts there |
| `from` | folder relative to the project | the folder; with `files` only the files listed |

| Extra field | Applies to | Description |
|-------------|------------|-------------|
| `files` | `headers_of`, `from` | list of files relative to the source |
| `exclude` | `output_dir_of`, `headers_of`/`from` without `files` | patterns on file names (`*.pdb`), effective at any depth |

### 2.3 Invocation and result

```bash
cmake --build <build> --target package_sichttest
```

The target is not part of `ALL`. It first builds the targets named and then writes to
`<project>/out/package/`:

```
out/package/
├── sichttest-v0.2.0-win64/           the package folder
├── sichttest-v0.2.0-win64.zip        the same folder as archive (one top-level folder)
└── sichttest-v0.2.0-win64.zip.sha256 checksum in sha256sum format
```

- The package folder is **rebuilt from scratch** on every run (remove, then copy).
- If the configuration differs from `config`, the target stops with a plain message; an
  existing package is left untouched.
- `out/package/` belongs in the project's `.gitignore`.

> **The checksum belongs to exactly this file.** Two runs with the same content give
> different checksums (the archive carries time stamps). A pin file therefore takes the checksum
> of the **published** file, not that of a later run.

### 2.4 The file `VERSION`

Consuming (§3) checks the line `produkt=<version>` in the package against the pin. A package
meant to be consumed therefore needs a `version_file` whose template carries this line:

```
produkt=@VERSION@
```

Further lines are free.

---

## 3. Consuming: external kind `archive`

```json
"externals": {
    "sichttest": {
        "archive": true,
        "pin": "sichttest.pin",
        "platforms": ["windows"],
        "include_dirs": ["include"],
        "define": "SICHTTEST_VORHANDEN",
        "runtime": { "files": ["bin/SichttestSteuerung1.dll"], "dirs": ["sichttest"] }
    }
}
```

### 3.1 Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `archive` | ✅ | boolean | Must be `true` |
| `pin` | ✅ | string | Pin file relative to the project (§4) |
| `platforms` | – | string[] | `windows`, `linux`, `macos`, `unix`; on any other platform the external is absent, without a warning |
| `include_dirs` | – | string[] | Include folders inside the package. **Nothing is linked** |
| `define` | – | string | Definition `<name>=1` on every target naming the external |
| `runtime.files` | – | string[] | Files of the package copied next to each executable |
| `runtime.dirs` | – | string[] | Folders of the package copied as a subfolder of the same name next to each executable |

The common field `skip` applies as for the other kinds.

### 3.2 What a target gets

A target names the external under `externals` like any other:

| Target | Include path | Define | Runtime files |
|--------|--------------|--------|---------------|
| Executable | yes | yes | yes — after each build, per configuration, only when changed |
| Library (STATIC, SHARED) | yes | yes | no |

Include path and define apply **only to the target naming the external** (PRIVATE); they are
not inherited by targets depending on it. A test target that includes a header of the package
through a public header of its library must therefore name the external itself — or the library
keeps the include inside a `.cpp`.

The runtime files are copied **when the executable is built**, not at configure time. After a
change of the package version the old copy stays next to the executable until the executable
is rebuilt.

Switching the copies off for a single target:

```json
"external_options": { "sichttest": { "runtime": false } }
```

### 3.3 When the package is missing

A package that cannot be obtained is **not an error**: warning W304 is issued, and the targets
get neither include path nor define nor copies. The source code tells the cases apart by the
define:

```cpp
#ifdef SICHTTEST_VORHANDEN
#  include <sichttest_steuerung.hpp>
#endif
```

### 3.4 Order of sources

`<NAME>` is the name of the external in upper case.

| # | Source | Remark |
|---|--------|--------|
| 1 | `-D<NAME>_LOCAL_DIR=<folder>` | unpacked package, used unchecked (development) |
| 2 | cache `<folder of the pin file>/.externals/<name>/<version>/` | valid when `VERSION` there matches the pin |
| 3 | download of `<NAME>_URL` | checksum `<NAME>_SHA256` |
| 4 | `<NAME>_FALLBACK_PATHS` | folders holding the same archive file; same checksum |

Once the package is in the cache, no further configure needs the network.

The cache is valid by **version**, not by checksum. If a package is rebuilt under the same
version, the old content stays until the folder `.externals/<name>/<version>/` is deleted.

---

## 4. The pin file

A CMake script with four variables, modelled on `cmakecraft.pin`:

```cmake
set(SICHTTEST_VERSION "v0.2.0")
set(SICHTTEST_URL     "https://github.com/<account>/<repo>/releases/download/${SICHTTEST_VERSION}/sichttest-${SICHTTEST_VERSION}-win64.zip")
set(SICHTTEST_SHA256  "<64 hex digits>")
set(SICHTTEST_FALLBACK_PATHS "../SichtTest_Helper/out/package")
```

| Variable | Required | Description |
|----------|----------|-------------|
| `<NAME>_VERSION` | ✅ | Pinned version. A leading `v` is ignored when comparing with `produkt=` |
| `<NAME>_URL` | – | Address of the archive. Its file name is also the one looked for in the fallback paths |
| `<NAME>_SHA256` | ✅ | Checksum of the archive. Nothing is fetched without it |
| `<NAME>_FALLBACK_PATHS` | – | List of folders; relative paths start at the folder of the pin file |

The pin lives **only** here; `Solution.json` refers to it with `"pin"`.

---

## 5. Without CMakeCraft: `CMakeCraftPackage.cmake`

The file in the root folder of CMakeCraft carries the whole fetch and deploy logic and depends
on nothing in the core. A project that does not build with CMakeCraft takes an **unchanged
copy** (version line in the header) and calls two functions:

```cmake
include("${CMAKE_CURRENT_LIST_DIR}/CMakeCraftPackage.cmake")

craft_package_fetch(NAME sichttest PIN_FILE sichttest.pin OUT_ROOT _sichttest_root)

craft_package_deploy(TARGET MyApp ROOT "${_sichttest_root}"
    INCLUDE_DIRS  include
    DEFINE        SICHTTEST_VORHANDEN
    RUNTIME_FILES bin/SichttestSteuerung1.dll
    RUNTIME_DIRS  sichttest)
```

| Function | Argument | Description |
|----------|----------|-------------|
| `craft_package_fetch` | `NAME` | package name; prefix of the pin variables in upper case |
| | `PIN_FILE` | pin file (relative: to `CMAKE_CURRENT_SOURCE_DIR`) |
| | `CACHE_DIR` | optional: folder of the unpacked package instead of the default |
| | `OUT_ROOT` | variable receiving the package root; empty when the package is missing |
| `craft_package_deploy` | `TARGET` | existing target |
| | `ROOT` | package root; empty = nothing happens |
| | `INCLUDE_DIRS`, `DEFINE` | like `include_dirs`, `define` |
| | `RUNTIME_FILES`, `RUNTIME_DIRS` | like `runtime.files`, `runtime.dirs` |
| | `NO_RUNTIME` | include path and define only |

---

## 6. Library fields: `output_name`, `defines`

Two fields that libraries know since v0.10.0 belong to building packages:

```json
{
    "name": "SichttestSteuerung",
    "type": "SHARED",
    "output_name": "SichttestSteuerung1",
    "defines": ["STS_PRODUKT=\"{version}\""]
}
```

| Field | Description |
|-------|-------------|
| `output_name` | File name without extension; the target name stays |
| `defines` | Preprocessor definitions, PRIVATE on the target (for `INTERFACE`: INTERFACE) |

`{version}` in `defines` is replaced for libraries **and** executables by the version of the
target (its own `version`, otherwise that of the solution).

After setting `output_name` on an existing library, the file with the old name stays in the
build folder; `binary_of` takes the right one.

---

## 7. Errors and warnings

| Code | When | Consequence |
|------|------|-------------|
| E001 | `packages[]` without `name` or `contents`; entry with no or several sources; `version_file` or `from` folder missing; library without public headers | abort |
| E102 | target `package_<name>` already exists | abort |
| E220 | archive external without `pin` | abort |
| W112 | a package names a target that does not exist (skipped, other platform) | `package_<name>` is not created |
| W304 | archive external not available | targets build without the package |

In addition there are warnings from `CMakeCraftPackage.cmake` prefixed `[CraftPackage]`; they
name every source tried and the reason.

---

## 8. See also

- [Solution_Schema.md](Solution_Schema.md) — schema of `Solution.json`
- [ErrorCodes.md](ErrorCodes.md) — error code reference

---

## 9. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2026-10-09** | **First version, for CMakeCraft v0.10.0** |
