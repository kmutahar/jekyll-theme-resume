# frozen_string_literal: true

require "yaml"
require "date"

module JekyllThemeResume
  # Statically checks the theme's own _layouts/_includes Liquid templates for
  # `.field` accesses on resume-data-bound variables that don't correspond to any
  # real key found in the target data directory's YAML — catching typos (e.g.
  # `item.discription`) that would otherwise silently render blank.
  #
  # Templates never write literal `site.data.foo.bar`: every section is reached
  # through a `resume_data` variable set indirectly by `_includes/data-loader.html`
  # (Liquid bracket notation, since dotted/hyphenated `data_path` segments break
  # literal dot syntax). This checker traces `resume_data.<section>` bindings
  # through `for`/`assign`/include-parameter chains instead of matching
  # `site.data.foo.bar` directly, which does not appear anywhere in this theme's
  # real templates. This includes the `grouped-item-list.html` include boundary
  # (`experience`/`volunteering` are passed in as `items=resume_data.<section>`)
  # and Liquid's `group_by` filter's synthetic `{name, items}` wrapper shape.
  #
  # Known keys are derived from the target data directory's actual YAML content
  # (recursively, so nested arrays like `durations: [{duration}]` count), unioned
  # across every discovered language — the same data-driven approach as the
  # original site-repo script this class replaces. This means a field a template
  # references but that happens not to appear anywhere in the checked sample data
  # (e.g. an optional field no demo language currently exercises) will warn even
  # though the template code is correct — see `bin/check-data-keys`'s and the
  # Rake/CI wiring's deliberate choice not to default to `--fail-on-warnings` for
  # this reason.
  class TemplateKeyChecker
    COLORS = {
      yellow: "\e[33m",
      cyan: "\e[36m",
      green: "\e[32m",
      bold: "\e[1m",
      reset: "\e[0m"
    }.freeze

    THEME_ROOT = File.expand_path("../..", __dir__)

    LOCALE_DIR_REGEX = /\A[a-z]{2,3}(?:[-_][a-zA-Z0-9]{2,4})?\z/i

    EXCLUDED_LOCALE_DIRS = %w[
      locales sample samples archive archives rawdata data assets images img css js
    ].freeze

    TAG_REGEX = /\{%-?\s*(.*?)\s*-?%\}/m
    OUTPUT_REGEX = /\{\{-?\s*(.*?)\s*-?\}\}/m

    # Field names produced by Liquid/Array machinery rather than resume data: the
    # `group_by` filter's synthetic `{name, items}` wrapper, and common
    # Array/Enumerable accessors templates call on a filtered collection (e.g.
    # `active_languages.size`). Checked before the known-keys lookup, so these are
    # never flagged regardless of the schema's real keys.
    # ponytail: a hardcoded list, not a general Liquid-builtin denylist — widen this
    # if another filter's synthetic shape starts producing warnings.
    LIQUID_BUILTIN_FIELDS = %w[name items size first last length].freeze

    attr_reader :data_dir, :warnings

    # template_root: overrides where _layouts/_includes are scanned from (default:
    # this gem's own root). Exists so tests can point the Liquid-tracing logic at
    # synthetic fixture templates instead of the theme's real ones.
    def initialize(data_dir = "_data", config_path: nil, config: nil, template_root: THEME_ROOT)
      @data_dir = data_dir.to_s.chomp("/")
      @config_path = config_path
      @config = config
      @template_root = template_root
      @warnings = []
      @use_color = $stdout.tty? && ENV["NO_COLOR"].nil?
      @lang_dirs = {}
    end

    # Runs the check. Returns 0 unless fail_on_warnings is true and warnings were
    # found — this checker only ever produces warnings, never hard errors, matching
    # the original script's "advisory only" design.
    def check(verbose: false, quiet: false, fail_on_warnings: false)
      @verbose = verbose
      @quiet = quiet
      @warnings.clear

      log_info("🔍 Checking theme templates against data keys in '#{@data_dir}'...")

      languages = load_language_config
      languages = discover_languages if languages.empty?

      if languages.empty?
        add_warning("Discovery", "No language directories found in '#{@data_dir}'.")
        report_results
        return fail_on_warnings ? 1 : 0
      end

      log_info("🌐 Languages: #{languages.map { |l| "#{l} (#{lang_dir(l)})" }.join(', ')}")

      known_keys = collect_known_keys(languages)
      run_checks(theme_template_files, known_keys)

      report_results unless @quiet && @warnings.empty?
      fail_on_warnings && @warnings.any? ? 1 : 0
    end

    # Auto-discovers language directories in data_dir matching BCP-47 / ISO
    # patterns while filtering out non-locale directories. Public, like
    # ResumeValidator#discover_languages, so bin/check-data-keys can use it for
    # default data-dir detection without reaching into a private method.
    def discover_languages
      return [] unless Dir.exist?(@data_dir)

      Dir.children(@data_dir).select do |entry|
        full = File.join(@data_dir, entry)
        File.directory?(full) &&
          entry =~ LOCALE_DIR_REGEX &&
          !EXCLUDED_LOCALE_DIRS.include?(entry.downcase) &&
          Dir.glob(File.join(full, "*.{yml,yaml}")).any?
      end.sort
    end

    private

    def theme_template_files
      Dir.glob(File.join(@template_root, "_layouts", "*.html")) +
        Dir.glob(File.join(@template_root, "_includes", "**", "*.html"))
    end

    # `for`/`assign`/`include` are always `{% %}` logic tags, so binding resolution only
    # needs those. `.field` ACCESSES appear in both `{% if x.field %}` conditions and
    # `{{ x.field }}` output/attribute interpolation, so the check pass needs both kinds.
    def run_checks(template_files, known_keys)
      logic_bodies_by_file = template_files.to_h do |file|
        [File.basename(file), File.read(file, encoding: "UTF-8").scan(TAG_REGEX).flatten]
      end
      all_bodies_by_file = template_files.to_h do |file|
        content = File.read(file, encoding: "UTF-8")
        [File.basename(file), content.scan(TAG_REGEX).flatten + content.scan(OUTPUT_REGEX).flatten]
      end

      include_param_bindings = build_include_param_bindings(logic_bodies_by_file)

      template_files.each do |file|
        basename = File.basename(file)
        vars = resolve_local_bindings(logic_bodies_by_file[basename], include_param_bindings[basename] || {})
        check_field_accesses(all_bodies_by_file[basename], vars, known_keys, file)
      end
    end

    # --- Language / data discovery (mirrors ResumeValidator's data_path-driven
    # convention in lib/jekyll-theme-resume/resume_validator.rb;
    # duplicated rather than reaching into its private methods — that class
    # validates YAML schema/dates/URLs/locale parity, this one checks a different
    # concern (template code correctness), so the two stay separate, small classes
    # rather than one growing to cover both) ---

    def lang_dir(lang)
      @lang_dirs[lang] || File.join(@data_dir, lang)
    end

    def load_language_config
      @lang_dirs = {}
      config = @config || load_site_config
      return [] unless config.is_a?(Hash) && config["languages"].is_a?(Hash)

      config["languages"].filter_map do |lang, lang_cfg|
        lang = lang.to_s
        data_path = lang_cfg["data_path"] if lang_cfg.is_a?(Hash)
        next if data_path.nil?

        @lang_dirs[lang] = File.join(@data_dir, *data_path.to_s.split("."))
        lang
      end
    end

    def load_site_config
      cfg_file = [
        @config_path,
        File.join(@data_dir, "_config.yml"),
        File.join(@data_dir, "_config.sample.yml"),
        File.join(@data_dir, "..", "_config.yml"),
        File.join(@data_dir, "..", "_config.sample.yml")
      ].compact.find { |f| File.file?(f) }
      return nil unless cfg_file

      log_info("⚙️  Using config '#{cfg_file}'")
      YAML.safe_load_file(cfg_file, permitted_classes: [Date, Time])
    rescue Psych::SyntaxError, ArgumentError
      nil
    end

    # --- Known-key collection: every hash key appearing anywhere (any nesting
    # depth — e.g. `durations: [{duration}]`, `awards: [{award}]`) in a section's
    # YAML, unioned across every discovered language. Recursion matters: templates
    # access `time.duration`/`award.award` from nested arrays, not just top-level
    # entry fields. ---

    def collect_known_keys(languages)
      known = Hash.new { |h, k| h[k] = Set.new }
      languages.each do |lang|
        dir = lang_dir(lang)
        next unless Dir.exist?(dir)

        Dir.glob(File.join(dir, "*.{yml,yaml}")).each do |file|
          section = File.basename(file, ".*")
          begin
            data = YAML.safe_load_file(file, permitted_classes: [Date, Time])
            collect_keys(data, known[section])
          rescue Psych::SyntaxError
            next
          end
        end
      end
      known
    end

    def collect_keys(value, keys)
      case value
      when Hash
        value.each do |k, v|
          keys << k.to_s
          collect_keys(v, keys)
        end
      when Array
        value.each { |v| collect_keys(v, keys) }
      end
      keys
    end

    # --- Liquid variable-to-section binding resolution ---

    # Global pass: for every `{% include target.html param=resume_data.section %}`
    # anywhere in the corpus, records which section(s) each parameter of `target`
    # can represent — bridges the include boundary before any file's local pass
    # runs (`grouped-item-list.html`'s `include.items`, bound from
    # `resume-section.html`'s two call sites for `experience` and `volunteering`).
    def build_include_param_bindings(tag_bodies_by_file)
      bindings = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = Set.new } }
      tag_bodies_by_file.each_value do |bodies|
        bodies.each do |body|
          next unless body =~ %r{\Ainclude\s+([\w\-./]+\.html)\b(.*)\z}m

          target = ::Regexp.last_match(1)
          rest = ::Regexp.last_match(2)
          rest.scan(/(\w+)\s*=\s*resume_data\.(\w+)/) { |param, section| bindings[target][param] << section }
        end
      end
      bindings
    end

    # Per-file pass: resolves `for`/`assign` chains to a variable -> section-set
    # map, seeded with this file's include-parameter bindings (keyed as
    # "include.<param>" so an `include.items` reference resolves directly).
    def resolve_local_bindings(bodies, seed)
      vars = Hash.new { |h, k| h[k] = Set.new }
      seed.each { |param, sections| vars["include.#{param}"].merge(sections) }

      bodies.each do |body|
        match = body.match(/\Afor\s+(\w+)\s+in\s+(.+)\z/m) || body.match(/\Aassign\s+(\w+)\s*=\s*(.+)\z/m)
        next unless match

        vars[match[1]].merge(resolve_expr_sections(match[2], vars))
      end

      vars
    end

    # Section(s) an expression resolves to: any direct `resume_data.<section>`
    # reference, plus whatever the expression's leading variable is already bound
    # to — so filter chains like `| where: ... | group_by: ...` propagate the
    # binding through unchanged (the filter's output *shape* changes, which
    # LIQUID_BUILTIN_FIELDS accounts for separately at the field-check step; its
    # section attribution doesn't).
    def resolve_expr_sections(expr, vars)
      sections = Set.new
      expr.scan(/resume_data\.(\w+)/) { |m| sections << m[0] }

      base = expr[/\A(include\.\w+|\w+)/, 1]
      sections.merge(vars[base]) if base && vars.key?(base)

      sections
    end

    # --- Field-access checking ---

    def check_field_accesses(bodies, vars, known_keys, file)
      bound_vars = vars.reject { |_, sections| sections.empty? }
      return if bound_vars.empty?

      var_pattern = Regexp.union(bound_vars.keys.sort_by { |k| -k.length })
      bodies.each do |body|
        body.scan(/(#{var_pattern})\.([a-zA-Z_][a-zA-Z0-9_]*)/) do |var, field|
          next if LIQUID_BUILTIN_FIELDS.include?(field)

          valid_fields = bound_vars[var].flat_map { |section| known_keys[section].to_a }
          next if valid_fields.include?(field)

          add_warning(File.basename(file),
                      "references `#{var}.#{field}` (#{bound_vars[var].to_a.join('/')}) but no such key was " \
                      "found in the checked data")
        end
      end
    end

    # --- Reporting (duplicated from ResumeValidator's small private reporting
    # helpers — both classes are genuinely small and cover a different concern;
    # extract a shared module if a third consumer of either ever appears) ---

    def color(code_key, text)
      return text unless @use_color

      "#{COLORS[code_key]}#{text}#{COLORS[:reset]}"
    end

    def log_info(msg)
      puts msg unless @quiet
    end

    def add_warning(context, msg)
      @warnings << { context: context, message: msg }
    end

    def report_results
      puts "\n"
      if @warnings.empty?
        puts color(:green, "✓ TEMPLATE KEY CHECK: no unresolved template key references found.")
        return
      end

      puts color(:yellow, "╔═══════════════════════════════════════════════════════════════╗")
      puts color(:yellow, "║#{"TEMPLATE KEY WARNINGS (#{@warnings.size.to_s.rjust(2)})".center(63)}║")
      puts color(:yellow, "╚═══════════════════════════════════════════════════════════════╝")
      @warnings.each do |finding|
        puts "  #{color(:yellow, '⚠')} #{color(:bold, finding[:context])}"
        puts "    → #{finding[:message]}\n"
      end
      puts color(:cyan, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
      puts color(:yellow, "⚠ #{@warnings.size} potential template key issue(s) found.")
      puts color(:cyan, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    end
  end
end
