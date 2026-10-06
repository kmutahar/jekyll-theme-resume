# Completed Work & Decision Log

What was fixed or shipped, why, and the rule each change established. Read this before touching the same area ([AGENTS.md Rule 4](../AGENTS.md#rule-4-historical-audit-awareness)): the **Keep** column is what must not regress. Planned work is in [FEATURE_ROADMAP.md](../FEATURE_ROADMAP.md), intentional removals in its [Delete-Zone](../FEATURE_ROADMAP.md#status-delete-zone), and release notes in [CHANGELOG.md](../CHANGELOG.md).

File names in older rows are historical (for example `resume-en.html`, replaced by `resume.html` in v1.0.0). The previous long-form log, with before/after code and the duplicate-issue registry, is in git history: `git log --follow -p docs/COMPLETED_AUDIT.md`.

## Bug fixes and hardening (v0.4.0 – v0.8.0)

| ID | Change | Why | Keep | Release · commit |
|---|---|---|---|---|
| P0.1 | `tel:` links strip spaces, dashes and parens; live/base contact values resolved consistently | Arabic layout linked `phone_live` when only `phone` was set, producing `tel:` with no number | One contact resolution rule (`enable_live` + `*_live`, else base) for header, microdata, CTA, JSON export | v0.7.0 · `caf726c` |
| P0.2 | Removed a duplicate `{% else %}` in `analytics-body.html` | Invalid Liquid broke the build | — | v0.7.0 · `54f5c96` |
| P0.3 | GA4 uses `analytics.gtag`; Universal Analytics removed | Gate checked `ga` but injected `gtag` | GTM or GA4 only (Delete-Zone #7) | v0.7.0 · `dff8c3d` |
| P0.4 | GTM `<noscript>` iframe on every layout | Resume layouts lacked the body snippet | Every layout includes `analytics-body.html` right after `<body>` | v0.7.0 · `54f5c96` |
| P0.5 | Quoted every `href`; `dir="ltr"` on URLs and IDs in RTL | Unquoted URLs truncated at `&`; RTL scrambled URLs | Always quote attributes; wrap URLs/IDs in `dir="ltr"` when `locale.direction == 'rtl'` | v0.7.0 · `73da095` |
| P0.6 | Favicons through `relative_url` in `shared-head.html` | Bare paths 404'd under subpaths | Every asset URL goes through `relative_url` (Delete-Zone #10) | v0.7.0 · `943d565` |
| P0.7 | Removed manual canonical tag | Duplicated `{% seo %}` output | Canonical only from `jekyll-seo-tag` (Delete-Zone #8) | v0.7.0 · `8f8b22b` |
| P0.8 | Arabic font no longer tied to `resume_theme: default` | Any other theme lost the Arabic font | Fonts come from the locale (`font_url`, `font_family`) | v0.7.0 · `ca6898b` |
| P0.9 | Scoped the SVG sizing selector | Unscoped `svg` distorted the toggle buttons | Never style bare `svg`/`img` (Delete-Zone #9) | v0.7.0 · `d44dcb1` |
| P0.10 | `aria-label`, `title`, `.sr-only` on icon links (#21) | Icon-only links were unlabelled | Every icon-only link has an accessible name | v0.7.0 · `d44dcb1` |
| P0.11 | Print social links: `dir="ltr"` URLs, localized labels | Arabic print output mirrored URLs | Print URLs wrapped in `<span dir="ltr">` | v0.7.0 · `ca6898b` |
| P0.12 | One version source (gemspec) | Docs quoted three different versions | Read versions from the gemspec, never copy them | v0.7.0 · `967e0f0` |
| P0.13–15 | `skills.description`, `recognitions.summary`, `associations.summary` optional (#2, #3, #4) | Empty tags rendered for missing fields | Optional fields render nothing when absent | v0.4.0 · `601dbf9`, `34b4661`, `a12cdc8` |
| P0.16 | Header intro moved from config to `<lang>/header.yml` (#5) | Config text cannot be translated | Translatable text lives in data or locale files, never config (Delete-Zone #6) | v0.4.0 · `d026de9` |
| P1.2 | Language switcher (#11) | No way to move between translations | See F2.12 | v0.8.0 · `c56e50f` |
| P1.4 | `avatar.html`: `avatar_url`, alt cascade, link options | Hardcoded path, alt text and `target="_blank"` | `resume_avatar` is a Boolean (Delete-Zone #3); alt: `avatar_alt` → `name` → `ui.photo_alt` | v0.7.0 · `a17cc60` |
| P2.4 | Site-wide dark mode, profile/default split, error page suite (#8) | Dark mode only on resumes; styles leaked; bare error pages | Anti-FOUC script in `shared-head.html`; error pages via `error.html` | v0.7.0 · `853a9ac` |
| P2.7 | Landmarks, skip links, focus styles (#21) | WCAG gaps | See [ACCESSIBILITY_GUIDE.md](reference/accessibility-coverage.md) | v0.8.0 · `a29c480` |
| #216 | Error page Home link resolved from config | Hardcoded `/resume/en/` paths (Delete-Zone #1) | Home: language profile → `languages.<lang>.url` → `/` | v0.8.0 · `853a9ac` |

## Features (v1.0.0 onward)

| ID | Change | Keep | Release · commit |
|---|---|---|---|
| 2.3 (#12) | Shared CV print partial with physical margins, break hints and locale-scaled typography; review retained the extractable print name font and corrected language-table cascade overrides and trailing blank-page footer spacing | Print rules load last in both CV bundles; retain locale spacing and Arabic name extraction, screen behavior, and oversized-entry fragmentation | unreleased · pending |
| F4.1 (#15) | One locale-driven layout for every language; six locale files; `languages.<lang>` config | Rule 1 all-locale parity; no per-language templates or `*_<lang>` keys (Delete-Zone #11, #12) | v1.0.0 · `54b40a4`…`5188e96` |
| F3.2 (#232) | Typed `publications` and `references` sections: validator rules, JSON Resume export (`publications[]`, `references[]`), localized titles in all six locales, demo data | Publication `summary` is always shown; references render and export exactly as authored (no config); no extra fields beyond the JSON Resume mapping | unreleased · pending |
| 2.1 (#9) | JSON-LD ProfilePage/Person built from the JSON Resume export; Person microdata shares the JSON-LD @id and only publishes visible contact values; json_ld.enabled toggle | JSON-LD and JSON Resume never disagree on inactive entries, live contacts, or privacy; microdata `itemid` links Person to `@id` | unreleased · pending |
| F4.6 (#214) | Removed `site.avatar`, `analytics.ga`, singular `recognition` fallbacks | No compatibility aliases (Delete-Zone #4, #5, #7) | v1.0.0 · `2c88adf` |
| F1.7 (#215) | `social_links.email` renders a `mailto:` icon and print line | — | v1.0.0 · `d53e53c` |
| F2.8 (#217) | Header contact items icon-first in every direction | — | v1.0.0 · `3153569` |
| F3.2 (#206) | CI: Ruby matrix, strict build, proof, RuboCop, tests, gem build | CI must stay green on every supported Ruby | v1.0.0 · `3be935f` |
| F3.3 (#13) | `validate-resume` CLI, engine, build plugin | See [VALIDATION_GUIDE.md](reference/validator-cli.md) | v1.0.0 · `3be935f` |
| F2.11 (#227) | Switcher top-left, dark toggle top-right in every direction | No RTL mirroring of the two widgets (tested in `test_language_switcher.rb`) | v1.0.1 · `305408c` |
| F2.12 (#228) | Switcher is a `<details>` dropdown, no JavaScript | Loop variables prefixed `switch_` (shared include scope) | v1.0.1 · `f37c6f6` |
| — | Demo moved to the `demo/` submodule; sample config at repo root | — | v1.0.2 · `bfd9e83`, `f1779be` |
| — | Theme loaded as a plugin so generators register | Consuming sites load the gem in `:jekyll_plugins` | v1.0.2 · `392c192` |
| — | Switcher on error pages | — | v1.0.2 · `8e942f9` |
| — | Template checker and this log excluded from the gem | Repository-only tools stay out of `spec.files` (tested in `test_packaging.rb`) | `4c5f7d8` |
| F2.10 (#224) | SCSS rules deduplicated | — | `a354b62` |
| F4.9 (#226) | CV/profile pages generated per language | Hand-authored `layout`+`lang` pages or occupied URLs always win; see [CONFIG_GUIDE.md](reference/config.md#3-languages) | `abaf487` |
| — | Single-caller head includes inlined | Delete-Zone #13 | `4513f29` |
| F3.1 (#6) | Localized JSON Resume export | Export only what the HTML shows (active flag, section order, contact visibility); never publish a document that fails the pinned schema; never log resume values | `898dce1` |

F3.1 design notes: YAML keys are translated, not migrated; `level_label` keeps the numeric skill `level` contract; `social_usernames` keeps social templates unchanged; the v1.0.0 schema (Draft 4, full certificate dates) is vendored with its license; generated pages bypass Liquid through renderer predicates. Details in [json-resume-fields.md](reference/json-resume-fields.md).

## Full code and test review (not yet released)

A line-by-line review added rendered-HTML, validator-rule, generator and packaging tests ([TESTING_GUIDE.md](reference/testing-suites.md)) and fixed what they exposed:

| Change | Why | Keep |
|---|---|---|
| `date-formatter.html` parses ISO parts itself | `2018` rendered "January 1970" (Liquid read it as a Unix time), `2020-02` rendered raw, free text got a "December" prefix | `YYYY` → year, `YYYY-MM` → month year, other text verbatim |
| `!= blank` guards replaced by `.size > 0` / truthiness | `blank` needs `blank?`, which plain strings and `nil` lack, so every guard was always true and missing fields printed stray `•` separators | Delete-Zone #14 |
| Validator requires the canonical key the templates render | Alias-only entries (`organization`, `role`, `title`, …) passed validation but rendered blank | Errors name the alias found |
| Social icon names use `ui.social_labels` | Screen readers heard English names on every locale | Every visible or accessible platform name is localized |
| Profile email icon labelled, no duplicate, no new tab | Icon-only `mailto:` link had no accessible name and doubled `social_links.email` | — |
| Error-page language detection strips `baseurl` | `/cv/ar/missing` showed the default language | — |
| Removed dead `preferred-lang` storage write and unread locale keys | Nothing read them | Delete-Zone #15, #16 |
| `test_resume_pages_generator.rb` fixture includes `_pages/` | The hand-authored-page test passed without ever reading the page | Fixtures must mirror consuming-site config |
| Error-page JSON block and locale strings escaped (SEC-01) | `jsonify` leaves `</script>` intact, so a locale string could end the inline JSON block; HTML-position locale strings rendered raw | `<` → `\u003c` inside the JSON block only (never HTML-escape there: `.textContent` would double-encode); `\| escape` on error and skip-link text |
| Validator and pages generator reject unsafe language keys; YAML alias errors are friendly (SEC-05) | `lang` keys were joined into paths and globs unchecked; `Psych::BadAlias` crashed config and locale loading; dead `YAML.load_file` fallback | One `ResumeValidator::LANG_KEY_REGEX` (`/\A[a-zA-Z0-9_-]+\z/`) shared by the validator, pages generator and JSON Resume generator; `Psych::SyntaxError` rescued before `Psych::Exception` |
| `lang`/`hreflang` escaped, analytics IDs validated and emitted as JS/URL literals (SEC-03) | Raw `'{{ id }}'` and `lang="{{ lang }}"` let a quote or `</script>` leave its context | Validator: `gtm` `\AGTM-[A-Z0-9]+\z`, `gtag` `\A[A-Za-z0-9-]+\z`; templates: `jsonify` + `\u003c` in scripts, `url_encode` in URLs |
| Config URLs restricted to safe schemes (SEC-02) | `avatar_url`, `avatar_link`, `social_links.*` and the Mastodon `rel="me"` link accepted `javascript:` and `data:` | One rule in `_includes/safe-url.html` and `ResumeValidator#safe_url?`: a value with `:` must start with an allowed scheme, a relative path passes; templates drop the offender silently (the demo runs non-strict), the validator errors |
| JSON Resume contact privacy documented (SEC-06) | Address, email and non-WhatsApp profiles export under rules that were only partly written down | Field-by-field table in `json-resume-fields.md`; only WhatsApp is suppressed by `export_contact_info: false`; `dob` is never exported |
| Gem ships only git-tracked files (SEC-07) | `spec.files` also globbed `_plugins/**`, `lib/**` and `bin/validate-resume`, which could pick up untracked scratch files | `test_gem_ships_only_git_tracked_files`; a new file must be `git add`ed before it is packaged |
| CSP guidance and inline-code inventory (SEC-08) | Consuming sites could not tell which inline scripts, styles and handlers the theme emits | `config.md` §14 lists them with directives and a Ruby command that prints `script-src`/`style-src` hashes from `_site` |
| Workflows pin actions to SHAs; publish only from `v*` tags (SEC-04, part 1) | Mutable action tags ran with write permission, and `workflow_dispatch` could publish from any ref | Full 40-character SHAs with a version comment in `ci.yml`, `lint.yml`, `publish.yml`; Dependabot's `github-actions` ecosystem keeps them current |
| Gem published via RubyGems Trusted Publishing (SEC-04, part 2) | `publish.yml` wrote a long-lived `RUBYGEMS_API_KEY` secret to `~/.gem/credentials` | `id-token: write` plus a SHA-pinned `rubygems/configure-rubygems-credentials` step mints a short-lived OIDC token before `gem push`; the Trusted Publisher on rubygems.org names this repo and `publish.yml`. First OIDC release was v1.3.1, after which the API-key secret was deleted |
