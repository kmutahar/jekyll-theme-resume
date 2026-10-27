---
title: "Keep FEATURE_ROADMAP.md, GitHub issues and the audit in sync"
author: Khaldoon
date: 2026-10-17
standing: true
touches:
  - FEATURE_ROADMAP.md
  - docs/COMPLETED_AUDIT.md
  - IMPLEMENTATION_PLAN.md
---

## Decided
Every roadmap feature has a GitHub issue, and the roadmap text is the source of truth. Edit the roadmap first, then sync the issue.
When a feature is finished, remove it from `FEATURE_ROADMAP.md` and add a row to `docs/COMPLETED_AUDIT.md`. Leave partly done features in place.
Don't create duplicate issues when syncing.

## Watch out
Also clear finished items out of `IMPLEMENTATION_PLAN.md`.

_Told to Claude in 3 past sessions here, most recently on Oct 5._
