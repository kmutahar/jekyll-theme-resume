# JSON-LD fields reference

*Audience: site owners and theme developers*

Reference for the Schema.org JSON-LD block on each CV page: output shape, field mappings, visibility and privacy rules, and limits. To check the output, see [Validate structured data](../how-to/validate-structured-data.md).

JSON-LD is metadata for search engines and other crawlers. It does not guarantee that an applicant tracking system (ATS) parses the CV, and it does not guarantee rich results in search. Crawlers decide for themselves what to use.

## Output

Each CV page has one `<script type="application/ld+json">` in `<head>`, right after `{% seo %}`. It is a `ProfilePage` whose `mainEntity` is a `Person`.

```json
{
  "@context": "https://schema.org",
  "@type": "ProfilePage",
  "@id": "https://example.org/en/cv/",
  "url": "https://example.org/en/cv/",
  "inLanguage": "en",
  "dateModified": "2026-10-05T12:00:00Z",
  "mainEntity": {
    "@type": "Person",
    "@id": "https://example.org/en/cv/#person",
    "name": "Sherlock Holmes",
    "jobTitle": "Consulting Detective",
    "worksFor": [{ "@type": "Organization", "name": "Acme" }],
    "knowsAbout": ["Ruby"]
  }
}
```

The example is shortened; the full property list is below. The theme builds the block in Ruby (`JsonLdBuilder`) from the [JSON Resume export](json-resume-fields.md) of the same language, then prints it through [`json-ld-resume.html`](includes.md#1a-json-ld-resumehtml). Because it reads the export, inactive entries, live contact values, privacy settings, HTML stripping and URL checks are already applied.

Every empty string, `nil`, empty array and empty object is dropped at every level. A node left with only `@type` is dropped too.

## Field mapping

| Schema.org | JSON Resume source | Rule |
|---|---|---|
| `ProfilePage.@id`, `ProfilePage.url`, `Person.url` | `basics.url` | All omitted when the export has no URL (no `site.url`). Relative values are never emitted. |
| `ProfilePage.inLanguage` | the language key | Same value as `<html lang>`. |
| `ProfilePage.dateModified` | `meta.lastModified` | Build time, UTC, ISO 8601. |
| `Person.@id` | `basics.url` plus `#person` | Omitted when `basics.url` is absent. |
| `name`, `jobTitle`, `description`, `image` | `basics.name`, `basics.label`, `basics.summary`, `basics.image` | `summary` exists only when `header_intro: true`; `image` only when `resume_avatar: true`. |
| `email`, `telephone` | `basics.email`, `basics.phone` | See [Visibility and privacy](#visibility-and-privacy). |
| `address` (`PostalAddress`) | `basics.location` | `address` to `streetAddress`, `postalCode` to `postalCode`, `city` to `addressLocality`, `region` to `addressRegion`, `countryCode` to `addressCountry`. Omitted when no part is set. |
| `sameAs` | `basics.profiles[].url` | Same order as the export. |
| `worksFor` | `work[]` with `startDate` and no `endDate` | Current roles only. Entries with no dates are not current. Deduplicated by name, first-seen order. Type `Organization`. |
| `alumniOf` | `education[].institution` | Type `EducationalOrganization`, deduplicated by name. |
| `hasCredential` | `certificates[]` | `EducationalOccupationalCredential` with `name`, `url`, `dateCreated` (from `date`) and `recognizedBy` (from `issuer`, only when present). |
| `award` | `awards[].title` | List of text. |
| `knowsAbout` | `skills[].name` | List of text. |
| `knowsLanguage` | `languages[].language` | `Language` objects. |

## Visibility and privacy

The block follows the same rules as `resume.json`; see [Visibility and privacy](json-resume-fields.md#visibility-and-privacy) for the table.

- `telephone` and `address` appear only when `display_header_contact_info: true`.
- `email` appears when `display_header_contact_info: true` or `resume_looking_for_work: true`.
- With `enable_live: true`, the live email and phone values are used, as on the page.
- `json_resume.privacy.export_contact_info: false` removes email, phone, address and the WhatsApp profile from the block. There is no separate JSON-LD privacy key.

`json_ld.enabled` is independent of `json_resume.enabled` and `json_resume.languages`. See [JSON-LD structured data](config.md#13a-json-ld-structured-data).

## Not mapped

Volunteering, projects, publications, references, interests, courses, associations and links have no clean `Person` property. They stay in the JSON Resume export and the visible HTML.

## Coexistence with `jekyll-seo-tag`

`{% seo %}` always emits its own `WebPage` JSON-LD and the page's only canonical link; it has no option to turn that off. The theme leaves it in place and does not emit a canonical link of its own. The `ProfilePage` `url` and `@id` equal the canonical URL.

If `site.author` is set, `jekyll-seo-tag` publishes it as the `author` of its block. Set it to the same name as the CV so the two blocks agree.

## Link to the Person microdata

The `.wrapper` element in [`resume.html`](layouts.md#3-resumehtml-resume-every-language) is also a Schema.org `Person` (microdata). It carries `itemid` equal to the JSON-LD `Person.@id`, so parsers can merge the two into one Person. Its `telephone`, `email` and `address` follow the same contact-bar and looking-for-work rules as the JSON-LD block. `json_resume.privacy.export_contact_info` does not apply to the microdata, because it only describes values the page already shows.

## Escaping

The script is serialized with `JSON.generate`, and every `<` is replaced with the six characters `\u003c`, which any JSON parser reads as `<`. Resume text such as `</script>` or `<!--<script` therefore cannot end or corrupt the block. If you override `json-ld-resume.html`, keep this escaping.

Test coverage: [Testing suites](testing-suites.md).
