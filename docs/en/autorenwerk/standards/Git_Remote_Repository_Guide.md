# Git Remote Repository — Guide

> **Version:** 1.1.1  
> **Date:** 2026-11-09  
> **Type:** Guide  
> **Status:** Stable  
> **Target Audience:** Developers  
> **Language:** English  
> **German:** [Git_Remote_Repository_Guide.md](../../../de/autorenwerk/standards/Git_Remote_Repository_Guide.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Creating a Local Repository](#3-creating-a-local-repository)
4. [Creating a Remote Repository](#4-creating-a-remote-repository)
5. [Linking Repositories](#5-linking-repositories)
6. [Configuring Multiple Remotes (Dual Push)](#6-configuring-multiple-remotes-dual-push)
7. [Configuring a Safe Directory](#7-configuring-a-safe-directory)
8. [Pushing Changes](#8-pushing-changes)
9. [Visual Studio Code Workflow](#9-visual-studio-code-workflow)
10. [SourceTree Workflow](#10-sourcetree-workflow)
11. [Troubleshooting](#11-troubleshooting)
12. [See Also](#12-see-also)
13. [Changelog](#13-changelog)

---

## 1. Overview

This guide describes how to connect a local Git repository to one or more remote repositories. Besides the classic single remote (network drive), it also covers the dual-remote setup, in which pushes go simultaneously to a local backup (USB/network) and to GitHub.

### Typical Structure — Single Remote

```
Local workstation                 Network server
┌──────────────────┐              ┌──────────────────┐
│ C:\Projects\     │   push/pull  │ N:\NegalGIT\     │
│   MyProject\     │◄────────────►│   MyProject\     │
│     .git\        │              │     (bare repo)  │
└──────────────────┘              └──────────────────┘
```

### Typical Structure — Dual Remote (USB + GitHub)

```
Local workstation
┌──────────────────────────────────────────────────┐
│ C:\Projects\MyProject\                           │
│   .git\                                          │
│                                                  │
│   origin (fetch) ──► GitHub                      │
│   origin (push)  ──► GitHub  ┐ simultaneously    │
│   origin (push)  ──► USB     ┘ on git push       │
└──────────────────────────────────────────────────┘
         │  fetch                        │  push
         ▼                               ▼
┌─────────────────┐            ┌─────────────────┐
│  GitHub         │            │  GitHub  +  USB │
│  (team source)  │            │  (both in sync) │
└─────────────────┘            └─────────────────┘
```

> **Rule of thumb:** Always fetch from the shared team source (GitHub), push to all targets simultaneously.

---

## 2. Prerequisites

### Software

| Tool | Description |
|------|-------------|
| **Git** | Standalone or via SourceTree |
| **SourceTree** | Optional, GUI for Git |
| **Visual Studio Code** | Optional, integrated Git panel |

### Network

- Access to a network drive (e.g. `N:\NegalGIT\`) or a USB stick (e.g. `E:\GitUSB\`)
- Write permissions in the remote directory
- GitHub account with access to the repository (for dual remote)

---

## 3. Creating a Local Repository

### 3.1 Command Line

```bash
# Change to the project directory
cd C:\Projects\MyProject

# Initialize Git
git init
```

This creates a `.git` folder with the repository structure.

### 3.2 Creating a .gitignore

Create a `.gitignore` before the first commit:

```gitignore
# Build artifacts
build/
out/
*.obj
*.exe
*.dll

# IDE files
.vs/
*.user
*.suo

# Temporary files
*.tmp
*.log
```

### 3.3 First Commit

```bash
# Stage all files
git add .

# Initial commit
git commit -m "Initial commit"
```

---

## 4. Creating a Remote Repository

### 4.1 Bare Repository (Command Line)

A **bare repository** contains no working copy — only the Git database.

```bash
# Change to the remote directory
cd N:\NegalGIT

# Create the project folder
mkdir MyProject
cd MyProject

# Initialize the bare repository
git init --bare
```

### Structure of a Bare Repository

```
N:\NegalGIT\MyProject\
├── HEAD
├── config
├── description
├── hooks\
├── info\
├── objects\
└── refs\
```

> **Note:** SourceTree cannot create bare repositories. Use the command line.

### 4.2 Creating a GitHub Repository

1. Log in at [github.com](https://github.com)
2. **New repository** → assign a name → **Create repository**
3. Note the displayed HTTPS URL (e.g. `https://github.com/User/MyProject.git`)

---

## 5. Linking Repositories

### 5.1 Adding a Single Remote

```bash
# Back to the local repository
cd C:\Projects\MyProject

# Add the remote "origin"
git remote add origin N:\NegalGIT\MyProject
```

### 5.2 Verifying the Remote

```bash
git remote -v
# Output:
# origin  N:\NegalGIT\MyProject (fetch)
# origin  N:\NegalGIT\MyProject (push)
```

> For the dual-remote setup (USB + GitHub), continue with section 6.

---

## 6. Configuring Multiple Remotes (Dual Push)

This setup makes it possible to push to two remotes simultaneously with a single `git push` (e.g. a USB stick as local backup + GitHub as team platform), while fetching happens exclusively from GitHub so that colleagues' commits become visible.

### 6.1 Concept: Fetch vs. Push URLs

Git allows **one fetch URL** but **several push URLs** per remote. This makes the following split possible:

| Direction | Source/Target | Purpose |
|-----------|---------------|---------|
| **fetch** | GitHub | Receive colleagues' commits |
| **push** | GitHub | Update the state on the team platform |
| **push** | USB / network drive | Local backup |

### 6.2 Setup — Step by Step

**Step 1: Set the fetch URL to GitHub**

```bash
git remote set-url origin https://github.com/User/MyProject.git
```

**Step 2: Define the push URLs**

Since `--add --push` does not automatically carry over the previous fetch URL, both push targets must be entered explicitly:

```bash
# Push URL 1: GitHub
git remote set-url --add --push origin https://github.com/User/MyProject.git

# Push URL 2: USB stick / network drive
git remote set-url --add --push origin E:\GitUSB\MyProject
```

> **Important:** Always enter push URLs with `--add --push`. `set-url --push` without `--add` replaces the first existing push URL instead of adding another one. The fetch URL from step 1 is not affected.

**Step 3: Check the configuration**

```bash
git remote -v
# Expected output:
# origin  https://github.com/User/MyProject.git  (fetch)
# origin  https://github.com/User/MyProject.git  (push)
# origin  E:\GitUSB\MyProject                    (push)
```

### 6.3 Adding a Second Named Remote (Optional)

If separate access to GitHub without pushing to USB is wanted (e.g. for an explicit `pull` from GitHub), a second remote can be added:

```bash
git remote add github https://github.com/User/MyProject.git
```

```bash
git remote -v
# origin  https://github.com/User/MyProject.git  (fetch)
# origin  https://github.com/User/MyProject.git  (push)
# origin  E:\GitUSB\MyProject                    (push)
# github  https://github.com/User/MyProject.git  (fetch)
# github  https://github.com/User/MyProject.git  (push)
```

This allows an explicit `git pull github main` without disturbing normal operation via `origin`.

### 6.4 Behavior in Normal Operation

| Action | Command | Result |
|--------|---------|--------|
| Push to both | `git push` | → GitHub + USB simultaneously |
| Fetch from GitHub | `git fetch` | → colleagues' commits visible |
| Fetch from all | `git fetch --all` | → update all remotes |
| Pull from GitHub | `git pull` | → local state in sync with GitHub |
| Explicit pull | `git pull github main` | → only from the `github` remote |

---

## 7. Configuring a Safe Directory

For network drives and USB sticks, the directory must be marked as "safe".

### 7.1 Important Commands

| Command | Description |
|---------|-------------|
| `git config --global --get-all safe.directory` | Show all safe directories |
| `git config --global --add safe.directory <path>` | Add a directory |
| `git config --global --unset-all safe.directory` | Remove all |
| `git config --show-origin --get-all safe.directory` | Show with source file |

### 7.2 Local Path

```bash
git config --global --add safe.directory N:/NegalGIT/MyProject
```

### 7.3 USB Stick Path (Windows)

```bash
git config --global --add safe.directory E:/GitUSB/MyProject
```

### 7.4 UNC Path (Network)

```bash
git config --global --add safe.directory //Negalserver/Mainserver/NegalGIT/MyProject
```

> **Important:** Replace backslashes with forward slashes!

---

## 8. Pushing Changes

### 8.1 First Push

```bash
# Check the branch name
git status
# On branch master (or main)

# Push with upstream tracking
git push -u origin master
```

### 8.2 Subsequent Pushes

```bash
git push
```

With a dual-push configuration (section 6), the push automatically goes to all configured push URLs.

---

## 9. Visual Studio Code Workflow

VS Code has an integrated Git panel (sidebar → Source Control, `Ctrl+Shift+G`) and uses `origin` for all operations by default.

### 9.1 Sync Button (↑↓)

The sync button in the status bar runs `git pull` + `git push` on `origin`. With a correct dual-push configuration (section 6):

| Action | Behavior |
|--------|----------|
| **Push (↑)** | → GitHub + USB simultaneously ✓ |
| **Pull (↓)** | → from GitHub (fetch URL) ✓ |
| **Colleagues' commits visible** | ✓ (provided the fetch URL points to GitHub) |

### 9.2 Pushing Manually to a Single Remote

If the push should go to only one specific remote:

`Ctrl+Shift+P` → **Git: Push to...** → select the remote

### 9.3 Fetching All Remotes

`Ctrl+Shift+P` → **Git: Fetch (All Remotes)**

Or in the terminal:

```bash
git fetch --all
```

### 9.4 Pulling from a Specific Remote

`Ctrl+Shift+P` → **Git: Pull from...** → select the remote and branch

Or in the terminal:

```bash
git pull github main
```

### 9.5 Viewing the Remote Status

Check the current state of all remotes in the terminal:

```bash
git remote -v
git branch -vv   # shows tracking branches and ahead/behind status
```

### 9.6 Note: VS Code Shows No New Commits from Colleagues

If VS Code shows no incoming commits even though a colleague has pushed to GitHub, the fetch URL of `origin` is misconfigured — it still points to the USB stick instead of GitHub. Solution: section 6.2, step 1.

---

## 10. SourceTree Workflow

### 10.1 Creating a Repository

1. **New tab** → **Create**
2. Select the source path (e.g. `C:\Projects\MyProject`)
3. Click **Create**
4. Confirm the warning "folder not empty"

### 10.2 Adding a Remote

1. **Repository** → **Repository Settings**
2. Tab **Remotes** → **Add**
3. Entries:
   - **Remote name:** `origin`
   - **URL/path:** `N:\NegalGIT\MyProject`
   - **Default remote:** ✓

### 10.3 Second Push URL in SourceTree

SourceTree offers no direct GUI for multiple push URLs. The configuration must be done via the command line (see section 6.2). After the setup, push in SourceTree works as usual and reaches both targets.

### 10.4 Limitation

> SourceTree **cannot create bare repositories**. Perform this step via the command line (see section 4).

---

## 11. Troubleshooting

### 11.1 "Dubious ownership" Error

```
fatal: detected dubious ownership in repository at 'N:/NegalGIT/...'
```

**Solution:** Add a safe directory (see section 7).

### 11.2 Remote Already Exists

```bash
# Remove the remote
git remote remove origin

# Add it again
git remote add origin N:\NegalGIT\MyProject
```

### 11.3 Push Rejected

```bash
# If the remote already has commits (e.g. from another user)
git pull origin master --rebase
git push
```

### 11.4 Different Branch Name

```bash
# Local branch: main, remote expects: master
git push -u origin main:master

# Or rename the local branch (main → master) to match the remote
git branch -m main master
git push -u origin master
```

### 11.5 Remotes Are Out of Sync (USB ≠ GitHub)

Cause: pushed directly to one remote (e.g. `git push github`) without updating the other.

```bash
# Fetch the current state from GitHub
git pull github main

# Synchronize both remotes again via origin
git push origin
```

Long term: work **exclusively** via `git push` (= `origin`), never push directly to `github`.

### 11.6 VS Code Does Not Show a Colleague's Push

Cause: the fetch URL of `origin` points to USB instead of GitHub.

```bash
# Check
git remote -v
# If "(fetch)" points to USB → fix:
git remote set-url origin https://github.com/User/MyProject.git
```

The push URLs are kept: `set-url` without `--push` changes only the fetch URL (`remote.origin.url`); configured push URLs (`remote.origin.pushurl`) are left untouched (`git help remote`, section *set-url*). Use `git remote -v` to check that both push targets are still listed.

### 11.7 Push URLs Missing or Wrong

`git remote set-url origin <url>` (without `--push`) changes only the fetch URL and leaves the push URLs in place. Push URLs are lost, however, when the remote is removed and added again (section 11.2); `git remote set-url --push origin <url>` without `--add` replaces the first push URL instead of adding another one. In both cases set the push URLs again:

```bash
git remote set-url --add --push origin https://github.com/User/MyProject.git
git remote set-url --add --push origin E:\GitUSB\MyProject
```

---

## 12. See Also

- [Git_Standard.md](Git_Standard.md) — Git conventions
- [Git documentation](https://git-scm.com/doc) — Official reference
- [GitHub Docs](https://docs.github.com) — GitHub-specific features

---

## 13. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.1.1** | **2026-11-09** | Aligned with the code: `git remote set-url` without `--push` changes only the fetch URL, push URLs are kept (§6.2, §11.6, §11.7 per `git help remote`); §11.4 `git branch -m` renames the local branch |
| **1.1.0** | **2026-03-31** | Sections 6 (dual push), 9 (VS Code) new; sections 4.2, 7.3, 11.5–11.7 extended; table of contents updated |
| **1.0.0** | **2025-12-19** | Initial: consolidated from How_to_create_remote_Git.docx |
