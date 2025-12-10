# Error Codes – CMake Architecture V2

> **Version:** 0.1.1  
> **Datum:** 2025-12-09  
> **Typ:** Referenz-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Basiert auf:** master_concept v0.1, Solution_Schema v0.1  
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/References/ErrorCodes_v0_1_1.md)

Dieses Dokument enthält alle Fehlercodes des CMake Build-Systems mit Erklärungen und Lösungsvorschlägen.

---

## 1. Übersicht

Das Build-System verwendet einheitliche Fehlercodes für konsistente und verständliche Fehlermeldungen. Jeder Code besteht aus einem Präfix (E für Error, W für Warning) und einer dreistelligen Nummer.

---

## 2. Fehlercode-Konvention

| Bereich | Codes | Beschreibung |
|---------|-------|--------------|
| JSON/Parsing | `E0xx` | Fehlende Pflichtfelder, ungültiges JSON |
| Target-Erstellung | `E1xx` | Target existiert bereits, Abhängigkeit fehlt, Source.cmake fehlt |
| Externals | `E2xx` | Fetch fehlgeschlagen, Include.cmake fehlt, Hooks fehlen |
| Deprecation | `W0xx` | Veraltete Features/Syntax |
| Konfiguration/Validation | `W1xx` | Suboptimale Einstellungen, Schema-Validierung |
| Tools/Setup | `W2xx` | Fehlende Tools, Build-Umgebung |
| Assertions | `ASSERT` | Interne Fehler (sollten nicht auftreten) |

---

## 3. Fatal Errors (Build bricht ab)

### 3.1 E0xx – JSON/Parsing Errors

#### E001 – Pflichtfeld fehlt

**Beschreibung:** Ein erforderliches Feld in der Solution.json fehlt.

**Beispiel:**
```
[E001] Executable 'MyApp' hat kein 'name' Feld
```

**Lösung:**
```json
{
    "name": "MyApp",
    "path": "src/apps/myapp"
}
```

---

#### E002 – Solution.json nicht gefunden

**Beschreibung:** Die Solution.json Datei existiert nicht im Projekt-Root.

**Lösung:**
- Stelle sicher, dass `Solution.json` im Projekt-Root liegt
- Prüfe Schreibweise (Groß-/Kleinschreibung)

---

#### E010 – External nicht in externals-Block definiert

**Beschreibung:** Ein Executable/Library referenziert ein External, das nicht im zentralen `externals`-Block definiert ist.

**Beispiel:**
```
[E010] External 'imgui' nicht in externals-Block definiert
```

**Lösung:**
```json
{
    "externals": {
        "imgui": {
            "git": "https://github.com/ocornut/imgui.git",
            "tag": "v1.90.1"
        }
    }
}
```

---

#### E012 – External-Source-Feld Fehler

**Beschreibung:** Ein External hat entweder kein Source-Feld (path/git) oder mehrere gleichzeitig.

**Beispiel:**
```
[E012] External 'mylib': Kein Source-Feld (path/git) angegeben
[E012] External 'mylib': Mehrere Source-Felder angegeben (nur eines erlaubt)
```

**Lösung:** Genau EIN Source-Feld pro External (path ODER git).

---

### 3.2 E1xx – Target-Erstellung Errors

#### E101 – Abhängigkeit existiert nicht

**Beschreibung:** Ein Target referenziert eine interne Abhängigkeit (Library), die nicht existiert.

**Lösung:** Library in Solution.json definieren oder Schreibfehler korrigieren.

---

#### E102 – Target existiert bereits

**Beschreibung:** Ein Target mit diesem Namen wurde bereits erstellt.

**Lösung:** Target-Namen müssen über Libraries, Executables UND Tests hinweg eindeutig sein.

---

#### E103 – Zirkuläre Abhängigkeit

**Beschreibung:** Eine zirkuläre Abhängigkeit zwischen Targets wurde erkannt (A → B → C → A).

**Lösung:** Gemeinsamen Code in separate Library extrahieren.

---

#### E104 – Source.cmake nicht gefunden

**Beschreibung:** Der Source-Mode ist `explicit` und das Source-Verzeichnis enthält keine `Source.cmake` Datei.

**Lösung:** Source.cmake erstellen oder Mode auf `auto` ändern.

---

### 3.3 E2xx – Externals Errors

#### E201 – Fetched External: Kein Target in Registry

**Beschreibung:** Ein gefetchtes External wurde geladen, aber es wurde kein CMake-Target gefunden.

**Beispiel:**
```
[E201] Fetched external 'mylib': Kein Target in Registry
```

**Lösung:**
1. Prüfe ob das External ein CMake-Projekt ist
2. Erstelle ggf. einen PostFetch-Hook
3. Oder verwende lokales External mit eigenem Include.cmake

---

#### E202 – External Fetch fehlgeschlagen

**Beschreibung:** Das Klonen/Fetchen eines Git-Repositories ist fehlgeschlagen.

**Lösung:**
- Netzwerkverbindung prüfen
- URL in Solution.json prüfen
- Tag/Branch existiert?

---

#### E213 – Lokales External: Include.cmake nicht gefunden

**Beschreibung:** Ein lokales External hat keine Include.cmake Datei.

**Lösung:** Datei erstellen: `externals/${name}/Include.cmake`

---

#### E214 – Lokales External: Pfad existiert nicht

**Beschreibung:** Der angegebene Pfad für ein lokales External existiert nicht.

**Lösung:** Pfad in Solution.json prüfen.

---

#### E215 – Fetched External: Kein tag/branch/commit

**Beschreibung:** Ein External mit `git` hat weder `tag`, `branch` noch `commit` angegeben.

**Lösung:** Eines von `tag`, `branch` oder `commit` angeben.

---

#### E216 – Explizit angegebener Hook nicht gefunden

**Beschreibung:** Ein in der Solution.json explizit angegebener Hook existiert nicht.

**Lösung:** Hook-Datei erstellen oder Hook-Angabe entfernen.

---

#### E217 – PostFetch Hook erforderlich aber nicht vorhanden

**Beschreibung:** Ein External hat `cmakeSupport: false`, aber es gibt keinen PostFetch Hook der Targets erstellt.

**Beispiel:**
```
[E217] External 'imgui': PostFetch hook required (cmakeSupport=false) but not found
```

**Lösung:**
1. PostFetch Hook erstellen: `cmake/externals/Hooks/PostFetch/${name}.cmake`
2. Oder `cmakeSupport: true` setzen (wenn External doch CMakeLists.txt hat)

---

## 4. Warnings (Build läuft weiter)

### 4.1 W0xx – Deprecation Warnings

#### W001 – Veraltetes Schema

**Beschreibung:** Die Solution.json verwendet ein veraltetes Schema.

---

#### W002 – Veraltete Syntax/Feld

**Beschreibung:** Ein Feld oder Syntax wird in Zukunft entfernt.

---

### 4.2 W1xx – Konfiguration/Validation Warnings

#### W101 – Suboptimale Konfiguration

**Beispiele:**
- Keine Source-Dateien gefunden
- PCH aktiviert aber Header nicht gefunden

---

#### W103 – Include.cmake erstellt Executables

**Beschreibung:** Eine Include.cmake eines Externals erstellt Executable-Targets (IDE Clutter).

---

#### W104 – Include.cmake bindet Beispiele ein

**Beschreibung:** Eine Include.cmake bindet Beispiel- oder Test-Verzeichnisse ein.

---

#### W105 – Version nicht SemVer-konform

**Korrektes Format:** `MAJOR.MINOR.PATCH` (z.B. `1.0.0`)

---

#### W109 – C++20 Module verwendet

**Beschreibung:** Das Target verwendet C++20 Module Interface Units, die noch experimentell sind.

---

#### W110 – GLOB-Fallback aktiv

**Beschreibung:** Keine Source.cmake gefunden, GLOB wird als Fallback verwendet.

---

### 4.3 W2xx – Tools/Setup Warnings

#### W201 – Clang-Tidy nicht gefunden

**Beschreibung:** `ENABLE_CLANG_TIDY=ON` ist gesetzt, aber clang-tidy wurde nicht gefunden.

---

## 5. Schnellreferenz

### Fatal Errors (E)

| Code | Kurzbeschreibung |
|------|------------------|
| E001 | Pflichtfeld fehlt |
| E002 | Solution.json nicht gefunden |
| E010 | External nicht im externals-Block |
| E012 | Kein/mehrere Source-Felder |
| E101 | Abhängigkeit existiert nicht |
| E102 | Target existiert bereits |
| E103 | Zirkuläre Abhängigkeit |
| E104 | Source.cmake nicht gefunden (mode=explicit) |
| E201 | Fetched External: kein Target in Registry |
| E202 | External Fetch fehlgeschlagen |
| E213 | Lokales External: Include.cmake fehlt |
| E214 | Lokales External: Pfad existiert nicht |
| E215 | Fetched External: kein tag/branch/commit |
| E216 | Explizit angegebener Hook fehlt |
| **E217** | **PostFetch Hook erforderlich (cmakeSupport=false)** |

### Warnings (W)

| Code | Kurzbeschreibung |
|------|------------------|
| W001 | Veraltetes Schema |
| W002 | Veraltete Syntax/Feld |
| W101 | Suboptimale Konfiguration |
| W103 | Include.cmake erstellt Executables |
| W104 | Include.cmake bindet Beispiel-Verzeichnisse ein |
| W105 | Version nicht SemVer-konform |
| W109 | C++20 Module verwendet (experimentell) |
| W110 | GLOB-Fallback aktiv |
| W201 | Clang-Tidy nicht gefunden |

---

## 6. Siehe auch

- [master_concept](../Concepts/master_concept_v0_1_0.md) – Architektur-Referenz
- [Solution_Schema](Solution_Schema_v0_1_0.md) – Vollständige Schema-Dokumentation
- [HookLoader.cmake](../Modules/Externals/HookLoader_cmake_v0_1_0_doc_v1.md) – Hook-System

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.1** | **2025-12-09** | **E217 hinzugefügt (PostFetch Hook required for cmakeSupport=false)** |
| 0.1.0 | 2025-12-03 | Initial (Clean Start): Alle Codes aus v1.4 |
