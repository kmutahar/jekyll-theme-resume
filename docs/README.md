# Documentation

This documentation is organized by what you need right now: learn the theme, do a task, look something up, or understand why it works the way it does. Each page states its audience under the title.

**Start here**

- New to the theme? Follow the [tutorial](tutorials/getting-started.md) to get a two-language resume running.
- Something broke? See [Troubleshoot builds](how-to/troubleshoot-builds.md).
- Not sure what a term means? See the [Glossary](reference/glossary.md).

## Tutorial

| Page | Audience | You will |
|---|---|---|
| [Getting Started](tutorials/getting-started.md) | Site owners | Build and run an English and Arabic resume site from an empty folder. |

## How-to guides

Steps for one task each.

| Page | Audience | Use it to |
|---|---|---|
| [Add a language](how-to/add-a-language.md) | Site owners | Add a new language with its locale file, data folder, and pages. |
| [Add a custom section](how-to/add-a-section.md) | Site owners and theme developers | Add a resume section that renders in every language. |
| [Add a social platform](how-to/add-a-social-platform.md) | Theme developers | Add a social network icon and label. |
| [Add a test](how-to/add-a-test.md) | Theme developers | Run the test suites and add a test for a change. |
| [Create a custom layout](how-to/create-a-custom-layout.md) | Theme developers | Add a page design that still renders in every language. |
| [Enable dark mode](how-to/enable-dark-mode.md) | Site owners and theme developers | Show the dark mode toggle site-wide or on one page. |
| [Link translations with hreflang](how-to/link-translations-with-hreflang.md) | Site owners | Connect the translations of a page for the language switcher and `hreflang` tags. |
| [Migrate from v0.9 to v1.0](how-to/migrate-v0.9-to-v1.0.md) | Site owners | Upgrade a v0.9.0 site. |
| [Override locale strings](how-to/override-locale-strings.md) | Site owners | Change UI text, fonts, error-page copy, or accepted "present" words. |
| [Override Sass partials](how-to/override-sass-partials.md) | Site owners | Change theme styles, including the accent color, without forking the gem. |
| [Proof the built HTML and lint the Ruby](how-to/proof-built-html.md) | Theme developers | Check a built site for dead links and missing assets, and run RuboCop. |
| [Publish the JSON Resume export](how-to/publish-json-resume.md) | Site owners | Serve the generated `resume.json` files. |
| [Show language proficiency in the header](how-to/show-language-proficiency-in-header.md) | Site owners | Show a one-line language summary in the resume header. |
| [Switch resume versions](how-to/switch-resume-versions.md) | Site owners | Load a different set of resume data for a language. |
| [Troubleshoot builds](how-to/troubleshoot-builds.md) | Site owners and theme developers | Diagnose a build problem from the symptom. |
| [Validate resume data in CI](how-to/validate-in-ci.md) | Site owners and theme developers | Gate builds on validation and run the checks in GitHub Actions. |
| [Verify accessibility](how-to/verify-accessibility.md) | Site owners and theme developers | Run the automated and manual accessibility checks. |

## Reference

Facts to look up: keys, schemas, flags, and structure.

| Page | Audience | Contains |
|---|---|---|
| [Configuration reference](reference/config.md) | Site owners | Every `_config.yml` setting. |
| [Data schemas](reference/data-schemas.md) | Site owners | The YAML schema of every resume data file. |
| [Locale keys](reference/locale-keys.md) | Site owners and theme developers | The locale file schema, shipped locales, and override rules. |
| [JSON Resume export reference](reference/json-resume-fields.md) | Site owners | Export configuration, privacy, and field mappings. |
| [Validator and build checks](reference/validator-cli.md) | Site owners and theme developers | `validate-resume`, `check-data-keys`, rules by section, and the Ruby API. |
| [Accessibility coverage](reference/accessibility-coverage.md) | Site owners and theme developers | What the theme implements and what the automated checks cover. |
| [Layouts reference](reference/layouts.md) | Site owners and theme developers | The layouts, language resolution, and data loading. |
| [Includes reference](reference/includes.md) | Theme developers | Every include and its parameters. |
| [Sass reference](reference/sass-tokens.md) | Theme developers | The stylesheet architecture, partials, and dark mode tokens. |
| [Testing suites](reference/testing-suites.md) | Theme developers | What each test suite proves. |
| [Repository map](reference/repository-map.md) | Theme developers | The annotated code tree. |
| [Glossary](reference/glossary.md) | Site owners and theme developers | Definitions of terms used across the docs. |

## Explanation

Why the theme is designed the way it is.

| Page | Audience |
|---|---|
| [Architecture](explanation/architecture.md) | Theme developers |
| [Multilingual and RTL design](explanation/multilingual-and-rtl-design.md) | Site owners and theme developers |
| [The data-driven model](explanation/data-driven-model.md) | Site owners and theme developers |
| [Dark mode approach](explanation/dark-mode-approach.md) | Site owners and theme developers |
| [Accessibility decisions](explanation/accessibility-decisions.md) | Site owners and theme developers |

## Working on the theme: where things live and how to check a change

These commands assume a checkout of the theme repository.

| Need / Task | Go to | Check your change |
|---|---|---|
| Configure site settings, languages, avatar, or analytics | `_config.yml`, [Configuration reference](reference/config.md) | Run the demo build; see [Getting Started](tutorials/getting-started.md) |
| Add a language or change UI strings, fonts, or month names | `_data/locales/<lang>.yml`, [Add a language](how-to/add-a-language.md), [Override locale strings](how-to/override-locale-strings.md), [Locale keys](reference/locale-keys.md) | `./bin/validate-resume demo/_data`, then inspect `_site/<lang>/cv/` |
| Modify resume section data | `_data/<lang>/*.yml`, [Data schemas](reference/data-schemas.md) | `./bin/validate-resume demo/_data` |
| Customize error pages or return URLs | `_layouts/error.html`, `_plugins/error_pages_generator.rb`, `error_pages` in the locale files, [Layouts reference](reference/layouts.md), [Locale keys](reference/locale-keys.md) | Inspect `_site/404.html`, `_site/500.html` |
| Adjust dark mode colors or tokens | `_sass/_dark-mode.scss`, [Sass reference](reference/sass-tokens.md), [Dark mode approach](explanation/dark-mode-approach.md) | Inspect CSS variables on `:root` and `[data-theme="dark"]` |
| Adjust RTL mirroring | `_sass/_resume-rtl.scss`, [Sass reference](reference/sass-tokens.md) | Inspect `_site/ar/cv/` and `_site/ur/cv/` |

## Project files

- [Changelog](../CHANGELOG.md): release notes.
- [`_config.sample.yml`](../_config.sample.yml): the annotated sample configuration for a consuming site.
- [Contribution and agent rules](https://github.com/kmutahar/jekyll-theme-resume/blob/master/AGENTS.md) (`AGENTS.md`, not shipped in the gem).
