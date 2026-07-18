# Documentation Standard — Languages, Versioning, Parity Hook

> **Version:** 1.0.0
> **Datum:** 2026-07-18
> **Typ:** Standard
> **Status:** Aktiv
> **Language:** English (translation — German master: [Doku_Standard.md](../../../de/autorenwerk/standards/Doku_Standard.md))

---

## 1. Languages

- **`docs/de/` is the leading language (SSOT).** Content changes happen there **first**.
- **`docs/en/`** (and possibly further languages) are **translations** — identical folder
  structure, **identical file name** (the hook pairs by path!),
  identical version.
- A missing translation is acceptable (the hook reminds you) — an **outdated** translation
  is the actual failure this standard prevents.

## 2. Versioning in the document head

Every document starts with the standard head (see [Blueprint](../blueprints/Doc.md)):

```markdown
# Title — short description

> **Version:** 1.2.0
> **Datum:** YYYY-MM-DD
> **Typ:** Guide | Reference | Standard | Concept | Cheatsheet | Index
> **Status:** Entwurf | Aktiv | Abgeschlossen
```

**Rules:**
- Content change in the de master ⇒ **bump the version** (semver spirit: fixes = patch,
  new sections = minor, reorientation = major) + update the date.
- When catching up, the translation adopts **exactly the same version number**.
- `de` version ≠ `en` version ⇒ the translation is outdated (and the hook reports it).

## 3. The parity hook

A committed pre-commit hook ([.githooks/pre-commit](../../../../.githooks/pre-commit))
checks the `docs/` files contained in each commit:

| Situation | Message |
|---|---|
| de file committed, en version differs | `HINWEIS: Uebersetzung veraltet: … != de-Master` |
| de file committed, no en counterpart | `HINWEIS: keine en-Uebersetzung vorhanden für: …` |
| en file committed, differs from de master | `HINWEIS: … weicht vom de-Master ab` |
| en file without de counterpart | `HINWEIS: Uebersetzung ohne de-Master (de ist SSOT!)` |

**The hook never blocks** (exit 0) — it is a reminder, not a gatekeeper.

### Activation (once per clone)

```bash
git config core.hooksPath .githooks
```

Without this setting the hook does not run (by default Git only executes `.git/hooks/`,
which cannot be versioned). Note for authors of the hook itself: files under `.githooks/`
are pinned to **LF** via `.gitattributes` — CRLF would break `sh` on Windows.

## 4. Typical workflow

1. Change the de document, **bump version + date** in the head.
2. If time permits: update the en version right away (same version). If not: just commit —
   the commit-time notice is your open-items list.
3. Find translation stragglers at any time via the notices, or with:
   ```bash
   git config core.hooksPath .githooks   # if not active yet
   git commit --dry-run                  # shows pending notices without committing
   ```

## 5. Filing rules (short form)

- No document twice, no version copies (`Name050.md`) — **Git is the history.**
- Sort new documents by [INDEX.md](../../../INDEX.md) logic:
  `guide/` (use) · `konzepte/` (develop the build system) · `autorenwerk/` (author rules).
- Format/structure of a new document: copy a template from [blueprints/](../blueprints/).
