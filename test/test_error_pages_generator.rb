# frozen_string_literal: true

require "minitest/autorun"
require "jekyll"
require "fileutils"
require "tmpdir"

require_relative "../lib/jekyll-theme-resume"

# ErrorPagesGenerator and gem registration: a consuming site gets 404/403/500 pages without
# authoring them, and any page it does author always wins.
class ErrorPagesGeneratorTest < Minitest::Test
  def setup
    @dirs = []
  end

  def teardown
    @dirs.each { |dir| FileUtils.rm_rf(dir) }
  end

  def site_with(files = {})
    source = Dir.mktmpdir("error_pages_src_")
    @dirs << source
    files.each do |path, content|
      FileUtils.mkdir_p(File.dirname(File.join(source, path)))
      File.write(File.join(source, path), content)
    end
    config = Jekyll.configuration("source" => source, "destination" => File.join(source, "_site"), "quiet" => true,
                                  "validate_resume" => false, "json_resume" => { "enabled" => false })
    site = Jekyll::Site.new(config)
    site.reset
    site.read
    site.generate
    site
  end

  def error_pages(site)
    site.pages.select { |page| page.data["layout"] == "error" }
  end

  def test_generates_404_403_and_500_with_error_layout_metadata
    pages = error_pages(site_with).to_h { |page| [page.url, page.data] }
    assert_equal %w[/403.html /404.html /500.html], pages.keys.sort
    assert_equal "404", pages["/404.html"]["code"]
    assert_equal "500 - Internal Server Error", pages["/500.html"]["title"]
    assert(pages.values.all? { |data| data["sitemap"] == false }, "synthetic error pages stay out of the sitemap")
  end

  def test_root_page_overrides_the_generated_one
    site = site_with("404.html" => "---\nlayout: error\ncode: \"404\"\ntitle: Mine\n---\n")
    assert_equal(["Mine"], site.pages.select { |page| page.url == "/404.html" }.map { |page| page.data["title"] })
  end

  def test_page_in_pages_folder_overrides_the_generated_one
    site = site_with("_pages/403.html" => "---\nlayout: error\n---\n")
    assert_empty(error_pages(site).select { |page| page.data["title"] == "403 - Access Forbidden" })
  end

  def test_page_with_the_same_permalink_overrides_the_generated_one
    site = site_with("missing.md" => "---\npermalink: /500.html\n---\nCustom\n")
    assert_equal(1, site.pages.count { |page| page.url == "/500.html" })
  end

  def test_gem_entrypoint_registers_every_theme_generator
    generators = Jekyll::Generator.descendants.map(&:name)
    %w[ErrorPagesGenerator ResumePagesGenerator ResumeValidatorGenerator JsonResumeGenerator].each do |name|
      assert_includes generators, "JekyllThemeResume::#{name}"
    end
  end
end
