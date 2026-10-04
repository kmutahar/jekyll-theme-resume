# Data schemas (`_data/`)

*Audience: site owners*

YAML schemas for every resume data file. Each resume section is one YAML file in a per-language data folder under `_data/`. The schemas are identical in every language; only the text values are translated.

UI strings, month names, and error page copy are not resume data: they live in the theme's locale files, `_data/locales/<lang>.yml`, documented in [`locale-keys.md`](locale-keys.md).

---

## Overview & Folder Architecture

Each language has one folder of the same 13 files. Why the model works this way: [data-driven model](../explanation/data-driven-model.md). Complete starter data for `en`, `ar`, `es`, `fr`, `de`, `ur` is in [`demo/_data/`](../../demo/_data).

```text
_data/
├── ar/
│   ├── header.yml
│   ├── experience.yml
│   ├── education.yml
│   ├── certifications.yml
│   ├── courses.yml
│   ├── volunteering.yml
│   ├── projects.yml
│   ├── skills.yml
│   ├── recognitions.yml
│   ├── associations.yml
│   ├── languages.yml
│   ├── links.yml
│   ├── publications.yml
│   ├── references.yml
│   └── interests.yml
├── en/
│   ├── header.yml
│   ├── experience.yml
│   ├── education.yml
│   ├── certifications.yml
│   ├── courses.yml
│   ├── volunteering.yml
│   ├── projects.yml
│   ├── skills.yml
│   ├── recognitions.yml
│   ├── associations.yml
│   ├── languages.yml
│   ├── links.yml
│   ├── publications.yml
│   ├── references.yml
│   └── interests.yml
└── ...                       # one folder per language in `languages:`
```

Each language's `data_path` in `_config.yml` points at its folder: see [`config.md`](config.md#3-languages).

The file links below name the English and Arabic demo files; every other language folder mirrors them. Examples use the canonical keys the templates render. If an entry uses only an alias the templates never read (for example `organization` instead of `company`), the validator reports it as a missing required field and names the alias it found; see [validator-cli.md](validator-cli.md#6-validation-rules-catalog-by-section). Optional fields that are absent or empty leave no stray `•` separators.

---

## Resume Content Sections

### 1. Experience (`experience.yml`)

- **Files:** [`_data/en/experience.yml`](../../demo/_data/en/experience.yml) / [`_data/ar/experience.yml`](../../demo/_data/ar/experience.yml)
- **Config Toggle:** `resume_section.experience: true`
- **Behavior:** Roles are grouped by `company` name. Multiple positions at the same employer appear together, sorted by `startdate` (most recent first).

```yaml
# Standard role entry with ISO dates
- company: "Acme Corporation"
  position: "Senior Product Manager"
  startdate: 2022-03-01
  enddate: Present # Use "Present" for ongoing roles
  location: "San Francisco, CA"
  active: true
  summary: "Led cross-functional team of 12 engineers delivering enterprise AI products."

# Role with custom non-continuous duration strings
- company: "State University"
  position: "Adjunct Lecturer"
  durations:
    - duration: "Jun 2020 &ndash; Jan 2021"
    - duration: "&amp; Jun 2022 &ndash; Dec 2022"
  location: "Austin, TX"
  active: true
  summary: "Taught undergraduate courses in software architecture and human-computer interaction."
```

**Display Format:**
- Company name appears as a prominent section item heading.
- Multiple roles at the same company are automatically grouped together.
- Each role displays: **Position • Date Range • Location**.
- Dates render through [`_includes/date-formatter.html`](../../_includes/date-formatter.html) with month names from the active locale: `2022-03-01` and `2022-03` become `March 2022` (`مارس 2022` in Arabic), and `2022` stays `2022`. See [Date Formats](#date-formats--iso-standards).
- Summary paragraph displays below the role details when provided and `enable_summary: true` is configured in `_config.yml`.

---

### 2. Education (`education.yml`)

- **Files:** [`_data/en/education.yml`](../../demo/_data/en/education.yml) / [`_data/ar/education.yml`](../../demo/_data/ar/education.yml)
- **Config Toggle:** `resume_section.education: true`
- **Display fields:** `uni`, `degree`, and `year` (a freeform date string). `uni` is the heading; `degree`, `year` and `location` appear on the details line. `uni`, `degree` and either `year` or `startdate` are required; an entry that sets `institution`/`school` without `uni` fails validation. The validator accepts `startdate` instead of a nonblank `year` (used by the JSON Resume export), but the page shows no date then. Optional `startdate`/`enddate` are validated as ISO dates.

```yaml
- degree: "M.S. in Computer Science"
  uni: "Stanford University"
  year: "Sep 2018 &ndash; Jun 2020"
  location: "Stanford, CA"
  active: true
  awards:
    - award: "Graduate Research Fellowship"
    - award: "Dean's Honors List (2019)"
  summary: "Specialized in distributed systems and natural language processing."

- degree: "B.S. in Software Engineering"
  uni: "State University"
  year: "2014 &ndash; 2018"
  location: "Seattle, WA"
  active: true
  award: "Graduated Magna Cum Laude"
```

**Display Format:**
- University/institution name appears as a heading.
- Second line displays: **Degree • Year • Location**.
- Honors and achievements are rendered as bulleted points under the degree (supporting both single `award` and multiple `awards` lists).
- Summary paragraph displays beneath honors when provided.

---

### 3. Certifications (`certifications.yml`)

- **Files:** [`_data/en/certifications.yml`](../../demo/_data/en/certifications.yml) / [`_data/ar/certifications.yml`](../../demo/_data/ar/certifications.yml)
- **Config Toggle:** `resume_section.certifications: true`

```yaml
# Example with verification credential and URL
- name: "AWS Certified Solutions Architect &ndash; Professional"
  issuing_organization: "Amazon Web Services"
  credential_id: "AWS-PSA-987654"
  credential_url: "https://aws.amazon.com/verification"
  issue_date: 2023-04-15
  expiration: 2026-04-15
  active: true

# Example with nested courses for personal record-keeping
- name: "Business Certificate in Financial Management"
  active: true
  issuing_organization: "State University Executive Education"
  credential_id: "ABC123XYZ"
  credential_url: "https://example.com/cert/ABC123XYZ"
  issue_date: 2024-03-15
  expiration: 2027-03-15
  courses: # Optional: INTERNAL USE ONLY - not displayed on resume
    - name: "Accounting for Corporate Business"
      active: true
      issuing_organization: "State University"
      credential_id: "COURSE123"
      credential_url: "https://example.com/course/COURSE123"
      issue_date: 2024-01-10
      expiration:
```

> [!IMPORTANT]
> The nested `courses:` list within certification entries is designed strictly for **personal record-keeping and linking coursework to parent credentials**. It is **never rendered** on the generated resume. To display coursework visibly on your resume, use [`courses.yml`](#4-courses-coursesyml).

**Display Format:**
- Certification name appears as a bold heading.
- Second line displays: **Issuing Organization • Issue Date – Expiration Date • Credential ID** (the dates render only when `issue_date` is set; `expiration` is shown only alongside it).
- Credential ID is rendered as a clickable link if `credential_url` is provided, and the full destination URL is printed in parentheses in physical and PDF outputs.

---

### 4. Courses (`courses.yml`)

- **Files:** [`_data/en/courses.yml`](../../demo/_data/en/courses.yml) / [`_data/ar/courses.yml`](../../demo/_data/ar/courses.yml)
- **Config Toggle:** `resume_section.courses: true`

```yaml
- name: "Deep Learning Specialization"
  issuing_organization: "DeepLearning.AI / Coursera"
  credential_id: "COURSERA-DL-1234"
  credential_url: "https://coursera.org/verify/COURSERA-DL-1234"
  startdate: 2024-01-10
  enddate: 2024-03-20
  active: true
  summary: "Comprehensive sequence covering CNNs, RNNs, Transformers, and optimization algorithms."
```

**Display Format:**
- Course name appears as a heading.
- Second line displays: **Issuing Organization • Start Date – End Date**. The dates render only when `startdate` is set; `enddate` is shown only alongside it.
- Summary paragraph displays if provided and `enable_summary: true` is configured in `_config.yml`.
- Credential ID displays with an interactive link when `credential_url` is provided.

---

### 5. Volunteering (`volunteering.yml`)

- **Files:** [`_data/en/volunteering.yml`](../../demo/_data/en/volunteering.yml) / [`_data/ar/volunteering.yml`](../../demo/_data/ar/volunteering.yml)
- **Config Toggle:** `resume_section.volunteering: true`

```yaml
- company: "Code for Good"
  position: "Technical Mentor"
  startdate: 2021-06-01
  enddate: Present
  location: "Remote"
  active: true
  summary: "Mentored aspiring engineers from underrepresented backgrounds on web development and open source contribution."
```

**Display Format:**
- Same layout structure as the [Experience](#1-experience-experienceyml) section: grouped by the `company` key (the organization name) and sorted chronologically.
- Displays: **Position • Date Range • Location** followed by the summary paragraph when `enable_summary: true`.

---

### 6. Projects (`projects.yml`)

- **Files:** [`_data/en/projects.yml`](../../demo/_data/en/projects.yml) / [`_data/ar/projects.yml`](../../demo/_data/ar/projects.yml)
- **Config Toggle:** `resume_section.projects: true`

```yaml
- project: "Open Source Data Pipeline"
  role: "Author & Maintainer"
  duration: "Jan 2023 &ndash; Present"
  url: "https://github.com/yourusername/pipeline"
  active: true
  description: "High-throughput streaming ETL pipeline written in Go and Apache Kafka, processing 5M+ daily events."
```

**Display Format:**
- Project title appears as a bold heading (rendered as a clickable link if `url` is specified).
- Second line displays: **Role • Duration**.
- Project description appears as a paragraph below.
- In print and PDF versions, external URLs are automatically echoed in parentheses.

---

### 7. Skills (`skills.yml`)

- **Files:** [`_data/en/skills.yml`](../../demo/_data/en/skills.yml) / [`_data/ar/skills.yml`](../../demo/_data/ar/skills.yml)
- **Config Toggle:** `resume_section.skills: true`

```yaml
- skill: "Cloud Architecture & Infrastructure"
  active: true
  level: 4          # optional integer from 1 to 5; other values produce a validator warning
  description: "Expert in AWS, GCP, Terraform, Docker, and Kubernetes. Designed and deployed multi-region high-availability infrastructure."

- skill: "Product Strategy & Technical Leadership"
  active: true
  description: "Roadmapping, OKR tracking, cross-functional mentoring, agile sprint leadership, and stakeholder communication."
```

**Display Format:**
- Skill name appears as a subheading (`<h4>`).
- Description appears as a detailed narrative paragraph immediately below the subheading.

---

### 8. Recognition (`recognitions.yml`)

- **Files:** [`_data/en/recognitions.yml`](../../demo/_data/en/recognitions.yml) / [`_data/ar/recognitions.yml`](../../demo/_data/ar/recognitions.yml)
- **Config Toggle:** `resume_section.recognitions: true`

> [!NOTE]
> The configuration toggle and render order key is **`recognitions`** (plural), matching the data file **`recognitions.yml`**. The singular `recognition` key was removed in v1.0.0.

```yaml
- award: "Innovator of the Year"
  organization: "Global Tech Summit"
  year: "2023"
  active: true
  summary: "Awarded for exceptional contributions to open-source developer tooling and developer velocity."

- award: "Dean's Excellence Award"
  organization: "State University"
  year: "2019, 2020"
  active: true
  summary: "Recognized for academic achievement and research excellence in computer engineering."
```

**Display Format:**
- Award name appears as a bold heading.
- Second line displays: **Awarding Organization • Year**.
- Summary description appears as a paragraph.

---

### 9. Associations (`associations.yml`)

- **Files:** [`_data/en/associations.yml`](../../demo/_data/en/associations.yml) / [`_data/ar/associations.yml`](../../demo/_data/ar/associations.yml)
- **Config Toggle:** `resume_section.associations: true`

```yaml
- organization: "Association for Computing Machinery (ACM)"
  role: "Senior Member"
  year: "2019 &ndash; Present"
  url: "https://www.acm.org"
  active: true
  summary: "Active contributor to SIGMOD working groups on data systems and data governance."
```

**Display Format:**
- Organization name appears as a heading (clickable link if `url` is provided).
- Second line displays: **Role • Year**.
- Summary paragraph describes candidate involvement and leadership.
- In print mode, the destination URL is echoed in parentheses.

---

### 10. Languages (`languages.yml`)

- **Files:** [`_data/en/languages.yml`](../../demo/_data/en/languages.yml) / [`_data/ar/languages.yml`](../../demo/_data/ar/languages.yml)
- **Config Toggles:**
  - `resume_section.lang_header: true`: Renders a one-line language summary in the header contact block (requires `display_header_contact_info: true`); this replaces the standalone section.
  - `resume_section.languages: true`: Renders a standalone two-column table section.

```yaml
- language: "English"
  description: "Native / Bilingual proficiency"
  descrp_short: "Native" # Used for the header language line
  active: true

- language: "Arabic"
  description: "Professional working proficiency"
  descrp_short: "Professional"
  active: true

- language: "German"
  description: "Elementary working proficiency"
  descrp_short: "Elementary"
  active: true
```

**Display Format:**
- **Table Mode (`resume_section.languages: true`, `lang_header: false`):** Renders a responsive two-column table in the main body. Each entry displays: **Language – Description**.
- **Header Line Mode (`resume_section.lang_header: true`):** Renders one line in the header contact block, `Language (descrp_short)` entries joined by the locale's list separator, using the `descrp_short` attribute. Requires `display_header_contact_info: true`.

---

### 11. Links (`links.yml`)

- **Files:** [`_data/en/links.yml`](../../demo/_data/en/links.yml) / [`_data/ar/links.yml`](../../demo/_data/ar/links.yml)
- **Config Toggle:** `resume_section.links: true`

```yaml
- description: "Technical Blog & Architecture Articles"
  url: "https://blog.yourdomain.com"
  active: true

- description: "GitHub Open Source Dossier"
  url: "https://github.com/yourusername"
  active: true
```

**Display Format:**
- Clean bulleted list of clickable text links.
- External URLs are echoed in parentheses during print and PDF rendering.

---

### 12. Interests (`interests.yml`)

- **Files:** [`_data/en/interests.yml`](../../demo/_data/en/interests.yml) / [`_data/ar/interests.yml`](../../demo/_data/ar/interests.yml)
- **Config Toggle:** `resume_section.interests: true`

```yaml
- description: "Distributed systems research and open-source software"
- description: "Landscape photography and digital storytelling"
- description: "Long-distance trail running and mountaineering"
```

**Display Format:**
- Unordered bulleted list under the "Outside Interests" section heading.
- Does not require an active flag: any item listed in the file will render.

---

### 13. Publications (`publications.yml`)

- **Files:** [`_data/en/publications.yml`](../../demo/_data/en/publications.yml) / [`_data/ar/publications.yml`](../../demo/_data/ar/publications.yml)
- **Config Toggle:** `resume_section.publications: true`

```yaml
- name: "On the Distinction of Tobacco Ashes"
  publisher: "The Strand Magazine"
  release_date: 1889-03-01   # YYYY, YYYY-MM, or YYYY-MM-DD
  url: "https://example.com/monographs/tobacco-ashes"
  summary: "A monograph cataloguing 140 varieties of tobacco ash."
  active: true
```

`name` is required; `publisher`, `release_date`, `url` (http/https) and `summary` are optional.

**Display Format:**
- Name, linked to `url` when set (the URL is echoed in print, `dir="ltr"` in RTL locales).
- `publisher • release date` (localized, same format as certifications).
- `summary` is always shown; it is not gated by `enable_summary`.
- Schema.org `CreativeWork` microdata.

---

### 14. References (`references.yml`)

- **Files:** [`_data/en/references.yml`](../../demo/_data/en/references.yml) / [`_data/ar/references.yml`](../../demo/_data/ar/references.yml)
- **Config Toggle:** `resume_section.references: true`

```yaml
- name: "Dr. John H. Watson, M.D."
  reference: "I have never known a more precise and fearless investigator."
  active: true
```

`name` and `reference` are both required. No other fields exist.

**Display Format:** a `<blockquote>` with the reference text and a `<cite>` naming the referee.

**Privacy:** references are rendered on the page and exported to `resume.json` exactly as written. Publish only what the referee agreed to make public; set `active: false` to hold an entry back.

---

## Header & Executive Summary (`header.yml`)

- **Files:** [`_data/en/header.yml`](../../demo/_data/en/header.yml) / [`_data/ar/header.yml`](../../demo/_data/ar/header.yml)
- **Config Toggle:** `languages.<lang>.header_intro: true` (per language)

Contains the executive bio summary rendered directly beneath the candidate name, job title, and social links bar:

```yaml
# _data/en/header.yml
intro: >-
  Results-oriented engineering leader with 10+ years of experience designing scalable distributed systems, cloud platforms, and bilingual consumer products. Passionate about developer tooling, accessibility, and high-performance architecture.
```

```yaml
# _data/ar/header.yml
intro: >-
  قائد هندسي متميز يتمتع بخبرة تزيد عن 10 سنوات في تصميم الأنظمة الموزعة والمنصات السحابية والتطبيقات ثنائية اللغة. شغوف بأدوات المطورين ومعايير النفاذ الرقمي والبنى التحتية عالية الأداء.
```

**Display Format:**
- Appears as a prominent narrative paragraph immediately below candidate name, title, contact row, and social links in the resume header.
- Only displays when `languages.<lang>.header_intro: true` is set for that language in `_config.yml`.
- Fully supports basic HTML inline formatting (e.g., `<strong>`, `<em>`).

---

## Error Page Copy

Error page text is not resume data. The `error_pages` schema is in [`locale-keys.md`](locale-keys.md#error_pages); the `layout: error` front matter and Home/Reload behavior are in [`layouts.md`](layouts.md#4-errorhtml-multilingual-http-error-suite).

---

## General Guidelines

### Date Formats & ISO Standards

1. **Structured Dates (`startdate`, `enddate`, `issue_date`, `expiration`, recognition `date`):**
   - Use ISO format: `YYYY-MM-DD`, `YYYY-MM`, or `YYYY`. Quoted and unquoted values both work.
   - Every language formats dates through [`_includes/date-formatter.html`](../../_includes/date-formatter.html), using the `months` list in `_data/locales/<lang>.yml`:

     | Value | Default style (`<month> <year>`) | `MDY` style (certifications, courses, date of birth) |
     |---|---|---|
     | `2024-03-15` | March 2024 | March 15, 2024 |
     | `2024-03` | March 2024 | March 2024 |
     | `2024` | 2024 | 2024 |
     | any other text | printed as written | printed as written |
   - For ongoing positions leave `enddate` blank or use a word from the locale's `present_values` (for example `Present`); it renders as the locale's `ui.present`. Accepted words per language: [`locale-keys.md`](locale-keys.md#present-values).

2. **Freeform Display Strings (`year`, `duration`):**
   - Used in education, projects, recognitions, and associations.
   - Use HTML entities like `&ndash;` for en-dash (–) and `&amp;` for ampersand (&).

### Active / Inactive Visibility Flags

Every list section except interests uses the boolean `active:` flag:
- `active: true`: Item renders on the resume.
- `active: false`: Item is preserved in your YAML record but omitted from generated HTML.
- No `active` key: the item does not render either, and the validator warns. `interests.yml` is the exception: its items have no flag and always render.

### YAML Formatting & Special Characters

- Wrap values containing colons, quotes, or dashes in double quotes:
  ```yaml
  name: "AWS Certified: Solutions Architect"
  ```
- Multiline summaries should use YAML folded blocks (`>-`) or literal blocks (`|`):
  ```yaml
  summary: >-
    First line of summary text that will flow continuously
    without unwanted line breaks.
  ```

### Section Mapping Summary

| Section Name | Config Key (`resume_section`) | Render Order Key (`resume_section_order`) | YAML File Name |
|---|---|---|---|
| Experience | `experience` | `experience` | `experience.yml` |
| Education | `education` | `education` | `education.yml` |
| Certifications | `certifications` | `certifications` | `certifications.yml` |
| Courses | `courses` | `courses` | `courses.yml` |
| Volunteering | `volunteering` | `volunteering` | `volunteering.yml` |
| Projects | `projects` | `projects` | `projects.yml` |
| Skills | `skills` | `skills` | `skills.yml` |
| Recognition | `recognitions` | `recognitions` | `recognitions.yml` |
| Associations | `associations` | `associations` | `associations.yml` |
| Languages | `languages` / `lang_header` | `languages` | `languages.yml` |
| Links | `links` | `links` | `links.yml` |
| Interests | `interests` | `interests` | `interests.yml` |
| Publications | `publications` | `publications` | `publications.yml` |
| References | `references` | `references` | `references.yml` |
| Header Intro | `languages.<lang>.header_intro` | *(rendered in header)* | `header.yml` |

## JSON Resume enrichment

Existing data does not need to change. Export mapping and rules: [`json-resume-fields.md`](json-resume-fields.md). For richer exports, add these optional fields:

- Experience and volunteering: `url` and `highlights` (array of strings).
- Education: `area`, `study_type`, `score`, `url`, `courses` (array of strings). Existing `startdate` and `enddate` are supported; display-oriented `year` remains.
- Projects: `startdate`, `enddate`, `roles`, `highlights`, `keywords`. The last three are arrays of strings; existing scalar `role` works without `roles`.
- Recognitions: an ISO `date`, independently of the display-oriented `year`.
- Skills: textual `level_label` and an array of `keywords`. Numeric `level` retains its existing 1–5 meaning and is not converted to an invented proficiency label.
- Interests: `keywords` as an array of strings.
- Per-language config: `postal_code`, `city`, `country_code`, `region`. These are exported as `basics.location` whenever `display_header_contact_info: true`, unless `json_resume.privacy.export_contact_info: false`; see [Contact fields by privacy setting](json-resume-fields.md#contact-fields-by-privacy-setting).

Use `startdate`/`enddate` consistently. No `start_date`/`end_date` aliases are added. The source validator checks added list fields, skill labels, project dates, recognition dates, and relevant URLs; the exporter also validates output formats.

A `skills.yml` example is in [Publish the JSON Resume export](../how-to/publish-json-resume.md#3-optionally-enrich-skills).
