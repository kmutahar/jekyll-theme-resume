---
title: Where IMPLEMENTATION_PLAN.md content belongs
author: Khaldoon
date: 2026-11-04
branch: main
cost: { minutes: 3, tokens: 94623 }
touches:
  - IMPLEMENTATION_PLAN.md
  - memory.md
  - AGENTS.md
---

## Decided
- The plan describes the unmerged print-and-pdf branch. Roadmap, audit and docs edits for it ship on that branch, not on main.
- After merge: delete the 2.3 and 3.2 briefs, keep the audit row, update the README print bullet, then delete the plan.

## Tried and ruled out
- Copying plan content into AGENTS.md: it holds no standing rules.
- Comparing with `main...feature/print-and-pdf`: no local branch exists. Use `origin/feature/print-and-pdf`.

## Watch out
- Check the branch's commits before saying an item is open. The upload-artifact pin was already done in 0b313ca although the plan and memory.md listed it as open.
- IMPLEMENTATION_PLAN.md can be staged on main. Don't commit it there.
