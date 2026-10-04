# frozen_string_literal: true

require_relative "../lib/jekyll-theme-resume/resume_validator"

module JekyllThemeResume
  # Synthesizes a CV (layout: resume) and profile (layout: profile) page for every
  # languages.<lang> entry in _config.yml that doesn't already have a hand-authored one,
  # the same way ErrorPagesGenerator synthesizes 404/403/500 pages (see
  # error_pages_generator.rb). t_id matches the documented convention (t_id: resume /
  # t_id: profile) so hreflang.html and language-switcher.html match generated and
  # hand-authored pages identically.
  class ResumePagesGenerator < Jekyll::Generator
    safe true
    # priority :low: run after physical pages are parsed, so collision checks are accurate.
    priority :low

    def generate(site)
      languages = site.config["languages"]
      return unless languages.is_a?(Hash)

      default_lang = site.config["default_lang"] || "en"

      languages.each do |lang, lang_cfg|
        unless ResumeValidator::LANG_KEY_REGEX.match?(lang.to_s)
          Jekyll.logger.warn "ResumePagesGenerator:",
                             "skipping language #{lang.to_s.inspect}: keys may only use letters, digits, '-' and '_'."
          next
        end

        lang_cfg ||= {}
        synthesize_or_warn(site, "resume", lang, lang_cfg["url"], lang_cfg)

        profile_url = lang == default_lang ? "/" : "/#{lang}/"
        synthesize_or_warn(site, "profile", lang, profile_url, lang_cfg)
      end
    end

    private

    def synthesize_or_warn(site, layout, lang, permalink, lang_cfg)
      return if existing_page?(site, layout, lang, permalink)

      unless permalink && auto_generate?(site, lang_cfg)
        Jekyll.logger.warn "ResumePagesGenerator:",
                           "no #{layout} page for language '#{lang}' - auto-generation is " \
                           "disabled or languages.#{lang}.url is missing, and no " \
                           "hand-authored page exists. This language will not be built."
        return
      end

      page = Jekyll::PageWithoutAFile.new(site, site.source, "", "#{layout}-#{lang}.html")
      page.content = ""
      page.data["layout"] = layout
      page.data["lang"] = lang
      page.data["t_id"] = layout
      page.data["permalink"] = permalink
      site.pages << page
    end

    def existing_page?(site, layout, lang, permalink)
      site.pages.any? { |p| p.data["layout"] == layout && p.data["lang"] == lang } ||
        (permalink && site.pages.any? { |p| p.url == permalink })
    end

    def auto_generate?(site, lang_cfg)
      return lang_cfg["auto_generate_pages"] unless lang_cfg["auto_generate_pages"].nil?

      site.config["resume_auto_generate_pages"] != false
    end
  end
end
