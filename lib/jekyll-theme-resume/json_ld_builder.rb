# frozen_string_literal: true

require "json"

module JekyllThemeResume
  # Maps a JSON Resume document (JsonResumeExporter output) to a Schema.org ProfilePage + Person.
  # Reusing the export means inactive entries, live contacts, privacy, HTML stripping and URL
  # checks are already applied, so JSON-LD and JSON Resume never disagree.
  module JsonLdBuilder
    module_function

    def build(resume, lang)
      basics = resume["basics"] || {}
      url = basics["url"]
      compact("@context" => "https://schema.org", "@type" => "ProfilePage", "@id" => url, "url" => url,
              "inLanguage" => lang, "dateModified" => resume.dig("meta", "lastModified"),
              "mainEntity" => person(resume, basics, url))
    end

    # jsonify/to_json leave "<" raw, so "</script x" or "<!--<script" in resume text could end or
    # corrupt the <script> block. "\u003c" is the same character to any JSON parser.
    def script(graph)
      JSON.generate(graph).gsub("<", "\\u003c")
    end

    def person(resume, basics, url)
      {
        "@type" => "Person", "@id" => url && "#{url}#person", "name" => basics["name"],
        "jobTitle" => basics["label"], "description" => basics["summary"], "image" => basics["image"],
        "url" => url, "email" => basics["email"], "telephone" => basics["phone"],
        "address" => address(basics["location"]),
        "sameAs" => Array(basics["profiles"]).filter_map { |profile| profile["url"] },
        "worksFor" => organizations(current_roles(resume).map { |role| role["name"] }, "Organization"),
        "alumniOf" => organizations(Array(resume["education"]).map { |item| item["institution"] },
                                    "EducationalOrganization"),
        "hasCredential" => Array(resume["certificates"]).map { |item| credential(item) },
        "award" => Array(resume["awards"]).filter_map { |item| item["title"] },
        "knowsAbout" => Array(resume["skills"]).filter_map { |item| item["name"] },
        "knowsLanguage" => Array(resume["languages"]).map { |item| { "@type" => "Language", "name" => item["language"] } }
      }
    end

    # Current roles only: a start date and no end date. Dateless entries are not current.
    def current_roles(resume)
      Array(resume["work"]).select { |role| role["startDate"] && !role["endDate"] }
    end

    def organizations(names, type)
      names.compact.uniq.map { |name| { "@type" => type, "name" => name } }
    end

    def credential(item)
      { "@type" => "EducationalOccupationalCredential", "name" => item["name"], "url" => item["url"],
        "dateCreated" => item["date"], "recognizedBy" => { "@type" => "Organization", "name" => item["issuer"] } }
    end

    def address(location)
      return unless location

      { "@type" => "PostalAddress", "streetAddress" => location["address"], "postalCode" => location["postalCode"],
        "addressLocality" => location["city"], "addressRegion" => location["region"],
        "addressCountry" => location["countryCode"] }
    end

    # Drops nil/empty values at every depth; a node left with only "@type" is dropped too.
    def compact(value)
      case value
      when Hash
        result = value.transform_values { |item| compact(item) }.reject { |_key, item| blank?(item) }
        result.keys == ["@type"] ? nil : result
      when Array then value.map { |item| compact(item) }.reject { |item| blank?(item) }
      else value
      end
    end

    def blank?(value)
      value.nil? || (value.respond_to?(:empty?) && value.empty?)
    end
  end
end
