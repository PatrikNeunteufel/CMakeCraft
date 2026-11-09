# Dokumentations-Standard — Sprachen, Versionierung, Paritäts-Hook

> **Version:** 1.0.1
> **Datum:** 2026-11-09
> **Typ:** Standard
> **Status:** Aktiv
> **Sprache:** Deutsch
> **English:** [Doku_Standard.md](../../../en/autorenwerk/standards/Doku_Standard.md)

---

## 1. Sprachen

- **`docs/de/` ist die Führungssprache (SSOT).** Inhaltliche Änderungen passieren **zuerst** dort.
- **`docs/en/`** (und ggf. weitere Sprachen) sind **Übersetzungen** — identische Ordnerstruktur,
  **identischer Dateiname** (der Hook paart über den Pfad!), identische Version.
- Eine fehlende Übersetzung ist erlaubt (der Hook erinnert daran) — eine **veraltete**
  Übersetzung ist der eigentliche Fehler, den dieser Standard verhindert.

## 2. Versionierung im Dokumentkopf

Jedes Dokument beginnt mit dem Standard-Kopf (siehe [Blueprint](../blueprints/Doc.md)):

```markdown
# Titel — Kurzbeschreibung

> **Version:** 1.2.0
> **Datum:** JJJJ-MM-TT
> **Typ:** Guide | Reference | Standard | Concept | Cheatsheet | Index
> **Status:** Entwurf | Aktiv | Abgeschlossen
```

**Regeln:**
- Inhaltliche Änderung am de-Master ⇒ **Version hochzählen** (Semver-Geist:
  Korrekturen = Patch, neue Abschnitte = Minor, Neuausrichtung = Major) + Datum aktualisieren.
- Die Übersetzung übernimmt bei der Nachführung **exakt dieselbe Versionsnummer**.
- `de`-Version ≠ `en`-Version ⇒ Übersetzung ist veraltet (und der Hook meldet es).
- **Der Changelog ist maßgeblich:** Jede Änderung ist ein neuer Changelog-Eintrag mit höherer Nummer; `Version` und
  `Datum` im Kopf sind immer die des jüngsten Eintrags.
- **Die Dokument-Version ist unabhängig von der CMakeCraft-Version.** Ein Dokument darf 1.x tragen, während CMakeCraft
  bei v0.x steht. Die Doku-Fassungen 1.0.0 stammen aus „Release 1“ (newCMake, `2e00db7`, 2025-12-26).
- **Keine CMakeCraft-Version im Kopf.** Doku und Code liegen im selben Repo; der Git-Tag (`vX.Y.Z`) bindet beide.
  Ist ein Verhalten an eine CMakeCraft-Version gebunden, sagt der Text „seit vX.Y.Z“, und der Changelog-Eintrag nennt
  die Version, mit der die Änderung kam (`CMakeCraft v0.14.1: …`).
- **Gemeinsame Major-Nummer ab CMakeCraft v2.0.0:** Das erste Major-Release von CMakeCraft heißt **v2.0.0** (nicht
  v1.0.0). Mit ihm gehen alle Dokumente und alle `.cmake`-Dateien auf 2.0.0. Ab dann teilen Produkt, Doku und Module
  die Major-Nummer: Jedes Major-Release von CMakeCraft hebt alle auf X.0.0; Minor und Patch zählt jede Datei für sich.

## 3. Der Paritäts-Hook

Ein committeter pre-commit-Hook ([.githooks/pre-commit](../../../../.githooks/pre-commit))
prüft bei jedem Commit die im Commit enthaltenen `docs/`-Dateien:

| Situation | Meldung |
|---|---|
| de-Datei committet, en-Version weicht ab | `HINWEIS: Uebersetzung veraltet: docs/en/… (Version <v_en>) != de-Master (Version <v_de>)` |
| de-Datei committet, en-Fassung existiert nicht | `HINWEIS: keine en-Uebersetzung vorhanden fuer: docs/de/…` |
| en-Datei committet, weicht vom de-Master ab | `HINWEIS: docs/en/… (Version <v_en>) weicht vom de-Master ab (Version <v_de>)` |
| en-Datei ohne de-Gegenstück | `HINWEIS: Uebersetzung ohne de-Master (de ist SSOT!): docs/en/…` |

Fehlt die Versionszeile in der en-Fassung, steht `fehlt` an Stelle von `<v_en>`. Gab es mindestens einen
Hinweis, schliesst der Hook mit `(Doku-Versions-Check: nur Hinweise, Commit laeuft weiter)`.

**Der Hook blockiert nie** (exit 0) — er ist ein Erinnerungszettel, kein Türsteher.

### Aktivierung (einmalig pro Klon)

```bash
git config core.hooksPath .githooks
```

Ohne diese Einstellung läuft der Hook nicht (Git führt standardmäßig nur `.git/hooks/` aus,
das nicht versionierbar ist). Hinweis für Autoren des Hooks selbst: Dateien unter `.githooks/`
sind per `.gitattributes` auf **LF** gepinnt — CRLF würde `sh` unter Windows brechen.

## 4. Typischer Arbeitsablauf

1. de-Dokument ändern, **Version + Datum** im Kopf anpassen.
2. Wenn Zeit: en-Fassung gleich nachziehen (gleiche Version). Wenn nicht: einfach committen —
   der Hinweis beim Commit ist die offene-Punkte-Liste.
3. Übersetzungs-Nachzügler findet man jederzeit per Volltextsuche der Hinweise oder mit:
   ```bash
   git config core.hooksPath .githooks   # falls noch nicht aktiv
   git commit --dry-run                  # zeigt anstehende Hinweise ohne Commit
   ```

## 5. Ablage-Regeln (Kurzform)

- Kein Dokument doppelt, keine Versionskopien (`Name050.md`) — **Git ist die Historie.**
- Neue Dokumente nach [INDEX.md](../../../INDEX.md)-Logik einsortieren:
  `guide/` (nutzen) · `konzepte/` (Build-System entwickeln) · `autorenwerk/` (Autoren-Regeln).
- Format/Aufbau eines neuen Dokuments: Vorlage aus [blueprints/](../blueprints/) kopieren.

## 6. Changelog

| Version | Datum | Änderungen |
|---|---|---|
| 1.0.1 | 2026-11-09 | An den Code angeglichen: Hinweise des Paritäts-Hooks (§3) wörtlich wie in `.githooks/pre-commit` (Schreibung `fuer`, Versionsangaben, Schlusszeile); Versionsregeln §2 nach den Entscheiden K1/K2/V2 a: Changelog maßgeblich, Dokument-Version unabhängig von CMakeCraft, keine CMakeCraft-Version im Kopf, gemeinsame Major-Nummer ab CMakeCraft v2.0.0 |
| 1.0.0 | 2026-07-18 | Erste Fassung |
