# frozen_string_literal: true

require "yaml"
require "uri"
require "date"

module BilingualJekyllResumeTheme
  # Validates resume YAML data against expected schemas, checks section-file parity
  # across every configured language, and provides colorized diagnostics.
  #
  # Languages come from the site's `languages:` config (each resolved through its
  # `data_path`), falling back to a directory scan when no config is found. Locale
  # data (present values, display names) comes from the theme's
  # `_data/locales/<lang>.yml` with the site's `<data_dir>/locales/<lang>.yml`
  # deep-merged over it, the same way Jekyll layers theme and site data.
  class ResumeValidator
    COLORS = {
      red: "\e[31m",
      green: "\e[32m",
      yellow: "\e[33m",
      blue: "\e[34m",
      cyan: "\e[36m",
      bold: "\e[1m",
      reset: "\e[0m"
    }.freeze

    THEME_LOCALES_DIR = File.expand_path("../../_data/locales", __dir__)

    EXCLUDED_LOCALE_DIRS = %w[
      locales sample samples archive archives rawdata data assets images img css js
    ].freeze

    # The one allowed shape for a language key. Keys are joined into file paths and globs, so
    # anything else (`../x`, `a/b`, `*`) is rejected before it reaches the filesystem.
    LANG_KEY_REGEX = /\A[a-zA-Z0-9_-]+\z/

    # Tracking IDs are emitted into inline scripts and URLs; only these shapes are accepted.
    # gtag covers G-, AW- and similar measurement IDs.
    ANALYTICS_ID_REGEXES = { "gtm" => /\AGTM-[A-Z0-9]+\z/, "gtag" => /\A[A-Za-z0-9-]+\z/ }.freeze

    # Allowed URL schemes per config setting; _includes/safe-url.html applies the same rule.
    # Other social_links keys use SOCIAL_LINK_SCHEMES.
    CONFIG_URL_SCHEMES = {
      "avatar_url" => %w[http https], "avatar_link" => %w[http https mailto tel]
    }.freeze
    SOCIAL_LINK_SCHEMES = %w[http https].freeze
    SOCIAL_EMAIL_SCHEMES = %w[mailto].freeze

    LOCALE_DIR_REGEX = /\A[a-z]{2,3}(?:[-_][a-zA-Z0-9]{2,4})?\z/i

    # Only these three ISO shapes are accepted by validate_date; parse_date_safely's
    # Date.parse fallback for other shapes is deliberately not reachable from there.
    STRICT_ISO_DATE_REGEX = /\A\d{4}(-\d{2}(-\d{2})?)?\z/

    attr_reader :data_dir, :errors, :warnings, :info, :primary_locale

    # config: an already-parsed Jekyll site config Hash (the Jekyll plugin passes
    # site.config). When nil, the config is looked up on disk (config_path first).
    def initialize(data_dir = "_data", config_path: nil, config: nil, primary_locale: "en")
      @data_dir = data_dir.to_s.chomp("/")
      @config_path = config_path
      @config = config
      @primary_locale = (primary_locale || "en").to_s
      @errors = []
      @warnings = []
      @info = []
      @use_color = $stdout.tty? && ENV["NO_COLOR"].nil?
      @locales = {}
      @lang_dirs = {}
    end

    # Runs validation across configured languages.
    # Returns 0 on success, 1 on error (or on warnings if fail_on_warnings is true).
    def validate(languages: nil, all_locales: false, primary_locale: nil, verbose: false, quiet: false, fail_on_warnings: false)
      @primary_locale = primary_locale.to_s if primary_locale
      @verbose = verbose
      @quiet = quiet
      @errors.clear
      @warnings.clear
      @info.clear
      @locales = {}

      log_info("🔍 Validating resume data in '#{@data_dir}'...")

      unless Dir.exist?(@data_dir)
        add_error(@data_dir, "Data directory '#{@data_dir}' does not exist.")
        report_results
        return 1
      end

      config_languages = load_language_config
      explicit = valid_language_keys(Array(languages).map(&:to_s))
      declared = explicit.empty? ? config_languages : explicit

      target_languages = resolve_target_languages(explicit, config_languages, all_locales)
      target_languages -= report_misconfigured_languages(declared)
      log_info("🌐 Languages: #{target_languages.map { |l| "#{l} (#{lang_dir(l)})" }.join(', ')}")

      add_warning("Discovery", "No language directories found in '#{@data_dir}'.") if target_languages.empty?

      validate_locale_parity(target_languages)
      validate_language_parity(target_languages)
      target_languages.each { |lang| validate_language_files(lang) }

      report_results unless @quiet && @errors.empty? && @warnings.empty?

      if @errors.any? || (fail_on_warnings && @warnings.any?)
        1
      else
        0
      end
    end

    # Auto-discovers language directories in data_dir matching BCP-47 / ISO patterns
    # while filtering out non-locale directories.
    def discover_languages
      return [] unless Dir.exist?(@data_dir)

      subdirs = Dir.children(@data_dir).select do |entry|
        full = File.join(@data_dir, entry)
        File.directory?(full) &&
          entry =~ LOCALE_DIR_REGEX &&
          !EXCLUDED_LOCALE_DIRS.include?(entry.downcase) &&
          Dir.glob(File.join(full, "*.{yml,yaml}")).any?
      end

      if subdirs.include?(@primary_locale)
        [@primary_locale] + (subdirs - [@primary_locale]).sort
      else
        subdirs.sort
      end
    end

    # Effective locale for a language: the theme's _data/locales/<lang>.yml with the
    # site's <data_dir>/locales/<lang>.yml deep-merged over it. A site-only locale is
    # used as-is. Returns nil when neither file exists. Cached per validate() run.
    def locale_for(lang)
      lang = lang.to_s.strip.downcase
      return @locales[lang] if @locales.key?(lang)

      theme = read_locale_file(THEME_LOCALES_DIR, lang)
      site = read_locale_file(File.join(@data_dir, "locales"), lang)
      @locales[lang] = theme && site ? deep_merge(theme, site) : (site || theme)
    end

    # Returns the "Present" date values the theme accepts for a language: the merged
    # locale's `present_values` plus its `ui.present` label. Mirrors
    # _includes/date-formatter.html, including its fallback to the default language's
    # locale when the language has none. A nil/empty lang returns every locale's values.
    def present_aliases_for(lang = nil)
      langs = lang.to_s.strip.empty? ? known_locale_languages : [lang]
      langs.flat_map do |l|
        locale = locale_for(l) || locale_for(@default_lang || @primary_locale)
        locale_present_values(locale)
      end.uniq
    end

    # Determines whether a date value represents a "Present" or ongoing role.
    def present_date?(date_val, lang: nil)
      return false if date_val.nil? || date_val.is_a?(Date) || date_val.is_a?(Time)

      str = date_val.to_s.strip
      return true if str.empty?

      aliases = present_aliases_for(lang)
      str_down = str.downcase

      aliases.any? { |a| a.to_s.strip.downcase == str_down || a.to_s.strip == str }
    end

    private

    def color(code_key, text)
      return text unless @use_color

      "#{COLORS[code_key]}#{text}#{COLORS[:reset]}"
    end

    def log_info(msg)
      puts msg unless @quiet
    end

    # Explicit --languages wins; otherwise the config's `languages:` block; otherwise a
    # directory scan. --all-locales unions the directory scan on top of either list.
    def resolve_target_languages(explicit, config_languages, all_locales)
      base = if explicit.any? then explicit
             elsif config_languages.any? then config_languages
             else discover_languages
             end
      all_locales ? (base + discover_languages).uniq : base
    end

    # A declared language (from --languages or the `languages:` config) with no data
    # folder or no locale is a misconfiguration, not a parity gap: report it as an error
    # and return the languages without a folder so parity does not double-report them.
    def report_misconfigured_languages(declared)
      declared.each do |lang|
        next if locale_for(lang)

        add_error(lang, "No locale found for '#{lang}': expected #{File.join(THEME_LOCALES_DIR, "#{lang}.yml")} " \
                        "or #{File.join(@data_dir, 'locales', "#{lang}.yml")}.")
      end

      declared.reject { |lang| Dir.exist?(lang_dir(lang)) }.each do |lang|
        add_error(lang, "Data directory '#{lang_dir(lang)}' for language '#{lang}' does not exist.")
      end
    end

    # Data folder for a language: its configured data_path (dot-separated, like
    # _includes/data-loader.html) or, for undeclared languages, <data_dir>/<lang>.
    def lang_dir(lang)
      @lang_dirs[lang] || File.join(@data_dir, lang)
    end

    # Loads the site config and records each declared language's data folder in
    # @lang_dirs. Returns the declared language codes ([] when there is no config).
    def load_language_config
      @lang_dirs = {}
      @default_lang = nil
      config = @config || load_site_config
      return [] unless config.is_a?(Hash)

      @default_lang = config["default_lang"]&.to_s
      validate_analytics_ids(config["analytics"])
      validate_config_urls(config)
      return [] unless config["languages"].is_a?(Hash)

      # A language without data_path is reported once here and left out of the run.
      config["languages"].filter_map do |lang, lang_cfg|
        lang = lang.to_s
        next if valid_language_keys([lang]).empty?

        data_path = lang_cfg["data_path"] if lang_cfg.is_a?(Hash)
        if data_path.nil?
          add_error("Config", "languages.#{lang} has no 'data_path' (use \"\" for the data root).")
          next
        end

        @lang_dirs[lang] = File.join(@data_dir, *data_path.to_s.split("."))
        lang
      end
    end

    # A value with ":" must start with an allowed scheme; one without is a relative path (or a
    # bare email address) and is allowed. Mirrors _includes/safe-url.html.
    def safe_url?(value, schemes)
      text = value.to_s.strip
      !text.include?(":") || schemes.include?(text.split(":").first.downcase)
    end

    def validate_config_urls(config)
      checks = CONFIG_URL_SCHEMES.map { |key, schemes| [key, config[key], schemes] }
      social = config["social_links"].is_a?(Hash) ? config["social_links"] : {}
      social.each do |key, value|
        checks << ["social_links.#{key}", value, key.to_s == "email" ? SOCIAL_EMAIL_SCHEMES : SOCIAL_LINK_SCHEMES]
      end
      checks.each do |name, value, schemes|
        next if value.nil? || value == false || safe_url?(value, schemes)

        add_error("Config", "#{name} #{value.to_s.inspect} must be a relative path or use #{schemes.join('/')}.")
      end
    end

    def validate_analytics_ids(analytics)
      return unless analytics.is_a?(Hash)

      ANALYTICS_ID_REGEXES.each do |key, regex|
        value = analytics[key]
        next if value.nil? || value.to_s.empty? || regex.match?(value.to_s)

        add_error("Config", "analytics.#{key} #{value.to_s.inspect} is not a valid ID (expected #{regex.source}).")
      end
    end

    # Reports every key that is not a plain language code and returns the rest.
    def valid_language_keys(keys)
      keys.select do |key|
        next true if LANG_KEY_REGEX.match?(key)

        add_error("Config", "Invalid language key #{key.inspect}: use only letters, digits, '-' and '_'.")
        false
      end
    end

    # First Jekyll config found: explicit config_path, then data-dir neighbours.
    # An explicit config_path that is missing, or any config that fails to parse, is an error.
    def load_site_config
      if @config_path && !File.file?(@config_path)
        add_error("Config", "Config file '#{@config_path}' does not exist.")
        return nil
      end

      cfg_file = [
        @config_path,
        File.join(@data_dir, "_config.yml"),
        File.join(@data_dir, "_config.sample.yml"),
        File.join(@data_dir, "..", "_config.yml"),
        File.join(@data_dir, "..", "_config.sample.yml")
      ].compact.find { |f| File.file?(f) }
      return nil unless cfg_file

      log_info("⚙️  Using config '#{cfg_file}'")
      load_yaml_file(cfg_file)
    rescue Psych::SyntaxError => e
      add_error(cfg_file, "YAML Syntax Error: line #{e.line}, col #{e.column}: #{e.problem}")
      nil
    rescue Psych::Exception => e
      add_error(cfg_file, "Unsupported YAML (aliases and custom classes are not allowed): #{e.message}")
      nil
    end

    def read_locale_file(dir, lang)
      path = Dir.glob(File.join(dir, "#{lang}.{yml,yaml}")).first
      return nil unless path

      data = load_yaml_file(path)
      return data if data.is_a?(Hash)

      add_error(path, "Locale file must be a Hash/dictionary, got #{data.class}.")
      nil
    rescue Psych::SyntaxError => e
      add_error(path, "YAML Syntax Error: line #{e.line}, col #{e.column}: #{e.problem}")
      nil
    rescue Psych::Exception => e
      add_error(path, "Unsupported YAML (aliases and custom classes are not allowed): #{e.message}")
      nil
    end

    # Hashes merge key by key; everything else (arrays included) is replaced whole.
    def deep_merge(base, override)
      base.merge(override) do |_key, old, new|
        old.is_a?(Hash) && new.is_a?(Hash) ? deep_merge(old, new) : new
      end
    end

    def known_locale_languages
      [THEME_LOCALES_DIR, File.join(@data_dir, "locales")]
        .flat_map { |dir| Dir.glob(File.join(dir, "*.{yml,yaml}")) }
        .map { |f| File.basename(f, ".*").downcase }
        .uniq
    end

    def locale_present_values(locale)
      return [] unless locale

      values = Array(locale["present_values"]).map(&:to_s)
      values << locale["ui"]["present"].to_s if locale["ui"].is_a?(Hash) && locale["ui"]["present"]
      values
    end

    # Warns when a language's merged locale (theme + site override) is missing keys the
    # reference locale has. Runs on the merged locale, never the raw site file, so a
    # one-line site override warns on nothing; only a genuinely incomplete locale does.
    def validate_locale_parity(languages)
      reference = [@primary_locale, @default_lang, *languages].compact.find { |l| locale_for(l) }
      return unless reference

      reference_keys = flatten_keys(locale_for(reference))

      languages.each do |lang|
        next if lang == reference

        locale = locale_for(lang)
        next unless locale

        missing = (reference_keys - flatten_keys(locale)).to_a.sort
        next if missing.empty?

        add_warning("Locale #{lang}", "Missing key(s) vs. '#{reference}' locale: #{missing.join(', ')}")
      end
    end

    # Flattens a locale Hash into dotted key paths (e.g. "ui.section_titles.experience").
    # Only Hash values are descended into; arrays and scalars are leaves.
    def flatten_keys(hash, prefix = "")
      hash.each_with_object(Set.new) do |(key, val), keys|
        path = prefix.empty? ? key.to_s : "#{prefix}.#{key}"
        val.is_a?(Hash) ? keys.merge(flatten_keys(val, path)) : (keys << path)
      end
    end

    # Checks parity of section files across all languages using a hub-and-spoke model.
    def validate_language_parity(languages)
      return unless languages.size > 1

      dir_files = collect_language_files(languages)

      # Designate primary hub locale
      primary = if dir_files.key?(@primary_locale)
                  @primary_locale
                else
                  languages.find { |l| dir_files.key?(l) } || languages.first
                end

      languages.reject { |l| l == primary }.each do |secondary|
        next unless dir_files.key?(secondary)

        report_parity_gaps(primary, dir_files[primary] || [], secondary, dir_files[secondary])
      end
    end

    # Maps each existing language directory to its section file names.
    def collect_language_files(languages)
      languages.each_with_object({}) do |lang, dir_files|
        lang_path = lang_dir(lang)
        unless Dir.exist?(lang_path)
          add_warning("Parity", "Language directory '#{lang_path}' does not exist.")
          next
        end

        names = Dir.glob(File.join(lang_path, "*.{yml,yaml}")).map { |f| File.basename(f) }
        dir_files[lang] = names.sort
      end
    end

    def report_parity_gaps(primary, primary_files, secondary, sec_files)
      primary_dir = lang_dir(primary)
      secondary_dir = lang_dir(secondary)

      (primary_files - sec_files).each do |f|
        add_warning("Parity", "Missing #{language_display_name(secondary)} counterpart: " \
                              "#{File.join(secondary_dir, f)} (exists in #{primary_dir}/)")
      end

      (sec_files - primary_files).each do |f|
        add_warning("Parity", "Missing #{language_display_name(primary)} counterpart: " \
                              "#{File.join(primary_dir, f)} (exists in #{secondary_dir}/)")
      end
    end

    # Native display name from the merged locale's ui.language_name, else the raw code.
    def language_display_name(lang)
      ui = locale_for(lang)&.fetch("ui", nil)
      (ui["language_name"] if ui.is_a?(Hash)) || lang.to_s
    end

    def validate_language_files(lang)
      dir = lang_dir(lang)
      return unless Dir.exist?(dir)

      files = Dir.glob(File.join(dir, "*.{yml,yaml}"))
      add_warning(lang, "No YAML data files found in '#{dir}'.") if files.empty?

      files.each do |file_path|
        filename = File.basename(file_path)
        section_name = File.basename(file_path, ".*")

        begin
          data = load_yaml_file(file_path)
          validate_section(section_name, data, lang, file_path)
        rescue Psych::SyntaxError => e
          add_error("#{lang}/#{filename}", "YAML Syntax Error: line #{e.line}, col #{e.column}: #{e.problem}")
        rescue Psych::Exception => e
          add_error("#{lang}/#{filename}", "Unsupported YAML (aliases and custom classes are not allowed): #{e.message}")
        rescue StandardError => e
          add_error("#{lang}/#{filename}", "Error loading YAML: #{e.message}")
        end
      end
    end

    def load_yaml_file(file_path)
      YAML.load_file(file_path, permitted_classes: [Date, Time])
    end

    def validate_section(section_name, data, lang, file_path)
      filename = File.basename(file_path)
      context = "#{lang}/#{filename}"

      if data.nil?
        add_warning(context, "File is empty or contains only comments.")
        return
      end

      if section_name == "header"
        validate_header(data, context)
        return
      end

      unless data.is_a?(Array)
        add_error(context, "Expected a list/array of items, but found #{data.class}.")
        return
      end

      data.each_with_index do |entry, idx|
        item_context = "#{context} [Item ##{idx + 1}]"
        validate_item_entry(section_name, entry, item_context, lang: lang)
      end
    end

    # Flat section-name dispatcher: one branch per section is clearer than a lookup table here.
    def validate_item_entry(section_name, entry, item_context, lang: nil) # rubocop:disable Metrics/CyclomaticComplexity
      unless entry.is_a?(Hash)
        add_error(item_context, "Item must be a Hash/dictionary, got #{entry.class}.")
        return
      end

      # 1. Active flag check (applies across all standard sections except interests)
      validate_active_flag(entry, item_context) unless section_name == "interests"

      # Inactive entries (drafts or archived records) are not rendered by the theme
      return if entry["active"] == false

      validate_export_fields(section_name, entry, item_context, lang: lang)

      # 2. Section-specific schema validations
      case section_name
      when "experience"
        validate_experience_entry(entry, item_context, lang: lang)
      when "education"
        validate_education_entry(entry, item_context, lang: lang)
      when "certifications"
        validate_certification_entry(entry, item_context, lang: lang)
      when "courses"
        validate_course_entry(entry, item_context, lang: lang)
      when "volunteering"
        validate_volunteering_entry(entry, item_context, lang: lang)
      when "projects"
        validate_project_entry(entry, item_context)
      when "skills"
        validate_skill_entry(entry, item_context)
      when "recognitions"
        validate_recognition_entry(entry, item_context)
      when "associations"
        validate_association_entry(entry, item_context)
      when "languages"
        validate_language_entry(entry, item_context)
      when "links"
        validate_link_entry(entry, item_context)
      when "publications"
        validate_publication_entry(entry, item_context)
      when "references"
        validate_reference_entry(entry, item_context)
      when "interests"
        validate_interest_entry(entry, item_context)
      end
    end

    # Optional JSON Resume enrichment never replaces the HTML-facing keys.
    def validate_export_fields(section, entry, context, lang:)
      list_fields = {
        "experience" => %w[highlights], "volunteering" => %w[highlights], "education" => %w[courses],
        "skills" => %w[keywords], "interests" => %w[keywords], "projects" => %w[roles highlights keywords]
      }
      Array(list_fields[section]).each do |field|
        next unless entry.key?(field)
        next if entry[field].is_a?(Array) && entry[field].all?(String)

        add_warning(context, "Optional '#{field}' must be an array of strings; invalid export values will be omitted.")
      end
      if section == "skills" && entry.key?("level_label") && !entry["level_label"].is_a?(String)
        add_warning(context, "Optional 'level_label' must be a string.")
      end
      validate_url(entry["url"], context, "url") if %w[experience volunteering education publications].include?(section) && entry["url"]
      if section == "projects"
        validate_date(entry["startdate"], context, "startdate")
        validate_date_or_present(entry["enddate"], context, "enddate", lang: lang)
        validate_date_range(entry["startdate"], entry["enddate"], context, lang: lang) if entry["startdate"] && entry["enddate"]
      end
      validate_date(entry["date"], context, "date") if section == "recognitions"
      validate_date(entry["release_date"], context, "release_date") if section == "publications"
    end

    def validate_active_flag(entry, context)
      return unless entry.is_a?(Hash)

      if entry["active"].nil?
        add_warning(context, "Missing 'active' boolean flag (recommended: active: true/false)")
      elsif entry["active"] != true && entry["active"] != false
        add_warning(context, "'active' flag should be a boolean (true or false), got #{entry['active'].inspect}")
      end
    end

    def validate_header(data, context)
      unless data.is_a?(Hash)
        add_error(context, "header.yml must be a Hash/dictionary, got #{data.class}.")
        return
      end

      intro = data["intro"] || data["about"]
      if intro.nil? || intro.to_s.strip.empty?
        add_warning(context, "Header 'intro' bio summary is missing.")
      elsif intro.to_s.strip.length < 20
        add_warning(context, "Header 'intro' bio is very brief (< 20 characters).")
      end
    end

    def validate_experience_entry(entry, context, lang: nil)
      require_field(entry, context, "company", %w[organization])
      require_field(entry, context, "position", %w[role])

      has_dates = false
      if entry["durations"].is_a?(Array) && entry["durations"].any?
        has_dates = true
        entry["durations"].each_with_index do |dur, d_idx|
          if dur.is_a?(Hash) && dur["duration"].to_s.strip.empty?
            add_warning(context, "Durations item ##{d_idx + 1} has empty 'duration' string.")
          end
        end
      end

      if entry["startdate"]
        has_dates = true
        validate_date(entry["startdate"], context, "startdate")
      end

      if entry["enddate"]
        has_dates = true
        validate_date_or_present(entry["enddate"], context, "enddate", lang: lang)
        validate_date_range(entry["startdate"], entry["enddate"], context, lang: lang)
      end

      add_warning(context, "Role has no 'startdate' or 'durations' specified.") unless has_dates
    end

    def validate_education_entry(entry, context, lang: nil)
      require_field(entry, context, "uni", %w[institution school], "institution/university")
      require_field(entry, context, "degree")

      # data-schemas.md documents education.yml with a freeform `year` string (not
      # startdate/enddate) as the displayed date range; require it be present since
      # nothing else here validates that education entries have a date at all.
      add_error(context, "Missing required field 'year'") if entry["year"].to_s.strip.empty? && !entry["startdate"]

      validate_date(entry["startdate"], context, "startdate") if entry["startdate"]
      validate_date_or_present(entry["enddate"], context, "enddate", lang: lang) if entry["enddate"]
      validate_date_range(entry["startdate"], entry["enddate"], context, lang: lang) if entry["startdate"] && entry["enddate"]
    end

    def validate_certification_entry(entry, context, lang: nil)
      require_field(entry, context, "name", %w[title])

      validate_date(entry["issue_date"], context, "issue_date") if entry["issue_date"]
      validate_date(entry["expiration"], context, "expiration") if entry["expiration"]
      validate_date_range(entry["issue_date"], entry["expiration"], context, lang: lang) if entry["issue_date"] && entry["expiration"]

      validate_url(entry["credential_url"], context, "credential_url") if entry["credential_url"]
    end

    def validate_course_entry(entry, context, lang: nil)
      require_field(entry, context, "name", %w[title course])

      validate_date(entry["startdate"], context, "startdate") if entry["startdate"]
      validate_date(entry["enddate"], context, "enddate") if entry["enddate"]
      validate_date_range(entry["startdate"], entry["enddate"], context, lang: lang) if entry["startdate"] && entry["enddate"]

      validate_url(entry["credential_url"], context, "credential_url") if entry["credential_url"]
    end

    def validate_volunteering_entry(entry, context, lang: nil)
      require_field(entry, context, "company", %w[organization], "organization name")
      require_field(entry, context, "position", %w[role])

      validate_date(entry["startdate"], context, "startdate") if entry["startdate"]
      validate_date_or_present(entry["enddate"], context, "enddate", lang: lang) if entry["enddate"]
      validate_date_range(entry["startdate"], entry["enddate"], context, lang: lang) if entry["startdate"] && entry["enddate"]
    end

    def validate_project_entry(entry, context)
      require_field(entry, context, "project", %w[title name])

      validate_url(entry["url"], context, "url") if entry["url"]
    end

    def validate_skill_entry(entry, context)
      require_field(entry, context, "skill", %w[category name])

      return unless entry["level"]

      lvl = entry["level"].to_i
      return if (1..5).cover?(lvl)

      add_warning(context, "Skill 'level' (#{entry['level']}) should be an integer between 1 and 5.")
    end

    def validate_recognition_entry(entry, context)
      require_field(entry, context, "award", %w[title recognition])
    end

    def validate_association_entry(entry, context)
      require_field(entry, context, "organization", %w[company name])

      validate_url(entry["url"], context, "url") if entry["url"]
    end

    def validate_language_entry(entry, context)
      require_field(entry, context, "language", %w[name])
    end

    def validate_link_entry(entry, context)
      require_field(entry, context, "description", %w[name title])

      if entry["url"].to_s.strip.empty?
        add_error(context, "Missing required field 'url'")
      else
        validate_url(entry["url"], context, "url")
      end
    end

    def validate_publication_entry(entry, context)
      require_field(entry, context, "name", %w[title])
    end

    def validate_reference_entry(entry, context)
      require_field(entry, context, "name")
      require_field(entry, context, "reference", %w[quote text])
    end

    def validate_interest_entry(entry, context)
      return unless entry["description"].to_s.strip.empty?

      found = %w[interest name].find { |key| !entry[key].to_s.strip.empty? }
      add_warning(context, "Missing 'description' string#{alias_hint(found, 'description')}")
    end

    # The templates render only the canonical key, so an entry that sets just an alias
    # (e.g. `organization` instead of `company`) would validate yet render blank.
    def require_field(entry, context, field, aliases = [], label = nil)
      return unless entry[field].to_s.strip.empty?

      found = aliases.find { |key| !entry[key].to_s.strip.empty? }
      add_error(context, "Missing required field '#{field}'#{" (#{label})" if label}#{alias_hint(found, field)}")
    end

    def alias_hint(found, field)
      found ? ": found '#{found}', but the theme only renders '#{field}'" : ""
    end

    # Helper: Validates date syntax against ISO 8601 (YYYY-MM-DD, YYYY-MM, or YYYY).
    # Delegates the actual calendar-validity check to parse_date_safely so the
    # Date.iso8601/strptime/new logic exists in one place.
    def validate_date(date_val, context, field_name)
      return if date_val.nil?
      return if date_val.is_a?(Date) || date_val.is_a?(Time)

      str = date_val.to_s.strip
      return if str.empty?
      return if STRICT_ISO_DATE_REGEX.match?(str) && parse_date_safely(str)

      add_error(context, "Invalid date format for '#{field_name}': '#{date_val}' (expected ISO YYYY-MM-DD, YYYY-MM, or YYYY)")
    end

    # Helper: Validates date or localized 'Present' alias
    def validate_date_or_present(date_val, context, field_name, lang: nil)
      return if date_val.nil?

      str = date_val.to_s.strip
      return if str.empty? || present_date?(date_val, lang: lang)

      validate_date(date_val, context, field_name)
    end

    # Helper: Ensures end date >= start date (handling localized 'Present' aliases and partial dates)
    def validate_date_range(start_val, end_val, context, lang: nil)
      return if start_val.nil? || end_val.nil?

      s_str = start_val.to_s.strip
      e_str = end_val.to_s.strip
      return if s_str.empty? || e_str.empty? || present_date?(end_val, lang: lang)

      s_date = parse_date_safely(start_val)
      e_date = parse_date_safely(end_val, end_of_period: true)

      return unless s_date && e_date && e_date < s_date

      add_error(context, "Date range error: end date (#{e_date}) is before start date (#{s_date}).")
    end

    # Parses ISO dates, partial dates (YYYY-MM, YYYY), Date/Time objects, and strings safely into Date objects.
    # When end_of_period is true, partial dates resolve to the end of that period (last day of month / year).
    def parse_date_safely(val, end_of_period: false)
      return val if val.is_a?(Date)
      return val.to_date if val.is_a?(Time)
      return nil if val.nil?

      str = val.to_s.strip
      return nil if str.empty?

      case str
      when /^\d{4}-\d{2}-\d{2}$/
        Date.iso8601(str)
      when /^(\d{4})-(\d{2})$/
        year = ::Regexp.last_match(1).to_i
        month = ::Regexp.last_match(2).to_i
        if end_of_period
          Date.new(year, month, -1)
        else
          Date.new(year, month, 1)
        end
      when /^(\d{4})$/
        year = ::Regexp.last_match(1).to_i
        if end_of_period
          Date.new(year, 12, 31)
        else
          Date.new(year, 1, 1)
        end
      else
        Date.parse(str)
      end
    rescue StandardError
      nil
    end

    # Helper: Validates HTTP / HTTPS URL syntax. Non-http(s) schemes (javascript:, data:, ...)
    # are rejected outright: resume-section.html renders these fields into raw href attributes
    # with no escaping, and there is no legitimate reason a resume link needs another scheme.
    def validate_url(url_val, context, field_name)
      return if url_val.nil? || url_val.to_s.strip.empty?

      uri = URI.parse(url_val.to_s.strip)
      unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
        add_error(context, "#{field_name} '#{url_val}' must begin with http:// or https://")
      end
    rescue URI::InvalidURIError
      add_error(context, "Invalid URL format for '#{field_name}': '#{url_val}'")
    end

    def add_error(context, msg)
      @errors << { context: context, message: msg }
    end

    def add_warning(context, msg)
      @warnings << { context: context, message: msg }
    end

    def report_results
      puts "\n"
      print_findings(@errors, :red, "✗", "VALIDATION ERRORS")
      print_findings(@warnings, :yellow, "⚠", "VALIDATION WARNINGS")

      puts color(:cyan, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
      if @errors.empty?
        status = @warnings.empty? ? "clean, 0 warnings" : "#{@warnings.size} warning(s)"
        puts color(:green, "✓ VALIDATION SUCCESSFUL: All resume data files are valid! (#{status})")
      else
        puts color(:red, "✗ VALIDATION FAILED: #{@errors.size} error(s), #{@warnings.size} warning(s)")
      end
      puts color(:cyan, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    end

    # Prints a boxed banner followed by one "<icon> context / → message" pair per finding.
    def print_findings(findings, tone, icon, title)
      return if findings.empty?

      puts color(tone, "╔═══════════════════════════════════════════════════════════════╗")
      puts color(tone, "║#{"#{title} (#{findings.size.to_s.rjust(2)})".center(63)}║")
      puts color(tone, "╚═══════════════════════════════════════════════════════════════╝")
      findings.each do |finding|
        puts "  #{color(tone, icon)} #{color(:bold, finding[:context])}"
        puts "    → #{finding[:message]}\n"
      end
    end
  end
end
