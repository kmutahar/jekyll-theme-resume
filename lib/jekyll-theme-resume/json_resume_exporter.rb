# frozen_string_literal: true

require "json"
require "yaml"
require "date"
require "time"
require "cgi"
require "addressable/uri"
require "kramdown/utils/entities"
require "json_schemer"

module JekyllThemeResume
  # Maps the existing CV data contract to JSON Resume without changing source keys.
  # Returns nil when final validation fails; callers must never publish that export.
  class JsonResumeExporter
    SCHEMA_URL = "https://raw.githubusercontent.com/jsonresume/resume-schema/v1.0.0/schema.json"
    SCHEMA = JSONSchemer.schema(JSON.parse(File.read(File.join(__dir__, "schemas/json_resume_v1.0.0.json"), encoding: "UTF-8")))
    SECTIONS = {
      "experience" => "work", "volunteering" => "volunteer", "education" => "education",
      "certifications" => "certificates", "recognitions" => "awards", "skills" => "skills",
      "languages" => "languages", "interests" => "interests", "projects" => "projects",
      "publications" => "publications", "references" => "references"
    }.freeze
    FIELDS = {
      "experience" => { "name" => "company", "position" => "position", "location" => "location" },
      "volunteering" => { "organization" => "company", "position" => "position" },
      "education" => { "institution" => "uni", "studyType" => %w[degree study_type], "area" => "area", "score" => %w[score gpa] },
      "certifications" => { "name" => "name", "issuer" => "issuing_organization" },
      "recognitions" => { "title" => %w[award title recognition], "awarder" => "organization", "summary" => "summary" },
      "skills" => { "name" => "skill", "level" => "level_label" },
      "languages" => { "language" => "language" },
      "interests" => { "name" => %w[name description] },
      "projects" => { "name" => "project", "description" => "description" },
      "publications" => { "name" => "name", "publisher" => "publisher", "summary" => "summary" },
      "references" => { "name" => "name", "reference" => "reference" }
    }.freeze
    LIST_FIELDS = {
      "experience" => %w[highlights], "volunteering" => %w[highlights], "education" => %w[courses],
      "skills" => %w[keywords], "interests" => %w[keywords], "projects" => %w[highlights keywords]
    }.freeze
    NETWORKS = (YAML.safe_load_file(File.expand_path("../../_data/social_networks.yml", __dir__)).map { |n| n["key"] } -
                %w[email]).freeze
    COUNTRY_CODES = %w[
      AD AE AF AG AI AL AM AO AQ AR AS AT AU AW AX AZ BA BB BD BE BF BG BH BI BJ BL BM BN BO BQ BR BS BT BV BW BY BZ
      CA CC CD CF CG CH CI CK CL CM CN CO CR CU CV CW CX CY CZ DE DJ DK DM DO DZ EC EE EG EH ER ES ET FI FJ FK FM FO FR
      GA GB GD GE GF GG GH GI GL GM GN GP GQ GR GS GT GU GW GY HK HM HN HR HT HU ID IE IL IM IN IO IQ IR IS IT JE JM JO JP
      KE KG KH KI KM KN KP KR KW KY KZ LA LB LC LI LK LR LS LT LU LV LY MA MC MD ME MF MG MH MK ML MM MN MO MP MQ MR MS
      MT MU MV MW MX MY MZ NA NC NE NF NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PN PR PS PT PW PY QA RE RO RS
      RU RW SA SB SC SD SE SG SH SI SJ SK SL SM SN SO SR SS ST SV SX SY SZ TC TD TF TG TH TJ TK TL TM TN TO TR TT TV TW
      TZ UA UG UM US UY UZ VA VC VE VG VI VN VU WF WS YE YT ZA ZM ZW
    ].freeze

    def self.export(site, lang)
      new(site, lang).export
    end

    def initialize(site, lang)
      @site = site
      @config = site.config
      @lang = lang
      @language = hash(hash(@config["languages"])[lang])
      @options = hash(@config["json_resume"])
      @sections = hash(@config["resume_section"])
      @data = @language["data_path"].to_s.split(".").reduce(site.data) { |data, key| hash(data)[key] }
      @data = hash(@data)
      locales = hash(site.data["locales"])
      @locale = hash(locales[lang] || locales[@config["default_lang"]])
    end

    def export
      result = { "$schema" => SCHEMA_URL, "basics" => basics }
      result["meta"] = metadata(result["basics"]["url"])
      SECTIONS.each do |section, target|
        next unless visible_section?(section)

        result[target] = entries(section).map { |entry| map_entry(section, entry) }.reject(&:empty?)
      end
      result = compact(result)
      errors = SCHEMA.validate(result).to_a
      return result if errors.empty?

      # Never log resume values or contact data in build output.
      paths = errors.map { |error| error["data_pointer"] }.uniq.join(", ")
      Jekyll.logger.error "JSON Resume:", "#{@lang}: schema validation failed at #{paths}; skipping export"
      nil
    end

    private

    def hash(value)
      value.is_a?(Hash) ? value : {}
    end

    def compact(value)
      case value
      when Hash
        value.transform_values { |item| compact(item) }.reject { |_key, item| empty?(item) }
      when Array
        value.map { |item| compact(item) }.reject { |item| empty?(item) }
      else
        value
      end
    end

    def empty?(value)
      value.nil? || (value.respond_to?(:empty?) && value.empty?)
    end

    def text(value)
      return unless value.is_a?(String) || value.is_a?(Numeric)

      # Decode entities first: an encoded tag like &lt;script&gt; must become
      # a literal tag *before* strip_html runs, or it survives untouched.
      decoded = value.to_s.gsub(/&(#x[0-9a-f]+|#\d+|[a-z][a-z0-9]+);/i) { |entity| decode_entity(entity) }
      strip_html(decoded).gsub("\r\n", "\n").tr("\u00a0", " ").gsub(/\n{3,}/, "\n\n").strip
    end

    # Single-pass regex tag removal can leave a match behind: deleting one
    # fragment can make two separated pieces adjacent and form a new tag a
    # single pass never rechecks. Loop to a fixed point so nothing survives.
    def strip_html(str)
      loop do
        stripped = str.gsub(%r{<script\b[^>]*>.*?</\s*script(?:[\s/][^>]*)?>}mi, "")
                      .gsub(%r{<br\s*/?\s*>|</\s*(?:p|div|li|ul|ol|h[1-6])\s*>}i, "\n")
                      .gsub(%r{</?[a-zA-Z][\w:-]*(?:\s[^<>]*?)?\s*/?>}, "")
        break str if stripped == str

        str = stripped
      end
    end

    def decode_entity(entity)
      return CGI.unescapeHTML(entity) if entity.start_with?("&#")

      Kramdown::Utils::Entities.entity(entity[1...-1]).code_point.chr(Encoding::UTF_8)
    rescue Kramdown::Error, RangeError
      entity
    end

    def warning(field, reason)
      Jekyll.logger.warn "JSON Resume:", "#{@lang}.#{field}: #{reason}; omitted"
      nil
    end

    def first(entry, fields)
      Array(fields).map { |field| entry[field] }.find { |value| !empty?(value) }
    end

    def truthy?(value)
      !value.nil? && value != false
    end

    def visible_section?(section)
      if section == "languages"
        return true if header_languages?
        return false if @sections["lang_header"] == true
      end
      truthy?(@sections[section]) && Array(@config["resume_section_order"]).include?(section)
    end

    def header_languages?
      @config["display_header_contact_info"] == true && truthy?(@sections["lang_header"])
    end

    def entries(section)
      list = @data[section]
      return [] unless list.is_a?(Array)

      list = list.select { |entry| entry.is_a?(Hash) && (section == "interests" || entry["active"] == true) }
      return list unless %w[experience volunteering].include?(section)

      list.group_by { |entry| entry["company"] }.values.flat_map do |roles|
        roles.sort_by { |entry| entry["startdate"].to_s }.reverse
      end
    end

    def basics
      result = { "name" => text(@language["name"]), "label" => text(@language["resume_title"]), "url" => canonical_url }
      result["summary"] = text(hash(@data["header"])["intro"]) if @language["header_intro"] == true
      if @config["resume_avatar"] == true
        result["image"] = absolute_url(first(@config, "avatar_url") || "/assets/images/Profile-min.jpg", "basics.image")
      end
      result.merge!(contacts) if export_contacts?
      result["profiles"] = profiles
      result
    end

    def export_contacts?
      hash(@options["privacy"])["export_contact_info"] != false
    end

    def contacts
      result = {}
      if @config["display_header_contact_info"] == true
        result["phone"] = text(contact("phone"))
        result["location"] = location
      end
      if @config["display_header_contact_info"] == true || @config["resume_looking_for_work"] == true
        email = text(contact("email"))
        result["email"] = valid_format(email, "email", "basics.email")
      end
      result
    end

    def contact(key)
      info = hash(@config["contact_info"])
      live = info["#{key}_live"]
      @config["enable_live"] == true && truthy?(live) ? live : info[key]
    end

    def location
      result = { "address" => text(@language["address"]), "postalCode" => text(@language["postal_code"]),
                 "city" => text(@language["city"]), "region" => text(@language["region"]) }
      country = text(@language["country_code"])
      result["countryCode"] = if empty?(country) || COUNTRY_CODES.include?(country)
                                country
                              else
                                warning("basics.location.countryCode", "expected ISO-3166-1 alpha-2 code")
                              end
      result
    end

    def profiles
      socials = hash(@config["social_links"])
      usernames = hash(@config["social_usernames"])
      NETWORKS.filter_map do |network|
        next if network == "whatsapp" && !export_contacts?
        next if empty?(socials[network])

        url = absolute_url(socials[network], "basics.profiles.#{network}.url", relative: false)
        next unless url

        { "network" => network, "username" => text(usernames[network]), "url" => url }
      end
    end

    def canonical_url
      page = @site.pages.find { |item| item.data["layout"] == "resume" && item.data["lang"] == @lang }
      absolute_url(page ? page.url : @language["url"], "basics.url")
    end

    def metadata(canonical)
      { "version" => "1.0.0", "lastModified" => @site.time.getutc.iso8601, "canonical" => canonical }
    end

    def map_entry(section, entry)
      result = FIELDS.fetch(section).to_h { |target, source| [target, text(first(entry, source))] }
      Array(LIST_FIELDS[section]).each do |field|
        result[field] = string_list(entry[field], "#{section}.#{field}")
      end
      add_dates_and_url(result, section, entry)
      result["summary"] = text(entry["summary"]) if %w[experience volunteering].include?(section) && @config["enable_summary"] == true
      if section == "languages"
        result["fluency"] = text(entry[header_languages? ? "descrp_short" : "description"])
      end
      result["roles"] = project_roles(entry) if section == "projects"
      compact(result)
    end

    def project_roles(entry)
      return string_list(entry["roles"], "projects.roles") if entry.key?("roles")

      [text(entry["role"])]
    end

    def string_list(value, field)
      return if value.nil?
      return warning(field, "expected an array of strings") unless value.is_a?(Array)

      value.filter_map do |item|
        item.is_a?(String) ? text(item) : warning(field, "expected a string item")
      end
    end

    def add_dates_and_url(result, section, entry)
      if %w[experience volunteering education projects].include?(section)
        result["startDate"] = date(entry["startdate"], "#{section}.startdate")
        result["endDate"] = date(entry["enddate"], "#{section}.enddate", ongoing: true)
        result["url"] = absolute_url(entry["url"], "#{section}.url")
      elsif section == "certifications"
        result["date"] = date(entry["issue_date"], "certifications.issue_date", full: true)
        result["url"] = absolute_url(entry["credential_url"], "certifications.credential_url")
      elsif section == "publications"
        result["releaseDate"] = date(entry["release_date"], "publications.release_date")
        result["url"] = absolute_url(entry["url"], "publications.url")
      elsif section == "recognitions"
        value = entry["date"] || (entry["year"] if entry["year"].to_s.match?(/\A\d{4}\z/))
        result["date"] = date(value, "recognitions.date")
      end
    end

    def date(value, field, ongoing: false, full: false)
      return if value.nil?

      value = value.strftime("%Y-%m-%d") if value.is_a?(Date) || value.is_a?(Time)
      str = value.to_s.strip
      return if str.empty?
      return if ongoing && (["present"] + Array(@locale["present_values"]).map { |item| item.to_s.downcase }).include?(str.downcase)

      pattern = full ? /\A[12]\d{3}-\d{2}-\d{2}\z/ : /\A[12]\d{3}(?:-\d{2}(?:-\d{2})?)?\z/
      raise ArgumentError unless pattern.match?(str)

      parts = str.split("-").map(&:to_i)
      Date.new(parts[0], parts[1] || 1, parts[2] || 1)
      str
    rescue ArgumentError
      warning(field, full ? "expected a valid YYYY-MM-DD date" : "expected a valid ISO date")
    end

    def valid_format(value, format, field)
      return if empty?(value)
      return value if JSONSchemer.schema({ "type" => "string", "format" => format }).valid?(value)

      warning(field, "invalid #{format}")
    end

    def absolute_url(value, field, relative: true)
      return if empty?(value)
      return warning(field, "expected a URL string") unless value.is_a?(String)

      uri = Addressable::URI.parse(value.strip)
      if uri.relative? && relative && !@config["url"].to_s.empty?
        root = @config["url"].to_s.sub(%r{/+\z}, "")
        base = @config["baseurl"].to_s.gsub(%r{\A/+|/+\z}, "")
        uri = Addressable::URI.parse([root, base, value.sub(%r{\A/+}, "")].reject(&:empty?).join("/"))
      end
      return warning(field, "expected an absolute HTTP(S) URL (configure site.url for local paths)") unless
        %w[http https].include?(uri.scheme) && !uri.host.to_s.empty? && uri.userinfo.nil?

      valid_format(uri.normalize.to_s, "uri", field)
    rescue Addressable::URI::InvalidURIError, ArgumentError
      warning(field, "invalid URL")
    end
  end
end
