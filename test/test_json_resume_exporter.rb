# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "yaml"
require "stringio"
require_relative "../lib/jekyll-theme-resume"

class JsonResumeExporterTest < Minitest::Test
  Exporter = JekyllThemeResume::JsonResumeExporter
  Generator = JekyllThemeResume::JsonResumeGenerator
  JsonPage = JekyllThemeResume::JsonResumePage
  ROOT = File.expand_path("..", __dir__)

  def setup
    @directory = Dir.mktmpdir("json_resume_")
    config = Jekyll.configuration(
      "source" => @directory, "destination" => File.join(@directory, "_site"), "quiet" => true,
      "url" => "https://example.org", "baseurl" => "/cv", "default_lang" => "en", "validate_resume" => false,
      "languages" => { "en" => { "name" => "Jane", "resume_title" => "Engineer", "data_path" => "en",
                                 "url" => "/en/cv/", "header_intro" => true, "address" => "123 Street", "country_code" => "GB" } },
      "resume_section" => Exporter::SECTIONS.keys.to_h { |section| [section, true] },
      "resume_section_order" => Exporter::SECTIONS.keys,
      "display_header_contact_info" => true, "enable_summary" => true, "resume_avatar" => true,
      "avatar_url" => "/image.png", "contact_info" => { "email" => "base@example.org", "phone" => "123",
                                                        "email_live" => "live@example.org", "phone_live" => "456" },
      "social_links" => { "github" => "https://github.com/jane", "email" => "private@example.org",
                          "whatsapp" => "https://wa.me/123" }, "social_usernames" => { "github" => "jane" }
    )
    @site = Jekyll::Site.new(config)
    @site.reset
    @site.read
    @site.data["en"] = fixture
    @site.data["locales"] = { "en" => { "present_values" => %w[Present Ongoing] } }
    @log = StringIO.new
    @old_logger = Jekyll.logger
    Jekyll.logger = Logger.new(@log)
  end

  def teardown
    Jekyll.instance_variable_set(:@logger, @old_logger)
    FileUtils.remove_entry(@directory)
  end

  def fixture
    {
      "header" => { "intro" => "<p>Jane &amp; team &ndash; **engineers**.</p><p>Next<br>line &bull; &#233;</p>" },
      "experience" => [{ "active" => true, "company" => "Acme", "position" => "Lead", "startdate" => "2020-02",
                         "enddate" => "Ongoing", "summary" => "* Built [things](https://example.org)", "highlights" => ["Shipped"] }],
      "volunteering" => [{ "active" => true, "company" => "Charity", "position" => "Volunteer", "startdate" => 2018 }],
      "education" => [{ "active" => true, "uni" => "University", "degree" => "BSc", "area" => "Computing", "score" => 4.0,
                        "courses" => ["Algorithms"], "startdate" => "2010", "enddate" => "2014" }],
      "certifications" => [{ "active" => true, "name" => "Certificate", "issuing_organization" => "Issuer",
                             "issue_date" => "2020-02-29", "credential_url" => "https://example.org/cert" }],
      "recognitions" => [{ "active" => true, "award" => "Prize", "organization" => "Society", "year" => 2021 }],
      "projects" => [{ "active" => true, "project" => "Tool", "role" => "Author", "url" => "/tool", "keywords" => ["Ruby"] }],
      "skills" => [{ "active" => true, "skill" => "Ruby", "level" => 5, "level_label" => "Expert", "keywords" => ["Jekyll"] }],
      "languages" => [{ "active" => true, "language" => "English", "description" => "Native speaker", "descrp_short" => "Native" }],
      "interests" => [{ "description" => "Reading" }],
      "publications" => [{ "active" => true, "name" => "Ashes", "publisher" => "Strand", "release_date" => "1889-03",
                           "url" => "https://example.org/ashes", "summary" => "On tobacco." },
                         { "active" => false, "name" => "Draft" }],
      "references" => [{ "active" => true, "name" => "Dr. Watson", "reference" => "Excellent.", "email" => "x@example.org" },
                       { "active" => false, "name" => "Hidden", "reference" => "No." }]
    }
  end

  def export
    Exporter.export(@site, "en")
  end

  def generate
    Generator.new.generate(@site)
  end

  def generated
    @site.pages.grep(JsonPage)
  end

  def test_maps_all_supported_sections_and_validates_schema
    document = export
    assert Exporter::SCHEMA.valid?(document)
    assert_equal "Acme", document.dig("work", 0, "name")
    assert_equal "Charity", document.dig("volunteer", 0, "organization")
    assert_equal "University", document.dig("education", 0, "institution")
    assert_equal "4.0", document.dig("education", 0, "score")
    assert_equal "Issuer", document.dig("certificates", 0, "issuer")
    assert_equal "2021", document.dig("awards", 0, "date")
    assert_equal "Expert", document.dig("skills", 0, "level")
    assert_equal "Reading", document.dig("interests", 0, "name")
    assert_equal ["Author"], document.dig("projects", 0, "roles")
    assert_equal "https://example.org/cv/tool", document.dig("projects", 0, "url")
    assert_equal "https://example.org/cv/image.png", document.dig("basics", "image")
    assert_equal "jane", document.dig("basics", "profiles", 0, "username")
    assert_equal "base@example.org", document.dig("basics", "email")
    assert_equal "Native speaker", document.dig("languages", 0, "fluency")
  end

  def test_publications_and_references_map_exactly_and_skip_inactive_entries
    result = export
    assert_equal [{ "name" => "Ashes", "publisher" => "Strand", "releaseDate" => "1889-03",
                    "url" => "https://example.org/ashes", "summary" => "On tobacco." }], result["publications"]
    assert_equal [{ "name" => "Dr. Watson", "reference" => "Excellent." }], result["references"]
    @site.config["resume_section"]["publications"] = false
    @site.config["resume_section"]["references"] = false
    result = export
    refute result.key?("publications")
    refute result.key?("references")
    assert result.key?("work")
  end

  def test_normalizes_html_entities_without_destroying_markdown
    assert_equal "Jane & team – **engineers**.\nNext\nline • é", export.dig("basics", "summary")
    assert_equal "* Built [things](https://example.org)", export.dig("work", 0, "summary")
    @site.data["en"]["header"]["intro"] = "&unknown; <https://example.org>"
    assert_equal "&unknown; <https://example.org>", export.dig("basics", "summary")
    @site.data["en"]["header"]["intro"] = "- Parent\n  - Child  \nNext"
    assert_equal "- Parent\n  - Child  \nNext", export.dig("basics", "summary")
  end

  def test_strips_script_tags_that_evade_a_single_regex_pass
    @site.data["en"]["header"]["intro"] = "before<script>evil()</script >after"
    refute_includes export.dig("basics", "summary"), "script"
    assert_equal "beforeafter", export.dig("basics", "summary")

    @site.data["en"]["header"]["intro"] = "before<scr<script>ipt>evil()</scr</script>ipt>after"
    refute_includes export.dig("basics", "summary"), "script"
    assert_equal "beforeafter", export.dig("basics", "summary")

    # A closing tag can carry bogus trailing content up to the next '>' and a
    # browser still treats it as </script>; the regex must match that too.
    @site.data["en"]["header"]["intro"] = "before<script>evil()</script\t\n bar>after"
    refute_includes export.dig("basics", "summary"), "script"
    assert_equal "beforeafter", export.dig("basics", "summary")
  end

  def test_decodes_entities_before_stripping_so_encoded_tags_cannot_survive
    @site.data["en"]["header"]["intro"] = "before&lt;script&gt;evil()&lt;/script&gt;after"
    refute_includes export.dig("basics", "summary"), "script"
    assert_equal "beforeafter", export.dig("basics", "summary")
  end

  def test_filters_missing_and_false_active_flags_and_section_order
    @site.data["en"]["experience"] += [{ "company" => "Hidden" }, { "company" => "Draft", "active" => false }]
    @site.config["resume_section"]["projects"] = false
    @site.config["resume_section_order"].delete("skills")
    result = export
    assert_equal 1, result["work"].size
    refute result.key?("projects")
    refute result.key?("skills")
  end

  def test_summary_and_avatar_visibility
    @site.config["enable_summary"] = false
    @site.config["resume_avatar"] = false
    @site.config["languages"]["en"].merge!("header_intro" => false, "about" => "Private profile biography")
    result = export
    refute result["basics"].key?("summary")
    refute result["basics"].key?("image")
    refute result["work"].first.key?("summary")
  end

  def test_live_contacts_and_fallback
    @site.config["enable_live"] = true
    assert_equal "live@example.org", export.dig("basics", "email")
    assert_equal "456", export.dig("basics", "phone")
    @site.config["contact_info"].delete("email_live")
    assert_equal "base@example.org", export.dig("basics", "email")
  end

  def test_privacy_omits_contact_fields_and_direct_contact_profiles
    @site.config["json_resume"] = { "privacy" => { "export_contact_info" => false } }
    basics = export["basics"]
    %w[email phone location].each { |field| refute basics.key?(field) }
    assert_equal(["github"], basics["profiles"].map { |profile| profile["network"] })
  end

  def test_contact_bar_and_cta_visibility
    @site.config["display_header_contact_info"] = false
    basics = export["basics"]
    %w[email phone location].each { |field| refute basics.key?(field) }
    @site.config["resume_looking_for_work"] = true
    assert_equal "base@example.org", export.dig("basics", "email")
  end

  def test_header_language_visibility_is_independent_of_section_order
    @site.config["resume_section"]["lang_header"] = true
    @site.config["resume_section_order"].delete("languages")
    assert_equal "Native", export.dig("languages", 0, "fluency")
    @site.config["display_header_contact_info"] = false
    refute export.key?("languages")
  end

  def test_nested_and_root_data_paths
    data = @site.data.delete("en")
    @site.data["2025-06"] = { "v1" => data }
    @site.config["languages"]["en"]["data_path"] = "2025-06.v1"
    assert_equal "Acme", export.dig("work", 0, "name")
    @site.data.merge!(data)
    @site.config["languages"]["en"]["data_path"] = ""
    assert_equal "Acme", export.dig("work", 0, "name")
  end

  def test_partial_iso_dates_and_present_values
    assert_equal "2020-02", export.dig("work", 0, "startDate")
    refute export["work"].first.key?("endDate")
    assert_empty @log.string
    %w[Present present ONGOING].each do |value|
      @site.data["en"]["experience"][0]["enddate"] = value
      refute export["work"].first.key?("endDate")
    end
    assert_empty @log.string
  end

  def test_invalid_optional_formats_omit_values_and_log_field_paths_only
    @site.data["en"]["experience"][0]["startdate"] = "2023-02-29"
    @site.data["en"]["certifications"][0]["issue_date"] = "2020-02"
    @site.config["contact_info"]["email"] = "secret invalid email"
    @site.config["languages"]["en"]["country_code"] = "ZZ"
    @site.data["en"]["projects"][0]["url"] = "javascript:alert(1)"
    result = export
    refute result["work"].first.key?("startDate")
    refute result["certificates"].first.key?("date")
    refute result["basics"].key?("email")
    refute result["basics"]["location"].key?("countryCode")
    refute result["projects"].first.key?("url")
    assert_includes @log.string, "en.certifications.issue_date"
    refute_includes @log.string, "secret invalid email"
    assert Exporter::SCHEMA.valid?(result)
  end

  def test_dates_loaded_as_yaml_dates_and_numeric_years
    @site.data["en"]["certifications"][0]["issue_date"] = Date.new(2020, 2, 29)
    assert_equal "2020-02-29", export.dig("certificates", 0, "date")
    assert_equal "2018", export.dig("volunteer", 0, "startDate")
  end

  def test_defaults_allowlists_and_unknown_languages
    @site.config["languages"]["ar"] = @site.config["languages"]["en"].merge("name" => "عربي")
    generate
    assert_equal %w[/ar/resume.json /en/resume.json /resume.json], generated.map(&:url).sort
    @site.pages.clear
    @site.config["json_resume"] = { "languages" => %w[ar unknown] }
    generate
    assert_equal ["/ar/resume.json"], generated.map(&:url)
    assert_includes @log.string, "unknown export language"
    assert_equal({ "ar" => "/ar/resume.json" }, @site.config["json_resume_routes"])
  end

  def test_disable_root_only_and_empty_allowlist
    @site.config["json_resume"] = { "root_export" => false, "languages" => [] }
    generate
    assert_equal ["/en/resume.json"], generated.map(&:url)
    @site.pages.clear
    @site.config["json_resume"]["enabled"] = false
    generate
    assert_empty generated
    assert_empty @site.config["json_resume_routes"]
  end

  def test_arbitrary_language_codes_and_unicode
    %w[ar ur de fr es pt-BR].each do |lang|
      @site.config["languages"][lang] = @site.config["languages"]["en"].merge("name" => "عربي اردو é ñ ü")
    end
    generate
    assert_equal 8, generated.size
    generated.each do |page|
      document = JSON.parse(page.content)
      assert Exporter::SCHEMA.valid?(document)
    end
    assert_includes generated.find { |page| page.url == "/ur/resume.json" }.content, "اردو"
  end

  def test_static_collision_suppresses_root_and_discovery
    @site.static_files << Jekyll::StaticFile.new(@site, @directory, "en", "resume.json")
    generate
    assert_empty generated
    assert_empty @site.config["json_resume_routes"]
    assert_includes @log.string, "destination occupied"
  end

  def test_authored_permalink_collision_and_root_collision
    authored = Jekyll::PageWithoutAFile.new(@site, @directory, "", "authored.json")
    authored.data["permalink"] = "/en/resume.json"
    @site.pages << authored
    generate
    assert_empty generated
    assert_equal [authored], @site.pages
    authored.data["permalink"] = "/resume.json"
    # Page caches its URL; use a new root resource for the second scenario.
    @site.pages.clear
    @site.static_files << Jekyll::StaticFile.new(@site, @directory, "", "resume.json")
    generate
    assert_equal ["/en/resume.json"], generated.map(&:url)
  end

  def test_missing_site_url_omits_relative_links
    @site.config["url"] = ""
    basics = export["basics"]
    refute basics.key?("url")
    refute basics.key?("image")
    assert_equal "https://github.com/jane", basics.dig("profiles", 0, "url")
  end

  def test_malformed_optional_arrays_do_not_break_export
    @site.data["en"]["skills"][0]["keywords"] = "not an array"
    @site.data["en"]["experience"][0]["highlights"] = ["Valid", { "bad" => true }]
    assert_equal ["Valid"], export.dig("work", 0, "highlights")
    refute export["skills"].first.key?("keywords")
  end

  def test_final_schema_failure_skips_document
    invalid_time = Object.new
    def invalid_time.getutc = self
    def invalid_time.iso8601 = 42
    @site.time = invalid_time
    generate
    assert_empty generated
    assert_empty @site.config["json_resume_routes"]
    assert_includes @log.string, "schema validation failed"
  end

  def test_real_build_bypasses_liquid_and_links_only_successful_exports
    FileUtils.mkdir_p(File.join(@directory, "_layouts"))
    FileUtils.mkdir_p(File.join(@directory, "_includes"))
    FileUtils.cp(File.join(ROOT, "_includes/shared-head.html"), File.join(@directory, "_includes"))
    File.write(File.join(@directory, "_layouts/resume.html"), "<html><head>{% include shared-head.html %}</head></html>")
    File.write(File.join(@directory, "_layouts/profile.html"), "<html><head>{% include shared-head.html %}</head></html>")
    FileUtils.mkdir_p(File.join(@directory, "_data/en"))
    literal = "{{ site.contact_info.email }} {% unclosed_tag %} اردو"
    File.write(File.join(@directory, "_data/en/header.yml"), YAML.dump("intro" => literal))
    @site.process
    document = JSON.parse(File.read(File.join(@site.dest, "en/resume.json")))
    assert_equal literal, document.dig("basics", "summary")
    assert_equal document, JSON.parse(File.read(File.join(@site.dest, "resume.json")))
    cv = File.read(File.join(@site.dest, "en/cv/index.html"))
    assert_includes cv, 'type="application/json" href="/cv/en/resume.json"'
    refute_includes File.read(File.join(@site.dest, "index.html")), 'type="application/json"'

    # Rebuild in the same process and destination: disabled exports and discovery must disappear.
    @site.config["json_resume"] = { "enabled" => false }
    @site.process
    refute File.exist?(File.join(@site.dest, "en/resume.json"))
    refute_includes File.read(File.join(@site.dest, "en/cv/index.html")), 'type="application/json"'
  end

  def test_localized_present_values_use_effective_locale
    @site.data["locales"]["en"]["present_values"] = ["حتى الآن"]
    @site.data["en"]["experience"][0]["enddate"] = "حتى الآن"
    refute export["work"].first.key?("endDate")
    assert_empty @log.string
  end

  def test_canonical_url_uses_authored_cv_permalink
    page = Jekyll::PageWithoutAFile.new(@site, @directory, "", "cv.html")
    page.data.merge!("layout" => "resume", "lang" => "en", "permalink" => "/custom-cv/")
    @site.pages << page
    assert_equal "https://example.org/cv/custom-cv/", export.dig("basics", "url")
  end

  def test_basics_carry_location_phone_and_meta
    document = export
    assert_equal({ "address" => "123 Street", "countryCode" => "GB" }, document.dig("basics", "location"))
    assert_equal "123", document.dig("basics", "phone")
    assert_equal "https://example.org/cv/en/cv/", document.dig("meta", "canonical")
    assert_equal "1.0.0", document.dig("meta", "version")
    assert_equal Exporter::SCHEMA_URL, document["$schema"]
  end

  def test_invalid_language_codes_are_never_used_as_routes
    @site.config["languages"]["../evil"] = @site.config["languages"]["en"]
    generate
    refute(generated.any? { |page| page.url.include?("evil") })
    assert_includes @log.string, "invalid language route"
  end

  def test_whatsapp_profile_follows_contact_privacy
    assert_includes export.dig("basics", "profiles").map { |profile| profile["network"] }, "whatsapp"
  end

  def test_actual_authored_json_is_preserved_without_discovery
    FileUtils.mkdir_p(File.join(@directory, "_layouts"))
    FileUtils.mkdir_p(File.join(@directory, "_includes"))
    FileUtils.cp(File.join(ROOT, "_includes/shared-head.html"), File.join(@directory, "_includes"))
    File.write(File.join(@directory, "_layouts/resume.html"), "<head>{% include shared-head.html %}</head>")
    FileUtils.mkdir_p(File.join(@directory, "en"))
    authored = '{"authored":true}'
    File.write(File.join(@directory, "en/resume.json"), authored)
    @site.process
    assert_equal authored, File.read(File.join(@site.dest, "en/resume.json"))
    refute File.exist?(File.join(@site.dest, "resume.json"))
    refute_includes File.read(File.join(@site.dest, "en/cv/index.html")), 'type="application/json"'
  end
end
