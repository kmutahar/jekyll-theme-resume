# frozen_string_literal: true

require_relative "../lib/bilingual-jekyll-resume-theme/json_resume_exporter"
require_relative "../lib/bilingual-jekyll-resume-theme/resume_validator"

module BilingualJekyllResumeTheme
  class JsonResumePage < Jekyll::PageWithoutAFile
    def initialize(site, route, document)
      super(site, site.source, File.dirname(route).delete_prefix("/"), "resume.json")
      self.content = "#{JSON.pretty_generate(document)}\n"
      data.merge!("layout" => nil, "permalink" => route, "sitemap" => false)
    end

    # Jekyll::Site uses Renderer directly, not Page#render.
    def render_with_liquid?
      false
    end

    def place_in_layout?
      false
    end
  end

  class JsonResumeGenerator < Jekyll::Generator
    safe true
    priority :lowest

    def generate(site)
      site.config["json_resume_routes"] = {}
      options = site.config["json_resume"].is_a?(Hash) ? site.config["json_resume"] : {}
      languages = site.config["languages"]
      return if options["enabled"] == false || !languages.is_a?(Hash)

      selected_languages(languages, options).each do |lang|
        unless ResumeValidator::LANG_KEY_REGEX.match?(lang.to_s)
          Jekyll.logger.warn "JSON Resume:", "invalid language route; skipping export"
          next
        end
        route = "/#{lang}/resume.json"
        next if collision?(site, route)

        document = JsonResumeExporter.export(site, lang)
        next unless document

        site.pages << JsonResumePage.new(site, route, document)
        site.config["json_resume_routes"][lang] = route
        next unless lang == (site.config["default_lang"] || "en") && options["root_export"] != false
        next if collision?(site, "/resume.json")

        site.pages << JsonResumePage.new(site, "/resume.json", document)
      end
    end

    private

    def selected_languages(languages, options)
      requested = options["languages"]
      return languages.keys if requested.nil? || requested == []

      unless requested.is_a?(Array)
        Jekyll.logger.warn "JSON Resume:", "languages must be an array; skipping exports"
        return []
      end
      requested.uniq.select do |lang|
        known = languages.key?(lang)
        Jekyll.logger.warn "JSON Resume:", "unknown export language '#{lang}'; ignored" unless known
        known
      end
    end

    def collision?(site, route)
      target = File.expand_path(route.delete_prefix("/"), site.dest)
      resources = site.pages + site.static_files + site.collections.values.flat_map(&:docs)
      occupied = resources.any? { |item| File.expand_path(item.destination(site.dest)) == target }
      Jekyll.logger.warn "JSON Resume:", "#{route}: destination occupied; keeping existing resource" if occupied
      occupied
    end
  end
end
