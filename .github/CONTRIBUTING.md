# Zu CMakeCraft beitragen

Danke fürs Interesse! CMakeCraft ist ein Einzelentwickler-Projekt — Beiträge
sind willkommen, aber lies bitte zuerst die zwei Abschnitte unten. Sie sparen
dir möglicherweise vergebliche Arbeit.

## Bevor du anfängst

**Der Selbsttest ist der Einstieg.** Bevor du etwas änderst, lass ihn einmal
laufen:

```bash
cmake --preset craft-selftest
```

Läuft das ohne Fehler durch, ist deine Umgebung in Ordnung. Anleitung und
Voraussetzungen: [BUILDING.md](../BUILDING.md).

**`Solution.json` ist eine öffentliche Schnittstelle.** Jede Änderung am Schema
betrifft jedes Projekt, das CMakeCraft nutzt — und zwar in dem Moment, in dem es
seinen Pin hochzieht. Für Schema-Änderungen deshalb **immer erst ein Issue**.
Neue Felder müssen optional sein und einen sinnvollen Standardwert haben;
bestehende Felder werden nicht umbenannt.

**Für alles außer Tippfehlern: erst ein Issue, dann Code.** Vieles im
Build-System sieht nach einer Vereinfachungsmöglichkeit aus und ist in
Wirklichkeit eine Reaktion auf eine Eigenart von CMake oder von Visual Studio.
Ein kurzes Issue vorab klärt das schneller als ein fertiger Pull Request.

**Lizenz deines Beitrags.** Mit dem Einreichen stellst du deinen Beitrag unter
dieselbe Dual-Lizenz wie CMakeCraft (MIT **oder** Apache-2.0), sofern du nicht
ausdrücklich etwas anderes erklärst.

**Kein fremdes Material einreichen.** Fremder Code — auch einzelne Funktionen
aus Stack-Overflow-Antworten oder anderen Build-Systemen — braucht eine
Herkunftsangabe im Dateikopf und einen Eintrag in
[THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md). Vorkompilierte
Bibliotheken (`.lib`, `.dll`, `.so`, `.a`) gehören grundsätzlich nicht ins
Repository, auch nicht als Testmaterial.

## Womit du am meisten hilfst

- **Plattformen außer Windows.** Linux und macOS werden nicht regelmäßig
  durchgebaut. Baufehler dort sind echte Befunde.
- **Fehlermeldungen, die nicht weiterhelfen.** Der Anspruch ist, dass ein
  Fehler sagt, *was* falsch ist und *wo*. Wo dir stattdessen CMake-Innenleben
  entgegenkommt, ist das ein Fehler — auch wenn das Build-System technisch
  richtig reagiert.
- **Lücken in der Dokumentation.** Besonders im
  [Neues_Projekt_Guide](../docs/de/guide/userguides/Neues_Projekt_Guide.md): Er
  ist der Weg, den jeder neue Nutzer geht. Jede Stelle, an der du hängen
  geblieben bist, ist eine Meldung wert.
- **Neue Phasentests.** Ein Test, der ein Verhalten festnagelt, bevor es jemand
  versehentlich ändert, ist mehr wert als eine neue Funktion.

## Konventionen

Verbindlich sind zwei Dokumente. Bei Widersprüchen gewinnt das erste:

| Dokument | Inhalt |
|---|---|
| [docs/de/konzepte/Guidelines.md](../docs/de/konzepte/Guidelines.md) | die Hausordnung **dieses** Build-Systems: Dateikopf, Include Guards, Namensschemata, Fehlercodes, Pipelines, Local-Externals-Vertrag |
| [docs/de/autorenwerk/standards/CMake_Standard.md](../docs/de/autorenwerk/standards/CMake_Standard.md) | allgemeine CMake-Richtlinien, projektunabhängig: Modern CMake, Target-basiert, keine harten Pfade |

Das Wichtigste in Kürze:

| Thema | Regel |
|---|---|
| **Dateikopf** | Standard-Header nach Guidelines §2.1 — Pfad, Zweck, Version, Datum, Status, Abhängigkeiten |
| **Include Guard** | `include_guard(GLOBAL)` in jedem Modul |
| **Interne Funktionen** | Präfix `_` (z. B. `_attach_local_external`), öffentliche ohne |
| **Interne Variablen** | Präfix `_` — CMake kennt keine Sichtbarkeit, das Präfix ist die einzige Trennung |
| **Fehler** | `cmake_fatal("E2xx" "…")` / `cmake_warn("W1xx" "…")` — nie `message(FATAL_ERROR)` direkt |
| **Neue Fehlercodes** | in `cmake/core/Errors.cmake` eintragen **und** in [ErrorCodes.md](../docs/de/guide/references/ErrorCodes.md) dokumentieren |
| **Dateinamen** | `phase*.cmake` und die Externals-Unterordner (`core`, `fetched`, `local`, `system`, `hooks`, `registry`, `includes`) sind **kleingeschrieben** — Linux unterscheidet Groß-/Kleinschreibung |
| **Hook-Dateien** | heißen exakt wie der External-Schlüssel in `Solution.json` (z. B. `qt-ads.cmake`) |
| **Ortsbezug** | Build-System-Module immer über `${CMAKECRAFT_DIR}`, **nie** `${CMAKE_SOURCE_DIR}/cmake/…` oder relatives `include(cmake/…)`. Projektbezogenes (`Solution.json`, `projects/`, `externals/`) bleibt am `CMAKE_SOURCE_DIR` |
| **Preset-Schema** | bleibt bei Version 6 — Visual Studio kann v2–v9, nicht v10 |
| **Preset-JSONs** | ohne Kommentare (VS kommt damit nicht zurecht) — Erklärungen gehören in `displayName`/`description` |
| **Versionierte Kopien** | keine (`Solution100a.cmake`, `Modul_v2.md`) — Git ist die Historie |

Die Dokumentation ist auf **Deutsch** (`docs/de/` ist die Führungsfassung),
Bezeichner im CMake-Code auf **Englisch**. `docs/en/` ist die Übersetzung; ein
Git-Hook weist auf Versionsabweichungen hin:

```bash
git config core.hooksPath .githooks
```

Für neue Dokumente gibt es Vorlagen unter
[docs/de/autorenwerk/blueprints/](../docs/de/autorenwerk/blueprints/) — je eine
pro Dokumenttyp (Guide, Reference, Concept, Standard, ModuleDoc, Cheatsheet).
Halte dich an den Typ, der zu deinem Text passt; das hält die Doku
durchsuchbar.

## Pull Requests

Vor dem Absenden:

1. `cmake --preset craft-selftest` läuft ohne Fehler durch
2. Die Demo-Solution konfiguriert **und** baut mit mindestens einem Preset
3. Neues Verhalten hat einen Phasentest
4. Neue oder geänderte Fehlercodes stehen in `Errors.cmake` **und** in `ErrorCodes.md`
5. Betroffene Modul-Doku unter `docs/de/guide/module/` ist nachgezogen
6. Keine absoluten Pfade, keine lokalen Eigenheiten

Ändert dein Beitrag das `Solution.json`-Schema, gehört zusätzlich dazu:
`docs/de/guide/references/Solution_Schema.md`, das Cheatsheet und — falls
sinnvoll — ein Eintrag in `templates/Solution.json`.

## Verhalten

Es gilt der [Verhaltenskodex](CODE_OF_CONDUCT.md).

## Fragen?

[Issue eröffnen](https://github.com/PatrikNeunteufel/CMakeCraft/issues) — dafür
gibt es eine eigene Vorlage „Frage".
