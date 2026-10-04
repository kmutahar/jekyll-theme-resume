# JSON Resume export reference

*Audience: site owners*

Reference for the localized JSON Resume export: configuration, visibility, field mappings, normalization, and standard conformance.

The theme generates one JSON Resume document per configured language at
`/<lang>/resume.json`. It also generates `/resume.json` from the default language.
These are static build outputs, prefixed by `baseurl` when served. Existing YAML
keys and HTML layouts continue working without migration.

## Configuration

Exports are enabled by default. The `json_resume` and `social_usernames` settings, their defaults, and the language allowlist rules are in [JSON Resume export](config.md#13-json-resume-export) in the configuration reference.

The root copy is generated only if the default language is allowed and its
localized export succeeds. A collision with an authored page, static file,
collection document, or existing generated page preserves that resource and logs
a warning. A collision at the localized route also suppresses its root copy.
A root-only collision does not suppress the localized export.

Discovery links on CV pages and the `application/json` hosting requirement are covered in [Publish the JSON Resume export](../how-to/publish-json-resume.md).

## Visibility and privacy

- Data comes from `languages.<lang>.data_path`, including nested dot paths and an
  empty path for root data.
- Sections must be enabled and present in `resume_section_order`. Entries require
  exactly `active: true`, except interests, whose HTML list has no active filter.
- Header languages follow `display_header_contact_info` and `resume_section.lang_header`.
  Section languages follow the existing section-placement rules.
- The biography is `header.intro` only when `header_intro: true`; profile `about`
  content is not used as a fallback. Work and volunteer summaries require
  `enable_summary: true`. The avatar requires `resume_avatar: true` and uses the
  same default image as the CV.
- Email is exported when the contact bar or contact-me CTA is visible. Phone and
  location are exported only when the contact bar is visible. `enable_live: true`
  selects each live contact value independently, falling back to its base value
  when the live key is absent or false.
- `json_resume.privacy.export_contact_info: false` omits email, phone, the entire location object, and
  WhatsApp profiles. `social_links.email` is never exported as a social profile.
  This setting does not redact free-form narrative text, usernames, or arbitrary
  URLs, and it does not change the HTML site's contact visibility.

### Contact fields by privacy setting

Two settings decide what personal data leaves in `resume.json`: `display_header_contact_info` (and `resume_looking_for_work`) in `_config.yml`, and `json_resume.privacy.export_contact_info`. Each cell says whether the field is exported.

| Field in `resume.json` | Source | Default export | `display_header_contact_info: false` | `export_contact_info: false` |
|---|---|---|---|---|
| `basics.phone` | `contact_info.phone` (or `phone_live`) | Only when `display_header_contact_info: true` | Omitted | Omitted |
| `basics.email` | `contact_info.email` (or `email_live`) | When `display_header_contact_info: true` **or** `resume_looking_for_work: true` | Omitted unless `resume_looking_for_work: true` | Omitted |
| `basics.location.address`, `postalCode`, `city`, `region`, `countryCode` | `languages.<lang>.address`, `postal_code`, `city`, `region`, `country_code` | Only when `display_header_contact_info: true` | Whole `location` object omitted | Whole `location` object omitted |
| `basics.profiles[]` for `whatsapp` | `social_links.whatsapp` | Exported when configured | Exported | **Omitted** |
| `basics.profiles[]` for every other network | `social_links.<network>` | Exported when configured | Exported | **Still exported** (including `telegram`, `website`, `twitter`) |
| `basics.profiles[].username` | `social_usernames.<network>` | Exported with its profile | Exported with its profile | Exported with its profile |
| `contact_info.dob` | `contact_info.dob` | Never exported | Never exported | Never exported |

Things to know before publishing:

- A postal address is exported whenever the CV header shows contact details, even if you only meant to show it on the page. Set `export_contact_info: false` to keep address, phone and email out of the JSON.
- `export_contact_info: false` does not touch the HTML. The CV still shows whatever `display_header_contact_info` shows.
- Only WhatsApp is treated as a contact channel. Any other `social_links` entry (for example a Telegram handle) is public in the JSON unless you remove it from `social_links`.
- Free-form text (summaries, references, highlights) is exported as written. The setting does not redact it.

The export is a supported subset of the CV, not a lossless representation; see [the data-driven model](../explanation/data-driven-model.md).

## Field mappings

All field names below on the left are existing YAML names or optional additions;
camelCase names on the right belong only to the JSON output.

| Source | JSON Resume target |
|---|---|
| `languages.<lang>.name`, `resume_title` | `basics.name`, `basics.label` |
| `avatar_url` or theme fallback | `basics.image` |
| Selected `contact_info.email`, `phone` | `basics.email`, `basics.phone` |
| Actual CV page URL, falling back to `languages.<lang>.url` | `basics.url`, `meta.canonical` |
| `header.intro` | `basics.summary` |
| Per-language `address`, `postal_code`, `city`, `country_code`, `region` | `basics.location.address`, `postalCode`, `city`, `countryCode`, `region` |
| Supported `social_links.<network>` and `social_usernames.<network>` | `basics.profiles[].network`, `url`, `username` |
| `experience.company`, `position`, `location`, `summary`, `url`, `highlights` | `work[].name`, `position`, `location`, `summary`, `url`, `highlights` |
| `volunteering.company`, `position`, `summary`, `url`, `highlights` | `volunteer[].organization`, `position`, `summary`, `url`, `highlights` |
| `education.uni`, `degree` (fallback `study_type`), `area`, `score` (fallback `gpa`), `courses`, `url` | `education[].institution`, `studyType`, `area`, `score`, `courses`, `url` |
| Work, volunteer, education, project `startdate`, `enddate` | Corresponding `startDate`, `endDate` |
| `certifications.name`, `issuing_organization`, `issue_date`, `credential_url` | `certificates[].name`, `issuer`, `date`, `url` |
| `recognitions.award` (fallback `title`, `recognition`), `organization`, `summary`, `date` | `awards[].title`, `awarder`, `summary`, `date` |
| Four-digit recognition `year`, when `date` is absent | `awards[].date` |
| `skills.skill`, `level_label`, `keywords` | `skills[].name`, `level`, `keywords` |
| `languages.language`, displayed `descrp_short` (header) or `description` (section) | `languages[].language`, `fluency` |
| `interests.name` (fallback `description`), `keywords` | `interests[].name`, `keywords` |
| `projects.project`, `description`, `url`, `highlights`, `keywords` | `projects[].name`, `description`, `url`, `highlights`, `keywords` |
| Project `roles`, or scalar `role` wrapped in an array | `projects[].roles` |
| `publications.name`, `publisher`, `release_date`, `url`, `summary` | `publications[].name`, `publisher`, `releaseDate`, `url`, `summary` |
| `references.name`, `reference` | `references[].name`, `reference` |

Experience and volunteering remain one record per role; company groups and
newest-first role ordering follow the HTML renderer. Supported social networks
are the ones rendered by the existing social include: GitHub, LinkedIn,
Telegram, Twitter, Medium, Dribbble, Facebook, Instagram, Website, WhatsApp,
Dev.to, Flickr, Pinterest, and YouTube. Their configured keys identify networks
in the export. Social URLs remain strings; nested `{url, username}` objects are
not introduced by this feature.

## Optional enrichment

The optional per-section fields that enrich the export are listed in [JSON Resume enrichment](data-schemas.md#json-resume-enrichment). A `skills.yml` example is in [Publish the JSON Resume export](../how-to/publish-json-resume.md#3-optionally-enrich-skills).

## Dates, text, and URLs

Dates must be real calendar dates in `YYYY`, `YYYY-MM`, or `YYYY-MM-DD` form.
**Certificate `issue_date` is the exception:** the pinned schema requires a full
`YYYY-MM-DD`. A partial certificate date remains valid website data but is
omitted from JSON with a warning; the exporter never guesses a month or day.

Blank end dates, `Present` (case-insensitive), and the effective locale's
`present_values` omit `endDate` silently. Free-form `duration`, `durations`, and
education `year` are not parsed into dates. Date of birth is not exported.

Raw HTML tags are removed, block boundaries preserved as newlines, and HTML
entities decoded to Unicode. Markdown and native multilingual characters remain.
Liquid-like text is serialized literally; generated JSON bypasses Liquid and
layouts during Jekyll rendering.

Links must resolve to absolute HTTP(S) URLs. Local paths use `site.url` and
`site.baseurl`; without `site.url`, relative links are omitted with a warning.
Social profile URLs must already be absolute. Invalid email addresses, country
codes, dates, and URLs are omitted with contextual warnings that do not print
field values. Empty fields, arrays, objects, and sections are omitted.

## Standard and omissions

Validation uses the vendored [JSON Resume 1.0.0 schema](https://raw.githubusercontent.com/jsonresume/resume-schema/v1.0.0/schema.json)
(Draft 4) through `json_schemer`. Builds perform no schema downloads. `$schema`
points to this pinned version; `meta.version` is `1.0.0`, and `meta.lastModified`
is the build timestamp in UTC. Schema validation is distinct from source YAML validation. If final schema validation unexpectedly fails,
the document is skipped and no discovery link is emitted.

Associations, standalone courses, generic links, date of birth, skill narrative
descriptions, education honors/summaries, certificate IDs/expiration, and
free-form display date ranges have no mapping in this exporter. Publications and
references export exactly as authored, with no extra fields; a publication's `summary` is exported regardless of `enable_summary`. References are
public once exported, so include only what each referee agreed to publish. Nested certificate courses
remain internal data and are not exported.

## Verification

Test coverage for the export is described in [JSON Resume export coverage](testing-suites.md#json-resume-export-coverage).
