# Feature Roadmap

**Status:** The canonical list of planned work. Every feature below maps to an open GitHub issue; check its hosted status before starting. Settings proposed in a brief do not exist until the feature ships. Shipped work leaves this file: its history is in [docs/COMPLETED_AUDIT.md](docs/COMPLETED_AUDIT.md) and [CHANGELOG.md](CHANGELOG.md).

## 1. Active Features Master Matrix

| Phase | ID | Planned feature | Issue |
|---|---|---|---|
| P1 | 1.1 | Predefined Color Themes Palette Engine (5 Palettes) | [#7](https://github.com/kmutahar/jekyll-theme-resume/issues/7) |
| P1 | 1.3 | Expanded Modern Social Media Platforms (7 Remaining) | [#204](https://github.com/kmutahar/jekyll-theme-resume/issues/204) |
| P1 | 1.5 | Dynamic Contact / Resume QR Code Component | [#14](https://github.com/kmutahar/jekyll-theme-resume/issues/14) |
| P1 | 1.6 | Achievement Badges & Credential Icons | [#19](https://github.com/kmutahar/jekyll-theme-resume/issues/19) |
| P2 | 2.2 | Skills Level Indicators & Visual Progress Bars | [#10](https://github.com/kmutahar/jekyll-theme-resume/issues/10) |
| P2 | 2.3 | Professional Print Pagination & Spacing Engine | [#12](https://github.com/kmutahar/jekyll-theme-resume/issues/12) |
| P2 | 2.5 | Skills Taxonomy & Categorized Tagging System | [#18](https://github.com/kmutahar/jekyll-theme-resume/issues/18) |
| P2 | 2.6 | Social Media Cards (Open Graph & Twitter) | [#22](https://github.com/kmutahar/jekyll-theme-resume/issues/22) |
| P2 | 2.9 | Dual Gregorian / Hijri (Islamic) Calendar Localization | [#218](https://github.com/kmutahar/jekyll-theme-resume/issues/218) |
| P2 | 2.11 | CEFR Language Proficiency Framework Support | [#235](https://github.com/kmutahar/jekyll-theme-resume/issues/235) |
| P2 | 2.12 | Client-Side Contact Info Anti-Scraping & Obfuscation | [#236](https://github.com/kmutahar/jekyll-theme-resume/issues/236) |
| P2 | 2.13 | Right-to-Left (RTL) Specialized Web Typography & Custom Font Stacks | [#237](https://github.com/kmutahar/jekyll-theme-resume/issues/237) |
| P3 | 3.2 | Automated Headless PDF Generation in CI/CD (GitHub Actions / Playwright) | [#238](https://github.com/kmutahar/jekyll-theme-resume/issues/238) |
| P3 | 3.3 | Digital Contact Card (vCard / `.vcf`) Generator & Download | [#239](https://github.com/kmutahar/jekyll-theme-resume/issues/239) |
| P3 | 3.4 | ATS Plain-Text & Markdown Resume Export (`resume.txt` / `resume.md`) | [#240](https://github.com/kmutahar/jekyll-theme-resume/issues/240) |
| P3 | 3.5 | JSON Resume Importer CLI (`bin/import-json-resume`) | [#241](https://github.com/kmutahar/jekyll-theme-resume/issues/241) |
| P3 | 3.6 | Automated ATS Compatibility Linter (`bin/lint-ats`) | [#242](https://github.com/kmutahar/jekyll-theme-resume/issues/242) |
| P4 | 4.2 | Interactive Career Timeline Visualization | [#16](https://github.com/kmutahar/jekyll-theme-resume/issues/16) |
| P4 | 4.3 | Contact Form Integration (Formspree / Netlify) | [#20](https://github.com/kmutahar/jekyll-theme-resume/issues/20) |
| P4 | 4.4 | Privacy-First Resume Engagement Analytics | [#17](https://github.com/kmutahar/jekyll-theme-resume/issues/17) |
| P4 | 4.5 | Resume Comparison View | [#23](https://github.com/kmutahar/jekyll-theme-resume/issues/23) |
| P4 | 4.7 | Dynamic Custom Resume Sections Engine | [#219](https://github.com/kmutahar/jekyll-theme-resume/issues/219) |
| P4 | 4.8 | Client-Side Site Search Index | [#225](https://github.com/kmutahar/jekyll-theme-resume/issues/225) |
| P4 | 4.10 | Interactive Cross-Section Skill Highlighting | [#243](https://github.com/kmutahar/jekyll-theme-resume/issues/243) |
| P4 | 4.11 | Project Portfolio Media Previews & Modal Lightbox | [#244](https://github.com/kmutahar/jekyll-theme-resume/issues/244) |
| P4 | 4.12 | Audience Scope & Target Role Switcher (1-Page Summary vs Detailed CV) | [#245](https://github.com/kmutahar/jekyll-theme-resume/issues/245) |
| P5 | 5.1 | Paired Cover Letter Layout (`_layouts/cover-letter.html`) | [#246](https://github.com/kmutahar/jekyll-theme-resume/issues/246) |
| P5 | 5.2 | BibTeX Publication Citations & Interactive DOI Resolver | [#247](https://github.com/kmutahar/jekyll-theme-resume/issues/247) |
| P5 | 5.3 | Patents & Research Grants Dedicated Schemas (JSON Resume Compatible) | [#248](https://github.com/kmutahar/jekyll-theme-resume/issues/248) |

<a id="status-delete-zone"></a>
## Status Delete-Zone (Intentional Removals & Deprecations)

In accordance with Living Docs Governance, this Delete-Zone catalogs files, patterns, features, and configurations that have been intentionally removed, prohibited, or deprecated. **AI agents and developers MUST NOT recreate or re-introduce these elements.**

| # | Path / Pattern / Concept | Lifecycle Status | Why Removed / Forbidden | Canonical Replacement | Revisit Condition |
|---|---|---|---|---|---|
| 1 | Static return URLs (`/resume/en/`, `/resume/ar/` in `_layouts/error.html`) | **Removed in v0.8.0 (Issue #216)** | Hardcoded paths broke return navigation for sites using custom resume paths (e.g. `/en/cv/`, `/ar/cv/`). | Current Home link: language profile page, then `languages.<lang>.url`, then `/`. | Never revert to hardcoded static URLs. Any locale work must keep dynamic resolution. |
| 2 | Gravatar MD5 email hashing & fallback initials claims | **Purged in v0.8.0** | Fictional feature documented in old drafts; neither Gravatar hashing nor initials fallback was ever implemented in `_includes/avatar.html`. Documenting `resume_avatar` as a Hash broke Liquid's strict boolean check `{% if site.resume_avatar == true %}`. | Direct image path via `site.avatar_url` (the `site.avatar` fallback is removed in v1.0.0), defaulting to `/assets/images/Profile-min.jpg`, with `resume_avatar: true` (Boolean). | Revisit only if a verified Jekyll Liquid MD5 plugin or client-side JS hashing filter is formally designed, approved in an ADR, and tested. |
| 3 | `resume_avatar: Hash` in `_config.yml` | **Forbidden in v0.8.0** | Liquid `{% if site.resume_avatar == true %}` checks boolean equality; a hash evaluates to `false`. | `resume_avatar: true` (strictly Boolean) and `avatar_url: "..."`. | Never use a hash for `resume_avatar`. |
| 4 | Singular section keys: `resume_section.recognition` | **Removed in v1.0.0 (#214)** | Inconsistent singular syntax across sections. Standardized to plural `recognitions`. | `resume_section.recognitions` and `resume_section_order: - recognitions`. | Standardize all section names to plural. |
| 5 | Scoped dark mode key: `site.resume_dark_mode` | **Removed (confirmed absent in v1.0.0, #214)** | Scoped key confusingly duplicated site-wide dark mode toggle. | `site.dark_mode: enabled / auto / disabled`. | Use global `site.dark_mode` exclusively. |
| 6 | Global header intro key: `site.resume_header_intro` | **Retired in v0.4.0** | Stored candidate intro in `_config.yml`, preventing bilingual localization. | `_data/en/header.yml` and `_data/ar/header.yml` (`intro:` field). | Never store translatable content in config. |
| 7 | Universal Analytics: `analytics.ga` (`UA-XXXXX-X`) | **Retired (P0.3 / #214)** | Google UA is deprecated and shut down; caused parameter mismatch. | GA4 (`analytics.gtag: "G-..."`) or GTM (`analytics.gtm: "GTM-..."`). | Never restore Universal Analytics. |
| 8 | Duplicate manual `<link rel="canonical">` | **Retired in v0.7.0 (P0.7)** | Conflicted with `jekyll-seo-tag` canonical tag emission. | Canonical tags emitted exclusively via `{% seo %}`. | Do not emit manual canonical tags in `<head>`. |
| 9 | Global unscoped `svg` CSS selector | **Retired in v0.7.0 (P0.9)** | Applied 30px width and grey fill to all SVGs, distorting toggle buttons. | Scoped selectors `.svg-icon, .icon-link svg, .social-links svg, .page-footer svg`. | Never style unscoped `svg` or `img` tags. |
| 10 | Bare relative favicon paths (`favicon.ico`) | **Retired in v0.7.0 (P0.6)** | Caused 404s on subpaths (`/resume/en/`, baseurl). | Modern favicon suite in `_includes/shared-head.html` using `relative_url`. | Always filter static assets with `relative_url`. |
| 11 | Per-language layouts and includes (`resume-en.html`, `resume-ar.html`, `resume-section-{en,ar}.html`, `resume-head-{en,ar}.html`, `ar-date.html`) | **Removed in v1.0.0 (#15)** | Duplicated about 1,100 lines of Liquid and blocked languages beyond EN/AR. | `_layouts/resume.html`, `_includes/resume-section.html`, `_includes/date-formatter.html`, driven by `_data/locales/<lang>.yml`. | Never add a per-language layout or include. |
| 12 | Per-language config keys (`active_resume_path_*`, `resume_*_url`, `resume_header_intro_*`, `name_ar`, `resume_title_ar`, `address_ar`, `avatar_alt_*`) and `dir` in config | **Removed in v1.0.0 (#15)** | Suffix keys cannot scale past two languages; direction in config duplicated the locale file. | `languages.<lang>.*` in `_config.yml`; direction only in `_data/locales/<lang>.yml`. | Never add `_<lang>` suffixed config keys. |
| 13 | `_includes/main-head.html`, `_includes/profile-head.html` | **Removed** | Each wrapped one stylesheet link for a single caller. | Inline stylesheet links in `_layouts/default.html` and `_layouts/profile.html`. | Add a shared abstraction only when multiple callers actually need it. |
| 14 | `!= blank` presence checks in Liquid (and `!= empty` on possibly-nil values) | **Forbidden** | Liquid's `blank` literal calls `blank?`, which plain Ruby strings and `nil` do not define, so `x != blank` is always true and printed stray `•` separators for missing fields; `nil != empty` is true for the same reason. | `x.size > 0` for text, plain `x` for dates. Guarded by `test/test_rendered_site.rb`. | Never. |
| 15 | `localStorage['preferred-lang']` write in `_layouts/resume.html` | **Removed** | Nothing read it; its comment wrongly claimed `error.html` did. Error pages pick the language from the URL. | URL-prefix detection in `_layouts/error.html` (baseurl-aware). | Only with a reader that is designed and tested. |
| 16 | Unused locale keys `error_pages.return_link`, `error_pages.search_*` | **Removed** | No template read them. | Feature 4.8 adds its own search strings when implemented. `test/test_packaging.rb` fails on any unread locale key. | When a template reads them. |


## 2. Planned Implementation Briefs

### Feature 1.1: Predefined Color Themes Palette Engine (5 Palettes)

**Issue:** [#7](https://github.com/kmutahar/jekyll-theme-resume/issues/7) · **Branch:** `feature/color-themes` · **Closure:** `Closes #7`

Add the planned default, modern-blue, emerald-green, corporate-navy, and warm-burgundy palettes. The existing resume_theme setting currently supplies a body class; the palette engine is not implemented.

**Files:** Create `_sass/_themes.scss`; update `_sass/_dark-mode.scss`, the four `assets/css/*.scss` entrypoints, and shared layouts as needed. Document in `_config.sample.yml` and a new `docs/THEMES_GUIDE.md`.

**Implementation contract:** Keep `resume_theme` as the selector. Put colors in CSS custom properties; preserve the current system/pinned dark-mode cascade and print reset. Use the shared `resume.html`, never language-specific layouts.

**Acceptance criteria:**

- [ ] Each named palette changes intended accents in every configured locale.
- [ ] Light, system-dark, pinned-dark, and print states retain readable colors.
- [ ] Omitting the setting preserves the existing appearance.

### Feature 1.3: Expanded Modern Social Media Platforms (7 Remaining)

**Issue:** [#204](https://github.com/kmutahar/jekyll-theme-resume/issues/204) · **Branch:** `feature/expanded-social-icons` · **Closure:** `Closes #204`

Add icon and print-list support for Mastodon, Bluesky, Threads, Substack, GitLab, Google Scholar, and ORCID. Discord and Behance shipped (commit 49ede2c). Mastodon already has rel="me" head metadata in default/profile layouts; icon and print support remains planned.

**Files:** Add entries to `_data/social_networks.yml` and SVGs to `_includes/vendors/svg-icons/` (`social-links.html` and `print-social-links.html` already loop over that data file and need no per-platform edits); update all `_data/locales/*.yml` (`ui.social_labels`), `_config.sample.yml`, and `docs/reference/config.md`.

**Implementation contract:** Extend `social_links` with `mastodon`, `bluesky`, `threads`, `substack`, `gitlab`, `google_scholar`, and `orcid`. Keep accessible names, hidden decorative SVGs, and safe external links. Use locale labels and bidi isolation for printed URLs.

**Acceptance criteria:**

- [ ] Only configured platforms render, without blank placeholders.
- [ ] All seven have accessible names and printable URLs in LTR/RTL.
- [ ] Mastodon identity links preserve rel="me".

### Feature 1.5: Dynamic Contact / Resume QR Code Component

**Issue:** [#14](https://github.com/kmutahar/jekyll-theme-resume/issues/14) · **Branch:** `feature/qr-code` · **Closure:** `Closes #14`

Add an optional QR code linking a printed or digital resume to its canonical online page.

**Files:** Create `_includes/qr-code.html`; update `_layouts/resume.html`, shared/print SCSS, `_config.sample.yml`, and locale UI strings.

**Implementation contract:** Proposed settings: `resume_show_qr_code` (false), `resume_qr_code_print_only` (true), and `resume_qr_code_size` (96). Encode `page.url | absolute_url`. Choose and document an actual local generation mechanism before implementation; the previous blueprint relied on an unprovided qr_code filter. Do not send resume/contact data to an external image service.

**Acceptance criteria:**

- [ ] A scanner opens the correct canonical URL, including baseurl.
- [ ] Print-only mode is hidden on screen and readable on paper.
- [ ] Caption and positioning work for every locale; disabling the feature adds no broken asset.

### Feature 1.6: Achievement Badges & Credential Icons

**Issue:** [#19](https://github.com/kmutahar/jekyll-theme-resume/issues/19) · **Branch:** `feature/achievement-badges` · **Closure:** `Closes #19`

Add optional badge images to certifications and recognitions while retaining the current text-only presentation when absent.

**Files:** Create `_includes/badge-display.html`; update `_includes/resume-section.html`, resume SCSS, validator rules, and `docs/reference/data-schemas.md`.

**Implementation contract:** Proposed per-item field: `badge_url`. Reuse existing `credential_url` for optional verification links. Resolve local images with relative_url, define appropriate alt text, and keep dimensions predictable.

**Acceptance criteria:**

- [ ] Entries with badges align with their headings in LTR and RTL.
- [ ] Missing badges leave no gaps or empty image elements.
- [ ] Verification links and printed text remain usable without images.

### Feature 2.2: Skills Level Indicators & Visual Progress Bars

**Issue:** [#10](https://github.com/kmutahar/jekyll-theme-resume/issues/10) · **Branch:** `feature/skills-visualization` · **Closure:** `Closes #10`

Add optional visual skill proficiency indicators alongside skill names and descriptions.

**Files:** Create `_includes/skill-level-bar.html`; update the skills branch in `_includes/resume-section.html`, resume SCSS, all locales, `_config.sample.yml`, and the data/config guides.

**Implementation contract:** Proposed toggle: `resume_skills_visualization` (false). Use existing validator-compatible integer `level` values from 1 to 5 and optional localized `level_label`. The previous 1–100 alternative conflicted with validation and is not part of the current data contract. Use appropriate accessible value semantics for a static proficiency measure.

**Acceptance criteria:**

- [ ] No meter renders if visualization is disabled or level is missing.
- [ ] Labels and numeric values are available without relying on color.
- [ ] RTL fill direction, dark mode, and print remain readable.

### Feature 2.3: Professional Print Pagination & Spacing Engine

**Issue:** [#12](https://github.com/kmutahar/jekyll-theme-resume/issues/12) · **Branch:** `feature/print-pagination-engine` · **Closure:** `Closes #12`

Improve the existing print styles with explicit page-break and typography controls.

**Files:** Create `_sass/_print.scss`; update `assets/css/cv-ltr.scss`, `assets/css/cv-rtl.scss`, `_sass/_resume-ltr.scss` (print rules moved out), and add `docs/how-to/print-your-resume.md`.

**Implementation contract:** Keep headings with following content, use break-inside/break-after deliberately, and avoid forcing oversized groups onto one page. Preserve locale typography, especially Arabic and Urdu; do not reuse the old fixed .7em line-height example.

**Acceptance criteria:**

- [x] Check multi-page A4 and Letter output for all six locales.
- [x] No clipped text, stranded headings, or blank trailing pages; long entries can still paginate.
- [x] Controls remain hidden and printed links remain directionally correct.
- [x] Print guide and Sass reference updated.
- [x] `bin/verify` passes.

### Feature 2.5: Skills Taxonomy & Categorized Tagging System

**Issue:** [#18](https://github.com/kmutahar/jekyll-theme-resume/issues/18) · **Branch:** `feature/skills-taxonomy` · **Closure:** `Closes #18`

Group skills by optional categories and display optional tags while keeping the current flat list available.

**Files:** Update `_includes/resume-section.html`, shared resume SCSS, validator rules, `_config.sample.yml`, `docs/reference/data-schemas.md`, and `docs/reference/config.md`.

**Implementation contract:** Proposed toggle: `resume_skills_categorized` (false). Add `category` and `tags` to entries that retain the canonical `skill` field. Filter active entries before grouping; define handling for uncategorized skills. Category names and tags are localized resume content.

**Acceptance criteria:**

- [ ] Flat mode preserves current output.
- [ ] Grouped mode renders each active skill once, including uncategorized entries.
- [ ] Category headings and tags work in RTL and print.

### Feature 2.6: Social Media Cards (Open Graph & Twitter)

**Issue:** [#22](https://github.com/kmutahar/jekyll-theme-resume/issues/22) · **Branch:** `feature/social-media-cards` · **Closure:** `Closes #22`

Improve per-language sharing images and summaries. Basic Open Graph metadata already exists through jekyll-seo-tag; this feature adds richer configuration and fallbacks.

**Files:** Update shared layout/head integration and `_config.sample.yml`; document in `docs/reference/config.md` and a new `docs/SEO_GUIDE.md`. Add image assets only as required.

**Implementation contract:** The previous draft proposed `og_image` and per-language image/title overrides. Finalize their mapping onto jekyll-seo-tag’s supported inputs before implementation; do not duplicate tags already emitted by {% seo %}. Use languages.<lang> or page data for localized values, not language-suffixed global keys.

**Acceptance criteria:**

- [ ] Each page has a single consistent title, description, image, and card type.
- [ ] Image URLs are absolute and respect subpath hosting.
- [ ] Fallback imagery works when a language has no dedicated image.

### Feature 2.9: Dual Gregorian / Hijri (Islamic) Calendar Localization

**Issue:** [#218](https://github.com/kmutahar/jekyll-theme-resume/issues/218) · **Branch:** `feature/hijri-calendar-support` · **Closure:** `Closes #218`

Offer Gregorian, Hijri, or dual display and optional numeral styling without changing source ISO dates.

**Files:** Extend `_includes/date-formatter.html` and its callers, especially `_includes/grouped-item-list.html`; update locale files, validator rules, `_config.sample.yml`, and date documentation.

**Implementation contract:** Keep the implementation locale-driven. The old arabic_date_calendar/arabic_numerals and language-specific month-file draft must be redesigned into the current locale/config model before coding. Proposed optional `hijri_startdate` values can provide authored display text; do not imply calendar conversion exists merely from replacing month names. If conversion is added, specify and test its calendar convention.

**Acceptance criteria:**

- [ ] Gregorian remains the default and fallback when Hijri text is absent.
- [ ] Present markers retain their locale labels in every calendar mode.
- [ ] Dual dates and numeral choices work in Arabic and Urdu without language-specific templates.

### Feature 2.11: CEFR Language Proficiency Framework Support

**Issue:** [#235](https://github.com/kmutahar/jekyll-theme-resume/issues/235) · **Branch:** `feature/cefr-languages` · **Closure:** `Closes #235`

Add structured CEFR (Common European Framework of Reference) proficiency indicators (A1, A2, B1, B2, C1, C2, Native) to languages.yml entries as an optional standard companion to the existing free-text fluency field.

**Files:** Update `_includes/resume-section.html`, `lib/jekyll-theme-resume/resume_validator.rb`, all six `_data/locales/*.yml` (`ui.cefr_labels`), `_config.sample.yml`, and `docs/reference/data-schemas.md`.

**Implementation contract:** Keep `fluency` as the canonical plain-text descriptor for backward compatibility. Add optional `cefr` string field validated against the standard set `["A1", "A2", "B1", "B2", "C1", "C2", "native"]` (case-insensitive in validator, stored uppercase). Render as a localized badge or abbreviation alongside the language name, with full level name (e.g. "Proficient User / C2") in an accessible title or aria-label pulled from `locale.ui.cefr_labels`. Works identically across all 6 locales in LTR and RTL.

**Acceptance criteria:**

- [ ] Languages with `cefr` render standard badges with localized accessible tooltips.
- [ ] Omitting `cefr` preserves the existing plain-text fluency display without empty tags.
- [ ] Invalid CEFR strings trigger a validator warning or error.
- [ ] Badge styling respects light mode, dark mode, RTL direction, and print styles.

### Feature 2.12: Client-Side Contact Info Anti-Scraping & Obfuscation

**Issue:** [#236](https://github.com/kmutahar/jekyll-theme-resume/issues/236) · **Branch:** `feature/contact-obfuscation` · **Closure:** `Closes #236`

Protect public resume contact details (email address and phone number) from automated harvester bots and web scrapers on static hosting (GitHub Pages).

**Files:** Update `_layouts/resume.html`, `_includes/shared-head.html` or inline contact rendering, `_sass/_resume-ltr.scss`, `_sass/_resume-rtl.scss`, `_config.sample.yml`, and all `_data/locales/*.yml`.

**Implementation contract:** Config toggle: `site.obfuscate_contact` (default false). When enabled, email and phone links are not output as plain `mailto:` or `tel:` hrefs in static HTML. Use accessible CSS direction reversal (`unicode-bidi: bidi-override`) combined with character entity encoding or a lightweight click-to-reveal button (`<button class="contact-reveal" aria-expanded="false">`). In print mode (`@media print`), contact details must automatically un-obfuscate and display clear readable text without requiring JavaScript interaction.

**Acceptance criteria:**

- [ ] Raw HTML contains no plain-text mailto: or harvestable email strings when enabled.
- [ ] Human visitors can click or view contact details seamlessly with keyboard and screen reader accessibility.
- [ ] Print output displays clear, un-obfuscated email and phone text.
- [ ] Disabling the setting preserves direct plain-text links.

### Feature 2.13: Right-to-Left (RTL) Specialized Web Typography & Custom Font Stacks

**Issue:** [#237](https://github.com/kmutahar/jekyll-theme-resume/issues/237) · **Branch:** `feature/rtl-typography` · **Closure:** `Closes #237`

Provide dedicated typography font stacks for Arabic (ar) and Urdu (ur) to replace generic system sans-serif fallbacks that cause typographical degradation in Nastaliq and Arabic scripts.

**Files:** Update `_sass/_resume-rtl.scss`, `_sass/_variables.scss`, `assets/css/resume-rtl.scss`, `_config.sample.yml`, and `docs/explanation/multilingual-and-rtl-design.md`.

**Implementation contract:** Introduce language-specific font tokens under `html[lang="ar"]` and `html[lang="ur"]`. Urdu defaults to modern Nastaliq stacks (e.g. `'Noto Nastaliq Urdu', 'Jameel Noori Nastaliq', serif`), while Arabic uses high-legibility Naskh stacks (e.g. `'Noto Sans Arabic', 'Amiri', system-ui, sans-serif`). Allow consuming sites to configure font sources via `site.rtl_fonts.arabic` and `site.rtl_fonts.urdu` in `_config.yml`. Do not hardcode remote CDN font imports unless configured by the site owner; provide clean system and webfont fallback cascades.

**Acceptance criteria:**

- [ ] Arabic and Urdu resumes render with distinct, script-appropriate typographic font stacks.
- [ ] Custom font families can be overridden in `_config.yml` without modifying theme SCSS.
- [ ] Line heights and baseline alignments are adjusted to avoid Nastaliq diacritic clipping.
- [ ] LTR locales remain completely unaffected.

### Feature 3.2: Automated Headless PDF Generation in CI/CD (GitHub Actions / Playwright)

**Issue:** [#238](https://github.com/kmutahar/jekyll-theme-resume/issues/238) · **Branch:** `feature/print-and-pdf` (shared with 2.3) · **Closure:** `Closes #238`

Provide a turnkey GitHub Actions workflow and theme integration that automatically renders and outputs downloadable vector PDFs (`resume-en.pdf`, `resume-ar.pdf`, etc.) using headless Chromium upon site build.

**Files:** Create `.github/workflows/generate-pdf.yml`, update `_layouts/resume.html`, `_config.sample.yml`, and all `_data/locales/*.yml`; add `bin/generate-pdf`, `test/ats_check.rb` and `docs/how-to/generate-pdf-in-ci.md`.

**Implementation contract:** Workflow builds Jekyll site, launches Playwright or Puppeteer in headless mode, sets `emulateMediaType('print')`, iterates through every configured locale (`languages.<lang>.url`), and outputs `resume-<lang>.pdf` to `_site/assets/pdf/`. The theme template inspects `site.resume_download_pdf` (default false): when true, it renders a localized "Download PDF" button in the header linking to `/assets/pdf/resume-{{ lang }}.pdf`.

**Acceptance criteria:**

- [ ] The workflow generates valid, searchable vector PDF artifacts for all active locales.
- [ ] Multi-page pagination and margins in generated PDFs match the theme's print stylesheet.
- [ ] The header "Download PDF" button is localized, accessible, and hidden from print output.
- [ ] Sites without PDF generation enabled render no broken download links.
- [ ] ATS check: run `pdftotext` on each PDF and confirm text extracts in logical order. Arabic and Urdu headings already mis-extract in the pre-2.3 baseline. Compare every expected item and the relative order of all extractable items against that baseline; do not stop at the first known failure.

**Deferred from 2.3:** a running footer and page numbers. Evaluate browser support for CSS margin boxes (`@page` `@bottom-center`) and extraction order before adding them; keep essential contact information in the page body.

**Render option without npm:** `google-chrome --headless=new --no-pdf-header-footer --print-to-pdf=<out>.pdf <url>`, with an injected `@page { size: A4 }` (or Letter) to fix the paper size. This needs no npm dependency and is an alternative to Playwright.

**Pre-2.3 A4 page counts (historical, not post-feature acceptance thresholds):** en 3.46, ar 3.27, es 3.50, fr 3.48, de 3.56, ur 3.28.

### Feature 3.3: Digital Contact Card (vCard / `.vcf`) Generator & Download

**Issue:** [#239](https://github.com/kmutahar/jekyll-theme-resume/issues/239) · **Branch:** `feature/vcard-generator` · **Closure:** `Closes #239`

Generate standard digital contact card (`.vcf`) files from `header.yml` data for each configured language, allowing recruiters to save candidate contact details to their address book in one tap.

**Files:** Create `_plugins/vcard_generator.rb`, update `_layouts/resume.html`, `_config.sample.yml`, all `_data/locales/*.yml`, and `docs/reference/config.md`.

**Implementation contract:** The Jekyll generator reads candidate metadata (`name`, `position`, `email`, `telephone`, `website`, `address`, `avatar_url`) from `_data/<lang>/header.yml` and outputs `/contacts/<lang>.vcf` in RFC 6350 (vCard 4.0/3.0) format with UTF-8 encoding. The theme provides an optional "Save Contact / vCard" button in the header or alongside the QR code component (Feature 1.5).

**Acceptance criteria:**

- [ ] Generated `.vcf` files parse cleanly on iOS, Android, macOS Contacts, and Outlook.
- [ ] Non-ASCII characters (Arabic, Urdu, accented Latin names) are correctly encoded.
- [ ] Contact button respects all-locale parity and print hiding rules.
- [ ] Private or omitted fields in `header.yml` leave no empty vCard fields.

### Feature 3.4: ATS Plain-Text & Markdown Resume Export (`/resume.txt` / `/resume.md`)

**Issue:** [#240](https://github.com/kmutahar/jekyll-theme-resume/issues/240) · **Branch:** `feature/ats-plaintext-export` · **Closure:** `Closes #240`

Generate clean, machine-parseable plain-text (`.txt`) and Markdown (`.md`) resume files for each locale, formatted specifically for direct copy-pasting into corporate ATS application portals.

**Files:** Create `_plugins/ats_export_generator.rb` or template pages `assets/exports/resume.txt`, update `_config.sample.yml`, `docs/reference/config.md`, and all `_data/locales/*.yml`.

**Implementation contract:** Read the active language resume data and render an unstyled, plain-text document with standardized uppercase section titles (e.g., `EXPERIENCE`, `EDUCATION`, `SKILLS`), standardized bullet points, and tab-separated date alignments. Exclude HTML tags, SVG markup, and styling artifacts. Files are emitted at `/exports/<lang>/resume.txt` and `/exports/<lang>/resume.md`.

**Acceptance criteria:**

- [ ] Generated `.txt` and `.md` files contain zero HTML tags or Liquid artifacts.
- [ ] Section titles follow standard ATS parsing conventions in English and localized equivalents.
- [ ] Character encoding is strict UTF-8 with clean line endings (LF).
- [ ] All active resume sections appear in the configured `resume_section_order`.

### Feature 3.5: JSON Resume Importer CLI (`bin/import-json-resume`)

**Issue:** [#241](https://github.com/kmutahar/jekyll-theme-resume/issues/241) · **Branch:** `feature/json-resume-importer` · **Closure:** `Closes #241`

Provide a command-line utility to bootstrap a new resume from an existing JSON Resume (`resume.json`) file or URL, mapping standard schema fields into the theme's modular YAML data structure.

**Files:** Create `bin/import-json-resume`, `lib/jekyll-theme-resume/json_resume_importer.rb`, `test/test_json_resume_importer.rb`, and `docs/how-to/import-json-resume.md`.

**Implementation contract:** The CLI takes an input JSON Resume file or HTTP URL and target language code (default `en`): `bin/import-json-resume <input.json> --lang en [--dest _data] [--overwrite]`. It reverse-maps JSON Resume sections (`basics` → `header.yml`, `work` → `experience.yml`, `education` → `education.yml`, `skills` → `skills.yml`, `projects` → `projects.yml`, etc.) into YAML files conforming to the theme's data schemas. Runs the validator (`ResumeValidator`) on generated output to ensure compliance before saving.

**Acceptance criteria:**

- [ ] Valid JSON Resume inputs produce compliant YAML files across all mapped sections.
- [ ] Generated YAML passes `bin/validate-resume` without warnings or errors.
- [ ] Existing files are not overwritten unless `--overwrite` is explicitly passed.
- [ ] Clear error reporting for malformed JSON or unsupported schema versions.

### Feature 3.6: Automated ATS Compatibility Linter (`bin/lint-ats`)

**Issue:** [#242](https://github.com/kmutahar/jekyll-theme-resume/issues/242) · **Branch:** `feature/ats-linter` · **Closure:** `Closes #242`

Introduce a specialized linter CLI that audits the rendered resume HTML and data against industry-standard Applicant Tracking System (ATS) parsing heuristics.

**Files:** Create `bin/lint-ats`, `lib/jekyll-theme-resume/ats_linter.rb`, `test/test_ats_linter.rb`, and `docs/reference/validator-cli.md`.

**Implementation contract:** Operates on built HTML or data files. Evaluates:
1. Standard Section Titles: Checks if section titles match recognizable ATS headings.
2. Single-Column Flow: Warns if reading order is broken by multi-column CSS or absolute positioning.
3. Contact Information: Checks for essential parsed fields (full name, email, phone, location).
4. Date Parsing: Verifies that job dates use recognizable ISO or Month Year formats without ambiguous abbreviations.
5. Icon-Only Information: Flags any content conveyable only via SVG icons without text alternatives.

**Acceptance criteria:**

- [ ] Outputs a structured PASS/WARN/FAIL score report with specific remediation advice.
- [ ] Runs across all configured locales without language bias.
- [ ] Integrates as an optional check in `bin/verify` or Rake task (`rake ats:lint`).
- [ ] Zero dependencies outside the theme's standard Ruby gems.

### Feature 4.2: Interactive Career Timeline Visualization

**Issue:** [#16](https://github.com/kmutahar/jekyll-theme-resume/issues/16) · **Branch:** `feature/career-timeline` · **Closure:** `Closes #16`

Add a timeline presentation for career milestones, reusing current multilingual resume data.

**Files:** Create `_layouts/resume-timeline.html` and `_sass/_timeline.scss`; reuse shared head/data/date components and document the layout in a new `docs/TIMELINE_GUIDE.md`.

**Implementation contract:** Use a semantic chronological structure with optional progressive enhancement. Explicitly provide the new layout on hand-authored pages; the existing generator only creates resume/profile layouts. Keep plain-text reading and print order coherent.

**Acceptance criteria:**

- [ ] Career entries render in a defined chronological order.
- [ ] The visual timeline mirrors appropriately in RTL.
- [ ] Keyboard access and a readable print/text fallback work without interaction.

### Feature 4.3: Contact Form Integration (Formspree / Netlify)

**Issue:** [#20](https://github.com/kmutahar/jekyll-theme-resume/issues/20) · **Branch:** `feature/contact-form` · **Closure:** `Closes #20`

Add an optional contact form with inline or modal presentation and a configured submission backend.

**Files:** Create `_includes/contact-form.html`; integrate into shared layouts, locale strings, styles, `_config.sample.yml`, and a new `docs/CONTACT_FORM_GUIDE.md`.

**Implementation contract:** Proposed settings: `resume_contact_form` (false) and `contact_form` with `provider`, `display_mode`, provider ID or `endpoint`. Earlier provider candidates include Formspree, Formcarry, Netlify, and Getform; verify each provider’s current integration contract during implementation. A honeypot may reduce spam but is not a guarantee. Keep secrets out of static output and define success/error states.

**Acceptance criteria:**

- [ ] Submission reaches the configured provider and reports success/failure accessibly.
- [ ] Modal mode supports keyboard focus, Escape, close control, and focus restoration.
- [ ] All labels/states are localized; the form is excluded from print.

### Feature 4.4: Privacy-First Resume Engagement Analytics

**Issue:** [#17](https://github.com/kmutahar/jekyll-theme-resume/issues/17) · **Branch:** `feature/privacy-analytics` · **Closure:** `Closes #17`

Add opt-in print and outbound-link events on top of the existing analytics integration.

**Files:** Create `assets/js/resume-analytics.js`; wire it through shared layout/analytics includes, `_config.sample.yml`, and a new `docs/ANALYTICS_GUIDE.md`.

**Implementation contract:** Proposed toggle: `resume_engagement_analytics` (false). Define event payloads and enabled-provider behavior. Avoid sending contact details or sensitive URL parameters. The dispatcher can avoid writing cookies/storage, but that does not establish that a configured third-party provider is cookie-free or privacy-preserving.

**Acceptance criteria:**

- [ ] Disabled mode emits no engagement events.
- [ ] Enabled print/link events fire once and degrade safely without a provider.
- [ ] Payloads omit personal data and the dispatcher does not add cookies/storage.

### Feature 4.5: Resume Comparison View

**Issue:** [#23](https://github.com/kmutahar/jekyll-theme-resume/issues/23) · **Branch:** `feature/resume-comparison` · **Closure:** `Closes #23`

Provide a side-by-side manual comparison of two existing resume pages or translations. The current proposal is a comparison UI, not a traffic-randomization or statistical A/B testing engine.

**Files:** Create `_layouts/resume-comparison.html`, optional `_includes/version-switcher.html`, `_sass/_comparison.scss`, and a new `docs/VERSIONING_GUIDE.md`.

**Implementation contract:** Accept page-level `v1_url`, `v2_url`, and localized pane labels; resolve local paths through relative_url. Label embedded panes and provide direct links. Existing data_path selection supports separate datasets; automatic role-specific tailoring is not part of this feature.

**Acceptance criteria:**

- [ ] Both chosen pages are visible with distinct accessible labels.
- [ ] The view stacks on narrow screens and supports LTR/RTL content.
- [ ] Missing/invalid targets have a documented fallback rather than blank unlabeled panes.

### Feature 4.7: Dynamic Custom Resume Sections Engine

**Issue:** [#219](https://github.com/kmutahar/jekyll-theme-resume/issues/219) · **Branch:** `feature/custom-sections-engine` · **Closure:** `Closes #219`

Allow additional sections such as patents or speaking without manually extending the standard dispatcher for each one.

**Status:** Designed, not started. Prerequisite met: #232 shipped, so the built-in list is final at 14 sections (experience, volunteering, education, skills, projects, languages, certifications, courses, associations, recognitions, interests, links, publications, references). Settings below do not exist until this ships.

**Files:**

- Create `_includes/resume-custom-section.html` (params `section_name`, `items`, `lang`).
- Extend `_includes/resume-section.html`, `lib/jekyll-theme-resume/resume_validator.rb`, `_config.sample.yml` (commented example).
- Tests: `test/test_resume_validator.rb`, `test/test_rendered_site.rb`, `test/test_json_resume_exporter.rb`, `test/test_packaging.rb`.
- Demo: `demo/_data/<lang>/speaking.yml`, `demo/_data/locales/<lang>.yml`, `demo/_config.yml` (6 languages).
- Docs:
  - Update: `data-schemas.md`, `config.md`, `locale-keys.md`, `override-locale-strings.md`, `includes.md`, `validator-cli.md`, `json-resume-fields.md`.
  - Rewrite: `how-to/add-a-section.md`, which currently teaches hand-editing the dispatcher. Custom sections come first; dispatcher edits are only for typed sections.

**Decisions (settled 2026-10-01; revisit D1 only deliberately):**

| # | Decision |
|---|---|
| D1 | **Implicit declaration.** Any name in `resume_section_order` that is not a built-in or reserved name, with `resume_section.<name>: true`, is a custom section. No new config key. |
| D2 | Item schema: `title` (required), `subtitle`, `date` (ISO), `enddate` (ISO or locale present value), `url`, `description` (plain text), `active`. Unknown extra keys are ignored. |
| D3 | Heading is `locale.ui.section_titles[<name>]` from the consuming site's locale overrides (the `custom_section_titles` global map is rejected as a duplicate source of truth). Missing title for a target language is a validator **error**; the template falls back to the raw name so an `<h2>` still renders. |
| D4 | Built-in names always win. `header`, `locales`, `lang_header` are reserved, so using one is a validator error. A configured custom section with no data file is a validator warning plus a silent skip at render. |
| D5 | The custom schema is applied only to files named by a configured custom section. Other unknown YAML files stay unvalidated, as today. |
| D6 | Custom sections are **not exported** to JSON Resume; document this. |
| D7 | `description` is plain text. Markdown is a separate future feature (see below). |
| D8 | Demo example: `speaking` (Holmes lectures), uses every field, in all 6 languages with site locale title overrides. |

**Rendering contract:** `<section class="content-section">` → `<h2>` → per active item:

- `h3.resume-item-title`: `title`, linked if `url` (`target="_blank" rel="noopener nofollow noreferrer"`), print-only URL span with `dir="ltr"` in RTL.
- `h4.resume-item-details`: `subtitle • date – enddate|Present`, dates via `date-formatter.html` (MDY). Bullets appear only between non-empty parts; `date` without `enddate` renders one date.
- `p.resume-item-copy`: `description`.
- Skip the whole section if there is no data file or no active items.

**Implementation contract and pitfalls (each needs a test):**

- **Disabled built-in falls through the `elsif` chain** in `resume-section.html`, so a naive `{% else %}` would render it as custom. Use a separate post-chain `if`: name is not a built-in, not reserved, and its toggle is true. Dedicated rendered test.
- **Validator dispatches by filename** and does not read `resume_section_order` or `resume_section` today (around `resume_validator.rb:201,424`). Load both in `load_language_config`, derive custom names, route to a new `validate_custom_entry`.
- **Built-in list is needed in Liquid and Ruby** (Liquid can't read Ruby constants). Keep one list in each (`BUILTIN_SECTIONS` / `RESERVED_SECTIONS` in Ruby) plus a parity test in `test/test_packaging.rb`.
- **Exporter must never pass a custom name to `FIELDS.fetch`** (raises `KeyError`). It iterates `SECTIONS` only, so no change is expected. Add a test proving custom sections are absent from the export.
- **Section name is a filename and a Liquid key:** validator error unless it matches `/\A[a-z][a-z0-9_]*\z/`.
- **`TemplateKeyChecker` does not trace bracket access** (`resume_data[section_name]`). That is acceptable (no false warnings); document it in `validator-cli.md`.
- **Partial locale overrides** (title in only some languages) also trigger `validate_locale_parity` warnings. Keep both and word the D3 error clearly; avoid double-reporting where possible.
- Reuse existing helpers (`validate_url`, `validate_date`, `validate_date_range`, `require_field`, `date-formatter.html`). `_sass/` probably needs no change; confirm RTL and print.

**Delivery notes:**

- Suggested commit split, each passing `rake` on its own:
  1. Validator + its tests.
  2. Include + dispatcher + packaging/exporter tests + `_config.sample.yml`.
  3. Docs + demo bump + rendered-site tests + roadmap/audit rows.
- Push order: demo repo first, then the theme branch.
- Commit message for the demo repo: `feat(data): add speaking custom section example (6 languages)`.
- Demo translations are drafted by agents; list every translated string in the PR body for native review.
- `CHANGELOG.md` and version are untouched in the PR. This is a deliberate deviation from §4's changelog rule, to be stated in the PR body.

**Future candidate (out of scope):** opt-in Markdown for text fields across all sections (`site.resume_markdown: true` using `markdownify`). Kramdown wraps output in `<p>`, which is invalid inside `h4` and inline contexts, so restrict to block fields or strip. Raw HTML passes through, making every field an HTML sink. The exporter would need `strip_html` (helper exists), and each section needs rendered tests.

**Acceptance criteria:**

- [ ] A configured custom section renders its localized heading and active items.
- [ ] All built-in schemas and rendering remain unchanged (existing tests pass).
- [ ] Missing data, missing title, and reserved names behave per D3–D4; links and dates work in RTL and print.
- [ ] A disabled built-in is never rendered as a custom section.

### Feature 4.8: Client-Side Site Search Index

**Issue:** [#225](https://github.com/kmutahar/jekyll-theme-resume/issues/225) · **Branch:** `feature/site-search` · **Closure:** `Closes #225`

Add localized resume search and an error-page search interface. The current error layout has no search form; both the index and interface remain future work.

**Files:** Create a generated `search.json` and `assets/js/site-search.js`; add a labelled form/results region to `_layouts/error.html` or a reusable include, plus locale strings and styles.

**Implementation contract:** Index resolved data for every configured language. Include active standard-section items, interests (which have no active flag), and deliberate summary text. Define stable result anchors before linking to sections/items. Use relative_url for index loading, exclude private/inactive data, and announce result updates accessibly.

**Acceptance criteria:**

- [ ] Queries return usable links for the selected language without a full navigation.
- [ ] Empty, no-match, index-load-error, and JavaScript-disabled states are defined.
- [ ] All standard sections are represented with the correct visibility rules.
- [ ] Keyboard navigation, RTL, and baseurl hosting work.

### Feature 4.10: Interactive Cross-Section Skill Highlighting

**Issue:** [#243](https://github.com/kmutahar/jekyll-theme-resume/issues/243) · **Branch:** `feature/interactive-skills` · **Closure:** `Closes #243`

Connect technical skills with real-world applications by interactively highlighting experience and project entries when a corresponding skill badge is clicked.

**Files:** Create `assets/js/skill-highlight.js`, update `_includes/resume-section.html`, `_sass/_resume-ltr.scss`, `_sass/_resume-rtl.scss`, `_config.sample.yml`, and `docs/reference/data-schemas.md`.

**Implementation contract:** Allow optional `skills: ["Ruby", "Docker"]` list on items in `experience.yml` and `projects.yml`. When `site.resume_interactive_skills: true` (default false), each skill pill in the skills section gains an interactive button role. Clicking a skill toggles a `.skill-active` class and adds a visual accent highlight (with accessible text badge) to all matching cards across the page. Fully zero-dependency vanilla JS; degrades gracefully to static display if JS is disabled.

**Acceptance criteria:**

- [ ] Clicking a skill highlights all associated experience and project items.
- [ ] Keyboard navigation (Enter, Space, Escape to clear) and ARIA states (`aria-pressed`) function accessibly.
- [ ] Visual highlights adapt to light and dark theme palettes.
- [ ] Completely inert when disabled or in print mode.

### Feature 4.11: Project Portfolio Media Previews & Modal Lightbox

**Issue:** [#244](https://github.com/kmutahar/jekyll-theme-resume/issues/244) · **Branch:** `feature/project-previews` · **Closure:** `Closes #244`

Add optional image previews, screenshots, and an accessible modal lightbox to project portfolio items.

**Files:** Create `_includes/project-lightbox.html`, update `_includes/resume-section.html`, shared SCSS, validator rules, `_config.sample.yml`, and `docs/reference/data-schemas.md`.

**Implementation contract:** Add optional `image:` or `screenshots:` list to `projects.yml` schema (`url`, `alt`, `caption`). Images render as thumbnail cards within project items. Clicking a thumbnail opens an accessible native HTML `<dialog>` or accessible lightbox modal showing the full image, caption, and navigation controls. Resolves images via `relative_url`. Print stylesheet suppresses dialog markup and scales thumbnails cleanly.

**Acceptance criteria:**

- [ ] Project thumbnails render neatly in both LTR and RTL layouts without layout breakage.
- [ ] Lightbox opens with focus trapping, Escape key closing, and visible close controls.
- [ ] Missing images render clean text-only project cards as before.
- [ ] All images have required, localized `alt` descriptions verified by the validator.

### Feature 4.12: Audience Scope & Target Role Switcher (1-Page Summary vs Detailed CV)

**Issue:** [#245](https://github.com/kmutahar/jekyll-theme-resume/issues/245) · **Branch:** `feature/role-scope-switcher` · **Closure:** `Closes #245`

Allow visitors and recruiters to toggle between an executive 1-Page Summary view and a Comprehensive Detailed CV view on the live site from a unified resume dataset.

**Files:** Create `assets/js/scope-switcher.js`, `_includes/scope-switcher.html`, update `_includes/resume-section.html`, all `_data/locales/*.yml`, `_config.sample.yml`, and `docs/reference/data-schemas.md`.

**Implementation contract:** Add optional `scope: summary | detailed` or `roles: [...]` tag on items across experience, projects, and education. When `site.resume_scope_switcher: true` (default false), the header displays a localized segmented control: `[Summary (1-Page) | Comprehensive]`. Toggling filters the visible DOM items with CSS transitions while preserving layout integrity and heading hierarchy. Print media query respects the currently active toggle state or defaults to a configured print scope.

**Acceptance criteria:**

- [ ] Switching between summary and comprehensive modes dynamically updates visible entries without page reloads.
- [ ] Items without an explicit `scope` tag remain visible in both modes.
- [ ] Segmented control is fully accessible via keyboard (`role="radiogroup"` or `role="tablist"`).
- [ ] All controls and mode labels are localized across all 6 locales.

### Feature 5.1: Paired Cover Letter Layout (`_layouts/cover-letter.html`)

**Issue:** [#246](https://github.com/kmutahar/jekyll-theme-resume/issues/246) · **Branch:** `feature/cover-letter-layout` · **Closure:** `Closes #246`

Provide a dedicated, printable Cover Letter layout that matches the typography, header branding, contact info, dark mode, and color theme of the resume.

**Files:** Create `_layouts/cover-letter.html`, `_sass/_cover-letter.scss`, `_plugins/cover_letter_generator.rb` (optional page auto-generator), `_config.sample.yml`, `docs/how-to/create-a-cover-letter.md`, and sample data `_data/<lang>/cover_letter.yml`.

**Implementation contract:** Layout renders `_data/<lang>/cover_letter.yml` with schema: `recipient: {name, title, company, address}`, `date` (ISO), `subject`, `opening`, `paragraphs: [...]`, `closing`, `signature_url`. Reuses `_includes/shared-head.html`, theme variables, and direction stylesheets. Formatted with professional margins and page-break controls to guarantee a clean 1-page printout on A4 and US Letter.

**Acceptance criteria:**

- [ ] Cover letter renders with identical brand typography, headers, and colors as the resume.
- [ ] Single-page print styling guarantees no overflow onto a second page for standard letter lengths.
- [ ] RTL layouts (Arabic and Urdu) mirror margins, signature alignment, and recipient headers correctly.
- [ ] Data validation in `ResumeValidator` checks required cover letter fields when present.

### Feature 5.2: BibTeX Publication Citations & Interactive DOI Resolver

**Issue:** [#247](https://github.com/kmutahar/jekyll-theme-resume/issues/247) · **Branch:** `feature/bibtex-publications` · **Closure:** `Closes #247`

Enhance the publications section for researchers and academics with rich citation rendering, direct DOI link resolution, candidate author name bolding, and a one-click "Cite" BibTeX popover.

**Files:** Update `_includes/resume-section.html`, `_sass/_resume-ltr.scss`, `_sass/_resume-rtl.scss`, `lib/jekyll-theme-resume/resume_validator.rb`, `_config.sample.yml`, and `docs/reference/data-schemas.md`.

**Implementation contract:** Extend `publications.yml` schema with optional `doi:`, `bibtex:`, `authors: [...]`, `journal:`, and `pdf_url:`. When `doi` is present, automatically render an authenticated DOI resolver link (`https://doi.org/...`). When `authors` list contains candidate's name (matching `header.name`), bold the candidate's name. Provide an accessible "Cite" button opening a clean copyable BibTeX modal or popover with a 1-click clipboard copy action.

**Acceptance criteria:**

- [ ] DOI links resolve cleanly without duplicate URL prefixes.
- [ ] Candidate's name is highlighted in author lists across all configured language forms.
- [ ] The "Cite" button exposes formatted BibTeX text with an accessible copy confirmation.
- [ ] Basic publication entries without academic fields continue to render identically to existing output.

### Feature 5.3: Patents & Research Grants Dedicated Schemas (JSON Resume Compatible)

**Issue:** [#248](https://github.com/kmutahar/jekyll-theme-resume/issues/248) · **Branch:** `feature/patents-and-grants` · **Closure:** `Closes #248`

Introduce first-class, structured schemas for patents and research grants with full validation and JSON Resume standard export support.

**Files:** Extend `lib/jekyll-theme-resume/resume_validator.rb`, `lib/jekyll-theme-resume/json_resume_exporter.rb`, `_includes/resume-section.html`, `_data/locales/*.yml`, `_config.sample.yml`, and `docs/reference/data-schemas.md`.

**Implementation contract:**
- Patents schema (`patents.yml`): `title` (required), `patent_number`, `jurisdiction` (e.g. USPTO, EPO, WIPO), `date` (filing or grant date), `url`, `status` (`pending` / `granted`), `description`, `active`.
- Grants schema (`grants.yml`): `title` (required), `funder` / `agency`, `grant_number`, `amount`, `role` (e.g. Principal Investigator, Co-PI), `date`, `enddate`, `url`, `description`, `active`.
- Add `patents` and `grants` to standard section order. Map `patents` directly to JSON Resume `patents` array in exporter.

**Acceptance criteria:**

- [ ] `patents.yml` and `grants.yml` are validated for field types, date ranges, and URL formats.
- [ ] Sections render with localized headings and status badges in both LTR and RTL.
- [ ] Patents cleanly export to the official JSON Resume `patents` standard schema.
- [ ] All 6 locale files define section titles and status labels with full parity.

## 3. Verification and Delivery

Follow [AGENTS.md](AGENTS.md) for the commit-approval and delivery rules. A documentation blueprint is not proof that a feature exists. Update current guides and `_config.sample.yml` only when implementation lands. When a feature ships, delete its brief and matrix row here, and add one row to [docs/COMPLETED_AUDIT.md](docs/COMPLETED_AUDIT.md) plus the changelog entry.

From the theme repository, with the demo submodule initialized:

```bash
git submodule update --init --recursive
bundle exec jekyll build --source demo --destination _site --strict_front_matter --trace
bundle exec rake
bundle exec rake "proof[_site,demo/_config.yml]"
./bin/validate-resume demo/_data --all-locales --fail-on-warnings
gem build jekyll-theme-resume.gemspec
rm -f jekyll-theme-resume-*.gem
```

For UI changes, inspect all configured locales, both direction stylesheets, light/dark states, keyboard operation, and print output. Add feature-specific verification that tests the behavior rather than only looking for a string in generated HTML. The default Rake task includes data validation, template-key warnings, RuboCop, and every test suite; HTML proofing is separate. See [docs/reference/testing-suites.md](docs/reference/testing-suites.md) and [docs/reference/validator-cli.md](docs/reference/validator-cli.md).
