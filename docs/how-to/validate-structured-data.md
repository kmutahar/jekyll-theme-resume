# Validate structured data

*Audience: site owners*

Check the JSON-LD block on a built CV page, run it through the public validators, and turn it off if you do not want it. What the block contains is in the [JSON-LD fields reference](../reference/json-ld-fields.md).

JSON-LD does not guarantee ATS parsing or rich results. These checks show that the markup is valid, not that a crawler will use it.

## 1. Build and extract the block

Build the site, then print the JSON-LD from a CV page. With Ruby and Nokogiri (already in the theme's bundle):

```bash
bundle exec jekyll build
bundle exec ruby -rnokogiri -rjson -e '
  doc = Nokogiri::HTML(File.read("_site/en/cv/index.html"))
  doc.css(%q(script[type="application/ld+json"])).each do |node|
    data = JSON.parse(node.text)
    puts JSON.pretty_generate(data) if data["@type"] == "ProfilePage"
  end'
```

Adjust the path to your CV page. The page has two JSON-LD blocks: the theme's `ProfilePage` and the `WebPage` block from `jekyll-seo-tag`. The filter above prints ours.

In a browser, open the page, view source, and search for `application/ld+json`.

## 2. Check it with the validators

To check syntax and vocabulary, paste the block into [validator.schema.org](https://validator.schema.org/). To see how Google reads it, use the [Rich Results Test](https://search.google.com/test/rich-results) with the published URL, or with pasted code for a local build.

## 3. Read the common warnings

| Warning | Cause | Fix |
|---|---|---|
| The block has no `@id`, `url` or `Person.@id` | `site.url` is not set, so the theme cannot build absolute URLs. | Set `url` in `_config.yml`. |
| No `email`, `telephone` or `address` | The CV hides them, or `json_resume.privacy.export_contact_info` is `false`. | See [Visibility and privacy](../reference/json-ld-fields.md#visibility-and-privacy). |
| No `worksFor` | `worksFor` lists only roles with a start date and no end date. | Give the current role a `startdate` and set `enddate` to `Present` or a word from the locale's `present_values`, or leave it out. |
| No `description` or `image` | Only emitted when `header_intro: true` and `resume_avatar: true`. | Enable them if you want the values. |
| Two blocks, different `author` | `site.author` feeds `jekyll-seo-tag`'s block. | Set `site.author` to the CV name. |

## 4. Turn it off

```yaml
json_ld:
  enabled: false
```

The block disappears from every CV page. The JSON Resume files are not affected; control them with [`json_resume.enabled`](../reference/config.md#13-json-resume-export).
