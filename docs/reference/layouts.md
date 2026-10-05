# Layouts reference (`_layouts/`)

*Audience: site owners and theme developers*

The theme's layouts in [`_layouts/`](../../_layouts): what each one renders, how the resume layout resolves its language and data, and where a custom layout fits. To build one, see [Create a custom layout](../how-to/create-a-custom-layout.md).

---

## Overview & Layout Hierarchy

Hand-authored pages select a layout in front matter. The theme also generates missing CV/profile pages; see [page configuration](config.md#3-languages). A resume page is `layout: resume` plus `lang: <code>`; there is no per-language layout.

```text
_layouts/default.html   (base shell: <head>, anti-FOUC, dark mode, footer)
 └── _layouts/error.html  (HTTP 404, 403, 500, 503)

_layouts/profile.html   (standalone landing page)
_layouts/resume.html    (standalone resume, one layout for every language and direction)
```

---

## Language Resolution

The common language-resolution pattern is shown below. Some includes accept `include.lang`; the default/profile layouts also fall back to the English locale if neither the page nor default locale exists:

```liquid
{% assign lang = page.lang | default: site.default_lang | default: 'en' %}
{% assign locale = site.data.locales[lang] | default: site.data.locales[site.default_lang] %}
{% assign lang_cfg = site.languages[lang] %}
```

- `locale` is the merged locale file `_data/locales/<lang>.yml` (theme file with any site override on top). It supplies `direction`, fonts, line height, UI strings, month names, and error copy.
- `lang_cfg` is the `languages.<lang>` config block. It supplies `data_path`, `url`, `header_intro`, `name`, `resume_title`, `address`, and `avatar_alt`.

The active language resolves in this order: `page.lang`, then `site.default_lang`, then `en`. The repository's own demo pages are in [`demo/`](../../demo/). English and Arabic CVs are hand-authored there; Spanish, French, German, and Urdu CVs are generated.

The locale schema is in [Locale keys](locale-keys.md); the `languages` schema is in [Configuration reference](config.md#3-languages).

---

## Layout Inventory

### 1. `default.html` (Base Layout)

- **File:** [`_layouts/default.html`](../../_layouts/default.html)
- **Role:** Shell for markdown pages and error pages.
- `<html lang="{{ lang }}" dir="{{ locale.direction }}">`, skip link text from `locale.ui.skip_to_content`.
- Includes [`shared-head.html`](../../_includes/shared-head.html), a stylesheet link to `assets/css/main.css`, `{% seo %}`, and the analytics includes.
- Emits `<link rel="me">` when `site.social_links.mastodon` is set.
- Includes [`dark-mode-toggle.html`](../../_includes/dark-mode-toggle.html) and [`language-switcher.html`](../../_includes/language-switcher.html) (also present on error pages unless disabled by site/page settings), and wraps content in `<main class="main-content" id="main-content">`.

### 2. `profile.html` (Portfolio Landing)

- **File:** [`_layouts/profile.html`](../../_layouts/profile.html)
- **Role:** Standalone landing page, independent of `default.html` so its centering styles do not leak.
- Same `lang` / `dir` resolution, skip link, dark mode toggle, and language switcher as `default.html`.
- Uses `languages.<lang>.name`, optional `name_html`, and `about` for its header; the CV button points to `languages.<lang>.url`. Calls `hreflang.html` for translated profile pages sharing `t_id: profile`.
- Social icons come from [`social-links.html`](../../_includes/social-links.html). When `social_links` is set, `contact_info.email` is set, and `social_links.email` is not, one extra labelled email icon is added.
- Stylesheet [`assets/css/profile.scss`](../../assets/css/profile.scss) (compiled to `assets/css/profile.css`, linked directly in the layout's `<head>`), styled by [`_sass/_profile-page.scss`](../../_sass/_profile-page.scss).

### 3. `resume.html` (Resume, Every Language)

- **File:** [`_layouts/resume.html`](../../_layouts/resume.html)
- **Role:** The resume for any configured language, LTR or RTL.
- **Head:**
  - `<html lang="{{ lang }}" dir="{{ locale.direction }}">`.
  - Loads `locale.font_url` when set, else the default Lora and Open Sans stylesheet; neither loads when `disable_google_fonts: true` or `resume_theme: no-custom-fonts`.
  - Emits `--font-locale` (from `locale.font_family`, when non-empty) and `--line-height-locale` (from `locale.line_height`) in an inline `:root` style.
  - Links `assets/css/cv-{{ locale.direction }}.css`, so LTR locales get `cv-ltr.css` and RTL locales get `cv-rtl.css`.
  - Includes [`hreflang.html`](../../_includes/hreflang.html), `{% seo %}`, [`json-ld-resume.html`](../../_includes/json-ld-resume.html) (after `{% seo %}`), and the analytics head include.
- **Person microdata:** the `.wrapper` element is a Schema.org `Person` with `itemid` set to the JSON-LD Person `@id` (`<site url>/<path>/#person`), so parsers merge it with the JSON-LD block. The `itemid` is omitted when no absolute URL is available. Microdata `telephone` and `address` are emitted only when `display_header_contact_info: true`; `email` also when `resume_looking_for_work: true`. This is the same rule as the [JSON Resume export](json-resume-fields.md#visibility-and-privacy).
- **Header:** avatar (when `resume_avatar: true`), `lang_cfg.name`, the contact row (when `display_header_contact_info: true`), the header language list (when `display_header_contact_info: true` and `resume_section.lang_header` is set), `lang_cfg.resume_title`, social icons (when `social_links` is set), the `header.yml` intro (when `lang_cfg.header_intro: true`), and the contact button (per `resume_looking_for_work`).
- **Contact row:** icon first, then text, in every direction. Phone numbers and emails carry `dir="ltr"`. The date of birth goes through [`date-formatter.html`](../../_includes/date-formatter.html).
- **Body:** loops `site.resume_section_order` through [`resume-section.html`](../../_includes/resume-section.html), then the print-only social links section when `resume_print_social_links` is set.
- **Footer:** localized "last generated" line and, when `enable_live == false`, a print-only footer with the page's permalink.

### 4. `error.html` (Multilingual HTTP Error Suite)

- **File:** [`_layouts/error.html`](../../_layouts/error.html), extends `default.html`. Used by `404.html`, `403.html`, and `500.html`.
- Reads `page.code` (default `"404"`) and server-renders a single heading/message block in `default_lang`.
- On `DOMContentLoaded`, the inline script removes `site.baseurl` from the start of `window.location.pathname`, then checks whether the rest begins with a configured `/<lang>/` prefix (so `/portfolio/ar/missing` on a `baseurl: /portfolio` site shows Arabic). It updates the block’s text, `lang`, and `dir`, plus the Home button’s label and destination. It does not use browser language or a stored preference.
- With JavaScript disabled, or without a matching prefix, the default-language content remains. The script changes the error block, not the outer page’s language or switcher label.
- The single Home link prefers the selected language’s `layout: profile` page, then `languages.<lang>.url`, then `/`. Reload is shown for `500`, `503`, or `page.show_reload: true`; its label remains in the default locale.
- There is no search form or per-language return-link list in the current error layout. Search is not currently supported.
- [`_plugins/error_pages_generator.rb`](../../_plugins/error_pages_generator.rb) creates missing `404.html`, `403.html`, and `500.html`. A manual `layout: error`, `code: 503` page is supported but is not generated automatically. Load the theme through the Gemfile’s `:jekyll_plugins` group or the config’s `plugins:` list.

---

## Dynamic Data Resolution

`resume.html` calls [`_includes/data-loader.html`](../../_includes/data-loader.html) with `path=lang_cfg.data_path`. The include binds `resume_data` by walking `site.data` one dot-separated segment at a time:

```liquid
{%- assign resume_data = site.data -%}
{%- if data_path.size > 0 -%}
  {%- assign path_parts = data_path | split: '.' -%}
  {%- for part in path_parts -%}
    {%- assign resume_data = resume_data[part] -%}
  {%- endfor -%}
{%- endif -%}
```

See [data-driven model](../explanation/data-driven-model.md) for why presence checks avoid `!= blank` and why bracket access is used.

```yaml
languages:
  en:
    data_path: en              # site.data.en
  ar:
    data_path: "2025-06.v1-ar" # site.data["2025-06"]["v1-ar"]
  es:
    data_path: ""              # site.data (files directly in _data/)
```

When called without `path`, the include falls back to `site.languages[page.lang or default_lang].data_path`.

---

## Resume Rendering Pipeline

The order of operations for one resume page:

```text
1. Resolve lang, locale, lang_cfg; load resume_data from lang_cfg.data_path
2. <head>: shared-head, locale font + CSS variables, cv-<direction>.css, hreflang, SEO, JSON-LD, analytics
3. Body start: analytics-body, dark-mode-toggle, language-switcher
4. Header: avatar, name, contact row, header languages, title, social icons, intro, contact button
5. Sections: for each name in site.resume_section_order
     {% include resume-section.html section_name=section_name lang=lang %}
6. Print-only social links (print-social-links.html)
7. Footer and print-only permalink footer
```

---

## Dark Mode & Anti-FOUC Mechanics

Layouts include [`dark-mode-toggle.html`](../../_includes/dark-mode-toggle.html). To configure it, see [Enable dark mode](../how-to/enable-dark-mode.md); for the anti-FOUC script and the two activation tiers, see [dark mode approach](../explanation/dark-mode-approach.md).

---

## Creating Custom Layouts

See [Create a custom layout](../how-to/create-a-custom-layout.md).
