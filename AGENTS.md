# AGENTS.md: Master AI Agent Operating Manual (Constitution)

> **Authoritative Single Source of Truth**: This document is the master instruction manual for all AI coding assistants, autonomous agents, and pair programmers (Google Antigravity, Cursor, Warp, Copilot, Claude Code, Codex, etc.) working in this repository.
> 
> *Note for Claude Code / Warp users*: [`CLAUDE.md`](CLAUDE.md) and [`WARP.md`](WARP.md) reference this master document. Do not create separate diverging guides; maintain all guidance in this file.

**jekyll-theme-resume** is a Ruby gem / Jekyll theme for data-driven, multilingual resume and CV websites. One locale-agnostic layout renders every language, LTR or RTL, from per-language YAML data and locale files. Six locales ship with the theme: English (`en`), Arabic (`ar`), Spanish (`es`), French (`fr`), German (`de`), and Urdu (`ur`). 
- **RubyGems**: https://rubygems.org/gems/jekyll-theme-resume
- **Demo / Homepage**: https://www.mutahr.me/jekyll-theme-resume

## 1. Agent Golden Rules & Operating Protocol

Whenever an AI agent operates in this codebase, the following rules are non-negotiable:

### Rule 1: All-Locale Parity
Language differences live only in data. Every language renders through the same layout (`_layouts/resume.html`) and direction-based stylesheets.
- **Visible text** belongs in `_data/locales/<lang>.yml`. When adding or renaming a key, update all six locale files (`en`, `ar`, `es`, `fr`, `de`, `ur`) to maintain identical key sets.
- **Templates** must read the active locale (`locale.ui.*`, `locale.direction`) and never branch on a specific language code.
- **RTL** changes go in `_sass/_resume-rtl.scss` as language-neutral overrides under `html[dir="rtl"]`.

### Rule 2: Single Source of Truth for Agent Guidance
Keep all project context and operational instructions in `AGENTS.md`. Maintain references in other companion pointer files ([`CLAUDE.md`](CLAUDE.md), [`WARP.md`](WARP.md)) but do not duplicate documentation.

### Rule 3: Roadmap-Driven Implementation
All feature work is planned in [`FEATURE_ROADMAP.md`](FEATURE_ROADMAP.md). Before starting, consult the implementation brief in the roadmap for target files, schemas, and test criteria.

### Rule 4: Historical Audit Awareness
Before addressing bugs, security findings, or refactoring, consult [`docs/COMPLETED_AUDIT.md`](docs/COMPLETED_AUDIT.md) for prior fixes. Check the roadmap’s [Status Delete-Zone](FEATURE_ROADMAP.md#status-delete-zone) before recreating removed files or keys.

### Rule 5: Build & Packaging Verification
Never declare a task complete without running the verification suite. Run `bin/verify`: it executes the three steps below, writes the full output to `/tmp/resume-theme-verify.log`, prints one PASS/FAIL line per step (plus the log tail on failure), and cleans up build artifacts. Don't run the steps individually unless debugging a failure.
```bash
# 1. Demo build
bundle exec jekyll build --source demo --destination _site
# 2. Test suite, linting, and data validation
bundle exec rake
# 3. Package verification
gem build jekyll-theme-resume.gemspec
rm -f jekyll-theme-resume-*.gem
```
*Done* means 0 Liquid errors, 0 test failures, 0 RuboCop offenses, and a successful gem build.

### Rule 6: Gated Commit Approval
Stage changes (`git add`), run verification commands, and propose commit messages for the user's review. Execute `git commit` only when explicitly commanded by the user.

### Rule 7: Task Decomposition
Decompose complex, multi-faceted tasks into focused sub-tasks. If your platform supports subagents or multiple models, match the model tier to the task's complexity (e.g., fast models for file scanning, reasoning models for architectural refactoring) to optimize execution speed.

### Rule 8: Clean Workspace & Artifact Hygiene
Always leave the git working directory clean. Remove temporary test outputs, scratch files, and build caches (`.jekyll-cache`) before declaring a task complete or presenting commit proposals. Keep the `demo/` submodule pointer clean unless updating the demo site is an explicit requirement.

### Rule 9: Release Files Are Owned by `bin/release`
Never edit `CHANGELOG.md` or the version number in `jekyll-theme-resume.gemspec` (`spec.version`). Both are handled by `bin/release`; hand edits conflict with it.

## 2. Context Pointers & Master Index

Use the following index to find specific architecture details, schemas, and configurations. Do not guess schemas or layout mechanics; load the relevant file.

| Need / Task | Go To | Role |
|---|---|---|
| **All documentation, grouped by need** | [`docs/README.md`](docs/README.md) | Index |
| **First site walkthrough** | [`docs/tutorials/getting-started.md`](docs/tutorials/getting-started.md) | Tutorial |
| **Architecture Map & File Tree** | [`docs/explanation/architecture.md`](docs/explanation/architecture.md), [`docs/reference/repository-map.md`](docs/reference/repository-map.md) | Explanation, Reference |
| **Site Config & `_config.yml`** | [`docs/reference/config.md`](docs/reference/config.md) | Reference |
| **Data Schemas & Resume Sections**: Dynamic YAML rendering | [`docs/reference/data-schemas.md`](docs/reference/data-schemas.md) | Reference |
| **Locale Files & RTL Setup** | [`docs/reference/locale-keys.md`](docs/reference/locale-keys.md), [`docs/explanation/multilingual-and-rtl-design.md`](docs/explanation/multilingual-and-rtl-design.md) | Reference, Explanation |
| **HTML Layouts & Data Flow**: Dynamic data path resolution | [`docs/reference/layouts.md`](docs/reference/layouts.md) | Reference |
| **Components & Include Files** | [`docs/reference/includes.md`](docs/reference/includes.md) | Reference |
| **SCSS Architecture & Dark Mode** | [`docs/reference/sass-tokens.md`](docs/reference/sass-tokens.md), [`docs/explanation/dark-mode-approach.md`](docs/explanation/dark-mode-approach.md) | Reference, Explanation |
| **Tests, Suites & Coverage** | [`docs/reference/testing-suites.md`](docs/reference/testing-suites.md), [`docs/how-to/add-a-test.md`](docs/how-to/add-a-test.md) | Reference, How-to |
| **Validator CLI & Build Checks** | [`docs/reference/validator-cli.md`](docs/reference/validator-cli.md) | Reference |
| **Accessibility Verification** | [`docs/reference/accessibility-coverage.md`](docs/reference/accessibility-coverage.md), [`docs/how-to/verify-accessibility.md`](docs/how-to/verify-accessibility.md) | Reference, How-to |
| **JSON Resume Export** | [`docs/reference/json-resume-fields.md`](docs/reference/json-resume-fields.md), [`docs/how-to/publish-json-resume.md`](docs/how-to/publish-json-resume.md) | Reference, How-to |
| **JSON-LD Structured Data** | [`docs/reference/json-ld-fields.md`](docs/reference/json-ld-fields.md), [`docs/how-to/validate-structured-data.md`](docs/how-to/validate-structured-data.md) | Reference, How-to |
| **Active Feature Blueprints** | [`FEATURE_ROADMAP.md`](FEATURE_ROADMAP.md) | Status |
| **Historical Fixes & Remediations** | [`docs/COMPLETED_AUDIT.md`](docs/COMPLETED_AUDIT.md) | History |

## 3. Common Developer Commands

```bash
# Initialize demo submodule and install dependencies
git submodule update --init --recursive
bundle install

# Serve the demo with live reload
bundle exec jekyll serve --source demo --destination _site --livereload --incremental

# Run the complete test and validation suite
bundle exec rake

# Multi-language data schema and parity validation
./bin/validate-resume demo/_data --all-locales --fail-on-warnings

# Test the theme in a consuming Jekyll site (local test)
# In consuming site Gemfile: gem "jekyll-theme-resume", path: "../jekyll-theme-resume"
```

## 4. Troubleshooting & Debugging

- **Section Not Appearing**: Check that the section name is in `site.resume_section_order`, `site.resume_section.<name>` is `true`, and the data items have `active: true`.
- **Page Renders Without Data**: The page's `lang` has no `languages.<lang>` entry, or its `data_path` folder is missing. Run `./bin/validate-resume <data_dir>`.
- **Dates Not Localized**: Check that the `enddate` string matches a value in the locale's `present_values`.
- **Files Missing from Built Gem**: Ensure the files match the `spec.files` filter in `jekyll-theme-resume.gemspec`.

## 5. GitHub Issues & Git Workflow

Automatically close issues by referencing them in branches and commits:
- **Branch Naming**: `feature/<feature-name>` (e.g. `feature/color-themes`)
- **Conventional Commit**: `feat(<scope>): <description> (Closes #<issue_id>)`
- **Pull Request Title**: `feat(<scope>): <description> (Closes #<issue_id>)`
