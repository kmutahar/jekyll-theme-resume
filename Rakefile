# frozen_string_literal: true

require "rake"
require_relative "lib/jekyll-theme-resume/resume_validator"
require_relative "lib/jekyll-theme-resume/template_key_checker"

desc "Validate multilingual resume YAML data files for schema conformance and parity"
task :validate, [:data_dir] do |_t, args|
  data_dir = args[:data_dir] || (Dir.exist?("_data/en") ? "_data" : "demo/_data")
  validator = JekyllThemeResume::ResumeValidator.new(data_dir)
  exit_code = validator.validate
  exit exit_code unless exit_code.zero?
end

desc "Check theme templates for Liquid references to resume data keys that don't exist in the sample data " \
     "(warnings only; unlike `rake validate`, this never fails the task, since a field's absence from the " \
     "sample data doesn't always mean the template is wrong — see TemplateKeyChecker's class doc)"
task :check_data_keys, [:data_dir] do |_t, args|
  data_dir = args[:data_dir] || (Dir.exist?("_data/en") ? "_data" : "demo/_data")
  checker = JekyllThemeResume::TemplateKeyChecker.new(data_dir)
  checker.check
end

desc "Run every test/test_*.rb suite"
task :test do
  Dir["test/test_*.rb"].each { |file| ruby "-r./test/warning_filter", file }
end

require "rubocop/rake_task"

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ["--display-cop-names"]
end

# Locates the Jekyll config that produced a built site, so absolute URLs (canonical, hreflang,
# social cards) can be mapped back onto local files. Consumer sites keep _config.yml next to _site/.
def proof_config_for(site_dir, explicit)
  candidates = [explicit, File.join(File.dirname(site_dir), "_config.yml"), "demo/_config.yml", "_config.sample.yml"]
  path = candidates.compact.find { |candidate| File.file?(candidate) }
  path ? (YAML.safe_load_file(path, permitted_classes: [Date, Time]) || {}) : {}
end

desc "Verify built HTML: dead internal links, anchors, images, favicons and hreflang alternates"
task :proof, %i[site_dir config] do |_t, args|
  require "html-proofer"
  require "yaml"

  site_dir = args[:site_dir] || "_site"
  unless Dir.exist?(site_dir)
    abort "❌ '#{site_dir}' not found. Build first: " \
          "bundle exec jekyll build --source demo --destination _site"
  end

  config = proof_config_for(site_dir, args[:config])
  base_url = config["url"].to_s.chomp("/")
  ignore_urls = []

  # The theme's own build ships error pages but no homepage or CV pages: those routes only exist in a
  # consuming site. Exempt them ONLY when there is no index.html, so a real site still fails if
  # a configured language's CV route is genuinely missing.
  unless File.exist?(File.join(site_dir, "index.html"))
    language_urls = (config["languages"] || {}).values.filter_map { |lang| lang["url"] }
    ignore_urls = ["/"] + language_urls
  end

  options = {
    disable_external: true, # Offline and deterministic: only local files and anchors are verified.
    checks: %w[Images Links Scripts Favicon], # Favicon is opt-in in html-proofer 5.
    ignore_urls: ignore_urls,
    ignore_files: [%r{/graphify-out/}, %r{/vendor/}, %r{/node_modules/}] # Repo tooling copied into _site by Jekyll.
  }
  # hreflang/canonical URLs are absolute (site.url + path); rewrite them to local paths so they are proofed too.
  options[:swap_urls] = { /\A#{Regexp.escape(base_url)}/ => "" } unless base_url.empty?

  HTMLProofer.check_directory(site_dir, options).run
end

desc "Run default validation and test suite"
task default: %i[validate check_data_keys rubocop test]
