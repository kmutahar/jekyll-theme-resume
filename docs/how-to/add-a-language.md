# Add a language

*Audience: site owners*

Add a new language (Italian, `it`, in this example) to your site, and optionally hand-author its page. The theme has no `it.yml`, so the site supplies a complete locale file.

## Steps

1. **Create the locale file.** Copy the theme's [`_data/locales/en.yml`](../../_data/locales/en.yml) (find the installed theme with `bundle info --path jekyll-theme-resume`; the shipped locales are listed in [Locale keys](../reference/locale-keys.md#shipped-locales)) to your site as `_data/locales/it.yml`, keep every key, and translate the values. Set `direction`, `font_family`, `font_url`, and `line_height` for the script (see [multilingual and RTL design](../explanation/multilingual-and-rtl-design.md)). Replace `months` with the 12 Italian month names and `present_values` with the words your data uses for ongoing roles (for example `["present", "presente", "attuale"]`). Keep `present` in `present_values`: Experience and Volunteering fall back to the English word "Present" for a blank `enddate`, and the formatter translates it only when `present_values` contains it.
2. **Create the data folder.** Copy an existing language folder (for example `_data/en/`) to `_data/it/` and translate every file. Keep the same file names and the same entries in the same order; the validator reports files that exist in one language and not the other.
3. **Register the language** in `_config.yml`:
   ```yaml
   languages:
     it:
       data_path: it             # folder under _data/; dot paths like "2025-06.it" also work
       url: /it/cv/              # used by error pages, hreflang, and the language switcher
       header_intro: true        # render _data/it/header.yml intro under the header
       name: "Nome Cognome"
       resume_title: "Titolo professionale"
       address: "Città, Paese"
       avatar_alt: "Foto di Nome Cognome"
   ```
4. **Page (optional).** With `resume_auto_generate_pages` at its default `true`, the theme auto-generates the CV page at `languages.it.url` and a profile page at `/it/` for you, both carrying `t_id: resume` / `t_id: profile`. Create your own `it/cv.md` (`layout: resume`, `lang: it`, `permalink` matching `languages.it.url`) only if you want to hand-author it instead - a hand-authored page always takes precedence. See `resume_auto_generate_pages` / `languages.<lang>.auto_generate_pages` in the [config reference](../reference/config.md).
5. **Validate and build:**
   ```bash
   bundle exec validate-resume _data
   bundle exec jekyll build
   ```
   Done when the validator reports no errors for `it` and `_site/it/cv/index.html` renders with Italian section titles and month names.

The error pages and the language switcher pick up the new language automatically because they loop over `site.languages`. hreflang tags pick it up when the new page shares a `t_id` with its translations: see [Link translations with hreflang](link-translations-with-hreflang.md).

## Hand-author a page

To override a generated page, or disable generation with `resume_auto_generate_pages: false`, create a page with matching `layout` and `lang`:

```markdown
---
layout: resume
lang: it
permalink: /it/cv/
t_id: resume        # optional: links translations for hreflang and the language switcher
---
```

How the layout resolves a page's language is described in [Language Resolution](../reference/layouts.md#language-resolution).

## Content conventions

- Translate every data file natively; copying English into another language's folder produces a resume that looks localized in the headings and English in the body.
- Keep proper nouns consistent: transliterate them in non-Latin scripts and keep them as-is in Latin-script languages.
- Write dates as ISO (`YYYY-MM-DD`, `YYYY-MM`, or `YYYY`). Month names come from the locale file, so the data stays language-neutral.
- For ongoing roles, leave `enddate` blank or use any value from that locale's `present_values`.

## Troubleshoot: a page renders with no name or content

The page's `lang` has no entry under `languages:`, or that entry's `data_path` points at a folder that does not exist. Run `bundle exec validate-resume _data`.
