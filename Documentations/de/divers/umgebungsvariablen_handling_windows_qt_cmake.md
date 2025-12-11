# Environment Variables on Windows (CMD & PowerShell)

## Ziel dieses Dokuments
Dieses Dokument beschreibt **Best Practices zum Setzen, Verwalten und Warten von Umgebungsvariablen unter Windows**, mit besonderem Fokus auf **Qt- und CMake-basierte C++-Projekte**.

Schwerpunkte:
- reproduzierbare Builds
- minimale globale Seiteneffekte
- saubere Wartbarkeit über mehrere Projekte hinweg

---

## 1. Grundverständnis: Scopes von Umgebungsvariablen

Windows kennt drei relevante Ebenen:

1. **Process (Session)**  
   Gültig nur für das aktuell laufende Terminal (CMD / PowerShell) und dessen Kindprozesse.

2. **User**  
   Persistent für den aktuell angemeldeten Benutzer.

3. **System**  
   Persistent für alle Benutzer und Dienste.

**Priorität:**
```
Process > User > System
```

Änderungen an User- oder System-Variablen wirken **nicht rückwirkend** auf bereits laufende Prozesse (Terminal, IDE, Build-Tools).

---

## 2. Grundprinzipien für sauberes Environment-Management

### 2.1 Weniger global ist besser

Empfohlene Reihenfolge:
1. Projektlokale Konfiguration (CMakePresets, env.bat)
2. Session-lokale Variablen (Terminal)
3. User-Variablen
4. System-Variablen (nur wenn zwingend nötig)

Je globaler eine Variable ist, desto größer:
- das Risiko versteckter Abhängigkeiten
- die Wahrscheinlichkeit für Versionskonflikte

---

## 3. Qt & CMake: Welche Variablen sind sinnvoll?

### 3.1 `CMAKE_PREFIX_PATH` (empfohlen)

CMake-Standardmechanismus zur Paketauflösung (inkl. Qt).

Beispiel Qt-Pfad:
```
C:\Qt\6.7.0\msvc2022_64
```

**CMD (nur Session):**
```
set CMAKE_PREFIX_PATH=C:\Qt\6.7.0\msvc2022_64
```

**PowerShell (nur Session):**
```
$env:CMAKE_PREFIX_PATH = "C:\Qt\6.7.0\msvc2022_64"
```

---

### 3.2 `Qt6_DIR` (explizit, aber enger)

Direkter Verweis auf das Qt-CMake-Paket:
```
<QtRoot>\lib\cmake\Qt6
```

**CMD:**
```
set Qt6_DIR=C:\Qt\6.7.0\msvc2022_64\lib\cmake\Qt6
```

Geeignet, wenn mehrere Qt-Versionen parallel existieren.

---

### 3.3 `QT_ROOT` (eigene Konvention)

Kein offizieller CMake-Standard, aber nützlich als Alias.

```
set QT_ROOT=C:\Qt\6.7.0\msvc2022_64
cmake -S . -B build -DCMAKE_PREFIX_PATH=%QT_ROOT%
```

Empfehlung: **nur verwenden, wenn konsistent dokumentiert**.

---

## 4. CMD: Umgebungsvariablen verwalten

### Setzen (Session)
```
set QT_ROOT=C:\Qt\6.7.0\msvc2022_64
```

### Anzeigen
```
echo %QT_ROOT%
```

### Existenz prüfen
```
if defined QT_ROOT echo QT_ROOT ist gesetzt
```

### Löschen (Session)
```
set QT_ROOT=
```

### Alle Variablen anzeigen
```
set
```

### Filtern
```
set QT
set CMAKE
```

---

## 5. PowerShell: Umgebungsvariablen verwalten

### Setzen (Session)
```
$env:QT_ROOT = "C:\Qt\6.7.0\msvc2022_64"
```

### Anzeigen
```
$env:QT_ROOT
```

### Löschen
```
Remove-Item Env:QT_ROOT
```

### Auflisten
```
Get-ChildItem Env:
```

### Filtern
```
Get-ChildItem Env: | Where-Object Name -like "*QT*"
```

---

## 6. Persistente Variablen (User / System)

### 6.1 Empfohlen: GUI

```
rundll32 sysdm.cpl,EditEnvironmentVariables
```

Vorteile:
- zuverlässig
- keine Seiteneffekte
- klar sichtbar

Nach Änderungen: **Terminal / IDE neu starten**.

---

### 6.2 `setx` (mit Vorsicht)

```
setx QT_ROOT "C:\Qt\6.7.0\msvc2022_64"
```

Nachteile:
- wirkt nicht auf aktuelle Sessions
- mögliche Kürzung langer Werte (PATH)
- Löschen nur indirekt (`setx VAR ""`)

Empfehlung: nur für einfache, kurze Variablen verwenden.

---

## 7. Wartbare Projekt-Patterns

### 7.1 `env.bat` pro Projekt

```
@echo off
set QT_ROOT=C:\Qt\6.7.0\msvc2022_64
set CMAKE_PREFIX_PATH=%QT_ROOT%
echo QT_ROOT=%QT_ROOT%
cmd /k
```

Vorteile:
- reproduzierbar
- keine globalen Effekte
- onboarding-freundlich

---

### 7.2 CMakePresets.json (Best Practice)

```
{
  "version": 6,
  "configurePresets": [
    {
      "name": "ninja-debug",
      "generator": "Ninja",
      "binaryDir": "${sourceDir}/build",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Debug",
        "CMAKE_PREFIX_PATH": "C:/Qt/6.7.0/msvc2022_64"
      }
    }
  ]
}
```

Build:
```
cmake --preset ninja-debug
cmake --build --preset ninja-debug
```

---

### 7.3 Versionswechsel ohne Chaos

```
QT_CURRENT -> C:\Qt\6.7.0\msvc2022_64
```

Nur ein Alias wird angepasst, alle Builds bleiben stabil.

---

## 8. Debugging bei Problemen

### 8.1 Aktuelles Environment prüfen

CMD:
```
echo %CMAKE_PREFIX_PATH%
where cmake
```

### 8.2 CMake-Cache bereinigen

```
rmdir /s /q build
```

### 8.3 IDE neu starten

Nach Änderungen an persistenten Variablen zwingend erforderlich.

---

## 9. Empfohlene Gesamtstrategie

- **CMakePresets.json** für alles, was geteilt oder versioniert wird
- `env.bat` für lokale Workflows
- User-Variablen nur für stabile Toolchains
- System-Variablen möglichst vermeiden

---

## 10. Referenzen

- Microsoft `set`:
  https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/set_1

- Microsoft `setx`:
  https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/setx

- CMake `CMAKE_PREFIX_PATH`:
  https://cmake.org/cmake/help/latest/variable/CMAKE_PREFIX_PATH.html

- Qt & CMake:
  https://doc.qt.io/qt-6/cmake-manual.html

