#import "@preview/touying:0.7.4": *
#import "theme.typ": *

#let pc = rgb("#2384a7");

#show: my-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Typesetting with],
    subtitle: [#image("assets/logo.svg", height: 2em)],
    author: [Roopesh O R],
    date: datetime.today(),
  ),
  config-colors(
    primary: pc,
    secondary: pc.darken(20%),
    neutral-lightest: rgb("#ffffff"),
    neutral-darkest: rgb("#000000"),
  ),
)
#show link: set text(fill: pc)
#show raw: it => {
  if it.lang == none {
    raw(lang: "typst", it.text)
  } else {
    it
  }
}
// #show raw: set text(size: 14pt)
#let code-preview(cnt-string, strk: 1pt, rg: 0pt, display-indicator: false, columns: 2) = {
  let inputs = if type(cnt-string) == array { cnt-string } else { (cnt-string,) }
  let cells = ()
  if display-indicator {
    cells = (
      [*Typst code*],
      [*Output*],
    )
  }
  for val in inputs {
    let clean-val = val.trim()
    cells.push([
      #raw(clean-val, lang: "typst")
    ])
    cells.push([
      #set text(size: .8em)
      #eval(clean-val, mode: "markup")
    ])
  }

  table(
    columns: columns,
    stroke: strk,
    row-gutter: rg,
    align: (left, top),
    ..cells
  )
}
#title-slide()
#set document(title: "Typesetting with Typst")
== Outline <touying:hidden>

#components.adaptive-columns(
  outline(title: none, indent: 1em),
)

= Introduction
== What is Typesetting?
#grid(
  columns: 2,
  column-gutter: 20pt,
  [*Typesetting* is the composition of text for publication, display, or distribution by means of arranging physical type (or sort) in mechanical systems or glyphs in digital systems representing characters
    #v(1cm)
    #image("assets/image.jpg", height: 7cm)
  ],
  image("assets/image-1.jpg"),
)

== Various systems for Typesetting
#set table.cell(inset: 10pt)
#align(center)[
  #v(-1cm)
  #table(
    columns: 2,
    column-gutter: 40pt,
    stroke: none,
    [*WYSIWYG \ (What you see is what you get)*], [*WYSIWYM \ (what you see is what you mean)*],

    [Emphasis on presentation], [Emphasis on structure/"semantics"],

    [
      #box()[#image("assets/Microsoft Word 2025 logo - Brandlogos.svg", height: 2cm)]
      #h(.5cm)
      #box()[#image("assets/LibreOffice_7.5_Writer_Icon.svg", height: 2cm)]
    ],
    [
      #box[#image("assets/latex-project-logo.svg", height: 1.5cm)]
      #h(.5cm)
      #box[#image("assets/Markdown-mark.svg", height: 1.5cm)]
      #h(.5cm)
      #box[#image("assets/logo.svg", height: 1.3cm)]
    ],

    [
      #block(stroke: 2pt)[#image("assets/image-2.png")]
    ],
    [
      #block(stroke: 2pt)[#image("assets/image-6.jpg")]
    ],
  )
]

== Why focus on structure
- Separation of content and presentation
- Change appearance at "scale"
- https://typst.app/#how-does-it-work

== Why Typst?
- Extremly fast
- Can be exported to PDF, HTML, PNG
- Emerging replacement for traditional Typesetting systems
- Create figures, charts in Typst itsef

= Basic Componets
== Formatting
#v(-.4cm)
#box[#code-preview(
  display-indicator: true,
  (
    "*Bold*",
    "_Italic_",
    "#underline[Italic]",
    "Inline code (monospaced): `function()`",
    "Block code:
```py
print(\"Hello \" + str(10))
```
",
    "#text(
  font: \"Impact\",
  size: 20pt, fill: red,
)[Custom font]
",
  ),
)]
== Lists
#code-preview(
  (
    "
Unordered list:
- item 1
- item 2
- item 3",
    "Ordered list:
+ item 1
+ item 2
+ item 3",
    "Nested list:
+ item 1
	- item 1.1
	- item 1.3
+ item 3
",
  ),
  strk: none,
)
== Alignment
- Text: justified or not
- Content: center, left, right

== Heading
Supports unlimited nested headings, and automatic numbering also
#table(
  column-gutter: 100pt,
  stroke: none,
  columns: 2,
  [
    ```typ
    #tile("Title")
    = Heading 1
    == Heading 2
    === Heading 3
    ==== Heading 4
    ```

    Or:
    ```typ
    #heading(level: 1)[Heading 1]
    #heading(level: 2)[Heading 2]
    #heading(level: 3)[Heading 3]
    #heading(level: 4)[Heading 4]
    ```
  ],
  block(stroke: 1pt)[#image("assets/image-3.png")],
)

== Table
#code-preview(strk: none, rg: 20pt, (
  "
#table(
	columns: 3,
	[col 1], [col 2], [col 3],
	[1], [2], [3],
	[4], [1], [2],
)
",
  "
#table(
	columns: (1fr, 3cm, 5cm),
	[*header*], [*Header2*], [*Header3*],
	[item1], [item2], [item3],
	[item1], [item2], [item3],
	[item1], [item2], [item3],
)",
))
== Figures
#grid(
  columns: 2,
  column-gutter: 60pt,
  [
    ```
      #figure(
    		image("image.png", width: 13cm),
    		caption: [image caption],
    	)
    ```
  ],
  [
    #figure(
      image("assets/image.jpg", width: 13cm),
      caption: [image caption],
    )
  ],
)

== Column layout
```
#columns(2)[
	#lorem(100)
]```
#columns(2)[
  #lorem(100)
]
== Grid layout

#grid(
  columns: 2,
  column-gutter: 100pt,
  [
    ```
    #grid(
    	columns: 3,
    	row-gutter: 20pt,
    	column-gutter: 10pt,
    	[ #image("logo.svg") ],
    	[ #image("logo.svg") ],
    	[ #image("logo.svg") ],
    	[ #image("logo.svg") ],
    	[ #image("logo.svg") ],
    	[ #image("logo.svg") ],
    	[ #image("logo.svg") ],
    	[ #image("logo.svg") ],
    )```
  ],
  [
    #grid(
      columns: 3,
      column-gutter: 10pt,
      row-gutter: 20pt,
      image("assets/Markdown-mark.svg", width: 2cm),
      image("assets/Markdown-mark.svg", width: 2cm),
      image("assets/Markdown-mark.svg", width: 2cm),

      image("assets/Markdown-mark.svg", width: 2cm),
      image("assets/Markdown-mark.svg", width: 2cm),
      image("assets/Markdown-mark.svg", width: 2cm),

      image("assets/Markdown-mark.svg", width: 2cm), image("assets/Markdown-mark.svg", width: 2cm),
    )
  ],
)

== Equations
- inline mode: `$x+y$`: $x+y$
- block mode: `$ x+y $`: $ x+y $
#pagebreak()
#code-preview((
  "$ x+y $",
  "$ sin(x) $",
  "$ 1/x $",
  "$ (x^2+y^2)/(2x) $",
  "$ y = (-b plus.minus sqrt(b^2 - 4a c))/(2a) $",
  "$ sum_(n=1)^infinity 1/n^2 = pi^2/6 $",
  "$
lim_(A -> infinity)
integral_0^(A) 1/(log_10(x))d x
$",
  "$ d^2/(d x^2) cos^2(x) $",
))
#pagebreak()
=== Aligning equations
#code-preview(
  (
    "$
y &= (x+a)(x+b)\
	&= x^2 + b x + a x + a b\
	&= x^2 + a b + x(a+b)
$"
  ),
)
#pagebreak()
=== Matrix
#code-preview(
  (
    "$
A = mat(
	delim: \"[\",
	1, 2, 4;
	1, 3, 4;
	5, 6, 7
) mat(x; y; z, delim: \"[\")
= mat(1; 2; 3)
$"
  ),
)
= Styling and Settings
== Set & Show rule
- For customizing the appearance of Elements
#code-preview(
  "
#set text(
  font: \"New Computer Modern\",
	size: 16pt
)
#show heading.where(level: 3) : set text(
	size: 20pt
)
#set list(marker: [--])
=== Test Code
#text[With set rules, you can style your document.]
- list
- list
",
)
== Page settings
```typ
#set page(
	numbering: "a",               // numbering style
	fill: rgb("#fff2f2")          // background color
	background: image("logo.svg") // other background stuff like watermarks, etc
)
```
#pagebreak()
```typ
#set page(
	// Header and footer
	header: [
		#image("assets/logo.svg")
	],

	footer: [
		Typst presentation
	]
)
```


= Scripting

- All Typst contents are functions: `#text[]`, `#link[]`, `#image[]`, ...
- The contents can be stored in variables
#pagebreak()
== Variables & Conditional statemnts
#code-preview(
  "#let x = 0
#if x == 1 {
  text(\"x is 1\")
} else if x == 0 {
  text(\"x is 0\")
} else {
  text(\"x is something else\")
}",
)
#pagebreak()

== Loops
#code-preview(
  "#for i in range(1, 11) {
	text[#i]
}",
)

#pagebreak()
#code-preview("
#let c = 7
#for i in range(1, 11) {
  [#i $times$ #c = #(i * c) \ ]
}")
#pagebreak()
== Functions
#code-preview(
  "
#let badge = (content, color: red) => {
	box(
		stroke: 2pt + color,
		inset: 15pt,
		radius: 10pt,
	)[#content]
}

#badge[Badge 1]
#badge(color: green)[Badge 2]
#badge(color: rgb(\"#169696\"))[Badge 3]
",
)

#pagebreak()
#let r = "#let isPrime = x => {
	let half = int(x / 2);
	for j in range(2, half) {
		if (calc.rem(x, j) == 0) {
			return false;
		}
	}
	return true;
}

#for i in range(2, 500) {
	if isPrime(i) {
		text[#i, ]
	}
}
";
#table(
  columns: (1fr, 1fr),
  raw(r,lang: "typst"),
)
#pagebreak()
#code-preview(
  r,
  columns: (1fr, 1fr),
)

= Packages
- The functionality of Typst can be extended via packages: https://typst.app/universe
- For export formats, templates, figures, advanced graphics, data visualization, etc.
#heading(depth: 2, outlined: false)[CeTz: For drawing]
#align(center)[
  #v(-25pt)
  https://diagrams.janosh.dev/
  #v(-10pt)
  #image("assets/cetz.jpg")
]
#heading(depth: 2, outlined: false)[Lilaq: For data visualization]
#align(center)[
  #v(-25pt)
  https://lilaq.org
  #v(-10pt)
  #image("assets/lilaq.jpg")
]
#heading(depth: 2, outlined: false)[Touying: For presentation]
#align(center)[
  #v(-25pt)
  https://typst.app/universe/package/touying
  #v(-10pt)
  #image("assets/toy.jpg")
]
#heading(depth: 2, outlined: false)[Alchemist: For creating chemical diagrams]
#align(center)[
  #v(-25pt)
  https://typst.app/universe/package/alchemist
  #v(-10pt)
  #image("assets/image-1.png")
]
#heading(depth: 2, outlined: false)[Mesa: Draw semiconductor devices and fabrication process]
#align(center)[
  #v(-25pt)
  https://typst.app/universe/package/mesa
  #v(-10pt)
  #image("assets/image-4.jpg")
]
#heading(depth: 2, outlined: false)[Maquette: Render 3D models as SVG or PNG images]
#align(center)[
  #v(-25pt)
  https://typst.app/universe/package/maquette
  #v(-10pt)
  #image("assets/image-5.jpg")
]

#focus-slide()[
  #place(left + top, dy: .5cm)[#image("assets/books.webp", width: 5.3cm)]
  #place(left + top, dx: 11.5cm, dy: .5cm)[#image("assets/spec.webp", width: 5.3cm)]
  #place(left + top, dx: 23cm, dy: .5cm)[#image("assets/letter.webp", width: 5.3cm)]
  #place(left + top, dy: 6cm)[#image("assets/report.webp", width: 5cm)]
  #place(left + top, dy: 12cm)[#image("assets/thesis.webp", width: 5.3cm)]
  #place(left + top, dx: 11.5cm, dy: 12cm)[#image("assets/presentation.webp", width: 5cm)]
  #place(left + top, dx: 23.3cm, dy: 12cm)[#image("assets/math-heavy-docs.webp", width: 5.3cm)]
  #place(left + top, dx: 23.3cm, dy: 6cm)[#image("assets/cv.webp", width: 5.3cm)]
  #place(left + top)[#rect(
    width: 100%,
    height: 100%,
    fill: pc.transparentize(20%),
  )]
  #text(weight: "semibold")[Thank you]
]
