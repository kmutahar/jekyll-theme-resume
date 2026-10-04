# Security Policy

## Supported Versions

We take the security of our resume theme and the dependencies it delivers to our users seriously. Because this theme is distributed as a RubyGem package used to build static sites, we actively patch vulnerabilities discovered in our runtime plugin requirements.

The following versions of `jekyll-theme-resume` currently receive security updates:

| Version | Supported          | Notes                               |
| ------- | ------------------ | ----------------------------------- |
| 1.0.x   | :white_check_mark: | Current stable release branch.      |
| 0.9.x   | :white_check_mark: | Maintenance & security patches.     |
| < 0.9   | :x:                | Legacy branches; please upgrade.    |

## Our Dependency Monitoring

The checked-in [Dependabot configuration](.github/dependabot.yml) schedules daily Bundler dependency updates and weekly GitHub Actions updates. The repository also contains [Mend configuration](.whitesource) with a `LOW` minimum issue severity. These files describe configuration, not proof that a hosted service is enabled or that all alerts are resolved. No CodeQL workflow is checked in.

## Reporting a Vulnerability

If you discover a security vulnerability within this theme or find an unpatched runtime dependency risk, please do not disclose it publicly via GitHub Issues. Instead, report it responsibly through private channels:

1. **Email the Maintainer:** Send a detailed report to **contact@mutahar.me**.
2. **Include Details:** Please provide a description of the vulnerability, the version affected, and a proof-of-concept or steps to reproduce the issue if possible.

### What to Expect

* **Acknowledgment:** You will receive a response acknowledging your report within 48 hours.
* **Triage & Status Updates:** We will update you at least once a week while working on a resolution.
* **Resolution:** If the vulnerability is accepted, a patched release (e.g., a new patch gem version) will be published, and credit will be given to the reporter if desired.
