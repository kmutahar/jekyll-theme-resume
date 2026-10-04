# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "jekyll-theme-resume"
  spec.version       = "1.3.0"
  spec.authors       = ["Khaldoon Mutahar"]
  spec.email         = ["contact@mutahar.me"]

  spec.summary       = "A data-driven, multilingual (LTR and RTL) Jekyll resume theme with six built-in locales."
  spec.homepage      = "https://www.mutahr.me/jekyll-theme-resume"
  spec.license       = "MIT"

  spec.platform      = Gem::Platform::RUBY # Specifies this is a pure Ruby gem (works on all platforms)
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata      = {
    "bug_tracker_uri"   => "https://github.com/kmutahar/jekyll-theme-resume/issues",
    "changelog_uri"     => "https://github.com/kmutahar/jekyll-theme-resume/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://github.com/kmutahar/jekyll-theme-resume#readme",
    "homepage_uri"      =>  spec.homepage,
    "source_code_uri"   => "https://github.com/kmutahar/jekyll-theme-resume/",
    "allowed_push_host" => "https://rubygems.org" # Security lock to prevent pushing to wrong host
  }

  # bin/check-data-keys and lib/.../template_key_checker.rb are dev/CI-only tools
  # (they check the theme's own templates against its own demo data — see
  # docs/reference/validator-cli.md) and are intentionally excluded from the packaged gem.
  tracked_files = `git ls-files -z`.split("\x0")
  # Only git-tracked files ship, so untracked scratch files can never reach a release gem.
  spec.files         = tracked_files.select do |f|
    f.match(%r!^(assets|_data|_layouts|_includes|_sass|_plugins|lib|bin|LICENSE|README|CHANGELOG|CODE_OF_CONDUCT|SECURITY|docs|_config\.sample\.yml|404|403|500)!i) &&
      File.file?(f) &&
      f != "bin/release" &&
      f != "bin/check-data-keys" &&
      f != "lib/jekyll-theme-resume/template_key_checker.rb" &&
      f != "docs/COMPLETED_AUDIT.md" &&
      !f.start_with?("docs/adr/") &&
      !f.start_with?("demo/")
  end

  spec.bindir        = "bin"
  spec.executables   = ["validate-resume"]

  # --- A helpful message shown to users after installation ---
  spec.post_install_message = <<~MSG
    --------------------------------------------------
    Thank you for installing jekyll-theme-resume!
    
    To get started, check the setup instructions:
    https://github.com/kmutahar/jekyll-theme-resume#readme
    --------------------------------------------------
  MSG

  # --- UPDATED: Runtime Dependencies ---
  # Allows any version from 4.4.0 up to (but not including) 5.0
  spec.add_runtime_dependency "jekyll", "~> 4.4"
  spec.add_runtime_dependency "json_schemer", "~> 2.3"
  # Required directly by json_resume_exporter.rb; do not rely on jekyll-seo-tag's
  # or Jekyll's own transitive versions for these.
  spec.add_runtime_dependency "addressable", "~> 2.8"
  spec.add_runtime_dependency "kramdown", "~> 2.3"

  # --- PLUGIN DEPENDENCIES ---
  spec.add_runtime_dependency "jekyll-feed", "~> 0.17"
  spec.add_runtime_dependency "jekyll-seo-tag", "~> 2.9"
  spec.add_runtime_dependency "jekyll-sitemap", "~> 1.4"
  spec.add_runtime_dependency "jekyll-redirect-from", "~> 0.16"
  spec.add_runtime_dependency "logger", "~> 1.7"  # Future-proof: 'logger' will be removed from the Ruby 3.5.0+ standard library.

  # --- Development Dependencies (verification tooling; never installed for theme consumers) ---
  spec.add_development_dependency "html-proofer", "~> 5.2"      # `rake proof`: dead links, anchors, images, hreflang
  spec.add_development_dependency "minitest", "~> 6.0"          # `rake test`: unit tests
  spec.add_development_dependency "rubocop", "~> 1.75"          # `rake rubocop`: static analysis
  spec.add_development_dependency "rubocop-performance", "~> 1.25"
  spec.add_development_dependency "rubocop-rake", "~> 0.7"
end
