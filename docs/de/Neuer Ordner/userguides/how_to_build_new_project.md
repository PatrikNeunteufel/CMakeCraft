# Neue App oder Library erstellen — Benutzerhandbuch

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Typ:** Guide  
> **Status:** Stabil  
> **Zielgruppe:** C++ Entwickler  
> **Basiert auf:** Guide v0.5  
> **Sprache:** Deutsch  
> **English:** [how_to_build_new_project.md](../en/guides/how_to_build_new_project.md)

---

## Inhaltsverzeichnis

1. [Überblick](#1-überblick)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Schnellstart](#3-schnellstart)
4. [Schritt-für-Schritt Anleitung](#4-schritt-für-schritt-anleitung)
5. [Stolpersteine und Lösungen](#5-stolpersteine-und-lösungen)
6. [Troubleshooting](#6-troubleshooting)
7. [Siehe auch](#7-siehe-auch)
8. [Changelog](#8-changelog)

---

## 1. Überblick

Dieses Handbuch beschreibt den Standardablauf, um ein neues Modul (Executable oder Library) sauber in das Build-System einzufügen.

### Der wichtigste Satz

> **Wenn es nicht in der Solution.json steht, existiert es nicht.**

### Ablauf

```
1. Solution.json Eintrag erstellen
2. CMake konfigurieren / generieren
3. Dateien anlegen
4. Dokumentation erstellen
5. Changelog starten
```

---

## 2. Voraussetzungen

- [ ] CMake Architecture V2 Build-System
- [ ] Kenntnisse über Solution.json Schema
- [ ] Zieltyp bekannt (CONSOLE, GUI, STATIC, INTERFACE)

---

## 3. Schnellstart

**1. Solution.json Eintrag:**

```json
{
    "executables": [
        {
            "name": "MyNewApp",
            "version": "0.1.0",
            "type": "CONSOLE"
        }
    ]
}
```

**2. CMake konfigurieren:**

```bash
cmake --preset windows-ninja-debug
```

**3. main.cpp erstellen:**

```cpp
// projects/demos/exec/MyNewApp/src/main.cpp
#include <iostream>

int main() {
    std::cout << "Hello from MyNewApp!" << std::endl;
    return 0;
}
```

**4. Bauen:**

```bash
cmake --build out/build/windows-ninja-debug --target MyNewApp
```

---

## 4. Schritt-für-Schritt Anleitung

### 4.1 Solution.json Eintrag erstellen (Pflicht)

**Immer zuerst** – bevor überhaupt Code angelegt wird.

#### Executable Beispiel

```json
{
    "name": "MyNewApp",
    "version": "0.1.0",
    "type": "CONSOLE",
    "dependencies": ["CoreLib"]
}
```

#### Library Beispiel

```json
{
    "name": "MyNewLibrary",
    "version": "0.1.0",
    "type": "INTERFACE",
    "public_headers": "projects/libs/MyNewLibrary/include"
}
```

#### Hinweise

- Ohne Solution.json → existiert nicht im Build-System
- Pfade optional, sofern Standardstruktur verwendet wird
- Dependencies und Externals klar halten

### 4.2 CMake konfigurieren

Erst hier erscheint das Modul in Visual Studio / CLion / Ninja.

```bash
cmake --preset windows-ninja-debug
```

**Was passiert:**
- CMake wird aktualisiert
- Include-Pfade werden gesetzt
- Externals werden geladen/konfiguriert

Falls Fehler → meist liegt's an Solution.json.

### 4.3 Dateien anlegen

#### Executable

```
projects/demos/exec/MyNewApp/
└── src/
    └── main.cpp
```

#### Library

```
projects/libs/MyNewLibrary/
├── include/
│   └── MyNewLibrary/
│       └── MyClass.hpp
└── src/
    └── MyClass.cpp
```

### 4.4 Dokumentation erstellen

Erstelle eine README.md mit folgender Struktur:

1. Solution.json-Konfiguration
2. Überblick
3. Ziele/Nutzen
4. Architektur/Aufbau
5. Nutzung/Initialisierung
6. Erweiterungen
7. Wartung/Versionierung
8. Changelog

### 4.5 Changelog initialisieren

```markdown
## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **YYYY-MM-DD** | **Modul erstellt und in Solution.json eingetragen** |
```

---

## 5. Stolpersteine und Lösungen

### 5.1 Target wird nicht gebaut

**Problem:** CMake generiert, aber Target erscheint nicht.

**Lösung:** Prüfen ob Solution.json korrekt ist und CMake neu konfigurieren.

### 5.2 Include-Pfade falsch

**Problem:** Header werden nicht gefunden.

**Lösung:** `public_headers` in Solution.json prüfen.

### 5.3 Dependencies nicht gelinkt

**Problem:** Linker-Fehler bei Verwendung anderer Libraries.

**Lösung:** Library in `dependencies` Array aufnehmen.

---

## 6. Troubleshooting

### Checkliste

- [ ] Eintrag in Solution.json vorhanden?
- [ ] CMake neu konfiguriert nach Änderung?
- [ ] Source-Dateien im richtigen Verzeichnis?
- [ ] Dependencies korrekt angegeben?

### Häufige Fehler

| Fehler | Lösung |
|--------|--------|
| Target nicht gefunden | Solution.json prüfen |
| Header nicht gefunden | Pfade prüfen |
| Linker-Fehler | Dependencies prüfen |

### Short-Cheat

| Schritt | Aktion |
|---------|--------|
| 1 | Solution.json Eintrag schreiben |
| 2 | CMake konfigurieren / generieren |
| 3 | Dateien anlegen |
| 4 | Dokumentation per Template erstellen |
| 5 | Changelog starten |

---

## 7. Siehe auch

- [Solution_Schema](../reference/Solution_Schema.md) — JSON-Schema
- [Externals UserGuide](Externals_UserGuide.md) — Externe Libraries
- [Testing UserGuide](Testing_UserGuide.md) — Tests erstellen

---

## 8. Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Migration auf Guide v0.5 Blueprint** |
| 0.1.0 | 2025-12-09 | Initial |
