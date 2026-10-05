# Multilingual and RTL design

*Audience: site owners and theme developers*

Why the theme treats a language as data rather than code, how theme and site locale files layer, and why right-to-left support is language-neutral. For task steps see [add a language](../how-to/add-a-language.md) and [override locale strings](../how-to/override-locale-strings.md); for the key list see the [locale keys reference](../reference/locale-keys.md).

## What a language is

Since v1.0.0 the theme renders every language through one layout, `_layouts/resume.html`. A language is three things:

1. A **locale file**, `_data/locales/<lang>.yml`: text direction, font, line height, UI strings, month names, "present" words, and error page copy.
2. A **data folder**, `_data/<data_path>/`: the resume content (`experience.yml`, `education.yml`, and so on). Schemas are in [`data-schemas.md`](../reference/data-schemas.md).
3. A **config entry**, `languages.<lang>` in `_config.yml`: data path, URL, name, title, address, avatar alt text, and the header intro toggle.

Because nothing else distinguishes one language from another, a language the theme does not ship is added by the site alone, with no Ruby, HTML, or SCSS changes. The shipped locales are listed in the [locale keys reference](../reference/locale-keys.md#shipped-locales). Pages only set `layout: resume` and `lang: <code>`; the layout reads direction and UI copy from the active locale and never branches on a specific language code.

## One date formatter for every language

Dates in the data are written as ISO values and month names come from the locale file, so the data stays language-neutral. [`_includes/date-formatter.html`](../../_includes/date-formatter.html) localizes month names and "Present" for every language. It splits the ISO value itself rather than using Liquid's `date` filter, which reads a bare `2018` as a Unix timestamp. This include is the single date hook for every language: calendar extensions (for example Hijri dates) belong here rather than in a language-specific include. The accepted "present" words are described in the [locale keys reference](../reference/locale-keys.md#present-values).

---

## Overriding Theme Locales

The six locale files ship inside the theme gem, so consuming sites get them with no setup. Jekyll reads theme data first and then deep-merges the site's `_data/` over it; the site wins. This layering is what lets a site change one heading with a one-key file, or replace a whole locale, without forking the theme or waiting for a gem release.

The validator mirrors the same layering: it builds each language's effective locale from the theme file with the site file deep-merged over it, and checks key parity on that merged result. Checking the merged result rather than the site file alone is why a one-line site override warns on nothing, while a site-only locale for a language the theme does not ship must be complete. The merge rules (including how arrays behave) are in the [locale keys reference](../reference/locale-keys.md#overriding-theme-locales).

---

## Typography & RTL

- **Fonts and line height come only from the locale file.** The layout emits them as CSS variables and the stylesheet reads them with the theme's default stacks as fallbacks, so changing a language's font is a locale override, not an SCSS edit. The shipped line heights follow the script: Arabic uses Cairo at `1.6` (room for diacritics); Urdu uses Noto Nastaliq Urdu at `2.0` (Nastaliq glyphs are tall); the LTR locales use the default stacks at `1.5`. The variable names are in the [Sass tokens reference](../reference/sass-tokens.md).
- **Direction selects the stylesheet.** The layout links `cv-<direction>.css`, where `direction` comes from the locale file, and sets `<html dir>` from the same value.
- **RTL is language-neutral.** Every RTL locale compiles through `assets/css/cv-rtl.scss`, which loads `_sass/_resume-ltr.scss`, then `_sass/_resume-rtl.scss`, then `_sass/_print.scss`. The RTL partial only mirrors positioning (floats, margins, timeline bullets, contact icons; floated elements such as the avatar, social bar, and job title flip alignment) under `html[dir="rtl"]` and resets `letter-spacing` so cursive scripts keep their ligatures. It sets no fonts, so Arabic, Urdu, and any future RTL language each keep their own typeface.
- **Bidi isolation.** In RTL locales, templates wrap phone numbers, email addresses, URLs, and credential IDs in `dir="ltr"` so Latin punctuation is not reordered.

---

Upgrading from the v0.9.0 per-language layouts (`resume-en`, `resume-ar`) to this model: see [migrate from v0.9 to v1.0](../how-to/migrate-v0.9-to-v1.0.md).
