# Configuration reference (`_config.yml`)

*Audience: site owners*

Every setting the theme reads from a consuming site's `_config.yml`. The annotated master copy is [`_config.sample.yml`](../../_config.sample.yml); the build reads your site’s `_config.yml`, not the sample automatically. Templates, generators, and the gemspec define current behavior.

Per-language settings (name, title, address, data path, URL) live under `languages.<lang>`. Direction, fonts, and UI strings are not config at all: they come from `_data/locales/<lang>.yml` (see [Locale keys](locale-keys.md)). Upgrading from v0.9.0? See [Migrate from v0.9 to v1.0](../how-to/migrate-v0.9-to-v1.0.md). The requirements (Ruby, Jekyll, loading the theme through `group :jekyll_plugins`) are listed in [Getting started](../tutorials/getting-started.md).

## Configuration Reference

### 1. Site Identity

| Setting | Type | Default | Description |
|---|---|---|---|
| `theme` | String | | **Required.** `jekyll-theme-resume`. |
| `title` | String | `""` | **Required.** Site title for SEO tags, avatar link title, and footers. |
| `description` | String | `""` | Site summary emitted by `{% seo %}`. |
| `url` | String | `""` | **Required.** Protocol and domain (e.g., `https://example.com`). Used for absolute hreflang URLs. |
| `baseurl` | String | `""` | Subdirectory path if the site is not served from the domain root. |
| `timezone` | String | unset (system time zone; the sample sets `UTC`) | Timezone for date rendering (e.g., `America/New_York`, `Asia/Riyadh`). Jekyll core key. |

The page language and text direction are not site settings. Every layout resolves the language from `page.lang`, then `default_lang`, then `en`, and reads `direction` from that language's locale file.

---

### 2. Favicons & Web App Manifest

The theme ships a favicon suite under `assets/favicon/resume/`. Override any asset with a site-level path:

| Setting | Type | Default | Description |
|---|---|---|---|
| `favicon` | String | `"assets/favicon/resume/favicon.ico"` | Primary `.ico` shortcut icon. |
| `apple_touch_icon` | String | `"assets/favicon/resume/apple-touch-icon.png"` | 180x180 PNG icon for iOS home screens. |
| `favicon_32` | String | `"assets/favicon/resume/favicon-32x32.png"` | 32x32 browser favicon. |
| `favicon_16` | String | `"assets/favicon/resume/favicon-16x16.png"` | 16x16 browser favicon. |

All favicon paths pass through `relative_url` in [`_includes/shared-head.html`](../../_includes/shared-head.html), so they work under a `baseurl`.

---

### 3. Languages

One entry per language, keyed by language code. The same code names the page's `lang`, the locale file `_data/locales/<code>.yml`, and (usually) the data folder.

| Setting | Type | Description |
|---|---|---|
| `languages.<lang>.data_path` | String | **Required.** Data folder under `_data/`. Dot paths select nested folders (`"2025-06.v1"` reads `_data/2025-06/v1/`); `""` reads `_data/` itself. |
| `languages.<lang>.url` | String | CV permalink used by page generation, profile CV buttons, the language switcher fallback, and error Home buttons when no profile page exists. |
| `languages.<lang>.about` | String | Profile-page bio; accepts Markdown, HTML, or plain text. |
| `languages.<lang>.name_html` | String | Optional profile-page name markup. Without it the final space-separated word in `name` is bolded. Keep `name` plain text for other uses. |
| `languages.<lang>.header_intro` | Boolean | `true` renders `intro` from this language's `header.yml` below the header. |
| `languages.<lang>.name` | String | Full name shown in the resume header. |
| `languages.<lang>.resume_title` | String | Job title shown under the name. |
| `languages.<lang>.address` | String | Location shown in the contact row and in Schema.org microdata. |
| `languages.<lang>.avatar_alt` | String | Avatar alt text. Falls back to `name`, then the locale's `ui.photo_alt`. |
| `languages.<lang>.postal_code`, `city`, `country_code`, `region` | String | Optional. Exported as `basics.location.postalCode`, `city`, `countryCode`, and `region` in the JSON Resume file; not shown on the page. An invalid `country_code` is omitted with a warning. |
| `languages.<lang>.auto_generate_pages` | Boolean | Per-language override of `resume_auto_generate_pages` below. Set `false` to require a hand-authored page for just this language even when auto-generation is on globally, or `true` to auto-generate just this language even when it's off globally. |
| `default_lang` | String | Language used when a page has no `lang`, for the hreflang `x-default` link, and for error page button labels. Default `en`. |
| `resume_auto_generate_pages` | Boolean | Default `true`. When a `languages.<lang>` entry has no hand-authored CV (`layout: resume`) or profile (`layout: profile`) page, the theme synthesizes one automatically at `languages.<lang>.url` (CV) and `/` for `default_lang` or `/<lang>/` for any other language (profile), each carrying `t_id: resume` / `t_id: profile` so hreflang and the language switcher match them like any hand-authored page. A hand-authored page for a given `layout`+`lang` always wins over auto-generation. Set `false` to require every language to have its own hand-authored page; a language left without a page (auto-generation off and no hand-authored file) logs a build warning instead of failing silently. |

```yaml
languages:
  en:
    data_path: en
    url: /en/cv/
    header_intro: true
    name: "Jane Doe"
    resume_title: "Senior Product Manager"
    address: "San Francisco, CA"
    avatar_alt: "Jane Doe - Professional Profile"
  ar:
    data_path: ar
    url: /ar/cv/
    header_intro: true
    name: "جين دو"
    resume_title: "مديرة منتج أولى"
    address: "سان فرانسيسكو، كاليفورنيا"
    avatar_alt: "جين دو - الصورة الشخصية"

default_lang: en
```

**Note:** a page occupying the intended permalink also prevents generation, even if its layout differs. Profile generation does not require a CV URL; CV generation does. Disabled generation or a missing CV URL produces a warning when the corresponding page is absent.

Adding a language beyond the six shipped ones: [Add a language](../how-to/add-a-language.md).

---

### 4. Profile Picture / Avatar Settings

[`_includes/avatar.html`](../../_includes/avatar.html) renders the avatar. Alt text is per language (`languages.<lang>.avatar_alt`, section 3).

| Setting | Type | Default | Description |
|---|---|---|---|
| `resume_avatar` | Boolean | unset (hidden) | `true` shows the avatar in the resume header. Must be a Boolean. |
| `avatar_url` | String | `"/assets/images/Profile-min.jpg"` | Local path (passed through `relative_url`) or external URL (anything containing a scheme, used as-is). Only `http`/`https` schemes are allowed: `javascript:`, `data:`, `file:` and others are a validator error and the avatar is not rendered. The theme does not ship the default file: supply it or set `avatar_url`. |
| `avatar_link` | String / Boolean | `"/"` | Link destination: a relative path or `http`/`https`/`mailto`/`tel` URL. `false`, or a disallowed scheme, renders a plain `<img>`. |
| `avatar_link_target` | String | `"_self"` | Link `target` attribute. |

```yaml
resume_avatar: true
avatar_url: "assets/images/profile.jpg"   # or "https://cdn.example.com/avatar.jpg"
avatar_link: "/"
avatar_link_target: "_self"
```

---

### 5. Contact Information

Language-neutral contact details. The address is per language (`languages.<lang>.address`, section 3).

| Setting | Type | Default | Description |
|---|---|---|---|
| `contact_info.email` | String | `""` | Shown in the contact row and used by the contact button when `resume_looking_for_work: true`. |
| `contact_info.phone` | String | `""` | Primary phone number. |
| `contact_info.dob` | Date | unset | Date of birth (`YYYY-MM-DD`), formatted with the locale's month names. |
| `contact_info.email_live` | String | `""` | Replaces `email` when `enable_live: true`. |
| `contact_info.phone_live` | String | `""` | Replaces `phone` when `enable_live: true`. |

```yaml
contact_info:
  email: "jane.doe@example.com"
  phone: "+1 555 555 5555"
  dob: 1992-05-14
  # email_live: "live@janedoe.com"
  # phone_live: "+1 555 000 0000"
```

---

### 6. Social Media Links

[`_includes/social-links.html`](../../_includes/social-links.html) renders an icon for each configured platform; [`_includes/print-social-links.html`](../../_includes/print-social-links.html) prints the supported platform list as text, labelled from the locale's `ui.social_labels`. Only supported, configured platforms render. `mastodon` currently adds `rel="me"` metadata in the default and profile layouts; it has no social icon or print-list entry yet.

`email` renders a `mailto:` link with an accessible label. Every other key takes a full `http`/`https` URL (`whatsapp` is a URL such as `https://wa.me/1234567890`). A value with any other scheme is a validator error and renders no link.

```yaml
social_links:
  email: "jane.doe@example.com"
  github: https://github.com/yourusername
  linkedin: https://www.linkedin.com/in/yourhandle/
  twitter: https://twitter.com/yourhandle
  telegram: https://t.me/yourhandle
  medium: https://medium.com/@yourhandle
  website: https://yourwebsite.com
  whatsapp: https://wa.me/1234567890
  instagram: https://instagram.com/yourhandle
  facebook: https://facebook.com/yourhandle
  youtube: https://youtube.com/@yourhandle
  devto: https://dev.to/yourhandle
  dribbble: https://dribbble.com/yourhandle
  flickr: https://flickr.com/people/yourhandle
  pinterest: https://pinterest.com/yourhandle
  discord: https://discord.gg/yourinvite
  behance: https://behance.net/yourhandle
  # mastodon emits <link rel="me"> in default.html and profile.html for Fediverse verification:
  mastodon: https://mastodon.social/@yourhandle
```

---

### 7. Resume Display & Behavior Controls

| Setting | Type | Default | Description |
|---|---|---|---|
| `resume_language_switcher` | Boolean | `true` | Floating switcher listing every other entry in `languages`. `false` hides it; `language_switcher: false` in page front matter hides it on one page. |
| `display_header_contact_info` | Boolean | unset (hidden) | `true` shows the phone, email, address, and date-of-birth row in the header. |
| `resume_looking_for_work` | Boolean / omitted | omitted | `true`: contact button; `false`: "not looking" pill; omitted: nothing. |
| `enable_summary` | Boolean | `false` | Show `summary` fields under roles and courses. |
| `enable_live` | Boolean | unset | `true` uses `phone_live` and `email_live` instead of `phone` and `email`. An explicit `false` also adds the print-only footer with the page's canonical URL (omitting the key does not). |
| `resume_print_social_links` | Boolean | unset (hidden) | `true` prints the text list of social links on paper and PDF. |

The header intro toggle is per language: `languages.<lang>.header_intro` (section 3).

```yaml
resume_language_switcher: true
display_header_contact_info: true
resume_looking_for_work: true
enable_summary: false
enable_live: false
resume_print_social_links: true
```

---

### 8. Resume Sections Toggle & Order

[`_includes/resume-section.html`](../../_includes/resume-section.html) renders one section per entry in `resume_section_order`, for every language. A section branch renders when its `resume_section.<name>` flag is truthy; use YAML booleans. Missing or empty data can leave a section heading without items. Section headings come from the locale's `ui.section_titles`.

```yaml
resume_section:
  experience: true
  education: true
  certifications: true
  courses: true
  volunteering: true
  projects: true
  associations: true
  skills: true
  recognitions: false    # plural only; the singular `recognition` key was removed in v1.0.0
  languages: false
  lang_header: true      # compact language list in the header (needs display_header_contact_info: true); suppresses the full languages section
  interests: false
  links: false
  publications: false
  references: false

resume_section_order:
  - experience
  - education
  - certifications
  - courses
  - volunteering
  - projects
  - associations
  - skills
  - recognitions
  - languages
  - interests
  - links
  - publications
  - references
```

---

### 9. Styling, Fonts & Dark Mode

| Setting | Type | Default | Description |
|---|---|---|---|
| `dark_mode` | String / Boolean | `"auto"` | `"auto"`: CSS-only `prefers-color-scheme`, no toggle. `"enabled"` or `true`: floating toggle with `localStorage` persistence. `false`, or any other value such as `"disabled"`: no toggle. |
| `resume_theme` | String | `"default"` | Added as a `theme-<value>` body class. `no-custom-fonts` also stops web font loading (same effect as `disable_google_fonts: true`). |
| `disable_google_fonts` | Boolean | `false` | `true` stops the resume layout from loading any locale `font_url` or the default Lora and Open Sans stylesheet. Supply the font yourself, or set `font_family` to a system font in a site locale override. |

Page front matter `dark_mode: false` / `true` controls the toggle on one page. These settings do not disable the system-preference CSS or the stored-preference script; `false` hides the button rather than forcing a light palette.

Per-language fonts (`font_url`, `font_family`) are locale settings, not `_config.yml` settings: see [Override locale strings](../how-to/override-locale-strings.md). Why dark mode is off in print: [Dark mode approach](../explanation/dark-mode-approach.md).

---

### 10. Analytics Configuration

Configure at most one provider.

| Setting | Type | Description |
|---|---|---|
| `analytics.gtm` | String | Google Tag Manager container ID (`"GTM-XXXXXXX"`). Injects the `<head>` script and the `<body>` `<noscript>` iframe. |
| `analytics.gtag` | String | Google Analytics 4 Measurement ID (`"G-XXXXXXXXXX"`). Injects async `gtag.js`. |

```yaml
analytics:
  # gtm: "GTM-XXXXXXX"
  # gtag: "G-XXXXXXXXXX"
```

---

### 11. Build-Time Validation

The validator runs on every build by default, logs findings, and never fails the build unless strict mode is on. Full reference: [`validator-cli.md`](validator-cli.md).

| Setting | Type | Default | Description |
|---|---|---|---|
| `validate_resume` | Boolean | on | Set to `false` to skip validation during builds. |
| `validate_resume_strict` | Boolean | `false` | `true` aborts the build when validation finds errors. |
| `validate_resume_fail_on_warnings` | Boolean | `false` | With strict mode, also abort on warnings. |

```yaml
# validate_resume: false        # opt out
validate_resume_strict: false
```

---

### 12. Jekyll Build Settings & Plugins

```yaml
plugins:
  - jekyll-theme-resume
  - jekyll-feed
  - jekyll-seo-tag
  - jekyll-sitemap
  - jekyll-redirect-from

include:
  - _redirects
  - .well-known/
  - _pages/
  - _posts/

exclude:
  - scratch.md
  - README.md
  - Gemfile*
  - vendor/
  - node_modules/
  - "*.gemspec"
  - netlify.toml
  - vercel.json
  - WARP.md
  - scripts/

defaults: []
```

---

### 13. JSON Resume export

Exports are on by default. Every key is optional.

| Setting | Type | Default | Description |
|---|---|---|---|
| `json_resume.enabled` | Boolean | `true` | `false` disables all exports. |
| `json_resume.root_export` | Boolean | `true` | `false` disables only the root `/resume.json` copy. |
| `json_resume.languages` | Array | `[]` | Missing or empty means every key in `site.languages`. A nonempty list is an allowlist; unknown languages are warned about and ignored. A malformed non-array value skips generation. Language codes may contain letters, digits, and internal hyphens or underscores; route separators and traversal characters are rejected. |
| `json_resume.privacy.export_contact_info` | Boolean | `true` | `false` omits email, phone, location and the WhatsApp profile from the export. With `true`, phone and location are exported only if `display_header_contact_info: true`, and email only if that or `resume_looking_for_work` is `true`. |
| `social_usernames.<network>` | String | unset | Optional profile username. `social_links` values remain URL strings. |

```yaml
json_resume:
  enabled: true
  root_export: true
  languages: [] # Missing or empty means every key in site.languages
  privacy:
    export_contact_info: true

# Optional usernames; existing social_links values remain URL strings.
social_usernames:
  github: octocat
```

Routes, collision rules, visibility, and field mappings: [JSON Resume export configuration and privacy](json-resume-fields.md#configuration).

### 14. Content Security Policy

The theme ships no CSP header (static sites set headers at the host). It does emit inline code, so a strict `script-src` needs a hash for each inline script, or `'unsafe-inline'`.

| Inline code | Where | Directive that governs it |
|---|---|---|
| Anti-FOUC theme detector (reads `localStorage`, sets `data-theme`) | `<head>`, every page (`shared-head.html`) | `script-src` |
| Dark-mode toggle handler | `dark-mode-toggle.html`, when the toggle is enabled | `script-src` |
| Error-page language detection | `404`/`403`/`500`/`503` pages (`error.html`) | `script-src` |
| Google Tag Manager or `gtag` snippet | `analytics-head.html`, when `analytics.gtm` / `analytics.gtag` is set | `script-src`, plus `connect-src`/`img-src`/`frame-src` for Google hosts |
| Locale font and line-height variables | `<style>` in `resume.html` | `style-src` |
| `onclick="window.location.reload();"` on the error-page Reload button | 500/503 error pages | `script-src-attr` |
| Some `style="..."` attributes (project and association titles, GTM `<noscript>` iframe) | resume sections, `analytics-body.html` | `style-src-attr` |

The language switcher is plain links and needs no script. `<script type="application/json">` blocks are data, not executed, and are not covered by CSP.

Starting point without analytics (hashes come from the command below):

```text
Content-Security-Policy:
  default-src 'self';
  script-src 'self' 'sha256-...' 'sha256-...';
  style-src 'self' 'sha256-...';
  style-src-attr 'unsafe-inline';
  script-src-attr 'none';
  img-src 'self' https: data:;
  object-src 'none'; base-uri 'self'; frame-ancestors 'self'
```

- `script-src-attr 'none'` blocks the error-page Reload `onclick`; allow it with `'unsafe-hashes' 'sha256-<hash of window.location.reload();>'` if you keep that button.
- `style-src-attr 'unsafe-inline'` covers the few inline `style` attributes; removing it needs those attributes moved into CSS.
- With analytics, add the Google hosts you use (for GA4: `https://www.googletagmanager.com` in `script-src`, `https://*.google-analytics.com` in `connect-src`). Tag Manager can load arbitrary tags, which a strict policy cannot control.
- A hash changes whenever the inline code changes: the theme's scripts change on upgrade, and the analytics snippet changes with your ID. Regenerate after each upgrade or config change.

Generate the hashes from a built site (run in the site root after `jekyll build`; Ruby only, no extra gems):

```bash
ruby -rdigest -rbase64 -e '
  tags = Dir["_site/**/*.html"].flat_map do |f|
    File.read(f).scan(%r{<(script|style)(?![^>]*\s(?:src|type="application/json"))[^>]*>(.*?)</\1>}m)
  end
  tags.uniq.each { |tag, body| puts "#{tag == "script" ? "script-src" : "style-src"} \x27sha256-#{Base64.strict_encode64(Digest::SHA256.digest(body))}\x27" }'
```

Each output line names the directive to add the hash to. Hashes cover the exact bytes between the tags, whitespace included, so serve the files unminified-after-hash or hash the final output.
