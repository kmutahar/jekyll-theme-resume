# frozen_string_literal: true

# =============================================================================
# Multilingual Jekyll Resume Theme — Gem Runtime Entrypoint
# =============================================================================
# When a consuming Jekyll site specifies `theme: jekyll-theme-resume`
# in its _config.yml or includes the gem in its Gemfile, Bundler/Jekyll automatically
# requires this file.
#
# Requiring "jekyll" loads the core Jekyll classes (e.g., Jekyll::Generator).
# Requiring "../_plugins/error_pages_generator" automatically registers the
# ErrorPagesGenerator plugin with Jekyll's plugin hook lifecycle, allowing
# consuming sites to automatically gain 404, 403, and 500 pages without manual setup.
# =============================================================================

require "jekyll"
require_relative "jekyll-theme-resume/resume_validator"
require_relative "../_plugins/error_pages_generator"
require_relative "../_plugins/resume_validator"
require_relative "../_plugins/resume_pages_generator"
require_relative "../_plugins/json_resume_generator"
