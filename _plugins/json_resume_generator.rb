# frozen_string_literal: true

require_relative "../lib/jekyll-theme-resume/json_ld_builder"
require_relative "../lib/jekyll-theme-resume/json_resume_exporter"
require_relative "../lib/jekyll-theme-resume/resume_validator"

module JekyllThemeResume
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

  # Publishes each language's JSON Resume export as /<lang>/resume.json and the matching JSON-LD
  # script and Person @id to site.json_ld_pages[lang] (read by _includes/json-ld-resume.html).
  # Each language is exported at most once per build, so export warnings are not repeated.
  class JsonResumeGenerator < Jekyll::Generator
    safe true
    priority :lowest

    def generate(site)
      site.config["json_resume_routes"] = {}
      site.config["json_ld_pages"] = {}
      languages = site.config["languages"]
      return unless languages.is_a?(Hash)

      documents = Hash.new { |cache, lang| cache[lang] = JsonResumeExporter.export(site, lang) }
      publish_json_resume(site, languages, documents)
      publish_json_ld(site, languages, documents)
    end

    private

    def publish_json_resume(site, languages, documents)
      options = site.config["json_resume"].is_a?(Hash) ? site.config["json_resume"] : {}
      return if options["enabled"] == false

      selected_languages(languages, options).each do |lang|
        unless ResumeValidator::LANG_KEY_REGEX.match?(lang.to_s)
          Jekyll.logger.warn "JSON Resume:", "invalid language route; skipping export"
          next
        end
        route = "/#{lang}/resume.json"
        next if collision?(site, route)

        document = documents[lang]
        next unless document

        site.pages << JsonResumePage.new(site, route, document)
        site.config["json_resume_routes"][lang] = route
        publish_root_export(site, lang, document, options)
      end
    end

    def publish_root_export(site, lang, document, options)
      return unless lang == (site.config["default_lang"] || "en") && options["root_export"] != false
      return if collision?(site, "/resume.json")

      site.pages << JsonResumePage.new(site, "/resume.json", document)
    end

    def publish_json_ld(site, languages, documents)
      options = site.config["json_ld"].is_a?(Hash) ? site.config["json_ld"] : {}
      return if options["enabled"] == false

      languages.each_key do |lang|
        next unless ResumeValidator::LANG_KEY_REGEX.match?(lang.to_s) && documents[lang]

        graph = JsonLdBuilder.build(documents[lang], lang)
        site.config["json_ld_pages"][lang] = { "script" => JsonLdBuilder.script(graph),
                                               "person_id" => graph.dig("mainEntity", "@id") }
      end
    end

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
