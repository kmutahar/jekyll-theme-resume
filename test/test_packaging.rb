# frozen_string_literal: true

require "date"
require "minitest/autorun"
require "rubygems"
require "yaml"

# What a consuming site receives: the gem's file list, and the shipped locale/data contracts
# every template relies on (AGENTS.md Rule 1: all-locale parity).
class PackagingTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  LOCALES = %w[en ar es fr de ur].freeze
  SECTIONS = %w[experience education certifications courses volunteering projects skills recognitions
                associations interests languages links publications references].freeze
  ERROR_CODES = %w[404 403 500 503].freeze

  def spec
    @spec ||= Dir.chdir(ROOT) { Gem::Specification.load("jekyll-theme-resume.gemspec") }
  end

  def locale(lang)
    YAML.safe_load_file(File.join(ROOT, "_data", "locales", "#{lang}.yml"))
  end

  def flatten(hash, prefix = nil)
    hash.flat_map do |key, value|
      path = [prefix, key].compact.join(".")
      value.is_a?(Hash) ? flatten(value, path) : [path]
    end
  end

  # --- Gem contents ----------------------------------------------------------------------------

  def test_gem_ships_theme_runtime_files
    files = spec.files
    LOCALES.each { |lang| assert_includes files, "_data/locales/#{lang}.yml" }
    %w[_layouts/resume.html _includes/resume-section.html _sass/_resume-rtl.scss assets/css/cv-rtl.scss
       _data/social_networks.yml bin/validate-resume lib/jekyll-theme-resume.rb
       lib/jekyll-theme-resume/resume_validator.rb lib/jekyll-theme-resume/json_resume_exporter.rb
       lib/jekyll-theme-resume/schemas/json_resume_v1.0.0.json _plugins/error_pages_generator.rb
       _plugins/resume_pages_generator.rb _plugins/resume_validator.rb _plugins/json_resume_generator.rb
       _config.sample.yml 404.html LICENSE.txt README.md docs/README.md
       docs/tutorials/getting-started.md].each { |file| assert_includes files, file }
  end

  def test_gem_excludes_repository_only_tooling
    files = spec.files
    %w[Rakefile bin/release bin/check-data-keys lib/jekyll-theme-resume/template_key_checker.rb
       docs/COMPLETED_AUDIT.md AGENTS.md FEATURE_ROADMAP.md].each { |file| refute_includes files, file }
    assert(files.none? { |file| file.start_with?("test/", "demo/", ".github/", "docs/adr/") })
  end

  def test_gem_ships_only_git_tracked_files
    tracked = Dir.chdir(ROOT) { `git ls-files -z`.split("\0") }
    assert_empty spec.files - tracked, "spec.files must be a subset of tracked files"
  end

  def test_only_the_validator_is_an_executable
    assert_equal ["validate-resume"], spec.executables
  end

  # --- Locale contract -------------------------------------------------------------------------

  def test_shipped_locales_share_one_key_set
    reference = flatten(locale("en")).sort
    LOCALES.each { |lang| assert_equal reference, flatten(locale(lang)).sort, "#{lang}.yml key set differs from en.yml" }
  end

  def test_locales_define_direction_months_titles_and_error_copy
    LOCALES.each do |lang|
      data = locale(lang)
      assert_includes %w[ltr rtl], data["direction"], lang
      assert_equal 12, data["months"].size, "#{lang}: months"
      assert_includes data["present_values"], "present", "#{lang}: the templates' English 'Present' default must match"
      SECTIONS.each { |name| refute_empty data["ui"]["section_titles"][name].to_s, "#{lang}: title for #{name}" }
      ERROR_CODES.each { |code| refute_empty data["error_pages"][code]["title"].to_s, "#{lang}: #{code}" }
    end
    assert_equal(%w[ar ur], LOCALES.select { |lang| locale(lang)["direction"] == "rtl" })
  end

  def test_every_locale_key_is_read_somewhere
    sources = Dir[File.join(ROOT, "{_layouts,_includes,_plugins,lib}", "**", "*.{html,rb}")].map { |file| File.read(file) }.join
    data = locale("en")
    dynamic = { "error_pages" => %w[404 403 500 503], "ui" => %w[section_titles social_labels] }
    keys = data.keys + data["ui"].keys + data["error_pages"].keys
    keys -= dynamic.values.flatten
    unread = keys.reject { |key| sources.match?(/\b#{Regexp.escape(key)}\b/) }
    assert_empty unread, "locale keys no template or plugin reads"
  end

  def test_every_social_network_has_an_icon_and_a_label_in_every_locale
    YAML.safe_load_file(File.join(ROOT, "_data", "social_networks.yml")).each do |network|
      icon = File.join(ROOT, "_includes", "vendors", "svg-icons", "#{network['icon']}.svg")
      assert_includes File.read(icon, 200), 'aria-hidden="true"', network["icon"]
      LOCALES.each { |lang| refute_empty locale(lang)["ui"]["social_labels"][network["key"]].to_s, "#{lang}: #{network['key']}" }
    end
  end

  # --- Demo data parity ------------------------------------------------------------------------

  def test_demo_languages_have_the_same_files_and_entry_counts
    data_dir = File.join(ROOT, "demo", "_data")
    skip "demo submodule not initialized" unless Dir.exist?(File.join(data_dir, "en"))
    reference = Dir.children(File.join(data_dir, "en")).sort
    LOCALES.each do |lang|
      assert_equal reference, Dir.children(File.join(data_dir, lang)).sort, "#{lang}: data files"
      reference.each do |file|
        en = YAML.safe_load_file(File.join(data_dir, "en", file), permitted_classes: [Date])
        other = YAML.safe_load_file(File.join(data_dir, lang, file), permitted_classes: [Date])
        next unless en.is_a?(Array)

        assert_equal en.size, other.size, "#{lang}/#{file}: entry count"
        assert_equal(en.map { |item| item["active"] }, other.map { |item| item["active"] }, "#{lang}/#{file}: active flags")
      end
    end
  end
end
