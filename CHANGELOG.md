# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [1.3.0] - 2026-10-04

### Added
* Add Content Security Policy guidance (SEC-08) ([`3057d21`](https://github.com/kmutahar/jekyll-theme-resume/commit/3057d217a0d1910cf1a96a5d8cbcc26053530b1a))

* Add more info Feature 4.7: Dynamic Custom Resume Sections Engine ([`99a3446`](https://github.com/kmutahar/jekyll-theme-resume/commit/99a3446187c940ac466618ee2b799abacd7b59e5))

* Add publications and references sections ([`4d4ccfb`](https://github.com/kmutahar/jekyll-theme-resume/commit/4d4ccfba696a9110e0e2e5d7b5720f6bd72f6f7b))


### Changed
* Rename gem to jekyll-theme-resume ([`6008f6e`](https://github.com/kmutahar/jekyll-theme-resume/commit/6008f6eef37668f3b7a2725f4beccbc76e6a9f25))

* Pin actions to commit SHAs and publish only from tags (SEC-04) ([`03a5485`](https://github.com/kmutahar/jekyll-theme-resume/commit/03a5485a158b72be4fcf5de79664707b68992eca))

* Package only git-tracked files (SEC-07) ([`8addd67`](https://github.com/kmutahar/jekyll-theme-resume/commit/8addd67695e9e910b69518b8dd0e6063d885fdf9))

* Document contact field export rules (SEC-06) ([`2b802e6`](https://github.com/kmutahar/jekyll-theme-resume/commit/2b802e6278d683aefae52339c57af91cf6ac1c54))

* Point JSON Resume export references at real docs ([`dcad54c`](https://github.com/kmutahar/jekyll-theme-resume/commit/dcad54c42d4dac111ee3609c2b1d6a70b6a4724f))


### Fixed
* Allowlist URL schemes for avatar and social links (SEC-02) ([`a8ebbda`](https://github.com/kmutahar/jekyll-theme-resume/commit/a8ebbda8c55bef96f557289329b8c16f0f136b76))

* Escape lang attributes and validate analytics IDs (SEC-03) ([`34481ad`](https://github.com/kmutahar/jekyll-theme-resume/commit/34481adf8822ef215c6ff22188445383c1ce3176))

* Validate language keys and handle unsafe YAML (SEC-05) ([`8c62641`](https://github.com/kmutahar/jekyll-theme-resume/commit/8c62641e767bd1b203c2ee99be0769ed987b15a8))

* Escape error-page JSON block and locale strings (SEC-01) ([`d2582a8`](https://github.com/kmutahar/jekyll-theme-resume/commit/d2582a8c37d476b701d422ff3862285e8d89e846))

## [1.1.0] - 2026-10-01

### Added
* Add bin/verify to run the Rule 5 suite with a log ([`333b939`](https://github.com/kmutahar/jekyll-theme-resume/commit/333b93947c9f7ac20e21a97ce51ecbbec64bb0b0))

* Add security briefs and streamline completed audit log ([`9580a55`](https://github.com/kmutahar/jekyll-theme-resume/commit/9580a55411a605d7636227233a97c7d2f38e9822))

* Add end-to-end rendered site, packaging, and error page suites ([`8eb6cb3`](https://github.com/kmutahar/jekyll-theme-resume/commit/8eb6cb3526dbfde6587f4d6e00019be72bcb679d))

* Add Feature 3.2 publications & references blueprint ([`8024a8a`](https://github.com/kmutahar/jekyll-theme-resume/commit/8024a8aad060fdab0e2f4f0f4b75d5c75d311064))

* Add exporter and generator test suite ([`aa237dd`](https://github.com/kmutahar/jekyll-theme-resume/commit/aa237dd65da91894cafe87b7800533c49244ed51))

* Add localized JSON Resume exporter and generator ([`c600361`](https://github.com/kmutahar/jekyll-theme-resume/commit/c60036172e9f856d9fe538d8a381bca95bbc2968))


### Changed
* Filter Liquid frozen-string warning from tests, bump demo ([`8f3f5f9`](https://github.com/kmutahar/jekyll-theme-resume/commit/8f3f5f98f62c6590c46a4db398c9a48f50af28c2))

* Bump submodule to the docs-path update ([`38ae031`](https://github.com/kmutahar/jekyll-theme-resume/commit/38ae031651476f4004ea1475af2000fb8dd855e9))

* Expand four short guides with verified steps and checks ([`9b1f337`](https://github.com/kmutahar/jekyll-theme-resume/commit/9b1f337807c2098ef3ba5e43e3fd53052a53bcef))

* Correct stale layout names in stylesheet comments ([`ce7e1c3`](https://github.com/kmutahar/jekyll-theme-resume/commit/ce7e1c3a2b1db4f2b60be1c87fd93c3b7be3fb51))

* Restructure documentation into Diataxis (tutorial, how-to, reference, explanation) ([`1348d88`](https://github.com/kmutahar/jekyll-theme-resume/commit/1348d88b17e3f6d0397bc881b25003bfa5362d89))

* Record ADR 0001 and exclude docs/adr from the gem ([`59695d5`](https://github.com/kmutahar/jekyll-theme-resume/commit/59695d5cb679602bcd06dba37851681c8f4e3d63))

* Restructure AGENTS.md and update README.md ([`9cb2459`](https://github.com/kmutahar/jekyll-theme-resume/commit/9cb245966949cc48db63ac4157bbdbaf9013640b))

* Update guides, README, and gemspec metadata for recent architecture ([`0ff18c0`](https://github.com/kmutahar/jekyll-theme-resume/commit/0ff18c0dade5fd632d1af8770b6902b355aab56e))

* Enforce canonical keys in data files with alias hints ([`9f43702`](https://github.com/kmutahar/jekyll-theme-resume/commit/9f43702da1404277d8ef8994a843590696c8d365))

* Localized JSON Resume export ([`898dce1`](https://github.com/kmutahar/jekyll-theme-resume/commit/898dce11a250029c23285964ca6ecbcf26d50552))

* Document the JSON Resume export feature ([`a304320`](https://github.com/kmutahar/jekyll-theme-resume/commit/a3043204b51d17547f66e095d7521cae178d8836))

* Wire discovery link and sample config ([`4fb5333`](https://github.com/kmutahar/jekyll-theme-resume/commit/4fb53333a6e343877ee4e3c1048480d2ff5bdf37))

* Validate optional JSON Resume enrichment fields ([`591cb9f`](https://github.com/kmutahar/jekyll-theme-resume/commit/591cb9fbab4b5613c6a378aa06a0e3530125493c))

* Merge vendor SVG folders and data-drive social links ([`e22afb8`](https://github.com/kmutahar/jekyll-theme-resume/commit/e22afb874357c93d66308de38d9ceab1c462ca32))

* Sync repository documentation, guides, and roadmap ([`40425a2`](https://github.com/kmutahar/jekyll-theme-resume/commit/40425a2ebddfaa0dcba06748329b99f739f456bc))

* Upgrade Lineicons to v5.1 and consolidate vendor assets ([`794edcb`](https://github.com/kmutahar/jekyll-theme-resume/commit/794edcb35f707ac32cc190ce8deb45e6cc0a6867))

* Inline single-caller stylesheet includes ([`4513f29`](https://github.com/kmutahar/jekyll-theme-resume/commit/4513f2997f57577358820a1b2b0ba0bf82a0ca90))

* Auto-generate CV and profile pages per language ([`abaf487`](https://github.com/kmutahar/jekyll-theme-resume/commit/abaf48779013fa6524d60f1ba8f7bfdf06641168))

* Deduplicate repeated CSS rules and remove dead code ([`a354b62`](https://github.com/kmutahar/jekyll-theme-resume/commit/a354b62253aed4637f0e07df4397adaf27ca2ba9))


### Fixed
* Match GitHub host by parsed URL, not substring ([`98c8d83`](https://github.com/kmutahar/jekyll-theme-resume/commit/98c8d83f69a408536c41a8de3ea9258bb4a43436))

* Check doc links and anchors; assert docs ship and docs/adr does not ([`0e097d9`](https://github.com/kmutahar/jekyll-theme-resume/commit/0e097d9a945b6757f48c26abafef225c485ce5ae))

* Require date to fix CI error on Ruby 3.3 ([`fc7cb6e`](https://github.com/kmutahar/jekyll-theme-resume/commit/fc7cb6e595809de402470f393bae7a934c9ca210))

* Improve date formatting, presence checks, and accessible social labels ([`ea7dfeb`](https://github.com/kmutahar/jekyll-theme-resume/commit/ea7dfeb40ae4dc8db865d52d39d203ebbbb8a140))

* Match script closing tags with trailing garbage ([`abd4d95`](https://github.com/kmutahar/jekyll-theme-resume/commit/abd4d9586183b9a3dc0bdaae2be701ecace07a34))

* Decode HTML entities before stripping tags ([`cae8378`](https://github.com/kmutahar/jekyll-theme-resume/commit/cae8378d111b23f38d62406b4c8c58ac2a547864))

* Close CodeQL tag-stripping bypasses in text() ([`365b7f6`](https://github.com/kmutahar/jekyll-theme-resume/commit/365b7f655a2adcc825033f5aab92c8c51edbe354))

* Stop packaging dev-only tools and internal audit log ([`4c5f7d8`](https://github.com/kmutahar/jekyll-theme-resume/commit/4c5f7d8ba256a0bf16f10e6bde9216fb0b93769e))

## [1.0.2] - 2026-09-25

### Changed
* Update submodule to latest commit ([`f1779be`](https://github.com/kmutahar/jekyll-theme-resume/commit/f1779be39697ccea22e9185b0bf57278e8a29707))

* Extract Sherlock Holmes demo to submodule and relocate sample config ([`bfd9e83`](https://github.com/kmutahar/jekyll-theme-resume/commit/bfd9e8374753885fece3098cfd00f40606e5d26b))

* Archive completed features 3.2 and 3.3 and streamline audit log ([`39ae7f3`](https://github.com/kmutahar/jekyll-theme-resume/commit/39ae7f346dff45828e74fafbfb445420b0d699dd))


### Fixed
* Render language switcher on error pages ([`8e942f9`](https://github.com/kmutahar/jekyll-theme-resume/commit/8e942f9fccc23a2c6e097938992c3f23f446bf97))

* Register theme gem in jekyll_plugins group; bump demo submodule ([`392c192`](https://github.com/kmutahar/jekyll-theme-resume/commit/392c19209a42f629aba5e1c1e9a2a964832bf0a9))

## [1.0.1] - 2026-09-24

### Changed
* Replace language-switcher button row with a dropdown ([`f37c6f6`](https://github.com/kmutahar/jekyll-theme-resume/commit/f37c6f6b410f5de4841ed36115db60408c805293))

* Pin language-switcher/dark-mode-toggle to fixed corners ([`305408c`](https://github.com/kmutahar/jekyll-theme-resume/commit/305408c8885c194ad71d88831179b287d4a10ec3))

## [1.0.0] - 2026-09-24

### Added
* Add Feature 4.9, auto-generate CV/profile pages per language ([`8b473b7`](https://github.com/kmutahar/jekyll-theme-resume/commit/8b473b731b3c5ecf58576db9b014d389c0ab06e5))

* Add check-data-keys, a static checker for template-vs-data key mismatches ([`f4fcfcd`](https://github.com/kmutahar/jekyll-theme-resume/commit/f4fcfcd7f8aaf2fbec08295a8029c0c5cfcfa6fe))

* Add client-side site search blueprint ([`ac7f7ef`](https://github.com/kmutahar/jekyll-theme-resume/commit/ac7f7ef20fc3123bf28e79f390416d10ee7bcc5f))

* Add public-domain sherlock holmes avatar image ([`c73945b`](https://github.com/kmutahar/jekyll-theme-resume/commit/c73945bbbc283acee174f70435fb3e5a0a8ca993))

* Add locale system reference guides ([`d4ebf9c`](https://github.com/kmutahar/jekyll-theme-resume/commit/d4ebf9c236cc26b69c27a4e13588f919b6dfaf16))

* Add locale, parity, and schema test coverage ([`1314632`](https://github.com/kmutahar/jekyll-theme-resume/commit/131463239e0bb9446430c7d4f0a2fb0bff034921))

* Add sherlock holmes demo resume in six languages ([`5194795`](https://github.com/kmutahar/jekyll-theme-resume/commit/5194795f82c8ab2b0fbae721803efb5e59a9376e))

* Add locale-agnostic resume layout ([`28239ec`](https://github.com/kmutahar/jekyll-theme-resume/commit/28239ecb2a4039f91c8be94bf78bac8a92a89a1e))

* Add unified section dispatcher for all locales ([`23cfc0d`](https://github.com/kmutahar/jekyll-theme-resume/commit/23cfc0df8c4ee240d9298ee6a3f36dd4e572b99f))

* Add universal date formatter for all six locales ([`1a830bd`](https://github.com/kmutahar/jekyll-theme-resume/commit/1a830bd52a44266a0145fb7ece5432f32ac9570e))

* Add native email support to social links ([`064e2e0`](https://github.com/kmutahar/jekyll-theme-resume/commit/064e2e0ee7f4d5dac86911ee30becf32562d8aaa))

* Add canonical locale dictionaries for six languages ([`20973be`](https://github.com/kmutahar/jekyll-theme-resume/commit/20973be336c3b871f1278e8be655ed0e7e547ab5))

* Add v1.0.0 multilingual implementation plan and align roadmap ([`9b71b02`](https://github.com/kmutahar/jekyll-theme-resume/commit/9b71b02312a15dd002f28e899fc6fd315b3cf58c))


### Changed
* Make profile layout multilingual and data-driven ([`87d4c46`](https://github.com/kmutahar/jekyll-theme-resume/commit/87d4c4680dfd8510c9dc9add4ef68619e9ed24f7))

* Include base styles in profile page stylesheet ([`193f96b`](https://github.com/kmutahar/jekyll-theme-resume/commit/193f96b41ccbc64938f8c54f6096c86fde69201d))

* Bump documented version to v1.0.0, reconcile roadmap ([`1c77680`](https://github.com/kmutahar/jekyll-theme-resume/commit/1c77680bca4b648104495860a0481622b6ddbee8))

* Localize error-page search box to the visitor's browser language ([`256dbb3`](https://github.com/kmutahar/jekyll-theme-resume/commit/256dbb3a4239d60cb1848f6db53d97e1b15780b2))

* Extract shared grouped-item-list renderer ([`1b5a0a4`](https://github.com/kmutahar/jekyll-theme-resume/commit/1b5a0a46d30f3fdc355d24ca05b7dca53d4870f4))

* Bump actions/checkout in the github-actions group ([`0809e9c`](https://github.com/kmutahar/jekyll-theme-resume/commit/0809e9cda99a6dd18e1daa3a83cdee1b2da26501))

* Update minitest requirement from ~> 5.25 to ~> 6.0 ([`7fa8a8e`](https://github.com/kmutahar/jekyll-theme-resume/commit/7fa8a8e8cc7ad5983394c72346ac3a8b6380b4cc))

* Record PR #220's live CI verification for Feature 3.2 ([`00e8fdf`](https://github.com/kmutahar/jekyll-theme-resume/commit/00e8fdffd6ed9f43dd7586ff44bda74104e138af))

* Update agent guidance and roadmap for v1.0.0; retire implementation plan ([`0579aa3`](https://github.com/kmutahar/jekyll-theme-resume/commit/0579aa3fb4bb27ad221b6f13430500bfcb3692de))

* Wire build/proof tooling to the locale-driven demo overlay ([`4f27143`](https://github.com/kmutahar/jekyll-theme-resume/commit/4f2714381205c1133372aa3f3ec093eed10be0de))

* Import and adapt locale-aware resume data validator ([`834969a`](https://github.com/kmutahar/jekyll-theme-resume/commit/834969a7c2e2fb2e263687b81ccf60500b0e4bca))

* Make every remaining EN/AR consumer locale-driven ([`faa5d7e`](https://github.com/kmutahar/jekyll-theme-resume/commit/faa5d7e503ac0dfc63fa1cd781430334f61be465))

* Purge deprecated site.avatar, analytics.ga, and resume_dark_mode fallbacks ([`e565de0`](https://github.com/kmutahar/jekyll-theme-resume/commit/e565de054705c01cf572893c1ec35470f6f46dc0))

* Align Arabic header contact icons icon-first ([`ed3e655`](https://github.com/kmutahar/jekyll-theme-resume/commit/ed3e655c7d6a413c87f5efd164bb06e22346383e))

* Split resume stylesheet into locale-driven LTR/RTL layers ([`807b4e2`](https://github.com/kmutahar/jekyll-theme-resume/commit/807b4e240ba83e98fb0b61e3657667ec3b729450))


### Fixed
* Resolve 404 language and Home button from the requested URL ([`8616bb2`](https://github.com/kmutahar/jekyll-theme-resume/commit/8616bb201a4246cd2dee0f5b862f39d08f7a635b))

* Require "date" so YAML.safe_load_file's permitted_classes resolves on Ruby 3.3 ([`ad4a1cd`](https://github.com/kmutahar/jekyll-theme-resume/commit/ad4a1cde235784d7e9e8c0fbc17741d1b959541a))

* Render single-language error pages via remembered language preference ([`7105376`](https://github.com/kmutahar/jekyll-theme-resume/commit/7105376c57763e98c977685c1a96c645bbb84505))

* Tighten URL/section/language checks, require education year ([`86b8212`](https://github.com/kmutahar/jekyll-theme-resume/commit/86b82122925fbb8557d0e7e4bb763730605558f6))

* Use locale-driven font variable instead of undefined RTL tokens ([`2a08333`](https://github.com/kmutahar/jekyll-theme-resume/commit/2a08333e35e1770adeb256a4844e071f3d360283))

* Fall back to standard contact info when live fields are partial ([`dbd5e00`](https://github.com/kmutahar/jekyll-theme-resume/commit/dbd5e001b43ef6688aab7a0d25c883a72d378ee6))

* Declare minitest as a development dependency ([`3b51fd4`](https://github.com/kmutahar/jekyll-theme-resume/commit/3b51fd4d2711de4c08ffb5b98e31f1e84a3b345e))

* Use lang_cfg.name for creator microdata ([`83c97d9`](https://github.com/kmutahar/jekyll-theme-resume/commit/83c97d9b99974f8860c514840c3b8682ada3c8df))

* Update actions/checkout and action-gh-release versions for compatibility ([`d807bc3`](https://github.com/kmutahar/jekyll-theme-resume/commit/d807bc3f36a30e64bad2b2e1ba2169c9990114d2))


### Removed
* Remove non-functional error-page search form ([`73e1ac5`](https://github.com/kmutahar/jekyll-theme-resume/commit/73e1ac5515b548a245fd8443078909a265a6dfb3))

## [0.9.0] - 2026-09-21

### Added
* Add accessible landmark roles, skip-links, and focus styles ([`a29c480`](https://github.com/kmutahar/jekyll-theme-resume/commit/a29c48087c3933c9edb71722bbb00ea12e3c9ad4))


### Changed
* Update active feature blueprints, issue mappings, and ignore rules ([`28dd0c3`](https://github.com/kmutahar/jekyll-theme-resume/commit/28dd0c317cc869f966731c1732570b7592affb3e))

* Consolidate dynamic data loader into shared include component ([`ef5cc4f`](https://github.com/kmutahar/jekyll-theme-resume/commit/ef5cc4fa1e979024a0fbc8efebef5105706aa1df))

* Consolidate profile styles with shared partials and remove redundant forwarder ([`0d1fbd0`](https://github.com/kmutahar/jekyll-theme-resume/commit/0d1fbd04b427c4ee334d64558d6275ec64f71e9c))

* Simplify resume section conditions with direct Liquid blank checks ([`c9a6ada`](https://github.com/kmutahar/jekyll-theme-resume/commit/c9a6ada2089b9b686d510edfffe0d196dca5f051))

* Clean up legacy mixins, remove IE zoom hacks, and eliminate dead table classes ([`2800d0a`](https://github.com/kmutahar/jekyll-theme-resume/commit/2800d0ab1553ee14e59c6eaae441d4de83c5b35f))

* Encapsulate dark mode activation cascade into toggle include ([`405b493`](https://github.com/kmutahar/jekyll-theme-resume/commit/405b4933ea0640951fd8a24a21151574bb0ab11a))

* Implement interactive bilingual language switcher ([`c56e50f`](https://github.com/kmutahar/jekyll-theme-resume/commit/c56e50fa6f7e64a58ff7930a3bfb4a7275b7e134))

* Apply living-docs framework, add code comments, browser QA verified ([`d1535b9`](https://github.com/kmutahar/jekyll-theme-resume/commit/d1535b9f22d79eab1cd7f4078c0db2d86a74f7b6))

* Update release notes for version automation ([`fc9ead1`](https://github.com/kmutahar/jekyll-theme-resume/commit/fc9ead129df08b3698264b9da5a07378e1543aa3))

* Preserve bump-only releases in git-cliff template ([`ba334a5`](https://github.com/kmutahar/jekyll-theme-resume/commit/ba334a54fa8d63aeea1a72ad646b2bb71ff6f0a7))

* Automate gem publishing and release workflow ([`f4bd096`](https://github.com/kmutahar/jekyll-theme-resume/commit/f4bd096ae44bfc42cb14c9635a0e9803e297a0ba))


### Fixed
* Render language header summary on a dedicated line ([`d3352dc`](https://github.com/kmutahar/jekyll-theme-resume/commit/d3352dcb6833f8bc48d2d799774757a42325a711))


### Removed
* Remove redundant Gem::Specification monkey-patch ([`a78efd6`](https://github.com/kmutahar/jekyll-theme-resume/commit/a78efd68e70c0848f78bb5b25ab51f848c437c1d))

## [0.8.0] - 2026-09-19

### Added
* Add global .sr-only utility class for accessible icons ([`f25fcb6`](https://github.com/kmutahar/jekyll-theme-resume/commit/f25fcb618c399a54039b00cb56e1d09724592516))

* Add error pages generator plugin and gem autoloading ([`9238b5a`](https://github.com/kmutahar/jekyll-theme-resume/commit/9238b5ace273c9c64de5c90bbd8a19fe6ac5a27b))

* Add .agents/ to ignore list ([`568b874`](https://github.com/kmutahar/jekyll-theme-resume/commit/568b874c290ae1673fe6c3e44b97a4c0c8e0b553))

* Add configurable avatar URL, bilingual alt text, and reusable include ([`a17cc60`](https://github.com/kmutahar/jekyll-theme-resume/commit/a17cc603a3633bb5dc67589bcc01ce7ef886d88c))


### Changed
* Improve accessibility, icon contrast, mobile responsiveness, and RTL typography ([`add2625`](https://github.com/kmutahar/jekyll-theme-resume/commit/add2625599027eb1f88ca6e1ec66c3bf2b334757))

* Populate comprehensive bilingual example data across all sections ([`1555d41`](https://github.com/kmutahar/jekyll-theme-resume/commit/1555d41efef50cd9010d4bf08223fb81060bc8f3))

* Standardize recognition section toggle to plural with fallback ([`dccee09`](https://github.com/kmutahar/jekyll-theme-resume/commit/dccee09c65e95a140281633342a09d58b236b888))

* Modernize all guides and master sample configuration ([`08f8823`](https://github.com/kmutahar/jekyll-theme-resume/commit/08f8823f91984891e55dff0dcc8488601c185aea))

* Establish master feature roadmap and archive completed audit ([`f6d28a3`](https://github.com/kmutahar/jekyll-theme-resume/commit/f6d28a354115fa6a0ce5e29250cd1b40be0c4dfd))

* Establish AGENTS.md master manual and refactor pointers ([`24ecf7e`](https://github.com/kmutahar/jekyll-theme-resume/commit/24ecf7e751eebff79ac9e805d7a7de8696c52b43))


### Fixed
* Render section detail bullets conditionally with proper spacing ([`e4564cc`](https://github.com/kmutahar/jekyll-theme-resume/commit/e4564cc43b5e5cec31ed704918cddbc124ec76ca))

* Enhance error layout usability, add sr-only styles, and maintain LTR/RTL parity ([`18a9b5b`](https://github.com/kmutahar/jekyll-theme-resume/commit/18a9b5bbd18c52456a5a0dfd958d09187686a003))

* Restore standalone profile layout and eliminate icon underline artifacts ([`5bed5dd`](https://github.com/kmutahar/jekyll-theme-resume/commit/5bed5ddc9b59bbfcb820df7793c2098ee0762d69))

* Resolve Liquid truthiness, unclosed tags, and Arabic date parsing ([`90a0750`](https://github.com/kmutahar/jekyll-theme-resume/commit/90a075077c812bc56d31ac9622abdf2f3278dc98))

## [0.7.0] - 2026-09-12

### Added
* Add bilingual error suite (404, 403, 500) and reusable layout ([`4eab127`](https://github.com/kmutahar/jekyll-theme-resume/commit/4eab127d8cc3a4cedccca89943482fd3a067ee14))


### Changed
* Enhance README and DATA_GUIDE with dark mode, typography, and error page details ([`8284ee7`](https://github.com/kmutahar/jekyll-theme-resume/commit/8284ee7c0ffe351b823ad8ea0854b8e6d6afecd5))

* Implement universal dark mode and isolate profile layout styles ([`853a9ac`](https://github.com/kmutahar/jekyll-theme-resume/commit/853a9ac1eaf11aadec62f198f6b7e9cdb2d3c209))

* Update analytics configuration to support direct measurement ID for Google Analytics 4 ([`dff8c3d`](https://github.com/kmutahar/jekyll-theme-resume/commit/dff8c3d3ce3bfebf2ebb37d3ada348ed1a603f3c))

* Integrate Google Tag Manager analytics snippet into resume layouts ([`54f5c96`](https://github.com/kmutahar/jekyll-theme-resume/commit/54f5c9676766c2ee04cd44a9b64b1a3472ca4d70))

* Enhance contact information handling and improve schema markup in resume layouts ([`caf726c`](https://github.com/kmutahar/jekyll-theme-resume/commit/caf726c557e8289c991b6cb15acc3cc54504867e))


### Fixed
* Upgrade Arabic font loading and isolate print social links ([`ca6898b`](https://github.com/kmutahar/jekyll-theme-resume/commit/ca6898b883a5264dbee9088c849bfd6a00fdf079))

* Scope global svg rules and add WCAG 2.1 AA accessible social links ([`d44dcb1`](https://github.com/kmutahar/jekyll-theme-resume/commit/d44dcb15360ddd3c6e5eb42bc973564f882ee177))

* Centralize modern favicon suite and resolve subdirectory 404s ([`943d565`](https://github.com/kmutahar/jekyll-theme-resume/commit/943d5653d5cbfa5f6189b4975a74f2e981c6ceb1))

* Add 'dir="ltr"' attribute to URLs for better text direction handling in resume sections ([`73da095`](https://github.com/kmutahar/jekyll-theme-resume/commit/73da0959f2de2b7a6585d2c1c03fc59a4fa55f65))


### Removed
* Remove conflicting duplicate canonical tag from shared head ([`8f8b22b`](https://github.com/kmutahar/jekyll-theme-resume/commit/8f8b22bfdea4e40371366db47bdddd98d412631a))

## [0.6.1] - 2026-08-21

### Changed
* Version bump release with no structural code changes.
## [0.6.0] - 2026-08-21

### Added
* Add CLAUDE.md for AI coding assistant guidance and project documentation ([`d68bb03`](https://github.com/kmutahar/jekyll-theme-resume/commit/d68bb031043eb88dc7bc6eaaa30a00867f7f7afc))


### Changed
* Add dark mode toggle with system preference detection ([`2dcb813`](https://github.com/kmutahar/jekyll-theme-resume/commit/2dcb8135817d05f97d8705ea09bfb326d244cd3d))

* Enhance CLAUDE.md with comprehensive project documentation and guidance for AI assistants ([`b3facba`](https://github.com/kmutahar/jekyll-theme-resume/commit/b3facba6cac2caf853d3f70243dd8a9a2f87ab53))

* Revise SECURITY.md with version support and monitoring ([`34c78a0`](https://github.com/kmutahar/jekyll-theme-resume/commit/34c78a08ee5e96fd0667b9896c07f6e18e380dd0))

* Potential fix for code scanning alert no. 1: Workflow does not contain permissions ([`915f9e7`](https://github.com/kmutahar/jekyll-theme-resume/commit/915f9e77982a962e3eda844263d65b5a4ffb849b))

## [0.5.2] - 2026-05-09

### Added
* Add GitHub Actions workflow for publishing Ruby gem ([`0f8fd88`](https://github.com/kmutahar/jekyll-theme-resume/commit/0f8fd889776fbc4be385c9c55fcbc6dbc04c2938))


### Changed
* Update GitHub Actions workflow for publishing Ruby gem with improved comments and version compatibility ([`5c2095c`](https://github.com/kmutahar/jekyll-theme-resume/commit/5c2095ca4818c34fc75bd214e43f527ba3d4db18))

## [0.5.1] - 2026-05-09

### Changed
* Create dependabot.yml ([`7fbe6bb`](https://github.com/kmutahar/jekyll-theme-resume/commit/7fbe6bb0ed32903468ff6abb11d2f789bda224aa))


### Fixed
* Replace em dash with en dash in HTML and YAML files ([`2f33ecd`](https://github.com/kmutahar/jekyll-theme-resume/commit/2f33ecdd167a3f358c362aaeb2e78ea541623baf))

## [0.5.0] - 2025-11-06

### Added
* Add sample configuration file for bilingual Jekyll resume theme ([`ce25360`](https://github.com/kmutahar/jekyll-theme-resume/commit/ce25360b10bcc8bd1a26e4d3b3abb20a9f0d4e04))

* Add conditional Mastodon link for social verification ([`5bb7f62`](https://github.com/kmutahar/jekyll-theme-resume/commit/5bb7f62586871c904df10003fe17f5f9fce9fce4))

* Add default Arabic months i18n files ([`1c3cac6`](https://github.com/kmutahar/jekyll-theme-resume/commit/1c3cac6c4f0179f0447c746d6d950c3addc33907))


### Changed
* Add project overview for bilingual Jekyll resume theme ([`6708f50`](https://github.com/kmutahar/jekyll-theme-resume/commit/6708f50bc84a6dd62fb7f77e5ed7797d7a97bd08))

* Revise README for bilingual Jekyll resume theme ([`7efff88`](https://github.com/kmutahar/jekyll-theme-resume/commit/7efff88b81d48aa9fac5d70cd4501e05f888e1db))

* Update configuration and data guides for bilingual resume theme ([`9c0f9e9`](https://github.com/kmutahar/jekyll-theme-resume/commit/9c0f9e9c20633970ffeb795cc6bd581caf7a4e62))

* Add Arabic and English resume data samples ([`a86a668`](https://github.com/kmutahar/jekyll-theme-resume/commit/a86a6680bb1384bc58053b502157aa0ae568a039))

* Enhance ar-date include with detailed comments and usage instructions ([`5f297d1`](https://github.com/kmutahar/jekyll-theme-resume/commit/5f297d1f2184b24e7feef8257a8bd9d73295d321))

* Update bilingual-jekyll-resume-theme.gemspec ([`ca84a88`](https://github.com/kmutahar/jekyll-theme-resume/commit/ca84a886bcdb7d8a41c1ed60dffd477207db9739))

* Rename CODE_OF_CONDUCT.MD to CODE_OF_CONDUCT.md ([`127813b`](https://github.com/kmutahar/jekyll-theme-resume/commit/127813b4f6acb867dff576977b899d1b46d20241))

* Use ar-date include for Date of Birth ([`0b2ec85`](https://github.com/kmutahar/jekyll-theme-resume/commit/0b2ec854638e9ceaefddc5b87f6a855cdeb0b596))

## [0.4.0] - 2025-11-05

### Added
* Add logger as explicit dependency ([`327702b`](https://github.com/kmutahar/jekyll-theme-resume/commit/327702beb3383375172401d8f5869ee3ab3f50a9))


### Changed
* Move intro text from _config to data file ([`d026de9`](https://github.com/kmutahar/jekyll-theme-resume/commit/d026de92817b3de76843e18b8770c20136ae0691))

* Make summary optional in association.yml ([`a12cdc8`](https://github.com/kmutahar/jekyll-theme-resume/commit/a12cdc8b9d64db5c3368db6dc270c03a4f353538))

* Make summary optional in recognition.yml ([`34b4661`](https://github.com/kmutahar/jekyll-theme-resume/commit/34b46613dc561a3d1868fdf8d64f7cfd80e02e5d))

* Make description optional in skills.yml ([`601dbf9`](https://github.com/kmutahar/jekyll-theme-resume/commit/601dbf9d81a621366d3a0e46f7079da42aa73e75))

## [0.3.1] - 2025-11-03

### Added
* Add arabic name to resume and config file ([`c6b224d`](https://github.com/kmutahar/jekyll-theme-resume/commit/c6b224d13f8602b8b6f30d0d630817dc6fa55e3a))

## [0.3.0] - 2025-11-03

### Added
* Add SCSS/SASS Guide Documentation ([`77c9e2e`](https://github.com/kmutahar/jekyll-theme-resume/commit/77c9e2e6a83188382e5c26033955438438d78beb))

* Add _config.yml Guide Documentation and a full sample file ([`a08d4f5`](https://github.com/kmutahar/jekyll-theme-resume/commit/a08d4f5675ca902e8a2b5e23a2f3d2b4b5e02902))

* Add _layouts Guide Documentation ([`94830fe`](https://github.com/kmutahar/jekyll-theme-resume/commit/94830fe4ac59667cc1514e45e5fc82af18440b5e))

* Add _includes Guide Documentation ([`b586225`](https://github.com/kmutahar/jekyll-theme-resume/commit/b5862259e2f3d955b71417ec9506b1a778c5440a))

* Add Data Structure Documentation ([`077184c`](https://github.com/kmutahar/jekyll-theme-resume/commit/077184ccd038441c0bfbd7644228d6efd743e75f))

* Add comments to the dynamic data loader ar&en layouts ([`4efe0a4`](https://github.com/kmutahar/jekyll-theme-resume/commit/4efe0a453f2ca767d55f601ca7b02c7372357e74))


### Changed
* Add WARP.md file ([`ff38359`](https://github.com/kmutahar/jekyll-theme-resume/commit/ff383590d783e17af1432d257f4f325b101dc574))

* Upload changelog file ([`d4ba77b`](https://github.com/kmutahar/jekyll-theme-resume/commit/d4ba77b2f17a1d53f9e7e93db57569840fd0e03f))

* Create git-cliff config file ([`ad72acd`](https://github.com/kmutahar/jekyll-theme-resume/commit/ad72acd74d03bc42c8380ff7d0a5362de66fff81))


### Fixed
* Update dynamic data loader to use specific active_resume_path variables for Arabic and English ([`f4852cc`](https://github.com/kmutahar/jekyll-theme-resume/commit/f4852cc01410deb358df978041a980a6e671ed00))

## [0.2.0] - 2025-11-02

### Added
* Add runtime dependency plugins ([`7b21773`](https://github.com/kmutahar/jekyll-theme-resume/commit/7b2177300f683939b9cb045fc3403db962d56193))


### Changed
* Update to version 0.2.0 ([`bd1ab3a`](https://github.com/kmutahar/jekyll-theme-resume/commit/bd1ab3af75041c5b17109bd3c20fd3c971266dd8))


### Fixed
* Correct theme asset paths for gem ([`189fc46`](https://github.com/kmutahar/jekyll-theme-resume/commit/189fc4693cdce7c2195909405bf97e1647d1aad8))

* Fix spec.files ([`92003e7`](https://github.com/kmutahar/jekyll-theme-resume/commit/92003e7865100961b60376bd63daa1b8705e4e81))

## [0.1.1] - 2025-11-02

### Added
* Add assets folder ([`41fbb34`](https://github.com/kmutahar/jekyll-theme-resume/commit/41fbb34708d28da99e1730cffdd485b3e6a1e1af))

* Add _sass folder ([`15ddfe1`](https://github.com/kmutahar/jekyll-theme-resume/commit/15ddfe1245dbc855eebd481d1529bfad28bf6916))

* Add _layouts folder ([`0d2bd65`](https://github.com/kmutahar/jekyll-theme-resume/commit/0d2bd65458760b7787a7fcca16fb9b5d805c8857))

* Add _includes folder ([`8c87411`](https://github.com/kmutahar/jekyll-theme-resume/commit/8c87411b64a9a66870a1e71f13e8d08ed3a29680))

* Add CODE_OF_CONDUCT.MD ([`abea110`](https://github.com/kmutahar/jekyll-theme-resume/commit/abea11088296b04f3f7ccbd845f7268c84b3e9cf))

* Add .whitesource configuration file ([`1958aa0`](https://github.com/kmutahar/jekyll-theme-resume/commit/1958aa04a25ce3aa8c60ddda3a5e9eb9fe43d79c))


### Changed
* Update to version 0.1.1 ([`07c61a7`](https://github.com/kmutahar/jekyll-theme-resume/commit/07c61a70da763e2258020c41c3d2198eb89dc1f7))

* Update gemspec with metadata ([`2c1f1a7`](https://github.com/kmutahar/jekyll-theme-resume/commit/2c1f1a7138314e6481edaa96391640d35349515e))

* Merge pull request #1 from kmutahar/whitesource/configure ([`058663b`](https://github.com/kmutahar/jekyll-theme-resume/commit/058663b282b2b839cb244a80dc4a1ca0cbdaedab))

## [0.1.0] - 2025-11-02

### Changed
* Update gemspec with correct email, summary, and homepage ([`39e7b88`](https://github.com/kmutahar/jekyll-theme-resume/commit/39e7b8872c1092c52261c9524245ebf73804a99e))

* Update LICENSE file with orginal author copyright ([`ff03b02`](https://github.com/kmutahar/jekyll-theme-resume/commit/ff03b02b285c14ac393b0ee71596961fb760c5b9))

* Initial commit (New Theme Template) ([`00af662`](https://github.com/kmutahar/jekyll-theme-resume/commit/00af6628dfec7aefe0ef7d7083bf98c9713a5ffd))

[1.3.0]: https://github.com/kmutahar/jekyll-theme-resume/compare/v1.1.0...v1.3.0
[1.1.0]: https://github.com/kmutahar/jekyll-theme-resume/compare/v1.0.2...v1.1.0
[1.0.2]: https://github.com/kmutahar/jekyll-theme-resume/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/kmutahar/jekyll-theme-resume/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/kmutahar/jekyll-theme-resume/compare/v0.9.0...v1.0.0
[0.9.0]: https://github.com/kmutahar/jekyll-theme-resume/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.com/kmutahar/jekyll-theme-resume/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/kmutahar/jekyll-theme-resume/compare/v0.6.1...v0.7.0
[0.6.1]: https://github.com/kmutahar/jekyll-theme-resume/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/kmutahar/jekyll-theme-resume/compare/v0.5.2...v0.6.0
[0.5.2]: https://github.com/kmutahar/jekyll-theme-resume/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/kmutahar/jekyll-theme-resume/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/kmutahar/jekyll-theme-resume/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/kmutahar/jekyll-theme-resume/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/kmutahar/jekyll-theme-resume/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/kmutahar/jekyll-theme-resume/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/kmutahar/jekyll-theme-resume/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/kmutahar/jekyll-theme-resume/compare/v0.1.0...v0.1.1

<!-- generated by git-cliff -->
