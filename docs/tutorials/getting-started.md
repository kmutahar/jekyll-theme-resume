# Getting Started: Your First Two-Language Resume

*Audience: site owners*

In this tutorial you start from an empty folder and end with an English and Arabic resume site running on your computer, built with the `jekyll-theme-resume` gem. Follow the steps in order. Each step shows what you should see before you move on.

## Before you start

You need:

- **Theme version 1.3.0 or newer.** This tutorial is written for 1.3.0.
- **Ruby 3.3.0 or newer.** The theme's CI tests Ruby 3.3, 3.4, and 4.0.
- **Bundler**, which installs Jekyll and the theme for you. The theme needs Jekyll `~> 4.4`, and Bundler installs it automatically.
- **Git**, used in step 5 to download the sample resume data.

Check your tools:

```bash
ruby -v
bundle -v
git --version
```

**Expected result:** `ruby -v` prints `ruby 3.3.0` or higher, and the other two commands print a version number.

## Step 1: Create the site folder

```bash
mkdir my-resume
cd my-resume
```

**Expected result:** you are inside an empty folder named `my-resume`. All later commands run from here.

## Step 2: Add a Gemfile

Create a file named `Gemfile` with this content:

```ruby
source "https://rubygems.org"

group :jekyll_plugins do
  gem "jekyll-theme-resume"
end

# Windows and JRuby do not include zoneinfo files, so bundle tzinfo-data.
platforms :windows, :jruby do
  gem "tzinfo"
  gem "tzinfo-data"
end

# Faster directory watching on Windows
gem "wdm", platforms: [:windows]
```

The theme must be inside `group :jekyll_plugins`. That group loads the theme's build-time generators and validator. A plain `gem` line outside the group does not load them.

## Step 3: Install the theme

```bash
bundle install
```

**Expected result:** Bundler installs `jekyll-theme-resume`, Jekyll, and the theme's plugins, then prints `Bundle complete!`.

## Step 4: Write `_config.yml`

Create `_config.yml` with this minimal English and Arabic configuration:

```yaml
theme: jekyll-theme-resume
title: "Jane Doe"
url: "https://your-domain.com"
baseurl: ""                   # Keep empty unless hosting on a subpath (e.g., /resume)
timezone: UTC

languages:
  en:
    data_path: en             # _data/en/*
    url: /en/cv/
    header_intro: true
    name: "Jane Doe"
    resume_title: "Senior Product Manager"
  ar:
    data_path: ar             # _data/ar/*
    url: /ar/cv/
    header_intro: true
    name: "جين دو"
    resume_title: "مديرة منتج أولى"

default_lang: en

contact_info:
  email: "jane.doe@example.com"

resume_section:
  experience: true
  education: true
  projects: true
  skills: true

resume_section_order:
  - experience
  - education
  - projects
  - skills
```

This file tells the theme to publish two languages. Each language reads its resume content from the folder named by `data_path`, and its CV lives at `url`. You do not create page files yourself: the theme generates each language's CV at its `url`, a profile landing page at `/` for the default language, and one at `/<lang>/` for every other language. For now, replace only the `name` and `resume_title` under each language, and the email, with your own if you want to. The name shown in the page header comes from `languages.<lang>.name`. Every other key is covered in the [Configuration reference](../reference/config.md).

## Step 5: Copy the starter resume data

The theme's demo site has a complete sample resume (Sherlock Holmes) in six languages. Download the demo and copy the English and Arabic folders into your site:

```bash
git clone https://github.com/kmutahar/bilingual-jekyll-resume-demo.git ../bilingual-jekyll-resume-demo
mkdir -p _data
cp -r ../bilingual-jekyll-resume-demo/_data/en ../bilingual-jekyll-resume-demo/_data/ar _data/
```

The clone creates a folder named `bilingual-jekyll-resume-demo` next to `my-resume`, not inside it. You only need it for this copy.

**Expected result:** `ls _data/en` and `ls _data/ar` each list 13 YAML files, from `associations.yml` to `volunteering.yml`, including `header.yml`, which holds the intro paragraph shown under your name.

## Step 6: Start the site

```bash
bundle exec jekyll serve
```

**Expected result:** the output includes these lines:

```text
✓ VALIDATION SUCCESSFUL: All resume data files are valid! (clean, 0 warnings)
    Server address: http://127.0.0.1:4000/
  Server running... press ctrl-c to stop.
```

Leave this command running.

## Step 7: Open your resume

Open these addresses in your browser:

| URL | What you see |
|---|---|
| `http://localhost:4000/` | The English profile landing page. |
| `http://localhost:4000/ar/` | The Arabic profile landing page. |
| `http://localhost:4000/en/cv/` | The English CV, left to right, headed "Jane Doe" and "Senior Product Manager", with Experience, Education, Projects, and Skills sections. |
| `http://localhost:4000/ar/cv/` | The Arabic CV, laid out right to left, headed "جين دو". |

On either page, use the floating language switcher to jump to the other language.

The section content is still the Sherlock Holmes sample. Only the header shows your name.

## Step 8: Make it yours

With the server still running, open `_data/en/header.yml`, replace the paragraph under `intro:` with a sentence about yourself, and save the file. The paragraph is a folded block (`intro: >-`), so keep your text indented under it. Reload `http://localhost:4000/en/cv/`.

**Expected result:** the new intro appears under your name. Jekyll rebuilds when you save a data file. Changes to `_config.yml` need a restart: stop the server with `ctrl-c` and run `bundle exec jekyll serve` again.

Replace the rest of the sample content the same way, one file at a time, in both `_data/en/` and `_data/ar/`. Write the Arabic content in Arabic. If you copy English text into `_data/ar/`, the headings will be in Arabic but the body will stay in English. If a change breaks something, the validation report in the `jekyll serve` output lists the problems it found in your data files.

You now have a working two-language resume site.

## Where to go next

- Look up what each field in the 13 data files means in [Data schemas](../reference/data-schemas.md).
- Look up every `_config.yml` key, including avatar, social links, and dark mode, in [Configuration](../reference/config.md).
- Add a third language with [Add a language](../how-to/add-a-language.md).
- If the build fails or a section is missing, see [Troubleshoot builds](../how-to/troubleshoot-builds.md).
- To learn how one layout renders both LTR and RTL languages, read [Multilingual and RTL design](../explanation/multilingual-and-rtl-design.md) and [The data-driven model](../explanation/data-driven-model.md).

To see all sections types in all six languages, build the full Sherlock Holmes demo from a clone of the theme repository. Run these commands from a folder outside `my-resume`; the first two clone the repository and move into it:

```bash
git clone https://github.com/kmutahar/jekyll-theme-resume.git
cd jekyll-theme-resume
git submodule update --init --recursive
bundle install
bundle exec jekyll build --source demo --destination _site
```
