# Build the starter template

*Audience: theme developers*

Generate a ready-to-use site with placeholder data from the demo, for publishing as a GitHub template repository.

## Generate the starter

```bash
git submodule update --init
bin/make-starter ../my-starter
```

**Expected result:** `../my-starter` holds a site with the starter `Gemfile`, `_config.yml` and `README.md`, plus placeholder `_data/<lang>/*.yml` for every locale in `demo/_data`. The script ends by running `validate-resume --all-locales --fail-on-warnings` on that data. The output folder must be empty or missing.

## What comes from where

| Output | Source |
|---|---|
| `Gemfile`, `_config.yml`, `README.md` | `starter/` |
| `_data/<lang>/<section>.yml` | `starter/data/<section>.yml`, copied into every locale folder |
| `.gitignore`, `.ruby-version` and other shared files | The demo submodule |
| `_pages/`, avatar image | Not copied; pages are auto-generated |

Placeholder text is English in every locale. Dates are ISO, never `Present`, because that value is localized.

## Keep the placeholders valid

When you add a section or change a data schema, update `starter/data/` and `starter/_config.yml` (`resume_section`, `resume_section_order`). The validator step in `bin/make-starter` fails if a placeholder no longer matches the schema. See [Add a section](add-a-section.md).

## Related

- [Data schemas](../reference/data-schemas.md)
- [Validator CLI](../reference/validator-cli.md)
