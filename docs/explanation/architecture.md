# Architecture

*Audience: theme developers*

This page explains how the theme fits together: the layouts and generators, how the pieces are wired, the two verification engines, and the Liquid pitfalls that shape the templates. For the annotated file tree see [repository map](../reference/repository-map.md); to build the demo site, see [getting started](../tutorials/getting-started.md).

**jekyll-theme-resume** is a Ruby gem / Jekyll theme for data-driven, multilingual resume and CV sites. One locale-agnostic layout renders every language, left-to-right or right-to-left, from YAML data and per-language locale files. The theme ships six locales: English, Arabic, Spanish, French, German, and Urdu.

---

## Components

### Layouts and generators
The four layouts (`default.html`, `profile.html`, `resume.html`, `error.html`) are described in the [layouts reference](../reference/layouts.md#layout-inventory).

- `_plugins/error_pages_generator.rb` adds missing `404`, `403`, and `500` pages to consuming sites. A manual error page can use `code: 503`.
- `_plugins/resume_pages_generator.rb` creates missing CV pages at each `languages.<lang>.url` and profiles at `/` or `/<lang>/`. Manual pages take precedence; see [page configuration](../reference/config.md#3-languages).

### Two verification engines

The repository has two verification engines, and only the resume-data validator ships in the gem: it checks resume YAML data, including during every consuming site's build. The template key checker checks the theme's own templates and runs only in this repository's development workflow and CI, never on a consuming site's build. The entry points and what each one checks are in the [validator reference](../reference/validator-cli.md).

`check-data-keys` catches a different class of bug than the resume validator: not bad *data*, but a Liquid template in `_layouts` or `_includes` referencing a field that doesn't exist anywhere in the checked sample data (e.g. `item.discription` instead of `item.description`), which renders silently blank rather than raising an error. It traces `resume_data.<section>` bindings through `for`/`assign`/include-parameter chains, including the `grouped-item-list.html` include boundary and the `group_by` filter's synthetic `{name, items}` wrapper, since the theme's templates never write literal `site.data.foo.bar`.

Because "known keys" are derived from whatever the checked sample data actually contains, a field a template correctly references but that no language in the checked data happens to exercise (an optional field, e.g. `education.yml`'s `awards` list) will warn even though nothing is wrong. For this reason `check-data-keys` never defaults to `--fail-on-warnings` in this repository's Rake task or CI steps, unlike `validate-resume`. Warnings are printed and worth reading, but a warning alone does not mean the template is broken; cross-check against the field before "fixing" it.

### Accessibility
- `.sr-only` utilities, visible `:focus-visible` outlines, landmarks, and localized skip links. Coverage and known contrast limitations are documented in [accessibility coverage](../reference/accessibility-coverage.md).

### Liquid pitfalls

Three Liquid behaviors shape how the templates are written, and the tests guard each of them.

- **Presence checks never use `blank`.** Liquid's `blank` literal calls Ruby's `blank?`, which plain Jekyll strings and `nil` do not define, so `x != blank` is always true and would render empty sections. The templates use `x.size > 0` for text and a plain truthiness test `x` for dates.
- **Dates are never passed to the `date` filter.** The filter reads a bare year such as `2018` as a Unix timestamp. `date-formatter.html` therefore parses the ISO parts itself.
- **Includes share the caller's variables.** An include has no scope of its own, so an unprefixed loop variable would overwrite `lang`, `locale`, or `lang_cfg` in `resume.html`. Loop and helper variables inside includes carry a prefix (`switch_` in `language-switcher.html`, `social_` in the social includes).

### Why `@use` instead of `@import`

The theme uses modern Dart Sass `@use` exclusively, instead of the deprecated `@import`. Namespacing keeps variables and mixins encapsulated (for example `variables.$white`, `@include mixins.clearfix`), which prevents global pollution. Modules load only what they explicitly require.

### Tests use public interfaces only

Every test goes through a public interface: the HTML a visitor receives, a Ruby class's public methods, a CLI's exit code and output, or the gem's file list. No test calls a private method. Suites are listed in [testing suites](../reference/testing-suites.md).
