#import "settings.typ": fit-to-page, numbered_eq, show_eqnum
= Formatting
Typst follows markdown like syntax


*Bold*,
_italic_,
#underline[underline]
_*bold italic*_

inline `monospace`

```cpp
// block code
#include <iostream>
int main () {
	return 0;
}
```
#text(size: 13pt)[custom text size (not recommended)]

to write hash: \#

To reference a source: @artix-7

To reference a section: @sec:intro

The formatting for how refs are shown in controlled in `settings.typ`

Use `#pagebreak()` to start new page

=== lists
- Unnumbered
- Unnumbered
- Unnumbered
- Unnumbered

+ Numbered
  - Un Numbered
+ Numbered
+ Numbered
+ Numbered

=== Table
#table(
  columns: 3,
  [*header*], [*Header2*], [*Header3*],
  [item1], [item2], [item3],
  [item1], [item2], [item3],
  [item1], [item2], [item3],
)

to span whole width of page (use `fr` units):
#table(
  columns: (1fr, 3cm, 5cm),
  [*header*], [*Header2*], [*Header3*],
  [item1], [item2], [item3],
  [item1], [item2], [item3],
  [item1], [item2], [item3],
)
=== Numbered table

to change caption position see the end of `settings.typ`
#figure(
  caption: [Table with different stroke style],
  table(
    columns: (1fr, 3cm, 5cm),
		stroke: none,
    [*header*], table.vline(), [*Header2*], table.vline(), [*Header3*],
		table.hline(),
    [item1], [item2], [item3],
    [item1], [item2], [item3],
    [item1], [item2], [item3],
  ),
)<tab:table-label1>

This time a reference was added to table (see code above) to call it: @tab:table-label1

=== Figure
#figure(
  caption: [img caption],
  image(
    "images/Cooley-tukey-general.png",
    width: 8cm,
  ),
)<img:myimg>

You can also `cetz` (https://typst.app/universe/package/cetz/) to create diagrams in typst itself. See https://github.com/roopeshor/Typesetting/tree/main/Reports/Internship-3 For examples


Some pages needs to cover maximum area of page, to show everything clearly. Manually putting width or height is just hard. And if the image height is more than the page height, you need manual scaling. For that `fit-to-page` function from `settings.typ` can be used, as shown in next page.

Best practice is to put all images in `images/` folder.

// #pagebreak()
#figure(
  caption: [An image that maximally covers the page. Use fit-to-page function from settings.typ],
	fit-to-page(image(
    "images/Citric_acid_cycle_with_aconitate.svg",
  )),
)<img:myimg>

=== column layout

#grid(
	columns: (1fr, 1fr),
	column-gutter: 15pt,
	[#lorem(50)],
	[#lorem(50)]
)

=== math

Inline math: $sum_(n=0)^infinity n^(-2)$

block math:
$
  sum_(n=0)^infinity n^(-2) = pi^2 / 6
$

aligned equations:
$
  (-b plus.minus sqrt(b^2 - 4a c)) / (2a) & = -b/(2a) plus.minus sqrt(b^2 - 4a c) / (2a) \
		& = -b/(2a) plus.minus sqrt((b^2 - 4a c) / (4a^2))\
		& = -b/(2a) plus.minus sqrt(b^2 / (4a^2) -  (4a c)/(4a^2))\
		& = -b/(2a) plus.minus sqrt(b^2 / (4a^2) -  c/a)\
$

$
	integral_(x=0)^infinity d/(d x) x^2 d x
$

if multiple letters are there, do seperate them by space, or typst will treat it as some variable.

==== matix: 
$
	= mat(
		delim: "[",
		1, 2, 4;
		1, 3, 4;
		5, 6, 7
	)mat(
		delim: "[",
		x;
		y;
		z
	) = mat(
		1;
		2;
		3
	)
$

==== numbered equation
#numbered_eq($X(k) = sum_(n=0)^5 exp(-(2pi)/5 n k) = 0$)<eq:label1>

To ref it: @eq:label1 or to get just number: #show_eqnum(<eq:label1>). Formatting can be changed in `settings.typ`