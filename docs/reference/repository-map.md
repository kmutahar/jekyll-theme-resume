# Repository Map

*Audience: theme developers*

Annotated tree of the theme's code directories. The `docs/` directory is not listed; see the [documentation index](../README.md).

```text
jekyll-theme-resume/
├── 403.html / 404.html / 500.html  # Root HTTP error pages (layout: error)
│
├── _layouts/
│   ├── default.html              # Base HTML shell
│   ├── profile.html              # Standalone landing page
│   ├── resume.html               # Resume layout for every language (LTR and RTL)
│   └── error.html                # HTTP error suite (404/403/500/503)
│
├── _includes/
│   ├── resume-section.html       # Section dispatcher (14 sections, every language)
│   ├── grouped-item-list.html    # Shared Experience/Volunteering renderer
│   ├── date-formatter.html       # Locale-driven date and "Present" formatting
│   ├── data-loader.html          # Dot-path data resolution into resume_data
│   ├── shared-head.html          # Meta, anti-FOUC script, favicons
│   ├── avatar.html               # Profile picture
│   ├── safe-url.html             # URL scheme allowlist (sets safe_url)
│   ├── dark-mode-toggle.html     # Floating theme toggle
│   ├── language-switcher.html    # Floating dropdown linking to every other configured language
│   ├── social-links.html         # Social icons (email + 14 platforms)
│   ├── print-social-links.html   # Print-only social links text list
│   ├── hreflang.html             # Alternate-language SEO links
│   ├── json-ld-resume.html       # Schema.org JSON-LD script for a CV page
│   ├── analytics-head.html       # GTM / GA4 head script
│   ├── analytics-body.html       # GTM noscript body fallback
│   └── vendors/svg-icons/        # Bundled Lineicons SVGs (MIT; see ATTRIBUTION.md inside)
│
├── _sass/
│   ├── _variables.scss           # Widths, gutters, font stacks
│   ├── _dark-mode.scss           # Color tokens, overrides, print reset
│   ├── _base.scss                # Reset, .sr-only, base typography
│   ├── _layout.scss              # Floating language-switcher styles
│   ├── _resume-ltr.scss          # Main resume styles + LTR positioning
│   ├── _resume-rtl.scss          # Language-neutral RTL overrides
│   ├── _profile-page.scss        # Landing page styles
│   ├── _all-pages.scss           # Shared markdown typography, icon links, footer, error-page styles
│   ├── _mixins.scss              # Breakpoints and font mixins
│   └── _normalize.scss           # Normalize.css v8.0.1
│
├── assets/
│   ├── css/
│   │   ├── cv-ltr.scss           # Resume entrypoint for LTR locales
│   │   ├── cv-rtl.scss           # Resume entrypoint for RTL locales
│   │   ├── profile.scss          # Profile page entrypoint
│   │   └── main.scss             # Default/error pages entrypoint
│   └── favicon/resume/           # Favicon suite
│
├── _data/
│   ├── locales/                  # en, ar, es, fr, de, ur locale dictionaries
│   └── social_networks.yml       # Shared platform list for social-links.html / print-social-links.html
│
├── _plugins/
│   ├── error_pages_generator.rb  # Synthesizes missing HTTP error pages
│   ├── json_resume_generator.rb  # Publishes /<lang>/resume.json (and /resume.json for default_lang) via JsonResumeExporter, and site.json_ld_pages for the JSON-LD include
│   ├── resume_pages_generator.rb # Synthesizes missing CV/profile pages per language
│   └── resume_validator.rb       # Build-time validation (on by default)
│
├── lib/
│   ├── jekyll-theme-resume.rb          # Gem entrypoint
│   └── jekyll-theme-resume/
│       ├── json_ld_builder.rb      # Maps the JSON Resume export to a Schema.org ProfilePage + Person
│       ├── json_resume_exporter.rb # Maps resume data to a JSON Resume v1.0.0 document
│       ├── resume_validator.rb   # Validator engine
│       ├── template_key_checker.rb # Template checker (repository-only)
│       └── schemas/
│           ├── json_resume_v1.0.0.json # Bundled JSON Resume schema used to validate exports
│           └── LICENSE.md        # License for the bundled schema
│
├── bin/
│   ├── validate-resume           # Validator CLI (gem executable)
│   ├── check-data-keys           # Template checker (repository-only)
│   └── release                   # Release script (not packaged)
│
├── test/                         # Minitest suites; see reference/testing-suites.md
└── Rakefile                      # validate, check_data_keys, test, rubocop, proof, default
```

Test suites are described in [testing suites](testing-suites.md). Layouts, includes, and Sass are detailed in [layouts](layouts.md), [includes](includes.md), and [Sass tokens](sass-tokens.md).
