# frozen_string_literal: true

require "minitest/autorun"

require "fileutils"
require "tmpdir"
require "yaml"
require "open3"
require_relative "../lib/jekyll-theme-resume/template_key_checker"

# Covers TemplateKeyChecker: the Liquid variable-to-section binding resolution (direct
# for-loops, assign/filter chains, the grouped-item-list.html include boundary, the
# group_by filter's synthetic {name, items} wrapper), and an integration run against the
# theme's real templates + demo data.
class TemplateKeyCheckerTest < Minitest::Test
  REPO_ROOT = File.expand_path("..", __dir__)
  SAMPLE_DATA_DIR = File.join(REPO_ROOT, "demo", "_data")

  # --- Helpers -----------------------------------------------------------------------------

  def write_yaml(path, data)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, YAML.dump(data))
  end

  def write_template(template_root, relative_path, content)
    path = File.join(template_root, relative_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  # Minimal single-language fixture: one section file (experience.yml) with one
  # entry, and a _config.yml declaring that language with data_path "en".
  def build_fixture
    Dir.mktmpdir("test_template_key_checker_data_") do |data_dir|
      Dir.mktmpdir("test_template_key_checker_templates_") do |template_root|
        write_yaml(File.join(data_dir, "en", "experience.yml"), [
                     { "company" => "Acme", "position" => "Engineer", "startdate" => "2020-01",
                       "durations" => [{ "duration" => "2 years" }], "active" => true }
                   ])
        write_yaml(File.join(data_dir, "_config.yml"), "languages" => { "en" => { "data_path" => "en" } })
        yield data_dir, template_root
      end
    end
  end

  def checker_for(data_dir, template_root)
    JekyllThemeResume::TemplateKeyChecker.new(data_dir, template_root: template_root)
  end

  # --- 1. A direct for-loop typo is caught ---------------------------------------------------

  def test_direct_for_loop_typo_is_caught
    build_fixture do |data_dir, template_root|
      write_template(template_root, "_layouts/resume.html", <<~LIQUID)
        {% for item in resume_data.experience %}{{ item.psotion }}{% endfor %}
      LIQUID

      checker = checker_for(data_dir, template_root)
      checker.check(quiet: true)

      assert checker.warnings.any? { |w| w[:message].include?("item.psotion") },
             "a typo'd field must be flagged: #{checker.warnings}"
    end
  end

  # --- 2. A real field on the same direct for-loop is never flagged --------------------------

  def test_direct_for_loop_valid_field_is_not_flagged
    build_fixture do |data_dir, template_root|
      write_template(template_root, "_layouts/resume.html", <<~LIQUID)
        {% for item in resume_data.experience %}{{ item.position }} {{ item.company }}{% endfor %}
      LIQUID

      checker = checker_for(data_dir, template_root)
      checker.check(quiet: true)

      assert_empty checker.warnings
    end
  end

  # --- 3. Nested keys (e.g. durations: [{duration}]) are recognized, not just top-level -----

  def test_nested_array_key_is_recognized
    build_fixture do |data_dir, template_root|
      write_template(template_root, "_layouts/resume.html", <<~LIQUID)
        {% for item in resume_data.experience %}
          {% for time in item.durations %}{{ time.duration }}{% endfor %}
        {% endfor %}
      LIQUID

      checker = checker_for(data_dir, template_root)
      checker.check(quiet: true)

      assert_empty checker.warnings, "a nested array's own keys must be known, not just top-level entry fields"
    end
  end

  # --- 4. The grouped-item-list.html include boundary resolves correctly ---------------------

  def test_include_parameter_boundary_is_resolved
    build_fixture do |data_dir, template_root|
      write_template(template_root, "_includes/resume-section.html", <<~LIQUID)
        {% include grouped-item-list.html items=resume_data.experience %}
      LIQUID
      write_template(template_root, "_includes/grouped-item-list.html", <<~LIQUID)
        {% assign active_entries = include.items | where: "active", true %}
        {% for role in active_entries %}{{ role.position }}{% endfor %}
      LIQUID

      checker = checker_for(data_dir, template_root)
      checker.check(quiet: true)

      assert_empty checker.warnings, "a valid field reached through include.items must not warn: #{checker.warnings}"
    end
  end

  def test_include_parameter_boundary_still_catches_a_typo
    build_fixture do |data_dir, template_root|
      write_template(template_root, "_includes/resume-section.html", <<~LIQUID)
        {% include grouped-item-list.html items=resume_data.experience %}
      LIQUID
      write_template(template_root, "_includes/grouped-item-list.html", <<~LIQUID)
        {% assign active_entries = include.items | where: "active", true %}
        {% for role in active_entries %}{{ role.psotion }}{% endfor %}
      LIQUID

      checker = checker_for(data_dir, template_root)
      checker.check(quiet: true)

      assert checker.warnings.any? { |w| w[:message].include?("role.psotion") },
             "a typo reached through include.items must still be flagged: #{checker.warnings}"
    end
  end

  # --- 5. group_by's synthetic {name, items} wrapper fields are never flagged ----------------

  def test_group_by_wrapper_fields_are_never_flagged
    build_fixture do |data_dir, template_root|
      write_template(template_root, "_layouts/resume.html", <<~LIQUID)
        {% assign groups = resume_data.experience | group_by: "company" %}
        {% for group in groups %}{{ group.name }}{% for role in group.items %}{{ role.position }}{% endfor %}{% endfor %}
      LIQUID

      checker = checker_for(data_dir, template_root)
      checker.check(quiet: true)

      assert_empty checker.warnings, "group_by's own {name, items} shape must never be flagged: #{checker.warnings}"
    end
  end

  # --- 6. Never fails by default, even with warnings; --fail-on-warnings opts in -------------

  def test_never_fails_by_default_but_fail_on_warnings_opts_in
    build_fixture do |data_dir, template_root|
      write_template(template_root, "_layouts/resume.html", <<~LIQUID)
        {% for item in resume_data.experience %}{{ item.psotion }}{% endfor %}
      LIQUID

      checker = checker_for(data_dir, template_root)
      assert_equal 0, checker.check(quiet: true)

      checker = checker_for(data_dir, template_root)
      assert_equal 1, checker.check(quiet: true, fail_on_warnings: true)
    end
  end

  # --- 7. Integration: the theme's real templates against its real demo data -----------------

  def test_real_theme_templates_against_real_demo_data_runs_clean_of_builtin_false_positives
    checker = JekyllThemeResume::TemplateKeyChecker.new(SAMPLE_DATA_DIR)
    checker.check(quiet: true)

    # Regression guard for the group_by/Array-accessor false positives this class is
    # documented to exclude (LIQUID_BUILTIN_FIELDS) — never `.name`/`.items`/`.size`/etc.
    refute(checker.warnings.any? { |w| w[:message] =~ /`[\w.]+\.(name|items|size|first|last|length)`/ },
           "a Liquid/Array builtin field must never be flagged: #{checker.warnings}")
  end

  # --- 8. bin/check-data-keys ------------------------------------------------------------------

  def test_cli_is_advisory_on_real_templates_and_prints_help
    out, status = Open3.capture2e(RbConfig.ruby, File.join(REPO_ROOT, "bin", "check-data-keys"), SAMPLE_DATA_DIR, "--quiet")
    assert status.success?, out
    help, = Open3.capture2e(RbConfig.ruby, File.join(REPO_ROOT, "bin", "check-data-keys"), "--help")
    assert_includes help, "Usage: check-data-keys"
  end

  def test_missing_data_directory_warns_and_fails_only_with_fail_on_warnings
    checker = JekyllThemeResume::TemplateKeyChecker.new("/nonexistent/dir")
    capture_io { assert_equal 0, checker.check(quiet: true) }
    capture_io { assert_equal 1, checker.check(quiet: true, fail_on_warnings: true) }
  end
end
