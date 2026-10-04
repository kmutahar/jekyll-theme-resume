# Add a test

*Audience: theme developers*

Run the test suites and add a new test for a change.

## Run the tests

```bash
git submodule update --init --recursive      # demo/ data is used by several suites
bundle exec rake                             # validate + check_data_keys + rubocop + every test/test_*.rb
bundle exec rake test                        # tests only
bundle exec ruby test/test_rendered_site.rb  # one suite
bundle exec ruby test/test_rendered_site.rb -n /date/   # tests whose name matches
```

## Add a test

1. Pick the interface a user or consuming site touches: rendered HTML for templates, `ResumeValidator#validate` for data rules, a site build for generators.
2. Write the failing test first and run it to see the failure message.
3. Make the smallest change that passes it, then run `bundle exec rake`.

## Common cases

- **New section field:** add it to `resume_data` in `test_rendered_site.rb` and assert on the rendered text; add a validator rule test if the field is validated.
- **New locale key:** add it to all six `_data/locales/*.yml` files. `test_packaging.rb` fails if the key sets differ or no template reads the key.
- **New social platform:** follow [Add a social platform](add-a-social-platform.md); `test_packaging.rb` checks the SVG and labels.
- **New generator:** require it from `lib/jekyll-theme-resume.rb` and add its class to the registration test in `test_error_pages_generator.rb`.

## See also

- [Testing suites reference](../reference/testing-suites.md)
- [Validator CLI](../reference/validator-cli.md)
- [Verification rules](../../AGENTS.md#rule-5-build--packaging-verification)
