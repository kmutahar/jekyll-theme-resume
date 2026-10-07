# Locale Keys

*Audience: site owners and theme developers*

Reference for the locale file schema (`_data/locales/<lang>.yml`), the shipped locales, and the rules that govern overriding them.

## Shipped locales

The theme ships six locales: English (`en`, LTR), Arabic (`ar`, RTL), Spanish (`es`, LTR), French (`fr`, LTR), German (`de`, LTR), and Urdu (`ur`, RTL). Any other language is added by the site alone, with no Ruby, HTML, or SCSS changes.

Shipped fonts and line heights:

| Locale | `direction` | `font_family` | `line_height` |
|---|---|---|---|
| `en`, `es`, `fr`, `de` | `ltr` | empty (theme default stacks) | 1.5 |
| `ar` | `rtl` | `'Cairo', sans-serif` | 1.6 |
| `ur` | `rtl` | `'Noto Nastaliq Urdu', serif` | 2.0 |

## Locale file keys

Every locale file has the same key set. The validator warns when a language's effective locale is missing a key that the reference locale (`en` by default) has.

| Key | Purpose |
|---|---|
| `direction` | `ltr` or `rtl`. Sets `<html dir>` and selects `assets/css/cv-ltr.css` or `cv-rtl.css`. |
| `font_family` | CSS font stack emitted as `--font-locale`. Empty string keeps the theme's default stacks (Lora and Open Sans). |
| `font_url` | Stylesheet URL for the font (usually Google Fonts). Empty string loads the default Lora and Open Sans stylesheet. |
| `line_height` | Emitted as `--line-height-locale` for resume body text. |
| `ui.*` | Every UI string the templates render: skip link, "Present", contact button, download-PDF button, dark mode toggle label, language switcher label, `language_name` (the language's own name, shown in the switcher and on error page return links), `list_separator`, and more. |
| `ui.section_titles.*` | One heading per resume section (`experience`, `education`, ... `links`, `publications`, `references`). |
| `ui.social_labels.*` | Platform names: the accessible name (`aria-label`, `title`, screen-reader text) of each social icon and the labels of the print-only contact list. |
| `error_pages."404"` / `"403"` / `"500"` / `"503"` | `title` and `message` for each HTTP error page. |
| `present_values` | Case-insensitive words that mean "ongoing" in `enddate` fields. A match renders `ui.present` instead of a date. |
| `months` | The 12 month names, January first. Dates render as `<month> <year>`; a year-only date renders as the year. |

Read the shipped files in [`../../_data/locales/`](../../_data/locales/) for the full key list and current values.

## `error_pages`

Error page text is not in the data folders. Each locale file carries an `error_pages` map, and [`../../_layouts/error.html`](../../_layouts/error.html) server-renders one block in `default_lang`. JavaScript can replace that block using a configured language prefix at the start of the requested URL:

```yaml
# _data/locales/en.yml (excerpt)
error_pages:
  "404":
    title: "Page Not Found"
    message: "The page you are looking for might have been removed, had its name changed, or is temporarily unavailable."
  "403": { title: "...", message: "..." }
  "500": { title: "...", message: "..." }
  "503": { title: "...", message: "..." }
```

## "Present" values

An `enddate` may be a word meaning "ongoing" instead of a date. For a given language the accepted words are that language's effective locale `present_values` plus its `ui.present` label, compared case-insensitively. A language with no locale falls back to the `default_lang` locale. The shipped values:

| Language | `present_values` | `ui.present` |
|---|---|---|
| `en` | `present`, `current` | `Present` |
| `ar` | `present`, `حتى الآن`, `حاليًا` | `حتى الآن` |

Read the other four in [`_data/locales/`](../../_data/locales). To accept more words, see [Override locale strings](../how-to/override-locale-strings.md#accept-more-present-words).

The template side ([`_includes/date-formatter.html`](../../_includes/date-formatter.html)) matches `present_values`. If you change `ui.present`, include that label in `present_values` too: the validator accepts the label automatically, but the formatter checks only the list.

## Overriding theme locales

The six locale files ship inside the theme gem. Jekyll reads theme data first and then deep-merges the site's `_data/` over it; the site wins.

- **Nested keys merge one by one.** A site file `_data/locales/<lang>.yml` containing only some keys changes those keys and leaves every other string intact.
- **Arrays are replaced whole, never merged.** Overriding `months` or `present_values` requires the complete list; a one-item `months` array leaves the other eleven months blank.
- **A new language has no theme file to merge with,** so its `_data/locales/<lang>.yml` must contain every key.

The validator builds each locale the same way (theme file, then site file deep-merged over it) and checks key parity on the merged result. A one-line override produces no warnings; an incomplete site-only locale does.

Task steps: [override locale strings](../how-to/override-locale-strings.md), [add a language](../how-to/add-a-language.md). Design background: [multilingual and RTL design](../explanation/multilingual-and-rtl-design.md).
