# Standards v0.5.0 — Übersicht

> **Version:** 0.5.0  
> **Datum:** 2025-12-13  
> **Status:** Stabil

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Dateien](#2-dateien)
3. [Beziehungen](#3-beziehungen)
4. [Anwendung](#4-anwendung)
5. [Siehe auch](#5-siehe-auch)

---

## 1. Übersicht

Standards definieren **verbindliche Konventionen** für Entwicklung und Zusammenarbeit. Sie beschreiben das "Was" und "Warum", während Blueprints das "Wie" der Dokumentation regeln.

### Zielgruppe

Alle Entwickler im Unternehmen.

### Durchsetzung

| Mechanismus | Beschreibung |
|-------------|--------------|
| **Automatisch** | clang-format, clang-tidy, Pre-Commit Hooks |
| **Manuell** | Code Review, PR-Checklisten |
| **CI/CD** | Build-Pipeline-Checks |

---

## 2. Dateien

| Datei | Zielgruppe | Geltungsbereich |
|-------|------------|-----------------|
| [Cpp_Coding_Standard.md](Cpp_Coding_Standard.md) | C++ Entwickler | PC-Applikationen |
| [C_Coding_Standard.md](C_Coding_Standard.md) | Embedded-Entwickler | Firmware, MCUs |
| [CMake_Standard.md](CMake_Standard.md) | Alle Entwickler | Build-System |
| [Git_Standard.md](Git_Standard.md) | Alle Entwickler | Versionskontrolle |

> **Hinweis:** Keine Versionen im Dateinamen. Version steht nur im Header.  
> Archivierte Versionen: `Cpp_Coding_Standard_v0_1_0.md` etc.

---

## 3. Beziehungen

```
Standards (Konventionen)              Blueprints (Dokumentation)
========================              =========================

Cpp_Coding_Standard ◄──────────────── Standard.md (Blueprint)
C_Coding_Standard   ◄──────────────── Standard.md (Blueprint)
CMake_Standard      ◄──────────────── Standard.md (Blueprint)
Git_Standard        ◄──────────────── Standard.md (Blueprint)
        │
        │ referenziert
        ▼
ClangFormat_Blueprint ─────────────► .clang-format (Tool-Config)
ClangTidy_Blueprint   ─────────────► .clang-tidy (Tool-Config)
```

### Hierarchie

| Ebene | Dokument | Regelt |
|-------|----------|--------|
| Meta | Standard.md (Blueprint) | Wie Standards geschrieben werden |
| Standard | *_Standard.md | Was getan werden soll |
| Tool-Config | .clang-format, .clang-tidy | Automatische Durchsetzung |

---

## 4. Anwendung

### 4.1 Für Entwickler

| Situation | Relevanter Standard |
|-----------|---------------------|
| Neuen C++ Code schreiben | Cpp_Coding_Standard |
| Embedded-Firmware entwickeln | C_Coding_Standard |
| CMakeLists.txt erstellen | CMake_Standard |
| Commit erstellen | Git_Standard |

### 4.2 Für neue Projekte

1. **CMake_Standard** lesen → Projektstruktur anlegen
2. **Git_Standard** lesen → Repository einrichten
3. **Cpp/C_Coding_Standard** lesen → Code-Stil kennen
4. Tool-Configs kopieren (`.clang-format`, `.clang-tidy`)

### 4.3 Quick Reference

| Thema | Standard | Abschnitt |
|-------|----------|-----------|
| Namenskonventionen (C++) | Cpp_Coding_Standard | §5 |
| Namenskonventionen (C) | C_Coding_Standard | §5 |
| Commit-Message-Format | Git_Standard | §3 |
| Branch-Strategie | Git_Standard | §4 |
| CMake Target-Namen | CMake_Standard | §4 |
| RAII | Cpp_Coding_Standard | §6.3 |
| Error-Handling (C) | C_Coding_Standard | §9 |

---

## 5. Siehe auch

- [blueprints/Standard.md](../blueprints/Standard.md) — Blueprint für Standards
- [blueprints/README.md](../blueprints/README.md) — Blueprint-Übersicht
- [ClangFormat_Blueprint.md](../blueprints/ClangFormat_Blueprint.md) — Formatierung
- [ClangTidy_Blueprint.md](../blueprints/ClangTidy_Blueprint.md) — Statische Analyse

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.5.0** | **2025-12-13** | **Initial: Migration aller Standards auf v0.5.0 Format** |
