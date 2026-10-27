---
title: Trail-code setup in this repo
author: Khaldoon
date: 2026-10-17
branch: master
cost: { minutes: 1, tokens: 50761 }
touches:
  - "_config.sample.yml"
  - "_data/locales/ar.yml"
  - "_data/locales/de.yml"
  - "_data/locales/en.yml"
  - "_data/locales/es.yml"
  - "_data/locales/fr.yml"
  - "_data/locales/ur.yml"
  - "_includes/resume-section.html"
  - "_layouts/resume.html"
  - "_sass/_resume-ltr.scss"
---

## Decided
Installed with `npm install -g @trailhq/trail-code`, then `trail init --agents claude`. The code map built (492 nodes) even though npm blocked the tree-sitter install scripts.

## Tried and ruled out
Did not pass `--allow-scripts` to npm. It is a security decision for the user, and the map built without it.

## Watch out
`trail init` leaves `.trail/` untracked and uncommitted. Restart Claude Code after init so the new session loads trail. Telemetry is on by default; turn it off with `trail telemetry disable`.
