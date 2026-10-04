# Validator and build checks

*Audience: site owners and theme developers*

The repository has two verification engines; only the resume-data validator ships in the gem. `lib/jekyll-theme-resume/resume_validator.rb` checks resume YAML data — reached three ways: the `validate-resume` CLI, the `rake validate` task, and a Jekyll generator that runs during every consuming site's build. `lib/jekyll-theme-resume/template_key_checker.rb` checks the theme's own `_layouts`/`_includes` Liquid templates for references to data keys that don't exist — reached via the `check-data-keys` CLI and the `rake check_data_keys` task ([section 11](#11-template-key-checker-check-data-keys)); unlike the resume validator, it runs only in this repository's own development workflow and CI, never on a consuming site's build, and it is not packaged in the gem. This page describes what each checks and how their entry points behave.

---

## 1. What Gets Checked

Findings are **errors** or **warnings**. Errors make the CLI exit 1; warnings do too only with `--fail-on-warnings`.

| Check | Severity |
|---|---|
| YAML syntax in every data, locale, and config file | Error |
| A configured language has no locale file (neither theme nor site) | Error |
| A configured language has no data folder | Error |
| A `languages.<lang>` entry has no `data_path` | Error |
| An explicit `--config` file does not exist | Error |
| Required fields per section, date formats, inverted date ranges, URLs that do not parse or do not start with `http://` or `https://` | Error (see [catalog](#6-validation-rules-catalog-by-section)) |
| A section file exists in one language folder and not another (file parity) | Warning |
| A language's effective locale is missing keys the reference locale has (locale parity) | Warning |
| Missing or non-boolean `active` flag, brief or missing header intro, skill `level` outside 1 to 5 | Warning |

Entries with `active: false` skip schema checks after the `active` flag check.

---

## 2. How Languages and Locales Are Resolved

**Config.** The validator reads the site's Jekyll config to learn which languages exist. It uses the first file found: the `--config` path, then `<data_dir>/_config.yml`, `<data_dir>/_config.sample.yml`, `<data_dir>/../_config.yml`, `<data_dir>/../_config.sample.yml`. The Jekyll plugin passes the already-loaded site config instead.

**Languages.** The set of languages to validate is, in order of precedence:

1. `--languages` on the CLI, if given.
2. Every key under `languages:` in the config. Each language's folder is `<data_dir>/<data_path>`, with dot paths split into folders (`2025-06.v1` resolves to `<data_dir>/2025-06/v1`).
3. With no `languages:` in the config (or no config), a directory scan of `<data_dir>` for folders named like language codes (`en`, `pt-BR`, `zh_CN`) that contain YAML files. Folders named `locales`, `sample`, `archive`, `assets`, and similar are skipped.

`--all-locales` adds the directory scan on top of 1 or 2.

**Locales.** Each language's effective locale is the theme gem's `_data/locales/<lang>.yml` with the site's `<data_dir>/locales/<lang>.yml` deep-merged over it: nested hashes merge key by key, arrays (`months`, `present_values`) are replaced whole. This mirrors how Jekyll layers theme and site data (see [`multilingual-and-rtl-design.md`](../explanation/multilingual-and-rtl-design.md#overriding-theme-locales)). Locale parity is checked on the merged result, so a one-line site override warns on nothing, while a site-only locale for a language the theme does not ship must be complete.

**Reference language.** Locale parity compares every language against one reference: `--primary` (default `en`) if it has a locale, else `default_lang`, else the first language that has one. File parity uses `--primary` if it has a data folder, else the first language that does.

---

## 3. CLI Validator (`validate-resume`)

The gem installs `validate-resume` as an executable. In a consuming site run it through Bundler; in this repository run `./bin/validate-resume`.

```bash
bundle exec validate-resume                       # auto-detects the data directory
bundle exec validate-resume _data                 # explicit data directory
bundle exec validate-resume _data -c _config.yml  # explicit config
./bin/validate-resume demo/_data                  # this repository's six-language demo
```

With no `DATA_DIR`, the CLI uses the first of `_data` and `demo/_data` that contains at least one language folder, else `_data`. A positional `DATA_DIR` wins over `-d`.

| Flag | Long flag | Description | Default |
|---|---|---|---|
| `-d DIR` | `--dir DIR` | Data directory | `_data` or `demo/_data` |
| `-c FILE` | `--config FILE` | Jekyll config that declares `languages:` | First config found next to the data directory ([section 2](#2-how-languages-and-locales-are-resolved)) |
| `-l LANGS` | `--languages LANGS` | Comma-separated languages to validate; overrides the config | The config's `languages:` |
| `-a` | `--all-locales` | Also validate every language folder found by directory scan | off |
| `-p LOCALE` | `--primary LOCALE` | Reference language for parity checks | `en` |
| `-w` | `--fail-on-warnings` | Exit 1 on warnings as well as errors | off |
| `-v` | `--verbose` | Accepted for compatibility; currently has no effect | off |
| `-q` | `--quiet` | Print only when there are findings | off |
| `-h` | `--help` | Show usage | |

Exit codes (from [`bin/validate-resume`](../../bin/validate-resume), which exits with the value `validate` returns; see [section 12](#12-ruby-api-resumevalidator)):

| Code | When |
|---|---|
| `0` | No errors, and no warnings under `-w`; also after `-h` prints usage |
| `1` | Any error (including a data directory that does not exist), or any warning under `-w` |

An unrecognized option raises an uncaught `OptionParser` exception, so Ruby exits with status `1` before validation starts.

---

## 4. Rake Task (`rake validate`)

```bash
bundle exec rake validate               # _data if _data/en exists, else demo/_data
bundle exec rake "validate[path/to/_data]"
```

The task takes no config argument; it finds the config next to the data directory as described in [section 2](#2-how-languages-and-locales-are-resolved). For what the default `bundle exec rake` task runs, see [testing-suites.md](testing-suites.md#test-tasks).

---

## 5. Jekyll Build-Time Validation

When the gem is loaded as a plugin (through `group :jekyll_plugins` in the site's `Gemfile` or the theme name in `_config.yml`’s `plugins:` list), `_plugins/resume_validator.rb` validates the site's `data_dir` on every `jekyll build` and `jekyll serve`. It is **on by default**; findings are logged and the build continues.

To opt out or gate the build on findings, see [Validate resume data in CI](../how-to/validate-in-ci.md#configure-build-time-validation).

| Key | Default | Effect |
|---|---|---|
| `validate_resume` | on (unset) | Only the literal value `false` disables validation. |
| `validate_resume_strict` | `false` | `true` raises `Jekyll::Errors::FatalException` when there are errors. |
| `validate_resume_fail_on_warnings` | `false` | With `validate_resume_strict: true`, warnings also abort the build. Has no effect without strict mode. |

If the configured `data_dir` does not exist, the plugin logs a warning and skips validation.

---

## 6. Validation Rules Catalog by Section

The rules are identical for every language. Required fields must use the canonical key the templates render. Names in parentheses are aliases the templates never read: an entry that sets only an alias still fails, and the error names the alias it found (for example `Missing required field 'company': found 'organization', but the theme only renders 'company'`). Field names are listed in [data-schemas.md](data-schemas.md).

| Section file | Required fields | Checked when present |
|---|---|---|
| `header.yml` | Must be a Hash | `intro` (or `about`): warning if missing or under 20 characters |
| `experience.yml` | `company` (`organization`), `position` (`role`) | `startdate`, `enddate` (date or "present"), date order, `url`, empty `durations[].duration` warns; warning if none of `startdate`, `enddate`, or `durations` is set |
| `education.yml` | `uni` (`institution`, `school`), `degree`, and nonblank `year` unless `startdate` is supplied | `startdate`, `enddate` (date or "present"), date order, `url` |
| `certifications.yml` | `name` (`title`) | `issue_date`, `expiration`, `expiration >= issue_date`, `credential_url` |
| `courses.yml` | `name` (`title`, `course`) | `startdate`, `enddate`, date order, `credential_url` |
| `volunteering.yml` | `company` (`organization`), `position` (`role`) | `startdate`, `enddate` (date or "present"), date order, `url` |
| `projects.yml` | `project` (`title`, `name`) | `url`, `startdate`, `enddate` (date or "present"), date order |
| `skills.yml` | `skill` (`category`, `name`) | `level` is an integer 1 to 5 (warning) |
| `recognitions.yml` | `award` (`title`, `recognition`) | `date` (ISO) |
| `associations.yml` | `organization` (`company`, `name`) | `url` |
| `languages.yml` | `language` (`name`) | |
| `links.yml` | `description` (`name`, `title`), `url` | `url` |
| `publications.yml` | `name` (`title`) | `release_date` (ISO), `url` (http/https) |
| `references.yml` | `name`, `reference` (`quote`, `text`) | none |
| `interests.yml` | none; missing `description` is a warning (naming `interest`/`name` when one is set) | No `active` flag check |

Every file except `header.yml` must be a list of Hashes. Every list entry except in `interests.yml` should carry `active: true` or `active: false`.

Dates must be ISO: `YYYY-MM-DD`, `YYYY-MM`, or `YYYY`. Ranges compare at the precision given, with partial end dates extended to the end of their period, so `2024-05-15` to `2024-05` is valid and `2025-01` to `2024-05` is an error.

URLs must parse and must start with `http://` or `https://`; either failure is an error.

---

## 7. "Present" Dates

The words the validator accepts for an ongoing `enddate` are listed in [Present values](locale-keys.md#present-values).

---

## 8. Troubleshooting

Findings and their fixes are in [Troubleshoot builds](../how-to/troubleshoot-builds.md).

---

## 9. Continuous Integration

This repository's workflows are listed in [testing-suites.md](testing-suites.md#continuous-integration). A consuming-site workflow is in [Validate resume data in CI](../how-to/validate-in-ci.md#run-the-validator-in-github-actions).

---

## 10. Built-HTML Proofing & Static Analysis

Commands are in [Validate resume data in CI](../how-to/proof-built-html.md); proofing semantics are in [testing-suites.md](testing-suites.md#built-html-proofing-semantics).

---

## 11. Template Key Checker (`check-data-keys`)

Why the checker exists and why it never defaults to `--fail-on-warnings`: [Resume Data Validator](../explanation/architecture.md#two-verification-engines).

```bash
./bin/check-data-keys demo/_data                  # this repository's six-language demo (the default target)
./bin/check-data-keys demo/_data --fail-on-warnings  # opt into strict mode yourself, once you trust your data's coverage
bundle exec rake check_data_keys                     # _data if _data/en exists, else demo/_data; never fails the task
bundle exec rake "check_data_keys[path/to/_data]"
```

| Flag | Long flag | Description | Default |
|---|---|---|---|
| `-d DIR` | `--dir DIR` | Data directory whose sample data defines the known keys | `_data` or `demo/_data` |
| `-c FILE` | `--config FILE` | Jekyll config that declares `languages:` | `_config.yml` / `_config.sample.yml` next to the data directory |
| `-w` | `--fail-on-warnings` | Exit 1 on warnings | off |
| `-v` | `--verbose` | Accepted for compatibility; currently has no effect | off |
| `-q` | `--quiet` | Print only when there are findings | off |
| `-h` | `--help` | Show usage | |

With no `DATA_DIR`, `check-data-keys` uses the first of `_data` and `demo/_data` that contains at least one language folder, else `demo/_data`. A positional `DATA_DIR` wins over `-d`.

Scans only `_layouts/*.html` and `_includes/**/*.html` — this repository's own shipped templates, never a consuming site's `_pages/` or `_layouts/`/`_includes` overrides. Runs in `bundle exec rake` (the default task) and in both CI workflows ([testing-suites.md](testing-suites.md#continuous-integration)), always without `--fail-on-warnings`.

---

## 12. Ruby API (`ResumeValidator`)

`JekyllThemeResume::ResumeValidator` in [`lib/jekyll-theme-resume/resume_validator.rb`](../../lib/jekyll-theme-resume/resume_validator.rb) backs the CLI, the Rake task, and the Jekyll generator. Public interface:

| Signature | Behavior |
|---|---|
| `new(data_dir = "_data", config_path: nil, config: nil, primary_locale: "en")` | Stores the data directory (trailing `/` removed), an explicit config path, an already-parsed site config Hash (the Jekyll plugin passes `site.config`; when `nil` the config is looked up on disk, `config_path` first), and the reference language (`nil` becomes `"en"`). |
| `validate(languages: nil, all_locales: false, primary_locale: nil, verbose: false, quiet: false, fail_on_warnings: false)` | Clears previous findings, runs every check on the resolved languages, prints the report (skipped under `quiet:` when there are no findings), and returns `1` when there are errors or, with `fail_on_warnings: true`, warnings; otherwise `0`. A missing data directory is an error and returns `1` at once. A non-nil `primary_locale:` replaces the one given to `new`. |
| `discover_languages` | Returns the subfolders of the data directory that are named like language codes, are not in the skip list, and contain `.yml`/`.yaml` files, with `primary_locale` first (when it is among them) and the rest sorted; `[]` if the data directory does not exist. |
| `locale_for(lang)` | Returns the effective locale Hash for `lang` (stripped and downcased): the theme's `_data/locales/<lang>.yml` with the site's `<data_dir>/locales/<lang>.yml` deep-merged over it, a site-only locale as-is, or `nil` when neither exists; cached per `validate` run. |
| `present_aliases_for(lang = nil)` | Returns the unique accepted "present" words for `lang`: the effective locale's `present_values` plus its `ui.present`, falling back to the `default_lang` (else reference-language) locale when `lang` has none; a `nil` or blank `lang` returns the words of every known locale. |
| `present_date?(date_val, lang: nil)` | Returns `false` for `nil`, `Date`, or `Time` values, `true` for a blank string, and otherwise whether the value matches one of `present_aliases_for(lang)` case-insensitively. |

Read-only attributes: `data_dir`, `errors`, `warnings`, `primary_locale`, and `info` (currently always empty). Each finding is a Hash `{ context:, message: }`.
