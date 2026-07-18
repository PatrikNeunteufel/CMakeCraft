# Dokumentations-Standard — Sprachen, Versionierung, Paritäts-Hook

> **Version:** 1.0.0
> **Datum:** 2026-07-18
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

## 3. Der Paritäts-Hook

Ein committeter pre-commit-Hook ([.githooks/pre-commit](../../../../.githooks/pre-commit))
prüft bei jedem Commit die im Commit enthaltenen `docs/`-Dateien:

| Situation | Meldung |
|---|---|
| de-Datei committet, en-Version weicht ab | `HINWEIS: Uebersetzung veraltet: … != de-Master` |
| de-Datei committet, en-Fassung existiert nicht | `HINWEIS: keine en-Uebersetzung vorhanden für: …` |
| en-Datei committet, weicht vom de-Master ab | `HINWEIS: … weicht vom de-Master ab` |
| en-Datei ohne de-Gegenstück | `HINWEIS: Uebersetzung ohne de-Master (de ist SSOT!)` |

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
