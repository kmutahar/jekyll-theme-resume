# Testing suites

*Audience: theme developers*

How the theme is tested, what each suite proves. Validator rules themselves are in [validator-cli.md](validator-cli.md); agent verification rules are in [AGENTS.md](../../AGENTS.md#rule-5-build--packaging-verification).

## Test tasks

To run the suites or add a test, see [Add a test](../how-to/add-a-test.md).

The `test` task runs every `test/test_*.rb` file, so a new suite needs no Rakefile edit. Two error-page tests run the page's real JavaScript in Node and are skipped when `node` is not installed.

`bundle exec rake` (the default task) runs `validate`, `check_data_keys`, `rubocop`, and `test`. The default task runs `validate` with its default data directory (`_data` if `_data/en` exists, else `demo/_data`); pass another one with `rake "validate[path/to/_data]"`. There is no config-path argument; see [validator-cli.md](validator-cli.md#4-rake-task-rake-validate). HTML proofing runs separately after a build.

## What each suite covers

Every test goes through a public interface; see [Tests use public interfaces only](../explanation/architecture.md#tests-use-public-interfaces-only).

| Suite | Interface under test | Covers |
|---|---|---|
| [`test_rendered_site.rb`](../../test/test_rendered_site.rb) | Generated HTML of a fixture site built from the theme's real `_layouts`, `_includes`, `_sass`, `_data`, `assets` | Each of the sections (fields, separators, inactive entries, grouping, RTL `dir="ltr"` isolation); date formats; header, contact bar, avatar, microdata (including the contact visibility gate and `itemid`); the JSON-LD block (`json_ld.enabled`, `<` escaping, privacy); social and print links; hreflang; profile, default and error layouts (including the URL-language script and `baseurl`); config switches such as `enable_live`, `lang_header`, `baseurl`, analytics, dark mode |
| [`test_language_switcher.rb`](../../test/test_language_switcher.rb) | Generated HTML, six languages | Switcher links, labels, direction, page/site opt-out, error layout |
| [`test_resume_validator.rb`](../../test/test_resume_validator.rb) | `ResumeValidator#validate`, `bin/validate-resume`, build plugin | Every schema rule per section, dates, "Present" values, URLs, alias keys, locale merge and parity, config resolution, strict mode, CLI flags |
| [`test_template_key_checker.rb`](../../test/test_template_key_checker.rb) | `TemplateKeyChecker#check`, `bin/check-data-keys` | Liquid binding resolution, include boundaries, advisory exit codes |
| [`test_error_pages_generator.rb`](../../test/test_error_pages_generator.rb) | Site build | Generated 404/403/500 pages, site overrides, generator registration |
| [`test_resume_pages_generator.rb`](../../test/test_resume_pages_generator.rb) | Site build | Generated CV/profile pages, collisions, per-language and global toggles |
| [`test_json_resume_exporter.rb`](../../test/test_json_resume_exporter.rb) | `JsonResumeExporter.export`, site build | JSON Resume mapping, privacy, visibility, schema validation, routes; the generator's `site.json_ld_pages` output and its independence from `json_resume.*`; see [json-resume-fields.md](json-resume-fields.md) |
| [`test_json_ld_builder.rb`](../../test/test_json_ld_builder.rb) | `JsonLdBuilder.build` and `.script` | Mapping to ProfilePage + Person, dropping empty values, current-role and dedupe rules, `<` escaping; see [json-ld-fields.md](json-ld-fields.md) |
| [`test_packaging.rb`](../../test/test_packaging.rb) | Gemspec, shipped `_data` | Gem file list, six-locale key parity, unused locale keys, social icons and labels, demo data parity |
| [`test_doc_links.rb`](../../test/test_doc_links.rb) | The tracked Markdown files | Every relative link and `#anchor` in the docs resolves; links in code blocks and external URLs are skipped |
| [`ats_check.rb`](../../test/ats_check.rb) | Generated PDFs of a built site (not part of `rake test`; run by the PDF workflow) | Every visible text node outside `.no-print` appears in `pdftotext` output in order; Arabic and Urdu compared with `ats_baseline.yml`; see [Generate PDFs in CI](../how-to/generate-pdf-in-ci.md) |

## The rendered-site fixture

`RenderedSiteTest` writes fixture data for `en` (LTR) and `ar` (RTL) into a temporary site. Each section has an entry for every rendering rule, an entry with optional fields missing, and an `active: false` entry whose text starts with `hidden-`. Entries are tagged `EN`/`AR` so a test can tell which language's data rendered.

Config variants reuse the same fixture. Pass overrides and the site is built once per distinct override set:

```ruby
cv("en", "enable_live" => true)          # _site/en/cv/ built with enable_live on
html("404.html", "baseurl" => "/cv")     # any output path
section("Experience")                    # the <section> whose heading matches, default config
```

## Continuous integration

This repository runs the validator and the template key checker in two workflows:

- [`.github/workflows/lint.yml`](../../.github/workflows/lint.yml): `./bin/validate-resume demo/_data --fail-on-warnings`, `rake validate[demo/_data]`, `./bin/check-data-keys demo/_data`, `rake check_data_keys[demo/_data]`, a gemspec executable check, and RuboCop.
- [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml): gem packaging, a strict Jekyll build, built-HTML proofing, RuboCop, the resume validator and template key checker, and the unit tests across Ruby 3.3, 3.4, and 4.0.

## Built-HTML proofing semantics

- External URLs are not fetched, so results are offline and deterministic.
- Absolute URLs built from `site.url` (hreflang, canonical) are mapped onto local files so they are checked too.
- When `_site/index.html` does not exist, `/` and every configured `languages.<lang>.url` are exempted as link targets. A site with a homepage gets no exemption. Use the demo build to check the complete generated site.

## JSON Resume export coverage

Run the normal demo build and `bundle exec rake`. Export coverage includes visibility, live contacts, privacy, locale characters, schema validation, collisions, literal Liquid content, and discovery-link cleanup on rebuild. Generated JSON can be downloaded directly or imported into JSON Resume tooling; compatibility with every third-party renderer is not guaranteed by schema validity.

## Liquid pitfalls the tests guard

See [Liquid pitfalls](../explanation/architecture.md#liquid-pitfalls).
