# HALTEPUNKT 2026-11-09 19:34 — CMakeCraft_Session10_2026-11-09_sync-lesen (aufgenommen 2026-11-09 20:06)

> Pause, kein Abschluss — weiter in derselben Session mit `/session-pause weiter`.
> Der Steckbrief nennt kein Handover, deshalb liegt der Haltepunkt hier im Projekt-Root (Fallback).

## Angehalten — beim Weitermachen neu starten

- **Sync-Wächter `sync_hoertest`, Prefix CC** (Hintergrundaufgabe `bzj9g8b2z`, gestoppt). Zweck: weckt die Session,
  wenn HT oder LV antworten. Beim Halt war nichts Ungelesenes da. Neu starten (Bash, `run_in_background`):

  ```bash
  for i in $(seq 1 180); do
    out=$(powershell -NoProfile -ExecutionPolicy Bypass -File "C:/Users/patri/source/repos/Visuals_Project/cmake/sync_hoertest/tools/sync_check.ps1" -Side CC 2>&1)
    if [ -n "$out" ]; then echo "$out"; exit 0; fi
    sleep 60
  done
  echo "Waechter beendet, nichts eingetroffen."
  ```

- Sonst war nichts aktiv: keine Agenten, Workflows, Server oder Bauten.

## Stand

- **Code:** unverändert. CMakeCraft steht auf `v0.14.0` (`8b68d25`). Ungetrackt ist nur
  `docs/report/SESSION_REPORT_2026-11-07.md`. Kein Bau nötig.
- **Geändert in dieser Sitzung, nicht versioniert:**
  - `.claude/settings.json`: Hook für `sync_hoertest` in `SessionStart` und `UserPromptSubmit` ergänzt.
  - `CLAUDE.md`, Steckbrief: Zeile zu `../sync_hoertest`.
- **Sync-Verzeichnis `../sync_hoertest`:** CC ist Teilnehmer (Leitung HT). Die CC-Hälfte steht in `STATUS.md`.
- **Sync-Nachrichten von CC:**
  - `CC-20261109-1851-…`: Beitritt und Fragen F1–F3.
  - `CC-20261109-1917-…`: Befund CC-2. Das Paket lässt sich aus einem Pfad mit „ö“ schnüren; `sha256sum -c` OK, LF,
    Selbsttest aus dem ausgepackten Paket 118 von 118.
- **Verbrauch:** 1133 von 4000 Token.
- **Entschieden (HT15–HT18 a, Patrik 09.11.):** Für Hoertest gilt das Bezugsmodell wie bei Sichttest; Repo
  `HoerTest_Helper`, Paket `hoertest`, Pin `v0.14.0`. Von CMakeCraft ist keine Änderung nötig.
- **Beim Lesen der Syncs aufgefallen:**
  - `sync_sichttest` und `sync_LumiViz_CMakeCraft` sind gestoppt.
  - IC ist seit 09.11. aufgelöst. Damit ist offen, ob das Quellpaket (v0.14.0) noch einen Bezieher hat und wer Linux
    prüft. Bei LV (LumiViz S182) nachlesen.

## Weiter mit

1. `sync_check -Side CC` für `sync_hoertest` laufen lassen, dann den Wächter neu starten (Kommando oben).
2. F2 bei LV abwarten: Hoertest neben die LumiViz-Exe (`runtime.dirs`) oder nur in den Zwischenspeicher. Antwort
   einordnen, die CC-Hälfte in `STATUS.md` nachführen, bei Klärung `-Idle`.
3. Danach die offenen Punkte aus dem Report vom 07.11.: die englische Doku nachziehen; ein Test für zwei Bibliotheken
   mit demselben External (Prüfsummen-Wächter).

## Offen beim Nutzer

- Ob in der CC-Hälfte von `sync_sichttest/STATUS.md` der Hinweis auf `v0.14.0` nachgetragen wird. Die Hälfte nennt
  noch `v0.13.1` als aktuellen Stand.
