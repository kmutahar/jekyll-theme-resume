#!/usr/bin/env ruby
# frozen_string_literal: true

# ATS full-text check: every visible text node of a language's resume page (outside .no-print) must
# appear in the generated PDF's `pdftotext` output, in DOM order.
#   ruby test/ats_check.rb <site_dir> <pdf_dir> [config.yml] [--update-baseline]
# Languages listed in test/ats_baseline.yml have known pdftotext defects (Arabic/Urdu letter swaps):
# they pass while their missing/out-of-order nodes stay within the baseline. Any other language must be clean.
require "nokogiri"
require "open3"
require "yaml"

BASELINE = File.expand_path("ats_baseline.yml", __dir__)

def normalize(text)
  # pdftotext drops hyphens at line wraps, so hyphens are ignored on both sides.
  text.unicode_normalize(:nfkc).gsub(/[\u200b-\u200f\u202a-\u202e\u2066-\u2069]/, "").split.join(" ").downcase.delete("-")
end

def page_nodes(file)
  doc = Nokogiri::HTML(File.read(file))
  doc.css("script, style, svg, noscript, .no-print").each(&:remove)
  doc.at_css("body").xpath(".//text()").map { |node| normalize(node.text) }
     .grep(/[[:alnum:]]/)
     .grep_v(/\d\d:\d\d:\d\dz/) # the "generated on <time>" footer differs on every build
end

# Whole-word match, so a short node ("Go", "5") cannot pass as a substring of a longer word.
def node_pattern(node)
  head = node.match?(/\A[[:alnum:]]/) ? "(?<![[:alnum:]])" : ""
  tail = node.match?(/[[:alnum:]]\z/) ? "(?![[:alnum:]])" : ""
  Regexp.new("#{head}#{Regexp.escape(node)}#{tail}")
end

def audit(nodes, pdf)
  text, status = Open3.capture2("pdftotext", pdf, "-")
  raise "pdftotext failed for #{pdf}" unless status.success?

  text = normalize(text)
  cursor = 0
  result = { "missing" => [], "out_of_order" => [] }
  nodes.each do |node|
    pattern = node_pattern(node)
    if (found = text.match(pattern, cursor))
      cursor = found.end(0)
    else
      result[text.match?(pattern) ? "out_of_order" : "missing"] << node
    end
  end
  result.transform_values(&:uniq)
end

update = ARGV.delete("--update-baseline")
site, pdf_dir, config_path = ARGV
abort "usage: ats_check.rb <site_dir> <pdf_dir> [config.yml] [--update-baseline]" unless site && pdf_dir

config = YAML.safe_load_file(config_path || "demo/_config.yml", permitted_classes: [Date, Time], aliases: true)
baseline = File.file?(BASELINE) ? YAML.safe_load_file(BASELINE) : {}
actual = {}
failures = []
config["languages"].each do |lang, cfg|
  next unless cfg.is_a?(Hash) && cfg["url"]

  page = File.join(site, cfg["url"])
  page = File.join(page, "index.html") if File.directory?(page)
  nodes = page_nodes(page)
  actual[lang] = audit(nodes, File.join(pdf_dir, "resume-#{lang}.pdf"))
  allowed = baseline.fetch(lang, { "missing" => [], "out_of_order" => [] })
  new_defects = actual[lang].to_h { |kind, list| [kind, list - allowed.fetch(kind, [])] }
  counts = actual[lang].transform_values(&:length)
  puts "#{lang.ljust(3)} #{nodes.length} nodes  missing #{counts['missing']}  out-of-order #{counts['out_of_order']}  " \
       "new defects #{new_defects.values.sum(&:length)}"
  new_defects.each { |kind, list| list.each { |node| failures << "#{lang} #{kind}: #{node}" } }
  allowed.each do |kind, list|
    (list - actual[lang][kind]).each { |node| failures << "#{lang} stale baseline entry (fixed? prune with --update-baseline): #{node}" }
  end
end

if update
  File.write(BASELINE, actual.reject { |_, r| r.values.all?(&:empty?) }.to_yaml)
  puts "wrote #{BASELINE}"
else
  puts failures
  exit(failures.empty? ? 0 : 1)
end
