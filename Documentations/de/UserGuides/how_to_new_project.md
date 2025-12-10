# How-To: Neue App oder Library im Solution-System

> **Zweck:** Standardablauf, um ein neues Modul sauber in das Buildsystem einzufügen.  
> **Gilt für:** Executables und Libraries (CONSOLE, GUI, INTERFACE, STATIC/SHARED)  
> **Ziel:** Konsistenz, Reproduzierbarkeit, keine vergessenen Schritte

---
## 1. Schritt – Solution.json Eintrag erstellen (**Pflicht**)

➡ Immer zuerst – bevor überhaupt Code angelegt wird.

### Executable Beispiel
```json
{
  "name": "MyNewApp",
  "version": "0.1.0",
  "type": "CONSOLE",
  "dependencies": ["BasicLogger"]
}
```

### Library Beispiel
```json
{
  "name": "MyNewLibrary",
  "version": "0.1.0",
  "type": "INTERFACE",
  "public_headers": "projects/libs/MyNewLibrary/include"
}
```

#### Hinweise
- Ohne Solution.json → existiert nicht im Buildsystem.
- Pfade optional, sofern Standardstruktur verwendet wird.
- Dependencies und Externals klar halten (keine versteckten Anforderungen).

---
## 2. Schritt – Projekt generieren / Build ausführen

➡ Erst hier erscheint das Modul in Visual Studio / CLion / Ninja

- CMake wird aktualisiert
- Include-Pfade werden gesetzt
- Externals werden geladen/konfiguriert

Falls Fehler → meist liegt’s an Solution.json.

---
## 3. Schritt – Dateien anlegen

### Executable
- `src/main.cpp`
- optional `AppConfig.hpp`

### Library
- `include/<modulname>.hpp`
- optional mehrere Header bei Bedarf

➡ Keine großen Ordnerstrukturen (wie von dir vorgegeben)

---
## 4. Schritt – Dokumentation basierend auf Template erstellen

### Kapitelstruktur gemäß Doku_Template

1. Solution.json-Konfiguration  
2. Überblick  
3. Ziele/Nutzen  
4. Architektur/Aufbau  
5. Nutzung/Initialisierung  
6. Erweiterungen  
7. Wartung/Versionierung  
8. Changelog

➡ Dokumentation schreibt sich damit „von selbst“.

---
## 5. Schritt – Changelog initialisieren

```
## Changelog
- 0.1.0 – Modul erstellt und in Solution.json eingetragen
```

➡ Jede Änderung dokumentieren, nicht nur Code.

---
## Der wichtigste Satz

> **Wenn es nicht in der Solution.json steht, existiert es nicht.**

Dieser Satz soll als Disclaimer in jede Doku.

---
## Zusammenfassung als Short-Cheat

| Schritt | Aktion |
|--------|--------|
| 1 | Solution.json Eintrag schreiben |
| 2 | CMake konfigurieren / generieren |
| 3 | Dateien anlegen |
| 4 | Dokumentation per Template erstellen |
| 5 | Changelog starten |

➡ Reihenfolge einhalten garantiert Funktion, Übersicht & Skalierbarkeit.

