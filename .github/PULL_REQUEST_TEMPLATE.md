# Pull Request

## Was ändert sich und warum?

<!-- Kurz und konkret. Beispiel: "Ein Local External mit Backslashes im path
     wurde still als nicht vorhanden behandelt — E214 statt eines Hinweises auf
     die Pfadschreibweise." -->

## Zugehöriges Issue

<!-- Closes #123 — bitte ausfüllen, falls vorhanden. Für Änderungen am
     Solution.json-Schema ist ein vorheriges Issue Pflicht. -->

## Art der Änderung

- [ ] Fehlerbehebung im Build-System
- [ ] Neue Funktion
- [ ] Änderung am `Solution.json`-Schema
- [ ] Dokumentation
- [ ] Aufräumen ohne Verhaltensänderung

## Checkliste

- [ ] `cmake --preset craft-selftest` läuft ohne Fehler durch
- [ ] Die Demo-Solution konfiguriert **und** baut mit mindestens einem Preset
      (welchem: …)
- [ ] Neues Verhalten hat einen Phasentest
- [ ] Neue/geänderte Fehlercodes stehen in `cmake/core/Errors.cmake` **und** in
      `docs/de/guide/references/ErrorCodes.md`
- [ ] Betroffene Modul-Doku unter `docs/de/guide/module/` ist nachgezogen
- [ ] Build-System-Module referenzieren `${CMAKECRAFT_DIR}`, nicht
      `${CMAKE_SOURCE_DIR}/cmake/…`
- [ ] Keine absoluten Pfade, keine lokalen Eigenheiten
- [ ] Keine Binärdateien, kein fremdes Material — bei übernommenem Fremdcode:
      Herkunft im Dateikopf **und** Eintrag in `THIRD_PARTY_NOTICES.md`

## Bei Änderungen am `Solution.json`-Schema

- [ ] Neue Felder sind optional und haben einen sinnvollen Standardwert
- [ ] Bestehende Felder wurden nicht umbenannt oder in ihrer Bedeutung verschoben
- [ ] `docs/de/guide/references/Solution_Schema.md` ist nachgezogen
- [ ] `docs/de/guide/cheatsheets/Solution_Cheatsheet.md` ist nachgezogen
- [ ] `templates/Solution.json` zeigt das neue Feld, falls es allgemein nützlich ist

<!-- Bestehende Projekte ziehen ihren cmakecraft.pin irgendwann hoch. Was
     passiert dann mit einer Solution.json, die dein neues Feld nicht kennt? -->

## Womit hast du es geprüft?

<!-- Betriebssystem, Compiler, Generator, verwendete Presets. Und falls du eine
     eigene Solution.json zum Testen gebaut hast: gern hier hineinkopieren. -->

## Worauf soll ich beim Review besonders schauen?

<!-- Optional, aber hilfreich. -->
