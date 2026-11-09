# Documentation Standard — Languages, Versioning, Parity Hook

> **Version:** 1.0.1
> **Date:** 2026-11-09
> **Type:** Standard
> **Status:** Active
> **Language:** English
> **German:** [Doku_Standard.md](../../../de/autorenwerk/standards/Doku_Standard.md)

---

## 1. Languages

- **`docs/de/` is the leading language (SSOT).** Content changes happen there **first**.
- **`docs/en/`** (and possibly further languages) are **translations** — identical folder
  structure, **identical file name** (the hook pairs by path!), identical version.
- A missing translation is acceptable (the hook reminds you) — an **outdated**
  translation is the actual failure this standard prevents.

## 2. Versioning in the document head

Every document starts with the standard head (see [Blueprint](../blueprints/Doc.md)):

```markdown
# Title — short description

> **Version:** 1.2.0
> **Date:** YYYY-MM-DD
> **Type:** Guide | Reference | Standard | Concept | Cheatsheet | Index
> **Status:** Draft | Active | Completed
```

**Rules:**
- Content change in the de master ⇒ **bump the version** (semver spirit:
  fixes = patch, new sections = minor, reorientation = major) + update the date.
- When catching up, the translation adopts **exactly the same version number**.
- `de` version ≠ `en` version ⇒ the translation is outdated (and the hook reports it).
- **The changelog is authoritative:** every change is a new changelog entry with a higher number; `Version` and
  `Date` in the header are always those of the newest entry.
- **The document version is independent of the CMakeCraft version.** A document may carry 1.x while CMakeCraft is
  at v0.x. The doc versions 1.0.0 come from "Release 1" (newCMake, `2e00db7`, 2025-12-26).
- **No CMakeCraft version in the header.** Docs and code live in the same repo; the Git tag (`vX.Y.Z`) binds both.
  If a behaviour is tied to a CMakeCraft version, the text says "since vX.Y.Z" and the changelog entry names the
  version the change came with (`CMakeCraft v0.14.1: …`).
- **Shared major number from CMakeCraft v2.0.0:** the first major release of CMakeCraft is **v2.0.0** (not
  v1.0.0). With it, all documents and all `.cmake` files go to 2.0.0. From then on product, docs and modules share
  the major number: every major release of CMakeCraft raises all of them to X.0.0; minor and patch count per file.

## 3. The parity hook

A committed pre-commit hook ([.githooks/pre-commit](../../../../.githooks/pre-commit))
checks the `docs/` files contained in each commit:

| Situation | Message |
|---|---|
| de file committed, en version differs | `HINWEIS: Uebersetzung veraltet: docs/en/… (Version <v_en>) != de-Master (Version <v_de>)` |
| de file committed, en version does not exist | `HINWEIS: keine en-Uebersetzung vorhanden fuer: docs/de/…` |
| en file committed, differs from the de master | `HINWEIS: docs/en/… (Version <v_en>) weicht vom de-Master ab (Version <v_de>)` |
| en file without a de counterpart | `HINWEIS: Uebersetzung ohne de-Master (de ist SSOT!): docs/en/…` |

If the en version has no version line, `fehlt` appears in place of `<v_en>`. If there was at least one
notice, the hook ends with `(Doku-Versions-Check: nur Hinweise, Commit laeuft weiter)`.

**The hook never blocks** (exit 0) — it is a reminder note, not a gatekeeper.

### Activation (once per clone)

```bash
git config core.hooksPath .githooks
```

Without this setting the hook does not run (by default Git only executes `.git/hooks/`,
which cannot be versioned). Note for authors of the hook itself: files under `.githooks/`
are pinned to **LF** via `.gitattributes` — CRLF would break `sh` on Windows.

## 4. Typical workflow

1. Change the de document, adjust **version + date** in the head.
2. If there is time: update the en version right away (same version). If not: just commit —
   the notice at commit time is the list of open items.
3. Translation stragglers can be found at any time via a full-text search for the notices, or with:
   ```bash
   git config core.hooksPath .githooks   # if not active yet
   git commit --dry-run                  # shows pending notices without committing
   ```

## 5. Filing rules (short form)

- No document twice, no version copies (`Name050.md`) — **Git is the history.**
- Sort new documents according to the [INDEX.md](../../../INDEX.md) logic:
  `guide/` (use) · `konzepte/` (develop the build system) · `autorenwerk/` (author rules).
- Format/structure of a new document: copy a template from [blueprints/](../blueprints/).

## 6. Changelog

| Version | Date | Changes |
|---|---|---|
| 1.0.1 | 2026-11-09 | Aligned with the code: parity hook notices (§3) verbatim as in `.githooks/pre-commit` (spelling `fuer`, version details, closing line); version rules §2 after decisions K1/K2/V2 a: changelog authoritative, document version independent of CMakeCraft, no CMakeCraft version in the header, shared major number from CMakeCraft v2.0.0 |
| 1.0.0 | 2026-07-18 | First version |
