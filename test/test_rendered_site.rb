# frozen_string_literal: true

require "minitest/autorun"
require "jekyll"
require "jekyll-seo-tag"
require "nokogiri"
require "fileutils"
require "tmpdir"
require "yaml"
require "open3"
require "json"

# End-user behavior: builds one Jekyll site from the theme's real _layouts/_includes/_sass/_data
# plus fixture resume data, then asserts on the generated HTML a visitor actually receives.
class RenderedSiteTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  SECTIONS = %w[experience education certifications courses volunteering projects skills recognitions
                associations interests languages links publications references].freeze

  # Formats fed straight into _includes/date-formatter.html, keyed by probe id.
  DATE_PROBES = {
    "full" => "2020-02-15", "month" => "2020-02", "year" => "2018", "int_year" => 2018,
    "date_obj" => Date.new(2020, 2, 15), "present" => "Present", "free_text" => "Summer 2019"
  }.freeze

  # One entry per rendering rule; `hidden` markers must never reach the HTML (active: false).
  def self.resume_data(tag)
    {
      "header" => { "intro" => "#{tag} intro paragraph for the fixture resume." },
      "experience" => [
        { "company" => "Acme", "position" => "#{tag} Lead", "startdate" => "2021-03-01", "enddate" => "Present",
          "location" => "London", "summary" => "#{tag} lead summary", "active" => true },
        { "company" => "Acme", "position" => "#{tag} Junior", "startdate" => "2019-01-01", "enddate" => "2021-02-01",
          "active" => true },
        { "company" => "Globex", "position" => "#{tag} Advisor",
          "durations" => [{ "duration" => "2015 &ndash; 2016" }, { "duration" => "&amp; 2018" }], "active" => true },
        { "company" => "Initech", "position" => "#{tag} Open-ended", "startdate" => "2022-05-01", "active" => true },
        { "company" => "Solo", "position" => "#{tag} Dateless", "active" => true },
        { "company" => "Hidden Corp", "position" => "hidden-experience", "startdate" => "2010-01-01", "active" => false }
      ],
      "education" => [
        { "uni" => "#{tag} University", "degree" => "BSc", "year" => "2010 &ndash; 2014", "location" => "Paris",
          "award" => "#{tag} single award", "awards" => [{ "award" => "#{tag} list award" }],
          "summary" => "#{tag} education summary", "active" => true },
        { "uni" => "Solo U", "degree" => "MSc", "active" => true },
        { "uni" => "hidden-education", "degree" => "PhD", "year" => "2020", "active" => false }
      ],
      "certifications" => [
        { "name" => "#{tag} Cert", "issuing_organization" => "Issuer", "issue_date" => "2020-02-15",
          "expiration" => "2023-02-15", "credential_id" => "CRED-1", "credential_url" => "https://example.org/cred",
          "active" => true },
        { "name" => "#{tag} Plain Cert", "credential_id" => "PLAIN-2", "active" => true },
        { "name" => "hidden-certification", "active" => false }
      ],
      "courses" => [
        { "name" => "#{tag} Course", "issuing_organization" => "School", "startdate" => "2019-01-10",
          "enddate" => "2019-03-20", "summary" => "#{tag} course summary", "credential_id" => "COURSE-1",
          "credential_url" => "https://example.org/course", "active" => true },
        { "name" => "hidden-course", "active" => false }
      ],
      "volunteering" => [
        { "company" => "Charity", "position" => "#{tag} Helper", "startdate" => "2017-06-01", "active" => true },
        { "company" => "Hidden Charity", "position" => "hidden-volunteering", "active" => false }
      ],
      "projects" => [
        { "project" => "#{tag} Tool", "url" => "https://example.org/tool", "role" => "Author", "duration" => "2020",
          "description" => "#{tag} project description", "active" => true },
        { "project" => "#{tag} Offline", "description" => "No link", "active" => true },
        { "project" => "hidden-project", "active" => false }
      ],
      "skills" => [
        { "skill" => "#{tag} Ruby", "description" => "#{tag} skill description", "active" => true },
        { "skill" => "#{tag} Bare Skill", "active" => true },
        { "skill" => "hidden-skill", "active" => false }
      ],
      "recognitions" => [
        { "award" => "#{tag} Prize", "organization" => "Society", "year" => "2021", "summary" => "#{tag} prize summary",
          "active" => true },
        { "award" => "#{tag} Bare Prize", "active" => true },
        { "award" => "hidden-recognition", "active" => false }
      ],
      "associations" => [
        { "organization" => "#{tag} Club", "url" => "https://example.org/club", "role" => "Member", "year" => "2019",
          "summary" => "#{tag} club summary", "active" => true },
        { "organization" => "#{tag} Bare Club", "active" => true },
        { "organization" => "hidden-association", "active" => false }
      ],
      "interests" => [{ "description" => "#{tag} Chess" }, { "description" => "#{tag} Hiking" }],
      "languages" => [
        { "language" => "#{tag} English", "description" => "Native", "descrp_short" => "N", "active" => true },
        { "language" => "#{tag} French", "description" => "Fluent", "descrp_short" => "F", "active" => true },
        { "language" => "#{tag} German", "description" => "Basic", "descrp_short" => "B", "active" => true },
        { "language" => "hidden-language", "description" => "None", "active" => false }
      ],
      "links" => [
        { "description" => "#{tag} Blog", "url" => "https://example.org/blog", "active" => true },
        { "description" => "hidden-link", "url" => "https://example.org/hidden", "active" => false }
      ],
      "publications" => [
        { "name" => "#{tag} Paper", "publisher" => "Journal", "release_date" => "1889-03", "url" => "https://example.org/paper",
          "summary" => "#{tag} paper summary", "active" => true },
        { "name" => "#{tag} Bare Paper", "release_date" => 1912, "active" => true },
        { "name" => "hidden-publication", "active" => false }
      ],
      "references" => [
        { "name" => "#{tag} Referee", "reference" => "#{tag} glowing words", "active" => true },
        { "name" => "hidden-reference", "reference" => "secret", "active" => false }
      ]
    }
  end

  class << self
    # One build per distinct config override set; the plain fixture is `fixture({})`.
    def fixture(overrides = {})
      (@fixtures ||= {})[overrides] ||= build(overrides)
    end

    def write(path, content)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, content)
    end

    def page(front_matter, body = "")
      "#{YAML.dump(front_matter)}---\n#{body}"
    end

    def base_config
      {
        "title" => "Fixture Site", "url" => "https://example.org", "baseurl" => "",
        "plugins" => ["jekyll-seo-tag"], "validate_resume" => false, "default_lang" => "en",
        "languages" => {
          "en" => { "data_path" => "en", "url" => "/en/cv/", "name" => "Jane Doe", "resume_title" => "Engineer",
                    "address" => "1 Road, London", "header_intro" => true, "avatar_alt" => "Portrait of Jane",
                    "about" => "English **about** text." },
          "ar" => { "data_path" => "ar", "url" => "/ar/cv/", "name" => "جين دو", "resume_title" => "مهندسة",
                    "address" => "لندن", "header_intro" => true }
        },
        "resume_section" => SECTIONS.to_h { |section| [section, true] },
        "resume_section_order" => SECTIONS,
        "display_header_contact_info" => true, "enable_summary" => true, "enable_live" => false,
        "resume_avatar" => true, "avatar_url" => "/assets/images/me.jpg",
        "resume_looking_for_work" => true, "resume_print_social_links" => true,
        "contact_info" => { "email" => "jane@example.org", "phone" => "+44 (20) 1234-5678", "dob" => "1990-04-12" },
        "social_links" => { "email" => "jane@example.org", "github" => "https://github.com/jane",
                            "linkedin" => "https://linkedin.com/in/jane" }
      }
    end

    # Deep-merges a patch (e.g. {"ui" => {...}}) into the fixture copy of the en locale file.
    def patch_en_locale(source, patch)
      file = File.join(source, "_data", "locales", "en.yml")
      merged = YAML.load_file(file).merge(patch) { |_key, old, new| old.is_a?(Hash) ? old.merge(new) : new }
      File.write(file, YAML.dump(merged))
    end

    # `_en_locale` in overrides is a test-only patch for the en locale, not a Jekyll config key.
    def build(overrides)
      overrides = overrides.dup
      en_locale_patch = overrides.delete("_en_locale")
      source = Dir.mktmpdir("rendered_site_src_")
      dest = Dir.mktmpdir("rendered_site_dest_")
      Minitest.after_run { [source, dest].each { |dir| FileUtils.rm_rf(dir) } }

      %w[_includes _layouts _sass _data assets].each { |dir| FileUtils.cp_r(File.join(ROOT, dir), source) }
      patch_en_locale(source, en_locale_patch) if en_locale_patch
      { "en" => "EN", "ar" => "AR" }.each do |lang, tag|
        resume_data(tag).each { |section, data| write(File.join(source, "_data", lang, "#{section}.yml"), YAML.dump(data)) }
        write(File.join(source, "cv-#{lang}.html"),
              page("layout" => "resume", "lang" => lang, "permalink" => "/#{lang}/cv/", "t_id" => "resume"))
        profile_url = lang == "en" ? "/" : "/#{lang}/"
        write(File.join(source, "profile-#{lang}.html"),
              page("layout" => "profile", "lang" => lang, "permalink" => profile_url, "t_id" => "profile"))

        probes = DATE_PROBES.keys.flat_map do |id|
          [%(<p id="#{id}">{% include date-formatter.html date=page.probes.#{id} %}</p>),
           %(<p id="mdy_#{id}">{% include date-formatter.html date=page.probes.#{id} style="MDY" %}</p>)]
        end
        write(File.join(source, "dates-#{lang}.html"), page({ "lang" => lang, "permalink" => "/dates/#{lang}/" }, probes.join("\n")))
      end
      write(File.join(source, "404.html"), page("layout" => "error", "code" => "404", "permalink" => "/404.html"))
      write(File.join(source, "500.html"), page("layout" => "error", "code" => 500, "permalink" => "/500.html"))
      write(File.join(source, "weird-lang.html"),
            page("layout" => "profile", "lang" => %(x"onload="alert(1)), "t_id" => "weird", "permalink" => "/weird/"))
      write(File.join(source, "about.md"), page({ "layout" => "default", "lang" => "ar", "permalink" => "/about/" }, "Hello **there**"))

      config = Jekyll.configuration(base_config.merge(overrides).merge("source" => source, "destination" => dest, "quiet" => true))
      site = Jekyll::Site.new(config)
      site.read
      site.pages.each { |item| item.data["probes"] = DATE_PROBES if item.name.start_with?("dates-") }
      site.generate
      site.render
      site.write
      { site: site, dest: dest }
    end
  end

  def html(path, overrides = {})
    file = File.join(self.class.fixture(overrides)[:dest], path)
    assert File.exist?(file), "expected #{path} to be built"
    Nokogiri::HTML(File.read(file))
  end

  def cv(lang = "en", overrides = {})
    html("#{lang}/cv/index.html", overrides)
  end

  def section(heading, lang = "en")
    node = cv(lang).css("section.content-section").find { |sec| sec.at_css("h2")&.text&.strip == heading }
    refute_nil node, "expected a '#{heading}' section on the #{lang} CV"
    node
  end

  def squish(node)
    node.text.gsub(/[[:space:]]+/, " ").strip
  end

  def locale(lang)
    YAML.safe_load_file(File.join(ROOT, "_data", "locales", "#{lang}.yml"))
  end

  def date(lang, id)
    html("dates/#{lang}/index.html").at_css("##{id}").text.strip
  end

  # --- Date formatter ------------------------------------------------------------------------

  def test_full_iso_date_renders_localized_month_and_year
    assert_equal "February 2020", date("en", "full")
    assert_equal "فبراير 2020", date("ar", "full")
  end

  def test_yaml_date_object_renders_localized_month_and_year
    assert_equal "February 2020", date("en", "date_obj")
  end

  def test_year_month_date_renders_localized_month_and_year
    assert_equal "February 2020", date("en", "month")
    assert_equal "فبراير 2020", date("ar", "month")
  end

  def test_year_only_date_renders_just_the_year
    assert_equal "2018", date("en", "year")
    assert_equal "2018", date("en", "int_year")
  end

  def test_present_marker_renders_locale_present_label
    assert_equal "Present", date("en", "present")
    assert_equal "حتى الآن", date("ar", "present")
  end

  def test_mdy_style_adds_the_day_only_when_the_date_has_one
    assert_equal "February 15, 2020", date("en", "mdy_full")
    assert_equal "February 15, 2020", date("en", "mdy_date_obj")
    assert_equal "February 2020", date("en", "mdy_month")
    assert_equal "2018", date("en", "mdy_year")
  end

  def test_unparseable_text_is_rendered_verbatim
    assert_equal "Summer 2019", date("en", "free_text")
  end

  # --- Resume page shell ---------------------------------------------------------------------

  def test_html_lang_and_direction_come_from_the_locale
    assert_equal %w[en ltr], [cv("en").at_css("html")["lang"], cv("en").at_css("html")["dir"]]
    assert_equal %w[ar rtl], [cv("ar").at_css("html")["lang"], cv("ar").at_css("html")["dir"]]
  end

  def test_direction_stylesheet_matches_the_locale
    assert cv("en").at_css('link[href="/assets/css/cv-ltr.css"]'), "LTR CV must link cv-ltr.css"
    assert cv("ar").at_css('link[href="/assets/css/cv-rtl.css"]'), "RTL CV must link cv-rtl.css"
  end

  def test_locale_font_and_line_height_become_css_variables
    ar_style = cv("ar").at_css("head style").text
    assert_includes ar_style, "--font-locale: #{locale('ar')['font_family']}"
    assert_includes ar_style, "--line-height-locale: #{locale('ar')['line_height']}"
    assert cv("ar").at_css(%(link[href="#{locale('ar')['font_url']}"])), "AR CV must load its locale web font"
    refute_includes cv("en").at_css("head style").text, "--font-locale", "an empty font_family must not emit the variable"
  end

  def test_skip_link_uses_the_locale_string
    assert_equal locale("ar")["ui"]["skip_to_content"], cv("ar").at_css("a.skip-link").text.strip
    assert cv("en").at_css("main#main-content"), "skip link target must exist"
  end

  def test_header_shows_name_title_and_intro_from_language_config_and_data
    doc = cv("ar")
    assert_equal "جين دو", doc.at_css("h1.header-name").text.strip
    assert_equal "مهندسة", doc.at_css("h2.header-title").text.strip
    assert_equal "AR intro paragraph for the fixture resume.", doc.at_css(".executive-summary p").text.strip
  end

  def test_contact_bar_renders_phone_email_address_and_date_of_birth
    bar = cv("en").at_css(".header-contact-info")
    assert_equal "tel:+442012345678", bar.at_css('a[href^="tel:"]')["href"], "tel: link must drop spaces, dashes and parens"
    assert_equal "ltr", bar.at_css('a[href^="tel:"]')["dir"]
    assert_equal "mailto:jane@example.org", bar.at_css('a[href^="mailto:"]')["href"]
    assert_includes squish(bar), "1 Road, London"
    assert_includes squish(bar), "DoB: April 12, 1990"
  end

  def test_looking_for_work_renders_a_localized_mailto_button
    button = cv("ar").at_css("a.contact-button")
    assert_equal "mailto:jane@example.org", button["href"]
    assert_equal locale("ar")["ui"]["contact_me"], button.text.strip
  end

  def test_avatar_uses_configured_url_and_localized_alt_cascade
    assert_equal "/assets/images/me.jpg", cv("en").at_css("img.avatar")["src"]
    assert_equal "Portrait of Jane", cv("en").at_css("img.avatar")["alt"], "avatar_alt wins"
    assert_equal "جين دو", cv("ar").at_css("img.avatar")["alt"], "falls back to the language's name"
    assert_equal "/", cv("en").at_css("a.avatar-link")["href"]
  end

  def test_person_microdata_carries_contact_values
    doc = cv("en")
    assert_equal "+44 (20) 1234-5678", doc.at_css('meta[itemprop="telephone"]')["content"]
    assert_equal "jane@example.org", doc.at_css('meta[itemprop="email"]')["content"]
    assert_equal "1 Road, London", doc.at_css('meta[itemprop="address"]')["content"]
  end

  def test_print_only_footer_links_to_the_canonical_cv_when_live_contacts_are_off
    link = cv("en").at_css("footer.print-only a")
    assert_equal "https://example.org/en/cv/", link["href"]
  end

  def test_cv_page_stores_no_visitor_data
    refute_includes cv.to_html, "preferred-lang", "nothing reads a stored language preference"
  end

  # --- Config switches ------------------------------------------------------------------------

  LIVE = { "enable_live" => true,
           "contact_info" => { "email" => "jane@example.org", "phone" => "111", "email_live" => "live@example.org",
                               "phone_live" => "222" } }.freeze

  def test_enable_live_swaps_in_live_contact_values_everywhere
    doc = cv("en", LIVE)
    assert_equal "tel:222", doc.at_css('.header-contact-info a[href^="tel:"]')["href"]
    assert_equal "mailto:live@example.org", doc.at_css('.header-contact-info a[href^="mailto:"]')["href"]
    assert_equal "222", doc.at_css('meta[itemprop="telephone"]')["content"]
    assert_equal "mailto:live@example.org", doc.at_css("a.contact-button")["href"]
    assert_nil doc.at_css("footer.print-only"), "the print permalink footer is only for enable_live: false"
  end

  def test_enable_live_falls_back_when_a_live_value_is_missing
    doc = cv("en", "enable_live" => true, "contact_info" => { "email" => "jane@example.org", "phone" => "111" })
    assert_equal "tel:111", doc.at_css('.header-contact-info a[href^="tel:"]')["href"]
  end

  def test_contact_bar_can_be_hidden
    assert_nil cv("en", "display_header_contact_info" => false).at_css(".header-contact-info")
  end

  def test_lang_header_moves_languages_into_the_header
    doc = cv("ar", "resume_section" => SECTIONS.to_h { |name| [name, true] }.merge("lang_header" => true))
    line = squish(doc.at_css("p.header-languages"))
    separator = locale("ar")["ui"]["list_separator"].strip
    assert_includes line, "AR English (N)#{separator} AR French (F)"
    refute(doc.css("section h2").any? { |h2| h2.text.strip == locale("ar")["ui"]["section_titles"]["languages"] },
           "the languages section must not render twice")
  end

  def test_not_looking_for_work_shows_a_badge_and_nil_shows_nothing
    badge = cv("en", "resume_looking_for_work" => false).at_css("a.contact-button.not-looking")
    assert_equal locale("en")["ui"]["not_looking_for_work"], badge.text.strip
    assert_nil badge["href"]
    assert_nil cv("en", "resume_looking_for_work" => nil).at_css("a.contact-button")
  end

  def test_avatar_can_be_disabled_unlinked_external_or_open_in_a_new_tab
    assert_nil cv("en", "resume_avatar" => false).at_css("img.avatar")
    unlinked = cv("en", "avatar_link" => false)
    assert unlinked.at_css("img.avatar")
    assert_nil unlinked.at_css("a.avatar-link")
    external = cv("en", "avatar_url" => "https://cdn.example.org/me.jpg", "avatar_link" => "https://example.org",
                        "avatar_link_target" => "_blank")
    assert_equal "https://cdn.example.org/me.jpg", external.at_css("img.avatar")["src"]
    assert_equal(%w[https://example.org _blank noopener], %w[href target rel].map { |attr| external.at_css("a.avatar-link")[attr] })
  end

  def test_avatar_defaults_to_the_bundled_image_and_ui_photo_alt
    doc = cv("en", "avatar_url" => nil, "languages" => { "en" => { "data_path" => "en", "url" => "/en/cv/" } })
    assert_equal "/assets/images/Profile-min.jpg", doc.at_css("img.avatar")["src"]
    assert_equal locale("en")["ui"]["photo_alt"], doc.at_css("img.avatar")["alt"]
  end

  def test_baseurl_prefixes_theme_assets_and_links
    doc = cv("en", "baseurl" => "/cv")
    assert doc.at_css('link[href="/cv/assets/css/cv-ltr.css"]')
    assert_equal "/cv/assets/images/me.jpg", doc.at_css("img.avatar")["src"]
    assert_equal "/cv/assets/favicon/resume/favicon.ico", doc.at_css('link[rel="icon"]')["href"]
    assert_equal "https://example.org/cv/en/cv/", doc.at_css("footer.print-only a")["href"]
  end

  def test_disabled_or_unordered_sections_do_not_render
    toggled = cv("en", "resume_section" => SECTIONS.to_h { |name| [name, name != "skills"] })
    refute(toggled.css("section h2").any? { |h2| h2.text.strip == "Skills" })
    unordered = cv("en", "resume_section_order" => %w[education])
    assert_equal(%w[Education], unordered.css("main section.content-section:not(.print-only) h2").map { |h2| h2.text.strip })
  end

  def test_summaries_hide_when_enable_summary_is_off
    doc = cv("en", "enable_summary" => false)
    refute_includes doc.text, "EN lead summary"
    refute_includes doc.text, "EN course summary"
  end

  def test_google_fonts_can_be_disabled
    refute_includes cv("ar", "disable_google_fonts" => true).css("link").map { |link| link["href"] }.join, "fonts.googleapis.com"
  end

  def test_social_list_is_omitted_without_social_links
    assert_nil cv("en", "social_links" => nil).at_css("ul.social-links")
  end

  def test_gtm_and_gtag_analytics_snippets
    gtm = cv("en", "analytics" => { "gtm" => "GTM-TEST1" })
    assert_includes gtm.css("head script").map(&:text).join, "GTM-TEST1"
    assert_includes gtm.at_css("body noscript iframe")["src"], "id=GTM-TEST1"
    gtag = cv("en", "analytics" => { "gtag" => "G-TEST2" })
    assert gtag.at_css('script[src="https://www.googletagmanager.com/gtag/js?id=G-TEST2"]')
    assert_nil cv.at_css('script[src*="googletagmanager"]'), "no analytics without an ID"
  end

  def test_dark_mode_toggle_renders_only_when_enabled_and_is_localized
    assert_nil cv.at_css("#dark-mode-toggle")
    toggle = cv("ar", "dark_mode" => "enabled").at_css("#dark-mode-toggle")
    assert_equal locale("ar")["ui"]["dark_mode_toggle"], toggle["aria-label"]
    assert_equal "button", toggle["type"]
  end

  # --- Sections ------------------------------------------------------------------------------

  def test_sections_render_in_configured_order_with_locale_titles
    %w[en ar].each do |lang|
      expected = SECTIONS.map { |name| locale(lang)["ui"]["section_titles"][name] }
      headings = cv(lang).css("main section.content-section h2").map { |h2| h2.text.strip }
      assert_equal expected + [locale(lang)["ui"]["social_links"]], headings
    end
  end

  def test_inactive_entries_never_render
    %w[en ar].each do |lang|
      text = cv(lang).at_css("main").text
      SECTIONS.each { |name| refute_includes text, "hidden-#{name.chomp('s')}" }
    end
  end

  def test_experience_groups_roles_by_company_newest_first
    items = section("Experience").css(".resume-item")
    assert_equal(%w[Acme Globex Initech Solo], items.map { |item| item.at_css("h3").text.strip })
    assert_equal(["EN Lead", "EN Junior"], items[0].css("h4").map { |h4| squish(h4).split(" • ").first })
  end

  def test_experience_details_join_position_dates_and_location
    lead = squish(section("Experience").css(".resume-item")[0].css("h4")[0])
    assert_equal "EN Lead • March 2021 – Present • London", lead
  end

  def test_experience_durations_are_printed_verbatim
    assert_equal "EN Advisor • 2015 – 2016 & 2018", squish(section("Experience").css(".resume-item")[1].at_css("h4"))
  end

  def test_experience_missing_enddate_is_ongoing_in_every_locale
    assert_equal "EN Open-ended • May 2022 – Present", squish(section("Experience").css(".resume-item")[2].at_css("h4"))
    ar = squish(section(locale("ar")["ui"]["section_titles"]["experience"], "ar").css(".resume-item")[2].at_css("h4"))
    assert_includes ar, "حتى الآن"
  end

  def test_experience_without_dates_or_location_shows_only_the_position
    assert_equal "EN Dateless", squish(section("Experience").css(".resume-item")[3].at_css("h4"))
  end

  def test_experience_summary_renders_when_enabled
    assert_equal "EN lead summary", section("Experience").at_css(".resume-item-copy").text.strip
  end

  def test_education_renders_degree_year_location_awards_and_summary
    item = section("Education").at_css(".resume-item")
    assert_equal "EN University", item.at_css("h3").text.strip
    assert_equal "BSc • 2010 – 2014 • Paris", squish(item.at_css("h4"))
    assert_equal "EN single award", item.at_css("h5.award-title").text.strip
    assert_equal(["EN list award"], item.css("ul.resume-item-list li").map { |li| li.text.strip })
    assert_equal "EN education summary", item.at_css("p.resume-item-copy").text.strip
  end

  def test_education_with_only_a_degree_has_no_separators
    assert_equal "MSc", squish(section("Education").css(".resume-item")[1].at_css("h4"))
  end

  def test_certification_renders_issuer_date_range_and_linked_credential
    item = section("Licenses & Certifications").css(".resume-item")[0]
    assert_equal "EN Cert", item.at_css("h3").text.strip
    assert_includes squish(item.at_css("h4")), "Issuer • February 15, 2020 – February 15, 2023"
    assert_equal "https://example.org/cred", item.at_css("a")["href"]
    assert_equal "CRED-1", item.at_css("a").text.strip
    assert_includes item.at_css(".print-only-inline").text, "https://example.org/cred"
  end

  def test_certification_without_url_renders_plain_credential_id
    item = section("Licenses & Certifications").css(".resume-item")[1]
    assert_nil item.at_css("a")
    assert_equal "Credential ID: PLAIN-2", squish(item.at_css("h4")), "no separators before the first present field"
  end

  def test_rtl_pages_isolate_credential_ids_and_urls
    ar = section(locale("ar")["ui"]["section_titles"]["certifications"], "ar")
    assert_equal "ltr", ar.at_css("a")["dir"]
    assert_equal "ltr", ar.at_css(".print-only-inline")["dir"]
    assert_nil section("Licenses & Certifications").at_css("a")["dir"], "LTR pages need no dir override"
  end

  def test_course_renders_date_range_summary_and_credential
    item = section("Courses").at_css(".resume-item")
    assert_equal "School • January 10, 2019 – March 20, 2019", squish(item.at_css("h4"))
    assert_equal "EN course summary", item.css("p.resume-item-copy")[0].text.strip
    assert_equal "https://example.org/course", item.at_css("a")["href"]
  end

  def test_volunteering_shares_the_grouped_renderer
    item = section("Volunteering").at_css(".resume-item")
    assert_equal "Charity", item.at_css("h3").text.strip
    assert_equal "EN Helper • June 2017 – Present", squish(item.at_css("h4"))
  end

  def test_projects_link_title_and_print_url_only_when_url_exists
    items = section("Projects").css(".resume-item")
    assert_equal "https://example.org/tool", items[0].at_css("h3 a")["href"]
    assert_equal "Author • 2020", squish(items[0].at_css("h4"))
    assert_includes items[0].at_css(".print-only-inline").text, "https://example.org/tool"
    assert_nil items[1].at_css("h3 a")
    assert_nil items[1].at_css(".print-only-inline")
    assert_nil items[1].at_css("h4"), "no details line without role or duration"
    assert_equal "Jane Doe", items[0].at_css('meta[itemprop="creator"]')["content"]
  end

  def test_skills_render_name_and_optional_description
    items = section("Skills").css(".resume-item")
    assert_equal(["EN Ruby", "EN Bare Skill"], items.map { |item| item.at_css("h4").text.strip })
    assert_equal "EN skill description", items[0].at_css("p").text.strip
    assert_nil items[1].at_css("p")
  end

  def test_recognitions_render_award_organization_year_and_summary
    item = section("Recognition").at_css(".resume-item")
    assert_equal "EN Prize", item.at_css("h3").text.strip
    assert_equal "Society • 2021", squish(item.at_css("h4"))
    assert_equal "EN prize summary", item.at_css("p").text.strip
    assert_nil section("Recognition").css(".resume-item")[1].at_css("h4"), "no details line without organization or year"
  end

  def test_associations_render_linked_organization_role_year_and_summary
    item = section("Associations").at_css(".resume-item")
    assert_equal "https://example.org/club", item.at_css("h3 a")["href"]
    assert_equal "Member • 2019", squish(item.at_css("h4"))
    assert_equal "EN club summary", item.at_css("p").text.strip
    assert_nil section("Associations").css(".resume-item")[1].at_css("h4"), "no details line without role or year"
  end

  def test_interests_render_every_entry_without_an_active_flag
    assert_equal(["EN Chess", "EN Hiking"], section("Outside Interests").css("li").map { |li| li.text.strip })
  end

  def test_languages_table_balances_two_columns_and_pads_odd_counts
    rows = section("Languages").css("table.languages-table tr")
    assert_equal([2, 2], rows.map { |row| row.css("td").size })
    assert_equal "EN German – Basic", squish(rows[1].css("td")[0])
    assert_equal "", squish(rows[1].css("td")[1])
  end

  def test_links_section_renders_active_links_with_print_urls
    items = section("Additional Links").css("li")
    assert_equal 1, items.size
    assert_equal "https://example.org/blog", items[0].at_css("a")["href"]
    assert_includes items[0].at_css(".print-only-inline").text, "https://example.org/blog"
  end

  def test_publications_render_linked_name_publisher_localized_partial_date_and_summary
    %w[en ar].each do |lang|
      pubs = section(locale(lang)["ui"]["section_titles"]["publications"], lang).css(".resume-item")
      assert_equal 2, pubs.size
      link = pubs[0].at_css("h3 a")
      assert_equal "https://example.org/paper", link["href"]
      assert_includes link["rel"], "noopener"
      print_url = pubs[0].at_css(".print-only-inline")
      lang == "ar" ? assert_equal("ltr", print_url["dir"]) : assert_nil(print_url["dir"])
      details = squish(pubs[0].at_css("h4"))
      assert_match(/\AJournal • \S+/, details)
      assert_match(/1889/, details)
      assert_includes pubs[0].at_css("p").text, "paper summary"
      assert_nil pubs[1].at_css("a"), "no url, no link"
      assert_equal "1912", squish(pubs[1].at_css("h4")), "integer year, no publisher: no stray bullet"
    end
  end

  def test_references_render_blockquote_with_cite_for_active_entries_only
    %w[en ar].each do |lang|
      quotes = section(locale(lang)["ui"]["section_titles"]["references"], lang).css("blockquote")
      assert_equal 1, quotes.size
      assert_includes quotes[0].at_css("p").text, "glowing words"
      assert_includes quotes[0].at_css("cite").text, "Referee"
    end
  end

  def test_publications_and_references_are_omitted_when_disabled
    extras = %w[publications references]
    html = cv("en", "resume_section" => SECTIONS.to_h { |name| [name, !extras.include?(name)] })
    titles = extras.map { |name| locale("en")["ui"]["section_titles"][name] }
    headings = html.css("main section.content-section h2").map { |h2| h2.text.strip }
    assert_empty(headings & titles)
  end

  def test_external_links_open_safely_in_a_new_tab
    cv.css('main a[target="_blank"]').each do |link|
      assert_includes link["rel"].to_s, "noopener", "#{link['href']} must carry rel=noopener"
    end
  end

  # --- Social links --------------------------------------------------------------------------

  def test_social_icons_render_only_configured_networks
    icons = cv.css("ul.social-links a.icon-link")
    assert_equal ["mailto:jane@example.org", "https://github.com/jane", "https://linkedin.com/in/jane"].sort,
                 icons.map { |a| a["href"] }.sort
    icons.each { |a| refute_empty a["aria-label"].to_s, "icon-only links need an accessible name" }
  end

  def test_social_icon_accessible_names_are_localized
    labels = locale("ar")["ui"]["social_labels"]
    github = cv("ar").at_css('ul.social-links a[href="https://github.com/jane"]')
    assert_equal labels["github"], github["aria-label"]
    assert_equal labels["github"], github.at_css(".sr-only").text
    assert_equal labels["email"], cv("ar").at_css('ul.social-links a[href^="mailto:"]')["aria-label"]
  end

  def test_print_social_links_use_locale_labels_and_ltr_urls
    items = cv("ar").css("section.print-only li")
    github = items.find { |li| URI(li.at_css("span").text.strip).host == "github.com" }
    assert_includes github.at_css("strong").text, locale("ar")["ui"]["social_labels"]["github"]
    assert_equal "ltr", github.at_css("span")["dir"]
  end

  # --- hreflang ------------------------------------------------------------------------------

  def test_hreflang_links_every_translation_and_x_default
    links = cv("ar").css('link[rel="alternate"][hreflang]').to_h { |link| [link["hreflang"], link["href"]] }
    assert_equal "https://example.org/en/cv/", links["en"]
    assert_equal "https://example.org/ar/cv/", links["ar"]
    assert_equal "https://example.org/en/cv/", links["x-default"]
  end

  # --- Profile, default and error layouts ------------------------------------------------------

  def test_profile_bolds_the_last_name_word_and_renders_about_markdown
    doc = html("index.html")
    assert_equal "Doe", doc.at_css("h1.full-name b").text
    assert_equal "about", doc.at_css(".about strong").text
    assert_equal "/en/cv/", doc.at_css("a.cv-button")["href"]
    assert_equal locale("en")["ui"]["cv_button"], doc.at_css("a.cv-button").text.strip
  end

  def test_profile_icon_links_all_have_accessible_names_and_one_email_link
    links = html("index.html").css("ul.social-links a.icon-link")
    links.each { |link| refute_empty link["aria-label"].to_s, "#{link['href']} needs an accessible name" }
    mailto = links.select { |link| link["href"].start_with?("mailto:") }
    assert_equal ["mailto:jane@example.org"], mailto.map { |link| link["href"] }, "no duplicate email icon"
    assert_nil mailto.first["target"], "mailto links must not open a new tab"
  end

  def test_profile_uses_its_language_direction
    assert_equal "rtl", html("ar/index.html").at_css("html")["dir"]
  end

  def test_default_layout_renders_markdown_content_in_page_language
    doc = html("about/index.html")
    assert_equal "rtl", doc.at_css("html")["dir"]
    assert_equal "there", doc.at_css("main strong").text
  end

  def test_error_page_renders_default_language_copy_and_home_button
    doc = html("404.html")
    assert_equal "404", doc.at_css(".error-code").text.strip
    assert_equal locale("en")["error_pages"]["404"]["title"], doc.at_css("h1.error-title").text.strip
    assert_equal "/", doc.at_css("#error-home-btn")["href"], "home falls back to the default language profile"
    assert_nil doc.at_css("button.error-btn"), "client errors get no reload button"
  end

  def test_error_page_ships_every_configured_language_for_the_url_script
    i18n = JSON.parse(html("404.html").at_css("#error-lang-i18n").text)
    assert_equal "en", i18n["default_lang"]
    assert_equal locale("ar")["error_pages"]["404"]["title"], i18n["ar"]["title"]
    assert_equal "rtl", i18n["ar"]["direction"]
    assert_equal "/ar/", i18n["ar"]["home_url"]
  end

  # Runs the error page's inline language-detection script in Node against a stub DOM and
  # returns what it wrote: [block lang, title text, home href].
  def run_error_script(page, pathname)
    skip "node is not installed" unless system("node --version", out: File::NULL, err: File::NULL)
    script = page.css("script:not([type])").map(&:text).find { |js| js.include?("error-lang-i18n") }
    stub = <<~JS
      const el = () => ({ attrs: {}, setAttribute(k, v) { this.attrs[k] = v; }, textContent: "", href: "" });
      const title = el(), message = el(), block = el(), home = el();
      block.querySelector = (sel) => (sel === ".error-title" ? title : message);
      const nodes = { "error-lang-i18n": { textContent: #{page.at_css('#error-lang-i18n').text.to_json} },
                      "error-lang-block": block, "error-home-btn": home };
      let ready;
      global.document = { getElementById: (id) => nodes[id], addEventListener: (_e, fn) => { ready = fn; } };
      global.window = { location: { pathname: #{pathname.to_json} } };
      #{script}
      ready();
      console.log(JSON.stringify([block.attrs.lang, title.textContent, home.href]));
    JS
    out, status = Open3.capture2("node", "-e", stub)
    assert status.success?, "error page script crashed"
    JSON.parse(out)
  end

  def test_error_page_script_picks_language_from_the_url_prefix
    lang, title, home = run_error_script(html("404.html"), "/ar/missing/page")
    assert_equal ["ar", locale("ar")["error_pages"]["404"]["title"], "/ar/"], [lang, title, home]
    assert_equal "en", run_error_script(html("404.html"), "/nowhere")[0], "unprefixed paths use default_lang"
  end

  def test_error_page_script_honours_baseurl
    page = html("404.html", "baseurl" => "/cv")
    lang, _title, home = run_error_script(page, "/cv/ar/missing")
    assert_equal %w[ar /cv/ar/], [lang, home]
  end

  HOSTILE = %(</script><img src=x onerror=alert(1)>)
  HOSTILE_LOCALE = {
    "ui" => { "home" => HOSTILE, "skip_to_content" => HOSTILE },
    "error_pages" => { "404" => { "title" => HOSTILE, "message" => HOSTILE } }
  }.freeze

  def test_error_page_json_block_survives_hostile_locale_strings
    page = html("404.html", "_en_locale" => HOSTILE_LOCALE)
    json = page.at_css("#error-lang-i18n").text
    refute_includes json, "<", "no raw < may reach the JSON script block"
    assert_equal HOSTILE, JSON.parse(json)["en"]["title"], "JSON.parse must decode the original string"
    assert_empty page.css("img"), "hostile markup must not become elements"
    assert_equal locale("ar")["error_pages"]["404"]["title"], JSON.parse(json)["ar"]["title"]
  end

  def test_hostile_locale_strings_are_escaped_in_html_positions
    page = html("404.html", "_en_locale" => HOSTILE_LOCALE)
    assert_equal HOSTILE, page.at_css("h1.error-title").text
    assert_equal HOSTILE, page.at_css(".error-description").text
    assert_equal HOSTILE, page.at_css("#error-home-btn").text.strip
    assert_equal HOSTILE, page.at_css("a.skip-link").text
  end

  def test_lang_and_hreflang_attributes_are_escaped
    doc = html("weird/index.html")
    assert_equal %(x"onload="alert(1)), doc.at_css("html")["lang"]
    assert_nil doc.at_css("html")["onload"], "a quote in lang must not open a new attribute"
    assert_nil doc.at_css("link[hreflang]")["onload"]
    assert_equal %(x"onload="alert(1)), doc.at_css("link[hreflang]")["hreflang"]
  end

  HOSTILE_ID = "X');alert(1);//</script><img src=x onerror=alert(2)>"

  def test_hostile_analytics_ids_cannot_break_out_of_inline_scripts
    %w[gtm gtag].each do |kind|
      doc = html("index.html", "analytics" => { kind => HOSTILE_ID })
      assert_empty doc.css("head img, body img").select { |img| img["onerror"] }, "#{kind}: injected element"
      script = doc.css("script").map(&:text).find { |js| js.include?("alert(1)") }
      refute_nil script, "#{kind}: the ID should stay inside one script"
      assert_includes script, HOSTILE_ID.to_json.gsub("<", "\\u003c"), "#{kind}: ID must be a JS string literal"
    end
  end

  def test_server_error_page_puts_the_reload_button_first
    doc = html("500.html")
    assert_equal locale("en")["ui"]["reload_page"], doc.at_css("button.error-btn.primary").text.strip
    refute_includes doc.at_css("#error-home-btn")["class"], "primary"
  end
end
