# frozen_string_literal: true

require "minitest/autorun"
require "jekyll"
require "fileutils"
require "tmpdir"
require "logger"
require "stringio"

require_relative "../_plugins/resume_pages_generator"

# Behavioral coverage for ResumePagesGenerator: auto-generation, collision-skip against
# hand-authored pages, and the global/per-language auto_generate_pages toggle.
class ResumePagesGeneratorTest < Minitest::Test
  def setup
    @dirs_to_clean = []
  end

  def teardown
    @dirs_to_clean.each { |d| FileUtils.rm_rf(d) }
  end

  def build_site(languages, extra_config = {}, pages: {})
    site_dir = Dir.mktmpdir("resume_pages_site_")
    @dirs_to_clean << site_dir

    pages.each do |filename, front_matter|
      FileUtils.mkdir_p(File.join(site_dir, "_pages"))
      File.write(File.join(site_dir, "_pages", filename), front_matter)
    end

    config = Jekyll.configuration({
      "source" => site_dir,
      "destination" => Dir.mktmpdir("resume_pages_dest_"),
      "quiet" => true,
      "include" => ["_pages"], # consuming sites opt _pages/ in, exactly like demo/_config.yml
      "languages" => languages,
      "default_lang" => languages.keys.first
    }.merge(extra_config))
    @dirs_to_clean << config["destination"]

    site = Jekyll::Site.new(config)
    site.reset
    site.read
    site.generate
    site
  end

  def page(site, layout, lang)
    site.pages.find { |p| p.data["layout"] == layout && p.data["lang"] == lang }
  end

  def test_generates_cv_and_profile_when_no_hand_authored_page_exists
    site = build_site({ "gen" => { "url" => "/gen/cv/" } })

    cv = page(site, "resume", "gen")
    profile = page(site, "profile", "gen")

    refute_nil cv, "expected a generated resume page for 'gen'"
    assert_equal "/gen/cv/", cv.data["permalink"]
    assert_equal "resume", cv.data["t_id"]

    refute_nil profile, "expected a generated profile page for 'gen'"
    assert_equal "/", profile.data["permalink"], "default_lang's profile page should be site root"
    assert_equal "profile", profile.data["t_id"]
  end

  def test_unsafe_language_key_generates_no_pages
    site = build_site({ "en" => { "url" => "/en/cv/" }, "../x" => { "url" => "/x/cv/" } })

    refute_nil page(site, "resume", "en")
    assert_nil page(site, "resume", "../x")
    assert_nil page(site, "profile", "../x")
  end

  def test_non_default_language_profile_permalink_is_lang_prefixed
    site = build_site({
                        "en" => { "url" => "/en/cv/" },
                        "es" => { "url" => "/es/cv/" }
                      })

    assert_equal "/es/", page(site, "profile", "es").data["permalink"]
  end

  def test_skips_language_with_hand_authored_page
    front_matter = <<~FM
      ---
      layout: resume
      lang: manual
      permalink: /manual/cv/
      t_id: resume
      ---
    FM

    site = build_site(
      { "manual" => { "url" => "/manual/cv/" } },
      pages: { "manual.md" => front_matter }
    )

    resume_pages = site.pages.select { |p| p.data["layout"] == "resume" && p.data["lang"] == "manual" }
    assert_equal 1, resume_pages.size, "must not duplicate the hand-authored page"
  end

  def test_global_flag_false_disables_generation
    site = build_site({ "off" => { "url" => "/off/cv/" } }, { "resume_auto_generate_pages" => false })

    assert_nil page(site, "resume", "off")
    assert_nil page(site, "profile", "off")
  end

  def test_per_language_flag_overrides_global_flag
    site = build_site(
      { "on" => { "url" => "/on/cv/", "auto_generate_pages" => true } },
      { "resume_auto_generate_pages" => false }
    )

    refute_nil page(site, "resume", "on"), "per-language true must override a global false"
  end

  def test_per_language_flag_false_disables_just_that_language
    site = build_site({
                        "off" => { "url" => "/off/cv/", "auto_generate_pages" => false },
                        "on" => { "url" => "/on/cv/" }
                      })

    assert_nil page(site, "resume", "off")
    refute_nil page(site, "resume", "on")
  end

  def test_language_without_url_gets_a_profile_but_no_cv_and_a_warning
    log = StringIO.new
    original = Jekyll.logger
    Jekyll.logger = Logger.new(log)
    site = build_site({ "nourl" => {} }, { "quiet" => false })
    assert_nil page(site, "resume", "nourl")
    refute_nil page(site, "profile", "nourl"), "the profile permalink does not depend on languages.<lang>.url"
    assert_includes log.string, "no resume page for language 'nourl'"
  ensure
    Jekyll.instance_variable_set(:@logger, original)
  end

  def test_null_language_block_is_tolerated
    site = build_site({ "en" => nil })
    refute_nil page(site, "profile", "en")
  end

  def test_occupied_permalink_blocks_generation
    front_matter = "---\npermalink: /taken/cv/\n---\nhand-made\n"
    site = build_site({ "taken" => { "url" => "/taken/cv/" } }, pages: { "taken.md" => front_matter })
    assert_nil page(site, "resume", "taken")
    assert_equal(1, site.pages.count { |p| p.url == "/taken/cv/" })
  end

  def test_generated_pages_are_named_per_layout_and_language
    site = build_site({ "en" => { "url" => "/en/cv/" } })
    assert_equal "resume-en.html", page(site, "resume", "en").name
    assert_equal "profile-en.html", page(site, "profile", "en").name
  end
end
