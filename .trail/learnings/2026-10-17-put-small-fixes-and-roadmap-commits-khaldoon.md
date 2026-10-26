---
title: Put small fixes and roadmap commits straight on master
author: Khaldoon
date: 2026-10-17
standing: true
---

## Decided
When the user says a fix, follow-up or doc/roadmap change belongs in master, commit it on `master`. Don't make a feature branch for it.
Feature work stays on `feature/<name>` branches.

## Watch out
Push order matters when the demo submodule pointer changes. Push the demo commit first, then the theme commit. Don't push unless the user says so.

_Told to Claude in 2 past sessions here, most recently on Oct 5._
