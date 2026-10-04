# frozen_string_literal: true

module JekyllThemeResume
  # Programmatically synthesizes standard HTTP error pages (404, 403, 500)
  # into site.pages if they are not already defined by the site.
  #
  # WHY THIS IS NECESSARY:
  # Jekyll gem-based themes only distribute assets, _layouts, _includes, _sass,
  # and _data. Root-level HTML files in a gem theme are NOT automatically copied
  # or rendered into the consuming site's destination directory (_site/).
  #
  # HOW IT WORKS:
  # This generator executes during the Jekyll build pipeline. For each error page
  # defined in ERROR_PAGES, it checks whether the consuming site already provides
  # an override. If no override exists, it creates an in-memory virtual page
  # (Jekyll::PageWithoutAFile) and adds it to site.pages so Jekyll compiles it
  # using _layouts/error.html.
  class ErrorPagesGenerator < Jekyll::Generator
    # safe true: Allows plugin execution in Jekyll safe mode / GitHub Pages environments
    safe true
    # priority :low: Ensures all physical pages in the consuming site are parsed and
    # added to site.pages first, allowing our collision checks to be fully accurate.
    priority :low

    # Standard HTTP error codes, target output filenames, and default bilingual titles.
    ERROR_PAGES = {
      "404" => {
        "file" => "404.html",
        "title" => "404 - Page Not Found"
      },
      "403" => {
        "file" => "403.html",
        "title" => "403 - Access Forbidden"
      },
      "500" => {
        "file" => "500.html",
        "title" => "500 - Internal Server Error"
      }
    }.freeze

    def generate(site)
      ERROR_PAGES.each do |code, info|
        filename = info["file"]
        # Skip if page already exists in site.pages or in site source files
        #
        # THREE-TIER COLLISION PREVENTION:
        # 1. Check in-memory site.pages for existing page name or permalink URL
        next if site.pages.any? { |p| p.name == filename || p.url == "/#{filename}" }
        # 2. Check if a physical file exists at the root of the consuming site
        next if File.exist?(site.in_source_dir(filename))
        # 3. Check if a physical file exists in the _pages/ collection directory
        next if File.exist?(site.in_source_dir("_pages", filename))

        # Synthesize virtual page in memory without requiring a physical file on disk.
        # Arguments: site, base directory, sub-directory (""), file name
        page = Jekyll::PageWithoutAFile.new(site, site.source, "", filename)
        page.content = ""
        # Assign Front Matter metadata consumed by _layouts/error.html:
        page.data["layout"] = "error"
        page.data["code"] = code
        page.data["title"] = info["title"]
        page.data["permalink"] = "/#{filename}"
        # Exclude synthetic error pages from sitemap generators (e.g. jekyll-sitemap)
        page.data["sitemap"] = false

        # Append virtual page to site.pages so Jekyll renders and writes it to _site/
        site.pages << page
      end
    end
  end
end
