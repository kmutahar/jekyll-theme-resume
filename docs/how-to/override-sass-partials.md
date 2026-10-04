# Override Sass partials

*Audience: site owners*

Change theme styles from a consuming site without forking the gem. Jekyll prioritizes files in the consuming site's directory over gem theme assets, so a file in your site's `_sass/` folder with the same name as a theme partial replaces it. The partials are listed in the [Sass reference](../reference/sass-tokens.md).

## Replace a partial

1. Find the theme's copy: `bundle info --path jekyll-theme-resume` prints the gem's folder; the partials are in its `_sass/` folder.
2. Copy the complete partial into your site's `_sass/` folder under the same name (for example `_sass/_dark-mode.scss`).
3. Edit your copy and rebuild. A same-path file replaces the whole theme partial, so keep every definition the other partials depend on.

`@use "variables" with (...)` does not work as a shortcut. The partials read only `$white` and `$text_color` from `_variables.scss`, and neither is declared with `!default`, so configuring variables changes nothing. Edit a copied partial instead.

## Change the accent color

The accent color is a CSS custom property, defined once per color scheme in `_sass/_dark-mode.scss`. Copy that partial as described above and change `--accent-color` and `--accent-hover` in each of the four blocks that define them:

1. `:root`: the light defaults.
2. `:root:not([data-color-scheme="light"]):not([data-theme="light"])` inside `@media (prefers-color-scheme: dark)`: the dark palette that follows the visitor's system preference.
3. `:root[data-color-scheme="dark"]` and its aliases: the dark palette when a visitor pins dark mode.
4. `:root[data-color-scheme="light"]` and its aliases: the light palette when a visitor pins light mode.

`--accent-hover-color` and `--social-hover-color` follow `--accent-hover`, so leave them alone. Printed pages reset every color to black and white, so the accent color does not print. Pick a dark-scheme color with enough contrast against the dark background; see [Accessibility decisions](../explanation/accessibility-decisions.md).

To change a language's font, do not edit SCSS; see [Override locale strings](override-locale-strings.md).
