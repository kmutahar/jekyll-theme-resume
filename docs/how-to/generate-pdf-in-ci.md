# Generate PDFs in CI

Build one A4 PDF per language from your built site and offer it as a download button. The PDFs are Chrome's own print output, so they match the browser's print preview. See [Print your resume](print-your-resume.md) for the layout rules.

## Requirements

- Google Chrome or Chromium (set `CHROME=/path/to/chrome` if it is not on your `PATH` as `google-chrome`, `chromium` or similar).
- A built site, and the `_config.yml` that built it (the script reads `baseurl` and each `languages.<lang>.url`).
- Network access while printing, so the Google Fonts load. With `disable_google_fonts: true` the PDF uses fallback fonts.

## Steps

1. Build the site, then run the script from the theme gem:

   ```bash
   bundle exec jekyll build
   ruby "$(bundle info --path jekyll-theme-resume)/bin/generate-pdf" _site _config.yml
   ```

   The second argument defaults to `./_config.yml`. Pass several files as `a.yml,b.yml` (later files win).

2. The script writes `_site/assets/pdf/resume-<lang>.pdf` for every language, A4 only, with selectable text and embedded fonts. It retries Chrome up to three times per page and exits non-zero if any page fails.

3. Show the button by adding this to `_config.yml`:

   ```yaml
   resume_download_pdf: true
   ```

   The button links to `/assets/pdf/resume-<lang>.pdf` and is hidden in print. If the PDFs were not built (for example under `jekyll serve`), the link returns 404, so turn the flag on only for builds that run the script.

Where the PDFs are hosted is up to you; the script only writes them into the built site.

## Check the extracted text

Applicant tracking systems read the PDF's text, not its pixels. This repository checks the demo's PDFs with `test/ats_check.rb`:

```bash
ruby bin/generate-pdf _site demo/_config.yml
bundle exec ruby test/ats_check.rb _site _site/assets/pdf demo/_config.yml
```

It requires every visible text node outside `.no-print` to appear in `pdftotext` output, in page order. English, Spanish, French and German must be clean. Arabic and Urdu are compared with `test/ats_baseline.yml`, which records the headings and text `pdftotext` already mis-extracts (letter swaps in Arabic-script text); they must not get worse. The check ignores hyphens, because `pdftotext` drops them where a long URL wraps.

The workflow `.github/workflows/generate-pdf.yml` runs both commands on the demo and uploads the PDFs as artifacts. It does not deploy them.

## Page numbers

Page numbers are not shipped. In Chrome 153, `@page { @bottom-center { content: counter(page) } }` renders and adds one `N/M` line per page to the extracted text without changing the order of the rest, so it is feasible if you want it later. Keep contact details in the page body either way.
