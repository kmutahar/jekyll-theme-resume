# My Resume

A multilingual resume built with [jekyll-theme-resume](https://github.com/kmutahar/jekyll-theme-resume). See a filled-in example on the `demo` branch.

1. Edit `_config.yml`: your name, `url`, `baseurl`, and contact details.
2. Replace the placeholders in `_data/<lang>/*.yml`. Set `active: false` to hide an entry.
3. Remove languages you do not need from `languages:` and delete their `_data/<lang>/` folder.
4. Preview: `bundle install && bundle exec jekyll serve`
5. Check your data: `bundle exec validate-resume _data --all-locales`

To upgrade the theme, run `bundle update jekyll-theme-resume`.
