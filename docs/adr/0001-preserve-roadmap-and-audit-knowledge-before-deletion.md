---
status: accepted
---

# Preserve roadmap and audit knowledge before deleting them

`FEATURE_ROADMAP.md` (planned work and the "Status Delete-Zone" of removed files and keys) and `docs/COMPLETED_AUDIT.md` (past fixes and their rationale) are temporary working files. They are expected to be deleted around the next major version. Because of that, the user docs (`docs/`, `README.md`) must not link to them, and any fact a doc needs from them is restated in the right Diátaxis quadrant instead. This ADR is the reminder: **before deleting either file, move everything durable out of it and update this ADR.**

## Before deleting either file

- [ ] Roadmap items not yet built become GitHub issues (or are dropped on purpose).
- [ ] The "Status Delete-Zone" (files and keys that were removed and must not be recreated) is preserved somewhere permanent, as an ADR or an explanation page.
- [ ] The rationale behind each audit fix that a future contributor could undo by accident becomes an ADR or an explanation page. Fixes with no lasting "why" can go.
- [ ] Rewrite `AGENTS.md` Rules 3 and 4 and the two index rows that point at these files.
- [ ] Remove the now-dead references: `docs/COMPLETED_AUDIT.md` in `jekyll-theme-resume.gemspec` (the `f != "docs/COMPLETED_AUDIT.md"` line), `.github/workflows/lint.yml`, and `test/test_packaging.rb`.
- [ ] Search the whole repo for `FEATURE_ROADMAP` and `COMPLETED_AUDIT` and fix every remaining mention.
- [ ] Record here what was moved where, then delete the two files.

## Consequences

`docs/adr/` is excluded from the packaged gem (see the gemspec), so ADRs are for contributors on GitHub, not for site owners. Shipped docs must not link into `docs/adr/`.
