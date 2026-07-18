# Git Remote Repository — Guide

> **Version:** 1.1.0  
> **Datum:** 2026-03-31  
> **Typ:** Guide  
> **Status:** Stabil  
> **Zielgruppe:** Entwickler  
> **Sprache:** Deutsch  
> **English:** [Git_Remote_Repository_Guide.md](../../../en/tooling/vcs/Git_Remote_Repository_Guide.md)

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Lokales Repository erstellen](#3-lokales-repository-erstellen)
4. [Remote Repository erstellen](#4-remote-repository-erstellen)
5. [Repositories verknüpfen](#5-repositories-verknüpfen)
6. [Mehrere Remotes konfigurieren (Dual-Push)](#6-mehrere-remotes-konfigurieren-dual-push)
7. [Safe Directory konfigurieren](#7-safe-directory-konfigurieren)
8. [Änderungen pushen](#8-änderungen-pushen)
9. [Visual Studio Code Workflow](#9-visual-studio-code-workflow)
10. [SourceTree-Workflow](#10-sourcetree-workflow)
11. [Troubleshooting](#11-troubleshooting)
12. [Siehe auch](#12-siehe-auch)
13. [Changelog](#13-changelog)

---

## 1. Übersicht

Dieser Guide beschreibt, wie ein lokales Git-Repository mit einem oder mehreren Remote-Repositories verbunden wird. Neben dem klassischen Einzelremote (Netzlaufwerk) wird auch das Dual-Remote-Setup behandelt, bei dem gleichzeitig auf ein lokales Backup (USB/Netzwerk) und auf GitHub gepusht wird.

### Typische Struktur — Einzelremote

```
Lokaler Arbeitsplatz              Netzwerk-Server
┌──────────────────┐              ┌──────────────────┐
│ C:\Projects\     │   push/pull  │ N:\NegalGIT\     │
│   MyProject\     │◄────────────►│   MyProject\     │
│     .git\        │              │     (bare repo)  │
└──────────────────┘              └──────────────────┘
```

### Typische Struktur — Dual-Remote (USB + GitHub)

```
Lokaler Arbeitsplatz
┌──────────────────────────────────────────────────┐
│ C:\Projects\MyProject\                           │
│   .git\                                          │
│                                                  │
│   origin (fetch) ──► GitHub                      │
│   origin (push)  ──► GitHub  ┐ gleichzeitig      │
│   origin (push)  ──► USB     ┘ bei git push      │
└──────────────────────────────────────────────────┘
         │  fetch                        │  push
         ▼                               ▼
┌─────────────────┐            ┌─────────────────┐
│  GitHub         │            │  GitHub  +  USB │
│  (Team-Quelle)  │            │  (beide sync)   │
└─────────────────┘            └─────────────────┘
```

> **Faustregel:** Fetch immer von der gemeinsamen Team-Quelle (GitHub), Push auf alle Ziele gleichzeitig.

---

## 2. Voraussetzungen

### Software

| Tool | Beschreibung |
|------|--------------|
| **Git** | Standalone oder via SourceTree |
| **SourceTree** | Optional, GUI für Git |
| **Visual Studio Code** | Optional, integriertes Git-Panel |

### Netzwerk

- Zugriff auf Netzlaufwerk (z.B. `N:\NegalGIT\`) oder USB-Stick (z.B. `E:\GitUSB\`)
- Schreibrechte im Remote-Verzeichnis
- GitHub-Account mit Zugriff auf das Repository (bei Dual-Remote)

---

## 3. Lokales Repository erstellen

### 3.1 Command Line

```bash
# In Projektverzeichnis wechseln
cd C:\Projects\MyProject

# Git initialisieren
git init
```

Das erstellt einen `.git`-Ordner mit der Repository-Struktur.

### 3.2 .gitignore erstellen

Vor dem ersten Commit eine `.gitignore` anlegen:

```gitignore
# Build-Artefakte
build/
out/
*.obj
*.exe
*.dll

# IDE-Dateien
.vs/
*.user
*.suo

# Temporäre Dateien
*.tmp
*.log
```

### 3.3 Erster Commit

```bash
# Alle Dateien stagen
git add .

# Initialer Commit
git commit -m "Initial commit"
```

---

## 4. Remote Repository erstellen

### 4.1 Bare Repository (Command Line)

Ein **Bare Repository** enthält keine Arbeitskopie — nur die Git-Datenbank.

```bash
# Ins Remote-Verzeichnis wechseln
cd N:\NegalGIT

# Projektordner erstellen
mkdir MyProject
cd MyProject

# Bare Repository initialisieren
git init --bare
```

### Struktur eines Bare Repository

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

> **Hinweis:** SourceTree kann keine Bare Repositories erstellen. Nutze die Command Line.

### 4.2 GitHub Repository erstellen

1. Auf [github.com](https://github.com) einloggen
2. **New repository** → Name vergeben → **Create repository**
3. Die angezeigte HTTPS-URL notieren (z.B. `https://github.com/User/MyProject.git`)

---

## 5. Repositories verknüpfen

### 5.1 Einzelremote hinzufügen

```bash
# Zurück ins lokale Repository
cd C:\Projects\MyProject

# Remote "origin" hinzufügen
git remote add origin N:\NegalGIT\MyProject
```

### 5.2 Remote verifizieren

```bash
git remote -v
# Ausgabe:
# origin  N:\NegalGIT\MyProject (fetch)
# origin  N:\NegalGIT\MyProject (push)
```

> Für das Dual-Remote-Setup (USB + GitHub) weiter mit Abschnitt 6.

---

## 6. Mehrere Remotes konfigurieren (Dual-Push)

Dieses Setup ermöglicht, mit einem einzigen `git push` auf zwei Remotes gleichzeitig zu pushen (z.B. USB-Stick als lokales Backup + GitHub als Team-Plattform), während Fetch ausschliesslich von GitHub erfolgt, damit Commits von Kollegen sichtbar werden.

### 6.1 Konzept: Fetch vs. Push URLs

Git erlaubt pro Remote **eine Fetch-URL**, aber **mehrere Push-URLs**. Das macht folgende Aufteilung möglich:

| Richtung | Quelle/Ziel | Zweck |
|----------|-------------|-------|
| **fetch** | GitHub | Commits von Kollegen empfangen |
| **push** | GitHub | Stand auf Team-Plattform aktualisieren |
| **push** | USB / Netzlaufwerk | Lokales Backup |

### 6.2 Setup — Schritt für Schritt

**Schritt 1: Fetch-URL auf GitHub setzen**

```bash
git remote set-url origin https://github.com/User/MyProject.git
```

**Schritt 2: Push-URLs definieren**

Da `--add --push` die bisherige Fetch-URL nicht automatisch übernimmt, müssen beide Push-Ziele explizit eingetragen werden:

```bash
# Push-URL 1: GitHub
git remote set-url --add --push origin https://github.com/User/MyProject.git

# Push-URL 2: USB-Stick / Netzlaufwerk
git remote set-url --add --push origin E:\GitUSB\MyProject
```

> **Wichtig:** Die Reihenfolge der Befehle einhalten. `set-url` (ohne `--add`) würde vorhandene Push-URLs überschreiben.

**Schritt 3: Konfiguration prüfen**

```bash
git remote -v
# Erwartete Ausgabe:
# origin  https://github.com/User/MyProject.git  (fetch)
# origin  https://github.com/User/MyProject.git  (push)
# origin  E:\GitUSB\MyProject                    (push)
```

### 6.3 Zweiten benannten Remote hinzufügen (optional)

Wenn ein separater Zugriff auf GitHub ohne Push auf USB gewünscht ist (z.B. für explizites `pull` von GitHub), kann ein zweiter Remote eingetragen werden:

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

Damit ist ein explizites `git pull github main` möglich, ohne den Normalbetrieb über `origin` zu stören.

### 6.4 Verhalten im Normalbetrieb

| Aktion | Befehl | Ergebnis |
|--------|--------|----------|
| Push auf beide | `git push` | → GitHub + USB gleichzeitig |
| Fetch von GitHub | `git fetch` | → Kollegen-Commits sichtbar |
| Fetch von allen | `git fetch --all` | → alle Remotes aktualisieren |
| Pull von GitHub | `git pull` | → lokaler Stand mit GitHub synchron |
| Pull explizit | `git pull github main` | → nur vom `github`-Remote |

---

## 7. Safe Directory konfigurieren

Bei Netzlaufwerken und USB-Sticks muss das Verzeichnis als "sicher" markiert werden.

### 7.1 Wichtige Befehle

| Befehl | Beschreibung |
|--------|--------------|
| `git config --global --get-all safe.directory` | Alle Safe Directories anzeigen |
| `git config --global --add safe.directory <pfad>` | Directory hinzufügen |
| `git config --global --unset-all safe.directory` | Alle entfernen |
| `git config --show-origin --get-all safe.directory` | Mit Quell-Datei anzeigen |

### 7.2 Lokaler Pfad

```bash
git config --global --add safe.directory N:/NegalGIT/MyProject
```

### 7.3 USB-Stick Pfad (Windows)

```bash
git config --global --add safe.directory E:/GitUSB/MyProject
```

### 7.4 UNC-Pfad (Netzwerk)

```bash
git config --global --add safe.directory //Negalserver/Mainserver/NegalGIT/MyProject
```

> **Wichtig:** Backslashes durch Forward-Slashes ersetzen!

---

## 8. Änderungen pushen

### 8.1 Erster Push

```bash
# Branch-Name prüfen
git status
# On branch master (oder main)

# Push mit Upstream-Tracking
git push -u origin master
```

### 8.2 Folgende Pushes

```bash
git push
```

Bei Dual-Push-Konfiguration (Abschnitt 6) wird automatisch auf alle konfigurierten Push-URLs gepusht.

---

## 9. Visual Studio Code Workflow

VS Code besitzt ein integriertes Git-Panel (Seitenleiste → Source Control, `Strg+Shift+G`) und nutzt standardmässig `origin` für alle Operationen.

### 9.1 Sync-Button (↑↓)

Der Sync-Button in der Statusleiste führt `git pull` + `git push` auf `origin` aus. Bei korrekter Dual-Push-Konfiguration (Abschnitt 6):

| Aktion | Verhalten |
|--------|-----------|
| **Push (↑)** | → GitHub + USB gleichzeitig ✓ |
| **Pull (↓)** | → von GitHub (Fetch-URL) ✓ |
| **Kollegen-Commits sichtbar** | ✓ (sofern Fetch-URL auf GitHub zeigt) |

### 9.2 Manuell auf einzelnen Remote pushen

Falls gezielt auf nur einen Remote gepusht werden soll:

`Strg+Shift+P` → **Git: Push to...** → Remote auswählen

### 9.3 Alle Remotes fetchen

`Strg+Shift+P` → **Git: Fetch (All Remotes)**

Oder im Terminal:

```bash
git fetch --all
```

### 9.4 Von einem bestimmten Remote pullen

`Strg+Shift+P` → **Git: Pull from...** → Remote und Branch auswählen

Oder im Terminal:

```bash
git pull github main
```

### 9.5 Remote-Status einsehen

Im Terminal den aktuellen Stand aller Remotes prüfen:

```bash
git remote -v
git branch -vv   # zeigt Tracking-Branches und Ahead/Behind-Status
```

### 9.6 Hinweis: VS Code zeigt keine neuen Commits von Kollegen

Wenn VS Code keine eingehenden Commits anzeigt, obwohl ein Kollege auf GitHub gepusht hat, ist die Fetch-URL von `origin` falsch konfiguriert — sie zeigt noch auf den USB-Stick statt auf GitHub. Lösung: Abschnitt 6.2, Schritt 1.

---

## 10. SourceTree-Workflow

### 10.1 Repository erstellen

1. **Neuer Tab** → **Create**
2. Quellpfad auswählen (z.B. `C:\Projects\MyProject`)
3. **Erstellen** klicken
4. Bei Warnung "Ordner nicht leer" bestätigen

### 10.2 Remote hinzufügen

1. **Repository** → **Repository-Einstellungen**
2. Tab **Remotes** → **Hinzufügen**
3. Eingaben:
   - **Remote-Name:** `origin`
   - **URL/Pfad:** `N:\NegalGIT\MyProject`
   - **Standard-Remote:** ✓

### 10.3 Zweite Push-URL in SourceTree

SourceTree bietet keine direkte GUI für mehrere Push-URLs. Die Konfiguration muss per Command Line vorgenommen werden (siehe Abschnitt 6.2). Nach dem Setup funktioniert Push in SourceTree wie gewohnt und trifft beide Ziele.

### 10.4 Einschränkung

> SourceTree kann **keine Bare Repositories erstellen**. Diesen Schritt per Command Line ausführen (siehe Abschnitt 4).

---

## 11. Troubleshooting

### 11.1 "Dubious ownership" Fehler

```
fatal: detected dubious ownership in repository at 'N:/NegalGIT/...'
```

**Lösung:** Safe Directory hinzufügen (siehe Abschnitt 7).

### 11.2 Remote existiert bereits

```bash
# Remote entfernen
git remote remove origin

# Neu hinzufügen
git remote add origin N:\NegalGIT\MyProject
```

### 11.3 Push rejected

```bash
# Wenn Remote bereits Commits hat (z.B. durch anderen User)
git pull origin master --rebase
git push
```

### 11.4 Branch-Name unterschiedlich

```bash
# Lokaler Branch: main, Remote erwartet: master
git push -u origin main:master

# Oder Remote-Branch umbenennen
git branch -m master main
```

### 11.5 Remotes sind nicht synchron (USB ≠ GitHub)

Ursache: Direkt auf einen Remote gepusht (z.B. `git push github`), ohne den anderen zu aktualisieren.

```bash
# Aktuellen Stand von GitHub holen
git pull github main

# Beide Remotes via origin wieder synchronisieren
git push origin
```

Langfristig: **ausschliesslich** über `git push` (= `origin`) arbeiten, nie direkt auf `github` pushen.

### 11.6 VS Code zeigt Kollegen-Push nicht an

Ursache: Fetch-URL von `origin` zeigt auf USB statt auf GitHub.

```bash
# Prüfen
git remote -v
# Falls "(fetch)" auf USB zeigt → Fix:
git remote set-url origin https://github.com/User/MyProject.git
```

Danach Push-URLs neu eintragen (Abschnitt 6.2, Schritt 2), da `set-url` ohne `--push` alle Push-URLs zurücksetzt.

### 11.7 Push-URLs nach set-url verschwunden

`git remote set-url origin <url>` (ohne `--push`) überschreibt die Fetch-URL **und** löscht alle bestehenden Push-URLs. Danach müssen die Push-URLs neu gesetzt werden:

```bash
git remote set-url --add --push origin https://github.com/User/MyProject.git
git remote set-url --add --push origin E:\GitUSB\MyProject
```

---

## 12. Siehe auch

- [Git_Standard.md](../../standards/Git_Standard.md) — Git-Konventionen
- [Git Dokumentation](https://git-scm.com/doc) — Offizielle Referenz
- [GitHub Docs](https://docs.github.com) — GitHub-spezifische Funktionen

---

## 13. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **1.1.0** | **2026-03-31** | Abschnitte 6 (Dual-Push), 9 (VS Code) neu; Abschnitte 4.2, 7.3, 11.5–11.7 ergänzt; Inhaltsverzeichnis aktualisiert |
| **1.0.0** | **2025-12-19** | Initial: Konsolidiert aus How_to_create_remote_Git.docx |
