# CMakeCraft — Dokumentations-Index

> **Version:** 1.0.0
> **Datum:** 2026-07-18
> **Typ:** Index
> **Status:** Aktiv

Die Doku ist nach **Leserrolle** in drei Bereiche geteilt — wer du gerade bist, bestimmt, wo du liest:

| Bereich | Frage | Inhalt |
|---|---|---|
| **[guide/](de/guide/)** | „Ich **nutze** das Build-System" | [userguides/](de/guide/userguides/) (Getting Started, [Neues Projekt](de/guide/userguides/Neues_Projekt_Guide.md), Externals, Testing) · [references/](de/guide/references/) (Solution-Schema, ErrorCodes) · [cheatsheets/](de/guide/cheatsheets/) · [module/](de/guide/module/) (Doku der cmake/-Module) |
| **[konzepte/](de/konzepte/)** | „Ich **ändere** das Build-System" | [Guidelines.md](de/konzepte/Guidelines.md) (Regelwerk für Build-System-Code) · aktive Konzepte (z. B. [Versionierter Bezug](de/konzepte/Konzept_Versionierter_Bezug.md)) · [abgeschlossen/](de/konzepte/abgeschlossen/) (Master-Konzept, Phasen-Konzepte — umgesetzt, Nachschlagewerk) |
| **[autorenwerk/](de/autorenwerk/)** | „Ich **schreibe** Code oder Doku — in *irgendeinem* Projekt" | [blueprints/](de/autorenwerk/blueprints/) (Vorlagen: CppModuleDoc, Guide, Reference, Standard, Concept, Source.cmake, …) · [standards/](de/autorenwerk/standards/) (Coding-Standards C++, C, CMake, Git, Sprache) |

Das **autorenwerk/** ist bewusst projektübergreifend: Jedes Konsumenten-Projekt bekommt es
über den Bootstrap-Fetch versioniert mit (`.externals/cmakecraft/docs/…`) — Projekt-Steckbriefe
können direkt darauf verweisen.

## Sprachregel (Kurzform)

**`de/` ist die Führungssprache (SSOT)**, `en/` ist Übersetzung mit identischem Dateinamen und
**derselben Version** im Dokumentkopf. Ein Commit-Hook meldet Abweichungen (nicht blockierend) —
einmalig aktivieren: `git config core.hooksPath .githooks`.
**Vollständige Regeln inkl. Hook-Anleitung und Arbeitsablauf:**
[autorenwerk/standards/Doku_Standard.md](de/autorenwerk/standards/Doku_Standard.md)

## Sonstiges

- `archive/` (Repo-Root): historische Doku (altes Makefile-Build-System, Research, Vorstände) —
  nur Nachschlagewerk, wird nicht gepflegt.
- Versionierte Dateikopien (`Name050.md` …) gibt es nicht mehr — **Git ist die Historie.**
- Vorlagen zum Kopieren (Source.cmake-Gerüste, App-Skelett): `templates/` im Repo-Root;
  ihr Aufbau ist in [autorenwerk/blueprints/](de/autorenwerk/blueprints/) beschrieben.
