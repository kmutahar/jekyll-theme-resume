# SVG Icon Attribution

Every SVG in this folder comes from [Lineicons](https://lineicons.com), licensed under the
[MIT License](https://lineicons.com/license). Packaged with the gem for offline/attribution
purposes; not built into any consuming site's `_site/` output (Jekyll never copies `_includes/`
into a build — files here are only reachable through `{% include %}`).

Files were merged into this single flat folder from two previously separate, version-numbered
folders. Original folder (version) each file shipped in:

| File | Original folder (version) |
|---|---|
| `phone.svg` | `vendors/lineicons-v4.0/` |
| `postcard.svg` | `vendors/lineicons-v4.0/` |
| `envelope.svg` | `vendors/lineicons-v5.1/` |
| `github.svg` | `vendors/lineicons-v5.1/` |
| `linkedin.svg` | `vendors/lineicons-v5.1/` |
| `telegram.svg` | `vendors/lineicons-v5.1/` |
| `x.svg` | `vendors/lineicons-v5.1/` |
| `medium.svg` | `vendors/lineicons-v5.1/` |
| `dribbble-symbol.svg` | `vendors/lineicons-v5.1/` |
| `facebook.svg` | `vendors/lineicons-v5.1/` |
| `instagram.svg` | `vendors/lineicons-v5.1/` |
| `globe-1.svg` | `vendors/lineicons-v5.1/` |
| `whatsapp.svg` | `vendors/lineicons-v5.1/` |
| `dev.svg` | `vendors/lineicons-v5.1/` |
| `flickr.svg` | `vendors/lineicons-v5.1/` |
| `pinterest.svg` | `vendors/lineicons-v5.1/` |
| `youtube.svg` | `vendors/lineicons-v5.1/` |
| `discord.svg` | `vendors/lineicons-v5.1/` |
| `behance.svg` | `vendors/lineicons-v5.1/` |

To add a new icon (from Lineicons or elsewhere), drop the SVG into this folder and reference it
by filename — from `_data/social_networks.yml` for a social platform, or directly via
`{% include vendors/svg-icons/<name>.svg %}` elsewhere. If it comes from a licensed icon set,
add a row to the table above (or a new one, if the source isn't Lineicons).
