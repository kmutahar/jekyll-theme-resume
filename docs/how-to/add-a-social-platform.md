# Add a social platform

*Audience: theme developers*

Add a new social network icon and label to the theme.

## Steps

1. Place an optimized SVG in `_includes/vendors/svg-icons/newplatform.svg`. Match the shipped icons: a square image with `width="24" height="24" viewBox="0 0 24 24"`, and `aria-hidden="true"` and `focusable="false"` on the `<svg>` element, because the link around the icon carries the accessible name. The stylesheet sets the icon color (`.icon-link svg`), so any fill colors inside the SVG do not matter. If the icon comes from a licensed set, add a row to the table in that folder's `ATTRIBUTION.md` giving the file name and the set it came from.
2. Add an entry to [`_data/social_networks.yml`](../../_data/social_networks.yml), the single list both `social-links.html` and `print-social-links.html` loop over. The order in this file is the order of the icons in the header and of the print list:
   ```yaml
   - key: newplatform
     icon: newplatform
     itemprop: sameAs # or "url" for a non-profile link
     label: New Platform
   ```
   `key` is the name a site uses under `social_links:` in `_config.yml`. `icon` is the SVG file name without `.svg`. Use `itemprop: sameAs` for a profile that verifies who the person is, `url` for a website or other link, and `email` for an email address. `label` is the English fallback for the icon's accessible name; each locale's label wins when it has one.
3. Add a `ui.social_labels.newplatform` key to every locale file (the icon's accessible name and the print-only label; the print list has no fallback):
   ```yaml
   # _data/locales/<lang>.yml, in each of the six shipped locales
   ui:
     social_labels:
       newplatform: "New Platform"   # translate for each language
   ```
   Once the entry from step 2 exists, `test/test_packaging.rb` fails until its SVG and all six labels exist.
4. To include the platform in the JSON Resume export, add its `key` to `JsonResumeExporter::NETWORKS` in [`lib/jekyll-theme-resume/json_resume_exporter.rb`](../../lib/jekyll-theme-resume/json_resume_exporter.rb). That list is hard-coded, so a platform missing from it is never exported.

## Check it

1. Run `bundle exec ruby test/test_packaging.rb`. It fails with the missing icon's file name, or with the language and key of a missing label, until steps 1 to 3 are complete.
2. Add the platform to `social_links:` in a site's `_config.yml` (for example `newplatform: "https://example.com/you"`), build, and look for the icon in the header's social row. Hovering over it shows the label.
3. Open the print preview. The print-only social list shows the platform's label followed by its address.
