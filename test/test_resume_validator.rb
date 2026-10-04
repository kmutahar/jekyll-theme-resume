# frozen_string_literal: true

require "minitest/autorun"

require "fileutils"
require "tmpdir"
require "yaml"
require "open3"
require "jekyll"
require_relative "../lib/bilingual-jekyll-resume-theme/resume_validator"
require_relative "../_plugins/resume_validator"

# Covers the config-driven, locale-file-driven ResumeValidator (Task 5.2 rewrite): language
# resolution from `languages:` config, locale merging (theme _data/locales/<lang>.yml deep-merged
# with the site's <data_dir>/locales/<lang>.yml), locale key-parity warnings, misconfigured-language
# errors, and the Jekyll::Generator plugin wrapper's default-on / strict-mode behavior.
class ResumeValidatorTest < Minitest::Test
  REPO_ROOT = File.expand_path("..", __dir__)
  SAMPLE_DATA_DIR = File.join(REPO_ROOT, "demo", "_data")
  SAMPLE_CONFIG_PATH = File.join(REPO_ROOT, "_config.sample.yml")
  THEME_LOCALES_DIR = File.join(REPO_ROOT, "_data", "locales")

  def setup
    @sample_config = YAML.safe_load_file(SAMPLE_CONFIG_PATH, permitted_classes: [Date, Time])
  end

  # --- Helpers -----------------------------------------------------------------------------

  def write_yaml(path, data)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, YAML.dump(data))
  end

  # Minimal valid header.yml, just enough to avoid unrelated schema warnings/errors so tests
  # can focus on the locale/language behaviour under test.
  def write_minimal_language_dir(data_dir, lang)
    write_yaml(File.join(data_dir, lang, "header.yml"), "intro" => "A sufficiently long introduction paragraph for validation.")
  end

  # --- 1. Six-language discovery from a real config's `languages:` block, end to end -------

  def test_six_language_fixture_discovers_all_languages_and_validates_cleanly
    validator = BilingualJekyllResumeTheme::ResumeValidator.new(SAMPLE_DATA_DIR, config_path: SAMPLE_CONFIG_PATH)
    exit_code = validator.validate(quiet: true, fail_on_warnings: true)

    assert_equal 0, exit_code
    assert_empty validator.errors
    assert_empty validator.warnings
  end

  def test_six_language_fixture_all_locales_matches_configured_languages
    validator = BilingualJekyllResumeTheme::ResumeValidator.new(SAMPLE_DATA_DIR, config_path: SAMPLE_CONFIG_PATH)
    validator.validate(quiet: true)

    assert_equal %w[ar de en es fr ur], validator.discover_languages.sort
  end

  # --- 2. Locale lookup falls back to the theme's gem-root locale ---------------------------

  def test_locale_for_falls_back_to_theme_locale_when_no_site_override
    Dir.mktmpdir("test_locale_fallback_") do |tmp|
      # No <tmp>/locales directory at all: locale_for must resolve purely from the theme.
      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp)

      expected = YAML.safe_load_file(File.join(THEME_LOCALES_DIR, "es.yml"))
      assert_equal expected, validator.locale_for("es")
      assert_equal "Español", validator.locale_for("es")["ui"]["language_name"]
    end
  end

  def test_locale_for_returns_nil_when_neither_theme_nor_site_locale_exists
    Dir.mktmpdir("test_locale_missing_") do |tmp|
      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp)
      assert_nil validator.locale_for("zz")
    end
  end

  # --- 3. Partial site override merges over the theme locale (no missing-key warnings) ------

  def test_partial_site_override_merges_over_theme_locale_without_parity_warnings
    Dir.mktmpdir("test_partial_override_") do |tmp|
      write_minimal_language_dir(tmp, "en")
      write_minimal_language_dir(tmp, "es")
      # Only one key overridden; everything else must still come from the theme's es.yml.
      write_yaml(File.join(tmp, "locales", "es.yml"), "ui" => { "section_titles" => { "experience" => "Mi Experiencia" } })

      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp, primary_locale: "en")
      exit_code = validator.validate(languages: %w[en es], quiet: true)

      merged = validator.locale_for("es")
      assert_equal "Mi Experiencia", merged["ui"]["section_titles"]["experience"], "site override key must win"
      assert_equal "Español", merged["ui"]["language_name"], "un-overridden keys must still come from the theme locale"

      assert_empty validator.errors
      refute(validator.warnings.any? { |w| w[:context].to_s.start_with?("Locale es") },
             "a merged (theme + partial override) locale must not warn about missing keys: #{validator.warnings}")
      assert_equal 0, exit_code
    end
  end

  # --- 4. A site array (present_values) fully replaces the theme's array ---------------------

  def test_site_present_values_array_replaces_theme_array_instead_of_merging
    Dir.mktmpdir("test_array_replace_") do |tmp|
      write_yaml(File.join(tmp, "locales", "de.yml"), "present_values" => ["Nur"])

      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp)
      aliases = validator.present_aliases_for("de")

      assert_includes aliases, "Nur"
      # Theme de.yml's own present_values ("present", "heute", "aktuell") must be gone, not merged in.
      refute_includes aliases, "heute"
      refute_includes aliases, "aktuell"
      # ui.present ("Heute", theme-only key untouched by the array override) still merges in normally.
      assert_includes aliases, "Heute"
    end
  end

  # --- 5. An incomplete site-only locale (no theme counterpart) warns on missing keys -------

  def test_site_only_locale_with_no_theme_counterpart_warns_on_missing_keys
    Dir.mktmpdir("test_site_only_locale_") do |tmp|
      write_minimal_language_dir(tmp, "en")
      write_minimal_language_dir(tmp, "xx")
      # "xx" has no theme-side _data/locales/xx.yml, so this tiny site file is used as-is.
      write_yaml(File.join(tmp, "locales", "xx.yml"), "ui" => { "present" => "Xx" })

      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp, primary_locale: "en")
      validator.validate(languages: %w[en xx], quiet: true)

      xx_warning = validator.warnings.find { |w| w[:context] == "Locale xx" }
      refute_nil xx_warning, "expected a missing-key warning for the incomplete site-only 'xx' locale"
      assert_match(/Missing key\(s\)/, xx_warning[:message])
    end
  end

  # --- 6. Missing locale keys are warnings, never errors -------------------------------------

  def test_missing_locale_keys_warn_but_never_error_and_exit_code_reflects_fail_on_warnings
    Dir.mktmpdir("test_warnings_not_errors_") do |tmp|
      write_minimal_language_dir(tmp, "en")
      write_minimal_language_dir(tmp, "xx")
      write_yaml(File.join(tmp, "locales", "xx.yml"), "ui" => { "present" => "Xx" })

      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp, primary_locale: "en")
      exit_code = validator.validate(languages: %w[en xx], quiet: true)

      assert_empty validator.errors
      refute_empty validator.warnings
      assert_equal 0, exit_code, "warnings alone must not fail the build"

      validator2 = BilingualJekyllResumeTheme::ResumeValidator.new(tmp, primary_locale: "en")
      strict_exit_code = validator2.validate(languages: %w[en xx], quiet: true, fail_on_warnings: true)
      assert_equal 1, strict_exit_code, "fail_on_warnings: true must turn warnings into a failing exit code"
    end
  end

  # --- 7. A declared language with no locale, or no data folder, is an error (exit 1) --------

  def test_declared_language_with_no_resolvable_locale_is_an_error
    Dir.mktmpdir("test_no_locale_") do |tmp|
      write_minimal_language_dir(tmp, "en")
      write_minimal_language_dir(tmp, "zz") # "zz" has no theme locale and no site locale override.

      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp, primary_locale: "en")
      exit_code = validator.validate(languages: %w[en zz], quiet: true)

      assert_equal 1, exit_code
      assert(validator.errors.any? { |e| e[:message].include?("No locale found for 'zz'") })
    end
  end

  def test_declared_language_with_no_data_folder_is_an_error
    Dir.mktmpdir("test_no_data_folder_") do |tmp|
      write_minimal_language_dir(tmp, "en")
      # "es" has a theme locale but no data folder at all under tmp.

      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp, primary_locale: "en")
      exit_code = validator.validate(languages: %w[en es], quiet: true)

      assert_equal 1, exit_code
      assert(validator.errors.any? { |e| e[:message].include?("does not exist") })
    end
  end

  # --- 8. Plugin default-on behavior and its `validate_resume: false` opt-out ----------------

  # Minimal Jekyll::Site double: the generator only calls #config and #in_source_dir.
  FakeSite = Struct.new(:config, :source_root) do
    def in_source_dir(path)
      File.expand_path(path, source_root)
    end
  end

  def test_generator_validates_by_default_and_strict_mode_raises_on_errors
    Dir.mktmpdir("test_plugin_default_on_") do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "_data")) # data dir exists, but the declared language folder does not.
      config = {
        "data_dir" => "_data",
        "languages" => { "xx" => { "data_path" => "xx" } },
        "validate_resume_strict" => true
        # "validate_resume" intentionally omitted: must default to on.
      }
      site = FakeSite.new(config, tmp)
      generator = BilingualJekyllResumeTheme::ResumeValidatorGenerator.new

      assert_raises(Jekyll::Errors::FatalException) do
        capture_io { generator.generate(site) }
      end
    end
  end

  def test_generator_validate_resume_false_short_circuits_even_in_strict_mode
    Dir.mktmpdir("test_plugin_opt_out_") do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "_data")) # same broken config as above...
      config = {
        "data_dir" => "_data",
        "languages" => { "xx" => { "data_path" => "xx" } },
        "validate_resume_strict" => true,
        "validate_resume" => false # ...but explicitly opted out.
      }
      site = FakeSite.new(config, tmp)
      generator = BilingualJekyllResumeTheme::ResumeValidatorGenerator.new

      capture_io { generator.generate(site) } # must not raise
    end
  end

  # --- 9. Strict mode: raises on errors, stays quiet on a clean run --------------------------

  def test_generator_strict_mode_does_not_raise_on_clean_six_language_data
    config = @sample_config.merge(
      "data_dir" => "demo/_data",
      "validate_resume_strict" => true
    )
    site = FakeSite.new(config, REPO_ROOT)
    generator = BilingualJekyllResumeTheme::ResumeValidatorGenerator.new

    capture_io { generator.generate(site) } # must not raise: demo/_data validates cleanly
  end

  # --- 10. Schema-level negative paths: malformed YAML, invalid URL, inverted dates, ---------
  # --- and a data-file parity mismatch across languages ---------------------------------------

  def test_malformed_yaml_file_is_a_syntax_error_and_fails_the_build
    Dir.mktmpdir("test_malformed_yaml_") do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "en"))
      File.write(File.join(tmp, "en", "header.yml"), "active: true\n  bad indent: [broken\n")

      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp, primary_locale: "en")
      exit_code = validator.validate(languages: %w[en], quiet: true)

      assert_equal 1, exit_code
      assert(validator.errors.any? { |e| e[:message].include?("YAML Syntax Error") })
    end
  end

  def test_yaml_alias_in_config_is_a_friendly_error_not_a_crash
    Dir.mktmpdir("test_alias_config_") do |tmp|
      File.write(File.join(tmp, "_config.yml"), "a: &x {k: 1}\nb: *x\n")

      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp)
      exit_code = validator.validate(quiet: true)

      assert_equal 1, exit_code
      assert(validator.errors.any? { |e| e[:message].include?("Unsupported YAML") })
    end
  end

  def test_unsafe_language_keys_are_rejected_before_touching_the_filesystem
    ["../x", "a/b", "*", "en\0"].each do |bad|
      config = { "languages" => { bad => { "data_path" => "en" } } }
      Dir.mktmpdir("test_lang_key_") do |tmp|
        validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp, config: config)
        validator.validate(quiet: true)

        assert(validator.errors.any? { |e| e[:message].include?("Invalid language key") }, "#{bad.inspect} must be rejected")
        refute(validator.errors.any? { |e| e[:message].include?("No locale found") }, "#{bad.inspect} must not reach locale lookup")
      end
    end
  end

  def test_unsafe_explicit_language_is_rejected
    Dir.mktmpdir("test_lang_arg_") do |tmp|
      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp)
      validator.validate(languages: %w[../etc], quiet: true)

      assert(validator.errors.any? { |e| e[:message].include?("Invalid language key") })
    end
  end

  def test_regional_language_keys_are_valid
    %w[en zh-CN pt_BR].each do |key|
      assert_match BilingualJekyllResumeTheme::ResumeValidator::LANG_KEY_REGEX, key
    end
  end

  def test_invalid_url_format_is_an_error
    Dir.mktmpdir("test_invalid_url_") do |tmp|
      write_yaml(File.join(tmp, "en", "links.yml"),
                 [{ "active" => true, "description" => "Bad Link", "url" => "not a valid url" }])

      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp, primary_locale: "en")
      exit_code = validator.validate(languages: %w[en], quiet: true)

      assert_equal 1, exit_code
      assert(validator.errors.any? { |e| e[:message].include?("Invalid URL format") })
    end
  end

  def test_inverted_date_range_is_an_error
    Dir.mktmpdir("test_inverted_dates_") do |tmp|
      write_yaml(File.join(tmp, "en", "experience.yml"),
                 [{ "active" => true, "company" => "Acme", "position" => "Engineer",
                    "startdate" => "2020-01-01", "enddate" => "2019-01-01" }])

      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp, primary_locale: "en")
      exit_code = validator.validate(languages: %w[en], quiet: true)

      assert_equal 1, exit_code
      assert(validator.errors.any? { |e| e[:message].include?("Date range error") })
    end
  end

  def test_data_file_parity_mismatch_is_flagged_across_languages
    Dir.mktmpdir("test_data_file_parity_") do |tmp|
      write_minimal_language_dir(tmp, "en")
      write_minimal_language_dir(tmp, "ar")
      # education.yml exists only for "en"; "ar" has no counterpart.
      write_yaml(File.join(tmp, "en", "education.yml"),
                 [{ "active" => true, "uni" => "MIT", "degree" => "BSc" }])

      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp, primary_locale: "en")
      validator.validate(languages: %w[en ar], quiet: true)

      assert(validator.warnings.any? { |w| w[:context] == "Parity" && w[:message].include?("education.yml") },
             "expected a data-file parity warning for the language missing education.yml")
    end
  end

  # --- 11. Per-section schema rules: one entry, one language, no config -------------------------

  # Validates `entries` as <section>.yml for a lone "en" language and returns [errors, warnings] messages.
  def findings(section, entries)
    Dir.mktmpdir("test_rule_") do |tmp|
      write_yaml(File.join(tmp, "en", "#{section}.yml"), entries)
      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp, primary_locale: "en")
      capture_io { validator.validate(languages: %w[en], quiet: true) }
      [validator.errors.map { |e| e[:message] }, validator.warnings.map { |w| w[:message] }]
    end
  end

  def errors_for(section, entry)
    findings(section, [{ "active" => true }.merge(entry)]).first
  end

  def test_alias_keys_the_templates_never_render_are_reported
    {
      "experience" => [{ "organization" => "Acme", "position" => "Dev", "startdate" => "2020" }, "company"],
      "volunteering" => [{ "company" => "Aid", "role" => "Helper" }, "position"],
      "education" => [{ "school" => "MIT", "degree" => "BSc", "year" => "2010" }, "uni"],
      "certifications" => [{ "title" => "Cert" }, "name"],
      "courses" => [{ "course" => "Ruby" }, "name"],
      "projects" => [{ "title" => "Tool" }, "project"],
      "skills" => [{ "name" => "Ruby" }, "skill"],
      "recognitions" => [{ "title" => "Prize" }, "award"],
      "associations" => [{ "name" => "Club" }, "organization"],
      "languages" => [{ "name" => "English" }, "language"],
      "links" => [{ "title" => "Blog", "url" => "https://example.org" }, "description"],
      "publications" => [{ "title" => "Paper" }, "name"],
      "references" => [{ "quote" => "Excellent.", "name" => "Dr. Watson" }, "reference"]
    }.each do |section, (entry, canonical)|
      alias_key = (entry.keys - %w[position startdate degree year url company]).first
      assert(errors_for(section, entry).any? { |m| m.include?("'#{canonical}'") && m.include?("'#{alias_key}'") },
             "#{section}: '#{alias_key}' is never rendered; expected an error naming '#{canonical}'")
    end
  end

  def warnings_for(section, entry)
    findings(section, [{ "active" => true }.merge(entry)]).last
  end

  def assert_error(section, entry, text)
    assert(errors_for(section, entry).any? { |m| m.include?(text) }, "#{section} #{entry}: expected error '#{text}'")
  end

  def assert_clean(section, entry)
    errors, warnings = findings(section, [{ "active" => true }.merge(entry)])
    assert_empty errors, "#{section} #{entry}"
    assert_empty warnings, "#{section} #{entry}"
  end

  VALID = {
    "experience" => { "company" => "Acme", "position" => "Dev", "startdate" => "2020-01-01", "enddate" => "Present" },
    "volunteering" => { "company" => "Aid", "position" => "Helper" },
    "education" => { "uni" => "MIT", "degree" => "BSc", "year" => "2010" },
    "certifications" => { "name" => "Cert" },
    "courses" => { "name" => "Ruby" },
    "projects" => { "project" => "Tool" },
    "skills" => { "skill" => "Ruby" },
    "recognitions" => { "award" => "Prize" },
    "associations" => { "organization" => "Club" },
    "languages" => { "language" => "English" },
    "links" => { "description" => "Blog", "url" => "https://example.org" },
    "publications" => { "name" => "Paper", "publisher" => "Journal", "release_date" => "1889-03", "url" => "https://example.org/p" },
    "references" => { "name" => "Dr. Watson", "reference" => "Excellent." }
  }.freeze

  def test_minimal_valid_entry_of_every_section_is_clean
    VALID.each { |section, entry| assert_clean(section, entry) }
    errors, warnings = findings("interests", [{ "description" => "Chess" }])
    assert_empty errors + warnings, "interests carry no active flag and need only a description"
  end

  def test_every_required_field_is_enforced
    VALID.each do |section, entry|
      required = entry.keys - %w[startdate enddate publisher release_date url]
      required.each do |field|
        assert_error(section, entry.except(field), "'#{field}'")
      end
    end
  end

  def test_active_flag_must_be_a_boolean
    assert(findings("skills", [{ "skill" => "Ruby" }]).last.any? { |m| m.include?("Missing 'active'") })
    assert(findings("skills", [{ "skill" => "Ruby", "active" => "yes" }]).last.any? { |m| m.include?("should be a boolean") })
  end

  def test_inactive_entries_skip_schema_checks
    errors, = findings("experience", [{ "active" => false }])
    assert_empty errors
  end

  def test_file_and_item_shapes
    assert(findings("skills", { "skill" => "Ruby" }).first.any? { |m| m.include?("Expected a list/array") })
    assert(findings("skills", ["just a string"]).first.any? { |m| m.include?("Item must be a Hash") })
    Dir.mktmpdir("test_empty_") do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "en"))
      File.write(File.join(tmp, "en", "skills.yml"), "# only a comment\n")
      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp)
      validator.validate(languages: %w[en], quiet: true)
      assert(validator.warnings.any? { |w| w[:message].include?("File is empty") })
    end
  end

  def test_header_intro_rules
    assert(findings("header", { "intro" => "" }).last.any? { |m| m.include?("intro' bio summary is missing") })
    assert(findings("header", { "intro" => "Too short" }).last.any? { |m| m.include?("very brief") })
    assert(findings("header", ["not a hash"]).first.any? { |m| m.include?("header.yml must be a Hash") })
    assert_empty findings("header", { "intro" => "A sufficiently long introduction." }).flatten
  end

  def test_iso_date_shapes_are_accepted_and_others_rejected
    %w[2020 2020-02 2020-02-29].each do |value|
      assert_clean("experience", VALID["experience"].merge("startdate" => value, "enddate" => "2021"))
    end
    { "2020/01/01" => "Invalid date format", "2023-02-30" => "Invalid date format", "Jan 2020" => "Invalid date format" }
      .each { |value, error| assert_error("experience", VALID["experience"].merge("startdate" => value), error) }
  end

  def test_yaml_date_objects_are_accepted
    assert_clean("experience", VALID["experience"].merge("startdate" => Date.new(2020, 1, 1), "enddate" => Date.new(2021, 1, 1)))
  end

  def test_date_ranges_compare_partial_dates_at_period_end
    assert_clean("experience", VALID["experience"].merge("startdate" => "2020-05-10", "enddate" => "2020-05"))
    assert_error("experience", VALID["experience"].merge("startdate" => "2020-05-10", "enddate" => "2020-04"), "Date range error")
    assert_error("certifications", { "name" => "C", "issue_date" => "2021-01-01", "expiration" => "2020-01-01" }, "Date range error")
    assert_error("courses", { "name" => "C", "startdate" => "2021", "enddate" => "2020" }, "Date range error")
    assert_error("volunteering", VALID["volunteering"].merge("startdate" => "2021", "enddate" => "2020"), "Date range error")
    assert_error("education", VALID["education"].merge("startdate" => "2021", "enddate" => "2020"), "Date range error")
    assert_error("projects", { "project" => "P", "startdate" => "2021", "enddate" => "2020" }, "Date range error")
  end

  def test_present_markers_are_case_insensitive_and_localized
    %w[Present present CURRENT].each do |value|
      assert_clean("experience", VALID["experience"].merge("enddate" => value))
    end
    assert_error("experience", VALID["experience"].merge("enddate" => "heute"), "Invalid date format")
  end

  def test_localized_present_marker_is_accepted_for_its_own_language
    Dir.mktmpdir("test_present_ar_") do |tmp|
      write_yaml(File.join(tmp, "ar", "experience.yml"),
                 [VALID["experience"].merge("active" => true, "enddate" => "حتى الآن")])
      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp)
      assert_equal 0, validator.validate(languages: %w[ar], quiet: true)
    end
  end

  def test_experience_without_any_dates_warns
    assert(warnings_for("experience", { "company" => "A", "position" => "B" }).any? { |m| m.include?("no 'startdate' or 'durations'") })
    assert(warnings_for("experience", { "company" => "A", "position" => "B", "durations" => [{ "duration" => "" }] })
      .any? { |m| m.include?("empty 'duration'") })
    assert_clean("experience", { "company" => "A", "position" => "B", "durations" => [{ "duration" => "2019" }] })
  end

  def test_education_needs_a_year_or_a_startdate
    assert_error("education", { "uni" => "MIT", "degree" => "BSc" }, "'year'")
    assert_clean("education", { "uni" => "MIT", "degree" => "BSc", "startdate" => "2010" })
  end

  def test_urls_must_be_http_or_https
    { "links" => "url", "projects" => "url", "associations" => "url", "certifications" => "credential_url",
      "courses" => "credential_url", "publications" => "url", "experience" => "url", "education" => "url",
      "volunteering" => "url" }.each do |section, field|
      assert_error(section, VALID[section].merge(field => "javascript:alert(1)"), "must begin with http:// or https://")
      assert_error(section, VALID[section].merge(field => "ftp://example.org"), "must begin with http:// or https://")
      assert_clean(section, VALID[section].merge(field => "https://example.org/x"))
    end
  end

  def test_publication_and_reference_required_fields_dates_and_inactive_entries
    assert_error("publications", { "publisher" => "Journal" }, "Missing required field 'name'")
    assert_error("publications", VALID["publications"].merge("release_date" => "1889-13"), "Invalid date format")
    assert_error("references", { "name" => "Dr. Watson" }, "Missing required field 'reference'")
    assert_error("references", { "reference" => "Excellent." }, "Missing required field 'name'")
    %w[publications references].each do |section|
      assert_empty findings(section, [{ "active" => false }]).first, "#{section}: inactive entries are skipped"
    end
  end

  def test_skill_level_must_be_between_one_and_five
    assert(warnings_for("skills", { "skill" => "Ruby", "level" => 7 }).any? { |m| m.include?("between 1 and 5") })
    assert_clean("skills", { "skill" => "Ruby", "level" => 3 })
  end

  def test_optional_export_lists_must_hold_strings
    assert(warnings_for("experience", VALID["experience"].merge("highlights" => "one")).any? { |m| m.include?("'highlights'") })
    assert(warnings_for("skills", { "skill" => "R", "level_label" => 5 }).any? { |m| m.include?("'level_label'") })
    assert_clean("projects", { "project" => "P", "roles" => ["Author"], "keywords" => ["Ruby"] })
    assert_error("recognitions", { "award" => "A", "date" => "yesterday" }, "Invalid date format")
  end

  def test_interest_alias_is_reported_as_a_warning
    _, warnings = findings("interests", [{ "name" => "Chess" }])
    assert(warnings.any? { |m| m.include?("found 'name'") })
  end

  # --- 12. Config resolution ---------------------------------------------------------------------

  def test_dotted_data_path_resolves_nested_folders
    Dir.mktmpdir("test_dotted_") do |tmp|
      write_minimal_language_dir(File.join(tmp, "2025-06"), "v1")
      write_yaml(File.join(tmp, "_config.yml"), "languages" => { "en" => { "data_path" => "2025-06.v1" } })
      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp)
      assert_equal 0, validator.validate(quiet: true)
      assert_empty validator.errors
    end
  end

  def test_language_without_data_path_is_a_config_error
    Dir.mktmpdir("test_no_data_path_") do |tmp|
      write_minimal_language_dir(tmp, "en")
      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp, config: { "languages" => { "en" => { "url" => "/" } } })
      assert_equal 1, validator.validate(quiet: true)
      assert(validator.errors.any? { |e| e[:message].include?("has no 'data_path'") })
    end
  end

  def test_missing_explicit_config_path_is_an_error
    Dir.mktmpdir("test_missing_cfg_") do |tmp|
      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp, config_path: File.join(tmp, "nope.yml"))
      assert_equal 1, validator.validate(quiet: true)
      assert(validator.errors.any? { |e| e[:message].include?("does not exist") })
    end
  end

  def test_missing_data_directory_is_an_error
    validator = BilingualJekyllResumeTheme::ResumeValidator.new("/nonexistent/data/dir")
    assert_equal 1, validator.validate(quiet: true)
  end

  def test_discovery_skips_non_locale_and_empty_folders
    Dir.mktmpdir("test_discovery_") do |tmp|
      %w[en fr assets].each { |dir| write_minimal_language_dir(tmp, dir) }
      FileUtils.mkdir_p(File.join(tmp, "de"))
      write_minimal_language_dir(tmp, "not-a-language-folder")
      validator = BilingualJekyllResumeTheme::ResumeValidator.new(tmp, primary_locale: "fr")
      assert_equal %w[fr en], validator.discover_languages, "primary locale first, then sorted"
    end
  end

  def test_present_date_api
    validator = BilingualJekyllResumeTheme::ResumeValidator.new(SAMPLE_DATA_DIR)
    assert validator.present_date?("")
    assert validator.present_date?("Present", lang: "en")
    assert validator.present_date?("حتى الآن", lang: "ar")
    refute validator.present_date?(Date.today)
    refute validator.present_date?("2020-01-01", lang: "en")
  end

  # --- 13. bin/validate-resume --------------------------------------------------------------------

  def run_cli(*)
    Open3.capture2e(RbConfig.ruby, File.join(REPO_ROOT, "bin", "validate-resume"), *)
  end

  def test_cli_passes_on_demo_data_and_fails_on_bad_data
    _out, status = run_cli(SAMPLE_DATA_DIR, "--all-locales", "--fail-on-warnings", "--quiet")
    assert status.success?
    Dir.mktmpdir("test_cli_bad_") do |tmp|
      write_yaml(File.join(tmp, "en", "skills.yml"), [{ "active" => true }])
      out, status = run_cli(tmp, "--languages", "en")
      refute status.success?
      assert_includes out, "Missing required field 'skill'"
    end
  end

  def test_cli_fail_on_warnings_and_quiet
    Dir.mktmpdir("test_cli_warn_") do |tmp|
      write_yaml(File.join(tmp, "en", "skills.yml"), [{ "skill" => "Ruby" }]) # missing active flag: a warning
      assert run_cli(tmp, "-l", "en").last.success?, "warnings alone exit 0"
      refute run_cli(tmp, "-l", "en", "-w").last.success?, "--fail-on-warnings exits 1"
    end
    out, = run_cli(SAMPLE_DATA_DIR, "-q")
    assert_empty out, "--quiet prints nothing on a clean run"
  end

  def test_cli_help
    out, status = run_cli("--help")
    assert status.success?
    assert_includes out, "Usage: validate-resume"
  end
end
