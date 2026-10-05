# Print your resume

*Audience: site owners*

Print a resume page, or save it as a PDF, with clean page breaks. The theme's print stylesheet ([`_sass/_print.scss`](../../_sass/_print.scss)) does the layout; you only choose the browser settings. For the rules behind it, see the [print rules table](../reference/sass-tokens.md#print-rules).

## Set up the print dialog

1. Open the resume page and press `Ctrl+P` (`Cmd+P` on macOS).
2. Set the options:

   | Option | Value |
   |---|---|
   | Margins | Default |
   | Scale | 100% |
   | Background graphics | Off |
   | Headers and footers | Off |

3. Choose a printer, or choose **Save as PDF** as the destination.
4. Print or save.

The paper size follows the dialog: pick A4 or Letter there. The theme sets its own page margins, so keep Margins on Default.

## Do not edit the data to fit pages

Do not add blank lines, shorten entries, or reword text to move a page break. The theme keeps each section heading with its first entry and keeps each entry whole. An entry that is longer than a page still splits, because nothing else can be done with it.

## What is not printed

- The language switcher and the dark mode toggle.
- Anything marked `no-print`.
- The page prints black on white, whatever the screen theme.

Printed only: the plain-text social links when `resume_print_social_links` is `true`, and the canonical URL footer when `enable_live` is `false`. See the [config reference](../reference/config.md).

## Check the result

1. Open the print preview for each language you publish.
2. Look for a heading alone at the bottom of a page, or an entry cut in half.
3. For Arabic and Urdu, check that lines do not overlap.
