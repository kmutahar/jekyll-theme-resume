# jekyll-theme-resume

[![CI Test Suite](https://github.com/kmutahar/jekyll-theme-resume/actions/workflows/ci.yml/badge.svg)](https://github.com/kmutahar/jekyll-theme-resume/actions/workflows/ci.yml) [![Latest release](https://img.shields.io/github/v/release/kmutahar/jekyll-theme-resume?display_name=tag)](https://github.com/kmutahar/jekyll-theme-resume/releases) [![Gem Version](https://badge.fury.io/rb/jekyll-theme-resume.svg?icon=si%3Arubygems)](https://badge.fury.io/rb/jekyll-theme-resume)

A flexible Jekyll theme for clean, data-driven, multilingual resume/CV websites. Ships English, Arabic, Spanish, French, German, and Urdu; any other language is added from your site alone. Created and maintained by Khaldoon Mutahar. See the latest version on the [Releases page](https://github.com/kmutahar/jekyll-theme-resume/releases).

**Links:** [RubyGems](https://rubygems.org/gems/jekyll-theme-resume) · [Live demo](https://www.mutahr.me/jekyll-theme-resume) · [Source](https://github.com/kmutahar/jekyll-theme-resume)
Inspired by and originally forked from [Joel Glovier’s resume template](https://github.com/jglovier/resume-template/). Joel’s version was a basic English-only theme with limited customization (e.g., no section reordering); this project has since evolved into a fully separate theme authored by Khaldoon.

## Features

- **Multilingual support**: One layout (`resume.html`) renders every language, LTR or RTL, from per-language locale files (`_data/locales/<lang>.yml`) with localized UI strings, month names, and fonts (Cairo for Arabic, Noto Nastaliq Urdu for Urdu)
- **Dark mode**: System preference detection (`prefers-color-scheme`) with optional interactive toggle, `localStorage` persistence, and zero-FOUC inline script
- **Data-driven architecture**: All resume content stored in YAML files, supporting multiple data paths and versioning
- **Resume sections**: Experience, Education, Certifications, Courses, Volunteering, Projects, Skills, Recognition, Associations, Languages, Links, Interests, Publications, References
- **Accessibility features**: Semantic landmarks, keyboard navigation, localized skip links, and labelled social controls. See the [Accessibility coverage](docs/reference/accessibility-coverage.md) for coverage and known limitations.
- **Modern favicon suite**: High-resolution favicons (Apple touch icon, 32x32, 16x16, webmanifest) with subpath-safe URLs and `_config.yml` override support
- **Print-friendly**: Optimized for PDF generation and printing with bidirectional text isolation (`dir="ltr"`) for URLs
- **SEO ready**: Built-in support for multilingual SEO, standardized canonical tags via `jekyll-seo-tag`, sitemaps, and feeds
- **JSON-LD structured data**: Each CV page carries a Schema.org `ProfilePage` + `Person` block built from the same data as the JSON Resume export (on by default; opt out with `json_ld.enabled: false`). It does not guarantee ATS parsing or rich results.
- **JSON Resume Export**: Multilingual builds generate standards-validated JSON Resume files at `/<lang>/resume.json` (on by default; opt out with `json_resume.enabled: false`).
- **Automatic pages**: Missing CV and profile pages are generated for each configured language; hand-authored pages take precedence.
- **Data validation**: `validate-resume` CLI and build-time checks for schemas, dates, URLs, and parity across every configured language

## Quick Start

### Installation

1. Add to your Jekyll site's `Gemfile`, inside `group :jekyll_plugins`. The `:jekyll_plugins` group loads the theme’s bundled generators and validator. Alternatively, explicitly list `jekyll-theme-resume` under `plugins:` in `_config.yml` (as the sample does); a plain Gemfile entry plus `theme:` alone is insufficient:
```ruby
group :jekyll_plugins do
  gem "jekyll-theme-resume"
end
```

2. Add to your `_config.yml`:
```yaml
theme: jekyll-theme-resume
```

3. Install dependencies:
```bash
bundle install
```

> **Upgrading from v0.9.0?** v1.0.0 removes the `resume-en` / `resume-ar` layouts and every `*_en` / `*_ar` config key with no compatibility aliases. Follow the migration table in the [migration guide](docs/how-to/migrate-v0.9-to-v1.0.md).

### Next steps

Follow [Getting Started](docs/tutorials/getting-started.md) for a complete walkthrough from an empty folder to a running two-language resume. The theme generates the CV and profile page for every language you configure (see [the languages table](docs/reference/config.md#3-languages)), and the sample data for six languages lives in `demo/_data/`.

## Documentation

The documentation is organized by what you need. Start at the [documentation index](docs/README.md).

| I want to... | Go to |
|---|---|
| Build my first resume site | [Getting Started](docs/tutorials/getting-started.md) (tutorial) |
| Do one task: add a language, override strings, publish JSON, validate in CI | [How-to guides](docs/README.md#how-to-guides) |
| Look up a setting, schema, or flag | [Reference](docs/README.md#reference) |
| Understand why the theme works this way | [Explanation](docs/README.md#explanation) |
| Contribute or follow the project rules | [AGENTS.md](AGENTS.md) · [Changelog](CHANGELOG.md) |

Most-used reference pages: [Configuration reference](docs/reference/config.md) (**start here** for `_config.yml`), [Data schemas](docs/reference/data-schemas.md), [Locale keys](docs/reference/locale-keys.md), [Validator and build checks](docs/reference/validator-cli.md), [JSON Resume export reference](docs/reference/json-resume-fields.md), and [Accessibility coverage](docs/reference/accessibility-coverage.md).

## Project Structure

```text
jekyll-theme-resume/
├── _layouts/          # HTML templates (default, resume, profile, error)
├── _includes/         # Reusable components (section dispatcher, date formatter, avatar, toggles)
├── _sass/             # SCSS (LTR main styles, RTL overrides, dark mode tokens, print styles)
├── _plugins/          # Error page generator and build-time resume validator
├── _data/locales/     # Locale dictionaries: en, ar, es, fr, de, ur
├── lib/               # Gem entrypoint and validator engine
├── bin/               # validate-resume CLI
├── assets/            # CSS entrypoints (cv-ltr, cv-rtl), images, favicons
├── _config.sample.yml # Annotated configuration for consuming sites
├── demo/              # Separate demo-site submodule, including six-language data
└── docs/              # Documentation: tutorial, how-to guides, reference, explanation
```

## Key Concepts

### Data Paths

Each language reads its data from the folder named by `languages.<lang>.data_path`:
```yaml
languages:
  en:
    data_path: en   # _data/en/*
  ar:
    data_path: ar   # _data/ar/*
```

Use one folder per language even for a single-language site; adding a language later is then one more folder. Dot paths (`"2025-06.v1"`) select nested, versioned datasets, and `""` reads `_data/` itself.

See the [Configuration reference](docs/reference/config.md#3-languages) for every per-language key.

### Sample Files

`demo/_data/{en,ar,es,fr,de,ur}/` hold a complete Sherlock Holmes demo resume in six languages, covering all section types. Copy the folders you need to your site.

### Locales

Month names, "Present" labels, section titles, fonts, and text direction come from `_data/locales/<lang>.yml`, shipped inside the gem for all six languages. Override single strings or add a new language from your site's own `_data/locales/`; see [Override locale strings](docs/how-to/override-locale-strings.md) and [Add a language](docs/how-to/add-a-language.md).

## Development

To develop this theme locally:

```bash
# Initialize the demo submodule, then install dependencies
git submodule update --init --recursive
bundle install

# Serve the six-language demo from the demo submodule
bundle exec jekyll serve --source demo --destination _site
# (Or with live reload and incremental builds)
bundle exec jekyll serve --source demo --destination _site --livereload --incremental

# Build static output
bundle exec jekyll build --source demo --destination _site

# Clean cached Jekyll build artifacts
bundle exec jekyll clean

# Validate resume data schemas and parity (CLI or Rake)
./bin/validate-resume demo/_data
bundle exec rake validate

# Check that the theme's own templates only reference real data keys (CLI or Rake)
./bin/check-data-keys demo/_data
bundle exec rake check_data_keys

# Data validator, template key checker, RuboCop, and every test suite
bundle exec rake

# Verify built HTML (separate from the default Rake task)
bundle exec rake "proof[_site,demo/_config.yml]"

# Build the gem
gem build jekyll-theme-resume.gemspec

# List packaged files (must include locales and bin, exclude tests)
gem spec jekyll-theme-resume-*.gem files
rm -f jekyll-theme-resume-*.gem

# Dependency Audit
bundle outdated
bundle update

# Automated Version Release (updates gemspec, changelog, commits, and tags)
./bin/release <version>
./bin/release --bump
```

For more details on resume schema checks, see [Validator and build checks](docs/reference/validator-cli.md). Contributor and agent rules are in [AGENTS.md](AGENTS.md).

## Requirements

- Ruby 3.3+; this repository’s CI matrix tests 3.3, 3.4, and 4.0.
- Jekyll `~> 4.4` (4.4 or later, below 5.0), as specified in the gemspec.
- Runtime plugin dependencies (Jekyll loads them automatically when `theme:` is set; the sample config also lists them under `plugins:` to make them explicit):
  - `jekyll-feed`
  - `jekyll-seo-tag`
  - `jekyll-sitemap`
  - `jekyll-redirect-from`

## Contributing

Bug reports and pull requests are welcome on GitHub. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](https://www.contributor-covenant.org/) code of conduct.

## License

The theme is available as open source under the terms of the [MIT License](LICENSE.txt).

## Support

- 📖 Check the [Documentation](#documentation) for detailed information
- 🐛 Report issues on [GitHub Issues](https://github.com/kmutahar/jekyll-theme-resume/issues)

---

**Created by Khaldoon Mutahar** | MIT License
