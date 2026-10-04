# frozen_string_literal: true

require_relative "../lib/jekyll-theme-resume/resume_validator"

module JekyllThemeResume
  # Jekyll Generator that validates resume YAML data during Jekyll build (on by default).
  #
  # _config.yml switches:
  #   validate_resume: false        # Opt out of validation entirely
  #   validate_resume_strict: true  # Abort the build on validation errors
  class ResumeValidatorGenerator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      return if site.config["validate_resume"] == false

      data_dir = site.config["data_dir"] || "_data"
      full_data_path = site.in_source_dir(data_dir)

      # Check if the data directory or language subdirectories exist
      unless Dir.exist?(full_data_path)
        Jekyll.logger.warn("ResumeValidator:", "Configured data directory '#{full_data_path}' not found. Skipping.")
        return
      end

      # Hand over the already-parsed config so languages come from `languages:` without re-reading disk.
      validator = ResumeValidator.new(full_data_path, config: site.config)
      strict = site.config["validate_resume_strict"] == true
      fail_warnings = site.config["validate_resume_fail_on_warnings"] == true
      validator.validate(fail_on_warnings: fail_warnings)

      return unless strict && (validator.errors.any? || (fail_warnings && validator.warnings.any?))

      msg = "Resume validation failed with #{validator.errors.size} error(s)"
      msg += " and #{validator.warnings.size} warning(s)" if fail_warnings
      raise Jekyll::Errors::FatalException, "#{msg} in strict mode."
    end
  end
end
