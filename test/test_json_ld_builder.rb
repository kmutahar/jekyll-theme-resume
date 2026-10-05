# frozen_string_literal: true

require "minitest/autorun"
require "json"
require_relative "../lib/jekyll-theme-resume/json_ld_builder"

class JsonLdBuilderTest < Minitest::Test
  Builder = JekyllThemeResume::JsonLdBuilder
  URL = "https://example.org/en/cv/"

  def full
    {
      "basics" => {
        "name" => "Jane", "label" => "Engineer", "summary" => "Plain intro", "image" => "https://example.org/jane.png",
        "url" => URL, "email" => "jane@example.org", "phone" => "+44 1",
        "location" => { "address" => "1 Street", "postalCode" => "N1", "city" => "London", "region" => "England",
                        "countryCode" => "GB" },
        "profiles" => [{ "network" => "GitHub", "url" => "https://github.com/jane" },
                       { "network" => "X", "url" => "https://x.com/jane" }]
      },
      "work" => [{ "name" => "Acme", "position" => "Lead", "startDate" => "2020-02" },
                 { "name" => "OldCo", "startDate" => "2015", "endDate" => "2019" }],
      "education" => [{ "institution" => "University", "studyType" => "BSc" }],
      "certificates" => [{ "name" => "Cert", "issuer" => "Issuer", "url" => "https://example.org/cert", "date" => "2020-02-15" }],
      "awards" => [{ "title" => "Prize" }],
      "skills" => [{ "name" => "Ruby" }],
      "languages" => [{ "language" => "English" }],
      "meta" => { "lastModified" => "2026-10-05T12:00:00Z" }
    }
  end

  def minimal
    { "basics" => { "name" => "Jane", "url" => URL } }
  end

  def with(overrides)
    minimal.merge(overrides) { |_key, old, new| old.is_a?(Hash) ? old.merge(new) : new }
  end

  def person(resume)
    Builder.build(resume, "en")["mainEntity"]
  end

  def blank_values(value, path = "$")
    case value
    when Hash then value.empty? ? [path] : value.flat_map { |key, item| blank_values(item, "#{path}.#{key}") }
    when Array then value.empty? ? [path] : value.each_with_index.flat_map { |item, index| blank_values(item, "#{path}[#{index}]") }
    when nil, "" then [path]
    else []
    end
  end

  def test_full_document_maps_every_field
    expected = {
      "@context" => "https://schema.org", "@type" => "ProfilePage", "@id" => URL, "url" => URL,
      "inLanguage" => "en", "dateModified" => "2026-10-05T12:00:00Z",
      "mainEntity" => {
        "@type" => "Person", "@id" => "#{URL}#person", "name" => "Jane", "jobTitle" => "Engineer",
        "description" => "Plain intro", "image" => "https://example.org/jane.png", "url" => URL,
        "email" => "jane@example.org", "telephone" => "+44 1",
        "address" => { "@type" => "PostalAddress", "streetAddress" => "1 Street", "postalCode" => "N1",
                       "addressLocality" => "London", "addressRegion" => "England", "addressCountry" => "GB" },
        "sameAs" => ["https://github.com/jane", "https://x.com/jane"],
        "worksFor" => [{ "@type" => "Organization", "name" => "Acme" }],
        "alumniOf" => [{ "@type" => "EducationalOrganization", "name" => "University" }],
        "hasCredential" => [{ "@type" => "EducationalOccupationalCredential", "name" => "Cert",
                              "url" => "https://example.org/cert", "dateCreated" => "2020-02-15",
                              "recognizedBy" => { "@type" => "Organization", "name" => "Issuer" } }],
        "award" => ["Prize"], "knowsAbout" => ["Ruby"],
        "knowsLanguage" => [{ "@type" => "Language", "name" => "English" }]
      }
    }
    assert_equal expected, Builder.build(full, "en")
  end

  def test_minimal_document_has_no_empty_keys
    graph = Builder.build(minimal.merge("work" => [], "skills" => [{}], "basics" => minimal["basics"].merge(
      "email" => "", "profiles" => [], "location" => {}
    )), "en")

    assert_equal %w[@context @type @id url inLanguage mainEntity].sort, graph.keys.sort
    assert_equal %w[@type @id name url].sort, graph["mainEntity"].keys.sort
    assert_empty blank_values(graph)
  end

  def test_ids_link_page_and_person
    graph = Builder.build(full, "en")

    assert_equal URL, graph["@id"]
    assert_equal URL, graph["url"]
    assert_equal URL, graph["mainEntity"]["url"]
    assert_equal "#{URL}#person", graph["mainEntity"]["@id"]
  end

  def test_missing_url_omits_all_ids
    resume = full
    resume["basics"].delete("url")
    graph = Builder.build(resume, "en")

    %w[@id url].each do |key|
      refute graph.key?(key), "page #{key}"
      refute graph["mainEntity"].key?(key), "person #{key}"
    end
    assert_equal "Jane", graph["mainEntity"]["name"]
    assert_equal ["Prize"], graph["mainEntity"]["award"]
  end

  def test_works_for_lists_only_current_roles
    work = [{ "name" => "Current", "startDate" => "2020" }, { "name" => "Past", "startDate" => "2010", "endDate" => "2015" },
            { "name" => "Dateless" }]

    assert_equal [{ "@type" => "Organization", "name" => "Current" }], person(with("work" => work))["worksFor"]
  end

  def test_organizations_are_deduped_in_order
    work = [{ "name" => "Acme", "startDate" => "2020" }, { "name" => "Beta", "startDate" => "2021" },
            { "name" => "Acme", "startDate" => "2022" }]
    education = [{ "institution" => "Uni" }, { "institution" => "College" }, { "institution" => "Uni" }]
    result = person(with("work" => work, "education" => education))

    assert_equal(%w[Acme Beta], result["worksFor"].map { |org| org["name"] })
    assert_equal(%w[Uni College], result["alumniOf"].map { |org| org["name"] })
  end

  def test_credentials_map_issuer_url_and_date
    certificates = [{ "name" => "A", "issuer" => "Issuer", "url" => "https://example.org/a", "date" => "2020-01-01" },
                    { "name" => "B" }]
    first, second = person(with("certificates" => certificates))["hasCredential"]

    assert_equal "Issuer", first["recognizedBy"]["name"]
    assert_equal "https://example.org/a", first["url"]
    assert_equal "2020-01-01", first["dateCreated"]
    assert_equal({ "@type" => "EducationalOccupationalCredential", "name" => "B" }, second)
  end

  def test_address_uses_present_parts_only
    partial = { "address" => "1 Street", "postalCode" => nil, "city" => "", "countryCode" => "GB" }

    assert_equal({ "@type" => "PostalAddress", "streetAddress" => "1 Street", "addressCountry" => "GB" },
                 person(with("basics" => { "location" => partial }))["address"])
    refute person(minimal).key?("address")
    empty = { "address" => "", "postalCode" => nil, "city" => "", "region" => nil, "countryCode" => "" }

    refute person(with("basics" => { "location" => empty })).key?("address")
  end

  def test_same_as_preserves_profile_order
    profiles = [{ "url" => "https://b.example" }, { "network" => "None" }, { "url" => "https://a.example" }]

    assert_equal %w[https://b.example https://a.example], person(with("basics" => { "profiles" => profiles }))["sameAs"]
  end

  def test_award_skills_languages
    result = person(with("awards" => [{ "title" => "Prize" }, { "awarder" => "Nobody" }],
                         "skills" => [{ "name" => "Ruby" }, { "level" => "Expert" }],
                         "languages" => [{ "language" => "English" }, { "fluency" => "Native" }]))

    assert_equal ["Prize"], result["award"]
    assert_equal ["Ruby"], result["knowsAbout"]
    assert_equal [{ "@type" => "Language", "name" => "English" }], result["knowsLanguage"]
  end

  def test_in_language_uses_given_key
    assert_equal "zh-Hant", Builder.build(minimal, "zh-Hant")["inLanguage"]
  end

  def test_script_escapes_angle_bracket
    graph = Builder.build(with("basics" => { "name" => "A </script x", "summary" => "<!--<script" }), "en")
    script = Builder.script(graph)

    refute_includes script, "<"
    assert_includes script, "\\u003c"
    assert_equal graph, JSON.parse(script)
  end

  def test_script_round_trips_quotes_and_unicode
    name = "Q\"uote \\ back & amp مرحبا خوش آمدید 🚀 sep end"
    graph = Builder.build(with("basics" => { "name" => name, "label" => "مهندس" }), "ar")
    script = Builder.script(graph)

    assert_equal graph, JSON.parse(script)
    assert_equal name, JSON.parse(script)["mainEntity"]["name"]
    assert_includes script, "مرحبا"
    assert_includes script, "مهندس"
  end

  def test_build_does_not_mutate_input
    resume = full
    snapshot = Marshal.load(Marshal.dump(resume))
    Builder.build(resume, "en")

    assert_equal snapshot, resume
  end
end
