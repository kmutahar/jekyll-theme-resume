---
title: Locale-driven MDY date order (date_format_mdy)
author: Khaldoon
date: 2026-10-26
branch: master
cost: { minutes: 2, tokens: 63959 }
touches:
  - "_config.sample.yml"
  - "_data/locales/ar.yml"
  - "_data/locales/de.yml"
  - "_data/locales/en.yml"
  - "_data/locales/es.yml"
  - "_data/locales/fr.yml"
  - "_data/locales/ur.yml"
  - "_includes/date-formatter.html"
  - "_includes/resume-section.html"
  - "_layouts/resume.html"
---

## Decided
Full dates (style="MDY") take their word order from the locale key `date_format_mdy` (placeholders {day} {month} {year}), defaulting to "{month} {day}, {year}". Added to all six locales, documented in docs/reference/locale-keys.md, tested in test_rendered_site.rb (EN + AR probes only).

## Tried and ruled out
Putting `replace: "{month}", ...` inside a single `{{ }}` output tag: Liquid 4 raises a syntax error. Assign the result first, then output it.

## Watch out
CHANGELOG.md and spec.version belong to bin/release. The rollout to the CV site (bundle update on master) is a separate step.
