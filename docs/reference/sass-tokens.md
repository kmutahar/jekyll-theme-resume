# Sass reference (`_sass/`)

*Audience: theme developers*

Reference for the theme's styling system in [`_sass/`](../../_sass) and the entrypoint stylesheets in [`assets/css/`](../../assets/css): Dart Sass module architecture, partial inventory, and the dark mode tokens.

---

## Entrypoints & Compilation Architecture

### Stylesheet Entrypoints

Jekyll compiles files in [`assets/css/`](../../assets/css) that start with YAML front matter into final static CSS assets:

| Source SCSS | Compiled Output CSS | Consuming Layouts |
|---|---|---|
| [`assets/css/cv-ltr.scss`](../../assets/css/cv-ltr.scss) | `assets/css/cv-ltr.css` | [`_layouts/resume.html`](../../_layouts/resume.html) for every locale with `direction: ltr` |
| [`assets/css/cv-rtl.scss`](../../assets/css/cv-rtl.scss) | `assets/css/cv-rtl.css` | [`_layouts/resume.html`](../../_layouts/resume.html) for every locale with `direction: rtl` |
| [`assets/css/profile.scss`](../../assets/css/profile.scss) | `assets/css/profile.css` | [`_layouts/profile.html`](../../_layouts/profile.html) |
| [`assets/css/main.scss`](../../assets/css/main.scss) | `assets/css/main.css` | [`_layouts/default.html`](../../_layouts/default.html), [`_layouts/error.html`](../../_layouts/error.html) |

### Modern Dart Sass `@use` Architecture

The theme uses `@use` exclusively. The reasons are in [Why `@use` instead of `@import`](../explanation/architecture.md#why-use-instead-of-import).

### Overriding Partials in a Consuming Site

Steps: [Override Sass partials](../how-to/override-sass-partials.md).

---

## SCSS Partial Inventory

### 1. `_variables.scss`

- **File:** [`_sass/_variables.scss`](../../_sass/_variables.scss)
- **Role:** Font stacks and default sizes. Only `$white` and `$text_color` are read (by `_base.scss`, as fallbacks for `--bg-color` and `--text-color`); the other variables are currently unused.
- **Variables:**
  - `$white`, `$text_color`: color fallbacks. They are not declared with `!default`, so they cannot be configured with `@use ... with`.
  - `$container-width: 980px !default;`, `$grid-gutter: 10px !default;`, `$body-font`, `$mono-font`, `$body-font-size: 13px !default;`: declared but not used by any partial or entrypoint.

---

### 2. `_mixins.scss`

- **File:** [`_sass/_mixins.scss`](../../_sass/_mixins.scss)
- **Role:** Breakpoint helpers, typography mixins, and border accents.
- **Key Mixins:**
  - `@mixin media_mobile` (`max-width: 600px`)
  - `@mixin media_larger_than_mobile` (`min-width: 600px`)
  - `@mixin sans`, `@mixin serif`, `@mixin section_border`

---

### 3. `_normalize.scss`

- **File:** [`_sass/_normalize.scss`](../../_sass/_normalize.scss)
- **Role:** Normalize.css v8.0.1 browser baseline reset.

---

### 4. `_base.scss`

- **File:** [`_sass/_base.scss`](../../_sass/_base.scss)
- **Role:** HTML and body defaults, box-sizing, and screen-reader accessibility classes.
- **Key Features:**
  - Universal `box-sizing: border-box`.
  - `.sr-only` utility class for WCAG screen-reader announcements.
  - Selection background and text styling.

---

### 5. `_layout.scss`

- **File:** [`_sass/_layout.scss`](../../_sass/_layout.scss)
- **Role:** Floating language switcher component (`.language-switcher`, fixed top-left, hidden in print; this hiding stays here because other bundles compile `_layout.scss`). The former grid classes (`.container`, `.columns`, `.one-third`, and so on) were removed.

---

### 6. `_resume-ltr.scss`

- **File:** [`_sass/_resume-ltr.scss`](../../_sass/_resume-ltr.scss)
- **Role:** The main resume stylesheet: every shared screen rule plus LTR positioning. It holds no print rules; those live in [`_print.scss`](#6a-_printscss). Both entrypoints load it; `cv-rtl.scss` then layers `_resume-rtl.scss` on top.
- **Typography:** resume text reads `var(--font-locale, <default stack>)` and `var(--line-height-locale, <default>)`, so each locale's font and line height apply without per-language rules.
- **Components Styled:**
  - Header: Avatar (`.avatar`), candidate name, contact info row, and social links bar.
  - Contact CTA button (`.contact-button`) and "not looking" modifier.
  - Section headers (`.section-header`) and item cards (`.resume-item`).
  - Two-column responsive Languages table.

---

### 6a. `_print.scss`

- **File:** [`_sass/_print.scss`](../../_sass/_print.scss)
- **Role:** Every `@media print` rule and print-visibility class (`.print-only`, `.print-only-inline`, `.no-print`) for the resume layout. `cv-ltr.scss` and `cv-rtl.scss` load it last so print overrides win the cascade.
- **Kept elsewhere on purpose:** the `.language-switcher` hiding stays in `_layout.scss` and the light colour tokens stay in `_dark-mode.scss`, because other bundles compile those partials and do not load `_print.scss`.

#### Print rules

| Selector | Rule | Why |
|---|---|---|
| `@page` | `size: auto; margin: 15mm 14mm` | Paper size follows the printer dialog (A4 or Letter); the page margin is the only margin |
| `.wrapper` | `padding: 0` | Avoids doubling the `@page` margin |
| `.page-footer.print-only` | `padding-top: 0; margin-bottom: 0` | Keeps the permalink footer from adding a blank trailing page |
| `.section-header`, `.resume-item-title`, `.resume-item-details` | `break-after: avoid` | Keeps a heading with the entry that follows |
| `.resume-item`, `.resume-item-list li` | `break-inside: avoid` | Keeps entries whole; a hint, so an entry longer than a page still splits |
| `.resume-item-copy`, `.resume-item-list li` | `orphans: 3; widows: 3` | No one- or two-line fragments at a page edge |
| `body` | `font-size: 10pt; line-height: calc(var(--line-height-locale, 1.5) * .9)` | Compact density; locale line height is kept (Urdu Nastaliq needs the room) |
| `.page-header` | Reduced padding; name `2rem` with the existing print sans stack | Saves page space; Arabic name extracts correctly from Chromium PDFs |
| `.section-header` | Hairline border; `h2` at `13pt`, line height `calc(var(--line-height-locale, 1.5) * .9)` | Lighter rules for paper |
| `.resume-item-title` | `12pt`; line height `calc(var(--line-height-locale, 1.5) * .8)` | Locale-driven, so Nastaliq does not overflow |
| `.resume-item-details` | `10pt` italic (`9pt` for `.award-title`); line height `calc(var(--line-height-locale, 1.5) * .8)` | Same as the title |
| `.lang-entry` | Locale line height × .9 | Overrides compact screen spacing for printed language descriptions |
| `.languages-table` | Stays a two-column table; `break-inside: avoid` | Does not stack to one column on paper |
| `.no-print` | `display: none` | Hides interactive controls |
| `.print-only`, `.print-only-inline` | Hidden on screen; shown (`block`, `inline`) in print | Printed contact text and URLs |

---

### 7. `_resume-rtl.scss`

- **File:** [`_sass/_resume-rtl.scss`](../../_sass/_resume-rtl.scss)
- **Role:** Language-neutral RTL overrides scoped under `html[dir="rtl"]`, loaded last by `cv-rtl.scss`. Serves Arabic, Urdu, and any future RTL locale.
- **Key Overrides:**
  - Flips horizontal floats, text alignments, borders, and margins.
  - Repositions timeline bullets and contact icons for RTL reading order.
  - Resets `letter-spacing` to `normal` on headings.
  - Sets no `font-family` or `line-height`; those come from the locale CSS variables.

---

<a id="8-_profile-pagescss"></a>
<a id="8-_profile-page-scss"></a>
### 8. `_profile-page.scss`

- **File:** [`_sass/_profile-page.scss`](../../_sass/_profile-page.scss)
- **Role:** Styles for the dedicated portfolio landing page layout ([`_layouts/profile.html`](../../_layouts/profile.html)) and entrypoint [`assets/css/profile.scss`](../../assets/css/profile.scss).
- **Architecture:** Provides clean, unconstrained vertical centering, avatar, bio typography, and CV action button without duplicating universal footer or SVG icon styles (which are loaded from [`_all-pages.scss`](../../_sass/_all-pages.scss)).

---

### 9. `_all-pages.scss`

- **File:** [`_sass/_all-pages.scss`](../../_sass/_all-pages.scss)
- **Role:** Universal styles shared across all layouts.
- **Key Features:**
  - Shared icon-link sizing, hover animations, and `.page-footer` spacing. Shared rules live here and `.sr-only` lives in `_base.scss`.
  - Complete dark-mode-aware typography rules for markdown content in `.main-content` (headings, paragraphs, blockquotes, tables, lists, and code blocks).

---

### 10. `_dark-mode.scss`

- **File:** [`_sass/_dark-mode.scss`](../../_sass/_dark-mode.scss)
- **Role:** Single source of truth for all color tokens, theme overrides, and the floating toggle button.

---

## The Dark Mode Token System

### Design Tokens Table

Shared color styles use CSS custom properties defined on `:root` in [`_sass/_dark-mode.scss`](../../_sass/_dark-mode.scss):

| CSS Custom Property | Light Mode Value | Dark Mode Value | Semantic Role |
|---|---|---|---|
| **Background & Typography** | | | |
| `--bg-color` | `#ffffff` | `#121212` | Main page and viewport background |
| `--text-color` | `#333` | `#e0e0e0` | Primary reading and heading typography |
| `--text-muted` | `#999` | `#888888` | Secondary copy, timestamps, and details |
| `--text-light` | `#646464` | `#aaaaaa` | Tertiary descriptive text |
| `--border-color` | `#c7c7c7` | `#333333` | Section dividers and card borders |
| `--card-bg` | `#efefef` | `#1e1e1e` | Button backgrounds and code blocks |
| **Links & Navigation** | | | |
| `--link-color` | `#333` | `#e0e0e0` | Interactive hyperlinks |
| `--link-hover` | `#9c9c9c` | `#ffffff` | Hyperlink hover color |
| `--link-hover-color` | `var(--link-hover)` | `var(--link-hover)` | Hyperlink hover alias |
| **Accent & Brand** | | | |
| `--accent-color` | `#3064a9` | `#6ba4e8` | Primary accents and focus outlines |
| `--accent-contrast-text` | `#ffffff` | `#121212` | Text and focus outline against the accent background |
| `--accent-hover` | `#307EA9` | `#8cbcf3` | Accent hover state |
| `--accent-hover-color` | `var(--accent-hover)` | `var(--accent-hover)` | Accent hover alias |
| `--social-hover-color` | `var(--accent-hover)` | `var(--accent-hover)` | Social icons hover color |
| `--about-color` | `var(--text-light)` | `var(--text-light)` | Executive summary / about text color |
| **Footer** | | | |
| `--footer-text-color` | `var(--text-muted)` | `var(--text-muted)` | Footer copyright typography |
| `--footer-link-color` | `var(--link-color)` | `var(--link-color)` | Footer hyperlink color |
| **Icons & Graphics** | | | |
| `--icon-fill` | `#333` | `#e0e0e0` | Social and contact SVG icon fill |
| `--icon-fill-muted` | `#555555` | `#888888` | Muted secondary icon fill |
| `--icon-fill-dark` | `#000` | `#ffffff` | Dark/prominent icon fill |
| `--icon-hover-fill` | `var(--icon-fill-dark)` | `var(--icon-fill-dark)` | Icon hover fill |
| `--header-icon-fill` | `var(--icon-fill-dark)` | `var(--icon-fill-dark)` | Header contact icon fill |
| **Buttons (.contact-button, .cv-button)** | | | |
| `--button-bg` | `#efefef` | `#2a2a2a` | Action button background |
| `--button-text` | `#333` | `#e0e0e0` | Action button label color |
| `--button-hover-bg` | `#333` | `#444444` | Action button hover background |
| `--button-hover-text` | `#fff` | `#ffffff` | Action button hover label color |
| **Text Selection** | | | |
| `--selection-bg` | `rgba(51, 51, 51, .8)` | `rgba(107, 164, 232, .5)` | Highlighted text background |
| `--selection-color` | `#fff` | `#ffffff` | Highlighted text color |
| **Dark Mode Toggle Component** | | | |
| `--toggle-btn-bg` | `transparent` | `transparent` | Toggle button background |
| `--toggle-btn-border` | `var(--border-color)` | `var(--border-color)` | Toggle button border |
| `--toggle-btn-color` | `var(--text-color)` | `var(--text-color)` | Toggle button icon color |
| `--toggle-btn-hover-bg` | `var(--button-bg)` | `var(--button-bg)` | Toggle button hover background |
| `--toggle-btn-focus-ring`| `var(--accent-color)`| `var(--accent-color)`| Toggle button focus ring outline |

### Two-Tier Activation Mechanism

Why activation has two tiers: [Dark mode approach](../explanation/dark-mode-approach.md#two-tiers-of-activation).

1. **Automatic Detection:**
   ```scss
   @media (prefers-color-scheme: dark) {
     :root:not([data-color-scheme="light"]):not([data-theme="light"]) {
       --bg-color: #121212;
       --text-color: #e0e0e0;
       // ...
     }
   }
   ```
2. **Explicit User Pin:**
   ```scss
   :root[data-color-scheme="dark"],
   :root[data-theme="dark"] {
     --bg-color: #121212;
     --text-color: #e0e0e0;
     // ...
   }
   ```

### Print Media Resets

The colour reset for print lives in [`_sass/_dark-mode.scss`](../../_sass/_dark-mode.scss) (all other print rules are in [`_print.scss`](#6a-_printscss)):

```scss
@media print {
  :root,
  :root[data-color-scheme="dark"],
  :root[data-color-scheme="light"],
  :root[data-theme="dark"],
  :root[data-theme="light"],
  [data-color-scheme="dark"],
  [data-theme="dark"],
  html.dark,
  html.light {
    color-scheme: light !important;
    --bg-color: #ffffff !important;
    --text-color: #000000 !important;
    --border-color: #c7c7c7 !important;
    --card-bg: #fff !important;
    /* ...every other color token (text, link, accent, icon, button, selection) is reset the same way */
  }
  html,
  body {
    background-color: #fff !important;
    color: #000 !important;
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }
  .dark-mode-toggle,
  #dark-mode-toggle {
    display: none !important;
  }
}
```

The block resets every color token to black, white, or grey values, whichever scheme the page is pinned to, forces `html` and `body` to `#fff` and `#000`, and hides the toggle.

---

## WCAG 2.2 Accessibility & High-Contrast Standards

- **Contrast:** see [Accessibility decisions](../explanation/accessibility-decisions.md) for the pair-based contrast rule; [accessibility-coverage.md](accessibility-coverage.md) lists current limitations and verification steps.
- **Focus Rings:** Interactive elements feature high-contrast visible focus outlines:
  ```scss
  :focus-visible {
    outline: 2px solid var(--accent-color, #3064a9);
    outline-offset: 2px;
  }
  ```
- **Screen-Reader Utility:**
  ```scss
  .sr-only {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip: rect(0, 0, 0, 0);
    white-space: nowrap;
    border-width: 0;
    text-decoration: none !important;
  }
  ```

---

## Locale Typography & RTL Mechanics

- **Per-locale typography:** `_layouts/resume.html` emits `--font-locale` (from the locale's `font_family`, when non-empty) and `--line-height-locale` (from `line_height`) in an inline `:root` style, and `_sass/_resume-ltr.scss` reads both with the theme defaults as fallbacks. Shipped font and line-height values: [locale-keys.md](locale-keys.md#shipped-locales). To change a language's font, see [Override locale strings](../how-to/override-locale-strings.md#change-a-languages-font).
- **Direction selects the entrypoint:** the layout links `cv-<direction>.css` (see the entrypoints table).
- **RTL scope:** overrides activate via `html[dir="rtl"]`; rationale in [Multilingual and RTL design](../explanation/multilingual-and-rtl-design.md#typography--rtl).
