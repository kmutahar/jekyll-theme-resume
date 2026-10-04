# Migrate from v0.9 to v1.0

*Audience: site owners*

Upgrade a site built on v0.9.0 to v1.0.0. v1.0.0 is a hard break: no aliases, shims, or fallback keys remain for the names below. Replace each one in your site.

## 1. Replace removed names

| Removed (v0.9.0) | Replacement (v1.0.0) |
|---|---|
| `layout: resume-en` / `layout: resume-ar` | `layout: resume` + `lang: <code>` |
| `_includes/resume-section-en.html` / `-ar.html` | `_includes/resume-section.html` |
| `_includes/resume-head-en.html` / `-ar.html` | Head logic inside `_layouts/resume.html` |
| `_includes/ar-date.html` | `_includes/date-formatter.html` |
| `_data/ar/months.yml` | `months:` in `_data/locales/ar.yml` |
| `_data/error_pages.yml` | `error_pages:` in each `_data/locales/<lang>.yml` |
| `assets/css/cv.css` / `cv-ar.css` | `assets/css/cv-ltr.css` / `cv-rtl.css` |
| `active_resume_path_en` / `_ar` | `languages.<lang>.data_path` |
| `resume_en_url` / `resume_ar_url` | `languages.<lang>.url` |
| `resume_header_intro_en` / `_ar` | `languages.<lang>.header_intro` |
| `name` / `name_ar` | `languages.<lang>.name` |
| `resume_title` / `resume_title_ar` | `languages.<lang>.resume_title` |
| `contact_info.address` / `address_ar` | `languages.<lang>.address` |
| `avatar_alt_en` / `avatar_alt_ar` / `avatar_alt` | `languages.<lang>.avatar_alt` |
| `site.avatar` | `site.avatar_url` |
| `analytics.ga` | `analytics.gtag` or `analytics.gtm` |
| `resume_section.recognition` (singular) | `resume_section.recognitions` |
| `required_ruby_version >= 3.0.0` | `>= 3.3.0` |
| A plain `gem "jekyll-theme-resume"` line (no longer enough on its own) | Put the line inside `group :jekyll_plugins do ... end`, or list the theme under `plugins:` in `_config.yml`, to load its generators and validator |

## 2. Apply the additional removals

- `languages.<lang>.name` is a plain string (`"Jane Doe"`), not the old `first` / `middle` / `last` hash.
- The site-level `lang` and `dir` keys no longer affect any layout; direction comes from the locale file and language from `page.lang` or `default_lang`.
- `font_ar_url` is gone. Override `font_url` in your site's `_data/locales/ar.yml` instead.
- Error page front matter overrides (`title_en`, `desc_en`, `title_ar`, `desc_ar`) are gone. Override `error_pages` in a site locale file instead.
- Build-time validation is now on by default. Set `validate_resume: false` to opt out (see [validator CLI reference](../reference/validator-cli.md)).

## 3. Validate and build

Run `bundle exec validate-resume _data` and `bundle exec jekyll build`.

Watch for two silent failures:

- A leftover `layout: resume-en` page only logs a Jekyll "layout does not exist" warning and renders unstyled.
- A page whose `lang` has no `languages:` entry renders without a name, title, or resume data.
